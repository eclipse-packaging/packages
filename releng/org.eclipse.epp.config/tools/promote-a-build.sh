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
mvn clean package -f ${DIR}

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
<present>2021-12/R</present>
<future>${RELEASE_NAME}/${RELEASE_MILESTONE}</future>
</packages>
EOM
$ECHO $SCP release.xml "${SSHUSER}:"${EPP_DOWNLOADS}/downloads/release/release.xml


# -------------------------
# Prepare template email with all the correct information
cat > email.txt <<EOM
Hi everyone,

Our next milestone build is available for testing: EPP ${RELEASE_NAME} ${RELEASE_MILESTONE}

TODO say: No special issues to report! or write the issues to bring to the attention of the group when sending the email.

I have been following the steps on https://hackmd.io/@jonahgraham/eclipse-epp-release-process - you can see the checkmarks as to what is done.

Download link: https://download.eclipse.org/technology/epp/downloads/release/${RELEASE_NAME}/${RELEASE_DIR}/_mirrors.php - This URL will change early next week to the release URL ahead of the release on Wednesday - assuming no respins!

EPP was built with the p2 repositories at:

${SIMREL_REPO} and
https://download.eclipse.org/technology/epp/packages/${RELEASE_NAME}/${RELEASE_DIR}/

Please test and send your +1 to this mailing list. +1s are optional as the package will be published anyway.

Last +1 received for each package and platform (apologies if I missed one of your +1 emails, just let me know and I will update Last Recorded +1) I have highlighted those packages/platforms that I haven't seen any confirmation in this release cycle on.

Packages:
committers - 2021-12 M2
cpp - 2021-12 RC1
dsl - 2021-12 M3
embedcpp - 2021-12 M3
java - 2021-12 M2
jee - 2021-12 RC1
modeling - 2021-12 M3
parallel - 2021-09 RC2
php - 2020-12 RC2
rcp - 2021-06 RC1
scout - 2021-12 M3

Platforms:
Linux x86_64 - 2021-12 M3
Linux aarch64 - 2021-09 RC1
Windows - 2021-12 RC1
macOS x86_64 - 2021-12 M3
macOS aarch64 - 2021-12 M3

Thank you for testing!

Regards,
Jonah
EOM
$ECHO $SCP email.txt "${SSHUSER}:"${DOWNLOADS}/email.txt

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
