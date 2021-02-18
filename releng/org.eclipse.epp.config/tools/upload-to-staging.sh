#!/bin/bash

set -u # run with unset flag error so that missing parameters cause build failure
set -e # error out on any failed commands
set -x # echo all commands used for debugging purposes

SSHUSER="genie.packaging@projects-storage.eclipse.org"
SSH="ssh ${SSHUSER}"
SCP="scp"

RELEASE_NAME=2021-03
RELEASE_MILESTONE=M2
WORKSPACE=${WORKSPACE:-"${PWD}"}
GIT_REPOSITORY=${GIT_REPOSITORY:-"org.eclipse.epp.packages"}
BUILT_PACKAGES=$(cat packages.txt)
PACKAGES=${BUILT_PACKAGES:-"committers cpp dsl embedcpp java jee modeling parallel php rcp scout"}
PLATFORMS=${PLATFORMS:-"linux.gtk.aarch64.tar.gz linux.gtk.x86_64.tar.gz macosx.cocoa.x86_64.dmg macosx.cocoa.x86_64.tar.gz win32.win32.x86_64.zip"}
STAGING=${STAGING:-"/home/data/httpd/download.eclipse.org/technology/epp/staging"}

cd ${WORKSPACE}/${GIT_REPOSITORY}/archive
for PACKAGE in $PACKAGES; do
  for PLATFORM in $PLATFORMS; do
    NAME=$(echo *_eclipse-${PACKAGE}-${RELEASE_NAME}-${RELEASE_MILESTONE}-${PLATFORM})
    NEWNAME=`echo ${NAME} | \
             cut -d "_" -f 2- | \
             sed 's/linux\.gtk\.aarch64/linux-gtk-aarch64/' | \
             sed 's/linux\.gtk\.x86\_64/linux-gtk-x86\_64/' | \
             sed 's/win32\.win32\.x86\_64\./win32\-x86\_64\./' | \
             sed 's/macosx\.cocoa\.x86\_64/macosx\-cocoa-x86\_64/' | \
             sed 's/macosx-cocoa-x86_64.dmg/macosx-cocoa-x86_64.dmg-tonotarize/'`
    # Move and rename file
    mv ${NAME} ${NEWNAME}
  done;
done

# place configurations in final location
for PACKAGE in $PACKAGES; do
  cp ${WORKSPACE}/${GIT_REPOSITORY}/packages/org.eclipse.epp.package.${PACKAGE}.feature/epp.website.xml ${PACKAGE}.xml
  cp ${WORKSPACE}/${GIT_REPOSITORY}/packages/org.eclipse.epp.package.${PACKAGE}.feature/feature.xml ${PACKAGE}.feature.xml
  cp ${WORKSPACE}/${GIT_REPOSITORY}/packages/org.eclipse.epp.package.${PACKAGE}.product/epp.product ${PACKAGE}.product.xml
done

# place a timestamp and CI build info in the directory
echo "TIMESTAMP: $(date)" > ci-info.txt
echo "CI URL: ${BUILD_URL}" >> ci-info.txt

# -----------------------------
# Notarize macos files

for i in `find * -name '*.dmg-tonotarize'`
do
   DMG_FILE=${i/-tonotarize/}
   LOG=$(basename ${i}).log
   echo "Starting ${DMG_FILE}" >> ${WORKSPACE}/${LOG}
   ${WORKSPACE}/${GIT_REPOSITORY}/releng/org.eclipse.epp.config/tools/macosx-notarization-single.sh ${DMG_FILE} >> ${LOG} &
   sleep 18s # start jobs at a small interval from each other
done

jobs -p
wait < <(jobs -p)

if [[ -n `find * -name '*.dmg-tonotarize'` ]]; then
   echo "Failed to notarize the following"
   find * -name '*.dmg-tonotarize'
   exit 1
fi


# ----------------------------------------------------------------------------------------------
# compute the checksum files for each package

for II in $(find eclipse*.zip eclipse*.tar.gz eclipse*.dmg); do
  echo .. $II
  md5sum $II >$II.md5
  sha1sum $II >$II.sha1
  sha512sum -b $II >$II.sha512
done

# ----------------------------------------------------------------------------------------------
# Copy everything to download.eclipse.org

${SSH} rm -rf ${STAGING}-new
${SCP} -rp . "${SSHUSER}:"${STAGING}-new
${SSH} rm -rf ${STAGING}-previous
${SSH} mv ${STAGING} ${STAGING}-previous
${SSH} mv ${STAGING}-new ${STAGING}
${SSH} rm -rf ${STAGING}-previous
