#!/bin/bash -ex

# Extract JSON args into shell variables
JQ=$(command -v jq || true)
[[ -z "${JQ}" ]] && echo "ERROR: Missing command: 'jq'" >&2 && exit 1

eval "$(${JQ} -r '@sh "URL=\(.url) ACTION=\(.action) ENTITY=\(.entity) ENTITY_TYPE=\(.entity_type)"')"

function log() {
    level=$1
    msg=$2
    echo "${LEVEL}: $msg" >&2
}

TMP_DIR=$(mktemp -d)
function cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

if [[ ! -z ${GOOGLE_CREDENTIALS+x} && ! -z ${GOOGLE_PROJECT+x} ]]; then
  export CLOUDSDK_CONFIG=${TMP_DIR}
  gcloud auth activate-service-account --key-file - <<<"${GOOGLE_CREDENTIALS}"
  gcloud config set project "${GOOGLE_PROJECT}"
fi

case $ACTION in
ch)
    case $ENTITY_TYPE in
    u)
        # Entity: <id|email>:<perm>
        log "INFO" "Change user type entity"
        gsutil acl ch -u "${ENTITY}" ${URL}
        ;;
    g)
        # Entity: <id|email|domain|All|AllAuth>:<perm>
        log "INFO" "Change group type entity"
        gsutil acl ch -g "${ENTITY}" ${URL}
        ;;
    p)
        # Entity: <viewers|editors|owners>-<project number>
        log "INFO" "Change project type entity"
        gsutil acl ch -p "${ENTITY}" ${URL}
        ;;
    d)
        # Delete entity: <id|email|domain|All|AllAuth|<viewers|editors|owners>-<project number>>
        log "INFO" "Delete entity"
        gsutil acl ch -d "${ENTITY}" ${URL}
        ;;
    esac

    ;;
noop)
    log "INFO" "No operation"
    ;;
*)
    echo "ERROR: Unsupported action: $ACTION" >&2
    exit 1
    ;;
esac

# Get the current ACL
ACL=$(gsutil acl get ${URL})

# Output results in JSON format.
jq -n \
  --arg url "${URL}" \
  --arg action "${ACTION}" \
  --arg entity_type "${ENTITY_TYPE}" \
  --arg entity "${ENTITY}" \
  --arg acl "${ACL}" \
    '{"url":$url, "action":$action, "entity_type":$entity_type, "entity":$entity, "acl":$acl}'