#!/bin/bash
#
# check_magento_mariadb.sh
# Audits all Magento installs under /home for MariaDB 10.11 readiness.
# Flags installs that need patching before a 10.6 -> 10.11 DB upgrade.
#
# Usage: ./check_magento_mariadb.sh [output.csv]

OUTFILE="${1:-magento_mariadb_audit_$(date +%Y%m%d).csv}"
TIMEOUT_SECS=30

echo "user,docroot,magento_version,status,note" > "$OUTFILE"

# version_le "1.2.3" "1.2.10" -> true if first <= second
version_le() {
    [ "$1" = "$(printf '%s\n%s' "$1" "$2" | sort -V | head -n1)" ]
}

while IFS= read -r path; do
    user=$(echo "$path" | cut -d/ -f3)
    docroot=$(dirname "$path")

    # Skip if user account looks invalid/suspended
    if ! id "$user" &>/dev/null; then
        echo "\"$user\",\"$docroot\",,error,\"no matching system user\"" >> "$OUTFILE"
        continue
    fi

    raw=$(timeout "$TIMEOUT_SECS" su - "$user" -s /bin/bash -c "php '$path' --version" 2>/dev/null)

    if [ -z "$raw" ]; then
        echo "\"$user\",\"$docroot\",,error,\"version check failed or timed out\"" >> "$OUTFILE"
        continue
    fi

    # Expected format: "Magento CLI 2.4.6-p11"
    ver=$(echo "$raw" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-p[0-9]+)?')

    if [ -z "$ver" ]; then
        echo "\"$user\",\"$docroot\",\"$raw\",error,\"unparsable version string\"" >> "$OUTFILE"
        continue
    fi

    base=$(echo "$ver" | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+')
    patch=$(echo "$ver" | grep -oE 'p[0-9]+$' | tr -d 'p')
    patch=${patch:-0}

    status="OK"
    note=""

    case "$base" in
        2.4.4)
            status="BLOCKED"
            note="2.4.4 branch caps at MariaDB 10.6, no 10.11 support exists"
            ;;
        2.4.5)
            if [ "$patch" -lt 17 ]; then
                status="NEEDS_PATCH"
                note="requires 2.4.5-p17 for 10.11 support (currently p$patch)"
            else
                note="10.11 supported"
            fi
            ;;
        2.4.6)
            if [ "$patch" -lt 11 ]; then
                status="NEEDS_PATCH"
                note="requires 2.4.6-p11+ for 10.11 support (currently p$patch)"
            else
                note="10.11 supported"
            fi
            ;;
        2.4.7)
            if [ "$patch" -lt 6 ]; then
                status="NEEDS_PATCH"
                note="requires 2.4.7-p6+ for 10.11 support (currently p$patch)"
            else
                note="10.11 supported"
            fi
            ;;
        2.4.8|2.4.9)
            status="REVIEW"
            note="this branch has moved past 10.11 (11.4/11.8/12.3) -- confirm target MariaDB version separately"
            ;;
        *)
            status="REVIEW"
            note="version not in known support matrix, check manually"
            ;;
    esac

    echo "\"$user\",\"$docroot\",\"$ver\",\"$status\",\"$note\"" >> "$OUTFILE"

done < <(find /home -maxdepth 5 -type f -name "magento" 2>/dev/null)

echo "Done. Results written to $OUTFILE"
echo ""
echo "Summary:"
awk -F'","' 'NR>1 {gsub(/"/,"",$4); print $4}' "$OUTFILE" | sort | uniq -c | sort -rn
