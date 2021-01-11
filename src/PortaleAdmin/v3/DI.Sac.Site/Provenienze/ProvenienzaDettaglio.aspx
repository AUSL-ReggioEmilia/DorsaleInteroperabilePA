<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="ProvenienzaDettaglio.aspx.vb" Inherits="DI.Sac.Admin.ProvenienzaDettaglio" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<asp:FormView ID="MainFormView" runat="server" DataKeyNames="Provenienza" DataSourceID="MainObjectDataSource"
		DefaultMode="Insert" EmptyDataText="Dettaglio non disponibile!">
		<InsertItemTemplate>
			<table class="table_dettagli">				
				<tr>
					<td class="Title" colspan="2">						
							Nuova Provenienza
					</td>
				</tr>
				<tr>
					<td width="200px">
					</td>
					<td width="300px;">
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Provenienza
						<asp:RequiredFieldValidator ID="RequiredProvenienza" runat="server" ControlToValidate="txtProvenienza"
							ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore richiesto!" />'></asp:RequiredFieldValidator>
					</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtProvenienza" runat="server" Text='<%# Bind("Provenienza") %>'
							CssClass="Input16" MaxLength="16" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Descrizione
					</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtCodiceFiscale" runat="server" Text='<%# Bind("Descrizione") %>'
							CssClass="Input64" MaxLength="128" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text2">
						Email Responsabile
					</td>
					<td class="Td-Value2">
						<asp:TextBox ID="TextBox2" runat="server" Text='<%# Bind("EmailResponsabile") %>'
							CssClass="Input64" MaxLength="128" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text2">
						Fusione Automatica
					</td>
					<td class="Td-Value2">
						<asp:CheckBox ID="chkFusioneAutomatica" runat="server" Checked='<%# Bind("FusioneAutomatica") %>' />
					</td>
				</tr>
				<tr>
					<td class="Td-Text2">
						Disabilita Ricerca da WS
					</td>
					<td class="Td-Value2">
						<asp:CheckBox ID="ChkDisabilitaRicercaWS" runat="server" Checked='<%# Bind("DisabilitaRicercaWS") %>' />
					</td>
				</tr>
				<tr>
					<td class="Td-Text2">
						Solo Propri da WS
					</td>
					<td class="Td-Value2">
						<asp:CheckBox ID="ChkSoloPropriWS" runat="server" Checked='<%# Bind("SoloPropriWS") %>' />
					</td>
				</tr>
				<tr>
					<td colspan="2" class="RightFooter">
						<br />
						<asp:Button ID="InsertButton" runat="server" CssClass="TabButton" CausesValidation="True"
							CommandName="Insert" Text="Conferma" />
						<asp:Button ID="InsertCancelButton" runat="server" CssClass="TabButton" CausesValidation="False"
							CommandName="Cancel" Text="Annulla" />
					</td>
				</tr>
			</table>
		</InsertItemTemplate>
		<EditItemTemplate>
			<table class="table_dettagli">				
				<tr>
					<td class="toolbar" colspan="2">
						<p>
							Dettaglio Provenienza</p>
						Nome: <span class="LabelReadOnly">
							<%#Eval("Provenienza")%>
						</span>
					</td>
				</tr>
				<tr>
				<td style="width: 200px;">
					</td>
					<td style="width: 300px;">
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Descrizione
					</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtCodiceFiscale" runat="server" Text='<%# Bind("Descrizione") %>'
							CssClass="Input64" MaxLength="128" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text2">
						Email Responsabile
					</td>
					<td class="Td-Value2">
						<asp:TextBox ID="TextBox2" runat="server" Text='<%# Bind("EmailResponsabile") %>'
							CssClass="Input64" MaxLength="128" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text2">
						Fusione Automatica
					</td>
					<td class="Td-Value2">
						<asp:CheckBox ID="chkFusioneAutomatica" runat="server" Checked='<%# Bind("FusioneAutomatica") %>' />
					</td>
				</tr>
				<tr>
					<td class="Td-Text2">
						Disabilita Ricerca da WS
					</td>
					<td class="Td-Value2">
						<asp:CheckBox ID="ChkDisabilitaRicercaWS" runat="server" Checked='<%# Bind("DisabilitaRicercaWS") %>' />
					</td>
				</tr>
				<tr>
					<td class="Td-Text2">
						Solo Propri da WS
					</td>
					<td class="Td-Value2">
						<asp:CheckBox ID="ChkSoloPropriWS" runat="server" Checked='<%# Bind("SoloPropriWS") %>' />
					</td>
				</tr>
				<tr>
					<td colspan="2" class="RightFooter">
						<br />
						<asp:Button ID="UpdateButton" runat="server" CssClass="TabButton" CausesValidation="True"
							CommandName="Update" Text="Conferma" />
						<asp:Button ID="UpdateCancelButton" runat="server" CssClass="TabButton" CausesValidation="False"
							CommandName="Cancel" Text="Annulla" />
					</td>
				</tr>
			</table>
			<br />
			<span class="Title">Utenti</span>
			<asp:GridView ID="gvUtentiServizi" runat="server" AllowPaging="True" AllowSorting="True"
				AutoGenerateColumns="False" DataSourceID="ProvenienzeUiUtentiListaObjectDataSource"
				EmptyDataText="Nessun risultato!" GridLines="Horizontal" PageSize="20" DataKeyNames="Id"
				Width="100%" PagerSettings-Position="TopAndBottom" CssClass="GridYellow" HeaderStyle-CssClass="Header"
				PagerStyle-CssClass="Pager">
				<Columns>
					<asp:BoundField DataField="Servizio" HeaderText="Servizio" SortExpression="Servizio" />
					<asp:TemplateField HeaderText="Utente">
						<ItemTemplate>
							<a href='../Utenti/UtenteDettaglio.aspx?utente=<%#Eval("Utente")%>'>
								<%#Eval("Utente")%></a>
						</ItemTemplate>
					</asp:TemplateField>
					<asp:BoundField DataField="DescrizioneUtente" HeaderText="Desc. Utente" SortExpression="DescrizioneUtente" />
					<asp:BoundField DataField="Provenienza" HeaderText="Provenienza" SortExpression="Provenienza" />
					<asp:CheckBoxField DataField="Lettura" HeaderText="Lettura" />
					<asp:CheckBoxField DataField="Scrittura" HeaderText="Scrittura" />
					<asp:CheckBoxField DataField="Cancellazione" HeaderText="Cancellazione" />
					<asp:BoundField DataField="LivelloAttendibilita" HeaderText="Livello Attendibilità" />
					<asp:BoundField DataField="Disattivato" HeaderText="Stato" />
				</Columns>
			</asp:GridView>
		</EditItemTemplate>
	</asp:FormView>
	<asp:ObjectDataSource ID="MainObjectDataSource" runat="server" SelectMethod="GetData"
		TypeName="DI.Sac.Admin.Data.ProvenienzeDataSetTableAdapters.ProvenienzeTableAdapter"
		UpdateMethod="Update" InsertMethod="Insert" OldValuesParameterFormatString="{0}">		
		<SelectParameters>
			<asp:QueryStringParameter Name="Provenienza" QueryStringField="provenienza" Type="String" />
		</SelectParameters>
		<UpdateParameters>
			<asp:Parameter Name="Provenienza" Type="String" />
			<asp:Parameter Name="Descrizione" Type="String" />
			<asp:Parameter Name="EmailResponsabile" Type="String" />
			<asp:Parameter Name="FusioneAutomatica" Type="Boolean"></asp:Parameter>
			<asp:Parameter Name="DisabilitaRicercaWS" Type="Boolean"></asp:Parameter>
		</UpdateParameters>
		<InsertParameters>
			<asp:Parameter Name="Provenienza" Type="String" />
			<asp:Parameter Name="Descrizione" Type="String" />
			<asp:Parameter Name="EmailResponsabile" Type="String" />
			<asp:Parameter Name="FusioneAutomatica" Type="Boolean"></asp:Parameter>
			<asp:Parameter Name="DisabilitaRicercaWS" Type="Boolean"></asp:Parameter>
		</InsertParameters>
	</asp:ObjectDataSource>
	<asp:ObjectDataSource ID="ProvenienzeUiUtentiListaObjectDataSource" runat="server"
		SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.ProvenienzeDataSetTableAdapters.ProvenienzeUiUtentiListaTableAdapter"
		OldValuesParameterFormatString="original_{0}">
		<SelectParameters>
			<asp:QueryStringParameter Name="Provenienza" QueryStringField="provenienza" Type="String" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
