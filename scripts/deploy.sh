#!/bin/sh

set -eu

docker run \
      --workdir /terraform \ 
      --volume $(pwd)/terraform:/terraform \ 
      -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
      chrisns/docker-terragrunt init -reconfigure
