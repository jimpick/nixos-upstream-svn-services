<?xml version="1.0"?>

<xsl:transform
  version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:sets="http://exslt.org/sets"
  xmlns:exsl="http://exslt.org/common"
  >

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

      a {
        color : inherit;
        text-decoration : none;
      }

      a:hover, a:visited:hover {
        color : blue;
        text-decoration  : underline;
      }
    </style>
  </xsl:template>

  <xsl:template name="release-table">
    <xsl:param name="releases"/>

    <xsl:variable name="rpm-systems" select="sets:distinct($releases//product[@type='rpm']/@fullName)"/>

    <table cellpadding="3" border="1" rules="groups" frame="void">
      <colgroup>
	<col width="100"/>
	<col width="100"/>
	<col width="70"/>
      </colgroup>
      <colgroup span="1" width="50"/>
      <colgroup span="{4 + count($rpm-systems)}" width="80"/>
      <thead>
	<tr>
	  <th>pkg</th>
	  <th>release</th>
	  <th>rev</th>
	  <th bgcolor="#E0E0E0">all</th>
	  <th>source</th>
	  <th>Nix/Linux</th>
	  <th>Nix/Darwin</th>
	  <xsl:for-each select="$rpm-systems">
	    <th>
	      <xsl:value-of select="current()"/>
	    </th>
	  </xsl:for-each>
	  <th>nodist</th>
	</tr>
      </thead>
      <tbody>
	  <tr bgcolor="#E0E0E0">
	    <th align="right"></th>
	    <th align="right"></th>
	    <th align="right"></th>
	    <td align="center">-</td>
	    <td bgcolor="#E0E0E0"></td> <!-- source -->
	    <td bgcolor="#E0E0E0"></td> <!-- linux -->
	    <td bgcolor="#E0E0E0"></td> <!-- darwin -->
	    <xsl:for-each select="$rpm-systems">
	      <td bgcolor="#E0E0E0"></td>
	    </xsl:for-each>
	    <td bgcolor="#E0E0E0"></td> <!-- nodist -->
	  </tr>
      </tbody>
      <tbody>
	<xsl:apply-templates select="$releases" mode="release-row">
	  <xsl:with-param name="rpm-systems" select="$rpm-systems"/>
	</xsl:apply-templates>
      </tbody>
    </table>
    
  </xsl:template>
  
  <xsl:template match="release" mode="release-row">
    <xsl:param name="rpm-systems"/>
    <xsl:variable name="release" select="current()"/>

    <tr>
      <th align="right">
	<a href="releases-{@packageName}.xhtml">
	  <xsl:value-of select="@packageName"/>
	</a>
      </th>
      <th align="right" style="color: #A0A0A0;">
	<a href="{@distURL}">
	  <xsl:value-of select="substring(@releaseName, string-length(@packageName) + 2)"/>
	</a>
      </th>
      <th align="center" style="color: #A0A0A0;">
	<xsl:value-of select="@svnRevision"/>
      </th>
      <td align="center" bgcolor="#E0E0E0">
	<xsl:choose>
	  <xsl:when test="product/@failed = '1'">
	    <img style="border-style: none;" src="failure.gif"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <img style="border-style: none;" src="success.gif"/>
	  </xsl:otherwise>
	</xsl:choose>
      </td>

      <td align="center">
	<xsl:apply-templates select="product[@type='source']" mode="product-cell"/>
      </td>

      <td align="center">
	<xsl:apply-templates select="product[@type='nix' and @system='i686-linux']" mode="product-cell"/>
      </td>

      <td align="center">
	<xsl:apply-templates select="product[@type='nix' and @system='powerpc-darwin']" mode="product-cell"/>
      </td>

      <xsl:for-each select="$rpm-systems">
	<td align="center">
	  <xsl:apply-templates select="$release/product[@type='rpm' and @fullName=current()] " mode="product-cell"/>
	</td>
      </xsl:for-each>

      <td align="left">
	<xsl:apply-templates select="product[@type='nodist']" mode="product-cell"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="product" mode="product-cell">
    <a href="{../@distURL}">
      <xsl:choose>
	<xsl:when test="@failed = '1'">
	  <img style="border-style: none;" src="failure.gif"/>
	</xsl:when>
	<xsl:otherwise>
	  <img style="border-style: none;" src="success.gif"/>
	</xsl:otherwise>
	</xsl:choose>
    </a>
    <xsl:apply-templates select="." mode="popup"/>
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

  <xsl:template match="release" mode="copy">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template name="latest-release-of-package">
    <xsl:param name="name"/>
    <xsl:param name="releases"/>

    <xsl:variable name="package-releases">
      <xsl:call-template name="releases-of-package">
	<xsl:with-param name="name" select="$name"/>
	<xsl:with-param name="releases" select="$releases"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy-of select="exsl:node-set($package-releases)//release[count(preceding::release) = 0]"/>
  </xsl:template>

  <xsl:template name="releases-of-package">
    <xsl:param name="name"/>
    <xsl:param name="releases"/>

    <xsl:apply-templates select="$releases[@packageName = $name]" mode="copy">
      <xsl:sort select="@date" order="descending"/>
    </xsl:apply-templates>
  </xsl:template>
</xsl:transform>
