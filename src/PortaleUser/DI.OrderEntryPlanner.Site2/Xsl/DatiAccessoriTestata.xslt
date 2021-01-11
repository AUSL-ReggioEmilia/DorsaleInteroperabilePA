<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="no" media-type="text/html"/>
  <xsl:template match="/">

    <table 	class="table table-condensed table-bordered small" >
      <xsl:for-each select="Testata/DatiAggiuntivi/DatoAggiuntivo">
        <tr>
          <th>
            <xsl:value-of select="Nome"/>
          </th>
          <td>
            <xsl:value-of select="ValoreDato"/>
          </td>
        </tr>
      </xsl:for-each>
    </table>

  </xsl:template>

  <!--
		Formattazione delle date
	-->
  <xsl:template name="FormatDate_IT">
    <xsl:param name="ParamMyDate"/>
    <xsl:variable name="MyDate" select="$ParamMyDate"/>
    <xsl:choose>
      <xsl:when test="string-length($ParamMyDate) &gt; 0  ">
        <xsl:variable name="substringResult" select="substring($MyDate, 9, 2)"/>
        <xsl:variable name="concatResult" select="concat($substringResult, '/')"/>
        <xsl:variable name="substringResult1" select="substring($MyDate, 6, 2)"/>
        <xsl:variable name="concatResult1" select="concat($substringResult1, '/')"/>
        <xsl:variable name="concatResult2" select="concat($concatResult, $concatResult1)"/>
        <xsl:variable name="substringResult2" select="substring($MyDate, 1, 4)"/>
        <xsl:variable name="concatResult3" select="concat($concatResult2, $substringResult2)"/>
        <xsl:value-of select="$concatResult3"/>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
