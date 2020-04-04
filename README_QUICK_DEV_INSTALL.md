# Quick dev install

This will get the Adaptive City real-time platform running on a local development machine.

For a complete installation see README.md. This installation doesn't set up certificates or SSL.

```
git clone https://github.com/AdaptiveCity/acp_server
sudo apt install maven
cd acp_server
mvn clean package
```

```
sudo adduser acp_prod
```

```
sudo mkdir /data
sudo mkdir /data/acp
sudo chown acp_prod:acp_prod /data/acp
sudo ln -s /data/acp /media/acp
```

```
ssh acp_prod@localhost
git clone https://github.com/AdaptiveCity/acp_prod
```

**Copy `~acp_prod/acp_prod/secrets` from an existing server to your dev server `~acp_prod/acp_prod/secrets`**

**Return to your dev sudo account**

```
sudo apt install nginx
sudo mkdir /etc/nginx/includes2
sudo cp ~acp_prod/acp_prod/nginx/includes2/* /etc/nginx/includes2/
sudo cp ~acp_prod/acp_prod/nginx/sites-available/acp_dev.conf /etc/nginx/sites-available/
sudo nginx -t
sudo service nginx restart
```

```
sudo mkdir /var/log/acp_prod
sudo chown acp_prod:acp_prod /var/log/acp_prod
sudo chmod a+w /var/log/acp_prod
```

```
sudo apt install mosquitto mosquitto-clients
sudo cp ~acp_prod/acp_prod/secrets/mosquitto_passwd /etc/mosquitto/passwd
sudo cp ~acp_prod/acp_prod/secrets/mosquitto_ttn.conf /etc/mosquitto/conf.d/
sudo cp ~acp_prod/acp_prod/mosquitto/default.conf /etc/mosquitto/conf.d/
sudo systemctl stop mosquitto
sudo systemctl start mosquitto
service mosquitto status
```

**To run the platform**
```
ssh acp_prod@localhost
cd acp_prod
cp ~<dev user>/acp_server/target/*fat.jar acp_YYYY-MM-DD.jar (use today's date)
ln -s acp_YYYY-MM-DD.jar acp.jar
./run.sh
```

**At this point the real-time system should be running**

Check the names of running verticles by `acp_prod/tools/ps.sh`.

Check the arrival of incoming data at `/media/acp/`.

Check the nginx web serving at `https://localhost/backdoor/system_status.html`
