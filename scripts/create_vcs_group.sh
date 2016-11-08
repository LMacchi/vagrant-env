#!/bin/bash
CERT=$(puppet config print hostcert)
KEY=$(puppet config print hostprivkey) 
CACERT=$(puppet config print localcacert) 
MASTER=$(puppet config print certname)

curl -X POST --data @/vagrant/scripts/vcs_group.json -H "Content-Type: application/json" --cert $CERT --key $KEY --cacert $CACERT https://${MASTER}:4433/classifier-api/v1/groups
