#!/usr/bin/env python3
import sys
import os
import re
import random
from PyQt5.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, 
                             QLabel, QLineEdit, QPushButton, QTabWidget, QTableWidget, 
                             QTableWidgetItem, QHeaderView, QAbstractItemView, QFrame)
from PyQt5.QtCore import Qt, pyqtSignal, QPoint, QPropertyAnimation, QRect
from PyQt5.QtGui import QFont, QColor, QPalette

CONFIG_PATH = os.path.expanduser("~/.config/hypr/config/keybindings.conf")

OBSIDIAN_BG = "#171217"
OBSIDIAN_SURFACE = "#1e1a1e"
OBSIDIAN_ACCENT = "#c4a7d7"
OBSIDIAN_TEXT = "#eae0e7"
OBSIDIAN_BORDER = "#3a343a"

class FramelessWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowFlags(Qt.FramelessWindowHint | Qt.Window)
        self.setAttribute(Qt.WA_TranslucentBackground)
        self.resize(900, 650)

        self._central = QWidget()
        self.setCentralWidget(self._central)
        self._central.setObjectName("mainWidget")
        
        self._layout = QVBoxLayout(self._central)
        self._layout.setContentsMargins(0, 0, 0, 0)
        self._layout.setSpacing(0)

        self._title_bar = QWidget()
        self._title_bar.setObjectName("titleBar")
        self._title_layout = QHBoxLayout(self._title_bar)
        self._title_layout.setContentsMargins(10, 5, 10, 5)

        self._title_label = QLabel("Hyprland Shortcut Manager")
        self._title_label.setFont(QFont("JetBrains Mono", 12, QFont.Bold))
        self._title_label.setStyleSheet(f"color: {OBSIDIAN_TEXT};")
        
        self._close_btn = QPushButton("✕")
        self._close_btn.setFixedSize(30, 30)
        self._close_btn.clicked.connect(self.close)
        self._close_btn.setStyleSheet(f"""
            QPushButton {{ background-color: transparent; color: {OBSIDIAN_TEXT}; border: none; font-size: 14px; }}
            QPushButton:hover {{ background-color: #ff5555; }}
        """)

        self._title_layout.addWidget(self._title_label)
        self._title_layout.addStretch()
        self._title_layout.addWidget(self._close_btn)

        self._layout.addWidget(self._title_bar)

        self.setStyleSheet(f"""
            #mainWidget {{
                background-color: {OBSIDIAN_BG};
                border: 1px solid {OBSIDIAN_BORDER};
                border-radius: 8px;
            }}
            #titleBar {{
                background-color: {OBSIDIAN_SURFACE};
                border-top-left-radius: 8px;
                border-top-right-radius: 8px;
                border-bottom: 1px solid {OBSIDIAN_BORDER};
            }}
        """)

        self.oldPos = self.pos()

    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton and event.pos().y() < self._title_bar.height():
            self.oldPos = event.globalPos()

    def mouseMoveEvent(self, event):
        if hasattr(self, 'oldPos') and event.buttons() == Qt.LeftButton and event.pos().y() < self._title_bar.height():
            delta = QPoint(event.globalPos() - self.oldPos)
            self.move(self.x() + delta.x(), self.y() + delta.y())
            self.oldPos = event.globalPos()


class ShortcutManager(FramelessWindow):
    def __init__(self):
        super().__init__()
        self.shortcuts = []
        self.lines = []
        
        self.init_ui()
        self.load_config()

    def init_ui(self):
        font = QFont("JetBrains Mono", 10)
        QApplication.setFont(font)

        self.content_widget = QWidget()
        self.content_layout = QVBoxLayout(self.content_widget)
        self.content_layout.setContentsMargins(15, 15, 15, 15)
        self.content_layout.setSpacing(10)
        
        self._layout.addWidget(self.content_widget)

        self.search_bar = QLineEdit()
        self.search_bar.setPlaceholderText("Search shortcuts (e.g., 'firefox', 'SUPER D')...")
        self.search_bar.textChanged.connect(self.filter_shortcuts)
        self.search_bar.setStyleSheet(f"""
            QLineEdit {{
                background-color: {OBSIDIAN_SURFACE};
                color: {OBSIDIAN_TEXT};
                border: 1px solid {OBSIDIAN_BORDER};
                border-radius: 4px;
                padding: 8px;
            }}
            QLineEdit:focus {{
                border: 1px solid {OBSIDIAN_ACCENT};
            }}
        """)
        self.content_layout.addWidget(self.search_bar)

        self.tabs = QTabWidget()
        self.tabs.setStyleSheet(f"""
            QTabWidget::pane {{
                border: 1px solid {OBSIDIAN_BORDER};
                border-radius: 4px;
                background-color: {OBSIDIAN_SURFACE};
            }}
            QTabBar::tab {{
                background-color: {OBSIDIAN_BG};
                color: {OBSIDIAN_TEXT};
                padding: 8px 16px;
                margin-right: 2px;
                border-top-left-radius: 4px;
                border-top-right-radius: 4px;
                border: 1px solid transparent;
            }}
            QTabBar::tab:selected {{
                background-color: {OBSIDIAN_SURFACE};
                border: 1px solid {OBSIDIAN_BORDER};
                border-bottom-color: {OBSIDIAN_SURFACE};
                color: {OBSIDIAN_ACCENT};
            }}
            QTabBar::tab:hover:!selected {{
                background-color: #2a252a;
            }}
        """)
        self.content_layout.addWidget(self.tabs)

        self.practice_tab = QWidget()
        self.practice_layout = QVBoxLayout(self.practice_tab)
        
        self.score_label = QLabel("Score: 0 | Streak: 0")
        self.score_label.setAlignment(Qt.AlignCenter)
        self.score_label.setStyleSheet(f"color: {OBSIDIAN_ACCENT}; font-size: 16px; font-weight: bold;")
        self.practice_layout.addWidget(self.score_label)

        self.prompt_label = QLabel("Click 'Start Practice' to begin")
        self.prompt_label.setAlignment(Qt.AlignCenter)
        self.prompt_label.setStyleSheet(f"color: {OBSIDIAN_TEXT}; font-size: 20px;")
        self.practice_layout.addWidget(self.prompt_label)

        self.answer_input = QLineEdit()
        self.answer_input.setPlaceholderText("Type the shortcut (e.g. SUPER T) and press Enter")
        self.answer_input.returnPressed.connect(self.check_practice_answer)
        self.answer_input.setStyleSheet(self.search_bar.styleSheet())
        self.answer_input.setAlignment(Qt.AlignCenter)
        self.practice_layout.addWidget(self.answer_input)

        self.start_btn = QPushButton("Start Practice")
        self.start_btn.clicked.connect(self.start_practice)
        self.start_btn.setStyleSheet(f"""
            QPushButton {{
                background-color: {OBSIDIAN_ACCENT};
                color: {OBSIDIAN_BG};
                border: none;
                border-radius: 4px;
                padding: 10px;
                font-weight: bold;
            }}
            QPushButton:hover {{
                background-color: #d1b8e1;
            }}
        """)
        self.practice_layout.addWidget(self.start_btn)
        
        self.practice_layout.addStretch()

        self.score = 0
        self.streak = 0
        self.current_practice = None

        self.save_btn = QPushButton("Save Changes")
        self.save_btn.clicked.connect(self.save_config)
        self.save_btn.setStyleSheet(self.start_btn.styleSheet())
        self.content_layout.addWidget(self.save_btn)
        self.save_btn.hide()

    def load_config(self):
        if not os.path.exists(CONFIG_PATH):
            return

        with open(CONFIG_PATH, 'r') as f:
            self.lines = f.readlines()

        self.shortcuts = []
        current_category = "General"

        for i, line in enumerate(self.lines):
            line = line.strip()
            cat_match = re.match(r'^#\s*──\s*(.*?)\s*──', line)
            if cat_match:
                current_category = cat_match.group(1).strip()
                continue
                
            bind_match = re.match(r'^(bind[a-z]*)\s*=\s*(.*)', line)
            if bind_match:
                bind_type = bind_match.group(1)
                bind_content = bind_match.group(2)
                
                parts = [p.strip() for p in bind_content.split(',', 3)]
                if len(parts) >= 3:
                    mods = parts[0]
                    key = parts[1]
                    dispatcher = parts[2]
                    args = parts[3] if len(parts) > 3 else ""
                    
                    display_mods = mods.replace('$mainMod', 'SUPER')
                    
                    self.shortcuts.append({
                        'category': current_category,
                        'bind_type': bind_type,
                        'mods': mods,
                        'display_mods': display_mods,
                        'key': key,
                        'dispatcher': dispatcher,
                        'args': args,
                        'line_num': i
                    })

        self.populate_tabs()

    def populate_tabs(self):
        while self.tabs.count() > 0:
            self.tabs.removeTab(0)

        categories = {}
        for sc in self.shortcuts:
            cat = sc['category']
            if cat not in categories:
                categories[cat] = []
            categories[cat].append(sc)

        for cat, scs in categories.items():
            tab = self.create_category_tab(scs)
            self.tabs.addTab(tab, cat)

        self.tabs.addTab(self.practice_tab, "Practice / Training")

    def create_category_tab(self, shortcuts):
        table = QTableWidget()
        table.setColumnCount(4)
        table.setHorizontalHeaderLabels(["Modifiers", "Key", "Dispatcher", "Command / Args"])
        table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        table.horizontalHeader().setSectionResizeMode(1, QHeaderView.ResizeToContents)
        table.setSelectionBehavior(QAbstractItemView.SelectRows)
        table.verticalHeader().setVisible(False)
        table.setEditTriggers(QAbstractItemView.DoubleClicked)
        
        table.setStyleSheet(f"""
            QTableWidget {{
                background-color: {OBSIDIAN_SURFACE};
                color: {OBSIDIAN_TEXT};
                border: none;
                gridline-color: {OBSIDIAN_BORDER};
            }}
            QHeaderView::section {{
                background-color: {OBSIDIAN_BG};
                color: {OBSIDIAN_ACCENT};
                padding: 4px;
                border: 1px solid {OBSIDIAN_BORDER};
            }}
            QTableWidget::item:selected {{
                background-color: #3a3245;
                color: {OBSIDIAN_TEXT};
            }}
        """)

        table.setRowCount(len(shortcuts))
        for row, sc in enumerate(shortcuts):
            self._set_row(table, row, sc)
            
        table.cellChanged.connect(lambda row, col, tbl=table: self.on_cell_changed(row, col, tbl))
        table.setProperty("shortcuts", shortcuts)
        
        return table

    def _set_row(self, table, row, sc):
        table.blockSignals(True)
        item_mods = QTableWidgetItem(sc['display_mods'])
        item_key = QTableWidgetItem(sc['key'])
        item_disp = QTableWidgetItem(sc['dispatcher'])
        item_args = QTableWidgetItem(sc['args'])
        
        item_mods.setData(Qt.UserRole, sc)
        
        table.setItem(row, 0, item_mods)
        table.setItem(row, 1, item_key)
        table.setItem(row, 2, item_disp)
        table.setItem(row, 3, item_args)
        table.blockSignals(False)

    def on_cell_changed(self, row, col, table):
        self.save_btn.show()

    def save_config(self):
        for i in range(self.tabs.count() - 1):
            table = self.tabs.widget(i)
            shortcuts = table.property("shortcuts")
            if not shortcuts:
                continue
            
            for row in range(table.rowCount()):
                sc = table.item(row, 0).data(Qt.UserRole)
                line_num = sc['line_num']
                
                disp_mods = table.item(row, 0).text()
                mods = disp_mods
                if sc['mods'] == '$mainMod' and disp_mods == 'SUPER':
                    mods = '$mainMod'
                elif disp_mods == 'SUPER' and '$mainMod' in "".join(self.lines):
                    mods = '$mainMod'
                    
                key = table.item(row, 1).text()
                disp = table.item(row, 2).text()
                args = table.item(row, 3).text()
                
                bind_type = sc['bind_type']
                if args:
                    new_line = f"{bind_type} = {mods}, {key}, {disp}, {args}\n"
                else:
                    new_line = f"{bind_type} = {mods}, {key}, {disp}\n"
                    
                self.lines[line_num] = new_line
                
        with open(CONFIG_PATH, 'w') as f:
            f.writelines(self.lines)
            
        self.save_btn.hide()
        self.load_config()

    def filter_shortcuts(self, text):
        search_term = text.lower()
        for i in range(self.tabs.count() - 1):
            table = self.tabs.widget(i)
            if not table.property("shortcuts"):
                continue
            for row in range(table.rowCount()):
                match = False
                for col in range(table.columnCount()):
                    item = table.item(row, col)
                    if item and search_term in item.text().lower():
                        match = True
                        break
                table.setRowHidden(row, not match)

    def start_practice(self):
        if not self.shortcuts:
            return
            
        self.start_btn.setText("Skip / Next Shortcut")
        self.next_practice()
        
    def next_practice(self):
        self.current_practice = random.choice(self.shortcuts)
        action = f"{self.current_practice['dispatcher']} {self.current_practice['args']}".strip()
        self.prompt_label.setText(f"Action: {action}\nWhat is the keybinding?")
        self.answer_input.clear()
        self.answer_input.setFocus()
        
    def check_practice_answer(self):
        if not self.current_practice:
            return
            
        user_ans = self.answer_input.text().strip().upper()
        correct_mods = self.current_practice['display_mods'].upper()
        correct_key = self.current_practice['key'].upper()
        
        correct_str1 = f"{correct_mods} {correct_key}".replace("  ", " ").strip()
        correct_str2 = f"{correct_mods} + {correct_key}".replace("  ", " ").strip()
        
        if user_ans == correct_str1 or user_ans == correct_str2:
            self.score += 10
            self.streak += 1
            self.prompt_label.setStyleSheet(f"color: #50fa7b; font-size: 20px;")
            self.prompt_label.setText(f"Correct! ({correct_str1})")
        else:
            self.streak = 0
            self.prompt_label.setStyleSheet(f"color: #ff5555; font-size: 20px;")
            self.prompt_label.setText(f"Incorrect. It was: {correct_str1}")
            
        self.score_label.setText(f"Score: {self.score} | Streak: {self.streak}")
        
        from PyQt5.QtCore import QTimer
        QTimer.singleShot(1500, self.reset_prompt_color_and_next)
        
    def reset_prompt_color_and_next(self):
        self.prompt_label.setStyleSheet(f"color: {OBSIDIAN_TEXT}; font-size: 20px;")
        self.next_practice()

if __name__ == '__main__':
    app = QApplication(sys.argv)
    app.setApplicationName("shortcut-manager")
    app.setDesktopFileName("shortcut_manager")
    app.setStyle('Fusion')
    window = ShortcutManager()
    window.show()
    sys.exit(app.exec_())
