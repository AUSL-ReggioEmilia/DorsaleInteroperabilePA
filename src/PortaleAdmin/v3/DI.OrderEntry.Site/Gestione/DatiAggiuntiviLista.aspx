<%@ Page Title="Order Entry - Configurazione Ennuple" Language="vb" AutoEventWireup="false" MasterPageFile="~/OrderEntry.Master"
	CodeBehind="DatiAggiuntiviLista.aspx.vb" Inherits="DI.OrderEntry.Admin.DatiAggiuntiviLista" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder" runat="server">
	<table id="filterPanel" runat="server" class="toolbar">
		<tr>
			<td colspan="7">
				<br />
			</td>
		</tr>
		<tr>
			<td nowrap="nowrap">
				Nome:
			</td>
			<td>
				<asp:TextBox ID="txtNome" runat="server"></asp:TextBox>
			</td>
			<td nowrap="nowrap">
				Descrizione:
			</td>
			<td nowrap="nowrap">
				<asp:TextBox ID="txtDescrizione" runat="server"></asp:TextBox>
			</td>
			<td style="width: 100%">
				<asp:Button ID="CercaButton" runat="server" CssClass="Button cercaFlag" Text="Cerca" />
			</td>
		</tr>
		<tr>
			<td colspan="7">
				<br />
			</td>
		</tr>
	</table>
	<div id="toolbarAzioni" style="padding: 3px;">
		<input id="butNuovo" type="button" class="addLongButton" value="Nuovo" onclick="window.location='DatiAggiuntiviDettaglio.aspx';"
			title="Nuovo" />
	</div>
	<asp:Label ID="ErrorLabel" runat="server" CssClass="Error" Visible="false"></asp:Label>
	<br />
	<asp:GridView ID="GridViewMain" runat="server" AllowPaging="True" AllowSorting="True" CssClass="Grid" AutoGenerateColumns="False"
		DataKeyNames="Nome" DataSourceID="ObjectDataSourceMain" EnableModelValidation="True" PageSize="100" Width="500px"
		PagerSettings-Position="TopAndBottom">
		<AlternatingRowStyle CssClass="GridAlternatingItem" />
		<HeaderStyle CssClass="GridHeader" />
		<PagerStyle CssClass="GridPager" />
		<SelectedRowStyle CssClass="GridSelected" />
		<RowStyle CssClass="GridItem" />
		<Columns>
			<asp:HyperLinkField DataTextField="Nome" DataNavigateUrlFormatString="DatiAggiuntiviDettaglio.aspx?Nome={0}" DataNavigateUrlFields="Nome"
				HeaderText="Nome" SortExpression="Nome" />
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
			<asp:CheckBoxField DataField="Visibile" HeaderText="Visibile" SortExpression="Visibile" ItemStyle-Width="50px"
				ItemStyle-HorizontalAlign="Center" />
		</Columns>
	</asp:GridView>
	<asp:ObjectDataSource ID="ObjectDataSourceMain" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData"
		TypeName="DatiAggiuntiviTableAdapters.UiDatiAggiuntiviTableAdapter" DeleteMethod="Delete" InsertMethod="Insert"
		UpdateMethod="Update">
		<SelectParameters>
			<asp:ControlParameter ControlID="txtNome" Name="Nome" PropertyName="Text" Type="String" />
			<asp:ControlParameter ControlID="txtDescrizione" Name="Descrizione" PropertyName="Text" Type="String" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
