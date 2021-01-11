<%@ Page Title="Richieste" Language="vb" AutoEventWireup="false" MasterPageFile="~/OrderEntry.Master" CodeBehind="Stati.aspx.vb"
	Inherits="DI.OrderEntry.Admin.Stati" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder" runat="server">
	<span class="Bold">Ricerca (<a id="linkFiltroAvanzato" href="#" onclick="javascript:ToggleFilter(); setIsFiltroEspanso(); return false;">avanzata</a>)</span>
	<div id="filterPanel" runat="server">
		<fieldset class="filters">
			<legend>Generale</legend>
			<div class="NoRequiredField">
				<span>Numero Ordine O.E.</span>
				<asp:TextBox ID="AnnoTextBox" MaxLength="4" Width="40px" runat="server" />
				&nbsp;/
				<asp:TextBox ID="NumeroTextBox" runat="server" Width="100px" />
			</div>
			<div>
				<span>Periodo da visualizzare</span>
				<asp:DropDownList ID="PeriodoInserimentoDropDownList" onchange="DateChanged(); return false;" runat="server" Width="100%">
					<asp:ListItem Value=" " Text=""></asp:ListItem>
					<asp:ListItem Value="1">ultima ora</asp:ListItem>
					<asp:ListItem Value="2" Selected="true">ultime 24 ore</asp:ListItem>
					<asp:ListItem Value="3">ultimi 7 giorni</asp:ListItem>
					<asp:ListItem Value="4">ultimi 30 giorni</asp:ListItem>
				</asp:DropDownList>
			</div>
			<div>
				<span>Data modifica da</span>
				<asp:TextBox ID="DataInserimentoDaTextBox" runat="server" Width="165px"></asp:TextBox>
			</div>
			<div>
				<span>a</span>
				<asp:TextBox ID="DataInserimentoATextBox" runat="server" Width="165px"></asp:TextBox>
			</div>
			<div>
				<span>Stato</span>
				<asp:DropDownList ID="StatoDropDownList" runat="server" Width="100%">
					<asp:ListItem Value=" " Text=""></asp:ListItem>
					<asp:ListItem Value="0">Inserito</asp:ListItem>
					<asp:ListItem Value="1">Processato</asp:ListItem>
					<asp:ListItem Selected="True" Value="2">Errore</asp:ListItem>
				</asp:DropDownList>
			</div>
		</fieldset>
		<fieldset class="filters">
			<legend>Sistema Richiedente</legend>
			<div class="NoRequiredField">
				<span>Azienda</span>
				<asp:DropDownList ID="AziendaRichiedenteComboBox" runat="server" DataSourceID="AziendaLookupObjectDataSource" DataTextField="Codice"
					DataValueField="Codice" Width="100%">
				</asp:DropDownList>
				<asp:ObjectDataSource ID="AziendaLookupObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
					SelectMethod="GetLookupAziendeData" TypeName="DI.OrderEntry.Admin.OrdiniRichiesti"></asp:ObjectDataSource>
			</div>
			<div>
				<span>Codice Sistema</span>
				<asp:TextBox ID="CodiceSistemaRichiedenteTextBox" runat="server" Width="165px" />
			</div>
			<div>
				<span>Numero Ordine</span>
				<asp:TextBox ID="IdRichiestaTextBox" runat="server" Width="165px" />
			</div>
			<div style="display: none;">
				<span>Campo nascosto</span>
				<asp:TextBox ID="FiltroAvanzatoTextBox" runat="server" Text="chiuso"></asp:TextBox>
			</div>
		</fieldset>
	</div>
	<div style="width: 80px; display: inline-block;">
		<asp:Button ID="SearchButton" Text="Cerca" runat="server" CssClass="Button" Style="margin-top: 11px;" />
		<asp:Button ID="ClearFilterButton" Text="Annulla" runat="server" CssClass="Button" OnClientClick="ClearFilters();"
			Style="margin-top: 4px;" />
	</div>
	<div class="separator">
	</div>
	<div id="gridPanel">
		<asp:GridView ID="StatiGridView" runat="server" AllowPaging="True" AllowSorting="True" CssClass="Grid" AutoGenerateColumns="False"
			DataKeyNames="ID" DataSourceID="MainObjectDataSource" EnableModelValidation="True" PageSize="100" Width="100%">
			<AlternatingRowStyle CssClass="GridAlternatingItem" />
			<HeaderStyle CssClass="GridHeader" />
			<PagerStyle CssClass="GridPager" />
			<SelectedRowStyle CssClass="GridSelected" />
			<RowStyle CssClass="GridItem" />
			<Columns>
				<asp:BoundField DataField="DataInserimento" HeaderText="Data Inserimento" SortExpression="DataInserimento" />
				<asp:BoundField DataField="DataModifica" HeaderText="Data Modifica" SortExpression="DataModifica" />
				<asp:TemplateField HeaderText="Numero Ordine O.E." SortExpression="Protocollo">
					<ItemTemplate>
						<a id="DettaglioHyperLink" href='<%# String.Format("../Ordini/OrdiniDettaglio.aspx?Id={0}", Eval("IDOrdineTestata"))%>'>
							<%#Eval("Protocollo") %></a>
					</ItemTemplate>
				</asp:TemplateField>
				<asp:BoundField DataField="CodiceAziendaRichiedente" HeaderText="Codice Azienda S.R." SortExpression="CodiceAziendaRichiedente" />
				<asp:BoundField DataField="CodiceSistemaRichiedente" HeaderText="Codice S.R." SortExpression="CodiceSistemaRichiedente" />
				<asp:BoundField DataField="IDRichiestaRichiedente" HeaderText="Numero Ordine S.R." SortExpression="IDRichiestaRichiedente" />
				<asp:TemplateField HeaderText="Messaggio Originale">
					<ItemTemplate>
						<a href='#' class='xmlFixedPreviewLink' idmessaggio='<%# Eval("Id") %>' onclick='return false;'>
							<img src='../Images/view.png' alt="visualizza dati" title="visualizza dati" /></a>
					</ItemTemplate>
				</asp:TemplateField>
				<asp:BoundField DataField="DettaglioErrore" HeaderText="Dettaglio Errore" ReadOnly="True" SortExpression="DettaglioErrore" />
			</Columns>
		</asp:GridView>
		<asp:ObjectDataSource ID="MainObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData"
			TypeName="DI.OrderEntry.Admin.Data.MessaggiTableAdapters.UiMessaggiStatiListTableAdapter">
			<SelectParameters>
				<asp:ControlParameter ControlID="DataInserimentoDaTextBox" Name="dataModificaDa" Type="DateTime" ConvertEmptyStringToNull="true"
					PropertyName="Text" />
				<asp:ControlParameter ControlID="DataInserimentoATextBox" Name="dataModificaA" Type="DateTime" ConvertEmptyStringToNull="true"
					PropertyName="Text" />
				<asp:Parameter Name="Stato" Type="Byte" ConvertEmptyStringToNull="true" />
				<asp:ControlParameter ControlID="AziendaRichiedenteComboBox" Name="codiceAziendaRichiedente" PropertyName="SelectedValue"
					Type="String" ConvertEmptyStringToNull="true" />
				<asp:ControlParameter ControlID="CodiceSistemaRichiedenteTextBox" Name="codiceSistemaRichiedente" PropertyName="Text"
					Type="String" ConvertEmptyStringToNull="true" />
				<asp:ControlParameter Name="anno" Type="Int32" ControlID="AnnoTextBox" ConvertEmptyStringToNull="true" PropertyName="Text" />
				<asp:ControlParameter Name="numero" Type="Int32" ControlID="NumeroTextBox" ConvertEmptyStringToNull="true" PropertyName="Text" />
				<asp:ControlParameter Name="IDRichiestaRichiedente" Type="String" ControlID="IdRichiestaTextBox" ConvertEmptyStringToNull="true"
					PropertyName="Text" />
				<asp:QueryStringParameter Name="IDOrdineTestata" Type="String" QueryStringField="Id" />
			</SelectParameters>
		</asp:ObjectDataSource>
	</div>
	<script type="text/javascript">
	
		function getIsFiltroEspanso() {

			return $('#<%=FiltroAvanzatoTextBox.ClientID %>').val();
		}

		function setIsFiltroEspanso() {

			var isFiltroEspanso = getIsFiltroEspanso();
			if (isFiltroEspanso == '') isFiltroEspanso = 'chiuso';
			$('#<%=FiltroAvanzatoTextBox.ClientID %>').val(isFiltroEspanso == 'chiuso' ? 'aperto' : 'chiuso');
		}

		function DateChanged() {

			var today = new Date();
			var dataDa = new Date();
			var comboId = "#<%=PeriodoInserimentoDropDownList.ClientID %>";
			var dataDaClientId = "#<%=DataInserimentoDaTextBox.ClientID %>";
			var dataAClientId = "#<%=DataInserimentoATextBox.ClientID %>";

			switch ($(comboId).val()) {

				case " ":
				/*	$(dataDaClientId).val('');
					$(dataAClientId).val('');*/
					return;

				case "1": //ultima ora        
					dataDa.setHours(today.getHours() - 1);
					break;

				case "2": //ultime 24 ore
					dataDa.setDate(today.getDate() - 1);
					break;

				case "3": //ultimi 7 giorni
					dataDa.setDate(today.getDate() - 7);
					break;

				case "4": //ultimi 30 giorni
					dataDa.setDate(today.getDate() - 30);
					break;
			}
	
			$(dataDaClientId).val(formatDateTime(dataDa));
			$(dataAClientId).val(formatDateTime(today));

		} //);
		//});
	</script>
	<script type="text/javascript" src="../Scripts/messaggi-stati.js"></script>
</asp:Content>
