<?xml version="1.0"?>

<xsl:transform
  version="2.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="nix-release-lib.xsl" />
  
  <xsl:param name="separatePages">0</xsl:param>
  <xsl:param name="shortIndex">1</xsl:param>
  
  <xsl:output method='xml' encoding="UTF-8"
              doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" /> 

  <xsl:template match="releases">

    <xsl:call-template name="makeIndex">
      <xsl:with-param name="releases" select="/releases/release" />
    </xsl:call-template>
          
  </xsl:template>
  
  
</xsl:transform>
