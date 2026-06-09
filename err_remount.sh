#!/bin/bash

echo "=== ERR_REMOUNT basic fixer ==="

if [ "$(id -u)" != "0" ]; then
  echo "[-] Not running as root. Run from Filza with root privileges."
  exit 1
fi

echo "[+] Remounting root as read/write if possible..."
mount -uw / 2>/dev/null || echo "[!] mount -uw / failed or not supported on this jailbreak."

echo "[+] Removing OTA update leftovers..."

PATHS="
/var/MobileSoftwareUpdate
/var/mobile/Library/SoftwareUpdate
/var/db/softwareupdate
/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
"

for p in $PATHS; do
  if [ -e "$p" ]; then
    echo "[+] Found: $p"
    mv "$p" "${p}.bak.$(date +%s)" 2>/dev/null || rm -rf "$p"
  fi
done

echo "[+] Cleaning update assets..."
find /var -iname "*OTA*" -o -iname "*softwareupdate*" 2>/dev/null | while read item; do
  echo "    $item"
done

echo "[+] Killing update daemons..."
killall -9 softwareupdated 2>/dev/null
killall -9 mobileassetd 2>/dev/null
killall -9 installd 2>/dev/null

echo "[+] Recreating common folders..."
mkdir -p /var/mobile/Library/SoftwareUpdate
chown -R mobile:mobile /var/mobile/Library/SoftwareUpdate
chmod 755 /var/mobile/Library/SoftwareUpdate

echo "[+] Syncing filesystem..."
sync

echo ""
echo "=== Done ==="
echo "Now reboot, then try Taurine/palera1n/etc again."
echo "If err_remount still happens, your jailbreak may not support remount on this iOS/rootless setup."
