<?xml version="1.0" encoding="UTF-8"?>
<!--
2017-06-01 - SimoneB: Sostituito l'url a TracciaAccessi (/Dwhclinico/TracciaAccessi.aspx?Url=/DwhClinico/Referti/ApreReferto.aspx&amp;NavBar=Referto&amp;IdReferto=) con il seguente url /DwhClinico/Referti/RefertiDettaglio.aspx?IdReferto=
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xsl:output version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="no" media-type="text/html"/>
  <!-- 
    PRIMA LA SP RESTITUIVA ANCHE IL CAMPO TipoRecord sempre uguale a 1
	<xsl:key name="SezioneCodice_Key" match="Table/Row[TipoRecord=1]" use="concat(SezioneCodice,SezioneDescrizione)"/>
	<xsl:key name="NumeroReferto_Key" match="Table/Row[TipoRecord=1]" use="NumeroReferto"/>
	<xsl:key name="PrestazioneCodice_Key" match="Table/Row[TipoRecord=1]" use="PrestazioneCodice"/>
	<xsl:key name="Referto_Key" match="Table/Row[TipoRecord=1]" use="IdReferto"/>
  -->
  <xsl:key name="SezioneCodice_Key" match="/ArrayOfMatricePrestazioneListaType/MatricePrestazioneListaType" use="concat(SezioneCodice,SezioneDescrizione)"/>
  <xsl:key name="NumeroReferto_Key" match="/ArrayOfMatricePrestazioneListaType/MatricePrestazioneListaType" use="NumeroReferto"/>
  <xsl:key name="PrestazioneCodice_Key" match="/ArrayOfMatricePrestazioneListaType/MatricePrestazioneListaType" use="PrestazioneCodice"/>
  <xsl:key name="Referto_Key" match="/ArrayOfMatricePrestazioneListaType/MatricePrestazioneListaType" use="IdReferto"/>

  <xsl:template match="/">
    <html>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
      <head/>
      <body>
        <xsl:for-each select="/ArrayOfMatricePrestazioneListaType/MatricePrestazioneListaType[generate-id() = generate-id(key('SezioneCodice_Key', concat(SezioneCodice,SezioneDescrizione)))]">
          <!-- Imposto un ordinamento 
					<xsl:sort  data-type="text" select="SezioneDescrizione"  ></xsl:sort>				
					<xsl:sort  data-type="text" select="SezioneCodice"  ></xsl:sort>
					-->
          <xsl:variable name="i" select="position()" />
          <xsl:variable name="SezioneCodice" select="SezioneCodice"/>
          <xsl:variable name="SezioneDescrizione" select="SezioneDescrizione"/>
          <div class="panel panel-default small">
            <div class="panel-heading">
              <a class="text-wrap btn-collapse" role="button" data-toggle="collapse" aria-expanded="false" href="#{$i}"  aria-controls="{$i}" >
                <!-- aria-expanded="false" <xsl:attribute name="colspan"><xsl:value-of select="count(key('NumeroReferto_Key', NumeroReferto)) + 1"/></xsl:attribute>-->
                <xsl:attribute name="colspan">
                  <xsl:value-of select="count(key('Referto_Key', IdReferto)) + 1"/>
                </xsl:attribute>
                <!--<xsl:text>Sezione: </xsl:text>-->
                <xsl:for-each select="SezioneDescrizione">
                  <xsl:apply-templates/>
                </xsl:for-each>
                <xsl:text> (</xsl:text>
                <xsl:for-each select="SezioneCodice">
                  <xsl:apply-templates/>
                </xsl:for-each>
                <xsl:text>)</xsl:text>
              </a>
            </div>
            <div class="table-responsive collapse in demo" id="{$i}">
              <table class="MatrixTable table table-bordered" >

                <!--<tr>
                    <td class="MatrixTitle">
                      -->
                <!--<xsl:attribute name="colspan"><xsl:value-of select="count(key('NumeroReferto_Key', NumeroReferto)) + 1"/></xsl:attribute>-->
                <!--
                      <xsl:attribute name="colspan">
                        <xsl:value-of select="count(key('Referto_Key', IdReferto)) + 1"/>
                      </xsl:attribute>
                      <xsl:text>Sezione: </xsl:text>
                      <xsl:for-each select="SezioneDescrizione">
                        <xsl:apply-templates/>
                      </xsl:for-each>
                      <xsl:text> (</xsl:text>
                      <xsl:for-each select="SezioneCodice">
                        <xsl:apply-templates/>
                      </xsl:for-each>
                      <xsl:text>)</xsl:text>
                    </td>
                  </tr>-->
                <thead>
                  <tr class="active" colspan="2">
                    <th class="MatrixCrossHeader">Prestazione\Referto</th>
                    <xsl:for-each select="/ArrayOfMatricePrestazioneListaType/MatricePrestazioneListaType[generate-id() = generate-id(key('Referto_Key', IdReferto))]">
                      <th class="MatrixHeader">
                        <a target="_top">
                          <xsl:attribute name="href">
                            <xsl:text>/Dwhclinico/TracciaAccessi.aspx?Url=/DwhClinico/Referti/ApreReferto.aspx&amp;IdReferto=</xsl:text>
                            <xsl:value-of select="IdReferto"/>
                          </xsl:attribute>

                          <!--<xsl:attribute name="href">
                            <xsl:text>/DwhClinico/Referti/RefertiDettaglio.aspx?IdReferto=</xsl:text>
                            <xsl:value-of select="IdReferto"/>
                          </xsl:attribute>-->
                          <xsl:for-each select="DataEvento">
                            <xsl:call-template name="FormatDateHour_IT">
                              <xsl:with-param name="ParamMyDate" select="."/>
                            </xsl:call-template>
                          </xsl:for-each>

                          <xsl:text> (</xsl:text>
                          <xsl:for-each select="NumeroReferto">
                            <xsl:apply-templates/>
                          </xsl:for-each>
                          <xsl:text>)</xsl:text>
                        </a>
                      </th>
                    </xsl:for-each>
                  </tr>
                </thead>
                <tbody>
                  <xsl:for-each select="/ArrayOfMatricePrestazioneListaType/MatricePrestazioneListaType[generate-id() = generate-id(key('PrestazioneCodice_Key', PrestazioneCodice))]">
                    <xsl:if test="SezioneCodice=$SezioneCodice and SezioneDescrizione=$SezioneDescrizione">
                      <xsl:variable name="Prestazione" select="PrestazioneCodice"/>
                      <tr>
                        <th class="MatrixHeader active">
                          <xsl:for-each select="PrestazioneDescrizione">
                            <xsl:apply-templates/>
                          </xsl:for-each>
                        </th>
                        <xsl:for-each select="/ArrayOfMatricePrestazioneListaType/MatricePrestazioneListaType[generate-id() = generate-id(key('Referto_Key', IdReferto))]">
                          <xsl:variable name="NumRef" select="NumeroReferto"/>
                          <td class="MatrixItem">
                            <xsl:if test="position() mod 2 = 0">
                              <xsl:attribute name="class">MatrixAlternatingItem</xsl:attribute>
                            </xsl:if>
                            <xsl:for-each select="key('Referto_Key', IdReferto)[PrestazioneCodice=$Prestazione]">
                              <xsl:for-each select="Risultato">
                                <xsl:apply-templates/>
                              </xsl:for-each>
                              <br/>
                            </xsl:for-each>
                            <xsl:if test="not(key('Referto_Key', IdReferto)[PrestazioneCodice=$Prestazione])">
                              <xsl:text>-</xsl:text>
                            </xsl:if>
                          </td>
                        </xsl:for-each>
                      </tr>
                    </xsl:if>
                  </xsl:for-each>
                </tbody>
              </table>
            </div>
          </div>
        </xsl:for-each>
      </body>
    </html>
  </xsl:template>

  <!-- FORMATTAZIONE DELLE DATE IN ITALIANO CON ORE E MINUTI -->
  <xsl:template name="FormatDateHour_IT">
    <xsl:param name="ParamMyDate"/>
    <xsl:variable name="day" select="substring($ParamMyDate, 9, 2)"/>
    <xsl:variable name="month" select="substring($ParamMyDate, 6, 2)"/>
    <xsl:variable name="year" select="substring($ParamMyDate, 1, 4)"/>
    <xsl:variable name="hour" select="substring($ParamMyDate, 12, 2)"/>
    <xsl:variable name="minutes" select="substring($ParamMyDate, 15, 2)"/>
    <xsl:value-of select="concat($day,'/', $month,'/', $year, ' ' , $hour, '.', $minutes)"/>
  </xsl:template>

</xsl:stylesheet>
