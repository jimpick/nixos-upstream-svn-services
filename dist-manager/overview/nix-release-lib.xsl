<?xml version="1.0"?>

<xsl:transform
  version="2.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="sortByDate">0</xsl:param>
  <xsl:param name="shortIndex">1</xsl:param>
  

  <!-- Default CSS stylesheet. -->
  <xsl:template name="defaultCSS">
    <link rel="stylesheet" href="@distPrefix@/css/releases.css" type="text/css" />
    <link rel="alternate" href="index.rss" type="application/rss+xml"
          title="Latest Nix Build Farm Results" />
  </xsl:template>
  

  <xsl:template name="popup-style">
    <style type="text/css">
      *.popup {
        display: none;
        background: url('menuback.png') repeat;
        border: solid #555555 1px;
        position: absolute;
        margin: 0;
        padding: 0;
        width: 23em;
      }
 
      *:hover > *.popup {
        display: block;
      }

      *.popup:hover {
        display: none;
      }
    </style>
  </xsl:template>


  <!-- Show detailed build farm results, with icons to indicate
       whether each release "product" succeeded. -->

  <xsl:template name="releaseTable">
    <xsl:param name="releases"/>

    <xsl:variable name="rpm-systems" select="distinct-values($releases//product[@type='rpm']/@fullName)"/>
    <xsl:variable name="nix-systems" select="distinct-values($releases//product[@type='nix']/@system)"/>

    <table class="buildfarmResults" cellpadding="3" border="1" rules="groups">
      <colgroup>
	<col width="100"/>
	<col width="100"/>
	<col width="70"/>
      </colgroup>
      <colgroup span="1" width="50"/>
      <colgroup span="{6 + count($rpm-systems)}" width="80"/>
      <thead>
	<tr>
	  <th>Package</th>
	  <th>Release</th>
	  <th>Rev</th>
	  <th>All</th>
	  <th>Source tarball</th>
          <!--
	  <th>Nix Linux</th>
	  <th>Nix FreeBSD</th>
	  <th>Nix Cygwin</th>
	  <th>Nix Darwin</th>
          -->
	  <xsl:for-each select="$nix-systems">
	    <th>
	      <xsl:value-of select="current()"/>
	    </th>
	  </xsl:for-each>
	  <xsl:for-each select="$rpm-systems">
	    <th>
	      <xsl:value-of select="current()"/>
	    </th>
	  </xsl:for-each>
	  <th>Check</th>
	  <th>Coverage</th>
	</tr>
      </thead>
      <tbody>
	<xsl:apply-templates select="$releases" mode="release-row">
	  <xsl:with-param name="nix-systems" select="$nix-systems"/>
	  <xsl:with-param name="rpm-systems" select="$rpm-systems"/>
	</xsl:apply-templates>
      </tbody>
    </table>
    
  </xsl:template>


  <!-- Print a picture showing the build status for the entire
       release. -->
  
  <xsl:template name="statusPictureForRelease">
    <xsl:param name="release" />
    <xsl:choose>
      <xsl:when test="$release/product[@failed = '1']">
        <img src="failure.gif" alt="Failure" />
      </xsl:when>
      <xsl:otherwise>
        <img src="success.gif" alt="Success" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    
  
  <xsl:template match="release" mode="release-row">
    <xsl:param name="nix-systems"/>
    <xsl:param name="rpm-systems"/>
    <xsl:variable name="release" select="current()"/>

    <tr>
      <td align="right">
	<a href="full-status-{@packageName}.html">
	  <xsl:value-of select="@packageName"/>
	</a>
      </td>
      <td align="right" style="color: #A0A0A0;">
	<a href="{@distURL}">
	  <xsl:value-of select="substring(@releaseName, string-length(@packageName) + 2)"/>
	</a>
      </td>
      <td align="center" style="color: #A0A0A0;">
	<xsl:value-of select="@svnRevision"/>
      </td>
      <td align="center" class="buildfarmMainColumn">
        <xsl:call-template name="statusPictureForRelease">
          <xsl:with-param name="release" select="." />
        </xsl:call-template>
      </td>

      <td align="center">
	<xsl:apply-templates select="product[@type='source']" mode="product-cell"/>
      </td>

      <xsl:for-each select="$nix-systems">
	<td align="center">
	  <xsl:apply-templates select="$release/product[@type='nix' and @system=current()] " mode="product-cell"/>
	</td>
      </xsl:for-each>

      <xsl:for-each select="$rpm-systems">
	<td align="center">
	  <xsl:apply-templates select="$release/product[@type='rpm' and @fullName=current()] " mode="product-cell"/>
	</td>
      </xsl:for-each>

      <td align="center">
	<xsl:apply-templates select="product[@type='nodist']" mode="product-cell"/>
      </td>

      <td align="center">
        <xsl:if test="product[@type='coverage']">
          <xsl:choose>
            <xsl:when test="product[@type='coverage']/@failed = 1 or not(coverage/@percentage)">
              <xsl:apply-templates select="product[@type='coverage']" mode="product-cell"/>
            </xsl:when>
            <xsl:otherwise>
              <a href="{./@distURL}/{coverage/@file}">
                <xsl:value-of select="coverage/@percentage" />%
              </a>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="product" mode="product-cell">
    <a href="{../@distURL}/{log[position() = last()]/@formatted}">
      <xsl:choose>
	<xsl:when test="@failed = '1'">
	  <img src="failure.gif" alt="Failure" />
	</xsl:when>
	<xsl:otherwise>
	  <img src="success.gif" alt="Success" />
	</xsl:otherwise>
	</xsl:choose>
    </a>
    <!-- <xsl:apply-templates select="." mode="popup"/> -->
  </xsl:template>

  <xsl:template match="product" mode="popup">
    <table class="popup" cellspacing="3">
      <tr>
	<th align="right">start</th>
	<td align="left"><xsl:value-of select="../@date"/></td>
      </tr>

      <tr>
	<th align="right">finish</th>
	<td align="left">-</td>
      </tr>
      <tr>
	<th align="right">duration</th>
	<td align="left">-</td>
      </tr>
    </table>
  </xsl:template>


  <!-- Get the latest release for each package, sorted either by date
       or by package name. -->

  <xsl:template name="getLatestReleases">
    
    <xsl:variable name="latestReleases">
      <xsl:for-each-group select="/releases/release" group-by="@packageName">
        <xsl:variable name="releases">
          <list xmlns="">
            <xsl:for-each select="current-group()">
              <xsl:sort select="@date" order="descending" />
              <xsl:copy-of select="." />
            </xsl:for-each>
          </list>
        </xsl:variable>
        <xsl:copy-of select="$releases/list/release[1]" />
      </xsl:for-each-group>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$sortByDate = 1">
        <xsl:for-each select="$latestReleases/release">
          <xsl:sort select="@date" order="descending" />
          <xsl:copy-of select="." />
        </xsl:for-each>
      </xsl:when>
            
      <xsl:otherwise>
        <xsl:for-each select="$latestReleases/release">
          <xsl:sort select="lower-case(@packageName)" />
          <xsl:copy-of select="." />
          </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

        
  <!-- Make a nice table of all releases. -->
  
  <xsl:template name="makeIndex">
    <xsl:param name="releases"/>
    
    <html>
      
      <head>
        <title>Release Index</title>
        <xsl:call-template name="defaultCSS" />
      </head>

      <body>
        <h1>Release Index</h1>

        <p>Note: the icon after each package's name indicates its
        current status in our build farm; that is, whether the latest
        build for that package succeeded (<img src="success.gif" alt="Success"/>) or
        failed (<img src="failure.gif" alt="Failure"/>).  You can also view the
        build farm status <a href="quick-view.html">at a
        glance</a>.</p>

        <table border="1">

          <tr><th>Name</th><th>Type</th><th>Release</th><th>Date</th></tr>

          <xsl:for-each-group select="$releases" group-by="@packageName">
            <xsl:sort select="lower-case(current-grouping-key())" />

            <xsl:variable name="releasesSorted">
              <list xmlns="">
                <xsl:for-each select="current-group()">
                  <xsl:sort select="@date" order="descending" />
                  <xsl:copy-of select="." />
                </xsl:for-each>
              </list>
            </xsl:variable>

            <tr><td class="pkgname" colspan="4">

              <table width="100%">
                <tr>
                  <td class="pkgname"><xsl:value-of select="current-grouping-key()" /></td>
                  <td>
                    <a href="{$releasesSorted/list/release[1]/@distURL}">
                      <xsl:call-template name="statusPictureForRelease">
                        <xsl:with-param name="release" select="$releasesSorted/list/release[1]" />
                      </xsl:call-template>
                    </a>
                  </td>
                </tr>
              </table>
              
            </td></tr>

            <xsl:call-template name="showReleases">
              <xsl:with-param name="type">Stable</xsl:with-param>
              <xsl:with-param
                  name="releases"
                  select="current-group()[
                          not(contains(@releaseName, 'pre') or contains(@releaseName, '-docs-')) and
                          count(./product[@failed = '1']) = 0]" />
            </xsl:call-template>

            <xsl:call-template name="showReleases">
              <xsl:with-param name="type">Unstable</xsl:with-param>
              <xsl:with-param
                  name="releases"
                  select="current-group()[
                          (contains(@releaseName, 'pre') or contains(@releaseName, '-docs-')) and
                          count(./product[@failed = '1']) = 0]" />
            </xsl:call-template>

            <xsl:call-template name="showReleases">
              <xsl:with-param name="type">Failed</xsl:with-param>
              <xsl:with-param
                  name="releases"
                  select="current-group()[./product[@failed = '1']]" />
            </xsl:call-template>

          </xsl:for-each-group>
            
        </table>

      </body>

    </html>

  </xsl:template>


  <!-- Print table elements for the releases of a given type,
       optionally eliding some of them. -->
  
  <xsl:template name="showReleases">
    <xsl:param name="type" />
    <xsl:param name="releases" />
    
    <xsl:variable name="releasesSorted">
      <list xmlns="">
        <xsl:for-each select="$releases">
          <xsl:sort select="@date" order="descending" />
          <xsl:copy-of select="." />
        </xsl:for-each>
      </list>
    </xsl:variable>

    <xsl:variable name="mostRecent"
                  select="$releasesSorted/list/release[$shortIndex = 0 or $type = 'Stable' or position() &lt;= 1]" />
    
    <xsl:for-each select="$mostRecent">
      <tr>
        <xsl:choose>
          <xsl:when test="position() = 1">
            <td />
            <td class="reltype" id="{@packageName}-{$type}">
              <xsl:value-of select="$type" />
            </td>
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

    <xsl:if test="$shortIndex = 1 and count($releases) > 0 and count($releases) != count($mostRecent)">
      <tr>
        <td colspan="2" />
        <td colspan="2"><em><a href="full-index-{$releases[1]/@packageName}.html#{$releases[1]/@packageName}-{$type}">all
        <xsl:call-template name="toLowercase">
          <xsl:with-param name="string" select="$type" />
        </xsl:call-template>
        releases...</a></em></td>
      </tr>
    </xsl:if>

  </xsl:template>


  <!-- Convert a string to lowercase. -->
  
  <xsl:template name="toLowercase">
    <xsl:param name="string" />
    <xsl:variable name="lcletters">abcdefghijklmnopqrstuvwxyz</xsl:variable>
    <xsl:variable name="ucletters">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
    <xsl:value-of select="translate($string, $ucletters, $lcletters)" />
  </xsl:template>
  
  
</xsl:transform>
