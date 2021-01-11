<%@ Page Title="Order Entry - Configurazione Ennuple" Language="vb" AutoEventWireup="false" MasterPageFile="~/OrderEntry.Master"
	CodeBehind="ListaUtenti.aspx.vb" Inherits="DI.OrderEntry.Admin.ListaUtenti" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder" runat="server">
	<script type="text/javascript" src="../Scripts/PopUp.js"></script>
	<script type="text/javascript" src="../Scripts/lista-utenti.js?<%= ScriptUtility.Ticks %>"></script>
	<script type="text/javascript">

		$(document).ready(function () {

			var codiceDescrizione = $("#<%= CodiceDescrizioneFiltroTextBox.ClientID %>").val();

			if (codiceDescrizione != '') {
				PageLoadUtenti();
			}
		});

		function PageLoadUtenti() {

			var codiceDescrizione = $("#<%= CodiceDescrizioneFiltroTextBox.ClientID %>").val();
			var attivi = $("#<%= AttivoCheckBox.ClientID %>").attr('checked') == 'checked';
			var nonattivi = $("#<%= NonAttivoCheckBox.ClientID %>").attr('checked') == 'checked';
			var delega = $("#<%= ddlFiltroDelega.ClientID %>").val();

			if (!attivi && !nonattivi) {
				document.getElementById('<%=AttivoCheckBox.ClientID%>').checked = true;
				document.getElementById('<%=NonAttivoCheckBox.ClientID%>').checked = true;
			}

			LoadUtenti(codiceDescrizione, attivi, nonattivi, delega);

		}	
	</script>
	<asp:Label ID="ErrorLabel" runat="server" CssClass="Error" Visible="false"></asp:Label>
	<table id="filterPanel" runat="server" class="toolbar">
		<tr>
			<td colspan="7">
				<br />
			</td>
		</tr>
		<tr>
			<td nowrap="nowrap">
				Nome utente<br />
				o descrizione:
			</td>
			<td>
				<asp:TextBox ID="CodiceDescrizioneFiltroTextBox" runat="server" Width="150px" />
			</td>
			<td nowrap="nowrap">
				Mostra solo:
			</td>
			<td nowrap="nowrap">
				<asp:CheckBox ID="AttivoCheckBox" runat="server" Checked="true" Text="Attivi" />
				<br />
				<asp:CheckBox ID="NonAttivoCheckBox" runat="server" Checked="true" Text="Non attivi" />
			</td>
			<td nowrap="nowrap">
				Delega:
			</td>
			<td nowrap="nowrap">
				<asp:DropDownList ID="ddlFiltroDelega" CssClass="GridCombo" Width="110px" runat="server">
					<asp:ListItem Value="" Text="" Selected="True" />
					<asp:ListItem Value="0" Text="No" />
					<asp:ListItem Value="1" Text="Può delegare" />
					<asp:ListItem Value="2" Text="Deve delegare" />
				</asp:DropDownList>
			</td>
			<td style="width: 100%">
				<asp:Button ID="CercaButton" runat="server" CssClass="Button cercaFlag" Text="Cerca" OnClientClick='PageLoadUtenti(); return false;' />
			</td>
		</tr>
		<tr>
			<td colspan="7">
				<br />
			</td>
		</tr>
	</table>
	<div id="toolbarAzioni" style="padding: 3px;">
		<input id="butCreaUtente" type="button" class="addLongButton" value="Crea Utente" onclick="ApriPopUpUtente();"
			title="Crea Utente" />
		<asp:Button ID="butAggiungiUtente" runat="server" CssClass="addLongButton" Text="Aggiungi Utente AD" />
		<asp:Button ID="butAggiungiGruppo" runat="server" CssClass="addLongButton" Text="Aggiungi Gruppo AD" />
		<input id="ImportFromCsvButton" type="button" class="csvLongButton" value="Importa" title="importa da file CSV"
			onclick="ImportaDaCsv(); return false;" />
		<input id="EliminaButton" type="button" class="deleteLongButton" value="Disattiva" onclick="RemoveUtenti(); return false;"
			title="elimina le utenti selezionate" />
	</div>
	<div id="Utenti">
	</div>
	<div id="importaDaCsv" style="display: none; padding: 5px; text-align: center; padding: 25px;">
		<asp:FileUpload ID="CsvFileUpload" runat="server" Width="300px" />
		<asp:Button ID="ImportButton" runat="server" CssClass="importFake" Text="Importa" ToolTip="importa da file CSV"
			Style="display: none;" CausesValidation="false" OnClick="ImportButton_Click"></asp:Button>
	</div>
	<asp:ObjectDataSource ID="SistemiErogantiObjectDataSource" runat="server" OldValuesParameterFormatString="{0}"
		SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.UtentiTableAdapters.UiLookupSistemiErogantiTableAdapter">
		<SelectParameters>
			<asp:Parameter Name="Codice" Type="String" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
