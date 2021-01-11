<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/OrderEntry.Master" CodeBehind="OrdiniDettaglio.aspx.vb"
	Inherits="DI.OrderEntry.Admin.OrdiniDettaglio" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder" runat="server">
	<div id="headerPanel">
		<h4>
			Dettaglio Prestazioni</h4>
		<div class="separator" style="margin-top: 5px; margin-bottom: 5px;">
			<a id="aggiornaLink" href="#" onclick="Reload($.QueryString['Id']); return false;">Aggiorna</a> |
			<%-- | --%>
			<a href="../Messaggi/Stati.aspx?Id=<%=Request.QueryString("Id") %>" target="_blank">Visualizza stati</a> |
			<%-- | --%>
			<a href="../Messaggi/Richieste.aspx?Id=<%=Request.QueryString("Id") %>" target="_blank">Visualizza richieste</a>
			|
			<%-- | --%>
			<a href="<%=GetDispatcherUrl(Request.QueryString("Id")) %>" target="_blank">Visualizza stampe</a> |
			<%-- | --%>
			<a id="linkReferti" href="" target="_blank">Referti</a> |
			<%-- | --%>
			<a href="#" onclick="EliminaOrdine('<%=Request.QueryString("Id") %>'); return false;">Cancella ordine</a> |
			<%-- | --%>
			<a id="linkInoltraOrdine" style="display: none;" href="#" onclick="InoltraOrdine('<%=Request.QueryString("Id") %>'); return false;">
				Inoltra ordine</a><span id="spanInoltraOrdineDisabled" class="DisabledText">Inoltra ordine</span> |
			<%-- | --%>
			<a id="linkReinvioUltimoMess" style="display: none;" href="#" onclick="ReinoltraOrdine('<%=Request.QueryString("Id") %>'); return false;">
				Reinoltra ordine</a><span id="spanReinvioUltimoMessDisabled" class="DisabledText">Reinvio ultimo messaggio</span>
		</div>
		<div class="quadro" style="width: 355px;">
			<div class="quadroHeader">
				<span>Dati Ordine</span><img class="ordineRefresh" src="../Images/refresh.gif" width="14" height="14" alt="Caricamento..." />
			</div>
			<div class="separator">
			</div>
			<div class="quadroContent" style="height: 405px; margin-top: 0px; overflow: hidden;">
				<table>
					<tr>
						<td style="width: 140px;">
							<strong>Numero O.E.:</strong>
						</td>
						<td>
							<span id="NumeroOrdine"></span>
						</td>
					</tr>
					<tr>
						<td>
							<strong>Dati accessori:</strong>
						</td>
						<td>
							<a id="DatiAggiuntivi" href='#' class='xmlFixedPreviewLink' idoe='' progressivo='' onclick='return false;'>
								<img src='../Images/view.png' alt="visualizza dati" title="visualizza dati" /></a>
						</td>
					</tr>
					<tr>
						<td>
							<strong>Richiedente:</strong>
						</td>
						<td>
							<span id="SistemaRichiedente"></span>
						</td>
					</tr>
					<tr>
						<td style="vertical-align: top;">
							<strong>Id Ric. Richiedente:</strong>
						</td>
						<td>
							<span id="IdRichiestaRichiedente"></span>
						</td>
					</tr>
					<tr>
						<td style="vertical-align: top;">
							<strong>Unità Operativa<br />
								&nbsp;Richiedente:</strong>
						</td>
						<td>
							<span id="UnitaOperativaRichiedente"></span>
							<br />
							<span id="DescrizioneUnitaOperativaRichiedente"></span>
						</td>
					</tr>
					<tr>
						<td>
							<strong>Data richiesta:</strong>
						</td>
						<td>
							<span id="DataRichiesta"></span>
						</td>
					</tr>
					<tr>
						<td>
							<strong>Data inserimento:</strong>
						</td>
						<td>
							<span id="DataInserimento"></span>
						</td>
					</tr>
					<tr>
						<td>
							<strong>Utente inserimento:</strong>
						</td>
						<td>
							<span id="UtenteInserimento"></span>
						</td>
					</tr>
					<tr>
						<td>
							<strong>Data modifica:</strong>
						</td>
						<td>
							<span id="DataModifica"></span>
						</td>
					</tr>
					<tr>
						<td>
							<strong>Utente modifica:</strong>
						</td>
						<td>
							<span id="UtenteModifica"></span>
						</td>
					</tr>
					<tr>
						<td style="vertical-align: top;">
							<strong>Operatore:</strong>
						</td>
						<td>
							<span id="Operatore"></span>
						</td>
					</tr>
					<tr>
						<td>
							<strong>Data prenotazione:</strong>
						</td>
						<td>
							<span id="DataPrenotazione"></span>
						</td>
					</tr>
					<tr>
						<td>
							<strong>Regime:</strong>
						</td>
						<td>
							<span id="Regime"></span>
						</td>
					</tr>
					<tr>
						<td>
							<strong>Priorità:</strong>
						</td>
						<td>
							<span id="Priorita"></span>
						</td>
					</tr>
					<tr>
						<td>
							<strong>Nosologico:</strong>
						</td>
						<td>
							<span id="Nosologico"></span>
						</td>
					</tr>
					<tr>
						<td style="vertical-align: top;">
							<strong>Cod. Anagrafica:</strong>
						</td>
						<td>
							<span id="CodiceAnagrafica"></span>
						</td>
					</tr>
					<tr>
						<td style="vertical-align: top;">
							<strong>Stato:</strong>
						</td>
						<td>
							<span id="StatoOrderEntryDescrizione"></span>
						</td>
					</tr>
					<tr>
						<td style="vertical-align: top;">
							<strong>Dati paziente:</strong>
						</td>
						<td>
							<a href="" id="DatiAnagraficiPaziente"></a>
						</td>
					</tr>
				</table>
			</div>
		</div>
		<div class="quadro" style="height: 120px; width: 355px;">
			<div class="quadroHeader">
				<span>Tracking</span><img class="ordineRefresh" src="../Images/refresh.gif" width="14" height="14" alt="Caricamento..." /></div>
			<div class="separator">
			</div>
			<div id="trackingDiv" class="quadroContent" style="width: 100%; height: 405px; padding: 0px; margin: 0px;">
			</div>
		</div>
		<div id="validazioneQuadro" class="quadro" style="height: 120px; width: 355px; display: none;">
			<div class="quadroHeader">
				<span>Validazione ultimo messaggio</span><img class="ordineRefresh" src="../Images/refresh.gif" width="14" height="14"
					alt="Caricamento..." /></div>
			<div class="separator">
			</div>
			<div id="validazioneDiv" class="quadroContent" style="width: 100%; height: 405px; margin: 0px;">
			</div>
		</div>
	</div>
	<div id="newGridPanel">
	</div>
	<script type="text/javascript" src="../Scripts/ordini-dettaglio.js"></script>
</asp:Content>
