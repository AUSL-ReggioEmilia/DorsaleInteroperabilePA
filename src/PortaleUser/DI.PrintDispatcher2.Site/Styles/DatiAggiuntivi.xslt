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
				<th>Speciale</th>
			</tr>
			<xsl:for-each select="TestataOrdine/DatoAggiuntivo">
				<tr class="GridItem">
					<td>
						<xsl:value-of select="Nome"/>
					</td>
					<td>
						<xsl:value-of select="Tipo"/>
					</td>
					<td>
						<xsl:value-of select="Valore"/>
					</td>
					<td>
						No
					</td>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>
	
</xsl:stylesheet>