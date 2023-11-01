#!/usr/bin/env bash

source /etc/os-release

if [[ "$ID_LIKE" == "fedora" ]]; then
  if [[ "$VERSION_ID" < "8.0" ]]; then
    HTTPD_DIR="/var/log/httpd24"
    ETC_DIR="/opt/rh/httpd24/root/etc/httpd"
  else
    HTTPD_DIR="/var/log/httpd"
    ETC_DIR="/etc/httpd"
  fi
else
  HTTPD_DIR="/var/log/apache2"
  ETC_DIR="/etc/apache2"
fi


LOG_FORMAT=$(grep -rh LogFormat "$ETC_DIR" 2>/dev/null | grep combined | grep -v combinedio | head -n 1 | sed 's/[{}%"\>]//g')
IFS=' ' read -r -a LOG_FORMAT_ARR <<< "$LOG_FORMAT"

for i in ${!LOG_FORMAT_ARR[@]}; do
  if [[ "${LOG_FORMAT_ARR[$i]}" == "u" ]]; then
    USER_INDEX="$i"
  fi
done

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

  USERS=$(awk "{print \$$USER_INDEX}" $TMP_FILE | sort | uniq)
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