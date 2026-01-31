/**
 * Copyright (c) 2025, 2026 Eclipse contributors and others.
 *
 * This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * which accompanies this distribution, and is available at
 * https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 */
package org.eclipse.epp.releng.updater;

import java.awt.Desktop;
import java.awt.Toolkit;
import java.awt.datatransfer.StringSelection;
import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse.BodyHandlers;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TreeSet;
import java.util.regex.Pattern;

public class Updater {
	/**
	 * M1, M2, M3, RC1, RC2
	 */
	private static final String MILESTONE = "M3";

	private static final String PLATFORM_VERSION = "4.39";

	private static final String EXECUTION_ENVIRONMENT = "21";

	private static final String PLATFORM_VERSION_MATCHER = "(4\\.[3-9][0-9])";

	private static final Pattern PLATFORM_VERSION_PATTERN = Pattern.compile("4\\.([0-9]+)(\\..*)?");

	private static final String SIMREL_PREVIOUS_VERSION = getSimRelVersion(PLATFORM_VERSION, -1);

	private static final String SIMREL_VERSION = getSimRelVersion(PLATFORM_VERSION, 0);

	private static final String SIMREL_NEXT_VERSION = getSimRelVersion(PLATFORM_VERSION, +1);

	private static final String SIMREL_VERSION_MATCHER = "(20[2-9][0-9]-(?:03|06|09|12))";

	private static final String SIMREL_QUALIFIER_MATCHER = "(M1|M2|M3|RC1|RC2|R)";

	private static final String SIMREL_QUALIFIED_VERSION = SIMREL_VERSION + "-" + MILESTONE.replace("RC2", "R");

	private static final String SIMREL_QUALIFIED_VERSION_MATCHER = "(20[2-9][0-9]-(?:03|06|09|12)-(?:M1|M2|M3|RC1|RC2|R))";

	private static final String SIMREL__SCHEDULE = "https://raw.githubusercontent.com/eclipse-simrel/.github/refs/heads/main/wiki/SimRel/"
			+ SIMREL_VERSION + "_dates.json";

	private static final String RELEASE_DIR = getReleaseDirFromSchedule();

	private static final String COPYRIGHT_YEAR = SIMREL_VERSION.replaceAll("-.*", "");

	private Path root;

	public static void main(String[] args) throws IOException {
		var arguments = List.of(args);
		var currentWorkingDirectory = Path.of(".").toRealPath();
		if (!currentWorkingDirectory.toString().replace("\\", "/")
				.endsWith("releng/org.eclipse.epp.config/org.eclipse.epp.releng.updater")) {
			throw new RuntimeException("Expecting to run this from the org.eclipse.epp.releng.updater project");
		}
		var root = currentWorkingDirectory.resolve("../../..").toRealPath();
		if (arguments.contains("-send-email")) {
			new Updater(root).sendEmail();
		} else if (arguments.contains("-to-milestone-repository")) {
			new Updater(root).toMilestoneRepository();
		} else if (arguments.contains("-to-staging-repository")) {
			new Updater(root).toStagingRepository();
		} else {
			new Updater(root).update();
			if (arguments.contains("-open-issue")) {
				var text = Files.readString(root.resolve("RELEASING.md"));
				var joinedText = text.replaceAll("([,;:.a-z()-_*])\r?\n +([^-* ])", "$1 $2");
				var issueURL = "https://github.com/eclipse-packaging/packages/issues/new?title="
						+ encode("EPP " + SIMREL_VERSION + " " + MILESTONE) + "&labels=endgame" + "&body="
						+ encode("<!-- paste body from clipboard -->\n");

				// Can't do this because the URL is then too long + "&body=" + encode(text);
				// So instead copy the text to the clipboard.
				copyToClipboard(joinedText);
				openURL(issueURL);
			}
		}
	}

	private Map<Path, String> contents = new LinkedHashMap<>();

	public Updater(Path root) {
		this.root = root;
		getReleaseDirFromSchedule();
	}

	private static String getReleaseDirFromSchedule() {
		try {
			var schedule = HttpClient.newBuilder().build()
					.send(HttpRequest.newBuilder(URI.create(SIMREL__SCHEDULE)).GET().build(), BodyHandlers.ofString())
					.body();
			var milestoneDatePattern = Pattern
					.compile("\"" + MILESTONE + "\"\\s*:\\s*\"(?<date>20[2-9][0-9]-[01][0-9]-[0123][0-9])\"");
			var matcher = milestoneDatePattern.matcher(schedule);
			if (matcher.find()) {
				var dateLiteral = matcher.group("date");
				var temporalAccessor = DateTimeFormatter.ofPattern("yyyy-MM-dd", Locale.US).parse(dateLiteral);
				var convertedDate = LocalDate.from(temporalAccessor);
				var previousDay = convertedDate.minusDays(1);
				return previousDay.format(DateTimeFormatter.ofPattern("yyyyMMdd", Locale.US)) + "1000";
			} else {
				throw new RuntimeException("No match found in: " + schedule);
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	private static String getSimRelVersion(String version, int delta) {
		var matcher = PLATFORM_VERSION_PATTERN.matcher(version);
		if (matcher.matches()) {
			var offset = Integer.valueOf(matcher.group(1)) - 11 + delta;
			var year = 2019 + offset / 4;
			String quarter;
			switch (offset % 4) {
			case 0: {
				quarter = "03";
				break;
			}
			case 1: {
				quarter = "06";
				break;
			}
			case 2: {
				quarter = "09";
				break;
			}
			default: {
				quarter = "12";
				break;
			}
			}
			return year + "-" + quarter;
		} else {
			throw new RuntimeException("Bad version");
		}
	}

	private String getContent(Path path) throws IOException {
		return contents.containsKey(path) ? contents.get(path) : Files.readString(path);
	}

	private void apply(Path path, String pattern, String... replacements) throws IOException {
		var content = getContent(path);
		var matcher = Pattern.compile(pattern).matcher(content);
		if (matcher.find()) {
			var modifiedContent = new StringBuilder(content);
			do {
				for (var group = matcher.groupCount(); group >= 1; --group) {
					modifiedContent.replace(matcher.start(group), matcher.end(group), replacements[group - 1]);
				}
			} while (matcher.find());
			if (!modifiedContent.toString().equals(content)) {
				contents.put(path, modifiedContent.toString());
			}
		}
	}

	private void visit(Path file) throws IOException {
		var relativePathName = root.relativize(file).toString().replace('\\', '/');
		var fileName = file.getFileName().toString();

		try {
			if (!fileName.endsWith(".class") && !fileName.endsWith(".png") && !fileName.endsWith(".icns")
					&& !fileName.endsWith(".ico") && !fileName.endsWith(".bmp") && !fileName.endsWith(".svg")) {
				var copyrightPattern = Pattern.compile("^.*Copyright.*?((?<begin>[0-9]{4})(, *(?<end>[0-9]{4}))?).*$",
						Pattern.MULTILINE);
				var content = getContent(file);
				var matcher = copyrightPattern.matcher(content);
				while (matcher.find()) {
					var begin = matcher.group("begin");
					var end = matcher.group("end");
					if (!COPYRIGHT_YEAR.equals(end) && !COPYRIGHT_YEAR.equals(begin)) {
						var modifiedContent = new StringBuilder(content);
						modifiedContent.replace(matcher.start(1), matcher.end(1), begin + ", " + COPYRIGHT_YEAR);
						contents.put(file, modifiedContent.toString());
					}
				}
			}
		} catch (IOException ex) {
			throw new RuntimeException(file + ": " + ex.getLocalizedMessage(), ex);
		}

		if (relativePathName.equals("Jenkinsfile")) {
			apply(file, "'https://download.eclipse.org/staging/" + SIMREL_VERSION_MATCHER + "/content.jar'",
					SIMREL_VERSION);
		} else if (relativePathName.equals("README.md")) {
			apply(file, "<https://download.eclipse.org/staging/" + SIMREL_VERSION_MATCHER + "/>", SIMREL_VERSION);
			apply(file, "Eclipse " + SIMREL_VERSION_MATCHER + " repository", SIMREL_VERSION);
			apply(file, "-Declipse.simultaneous.release.repository=\"https://download.eclipse.org/releases/"
					+ SIMREL_VERSION_MATCHER + "\"", SIMREL_VERSION);
		} else if (fileName.equals("epp.website.xml")) {
			apply(file, "url=\"https://eclipse.dev/eclipse/news/" + PLATFORM_VERSION_MATCHER + "/\"", PLATFORM_VERSION);
			apply(file, "<product name=\"[^\"]+" + SIMREL_QUALIFIED_VERSION_MATCHER + "\"\\s*/>",
					SIMREL_QUALIFIED_VERSION);
		} else if (fileName.equals("feature.xml")) {
			apply(file, "version=\"" + PLATFORM_VERSION_MATCHER + "\\.0\\.qualifier\"", PLATFORM_VERSION);
		} else if (fileName.equals("epp.p2.inf")) {
			apply(file, "properties\\.[0-9]+\\.value = " + SIMREL_VERSION_MATCHER + " Release ", SIMREL_VERSION);
		} else if (fileName.equals("pom.xml")) {
			apply(file, "<version>" + PLATFORM_VERSION_MATCHER + "\\.0-SNAPSHOT</version>", PLATFORM_VERSION);
			apply(file, "<RELEASE_NAME>" + SIMREL_VERSION_MATCHER + "</RELEASE_NAME>", SIMREL_VERSION);
			apply(file, "<PREV_RELEASE_NAME>" + SIMREL_VERSION_MATCHER + "</PREV_RELEASE_NAME>",
					SIMREL_PREVIOUS_VERSION);
			apply(file, "<NEXT_RELEASE_NAME>" + SIMREL_VERSION_MATCHER + "</NEXT_RELEASE_NAME>", SIMREL_NEXT_VERSION);
			apply(file, "<RELEASE_MILESTONE>([^<]+)</RELEASE_MILESTONE>", MILESTONE.replace("RC2", "R"));
			apply(file, "<RELEASE_VERSION>" + PLATFORM_VERSION_MATCHER + "\\.0</RELEASE_VERSION>", PLATFORM_VERSION);
			apply(file, "<RELEASE_DIR>([^<]+)</RELEASE_DIR>", RELEASE_DIR);
			apply(file,
					" <SIMREL_REPO>https://download.eclipse.org/staging/" + SIMREL_VERSION_MATCHER + "/?</SIMREL_REPO>",
					SIMREL_VERSION);
			apply(file, "\n *<eclipse.simultaneous.release.name>([^>]+)</eclipse.simultaneous.release.name>",
					MILESTONE.equals("RC2") ? "${RELEASE_NAME} (${RELEASE_VERSION})"
							: "${RELEASE_NAME} ${RELEASE_MILESTONE} (${RELEASE_VERSION} ${RELEASE_MILESTONE})");
			apply(file, "<execution.environment.version>([^<]+)</execution.environment.version>",
					EXECUTION_ENVIRONMENT);
		} else if (fileName.equals("epp.product")) {
			apply(file, "<product[^>]+version=\"" + PLATFORM_VERSION_MATCHER + "\\.0\\.qualifier\"", PLATFORM_VERSION);

			apply(file, "<feature id=\"org.eclipse.epp.[^\"]+\" version=\"" + PLATFORM_VERSION_MATCHER
					+ "\\.0\\.qualifier\"/>", PLATFORM_VERSION);
			apply(file, "<repository[^>]+location=\"https://download.eclipse.org/eclipse/updates/"
					+ PLATFORM_VERSION_MATCHER + "\"", PLATFORM_VERSION, PLATFORM_VERSION);
			apply(file, "<repository[^>]+location=\"https://download.eclipse.org/releases/" + SIMREL_VERSION_MATCHER
					+ "\"\\s+name=\"" + SIMREL_VERSION_MATCHER + "\"", SIMREL_VERSION, SIMREL_VERSION);
		} else if (fileName.equals("MANIFEST.MF")) {
			apply(file, "Bundle-Version: " + PLATFORM_VERSION_MATCHER + "\\.0\\.qualifier", PLATFORM_VERSION);
		} else if (fileName.equals("promote-a-build.sh")) {
			var pattern = Pattern.compile("<past>(?<version>20[2-9][0-9]-(?:03|06|09|12))/R</past>(?<nl>\r?\n)EOM");
			var content = getContent(file);
			var matcher = pattern.matcher(content);
			if (!matcher.find()) {
				throw new IllegalStateException("Expecting a proper match in " + relativePathName);
			}
			var expectedPastVersion = getSimRelVersion(PLATFORM_VERSION, -2);
			if (!expectedPastVersion.equals(matcher.group("version"))) {
				var modifiedContent = content.substring(0, matcher.end("nl")) //
						+ "<past>" + expectedPastVersion + "/R</past>" + matcher.group("nl")//
						+ content.substring(matcher.end("nl"));
				contents.put(file, modifiedContent);
			}
		} else if (relativePathName.equals("RELEASING.md")) {
			apply(file, " `https://download.eclipse.org/staging/" + SIMREL_VERSION_MATCHER + "/`", SIMREL_VERSION);
			apply(file, "e\\.g\\., `" + SIMREL_VERSION_MATCHER + "_R`", SIMREL_VERSION);
			apply(file, "e\\.g\\., `" + SIMREL_VERSION_MATCHER + "`", SIMREL_VERSION);
			apply(file, "e\\.g\\., `" + SIMREL_VERSION_MATCHER + "[- ]" + SIMREL_QUALIFIER_MATCHER + "`",
					SIMREL_VERSION, MILESTONE.replace("RC2", "R"));
			apply(file, "copy the composite.[*]" + SIMREL_QUALIFIER_MATCHER
					+ ".jar files over the composite.[*].jar files in https://download.eclipse.org/technology/epp/packages/"
					+ SIMREL_VERSION_MATCHER + "/", MILESTONE.replace("RC2", "R"), SIMREL_VERSION);
			apply(file,
					"`git tag --annotate " + SIMREL_VERSION_MATCHER + "_R -m\"" + SIMREL_VERSION_MATCHER + " Release\"",
					SIMREL_VERSION, SIMREL_VERSION);
			apply(file,
					"When " + SIMREL_VERSION_MATCHER + " is released, a directory " + SIMREL_VERSION_MATCHER
							+ " must be created with an empty p2 composite repository pointing to "
							+ SIMREL_VERSION_MATCHER + " until M1",
					SIMREL_VERSION, SIMREL_NEXT_VERSION, SIMREL_VERSION);
			apply(file, "issue titled `EPP " + SIMREL_VERSION_MATCHER + " " + SIMREL_QUALIFIER_MATCHER + "`",
					SIMREL_VERSION, MILESTONE);
			apply(file,
					"https://github.com/eclipse-simrel/.github/blob/main/wiki/SimRel/" + SIMREL_VERSION_MATCHER + ".md",
					SIMREL_VERSION);
			apply(file,
					"\\[" + SIMREL_VERSION_MATCHER
							+ " Participants\\]\\(https://eclipse.dev/simrel/\\?file=wiki/SimRel/"
							+ SIMREL_VERSION_MATCHER + "_participants.json\\).",
					SIMREL_VERSION, SIMREL_VERSION);
		}
	}

	private void update() throws IOException {
		Files.walkFileTree(root, new SimpleFileVisitor<Path>() {
			@Override
			public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
				visit(file);
				return super.visitFile(file, attrs);
			}

			@Override
			public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs) throws IOException {
				String fileName = dir.getFileName().toString();
				if ("target".equals(fileName) || "sanity-check".equals(fileName) || fileName.startsWith(".")
						|| dir.endsWith("META-INF/maven")) {
					return FileVisitResult.SKIP_SUBTREE;
				}
				Path relativePath = root.relativize(dir);
				if (relativePath.startsWith("updates")) {
					return FileVisitResult.SKIP_SUBTREE;
				}
				return super.preVisitDirectory(dir, attrs);
			}
		});

		saveModifiedContents();
	}

	private void sendEmail() throws IOException {
		var text = getContents("https://download.eclipse.org/technology/epp/downloads/release/" + SIMREL_VERSION + "/"
				+ MILESTONE + "/_email.txt");
		text = text.replace("https://github.com/eclipse-packaging/packages/labels/endgame", getEndgameIssue());
		openURL("mailto:epp-dev@eclipse.org?subject=" + encode("EPP " + SIMREL_VERSION + " " + MILESTONE) + "&body="
				+ encode(text));
	}

	private void toMilestoneRepository() throws IOException {
		var parentPOM = root.resolve("releng/org.eclipse.epp.config/parent/pom.xml");
		var releaseFolderContent = getContents("https://download.eclipse.org/justj/?file=releases/" + SIMREL_VERSION);
		var versions = new TreeSet<String>(Comparator.reverseOrder());
		for (var matcher = Pattern
				.compile("justj/\\?file=releases/" + SIMREL_VERSION + "/(" + COPYRIGHT_YEAR + "[0-9]+)")
				.matcher(releaseFolderContent); matcher.find();) {
			versions.add(matcher.group(1));
		}
		var latestVersion = versions.getFirst();
		var latestRepository = "https://download.eclipse.org/releases/" + SIMREL_VERSION + "/" + latestVersion + "/";

		// Verify it exists.
		var p2Index = getContents(latestRepository + "p2.index");
		if (!p2Index.contains("version=1")) {
			throw new IllegalStateException("A proper p2.index is expected in " + latestRepository);
		}
		apply(parentPOM, "<SIMREL_REPO>([^<]+)</SIMREL_REPO>", latestRepository);
		saveModifiedContents();

		var endgameIssue = getEndgameIssue();
		copyToClipboard(String.format("""
				Prepare for %s %s

				- Use %s

				Part of %s
				""", SIMREL_VERSION, MILESTONE, latestRepository, endgameIssue));
	}

	private void toStagingRepository() throws IOException {
		var parentPOM = root.resolve("releng/org.eclipse.epp.config/parent/pom.xml");
		var stagingRepository = "https://download.eclipse.org/staging/" + SIMREL_VERSION + "/";
		apply(parentPOM, "<SIMREL_REPO>([^<]+)</SIMREL_REPO>", stagingRepository);
		saveModifiedContents();

		var endgameIssue = getEndgameIssue();
		copyToClipboard(String.format("""
				Back to staging

				- Use %s

				Part of %s
				""", stagingRepository, endgameIssue));
	}

	private String getEndgameIssue() throws IOException {
		var issues = getContents("https://api.github.com/repos/eclipse-packaging/packages/issues?labels=endgame");
		var issueMatcher = Pattern
				.compile("html_url\" *: *\"(https://github.com/eclipse-packaging/packages/issues/[0-9]+)\"")
				.matcher(issues);
		if (!issueMatcher.find()) {
			throw new IllegalStateException("No issue found: " + issues);
		}
		return issueMatcher.group(1);
	}

	private String getContents(String location) throws IOException {
		try {
			var uri = URI.create(location);
			var httpClient = HttpClient.newBuilder().followRedirects(HttpClient.Redirect.NORMAL).build();
			var requestBuilder = HttpRequest.newBuilder(uri).GET();
			var request = requestBuilder.build();
			var response = httpClient.send(request, BodyHandlers.ofString());
			var statusCode = response.statusCode();
			if (statusCode != 200) {
				throw new IOException("status code " + statusCode + " -> " + uri);
			}
			return response.body();
		} catch (InterruptedException e) {
			throw new IOException(e);
		}
	}

	private void saveModifiedContents() throws IOException {
		for (var entry : contents.entrySet()) {
			Files.writeString(entry.getKey(), entry.getValue());
		}
	}

	private static String encode(String value) {
		return URLEncoder.encode(value, StandardCharsets.UTF_8).replace("+", "%20");
	}

	private static void openURL(String uri) throws IOException {
		Desktop.getDesktop().browse(URI.create(uri));
	}

	private static void copyToClipboard(String string) {
		Toolkit.getDefaultToolkit().getSystemClipboard().setContents(new StringSelection(string), null);
	}
}
