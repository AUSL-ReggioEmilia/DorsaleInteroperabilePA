﻿<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PazienteCercaPosCollegata.aspx.vb" Inherits=".PazienteCercaPosCollegata" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False"></asp:Label>
	<table id="MainTable" runat="server" cellpadding="1" cellspacing="0" border="0" style="width: 100%;">
		<tr>
			<td>
				<table id="pannelloFiltri" runat="server" class="toolbar">
					<tr>
						<td nowrap="nowrap">
							<asp:Label ID="lblFiltroCodicePosCollegata" runat="server" Text="Codice Posizione collegata"></asp:Label>
						</td>
						<td width="250px">
							<asp:TextBox ID="txtFiltroPosCollegata" runat="server" Width="250"></asp:TextBox>
						</td>
						<td width="100%">
							<asp:Button ID="btnRicercaButton" runat="server" CssClass="TabButton" Text="Cerca" />
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<asp:FormView ID="MainFormView" runat="server" DataKeyNames="IdPosizioneCollegata" DataSourceID="MainObjectDataSource" EmptyDataText="Dati non disponibili!"
					EnableModelValidation="True" Width="800px">
					<ItemTemplate>
						<fieldset>
							<table cellpadding="5" cellspacing="1" border="0" width="100%">
								<tr>
									<td colspan="2">
										<asp:HyperLink ID="hlGoToPosOriginale" runat="server" NavigateUrl='<%# string.format("~/Pazienti/PazienteDettaglio.aspx?Id={0}", Eval("IdSacOriginale")) %>'>Vai a posizione originale</asp:HyperLink>
									</td>
								</tr>
								<tr>
									<td colspan="2">
										<asp:HyperLink ID="hlGoToPosCollegata" runat="server" NavigateUrl='<%#String.Format("~/Pazienti/PazienteDettaglio.aspx?Id={0}", Eval("IdSacPosizioneCollegata")) %>'>Vai a posizione collegata</asp:HyperLink>
									</td>
								</tr>
								<tr>
									<td width="150px">
										Utente
									</td>
									<td>
										<asp:Label ID="lblUtente" runat="server" Text='<%# Bind("Utente") %>' CssClass="LabelReadOnly" Style="white-space: nowrap" />
									</td>
								</tr>
								<tr>
									<td width="150px">
										Data creazione
									</td>
									<td>
										<asp:Label ID="lblDataInserimento" runat="server" Text='<%# Bind("DataInserimento", "{0:g}") %>' CssClass="LabelReadOnly"
											Style="white-space: nowrap" />
									</td>
								</tr>
								<tr>
									<td width="150px" valign="top">
										Motivo anonimizzazione
									</td>
									<td>
										<asp:Label ID="txtNote" runat="server" Text='<%# Bind("Note") %>' CssClass="LabelReadOnly" Rows="7" Width="100%"
											TextMode="MultiLine" wrap />
									</td>
								</tr>
							</table>
						</fieldset>
					</ItemTemplate>
				</asp:FormView>
			</td>
		</tr>
	</table>
	<asp:ObjectDataSource ID="MainObjectDataSource" runat="server" SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.PazientiPosizioniCollegateDataSetTableAdapters.PazientiPosizioniCollegateSelectTableAdapter"
		CacheKeyDependency="CKD_MainObjectDataSource_Pos_Collegate">
		<SelectParameters>
			<asp:QueryStringParameter Name="IdPosizioneCollegata" QueryStringField="IdPosizioneCollegata" DbType="String" />
		</SelectParameters>
	</asp:ObjectDataSource>

</asp:Content>
