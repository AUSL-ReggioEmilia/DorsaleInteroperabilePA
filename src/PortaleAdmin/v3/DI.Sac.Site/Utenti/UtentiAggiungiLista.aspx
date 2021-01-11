<%@ Page Title="Lista Utenti" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="UtentiAggiungiLista.aspx.vb"
	Inherits=".UtentiAggiungiLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />
	<asp:Label ID="LabelTitolo" runat="server" CssClass="Title" EnableViewState="False" Text="Ricerca degli utenti Active Directory da aggiungere" />
	<table id="pannelloFiltri" runat="server" class="toolbar">
		<tr>
			<td colspan="7">
				<br />
			</td>
		</tr>
		<tr>
			<td nowrap="nowrap">
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
				<asp:Button ID="butConfermaTop" runat="server" Text="Aggiungi Selezionati" CssClass="TabButton" Style="width: 140px;"
					CommandName="Insert" />
			</td>
			<td class="Right">
				<asp:Button ID="butAnnullaTop" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="TabButton" ValidationGroup="none" />
			</td>
		</tr>
	</table>
	<asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False" DataSourceID="odsLista"
		GridLines="Horizontal" PageSize="100" Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!"
		PagerSettings-Position="TopAndBottom" DataKeyNames="Utente,Descrizione,Email" CssClass="GridYellow" HeaderStyle-CssClass="Header"
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
			<asp:BoundField DataField="Utente" HeaderText="Utente / Gruppo" SortExpression="Utente" />
			<asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome" />
			<asp:BoundField DataField="Cognome" HeaderText="Cognome" SortExpression="Cognome" />
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
			<asp:CheckBoxField DataField="Attivo" HeaderText="Attivo" SortExpression="Attivo" ItemStyle-Width="1px" />
			<asp:BoundField DataField="Email" HeaderText="Email" SortExpression="Email" />
		</Columns>
	</asp:GridView>
	<table class="table_pulsanti" width="100%">
		<tr>
			<td class="Left">
				<asp:Button ID="butConferma" runat="server" Text="Aggiungi Selezionati" CssClass="TabButton" Style="width: 140px;"
					CommandName="Insert" />
			</td>
			<td class="Right">
				<asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="TabButton" ValidationGroup="none" />
			</td>
		</tr>
	</table>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="OrganigrammaDataSetTableAdapters.OggettiActiveDirectoryTableAdapter"
		CacheDuration="120" CacheKeyDependency="CacheOggettiActiveDirectory" EnableCaching="True" OldValuesParameterFormatString="original_{0}">
		<SelectParameters>
			<asp:ControlParameter ControlID="txtFiltriUtente" Name="Utente" PropertyName="Text" Type="String" />
			<asp:Parameter Name="Tipo" Type="String" DefaultValue="Utente" />
			<asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text" Type="String" />
			<asp:Parameter Name="MembroConRuolo" Type="Boolean" DefaultValue="False" />
			<asp:Parameter Name="Top" Type="Int32" DefaultValue="200" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
