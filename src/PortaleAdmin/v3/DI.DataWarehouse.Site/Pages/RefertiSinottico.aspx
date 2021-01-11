<%@ Page Title="Sistemi" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="RefertiSinottico.aspx.vb"
	Inherits=".RefertiSinottico" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<style type="text/css">
		.Indent
		{
			padding-left: 20px !important;
		}
	</style>
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />
	<fieldset class="filters">
		<table id="pannelloFiltri" runat="server">
			<tr>
				<td>
					Periodo
				</td>
				<td>
					<asp:DropDownList ID="ddlFiltriPeriodo" runat="server" Width="120px" AutoPostBack="True">
						<asp:ListItem Text="Ultima ora" Value="1" Selected="True" />
						<asp:ListItem Text="Oggi" Value="2" />
						<asp:ListItem Text="Ultimi 7 Giorni" Value="3" />
						<asp:ListItem Text="Ultimi 30 Giorni" Value="4" />
					</asp:DropDownList>
				</td>
				<td style="padding-left: 30px;">
					Visualizzazione
				</td>
				<td>
					<asp:RadioButtonList runat="server" ID="rbtVisual" AutoPostBack="True">
						<asp:ListItem Text="Compatta" Value="Compatta" Selected="True" />
						<asp:ListItem Text="Dettagliata" Value="Dettagliata" />
					</asp:RadioButtonList>
				</td>
			</tr>
		</table>
	</fieldset>
	<asp:GridView ID="gvLista" runat="server" AllowSorting="False" DataSourceID="odsLista" AutoGenerateColumns="False"
		CssClass="Grid" Width="800px" EnableModelValidation="True" EmptyDataText="Nessun risultato!">
		<Columns>
			<asp:BoundField DataField="AziendaSistemaErogante" HeaderText="Azienda-Sistema Erogante" ItemStyle-HorizontalAlign="Left" />
			<asp:BoundField DataField="RepartoRichiedente" HeaderText="Reparto Richiedente" ItemStyle-HorizontalAlign="Left" />
			<asp:BoundField DataField="InCorso" HeaderText="In Corso" ItemStyle-Width="80" />
			<asp:BoundField DataField="Completata" HeaderText="Completata" ItemStyle-Width="80" />
			<asp:BoundField DataField="Variata" HeaderText="Variata" ItemStyle-Width="80" />
			<asp:BoundField DataField="Cancellata" HeaderText="Cancellata" ItemStyle-Width="80" />
		</Columns>
		<RowStyle CssClass="GridItem" />
		<SelectedRowStyle CssClass="GridSelected" />
		<PagerStyle CssClass="GridPager" />
		<HeaderStyle CssClass="GridHeader" />
		<FooterStyle CssClass="GridFooter" />
	</asp:GridView>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="MonitorTableAdapters.BevsRefertiSinotticoTableAdapter"
		OldValuesParameterFormatString="original_{0}">
		<SelectParameters>
			<asp:Parameter Name="DataDal" Type="DateTime" />
			<asp:Parameter Name="DataAl" Type="DateTime" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
