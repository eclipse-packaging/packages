# Eclipse Packaging Project Change Log

The Eclipse Packaging Project (EPP) assembles the contents of the quarterly Eclipse Simultaneous Release (SimRel) into products that can be downloaded from the [Eclipse IDE website](https://eclipseide.org).
This document aims to highlight configuration and content changes of the packages provided by EPP in each quarterly release.
For changes in Eclipse projects that contribute to SimRel and are included in the EPP packages, refer to the change log or New and Noteworthy document of the participating projects.
The [Eclipse IDE New & Noteworthy](https://eclipseide.org/release/noteworthy/) page combines all those documents in one place.

## 2023-12

- The Eclipse IDE for Scientific Computing is not longer being published. If you are interested in helping maintain or resurrect this package, and the underlying Parallel Tools Project, please [leave a comment](https://github.com/eclipse-packaging/packages/issues/85). 
- Eclipse [contains a new backend](https://eclipse.dev/eclipse/news/4.30/platform.php#new-ecf-client) used by P2 to install and update software. The Eclipse Packaging Project [has disabled this by default](https://github.com/eclipse-packaging/packages/issues/81) as it is [known to not work in some corporate environments](https://github.com/eclipse-equinox/p2/issues/381). Please help test the new backend by removing `-Dorg.eclipse.ecf.provider.filetransfer.excludeContributors=org.eclipse.ecf.provider.filetransfer.httpclientjava` from eclipse.ini and [reporting any issues you have](https://github.com/eclipse-equinox/p2/issues/new/choose) so that the new backend can be the default in the near future.
- The PDE Spies has been restored to the Eclipse IDE for RCP and RAP Developers.

## 2023-09

- Packages now contain configuration and start levels for logging support.
This change applies the [recommendation](https://eclipse.dev/eclipse/news/4.28/platform.php#slf4j.api-version-2) from Eclipse Platform to support SLF4J version 2.
For implementation details refer to [EPP Issue #27](https://github.com/eclipse-packaging/packages/issues/27).
- With the new Mylyn major version being released the list of features included in packages have been updated to their new names and IDs.
- The Eclipse IDE for RCP and RAP Developers is missing the PDE Spies, this can be manually installed by selecting "Eclipse Plug-in Development Environment Spies" in the Install New Software wizard.

## 2023-06

- With [Eclipse Mylyn](https://eclipse.dev/mylyn/)'s return to the SimRel train Mylyn features have also been added back to all the EPPs, except Eclipse IDE for Java and DSL Developers.

## Prior to 2023-06

This Changelog was introduced for release 2023-09 and backfilled to 2023-06.
If you require additional information about older versions to be added to this changelog, please [raise an issue](https://github.com/eclipse-packaging/packages/issues).
