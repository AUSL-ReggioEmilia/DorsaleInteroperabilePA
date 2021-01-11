<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PazienteLog.aspx.vb"
	Inherits="DI.Sac.Admin.PazienteLog" Title="Untitled Page" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<table cellpadding="1" cellspacing="0" border="0" style="width: 100%;">
		<tr>
			<td>
				<asp:GridView ID="PazientiNotificheGridView" runat="server" AllowPaging="True" AllowSorting="True"
					AutoGenerateColumns="False" DataSourceID="PazientiNotificheListaObjectDataSource"
					EmptyDataText="Nessun risultato." GridLines="Horizontal" PageSize="100" Width="100%"
					EnableModelValidation="True" PagerSettings-Position="TopAndBottom" CssClass="GridYellow"
					HeaderStyle-CssClass="Header" PagerStyle-CssClass="Pager">
					<Columns>
						<%--        <asp:BoundField DataField="Cognome" HeaderText="Cognome" SortExpression="Cognome" />
                        <asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome" />--%>
						<asp:BoundField DataField="Data" HeaderText="Data" SortExpression="Data" />
						<asp:BoundField DataField="Tipo" HeaderText="Tipo" SortExpression="Tipo" ReadOnly="True" />
						<asp:BoundField DataField="Utente" HeaderText="Utente" SortExpression="Utente" ReadOnly="True" />
						<asp:BoundField DataField="InvioData" HeaderText="Data di invio" SortExpression="InvioData" />
						<asp:BoundField DataField="InvioUtente" HeaderText="Utente invio" SortExpression="InvioUtente"
							ReadOnly="True" />
					</Columns>
				</asp:GridView>
				<asp:ObjectDataSource ID="PazientiNotificheListaObjectDataSource" runat="server"
					OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.PazientiDataSetTableAdapters.PazientiNotificheListaTableAdapter"
					CacheKeyDependency="PazientiGestioneLista" EnableCaching="True" CacheDuration="60">
					<SelectParameters>
						<asp:QueryStringParameter DbType="Guid" Name="IdPaziente" QueryStringField="IdPaziente" />
					</SelectParameters>
				</asp:ObjectDataSource>
			</td>
		</tr>
	</table>
</asp:Content>
