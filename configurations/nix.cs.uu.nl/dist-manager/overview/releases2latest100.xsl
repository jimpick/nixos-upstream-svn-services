<?xml version="1.0"?>

<xsl:transform
  version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl">

  <xsl:import href="nix-release-lib.xsl"/>

  <xsl:output method="xml" indent="yes" encoding="UTF-8"
     doctype-public="-//W3C//DTD XHTML 1.1//EN"
     doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"/>

  <xsl:template match="releases">
    <html >
      <head>
        <title>Nix Buildfarm Overview</title>
	<xsl:call-template name="popup-style"/>
      </head>
      <body>
	<xsl:variable name="releases">
	  <xsl:apply-templates select="release" mode="copy">
	    <xsl:sort select="@date" order="descending"/>
	  </xsl:apply-templates>
	</xsl:variable>

	<xsl:call-template name="release-table">
	  <xsl:with-param name="releases" select="exsl:node-set($releases)/release[position() &lt; 100]"/>
	</xsl:call-template>
      </body>
    </html>
  </xsl:template>


</xsl:transform>
