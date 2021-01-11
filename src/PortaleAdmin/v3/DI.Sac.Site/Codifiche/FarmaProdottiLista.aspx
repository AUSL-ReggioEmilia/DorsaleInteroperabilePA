<%@ Page Title="Farma Lista Prodotti" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="FarmaProdottiLista.aspx.vb"
	Inherits=".FarmaProdottiLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />
	<table id="pannelloFiltri" runat="server" class="toolbar">
		<tr>
			<td colspan="9">
				<br />
			</td>
		</tr>
		<tr>
			<td>
				Codice Prodotto
			</td>
			<td>
				<asp:TextBox ID="txtFiltriCodiceProdotto" runat="server" Width="120px" MaxLength="16" />
			</td>
			<td>
				EAN
			</td>
			<td>
				<asp:TextBox ID="txtFiltriEAN" runat="server" Width="120px" MaxLength="16" />
			</td>
			<td>
				EMEA
			</td>
			<td>
				<asp:TextBox ID="txtFiltriEMEA" runat="server" Width="120px" MaxLength="20" />
			</td>
			<td>
				Descrizione
			</td>
			<td>
				<asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="180px" MaxLength="256" />
			</td>
			<td width="100%">
				<asp:Button ID="butFiltriRicerca" runat="server" CssClass="TabButton" Text="Cerca" />
			</td>
		</tr>
		<tr>
			<td colspan="9">
				<br />
			</td>
		</tr>
	</table>
	<br />
	<asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False" DataSourceID="odsLista"
		GridLines="Horizontal" PageSize="100" Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!"
		DataKeyNames="Id" CssClass="GridYellow">
		<AlternatingRowStyle CssClass="AlternatingRow"></AlternatingRowStyle>
		<HeaderStyle CssClass="Header"></HeaderStyle>
		<PagerSettings Position="TopAndBottom"></PagerSettings>
		<PagerStyle CssClass="Pager"></PagerStyle>
		<Columns>
			<asp:TemplateField HeaderText="Prodotto" SortExpression="CodiceProdotto">
				<ItemTemplate>
					<b>
						<%#Eval("CodiceProdotto")%>
					</b>
					<br />
					EAN:&nbsp;<%#Eval("CodiceEAN")%>
					<br />
					EMEA:&nbsp;<%#Eval("CodiceEMEA")%>
				</ItemTemplate>
			</asp:TemplateField>
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
			<asp:BoundField DataField="CodiceInternoDitta" HeaderText="Codice Interno Ditta" SortExpression="CodiceInternoDitta" />
			<asp:BoundField DataField="NoPrezzo" HeaderText="No Prezzo" SortExpression="NoPrezzo" />
			<asp:BoundField DataField="DataPrezzo1" HeaderText="Data Prezzo 1" SortExpression="DataPrezzo1" DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="TipoPrezzo1" HeaderText="Tipo Prezzo 1" SortExpression="TipoPrezzo1" />
			<asp:BoundField DataField="Prezzo1Euro" HeaderText="Prezzo 1 Euro" SortExpression="Prezzo1Euro" />
			<asp:BoundField DataField="DataPrezzo2" HeaderText="Data Prezzo 2" SortExpression="DataPrezzo2" DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="TipoPrezzo2" HeaderText="Tipo Prezzo 2" SortExpression="TipoPrezzo2" />
			<asp:BoundField DataField="Prezzo2Euro" HeaderText="Prezzo 2 Euro" SortExpression="Prezzo2Euro" />
			<asp:BoundField DataField="DataPrezzo3" HeaderText="Data Prezzo 3" SortExpression="DataPrezzo3" DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="TipoPrezzo3" HeaderText="Tipo Prezzo 3" SortExpression="TipoPrezzo3" />
			<asp:BoundField DataField="Prezzo3Euro" HeaderText="Prezzo 3 Euro" SortExpression="Prezzo3Euro" />
			<asp:BoundField DataField="UnitaDiMisura" HeaderText="Unità Di Misura" SortExpression="UnitaDiMisura" />
			<asp:BoundField DataField="PrezzoUMEuro" HeaderText="Prezzo UM Euro" SortExpression="PrezzoUMEuro" />
			<asp:BoundField DataField="TariffaDataVigore" HeaderText="Tariffa Data Vigore" SortExpression="TariffaDataVigore"
				DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="TariffaUM" HeaderText="Tariffa UM" SortExpression="TariffaUM" />
			<asp:BoundField DataField="TariffaEuro" HeaderText="Tariffa Euro" SortExpression="TariffaEuro" />
			<asp:BoundField DataField="DataDalDitta1" HeaderText="Data Dal Ditta 1" SortExpression="DataDalDitta1" DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="Ditta1Produttrice" HeaderText="Ditta 1 Produttrice" SortExpression="Ditta1Produttrice" />
			<asp:BoundField DataField="DivisioneDitta1" HeaderText="Divisione Ditta 1" SortExpression="DivisioneDitta1" />
			<asp:BoundField DataField="DataDalDitta2" HeaderText="Data Dal Ditta 2" SortExpression="DataDalDitta2" DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="Ditta2Produttrice" HeaderText="Ditta 2 Produttrice" SortExpression="Ditta2Produttrice" />
			<asp:BoundField DataField="DivisioneDitta2" HeaderText="Divisione Ditta 2" SortExpression="DivisioneDitta2" />
			<asp:BoundField DataField="DataDalAssInde1" HeaderText="Data Dal AssInde 1" SortExpression="DataDalAssInde1" DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="AssInde1" HeaderText="AssInde 1" SortExpression="AssInde1" />
			<asp:BoundField DataField="DataDalAssInde2" HeaderText="Data Dal AssInde 2" SortExpression="DataDalAssInde2" DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="AssInde2" HeaderText="AssInde 2" SortExpression="AssInde2" />
			<asp:BoundField DataField="DittaConcessionaria" HeaderText="Ditta Concessionaria" SortExpression="DittaConcessionaria" />
			<asp:BoundField DataField="DivisioneDittaConcessionaria" HeaderText="Divisione Ditta Concessionaria" SortExpression="DivisioneDittaConcessionaria" />
			<asp:BoundField DataField="ATC" HeaderText="ATC" SortExpression="ATC" />
			<asp:BoundField DataField="GruppoTerapeutico" HeaderText="Gruppo Terapeutico" SortExpression="GruppoTerapeutico" />
			<%--<asp:BoundField DataField="PrincipioAttivo" HeaderText="Principio Attivo" SortExpression="PrincipioAttivo" />--%>
			<asp:HyperLinkField DataNavigateUrlFormatString="FarmaPrincipiAttiviLista.aspx?Codice={0}" DataNavigateUrlFields="PrincipioAttivo"
				HeaderText="Principio Attivo" DataTextField="PrincipioAttivo" />
			<asp:BoundField DataField="DataPrimaRegistrazione" HeaderText="Data Prima Registrazione" SortExpression="DataPrimaRegistrazione"
				DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="DataInizioCommercio" HeaderText="Data Inizio Commercio" SortExpression="DataInizioCommercio"
				DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="Commercio" HeaderText="Commercio" SortExpression="Commercio" />
			<asp:BoundField DataField="SostituisceIl" HeaderText="Sostituisce Il" SortExpression="SostituisceIl" />
			<asp:BoundField DataField="SostituitoDa" HeaderText="Sostituito Da" SortExpression="SostituitoDa" />
			<asp:BoundField DataField="ProdottoBaseGenerico" HeaderText="Prodotto Base Generico" SortExpression="ProdottoBaseGenerico" />
			<asp:BoundField DataField="ProdottoDiRiferimento" HeaderText="Prodotto Di Riferimento" SortExpression="ProdottoDiRiferimento" />
			<asp:BoundField DataField="CodiceNomenclatore" HeaderText="Codice Nomenclatore" SortExpression="CodiceNomenclatore" />
			<asp:BoundField DataField="ProntuarioDal" HeaderText="Prontuario Dal" SortExpression="ProntuarioDal" DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="ProntuarioAl" HeaderText="Prontuario Al" SortExpression="ProntuarioAl" DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="DataDalSSNClasse1" HeaderText="Data Dal SSN Classe 1" SortExpression="DataDalSSNClasse1"
				DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="RegimeSSN1" HeaderText="Regime SSN 1" SortExpression="RegimeSSN1" />
			<asp:BoundField DataField="Classe1" HeaderText="Classe 1" SortExpression="Classe1" />
			<asp:BoundField DataField="DataDalSSNClasse2" HeaderText="Data Dal SSN Classe 2" SortExpression="DataDalSSNClasse2"
				DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="RegimeSSN2" HeaderText="Regime SSN 2" SortExpression="RegimeSSN2" />
			<asp:BoundField DataField="Classe2" HeaderText="Classe 2" SortExpression="Classe2" />
			<asp:BoundField DataField="DataDalPrescrivibilita1" HeaderText="Data Dal Prescrivibilità 1" SortExpression="DataDalPrescrivibilita1"
				DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="Prescrivibilita1" HeaderText="Prescrivibilità 1" SortExpression="Prescrivibilita1" />
			<asp:BoundField DataField="DataDalPrescrivibilita2" HeaderText="Data Dal Prescrivibilità 2" SortExpression="DataDalPrescrivibilita2"
				DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="Prescrivibilita2" HeaderText="Prescrivibilità 2" SortExpression="Prescrivibilita2" />
			<asp:BoundField DataField="DataDalTipoRicetta1" HeaderText="Data Dal Tipo Ricetta 1" SortExpression="DataDalTipoRicetta1"
				DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="TipoRicetta1" HeaderText="Tipo Ricetta 1" SortExpression="TipoRicetta1" />
			<asp:BoundField DataField="DataDalTipoRicetta2" HeaderText="Data Dal Tipo Ricetta 2" SortExpression="DataDalTipoRicetta2"
				DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="TipoRicetta2" HeaderText="Tipo Ricetta 2" SortExpression="TipoRicetta2" />
			<asp:BoundField DataField="DataDalNotePrescrizione1" HeaderText="Data Dal Note Prescrizione 1" SortExpression="DataDalNotePrescrizione1"
				DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="NoteSullaPrescrizione1" HeaderText="Note Sulla Prescrizione 1" SortExpression="NoteSullaPrescrizione1" />
			<asp:BoundField DataField="DataDalNotePrescrizione2" HeaderText="Data Dal Note Prescrizione 2" SortExpression="DataDalNotePrescrizione2"
				DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="NoteSullaPrescrizione2" HeaderText="Note Sulla Prescrizione 2" SortExpression="NoteSullaPrescrizione2" />
			<asp:BoundField DataField="TipoProdotto" HeaderText="Tipo Prodotto" SortExpression="TipoProdotto" />
			<asp:BoundField DataField="Caratteristica" HeaderText="Caratteristica" SortExpression="Caratteristica" />
			<asp:BoundField DataField="Obbligatorieta" HeaderText="Obbligatorietà" SortExpression="Obbligatorieta" />
			<asp:BoundField DataField="Forma" HeaderText="Forma" SortExpression="Forma" />
			<asp:BoundField DataField="Contenitore" HeaderText="Contenitore" SortExpression="Contenitore" />
			<asp:BoundField DataField="Stupefacente" HeaderText="Stupefacente" SortExpression="Stupefacente" />
			<asp:BoundField DataField="CodiceIVA" HeaderText="Codice IVA" SortExpression="CodiceIVA" />
			<asp:BoundField DataField="Temperatura" HeaderText="Temperatura" SortExpression="Temperatura" />
			<asp:BoundField DataField="Validita" HeaderText="Validità" SortExpression="Validita" />
			<asp:BoundField DataField="CodiceDegrassi" HeaderText="Codice Degrassi" SortExpression="CodiceDegrassi" />
			<asp:BoundField DataField="Particolare" HeaderText="Particolare" SortExpression="Particolare" />
			<asp:BoundField DataField="VendibilitaAl" HeaderText="Vendibilità Al" SortExpression="VendibilitaAl" />
			<asp:BoundField DataField="Ricommerciabilita" HeaderText="Ricommerciabilità" SortExpression="Ricommerciabilita" />
			<asp:BoundField DataField="RitiroDefinitivo" HeaderText="Ritiro Definitivo" SortExpression="RitiroDefinitivo" />
			<asp:BoundField DataField="DataInizioEsaurimento" HeaderText="Data Inizio Esaurimento" SortExpression="DataInizioEsaurimento"
				DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="DegrassiBDF400" HeaderText="Degrassi BDF400" SortExpression="DegrassiBDF400" />
			<asp:BoundField DataField="DataPrezzoRimborso" HeaderText="Data Prezzo Rimborso" SortExpression="DataPrezzoRimborso"
				DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="PrezzoMaxRimborsoEuro" HeaderText="Prezzo Max Rimborso Euro" SortExpression="PrezzoMaxRimborsoEuro" />
		</Columns>
	</asp:GridView>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="CodificheDataSetTableAdapters.FarmaProdottiTableAdapter"
		CacheDuration="120" CacheKeyDependency="CacheFarmaProdottiLista" EnableCaching="True">
		<SelectParameters>
			<asp:ControlParameter ControlID="txtFiltriCodiceProdotto" Name="CodiceProdotto" PropertyName="Text" Type="String" />
			<asp:ControlParameter ControlID="txtFiltriEAN" Name="CodiceEAN" PropertyName="Text" Type="String" />
			<asp:ControlParameter ControlID="txtFiltriEMEA" Name="CodiceEMEA" PropertyName="Text" Type="String" />
			<asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text" Type="String" />
			<asp:Parameter Name="Top" Type="Int32" DefaultValue="500" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
