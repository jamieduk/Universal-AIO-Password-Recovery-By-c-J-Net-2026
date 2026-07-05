#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"

GREEN='\033[1;32m'
NC='\033[0m'

banner() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║       Universal AIO Password Recovery Tool v2.0              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_menu() {
    echo -e "${GREEN}"
    echo "  Select file type to recover:"
    echo "  ────────────────────────────────────────────────────────────"
    echo "   1)  ZIP Archive              (.zip)"
    echo "   2)  PDF Document             (.pdf)"
    echo "   3)  7-Zip Archive            (.7z)"
    echo "   4)  RAR Archive              (.rar)"
    echo "   5)  MS Office                (.doc/.docx/.xls/.xlsx/.ppt/.pptx)"
    echo "   6)  OpenDocument             (.odt/.ods/.odp/.odg)"
    echo "   7)  OpenSSL Encrypted        (.enc)"
    echo "   8)  Disk Image/Container     (.iso/.img/.dmg/.vhd/.vhdx/.hc)"
    echo "   9)  GPG Encrypted            (.gpg/.tar.gz.gpg)"
    echo "  10)  PGP Encrypted            (.pgp)"
    echo "  11)  PEM/KEY Private Key      (.pem/.key)"
    echo "  12)  P12/PFX Certificate      (.p12/.pfx)"
    echo "  13)  KeePass Database         (.kdbx)"
    echo "  14)  SQLite Database          (.sqlite/.db)"
    echo "  15)  BAK Backup File          (.bak)"
    echo "  16)  Office Macro Doc         (.docm/.xlsm/.pptm)"
    echo "  17)  EPUB eBook               (.epub)"
    echo "  ────────────────────────────────────────────────────────────"
    echo "  18)  VeraCrypt/TrueCrypt      (.hc/.tc/.vc)"
    echo "  19)  LUKS Encrypted Volume    (header/device)"
    echo "  20)  BitLocker Volume         (drive/image)"
    echo "  21)  Apple DMG Image          (.dmg/.sparsebundle)"
    echo "  22)  Android Backup           (.ab)"
    echo "  23)  SSH Private Key          (OpenSSH format)"
    echo "  24)  GnuPG Keyring            (keyring file)"
    echo "  25)  Browser Profile          (Firefox/Chrome)"
    echo "  26)  Outlook PST              (.pst/.ost)"
    echo "  27)  PDF Portfolio            (.pdf portfolio)"
    echo "  28)  Database Encrypted       (SQLCipher/MySQL/PG/Mongo)"
    echo "  29)  iOS Backup               (iTunes/Finder)"
    echo "  30)  Hybrid Archive           (tar+gpg/zip+AES)"
    echo "  ────────────────────────────────────────────────────────────"
    echo "   0)  Exit"
    echo -e "${NC}"
}

run_recovery() {
    local script="$1"
    local file="$2"
    local wordlist="$3"

    if [ ! -f "$SRC_DIR/$script" ]; then
        echo -e "${GREEN}ERROR: Recovery script not found: $SRC_DIR/$script${NC}"
        return 1
    fi

    echo -e "${GREEN}[*] Running $script on $file with wordlist $wordlist ...${NC}"
    python3 "$SRC_DIR/$script" "$file" "$wordlist"
}

main() {
    local file_arg=""
    local wordlist_arg=""
    local choice=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--file) file_arg="$2"; shift 2 ;;
            -w|--wordlist) wordlist_arg="$2"; shift 2 ;;
            -c|--choice) choice="$2"; shift 2 ;;
            -h|--help)
                echo "Usage: $0 [-f <file>] [-w <wordlist>] [-c <choice>]"
                echo "  -f, --file      Target file to recover"
                echo "  -w, --wordlist  Path to password wordlist"
                echo "  -c, --choice    Menu choice number (1-30)"
                echo "  -h, --help      Show this help"
                exit 0
                ;;
            *) shift ;;
        esac
    done

    banner

    if [ -z "$choice" ]; then
        show_menu
        read -p "  Enter choice [0-30]: " choice
    fi

    case "$choice" in
        0) echo -e "${GREEN}Exiting.${NC}"; exit 0 ;;
        1) script="zip_recovery.py" ;;
        2) script="pdf_recovery.py" ;;
        3) script="sevenzip_recovery.py" ;;
        4) script="rar_recovery.py" ;;
        5) script="office_recovery.py" ;;
        6) script="odf_recovery.py" ;;
        7) script="openssl_recovery.py" ;;
        8) script="disk_image_recovery.py" ;;
        9) script="gpg_recovery.py" ;;
        10) script="pgp_recovery.py" ;;
        11) script="pemkey_recovery.py" ;;
        12) script="p12_recovery.py" ;;
        13) script="kdbx_recovery.py" ;;
        14) script="sqlite_recovery.py" ;;
        15) script="bak_recovery.py" ;;
        16) script="office_macro_recovery.py" ;;
        17) script="epub_recovery.py" ;;
        18) script="veracrypt_recovery.py" ;;
        19) script="luks_recovery.py" ;;
        20) script="bitlocker_recovery.py" ;;
        21) script="dmg_recovery.py" ;;
        22) script="android_ab_recovery.py" ;;
        23) script="sshkey_recovery.py" ;;
        24) script="gnupg_keyring_recovery.py" ;;
        25) script="browser_profile_recovery.py" ;;
        26) script="pst_recovery.py" ;;
        27) script="pdf_portfolio_recovery.py" ;;
        28) script="database_recovery.py" ;;
        29) script="ios_backup_recovery.py" ;;
        30) script="hybrid_archive_recovery.py" ;;
        *) echo -e "${GREEN}Invalid choice.${NC}"; exit 1 ;;
    esac

    if [ -z "$file_arg" ]; then
        read -p "  Enter path to target file: " file_arg
    fi

    if [ -z "$wordlist_arg" ]; then
        read -p "  Enter path to wordlist [password-list.txt]: " wordlist_arg
        wordlist_arg="${wordlist_arg:-$SCRIPT_DIR/password-list.txt}"
    fi

    if [ ! -f "$file_arg" ]; then
        echo -e "${GREEN}ERROR: File not found: $file_arg${NC}"
        exit 1
    fi

    if [ ! -f "$wordlist_arg" ]; then
        echo -e "${GREEN}ERROR: Wordlist not found: $wordlist_arg${NC}"
        exit 1
    fi

    run_recovery "$script" "$file_arg" "$wordlist_arg"
}

main "$@"
