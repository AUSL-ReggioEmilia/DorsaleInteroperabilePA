<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="no" media-type="text/html"/>
	<xsl:template match="/">
    <div class="panel panel-default">
      <div class="panel-heading">
        Prenotazione
      </div>
      <div class="panel-body">
        <div class="row">
          <div class="col-sm-4">
            <div class=" form-group">
              <label class="col-sm-6">
                <strong>Azienda/Ospedale:</strong>
              </label>
              <xsl:value-of select="PrenotazioniDataSet/FevsPrenotazioneTestata/AziendaErogante"/>
            </div>
          </div>
          <div class="col-sm-4">
            <div class=" form-group">
              <label class="col-sm-6">
                <strong>Codice prenotazione:</strong>
              </label>
              <xsl:value-of select="PrenotazioniDataSet/FevsPrenotazioneTestata/NumeroNosologico"/>
            </div>
          </div>
          <div class="col-sm-4">
            <div class=" form-group">
              <label class="col-sm-6">
                <strong>Episodio:</strong>
              </label>
              <xsl:value-of select="PrenotazioniDataSet/FevsPrenotazioneTestata/TipoEpisodioDescr"/>
            </div>
          </div>
        </div>

        <div class="row">
          <div class="col-sm-4">
            <div class=" form-group">
              <label class="col-sm-6">
                <strong>Data/ora inizio:</strong>
              </label>
              <xsl:call-template name="FormatDateHourMin_IT" >
                <xsl:with-param name="ParamMyDate" select="PrenotazioniDataSet/FevsPrenotazioneTestata/DataInizioEpisodio" />
              </xsl:call-template>
            </div>
          </div>

          <div class="col-sm-4">
            <div class=" form-group">
              <label class="col-sm-6">
                <strong>Data/ora fine:</strong>
              </label>
              <xsl:call-template name="FormatDateHourMin_IT" >
                <xsl:with-param name="ParamMyDate" select="PrenotazioniDataSet/FevsPrenotazioneTestata/DataFineEpisodio" />
              </xsl:call-template>
            </div>
          </div>

          <div class="col-sm-4">
            <div class=" form-group">
              <label class="col-sm-6">
                <strong>Ultimo evento:</strong>
              </label>
              <xsl:value-of select="PrenotazioniDataSet/FevsPrenotazioneTestata/UltimoEventoDescr"/>
            </div>
          </div>
        </div>

        <div class="row">
          <div class="col-sm-12">
            <div class=" form-group">
              <label class="col-sm-2">
                <strong>Reparto:</strong>
              </label>
              <xsl:value-of select="PrenotazioniDataSet/FevsPrenotazioneTestata/RepartoRicoveroAccettazioneDescr"/>
            </div>
          </div>
        </div>

        <div class="row">
          <div class="col-sm-4">
            <div class="form-group">
              <label class="col-sm-3">
                <strong>Urgenza:</strong>
              </label>
              <xsl:value-of select="PrenotazioniDataSet/FevsPrenotazioniDettaglio[Nome='Urgenza']/Valore "/>
              <xsl:if test="count(PrenotazioniDataSet/FevsPrenotazioniDettaglio[Nome='Categoria']/Valore ) > 0 ">
                <xsl:text> </xsl:text>(<xsl:value-of select="PrenotazioniDataSet/FevsPrenotazioniDettaglio[Nome='Categoria']/Valore "/>)
              </xsl:if>
            </div>
          </div>

          <div class="col-sm-8">
            <div class="form-group">
              <label class="col-sm-3">
                <strong>Stato prenotazione:</strong>
              </label>
              <xsl:value-of select="PrenotazioniDataSet/FevsPrenotazioniDettaglio[Nome='DescStatoPrenotazione']/Valore "/>
            </div>
          </div>
        </div>

        <div class="row">
          <div class="col-sm-4">
            <div class="form-group">
              <label class="col-sm-3">
                <strong>Data fissata:</strong>
              </label>
              <xsl:call-template name="FormatDateHourMin_IT" >
                <xsl:with-param name="ParamMyDate" select="PrenotazioniDataSet/FevsPrenotazioniDettaglio[Nome='DataFissata']/Valore" />
              </xsl:call-template>
            </div>
          </div>

          <div class="col-sm-8">
            <div class="form-group">
              <label class="col-sm-3">
                <strong>Data ipotizzata:</strong>
              </label>
              <xsl:call-template name="FormatDateHourMin_IT" >
                <xsl:with-param name="ParamMyDate" select="PrenotazioniDataSet/FevsPrenotazioniDettaglio[Nome='DataIpotizzata']/Valore" />
              </xsl:call-template>
            </div>
          </div>
        </div>

        <div class="row">
          <div class="col-sm-12">
            <div class="form-group">
              <label class="col-sm-2">
                <strong>Diagnosi:</strong>
              </label>
              <xsl:value-of select="PrenotazioniDataSet/FevsPrenotazioniDettaglio[Nome='DescrizioneICD9Diagnosi']/Valore "/>
              <xsl:if test="count(PrenotazioniDataSet/FevsPrenotazioniDettaglio[Nome='CodICD9Diagnosi']/Valore) > 0 ">
                <xsl:text> </xsl:text>(<xsl:value-of select="PrenotazioniDataSet/FevsPrenotazioniDettaglio[Nome='CodICD9Diagnosi']/Valore "/>)
              </xsl:if>
            </div>
          </div>
        </div>

        <div class="row">
          <div class="col-sm-12">
            <div class="form-group">
              <label class="col-sm-2">
                <strong>Diagnosi (note):</strong>
              </label>
              <xsl:value-of select="PrenotazioniDataSet/FevsPrenotazioniDettaglio[Nome='DiagnosiTestoLibero']/Valore "/>
            </div>
          </div>
        </div>

        <div class="row">
          <div class="col-sm-12">
            <div class="form-group">
              <label class="col-sm-2">
                <strong>Intervento:</strong>
              </label>
              <xsl:value-of select="PrenotazioniDataSet/FevsPrenotazioniDettaglio[Nome='DescrizioneICD9Intervento']/Valore "/>
              <xsl:if test="count(PrenotazioniDataSet/FevsPrenotazioniDettaglio[Nome='CodiceICD9Intervento']/Valore) > 0 ">
                <xsl:text> </xsl:text>(<xsl:value-of select="PrenotazioniDataSet/FevsPrenotazioniDettaglio[Nome='CodiceICD9Intervento']/Valore "/>)
              </xsl:if>
            </div>
          </div>
        </div>

        <div class="row">
          <div class="col-sm-12">
            <div class="form-group">
              <label class="col-sm-2">
                <strong>Intervento (note):</strong>
              </label>
              <xsl:value-of select="PrenotazioniDataSet/FevsPrenotazioniDettaglio[Nome='InterventoTestoLibero']/Valore "/>
            </div>
          </div>
        </div>

        <div class="row">
          <div class="col-sm-12">
            <div class="form-group">
              <label class="col-sm-2">
                <strong>Provenienza:</strong>
              </label>
              <xsl:value-of select="PrenotazioniDataSet/FevsPrenotazioniDettaglio[Nome='DescProvenienza']/Valore "/>
            </div>
          </div>
        </div>

        <div class="row">
          <div class="col-sm-12">
            <div class="form-group">
              <label class="col-sm-2">
                <strong>Medico Responsabile:</strong>
              </label>
              <xsl:value-of select="PrenotazioniDataSet/FevsPrenotazioniDettaglio[Nome='DescMedicoResponsabile']/Valore "/>
            </div>
          </div>
        </div>

        <div class="row">
          <div class="col-sm-12">
            <a>
              <xsl:attribute name="href">
                <xsl:value-of select="PrenotazioniDataSet/FevsPrenotazioniDettaglio[Nome='UrlLinkReferti']/Valore"/>
              </xsl:attribute>
              <strong>Visualizza i referti pre ricovero</strong>
            </a>
          </div>
        </div>
      </div>
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
