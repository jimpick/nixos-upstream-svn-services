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

    <!-- For each unique package name, generate a file showing all the
         releases for that package. -->
    
    <xsl:for-each-group select="/releases/release" group-by="@packageName">

      <xsl:result-document href="{$out}/full-index-{current-grouping-key()}.html" encoding="UTF-8" 
                           doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
                           doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

        <xsl:call-template name="makeIndex">
          <xsl:with-param name="releases" select="current-group()" />
        </xsl:call-template>

      </xsl:result-document>

    </xsl:for-each-group>
      
  </xsl:template>

</xsl:transform>
