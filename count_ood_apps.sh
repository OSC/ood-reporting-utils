#!/usr/bin/env bash

SYS_DIR='/var/www/ood/apps/sys'
USR_DIR='/var/www/ood/apps/usr'
VERSION=$(cat /opt/ood/VERSION)

SYS_DIRS=$(ls $SYS_DIR)
USR_DIRS=$(ls $USR_DIR)
declare -a VALID_SYS_DIRS
declare -a VALID_USR_DIRS

for dir in $SYS_DIRS; do
  if ls "$SYS_DIR/$dir" >/dev/null 2>&1; then
    VALID_SYS_DIRS+=("$dir")
  fi
done

for dir in $USR_DIRS; do
  if ls "$USR_DIR/$dir/gateway" >/dev/null 2>&1; then
    SHARED_APPS=$(ls "$USR_DIR/$dir/gateway")
    for shared_app in $SHARED_APPS; do
      if ls "$USR_DIR/$dir/gateway/$shared_app" >/dev/null 2>&1; then
        VALID_USR_DIRS+=("$shared_app")  
      fi
    done
  fi
done

echo "The user $(whoami) has access to these Open OnDemand $VERSION apps:"
echo "  ${#VALID_SYS_DIRS[@]} system installed applications."
echo "  ${#VALID_USR_DIRS[@]} shared applications."
echo ''
echo 'system installed apps are:'
echo ''

for app in ${VALID_SYS_DIRS[@]}; do
  echo $app
done