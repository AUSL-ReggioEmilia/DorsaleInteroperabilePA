<%@ Page Title="Oggetti Active Directory" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="RuoloOggettiActiveDirectoryLista.aspx.vb" Inherits=".RuoloOggettiActiveDirectoryLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<asp:Label ID="lblTitolo" runat="server" class="Title" Text=""></asp:Label>
	<table id="pannelloFiltri" runat="server" class="toolbar">
		<tr>
			<td colspan="7">
				<br />
			</td>
		</tr>
		<tr>
			<td>
				Tipo
			</td>
			<td>
				<asp:DropDownList ID="ddlFiltriTipoOggetto" runat="server" Width="120px" AppendDataBoundItems="True"
					DataTextField="Descrizione" DataValueField="Codice">
					<asp:ListItem Text="" Value="" Selected="True" />
					<asp:ListItem>Gruppo</asp:ListItem>
					<asp:ListItem>Utente</asp:ListItem>
				</asp:DropDownList>
			</td>
			<td>
				Utente
			</td>
			<td>
				<asp:TextBox ID="txtFiltriUtente" runat="server" Width="120px" MaxLength="128"></asp:TextBox>
			</td>
			<td>
				Descrizione
			</td>
			<td>
				<asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="120px" MaxLength="256"></asp:TextBox>
			</td>
			<td width="100%">
				<asp:Button ID="butFiltriRicerca" runat="server" CssClass="TabButton" Text="Cerca" />
			</td>
		</tr>
		<tr>
			<td colspan="7">
				<br />
			</td>
		</tr>
	</table>
	<table class="table_pulsanti" width="100%">
		<tr>
			<td class="Left">
				<asp:Button ID="butEliminaTop" runat="server" Text="Elimina Selezionati" CssClass="TabButton"
					CommandName="Delete" OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione degli elementi selezionati?');"
					ValidationGroup="none" Width="10em" />
				<asp:Button ID="butAggiungiTop" runat="server" Text="Aggiungi..." CssClass="TabButton"
					CommandName="Insert" />
				<asp:Button ID="butConfermaTop" runat="server" Text="Aggiungi Selezionati" CssClass="TabButton"
					Style="width: 140px;" CommandName="Insert" />
			</td>
			<td class="Right">
				<asp:Button ID="butAnnullaTop" runat="server" CommandName="Cancel" Text="Chiudi"
					CssClass="TabButton" ValidationGroup="none" />
			</td>
		</tr>
	</table>
	<asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="odsLista" GridLines="Horizontal" PageSize="100"
		Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom"
		DataKeyNames="Id,IDOggettiActiveDirectory" CssClass="GridYellow" HeaderStyle-CssClass="Header"
		AlternatingRowStyle-CssClass="AlternatingRow" PagerStyle-CssClass="Pager">
		<Columns>
			<asp:TemplateField ItemStyle-Width="30px">
				<HeaderTemplate>
					<asp:CheckBox ID="chkboxSelectAll" runat="server" AutoPostBack="true" OnCheckedChanged="chkboxSelectAll_CheckedChanged" />
				</HeaderTemplate>
				<ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
				<ItemTemplate>
					<asp:CheckBox ID="CheckBox" runat="server"></asp:CheckBox>
				</ItemTemplate>
			</asp:TemplateField>
			<asp:BoundField DataField="Tipo" HeaderText="Tipo" SortExpression="Tipo" />
			<asp:BoundField DataField="Utente" HeaderText="Utente" SortExpression="Utente" ItemStyle-Wrap="false" />
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"
				ItemStyle-Width="100%" />
		</Columns>
	</asp:GridView>
	<table class="table_pulsanti" width="100%">
		<tr>
			<td class="Left">
				<asp:Button ID="butElimina" runat="server" Text="Elimina Selezionati" CssClass="TabButton"
					CommandName="Delete" OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione degli elementi selezionati?');"
					ValidationGroup="none" Width="10em" />
				<asp:Button ID="butAggiungi" runat="server" Text="Aggiungi..." CssClass="TabButton"
					CommandName="Insert" />
				<asp:Button ID="butConferma" runat="server" Text="Aggiungi Selezionati" CssClass="TabButton"
					Style="width: 140px;" CommandName="Insert" />
			</td>
			<td class="Right" width="50%">
				<asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="TabButton"
					ValidationGroup="none" />
			</td>
		</tr>
	</table>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="OrganigrammaDataSetTableAdapters.RuoliOggettiActiveDirectoryTableAdapter"
		CacheDuration="120" CacheKeyDependency="CacheRuoliOggettiActiveDirectory" EnableCaching="True"
		OldValuesParameterFormatString="{0}" DeleteMethod="Delete" InsertMethod="Insert">
		<InsertParameters>
			<asp:Parameter Name="IdRuolo" DbType="Guid" />
			<asp:Parameter Name="IdUtente" DbType="Guid" />
			<asp:Parameter Name="UtenteInserimento" Type="String" />
		</InsertParameters>
		<SelectParameters>
			<asp:QueryStringParameter DbType="Guid" Name="IDRuolo" QueryStringField="Id" />
			<asp:ControlParameter ControlID="ddlFiltriTipoOggetto" Name="Tipo" PropertyName="SelectedValue"
				Type="String" />
			<asp:ControlParameter ControlID="txtFiltriUtente" Name="Utente" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text"
				Type="String" />
			<asp:Parameter DefaultValue="200" Name="Top" Type="Int32" />
		</SelectParameters>
		<DeleteParameters>
			<asp:Parameter DbType="Guid" Name="Id" />
		</DeleteParameters>
	</asp:ObjectDataSource>
</asp:Content>
