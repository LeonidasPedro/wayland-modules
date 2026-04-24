#!/usr/bin/env python3

import os
import json
import time
import argparse
import subprocess

# Constants
POMODORO = 25 * 60  # 25 minutes in seconds
SHORT_BREAK = 5 * 60  # 5 minutes in seconds
LONG_BREAK = 15 * 60  # 15 minutes in seconds

# State file
STATE_FILE = os.path.expanduser("~/.cache/pomodoro_state.json")

def load_state():
    if not os.path.exists(STATE_FILE):
        return {
            "status": "inactive",
            "time_left": 0,
            "pomodoros": 0,
            "last_update": int(time.time())
        }
    
    try:
        with open(STATE_FILE, 'r') as f:
            state = json.load(f)
            
        # Update time_left if timer is active
        if state["status"] not in ["inactive", "paused"]:
            elapsed = int(time.time()) - state["last_update"]
            state["time_left"] = max(0, state["time_left"] - elapsed)
            
            # Auto-transition if timer completed
            if state["time_left"] <= 0:
                if state["status"] == "pomodoro":
                    notify("Pomodoro Complete!", "Time for a break")
                    state["pomodoros"] += 1
                    if state["pomodoros"] % 4 == 0:
                        state["status"] = "long_break"
                        state["time_left"] = LONG_BREAK
                    else:
                        state["status"] = "short_break"
                        state["time_left"] = SHORT_BREAK
                else:
                    notify("Break Complete!", "Time to focus")
                    state["status"] = "pomodoro"
                    state["time_left"] = POMODORO
            
        state["last_update"] = int(time.time())
        save_state(state)
        return state
    except:
        return {
            "status": "inactive",
            "time_left": 0,
            "pomodoros": 0,
            "last_update": int(time.time())
        }

def save_state(state):
    os.makedirs(os.path.dirname(STATE_FILE), exist_ok=True)
    with open(STATE_FILE, 'w') as f:
        json.dump(state, f)

def format_time(seconds):
    minutes = seconds // 60
    seconds = seconds % 60
    return f"{minutes:02d}:{seconds:02d}"

def notify(title, message):
    try:
        subprocess.run(["notify-send", title, message])
    except:
        pass

def output_for_waybar(state):
    status = state["status"]
    pomodoros = state["pomodoros"]
    
    if status == "inactive":
        text = "󰔟 Start"
        tooltip = "Click to start a pomodoro"
    elif status == "pomodoro":
        text = f"󰔛 {format_time(state['time_left'])}"
        tooltip = f"Focus time - Pomodoros: {pomodoros}"
    elif status == "short_break":
        text = f"󰭹 {format_time(state['time_left'])}"
        tooltip = f"Short break - Pomodoros: {pomodoros}"
    elif status == "long_break":
        text = f"󰭹 {format_time(state['time_left'])}"
        tooltip = f"Long break - Pomodoros: {pomodoros}"
    elif status == "paused":
        text = f"󰏤 {format_time(state['time_left'])}"
        tooltip = f"Paused - Pomodoros: {pomodoros}"
    
    tooltip += "\nClick: Toggle | Right-click: Skip | Middle-click: Reset"
    
    return json.dumps({
        "text": text,
        "tooltip": tooltip,
        "class": status
    })

def toggle(state):
    if state["status"] == "inactive":
        state["status"] = "pomodoro"
        state["time_left"] = POMODORO
    elif state["status"] == "paused":
        state["status"] = state.get("paused_state", "pomodoro")
    else:
        state["paused_state"] = state["status"]
        state["status"] = "paused"
    
    state["last_update"] = int(time.time())
    save_state(state)
    return state

def skip(state):
    if state["status"] in ["pomodoro", "paused"] and state.get("paused_state") == "pomodoro":
        state["pomodoros"] += 1
        if state["pomodoros"] % 4 == 0:
            state["status"] = "long_break"
            state["time_left"] = LONG_BREAK
        else:
            state["status"] = "short_break"
            state["time_left"] = SHORT_BREAK
    else:
        state["status"] = "pomodoro"
        state["time_left"] = POMODORO
    
    if state["status"] != "inactive":
        state["paused_state"] = state["status"]
    
    state["last_update"] = int(time.time())
    save_state(state)
    return state

def reset(state):
    state = {
        "status": "inactive",
        "time_left": 0,
        "pomodoros": 0,
        "last_update": int(time.time())
    }
    save_state(state)
    return state

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Pomodoro Timer for Waybar')
    parser.add_argument('action', nargs='?', default='status', 
                        choices=['status', 'toggle', 'skip', 'reset'],
                        help='Action to perform')
    args = parser.parse_args()
    
    state = load_state()
    
    if args.action == 'toggle':
        state = toggle(state)
    elif args.action == 'skip':
        state = skip(state)
    elif args.action == 'reset':
        state = reset(state)
    
    print(output_for_waybar(state))
