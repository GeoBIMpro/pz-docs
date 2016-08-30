#!/bin/bash

. setup.sh

check_arg $1 serviceId

# tag::public[]
serviceId=`unquote $1`

job='{
    "type": "execute-service",
    "data": {
        "serviceId": "'"$serviceId"'",
        "dataInputs": { },
        "dataOutput": [ { "mimeType":"application/json", "type":"text" } ]
    }
}'

$curl -X POST -d "$job" $PZSERVER/job | jq '.data.jobId'
# end::public[]
