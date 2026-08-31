#!/usr/bin/env python3
import subprocess
import sys

def main():
    cmd = ["libinput", "debug-events"]
    try:
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
    except Exception as e:
        sys.exit(1)

    in_swipe_3 = False
    cum_dx = 0.0
    cum_dy = 0.0
    triggered = False
    THRESHOLD = 15.0  # Movement threshold in mm/points for reliable trigger

    for line in proc.stdout:
        line = line.strip()
        if not line:
            continue

        if "GESTURE_SWIPE_BEGIN" in line:
            parts = line.split()
            # 3-finger swipe begins for window switching
            if parts and parts[-1] == "3":
                in_swipe_3 = True
                cum_dx = 0.0
                cum_dy = 0.0
                triggered = False

        elif "GESTURE_SWIPE_UPDATE" in line and in_swipe_3:
            if triggered:
                continue
            parts = line.split()
            try:
                idx = parts.index("3")
                dx_dy = parts[idx + 1]
                dx_str, dy_str = dx_dy.split("/")
                cum_dx += float(dx_str)
                cum_dy += float(dy_str)

                # Only trigger on horizontal swipe (left / right only)
                if abs(cum_dx) > THRESHOLD and abs(cum_dx) > abs(cum_dy):
                    if cum_dx < 0:
                        # 3-Finger Swipe Left -> Next Window
                        subprocess.run(["hyprctl", "dispatch", "cyclenext"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                    else:
                        # 3-Finger Swipe Right -> Previous Window
                        subprocess.run(["hyprctl", "dispatch", "cyclenext", "prev"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                    triggered = True
            except Exception:
                pass

        elif "GESTURE_SWIPE_END" in line:
            in_swipe_3 = False
            triggered = False

if __name__ == "__main__":
    main()
