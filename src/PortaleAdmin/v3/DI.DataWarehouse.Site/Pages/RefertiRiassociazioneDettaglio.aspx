<%@ Page Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeBehind="RefertiRiassociazioneDettaglio.aspx.vb"
	Inherits="DI.DataWarehouse.Admin.RefertiRiassociazioneDettaglio" Title="Riassociazione Referto" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="Server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"></asp:Label>
	<div style="width: 900px;">
		<asp:FormView ID="FormViewDettagliReferto" runat="server" Width="100%" DataSourceID="odsDettagliReferto"
			DataKeyNames="IdPaziente" EnableModelValidation="True">
			<ItemTemplate>
				<span class="Title">Referto</span>
				<table class="table_dettagli" style="width: 100%">
					<tr>
						<td style="width: 16%;" class="Td-Text">
							Id Referto:
						</td>
						<td style="width: 34%;" class="Td-Value">
							<asp:HyperLink ID="IdHyperLink" runat="server" Target="_blank" NavigateUrl='<%# GetDettaglioRefertoTestataUrl(Eval("Id")) %>'
								ToolTip="Vai al dettaglio...">
							<%# Eval("Id")%>
							</asp:HyperLink>
						</td>
						<td style="width: 16%;" class="Td-Text">
						</td>
						<td style="width: 34%;" class="Td-Value">
						</td>
					</tr>
					<tr>
						<td style="width: 16%;" class="Td-Text">
							Data Inserimento:
						</td>
						<td style="width: 34%;" class="Td-Value">
							<%# Eval("DataInserimento") %>
						</td>
						<td style="width: 16%;" class="Td-Text">
							Data Modifica:
						</td>
						<td style="width: 34%;" class="Td-Value">
							<%# Eval("DataModifica") %>
						</td>
					</tr>
					<tr>
						<td class="Td-Text">
							Numero referto:
						</td>
						<td class="Td-Value">
							<%# Eval("NumeroReferto") %>
						</td>
						<td class="Td-Text">
							Nosologico:
						</td>
						<td class="Td-Value">
							<%# Eval("NumeroNosologico") %>
						</td>
					</tr>
					<tr>
						<td class="Td-Text" nowrap="nowrap">
							Numero Prenotazione:
						</td>
						<td class="Td-Value">
							<%# Eval("NumeroPrenotazione")%>
						</td>
						<td class="Td-Text">
							Data Referto:
						</td>
						<td class="Td-Value">
							<%#Eval("DataReferto", "{0:d}")%>
						</td>
					</tr>
					<tr>
						<td class="Td-Text" nowrap="nowrap">
							Azienda erogante:
						</td>
						<td class="Td-Value">
							<%# Eval("AziendaErogante")%>
						</td>
						<td class="Td-Text" nowrap="nowrap">
							Sistema erogante:
						</td>
						<td class="Td-Value">
							<%# Eval("SistemaErogante")%>
						</td>
					</tr>
					<tr>
						<td class="Td-Text">
							Reparto:
						</td>
						<td class="Td-Value">
							<%# Eval("RepartoErogante")%>
						</td>
						<td class="Td-Text">
						</td>
						<td class="Td-Value">
						</td>
					</tr>
					<tr>
						<td colspan="4" class="Title" style="padding-left: 15px;">
							Dati Anagrafici del Referto
						</td>
					</tr>
					<tr>
						<td class="Td-Text" nowrap="nowrap">
							Id Paziente SAC
						</td>
						<td class="Td-Value" nowrap="nowrap">
							<%# Eval("IdPaziente")%>
						</td>
						<td class="Td-Text">
						</td>
						<td class="Td-Value">
						</td>
					</tr>
					<tr>
						<td class="Td-Text">
							Anagrafica
						</td>
						<td class="Td-Value">
							<%# Eval("NomeAnagraficaCentrale")%>
						</td>
						<td class="Td-Text" nowrap="nowrap">
							Codice Anagrafica
						</td>
						<td class="Td-Value">
							<%# Eval("CodiceAnagraficaCentrale")%>
						</td>
					</tr>
					<tr>
						<td class="Td-Text" nowrap="nowrap">
							Cognome:
						</td>
						<td class="Td-Value">
							<%# Eval("Cognome")%>
						</td>
						<td class="Td-Text">
							Nome:
						</td>
						<td class="Td-Value">
							<%# Eval("Nome")%>
						</td>
					</tr>
					<tr>
						<td class="Td-Text" nowrap="nowrap">
							Codice Fiscale:
						</td>
						<td class="Td-Value">
							<%# Eval("CodiceFiscale")%>
						</td>
						<td class="Td-Text" nowrap="nowrap">
							Data di Nascita:
						</td>
						<td class="Td-Value">
							<%#Eval("DataNascita", "{0:d}")%>
						</td>
					</tr>
					<tr>
						<td class="Td-Text" nowrap="nowrap">
						
						</td>
						<td class="Td-Value">
							
						</td>
						<td class="Td-Text" nowrap="nowrap">
							Luogo di Nascita:
						</td>
						<td class="Td-Value">
							<%# Eval("ComuneNascita")%>
							<%#If(Eval("ProvinciaNascita") Is DBNull.Value, "", "(" & Eval("ProvinciaNascita") & ")")%>
						</td>
					</tr>
					<tr>
						<td colspan="4" class="Title" style="padding-left: 15px;">
							Dati Anagrafici SAC Correnti
						</td>
					</tr>
					<tr>
						<td class="Td-Text">
							Anagrafica
						</td>
						<td class="Td-Value">
							<%# Eval("SACProvenienza")%>
						</td>
						<td class="Td-Text" nowrap="nowrap">
							Codice Anagrafica
						</td>
						<td class="Td-Value">
							<%# Eval("SACIdProvenienza")%>
						</td>
					</tr>
					<tr>
						<td class="Td-Text" nowrap="nowrap">
							Cognome:
						</td>
						<td class="Td-Value">
							<%# Eval("SACCognome")%>
						</td>
						<td class="Td-Text">
							Nome:
						</td>
						<td class="Td-Value">
							<%# Eval("SACNome")%>
						</td>
					</tr>
					<tr>
						<td class="Td-Text" nowrap="nowrap">
							Codice Fiscale:
						</td>
						<td class="Td-Value">
							<%#Eval("SACCodiceFiscale")%>
						</td>
						<td class="Td-Text" nowrap="nowrap">
							Data di Nascita:
						</td>
						<td class="Td-Value">
							<%#Eval("SACDataNascita", "{0:d}")%>
						</td>
					</tr>
					<tr>
						<td class="Td-Text" nowrap="nowrap">
						
						</td>
						<td class="Td-Value">
						
						</td>
						<td class="Td-Text" nowrap="nowrap">
							Luogo di Nascita:
						</td>
						<td class="Td-Value">
							<%#Eval("SACComuneNascita")%>
							<%#If(Eval("SACProvinciaNascita") Is DBNull.Value, "", "(" & Eval("SACProvinciaNascita") & ")")%>
						</td>
					</tr>
				</table>
			</ItemTemplate>
		</asp:FormView>
		<asp:FormView ID="FormViewDettagliSAC" runat="server" Width="100%" DataSourceID="odsDettagliSAC"
			EnableModelValidation="True" EmptyDataText="">
			<ItemTemplate>
				<table class="table_dettagli" style="width: 100%">
					<tr>
						<td colspan="4">
							<span class="Title" style="display: inline-block; margin-right: 30px;">Nuovi Dati
								Anagrafici SAC</span>
							<asp:Label ID="lblWarning" runat="server" CssClass="Warning">Verificare i dati anagrafici e premere Associa per eseguire la sostituzione.</asp:Label>
						</td>
					</tr>
					<tr>
						<td style="width: 16%;" class="Td-Text" nowrap="nowrap">
							Id Paziente SAC
						</td>
						<td style="width: 34%;" class="Td-Value-Alt">
							<%# Eval("Id")%>
						</td>
						<td style="width: 16%;" class="Td-Text">
						</td>
						<td style="width: 34%;" class="Td-Value-Alt">
						</td>
					</tr>
					<tr>
						<td class="Td-Text">
							Anagrafica
						</td>
						<td class="Td-Value-Alt">
							<%# Eval("Provenienza")%>
						</td>
						<td class="Td-Text" nowrap="nowrap">
							Codice Anagrafica
						</td>
						<td class="Td-Value-Alt">
							<%# Eval("IdProvenienza")%>
						</td>
					</tr>
					<tr>
						<td class="Td-Text" nowrap="nowrap">
							Cognome:
						</td>
						<td class="Td-Value-Alt">
							<%# Eval("Cognome")%>
						</td>
						<td class="Td-Text">
							Nome:
						</td>
						<td class="Td-Value-Alt">
							<%# Eval("Nome")%>
						</td>
					</tr>
					<tr>
						<td class="Td-Text" nowrap="nowrap">
							Codice Fiscale:
						</td>
						<td class="Td-Value-Alt">
							<%#Eval("CodiceFiscale")%>
						</td>
						<td class="Td-Text" nowrap="nowrap">
							Data di Nascita:
						</td>
						<td class="Td-Value-Alt">
							<%#Eval("DataNascita", "{0:d}")%>
						</td>
					</tr>
					<tr>
						<td class="Td-Text" nowrap="nowrap">
							
						</td>
						<td class="Td-Value-Alt">
							
						</td>
						<td class="Td-Text" nowrap="nowrap">
							Luogo di Nascita:
						</td>
						<td class="Td-Value-Alt">
							<%#Eval("ComuneNascitaNome")%>
							<%#If(Eval("ProvincianascitaNome") Is DBNull.Value, "", "(" & Eval("ProvincianascitaNome") & ")")%>
						</td>
					</tr>
				</table>
			</ItemTemplate>
		</asp:FormView>
		<table class="table_dettagli" style="width: 100%;">
			<tr>
				<td class="LeftFooter" style="width: 50%;">
					<asp:Button ID="butCerca" runat="server" CausesValidation="False" Text="Cerca Paziente"
						class="Button" Width="130px" />
				</td>
				<td class="RightFooter" style="width: 50%;">
					<asp:Button ID="butAssocia" runat="server" CausesValidation="False" Text="Associa"
						OnClientClick="return confirm('Confermi la riassociazione del paziente al referto?');"
						class="Button" />
					<asp:Button ID="butAnnulla" runat="server" CausesValidation="False" Text="Annulla"
						class="Button" Style="margin-left: 10px;" />
				</td>
			</tr>
		</table>
	</div>
	<asp:ObjectDataSource ID="odsDettagliReferto" runat="server" OldValuesParameterFormatString="original_{0}"
		SelectMethod="GetDataByIdReferto" TypeName="RefertiDataSetTableAdapters.RiassociazioneRefertiOttieniTableAdapter"
		UpdateMethod="Update">
		<SelectParameters>
			<asp:QueryStringParameter DbType="Guid" Name="idReferto" QueryStringField="IdReferto" />
		</SelectParameters>
		<UpdateParameters>
			<asp:QueryStringParameter DbType="Guid" Name="idReferto" QueryStringField="IdReferto" />
			<asp:QueryStringParameter DbType="Guid" Name="IdPaziente" QueryStringField="IdPaziente" />
		</UpdateParameters>
	</asp:ObjectDataSource>
	<asp:ObjectDataSource ID="odsDettagliSAC" runat="server" OldValuesParameterFormatString="original_{0}"
		SelectMethod="GetData" TypeName="RefertiDataSetTableAdapters.RiassociazioneSACPazienteTableAdapter">
		<SelectParameters>
			<asp:QueryStringParameter DbType="Guid" Name="idPaziente" QueryStringField="IdPaziente" />
			<asp:Parameter Name="IdProvenienza" Type="String" />
			<asp:Parameter Name="Provenienza" Type="String" />
			<asp:Parameter Name="Disattivato" Type="Byte" />
			<asp:Parameter Name="Cognome" Type="String" />
			<asp:Parameter Name="Nome" Type="String" />
			<asp:Parameter Name="AnnoNascita" Type="Int32" />
			<asp:Parameter Name="CodiceFiscale" Type="String" />
			<asp:Parameter Name="Top" Type="Int32" DefaultValue="1" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
