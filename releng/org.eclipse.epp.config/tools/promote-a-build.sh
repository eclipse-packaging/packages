#!/bin/bash

set -u # run with unset flag error so that missing parameters cause build failure
set -e # error out on any failed commands
set -x # echo all commands used for debugging purposes

RELEASE_NAME=2021-12
RELEASE_MILESTONE=M1
RELEASE_DIR=202110071200
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
<present>2021-09/R</present>
<future>2021-12/M1</future>
</packages>
EOM
$ECHO $SCP release.xml "${SSHUSER}:"${EPP_DOWNLOADS}/downloads/release/release.xml


# ----------------------------------------------------------------------------------------------
# Prepare compositeArtifacts.xml/compositeContent.xml that will be made visible with https://ci.eclipse.org/packaging/job/epp-makeVisible/

if [ "$RELEASE_MILESTONE" == "R" ]; then
  UPDATE_SITES=${RELEASE_DIR}
else
  UPDATE_SITES=$($SSH "cd ${REPO} && find * -maxdepth 0 -type d | sort -u")
fi

TIMESTAMP=$(date +%s000)
NUMBER_UPDATE_SITES=$(echo "$UPDATE_SITES" | wc -w)

CONTENTXML="<?xml version='1.0' encoding='UTF-8'?>
<?compositeMetadataRepository version='1.0.0'?>
<repository name='Eclipse Packaging Project EPP ${RELEASE_NAME}'
    type='org.eclipse.equinox.internal.p2.metadata.repository.CompositeMetadataRepository'
    version='1.0.0'>
  <properties size='1'>
    <property name='p2.timestamp' value='${TIMESTAMP}'/>
  </properties>
  <children size='${NUMBER_UPDATE_SITES}'>
$(
for site in $UPDATE_SITES
do
printf "    <child location='${site}'/>\n"
done
)
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
  <children size='${NUMBER_UPDATE_SITES}'>
$(
for site in $UPDATE_SITES
do
printf "    <child location='${site}'/>\n"
done
)
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
