<%@ Page Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeBehind="SottoscrizioniDettaglio.aspx.vb"
	Inherits="DI.DataWarehouse.Admin.SottoscrizioniDettaglio" Title="Untitled Page" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="Server">
	<asp:ScriptManager ID="scrMgr" runat="server"></asp:ScriptManager>

	<style>
		.inputbox {
			display: block;
			color: black;
			background-color: white;
			border: 1px solid #CEDCD5;
			padding: 0px;
			margin: 0px;
			width: 100%;
			box-sizing: border-box;
		}

			.inputbox textarea {
				float: left;
				border: none;
				width: 100%;
				margin: 0px;
			}

			.inputbox input {
				margin: 3px;
				float: right;
			}

		.divPulsanti {
			padding-bottom: 10px;
		}

			.divPulsanti input {
				width: 150px;
				margin-top: 2px;
			}
	</style>

	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"></asp:Label>

	<asp:FormView ID="fwMain" runat="server" DataSourceID="DataSourceMain" DataKeyNames="Id,Ts" DefaultMode="Edit" RenderOuterTable="false">
		<EditItemTemplate>
			<div class="toolbar" style="width: 100%;">
				<a style="width: 80px" class="backButton" href='SottoscrizioniLista.aspx'>Indietro</a>&nbsp;
				<asp:LinkButton ID="butSalva" runat="server" Text="Salva" CssClass="saveButton" CommandName="Update" />&nbsp;
		  	<asp:LinkButton ID="butElimina" runat="server" Text="Elimina" CssClass="deleteButton" CommandName="Delete"
					OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione dell\'elemento?');" ValidationGroup="none" />
			</div>
			<%--<span class="Title">Dettaglio Sottoscrizione</span>--%>
			<table class="table_dettagli" style="width: 700px;">
				<tr>
					<td class="Td-Text" style="width: 200px;">Nome Deposito:</td>
					<td class="Td-Value" style="width: 500px;">
						<asp:TextBox ID="NomeTextBox" runat="server" Text='<%# Bind("Nome") %>' Width="100%" MaxLength="128"></asp:TextBox>
						<asp:RequiredFieldValidator ID="req1" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="NomeTextBox" CssClass="Error" Display="Dynamic" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">Descrizione:</td>
					<td class="Td-Value">
						<asp:TextBox ID="DescrizioneTextBox" runat="server" Text='<%# Bind("Descrizione") %>' Width="100%" MaxLength="1024"></asp:TextBox>
					</td>
				</tr>
				<tr>
					<td class="Td-Text">Attivo:</td>
					<td class="Td-Value">
						<asp:CheckBox ID="AttivoCheckBox" runat="server" Checked='<%# Bind("Attivo") %>'></asp:CheckBox>
					</td>
				</tr>
				<tr>
					<td class="Td-Text">Data Inizio Validità:</td>
					<td class="Td-Value">
						<asp:TextBox ID="DataInizioValiditaTextBox" runat="server" Text='<%# Bind("DataInizio", "{0:d}") %>' MaxLength="10" CssClass="DateInput"></asp:TextBox>
						<asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="DataInizioValiditaTextBox" CssClass="Error" Display="Dynamic" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">Data Fine Validità:</td>
					<td class="Td-Value">
						<asp:TextBox ID="DataFineValiditaTextBox" runat="server" Text='<%# Bind("DataFine", "{0:d}") %>' MaxLength="10" CssClass="DateInput"></asp:TextBox>
						<asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="DataFineValiditaTextBox" CssClass="Error" Display="Dynamic" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">Tipo Referto:</td>
					<td class="Td-Value">
						<asp:DropDownList ID="TipoRefertoDropDown" runat="server" Width="153" SelectedValue='<%# Bind("TipoReferto") %>'
							DataSourceID="DataSourceTipiReferto" DataTextField="Descrizione" DataValueField="Id">
						</asp:DropDownList>
					</td>
				</tr>
				<tr>
					<td class="Td-Text">Gestione Oscurati:</td>
					<td class="Td-Value">
						<asp:CheckBox ID="GestioneOscuratiCheckBox" runat="server" Checked='<%# Bind("GestioneOscurati") %>'></asp:CheckBox>
					</td>
				</tr>
				<tr>
					<td class="Td-Text">Gestione Confidenziali:</td>
					<td class="Td-Value">
						<asp:CheckBox ID="GestioneConfidenzialiCheckBox" runat="server" Checked='<%# Bind("GestioneConfidenziali") %>'></asp:CheckBox>
					</td>
				</tr>
				<tr>
					<td class="Td-Text">Numero di Tentativi (max)</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtNumeroTentativi" runat="server" Text='<%# Bind("NumeroTentativi") %>' MaxLength="3">3</asp:TextBox>
						<asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="txtNumeroTentativi" CssClass="Error" Display="Dynamic" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">Attesa fra i Tentativi (sec)</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtAttesaFraTentativi" runat="server" Text='<%# Bind("AttesaFraTentativi") %>' MaxLength="4">30</asp:TextBox>
						<asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="txtAttesaFraTentativi" CssClass="Error" Display="Dynamic" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">Attesa Completamento (sec)</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtAttesaCompletamento" runat="server" Text='<%# Bind("AttesaCompletamento") %>' MaxLength="4">30</asp:TextBox>
						<asp:RequiredFieldValidator ID="RequiredFieldValidator8" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="txtAttesaCompletamento" CssClass="Error" Display="Dynamic" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">Rename Allegato:</td>
					<td class="Td-Value" style="text-wrap: none;">
						<div class="inputbox">
							<asp:TextBox ID="RenameAllegatoTextBox" runat="server" Text='<%# Bind("RenameAllegato") %>'
								Rows="3" TextMode="MultiLine" CssClass="RenameAllegatoTextBox" MaxLength="1024"></asp:TextBox>
							<input type="button" class="Button" onclick="Pulisci();" value="Pulisci" />
						</div>
						<asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="RenameAllegatoTextBox" CssClass="Error" Display="Dynamic" />
						<div class="divPulsanti">
							<input type="button" class="Button" onclick="Concatena('[AZIENDA EROGANTE]');" value="Azienda Erogante" />
							<input type="button" class="Button" onclick="Concatena('[SISTEMA EROGANTE]');" value="Sistema Erogante" />
							<input type="button" class="Button" onclick="Concatena('[REPARTO EROGANTE]');" value="Reparto Erogante" />
							<input type="button" class="Button" onclick="Concatena('[REPARTO RICHIEDENTE]');" value="Reparto Richiedente" />
							<input type="button" class="Button" onclick="Concatena('[NUMERO NOSOLOGICO]');" value="Numero Nosologico" />
							<input type="button" class="Button" onclick="Concatena('[NUMERO REFERTO]');" value="Numero Referto" />
							<input type="button" class="Button" onclick="Concatena('[ANAGRAFICA]');" value="Anagrafica" />
						</div>
					</td>
				</tr>
				<tr>
					<td class="Td-Text">Cancellazione Cambio Stato:</td>
					<td class="Td-Value">
						<asp:CheckBox ID="CancellazioneCambioStatoCheckBox" runat="server" Checked='<%# Bind("CancellazioneCambioStato") %>'></asp:CheckBox>
					</td>
				</tr>
				<tr>
					<td class="Td-Text">Destinazione&nbsp;della&nbsp;Copia (path):</td>
					<td class="Td-Value">
						<asp:TextBox ID="DestinazioneCopiaTextBox" runat="server" Text='<%# Bind("DestinazioneCopia") %>' Width="100%" MaxLength="1024"></asp:TextBox>
						<asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="DestinazioneCopiaTextBox" CssClass="Error" Display="Dynamic" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">MIME Type:</td>
					<td class="Td-Value">
						<asp:TextBox ID="MimeTypeTextBox" runat="server" Text='<%# Bind("MimeType") %>' Width="100%" MaxLength="512"></asp:TextBox>
						<asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="MimeTypeTextBox" CssClass="Error" Display="Dynamic" />
					</td>
				</tr>
			</table>
		</EditItemTemplate>
	</asp:FormView>

	<asp:ObjectDataSource ID="DataSourceTipiReferto" runat="server" SelectMethod="GetData"
		TypeName="CrashSystemTableAdapters.TipiRefertoTableAdapter" OldValuesParameterFormatString="{0}"
		EnableCaching="true" CacheDuration="120">
		<SelectParameters></SelectParameters>
	</asp:ObjectDataSource>

	<asp:ObjectDataSource ID="DataSourceMain" runat="server" DeleteMethod="Delete"
		OldValuesParameterFormatString="{0}" SelectMethod="GetData"
		TypeName="CrashSystemTableAdapters.SottoscrizioniTableAdapter" InsertMethod="Insert" UpdateMethod="Update">

		<SelectParameters>
			<asp:QueryStringParameter DbType="Guid" Name="Id" QueryStringField="Id" />
		</SelectParameters>

		<DeleteParameters>
			<asp:Parameter Name="Id" DbType="Guid" />
			<asp:Parameter Name="Ts" Type="Object"></asp:Parameter>
		</DeleteParameters>

		<InsertParameters>
			<asp:Parameter Name="UtenteInserimento" Type="String"></asp:Parameter>
			<asp:Parameter Name="Nome" Type="String"></asp:Parameter>
			<asp:Parameter Name="Descrizione" Type="String"></asp:Parameter>
			<asp:Parameter Name="Attivo" Type="Boolean"></asp:Parameter>
			<asp:Parameter Name="DataInizio" Type="DateTime"></asp:Parameter>
			<asp:Parameter Name="DataFine" Type="DateTime"></asp:Parameter>
			<asp:Parameter Name="TipoReferto" Type="Int32"></asp:Parameter>
			<asp:Parameter Name="GestioneOscurati" Type="Boolean"></asp:Parameter>
			<asp:Parameter Name="GestioneConfidenziali" Type="Boolean"></asp:Parameter>
			<asp:Parameter Name="RenameAllegato" Type="String"></asp:Parameter>
			<asp:Parameter Name="CancellazioneCambioStato" Type="Boolean"></asp:Parameter>
			<asp:Parameter Name="DestinazioneCopia" Type="String"></asp:Parameter>
			<asp:Parameter Name="MimeType" Type="String"></asp:Parameter>
			<asp:Parameter Direction="Output" Name="InsertedId" Type="Object"></asp:Parameter>
		</InsertParameters>

		<UpdateParameters>
			<asp:Parameter DbType="Guid" Name="Id"></asp:Parameter>
			<asp:Parameter Name="Ts" Type="Object"></asp:Parameter>
			<asp:Parameter Name="UtenteModifica" Type="String"></asp:Parameter>
			<asp:Parameter Name="Nome" Type="String"></asp:Parameter>
			<asp:Parameter Name="Descrizione" Type="String"></asp:Parameter>
			<asp:Parameter Name="Attivo" Type="Boolean"></asp:Parameter>
			<asp:Parameter Name="DataInizio" Type="DateTime"></asp:Parameter>
			<asp:Parameter Name="DataFine" Type="DateTime"></asp:Parameter>
			<asp:Parameter Name="TipoReferto" Type="Int32"></asp:Parameter>
			<asp:Parameter Name="GestioneOscurati" Type="Boolean"></asp:Parameter>
			<asp:Parameter Name="GestioneConfidenziali" Type="Boolean"></asp:Parameter>
			<asp:Parameter Name="RenameAllegato" Type="String"></asp:Parameter>
			<asp:Parameter Name="CancellazioneCambioStato" Type="Boolean"></asp:Parameter>
			<asp:Parameter Name="DestinazioneCopia" Type="String"></asp:Parameter>
			<asp:Parameter Name="MimeType" Type="String"></asp:Parameter>
		</UpdateParameters>
	</asp:ObjectDataSource>



	<%--
		
		
		RIGHE DI DETTAGLIO
		
		
	--%>

	<asp:UpdatePanel ID="upd_dettagli" runat="server" UpdateMode="Conditional">
		<ContentTemplate>

			<fieldset class="filters" style="width: 100%;">
				<legend>Sistemi e Reparti coinvolti</legend>
				<%--
		
					FORM INSERIMENTO NUOVA RIGA
		
				--%>
				<asp:FormView ID="fwEditRigaDettaglio" runat="server" DataSourceID="DataSourceSottoscrizioniDettaglio"
					DataKeyNames="Id" DefaultMode="Insert" RenderOuterTable="false">
					<InsertItemTemplate>

						<asp:ObjectDataSource ID="odsAziende" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData"
							TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.AziendeErogantiListaTableAdapter"
							EnableCaching="true" CacheDuration="120"></asp:ObjectDataSource>

						<asp:ObjectDataSource ID="odsSistemiEroganti" runat="server" SelectMethod="GetDataByAziendaETipo"
							TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.SistemiErogantiListaTableAdapter"
							EnableCaching="true" CacheDuration="120" OldValuesParameterFormatString="{0}">
							<SelectParameters>
								<asp:ControlParameter ControlID="ddlAziendaErogante" PropertyName="SelectedValue" Name="AziendaErogante" Type="String"></asp:ControlParameter>
								<asp:Parameter DefaultValue="referti" Name="Tipo" Type="String" />
							</SelectParameters>
						</asp:ObjectDataSource>

						<div class="fieldbox">
							<%--SelectedValue='<%# Bind("AziendaEroganteCodice") %>' --%>
							<label for="ddlAziendaErogante">Azienda Erogante</label><br />
							<asp:DropDownList ID="ddlAziendaErogante" runat="server" Width="170px" DataSourceID="odsAziende"
								DataTextField="Descrizione" DataValueField="Codice" AutoPostBack="true" OnDataBound="ddlAziendaErogante_DataBound">
							</asp:DropDownList>
						</div>
						<div class="fieldbox">
							<%--SelectedValue='<%# Bind("SistemaEroganteCodice") %>'--%>
							<label for="ddlSistemaErogante">Sistema Erogante</label><br />
							<asp:DropDownList ID="ddlSistemaErogante" runat="server" Width="170px" DataSourceID="odsSistemiEroganti"
								DataTextField="Descrizione" DataValueField="Codice" OnDataBound="ddlSistemaErogante_DataBound">
							</asp:DropDownList>
						</div>
						<div class="fieldbox">
							<label for="txtRepartoErogante">Reparto Erogante</label><br />
							<asp:TextBox ID="txtRepartoErogante" runat="server" Width="170px" Text='<%# Bind("RepartoErogante") %>' MaxLength="64" />
						</div>
						<div class="fieldbox">
							<label for="txtRepartoRichiedente">Codice Reparto Richiedente</label><br />
							<asp:TextBox ID="txtRepartoRichiedente" runat="server" Width="170px" Text='<%# Bind("RepartoRichiedenteCodice") %>' MaxLength="16" />
						</div>
						<div class="fieldbox">
							<br />
							<asp:Button ID="butInserisci" runat="server" Text="Inserisci" CssClass="Button" CommandName="Insert" UseSubmitBehavior="false" />
						</div>

					</InsertItemTemplate>
				</asp:FormView>
				<%--
		
					GRID RIGHE DI DETTAGLIO
		
				--%>
				<span style="clear: both"></span>
				<asp:GridView ID="gvDettagli" runat="server" AllowSorting="True"
					DataSourceID="DataSourceSottoscrizioniDettaglio" AutoGenerateColumns="False" DataKeyNames="Id"
					CssClass="Grid" Width="100%" EmptyDataText="Nessun elemento presente.">
					<Columns>
						<asp:BoundField DataField="AziendaEroganteCodice" HeaderText="Azienda Erogante" SortExpression="AziendaEroganteCodice" />
						<asp:BoundField DataField="SistemaEroganteCodice" HeaderText="Sistema Erogante" SortExpression="SistemaEroganteCodice"></asp:BoundField>
						<asp:BoundField DataField="RepartoErogante" HeaderText="Reparto Erogante" SortExpression="RepartoErogante"></asp:BoundField>
						<asp:BoundField DataField="RepartoRichiedenteCodice" HeaderText="Codice Reparto Richiedente" SortExpression="RepartoRichiedenteCodice"></asp:BoundField>
						<asp:TemplateField ItemStyle-Width="30px">
							<ItemTemplate>
								<asp:Button ID="butDettaglioElimina" runat="server" Text="" CssClass="input deleteButton" Width="22" ToolTip="Elimina"
									OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione dell\'elemento?');" CommandName="Delete" />
							</ItemTemplate>
						</asp:TemplateField>
					</Columns>
					<RowStyle CssClass="GridItem" />
					<HeaderStyle CssClass="GridHeader" />
					<AlternatingRowStyle CssClass="GridAlternatingItem" />
				</asp:GridView>

			</fieldset>

			<asp:ObjectDataSource ID="DataSourceSottoscrizioniDettaglio" runat="server" SelectMethod="GetDataBySottoscrizioniId"
				TypeName="CrashSystemTableAdapters.SottoscrizioniDettaglioTableAdapter" OldValuesParameterFormatString="{0}"
				DeleteMethod="Delete" InsertMethod="Insert">
				<SelectParameters>
					<asp:QueryStringParameter QueryStringField="Id" DbType="Guid" Name="SottoscrizioniId"></asp:QueryStringParameter>
				</SelectParameters>
				<InsertParameters>
					<asp:QueryStringParameter QueryStringField="Id" DbType="Guid" Name="SottoscrizioniId"></asp:QueryStringParameter>
					<asp:Parameter Name="UtenteInserimento" Type="String"></asp:Parameter>
					<asp:Parameter Name="AziendaEroganteCodice" Type="String"></asp:Parameter>
					<asp:Parameter Name="SistemaEroganteCodice" Type="String"></asp:Parameter>
					<asp:Parameter Name="RepartoErogante" Type="String"></asp:Parameter>
					<asp:Parameter Name="RepartoRichiedenteCodice" Type="String"></asp:Parameter>
				</InsertParameters>
				<DeleteParameters>
					<asp:Parameter Name="Id" DbType="Guid" />
				</DeleteParameters>
			</asp:ObjectDataSource>

			<%--pulsante nascosto per catturare il tasto enter--%>
			<asp:Button ID="hiddenbutton" runat="server" Text="" Style="display: none;" UseSubmitBehavior="false" />

		</ContentTemplate>
	</asp:UpdatePanel>

	<script type="text/javascript">

		//DATE PICKER PER LE TEXTBOX
		$(".DateInput").datepicker($.datepicker.regional['it']);

		function Concatena(testo) {
			var $txtBox = $(".RenameAllegatoTextBox");
			if ($txtBox.length > 0) {
				if ($txtBox.val().length > 0) {
					$txtBox.val($txtBox.val() + '_' + testo);
				}
				else {
					$txtBox.val(testo);
				}
			}
		}

		function Pulisci() {
			var $txtBox = $(".RenameAllegatoTextBox");
			if ($txtBox.length > 0) $txtBox.val('');
		}

	</script>

</asp:Content>
