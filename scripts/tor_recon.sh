#!/data/data/com.termux/files/usr/bin/bash
export PATH=$HOME/go/bin:$PATH
HOME_DIR=$HOME/black_ronzer

# Route ALL traffic through Tor
export ALL_PROXY=socks5h://127.0.0.1:9050
export HTTP_PROXY=socks5h://127.0.0.1:9050
export HTTPS_PROXY=socks5h://127.0.0.1:9050

bash $HOME_DIR/scripts/recon.sh
