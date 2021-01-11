<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:t="http://schemas.progel.it/WCF/OE/WsTypes/1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xslFormatting="urn:xslFormatting">
	<xsl:output indent="no" method="html"/>

	<!--<StatoValidazioneType xmlns="http://schemas.progel.it/WCF/OE/WsTypes/1.1" xmlns:i=""http:=""//www.w3.org/2001/XMLSchema-instance">
	<Stato>AR</Stato>
	<Descrizione>
		Alcune dati non sono stati compilati correttamente!
	</Descrizione>
	<Righe>
		<Riga>
			<Index>1</Index>
			<IdRigaRichiedente>1</IdRigaRichiedente>
			<Stato>AR</Stato>
			<Descrizione>
				Dati accessori obbligatori non valorizzati:
				Domanda ComboBox
				Domanda ComboBox
				Domanda NumberBox
				Domanda NumberBox
				Domanda TimeBox
				Domanda TimeBox
			</Descrizione>
		</Riga>	
	</Righe>
	</StatoValidazioneType>
	-->

	<xsl:template match="/t:StatoValidazioneType">
		<div style="height:15px;">
			<xsl:value-of select="t:Descrizione"/>
		</div>
		<ul>
			<xsl:for-each select="t:Righe/t:Riga">
				<xsl:choose>
					<xsl:when test="t:Descrizione!=''">
						<li>
							<span style="font-weight:bold; border-bottom: 1px solid black; width: 100%;">
								Riga <xsl:value-of select="t:Index"/>
							</span>
							<br/>
							<xsl:value-of select="t:Descrizione"/>
						</li>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
		</ul>
	</xsl:template>
</xsl:stylesheet>
