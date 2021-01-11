<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output version="1.0" encoding="utf-8" omit-xml-declaration="yes" indent="no" media-type="text/html"/>
  <xsl:template match="/">
    <div class="form-horizontal">
      <div class="row">
        <div class="col-sm-4">
          <label class="col-sm-6">
            <strong>Azienda/Ospedale:</strong>
          </label>
          <xsl:value-of select="EpisodioType/AziendaErogante"/>
        </div>
        <div class="col-sm-4">
          <label class="col-sm-6">
            <strong>Codice prenotazione:</strong>
          </label>
          <xsl:value-of select="EpisodioType/NumeroNosologico"/>
        </div>
        <div class="col-sm-4">
          <label class="col-sm-6">
            <strong>Episodio:</strong>
          </label>
          <xsl:value-of select="EpisodioType/TipoEpisodio/Descrizione"/>
        </div>
      </div>
      <div class="row">
        <div class="col-sm-4">
          <label class="col-sm-6">
            <strong>Data/ora inizio:</strong>
          </label>
          <xsl:call-template name="FormatDateHourMin_IT">
            <xsl:with-param name="ParamMyDate" select="EpisodioType/DataApertura"/>
          </xsl:call-template>
        </div>
        <div class="col-sm-4">
          <label class="col-sm-6">
            <strong>Data/ora fine:</strong>
          </label>
          <xsl:call-template name="FormatDateHourMin_IT">
            <xsl:with-param name="ParamMyDate" select="EpisodioType/DataConclusione"/>
          </xsl:call-template>
        </div>
        <div class="col-sm-4">
          <label class="col-sm-6">
            <strong>Ultimo evento:</strong>
          </label>
          <xsl:value-of select="EpisodioType/Stato/Descrizione"/>
        </div>
      </div>
      <div class="row">
        <div class="col-sm-12">
          <label class="col-sm-2">
            <strong>Reparto:</strong>
          </label>
          <xsl:value-of select="EpisodioType/StrutturaApertura/Descrizione"/>
        </div>
      </div>
      <!-- I dati seguenti devono essere letti dall'ultimo evento della lista degli eventi -->
      <xsl:for-each select="//EpisodioType/Eventi/EventoType">
        <!-- Posso ordinare usando il tipo text perchè le date vengono restituite nel formato yyyy-MM-ddThh:mm:ss -->
        <xsl:sort data-type="text" order="descending"/>
        <xsl:if test="position() = 1">
          <div class="row">
            <div class="col-sm-4">
              <label class="col-sm-6">
                <strong>Urgenza:</strong>
              </label>
              <xsl:value-of select="./Attributi/AttributoType[Nome='Urgenza' ]/Valore"/>
              <xsl:if test="count(./Attributi/AttributoType[Nome='Categoria']/Valore ) > 0">
                <xsl:text> </xsl:text>(<xsl:value-of select="./Attributi/AttributoType[Nome='Categoria']/Valore "/>)
              </xsl:if>
            </div>
            <div class="col-sm-4">
              <label class="col-sm-6">
                <strong>Stato prenotazione:</strong>
              </label>
              <xsl:value-of select="./Attributi/AttributoType[Nome='DescStatoPrenotazione']/Valore "/>
            </div>
          </div>
          <div class="row">
            <div class="col-sm-12">
              <label class="col-sm-2">
                <strong>Data fissata:</strong>
              </label>
              <xsl:call-template name="FormatDateHourMin_IT">
                <xsl:with-param name="ParamMyDate" select="./Attributi/AttributoType[Nome='DataFissata']/Valore"/>
              </xsl:call-template>
            </div>
            <div class="col-sm-12">
              <label class="col-sm-2">
                <strong>Data ipotizzata:</strong>
              </label>
              <xsl:call-template name="FormatDateHourMin_IT">
                <xsl:with-param name="ParamMyDate" select="./Attributi/AttributoType[Nome='DataIpotizzata']/Valore"/>
              </xsl:call-template>
            </div>
          </div>
          <div class="row">
            <div class="col-sm-12">
              <label class="col-sm-2">
                <strong>Diagnosi:</strong>
              </label>
              <xsl:value-of select="./Attributi/AttributoType[Nome='DescrizioneICD9Diagnosi']/Valore "/>
              <xsl:if test="count(./Attributi/AttributoType[Nome='CodICD9Diagnosi']/Valore) > 0 ">
                <xsl:text> </xsl:text>(<xsl:value-of select="./Attributi/AttributoType[Nome='CodICD9Diagnosi']/Valore "/>)
              </xsl:if>
            </div>
          </div>
          <div class="row">
            <div class="col-sm-12">
              <label class="col-sm-2">
                <strong>Diagnosi (note):</strong>
              </label>
              <xsl:value-of select="./Attributi/AttributoType[Nome='DiagnosiTestoLibero']/Valore "/>
            </div>
          </div>
          <div class="row">
            <div class="col-sm-12">
              <label class="col-sm-2">
                <strong>Intervento:</strong>
              </label>
              <xsl:value-of select="./Attributi/AttributoType[Nome='DescrizioneICD9Intervento']/Valore "/>
              <xsl:if test="count(./Attributi/AttributoType[Nome='CodiceICD9Intervento']/Valore) > 0 ">
                <xsl:text> </xsl:text>(<xsl:value-of select="./Attributi/AttributoType[Nome='CodiceICD9Intervento']/Valore "/>)
              </xsl:if>
            </div>
          </div>
          <div class="row">
            <div class="col-sm-12">
              <label class="col-sm-2">
                <strong>Intervento (note):</strong>
              </label>
              <xsl:value-of select="./Attributi/AttributoType[Nome='InterventoTestoLibero']/Valore "/>
            </div>
          </div>
          <div class="row">
            <div class="col-sm-12">
              <label class="col-sm-2">
                <strong>Provenienza:</strong>
              </label>
              <xsl:value-of select="./Attributi/AttributoType[Nome='DescProvenienza']/Valore "/>
            </div>
          </div>
          <div class="row">
            <div class="col-sm-12">
              <label class="col-sm-2">
                <strong>Medico Responsabile:</strong>
              </label>
              <xsl:value-of select="./Attributi/AttributoType[Nome='DescMedicoResponsabile']/Valore "/>
            </div>
          </div>
        </xsl:if>
      </xsl:for-each>
    </div>
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
  <!--
Formattazione delle date + ora min sec
-->
  <xsl:template name="FormatDateHourMinSec_IT">
    <xsl:param name="ParamMyDate"/>
    <xsl:variable name="MyDate" select="$ParamMyDate"/>
    <xsl:choose>
      <xsl:when test="string-length($ParamMyDate) &gt; 0  ">
        <!--ricavo il giorno-->
        <xsl:variable name="DD" select="substring($MyDate, 9, 2)"/>
        <!--ricavo il mese-->
        <xsl:variable name="MM" select="substring($MyDate, 6, 2)"/>
        <!--ricavo l'anno -->
        <xsl:variable name="YYYY" select="substring($MyDate, 1, 4)"/>
        <!--ricavo hh:mm:ss-->
        <xsl:variable name="hh_mm_ss" select="substring($MyDate, 12,8)"/>
        <!-- concateno tutto -->
        <xsl:variable name="concat_ret" select="concat($DD ,'/',$MM, '/',  $YYYY, ' ' , $hh_mm_ss)"/>
        <!-- restituisco -->
        <xsl:value-of select="$concat_ret"/>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
Formattazione delle date + ora min
-->
  <xsl:template name="FormatDateHourMin_IT">
    <xsl:param name="ParamMyDate"/>
    <xsl:variable name="MyDate" select="$ParamMyDate"/>
    <xsl:choose>
      <xsl:when test="string-length($ParamMyDate) &gt; 0  ">
        <!--ricavo il giorno-->
        <xsl:variable name="DD" select="substring($MyDate, 9, 2)"/>
        <!--ricavo il mese-->
        <xsl:variable name="MM" select="substring($MyDate, 6, 2)"/>
        <!--ricavo l'anno -->
        <xsl:variable name="YYYY" select="substring($MyDate, 1, 4)"/>
        <!--ricavo hh:mm-->
        <xsl:variable name="hh_mm" select="substring($MyDate, 12,5)"/>
        <!-- concateno tutto -->
        <xsl:variable name="concat_ret" select="concat($DD ,'/',$MM, '/',  $YYYY, ' ' , $hh_mm)"/>
        <!-- restituisco -->
        <xsl:value-of select="$concat_ret"/>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
Converte true/false in Si/No
-->
  <xsl:template name="ConvertSiNo">
    <xsl:param name="ParamValue"/>
    <!-- Rendo uppercase -->
    <xsl:variable name="Value">
      <xsl:call-template name="UpperCase">
        <xsl:with-param name="ParamValue" select="string($ParamValue)"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$Value = 'TRUE' ">
        Si
      </xsl:when>
      <xsl:when test="$Value = 'FALSE' ">
        No
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$Value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
UpperCase
-->
  <xsl:template name="UpperCase">
    <xsl:param name="ParamValue"/>
    <xsl:variable name="Value" select="$ParamValue"/>
    <xsl:choose>
      <xsl:when test="string-length($Value) &gt; 0  ">
        <xsl:variable name="sUpper" select="translate($Value,'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
        <xsl:value-of select="$sUpper"/>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
