#!/bin/bash
set -e
set -o pipefail

if [[ -z "$INPUT_APITREE_USER_ID" ]]; then
    echo "Set the apitree_user_id env variable."
    exit 1
fi
echo "APITree USER ID...: ${apitree_user_id}"
echo "APITree USER ID...: ${INPUT_APITREE_USER_ID}"

if [[ -z "$apitree_api_nickname" ]]; then
    echo "Set the apitree_api_nickname env variable."
    exit 1
fi
echo "API nickname......: ${apitree_api_nickname}"

if [[ -z "$apitree_api_type" ]]; then
    apitree_api_type="private"
fi
echo "API type..........: ${apitree_api_type}"

if [[ -z "$apitree_api_file" ]]; then
    echo "Set the apitree_api_file env variable."
    exit 1
fi
echo "API file..........: ${apitree_api_file}"

if [[ -z "$apitree_auto_commit" ]]; then
    apitree_auto_commit=true
fi
echo "API auto-commit...: ${apitree_auto_commit}"

if [[ -z "$apitree_commit_message" ]]; then
    git_sha=$(git hash-object ${apitree_api_file})
    git_log=$(git log -1 --pretty=%s -- ${apitree_api_file})

    if [[ apitree_api_type == "public" ]]; then
        apitree_commit_message=${git_log}
    else
        apitree_commit_message="[$(git rev-parse --short ${git_sha})](https://github.com/${GITHUB_REPOSITORY}/commit/${git_sha}) - ${git_log}"
    fi
fi
echo "Commit message....: ${apitree_commit_message}"

if [[ -z "$apitree_token" ]]; then
    echo "Set the apitree_token env variable."
    exit 1
fi

protocol="https"
host="core-api.apitree.com"

api_exists=$(curl -v -s -o /dev/null -I \
    -w "%{http_code}" \
    -X GET "${protocol}://${host}/api/${apitree_user_id}/${apitree_api_nickname}" \
    -H "Authorization: Bearer ${apitree_token}")

if [[ $api_exists == "401" ]]; then
    echo "Invalid apitree_token env variable provided."
    exit 1
fi

if [[ $api_exists == "404" ]]; then
    echo "API not found"

    curl -v \
        -H "Content-Type:multipart/form-data" \
        -H "Authorization: Bearer ${apitree_token}" \
        -F "body={\"type\":\"${apitree_api_type}\",\"nickname\":\"${apitree_api_nickname}\",\"autoCommit\":${apitree_auto_commit},\"commitMessage\":\"${apitree_commit_message}\"}" \
        -F "spec=@${GITHUB_WORKSPACE}/${apitree_api_file}" \
        "${protocol}://${host}/api/${apitree_user_id}/import"

else
    echo "API found"

    curl -v \
        -H "Content-Type:multipart/form-data" \
        -H "Authorization: Bearer ${apitree_token}" \
        -F "body={\"type\":\"${apitree_api_type}\",\"autoCommit\":${apitree_auto_commit},\"commitMessage\":\"${apitree_commit_message}\"}" \
        -F "spec=@${GITHUB_WORKSPACE}/${apitree_api_file}" \
        "${protocol}://${host}/api/${apitree_user_id}/${apitree_api_nickname}/import"

fi