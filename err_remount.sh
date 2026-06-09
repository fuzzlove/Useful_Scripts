#!/bin/sh
# fix_err_remount_ios.sh

echo "=== iOS ERR_REMOUNT repair attempt ==="

if [ "$(id -u)" != "0" ]; then
  echo "[-] Not root. Run as root:"
  echo "    su"
  echo "    sh fix_err_remount_ios.sh"
  exit 1
fi

echo "[+] Detecting shell..."
echo "Shell: ${SHELL:-unknown}"

echo "[+] Killing update / install daemons..."
killall -9 softwareupdated 2>/dev/null
killall -9 mobileassetd 2>/dev/null
killall -9 installd 2>/dev/null
killall -9 otaupdated 2>/dev/null
killall -9 nsurlsessiond 2>/dev/null

echo "[+] Removing OTA/update leftovers..."

for p in \
  /var/MobileSoftwareUpdate \
  /var/mobile/Library/SoftwareUpdate \
  /var/db/softwareupdate \
  /var/db/SoftwareUpdate \
  /private/var/MobileSoftwareUpdate \
  /private/var/mobile/Library/SoftwareUpdate \
  /private/var/db/softwareupdate \
  /private/var/db/SoftwareUpdate
do
  if [ -e "$p" ]; then
    echo "    Moving $p"
    mv "$p" "$p.bak.$(date +%s)" 2>/dev/null || rm -rf "$p"
  fi
done

echo "[+] Removing MobileAsset update cache..."
find /var/MobileAsset -maxdepth 3 \( \
  -iname "*softwareupdate*" -o \
  -iname "*ota*" -o \
  -iname "*com_apple_MobileAsset_SoftwareUpdate*" \
\) -print -exec rm -rf {} \; 2>/dev/null

echo "[+] Recreating clean SoftwareUpdate dirs..."
mkdir -p /var/mobile/Library/SoftwareUpdate
mkdir -p /var/db/softwareupdate
chown -R mobile:mobile /var/mobile/Library/SoftwareUpdate 2>/dev/null
chmod 755 /var/mobile/Library/SoftwareUpdate 2>/dev/null

echo "[+] Trying remount methods..."

mount -uw / 2>/dev/null && echo "[+] mount -uw / succeeded" || echo "[!] mount -uw / failed"

if command -v /sbin/mount_apfs >/dev/null 2>&1; then
  /sbin/mount_apfs -o rw / 2>/dev/null && echo "[+] mount_apfs rw succeeded" || true
fi

if command -v launchctl >/dev/null 2>&1; then
  echo "[+] Reloading update services..."
  launchctl kickstart -k system/com.apple.mobile.softwareupdated 2>/dev/null
  launchctl kickstart -k system/com.apple.mobileassetd 2>/dev/null
fi

echo "[+] Checking root mount:"
mount | grep " on / " || mount | head -20

echo "[+] Syncing..."
sync

echo ""
echo "=== Finished ==="
echo "Now reboot fully, delete any iOS update from Settings > General > iPhone Storage, then try jailbreak again."
echo ""
echo "Run with fish/Filza/SSH like this:"
echo "    su"
echo "    sh fix_err_remount_ios.sh"
