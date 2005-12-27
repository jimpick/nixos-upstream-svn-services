<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:sets="http://exslt.org/sets"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl sets">

  <xsl:output method='html' />

  <xsl:template match="/log">

    <html>
      
      <head>
        <title>SVN Stats</title>
        <link rel="stylesheet" href="style.css" type="text/css" />
      </head>

      <body>
        <h1>Top committers</h1>

        <xsl:variable name="authors"
                      select="sets:distinct(logentry/author)" />

        <!--
        <ul>
          <xsl:for-each select="$authors">
            <xsl:sort />
            <li>
              Name: <xsl:value-of select="." />
              Commits: <xsl:value-of select="count(/log/logentry[author = current()])" />
            </li>
          </xsl:for-each>
        </ul>
        -->

        <xsl:variable name="authorsWithCount">
          <xsl:for-each select="$authors">
            <xsl:sort />
            <author xmlns="">
              <name><xsl:value-of select="." /></name>
              <count>
                <xsl:value-of select="count(/log/logentry[author = current()])" />
              </count>
              <commits>
                <xsl:for-each select="/log/logentry[author = current()]">
                  <commit>
                    <xsl:value-of select="@revision" />
                  </commit>
                </xsl:for-each>
              </commits>
            </author>
          </xsl:for-each>          
        </xsl:variable>

        <table border="1">
          <tr>
            <th>Name</th>
            <th># of commits</th>
            <th>Recent commits</th>
          </tr>

          <xsl:for-each select="exsl:node-set($authorsWithCount)/author">
            <xsl:sort select="count" data-type="number" order="descending" />
            <tr>
              <xsl:if test="position() mod 2 != 1">
                <xsl:attribute name="class">odd</xsl:attribute>
              </xsl:if>
              <td><xsl:value-of select="name" /></td>
              <td class="commitCount"><xsl:value-of select="count" /></td>
              <td class="recentCommits">
                <!-- Sort the commits for this author in descending order. -->
                <xsl:variable name="commitsSorted">
                  <xsl:for-each select="commits/commit">
                    <xsl:sort data-type="number" order="descending" />
                    <xsl:copy-of select="." />
                  </xsl:for-each>
                </xsl:variable>
                
                <!-- Take the N most recent commits. -->
                <xsl:for-each select="exsl:node-set($commitsSorted)/commit[position() &lt;= 10]">
                  <a href="https://svn.cs.uu.nl:12443/viewcvs/StrategoXT?rev={.}&amp;view=rev">
                    <xsl:value-of select="." />
                  </a>
                  <xsl:text> </xsl:text>
                </xsl:for-each>
              </td>
            </tr>
          </xsl:for-each>

        </table>

      </body>
      
    </html>

  </xsl:template>

</xsl:stylesheet>  