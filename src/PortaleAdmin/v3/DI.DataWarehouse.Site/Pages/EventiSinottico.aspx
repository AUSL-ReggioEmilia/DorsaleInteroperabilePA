<%@ Page Title="Sistemi" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="EventiSinottico.aspx.vb"
	Inherits=".EventiSinottico" %>

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
	<asp:GridView ID="gvLista" runat="server" DataSourceID="odsLista" AutoGenerateColumns="False" CssClass="Grid" Width="800px"
		EnableModelValidation="True" EmptyDataText="Nessun risultato!">
		<Columns>
			<asp:BoundField DataField="AziendaSistemaErogante" HeaderText="Azienda-Sistema Erogante" ItemStyle-HorizontalAlign="Left" />
			<asp:BoundField DataField="Reparto" HeaderText="Reparto" ItemStyle-HorizontalAlign="Left" />
			<asp:BoundField DataField="TIPO_A" HeaderText="A" ItemStyle-Width="50" />
			<asp:BoundField DataField="TIPO_T" HeaderText="T" ItemStyle-Width="50" />
			<asp:BoundField DataField="TIPO_D" HeaderText="D" ItemStyle-Width="50" />
			<asp:BoundField DataField="TIPO_R" HeaderText="R" ItemStyle-Width="50" />
			<asp:BoundField DataField="TIPO_IL" HeaderText="IL" ItemStyle-Width="50" />
			<asp:BoundField DataField="TIPO_ML" HeaderText="ML" ItemStyle-Width="50" />
			<asp:BoundField DataField="TIPO_DL" HeaderText="DL" ItemStyle-Width="50" />
		</Columns>
		<RowStyle CssClass="GridItem" />
		<SelectedRowStyle CssClass="GridSelected" />
		<PagerStyle CssClass="GridPager" />
		<HeaderStyle CssClass="GridHeader" />
		<FooterStyle CssClass="GridFooter" />
	</asp:GridView>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="MonitorTableAdapters.BevsEventiSinotticoTableAdapter"
		OldValuesParameterFormatString="original_{0}">
		<SelectParameters>
			<asp:Parameter Name="DataDal" Type="DateTime" />
			<asp:Parameter Name="DataAl" Type="DateTime" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
