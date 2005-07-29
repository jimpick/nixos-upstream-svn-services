<?xml version="1.0"?>

<xsl:transform
  version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:sets="http://exslt.org/sets"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl sets">

  <xsl:import href="nix-release-lib.xsl"/>
  <xsl:param name="out"/>

  <xsl:output method="xml" indent="yes" encoding="UTF-8"
     doctype-public="-//W3C//DTD XHTML 1.1//EN"
     doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"/>

  <xsl:template match="releases">
    <xsl:variable name="packages" select="sets:distinct(//release/@packageName)"/>    
    <xsl:variable name="releases" select="//release"/>

    <xsl:for-each select="$packages">
      <xsl:variable name="package-releases-unsorted">
	<xsl:call-template name="releases-of-package">
	  <xsl:with-param name="name" select="current()"/>
	  <xsl:with-param name="releases" select="$releases"/>
	</xsl:call-template>
      </xsl:variable>

      <xsl:variable name="package-releases">
	<xsl:apply-templates select="exsl:node-set($package-releases-unsorted)//release" mode="copy">
	  <xsl:sort select="@date" order="descending"/>
	</xsl:apply-templates>
      </xsl:variable>

      <exsl:document href="{$out}/releases-{current()}.xhtml">
	<html>
	  <head>
	    <title>
	      Nix Buildfarm Overview for <xsl:value-of select="current()"/>
	    </title>

	    <xsl:call-template name="popup-style"/>
	  </head>
	  <body>
	    <xsl:call-template name="release-table">
	      <xsl:with-param name="releases" select="exsl:node-set($package-releases)//release"/>
	    </xsl:call-template>
	  </body>
	</html>
      </exsl:document>
    </xsl:for-each>
  </xsl:template>
</xsl:transform>
