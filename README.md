# The EPP Build

The [Eclipse Packaging Project (EPP)](https://projects.eclipse.org/projects/technology.packaging/) provides the download packages based on the content of the yearly Simultaneous Release.
The download packages are provided from [www.eclipse.org/downloads/eclipse-packages/](https://www.eclipse.org/downloads/eclipse-packages/).

## Creating and releasing packages

Please see [RELEASING.md](RELEASING.md) in this repo for instructions on the release process for the EPP project.

## Build Locally

It's _easy_ to run the build locally! All you need is Maven:

    mvn clean verify

will build all the packages (using automatically activated profiles) and the resulting zip/tar/dmg will be in `packages/org.eclipse.epp.package.${PACKAGE}.product/target/products`.
In addition the combined p2 site will be in `archive/repository`.

### Build a single package

If you want to build just a single package add the profile for the package you want to build, along with the profile to materialize the product:

    mvn verify -Pepp.p2.common -Pepp.product.cpp -Pepp.p2.cpp -Pepp.materialize-products

This build creates output in two places:

1. tar.gz/zip/dmg archives with the packages in `archive/` and
2. a p2 repository with the EPP artifacts in `archive/repository/`.

### Build a single platform

By default the maven build runs the build for all platforms, this can be time consuming and can be changed to only build a limited number of platforms, a useful thing to do for testing changes locally.
There is no profile (PRs welcome!) to disabled other platforms, instead modify `releng/org.eclipse.epp.config/parent/pom.xml` to exclude the unwanted platforms in `target-platform-configuration`'s configuration.

### Windows users

In the past the last step in the build process used to fail.
For further details see [bug 426416](https://bugs.eclipse.org/bugs/show_bug.cgi?id=426416).
If that happens again you can omit the `verify` stage and simply `package`.

    mvn clean package -Pepp.package.rcp -Pepp.materialize-products

### Available Profiles

Each package uses its own profile, with the zip/tar/dmg in `packages/org.eclipse.epp.package.${PACKAGE}.product/target/products`.
With the `epp.materialize-products` profile the zip/tar/dmg will be created, otherwise only the p2 site will be created.

- epp.package.committers
- epp.package.cpp
- epp.package.embedcpp
- epp.package.dsl
- epp.package.java
- epp.package.jee
- epp.package.modeling
- epp.package.php
- epp.package.rcp
- epp.package.scout

macOS dmg files can only be created within the Eclipse Foundation network. To enable creating
dmg files enable the `eclipse-package-dmg` profile. Without `eclipse-package-dmg` enabled, the .tar.gz
for macOS will be created regardless.

With the signing profiles enabled, the build artifacts (bundles, features) and the
Windows and macOS executables are signed. This is done by using the Eclipse Foundation
internal signing service and can be activated only if the build is running there.

- `eclipse-sign-jar` profile enables signing of the EPP bundles and jar files
- `eclipse-sign-mac` profile enables usage of macOS signing service
- `eclipse-sign-dmg` profile enables signing of the DMG files for the macOS platform (the `eclipse-package-dmg` needs to be enabled too!)
- `eclipse-sign-windows` profile enables usage of Windows signing service

### Additional Configuration Possibilities

By default, the EPP build uses the content of the Eclipse Simultaneous Release _Staging_
repository at <https://download.eclipse.org/staging/2026-03/> as input. Sometimes it is
desired to build against another release (e.g., a different milestone), or against a local
mirror of this repository. This can be achieved by setting the Java property
`eclipse.simultaneous.release.repository`to another URL. As an example, by adding the
following argument to the Maven command line, the EPP build will read its input from the
composite Eclipse 2026-03 repository:

    -Declipse.simultaneous.release.repository="https://download.eclipse.org/releases/2026-03"

### EPP Configuration File format

The individual EPP packages have a special file called epp.website.xml that defines various
pieces of information about the package. The format of the file is:

```
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
 <!-- Package Description information to be picked up by www.eclipse.org/packages -->
 <!-- PackageName is the title of your package
      maintainer is the project or persons that are maintaining the package
      iconurl is the fully qualified URL to the icon you wish to use on the site (48x48)
      bugzillaComponentID is used to gather bugzilla information about your package.
         This should be given to you after provisioning of the package is finished
      testPlan is the fully qualified URL to the test plan for this package
   -->
  <packageMetaData
   packageName="Eclipse IDE for C/C++ Developers"
   maintainer="Eclipse Packaging Project"
   iconurl="http://www.eclipse.org/downloads/images/c.jpg"
   bugzillaComponentId="cpp-package"
   testPlan="http://www.eclipse.org/epp/testplan.php" >

     <!-- Description is wrapped in CDATA tags to allow you to insert HTML code if necessary -->
     <description><![CDATA[An IDE for C/C++ developers.]]></description>

     <!-- packageTesters is a list of the people that are testing the package -->
     <packageTesters>
       <tester>Markus Knauer</tester>
    </packageTesters>

  </packageMetaData>

...

</configuration>
```
