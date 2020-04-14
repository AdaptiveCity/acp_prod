# Adaptive City Program production server build and system installation

These steps describe the process of getting from a bare brand new server to a running ACP real-time server
platform. The specific machine comments, e.g. regarding iTrac relate to a Dell PowerEdge server.

## Summary steps / checklist

1. [Install Ubuntu on the server](#install-ubuntu-on-the-server)

2. [Create (non-sudo) acp_prod user](#create-non-sudo-acp_prod-user)

3. As `acp_prod` user [clone this `acp_prod` repo](#get-latest-acp_prod-build)

4. [Install nginx](nginx/README.md)

5. [Install Java](#install-java-8-sdk)

6. [Install zookeeper](https://github.com/AdaptiveCity/acp_zookeeper)

7. [Setup data directories](#create-data-directory-links)

8. [Setup MQTT](https://github.com/AdaptiveCity/acp_local_mqtt)

9. [Install `acp_server`](#add-the-acp_server-jar-file-to-the-acp_prod-directory)


## Install Ubuntu on the server

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

### Installation options:
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

### Networking

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

### Configure disks as LVM volumes

Run ```acp_prod/tools/mkdisks.sh``` (as below):
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

### Create (non-sudo) acp_prod user

with `tfc-appN` as the correct hostname:

```
sudo adduser acp_prod
<reply to prompts>

su acp_prod
<enter password>
cd ~
ssh-keygen -t rsa -b 4096 -C "acp_prod@tfc-appN"
<reply to prompts>
```

### Install git
```
sudo apt install git
```

### Get latest acp_prod build

```
su acp_prod
cd ~

git clone https://github.com/AdaptiveCity/acp_prod.git
```

From another server, sftp the current `acp_prod/secrets/` directory.

### Update server `/etc/ssh/ssh_known_hosts`

As a sudoer, run
```
~acp_prod/acp_prod/scripts/update_known_hosts.sh >ssh_known_hosts
sudo mv ssh_known_hosts /etc/ssh/
```
If you inspect the ssh_known_hosts file, you should see an entry for each `tfc-appX` server followed
by an identical entry with the `csbb.uk` and `www.cddb.uk` hostnames.

### Install Nginx

See [nginx/README.md](nginx/README.md)

### Install Java 8 SDK

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

### Install Zookeeper

See [https://github.com/AdaptiveCity/acp_zookeeper](https://github.com/AdaptiveCity/acp_zookeeper)

## Create data directory links

### Create /media/acp for sensor data

Create an `acp` directory on any filesystem, and link it to
`/media/acp`, owned by the `acp_prod` user.

E.g. you as sudoer can run ```acp_prod/tools/mkdirs.sh``` as below:

```
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

```

### Create acp_web log directories

As user `acp_prod`:

```
mkdir /var/log/acp_prod/gunicorn
mkdir /var/log/acp_prod/pocket_log
```

### Create ```acp_prod/secrets``` directory

As acp_prod user:

Use sftp to populate ```acp_prod/secrets``` contents from another server.

### Install MQTT (mosquitto)

See [https://github.com/AdaptiveCity/acp_local_mqtt](https://github.com/AdaptiveCity/acp_local_mqtt)

### Add the acp_server JAR file to the acp_prod directory

Ideally, as a developer user (not acp_prod), install the acp_server source
[https://github.com/AdaptiveCity/acp_server](https://github.com/AdaptiveCity/acp_server)

Run ```mvn clean package``` in the acp_server directory to create the fat jar.

Copy the fat jar file (such as `~/acp_server/target/acp_server-*-fat.jar`) to (say)
`~/acp_prod/acp_YYYY-MM-DD.jar`, where `YYYY-MM-DD` is today's date.

Alternatively you can simple collect the `acp_prod/acp_YYYY-MM-DD.jar` from another server

In the `acp_prod` directory, create a symlink to the jar file (use the actual name,
not acp_YYYY_MM_DD) with:

```
rm acp.jar
ln -s acp_YYYY_MM_DD.jar acp.jar
```

### Test run the ACP Console

As the `acp_prod` user:
```
cd ~/acp_prod

java -cp 'acp.jar:configs' io.vertx.core.Launcher run "service:console.A" -cluster >/dev/null 2>>/var/log/acp_prod/console.A.err &
```

You can check the verticle is running with `~/acp_prod/tools/ps.sh`.

If the verticle fails to launch, re-run it without the stdout and stderr being redirected and
see what errors you get.

Test by browsing to `http://localhost/backdoor/system_status.html`.
(Note for localhost you may use the remote server name if necessary).

Also conform the logfile is being written to `/var/log/acp_prod/console.A.err`.

## Setup crontab to start real-time platform on boot

As `acp_prod` user:
```
crontab -e
```
Add entry:
```
@reboot /home/acp_prod/acp_prod/run.sh
```

# Install acp_web

### Download acp_web
```
git clone https://github.com/AdaptiveCity/acp_web
```

### Setup log rotation

```
sudo cp logrotate/acp_prod /etc/logrotate.d/acp_prod
```

### See acp_web/README.md

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
`root` and `acp_prod` is re-written to `admin@cdbb.uk`
(and more local addresses can be added to this list in `revaliases`).
The FROM address of all other
mail has `@cam.ac.uk` appended. The envelope TO address of all mail for
local users with UID < 1000 is rewritten to
`admin@cdbb.uk`, and for all other users has
`@cam.ac.uk` appended.

This works for almost everything except mail to the 'acp_prod' local user
which fails because `acp_prod@cam.ac.uk` doesn't exist. ssmtp
explicitly doesn't support aliasing destination addresses for
UIDs >= 1000. Th only way around this is to explicitly send such mail
to an address that does work, e.e. by including

```
MAILTO=admin@cdbb.uk
```

at the start of acp_prod's crontab file.

### (For optional status alerts) Install Monit

See (monit/INSTALLATION.md)[monit/INSTALLATION.md]

