<%@ Page Title="ICD9" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="ICD9Lista.aspx.vb" Inherits=".ICD9Lista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False" />
	<table id="pannelloFiltri" runat="server" class="toolbar">
		<tr>
			<td colspan="9">
				<br />
			</td>
		</tr>
		<tr>
			<td>
				Tipo Codice
			</td>
			<td>
				<asp:DropDownList ID="ddlFiltriTipoCodice" runat="server" Width="120px" AppendDataBoundItems="True"
					DataSourceID="odsTipoCodice" DataTextField="Descrizione" DataValueField="Id">
					<asp:ListItem Text="" Value="" />
				</asp:DropDownList>
			</td>
			<td>
				Codice
			</td>
			<td>
				<asp:TextBox ID="txtFiltriCodice" runat="server" Width="120px" MaxLength="6" />
			</td>
			<td>
				Descrizione
			</td>
			<td>
				<asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="180px" MaxLength="200" />
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
		AutoGenerateColumns="False" DataSourceID="odsLista" GridLines="Horizontal" PageSize="100"
		Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom"
		CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
		PagerStyle-CssClass="Pager">
		<AlternatingRowStyle CssClass="AlternatingRow"></AlternatingRowStyle>
		<Columns>
			<asp:BoundField DataField="TipoCodiceDescrizione" 
				HeaderText="Tipo Codice" SortExpression="TipoCodiceDescrizione" ItemStyle-Width="100px"/>
			<asp:BoundField DataField="Codice" HeaderText="Codice"  ItemStyle-Width="100px"
				SortExpression="Codice" />
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" 
				SortExpression="Descrizione" />
		</Columns>
		<HeaderStyle CssClass="Header"></HeaderStyle>
		<PagerSettings Position="TopAndBottom"></PagerSettings>
		<PagerStyle CssClass="Pager"></PagerStyle>
	</asp:GridView>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="CodificheDataSetTableAdapters.ICD9TableAdapter"	
		CacheDuration="120" CacheKeyDependency="CacheICD9Lista" EnableCaching="True" >
		<SelectParameters>
			<asp:ControlParameter ControlID="ddlFiltriTipoCodice" Name="TipoCodice" 
				PropertyName="SelectedValue" Type="Byte" />
			<asp:ControlParameter ControlID="txtFiltriCodice" Name="Codice" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text"
				Type="String" />
			<asp:Parameter Name="Top" Type="Int32" DefaultValue="500" />
		</SelectParameters>
	</asp:ObjectDataSource>
		<asp:ObjectDataSource ID="odsTipoCodice" runat="server" 
		SelectMethod="GetData" TypeName="CodificheDataSetTableAdapters.ICD9TipoCodiceTableAdapter"
		CacheDuration="120" CacheKeyDependency="CacheICD9TipoCodice" 
		EnableCaching="True"></asp:ObjectDataSource>
</asp:Content>
