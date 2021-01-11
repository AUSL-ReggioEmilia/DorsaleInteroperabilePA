<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="IstatProvinceLista.aspx.vb" Inherits=".IstatProvinceLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<table id="pannelloFiltri" class="toolbar" runat="server">
		<tr>
			<td colspan="7" style="height: 21px">
				<asp:HyperLink ID="lnkNuovoCodice" runat="server" NavigateUrl="IstatProvinceDettaglio.aspx?Codice="><img src="../Images/newitem.gif" alt="Nuovo Codice" class="toolbar-img"/>Nuovo Codice</asp:HyperLink>
			</td>
		</tr>
		<tr>
			<td nowrap="nowrap">
				Codice (3 car.)
			</td>
			<td style="width: 120px">
				<asp:TextBox ID="txtFiltriCodice" runat="server" Width="120px" MaxLength="3"></asp:TextBox>
			</td>
			<td nowrap="nowrap">
				Nome (inizia con)
			</td>
			<td>
				<asp:TextBox ID="txtFiltriNome" runat="server" Width="120px" MaxLength="64"></asp:TextBox>
			</td>
			<td>
				Regione
			</td>
			<td width="20">
				<asp:DropDownList ID="ddlFiltriRegione" runat="server" Width="150px" AppendDataBoundItems="True"
					DataSourceID="odsRegioni" DataTextField="Nome" DataValueField="Codice">
					<asp:ListItem Value="" Text=""></asp:ListItem>
				</asp:DropDownList>
			</td>
			<td style="width: 100%">
				<asp:Button ID="butFiltriRicerca" runat="server" CssClass="TabButton" Text="Cerca" />
			</td>
		</tr>
		<tr>
			<td colspan="7">
				<br />
			</td>
		</tr>
	</table>
	<br />
	<asp:GridView ID="gvIstatProvince" runat="server" AllowPaging="True" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="odsIstatProvince" GridLines="Horizontal"
		PageSize="100" DataKeyNames="Codice" Width="100%" EnableModelValidation="True"
		EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom" CssClass="GridYellow"
		HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow" PagerStyle-CssClass="Pager">
		<Columns>
			<asp:TemplateField HeaderText="" ControlStyle-Width="20">
				<ItemTemplate>
					<a href='<%# String.Format("IstatProvinceDettaglio.aspx?Codice={0}", Eval("Codice")) %>'>
						<img src='../Images/view.png' alt="vai al dettaglio" title="vai al dettaglio" /></a>
				</ItemTemplate>
				<ControlStyle Width="20px" />
				<ItemStyle Width="20px" Wrap="False" />
			</asp:TemplateField>
			<asp:BoundField DataField="Codice" HeaderText="Codice" ReadOnly="True" SortExpression="Codice">
				<ItemStyle Width="60px" Wrap="False" />
			</asp:BoundField>
			<asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome">
				<ItemStyle Wrap="False" />
			</asp:BoundField>
			<asp:BoundField DataField="Sigla" HeaderText="Sigla" SortExpression="Sigla">
				<ItemStyle Width="60px" Wrap="False" />
			</asp:BoundField>
			<asp:BoundField DataField="Regione" HeaderText="Regione" SortExpression="Regione">
				<ItemStyle Wrap="False" />
			</asp:BoundField>
		</Columns>
	</asp:GridView>
	<asp:ObjectDataSource ID="odsRegioni" runat="server" OldValuesParameterFormatString="original_{0}"
		SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.ISTATDataSetTableAdapters.IstatUiComboRegioniTableAdapter"
		CacheDuration="180"></asp:ObjectDataSource>
	<asp:ObjectDataSource ID="odsIstatProvince" runat="server" OldValuesParameterFormatString="original_{0}"
		SelectMethod="GetData" CacheKeyDependency="CacheIstatProvince" EnableCaching="True"
		CacheDuration="120" TypeName="DI.Sac.Admin.Data.ISTATDataSetTableAdapters.IstatProvinceUiListaTableAdapter">
		<SelectParameters>
			<asp:Parameter Name="Codice" Type="String" />
			<asp:Parameter Name="Nome" Type="String" />
			<asp:Parameter Name="CodiceRegione" Type="String" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
