#!/bin/sh
set -e

cd "$(dirname "$0")"

SECRET_FILE=~/.secrets/asahilinux-storage
BASEPATH=asahi-alarm.org:/public_html/
USER=asahim
SRC=releases

if [ ! -e "$SECRET_FILE" ]; then
    echo "Missing storage bucket secret. Please place the secret in $SECRET_FILE." 1>&2
    exit 1
fi

SECRET="$(cat "$SECRET_FILE")"

put() {
    sshpass -p "$SECRET" scp -o PubkeyAuthentication=no $1 $USER@$BASEPATH
}

VERSION="$(cat $SRC/latest)"
FILE="installer-${VERSION}.tar.gz"
SRCFILE="$SRC/$FILE"

if [ ! -e "$SRCFILE" ]; then
    echo "$SRCFILE does not exist" 1>&2
    exit 1
fi

echo "About to push version $VERSION from $SRCFILE to $USER@$BASEPATH."
echo "Press enter to confirm."

read

put "$SRCFILE"

echo "Updating latest flag..."

put "$SRC/latest"

echo "Updating data"

put data/installer_data.json

echo "Done!"
