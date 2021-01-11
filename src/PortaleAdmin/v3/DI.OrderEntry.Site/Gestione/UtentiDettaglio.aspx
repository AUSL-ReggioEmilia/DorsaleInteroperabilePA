<%@ Page Title="Dettaglio Ruolo" Language="vb" AutoEventWireup="false" MasterPageFile="~/SitePopup.Master" CodeBehind="UtentiDettaglio.aspx.vb"
	Inherits=".UtentiDettaglio" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />
	<asp:Label ID="LabelTitolo" runat="server" CssClass="Title" Text="Dettaglio Utente" />
	<asp:FormView ID="FormViewDettaglio" runat="server" DataKeyNames="Id" DataSourceID="odsDettagli" EmptyDataText="Dettaglio non disponibile."
		EnableModelValidation="True" DefaultMode="Edit" Width="500px">
		<InsertItemTemplate>
			<table class="table_dettagli" width="500px">
				<tr>
					<td class="Td-Text" width="200px">
						Nome Utente
					</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtNomeUtente" runat="server" Text='<%# Bind("Utente") %>' MaxLength="64" Width="100%" />
						<asp:RequiredFieldValidator runat="server" ID="ReqNome" CssClass="Error" ControlToValidate="txtNomeUtente" ErrorMessage="Campo Obbligatorio"
							Display="Dynamic" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Descrizione
					</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtDescrizione" runat="server" Text='<%# Bind("Descrizione") %>' MaxLength="128" Width="100%" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Attivo
					</td>
					<td class="Td-Value">
						<asp:CheckBox ID="chkAttivo" runat="server" Checked='<%# Bind("Attivo") %>' />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Delega
					</td>
					<td class="Td-Value">
						<asp:RadioButtonList runat="server" ID="rblDelega" SelectedValue='<%# Bind("Delega") %>'>
							<asp:ListItem Value="0" Text="No" Selected="True" />
							<asp:ListItem Value="1" Text="Può Delegare" />
							<asp:ListItem Value="2" Text="Deve Delegare" />
						</asp:RadioButtonList>
				</tr>
				<tr>
					<td class="LeftFooter">
						<asp:Button ID="butSalva" runat="server" Text="Conferma" CssClass="TabButton" CommandName="Insert" />
					</td>
					<td class="RightFooter">
						<button onclick="window.parent.commonModalDialogClose(0);" class="asp_button">
							Chiudi</button>
					</td>
				</tr>
			</table>
		</InsertItemTemplate>
		<EditItemTemplate>
			<table class="table_dettagli" width="500px">
				<tr>
					<td class="Td-Text" width="200px">
						Nome Utente
					</td>
					<td class="Td-Value">
						<asp:Literal ID="Codice" runat="server" Text='<%# Eval("NomeUtente") %>' />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Tipo
					</td>
					<td class="Td-Value">
						<asp:Literal ID="Literal2" runat="server" Text='<%# Eval("DescrizioneTipo") %>' />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Descrizione
					</td>
					<td class="Td-Value">
						<asp:Literal ID="Literal1" runat="server" Text='<%# Eval("Descrizione") %>' />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Attivo
					</td>
					<td class="Td-Value">
						<asp:CheckBox ID="chkAttivo" runat="server" Checked='<%# Bind("Attivo") %>' />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Delega
					</td>
					<td class="Td-Value">
						<asp:RadioButtonList runat="server" ID="rblDelega" SelectedValue='<%# Bind("Delega") %>'>
							<asp:ListItem Value="0" Text="No" />
							<asp:ListItem Value="1" Text="Può Delegare" />
							<asp:ListItem Value="2" Text="Deve Delegare" />
						</asp:RadioButtonList>
				</tr>
				<tr>
					<td class="LeftFooter">
						<asp:Button ID="butSalva" runat="server" Text="Conferma" CssClass="TabButton" CommandName="Update" />
					</td>
					<td class="RightFooter">
						<button onclick="window.parent.commonModalDialogClose(0);" class="asp_button">
							Chiudi</button>
					</td>
				</tr>
			</table>
		</EditItemTemplate>
	</asp:FormView>
	<asp:Label ID="LabelUtenteGruppi" runat="server" Text="Gruppi di appartenenza" class="Title" />
	<asp:GridView ID="gvUtenteGruppi" runat="server" AutoGenerateColumns="false" AllowPaging="false" AllowSorting="False"
		DataSourceID="ObjectDataSourceUtenteGruppi" CssClass="tablesorter" Width="500px" HeaderStyle-CssClass="Hidden"
		EmptyDataText="Nessuno.">
		<RowStyle Height="15px" />
		<Columns>
			<asp:BoundField DataField="Descrizione" ItemStyle-Width="100%" />
		</Columns>
	</asp:GridView>
	<asp:ObjectDataSource ID="odsDettagli" runat="server" TypeName="DI.OrderEntry.Admin.Data.UtentiTableAdapters.UiUtentiSelectTableAdapter"
		SelectMethod="GetData" UpdateMethod="Update" OldValuesParameterFormatString="{0}" DeleteMethod="Delete" InsertMethod="Insert">
		<InsertParameters>
			<asp:Parameter Name="Utente" Type="String" />
			<asp:Parameter Name="Descrizione" Type="String" />
			<asp:Parameter Name="Delega" Type="Byte" />
			<asp:Parameter Name="Attivo" Type="Boolean" />
			<asp:Parameter Name="Tipo" Type="Byte" DefaultValue="0" />
		</InsertParameters>
		<SelectParameters>
			<asp:QueryStringParameter Name="ID" QueryStringField="Id" DbType="Guid" />
			<asp:Parameter Name="CodiceDescrizione" Type="String" />
			<asp:Parameter Name="Attivo" Type="Boolean" />
			<asp:Parameter Name="Delega" Type="Int32" />
		</SelectParameters>
		<UpdateParameters>
			<asp:Parameter Name="ID" DbType="Guid" />
			<asp:Parameter Name="Attivo" Type="Boolean" />
			<asp:Parameter Name="Delega" Type="Byte" />
		</UpdateParameters>
	</asp:ObjectDataSource>
	<asp:ObjectDataSource ID="ObjectDataSourceUtenteGruppi" runat="server" SelectMethod="GetDataByIdUtente" TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiGruppiUtentiListTableAdapter">
		<SelectParameters>
			<asp:QueryStringParameter Name="IDUtente" QueryStringField="Id" DbType="Guid" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
