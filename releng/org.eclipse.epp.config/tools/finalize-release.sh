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


echo "----------------------------------------------------------------------------------------------"
echo "Prepare compositeArtifacts.xml/compositeContent.xml for "latest" that points at RELEASE_NAME"
$ECHO ${SSH} mkdir ${EPP_DOWNLOADS}/packages/latest/

TIMESTAMP=$(date +%s000)

CONTENTXML="<?xml version='1.0' encoding='UTF-8'?>
<?compositeMetadataRepository version='1.0.0'?>
<repository name='Eclipse Packaging Project EPP Latest (${RELEASE_NAME})'
    type='org.eclipse.equinox.internal.p2.metadata.repository.CompositeMetadataRepository'
    version='1.0.0'>
  <properties size='1'>
    <property name='p2.timestamp' value='${TIMESTAMP}'/>
  </properties>
  <children size='1'>
    <child location='../${RELEASE_NAME}'/>
  </children>
</repository>
"

echo "$CONTENTXML" > ./compositeContent.xml
echo "==== Start Content of compositeContent.xml ===="
cat ./compositeContent.xml
echo "==== End Content of compositeContent.xml ===="
$ECHO $SCP compositeContent.xml "${SSHUSER}:"${EPP_DOWNLOADS}/packages/latest/

ARTIFACTXML="<?xml version='1.0' encoding='UTF-8'?>
<?compositeArtifactRepository version='1.0.0'?>
<repository name='Eclipse Packaging Project EPP Latest (${RELEASE_NAME})'
    type='org.eclipse.equinox.internal.p2.artifact.repository.CompositeArtifactRepository'
    version='1.0.0'>
  <properties size='1'>
    <property name='p2.timestamp' value='${TIMESTAMP}'/>
  </properties>
  <children size='1'>
    <child location='../${RELEASE_NAME}'/>
  </children>
</repository>
"

echo "$ARTIFACTXML" > ./compositeArtifacts.xml
echo "==== Start Content of compositeArtifacts.xml ===="
cat ./compositeArtifacts.xml
echo "==== End Content of compositeArtifacts.xml ===="
$ECHO $SCP compositeArtifacts.xml "${SSHUSER}:"${EPP_DOWNLOADS}/packages/latest/


echo "----------------------------------------------------------------------------------------------"
echo "Prepare compositeArtifacts.xml/compositeContent.xml for next release that points at RELEASE_NAME"
$ECHO ${SSH} mkdir ${EPP_DOWNLOADS}/packages/${NEXT_RELEASE_NAME}/

TIMESTAMP=$(date +%s000)

CONTENTXML="<?xml version='1.0' encoding='UTF-8'?>
<?compositeMetadataRepository version='1.0.0'?>
<repository name='Eclipse Packaging Project EPP ${NEXT_RELEASE_NAME}'
    type='org.eclipse.equinox.internal.p2.metadata.repository.CompositeMetadataRepository'
    version='1.0.0'>
  <properties size='1'>
    <property name='p2.timestamp' value='${TIMESTAMP}'/>
  </properties>
  <children size='1'>
    <child location='../${RELEASE_NAME}'/>
  </children>
</repository>
"

echo "$CONTENTXML" > ./compositeContent.xml
echo "==== Start Content of compositeArtifacts.xml ===="
cat ./compositeArtifacts.xml
echo "==== End Content of compositeArtifacts.xml ===="
$ECHO $SCP compositeContent.xml "${SSHUSER}:"${EPP_DOWNLOADS}/packages/${NEXT_RELEASE_NAME}/

ARTIFACTXML="<?xml version='1.0' encoding='UTF-8'?>
<?compositeArtifactRepository version='1.0.0'?>
<repository name='Eclipse Packaging Project EPP ${NEXT_RELEASE_NAME}'
    type='org.eclipse.equinox.internal.p2.artifact.repository.CompositeArtifactRepository'
    version='1.0.0'>
  <properties size='1'>
    <property name='p2.timestamp' value='${TIMESTAMP}'/>
  </properties>
  <children size='1'>
    <child location='../${RELEASE_NAME}'/>
  </children>
</repository>
"

echo "$ARTIFACTXML" > ./compositeArtifacts.xml
echo "==== Start Content of compositeArtifacts.xml ===="
cat ./compositeArtifacts.xml
echo "==== End Content of compositeArtifacts.xml ===="
$ECHO $SCP compositeArtifacts.xml "${SSHUSER}:"${EPP_DOWNLOADS}/packages/${NEXT_RELEASE_NAME}/

