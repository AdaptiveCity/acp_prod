#!/bin/bash

# For the current host

domain=$(hostname)
if [[ ! "${domain}" =~ "." ]]
then
    domain="${domain}.cl.cam.ac.uk"
fi

certbot certonly \
    --manual \
    --cert-name acp_prod \
    --domains "${domain}" \
    --manual-auth-hook /home/acp_prod/acp_prod/nginx/scripts/authenticator.sh \
    --manual-cleanup-hook /home/acp_prod/acp_prod/nginx/scripts/cleanup.sh

