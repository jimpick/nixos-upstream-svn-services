<?xml version="1.0"?>

<xsl:transform
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:set="http://exslt.org/sets"
  extension-element-prefixes="set">

  <xsl:output method="html" indent="yes"/>

  <xsl:template match="log">
    <html>
      <head>
        <title>Subversion Log</title>
      </head>
      <body>
        <xsl:apply-templates select="." mode="year">
          <xsl:with-param name="year" select="2004"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="." mode="year">
          <xsl:with-param name="year" select="2003"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="." mode="year">
          <xsl:with-param name="year" select="2002"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="." mode="year">
          <xsl:with-param name="year" select="2001"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="." mode="year">
          <xsl:with-param name="year" select="2000"/>
        </xsl:apply-templates>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="log" mode="year">
    <xsl:param name="year"/>

    <h2><xsl:value-of select="$year"/></h2>

    <xsl:variable
       name="logentries"
     select="logentry[substring(date/text(), 1, 4) = $year]"/>

    <p>
      <b>Number of commits: </b>
      <xsl:value-of select="count($logentries)"/>
    </p>

    <ul>
      <li>
        <xsl:call-template name="month">
          <xsl:with-param name="logentries" select="$logentries[substring(date/text(), 6, 2) = '12']"/>
          <xsl:with-param name="nr" select="12"/>
          <xsl:with-param name="month" select="'December'"/>
          <xsl:with-param name="year" select="$year"/>
        </xsl:call-template>
      </li>

      <li>
        <xsl:call-template name="month">
          <xsl:with-param name="logentries" select="$logentries[substring(date/text(), 6, 2) = '11']"/>
          <xsl:with-param name="nr" select="11"/>
          <xsl:with-param name="month" select="'November'"/>
          <xsl:with-param name="year" select="$year"/>
        </xsl:call-template>
      </li>

      <li>
        <xsl:call-template name="month">
          <xsl:with-param name="logentries" select="$logentries[substring(date/text(), 6, 2) = '10']"/>
          <xsl:with-param name="nr" select="10"/>
          <xsl:with-param name="month" select="'October'"/>
          <xsl:with-param name="year" select="$year"/>
        </xsl:call-template>
      </li>

      <li>
        <xsl:call-template name="month">
          <xsl:with-param name="logentries" select="$logentries[substring(date/text(), 6, 2) = '09']"/>
          <xsl:with-param name="nr" select="'09'"/>
          <xsl:with-param name="month" select="'September'"/>
          <xsl:with-param name="year" select="$year"/>
        </xsl:call-template>
      </li>

      <li>
        <xsl:call-template name="month">
          <xsl:with-param name="logentries" select="$logentries[substring(date/text(), 6, 2) = '08']"/>
          <xsl:with-param name="nr" select="'08'"/>
          <xsl:with-param name="month" select="'August'"/>
          <xsl:with-param name="year" select="$year"/>
        </xsl:call-template>
      </li>

      <li>
        <xsl:call-template name="month">
          <xsl:with-param name="logentries" select="$logentries[substring(date/text(), 6, 2) = '07']"/>
          <xsl:with-param name="nr" select="'07'"/>
          <xsl:with-param name="month" select="'July'"/>
          <xsl:with-param name="year" select="$year"/>
        </xsl:call-template>
      </li>

      <li>
        <xsl:call-template name="month">
          <xsl:with-param name="logentries" select="$logentries[substring(date/text(), 6, 2) = '06']"/>
          <xsl:with-param name="nr" select="'06'"/>
          <xsl:with-param name="month" select="'June'"/>
          <xsl:with-param name="year" select="$year"/>
        </xsl:call-template>
      </li>

      <li>
        <xsl:call-template name="month">
          <xsl:with-param name="logentries" select="$logentries[substring(date/text(), 6, 2) = '05']"/>
          <xsl:with-param name="nr" select="'05'"/>
          <xsl:with-param name="month" select="'May'"/>
          <xsl:with-param name="year" select="$year"/>
        </xsl:call-template>
      </li>

      <li>
        <xsl:call-template name="month">
          <xsl:with-param name="logentries" select="$logentries[substring(date/text(), 6, 2) = '04']"/>
          <xsl:with-param name="nr" select="'04'"/>
          <xsl:with-param name="month" select="'April'"/>
          <xsl:with-param name="year" select="$year"/>
        </xsl:call-template>
      </li>

      <li>
        <xsl:call-template name="month">
          <xsl:with-param name="logentries" select="$logentries[substring(date/text(), 6, 2) = '03']"/>
          <xsl:with-param name="nr" select="'03'"/>
          <xsl:with-param name="month" select="'March'"/>
          <xsl:with-param name="year" select="$year"/>
        </xsl:call-template>
      </li>

      <li>
        <xsl:call-template name="month">
          <xsl:with-param name="logentries" select="$logentries[substring(date/text(), 6, 2) = '02']"/>
          <xsl:with-param name="nr" select="'02'"/>
          <xsl:with-param name="month" select="'February'"/>
          <xsl:with-param name="year" select="$year"/>
        </xsl:call-template>
      </li>

      <li>
        <xsl:call-template name="month">
          <xsl:with-param name="logentries" select="$logentries[substring(date/text(), 6, 2) = '01']"/>
          <xsl:with-param name="nr" select="'01'"/>
          <xsl:with-param name="month" select="'January'"/>
          <xsl:with-param name="year" select="$year"/>
        </xsl:call-template>
      </li>
    </ul>
  </xsl:template>

  <xsl:template name="month">
    <xsl:param name="logentries"/>
    <xsl:param name="nr"/>
    <xsl:param name="month"/>
    <xsl:param name="year"/>

    <xsl:variable name="count" select="count($logentries)"/>

    <xsl:choose>
      <xsl:when test="$count = 0">
        <xsl:value-of select="$month"/>
      </xsl:when>
      <xsl:otherwise>
        <a href="{$year}-{$nr}.html">
          <xsl:value-of select="$month"/>
        </a> (<xsl:value-of  select="$count"/> commits)
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:transform>
