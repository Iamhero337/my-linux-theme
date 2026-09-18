#!/usr/bin/env python3
"""
Bluetooth Audio Auto-Prioritizer for PipeWire / WirePlumber.
Automatically routes default audio playback (sink) and recording (source)
to newly connected Bluetooth devices (A2DP / HFP / HSP), and gracefully
falls back to internal speakers and microphones when disconnected.
"""

import json
import os
import select
import subprocess
import sys
import time

SPEAKER_SINK = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink"
INTERNAL_MIC = "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source"

def run_cmd(cmd):
    try:
        res = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
        return res.stdout.strip()
    except Exception:
        return ""

def get_json(cmd):
    try:
        out = run_cmd(cmd)
        return json.loads(out) if out else []
    except Exception:
        return []

def notify(title, message, icon="audio-headphones-bluetooth"):
    try:
        subprocess.run(["notify-send", "-a", "Audio", "-i", icon, "-u", "normal", title, message], check=False)
    except Exception:
        pass

last_notified_sink = ""
last_notified_source = ""

def evaluate_and_prioritize():
    global last_notified_sink, last_notified_source

    sinks = get_json("pactl -f json list sinks")
    sources = get_json("pactl -f json list sources")
    info = get_json("pactl -f json info")

    current_sink = info.get("default_sink_name", "") if isinstance(info, dict) else ""
    current_source = info.get("default_source_name", "") if isinstance(info, dict) else ""

    # --- SINK (OUTPUT) LOGIC ---
    bt_sinks = []
    for s in sinks:
        name = s.get("name", "")
        props = s.get("properties", {})
        if name.startswith("bluez_output.") or props.get("device.bus") == "bluetooth":
            bt_sinks.append(s)

    if bt_sinks:
        target_sink = bt_sinks[0]
        target_name = target_sink.get("name", "")
        if target_name and target_name != current_sink:
            print(f"[bt_audio] Prioritizing Bluetooth Sink: {target_name}")
            subprocess.run(["pactl", "set-default-sink", target_name], check=False)
            sink_desc = (
                target_sink.get("properties", {}).get("device.description")
                or target_sink.get("description")
                or "Bluetooth Headset"
            )
            if target_name != last_notified_sink:
                notify("Bluetooth Audio Connected", f"Audio Output set to {sink_desc}", "audio-headphones-bluetooth")
                last_notified_sink = target_name
    else:
        # If no BT sink, ensure current sink is actually available
        last_notified_sink = ""
        current_sink_available = False
        for s in sinks:
            if s.get("name") == current_sink:
                ports = s.get("ports", [])
                if not ports or not all(p.get("availability") == "not available" for p in ports):
                    current_sink_available = True
                break
        
        if not current_sink_available:
            print(f"[bt_audio] Fallback to default Speaker: {SPEAKER_SINK}")
            subprocess.run(["pactl", "set-default-sink", SPEAKER_SINK], check=False)

    # --- SOURCE (INPUT) LOGIC ---
    bt_sources = []
    for s in sources:
        name = s.get("name", "")
        props = s.get("properties", {})
        if (name.startswith("bluez_input.") or props.get("device.bus") == "bluetooth") and not name.endswith(".monitor"):
            bt_sources.append(s)

    if bt_sources:
        target_source = bt_sources[0]
        target_src_name = target_source.get("name", "")
        if target_src_name and target_src_name != current_source:
            print(f"[bt_audio] Prioritizing Bluetooth Source: {target_src_name}")
            subprocess.run(["pactl", "set-default-source", target_src_name], check=False)
            src_desc = (
                target_source.get("properties", {}).get("device.description")
                or target_source.get("description")
                or "Bluetooth Microphone"
            )
            if target_src_name != last_notified_source:
                notify("Bluetooth Mic Connected", f"Audio Input set to {src_desc}", "audio-input-microphone")
                last_notified_source = target_src_name
    else:
        # If no BT source, ensure current source is actually available
        last_notified_source = ""
        current_source_available = False
        for s in sources:
            if s.get("name") == current_source:
                ports = s.get("ports", [])
                if not ports or not all(p.get("availability") == "not available" for p in ports):
                    current_source_available = True
                break
        
        if not current_source_available:
            print(f"[bt_audio] Fallback to default Internal Mic: {INTERNAL_MIC}")
            subprocess.run(["pactl", "set-default-source", INTERNAL_MIC], check=False)

def main():
    print("[bt_audio] Starting Bluetooth Audio Auto-Prioritizer...")
    evaluate_and_prioritize()

    while True:
        try:
            proc = subprocess.Popen(
                ["pactl", "subscribe"],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                bufsize=1
            )

            poll = select.poll()
            poll.register(proc.stdout, select.POLLIN)

            while True:
                events = poll.poll(1000)
                if not events:
                    if proc.poll() is not None:
                        break
                    continue

                line = proc.stdout.readline()
                if not line:
                    break

                # React to sink, source, or card changes
                if any(x in line for x in ["sink", "source", "card"]):
                    # Short debounce to let PipeWire finish creating nodes/routes
                    time.sleep(0.15)
                    # Flush any other pending lines in buffer
                    while True:
                        drain = poll.poll(20)
                        if drain:
                            proc.stdout.readline()
                        else:
                            break
                    evaluate_and_prioritize()

        except Exception as e:
            print(f"[bt_audio] Listener exception: {e}", file=sys.stderr)
            time.sleep(2)

if __name__ == "__main__":
    main()
