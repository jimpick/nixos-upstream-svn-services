<?xml version="1.0"?>

<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text"/>

  <xsl:template match="/">
    <xsl:value-of select="log/logentry[1]/@revision"/>
  </xsl:template>
</xsl:transform>
