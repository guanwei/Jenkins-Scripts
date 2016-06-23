#!/usr/bin/env bash
# Env Parameters: USERNAME, PASSWORD, PROJECT, SPACES
set -e

API_URL="https://api.sys.pcf.mkc.io"
ENVS=(DEV QA UAT STAG PROD)
SERVICE="SPLUNK"
SYSLOG="syslog://10.216.11.221:514"

cf login -a "$API_URL" -u "$USERNAME" -p "$PASSWORD" -o "system" -s "apps-manager" --skip-ssl-validation

for env in ${ENVS[*]}; do
	cf create-org "${env}_${PROJECT}"

    for space in ${SPACES}; do
		cf create-space "$space" -o "${env}_${PROJECT}"
        cf target -o "${env}_${PROJECT}" -s "$space"

        if [ -z "$(cf services | grep "$SERVICE")" ]; then
        	cf create-user-provided-service "$SERVICE" -l "$SYSLOG"
        else
        	echo "Service $SERVICE already exists"
        fi
	done
done

cf logout
