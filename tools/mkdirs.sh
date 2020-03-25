#!/bin/bash

# create log directory for acp_prod user

sudo mkdir /var/log/acp_prod
sudo chown acp_prod:acp_prod /var/log/acp_prod
sudo chmod a+w /var/log/acp_prod

echo Log directory /var/log/acp_prod is setup

# create basic ACP directories in /mnt/sdb1 and /media

sudo mkdir /mnt/sdb1/acp
sudo chown acp_prod:acp_prod /mnt/sdb1/acp


sudo ln -s /mnt/sdb1/acp /media/acp

echo Data directories set up at /media/acp

