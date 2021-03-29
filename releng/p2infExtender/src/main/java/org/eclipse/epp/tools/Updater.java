/****************************************************************************
* Copyright (c) 2016, 2021 Ed Merks (Berlin, Germany) and others.
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v2.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v20.html
*******************************************************************************/
package org.eclipse.epp.tools;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

public class Updater {

	public static void main(String[] args) throws Exception {
		System.out.println("####" + System.getProperty("user.dir"));

		DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
		documentBuilderFactory.setNamespaceAware(true);
		documentBuilderFactory.setValidating(false);
		DocumentBuilder documentBuilder = documentBuilderFactory.newDocumentBuilder();

		File file = new File(System.getProperty("user.dir"), "../../packages").getCanonicalFile();
		for (File project : file.listFiles()) {
			if (project.getName().endsWith(".product")) {

				List<String> rootFeatures = new ArrayList<String>();
				File productFile = new File(project, "epp.product");
				Document document = documentBuilder.parse(new FileInputStream(productFile));
				NodeList features = document.getElementsByTagName("feature");
				for (int i = 0, length = features.getLength(); i < length; ++i) {
					Element feature = (Element) features.item(i);
					if ("root".equals(feature.getAttribute("installMode"))) {
						rootFeatures.add(feature.getAttribute("id"));
					}
				}

				if (rootFeatures.isEmpty()) {
					System.out.println("Skipping " + productFile);
					
				} else {
					System.out.println("Processing  " + productFile);
					System.out.println(rootFeatures);
					
					File p2InfFile = new File(project, "p2.inf");
					FileInputStream in = new FileInputStream(p2InfFile);
					byte[] bytes = new byte[in.available()];
					in.read(bytes);
					in.close();
					String content = new String(bytes, "8859_1");

					Pattern propertyPattern = Pattern.compile(
							"^properties\\.([0-9]*)\\.(name|value)\\s*=\\s*((:?[^\r\n\\\\]|\\\\\r?\n|\\\\[^\r\n])*)(\r?\n)",
							Pattern.DOTALL | Pattern.MULTILINE);

					int newProperty = 0;
					int newPosition = -1;
					String nl = null;
					int oldStart = -1;
					int oldEnd = -1;
					int oldProperty = -1;
					for (Matcher matcher = propertyPattern.matcher(content); matcher.find();) {
						String propertyKind = matcher.group(2);
						int property = Integer.parseInt(matcher.group(1));
						if ("name".equals(propertyKind)
								&& "org.eclipse.equinox.p2.product.install.roots".equals(matcher.group(3))) {
							oldStart = matcher.start();
							oldProperty = property;
						} else if ("value".equals(propertyKind) && property == oldProperty) {
							oldEnd = matcher.end(4);
						}

						newProperty = Math.max(newProperty, property + 1);
						// System.err.println(">" + matcher.group(1) + " " + propertyKind + " '" + matcher.group(3) + "'");
						newPosition = matcher.end(4);
						nl = matcher.group(5);
					}

					if (true) {
						OutputStream o = new FileOutputStream(p2InfFile);
						PrintStream out = new PrintStream(p2InfFile, "8859_1");
						
						if (oldProperty != -1) {
							newProperty = oldProperty;
						}

						if (oldStart == -1) {
							out.print(content.substring(0, newPosition));
							out.print(nl);
							out.print(nl);
						} else {
							out.print(content.substring(0, oldStart));
						}

						out.print("properties." + newProperty + ".name = org.eclipse.equinox.p2.product.install.roots");
						out.print(nl);
						out.print("properties." + newProperty + ".value =");
						for (int i = 0, size = rootFeatures.size(); i < size; ++i) {
							out.print(" \\");
							out.print(nl);
							out.print(' ');
							out.print(rootFeatures.get(i));
						}

						out.print(content.substring(oldEnd != -1 ? oldEnd : newPosition));
						
						out.close();
						o.close();
					}
				}
			}
		}
	}
}
