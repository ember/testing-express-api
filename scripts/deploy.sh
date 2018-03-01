#!/bin/sh

set -eu

docker run \
    --rm \
    --workdir /terraform \
    --volume $(pwd)/terraform:/terraform \
    -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    chrisns/docker-terragrunt init -reconfigure

docker run \
    --rm \
    --workdir /terraform \
    --volume $(pwd)/terraform:/terraform \
    -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    -e APP_VERSION=$TRAVIS_COMMIT \
    chrisns/docker-terragrunt plan -out plan -var "api_version=$APP_VERSION"

docker run \
    --rm \
    --workdir /terraform \
    --volume $(pwd)/terraform:/terraform \
    -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    chrisns/docker-terragrunt apply plan
