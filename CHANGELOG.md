# Eclipse Packaging Project Change Log

The Eclipse Packaging Project (EPP) assembles the contents of the quarterly Eclipse Simulatanous Release (SimRel) into products that can be downloaded from the [Eclipse IDE website](https://eclipseide.org).
This document aims to highlight configuration and content changes of the packages provided by EPP in each quarterly release.
For changes in Eclipse projects that contribute to SimRel and are included in the EPP packages, refer to the change log or New and Noteworthy document of the particpating projects.
The [Eclipse IDE New & Noteworthy](https://eclipseide.org/release/noteworthy/) page combines all those documents in one place.

## 2023-09

- Packages now contain configuration and start levels for logging support.
This change applies the [recommendation](https://eclipse.dev/eclipse/news/4.28/platform.php#slf4j.api-version-2) from Eclipse Platform to support SLF4J version 2.
For implementation details refer to [EPP Issue #27](https://github.com/eclipse-packaging/packages/issues/27).
- With the new Mylyn major version being released the list of features included in packages have been updated to their new names and IDs.

## 2023-06

- With [Eclips Mylyn](https://eclipse.dev/mylyn/)'s return to the SimRel train Mylyn features have also been added back to all the EPPs, except Eclipse IDE for Java and DSL Developers.

## Prior to 2023-06

This Changelog was introduced for release 2023-09 and backfilled to 2023-06.
If you require additional information about older versions to be added to this changelog, please [raise an issue](https://github.com/eclipse-packaging/packages/issues).
