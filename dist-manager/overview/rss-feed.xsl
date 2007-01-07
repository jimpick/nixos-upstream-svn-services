<?xml version="1.0"?>

<xsl:transform
  version="2.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="nix-release-lib.xsl"/>

  <xsl:param name="sortByDate">0</xsl:param>
  <xsl:param name="baseURL">http://nix.cs.uu.nl/</xsl:param>

  <xsl:output method='xml' encoding="UTF-8" />

  
  <xsl:template match="releases">

    <xsl:variable name="latestReleasesSorted">
      <xsl:call-template name="getLatestReleases" />
    </xsl:variable>


    <rdf:RDF
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns="http://purl.org/rss/1.0/"
        xmlns:syn="http://purl.org/rss/1.0/modules/syndication/"
        >
      
      <channel rdf:about="{$baseURL}">
        <title>Latest Nix Build Farm Results</title>
        <link><xsl:value-of select="$baseURL" /></link>
        <description>List of the latest build for each package
        performed by the Nix build farm.</description>
        <syn:updatePeriod>hourly</syn:updatePeriod>
        <syn:updateFrequency>1</syn:updateFrequency>
        <items>
          <rdf:Seq>
	    <rdf:li resource="overview" />
            <xsl:for-each select="$latestReleasesSorted/release">
              <rdf:li resource="{@distURL}" />
            </xsl:for-each>
          </rdf:Seq>
        </items>
      </channel>

      <item rdf:about="overview">
        <title>Overview</title>
        <link><xsl:value-of select="$baseURL" />/quick-view-by-date.html</link>
      </item>

      <xsl:for-each select="$latestReleasesSorted/release">
        
        <item rdf:about="{@distURL}">
          <title>
            <xsl:choose>
              <xsl:when test="product[@failed = '1']">X: </xsl:when>
              <xsl:otherwise>O: </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="@releaseName" />
          </title>
          <link><xsl:value-of select="@distURL" /></link>
        </item>

      </xsl:for-each>
      
    </rdf:RDF>
    
  </xsl:template>
</xsl:transform>
