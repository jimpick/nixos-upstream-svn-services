<?xml version="1.0"?>

<xsl:transform
  version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:sets="http://exslt.org/sets"
  xmlns:regexp="http://exslt.org/regular-expressions"
  extension-element-prefixes="exsl sets regexp">

  <!--
  <xsl:output method="xml" indent="yes" encoding="UTF-8"
     doctype-public="-//W3C//DTD XHTML 1.1//EN"
     doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"/>
  -->

  <xsl:output method='html' />

  <xsl:key name="packagesByPkgName" match="release" use="@packageName" />

  
  <xsl:template match="releases">

    <html>
      
      <head>
        <title>Release Index</title>
	<link rel="stylesheet" href="../css/releases.css" type="text/css" />
        <link rel="alternate" href="index.rss" type="application/rss+xml"
              title="Latest Releases" />
      </head>

      <body>
        <h1>Release Index</h1>

        <p><a href='./overviews.xhtml'>Overviews of all recent
        releases</a> are available.</p>

        <table border="1">

          <tr><th>Name</th><th>Type</th><th>Release</th><th>Date</th></tr>

          <xsl:for-each select="release[count(. | key('packagesByPkgName', @packageName)[1]) = 1]">

            <tr><td class="pkgname" colspan="4"><xsl:value-of select="@packageName" /></td></tr>

            <!-- 
            <xsl:for-each select="key('packagesByPkgName', @packageName)">
              <tr>
                <td />
                <td />
                <td class="relname">
                  <a href="{@distURL}">
                    <xsl:value-of select="@releaseName" />
                  </a>
                </td>
                <td class="date">
                  <xsl:value-of select="@date" />
                </td>
              </tr>
            </xsl:for-each>
            -->

            <xsl:call-template name="foo">
              <xsl:with-param name="type">Stable</xsl:with-param>
              <xsl:with-param
                  name="releases"
                  select="key('packagesByPkgName', @packageName)[
                          not(contains(@releaseName, 'pre')) and
                          count(./product[@failed = '1']) = 0]" />
            </xsl:call-template>

            <xsl:call-template name="foo">
              <xsl:with-param name="type">Unstable</xsl:with-param>
              <xsl:with-param
                  name="releases"
                  select="key('packagesByPkgName', @packageName)[
                          contains(@releaseName, 'pre') and
                          count(./product[@failed = '1']) = 0]" />
            </xsl:call-template>

            <xsl:call-template name="foo">
              <xsl:with-param name="type">Failed</xsl:with-param>
              <xsl:with-param
                  name="releases"
                  select="key('packagesByPkgName', @packageName)[./product[@failed = '1']]" />
            </xsl:call-template>

          </xsl:for-each>
            
        </table>

      </body>

    </html>

  </xsl:template>


  <xsl:template name="foo">
    <xsl:param name="type" />
    <xsl:param name="releases" />
    <xsl:for-each select="$releases">
      <xsl:sort select="@date" order="descending" />
      <tr>
        <xsl:choose>
          <xsl:when test="position() = 1">
            <td />
            <td class="reltype"><xsl:value-of select="$type" /></td>
          </xsl:when>
          <xsl:otherwise>
            <td colspan="2" />
          </xsl:otherwise>
        </xsl:choose>
        <td class="relname">
          <a href="{@distURL}">
            <xsl:value-of select="@releaseName" />
          </a>
        </td>
        <td class="date">
          <xsl:value-of select="@date" />
        </td>
      </tr>
    </xsl:for-each>
    <xsl:if test="count($releases) = 0">
      <tr>
        <td />
        <td class="reltype"><xsl:value-of select="$type" /></td>
        <td colspan="2"><em>none</em></td>
      </tr>
    </xsl:if>
  </xsl:template>
  
</xsl:transform>