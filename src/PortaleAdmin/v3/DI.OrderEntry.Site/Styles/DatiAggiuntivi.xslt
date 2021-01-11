<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output indent="no" method="html"/>


	<!--- <TestataOrdine>
		<IDOrderEntry>958857C3-70A7-4842-BCF4-46999C2FED80</IDOrderEntry>
		<Protocollo>2011/253</Protocollo>
		<Operatore/>
		- <DatoAggiuntivo>
			<DataInserimento>2011-03-07T12:54:26</DataInserimento>
			<DataModifica>2011-03-07T12:54:26</DataModifica>
			<Nome>abcd</Nome>
			<Tipo>string</Tipo>
			<Valore>0</Valore>
		</DatoAggiuntivo>
	</TestataOrdine>-->
	<xsl:template match="/">
		<table class="Grid" style="width:100%; border:0px;">
			<tr class="GridHeader">
				<th>Nome</th>
				<th>Tipo</th>
				<th>Valore</th>
				<th>Tipo Contenuto</th>
			</tr>
			<xsl:for-each select="TestataOrdine/DatoAggiuntivo">
				<tr class="GridItem">
					<td>
						
						<xsl:value-of select="Nome"/>								
						
						<xsl:if test="Visibile = 1">
							(Visibile
							<xsl:if test="Descrizione != ''">
								, <xsl:value-of select="Descrizione"/>
							</xsl:if>)
						</xsl:if>
					</td>
					<td>
						<xsl:value-of select="Tipo"/>
					</td>
					<td>
						<xsl:choose>
							<xsl:when test="Tipo='xs:base64Binary'">
								<a href="#" target="_blank">
									<xsl:attribute name="onclick">
										<xsl:text>sendByPost('</xsl:text>
										<xsl:value-of select="Valore"/>
										<xsl:text>'); return false;</xsl:text>
									</xsl:attribute>
									<img src="../Images/pdficon.gif" alt="clicca per vedere il documento" />
								</a>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="Valore"/>
							</xsl:otherwise>
						</xsl:choose>
					</td>
					<td>
						<xsl:value-of select="TipoContenuto"/>
					</td>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>

</xsl:stylesheet>