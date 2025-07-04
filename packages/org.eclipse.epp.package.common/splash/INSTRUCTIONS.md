# About and Splash Screen

### Interact with Eclipse Foundation for new splash screen series

**When:** after the March release

Although Eclipse IDE packages are shipped every 3 months,
one release a year (usually in June) receives addition marketing support.
This usually include a new main website, a new splash screen, and `Help -> About Image`.
The community must request the new splash screen as early as possible before June
(ideally after the March release)
 via a [Helpdesk issue](https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues).
 If you open this issue, make sure Eclipse Foundation marketing people are notified.

When ready, the Eclipse Foundation marketing team will submit some splashscreen,
sometimes asking for feedback when multiple splash screens are competing.
When the final splashscreen is selected,
the community must ask for the variations of this splashscreen:
some saying just "Eclipse" (for the Platform artifacts) and some saying "Eclipse IDE" (for the EPP packages),
and the 4 variations for each quarterly release (202x-06, 202x-09, 202x-12, 202(x+1)-03).

- For 2023-06 -> 2024-03 see [Helpdesk 2335](https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/2336)
- For 2024-06 -> 2025-03 see [Helpdesk 3963](https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/3963)
- For 2025-06 -> 2026-03 see [Helpdesk 5332](https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/5332) - [Eclipse_IDE.zip](https://gitlab.eclipse.org/-/project/23/uploads/b449ea9c813e964d3fe480727630d651/Eclipse_IDE.zip)

### Copy splash screen series into `org.eclipse.epp.package.common/splash/`

Once the Foundation and community agree on a splash screen,
some EPP contributor must copy the new splash screen into `org.eclipse.epp.package.common/splash/`
for further usage in EPP.

Some raw image files are welcome, but as those artifacts may have to be changed unexpectedly,
keeping the "image project" files (Photoshop or Illustrator files) in the repository can also help later.

### Changing EPP splashscreen

**When:** Before every M1

The splash screen needs to be an (approximately) 450x300 pixels .bmp file,
24-bits RGB (maybe other depth work too, but it's not tested),
**without color space information** (some SWT bug),
and 72 DPI (so it draws the correct size on macOS).

To produce it, if the initial splash screens aren't of that form (they're usually .jpg files),
open the desired splash screen variation file from the `org.eclipse.epp.package.common/splash/` folder in Gimp:

- [ ] resize it to approximately 450x300 with _Image > Scale_
- [ ] then set DPI to 72 with _Image > Print Size_
- [ ] then _File > Export_ it: choose the location `org.eclipse.epp.package.common/splash.bmp` press _Save_, 
  - [ ] and in the Export options, tick _Compatibility Options > Do not write color space information_. 
  - [ ] Apply.

Repeat process, but for About dialog image which exists in each EPP package as `packages/org.eclipse.epp.package.*/eclipse_lg.png` (approx 115 x 302) and `packages/org.eclipse.epp.package.*/eclipse_lg@2x.png` (2x other image, approx 230 x 604).

This is only needed once per year for a `20xx-06` release when the style of the logo changes.
Typically one can just reuse these from the Platform:

- https://github.com/eclipse-platform/eclipse.platform/blob/master/platform/org.eclipse.platform/eclipse_lg.png
- https://github.com/eclipse-platform/eclipse.platform/blob/master/platform/org.eclipse.platform/eclipse_lg%402x.png

Then, commit the change locally,
test it by building whichever EPP package via command-line and then starting this package.
The new splash screen should be in place.
Then, push the change to GitHub.
