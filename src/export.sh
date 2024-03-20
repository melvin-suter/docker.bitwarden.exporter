#!/bin/bash

export NODE_NO_WARNINGS=1
export NODE_TLS_REJECT_UNAUTHORIZED=0
export TMPD=/tmp/bwexport
export TMPF=/tmp/bwsess

echo "$(date) - setting bitwarden url"
bw config server $BITWARDEN_URL

echo "$(date) - logging into bitwarden as $BITWARDEN_USER"
bw login "$BITWARDEN_USER" "$BITWARDEN_PASSWORD" 2>&1 | grep 'export BW_SESSION' | sed 's/.*export/export/' > $TMPF

echo "$(date) - loading sesseion info"
source $TMPF
rm -f $TMPF

echo "$(date) - getting bitwarden organisationId"
ORG=$(bw list organizations | jq .[] | jq -r .'id')

echo "$(date) - exporting bitwarden vault"
mkdir -p $TMPD
bw export --organizationid $ORG --output $TMPD/ --format csv
mv $TMPD/*.csv $TMPD/data.csv

echo "$(date) - converting file"
unoconv -f xls -o $TMPD/bitwarden_export.xls $TMPD/data.csv

echo "$(date) - creating export zip"
zip --password "$EXPORT_ENCRYPTION_PASSWORD" $EXPORT_DIR/bitwarden.zip -j $TMPD/bitwarden_export.xls

echo "$(date) - bitwarden logout and cleanup"
bw logout || true
unset BW_SESSION