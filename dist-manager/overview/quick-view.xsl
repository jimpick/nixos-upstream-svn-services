<?xml version="1.0"?>

<xsl:transform
  version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:sets="http://exslt.org/sets"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl sets">

  <xsl:import href="nix-release-lib.xsl"/>

  <xsl:param name="sortByDate">0</xsl:param>

  <xsl:key name="packagesByPkgName" match="release" use="@packageName" />

  <xsl:output method='xml' encoding="UTF-8"
              doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" /> 

  
  <xsl:template match="releases">
    <html >
      <head>
        <title>Latest Build Farm Results</title>
        <xsl:call-template name="defaultCSS" />
	<xsl:call-template name="popup-style"/>
      </head>
      
      <body>

        <h1>Latest Build Farm Results</h1>
        
        <p>Note: there is also a more <a href="index.html">end-user
        centric overview of the releases</a>.  Clicking on the
        left-most column will show the build farm results for each
        release of a package.  You can also see this list sorted by
        <xsl:choose><xsl:when test="$sortByDate = 1"><a
        href="quick-view.html">package
        name</a></xsl:when><xsl:otherwise><a
        href="quick-view-by-date.html">date</a></xsl:otherwise></xsl:choose>.
        Finally, an <a href="index.rss">RSS feed</a> is available.</p>

        <xsl:variable name="latestReleasesSorted">
          <xsl:call-template name="getLatestReleases" />
        </xsl:variable>

	<xsl:call-template name="releaseTable">
	  <xsl:with-param name="releases" select="exsl:node-set($latestReleasesSorted)"/>
	</xsl:call-template>
        
      </body>
      
    </html>
  </xsl:template>
</xsl:transform>
