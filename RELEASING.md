The EPP Release Process
=======================

An online editable version of this document is on [hackmd.io](https://hackmd.io/@jonahgraham/eclipse-epp-release-process), updates should be copied to [Eclipse's git repo](https://git.eclipse.org/c/epp/org.eclipse.epp.packages.git/tree/RELEASING.md). The Eclipse version is the official one.

This guide contains the step-by-step process to complete an EPP release.

EPP releases happen for each milestone and release candidate according to the [Eclipse Simultaneous Release Plan](https://wiki.eclipse.org/Simultaneous_Release).

**Steps at the beginning of each release cycle (i.e. before M1):**

- [ ] Fix https://bugs.eclipse.org/bugs/show_bug.cgi?id=571369
- [ ] Create new [PMI entry](https://projects.eclipse.org/projects/technology.packaging)
- [ ] Add Target Milestones in [Bugzilla](https://dev.eclipse.org/committers/bugs/bugz_manager.php)
- [ ] Update splash screen (once per release cycle, hopefully done before M1). See detailed [instructions](https://git.eclipse.org/c/epp/org.eclipse.epp.packages.git/tree/packages/org.eclipse.epp.package.common/splash/INSTRUCTIONS.md). For 2021-06 see Bug [569333](https://bugs.eclipse.org/bugs/show_bug.cgi?id=569333) for new splash screens.
- [ ] When the year changes, e.g. between 2019-12 and 2020-03 releases, an update of the copyright year is required with a very smart search&replace. A good replacement is `/, 2021/, 2022/` excluding `*.svg`
- [ ] In addition to the "Update Name" step on every M and RC, the whole version string is updated, including platform version; this is a large change including pom.xml, feature.xml, MANIFEST.MF, epp.website.xml, epp.product, build.xml, and p2.inf
    - [ ] `2020-12` -> `2021->03` part
    - [ ] `4.14` -> `4.15` part
- [ ] rsync the downloads area to archive.eclipse.org and remove non-R downloads.
    - This can be done either through the web ui at https://download.eclipse.org/technology/epp/ or with the following steps:
    - [ ] Remove the old M and RC builds with https://ci.eclipse.org/packaging/job/releng-delete-old-M-RC-downloads
    - [ ] rsync the last release to the archives with https://ci.eclipse.org/packaging/job/releng-rsync-epp-downloads-to-archive
    - [ ] Remove releases from download.eclipse.org by listing releases to delete and then running https://ci.eclipse.org/packaging/job/releng-remove-old-downloads (TODO create this job)

**Steps for all Milestones and RCs:**
- [ ] Fix/check links in email, the mirrors link was wrong for M1
- [ ] Look at renaming zips for mac
- [ ] at beginning of 2022-06 apply removal of Orbit from simrel
- [ ] Make sure any outstanding reviews are progressing - e.g. file IP logs, get PMC approval, etc. 
    - For 2022-03 there is no review planned, next review expected to be a progress review around 2022-06
- [ ] Ensure that the [CI build](https://ci.eclipse.org/packaging/job/simrel.epp-tycho-build/) is green<!-- or yellow (yellow means some files have failed to notarize which can be handled later on in this process)-->. Resolving non-green builds will require tracking down problems and incompatibilities across all Eclipse participating projects. [cross-project-issues-dev](https://accounts.eclipse.org/mailing-list/cross-project-issues-dev) mailing list is a good place to start when tracking such problems.
- [ ] Check that packages containing incubating projects have that information reflected in Help -> About dialog. See near the end of build output for report of check-incubating.sh script.
    - `-incubation` and ` (includes Incubating components)` are not used in packageMetaData anymore (See [Bug 564214](https://bugs.eclipse.org/bugs/show_bug.cgi?id=564214))
- [ ] On RC1 check "new and noteworthy" version numbers - If any N&N are out of date, remove the N&N entries and notify the corresponding package maintainer.
    - [ ] Search for ` url=` (notice the blank before url) in `epp.website.xml` to see which ones are contained in the different packages.
    - [ ] Remember that some of the features will release new versions together with the new Eclipse release. Therefore using the _currently_ released version number may be wrong. Instead lookup the feature version [to be released with the release train](https://projects.eclipse.org/releases/).
- [ ] Update the JustJ version - look for announcements, particularly from Ed to epp-dev and for the EOL and new release dates of JDKs
    - Coordination may be needed with JustJ and Platform projects to make sure we are all on the same page.
    - [ ] Update the full names of the JRE bundles in [remove-justj-from-p2.xml](https://git.eclipse.org/c/epp/org.eclipse.epp.packages.git/tree/releng/org.eclipse.epp.config/tools/remove-justj-from-p2.xml)
- [ ] Update name of the release in strings with a "smart" global find&replace. *Be careful on M3 that the replace did not match the Eclipse project name M2E!* See this [gerrit](https://git.eclipse.org/r/#/c/158509/) for an example. Use commit message like `[releng] Prepare repo for 2020-12 M1`. In particular, check:
    -  **TODO can this be automated** On M1 add the M1 qualifier (e.g. `2021-03-R` -> `2021-06-M1`, on RC2 set it to `R` the qualifier e.g. `2021-03-RC1` -> `2021-03-R`). **Except** for `eclipse.simultaneous.release.name` which should go from `2021-03 (4.19.0)` -> `2021-06 M1 (4.20.0 M1)` on M1 and `2021-03 RC1 (4.19.0 RC1)` -> `2021-03 (4.19.0)` on RC2
    - [ ] `packages/*/epp.website.xml` for `product name=` line
    - [ ] `RELEASE_NAME`, `RELEASE_MILESTONE`, `RELEASE_DIR`, `SIMREL_REPO` Variables in parent pom `releng/org.eclipse.epp.config/parent/pom.xml`
        - `SIMREL_REPO` should be updated to the URL published in the email to cross-project-issues announcing SimRel repo is ready for EPP build
    - **TODO can this part below be automated**
        - On R build, for `eclipse.simultaneous.release.name` remove qualifier i.e. it should be `2020-12 (4.18.0)`
        - On M1 build add the qualifier back in, for `eclipse.simultaneous.release.name` remove qualifier i.e. it should be `2020-12 M1 (4.18.0 M1)`
    - [ ] **TODO can this be automated** on release builds release.xml template in `releng/org.eclipse.epp.config/tools/promote-a-build.sh` needs updating
- [ ] Update the [Last Recorded +1 in the email template](https://git.eclipse.org/c/epp/org.eclipse.epp.packages.git/tree/releng/org.eclipse.epp.config/tools/upload-to-staging.sh) which any package and platform +1s that have been received since the last update.
- [ ] Update the build qualifiers to ensure that packages are all updated. See this [gerrit](https://git.eclipse.org/r/#/c/161075/) for an example. To do this run [`releng/org.eclipse.epp.config/tools/setGitDate`](https://git.eclipse.org/c/epp/org.eclipse.epp.packages.git/tree/releng/org.eclipse.epp.config/tools/setGitDate) script. This script will make a local commit you need to push.
- [ ] Wait for announcement that the staging repo is ready on [cross-project-issues-dev](https://accounts.eclipse.org/mailing-list/cross-project-issues-dev). An [example announcement](https://www.eclipse.org/lists/cross-project-issues-dev/msg17420.html).
    - [ ] Update `SIMREL_REPO` if not done above.
- [ ] Run a [CI build](https://ci.eclipse.org/packaging/job/simrel.epp-tycho-build/) that includes the above changes.
- [ ] Check that there are no unexpected warnings in the console output. Especially look for warnings about failure to sign. (Warnings about Mirror tool seem to be ok and can be ignored. In a historically good build there is one `[WARNING] Mirror tool: Messages while mirroring artifact descriptors.` per package)
    - If warnings about signings occur that leave the dmg unsigned and the build does not fail, please reopen [Bug 567916](https://bugs.eclipse.org/bugs/show_bug.cgi?id=567916)
- [ ] Disable the [CI build](https://ci.eclipse.org/packaging/job/simrel.epp-tycho-build/) so that the build results are not overwritten while doing the promotion
- [ ] Run the [Notarize MacOSX Downloads](https://ci.eclipse.org/packaging/job/notarize-downloads/) CI job to notarize DMG packages on download.eclipse.org if the promoted build was unstable. *This can be done after promotion if time is tight or the notarization fails repeatedly. See [Bug 571669](https://bugs.eclipse.org/bugs/show_bug.cgi?id=571669) for an example of failures.*
    - [ ] Check the build script output to make sure that the curl calls were successful (e.g. no `curl: (92) HTTP/2 stream 0 was not closed cleanly: INTERNAL_ERROR (err 2)
` messages)
    - If there is an error like the above the .dmg file that is copied to download.eclipse.org is corrupt. Manually rename the `.dmg-signed` to `.dmg-tonotarize` and rerun the notarization
        - A script like this works - I use https://ci.eclipse.org/packaging/job/jonah-releng-test/ job **TODO** add this to git?:
```
#!/bin/bash

set -u # run with unset flag error so that missing parameters cause build failure
set -e # error out on any failed commands
set -x # echo all commands used for debugging purposes

SSHUSER="genie.packaging@projects-storage.eclipse.org"
SSH="ssh ${SSHUSER}"
SCP="scp"

ssh genie.packaging@projects-storage.eclipse.org /bin/bash << EOF
  set -u # run with unset flag error so that missing parameters cause build failure
  set -e # error out on any failed commands
  set -x # echo all commands used for debugging purposes
  mv -v /home/data/httpd/download.eclipse.org/technology/epp/staging/eclipse-cpp-2022-03-M1-macosx-cocoa-aarch64.dmg-signed /home/data/httpd/download.eclipse.org/technology/epp/staging/eclipse-cpp-2022-03-M1-macosx-cocoa-aarch64.dmg-tonotarize
EOF
```

- Other notes about notarization
    - **NOTE** It seems perfectly normal that the notarize job needs to be run multiple times as so many notarization attempts fail due to 500 and 000 response codes from the notarization server. See [Bug 571669](https://bugs.eclipse.org/bugs/show_bug.cgi?id=571669)
    - **NOTE** Sometimes the notarization server has an error that causes a failure that requires Webmaster support. Error looks like "an existing transporter instance is currently uploading this package". To resolve request assistance in [Bug 571669](https://bugs.eclipse.org/bugs/show_bug.cgi?id=571669) (like what was done in Comment 11 of that bug). (TODO it may be possible to workaround this error by always using a different random ID when doing the notarization.)
- [ ] Sanity check the build for the following:
    - [ ] Download a package from the build's [staging output](https://download.eclipse.org/technology/epp/staging/)
    - [ ] Made sure filenames contain expected build name and milestone, e.g. `2020-03-M2`
    - [ ] Splash screen says expected release name (with no milestone), e.g. `2020-03`
    - [ ] Help -> About says expected build name and milestone, e.g. `2020-03-M2`
    - [ ] `org.eclipse.epp.package.*` features and bundles have the timestamp of the forced qualifier update or later
    - [ ] Upgrade from previous release works. To test the upgrade an equivalent to the simrel release composite site needs to done. Add the following software sites to available software, check for updates and then make sure stuff works. In particular check error log and that core features (Such as JDT, Platform) have been upgraded.
        - `https://download.eclipse.org/staging/2022-03/` - *NOTE* Use `SIMREL_REPO` if the staging repo has been updated since the `SIMREL_REPO` location was created.
        - `https://download.eclipse.org/technology/epp/staging/repository/`
    - [ ] Verify no non-EPP content is in the p2 repo (especially justj, update [remove-justj-from-p2.xml](https://git.eclipse.org/c/epp/org.eclipse.epp.packages.git/tree/releng/org.eclipse.epp.config/tools/remove-justj-from-p2.xml) if needed)
- [ ] Edit the [Jenkins build](https://ci.eclipse.org/packaging/job/simrel.epp-tycho-build/)
    - [ ] Mark build as Keep forever
    - [ ] Edit Jenkins Build Information and name it (e.g. `2020-03 M3`)
- [ ] In the evening Ottawa time, run the [Promote a Build](https://ci.eclipse.org/packaging/job/promote-a-build/) CI job to prepare build artifacts and copy them to download.eclipse.org
    - [ ] *Optional - useful when testing changes to the promotion scripts:* Run the build once in `DRY_RUN` mode to ensure that the output is correct before it is copied to download.eclipse.org.
    - This is done late in the day to try and reduce impact of adding dozens of GB on the download server and having all the mirrors start to pick it up right away. See [epp-dev emails that led to this decision](https://www.eclipse.org/lists/epp-dev/msg06317.html).
    - The `DRY_RUN` can be done earlier in the day and is a good way to increase the chance that the final promotion step will be successful.
- [ ] Run the [Notarize MacOSX Downloads](https://ci.eclipse.org/packaging/job/notarize-downloads/) CI job to notarize DMG packages on download.eclipse.org if the promoted build was unstable
- [ ] Update `SIMREL_REPO` to the staging repo so CI builds run against CI of SimRel (e.g. [see this gerrit](https://git.eclipse.org/r/c/epp/org.eclipse.epp.packages/+/189618))
- [ ] Re-enable the [CI build](https://ci.eclipse.org/packaging/job/simrel.epp-tycho-build/)
- [ ] Send email to epp-dev to request package maintainers test it. The email is templated in email.txt in the release directory.
- [ ] Archive old milestones/RCs so that they don't accumulate on the mirrors
- [ ] **24 Hours before Final release** Make sure files are in final location to allow downloads to mirror
    - [ ] Tag the release, e.g. with 2020-03_R. Example command line: `git tag -s -a 2020-03_R -m"2020-03 Release" 1b7a1c1af156e3ac57768b87be258cd22b49456b`
    - [ ] rename the provisional release milestone to final directory (E.g. [2020-09/202009101200](https://download.eclipse.org/technology/epp/downloads/release/2020-09/202009101200/) -> [2020-09/R](https://download.eclipse.org/technology/epp/downloads/release/2020-09/R/) (to match what is in [release.xml](https://download.eclipse.org/technology/epp/downloads/release/release.xml)) - this only applies to downloads, not to packages
    This can be done with a script like **TODO: make a job for this** :
```
ssh genie.packaging@projects-storage.eclipse.org /bin/bash << EOF
  set -u # run with unset flag error so that missing parameters cause build failure
  set -e # error out on any failed commands
  set -x # echo all commands used for debugging purposes
  mv -v /home/data/httpd/download.eclipse.org/technology/epp/downloads/release/2021-03/202103121200 /home/data/httpd/download.eclipse.org/technology/epp/downloads/release/2021-03/R
  touch /home/data/httpd/download.eclipse.org/technology/epp/downloads/release/2021-03/R/*
EOF
```
    
- [ ] **On release days** approximately 9:30am
    - [ ] Add Versions in [Bugzilla](https://dev.eclipse.org/committers/bugs/bugz_manager.php)
    - [ ] check that this worked: copy the composite\*RC1.jar files over the composite\*.jar files in https://download.eclipse.org/technology/epp/packages/2021-03/ - this is done automatically with the [EPP Make Visible job](https://ci.eclipse.org/packaging/job/epp-makeVisible/) which is automatically triggered by simrel's [SimRel Make Visible Job](https://ci.eclipse.org/simrel/view/All/job/simrel.releng.makeVisible/)
- [ ] **On Final release day** immediately _after_ a release (just after 10am):
    - [ ] The current release needs to be promoted as "latest" under https://download.eclipse.org/technology/epp/packages/latest/ . This should be a composite pointing to specific https://download.eclipse.org/technology/epp/packages/yyyy-MM/ . This is achieved by triggering the [epp-promoteReleaseToLatest](https://ci.eclipse.org/packaging/job/epp-promoteReleaseToLatest).
    - [ ] The _next_ release sub-directory needs to be created immediately _after_ a release, i.e. when 2019-12 was released, a directory 2020-03 had been created with an empty p2 composite repository pointing to 2019-12 until M1. (Use Job https://ci.eclipse.org/packaging/job/epp-createNextRelease/) On M1 release day this changes to a composite p2 repository with M1 content. On other release days, add the new releases as children and on final release this changes to a composite with just the one child.
