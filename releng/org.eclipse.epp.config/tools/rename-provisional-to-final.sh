#!/bin/bash

set -u # run with unset flag error so that missing parameters cause build failure
set -e # error out on any failed commands
set -x # echo all commands used for debugging purposes

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# Read a property from the epp.properties file (which needs to be generated)
# Usage: get_property KEY
function get_property
{
    grep "^$1=" "${DIR}/epp.properties" | cut -d'=' -f2 | sed '-es,\\:,:,'
}

echo Create the epp.properties file
MVN=/opt/tools/apache-maven/latest/bin/mvn
if [ ! -f "$MVN" ]; then
    MVN=mvn
fi
${MVN} clean package -f ${DIR}

RELEASE_NAME=$(get_property RELEASE_NAME)
PREV_RELEASE_NAME=$(get_property PREV_RELEASE_NAME)
NEXT_RELEASE_NAME=$(get_property NEXT_RELEASE_NAME)
RELEASE_MILESTONE=$(get_property RELEASE_MILESTONE)
RELEASE_DIR=$(get_property RELEASE_DIR)
SIMREL_REPO=$(get_property SIMREL_REPO)
EPP_DOWNLOADS=/home/data/httpd/download.eclipse.org/technology/epp
DOWNLOADS=${EPP_DOWNLOADS}/downloads/release/${RELEASE_NAME}
REPO=${EPP_DOWNLOADS}/packages/${RELEASE_NAME}/

SSHUSER="genie.packaging@projects-storage.eclipse.org"
SSH="ssh ${SSHUSER}"
SCP="scp"


ECHO=echo
if [ "$DRY_RUN" == "false" ]; then
    ECHO=""
else
    echo Dry run of build:
fi

if [ "$RELEASE_MILESTONE" != "R" ]; then
    $ECHO "This job is only inteded for R builds"
    exit 1
fi

$ECHO $SSH mv ${DOWNLOADS}/${RELEASE_DIR} ${DOWNLOADS}/R
TOUCHDIRS="${DOWNLOADS}/R"

# ----------------------------------------------------------------------------------------------
#  Touch All Files See Bug 568574: Touch all files for the milestone in the download area to make sure mirrors are not misreporting them as mirrored before sending announcements.
echo Touching ${TOUCHDIRS} recursively
$ECHO $SSH /bin/bash << EOF
  set -u # run with unset flag error so that missing parameters cause build failure
  set -e # error out on any failed commands
  set -x # echo all commands used for debugging purposes
  find ${TOUCHDIRS} | while read i
  do
    touch \$i
  done
EOF
