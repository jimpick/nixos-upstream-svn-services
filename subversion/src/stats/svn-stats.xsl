<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:sets="http://exslt.org/sets"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl sets">

  <xsl:output method='html' />

  <xsl:key name="paths" match="path" use="." />
  
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

        <xsl:variable name="authorsWithCount">
          <xsl:for-each select="$authors">
            <author xmlns="">
              <name><xsl:value-of select="." /></name>
              <count>
                <xsl:value-of select="count(/log/logentry[author = current()])" />
              </count>
              <commits>
                <xsl:for-each select="/log/logentry[author = current()]">
                  <xsl:copy-of select="." />
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
                  <xsl:for-each select="commits">
                    <xsl:sort data-type="number" order="descending" select="logentry/@revision" />
                    <xsl:copy-of select="." />
                  </xsl:for-each>
                </xsl:variable>

                <!-- Take the N most recent commits. -->
                <xsl:for-each select="exsl:node-set($commitsSorted)/commits/logentry[position() &lt;= 10]">
                  <span class="commit">
                      <span class="commitPopup">
                        <span class="commitDate"><xsl:value-of select="date" /></span>
                        <hr />
                        <pre class="commitMsg"><xsl:value-of select="msg" /></pre>
                      </span>
                      <a href="https://svn.cs.uu.nl:12443/viewcvs/StrategoXT?rev={@revision}&amp;view=rev">
                        <xsl:value-of select="@revision" />
                      </a>
                  </span>
                  <xsl:text> </xsl:text>
                </xsl:for-each>
              </td>
            </tr>
          </xsl:for-each>

        </table>


        <xsl:if test="false">
          
        <h1>Most frequently modified paths</h1>

        <xsl:variable name="pathsWithCount">
          <xsl:for-each select="//path[count(. | key('paths', .)[1]) = 1]"> 
            <path xmlns="">
              <name><xsl:value-of select="." /></name>
              <count><xsl:value-of select="count(key('paths', .))" /></count>
            </path>
          </xsl:for-each>
        </xsl:variable>
          
        <xsl:variable name="pathsWithCountSorted">
          <xsl:for-each select="exsl:node-set($pathsWithCount)/path">
            <xsl:sort select="count" data-type="number" order="descending" />
            <xsl:copy-of select="." />
          </xsl:for-each>
        </xsl:variable>

        <table border="1">
          <tr>
            <th>Path</th>
            <th># of changes</th>
          </tr>

          <xsl:for-each select="exsl:node-set($pathsWithCountSorted)/path[position() &lt; 100]">
            <tr>
              <xsl:if test="position() mod 2 != 1">
                <xsl:attribute name="class">odd</xsl:attribute>
              </xsl:if>
              <td><xsl:value-of select="name" /></td>
              <td class="commitCount"><xsl:value-of select="count" /></td>
            </tr>
          </xsl:for-each>

        </table>
        </xsl:if>
        
      </body>
      
    </html>

  </xsl:template>

</xsl:stylesheet>  