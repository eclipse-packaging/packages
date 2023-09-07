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
RELEASE_MILESTONE=$(get_property RELEASE_MILESTONE)
RELEASE_DIR=$(get_property RELEASE_DIR)
SIMREL_REPO=$(get_property SIMREL_REPO)
EPP_DOWNLOADS=/home/data/httpd/download.eclipse.org/technology/epp
DOWNLOADS=${EPP_DOWNLOADS}/downloads/release/${RELEASE_NAME}/
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

# ----------------------------------------------------------------------------------------------
# Move the repo and downloads into their location

$ECHO $SSH mkdir -p ${REPO}
$ECHO $SSH mkdir -p ${DOWNLOADS}
$ECHO $SSH mv ${EPP_DOWNLOADS}/staging/repository ${REPO}/${RELEASE_DIR}
if [ "$RELEASE_MILESTONE" != "R" ]; then
    $ECHO $SSH mv ${EPP_DOWNLOADS}/staging ${DOWNLOADS}/${RELEASE_MILESTONE}
    TOUCHDIRS="${REPO}/${RELEASE_DIR} ${DOWNLOADS}/${RELEASE_MILESTONE}"
else
    $ECHO $SSH mv ${EPP_DOWNLOADS}/staging ${DOWNLOADS}/${RELEASE_DIR}
    TOUCHDIRS="${REPO}/${RELEASE_DIR} ${DOWNLOADS}/${RELEASE_DIR}"
fi

# ----------------------------------------------------------------------------------------------
# Update the release.xml for Web team to consume and create the entries in https://www.eclipse.org/downloads/packages/
# The other consumer of this is some external packagers, see Bug 577659 Comment 3 for an example
cat > release.xml <<EOM
<packages>
<past>2019-03/R</past>
<past>2019-06/R</past>
<past>2019-09/R</past>
<past>2019-12/R</past>
<past>2020-03/R</past>
<past>2020-06/R</past>
<past>2020-09/R</past>
<past>2020-12/R</past>
<past>2021-03/R</past>
<past>2021-06/R</past>
<past>2021-09/R</past>
<past>2021-12/R</past>
<past>2022-03/R</past>
<past>2022-06/R</past>
<past>2022-09/R</past>
<past>2022-12/R</past>
<past>2023-03/R</past>
<past>2023-06/R</past>
<present>2023-09/R</present>
</packages>
EOM
$ECHO $SCP release.xml "${SSHUSER}:"${EPP_DOWNLOADS}/downloads/release/release.xml


# ----------------------------------------------------------------------------------------------
# Prepare compositeArtifacts.xml/compositeContent.xml that will be made visible with https://ci.eclipse.org/packaging/job/epp-makeVisible/

TIMESTAMP=$(date +%s000)

CONTENTXML="<?xml version='1.0' encoding='UTF-8'?>
<?compositeMetadataRepository version='1.0.0'?>
<repository name='Eclipse Packaging Project EPP ${RELEASE_NAME}'
    type='org.eclipse.equinox.internal.p2.metadata.repository.CompositeMetadataRepository'
    version='1.0.0'>
  <properties size='1'>
    <property name='p2.timestamp' value='${TIMESTAMP}'/>
  </properties>
  <children size='1'>
    <child location='${RELEASE_DIR}'/>
  </children>
</repository>
"

echo "$CONTENTXML" > ./compositeContent.xml
$ECHO $SCP compositeContent.xml "${SSHUSER}:"${REPO}/compositeContent${RELEASE_MILESTONE}.xml

ARTIFACTXML="<?xml version='1.0' encoding='UTF-8'?>
<?compositeArtifactRepository version='1.0.0'?>
<repository name='Eclipse Packaging Project EPP ${RELEASE_NAME}'
    type='org.eclipse.equinox.internal.p2.artifact.repository.CompositeArtifactRepository'
    version='1.0.0'>
  <properties size='1'>
    <property name='p2.timestamp' value='${TIMESTAMP}'/>
  </properties>
  <children size='1'>
    <child location='${RELEASE_DIR}'/>
  </children>
</repository>
"

echo "$ARTIFACTXML" > ./compositeArtifacts.xml
$ECHO $SCP compositeArtifacts.xml "${SSHUSER}:"${REPO}/compositeArtifacts${RELEASE_MILESTONE}.xml

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
