# Mosquitto MQTT broker configuration

Install with:
```
sudo apt install mosquitto mosquitto-clients
```

Installation can immediately be tested with `mosquitto_sub -v -t '#'` and `mosquitto_pub -t foo -m bah`
issued in that order in two open terminals.

Note the MQTT broker is *open to anyone* at this point.

## Require passwords

```
sudo cp ~acp_prod/acp_prod/secrets/mosquitto_passwd /etc/mosquitto/passwd

sudo cp ~acp_prod/acp_prod/mosquitto/default.conf /etc/mosquitto/conf.d/

sudo systemctl stop mosquitto

service mosquitto status

sudo systemctl start mosquitto
```

View the usernames with
```
cat /etc/mosquitto/passwd
```
For the passwords see the `~acp_prod/acp_prod/secrets/feedmqtt.local.json` 
which connects to this local mosquitto broker.

## Limit MQTT to port 8883 encrypted connections

We will overwrite the non-encrypting `/etc/mosquitto/conf.d/default.conf`:

First, copy and edit the `acp_prod/mosquitto/default_ssl.conf` to INCLUDE THE CORRECT HOSTNAME.

```
sudo cp ~acp_prod/acp_prod/mosquitto/default_ssl.conf /etc/mosquitto/conf.d/default.conf
```

Note this file will allow connections to BOTH port 1883 (plaintext) and 8883 (SSL).

Test a plaintext subscribe via a local console with 

```
mosquitto_sub -v -h localhost -t '#' -u <username> -P <password>
```

For SSL access the hostname given in the server certificate must be used, e.g.:

```
mosquitto_pub -t 'hello' -m 'world' -u <username> -P <password> -p 8883 -h <hostname> --capath /etc/ssl/certs
```

