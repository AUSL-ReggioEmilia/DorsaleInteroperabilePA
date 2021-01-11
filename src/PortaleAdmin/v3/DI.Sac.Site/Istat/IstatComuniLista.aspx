<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="IstatComuniLista.aspx.vb" Inherits=".IstatComuniLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<table id="pannelloFiltri" class="toolbar" runat="server" >
		<tr>
			<td colspan="9">
				<asp:HyperLink ID="lnkNuovoCodice" runat="server" NavigateUrl="IstatComuniDettaglio.aspx?Codice="><img src="../Images/newitem.gif" alt="Nuovo Codice" class="toolbar-img"/>Nuovo Codice</asp:HyperLink>
			</td>
		</tr>
		<tr>
			<td>
				Codice (6 car.)
				<br />
			</td>
			<td>
				<asp:TextBox ID="txtFiltriCodice" runat="server" Width="120px" MaxLength="6"></asp:TextBox>
			</td>
			<td>
				Nome (inizia con)<br />
			</td>
			<td>
				<asp:TextBox ID="txtFiltriNome" runat="server" Width="120px" MaxLength="128"></asp:TextBox>
			</td>
			<td>
				Tipo
			</td>
			<td>
				<asp:DropDownList ID="ddlFiltriTipo" runat="server" Width="120px" AppendDataBoundItems="True">
					<asp:ListItem Value="0" Text="" Selected="True"></asp:ListItem>
					<asp:ListItem Value="1">Nazioni</asp:ListItem>
					<asp:ListItem Value="2">Comuni</asp:ListItem>
				</asp:DropDownList>
			</td>
			<td>
				Stato
			</td>
			<td>
				<asp:DropDownList ID="ddlFiltriStato" runat="server" Width="120px" AppendDataBoundItems="True">
					<asp:ListItem Value="0" Text="" Selected="True"></asp:ListItem>
					<asp:ListItem Value="1">Attivo</asp:ListItem>
					<asp:ListItem Value="2">Obsoleto</asp:ListItem>
				</asp:DropDownList>
			</td>
			<td>
			</td>
		</tr>
		<tr>
			<td>
				Provenienza
				<br />
			</td>
			<td style="width: 120px">
				<asp:DropDownList ID="ddlFiltriProvenienza" runat="server" Width="120px" DataSourceID="odsProvenienza"
					DataTextField="Provenienza" DataValueField="Provenienza" AppendDataBoundItems="True">
					<asp:ListItem Value=""></asp:ListItem>
				</asp:DropDownList>
			</td>
			<td>
				ID Provenienza
			</td>
			<td>
				<asp:TextBox ID="txtFiltriIDProvenienza" runat="server" Width="120px" MaxLength="64"></asp:TextBox>
			</td>
			<td colspan="4">
			</td>
			<td style="width: 100%;">
				<asp:Button ID="butFiltriRicerca" runat="server" CssClass="TabButton" Text="Cerca" />
			</td>
		</tr>
		<tr>
			<td>
				<br />
			</td>
		</tr>
	</table>
	<br />
    <asp:Label ID="lblGvLista" Visible="false" runat="server"  CssClass="Error" />
	<asp:GridView ID="gvIstatComuni" runat="server" AllowPaging="True" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="odsIstatComuni" GridLines="Horizontal"
		PageSize="100" DataKeyNames="Codice" Width="100%" EnableModelValidation="True"
		EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom" CssClass="GridYellow"
		HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow" PagerStyle-CssClass="Pager">
		<Columns>
			<asp:TemplateField HeaderText="" ControlStyle-Width="20">
				<ItemTemplate>
					<a href='<%# String.Format("IstatComuniDettaglio.aspx?Codice={0}", Eval("Codice")) %>'>
						<img src='../Images/view.png' alt="vai al dettaglio" title="vai al dettaglio" /></a>
				</ItemTemplate>
				<ControlStyle Width="20px" />
				<ItemStyle Width="20px" Wrap="False" />
			</asp:TemplateField>
			<asp:BoundField DataField="Tipo" HeaderText="Tipo" ReadOnly="True" SortExpression="Tipo">
				<ItemStyle Width="60px" Wrap="False" />
			</asp:BoundField>
			<asp:BoundField DataField="Codice" HeaderText="Codice" ReadOnly="True" SortExpression="Codice">
				<ItemStyle Width="60px" Wrap="False" />
			</asp:BoundField>
			<asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome" />
			<asp:BoundField DataField="Provincia" HeaderText="Provincia" SortExpression="Provincia" />
			<asp:BoundField DataField="Stato" HeaderText="Stato" SortExpression="Stato" ReadOnly="True">
				<ItemStyle Width="60px" Wrap="False" />
			</asp:BoundField>
			<asp:BoundField DataField="DataInizioValidita" HeaderText="Inizio Validità" SortExpression="DataInizioValidita"
				DataFormatString="{0:d}" HtmlEncode="False">
				<ItemStyle Wrap="False" />
			</asp:BoundField>
			<asp:BoundField DataField="DataFineValidita" HeaderText="Fine Validità" SortExpression="DataFineValidita"
				DataFormatString="{0:d}" HtmlEncode="False">
				<ItemStyle Wrap="False" />
			</asp:BoundField>
			<asp:BoundField DataField="Provenienza" HeaderText="Provenienza" SortExpression="Provenienza">
				<ItemStyle Wrap="False" />
			</asp:BoundField>
			<asp:BoundField DataField="IdProvenienza" HeaderText="Id Provenienza" SortExpression="IdProvenienza">
				<ItemStyle Wrap="False" />
			</asp:BoundField>
			<asp:BoundField DataField="DataInserimento" HeaderText="Data Inserimento" SortExpression="DataInserimento"
				DataFormatString="{0:d}" HtmlEncode="False">
				<ItemStyle Wrap="False" />
			</asp:BoundField>
		</Columns>
	</asp:GridView>
	<asp:ObjectDataSource ID="odsProvenienza" runat="server" OldValuesParameterFormatString="original_{0}"
		SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.ProvenienzeDataSetTableAdapters.ProvenienzeListaTableAdapter"
		CacheDuration="180"></asp:ObjectDataSource>
	<asp:ObjectDataSource ID="odsIstatComuni" runat="server" OldValuesParameterFormatString="original_{0}"
		SelectMethod="GetData" CacheKeyDependency="CacheIstatComuni" EnableCaching="True"
		CacheDuration="120" TypeName="DI.Sac.Admin.Data.ISTATDataSetTableAdapters.IstatComuniUiListaTableAdapter">
		<SelectParameters>
			<asp:Parameter Name="Codice" Type="String" />
			<asp:Parameter Name="Nome" Type="String" />
			<asp:Parameter Name="Tipo" Type="Byte" />
			<asp:Parameter Name="Provenienza" Type="String" />
			<asp:Parameter Name="IdProvenienza" Type="String" />
			<asp:Parameter Name="Stato" Type="Byte" />
			<asp:Parameter Name="Top" Type="Int32" DefaultValue="1000" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
