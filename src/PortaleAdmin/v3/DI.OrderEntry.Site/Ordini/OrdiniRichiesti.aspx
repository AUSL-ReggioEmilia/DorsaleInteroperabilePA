<%@ Page Title="Ordini" Language="vb" AutoEventWireup="false" MasterPageFile="~/OrderEntry.Master" CodeBehind="OrdiniRichiesti.aspx.vb"
	Inherits="DI.OrderEntry.Admin.OrdiniRichiesti" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder" runat="server">
	<style type="text/css">
		.divRicerca
		{
			display: inline-block;
			width:135px;
		}
		.marginTop
		{
			display: block;
			margin: 10px 0 0 0;
		}
	</style>

	<asp:Label ID="ErrorLabel" runat="server" CssClass="Error" Visible="false"></asp:Label>
	<span class="Bold">Ricerca (<a id="linkFiltroAvanzato" href="#" onclick="ToggleFilter(); return false;">semplice</a>)</span>
	<div id="filterPanel" runat="server">
		<fieldset class="filters">
			<legend>Generale</legend>
			<div>
				<span>Numero Ordine O.E.</span>
				<asp:TextBox ID="AnnoTextBox" MaxLength="4" Width="40px" runat="server" />
				&nbsp;/
				<asp:TextBox ID="NumeroTextBox" runat="server" Width="100px" />
			</div>
			<div>
				<span>Sistemi Eroganti</span>
				<asp:DropDownList ID="SistemaEroganteFiltroDropDownList" DataSourceID="SistemiErogantiObjectDataSource" DataTextField="Descrizione"
					DataValueField="Id" CssClass="GridCombo" Width="100%" runat="server">
				</asp:DropDownList>
			</div>
			<div class="NoRequiredField">
				<span>Stato O.E.</span>
				<asp:DropDownList ID="StatoDropDownList" DataSourceID="StatoObjectDataSource" DataTextField="Descrizione" DataValueField="Descrizione"
					CssClass="GridCombo" Width="100%" runat="server">
				</asp:DropDownList>
			</div>
			<div>
				<span>Periodo (data modifica)</span>
				<asp:DropDownList ID="PeriodoInserimentoDropDownList" onchange="DateChanged('inserimento'); return false;" runat="server"
					Width="100%">
					<asp:ListItem Value=" " Selected="True" Text=""></asp:ListItem>
					<asp:ListItem Value="1">ultima ora</asp:ListItem>
					<asp:ListItem Value="2">ultime 24 ore</asp:ListItem>
					<asp:ListItem Value="3">ultimi 7 giorni</asp:ListItem>
					<asp:ListItem Value="4">ultimi 30 giorni</asp:ListItem>
				</asp:DropDownList>
			</div>
			<div class="NoRequiredField">
				<span>Data modifica da</span>
				<asp:TextBox ID="DataInserimentoDaTextBox" runat="server" onchange="ResetComboOnUserDateChange('inserimento');"
					Width="100%"></asp:TextBox>
			</div>
			<div class="NoRequiredField">
				<span>a</span>
				<asp:TextBox ID="DataInserimentoATextBox" runat="server" onchange="ResetComboOnUserDateChange('inserimento');"
					Width="100%"></asp:TextBox>
			</div>
		</fieldset>
		<fieldset class="filters">
			<legend>Richiedente</legend>
			<div>
				<span>Sistema</span>
				<asp:DropDownList ID="SistemaRichiedenteFiltroDropDownList" DataSourceID="SistemiRichiedentiObjectDataSource" DataTextField="Descrizione"
					DataValueField="Id" CssClass="GridCombo" Width="100%" runat="server">
				</asp:DropDownList>
			</div>
			<div>
				<span>Numero Ordine S.R.</span>
				<asp:TextBox ID="IdRichiestaTextBox" runat="server" Width="100%"></asp:TextBox>
			</div>
			<div>
				<span>Periodo (data richiesta)</span>
				<asp:DropDownList ID="PeriodoRichiestaDropDownList" onchange="DateChanged('richiesta'); return false;" runat="server"
					Width="100%">
					<asp:ListItem Value=" " Text=""></asp:ListItem>
					<asp:ListItem Value="1" Selected="true">ultima ora</asp:ListItem>
					<asp:ListItem Value="2">ultime 24 ore</asp:ListItem>
					<asp:ListItem Value="3">ultimi 7 giorni</asp:ListItem>
					<asp:ListItem Value="4">ultimi 30 giorni</asp:ListItem>
				</asp:DropDownList>
			</div>
             <div>
                <span>Unità Operativa Richiedente</span>
				<asp:TextBox ID="UnitaOperativaRichiedenteTextBox" runat="server" Width="100%"></asp:TextBox>
            </div>
			<div class="NoRequiredField">
				<span>Data richiesta da</span>
				<asp:TextBox ID="DataRichiestaDaTextBox" runat="server" onchange="ResetComboOnUserDateChange('richiesta');" Width="100%"></asp:TextBox>
			</div>
			<div class="NoRequiredField">
				<span>a</span>
				<asp:TextBox ID="DataRichiestaATextBox" runat="server" onchange="ResetComboOnUserDateChange('richiesta');" Width="100%"></asp:TextBox>
			</div>
           
		</fieldset>
		<fieldset class="filters">
			<legend>Paziente</legend>
			<div>
				<span>Nosologico</span>
				<asp:TextBox ID="NosologicoTextBox" runat="server" Width="163px"></asp:TextBox>
			</div>
			<div class="NoRequiredField">
				<span>Nome Anagrafica</span>
				<asp:TextBox ID="NomeAnagraficaTextBox" runat="server" Width="163px"></asp:TextBox>
			</div>
			<div class="NoRequiredField">
				<span>Cod. Anagrafica</span>
				<asp:TextBox ID="CodiceAnagraficaTextBox" runat="server" Width="163px"></asp:TextBox>
			</div>
			<div>
				<span>Cognome</span>
				<asp:TextBox ID="CognomeTextBox" runat="server" Width="163px"></asp:TextBox>
			</div>
			<div>
				<span>Nome</span>
				<asp:TextBox ID="NomeTextBox" runat="server" Width="163px"></asp:TextBox>
			</div>
			<div class="NoRequiredField">
				<span>Data di nascita</span>
				<asp:TextBox ID="DataNascitaTextBox" runat="server" Width="163px"></asp:TextBox>
			</div>
			<div>
				<span>Codice Fiscale</span>
				<asp:TextBox ID="CodiceFiscaleTextBox" runat="server" Width="163px"></asp:TextBox>
			</div>
		</fieldset>
	</div>
	<div class="divRicerca">
		<span>Max Risultati</span>
		<asp:DropDownList ID="NumeroRisultatiDropDownList" Width="130px" runat="server" ToolTip="Numero massimo di risultati da visualizzare">
			<asp:ListItem Selected="True" Value="100">100</asp:ListItem>
			<asp:ListItem Value="200">200</asp:ListItem>
			<asp:ListItem Value="500">500</asp:ListItem>
			<asp:ListItem Value="1000">1000</asp:ListItem>
		</asp:DropDownList>	
		<asp:Button ID="SearchButton" Text="Cerca" runat="server" CssClass="Button marginTop" />
		<asp:Button ID="ClearFilterButton" Text="Annulla" runat="server" CssClass="Button marginTop" OnClientClick="ClearFilters(); return false;" />
	</div>
	<div class="separator">
	</div>
	<div id="gridPanel">
		<asp:GridView ID="OrdiniGridView" runat="server" AllowPaging="True" AllowSorting="true" CssClass="Grid" AutoGenerateColumns="False"
			DataKeyNames="Id" DataSourceID="OrdiniListaObjectDataSource" EnableModelValidation="True" PageSize="100" PagerSettings-Position="TopAndBottom">
			<AlternatingRowStyle CssClass="GridAlternatingItem" />
			<HeaderStyle CssClass="GridHeader" />
			<PagerStyle CssClass="GridPager" />
			<SelectedRowStyle CssClass="GridSelected" />
			<RowStyle CssClass="GridItem" />
			<Columns>
				<asp:HyperLinkField DataNavigateUrlFormatString="OrdiniDettaglio.aspx?Id={0}" DataNavigateUrlFields="Id" Text="&lt;img src='../Images/detail.png' alt='visualizza il dettaglio' border='0'/&gt;" />
				<asp:BoundField DataField="DataInserimento" HeaderText="Data Inserimento O.E." SortExpression="DataInserimento" />
				<asp:BoundField DataField="DataModifica" HeaderText="Data Modifica O.E." SortExpression="DataModifica" />
				<asp:BoundField DataField="DataRichiesta" HeaderText="Data Richiesta" SortExpression="DataRichiesta" />
				<asp:BoundField DataField="NumeroOrdine" HeaderText="Numero Ordine O.E." SortExpression="NumeroOrdineSort" />
				<asp:BoundField DataField="StatoOrderEntryDescrizione" HeaderText="Stato O.E." SortExpression="StatoOrderEntryDescrizione"
					HtmlEncode="false" />
				<asp:BoundField DataField="SistemaRichiedente" HeaderText="Sistema Richiedente" />
				<asp:BoundField DataField="IdRichiestaRichiedente" HeaderText="Numero Ordine S.R." SortExpression="IdRichiestaRichiedente" />
				<asp:BoundField DataField="TipiRichieste" HeaderText="Sistemi Eroganti" HtmlEncode="false" />
				<asp:TemplateField HeaderText="Dati Anagrafici Paziente" SortExpression="DatiAnagraficiPaziente">
					<ItemTemplate>
						<asp:HyperLink ID="PazienteIdSacHyperLink" Visible='<%# Eval("PazienteIdSac") IsNot DBNull.Value %>' runat="server"
							Target="_blank" Text='<%#Eval("DatiAnagraficiPaziente")%>' NavigateUrl='<%# GetSacPazienteUrl(Eval("PazienteIdSac")) %>'></asp:HyperLink>
						<asp:Label ID="PazienteLabel" Visible='<%# Eval("PazienteIdSac") Is DBNull.Value %>' runat="server" Text='<%#Eval("DatiAnagraficiPaziente")%>'></asp:Label>
					</ItemTemplate>
					<ItemStyle CssClass="datiAnagraficiColumn"></ItemStyle>
				</asp:TemplateField>
				<asp:BoundField DataField="CodiceAnagrafica" HeaderText="Codice Anagrafica" SortExpression="CodiceAnagrafica" />
				<asp:BoundField DataField="NumeroNosologico" HeaderText="Nosologico" SortExpression="NumeroNosologico" />
				<asp:BoundField DataField="TotaleRigheRichieste" HeaderText="Numero Prestazioni" ReadOnly="True" SortExpression="TotaleRigheRichieste" />
				<asp:BoundField DataField="DescrizioneUnitaOperativaRichiedente" HeaderText="Descrizione Unita Operativa Richiedente" ReadOnly="True" SortExpression="DescrizioneUnitaOperativaRichiedente" />

				<asp:BoundField DataField="DataAggiornamentoStato" HeaderText="Data Aggiornamento Stato" />
				<asp:TemplateField HeaderText="Validità Ordine" SortExpression="ValiditaOrdine">
					<ItemTemplate>
						<%# GetValiditaIcon(Eval("ValiditaOrdine"), Eval("MessaggioValidita")) %>
					</ItemTemplate>
				</asp:TemplateField>
			</Columns>
		</asp:GridView>
		<asp:ObjectDataSource ID="OrdiniListaObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
			SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.OrdiniTableAdapters.UiOrdiniListTableAdapter">
			<SelectParameters>
				<asp:ControlParameter ControlID="NumeroRisultatiDropDownList" Name="numeroRisultati" PropertyName="SelectedValue"
					Type="Int32" />
				<asp:Parameter  Name="Ordinamento" Type="String" />
				<asp:Parameter Name="Id" DbType="Guid" />
				<asp:ControlParameter Name="anno" Type="Int32" ControlID="AnnoTextBox" ConvertEmptyStringToNull="true" />
				<asp:ControlParameter Name="numero" Type="Int32" ControlID="NumeroTextBox" ConvertEmptyStringToNull="true" />
				<asp:ControlParameter ControlID="NosologicoTextBox" Name="numeroNosologico" PropertyName="Text" Type="String" ConvertEmptyStringToNull="true" />
				<asp:ControlParameter ControlID="SistemaEroganteFiltroDropDownList" DbType="Guid" Name="idSistemaErogante" PropertyName="SelectedValue" />
				<asp:ControlParameter ControlID="StatoDropDownList" Name="descrizioneStatoOrderEntry" PropertyName="SelectedValue"
					Type="String" ConvertEmptyStringToNull="true" />
				<asp:ControlParameter ControlID="SistemaRichiedenteFiltroDropDownList" Name="idSistemaRichiedente" PropertyName="SelectedValue"
					Type="String" ConvertEmptyStringToNull="true" />
				<asp:ControlParameter ControlID="IdRichiestaTextBox" Name="idRichiestaRichiedente" PropertyName="Text"
					Type="String" ConvertEmptyStringToNull="true" />
				<asp:ControlParameter ControlID="DataRichiestaDaTextBox" Name="dataRichiestaDa" Type="DateTime" ConvertEmptyStringToNull="true" />
				<asp:ControlParameter ControlID="DataRichiestaATextBox" Name="dataRichiestaA" Type="DateTime" ConvertEmptyStringToNull="true" />
				<asp:ControlParameter ControlID="DataInserimentoDaTextBox" Name="dataInserimentoDa" Type="DateTime" ConvertEmptyStringToNull="true" />
				<asp:ControlParameter ControlID="DataInserimentoATextBox" Name="dataInserimentoA" Type="DateTime" ConvertEmptyStringToNull="true" />
				<asp:ControlParameter ControlID="CodiceAnagraficaTextBox" Name="anagraficaCodice" ConvertEmptyStringToNull="true"
					PropertyName="Text" Type="String" />
				<asp:ControlParameter ControlID="NomeAnagraficaTextBox" Name="anagraficaNome" PropertyName="Text" ConvertEmptyStringToNull="true"
					Type="String" />
				<asp:ControlParameter ControlID="CognomeTextBox" Name="pazienteCognome" PropertyName="Text" ConvertEmptyStringToNull="true"
					Type="String" />
				<asp:ControlParameter ControlID="NomeTextBox" Name="pazienteNome" PropertyName="Text" ConvertEmptyStringToNull="true"
					Type="String" />
				<asp:ControlParameter ControlID="DataNascitaTextBox" Name="pazienteDataNascita" PropertyName="Text" ConvertEmptyStringToNull="true"
					Type="DateTime" />
				<asp:ControlParameter ControlID="CodiceFiscaleTextBox" Name="pazienteCodiceFiscale" PropertyName="Text" ConvertEmptyStringToNull="true"
					Type="String" />
                <asp:ControlParameter ControlID="UnitaOperativaRichiedenteTextBox" Name="unitaOperativaRichiedente" PropertyName="Text" ConvertEmptyStringToNull="true"
					Type="String" />
			</SelectParameters>
		</asp:ObjectDataSource>
	</div>
	<script type="text/javascript">

		//comboType = richiesta, inserimento
		function ResetComboOnUserDateChange(comboType) {

			var comboId = (comboType == "richiesta") ? "#<%=PeriodoRichiestaDropDownList.ClientID %>" : "#<%=PeriodoInserimentoDropDownList.ClientID %>";

			$(comboId).val(' ');
		}

		//comboType = richiesta, inserimento
		function DateChanged(comboType, isLoading) {

			var today = new Date();
			var dataDa = new Date();

			var comboId = (comboType == "richiesta") ? "#<%=PeriodoRichiestaDropDownList.ClientID %>" : "#<%=PeriodoInserimentoDropDownList.ClientID %>";
			var dataDaClientId = (comboType == "richiesta") ? "#<%=DataRichiestaDaTextBox.ClientID %>" : "#<%=DataInserimentoDaTextBox.ClientID %>";
			var dataAClientId = (comboType == "richiesta") ? "#<%=DataRichiestaATextBox.ClientID %>" : "#<%=DataInserimentoATextBox.ClientID %>";

			$(dataDaClientId).attr('disabled', 'disabled');
			$(dataAClientId).attr('disabled', 'disabled');

			switch ($(comboId).val()) {
				case " ":
					$(dataDaClientId).removeAttr('disabled');
					$(dataAClientId).removeAttr('disabled');

					if (!isLoading) {
						$(dataDaClientId).val('');
						$(dataAClientId).val('');
					}
					return;

				case "1": //ultima ora
					dataDa.setHours(today.getHours() - 1);
					$(dataDaClientId).val(formatDateTime(dataDa));
					break;

				case "2": //ultime 24 ore
					dataDa.setDate(today.getDate() - 1);
					$(dataDaClientId).val(formatDateTime(dataDa));
					break;

				case "3": //ultimi 7 giorni
					dataDa.setDate(today.getDate() - 7);
					$(dataDaClientId).val(formatDateTime(dataDa));
					break;

				case "4": //ultimi 30 giorni				
					dataDa.setDate(today.getDate() - 30);
					$(dataDaClientId).val(formatDateTime(dataDa));
					break;
			}

			$(dataAClientId).val(formatDateTime(today));

			if ($(comboId).val() != " ") {

				DataDaAOnChange(comboType);
			}
		}

		function DataDaAOnChange(comboType) {

			//resetta l'altro campo di filtro "data"
			var otherComboId = (comboType != "richiesta") ? "#<%=PeriodoRichiestaDropDownList.ClientID %>" : "#<%=PeriodoInserimentoDropDownList.ClientID %>";
			var otherDataDaClientId = (comboType != "richiesta") ? "#<%=DataRichiestaDaTextBox.ClientID %>" : "#<%=DataInserimentoDaTextBox.ClientID %>";
			var otherDataAClientId = (comboType != "richiesta") ? "#<%=DataRichiestaATextBox.ClientID %>" : "#<%=DataInserimentoATextBox.ClientID %>";

			$(otherComboId).val(" ");
			$(otherDataDaClientId).val("");
			$(otherDataAClientId).val("");

			$(otherDataDaClientId).removeAttr('disabled');
			$(otherDataAClientId).removeAttr('disabled');
		}

		//Cancella i filtri
		function ClearFilters() {

			$(".filters select").each(function () {
				$(this)[0].selectedIndex = 0;
			});

			$(".filters input").each(function () {
				$(this).val('');
			});

			var comboRichiestaId = "#<%=PeriodoRichiestaDropDownList.ClientID %>";

			$(comboRichiestaId).val("1");
			DateChanged("richiesta");
		}
	</script>
	<script type="text/javascript" src="../Scripts/ordini-richiesti.js"></script>
	<asp:ObjectDataSource ID="SistemiErogantiObjectDataSource" runat="server" OldValuesParameterFormatString="{0}"
		SelectMethod="GetLookupSistemiErogantiData" TypeName="DI.OrderEntry.Admin.OrdiniRichiesti"></asp:ObjectDataSource>
	<asp:ObjectDataSource ID="StatoObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetLookupStati"
		TypeName="DI.OrderEntry.Admin.OrdiniRichiesti"></asp:ObjectDataSource>
	<asp:ObjectDataSource ID="SistemiRichiedentiObjectDataSource" runat="server" OldValuesParameterFormatString="{0}"
		SelectMethod="GetLookupSistemiRichiedentiData" TypeName="DI.OrderEntry.Admin.OrdiniRichiesti"></asp:ObjectDataSource>
</asp:Content>
