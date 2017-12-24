#!/bin/bash

set -e

AUTH_STRING=$((echo -n oauth2accesstoken:; curl -s -H Metadata-Flavor:Google http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token | jq -r .access_token ) | tr -d '\n' | base64 -w0)

mkdir -p ~/.docker
cat > ~/.docker/config.json <<EOF
{
    "auths": {
        "https://appengine.gcr.io": {"auth": "$AUTH_STRING", "email": "not@val.id"},
        "https://asia-mirror.gcr.io": {"auth": "$AUTH_STRING", "email": "not@val.id"},
        "https://asia.gcr.io": {"auth": "$AUTH_STRING", "email": "not@val.id"},
        "https://b.gcr.io": {"auth": "$AUTH_STRING", "email": "not@val.id"},
        "https://bucket.gcr.io": {"auth": "$AUTH_STRING", "email": "not@val.id"},
        "https://eu-mirror.gcr.io": {"auth": "$AUTH_STRING", "email": "not@val.id"},
        "https://eu.gcr.io": {"auth": "$AUTH_STRING", "email": "not@val.id"},
        "https://gcr.io": {"auth": "$AUTH_STRING", "email": "not@val.id"},
        "https://gcr.kubernetes.io": {"auth": "$AUTH_STRING", "email": "not@val.id"},
        "https://k8s.gcr.io": {"auth": "$AUTH_STRING", "email": "not@val.id"},
        "https://l.gcr.io": {"auth": "$AUTH_STRING", "email": "not@val.id"},
        "https://launcher.gcr.io": {"auth": "$AUTH_STRING", "email": "not@val.id"},
        "https://mirror.gcr.io": {"auth": "$AUTH_STRING", "email": "not@val.id"},
        "https://us-mirror.gcr.io": {"auth": "$AUTH_STRING", "email": "not@val.id"},
        "https://us.gcr.io": {"auth": "$AUTH_STRING", "email": "not@val.id"}
    }
}
EOF

echo Building...
docker build -t eu.gcr.io/kernel-prod/$DRONE_REPO_NAME:$DRONE_COMMIT_SHA .

echo Pushing eu.gcr.io/kernel-prod/$DRONE_REPO_NAME:$DRONE_COMMIT_SHA ...
docker push eu.gcr.io/kernel-prod/$DRONE_REPO_NAME:$DRONE_COMMIT_SHA

if [ "$PLUGIN_TAG_LATEST" = true ] ; then
    docker tag eu.gcr.io/kernel-prod/$DRONE_REPO_NAME:$DRONE_COMMIT_SHA eu.gcr.io/kernel-prod/$DRONE_REPO_NAME:latest
    docker push eu.gcr.io/kernel-prod/$DRONE_REPO_NAME:latest
fi
