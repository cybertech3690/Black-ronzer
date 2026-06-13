#!/data/data/com.termux/files/usr/bin/bash
export PATH=$HOME/go/bin:$PATH
HOME_DIR=$HOME/black_ronzer
DATE=$(date +%Y%m%d_%H%M)

send_telegram() {
    python3 -c "
import requests,json
with open('$HOME_DIR/config/system.json') as f:c=json.load(f)
requests.post(f'https://api.telegram.org/bot{c[\"telegram_bot\"]}/sendMessage',json={'chat_id':c[\"telegram_chat\"],'text':'''$1''','parse_mode':'HTML'})
" 2>/dev/null
}

TARGETS=("compound.finance" "aave.com" "uniswap.org" "sushi.com" "curve.fi" "balancer.fi" "1inch.io" "makerdao.com" "synthetix.io" "chain.link" "lido.fi" "yearn.finance" "dydx.exchange" "gmx.io" "frax.finance" "pancakeswap.finance" "stargate.finance" "euler.finance" "morpho.org" "across.to")

send_telegram "🔍 RECON STARTED - $(date +%H:%M)"

for domain in "${TARGETS[@]}"; do
    WORKDIR="$HOME_DIR/data/$domain/$DATE"
    mkdir -p "$WORKDIR"
    
    echo "[+] $domain"
    
    subfinder -d "$domain" -silent -timeout 5 -o "$WORKDIR/subs.txt" 2>/dev/null &
    curl -s "https://crt.sh/?q=%.$domain&output=json" | jq -r '.[].name_value' 2>/dev/null | tr ',' '\n' | sort -u >> "$WORKDIR/subs.txt" &
    wait
    sort -u "$WORKDIR/subs.txt" -o "$WORKDIR/subs.txt"
    
    httpx -l "$WORKDIR/subs.txt" -silent -timeout 8 -o "$WORKDIR/live.txt" 2>/dev/null
    
    nuclei -l "$WORKDIR/live.txt" -severity critical,high -silent -rl 80 -o "$WORKDIR/vulns.txt" 2>/dev/null
    
    for path in ".env" ".git/config" "backup.sql" "admin/" "phpinfo.php" "credentials.json"; do
        status=$(curl -s -o /dev/null -w "%{http_code}" "https://$domain/$path" --connect-timeout 5 2>/dev/null)
        if [ "$status" = "200" ]; then
            echo "https://$domain/$path [$status]" >> "$WORKDIR/exposed.txt"
        fi
    done
    
    VULNS=$(wc -l < "$WORKDIR/vulns.txt" 2>/dev/null || echo 0)
    EXPOSED=$(wc -l < "$WORKDIR/exposed.txt" 2>/dev/null || echo 0)
    
    if [ "$VULNS" -gt 0 ] || [ "$EXPOSED" -gt 0 ]; then
        send_telegram "🚨 $domain | Vulns: $VULNS | Exposed: $EXPOSED"
    fi
    
    sleep 5
done

send_telegram "✅ RECON DONE. Check ~/black_ronzer/data/"
