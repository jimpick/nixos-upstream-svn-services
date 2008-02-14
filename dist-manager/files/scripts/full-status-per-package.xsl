<?xml version="1.0"?>

<xsl:transform
  version="2.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="nix-release-lib.xsl" />
  
  <xsl:param name="separatePages">0</xsl:param>
  <xsl:param name="shortIndex">0</xsl:param>
  <xsl:param name="out">.</xsl:param>
  
  
  <xsl:template match="releases">

    <!-- For each unique package name, generate a file showing the
         detailed build farm results of each release for that
         package. -->
    
    <xsl:for-each-group select="/releases/release" group-by="@packageName">

      <xsl:result-document href="{$out}/full-status-{current-grouping-key()}.html" encoding="UTF-8"
                     doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
                     doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

        <xsl:variable name="title">
          Build Farm Results for Package <xsl:value-of select="current-grouping-key()" />
        </xsl:variable>

        <html >
          <head>
            <title><xsl:copy-of select="$title" /></title>
            <xsl:call-template name="defaultCSS" />
            <xsl:call-template name="popup-style"/>
          </head>

          <body>

            <h1><xsl:copy-of select="$title" /></h1>

            <p>Note: there is also an <a
            href="quick-view.html">overview of the latest build
            results per package</a>.</p>

            <xsl:variable name="sorted">
              <xsl:for-each select="current-group()">
                <xsl:sort select="@date" order="descending" />
                <xsl:copy-of select="." />
              </xsl:for-each>
            </xsl:variable>
            
            <xsl:call-template name="releaseTable">
              <xsl:with-param name="releases" select="$sorted"/>
            </xsl:call-template>

          </body>

        </html>

      </xsl:result-document>

    </xsl:for-each-group>

  </xsl:template>

</xsl:transform>
