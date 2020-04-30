#!/bin/bash -e

# This scripts installs jq: http://stedolan.github.io/jq/

JQ=/usr/bin/jq
curl https://stedolan.github.io/jq/download/linux64/jq > $JQ && chmod +x $JQ
ls -la $JQ