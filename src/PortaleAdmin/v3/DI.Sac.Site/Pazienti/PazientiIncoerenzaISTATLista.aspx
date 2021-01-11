<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="PazientiIncoerenzaISTATLista.aspx.vb" Inherits=".PazientiIncoerenzaISTATLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<table id="pannelloFiltri" class="toolbar" runat="server">
	<tr>
			<td colspan="5">
				<br />
			</td>
		</tr>
		<tr>
			<td nowrap="nowrap">
				Data dal (gg/mm/aaaa)
				<br />
				<asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" ErrorMessage="Formato non valido"
					Display="Dynamic" ControlToValidate="txtFiltriDataDal" ValidationExpression="^(0?[1-9]|[12][0-9]|3[01])[/-](0?[1-9]|1[0-2])[/-](1[89][0-9]{2}|[2][0-9]{3})$"
					SetFocusOnError="True"></asp:RegularExpressionValidator>
			</td>
			<td>
				<asp:TextBox ID="txtFiltriDataDal" runat="server" Width="120px" MaxLength="10"></asp:TextBox>
			</td>
		
			<td nowrap="nowrap">
				Data al (gg/mm/aaaa)
				<br />
				<asp:RegularExpressionValidator ID="RegularExpressionValidator2" runat="server" ErrorMessage="Formato non valido"
					Display="Dynamic" ControlToValidate="txtFiltriDataAl" ValidationExpression="^(0?[1-9]|[12][0-9]|3[01])[/-](0?[1-9]|1[0-2])[/-](1[89][0-9]{2}|[2][0-9]{3})$"
					SetFocusOnError="True"></asp:RegularExpressionValidator>
			</td>
			<td>
				<asp:TextBox ID="txtFiltriDataAl" runat="server" Width="120px" MaxLength="10"></asp:TextBox>
			</td>
		</tr>
		<tr>
			<td>
				Provenienza
				<br />
			</td>
			<td>
				<asp:DropDownList ID="ddlFiltriProvenienza" runat="server" Width="120px" DataSourceID="odsProvenienza"
					DataTextField="Provenienza" DataValueField="Provenienza" AppendDataBoundItems="True">
					<asp:ListItem Value=""></asp:ListItem>
				</asp:DropDownList>
			</td>
		
			<td>
				ID Provenienza
			</td>
			<td>
				<asp:TextBox ID="txtFiltriIDProvenienza" runat="server" Width="120px"></asp:TextBox>
			</td>
		</tr>
		<tr>
			<td>
				Codice Istat
			</td>
			<td style="width: 120px">
				<asp:TextBox ID="txtFiltriCodIstat" runat="server" Width="120px" MaxLength="6"></asp:TextBox>
			
			</td>
			<td>
				Limite righe
			</td>
			<td>
				<asp:DropDownList ID="ddlFiltriTop" runat="server" Width="120px" AppendDataBoundItems="True"/>				
			</td>
			<td style="width: 100%;">
				<asp:Button ID="RicercaButton" runat="server" CssClass="TabButton" Text="Cerca" />
			</td>
		</tr>
		<tr>
			<td colspan="5">
				<br />
			</td>
		</tr>
	</table>
	<br />
	<asp:GridView ID="gvIncoerenzeIstat" runat="server" AllowPaging="True" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="odsIncoerenzeIstat" GridLines="Horizontal"
		PageSize="100" DataKeyNames="Id" Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!"
		CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
		PagerStyle-CssClass="Pager">
		<Columns>
			<asp:TemplateField HeaderText="" ControlStyle-Width="20">
				<ItemTemplate>
					<a href='<%# String.Format("PazientiIncoerenzaISTATDettaglio.aspx?id={0}", Eval("Id")) %>'>
						<img src='../Images/view.png' alt="vai al dettaglio" title="vai al dettaglio" /></a>
				</ItemTemplate>
				<ControlStyle Width="20px" />
				<ItemStyle Width="20px" Wrap="False" />
			</asp:TemplateField>
			<asp:BoundField DataField="Provenienza" HeaderText="Provenienza" SortExpression="Provenienza" />
			<asp:BoundField DataField="IdProvenienza" HeaderText="ID Provenienza" SortExpression="IdProvenienza" />
			<asp:BoundField DataField="CodiceIstat" HeaderText="Codice Istat" SortExpression="CodiceIstat" />
			<asp:BoundField DataField="Motivo" HeaderText="Motivo" SortExpression="Motivo" />
			<asp:BoundField DataField="GeneratoDa" HeaderText="Generato Da" SortExpression="GeneratoDa" />
			<asp:BoundField DataField="DataInserimento" HeaderText="Data Inserimento" SortExpression="DataInserimento"
				DataFormatString="{0:d}" HtmlEncode="False" />
		</Columns>
	</asp:GridView>
	<asp:ObjectDataSource ID="odsProvenienza" runat="server" OldValuesParameterFormatString="original_{0}"
		SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.ProvenienzeDataSetTableAdapters.ProvenienzeListaTableAdapter"
		CacheDuration="180"></asp:ObjectDataSource>
	<asp:ObjectDataSource ID="odsIncoerenzeIstat" runat="server" OldValuesParameterFormatString="original_{0}"
		SelectMethod="GetData" CacheKeyDependency="CacheIncoerenzeIstat" EnableCaching="True"
		CacheDuration="120" TypeName="DI.Sac.Admin.Data.PazientiIncoerenzaISTATDataSetTableAdapters.PazientiUiIncoerenzaIstatListaTableAdapter">
		<SelectParameters>
			<asp:Parameter Name="DataInserimentoDal" Type="DateTime" />
			<asp:Parameter Name="DataInserimentoAl" Type="DateTime" />
			<asp:Parameter Name="Provenienza" Type="String" />
			<asp:Parameter Name="IdProvenienza" Type="String" />
			<asp:Parameter Name="CodiceIstat" Type="String" />
			<asp:Parameter Name="Top" Type="Int32" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
