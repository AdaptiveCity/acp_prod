#!/bin/bash

FEEDS=(
/media/acp/mqtt_ttn/data_monitor
/media/acp/mqtt_csn/data_monitor
)

TODAY=$(date +'%Y/%m/%d')

printf "Current time: %s\n" "$(date)"

for f in ${FEEDS[@]}
do
    ts=$(stat --printf='%Z' $f)
    printf "%12s @ %s\n" $f "$(date -d @$ts)"
done


