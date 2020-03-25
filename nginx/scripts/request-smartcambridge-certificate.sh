#!/bin/bash

# For tsmartcambridge.org/www.smartcambridge.org
certbot certonly \
    --manual \
    --cert-name smartcambridge.org \
    --domains www.smartcambridge.org,smartcambridge.org \
    --manual-auth-hook /home/acp_prod/acp_prod/nginx/scripts/authenticator.sh \
    --manual-cleanup-hook /home/acp_prod/acp_prod/nginx/scripts/cleanup.sh

