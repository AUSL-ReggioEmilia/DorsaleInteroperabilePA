<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PazienteMerge.aspx.vb"
	Inherits="DI.Sac.Admin.PazienteMerge" Title="Untitled Page" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<table border="0">
		<tr>
			<td>
				<asp:FormView ID="PazienteDettaglioFormView" runat="server" DataKeyNames="Id" DataSourceID="PazienteFusoDettaglioObjectDataSource"
					EmptyDataText="Dettaglio non disponibile!">
					<ItemTemplate>
						<table cellpadding="3" cellspacing="0" border="0">
							<tr>
								<td style="width: 120px;">
									<b>DA</b>
								</td>
								<td style="width: 180px;"></td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Text">Cognome
								</td>
								<td class="Td-Value">
									<asp:Label ID="lblCognome" runat="server" Text='<%# Eval("Cognome") %>' CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Text">Nome
								</td>
								<td class="Td-Value">
									<asp:Label ID="lblNome" runat="server" Text='<%# Eval("Nome") %>' CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Text">DataNascita
								</td>
								<td class="Td-Value">
									<asp:Label ID="lblDataNascita" runat="server" Text='<%# Eval("DataNascita", "{0:d}") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Text">Sesso
								</td>
								<td class="Td-Value">
									<asp:Label ID="lblSesso" runat="server" Text='<%# Eval("Sesso") %>' CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Text">CodiceFiscale
								</td>
								<td class="Td-Value">
									<asp:Label ID="lblCodiceFiscale" runat="server" Text='<%# Eval("CodiceFiscale") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>						
							<tr style="height: 30px;">
								<td class="Td-Text">Comune Residenza
								</td>
								<td class="Td-Value">
									<asp:Label ID="lblComuneResidenza" runat="server" Text='<%# Eval("ComuneResDescrizione") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Text">Provincia Residenza
								</td>
								<td class="Td-Value">
									<asp:Label ID="lblProvinciaResDescrizione" runat="server" Text='<%# Eval("ProvinciaResDescrizione") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Text">Regione Residenza
								</td>
								<td class="Td-Value">
									<asp:Label ID="lblRegioneResDescrizione" runat="server" Text='<%# Eval("RegioneResDescrizione") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Text">Stato
								</td>
								<td class="Td-Value">
									<asp:Label ID="lblDisattivato" runat="server" Text='<%# Eval("DisattivatoDescrizione") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Text">Data Cambio Stato
								</td>
								<td class="Td-Value">
									<asp:Label ID="lblDataDisattivazione" runat="server" Text='<%# Eval("DataDisattivazione") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Text2">Occultato
								</td>
								<td class="Td-Value2">
									<asp:CheckBox ID="chkOccultato" runat="server" Checked='<%# Eval("Occultato") %>'
										Enabled="false" />&nbsp;
								</td>
							</tr>
							<tr>
								<td>
									<br />
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Text_Gray">Provenienza
								</td>
								<td class="Td-Value_Gray">
									<asp:Label ID="lblProvenienza" runat="server" Text='<%# Eval("Provenienza") %>' CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Text_Gray">Id Provenienza
								</td>
								<td class="Td-Value_Gray">
									<asp:Label ID="lblIdProvenienza" runat="server" Text='<%# Eval("IdProvenienza") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Text_Gray">Livello Attendibilità
								</td>
								<td class="Td-Value_Gray">
									<asp:Label ID="lblLivelloAttendibilita" runat="server" Text='<%# Eval("LivelloAttendibilita") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Text_Gray2">Data Modifica
								</td>
								<td class="Td-Value_Gray2">
									<asp:Label ID="lblDataModifica" runat="server" Text='<%# Eval("DataModifica") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
						</table>
					</ItemTemplate>
				</asp:FormView>
				<asp:ObjectDataSource ID="PazienteFusoDettaglioObjectDataSource" runat="server" SelectMethod="GetData"
					TypeName="DI.Sac.Admin.Data.PazientiDataSetTableAdapters.PazientiGestioneTableAdapter"
					OldValuesParameterFormatString="original_{0}">
					<SelectParameters>
						<asp:QueryStringParameter Name="Id" QueryStringField="idPazienteFuso" Type="Object" />
					</SelectParameters>
				</asp:ObjectDataSource>
			</td>
			<td>
				<img src="../Images/arrow_right.gif" alt="">
			</td>
			<td>
				<asp:FormView ID="FormView1" runat="server" DataKeyNames="Id" DataSourceID="PazienteDettaglioObjectDataSource"
					EmptyDataText="Dettaglio non disponibile!">
					<ItemTemplate>
						<table cellpadding="3" cellspacing="0" border="0">
							<tr>
								<td style="width: 120px;">
									<b>A</b>
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Value">
									<asp:Label ID="lblCognome" runat="server" Text='<%# Eval("Cognome") %>' CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Value">
									<asp:Label ID="lblNome" runat="server" Text='<%# Eval("Nome") %>' CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Value">
									<asp:Label ID="lblDataNascita" runat="server" Text='<%# Eval("DataNascita", "{0:d}") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Value">
									<asp:Label ID="lblSesso" runat="server" Text='<%# Eval("Sesso") %>' CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Value">
									<asp:Label ID="lblCodiceFiscale" runat="server" Text='<%# Eval("CodiceFiscale") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>							
							<tr style="height: 30px;">
								<td class="Td-Value">
									<asp:Label ID="lblComuneResidenza" runat="server" Text='<%# Eval("ComuneResDescrizione") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Value">
									<asp:Label ID="lblProvinciaResDescrizione" runat="server" Text='<%# Eval("ProvinciaResDescrizione") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Value">
									<asp:Label ID="lblRegioneResDescrizione" runat="server" Text='<%# Eval("RegioneResDescrizione") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Value">
									<asp:Label ID="lblDisattivato" runat="server" Text='<%# Eval("DisattivatoDescrizione") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Value">
									<asp:Label ID="lblDataDisattivazione" runat="server" Text='<%# Eval("DataDisattivazione") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Value2">
									<asp:CheckBox ID="chkOccultato" runat="server" Checked='<%# Eval("Occultato") %>'
										Enabled="false" />&nbsp;
								</td>
							</tr>
							<tr>
								<td>
									<br />
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Value_Gray">
									<asp:Label ID="lblProvenienza" runat="server" Text='<%# Eval("Provenienza") %>' CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Value_Gray">
									<asp:Label ID="lblIdProvenienza" runat="server" Text='<%# Eval("IdProvenienza") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Value_Gray">
									<asp:Label ID="lblLivelloAttendibilita" runat="server" Text='<%# Eval("LivelloAttendibilita") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
							<tr style="height: 30px;">
								<td class="Td-Value_Gray2">
									<asp:Label ID="lblDataModifica" runat="server" Text='<%# Eval("DataModifica") %>'
										CssClass="LabelReadOnly" />&nbsp;
								</td>
							</tr>
						</table>
					</ItemTemplate>
				</asp:FormView>
				<asp:ObjectDataSource ID="PazienteDettaglioObjectDataSource" runat="server" SelectMethod="GetData"
					TypeName="DI.Sac.Admin.Data.PazientiDataSetTableAdapters.PazientiGestioneTableAdapter"
					OldValuesParameterFormatString="original_{0}">
					<SelectParameters>
						<asp:QueryStringParameter Name="Id" QueryStringField="idPaziente" Type="Object" />
					</SelectParameters>
				</asp:ObjectDataSource>
			</td>
		</tr>
		<tr>
			<td colspan="3">
				<br />
				Note fusione:<br />
				<asp:TextBox ID="txtNote" runat="server" Height="50px" TextMode="MultiLine" Width="100%"></asp:TextBox>
			</td>
		</tr>
		<tr>
			<td colspan="3" style="text-align: right">
				<br />
				<asp:Button ID="btnUpdate" runat="server" CssClass="TabButton" CausesValidation="True"
					Text="Conferma" />
				<asp:Button ID="btnCancel" runat="server" CssClass="TabButton" CausesValidation="False"
					Text="Annulla" />
			</td>
		</tr>
	</table>
</asp:Content>
