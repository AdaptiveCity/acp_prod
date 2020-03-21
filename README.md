# Adaptive City Program production server build and system installation

These steps describe the process of getting from a bare brand new server to a running ACP real-time server
platform. The specific machine comments, e.g. regarding iTrac relate to a Dell PowerEdge server.

### Install Ubuntu on the server

These instructions assume you've downloaded the appropriate Ubuntu Server iso image, e.g. from
```
https://www.ubuntu.com/download/server
```
Note that the default download is the 'live' CD, using Subiquity which is *incompatible* with Dell iDrac.

If this is a problem for you then install the download version available on the 'alternatives' page:
```
http://cdimage.ubuntu.com/releases/18.04.2/release/
```

Dell F11 - enter boot manager

One-shot UEFI Boot
Disk connected to front USB 1

##### Installation options:
Install Ubuntu
+ Download while installing
+ Install 3rd party
+ Erase Disk and Install
+ Use LVM
> Continue in UEFI mode
> Write changed to disk
> London timezone
+ English (UK) Extended winkeys
+ Enter user details, e.g. for Computer Name use 'tfc-appN'

## Networking

Usually the IP parameters will be set during the boot process.

Note the IP V4 parameters are as follows, with XXX as issued.
```
address 128.232.98.XXX (or 128.232.98.XXX/24 if requested)
gateway 128.232.98.1
netmask 255.255.255.0
dns-nameservers 128.232.1.1 128.232.1.2
```

### Apply immediate updates
```
sudo apt-get update
sudo apt-get upgrade
```

### Install openSSH
```
sudo apt-get install openssh-server
```

Add or update the following two directives in `/etc/ssh/sshd_config`:

```
PermitRootLogin prohibit-password
UseDNS yes
```

### Create local ssh key
```
ssh-keygen -t rsa -b 4096 -C "username@tfc-appN"
```

### Install emacs
```
sudo apt-get install emacs
```

### Add emacs/ssh config files

If required, now is an opportunity to sftp `.emacs.el` and `.ssh/authorized_keys` from your other servers.

### Configure disks as LVM volumes

Run ```tfc_prod/tools/mkdisks.sh``` (as below):
```
#!/bin/bash

sudo pvcreate /dev/sdb
sudo pvcreate /dev/sdc
sudo pvcreate /dev/sdd


sudo vgcreate sdb-vg /dev/sdb
sudo vgcreate sdc-vg /dev/sdc
sudo vgcreate sdd-vg /dev/sdd

sudo lvcreate -L 3.5T -n sdb1 sdb-vg
sudo lvcreate -L 3.5T -n sdc1 sdc-vg
sudo lvcreate -L 3.5T -n sdd1 sdd-vg

sudo mkfs.ext4 /dev/sdb-vg/sdb1
sudo mkfs.ext4 /dev/sdc-vg/sdc1
sudo mkfs.ext4 /dev/sdd-vg/sdd1

sudo mkdir /mnt/sdb1
sudo mkdir /mnt/sdc1
sudo mkdir /mnt/sdd1
```
These steps are listed in more detail (for a single disk /dev/sdb) below.
If you have already run the script above then skip to "Mount drives" section.

E.g. with new 4TB drive as /dev/sdb, check with:
```
sudo fdisk -l
```
Create one LV per disk with:
Create PV:
```
sudo pvcreate /dev/sdb
```
View with:
```
sudo pvdisplay
sudo pvs
```
Create VG:
```
sudo vgcreate sdb-vg /dev/sdb
```
Create LV:
```
sudo lvcreate -L 3.5T -n sdb1 sdb-vg
```
Check with:
```
sudo fdisk -l /dev/sdb-vg/sdb1
```
New LV is now accessible as /dev/sdb-vg/sdb1
Add ext4 filesystem to LV:
```
sudo mkfs.ext4 /dev/sdb-vg/sdb1
```

Set up permanent mount:
Create mount point:
```
sudo mkdir /mnt/sdb1
```
### Mount Drives

Get LV /dev/mapper location:
```
ll /dev/mapper
```
Create fstab entry
```
sudo emacs /etc/fstab
```
adding (e.g.):
```
/dev/mapper/sdb--vg-sdb1 /mnt/sdb1               ext4    defaults 0       2
/dev/mapper/sdc--vg-sdc1 /mnt/sdc1               ext4    defaults 0       2
/dev/mapper/sdd--vg-sdd1 /mnt/sdd1               ext4    defaults 0       2

```
Re-initialize mounts and check filesystem mounted ok:
```
sudo mount -a
df -h
ll /mnt/sdb1
```

### Install Java 8 SDK (JRE?)

```
sudo apt-get install openjdk-8-jdk
```
test with
```
java -version
```
You should see the SDK version 1.8.xxx.

Note that if multiple java versions are to be installed (e.g. on a development server)
then the default can be set with
```
sudo update-alternatives --config java
```
and checked with
```
update-java-alternatives --list
```

### Create (non-sudo) tfc_prod user

with `tfc-appN` as the correct hostname:

```
sudo adduser tfc_prod
<reply to prompts>

su tfc_prod
<enter password>
cd ~
ssh-keygen -t rsa -b 4096 -C "tfc_prod@tfc-appN"
<reply to prompts>
```

### Install git
```
sudo apt install git
```

### Get latest tfc_prod build

```
su tfc_prod
cd ~

git clone https://github.com/SmartCambridge/tfc_prod.git
```

From another server, sftp the current `tfc_prod/secrets/` directory and `tfc_prod/secrets.sh` file.

### Update server `/etc/ssh/ssh_known_hosts`

As a sudoer, run
```
~tfc_prod/tfc_prod/scripts/update_known_hosts.sh >ssh_known_hosts
sudo mv ssh_known_hosts /etc/ssh/
```
If you inspect the ssh_known_hosts file, you should see an entry for each `tfc-appX` server followed
by an identical entry with the `smartcambridge.org` hostname.

### Install Nginx

See nginx/README.md

### Install Monit (?)

See (monit/INSTALLATION.md)[monit/INSTALLATION.md]


### Add the tfc_server JAR file to the tfc_prod directory

Ideally, as a developer user (not tfc_prod), install the tfc_server source 
[https://github.com/SmartCambridge/tfc_server](https://github.com/SmartCambridge/tfc_server)

Run ```mvn clean package``` in the tfc_server directory to create the fat jar.

Copy the fat jar file (such as ~/tfc_server/target/tfc_server-*-fat.jar) to (say) ~/tfc_prod/tfc_2017-09-27.jar.

Alternatively you can simple collect the `tfc_prod/tfc_YYYY-MM-DD.jar` from another server

In the `tfc_prod` directory, create a symlink to the jar file (use the actual name, not tfc_YYYY_MM_DD) with:

```
rm tfc.jar
ln -s tfc_YYYY_MM_DD.jar tfc.jar
```

### Create data directory links

#### Run ```tfc_prod/tools/mkdirs.sh``` as below:
```
#!/bin/bash

# create log directory for tfc_prod user

sudo mkdir /var/log/tfc_prod
sudo chown tfc_prod:tfc_prod /var/log/tfc_prod
sudo chmod a+w /var/log/tfc_prod

echo Log directory /var/log/tfc_prod is setup

# create basic tfc directories in /mnt/sdb1 and /media

sudo mkdir /media/tfc
sudo chown tfc_prod:tfc_prod /media/tfc

sudo mkdir /mnt/sdb1/tfc
sudo chown tfc_prod:tfc_prod /mnt/sdb1/tfc

echo Data directories /media/tfc and /mnt/sdb1/tfc setup

```
#### Create remainder of directories as tfc_prod user

```
sudo su tfc_prod
```
Then run ```tfc_prod/tools/mkdirs_tfc_prod.sh``` as below:
```
#!/bin/bash

# run as user tfc_prod

# create tfc/vix directory and sub-dirs on sdb1

mkdir /mnt/sdb1/tfc/vix

mkdir /mnt/sdb1/tfc/vix/data_bin
mkdir /mnt/sdb1/tfc/vix/data_bin_json
mkdir /mnt/sdb1/tfc/vix/data_zone
mkdir /mnt/sdb1/tfc/vix/data_cache
mkdir /mnt/sdb1/tfc/vix/data_monitor
mkdir /mnt/sdb1/tfc/vix/data_monitor_json

# create links to all vix directories from /media/tfc

mkdir /media/tfc/vix

ln -sfn /mnt/sdb1/tfc/vix/data_bin /media/tfc/vix/data_bin
ln -sfn /mnt/sdb1/tfc/vix/data_bin_json /media/tfc/vix/data_bin_json
ln -sfn /mnt/sdb1/tfc/vix/data_zone /media/tfc/vix/data_zone
ln -sfn /mnt/sdb1/tfc/vix/data_cache /media/tfc/vix/data_cache
ln -sfn /mnt/sdb1/tfc/vix/data_monitor /media/tfc/vix/data_monitor
ln -sfn /mnt/sdb1/tfc/vix/data_monitor_json /media/tfc/vix/data_monitor_json

# set up 'tfc/sys' directory

mkdir /mnt/sdb1/tfc/sys
ln -sfn /mnt/sdb1/tfc/sys /media/tfc/sys

# set up 'tfc/cam_park_local' directory

mkdir /mnt/sdb1/tfc/cam_park_local
ln -sfn /mnt/sdb1/tfc/cam_park_local /media/tfc/cam_park_local

# set up 'tfc/cam_park_rss' directory

mkdir /mnt/sdb1/tfc/cam_park_rss
ln -sfn /mnt/sdb1/tfc/cam_park_rss /media/tfc/cam_park_rss

# set up 'tfc/cam_aq' directory

mkdir /mnt/sdb1/tfc/cam_aq
ln -sfn /mnt/sdb1/tfc/cam_aq /media/tfc/cam_aq

# Cambridge Sensor Network - LoraWAN TTN
# set up 'tfc/csn_ttn' directory

mkdir /mnt/sdb1/tfc/csn_ttn
ln -sfn /mnt/sdb1/tfc/csn_ttn /media/tfc/csn_ttn

# copy data into tfc/sys

cp -r /home/tfc_prod/tfc_prod/config/sys/* /media/tfc/sys

# Create tfc_web log directories

mkdir /var/log/tfc_prod/gunicorn
mkdir /var/log/tfc_prod/pocket_log
```

### Create ```tfc_prod/secrets``` directory

As tfc_prod user:
```
mkdir ~/tfc_prod/secrets
```

Use sftp to populate ```tfc_prod/secrets``` contents from another server.

### Test run Rita Console

```
java -cp tfc.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.console.A" -cluster -cluster-port 10081 >/dev/null 2>>/var/log/tfc_prod/tfc_console.A.err &
```

Test by browsing to ```http://localhost:8081/console``` and ```http://localhost/backdoor/console```.
(Note for localhost you may use the remote server name if necessary).

## Install tfc_web

### Download tfc_web
```
git clone https://github.com/ijl20/tfc_web.git
```

### Setup log rotation

```
sudo cp logrotate/tfc_prod /etc/logrotate.d/tfc_prod
```

### See tfc_web/README.md

### Configure email (for Monit alerts)

Install/configure ssmtp:
```
sudo apt install ssmtp
sudo cp ssmtp/ssmtp.conf /etc/ssmtp
sudo cp ssmtp/revaliases /etc/ssmtp
```
Test by sending an email:
```
ssmtp foo@cam.ac.uk
To: foo@cam.ac.uk
From: bah@cam.ac.uk
Subject: test email from ssmtp

hello world?

```
Note blank lines above, and finish email with CTRL-D.

This ssmtp configuration does a reasonable job of getting
email out of these systems. The envelope FROM address of mail sent by
`root` and `tfc_prod` is re-written to `admin@smartcambridge.org`
(and more local addresses can be added to this list in `revaliases`).
The FROM address of all other
mail has `@cam.ac.uk` appended. The envelope TO address of all mail for
local users with UID < 1000 is rewritten to
`admin@smartcambridge.org`, and for all other users has
`@cam.ac.uk` appended.

This works for almost everything except mail to the 'tfc_prod' local user
which fails because `tfc_prod@cam.ac.uk` doesn't exist. ssmtp
explicitly doesn't support aliasing destination addresses for
UIDs >= 1000. Th only way around this is to explicitly send such mail
to an address that does work, e.e. by including

```
MAILTO=admin@smartcambridge.org
```

at the start of tfc_prod's crontab file.

### Install/configure Monit
Get the ```monitrc``` file  (from tfc_prod@tfc-app2.cl.cam.ac.uk:~/tfc_prod/monit/monitrc)
Note the monitrc file contains
1. The email address alerts will be sent to (and from)
2. The username/password for the web access

```
sudo apt install monit
sudo cp monitrc /etc/monit
sudo service monit restart
```
Note that monitrc contains the email address Alerts should be sent to, so check that.
An alert should be set as soon as Monit is restarted (testfile does not exist) so check your inbox.
Final test by visiting the local monit web page (note the username/password from monitrc):
```
https://tfc-appZ.cl.cam.ac.uk/system/monitor/
```
