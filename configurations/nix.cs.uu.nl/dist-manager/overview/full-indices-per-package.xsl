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
    
    <!-- For each unique package name, generate a file showing all the
         releases for that package. -->
    
    <xsl:for-each select="exsl:node-set($packages)/package">

      <exsl:document href="{$out}/full-index-{@name}.html" encoding="UTF-8">

        <xsl:variable name="justThis">
          <package xmlns=""><xsl:copy-of select="release" /></package>
        </xsl:variable>

        <xsl:call-template name="makeIndex">
          <xsl:with-param name="packages" select="exsl:node-set($justThis)" />
        </xsl:call-template>
        
      </exsl:document>
      
    </xsl:for-each>
      
  </xsl:template>

</xsl:transform>
