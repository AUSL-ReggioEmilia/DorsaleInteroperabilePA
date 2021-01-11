<%@ Page Title="Unità Operative" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="UnitaOperativeLista.aspx.vb" Inherits=".UnitaOperativeLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False" />
	<table id="pannelloFiltri" runat="server" class="toolbar">
		<tr>
			<td colspan="7">
				<asp:HyperLink ID="lnkNuovo" runat="server" NavigateUrl="UnitaOperativeDettaglio.aspx"
					ToolTip="Nuova Unità Operativa"><img src="../Images/newitem.gif" alt="Nuova unità operativa" class="toolbar-img"/>Nuova unità operativa</asp:HyperLink>
			</td>
		</tr>
		<tr>
			<td>
				Azienda
			</td>
			<td>
				<asp:DropDownList ID="ddlFiltriAzienda" runat="server" Width="120px" AppendDataBoundItems="True"
					DataSourceID="odsAziende" DataTextField="Descrizione" DataValueField="Codice">
					<asp:ListItem Text="" Value="" />
				</asp:DropDownList>
			</td>
			<td>
				Codice
			</td>
			<td>
				<asp:TextBox ID="txtFiltriCodice" runat="server" Width="120px" MaxLength="16" />
			</td>
			<td>
				Descrizione
			</td>
			<td>
				<asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="120px" MaxLength="128" />
			</td>
            <td>
				Regime
			</td>
			<td>
                <asp:DropDownList ID="ddlRegimi" runat="server" Width="120px" AppendDataBoundItems="True"
                    DataSourceID="odsRegimi" DataTextField="Descrizione" DataValueField="Codice">
					<asp:ListItem Text="" Value="" />
				</asp:DropDownList>
                <asp:ObjectDataSource ID="odsRegimi" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="OrganigrammaDataSetTableAdapters.RegimiCercaTableAdapter" /> 
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
	<br />
    <asp:Label ID="lblGvLista" Visible="false" runat="server"  CssClass="Error" />
	<asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="odsLista" GridLines="Horizontal" PageSize="100"
		Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom"
		DataKeyNames="Id" CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
		PagerStyle-CssClass="Pager">
		<Columns>
			<asp:HyperLinkField DataTextField="Codice" DataNavigateUrlFormatString="UnitaOperativeDettaglio.aspx?id={0}"
				DataNavigateUrlFields="Id" HeaderText="Codice" SortExpression="Codice" ItemStyle-Width="100px" />
			<asp:BoundField DataField="CodiceAzienda" HeaderText="Codice Azienda" SortExpression="CodiceAzienda"
				ItemStyle-Width="70px" />
			<asp:CheckBoxField DataField="Attivo" HeaderText="Attiva" ReadOnly="True" SortExpression="Attivo"
				ItemStyle-Width="60px" />
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
            <asp:BoundField DataField="Regimi" HeaderText="Regimi" SortExpression="Regimi" />
		</Columns>
	</asp:GridView>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="OrganigrammaDataSetTableAdapters.UnitaOperativeTableAdapter"
		CacheDuration="120" CacheKeyDependency="CacheListaUnitaOperative" EnableCaching="True"
		OldValuesParameterFormatString="{0}">
		<SelectParameters>
			<asp:ControlParameter ControlID="txtFiltriCodice" Name="Codice" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="ddlFiltriAzienda" Name="CodiceAzienda" PropertyName="SelectedValue"
				Type="String" />
            <asp:ControlParameter ControlID="ddlRegimi" Name="CodiceRegime" PropertyName="SelectedValue"
				Type="String" />
			<asp:Parameter Name="Top" Type="Int32" DefaultValue="1000" />
		</SelectParameters>
	</asp:ObjectDataSource>
	<asp:ObjectDataSource ID="odsAziende" runat="server" OldValuesParameterFormatString="{0}"
		SelectMethod="AziendeLista" TypeName="OrganigrammaDataSetTableAdapters.AziendeListaTableAdapter"
		CacheDuration="120" CacheKeyDependency="CacheAziende" EnableCaching="True"></asp:ObjectDataSource>
</asp:Content>
