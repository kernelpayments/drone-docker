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

if [ -z "$PLUGIN_PREFIX" ]; then
    echo "Missing argument prefix"
    exit 1
fi

if [ -z "$PLUGIN_FLAVOR" ]; then
    IMAGE_NAME=$DRONE_REPO_NAME
    BUILD_ARGS=""
else
    IMAGE_NAME=$DRONE_REPO_NAME/$PLUGIN_FLAVOR
    BUILD_ARGS="--build-arg FLAVOR=$PLUGIN_FLAVOR"
fi

if [ -z "$PLUGIN_DIR" ]; then
    PLUGIN_DIR=.
fi

if [ -z "$PLUGIN_DOCKERFILE" ]; then
    PLUGIN_DOCKERFILE=Dockerfile
fi

cd $PLUGIN_DIR

IMAGE=$PLUGIN_PREFIX/$IMAGE_NAME

echo Building...
docker build -t $IMAGE:$DRONE_COMMIT_SHA -f $PLUGIN_DOCKERFILE $BUILD_ARGS .

echo Pushing $IMAGE:$DRONE_COMMIT_SHA ...
docker push $IMAGE:$DRONE_COMMIT_SHA

if [ "$PLUGIN_TAG_LATEST" = true ] ; then
    echo Pushing $IMAGE:latest ...
    docker tag $IMAGE:$DRONE_COMMIT_SHA $IMAGE:latest
    docker push $IMAGE:latest
fi
