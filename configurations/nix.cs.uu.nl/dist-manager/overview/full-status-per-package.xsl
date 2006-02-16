<?xml version="1.0"?>

<xsl:transform
  version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:sets="http://exslt.org/sets"
  xmlns:regexp="http://exslt.org/regular-expressions"
  extension-element-prefixes="exsl sets regexp">

  <xsl:import href="nix-release-lib.xsl" />
  
  <xsl:param name="separatePages">0</xsl:param>
  <xsl:param name="shortIndex">0</xsl:param>
  <xsl:param name="out">.</xsl:param>
  
  <xsl:output method='html' />

  <xsl:key name="packagesByPkgName" match="release" use="@packageName" />

  
  <xsl:template match="releases">

    <xsl:variable name="packages">
      <xsl:call-template name="groupReleases" />
    </xsl:variable>

    <!-- For each unique package name, generate a file showing the
         detailed build farm results of each release for that
         package. -->
    
    <xsl:for-each select="exsl:node-set($packages)/package">

      <exsl:document href="{$out}/full-status-{@name}.html" encoding="UTF-8">

        <xsl:variable name="title">
          Build Farm Results for Package <xsl:value-of select="@name" />
        </xsl:variable>

        <html >
          <head>
            <title><xsl:copy-of select="$title" /></title>
            <xsl:call-template name="defaultCSS" />
            <xsl:call-template name="popup-style"/>
          </head>

          <body>

            <h1><xsl:copy-of select="$title" /></h1>

            <p>Note: there is also a <a
            href="quick-view.html">overview of the latest build
            results per package</a>.</p>

            <xsl:variable name="sorted">
              <xsl:for-each select="release">
                <xsl:sort select="@date" order="descending" />
                <xsl:copy-of select="." />
              </xsl:for-each>
            </xsl:variable>
            
            <xsl:call-template name="releaseTable">
              <xsl:with-param name="releases" select="exsl:node-set($sorted)"/>
            </xsl:call-template>

          </body>

        </html>
        
      </exsl:document>

    </xsl:for-each>

  </xsl:template>

</xsl:transform>
