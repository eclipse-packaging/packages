#!/bin/bash


####
# This directory was supposed to try to recreate a Java program that has been lost to time. See
# the history of it in https://bugs.eclipse.org/bugs/show_bug.cgi?id=571369.
# The source here was supposed to create the same output as p2infExtender.jar does,
# but it is nothing like it.
# Therefore for now we are continuing to use the built jar, but no longer relying
# on pulling it from an external website.


set -u # run with unset flag error so that missing parameters cause build failure
set -e # error out on any failed commands
set -x # echo all commands used for debugging purposes

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
java -jar ${DIR}/p2infExtender.jar


exit 0
# The rest of this script can be used instead of the above if someone writes the
# expected Java code

mvn -f ${DIR} package
java -jar ${DIR}/target/p2infExtender-1.0-SNAPSHOT.jar
