<%@ Page Title="Oggetti Active Directory" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="OggettoActiveDirectoryRuoliLista.aspx.vb" Inherits=".OggettoActiveDirectoryRuoliLista" %>

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
			<td nowrap="nowrap">
				Codice Ruolo
			</td>
			<td>
				<asp:TextBox ID="txtFiltriCodice" runat="server" Width="120px" MaxLength="16"></asp:TextBox>
			</td>
			<td>
				Descrizione
			</td>
			<td>
				<asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="120px" MaxLength="128"></asp:TextBox>
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
		DataKeyNames="ID,IdRuolo" CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
		PagerStyle-CssClass="Pager">
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
			<asp:BoundField DataField="Codice" HeaderText="Codice Ruolo" SortExpression="Codice"
				ItemStyle-Width="150px" />
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
			<asp:BoundField DataField="TipoAbilitazione" HeaderText="Tipo Abilitazione" SortExpression="TipoAbilitazione" />
			<asp:BoundField DataField="GruppoAbilitante" HeaderText="Gruppo Abilitante" SortExpression="GruppoAbilitante" />
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
			<td class="Right">
				<asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="TabButton"
					ValidationGroup="none" />
			</td>
		</tr>
	</table>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="OrganigrammaDataSetTableAdapters.RuoliPerOggettoActiveDirectoryTableAdapter"
		CacheDuration="120" CacheKeyDependency="CacheOggettoActiveDirectoryRuoli" EnableCaching="True"
		OldValuesParameterFormatString="{0}" DeleteMethod="Delete" InsertMethod="Insert">
		<SelectParameters>
			<asp:QueryStringParameter DbType="Guid" Name="OggettiActiveDirectoryID" QueryStringField="Id" />
			<asp:ControlParameter ControlID="txtFiltriCodice" Name="Codice" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text"
				Type="String" />
			<asp:Parameter Name="Top" Type="Int32" ConvertEmptyStringToNull="true" DefaultValue="200" />
		</SelectParameters>
		<InsertParameters>
			<asp:Parameter DbType="Guid" Name="IdRuolo" />
			<asp:QueryStringParameter Name="IdUtente" QueryStringField="Id" DbType="Guid" />
			<asp:Parameter Name="UtenteInserimento" Type="String" />
		</InsertParameters>
		<DeleteParameters>
			<asp:Parameter DbType="Guid" Name="Id" />
		</DeleteParameters>
	</asp:ObjectDataSource>
</asp:Content>
