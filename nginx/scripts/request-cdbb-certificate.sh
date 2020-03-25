#!/bin/bash

# For [www.]cdbb.uk
certbot certonly \
    --manual \
    --cert-name cdbb.uk \
    --domains www.cdbb.uk,cdbb.uk \
    --manual-auth-hook /home/acp_prod/acp_prod/nginx/scripts/authenticator.sh \
    --manual-cleanup-hook /home/acp_prod/acp_prod/nginx/scripts/cleanup.sh

