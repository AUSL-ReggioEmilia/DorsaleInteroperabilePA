<%@ Page Title="Accessi" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="AttributiLista.aspx.vb" Inherits=".AttributiLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<script type="text/javascript" src="../Scripts/PopUp.js"></script>
	<script>
		function PopUp_AttributiInserisci() {
			commonModalDialogOpen('AttributiInserisci.aspx?Id=' + $.QueryString['Id'], '', 580, 360);
			return false;
		}
	</script>
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<asp:Label ID="lblTitolo" runat="server" class="Title" Text=""></asp:Label>
	<table id="pannelloFiltri" runat="server" class="toolbar">
		<tr>
			<td colspan="5">
				<br />
			</td>
		</tr>
		<tr>
			<td>
				Codice
			</td>
			<td>
				<asp:TextBox ID="txtFiltriCodice" runat="server" Width="120px" MaxLength="32"></asp:TextBox>
			</td>
			<td>
				Descrizione
			</td>
			<td>
				<asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="120px" MaxLength="128"></asp:TextBox>
			</td>
			<td width="100%">
				<asp:Button ID="butFiltriRicerca" runat="server" CssClass="TabButton" Text="Cerca" />
			</td>
		</tr>
		<tr>
			<td colspan="5">
				<br />
			</td>
		</tr>
	</table>
	<table class="table_pulsanti" width="100%">
		<tr>
			<td class="Left">
				<asp:Button ID="butEliminaTop" runat="server" Text="Elimina Selezionati" CssClass="TabButton"
					CommandName="Delete" OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione degli elementi selezionati?');"
					ValidationGroup="none" Width="10em" />
				<asp:Button ID="butAggiungiTop" runat="server" Text="Aggiungi..." CssClass="TabButton"
					OnClientClick="PopUp_AttributiInserisci();return false;" />
			</td>
			<td class="Right">
				<asp:Button ID="butAnnullaTop" runat="server" CommandName="Cancel" Text="Chiudi"
					CssClass="TabButton" ValidationGroup="none" />
			</td>
		</tr>
	</table>
	<asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="odsLista" GridLines="Horizontal" PageSize="100"
		Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom"
		DataKeyNames="Id,TipoAttributo" CssClass="GridYellow" HeaderStyle-CssClass="Header"
		AlternatingRowStyle-CssClass="AlternatingRow" PagerStyle-CssClass="Pager">
		<Columns>
			<asp:TemplateField ItemStyle-Width="1px">
				<HeaderTemplate>
					<asp:CheckBox ID="chkboxSelectAll" runat="server" AutoPostBack="true" OnCheckedChanged="chkboxSelectAll_CheckedChanged" />
				</HeaderTemplate>
				<ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
				<ItemTemplate>
					<asp:CheckBox ID="CheckBox" runat="server"></asp:CheckBox>
				</ItemTemplate>
			</asp:TemplateField>
			<asp:BoundField DataField="CodiceAttributo" HeaderText="Codice" SortExpression="CodiceAttributo"
				ItemStyle-Width="10%" />
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
			<asp:BoundField DataField="Note" HeaderText="Note" SortExpression="Note" ItemStyle-Width="10%" />
		</Columns>
	</asp:GridView>
	<table class="table_pulsanti" width="100%">
		<tr>
			<td class="Left">
				<asp:Button ID="butElimina" runat="server" Text="Elimina Selezionati" CssClass="TabButton"
					CommandName="Delete" OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione degli elementi selezionati?');"
					ValidationGroup="none" Width="10em" />
				<asp:Button ID="butAggiungi" runat="server" Text="Aggiungi..." CssClass="TabButton"
					OnClientClick="PopUp_AttributiInserisci();return false;" />
			</td>
			<td class="Right">
				<asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="TabButton"
					ValidationGroup="none" />
			</td>
		</tr>
	</table>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="OrganigrammaDataSetTableAdapters.RuoliAttributiTableAdapter"
		CacheDuration="120" CacheKeyDependency="CacheListaUnitaOperative" EnableCaching="True"
		OldValuesParameterFormatString="{0}" DeleteMethod="Delete">
		<DeleteParameters>
			<asp:Parameter DbType="Guid" Name="ID" />
			<asp:Parameter Name="TipoAttributo" Type="Byte" />
		</DeleteParameters>
		<SelectParameters>
			<asp:QueryStringParameter DbType="Guid" Name="IDRuolo" QueryStringField="Id" />
			<asp:ControlParameter ControlID="txtFiltriCodice" Name="CodiceAttributo" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text"
				Type="String" />
			<asp:Parameter Name="Top" Type="Int32" DefaultValue="500" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
