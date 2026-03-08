#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

echo ""
echo -e "${CYAN}================================${NC}"
echo -e "${CYAN}   VPS Setup Script by Bisam    ${NC}"
echo -e "${CYAN}================================${NC}"
echo ""

log "updating packages..."
apt update -y && apt upgrade -y
log "done updating"

log "installing essentials..."
apt install -y curl wget git openssh-client openssh-server autossh nano htop net-tools
log "done installing essentials"

# fix sshd config FIRST before starting
log "configuring ssh..."
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
# make sure it's in there even if line didn't exist
grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config || echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config || echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# set root password
ROOT_PASS=${ROOT_PASSWORD:-Bisam}
echo "root:$ROOT_PASS" | chpasswd
log "root password set"

# now start ssh with correct config
log "starting ssh service..."
service ssh restart || service ssh start
log "ssh running"

PUBLIC_IP=$(curl -s https://api.ipify.org || curl -s https://ifconfig.me || echo "unknown")
LOCAL_IP=$(hostname -I | awk '{print $1}')

echo ""
echo -e "${GREEN}=============================${NC}"
echo -e "${GREEN}   done installing!          ${NC}"
echo -e "${GREEN}=============================${NC}"
echo -e "  User     : ${CYAN}root${NC}"
echo -e "  Password : ${CYAN}$ROOT_PASS${NC}"
echo -e "  IP (pub) : ${CYAN}$PUBLIC_IP${NC}"
echo -e "  IP (loc) : ${CYAN}$LOCAL_IP${NC}"
echo -e "  Hostname : ${CYAN}$(hostname)${NC}"
echo -e "  OS       : ${CYAN}$(lsb_release -d | cut -f2)${NC}"
echo -e "  Uptime   : ${CYAN}$(uptime -p)${NC}"
echo -e "${GREEN}=============================${NC}"
echo ""

log "starting serveo SSH tunnel..."
SERVEO_PORT=${SERVEO_PORT:-22}

autossh -M 0 -T -N -o "StrictHostKeyChecking=no" -o "ServerAliveInterval=30" -o "ServerAliveCountMax=3" \
  -R 0:localhost:$SERVEO_PORT serveo.net &

SERVEO_PID=$!
sleep 3

if kill -0 $SERVEO_PID 2>/dev/null; then
  log "serveo tunnel running (pid: $SERVEO_PID)"
  warn "check serveo output above for your public SSH address"
else
  warn "serveo failed, trying fallback (localhost.run)..."
  ssh -T -N -o "StrictHostKeyChecking=no" -R 22:localhost:22 localhost.run &
fi

echo ""
log "all done! VPS is ready."
echo ""

log "keeping alive..."
tail -f /dev/null
