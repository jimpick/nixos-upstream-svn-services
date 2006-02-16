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
  <xsl:param name="shortIndex">1</xsl:param>
  
  <xsl:output method='html' />

  <xsl:key name="packagesByPkgName" match="release" use="@packageName" />


  <xsl:template match="releases">

    <xsl:variable name="packages">
      <xsl:call-template name="groupReleases" />
    </xsl:variable>

    <xsl:call-template name="makeIndex">
      <xsl:with-param name="packages" select="exsl:node-set($packages)" />
    </xsl:call-template>
          
  </xsl:template>
  
  
</xsl:transform>
