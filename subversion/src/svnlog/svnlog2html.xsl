<?xml version="1.0"?>

<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" indent="yes"/>

  <xsl:param name="year"/>
  <xsl:param name="month"/>
  <xsl:param name="title"/>
  <xsl:param name="repos"/>
  <xsl:param name="path"/>

  <xsl:template match="log">
    <html>
      <head>
        <title>
	  Subversion Log - Repository
          <xsl:value-of select="$repos"/>
	  - Path - 
          <xsl:value-of select="$path"/>
	  - 
          <xsl:value-of select="$year"/>
          <xsl:text>-</xsl:text>
          <xsl:value-of select="$month"/>
        </title>
      </head>
      <body>
        <xsl:apply-templates
            select="logentry[
                substring(date/text(), 1, 4) = $year
            and substring(date/text(), 6, 2) = $month ]"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="logentry">
    <div style="background-color: #E0E0E0;
                padding: 15px;
                margin: 15px;
                border-style: solid;
                border-width: 1px;
                border-color: black">
      <p>
        <a name="{@revision}"/>
        <img src="page_number_24.gif" align="middle"/>
        <xsl:text> </xsl:text>
        <a href="#{@revision}" title="Link to this commit">
          <xsl:value-of select="@revision"/>
        </a>
        <xsl:text> </xsl:text>
        <img src="calendar_24.gif" align="middle" style="margin-left: 15pt"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="substring(date/text(), 1, 4)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(date/text(), 6, 2)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(date/text(), 9, 2)"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="substring(date/text(), 12, 2)"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="substring(date/text(), 15, 2)"/>
        <img src="user_24.gif" align="middle" style="margin-left: 15pt"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="author/text()"/>
      </p>

      <div style="background-color: #C8C8C8;
                  padding: 5px;
                  margin: 15px;
                  margin-left: 30px;">
        <pre width="85">
          <code>
            <xsl:value-of select="msg/text()"/>
          </code>
        </pre>
      </div>

      <xsl:apply-templates select="paths"/>
    </div>
  </xsl:template>

  <xsl:template match="paths">
    <table border="0" cellspacing="5">
      <xsl:apply-templates select="path">
        <xsl:sort data-type="text" select="text()"/>
      </xsl:apply-templates>
    </table>
  </xsl:template>

  <xsl:template match="path">
    <tr>
      <td>
        <xsl:apply-templates select="." mode="action"/>
      </td>

      <td>
        <xsl:value-of select="text()"/>
      </td>

      <td>
        <a href="https://svn.cs.uu.nl:12443/repos/{$repos}{text()}"
           title="Open file">
          <img border="0" src="open_16.gif"/>
        </a>
      </td>

      <td>
        <a href="https://svn.cs.uu.nl:12443/viewcvs/{$repos}{text()}"
           title="Open file in ViewCVS">
          <img border="0" src="zoom_16.gif"/>
        </a>
      </td>

      <td>
        <xsl:if test="@action='M'">
          <xsl:variable name="rev"    select="ancestor::logentry/@revision"/>
          <xsl:variable name="prerev" select="number($rev) - 1"/>

          <a
             href="https://svn.cs.uu.nl:12443/viewcvs/{$repos}{text()}?r1={$prerev}&amp;r2={$rev}&amp;p1={text()}&amp;p2={text()}"
             title="View difference to previous revision in ViewCVS">
            <img border="0" src="window_tile_vert_16.gif"/>
          </a>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="path[@action='M']"  mode="action">
    <img src="edit_16.gif" title="Modified"/>
  </xsl:template>

  <xsl:template match="path[@action='A']"  mode="action">
    <img src="plus_16.gif" title="Added"/>
  </xsl:template>

  <xsl:template match="path[@action='D']"  mode="action">
    <img src="delete_16.gif" title="Deleted"/>
  </xsl:template>
</xsl:transform>
