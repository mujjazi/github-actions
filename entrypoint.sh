#!/bin/bash
set -e
set -o pipefail

if [[ -z "$apitree_user_id" ]]; then
    echo "Set the apitree_user_id env variable."
    exit 1
fi
echo "APITree USER ID...: ${apitree_user_id}"

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
    git_commit_hash=$(git --git-dir=${GITHUB_WORKSPACE}/.git --work-tree=${GITHUB_WORKSPACE} log -1 --pretty=%H -- ${apitree_api_file})
    git_commit_hash_abbrev=$(git --git-dir=${GITHUB_WORKSPACE}/.git --work-tree=${GITHUB_WORKSPACE} log -1 --pretty=%h -- ${apitree_api_file})
    git_commit_subject=$(git --git-dir=${GITHUB_WORKSPACE}/.git --work-tree=${GITHUB_WORKSPACE} log -1 --pretty=%s -- ${apitree_api_file})

    if [[ $apitree_api_type == "public" ]]; then
        apitree_commit_message=${git_commit_subject}
    else
        apitree_commit_message="[${git_commit_hash_abbrev}](https://github.com/${GITHUB_REPOSITORY}/commit/${git_commit_hash}) - ${git_commit_subject}"
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