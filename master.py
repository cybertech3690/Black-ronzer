#!/usr/bin/env python3
import subprocess, time, json, os, requests
from datetime import datetime

HOME = os.path.expanduser("~/black_ronzer")
with open(f"{HOME}/config/system.json") as f:
    cfg = json.load(f)

BOT = cfg["telegram_bot"]
CHAT = cfg["telegram_chat"]

def tg(msg):
    try:
        requests.post(f"https://api.telegram.org/bot{BOT}/sendMessage",
                     json={"chat_id": CHAT, "text": msg, "parse_mode": "HTML"}, timeout=10)
    except: pass

tg("✅ BLACK RONZER ONLINE\n20 programs | 2hr cycles\nWallet: " + cfg["wallet"][:10] + "...")

cycle = 0
while True:
    cycle += 1
    print(f"[{datetime.now().strftime('%H:%M:%S')}] Cycle {cycle}")
    
    try:
        subprocess.run(["bash", f"{HOME}/scripts/recon.sh"], timeout=3600)
        
        total = 0
        for root, dirs, files in os.walk(f"{HOME}/data"):
            for f in files:
                if f in ["vulns.txt", "exposed.txt"]:
                    try:
                        with open(os.path.join(root, f)) as fp:
                            total += len(fp.readlines())
                    except: pass
        
        if total > 0:
            tg(f"📊 Cycle {cycle} Done | Total findings: {total}\nSubmit at Immunefi as: {cfg['immunefi_user']}")
        
    except Exception as e:
        tg(f"❌ Error: {str(e)[:100]}")
    
    time.sleep(7200)
