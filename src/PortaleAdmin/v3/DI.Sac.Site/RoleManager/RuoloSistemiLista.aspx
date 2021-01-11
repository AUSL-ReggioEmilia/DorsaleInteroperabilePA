<%@ Page Title="Sistemi" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="RuoloSistemiLista.aspx.vb" Inherits=".RuoloSistemiLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<script type="text/javascript" src="../Scripts/PopUp.js"></script>
	<script>
		function PopUp_AttributiInserisci(IdSistema) {
			commonModalDialogOpen('AttributiInserisci.aspx?IDSistema=' + IdSistema + '&Id=' + $.QueryString['Id'], '', 580, 360);
			return false;
		}
	</script>
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<asp:Label ID="lblTitolo" runat="server" class="Title" Text=""></asp:Label>
	<table id="pannelloFiltri" runat="server" class="toolbar">
		<tr>
			<td colspan="7">
				<br />
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
				<asp:TextBox ID="txtFiltriCodice" runat="server" Width="120px" MaxLength="16"></asp:TextBox>
			</td>
			<td>
				Descrizione<br />
			</td>
			<td>
				<asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="120px" MaxLength="128"></asp:TextBox>
			</td>
            <td>
				Attivo
			</td>
			<td>
                <asp:DropDownList ID="ddlAttivo" runat="server" Width="120px">
					<asp:ListItem Text="" Value="" />
                    <asp:ListItem Text="Si" Value="1" Selected />
                    <asp:ListItem Text="No" Value="0" />
				</asp:DropDownList>
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
	<table class="table_pulsanti" width="100%">
		<tr>
			<td class="Left">
				<asp:Button ID="butEliminaTop" runat="server" Text="Elimina Selezionati" CssClass="TabButton"
					CommandName="Delete" OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione degli elementi selezionati?');"
					ValidationGroup="none" Width="10em" />
				<asp:Button ID="butAggiungiTop" runat="server" Text="Aggiungi..." CssClass="TabButton"
					CommandName="Insert" />
				<asp:Button ID="butConfermaTop" runat="server" Text="Aggiungi Selezionati" CssClass="TabButton"
					Style="width: 140px;" CommandName="Insert" />
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
		DataKeyNames="Id,IdSistema" CssClass="GridYellow" HeaderStyle-CssClass="Header"
		AlternatingRowStyle-CssClass="AlternatingRow" PagerStyle-CssClass="Pager">
		<Columns>
			<asp:TemplateField ItemStyle-Width="30px">
				<HeaderTemplate>
					<asp:CheckBox ID="chkboxSelectAll" runat="server" AutoPostBack="true" OnCheckedChanged="chkboxSelectAll_CheckedChanged" />
				</HeaderTemplate>
				<ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
				<ItemTemplate>
					<asp:CheckBox ID="CheckBox" runat="server"></asp:CheckBox>
				</ItemTemplate>
			</asp:TemplateField>
			<asp:TemplateField ItemStyle-Wrap="false" ItemStyle-Width="110px">
				<ItemTemplate>
					<asp:LinkButton ID="lnkImpostaAttributi" runat="server" Text="Imposta Accessi" OnClientClick='<%# String.Format("javascript:PopUp_AttributiInserisci({0}{1}{0}); return false;", Strings.Chr(34), Eval("Id").Tostring()) %>' />
				</ItemTemplate>
			</asp:TemplateField>
			<asp:BoundField DataField="CodiceAzienda" HeaderText="Azienda" SortExpression="CodiceAzienda"
				ItemStyle-Width="90px" />
			<asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice" ItemStyle-Width="110px" />
			<asp:CheckBoxField DataField="Attivo" HeaderText="Attivo" ReadOnly="True" SortExpression="Attivo"
				ItemStyle-Width="60px" />
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
		</Columns>
	</asp:GridView>
	<table class="table_pulsanti" width="100%">
		<tr>
			<td class="Left">
				<asp:Button ID="butElimina" runat="server" Text="Elimina Selezionati" CssClass="TabButton"
					CommandName="Delete" OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione degli elementi selezionati?');"
					ValidationGroup="none" Width="10em" />
				<asp:Button ID="butAggiungi" runat="server" Text="Aggiungi..." CssClass="TabButton"
					CommandName="Insert" />
				<asp:Button ID="butConferma" runat="server" Text="Aggiungi Selezionati" CssClass="TabButton"
					Style="width: 140px;" CommandName="Insert" />
			</td>
			<td class="Right">
				<asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="TabButton"
					ValidationGroup="none" />
			</td>
		</tr>
	</table>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="OrganigrammaDataSetTableAdapters.RuoliSistemiTableAdapter"
		CacheDuration="120" CacheKeyDependency="CacheRuoloSistemi" DeleteMethod="Delete"
		EnableCaching="True" InsertMethod="Insert" OldValuesParameterFormatString="{0}">
		<InsertParameters>
			<asp:Parameter Name="UtenteInserimento" Type="String" />
			<asp:Parameter DbType="Guid" Name="IdRuolo" />
			<asp:Parameter DbType="Guid" Name="IdSistema" />
		</InsertParameters>
		<SelectParameters>
			<asp:QueryStringParameter DbType="Guid" Name="IDRuolo" QueryStringField="Id" />
			<asp:ControlParameter ControlID="txtFiltriCodice" Name="Codice" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="ddlFiltriAzienda" Name="CodiceAzienda" PropertyName="SelectedValue"
				Type="String" />
			<asp:Parameter Name="Top" Type="Int32" DefaultValue="500" />
            <asp:ControlParameter ControlID="ddlAttivo" Name="Attivo" PropertyName="SelectedValue" Type="String" />
		</SelectParameters>
		<DeleteParameters>
			<asp:Parameter DbType="Guid" Name="Id" />
		</DeleteParameters>
	</asp:ObjectDataSource>
	<asp:ObjectDataSource ID="odsAziende" runat="server" OldValuesParameterFormatString="{0}"
		SelectMethod="AziendeLista" TypeName="OrganigrammaDataSetTableAdapters.AziendeListaTableAdapter"
		CacheDuration="120" CacheKeyDependency="CacheAziende" EnableCaching="True"></asp:ObjectDataSource>
</asp:Content>
