#!/usr/bin/env bash

# This script is intended to be run by the CI/CD pipeline to push a docker tag previously built by build-docker.sh

set -Eeo pipefail

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -a|--aws-account)
    aws_acct="$2"
    echo "--- aws-account"
    echo $aws_acct
    shift # past argument
    shift # past value
    ;;
    -t|--docker-tag)
    docker_tag="$2"
    echo "--- docker-tag"
    echo $docker_tag
    shift # past argument
    shift # past value
    ;;
    -v|--tf-venue)
    tf_venue="$2"
    echo "--- tf_venue"
    echo $tf_venue
    case $tf_venue in
     sit|uat|ops) ;;
     *)
        echo "tf_venue must be sit, uat, or ops"
        exit 1;;
    esac
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

USAGE="push-docker-ecr.sh -t|--docker-tag docker_tag -v|--tf-venue tf_venue"

# shellcheck disable=SC2154
if [[ -z "${tf_venue}" ]]; then
  echo "tf_venue required. One of sit, uat, ops" >&2
  echo "$USAGE" >&2
  exit 1
fi

# shellcheck disable=SC2154
if [[ -z "${docker_tag}" ]]; then
  echo "docker_tag required." >&2
  echo "$USAGE" >&2
  exit 1
fi

set -u

repositoryName=$(echo "${docker_tag}" | awk -F':' '{print $1}')

# Get the AWS Account ID for this venue/profile
# shellcheck disable=SC2154
# aws_acct=$(aws sts get-caller-identity | python -c "import sys, json; print(json.load(sys.stdin)['Account'])")

echo "aws_acct"
echo $aws_acct

# Create repository if needed
aws ecr create-repository --repository-name "${repositoryName}" || echo "No need to create, repository ${repositoryName} already exists"

# Login to ECR
echo "aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin \"$aws_acct\".dkr.ecr.us-west-2.amazonaws.com"
set +x
$(aws ecr get-login --no-include-email --region us-west-2 2> /dev/null) || \
  docker login --username AWS --password "$(aws ecr get-login-password --region us-west-2 )" "$aws_acct".dkr.ecr.us-west-2.amazonaws.com
set -x

# Tag the image for this venue's ECR
docker tag "${docker_tag}" "$aws_acct".dkr.ecr.us-west-2.amazonaws.com/"${docker_tag}"

# Push the tag
docker push "$aws_acct".dkr.ecr.us-west-2.amazonaws.com/"${docker_tag}"
