#!/usr/bin/env bash

source /etc/os-release

if [[ "$ID_LIKE"=="fedora" ]]; then
  if [[ "$VERSION_ID" < "8.0" ]]; then
    HTTPD_DIR="/var/log/httpd24"
  else
    HTTPD_DIR="/var/log/httpd"
  fi
else
  HTTPD_DIR="/var/log/apache2"
fi

LOGS=$(ls $HTTPD_DIR | grep -v 'localhost' | grep access)
declare -a ALL_USERS
LAST_LOG=$(date +%Y%m%d)

for log in $LOGS; do
  FULL_PATH="$HTTPD_DIR/$log"
  LOG_DATE=$(echo "$log" | grep -Po "\d+")

  if [[ "$LOG_DATE" != "" && "$LOG_DATE" < "$LAST_LOG" ]]; then
    LAST_LOG=$LOG_DATE
  fi

  TMP_FILE=$(mktemp)

  if [[ "$FULL_PATH" == *.gz ]]; then
    zcat "$FULL_PATH" > "$TMP_FILE"
  else
    cp "$FULL_PATH" "$TMP_FILE"
  fi

  USERS=$(awk '{print $4}' $TMP_FILE | sort | uniq)
  ALL_USERS+=( "${USERS[@]}" )

  
  rm $TMP_FILE
done

UNIQ_USERS=$(echo "${ALL_USERS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
declare -a ACTUAL_USERS

for user in ${UNIQ_USERS[@]}; do
  if id $user >/dev/null 2>&1; then
    ACTUAL_USERS+=($user)
  fi
done

LAST_LOG_DATE=$(date -d $LAST_LOG +%m-%d-%Y)

echo "${#ACTUAL_USERS[@]} users have logged into this system since $LAST_LOG_DATE."