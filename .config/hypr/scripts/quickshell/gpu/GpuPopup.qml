import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import Quickshell
import Quickshell.Io
import "../"

Item {
    id: root
    focus: true

    Scaler {
        id: scaler
        currentWidth: Screen.width
    }
    function s(val) { return scaler.s(val); }

    MatugenColors { id: _theme }
    readonly property color base: _theme.base
    readonly property color mantle: _theme.mantle
    readonly property color surface0: _theme.surface0
    readonly property color surface1: _theme.surface1
    readonly property color text: _theme.text
    readonly property color subtext0: _theme.subtext0
    readonly property color overlay1: _theme.overlay1
    readonly property color mauve: _theme.mauve
    readonly property color green: _theme.green
    readonly property color blue: _theme.blue
    readonly property color yellow: _theme.yellow
    readonly property color red: _theme.red
    readonly property color peach: _theme.peach

    property string currentMode: "hybrid" // nvidia, hybrid, integrated
    property string currentProfile: "balanced" // performance, balanced, power-saver
    property string gpuName: "NVIDIA GeForce RTX 3050"
    property string vramTotal: "6144"
    property string vramUsed: "0"
    property string gpuTemp: "50"
    property string gpuUsage: "0"
    property string powerDraw: "0"
    property string driverVer: "580.0"

    property bool isSwitching: false

    Process {
        id: gpuFetcher
        command: ["bash", "-c", "~/.config/hypr/scripts/quickshell/gpu/gpu_fetch.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let out = this.text ? this.text.trim() : "";
                if (!out) return;
                let parts = out.split("|");
                if (parts.length >= 3) {
                    root.currentMode = parts[0].trim();
                    root.currentProfile = parts[1].trim();
                    let gparts = parts[2].split(",");
                    if (gparts.length >= 7) {
                        root.gpuName = gparts[0].trim();
                        root.vramTotal = gparts[1].trim();
                        root.vramUsed = gparts[2].trim();
                        root.gpuTemp = gparts[3].trim();
                        root.gpuUsage = gparts[4].trim();
                        root.powerDraw = gparts[5].trim();
                        root.driverVer = gparts[6].trim();
                    }
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            gpuFetcher.running = false;
            gpuFetcher.running = true;
        }
    }

    function switchGpu(mode) {
        root.isSwitching = true;
        root.currentMode = mode;
        Quickshell.execDetached(["bash", "-c", "~/.config/hypr/scripts/quickshell/gpu/gpu_switch.sh " + mode]);
        switchTimer.restart();
    }

    Timer {
        id: switchTimer
        interval: 2000
        onTriggered: {
            root.isSwitching = false;
            gpuFetcher.running = false;
            gpuFetcher.running = true;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: root.base
        radius: root.s(16)
        border.width: 1
        border.color: Qt.rgba(root.text.r, root.text.g, root.text.b, 0.12)
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.s(20)
            spacing: root.s(14)

            // ─── Header ───
            RowLayout {
                Layout.fillWidth: true
                spacing: root.s(12)

                Rectangle {
                    width: root.s(44); height: root.s(44)
                    radius: root.s(12)
                    color: Qt.rgba(root.green.r, root.green.g, root.green.b, 0.2)
                    border.width: 1
                    border.color: root.green

                    Text {
                        anchors.centerIn: parent
                        text: "󰢮"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: root.s(24)
                        color: root.green
                    }
                }

                ColumnLayout {
                    spacing: root.s(2)
                    Layout.fillWidth: true

                    RowLayout {
                        Text {
                            text: "GPU & Graphics Profile"
                            font.family: "JetBrains Mono"
                            font.pixelSize: root.s(16)
                            font.weight: Font.Black
                            color: root.text
                        }
                        Item { Layout.fillWidth: true }
                        Rectangle {
                            radius: root.s(6)
                            color: root.currentMode === "nvidia" ? Qt.rgba(root.green.r, root.green.g, root.green.b, 0.2) : (root.currentMode === "integrated" ? Qt.rgba(root.yellow.r, root.yellow.g, root.yellow.b, 0.2) : Qt.rgba(root.blue.r, root.blue.g, root.blue.b, 0.2))
                            border.width: 1
                            border.color: root.currentMode === "nvidia" ? root.green : (root.currentMode === "integrated" ? root.yellow : root.blue)
                            implicitWidth: modeBadgeText.implicitWidth + root.s(14)
                            implicitHeight: modeBadgeText.implicitHeight + root.s(6)

                            Text {
                                id: modeBadgeText
                                anchors.centerIn: parent
                                text: root.currentMode.toUpperCase()
                                font.family: "JetBrains Mono"
                                font.pixelSize: root.s(11)
                                font.weight: Font.Black
                                color: root.currentMode === "nvidia" ? root.green : (root.currentMode === "integrated" ? root.yellow : root.blue)
                            }
                        }
                    }

                    Text {
                        text: root.gpuName + " (Driver " + root.driverVer + ")"
                        font.family: "JetBrains Mono"
                        font.pixelSize: root.s(11)
                        color: root.subtext0
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }

            // ─── Live Telemetry Strip ───
            Rectangle {
                Layout.fillWidth: true
                height: root.s(52)
                radius: root.s(10)
                color: root.surface0
                border.width: 1
                border.color: Qt.rgba(root.text.r, root.text.g, root.text.b, 0.08)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: root.s(8)

                    // Usage
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Text { text: "UTILIZATION"; font.family: "JetBrains Mono"; font.pixelSize: root.s(9); font.weight: Font.Bold; color: root.overlay1; Layout.alignment: Qt.AlignHCenter }
                        Text { text: root.gpuUsage + "%"; font.family: "JetBrains Mono"; font.pixelSize: root.s(14); font.weight: Font.Black; color: root.green; Layout.alignment: Qt.AlignHCenter }
                    }

                    Rectangle { width: 1; height: root.s(30); color: Qt.rgba(root.text.r, root.text.g, root.text.b, 0.1) }

                    // Temp
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Text { text: "TEMP"; font.family: "JetBrains Mono"; font.pixelSize: root.s(9); font.weight: Font.Bold; color: root.overlay1; Layout.alignment: Qt.AlignHCenter }
                        Text { text: root.gpuTemp + "°C"; font.family: "JetBrains Mono"; font.pixelSize: root.s(14); font.weight: Font.Black; color: root.peach; Layout.alignment: Qt.AlignHCenter }
                    }

                    Rectangle { width: 1; height: root.s(30); color: Qt.rgba(root.text.r, root.text.g, root.text.b, 0.1) }

                    // VRAM
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Text { text: "VRAM"; font.family: "JetBrains Mono"; font.pixelSize: root.s(9); font.weight: Font.Bold; color: root.overlay1; Layout.alignment: Qt.AlignHCenter }
                        Text { text: Math.round(root.vramUsed) + " / " + Math.round(root.vramTotal) + " MB"; font.family: "JetBrains Mono"; font.pixelSize: root.s(13); font.weight: Font.Black; color: root.blue; Layout.alignment: Qt.AlignHCenter }
                    }

                    Rectangle { width: 1; height: root.s(30); color: Qt.rgba(root.text.r, root.text.g, root.text.b, 0.1) }

                    // Power
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Text { text: "POWER"; font.family: "JetBrains Mono"; font.pixelSize: root.s(9); font.weight: Font.Bold; color: root.overlay1; Layout.alignment: Qt.AlignHCenter }
                        Text { text: root.powerDraw + " W"; font.family: "JetBrains Mono"; font.pixelSize: root.s(14); font.weight: Font.Black; color: root.mauve; Layout.alignment: Qt.AlignHCenter }
                    }
                }
            }

            // ─── Mode Cards ───
            ColumnLayout {
                Layout.fillWidth: true
                spacing: root.s(8)

                // 1. PERFORMANCE / NVIDIA MODE
                Rectangle {
                    Layout.fillWidth: true
                    height: root.s(64)
                    radius: root.s(12)
                    color: root.currentMode === "nvidia" ? Qt.rgba(root.green.r, root.green.g, root.green.b, 0.18) : (card1Mouse.containsMouse ? root.surface1 : root.surface0)
                    border.width: root.currentMode === "nvidia" ? 2 : 1
                    border.color: root.currentMode === "nvidia" ? root.green : Qt.rgba(root.text.r, root.text.g, root.text.b, 0.08)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: root.s(12)
                        spacing: root.s(12)

                        Text { text: "⚡"; font.pixelSize: root.s(22) }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: root.s(2)
                            Text { text: "Dedicated NVIDIA (Performance)"; font.family: "JetBrains Mono"; font.pixelSize: root.s(13); font.weight: Font.Black; color: root.text }
                            Text { text: "Maximum FPS & 3D render speed. dGPU active always."; font.family: "JetBrains Mono"; font.pixelSize: root.s(10); color: root.subtext0 }
                        }
                        Rectangle {
                            visible: root.currentMode === "nvidia"
                            width: root.s(18); height: root.s(18); radius: root.s(9); color: root.green
                            Text { anchors.centerIn: parent; text: "✓"; font.pixelSize: root.s(11); font.weight: Font.Black; color: root.base }
                        }
                    }
                    MouseArea { id: card1Mouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.switchGpu("nvidia") }
                }

                // 2. HYBRID MODE (PRIME Offload)
                Rectangle {
                    Layout.fillWidth: true
                    height: root.s(64)
                    radius: root.s(12)
                    color: root.currentMode === "hybrid" ? Qt.rgba(root.blue.r, root.blue.g, root.blue.b, 0.18) : (card2Mouse.containsMouse ? root.surface1 : root.surface0)
                    border.width: root.currentMode === "hybrid" ? 2 : 1
                    border.color: root.currentMode === "hybrid" ? root.blue : Qt.rgba(root.text.r, root.text.g, root.text.b, 0.08)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: root.s(12)
                        spacing: root.s(12)

                        Text { text: "🔄"; font.pixelSize: root.s(22) }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: root.s(2)
                            Text { text: "Hybrid (PRIME Dynamic Offload)"; font.family: "JetBrains Mono"; font.pixelSize: root.s(13); font.weight: Font.Black; color: root.text }
                            Text { text: "Recommended. Intel iGPU for desktop + NVIDIA on-demand."; font.family: "JetBrains Mono"; font.pixelSize: root.s(10); color: root.subtext0 }
                        }
                        Rectangle {
                            visible: root.currentMode === "hybrid"
                            width: root.s(18); height: root.s(18); radius: root.s(9); color: root.blue
                            Text { anchors.centerIn: parent; text: "✓"; font.pixelSize: root.s(11); font.weight: Font.Black; color: root.base }
                        }
                    }
                    MouseArea { id: card2Mouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.switchGpu("hybrid") }
                }

                // 3. INTEGRATED / APU MODE
                Rectangle {
                    Layout.fillWidth: true
                    height: root.s(64)
                    radius: root.s(12)
                    color: root.currentMode === "integrated" ? Qt.rgba(root.yellow.r, root.yellow.g, root.yellow.b, 0.18) : (card3Mouse.containsMouse ? root.surface1 : root.surface0)
                    border.width: root.currentMode === "integrated" ? 2 : 1
                    border.color: root.currentMode === "integrated" ? root.yellow : Qt.rgba(root.text.r, root.text.g, root.text.b, 0.08)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: root.s(12)
                        spacing: root.s(12)

                        Text { text: "🍃"; font.pixelSize: root.s(22) }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: root.s(2)
                            Text { text: "Integrated APU (Eco & Battery Saver)"; font.family: "JetBrains Mono"; font.pixelSize: root.s(13); font.weight: Font.Black; color: root.text }
                            Text { text: "dGPU completely powered down. Maximum battery life."; font.family: "JetBrains Mono"; font.pixelSize: root.s(10); color: root.subtext0 }
                        }
                        Rectangle {
                            visible: root.currentMode === "integrated"
                            width: root.s(18); height: root.s(18); radius: root.s(9); color: root.yellow
                            Text { anchors.centerIn: parent; text: "✓"; font.pixelSize: root.s(11); font.weight: Font.Black; color: root.base }
                        }
                    }
                    MouseArea { id: card3Mouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.switchGpu("integrated") }
                }
            }

            // ─── Quick Actions Bottom Bar ───
            RowLayout {
                Layout.fillWidth: true
                spacing: root.s(10)

                Rectangle {
                    Layout.fillWidth: true
                    height: root.s(38)
                    radius: root.s(10)
                    color: btn1Mouse.containsMouse ? root.surface1 : root.surface0
                    border.width: 1
                    border.color: Qt.rgba(root.text.r, root.text.g, root.text.b, 0.1)

                    Row {
                        anchors.centerIn: parent
                        spacing: root.s(8)
                        Text { anchors.verticalCenter: parent.verticalCenter; text: "⚙"; font.pixelSize: root.s(14); color: root.green }
                        Text { anchors.verticalCenter: parent.verticalCenter; text: "NVIDIA Control Panel"; font.family: "JetBrains Mono"; font.pixelSize: root.s(11); font.weight: Font.Bold; color: root.text }
                    }
                    MouseArea { id: btn1Mouse; anchors.fill: parent; hoverEnabled: true; onClicked: Quickshell.execDetached(["bash", "-c", "~/.config/hypr/scripts/quickshell/gpu/gpu_switch.sh nvidia-settings"]) }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: root.s(38)
                    radius: root.s(10)
                    color: btn2Mouse.containsMouse ? root.surface1 : root.surface0
                    border.width: 1
                    border.color: Qt.rgba(root.text.r, root.text.g, root.text.b, 0.1)

                    Row {
                        anchors.centerIn: parent
                        spacing: root.s(8)
                        Text { anchors.verticalCenter: parent.verticalCenter; text: "⚡"; font.pixelSize: root.s(14); color: root.mauve }
                        Text { anchors.verticalCenter: parent.verticalCenter; text: "Power: " + root.currentProfile.toUpperCase(); font.family: "JetBrains Mono"; font.pixelSize: root.s(11); font.weight: Font.Bold; color: root.text }
                    }
                    MouseArea {
                        id: btn2Mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            let next = root.currentProfile === "performance" ? "balanced" : (root.currentProfile === "balanced" ? "power-saver" : "performance");
                            root.currentProfile = next;
                            Quickshell.execDetached(["bash", "-c", "~/.config/hypr/scripts/quickshell/gpu/gpu_switch.sh " + next]);
                        }
                    }
                }
            }
        }
    }
}
