#!/bin/bash

set -u # run with unset flag error so that missing parameters cause build failure
set -e # error out on any failed commands
set -x # echo all commands used for debugging purposes

## usage
## upload-to-building.sh <path to copy output to> <list of packages>
## e.g.
## upload-to-building.sh /home/data/httpd/download.eclipse.org/technology/epp/building/ cpp
DESTINATION=$1
shift
PACKAGES="$*"

SSHUSER="genie.packaging@projects-storage.eclipse.org"
SSH="ssh ${SSHUSER}"
SCP="scp"

for PACKAGE in $PACKAGES; do
  pushd packages/org.eclipse.epp.package.${PACKAGE}.product/target/products
  for NAME in $(find * -type f -maxdepth 0); do
    # The naming pattern tycho uses is different than the traditional
    # output of EPP, here we rename the zips/tars/dmgs,
    # with an extra "tonotarize" on the macosx items
    NEWNAME=`echo ${NAME} | \
             sed 's/linux\.gtk\.aarch64/linux-gtk-aarch64/' | \
             sed 's/linux\.gtk\.x86\_64/linux-gtk-x86\_64/' | \
             sed 's/win32\.win32\.x86\_64\./win32\-x86\_64\./' | \
             sed 's/macosx\.cocoa\.aarch64/macosx\-cocoa-aarch64/' | \
             sed 's/macosx\.cocoa\.x86\_64/macosx\-cocoa-x86\_64/' | \
             sed 's/macosx-cocoa-aarch64.dmg/macosx-cocoa-aarch64.dmg-tonotarize/' | \
             sed 's/macosx-cocoa-x86_64.dmg/macosx-cocoa-x86_64.dmg-tonotarize/'`
    # Upload and rename file
    mv ${NAME} ${NEWNAME}
    md5sum ${NEWNAME} >${NEWNAME}.md5
    sha1sum ${NEWNAME} >${NEWNAME}.sha1
    sha512sum -b ${NEWNAME} >${NEWNAME}.sha512
    ${SCP} ${NEWNAME}* "${SSHUSER}:"${DESTINATION}/
  done;
  popd
  ${SCP} packages/org.eclipse.epp.package.${PACKAGE}.feature/epp.website.xml "${SSHUSER}:"${DESTINATION}/${PACKAGE}.xml
  ${SCP} packages/org.eclipse.epp.package.${PACKAGE}.feature/feature.xml "${SSHUSER}:"${DESTINATION}/${PACKAGE}.feature.xml
  ${SCP} packages/org.eclipse.epp.package.${PACKAGE}.product/epp.product "${SSHUSER}:"${DESTINATION}/${PACKAGE}.product.xml
done
