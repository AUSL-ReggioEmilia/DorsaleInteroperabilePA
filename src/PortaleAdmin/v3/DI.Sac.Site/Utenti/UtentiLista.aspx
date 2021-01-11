<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="UtentiLista.aspx.vb" Inherits="DI.Sac.Admin.UtentiLista" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<table id="pannelloFiltri" runat="server" class="toolbar">
		<tr>
			<td colspan="9">
				<asp:HyperLink ID="lnkAggiungiUtente" runat="server" NavigateUrl="UtentiAggiungiLista.aspx"><img src="../Images/newitem.gif" alt="Aggiungi utente Active Directory" />Aggiungi utente Active Directory</asp:HyperLink>			
				<asp:HyperLink ID="lnkAggiungiUtenteSQL" runat="server" NavigateUrl="UtentiSQLAggiungiLista.aspx"><img src="../Images/newitem.gif" alt="Aggiungi utente SQL Server" />Aggiungi utente SQL Server</asp:HyperLink>
			</td>
		</tr>
		<tr>
			<td>
				Utente
			</td>
			<td>
				<asp:TextBox ID="txtFiltriUtente" runat="server" Width="120px" MaxLength="128" />
			</td>
			<td width="100%">
				<asp:Button ID="butFiltriRicerca" runat="server" CssClass="TabButton" Text="Cerca" />
			</td>
		</tr>
		<tr>
			<td colspan="9">
				<br />
			</td>
		</tr>
	</table>
	<asp:GridView ID="gvUtenti" runat="server" AllowPaging="True" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="MainObjectDataSource" EmptyDataText="Nessun risultato!"
		GridLines="Horizontal" PageSize="100" DataKeyNames="Utente" Width="100%" PagerSettings-Position="TopAndBottom"
		CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
		PagerStyle-CssClass="Pager">
		<Columns>
			<asp:HyperLinkField DataTextField="Utente" DataNavigateUrlFormatString="~/Utenti/UtenteDettaglio.aspx?utente={0}"
				DataNavigateUrlFields="Utente" HeaderText="Utente" />
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
			<asp:BoundField DataField="Dipartimentale" HeaderText="Dipartimentale" SortExpression="Dipartimentale" />
			<asp:BoundField DataField="EmailResponsabile" HeaderText="Email Responsabile" SortExpression="EmailResponsabile" />
			<asp:TemplateField HeaderText="Disattivato">
				<ItemTemplate>
					<asp:CheckBox ID="chkDisattivato" runat="server" Checked='<%# Eval("Disattivato") %>'
						Enabled="false" /></td>
				</ItemTemplate>
			</asp:TemplateField>
		</Columns>
	</asp:GridView>
	<asp:ObjectDataSource ID="MainObjectDataSource" runat="server" SelectMethod="GetData"
		TypeName="DI.Sac.Admin.Data.UtentiDataSetTableAdapters.UtentiListaTableAdapter"
		OldValuesParameterFormatString="{0}">
		<SelectParameters>
			<asp:ControlParameter ControlID="txtFiltriUtente" Name="Utente" PropertyName="Text"
				Type="String" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
