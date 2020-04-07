# Adaptive City Platform Zookeeper installation

```
sudo adduser zookeeper
```
Data directory
```
sudo mkdir /var/lib/zookeeper
sudo chown zookeeper:zookeeper /var/lib/zookeeper
```
Log directory
```
sudo mkdir /var/log/zookeeper
sudo chown zookeeper:zookeeper /var/log/zookeeper
```
Code directory
```
sudo mkdir /opt/zookeeper-3.6.0
sudo chown zookeeper:zookeeper /opt/zookeeper-3.6.0

sudo ln -s /opt/zookeeper-3.6.0 /opt/zookeeper

```
As user `zookeeper`:
```
wget -0- "https://downloads.apache.org/zookeeper/zookeeper-3.6.0/apache-zookeeper-3.6.0-bin.tar.gz"
tar -xzf "apache-zookeeper-3.6.0-bin.tar.gz" --directory /opt/zookeeper-3.6.0 --strip-components 1
cp ~acp_prod/acp_prod/secrets/zoo.conf /opt/zookeeper/conf/
cp ~acp_prod/acp_prod/zookeeper/conf/zookeeper-env.sh /opt/zookeeper/conf/
```

Start zookeeper
```
/opt/zookeeper/bin/zkServer.sh --config /opt/zookeeper/conf start
```
Check running zookeeper
```
echo srvr | nc localhost 2181
```

Add to crontab
```
crontab -e

@reboot /opt/zookeeper/bin/zkServer.sh --config /opt/zookeeper/conf start
```
