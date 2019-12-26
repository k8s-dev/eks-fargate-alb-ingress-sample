#!/bin/bash

# Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


log(){
  echo "[$(date '+%Y-%m-%d %H:%M:%S %Z')] $1"
}


URL=""

log "Waiting for an ALB to be created for ingress"

while [ 1 ]; do 
    URL=$(kubectl get ingress 2048-ingress -o=jsonpath='{.status.loadBalancer.ingress[0].hostname}' --ignore-not-found=true)
    if [[ "$URL" =~ .*elb\.amazonaws\.com$ ]]; then
    break
    fi
done

log "ALB created $URL"
log "Waiting for target to be marked as healthy"

STATUS=""

while [ 1 ]; do
    STATUS=$(curl -I --silent http://$URL | grep HTTP/1.1 | awk '{ print $2}')
    if [[ $STATUS == "200" ]]; then
        break
    fi
    sleep 2
done

log "a target is returning 200 OK, ALB is ready to serve traffic"
log "Sample application is available at http://$URL"