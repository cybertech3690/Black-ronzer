from flask import Flask, request, jsonify
import requests, json, os, time
from datetime import datetime

app = Flask(__name__)

BOT = os.environ.get("TELEGRAM_BOT", "")
CHAT = os.environ.get("TELEGRAM_CHAT", "")
WALLET = os.environ.get("WALLET", "")
USER = os.environ.get("IMMUNEFI_USER", "")

findings_db = []
start_time = datetime.now()

@app.route('/')
def home():
    return jsonify({
        "system": "Black Ronzer API",
        "status": "running",
        "uptime": str(datetime.now() - start_time),
        "findings": len(findings_db)
    })

@app.route('/health')
def health():
    return jsonify({"status": "ok"})

@app.route('/report', methods=['POST'])
def receive_report():
    data = request.json
    findings_db.append(data)
    
    # Forward to Telegram
    msg = f"🚨 <b>NEW FINDING</b>\n\nDomain: {data.get('domain')}\nType: {data.get('type')}\nURL: {data.get('url')}\n\nSubmit as: {USER}\nWallet: {WALLET[:10]}..."
    requests.post(f"https://api.telegram.org/bot{BOT}/sendMessage",
                 json={"chat_id": CHAT, "text": msg, "parse_mode": "HTML"})
    
    return jsonify({"received": True, "total": len(findings_db)})

@app.route('/dashboard')
def dashboard():
    return jsonify({
        "total_findings": len(findings_db),
        "recent": findings_db[-5:] if findings_db else [],
        "user": USER,
        "wallet": WALLET[:10] + "..."
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 10000)))
