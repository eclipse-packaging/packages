# The EPP Release Process

This guide contains the step-by-step process to complete an EPP release and assumes that you have an IDE provisioned using the [Oomph setup](
https://github.com/eclipse-packaging/packages/blob/master/CONTRIBUTING.md#create-an-eclipse-development-environment).

**Before** copying this file to create a new issue titled `EPP 2026-03 M3` with label `endgame`, update the names and versions, including those in this document.
- [ ] To update names and versions, edit [org.eclipse.epp.releng.updater.Updater](
      releng/org.eclipse.epp.config/org.eclipse.epp.releng.updater/src/org/eclipse/epp/releng/updater/Updater.java
      ) to set the values of `MILESTONE`, `PLATFORM_VERSION`, and possibly `EXECUTION_ENVIRONMENT` to the current appropriate values.
     - Use the `Run` toolbar button drop-down menu to launch the `Update Versions` launch configuration to apply all the necessary name and version changes.
     - Or use the `Run` toolbar button drop-down menu to launch the `Open Issue` launch configuration to apply all the necessary name and version changes,
       and to open a new properly-titled, properly-labeled issue;
       the body text is too long to automatically create the body of the issue,
       but that text is copied to the system clipboard,
       so you can use simply paste it into the body.

The individual releases are tracked with [endgame](https://github.com/eclipse-packaging/packages/labels/endgame) issues on GitHub.

For each release (M1, M2, M3, RC1, RC2) an endgame ticket is created with the appropriate contents from the rest of this document:

EPP releases happen for each milestone and release candidate according to the [Eclipse Simultaneous Release Plan](
https://github.com/eclipse-simrel/.github/blob/main/wiki/SimRel/2026-03.md)

**Steps at the beginning of each release cycle, i.e., before M1:**

This checklist is only used once per release cycle.
Scroll down for the per-milestone/RC steps.

- [ ] Create new [PMI entry](https://projects.eclipse.org/projects/technology.packaging)
- [ ] Update splash screen (once per release cycle, hopefully done before M1).
      See detailed [instructions](https://github.com/eclipse-packaging/packages/blob/master/packages/org.eclipse.epp.package.common/splash/INSTRUCTIONS.md).
- [ ] Archive old releases (two R releases should stay on download.eclipse.org) to archive.eclipse.org and remove non-R downloads.
  - This can be done through the web UI at https://download.eclipse.org/technology/epp/

**Steps for all Milestones and RCs:**

- [ ] Check for bad links to issues (and other things) especially in `epp.website.xml`.
- [ ] Make sure any outstanding [reviews](https://projects.eclipse.org/projects/technology.packaging/governance) are progressing, e.g., create progress review, get PMC approval, etc.
  - Annual progress review is normally done in early June.
- [ ] Ensure that the [CI build](https://ci.eclipse.org/packaging/job/epp/job/master/) is green.
      Resolving non-green builds will require tracking down problems and incompatibilities across all Eclipse participating projects.
      The [simrel-dev](https://accounts.eclipse.org/mailing-list/simrel-dev) mailing list is a good place to start when tracking such problems.
- [ ] Check that packages containing incubating projects have that information reflected in `Help -> About` dialog.
      See near the end of the build output for a report of `check-incubating.sh` script.
  - This item is not currently done per milestone/release because for a while now all packages contain incubating components and until TM4E moves out of incubation this step is redundant.
  - The incubating indication should appear in feature.properties `description`, `plugin.xml`'s product `aboutText` and `about.properties` _blurb_.
    In the past `-incubation` had to appear in the file name and `(includes Incubating components)` had to appear in `packageMetaData`.
    See [Bug 564214](https://bugs.eclipse.org/bugs/show_bug.cgi?id=564214) for documentation/votes on decision making.

- [ ] On RC1 check "new and noteworthy" version numbers.
      If any N&N are out of date, remove the N&N entries and notify the corresponding package maintainer.
  - [ ] Search for ` url=` (notice the blank before url) in `epp.website.xml` to see which ones are contained in the different packages.
  - [ ] Remember that some of the features will release new versions together with the new Eclipse release.
        Therefore using the _currently_ released version number may be wrong.
        Look at the news links in [2026-03 Participants](https://eclipse.dev/simrel/?file=wiki/SimRel/2026-03_participants.json).
- [ ] Synchronize the following - Remember to check the branch; these links are to master, but around RC2 master may be set up for the next release already.
  - [ ] Synchronize any changes to [platform.product](
        https://github.com/eclipse-platform/eclipse.platform.releng.aggregator/blob/master/products/eclipse-platform/platform.product
        ) into all the `epp.product` files.
  - [ ] Synchronize any changes to [platform.p2.inf](
	    https://github.com/eclipse-platform/eclipse.platform.releng.aggregator/blob/master/products/eclipse-platform/platform.p2.inf
        ) into all the `*.product/p2.inf` files.
  - [ ] Synchronize any changes to [platform's icons](
        https://github.com/eclipse-platform/eclipse.platform.releng.aggregator/tree/master/products/icons
        ) into `icons` root directory.
- [ ] Update the [Last Recorded +1 in the email template](
      https://github.com/eclipse-packaging/packages/blob/master/releng/org.eclipse.epp.config/tools/upload-to-staging.sh
      ) which lists any package and platform +1s that have been received since the last update.
- [ ] Wait for announcement that the staging repo is ready on [simrel-dev](https://accounts.eclipse.org/mailing-list/simrel-dev).
      An [example announcement](https://www.eclipse.org/lists/simrel-dev/msg00032.html).
  - [ ] Update `SIMREL_REPO` in `releng/org.eclipse.epp.config/parent/pom.xml` if not done above.
  - [ ] Or use the `Run` toolbar button drop-down menu to launch the `Update to Milestone Repository` launch configuration.
        This will automatically determine the correct update site URL and will create an appropriate commit message in the system clipboard.
- [ ] Update the build qualifiers to ensure that packages are all updated.
      See this [gerrit](https://git.eclipse.org/r/#/c/161075/) for an example.
      Commit all other changes before this step because this step will automatically create a Git commit specifically for the forced qualifier changes.
      Use the `External Tools` toolbar drop-down menu to launch the `Update Qualifiers` launch configuration.
      This runs the [setGitDate](releng/org.eclipse.epp.config/tools/setGitDate) bash script.
      This script will make a local commit you need to push; **do not amend it** because the timestamp is relevant.
  - In some cases a respin/rebuild is needed and setGitDate needs to be run again.
    In that case you may need to manually add a minute or two to the applied timestamp in the script.
- [ ] Run a [CI build](https://ci.eclipse.org/packaging/job/epp/job/master/) that includes the above changes.
  - If the build fails there may be the opportunity to continue the build rather than restart it.
    This is relatively underused option but enabled by the multi-step Jenkins build in the Jenkinsfile.
    For example, running the build with the previously successful steps commented out can produce a build.
- [ ] Disable the [CI build](https://ci.eclipse.org/packaging/job/epp/job/master/) so that the build results are not overwritten while doing the promotion.
      You can disable the project once it has fully started running; you don't have to wait for the build to finish.
- [ ] Check that there are no warnings in the console output. Especially look for warnings about failure to sign.
  - If warnings about signing occur that leave the DMG unsigned and the build does not fail,
    please reopen [Bug 567916](https://bugs.eclipse.org/bugs/show_bug.cgi?id=567916).
- [ ] Run the [Notarize MacOSX Downloads](
      https://ci.eclipse.org/packaging/job/notarize-downloads/
      ) CI job to notarize DMG packages on download.eclipse.org.
      _This can be done after promotion if time is tight or the notarization fails repeatedly._
      _See [Bug 571669](https://bugs.eclipse.org/bugs/show_bug.cgi?id=571669) for an example of failures._
- [ ] Check the build script output to make sure that the curl calls were successful, e.g.,
      no `curl: (92) HTTP/2 stream 0 was not closed cleanly: INTERNAL_ERROR (err 2) ` messages.
      If there is an error like the above, the .dmg file that is copied to download.eclipse.org is corrupt.
      Run [notarize-prepare-to-redo](
      https://ci.eclipse.org/packaging/job/notarize-prepare-to-redo/
      ) to rename the -signed file back to `-tonotarize` and then re-run the [notarize job](https://ci.eclipse.org/packaging/job/notarize-downloads/) job.
- Other notes about notarization
  - **NOTE**
    It seems perfectly normal that the notarize job needs to be run multiple times because many notarization attempts fail due to 500 and 000 response codes from the notarization server.
    See [Bug 571669](https://bugs.eclipse.org/bugs/show_bug.cgi?id=571669)
  - **NOTE**
    Sometimes the notarization server has an error that causes a failure that requires Webmaster support.
    Error looks like "an existing transporter instance is currently uploading this package".
    To resolve, request assistance in [Bug 573875](https://bugs.eclipse.org/bugs/show_bug.cgi?id=573875) like what was done in Comment 11 of that bug.
    TODO: it may be possible to work around this error by always using a different random ID when doing the notarization.
- [ ] Sanity check the build for the following:
  - [ ] Use the `External Tools` toolbar button drop-down menu to launch the `Prepare Staging Sanity Check` launch configuration. 
        This will automatically download the packages specified in the launch configuration to subfolders in `/org.eclipse.epp.packages/sanity-check` to make the follow steps easier.
  - [ ] Download a package from the build's [staging output](https://download.eclipse.org/technology/epp/staging/).
  - [ ] Make sure filenames contain expected build name and milestone, e.g., `2026-03-M3`.
  - [ ] Splash screen says the expected release name with no milestone, e.g., `2026-03`.
  - [ ] `Help -> About` says the expected build name and milestone, e.g., `2026-03-M3`.
  - [ ] From the `Console`, open the `Host OSGi console` and use `ss -s INSTALLED` to verify that there are no bundles failing to resolve.
  - [ ] The `org.eclipse.epp.package.*` features and bundles have the timestamp of the forced qualifier update or later.
  - [ ] Upgrade from previous release works.
        The `Prepare Staging Sanity Check` automatically configures the available updates sites for this test.
        To test the upgrade an equivalent to the simrel release composite site needs to be done.
        Add the following software sites to available software, check for updates and then make sure stuff works.
        In particular check error log and that core features, e.g., JDT, Platform, have been upgraded.
    - `https://download.eclipse.org/staging/2026-03/` -
        _NOTE_ Use `SIMREL_REPO` if the staging repo has been updated since the `SIMREL_REPO` location was created.
    - `https://download.eclipse.org/technology/epp/staging/repository/`
    - `https://download.eclipse.org/justj/epp/milestone/latest` - 
       This is needed when there is a new version of JustJ that is not also published as a release.
       For example, Java 21 between 2024-06 M1 and release date of 2024-06.
  - [ ] Verify that no non-EPP content is in the [p2 repo](https://download.eclipse.org/technology/epp/staging/repository/)
       (especially justj, update [remove-justj-from-p2.xml](https://github.com/eclipse-packaging/packages/blob/master/releng/org.eclipse.epp.config/tools/remove-justj-from-p2.xml) if needed).
- [ ] Edit the [Jenkins build](https://ci.eclipse.org/packaging/job/epp/job/master/lastBuild/).
  - [ ] Mark build as Keep forever.
  - [ ] Edit Jenkins Build Information and name it, e.g., `2026-03 M3`.
- [ ] Run the [Promote a Build](
      https://ci.eclipse.org/packaging/job/promote-a-build/
      ) CI job to prepare build artifacts and copy them to download.eclipse.org.
  - [ ] _Optional - useful when testing changes to the promotion scripts:_
       Run the build once in `DRY_RUN` mode to ensure that the output is correct before it is copied to download.eclipse.org.
  - This used to be done late in the day to try and reduce impact of adding dozens of GB on the download server and having all the mirrors start to pick it up right away.
    See [epp-dev emails that led to this decision](https://www.eclipse.org/lists/epp-dev/msg06317.html).
    However in 2024 the impact seems to no longer be a concern.
    This note is preserved until we know for sure there is no issue.
  - The `DRY_RUN` can be done earlier in the day and is a good way to increase the chance that the final promotion step will be successful.
- [ ] Run the [Notarize MacOSX Downloads](
      https://ci.eclipse.org/packaging/job/notarize-downloads/
      ) CI job to notarize DMG packages on download.eclipse.org if the promoted build was unstable.
- [ ] Send an email to epp-dev to request package maintainers test it.
      The email is templated in `email.txt` in the release directory.
  - [ ] Or use the `Run` toolbar button drop-down menu to launch the `Send EMail` launch configuration.
        This will automatically locate the `email.txt` to compose the email.
        Best to get the email drafted before the next step when using the launch configuration.
  - _NOTE_ For `R` build the release is initially published to a temporary location and then moved to the `R` directory later.
    Make a note in the email where the temporary location is.
- [ ] Update `SIMREL_REPO` to the staging repo so CI builds run against CI of SimRel, e.g., [see this gerrit](https://git.eclipse.org/r/c/epp/org.eclipse.epp.packages/+/189618).
  - [ ] Or use the `Run` toolbar button drop-down menu to launch the `Update to Staging Repository` launch configuration.
        This will automatically determine the correct update site URL and will create an appropriate commit message in the system clipboard.
        At this point it's best to also update the `MILESTONE` in `Updater.java` so that staging builds produce results for the next milestone.
- [ ] Re-enable the [CI build](https://ci.eclipse.org/packaging/job/epp/job/master/).
- [ ] Archive old milestones/RCs so that they don't accumulate on the mirrors.

**On all milestone/release days**

This applies to all releases, i.e. M1, M2, M3, RC1 and R.
Everything except R is typically the Friday around 9:30am Ottawa time and the R is the following Wednesday sometime before 10am in coordination with the SimRel release engineer.

- [ ] Check that this worked:
      copy the composite\*M3.jar files over the composite\*.jar files in https://download.eclipse.org/technology/epp/packages/2026-03/ -
      this is done automatically with the
      [EPP Make Visible job](https://ci.eclipse.org/packaging/job/epp-makeVisible/)
      which is automatically triggered by SimRel's
      [SimRel Make Visible Job](https://ci.eclipse.org/simrel/view/All/job/simrel.releng.makeVisible/).

**24-48 Hours Before Final release day**

- [ ] **24 Hours before Final release** Make sure files are in final location to allow downloads to mirror.
  - [ ] Tag the release, e.g., `2026-03_R`.
        Example command line: `git tag --annotate 2026-03_R -m"2026-03 Release" 1b7a1c1af156e3ac57768b87be258cd22b49456b`.
  - [ ] Run the [Rename Provisional to Final](
        https://ci.eclipse.org/packaging/job/rename-provisional-to-final/
        ) CI job to rename the provisional release milestone to final directory.
        E.g., [2020-09/202009101200](
        https://download.eclipse.org/technology/epp/downloads/release/2020-09/202009101200/
        ) -> [2020-09/R](
        https://download.eclipse.org/technology/epp/downloads/release/2020-09/R/
        ) to match what is in [release.xml](
        https://download.eclipse.org/technology/epp/downloads/release/release.xml
        ) - this only applies to downloads, not to packages.
    - [ ] _Optional - useful when testing changes to the promotion scripts:_
          Run the build once in `DRY_RUN` mode to ensure that the output is correct before it applies changes to download.eclipse.org.
  - [ ] Send an updated email to epp-dev informing that the provisional URL has been renamed to `R`.

**On Final release day**

These jobs should be completed by approximately 10am Ottawa time on release days.

- [ ] Run the [Finalize Release](
      https://ci.eclipse.org/packaging/job/finalize-release/
      ) CI job to create the "next" release and update the "latest" release  as follows:
  - The current release needs to be promoted as "latest" under https://download.eclipse.org/technology/epp/packages/latest/.
    This should be a composite pointing to a specific https://download.eclipse.org/technology/epp/packages/yyyy-MM/.
  - The _next_ release sub-directory needs to be created immediately.
    - When 2026-03 is released, a directory 2026-06 must be created with an empty p2 composite repository pointing to 2026-03 until M1.
    - On M1 release day this changes to a composite p2 repository with M1 content.
  - [ ] _Optional - useful when testing changes to the promotion scripts:_
       - Run the build once in `DRY_RUN` mode to ensure that the output is correct before it applies changes to download.eclipse.org.
