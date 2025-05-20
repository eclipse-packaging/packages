#!/bin/bash

set -u # run with unset flag error so that missing parameters cause build failure
set -e # error out on any failed commands
set -x # echo all commands used for debugging purposes

SSHUSER="genie.packaging@projects-storage.eclipse.org"
SSH="ssh ${SSHUSER}"
SCP="scp"

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# Read a property from the epp.properties file (which needs to be generated)
# Usage: get_property KEY
function get_property
{
    grep "^$1=" "${DIR}/epp.properties" | cut -d'=' -f2
}

echo Create the epp.properties file
mvn clean package -f ${DIR}

RELEASE_NAME=$(get_property RELEASE_NAME)
PREV_RELEASE_NAME=$(get_property PREV_RELEASE_NAME)
NEXT_RELEASE_NAME=$(get_property NEXT_RELEASE_NAME)
RELEASE_MILESTONE=$(get_property RELEASE_MILESTONE)
RELEASE_DIR=$(get_property RELEASE_DIR)
SIMREL_REPO=$(get_property SIMREL_REPO)
BUILDING="/home/data/httpd/download.eclipse.org/technology/epp/building"
STAGING="/home/data/httpd/download.eclipse.org/technology/epp/staging"

# -------------------------
# Prepare template email with all the correct information
cat > _email.txt <<EOM
This is the template email sent to the epp-dev mailing list. Please update the TODO section when sending emails to
advise of last minute issues, etc.

Hi everyone,

Our next milestone build is available for testing: EPP ${RELEASE_NAME} ${RELEASE_MILESTONE}

TODO say: No special issues to report! or write the issues to bring to the attention of the group when sending the email.

I have been following the steps on https://github.com/eclipse-packaging/packages/labels/endgame - you can see the checkmarks as to what is done.

Download link: https://download.eclipse.org/technology/epp/downloads/release/${RELEASE_NAME}/${RELEASE_MILESTONE}/

EPP was built with the p2 repositories at:

${SIMREL_REPO} and
https://download.eclipse.org/technology/epp/packages/${RELEASE_NAME}/${RELEASE_DIR}/

Please test and send your +1 to this mailing list. +1s are optional as the package will be published anyway.

Last +1 received for each package and platform (apologies if I missed one of your +1 emails, just let me know and I will update Last Recorded +1)

Packages:
committers - 2024-12 RC2
cpp - 2025-06 M2
dsl - 2025-06 M2
embedcpp - 2024-09 RC2
java - 2024-12 RC2
jee -  2025-03 RC2
modeling - 2025-03 RC2
php - 2025-06 M1
rcp - 2024-12 RC2
scout - 2025-03 RC2

Platforms:
Linux x86_64 - 2025-06 M2
Linux aarch64 - 2023-09 RC2
Linux riscv64 - 2025-06 M2
Windows x86_64 - 2025-03 RC2
Windows on Arm - 2025-03 RC2
macOS x86_64 - 2024-09 RC2
macOS aarch64 - 2025-03 RC2

Thank you for testing!

Regards,
Jonah
EOM

${SCP} -rp _email.txt "${SSHUSER}:"${BUILDING}

# place a timestamp and CI build info in the directory
echo "TIMESTAMP: $(date)" > _ci-info.txt
echo "CI URL: ${BUILD_URL}" >> _ci-info.txt

${SCP} -rp _ci-info.txt "${SSHUSER}:"${BUILDING}


${SSH} rm -rf ${STAGING}-previous
if $SSH test -e ${STAGING}; then
  ${SSH} mv ${STAGING} ${STAGING}-previous
fi
${SSH} mv ${BUILDING} ${STAGING}
${SSH} rm -rf ${STAGING}-previous
