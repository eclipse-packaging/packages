The EPP Build
=============

The [Eclipse Packaging Project (EPP)](http://www.eclipse.org/epp/) provides 
the download packages based on the content of the yearly Simultaneous Release. 
The download packages are provided from 
[www.eclipse.org/downloads/eclipse-packages/](https://www.eclipse.org/downloads/eclipse-packages/).

Creating and releasing packages
-------------------------------

Please see [RELEASING.md](RELEASING.md) in this repo for instructions on the release process for the EPP project.

Build a Package Locally
-----------------------

It's *easy* to run the build locally! All you need is Maven and then you need 
to tell Maven which package(s) to build via profile. As an example, the following 
command from the root of the Git repository builds the RCP/RAP package against 
the Simultaneous Release staging p2 repository:

    mvn clean verify -Pepp.package.rcp

To build all the packages:

    mvn clean verify -Pepp.package.cpp,epp.package.dsl,epp.package.embedcpp,epp.package.java,epp.package.jee,epp.package.modeling,epp.package.parallel,epp.package.php,epp.package.rcp,epp.package.scout,epp.package.committers

This build creates output in two places:

1. tar.gz/zip/dmg archives with the packages in `archive/` and
2. a p2 repository with the EPP artifacts in `archive/repository/`.

Windows users
------------- 

In the past the last step in the build process used to fail.
For further  details see [bug 426416](https://bugs.eclipse.org/bugs/show_bug.cgi?id=426416).
If that happens again

    mvn clean package -P"epp.package.rcp"

Available Profiles
------------------

Each package uses its own profile:

- epp.package.committers
- epp.package.cpp
- epp.package.embedcpp
- epp.package.dsl
- epp.package.java
- epp.package.jee
- epp.package.modeling
- epp.package.parallel
- epp.package.php
- epp.package.rcp
- epp.package.scout

macOS dmg files can only be created within the Eclipse Foundation network. To enable creating
dmg files enable the eclipse-package-dmg profile. Without eclipse-package-dmg enabled, the .tar.gz
for macOS will be created regardless.

With the signing profiles enabled, the build artifacts (bundles, features) and the
Windows and macOS executables are signed. This is done by using the Eclipse Foundation 
internal signing service and can be activated only if the build is running there.

- eclipse-sign-jar profile enables signing of the EPP bundles and jar files
- eclipse-sign-mac profile enables usage of macOS signing service
- eclipse-sign-dmg profile enables signing of the DMG files for the macOS platform (the eclipse-package-dmg needs to be enabled too!)
- eclipse-sign-windows profile enables usage of Windows signing service

Additional Configuration Possibilities
--------------------------------------

By default, the EPP build uses the content of the Eclipse Simultaneous Release *Staging*
repository at <http://download.eclipse.org/staging/2020-03/> as input. Sometimes it is
desired to build against another release (e.g. a different milestone), or against a local
mirror of this repository. This can be achieved by setting the Java property
`eclipse.simultaneous.release.repository`to another URL. As an example, by adding the
following argument to the Maven command line, the EPP build will read its input from the
composite Eclipse 2020-03 repository:

    -Declipse.simultaneous.release.repository="http://download.eclipse.org/releases/2020-03"

EPP Configuration File format
-----------------------------

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

This content in this section has been migrated from the [wiki](https://wiki.eclipse.org/EPP/Packaging_Site)
