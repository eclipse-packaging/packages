Contributing to the Eclipse Packaging Project (EPP)
===================================================

Thanks for your interest in this project. Contributions to the [Eclipse Packaging Project (EPP)] [1] are most welcome. There are many ways to contribute, from entering high quality bug reports, to contributing code or documentation changes.

Project description:
--------------------

The objectives of the Eclipse Packaging project are to

- create *entry level downloads* based on defined user profiles for the [Eclipse Simultaneous Release] [2]. The project defined and created the EPP downloads of Java Developer, Enterprise Java Developer, C/C++ Developer, RCP Developer, and more. These downloads are available from the main [Eclipse download page] [3].
- provide a platform that allows the creation of packages (zip/tar/dmg downloads) from an p2 repository. The core technology of the project enables the creation of download packages that are created by bundling Eclipse features from one or multiple Eclipse p2 repositories.

For more information, please go to the [Eclipse Packaging Project overview page] [4] or to the [EPP web site] [1]. 


Developer resources:
--------------------

Information regarding source code management, builds, coding standards, and more.

- <https://projects.eclipse.org/projects/technology.packaging/developer>

- Nightly builds are created on the project's Jenkins instance at <https://ci.eclipse.org/packaging/>.
- For instructions on how to run a build locally, follow the instructions of the README included in the root of this Git repository.

Create an Eclipse Development Environment
-----------------------------------------

[![Create Eclipse Development Environment for EPP](https://download.eclipse.org/oomph/www/setups/svg/EPP.svg)](https://www.eclipse.org/setups/installer/?url=https://raw.githubusercontent.com/eclipse-packaging/packages/master/releng/org.eclipse.epp.config/oomph/EPPConfiguration.setup&show=true "Click to open Eclipse-Installer Auto Launch or drag onto your running installer's title area")

Contributor License Agreement:
------------------------------

Before your contribution can be accepted by the project, you need to create and electronically sign the Eclipse Foundation Contributor License Agreement (CLA).

- <http://www.eclipse.org/legal/CLA.php>

Contact:
--------

Contact the project developers via the project's "dev" mailing list.

- <https://dev.eclipse.org/mailman/listinfo/epp-dev>

Search for bugs:
----------------

This project uses Bugzilla to track ongoing development and issues.

- <https://bugs.eclipse.org/bugs/buglist.cgi?product=EPP>

Create a new bug:
-----------------

Be sure to search for existing bugs before you create another one. Remember that contributions are always welcome!

- <https://bugs.eclipse.org/bugs/enter_bug.cgi?product=EPP>


EPP Committer and Maintainer Policy
-----------------------------------

In EPP, the "maintainer" of a package is a committer in EPP. Partially so they can do work on their package, and also so that can participate in project discussions and decisions that effect the project or whole set of EPP packages.

Historical note 1: in 2010, the current set of committers were "seeded" by making all current maintainers committers. Prior to that, there was only one active committer, the Project Lead, Markus Knauer, which was less than ideal for many reasons. Now that time has passed, it was thought best to document the EPP project's policy on making new people committers and maintainers of packages (either new packages, or transfer "ownership" of an existing package). In particular, it was decided to follow "the Orbit model" of committership and package "owner".

Historical note 2: this policy used to live on the wiki and was moved to the git repo from: https://wiki.eclipse.org/EPP/EPP_Committer_and_Maintainer_Policy

If someone is a committer on another Eclipse project, and they state they are interested in contributing and maintaining an EPP package (or, transferring ownership of an existing EPP package), that history with other Eclipse projects suffices for them to be nominated and voted-in as a committer. This differs from most other projects where, for good reason, a person must (usually) have a history of contributions to that specific project, not just Eclipse in general. There still could be reasons an existing committer would note "no" (-1) for a nomination, for example, "no, I am the current maintainer and I do not agree to this!" ... or some other fairly large issue. Normally people do not vote "0" just because they have no first hand knowledge of a person's committer history (as they might on other projects), but vote "+1" if basic criteria are met, to be welcoming and supportive of new people coming in.

Normally, as with most other Eclipse projects, unless a committer explicitly "resigns" there would be no automatic removal of a committer just because package responsibility is transferred, except eventually the usual "inactive" reasons would apply ... if someone is no longer responsible for maintaining a package and has not been active on mailing lists, etc., for a period of 6 months or so, the Project Lead can remove them via Eclipse Portal for "inactivity". And, of course, committers should explicitly resign, when appropriate, such as they are changing responsibilities and know they have no interest or time to be involved.


[1]: http://eclipse.org/epp/
[2]: http://wiki.eclipse.org/Simultaneous_Release
[3]: https://www.eclipse.org/downloads/eclipse-packages/
[4]: https://projects.eclipse.org/projects/technology.packaging
