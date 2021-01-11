<%@ Page Title="Sistemi" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="UtentiLista.aspx.vb"
	Inherits=".UtentiLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />
	<asp:Label ID="LabelTitolo" runat="server" CssClass="Title" Text="Utenti Applicativi"/>
	<asp:Button ID="NewButton" CssClass="newbutton" runat="server" Text="Aggiungi Utente" TabIndex="10" Width="130px" />
	<fieldset class="filters">
		<legend>Ricerca</legend>
		<table id="pannelloFiltri" class="table_dettagli" runat="server">
			<tr>
				<td>
					Utente
				</td>
				<td>
					<asp:TextBox ID="txtFiltriUtente" runat="server" Width="200px" MaxLength="128" />
				</td>
				<td>
					Descrizione
				</td>
				<td>
					<asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="200px" MaxLength="128" />
				</td>
				<td width="100%">
					<asp:Button ID="butFiltriRicerca" runat="server" CssClass="Button" Text="Cerca" />
				</td>
			</tr>
		</table>
	</fieldset>
	<asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="True" DataSourceID="odsLista" AutoGenerateColumns="False"
		PageSize="100" CssClass="Grid" Width="700px" EnableModelValidation="True" EmptyDataText="Nessun risultato!" 
		PagerSettings-Position="TopAndBottom" DataKeyNames="Id">
		<Columns>
			<asp:HyperLinkField DataTextField="Utente" DataNavigateUrlFormatString="UtentiDettaglio.aspx?Id={0}"
				DataNavigateUrlFields="Id" HeaderText="Utente" SortExpression="Utente" />
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
			<asp:BoundField DataField="Ruolo" HeaderText="Ruolo" SortExpression="Ruolo" />
		</Columns>
		<RowStyle CssClass="GridItem" />
		<SelectedRowStyle CssClass="GridSelected" />
		<PagerSettings Position="TopAndBottom"></PagerSettings>
		<PagerStyle CssClass="GridPager" />
		<HeaderStyle CssClass="GridHeader" />
		<AlternatingRowStyle CssClass="GridAlternatingItem" />
		<FooterStyle CssClass="GridFooter" />
	</asp:GridView>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.UtentiTableAdapter"
		OldValuesParameterFormatString="original_{0}" EnableCaching="True" CacheKeyDependency="ListaUtenti" CacheDuration="120" CacheExpirationPolicy="Absolute">
		<SelectParameters>
			<asp:Parameter DbType="Guid" Name="Id" />
			<asp:ControlParameter ControlID="txtFiltriUtente" Name="Utente" PropertyName="Text" Type="String" />
			<asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text" Type="String" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
