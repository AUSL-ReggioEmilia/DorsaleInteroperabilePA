<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882" xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882" xmlns:rs="urn:schemas-microsoft-com:rowset" xmlns:z="#RowsetSchema" xmlns:n1="http://schemas.microsoft.com/sharepoint/soap/">
	<xsl:output version="1.0" encoding="utf-8" omit-xml-declaration="yes" indent="no" media-type="text/html"/>
	<xsl:template match="/">
		<table id="DwhInfo" class="table table-bordered table-striped table-condensed">
			<tbody>
				<xsl:choose>
					<xsl:when  test="count(/n1:listitems/rs:data/z:row) > 0 ">
						<xsl:for-each select="/n1:listitems/rs:data/z:row">
							<xsl:sort select="@ows_Modified" order="descending"/>
							<xsl:variable name="Immagine" select="@ows_Immagine" />
							<xsl:variable name="Attachments" select="@ows_Attachments" />
							<tr>
								<td style="width:28px;" class="text-center">
									<xsl:choose>
										<xsl:when test="(string-length($Immagine) > 0) and (string-length(substring-after($Immagine,',')) > 1)" >
											<img>
												<xsl:attribute name="src">
													<xsl:value-of select="substring-before($Immagine,',')"/>
												</xsl:attribute>
												<xsl:attribute name="alt">
													<xsl:value-of select="substring-after($Immagine,',')"/>
												</xsl:attribute>
												<xsl:attribute name="align">
													<xsl:value-of select="center"/>
												</xsl:attribute>
											</img>
										</xsl:when>
										<xsl:when test="(string-length($Immagine) > 0)" >
											<img>
												<xsl:attribute name="src">
													<xsl:value-of select="substring-before($Immagine,',')"/>
												</xsl:attribute>
												<xsl:attribute name="align">
													<xsl:value-of select="center"/>
												</xsl:attribute>
											</img>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>&#160;</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</td>
								<td style="width:28px;" class="text-center">
									<!-- Allegato-->
									<xsl:choose>
										<xsl:when test="$Attachments > 0" >
											<img src="..\Images\attachment.gif" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>&#160;</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</td>
								<td valign="top">
									<a target="_blank">
										<xsl:attribute name="href">
											<xsl:value-of select="@UrlDetail"/>
										</xsl:attribute>
										<xsl:value-of select="@ows_Title"/>
									</a>
								</td>
								<td class="text-center" style="width:150px;">
									<xsl:call-template name="FormatDateHour_IT">
										<xsl:with-param name="ParamMyDate" select="@ows_Modified"/>
									</xsl:call-template>
								</td>
							</tr>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<tr>
							<td align="center">
								<br></br>
								Non ci sono news!
							</td>
						</tr>
					</xsl:otherwise>
				</xsl:choose>
			</tbody>
		</table>
	</xsl:template>
	<!--
Formattazione delle date
-->
	<xsl:template name="FormatDateHour_IT">
		<xsl:param name="ParamMyDate"/>
		<xsl:variable name="MyDate" select="$ParamMyDate"/>
		<xsl:choose>
			<xsl:when test="string-length($ParamMyDate) &gt; 0  ">
				<xsl:variable name="giorno" select="substring($MyDate, 9, 2)"/>
				<xsl:variable name="mese" select="substring($MyDate, 6, 2)"/>
				<xsl:variable name="anno" select="substring($MyDate, 1, 4)"/>
				<xsl:variable name="ora" select="substring($MyDate, 12, 5)"/>
				<xsl:variable name="result" select="concat($giorno, '/', $mese, '/', $anno, ' ', $ora) "/>
				<xsl:value-of select="$result"/>
			</xsl:when>
			<xsl:otherwise>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
