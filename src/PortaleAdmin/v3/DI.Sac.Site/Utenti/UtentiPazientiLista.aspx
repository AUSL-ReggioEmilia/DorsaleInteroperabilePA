<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="UtentiPazientiLista.aspx.vb" Inherits="DI.Sac.Admin.UtentiPazientiLista" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<table class="toolbar">
		<tr>
			<td>
				<asp:HyperLink ID="lnkNuovo" runat="server" NavigateUrl="~/Utenti/UtentePazienteDettaglio.aspx?mode=insert"><img src="../Images/newitem.gif" alt="Nuovo utente" class="toolbar-img"/>Nuovo utente</asp:HyperLink>
			</td>
		</tr>
	</table>
	<br />
	<asp:GridView ID="gvUtentiPazienti" runat="server" AllowPaging="True" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="MainObjectDataSource" EmptyDataText="Nessun risultato!"
		GridLines="Horizontal" PageSize="100" DataKeyNames="Id" Width="100%" PagerSettings-Position="TopAndBottom"
		CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
		PagerStyle-CssClass="Pager">
		<Columns>
			<asp:HyperLinkField DataTextField="Utente" DataNavigateUrlFormatString="~/Utenti/UtentePazienteDettaglio.aspx?mode=edit&id={0}"
				DataNavigateUrlFields="Id" HeaderText="Utente" SortExpression="Utente" />
			<asp:BoundField DataField="UtenteDescrizione" HeaderText="Descrizione Utente" SortExpression="UtenteDescrizione" />
			<asp:BoundField DataField="Provenienza" HeaderText="Provenienza" SortExpression="Provenienza" />
			<asp:BoundField DataField="ProvenienzaDescrizione" HeaderText="Descrizione Provenienza"
				SortExpression="ProvenienzaDescrizione" />
			<asp:BoundField DataField="LivelloAttendibilita" HeaderText="Livello Attendibilità"
				SortExpression="LivelloAttendibilita" />
			<asp:TemplateField HeaderText="Disattivato">
				<ItemTemplate>
					<asp:CheckBox ID="chkDisattivato" runat="server" Checked='<%# Eval("Disattivato") %>'
						Enabled="false" /></td>
				</ItemTemplate>
			</asp:TemplateField>
		</Columns>
	</asp:GridView>
	<asp:ObjectDataSource ID="MainObjectDataSource" runat="server" SelectMethod="GetData"
		TypeName="DI.Sac.Admin.Data.UtentiDataSetTableAdapters.UtentiPazientiListaTableAdapter"
		OldValuesParameterFormatString="original_{0}"></asp:ObjectDataSource>
</asp:Content>
