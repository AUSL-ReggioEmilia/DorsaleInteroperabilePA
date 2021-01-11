<%@ Page Title="Order Entry - Configurazione Sistemi" Language="vb" AutoEventWireup="false"
	MasterPageFile="~/OrderEntry.Master" CodeBehind="ListaSistemi.aspx.vb" Inherits="DI.OrderEntry.Admin.ListaSistemi" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder"
	runat="server">
	<asp:Label ID="ErrorLabel" runat="server" CssClass="Error" Visible="false"></asp:Label>
	<div id="grigliaInserimentoDiv">
		<table id="filterPanel" runat="server" class="toolbar">
			<tr>
				<td colspan="7">
					<br />
				</td>
			</tr>
			<tr>
				<td>
					Codice o Descrizione:
				</td>
				<td>
					<asp:TextBox ID="CodiceDescrizioneFiltroTextBox" Width="120px" runat="server" />
				</td>
				<td nowrap="nowrap">
					Azienda:
				</td>
				<td nowrap="nowrap">
					<asp:DropDownList ID="AziendaFiltroDropDownList" DataSourceID="AziendeObjectDataSource"
						DataTextField="Descrizione" DataValueField="Codice" AppendDataBoundItems="true"
						CssClass="GridCombo" Width="120px" runat="server">
						<asp:ListItem Value="" Selected="True" Text="" />
					</asp:DropDownList>
				</td>
				<td nowrap="nowrap">
					<asp:CheckBox ID="EroganteCheckBox" runat="server" Checked="true" Text="Erogante" />
					<br />
					<asp:CheckBox ID="RichiedenteCheckBox" runat="server" Checked="true" Text="Richiedente" />
				</td>
				<td>
					Attivo:
				</td>
				<td>
					<asp:DropDownList ID="AttivoDropDown" CssClass="GridCombo" Width="90px" runat="server">
						<asp:ListItem Value="" Text="" Selected="True" />
						<asp:ListItem Value="True" Text="Attivo" />
						<asp:ListItem Value="False" Text="Non attivo" />
					</asp:DropDownList>
				</td>
				<td>
					Cancellazione Post-Inoltro:
				</td>
				<td nowrap="nowrap">
					<asp:DropDownList ID="CancellazionePostInoltroDropDown" CssClass="GridCombo" Width="50px"
						runat="server">
						<asp:ListItem Value="" Text="" Selected="True" />
						<asp:ListItem Value="True" Text="Sì" />
						<asp:ListItem Value="False" Text="No" />
					</asp:DropDownList>
				</td>
                <td>
					Cancellazione Post-InCarico:
				</td>
				<td nowrap="nowrap">
					<asp:DropDownList ID="CancellazionePostInCaricoDropDown" CssClass="GridCombo" Width="50px"
						runat="server">
						<asp:ListItem Value="" Text="" Selected="True" />
						<asp:ListItem Value="True" Text="Sì" />
						<asp:ListItem Value="False" Text="No" />
					</asp:DropDownList>
				</td>
				<td style="width: 100%">
					<asp:Button ID="CercaButton" runat="server" CssClass="Button cercaFlag" Text="Cerca"
						OnClientClick='PageLoadSistemi(); return false;' />
				</td>
			</tr>
			<tr>
				<td colspan="7">
					<br />
				</td>
			</tr>
		</table>
	</div>
	<div id="Sistemi">
	</div>
	<div id="modificaSistema" style="display: none; padding: 5px;">
		<table style="width: 100%; border-collapse: collapse; padding: 10px; font-size: 12px;"
			cellpadding="5">
			<tr>
				<td>
					Azienda
				</td>
				<td class="Bold" style="width: 80%;">
					<span id="sistema_azienda" />
				</td>
			</tr>
			<tr>
				<td>
					Codice
				</td>
				<td class="Bold">
					<span id="sistema_codice" />
				</td>
			</tr>
			<tr>
				<td>
					Descrizione
				</td>
				<td class="Bold">
					<span id="sistema_descrizione" />
				</td>
			</tr>
			<tr>
				<td>
					Attivo
				</td>
				<td>
					<input id="sistema_attivo" type="checkbox" value="Attivo" />
				</td>
			</tr>
			<tr>
				<td>
					Cancellazione<br />
					Post-Inoltro
				</td>
				<td>
					<input id="sistema_cancellazionePostInoltro" type="checkbox" value="CancellazionePostInoltro" />
				</td>
			</tr>
            <tr>
				<td>
					Cancellazione<br />
					Post-InCarico
				</td>
				<td>
					<input id="sistema_cancellazionePostInCarico" type="checkbox" value="CancellazionePostInCarico" />
				</td>
			</tr>
		</table>
	</div>
	<div id="aggiungiDatiAccessori" style="display: none;">
		<table id="splitter" style="height: 400px; width: 100%">
			<tr>
				<td style="width: 50%; vertical-align: top;">
					<fieldset style="height: 100%;">
						<legend>Dati accessori</legend>
						<div id="DatiAccessori" style="overflow-y: auto; height: 380px; max-height: 350px;
								margin-top: 5px; border: 1px solid #c0c0c0;">
						</div>
					</fieldset>
				</td>
				<td style="vertical-align: middle;">
					<input id="addDatiAccessori" type="button" class="leftArrowButton" onclick="AddDatiAccessori(); return false;"
						title="Inserisci" />
					<br />
					<input id="removeDatiAccessori" type="button" class="rightArrowButton" onclick="RemoveDatiAccessori(); return false;"
						title="Rimuovi" />
				</td>
				<td style="width: 50%; vertical-align: top;">
					<fieldset style="height: 100%;">
						<legend>Aggiungi dati accessori</legend>
						<div id="selettoreDatiAccessori" style="padding: 5px;">
							<div id="selettoreDatiAccessoriFiltro">
								<div style="float: left;">
									<span>Codice:</span>
									<input id="codiceFiltro" type="text" onkeydown="if(event.keyCode == 13){CercaDatiAccessori();}"
										style="height: 22px; width: 100px; margin-right: 15px;" />
									<span>Descrizione:</span>
									<input id="descrizioneFiltro" type="text" onkeydown="if(event.keyCode == 13){CercaDatiAccessori();}"
										style="height: 22px; width: 100px;" />
								</div>
								<div style="float: left; margin-left: 3px;">
									<input id="selettoreUtentiFiltroButtonGruppo" type="button" class="searchButton"
										onclick="CercaDatiAccessori(); return false;" style="width: 80px; text-align: center;"
										value="Cerca" />
								</div>
								<img id="loader" src="../Images/refresh.gif" style="display: none; float: left; margin-top: 7px;" />
							</div>
							<div class="separator">
							</div>
							<div id="listaDatiAccessori" style="overflow-y: auto; height: 350px; max-height: 350px;
								margin-top: 5px; border: 1px solid #c0c0c0;">
							</div>
						</div>
					</fieldset>
				</td>
			</tr>
		</table>
	</div>
	<div id="modificaDatiAccessoriSistemi" style="display: none; padding: 5px;">
		<table style="width: 100%; border-collapse: collapse; padding: 10px; font-size: 12px;">
			<tr>
				<td colspan="2" style="padding: 5px; font-size: 15; font-weight: bold">
					Codice del Dato Accessorio di Sistema:
					<asp:Label ID="labelCodiceDatoAccessorio" CssClass="labelCodiceDatoAccessorio" runat="server"
						Text='<%# Eval("CodiceDatoAccessorio") %>'></asp:Label>
					<input type="text" id="dato_codiceDatoAccessorio" style="display: none; width: 180px;"
						value="CodiceDatoAccessorio" />
				</td>
				<%--<td style="width: 100%; padding: 5px;">
                    <input type="text" id="dato_codiceDatoAccessorio" style="display: none; width: 180px;" value="CodiceDatoAccessorio" />
                </td>--%>
			</tr>
			<tr>
				<td colspan="2">
					<br />
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<div>
						<fieldset class="filters" style="float: left; width: 95%;">
							<legend>
								<input id="dato_eredita" type="checkbox" value="Eredita" onclick="EnableEreditaDatiAccessorisistemi()" />
								<span>Eredita da Dato Accessorio</span> </legend>
							<%--<div>
                                <input id="dato_attivo" type="checkbox" value="Attivo" /><span>Attivo</span>
                            </div>--%>
							<div>
								<input id="dato_sistema" type="checkbox" value="Sistema" onclick="EnableValoreDefault()" /><span>Sistema</span>
							</div>
							<div>
								<span>Valore Default</span>
								<input type="text" id="dato_valoreDefault" style="width: 180px;" value="ValoreDefault" />
								<span style="color: red; margin-left: 5px; display: none;">campo obbligatorio</span>
							</div>
						</fieldset>
					</div>
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<br />
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<input id="dato_attivo" type="checkbox" value="Attivo" />
					Attivo<br />
				</td>
			</tr>
		</table>
	</div>
	<asp:ObjectDataSource ID="AziendeObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
		SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.OrdiniTableAdapters.UiLookupAziendeTableAdapter">
		<SelectParameters>
			<asp:Parameter Name="Codice" Type="String" />
		</SelectParameters>
	</asp:ObjectDataSource>
	<script src="../Scripts/lista-sistemi.js?<%= ScriptUtility.Ticks %>" type="text/javascript"></script>
	<script type="text/javascript">

		//precarico la lista di sistemi al load
		window.onload = PageLoadSistemi;

		var _aziendaComboId;

		$(document).ready(function () {

		});

		function PageLoadSistemi() {

            //Ottengo i valori di filtro.
			var codiceDescrizione = $("#<%= CodiceDescrizioneFiltroTextBox.ClientID %>").val();
			var azienda = $("#<%= AziendaFiltroDropDownList.ClientID %>").val();
			var erogante = $("#<%= EroganteCheckBox.ClientID %>").attr('checked') == 'checked';
			var richiedente = $("#<%= RichiedenteCheckBox.ClientID %>").attr('checked') == 'checked'
			var attivo = $("#<%= AttivoDropDown.ClientID %>").val()
		    var cancellazionePostInoltro = $("#<%= CancellazionePostInoltroDropDown.ClientID %>").val()
            var cancellazionePostInCarico = $("#<%= CancellazionePostInCaricoDropDown.ClientID %>").val()

			LoadSistemi(codiceDescrizione, azienda, erogante, richiedente, attivo, cancellazionePostInoltro,cancellazionePostInCarico);

		}


	</script>
	<%--				
var attivo = $("#<%= AttivoCheckBox.ClientID %>").attr('checked') == 'checked'				
var cancellazionePostInoltro = $("#<%= CancellazionePostInoltroCheckBox.ClientID %>").attr('checked') == 'checked'				
	--%>
	<%--
//						var _sistemiGrid = '<%= sistemiGrid.ClientID %>';
//					  _sistemiGrid.tablesorter({widgets: ['zebra']}); 
	--%>
</asp:Content>
