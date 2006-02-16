<?xml version="1.0"?>

<xsl:transform
  version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:sets="http://exslt.org/sets"
  extension-element-prefixes="exsl sets">

  <xsl:import href="nix-release-lib.xsl"/>

  <xsl:output method="xml" indent="yes" encoding="UTF-8"
     doctype-public="-//W3C//DTD XHTML 1.1//EN"
     doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"/>

  <xsl:template match="releases">
    <html>
      <head>
        <title>Nix Buildfarm Overviews</title>
	<link rel="stylesheet" href="../css/releases.css" type="text/css" />
      </head>
      <body>
	<h1>Overviews of the Nix Buildfarm</h1>

	<h2>All packages</h2>

	<ul>
	  <li>
	    <a href="latest100.xhtml">Latest releases (100)</a>
	  </li>
	  <li>
	    <a href="latest.xhtml">Latest releases for each package</a>
	  </li>
	</ul>

	<h2>Per package</h2>

	<ul>
	  <xsl:variable name="packages" select="sets:distinct(//release/@packageName)"/>

	  <xsl:for-each select="$packages">
	    <xsl:sort select="." order="ascending"/>
	    <li>
	      <a href="releases-{current()}.xhtml">
		<xsl:value-of select="current()"/>
	      </a>
	    </li>
	  </xsl:for-each>
	</ul>
      </body>
    </html>
  </xsl:template>

</xsl:transform>
