/*******************************************************************************
 * Copyright (c) 2007 Innoopract Informationssysteme GmbH
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    Innoopract - initial API and implementation
 *******************************************************************************/
package org.eclipse.epp.packaging.core.configuration.xml;

import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;

import javax.xml.parsers.ParserConfigurationException;

import org.eclipse.epp.packaging.core.configuration.IPackagerConfiguration;
import org.eclipse.epp.packaging.core.configuration.PackagerConfiguration;
import org.eclipse.epp.packaging.core.configuration.Platform;
import org.xml.sax.SAXException;

/**
 * Parses an Eclipse Packager configuration in XML format.
 */
public class ConfigurationParser {

  private static final String LATEST = "latest"; //$NON-NLS-1$
  
  private static final String ATTRIB_ARCH = "arch"; //$NON-NLS-1$
  private static final String ATTRIB_ECLIPSE_INI_PATH = "path"; //$NON-NLS-1$
  private static final String ATTRIB_ECLIPSE_PRODUCT_ID = "eclipseProductId"; //$NON-NLS-1$
  private static final String ATTRIB_FOLDER = "folder"; //$NON-NLS-1$
  private static final String ATTRIB_FORMAT = "format"; //$NON-NLS-1$
  private static final String ATTRIB_ID = "id"; //$NON-NLS-1$
  private static final String ATTRIB_INITIAL_PERSPECTIVE_ID = "initialPerspectiveId"; //$NON-NLS-1$
  private static final String ATTRIB_NAME = "name"; //$NON-NLS-1$
  private static final String ATTRIB_OS = "os"; //$NON-NLS-1$
  private static final String ATTRIB_RELATIVE_FOLDER = "relativeFolder"; //$NON-NLS-1$
  private static final String ATTRIB_URL = "url"; //$NON-NLS-1$
  private static final String ATTRIB_VERSION = "version"; //$NON-NLS-1$
  private static final String ATTRIB_WS = "ws"; //$NON-NLS-1$

  private static final String TAG_ARCHIVE_FORMAT = "archiveFormat"; //$NON-NLS-1$
  private static final String TAG_ECLIPSE_INI_FILE = "eclipseIniFileContent"; //$NON-NLS-1$
  private static final String TAG_EXTENSION_SITE = "extensionSite"; //$NON-NLS-1$
  private static final String TAG_FEATURE = "feature"; //$NON-NLS-1$
  private static final String TAG_PLATFORM = "platform"; //$NON-NLS-1$
  private static final String TAG_PRODUCT = "product"; //$NON-NLS-1$
  private static final String TAG_RCP = "rcp"; //$NON-NLS-1$
  private static final String TAG_REQUIRED_FEATURES = "requiredFeatures"; //$NON-NLS-1$
  private static final String TAG_ROOT_FILE_FOLDER = "rootFileFolder"; //$NON-NLS-1$
  private static final String TAG_TARGET_PLATFORMS = "targetPlatforms"; //$NON-NLS-1$
  private static final String TAG_UPDATE_SITE = "updateSite"; //$NON-NLS-1$
  private static final String TAG_UPDATE_SITES = "updateSites"; //$NON-NLS-1$

  private final File xmlFile;

  public ConfigurationParser( final File xmlFile ) {
    this.xmlFile = xmlFile;
  }
  
  /**
   * Parses the configuration contained in xmlFile.
   */
  public IPackagerConfiguration parseConfiguration()
    throws SAXException, IOException, ParserConfigurationException
  {
    return parseConfiguration( new XMLDocument( xmlFile ).getRootElement() );
  }

  /**
   * Parses the configuration-string xml. Used in tests only.
   */
  public IPackagerConfiguration parseConfiguration( final String xml )
    throws MalformedURLException, SAXException, IOException,
    ParserConfigurationException
  {
    return parseConfiguration( new XMLDocument( xml ).getRootElement() );
  }

  private IXmlElement[] getElements( final IXmlElement element,
                                     final String name )
  {
    return element.getElements( name );
  }

  private String getFolderName( final IXmlElement element ) {
    return element.getAttributeValue( ATTRIB_FOLDER );
  }

  /**
   * Reads the various elements of the configuration from the root element.
   * 
   * @throws MalformedURLException
   */
  private IPackagerConfiguration parseConfiguration( final IXmlElement root )
    throws MalformedURLException
  {
    PackagerConfiguration configuration = new PackagerConfiguration();
    parseRcp( configuration, root );
    parseProduct( configuration, root );
    parseUpdateSites( configuration, root );
    parseRequiredFeatures( configuration, root );
    parseRootFolder( configuration, root );
    parseExtensionSite( configuration, root );
    parsePlatforms( configuration, root );
    return configuration;
  }


  /** Loads and sets the extension site to use. */
  private void parseExtensionSite( final PackagerConfiguration configuration,
                                   final IXmlElement parent )
  {
    IXmlElement element = parent.getElement( TAG_EXTENSION_SITE );
    configuration.setExtensionSiteRelative( element.getAttributeValue( ATTRIB_RELATIVE_FOLDER ) );
  }

  
  /** Loads and sets the target platforms. */
  private void parsePlatforms( final PackagerConfiguration configuration,
                               final IXmlElement parent )
  {
    IXmlElement element = parent.getElement( TAG_TARGET_PLATFORMS );
    for( IXmlElement platformElement : getElements( element, TAG_PLATFORM ) ) {
      String os = platformElement.getAttributeValue( ATTRIB_OS );
      String ws = platformElement.getAttributeValue( ATTRIB_WS );
      String arch = platformElement.getAttributeValue( ATTRIB_ARCH );
      IXmlElement eclipseIniFileElement = platformElement.getElement( TAG_ECLIPSE_INI_FILE );
      String eclipseIniFileContent = eclipseIniFileElement.getText();
      String eclipseIniFilePath = eclipseIniFileElement.getAttributeValue( ATTRIB_ECLIPSE_INI_PATH );
      Platform platform = configuration.addTargetPlatform( os, ws, arch, eclipseIniFileContent, eclipseIniFilePath );
      IXmlElement archiveFormat = platformElement.getElement( TAG_ARCHIVE_FORMAT );
      if( archiveFormat != null ) {
        platform.setArchiveFormat( archiveFormat.getAttributeValue( ATTRIB_FORMAT ) );
      }
    }
  }

  private void parseProduct( final PackagerConfiguration configuration,
                             final IXmlElement parent )
  {
    IXmlElement productElement = parent.getElement( TAG_PRODUCT );
    String productName = productElement.getAttributeValue( ATTRIB_NAME );
    configuration.setProductName( productName );
    String eclipseProductId = productElement.getAttributeValue( ATTRIB_ECLIPSE_PRODUCT_ID );
    configuration.setEclipseProductId( eclipseProductId );
    String initialPerspectiveId = productElement.getAttributeValue( ATTRIB_INITIAL_PERSPECTIVE_ID );
    configuration.setInitialPerspectiveId( initialPerspectiveId );
  }

  private void parseRcp( final PackagerConfiguration configuration,
                         final IXmlElement parent )
  {
    IXmlElement rcpElement = parent.getElement( TAG_RCP );
    String rcpVersion = rcpElement.getAttributeValue( ATTRIB_VERSION );
    configuration.setRcpVersion( rcpVersion );
  }

  /** 
   * Loads and sets the required features.
   */
  private void parseRequiredFeatures( final PackagerConfiguration configuration,
                                      final IXmlElement parent )
  {
    IXmlElement element = parent.getElement( TAG_REQUIRED_FEATURES );
    for( IXmlElement featureElement : getElements( element, TAG_FEATURE ) ) {
      String version = featureElement.getAttributeValue( ATTRIB_VERSION );
      if( version != null ) {
        version = version.trim();
        if( version.length() == 0 || LATEST.equalsIgnoreCase( version ) ) {
          version = null;
        }
      }
      configuration.addRequiredFeature( featureElement.getAttributeValue( ATTRIB_ID ),
                                        version );
    }
  }

  /** Loads and sets the folder containing the root files. */
  private void parseRootFolder( final PackagerConfiguration configuration,
                                final IXmlElement parent )
  {
    IXmlElement element = parent.getElement( TAG_ROOT_FILE_FOLDER );
    String folder = resolveRelativeFileName( getFolderName( element ) );
    configuration.setRootFileFolder( folder );
  }

  /**
   * Loads and sets the available update sites.
   * 
   * @throws MalformedURLException
   */
  private void parseUpdateSites( final PackagerConfiguration configuration,
                                 final IXmlElement parent )
    throws MalformedURLException
  {
    IXmlElement element = parent.getElement( TAG_UPDATE_SITES );
    for( IXmlElement siteElement : getElements( element, TAG_UPDATE_SITE ) ) {
      configuration.addUpdateSite( siteElement.getAttributeValue( ATTRIB_URL ) );
    }
  }
  
  /*
   * This method resolves a potentially relative file name. If the path is
   * specified relative, then it is considered relative to the parent of the
   * configuration (XML) file.
   */
  private String resolveRelativeFileName( final String path ) {
    if( new File( path ).isAbsolute() )
      return path;
    return new File( this.xmlFile.getParent(), path ).toString();
  }
  
}