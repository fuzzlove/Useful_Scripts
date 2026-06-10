cat > /var/mobile/err_remount_fix.sh <<'EOF'
#!/bin/sh

echo "[*] ERR_REMOUNT safe fixer for Taurine"
echo "[*] This will NOT delete /private/preboot or wipe user data."

echo "[*] Checking root..."
id

echo "[*] Saving diagnostics..."
mkdir -p /var/mobile/err_remount_logs
mount > /var/mobile/err_remount_logs/mount.txt 2>&1
df -h > /var/mobile/err_remount_logs/df.txt 2>&1
ls -la /private/preboot > /var/mobile/err_remount_logs/preboot.txt 2>&1
ls -la /var/MobileSoftwareUpdate > /var/mobile/err_remount_logs/mobile_update.txt 2>&1
ls -la /var/db/softwareupdate > /var/mobile/err_remount_logs/db_update.txt 2>&1
ls -ld /var/jb /.procursus_strapped /private/var/jb > /var/mobile/err_remount_logs/jb_state.txt 2>&1

echo "[*] Removing OTA update leftovers..."
rm -rf /var/MobileSoftwareUpdate/*
rm -rf /private/var/MobileSoftwareUpdate/*
rm -rf /var/db/softwareupdate/*
rm -rf /var/db/SoftwareUpdate/*
rm -rf /var/mobile/Library/Preferences/com.apple.MobileSoftwareUpdate.plist

echo "[*] Removing Taurine app caches/log state only..."
rm -rf /var/mobile/Library/Caches/*taurine* 2>/dev/null
rm -rf /var/mobile/Library/Caches/*Taurine* 2>/dev/null
rm -rf /var/mobile/Library/Logs/*taurine* 2>/dev/null
rm -rf /var/mobile/Library/Logs/*Taurine* 2>/dev/null

echo "[*] Clearing uicache if available..."
uicache -a 2>/dev/null || true

echo "[*] Attempting ldrestart..."
ldrestart 2>/dev/null || true

echo
echo "[+] Done."
echo "[!] Now FULLY reboot the iPad."
echo "[!] Then reinstall latest Taurine and try Restore RootFS first."
echo "[!] Logs saved in: /var/mobile/err_remount_logs"
EOF

chmod +x /var/mobile/err_remount_fix.sh
sh /var/mobile/err_remount_fix.sh
