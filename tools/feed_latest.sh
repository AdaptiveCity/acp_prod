#!/bin/bash

FEEDS=(
/media/acp/mqtt_ttn
/media/acp/mqtt_acp
/media/acp/mqtt_csn
)

LATEST_COUNT=5

TODAY=$(date +'%Y-%m-%d')

YYYY=$(date +%Y)
MM=$(date +%m)

echo
printf "Current time: %s\n" "$(date)"

for feed in ${FEEDS[@]}
do
    echo
    echo ${feed} \(Latest ${LATEST_COUNT} messages\):
    (ls -al ${feed}/sensors/*/${YYYY}/${MM} | grep ${TODAY} | awk '{print $8 " " $9}' | sort | tail -n ${LATEST_COUNT})
done
