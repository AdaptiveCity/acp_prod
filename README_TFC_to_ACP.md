# System changes from TFC to ACP

This note summarizes the changes affecting `acp_server` and `acp_prod`. `acp_web`
will be documented separately in that git repo.

* There is a systematic name change from `tfc` to `acp`, for everything except the
server hostnames. This affects all code and scripts, including nginx configuration,
data directories and log file directories.

* The 'uk/ac/cam/tfc_server/' java source structure has been replaced with 'acp_server/'

* All verticle configs are now stored in `acp_prod/configs/` or `acp_prod/secrets`.

* The TFC region-specific verticles (such as related to buses and car parking)
have been removed.

* The `acp_prod/run.sh` is ACP verticles only.

* The tfc numeric field "ts" is replaced with the string "acp_ts" to accommodate
more flexible floating point timestamps.

* All verticle configurations are held in `acp_prod/configs/` and `acp_prod/secrets`.

* `tfc_prod/secrets.sh` is no longer used.

* The `acp_prod` installation now requires the `mosquitto` MQTT broker to be installed.

