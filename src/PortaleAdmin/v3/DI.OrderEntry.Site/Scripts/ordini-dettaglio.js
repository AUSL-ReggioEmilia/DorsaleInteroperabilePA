$(document).ready(function () {

	$(".ordineRefresh").fadeIn();

	var idTestata = $.QueryString["Id"];

	LoadTestata(idTestata);
	LoadTracking(idTestata);
	LoadMessaggiValidazione(idTestata);
	LoadOrdiniData(idTestata);

	$("#aggiornaLink").attr('title', formatDateTime(new Date()));
});

function Reload(idTestata) {

	if ($(".ordineRefresh").css("display") != 'none')
		return;

	$(".ordineRefresh").fadeIn();

	LoadTestata(idTestata);
	LoadTracking(idTestata);
	LoadMessaggiValidazione(idTestata);
	LoadOrdiniData(idTestata);

	$("#aggiornaLink").attr('title', formatDateTime(new Date()));
}

function LoadTestata(idTestata) {

	$.ajax({
		type: "POST",
		url: "OrdiniDettaglio.aspx/GetDatiTestata",
		data: "{id:'" + idTestata + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			var ordine = result.d;

			if (ordine.StatoOrderEntry == 'HD' || ordine.StatoOrderEntry == 'MD') {				
				$("#validazioneQuadro").show();
			}
			
			//disabilito il link reinvio ultimo messaggio se lo stato è HD
			if (ordine.StatoOrderEntry == 'HD') {
				$("#linkInoltraOrdine").show();
				$("#spanInoltraOrdineDisabled").hide();
				$("#linkReinvioUltimoMess").hide();
				$("#spanReinvioUltimoMessDisabled").show();
			}
			else {
				//disabilito il link InoltraOrdine se lo stato è <> HD
				$("#linkInoltraOrdine").hide();
				$("#spanInoltraOrdineDisabled").show();
				$("#linkReinvioUltimoMess").show();
				$("#spanReinvioUltimoMessDisabled").hide();
			}

			$("#NumeroOrdine").html(ordine.NumeroOrdine);
			$("#SistemaRichiedente").html(ordine.SistemaRichiedente);
			$("#Regime").html(ordine.Regime);
			$("#Priorita").html(ordine.Priorita);
			$("#UnitaOperativaRichiedente").html(ordine.UnitaOperativaRichiedente);
			$("#DescrizioneUnitaOperativaRichiedente").html(ordine.DescrizioneUnitaOperativaRichiedente);
			$("#IdRichiestaRichiedente").html(ordine.IdRichiestaRichiedente);
			$("#CodiceAnagrafica").html(ordine.CodiceAnagrafica);
			$("#Nosologico").html(ordine.Nosologico);
			$("#DataRichiesta").html(ordine.DataRichiesta);
			$("#DataInserimento").html(ordine.DataInserimento);
			$("#UtenteInserimento").html(ordine.TicketInserimentoUserName);
			$("#DataModifica").html(ordine.DataModifica);
			$("#UtenteModifica").html(ordine.TicketModificaUserName);
			var sIDOperatore = (ordine.OperatoreId.toString().length > 0 ? '(' + ordine.OperatoreId + ')' : '');
			var sOperatore = [ordine.OperatoreCognome, ordine.OperatoreNome, sIDOperatore].join(' ');
			$("#Operatore").html(sOperatore);
			$("#DataPrenotazione").html(ordine.DataPrenotazione);
			$("#StatoOrderEntryDescrizione").html(ordine.StatoOrderEntryDescrizione);
			$("#DatiAnagraficiPaziente").html(ordine.DatiAnagraficiPaziente)
                                        .attr("href", ordine.LinkPazienteIdSac);

			$("#linkReferti").attr("href", ordine.LinkPazienteRefertiDwh);

			if ($("#DatiAggiuntivi").attr("idoe") == '') {

				$("#DatiAggiuntivi").attr("idoe", ordine.Id)
                                    .attr("progressivo", ordine.NumeroOrdine);

				BindServerXmlPreview(".xmlFixedPreviewLink", "OrdiniRichiesti.aspx/GetDatiAggiuntivi", "Dati Accessori", "idoe", "progressivo");
			}

		},

		//        error: function (error) { alert('Caricamento della testata: si è verificato un errore'); } //<----cambiare messaggio?
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});
}

function LoadTracking(idTestata) {

	$.ajax({
		type: "POST",
		url: "OrdiniDettaglio.aspx/GetTrackingData",
		data: "{idTestata:'" + idTestata + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			var html = new Array();

			html.push('<table class="Grid" style="width:100%; border-width:0px 1px 1px 0px; border-collapse:collapse;" border="1" cellspacing="0"><thead>'
                               + '<th>Data</th>'
                               + '<th>Sistema</th>'
                               + '<th>Stato O.E.</th>'
                               + '<th>Messaggio</th>'
                               + '</thead><tbody>');

			for (var i = 0; i < result.d.length; i++) {

				var messaggio = result.d[i];
				var rowColor = messaggio.Stato == 2 ? '#FA8C8C' : '#FFF';

				html.push('<tr style="background-color:' + rowColor + '">'
                               + '<td>' + formatJSONDate(messaggio.DataInserimento) + '</td>'
                               + '<td>' + messaggio.Sistema + '</td>'
                               + '<td>' + (messaggio.StatoOE ? messaggio.StatoOE : '') + '</td>'
                               + '<td><a target="_blank" href="XmlViewer.aspx?Id=' + messaggio.Id + '" class="xmlVersionContainer" dataInserimento="' + formatJSONDate(messaggio.DataInserimento) + '"'
                                  + ' idversion="' + messaggio.Id + '">'
                                  + '<img src="../Images/view.png" alt="visualizza dati" title="visualizza dati" /></a></td>'
                               + '</tr>');
			}

			html.push('</tbody></table>');

			$("#trackingDiv").html(html.join(""));
		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});
}

function LoadMessaggiValidazione(idTestata) {

	$.ajax({
		type: "POST",
		url: "OrdiniDettaglio.aspx/GetMessaggiValidazione",
		data: "{idTestata:'" + idTestata + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (!result.d) {
				return;
			}

			var html = result.d;
			$("#validazioneDiv").html(html);

		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});
}

function LoadOrdiniData(idTestata) {

	$.ajax({
		type: "POST",
		url: "OrdiniDettaglio.aspx/GetOrdineData",
		data: "{idTestata:'" + idTestata + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			var html = new Array();

			for (var i = 0; i < result.d.length; i++) {

				var ordineErogato = result.d[i];
				var testata = ordineErogato.TestataErogato;

				var idRichiestaErogante = testata.IdRichiestaErogante;

				if (!idRichiestaErogante)
					idRichiestaErogante = "-";

				// Tabella per lo stato esteso
				html.push('<table class="Grid" style="width:100%; border-bottom-width:0px;">');
				html.push('<caption style="text-align:left;padding-top: 20px; padding-bottom: 5px;font-size:11px; font-weight:bold;">Struttura Erogante - ' + (testata.CodiceSistemaErogante == '???' ? 'Profilo' : testata.CodiceAziendaSistemaErogante + ' ' + testata.CodiceSistemaErogante) + ' <img class="ordineRefresh" src="../Images/refresh.gif" width="14" height="14" /></caption>'
                          + '<thead><th>Id Ric. Erogante</th>'
                           + '<th>Stato O.E.</th>'
                           + '<th>Stato Erogante</th>'
                           + '<th>Stato Esteso</th></thead>'
                               + '<tbody><tr><td>' + idRichiestaErogante + '</td>'
                               + '<td>' + (testata.StatoOrderEntry ? testata.StatoOrderEntry : '-') + '</td>'
                               + '<td>' + (testata.StatoErogante ? testata.StatoErogante : '-') + '</td>'
                               + '<td><a href="#" class="xmlFixedPreviewLinkDatiAggiuntiviTestataErogante" numeroOrdine="' + idRichiestaErogante + '"'
                                  + ' idoe="' + testata.Id + '" onclick="return false;">'
                                  + '<img src="../Images/view.png" alt="visualizza dati" title="visualizza dati" /></a></td>'
                        + '</tr></tbody></table>');

				// Tabella per le righe richieste e le righe erogate
				html.push('<table class="Grid" style="width:100%;border-collapse:collapse;" border="1" cellspacing="0"><tr><th class="rigaRR" colspan="7">Righe Richiedente</th><th class="gridWhiteSpaceHeader"></th><th colspan="9">Righe Erogante</th></tr><tr>'
                               + '<th>Data Inserimento</th>'
                               + '<th>Data Modifica</th>'
                               + '<th>Data Modifica Stato</th>'
                               + '<th>Codice Prestazione</th>'
                               + '<th>Prestazione</th>'
                               + '<th>Stato O.E.</th>'
                               + '<th>Dati Accessori</th>'
                               + '<th class="gridWhiteSpaceHeader"></th>'
                               + '<th>Data Inserimento</th>'
                               + '<th>Data Modifica</th>'
                               + '<th>Data Modifica Stato</th>'
							   + '<th>Data Pianificata</th>'
                               + '<th>Stato O.E.</th>'
                               + '<th>Dati Accessori</th>'
                               + '</tr><tbody>');

				var prestazioni = [];
				for (var j = 0; j < ordineErogato.Righe.length; j++) {

					var riga = ordineErogato.Righe[j];

					var richiedenteColor = getColorForRichiedente(riga.StatoOrderEntryRichiedente);
					var eroganteColor = getColorForErogante(riga.StatoOrderEntryErogante);

					var arrowImageUrl = riga.IdRigaErogata ? '../Images/back.gif' : '../Images/next.gif';

					if (!prestazioni[riga.IdRigaRichiedente]) {

						prestazioni[riga.IdRigaRichiedente] = 1
					}
					else {

						prestazioni[riga.IdRigaRichiedente]++;
					}

					html.push('<tr class="RigaErogata" prestazione="' + testata.CodiceSistemaErogante + "-" + riga.PrestazioneCodice + '">'
                               + '<td style="background-color:' + richiedenteColor + '">' + formatJSONDate(riga.DataInserimentoRigaRichiesta) + '</td>'
                               + '<td style="background-color:' + richiedenteColor + '">' + formatJSONDate(riga.DataModificaRigaRichiesta) + '</td>'
                               + '<td style="background-color:' + richiedenteColor + '">' + formatJSONDate(riga.DataModificaStatoRigaRichiesta) + '</td>'
                               + '<td style="background-color:' + richiedenteColor + '">' + (riga.PrestazioneCodice ? riga.PrestazioneCodice : '') + '</td>'
                               + '<td style="background-color:' + richiedenteColor + '">' + (riga.PrestazioneDescrizione ? HtmlEncode(riga.PrestazioneDescrizione) : '') + '</td>'
                               + '<td style="background-color:' + richiedenteColor + '">' + (riga.StatoOrderEntryRichiedenteDescrizione ? riga.StatoOrderEntryRichiedenteDescrizione : '') + '</td>'
                               + '<td style="background-color:' + richiedenteColor + '; border-right:1px solid #c0c0c0;"><a href="#" class="xmlFixedPreviewLinkDatiAggiuntiviRR" codiceprestazione="' + riga.PrestazioneCodice + '"'
                                  + ' idoe="' + (riga.IdRigaRichiesta ? riga.IdRigaRichiesta : '') + '" onclick="return false;">'
                                  + '<img src="../Images/view.png" alt="visualizza dati" title="visualizza dati" /></a></td>'
                               + '<td class="gridWhiteSpaceHeader"><img src="' + arrowImageUrl + '" /></td>'
                               + '<td style="background-color:' + eroganteColor + '">' + formatJSONDate(riga.DataInserimentoRigaErogata) + '</td>'
                               + '<td style="background-color:' + eroganteColor + '">' + formatJSONDate(riga.DataModificaRigaErogata) + '</td>'
                               + '<td style="background-color:' + eroganteColor + '">' + formatJSONDate(riga.DataModificaStatoRigaErogata) + '</td>'
                               + '<td style="background-color:' + eroganteColor + '">' + formatJSONDate(riga.DataPianificataRigaErogata) + '</td>'
                               + '<td style="background-color:' + eroganteColor + '">' + (riga.StatoOrderEntryEroganteDescrizione ? riga.StatoOrderEntryEroganteDescrizione : '') + '</td>'
                               + '<td style="background-color:' + eroganteColor + '"><a href="#" class="xmlFixedPreviewLinkDatiAggiuntiviRE" codiceprestazione="' + riga.PrestazioneCodice + '"'
                                  + ' idoe="' + (riga.IdRigaErogata ? riga.IdRigaErogata : '') + '" onclick="return false;">'
                                  + '<img src="../Images/view.png" alt="visualizza dati" title="visualizza dati" /></a></td>'
                               + '</tr>');
				}

				html.push('</tbody></table>');
			}

			$("#newGridPanel").html(html.join(""));

			BindServerXmlPreview(".xmlFixedPreviewLinkDatiAggiuntiviTestataErogante", "OrdiniDettaglio.aspx/GetDatiAggiuntiviTestataErogata", "Stato Esteso", "idoe", "numeroOrdine");
			BindServerXmlPreview(".xmlFixedPreviewLinkDatiAggiuntiviRR", "OrdiniDettaglio.aspx/GetDatiAggiuntiviRigaRichiesta", "Dati Accessori Riga Richiesta", "idoe", "codicePrestazione");
			BindServerXmlPreview(".xmlFixedPreviewLinkDatiAggiuntiviRE", "OrdiniDettaglio.aspx/GetDatiAggiuntiviRigaErogata", "Dati Accessori Riga Erogata", "idoe", "codicePrestazione");

			SetLensVisibility();
			SetColumnToSameWidth();

			$(".ordineRefresh").fadeOut();

			//unisce le righe con la stessa prestazione
			for (prestazione in prestazioni) {

				var count = 0;
				$('.RigaErogata[prestazione="' + prestazione + '"]').each(function () {

					if (count == 0) {
						//prime 7 colonne
						$(this).find("td:nth-child(-n+7)").each(function () {

							$(this).attr("rowSpan", prestazioni[prestazione] + "");
						});
					}
					else {

						$(this).find("td:nth-child(-n+7)").each(function () {

							$(this).remove();
						});
					}

					count++;
				});
			}
		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});
}

function EliminaOrdine(id) {

	if (!confirm("L'ordine sarà cancellato, sei sicuro?"))
		return;

	$(".toolbarRefresh").fadeIn();

	$.ajax({
		type: "POST",
		url: "OrdiniDettaglio.aspx/EliminaOrdine",
		data: "{id:'" + id + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (result.d != "ok")
				alert(result.d);

			Reload(id);
			$(".toolbarRefresh").fadeOut();
		},
		error: function (error) {

			$(".toolbarRefresh").fadeOut();

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});
}

function InoltraOrdine(id) {

	if (!confirm("L'ordine sarà inoltrato, continuare?"))
		return;

	$(".toolbarRefresh").fadeIn();

	$.ajax({
		type: "POST",
		url: "OrdiniDettaglio.aspx/InoltraOrdine",
		data: "{id:'" + id + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (result.d != "ok")
				alert(result.d);

			Reload(id);
			$(".toolbarRefresh").fadeOut();
		},
		error: function (error) {

			$(".toolbarRefresh").fadeOut();

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});
}

function ReinoltraOrdine(id) {

	if (!confirm("L'ordine sarà reinoltrato, continuare?"))
		return;

	$(".toolbarRefresh").fadeIn();

	$.ajax({
		type: "POST",
		url: "OrdiniDettaglio.aspx/ReinoltraOrdine",
		data: "{id:'" + id + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (result.d != "ok")
				alert(result.d);

			Reload(id);
			$(".toolbarRefresh").fadeOut();
		},
		error: function (error) {

			$(".toolbarRefresh").fadeOut();

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});
}

function SetLensVisibility() {

	$(".xmlFixedPreviewLinkDatiAggiuntiviRR, .xmlFixedPreviewLinkDatiAggiuntiviRE, .xmlFixedPreviewLinkDatiAggiuntiviTestataErogante").each(function () {

		if (!$(this).attr("idoe") || $(this).attr("idoe") == "") $(this).hide();
	});
}

function SetColumnToSameWidth() {

	$('.rigaRR').width(Math.max.apply(Math, $('.rigaRR').map(function () { return $(this).width(); }).get()));
}

function getColorForErogante(statusCode) {

	switch (statusCode) {

		case 'CA':

			return '#FA8C8C';
			break;

		case 'CM':

			return '#90EE90';
			break;

		case 'IC':

			return '#63C3FF';
			break;

		case 'IP':

			return '#63C3FF';
			break;


		default:
			return '#D3D3D3';
			break;
	}
}

function getColorForRichiedente(statusCode) {

	switch (statusCode) {

		case 'CA':

			return '#FA8C8C';
			break;

		case 'IS':

			return '#90EE90';
			break;

		case 'MD':

			return '#63C3FF';
			break;

		default:
			return '#D3D3D3';
			break;
	}
}

function sendByPost(base64) {

	$.ajax({
		type: "POST",
		url: "OrdiniDettaglio.aspx/SaveBase64AndGetId",
		data: "{base64:'" + base64 + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (base64 && base64 != '')
				window.open('PdfViewer.aspx?id=' + encodeURIComponent(result.d));
			else
				alert("File non trovato.")
		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});
}