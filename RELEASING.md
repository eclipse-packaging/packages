# The EPP Release Process

This guide contains the step-by-step process to complete an EPP release.

The individual releases are tracked with [endgame](https://github.com/eclipse-packaging/packages/labels/endgame) issues on GitHub issues.
For each release (M1, M2, M3, RC1, RC2) an endgame ticket is created with the appropriate contents from the rest of this document:

EPP releases happen for each milestone and release candidate according to the [Eclipse Simultaneous Release Plan](https://github.com/eclipse-simrel/.github/blob/main/wiki/Simultaneous_Release.md).

**Steps at the beginning of each release cycle (i.e. before M1):**

This checklist is only used once per release cycle. Scroll down for the per-milestone/RC steps.

- [ ] Create new [PMI entry](https://projects.eclipse.org/projects/technology.packaging)
- [ ] Update splash screen (once per release cycle, hopefully done before M1). See detailed [instructions](https://github.com/eclipse-packaging/packages/blob/master/packages/org.eclipse.epp.package.common/splash/INSTRUCTIONS.md).
- [ ] When the year changes, e.g. between 2019-12 and 2020-03 releases, an update of the copyright year is required with a very smart search&replace. A good replacement is `/, 2021/, 2022/` excluding `*.svg`
- [ ] In addition to the "Update Name" step on every M and RC, the whole version string is updated, including platform version; this is a large change including
  - [ ] pom.xml
  - [ ] feature.xml
  - [ ] MANIFEST.MF
  - [ ] epp.website.xml
  - [ ] epp.product
  - [ ] p2.inf
  - [ ] epp.p2.inf
  - [ ] Jenkinsfile (SimRel triggering URL)
  - [ ] `2020-12` -> `2021->03` part
  - [ ] `4.14` -> `4.15` part
  - [ ] Adding the previous past release explicitly to list in release.xml, located in promote-a-build.sh
- [ ] Archive old releases (two R releases should stay on download.eclipse.org) to archive.eclipse.org and remove non-R downloads.
  - This can be done through the web ui at https://download.eclipse.org/technology/epp/

**Steps for all Milestones and RCs:**

- [ ] Check for bad links to Bugzilla (and other things) especially in `epp.website.xml`
- [ ] Make sure any outstanding [reviews](https://projects.eclipse.org/projects/technology.packaging/governance) are progressing - e.g. create progress review, get PMC approval, etc.
  - Annual progress review is normally done in early June
- [ ] Ensure that the [CI build](https://ci.eclipse.org/packaging/job/epp/job/master/) is green. Resolving non-green builds will require tracking down problems and incompatibilities across all Eclipse participating projects. [cross-project-issues-dev](https://accounts.eclipse.org/mailing-list/cross-project-issues-dev) mailing list is a good place to start when tracking such problems.
- [ ] Check that packages containing incubating projects have that information reflected in Help -> About dialog. See near the end of build output for report of check-incubating.sh script.
  - `-incubation` and ` (includes Incubating components)` are not used in packageMetaData anymore (See [Bug 564214](https://bugs.eclipse.org/bugs/show_bug.cgi?id=564214))
- [ ] On RC1 check "new and noteworthy" version numbers - If any N&N are out of date, remove the N&N entries and notify the corresponding package maintainer.
  - [ ] Search for ` url=` (notice the blank before url) in `epp.website.xml` to see which ones are contained in the different packages.
  - [ ] Remember that some of the features will release new versions together with the new Eclipse release. Therefore using the _currently_ released version number may be wrong. Instead lookup the feature version [to be released with the release train](https://projects.eclipse.org/releases/).
- [ ] Synchronize the following - Remember to check branch, these links are to master, but around RC2 master may be setup for next release already
  - [ ] Synchronize any changes to [platform.product](https://github.com/eclipse-platform/eclipse.platform.releng.aggregator/blob/master/eclipse.platform.releng.tychoeclipsebuilder/eclipse.platform.repository/platform.product) into all the `epp.product` files.
  - [ ] Synchronize any changes to [platform.p2.inf](https://github.com/eclipse-platform/eclipse.platform.releng.aggregator/blob/master/eclipse.platform.releng.tychoeclipsebuilder/eclipse.platform.repository/platform.p2.inf) into all the `*.product/p2.inf` files.
  - [ ] Synchronize any changes to [platform's icons'](https://github.com/eclipse-platform/eclipse.platform.releng.aggregator/tree/master/eclipse.platform.releng.tychoeclipsebuilder/eclipse.platform.repository/icons) into `icons` root directory.
- [ ] Update name of the release in strings with a "smart" global find&replace. _Be careful on M3 that the replace did not match the Eclipse project name M2E!_ See this [gerrit](https://git.eclipse.org/r/#/c/158509/) for an example. Use commit message like `[releng] Prepare repo for 2020-12 M1`. In particular, check:
  - **TODO can this be automated** On M1 add the M1 qualifier (e.g. `2021-03-R` -> `2021-06-M1`, on RC2 set it to `R` the qualifier e.g. `2021-03-RC1` -> `2021-03-R`). **Except** for `eclipse.simultaneous.release.name` which should go from `2021-03 (4.19.0)` -> `2021-06 M1 (4.20.0 M1)` on M1 and `2021-03 RC1 (4.19.0 RC1)` -> `2021-03 (4.19.0)` on RC2
  - [ ] `packages/*/epp.website.xml` for `product name=` line
  - [ ] `RELEASE_NAME`, `PREV_RELEASE_NAME`, `NEXT_RELEASE_NAME`, `RELEASE_MILESTONE`, `RELEASE_DIR`, `SIMREL_REPO`,  Variables in parent pom `releng/org.eclipse.epp.config/parent/pom.xml`
    - `SIMREL_REPO` should be updated to the URL published in the email to cross-project-issues announcing SimRel repo is ready for EPP build
  - [ ] **TODO can this part below be automated**
    - See comment in the pom.xml file around `eclipse.simultaneous.release.name`
    - On R build, for `eclipse.simultaneous.release.name` remove qualifier i.e. it should be `2020-12 (4.18.0)`
    - On M1 build add the qualifier back in, for `eclipse.simultaneous.release.name` remove qualifier i.e. it should be `2020-12 M1 (4.18.0 M1)`
- [ ] Update the [Last Recorded +1 in the email template](https://github.com/eclipse-packaging/packages/blob/master/releng/org.eclipse.epp.config/tools/upload-to-staging.sh) which any package and platform +1s that have been received since the last update.
- [ ] Wait for announcement that the staging repo is ready on [cross-project-issues-dev](https://accounts.eclipse.org/mailing-list/cross-project-issues-dev). An [example announcement](https://www.eclipse.org/lists/cross-project-issues-dev/msg17420.html).
  - [ ] Update `SIMREL_REPO` in `releng/org.eclipse.epp.config/parent/pom.xml` if not done above.
- [ ] Update the build qualifiers to ensure that packages are all updated. See this [gerrit](https://git.eclipse.org/r/#/c/161075/) for an example. To do this run `releng/org.eclipse.epp.config/tools/setGitDate` ([link](https://github.com/eclipse-packaging/packages/blob/master/releng/org.eclipse.epp.config/tools/setGitDate)) script. This script will make a local commit you need to push.
  - In some cases a respin/rebuild is needed and setGitDate needs to be run again. In that case you may need to manually add a minute or two to the applied timestamp in the script.
- [ ] Run a [CI build](https://ci.eclipse.org/packaging/job/epp/job/master/) that includes the above changes.
  - If the build fails there may be the opportunity to continue the build rather than restart it. This is relatively underused option but enabled by the multi-step Jenkins build in the Jenkinsfile. For example, running the build with the previously successful steps commented out can produce a build.
- [ ] Disable the [CI build](https://ci.eclipse.org/packaging/job/epp/job/master/) so that the build results are not overwritten while doing the promotion. You can disable the project once it has fully started running, you don't have to wait for the build to finish.
- [ ] Check that there are no warnings in the console output. Especially look for warnings about failure to sign.
  - If warnings about signings occur that leave the dmg unsigned and the build does not fail, please reopen [Bug 567916](https://bugs.eclipse.org/bugs/show_bug.cgi?id=567916)
- [ ] Run the [Notarize MacOSX Downloads](https://ci.eclipse.org/packaging/job/notarize-downloads/) CI job to notarize DMG packages on download.eclipse.org. _This can be done after promotion if time is tight or the notarization fails repeatedly. See [Bug 571669](https://bugs.eclipse.org/bugs/show_bug.cgi?id=571669) for an example of failures._
- [ ] Check the build script output to make sure that the curl calls were successful (e.g. no `curl: (92) HTTP/2 stream 0 was not closed cleanly: INTERNAL_ERROR (err 2) ` messages) - If there is an error like the above the .dmg file that is copied to download.eclipse.org is corrupt. Run [notarize-prepare-to-redo](https://ci.eclipse.org/packaging/job/notarize-prepare-to-redo/) to rename the -signed file back to -tonotarize and then re-run the [notarize job](https://ci.eclipse.org/packaging/job/notarize-downloads/)
- Other notes about notarization
  - **NOTE** It seems perfectly normal that the notarize job needs to be run multiple times as so many notarization attempts fail due to 500 and 000 response codes from the notarization server. See [Bug 571669](https://bugs.eclipse.org/bugs/show_bug.cgi?id=571669)
  - **NOTE** Sometimes the notarization server has an error that causes a failure that requires Webmaster support. Error looks like "an existing transporter instance is currently uploading this package". To resolve request assistance in [Bug 573875](https://bugs.eclipse.org/bugs/show_bug.cgi?id=573875) (like what was done in Comment 11 of that bug). (TODO it may be possible to workaround this error by always using a different random ID when doing the notarization.)
- [ ] Sanity check the build for the following:
  - [ ] Download a package from the build's [staging output](https://download.eclipse.org/technology/epp/staging/)
  - [ ] Made sure filenames contain expected build name and milestone, e.g. `2020-03-M2`
  - [ ] Splash screen says expected release name (with no milestone), e.g. `2020-03`
  - [ ] Help -> About says expected build name and milestone, e.g. `2020-03-M2`
  - [ ] `org.eclipse.epp.package.*` features and bundles have the timestamp of the forced qualifier update or later
  - [ ] Upgrade from previous release works. To test the upgrade an equivalent to the simrel release composite site needs to done. Add the following software sites to available software, check for updates and then make sure stuff works. In particular check error log and that core features (Such as JDT, Platform) have been upgraded.
    - `https://download.eclipse.org/staging/2024-12/` - _NOTE_ Use `SIMREL_REPO` if the staging repo has been updated since the `SIMREL_REPO` location was created.
    - `https://download.eclipse.org/technology/epp/staging/repository/`
    - `https://download.eclipse.org/justj/epp/milestone/latest` - This is needed when there is a new version of JustJ that is not also published as a release. For example, Java 21 between 2024-06 M1 and release date of 2024-06.
  - [ ] Verify no non-EPP content is in the p2 repo (especially justj, update [remove-justj-from-p2.xml](https://github.com/eclipse-packaging/packages/blob/master/releng/org.eclipse.epp.config/tools/remove-justj-from-p2.xml) if needed)
- [ ] Edit the [Jenkins build](https://ci.eclipse.org/packaging/job/epp/job/master/)
  - [ ] Mark build as Keep forever
  - [ ] Edit Jenkins Build Information and name it (e.g. `2020-03 M3`)
- [ ] Run the [Promote a Build](https://ci.eclipse.org/packaging/job/promote-a-build/) CI job to prepare build artifacts and copy them to download.eclipse.org
  - [ ] _Optional - useful when testing changes to the promotion scripts:_ Run the build once in `DRY_RUN` mode to ensure that the output is correct before it is copied to download.eclipse.org.
  - This used to be done done late in the day to try and reduce impact of adding dozens of GB on the download server and having all the mirrors start to pick it up right away. See [epp-dev emails that led to this decision](https://www.eclipse.org/lists/epp-dev/msg06317.html). However in 2024 the impact seems to no longer be a concern. This note is preserved until we know for sure there is no issue.
  - The `DRY_RUN` can be done earlier in the day and is a good way to increase the chance that the final promotion step will be successful.
- [ ] Run the [Notarize MacOSX Downloads](https://ci.eclipse.org/packaging/job/notarize-downloads/) CI job to notarize DMG packages on download.eclipse.org if the promoted build was unstable
- [ ] Update `SIMREL_REPO` to the staging repo so CI builds run against CI of SimRel (e.g. [see this gerrit](https://git.eclipse.org/r/c/epp/org.eclipse.epp.packages/+/189618))
- [ ] Re-enable the [CI build](https://ci.eclipse.org/packaging/job/epp/job/master/)
- [ ] Send email to epp-dev to request package maintainers test it. The email is templated in email.txt in the release directory.
  - _NOTE_ For `R` build the release is initially published to a temporary location and then moved to the `R` directory later. Make a note in the email where the temporary location is.
- [ ] Archive old milestones/RCs so that they don't accumulate on the mirrors

**On all milestone/release days**

This applies to all releases, i.e. M1, M2, M3, RC1 and R. Everything except R is typically the Friday around 9:30am Ottawa time and the R is the following Wednesday sometime before 10am in coordination with the SimRel release engineer.

- [ ] check that this worked: copy the composite\*RC1.jar files over the composite\*.jar files in https://download.eclipse.org/technology/epp/packages/2021-03/ - this is done automatically with the [EPP Make Visible job](https://ci.eclipse.org/packaging/job/epp-makeVisible/) which is automatically triggered by simrel's [SimRel Make Visible Job](https://ci.eclipse.org/simrel/view/All/job/simrel.releng.makeVisible/)

**24-48 Hours Before Final release day**

- [ ] **24 Hours before Final release** Make sure files are in final location to allow downloads to mirror
  - [ ] Tag the release, e.g. with 2020-03_R. Example command line: `git tag --annotate 2020-03_R -m"2020-03 Release" 1b7a1c1af156e3ac57768b87be258cd22b49456b`
  - [ ] Run the [Rename Provisional to Final](https://ci.eclipse.org/packaging/job/rename-provisional-to-final/) CI job to rename the provisional release milestone to final directory. (E.g. [2020-09/202009101200](https://download.eclipse.org/technology/epp/downloads/release/2020-09/202009101200/) -> [2020-09/R](https://download.eclipse.org/technology/epp/downloads/release/2020-09/R/) (to match what is in [release.xml](https://download.eclipse.org/technology/epp/downloads/release/release.xml)) - this only applies to downloads, not to packages
    - [ ] _Optional - useful when testing changes to the promotion scripts:_ Run the build once in `DRY_RUN` mode to ensure that the output is correct before it applies changes to download.eclipse.org.
  - [ ] Send an updated email to epp-dev informing that the provisional URL has been renamed to `R`.

**On Final release day**

These jobs should be completed by approximately 10am Ottawa time on release days.

- [ ] Run the [Finalize Release](https://ci.eclipse.org/packaging/job/finalize-release/) CI job to create the "next" release and updated the "latest" release  as follows:
  - The current release needs to be promoted as "latest" under https://download.eclipse.org/technology/epp/packages/latest/ . This should be a composite pointing to specific https://download.eclipse.org/technology/epp/packages/yyyy-MM/ .
  - The _next_ release sub-directory needs to be created immediately, i.e. when 2019-12 was released, a directory 2020-03 had been created with an empty p2 composite repository pointing to 2019-12 until M1. On M1 release day this changes to a composite p2 repository with M1 content.
  - [ ] _Optional - useful when testing changes to the promotion scripts:_ Run the build once in `DRY_RUN` mode to ensure that the output is correct before it applies changes to download.eclipse.org.
