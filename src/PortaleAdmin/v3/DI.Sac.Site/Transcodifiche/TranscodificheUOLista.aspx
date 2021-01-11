<%@ Page Title="Transcodifiche" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="TranscodificheUOLista.aspx.vb" Inherits=".TranscodificheUOLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False" />
	<table id="pannelloFiltri" runat="server" class="toolbar">
		<tr>
			<td colspan="9">
				<asp:HyperLink ID="lnkNuovo" runat="server" NavigateUrl="UnitaOperativeSeleziona.aspx"
					ToolTip="Nuova Transcodifica"><img src="../Images/newitem.gif" alt="Nuova Transcodifica" class="toolbar-img"/>Nuova Transcodifica</asp:HyperLink>
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
				Codice Transcodifica
			</td>
			<td>
				<asp:TextBox ID="txtFiltriCodTranscodifica" runat="server" Width="120px" MaxLength="128" />
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
	<br />
	<asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="odsLista" GridLines="Horizontal"
		PageSize="100" Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!"
		PagerSettings-Position="TopAndBottom"
		CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"	PagerStyle-CssClass="Pager">
		<Columns>
			<asp:HyperLinkField DataTextField="Codice" DataNavigateUrlFormatString="TranscodificheUODettaglio.aspx?id={0}"
				DataNavigateUrlFields="Id" HeaderText="Codice Unità Operativa" SortExpression="Codice" 	ItemStyle-Width="100px"/>
			<asp:BoundField DataField="CodiceAzienda" HeaderText="Codice Azienda" SortExpression="CodiceAzienda" 	ItemStyle-Width="70px"/>
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
			<asp:BoundField DataField="SistemiConcat" HeaderText="Transcodifiche" SortExpression="SistemiConcat" />
		</Columns>		
	</asp:GridView>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="OrganigrammaDataSetTableAdapters.UnitaOperativeSistemiCercaTableAdapter"
		OldValuesParameterFormatString="original_{0}">
		<SelectParameters>
			<asp:ControlParameter ControlID="txtFiltriCodice" Name="Codice" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="ddlFiltriAzienda" Name="CodiceAzienda" PropertyName="SelectedValue"
				Type="String" />
			<asp:ControlParameter ControlID="txtFiltriCodTranscodifica" 
				Name="UnitaOperativeSistemiCodice" PropertyName="Text" Type="String" />
			<asp:Parameter Name="Top" Type="Int32" DefaultValue="200" />
		</SelectParameters>
	</asp:ObjectDataSource>
	<asp:ObjectDataSource ID="odsAziende" runat="server" OldValuesParameterFormatString="{0}"
		SelectMethod="AziendeLista" TypeName="OrganigrammaDataSetTableAdapters.AziendeListaTableAdapter"
		CacheDuration="120" CacheKeyDependency="CacheAziende" EnableCaching="True"></asp:ObjectDataSource>
</asp:Content>
