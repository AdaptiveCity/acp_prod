#!/bin/bash

# update_known_hosts.sh
#
# Will collect host ssh keys from tfc-app[6-9] and write to STDOUT correct entries for
# /etc/ssh/ssh_known_hosts
# A cdbb.uk entry will be duplicated from each tfc-app[6-9] host key entry in ssh_known_host
#
# This script can most simply be used with:
# scripts/update_known_hosts.sh >ssh_known_hosts
# sudo mv ssh_known_hosts /etc/ssh/
#
# Alternatively (if you have existing entries you want to keep)
# delete bad entries from /etc/ssh/ssh_known_hosts and append new records from above.
#

for n in 6 7 8 9;
do
  name=tfc-app${n}.cl.cam.ac.uk
  entry=$(ssh-keyscan -t ecdsa $name)
  ip=$(dig +short $name)
  #ssh-keyscan -t ecdsa $name
  entrylength=${#entry}
  if ((entrylength <= 20))
  then
      echo bad exit for $name 1>&2
      continue
  fi
  echo ${entry/$name/$name,cdbb.uk,www.cdbb.uk,$ip}
done

