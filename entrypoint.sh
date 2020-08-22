#!/usr/bin/env bash

if [[ "$@" == "bash" ]]; then
    exec $@
fi

export RUNNER_NAME=${RUNNER_NAME:-${HOSTNAME}}
export RUNNER_REPLACE_EXISTING=${RUNNER_REPLACE_EXISTING:-"true"}

if [[ -z $RUNNER_TOKEN && -z $GITHUB_ACCESS_TOKEN ]]; then
    echo "RUNNER_TOKEN or GITHUB_ACCESS_TOKEN is not set"
    exit 1
fi

if [[ -z $RUNNER_REPOSITORY_URL && -z $RUNNER_ORGANIZATION_URL ]]; then
    echo "RUNNER_REPOSITORY_URL or RUNNER_ORGANIZATION_URL is not set"
    exit 1
fi

CONFIG_OPTS=""

if [ "$(echo $RUNNER_REPLACE_EXISTING | tr '[:upper:]' '[:lower:]')" == "true" ]; then
	CONFIG_OPTS="${CONFIG_OPTS} --replace"
fi

if [[ -n $RUNNER_LABELS ]]; then
    CONFIG_OPTS="${CONFIG_OPTS} --labels ${RUNNER_LABELS}"
fi

if [[ -f ".runner" ]]; then
    echo "Runner is already configured"
else
    if [[ ! -z $RUNNER_ORGANIZATION_URL ]]; then
        SCOPE="orgs"
        RUNNER_URL="${RUNNER_ORGANIZATION_URL}"
    else
        SCOPE="repos"
        RUNNER_URL="${RUNNER_REPOSITORY_URL}"
    fi

    if [[ -n $GITHUB_ACCESS_TOKEN ]]; then
        echo "Generating a new runner token with ${SCOPE} scope"

        _PROTO="$(echo "${RUNNER_URL}" | grep :// | sed -e's,^\(.*://\).*,\1,g')"
        _URL="$(echo "${RUNNER_URL/${_PROTO}/}")"
        _PATH="$(echo "${_URL}" | grep / | cut -d/ -f2-)"

        RUNNER_TOKEN="$(curl -XPOST -fsSL \
            -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/${SCOPE}/${_PATH}/actions/runners/registration-token" \
            | jq -r '.token')"
    fi

    ./config.sh \
        --url $RUNNER_URL \
        --token $RUNNER_TOKEN \
        --name $RUNNER_NAME \
        --unattended \
        $CONFIG_OPTS
fi

exec "$@"