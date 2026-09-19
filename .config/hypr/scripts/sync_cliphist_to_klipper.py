#!/usr/bin/env python3
"""
Sync recent items from cliphist into KDE Plasma Klipper SQLite database.
Ensures that KDE Clipboard always has the latest items copied across Wayland sessions.
"""
import os
import sys
import sqlite3
import hashlib
import subprocess
import time

def sync():
    db_path = os.path.expanduser("~/.local/share/klipper/history3.sqlite")
    data_dir = os.path.expanduser("~/.local/share/klipper/data")
    os.makedirs(data_dir, exist_ok=True)

    if not os.path.exists(db_path):
        # Database doesn't exist yet, Klipper will initialize it on first launch
        return

    try:
        con = sqlite3.connect(db_path, timeout=1.0)
        cur = con.cursor()

        # Check existing UUIDs in Klipper
        existing_uuids = set(r[0] for r in cur.execute("SELECT uuid FROM main"))

        # Fetch recent 60 items from cliphist
        res = subprocess.run(["cliphist", "list"], capture_output=True, text=True, timeout=2.0)
        if res.returncode != 0 or not res.stdout.strip():
            con.close()
            return

        lines = res.stdout.strip().split("\n")[:60]
        now = time.time()

        for idx, line in enumerate(reversed(lines)):
            if not line:
                continue
            parts = line.split("\t", 1)
            summary = parts[1] if len(parts) > 1 else ""

            dec = subprocess.run(["cliphist", "decode"], input=(line + "\n").encode("utf-8"), capture_output=True, timeout=1.0)
            raw = dec.stdout
            if not raw:
                continue

            u = hashlib.sha1(raw).hexdigest()
            if u in existing_uuids:
                continue

            # Detect image data
            is_img = (
                raw.startswith(b"\x89PNG")
                or raw.startswith(b"\xff\xd8\xff")
                or raw.startswith(b"GIF8")
                or "binary data" in summary
            )

            data_file = os.path.join(data_dir, u)
            if not os.path.exists(data_file):
                try:
                    with open(data_file, "wb") as f:
                        f.write(raw)
                except OSError:
                    pass

            item_time = now - (len(lines) - idx)
            if is_img:
                mimetypes = "image/png"
                cur.execute(
                    "INSERT OR IGNORE INTO main (uuid, added_time, last_used_time, mimetypes, text, starred) VALUES (?, ?, ?, ?, NULL, 0)",
                    (u, item_time, item_time, mimetypes),
                )
                cur.execute(
                    "INSERT OR IGNORE INTO aux (uuid, mimetype, data_uuid) VALUES (?, ?, ?)",
                    (u, "image/png", u),
                )
            else:
                text_val = raw.decode("utf-8", errors="replace")
                mimetypes = "text/plain,text/plain;charset=utf-8"
                cur.execute(
                    "INSERT OR IGNORE INTO main (uuid, added_time, last_used_time, mimetypes, text, starred) VALUES (?, ?, ?, ?, ?, 0)",
                    (u, item_time, item_time, mimetypes, text_val),
                )
                cur.execute(
                    "INSERT OR IGNORE INTO aux (uuid, mimetype, data_uuid) VALUES (?, ?, ?)",
                    (u, "text/plain;charset=utf-8", u),
                )
                cur.execute(
                    "INSERT OR IGNORE INTO aux (uuid, mimetype, data_uuid) VALUES (?, ?, ?)",
                    (u, "text/plain", u),
                )

            existing_uuids.add(u)

        con.commit()
        con.close()
    except Exception:
        # Failsafe: never crash or block clipboard toggle
        pass

if __name__ == "__main__":
    sync()
