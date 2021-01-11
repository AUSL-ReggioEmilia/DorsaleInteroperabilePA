<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output version="1.0" encoding="utf-8" omit-xml-declaration="yes" indent="no" media-type="text/html"/>
  <xsl:template match="/">
    <div class="form-horizontal">
      <div class="row">
      <div class="row">
        <div class="col-sm-4">
          <label runat="server" class="col-sm-6">
            <strong>Azienda/Ospedale:</strong>
          </label>
          <xsl:value-of select="RicoveriDataSet/FevsRicoveroTestata/AziendaErogante"/>
        </div>
        <div class="col-sm-4">
          <label runat="server" class="col-sm-6">
            <strong>Nosologico:</strong>
          </label>
          <xsl:value-of select="RicoveriDataSet/FevsRicoveroTestata/NumeroNosologico"/>
        </div>
        <div class="col-sm-4">
          <label runat="server" class="col-sm-6">
            <strong>Episodio:</strong>
          </label>
          <xsl:value-of select="RicoveriDataSet/FevsRicoveroTestata/TipoEpisodioDescr"/>
        </div>
      </div>
      <div class="row">
        <div class="col-sm-4">
          <label runat="server" class="col-sm-6">
            <strong>Data/ora inizio:</strong>
          </label>
          <xsl:call-template name="FormatDateHourMin_IT" >
            <xsl:with-param name="ParamMyDate" select="RicoveriDataSet/FevsRicoveroTestata/DataInizioEpisodio" />
          </xsl:call-template>
        </div>
        <div class="col-sm-4">
          <label runat="server" class="col-sm-6">
            <strong>Data/ora fine:</strong>
          </label>
          <xsl:call-template name="FormatDateHourMin_IT" >
            <xsl:with-param name="ParamMyDate" select="RicoveriDataSet/FevsRicoveroTestata/DataFineEpisodio" />
          </xsl:call-template>
        </div>
        <div class="col-sm-4">
          <label runat="server" class="col-sm-6">
            <strong>Ultimo evento:</strong>
          </label>
          <label class="text-danger">
            <xsl:value-of select="RicoveriDataSet/FevsRicoveroTestata/UltimoEventoDescr"/>
          </label>
        </div>
      </div>
      <div class="row">
        <div class="col-sm-4">
          <label runat="server" class="col-sm-6">
            <strong>Diagnosi accettazione:</strong>
          </label>
          <xsl:value-of select="RicoveriDataSet/FevsRicoveroTestata/DiagnosiEpisodio"/>
        </div>
        <!-- Solo se esiste diagnosi ICD9 visualizzo la riga -->
        <xsl:if test="count(RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='Icd9AccettazioneDescr']/Valore) > 0 ">
          <div class="col-sm-6">
            <label runat="server" class="col-sm-6">
              <strong>Diagnosi ICD9:</strong>
            </label>
            <xsl:value-of select="RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='Icd9AccettazioneDescr']/Valore "/>
            <xsl:if test="count(RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='Icd9AccettazioneCodice']/Valore) > 0 ">
              <xsl:text> </xsl:text>(<xsl:value-of select="RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='Icd9AccettazioneCodice']/Valore "/>)
            </xsl:if>
          </div>
        </xsl:if>
      </div>
      <!-- SOLO SE SONO PRESENTI LE INFO DI RICOVERO PER COERENZA DI VISUALIZZAZIONE CON I RICOVERI PRECEDENTI ALL'INTRODUZIONE DELLE INFO DI RICOVERO -->
      <xsl:if test="count(RicoveriDataSet/FevsRicoveroInfoRicovero) > 0">
        <div class="row">
          <div class="col-sm-4">
            <label runat="server" class="col-sm-6">
              <strong>Episodio di origine:</strong>
            </label>
            <xsl:value-of select="RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='NumEpisodioOriginePS']/Valore "/>
          </div>
          <div class="col-sm-4">
            <label runat="server" class="col-sm-6">
              <strong>Provenienza paziente:</strong>
            </label>
            <!-- ProvenienzaDescr + ProvenienzaCodice	-->
            <xsl:choose>
              <xsl:when test="count(RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='ProvenienzaDescr']/Valore) > 0 ">
                <xsl:value-of select="RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='ProvenienzaDescr']/Valore" />
                <xsl:if test="count(RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='ProvenienzaCodice']/Valore) > 0 ">
                  <xsl:text> </xsl:text>(<xsl:value-of select="RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='ProvenienzaCodice']/Valore"/>)
                </xsl:if>
              </xsl:when>
            </xsl:choose>
          </div>
        </div>
        <div class="row">
          <div class="col-sm-4">
            <label runat="server" class="col-sm-6">
              <strong>Tipo di ricovero:</strong>
            </label>
            <!-- TipoRicoveroDescr + TipoRicoveroCodice	-->
            <xsl:choose>
              <xsl:when test="count(RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='TipoRicoveroDescr']/Valore) > 0 ">
                <xsl:value-of select="RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='TipoRicoveroDescr']/Valore" />
                <xsl:if test="count(RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='TipoRicoveroCodice']/Valore) > 0 ">
                  <xsl:text> </xsl:text>(<xsl:value-of select="RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='TipoRicoveroCodice']/Valore"/>)
                </xsl:if>
              </xsl:when>
            </xsl:choose>
          </div>
          <!-- Solo se esiste almeno un dato di dimissione mostro la parte di dati di dimissione -->
          <xsl:if  test="count(//FevsRicoveroInfoRicovero[ contains(Nome, 'Dimissione')] ) > 0" >
            <div class="col-sm-4">
              <label runat="server" class="col-sm-6">
                <strong>Tipo di dimissione:</strong>
              </label>
              <!-- DimissioneDescr + DimissioneCodice	-->
              <xsl:choose>
                <xsl:when test="count(RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='DimissioneDescr']/Valore) > 0 ">
                  <xsl:value-of select="RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='DimissioneDescr']/Valore" />
                  <xsl:if test="count(RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='DimissioneCodice']/Valore) > 0 ">
                    <xsl:text> </xsl:text>(<xsl:value-of select="RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='DimissioneCodice']/Valore"/>)
                  </xsl:if>
                </xsl:when>
              </xsl:choose>
            </div>
            <div class="col-sm-4">
              <label runat="server" class="col-sm-6">
                <strong>Medico in dimissione:</strong>
              </label>
              <!-- MedicoDimissioneCodice	MedicoDimissioneDescr	MedicoDimissioneCodiceFiscale	-->
              <xsl:choose>
                <xsl:when test="count(RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='MedicoDimissioneDescr']/Valore) > 0 ">
                  <xsl:value-of select="RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='MedicoDimissioneDescr']/Valore" />
                  <xsl:if test="count(RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='MedicoDimissioneCodice']/Valore) > 0 ">
                    <xsl:text> </xsl:text>(<xsl:value-of select="RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='MedicoDimissioneCodice']/Valore"/>)
                  </xsl:if>
                  <xsl:if test="count(RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='MedicoDimissioneCodiceFiscale']/Valore) > 0 ">
                    <xsl:text> - </xsl:text>
                    <xsl:value-of select="RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='MedicoDimissioneCodiceFiscale']/Valore"/>
                  </xsl:if>
                </xsl:when>
              </xsl:choose>
            </div>
            <div class="col-sm-4">
              <label runat="server" class="col-sm-6">
                <strong>Reparto di dimissione:</strong>
              </label>
              <!-- RepartoDimissioneDescr + RepartoDimissioneCodice	-->
              <xsl:choose>
                <xsl:when test="count(RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='RepartoDimissioneDescr']/Valore) > 0 ">
                  <xsl:value-of select="RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='RepartoDimissioneDescr']/Valore" />
                  <xsl:if test="count(RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='RepartoDimissioneCodice']/Valore) > 0 ">
                    <xsl:text> </xsl:text>(<xsl:value-of select="RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='RepartoDimissioneCodice']/Valore"/>)
                  </xsl:if>
                </xsl:when>
              </xsl:choose>
            </div>
          </xsl:if>
          <div class="col-sm-4">
            <label runat="server" class="col-sm-6">
              <strong>Motivo del ricovero:</strong>
            </label>
            <!-- MotivoRicoveroDescr + MotivoRicoveroCodice	-->
            <xsl:choose>
              <xsl:when test="count(RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='MotivoRicoveroDescr']/Valore) > 0 ">
                <xsl:value-of select="RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='MotivoRicoveroDescr']/Valore" />
                <xsl:if test="count(RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='MotivoRicoveroCodice']/Valore) > 0 ">
                  <xsl:text> </xsl:text>(<xsl:value-of select="RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='MotivoRicoveroCodice']/Valore"/>)
                </xsl:if>
              </xsl:when>
            </xsl:choose>
          </div>
        </div>
      </xsl:if>
        <!--<div class="col-sm-4">
          <a class="btn btn-default btn-xs" >
            <xsl:attribute name="href">
              <xsl:value-of select="RicoveriDataSet/FevsRicoveroInfoRicovero[Nome='UrlLinkReferti']/Valore"/>
            </xsl:attribute>
            Visualizza tutti i referti dell'episodio
          </a>
        </div>-->
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
