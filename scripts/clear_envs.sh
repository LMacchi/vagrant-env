#!/bin/bash
CACERT=$(puppet master --configprint cacert) 
CERT=$(puppet master --configprint hostcert)
KEY=$(puppet master --configprint hostprivkey)

curl -i --cert ${CERT} --key ${KEY} --cacert ${CACERT} -X DELETE https://$(facter fqdn):8140/puppet-admin-api/v1/environment-cache
