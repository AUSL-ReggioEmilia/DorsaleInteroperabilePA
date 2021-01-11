<%@ Page Title="CercaUtente" Language="vb" AutoEventWireup="false" MasterPageFile="~/OrderEntry.master"
	CodeBehind="SACCercaGruppo.aspx.vb" Inherits=".SACCercaGruppo" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder"
	runat="server">
	<div id="divErrore" style="color:red;" visible="false" runat="server">Si è verificato un errore durante l'inserimento dei seguenti gruppi:</div>
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False" />
	<asp:Label ID="LabelTitolo" runat="server" CssClass="Title" EnableViewState="False"
		Text="Scegliere il gruppo da aggiungere" />
	<table id="pannelloFiltri" runat="server" class="toolbar">
		<tr>
			<td colspan="7">
				<br />
			</td>
		</tr>
		<tr>
			<td nowrap="nowrap">Gruppo
			</td>
			<td>
				<asp:TextBox ID="txtFiltriUtente" runat="server" Width="120px" MaxLength="64"></asp:TextBox>
			</td>
			<td>Descrizione
			</td>
			<td>
				<asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="120px" MaxLength="128"></asp:TextBox>
			</td>
			<td width="100%">
				<asp:Button ID="butFiltriRicerca" runat="server" CssClass="TabButton" Text="Cerca" />
			</td>
			<td width="100%">
				<asp:Button ID="btnAggiungi" runat="server" CssClass="TabButton" OnClick="btnAggiungi_Click" Text="Aggiungi" />
			</td>
		</tr>
		<tr>
			<td colspan="7">
				<br />
			</td>
		</tr>
	</table>
	<br />
	<asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="odsLista" PageSize="100" Width="100%"
		EnableModelValidation="True" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom"
		DataKeyNames="Id,Gruppo,Descrizione" CssClass="Grid" HeaderStyle-CssClass="Header"
		AlternatingRowStyle-CssClass="GridAlternatingItem" PagerStyle-CssClass="Pager">
		<Columns>
			<asp:TemplateField ItemStyle-Width="2%">
				<HeaderTemplate>
					<asp:CheckBox ClientIDMode="Static" ID="CheckBoxSelectAll" runat="server" />
				</HeaderTemplate>
				<ItemTemplate>
					<asp:CheckBox ID="CheckBox" runat="server" />
				</ItemTemplate>
			</asp:TemplateField>
			<asp:BoundField DataField="Gruppo" HeaderText="Gruppo"
				SortExpression="Gruppo" ItemStyle-Wrap="false" ItemStyle-Width="20%" />
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
		</Columns>
	</asp:GridView>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.UtentiTableAdapters.UiSACGruppiTableAdapter"
		CacheDuration="120" CacheKeyDependency="CacheOggettiActiveDirectory" EnableCaching="True"
		OldValuesParameterFormatString="{0}" InsertMethod="Insert">
		<InsertParameters>
			<asp:Parameter Name="Utente" Type="String" />
			<asp:Parameter Name="Descrizione" Type="String" />
			<asp:Parameter Name="Delega" Type="Byte" DefaultValue="0" />
			<asp:Parameter Name="Attivo" Type="Boolean" DefaultValue="True" />
			<asp:Parameter Name="Tipo" Type="Byte" DefaultValue="1" />
		</InsertParameters>
		<SelectParameters>
			<asp:ControlParameter ControlID="txtFiltriUtente" Name="Gruppo" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text"
				Type="String" />
			<asp:Parameter DefaultValue="200" Name="Top" Type="Int32" />
		</SelectParameters>
	</asp:ObjectDataSource>


	<script type="text/javascript">
		$(document).ready(function () {
			$('#CheckBoxSelectAll').click(function () {
				if (this.checked) {
					$('input:checkbox').each(function () {
						this.checked = true;
					});
				} else {
					$('input:checkbox').each(function () {
						this.checked = false;
					});
				}
			});

			$('input:checkbox').click(function () {
				if ($('input:checkbox:checked').length == $('input:checkbox').length) {
					$('#CheckBoxSelectAll').prop('checked', true);
				} else {
					$('#CheckBoxSelectAll').prop('checked', false);
				}
			});
		});
	</script>
</asp:Content>
