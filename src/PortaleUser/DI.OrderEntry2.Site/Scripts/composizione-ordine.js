$(document).ready(function () {



	//#region	
	
	////Creo i datetimepicker.
	//$('.form-control-datatimepicker').datetimepicker({
	//    //sull'evento onClose del datetimepicker salvo l'ordine.
	//    onClose: function () { saveRequest(SalvaRichiesta); }
	//});


	//Modifica di SimoneB il 26/01/2017
	// Quando navigo in un'altra pagina segnalo che l'ordine non è stato inoltrato.
	//$(".navbar li:not('.has-popup,.dropdown') a").click(function () {
	//    var message = 'Attenzione: Ordine non inserito. Continuare comunque?'
	//    var url = $(this).attr('href');
	//    var result = ConfirmMessage(message, url);
	//    if (result == false) {
	//        return false;
	//    };
	//});


//RIEMPIE LA DROPDOWN CON LE UNITÀ OPERATIVE
//function LoadUnitaOperativa(aziendauo) {
	//OTTIENE LA COMBO DELLE UNITÀ OPERATIVE.
	//_idComboUO È UNA VARIABILE DEFINITA NEL MARKUP DELLA PAGINA ComposizioneOrdine.aspx
//	var uoSelect = $("#" + _idComboUO);

//	//DISABILITA LA COMBO. 
//	//IN QUESTO MODO SE SI DOVESSERO VERIFICARE DEGLI ERRORE LA COMBO SAREBBE DISABILITATA.
//	uoSelect.attr('disabled', 'disabled');

//	//OTTIENE IL NOSOSLOGICO DAL QUERY STRING.
//	var nosologico = $.QueryString['Nosologico'] ? $.QueryString['Nosologico'] : '';

//	//CHIAMATA AJAX
//	$.ajax({
//		type: "POST",
//		url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/GetLookupUnitaOperative",
//		data: "{'idPaziente':'" + $.QueryString['IdPaziente'] + "', 'nosologico':'" + nosologico + "', 'aziendauo':'" + aziendauo + "'}",
//		contentType: "application/json; charset=utf-8",
//		dataType: "json",
//		async: false,
//		success: function (result) {
//			//PER OGNI ITEM DELLA LISTA DELLE UNITA' OPERATIVE.
//			for (var i = 0; i < result.d.length; i++) {
//				//OTTENGO L'UNITÀ OPERATIVA.
//				var unitaOperaivaDesc = result.d[i].DescrizioneUO

//				//SE L'UNITà OPERATIVA è NULL ALLORA MOSTRO UNA STRINGA VUOTA. 
//				//PER EVITARE CHE VENGA INSERITO NELLA COMBO UN VALORE "null"
//				if (unitaOperaivaDesc == null) {
//					unitaOperaivaDesc = ""
//				};

//				//AGGIUNGE UN <option> ALLA COMBO DELLE UNITA' OPERATIVE.
//				uoSelect.append("<option value='" + result.d[i].CodiceUO + "'>" + result.d[i].DescrizioneUO + "</option>");
//			}
//			//RIMUOVE L'ATTRIBUTO "DISABLED" DALLA COMBO.
//			uoSelect.removeAttr('disabled');
//		},
//		error: function (error) { var message = GetMessageFromAjaxError(error.responseText); alert(message); } //GESTIONE ERRORE.
//	});
//}

//riempie la DropDown con i Regimi
//function LoadRegimi(currentregime) {

//	var regimeSelect = $("#RegimeSelect");

//	regimeSelect.attr('disabled', 'disabled');

//	var nosologico = $.QueryString['Nosologico'] ? $.QueryString['Nosologico'] : '';
//	var aziendauo = $.QueryString['AziendaUo'] ? $.QueryString['AziendaUo'] : '';

//	$.ajax({
//		type: "POST",
//		url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/GetLookupRegimi",
//		data: "{'idPaziente':'" + $.QueryString['IdPaziente'] + "', 'nosologico':'" + nosologico + "', 'currentregime':'" + currentregime + "', 'aziendauo':'" + aziendauo + "' }",
//		contentType: "application/json; charset=utf-8",
//		dataType: "json",
//		async: false,
//		success: function (result) {

//			for (var i = 0; i < result.d.length; i++) {

//				regimeSelect.append("<option value='" + result.d[i].Key + "'>" + result.d[i].Value + "</option>");
//			}

//			regimeSelect.removeAttr('disabled');
//		},
//		error: function (error) { }
//	});
//}
	// #endregion

	//eseguo le chiamate ajax per caricare tutti i pannelli della pagina
	//LoadPriorita();
	LoadRichiesta();
	LoadListaGruppiPrestazioni();
	GetDatiAccessori();
	//LoadAziende();

	//$('#dettaglioPaziente').load('DettaglioPaziente.aspx?Id=' + $.QueryString["IdPaziente"] + ($.QueryString["Nosologico"] ? '&Nosologico=' + $.QueryString["Nosologico"] : '') + ' #dettaglio', function () {
	//    LoadEsenzioniContainer();
	//    LoadRicoveriContainer();
	//    LoadRefertiContainer();
	//});
	
	//$(".gridCheckBox").change(function () {
	//	var checked = $(this).attr('checked');
	//	if (checked == 'checked') {
	//		$(this).parent().parent().addClass('GridSelected');
	//	} else {
	//		$(this).parent().parent().removeClass('GridSelected');
	//	}
	//});

	// Richiamo la funzione FiltroSelettoriClick passandogli il tab da visualizzare di default.
	//FiltroSelettoriClick($("#GruppiPrestazioniButton"), 'gruppiprestazioni');

	// cambio il testo e l'icone del bottone che collassa il panel di ricerca delle prestazioni
	//$('#selettorePrestazioni').on('hidden.bs.collapse', function () {
	//	$("#collapseBtn").html("Mostra Ricerca " + "<span class='glyphicon glyphicon-chevron-down' aria-hidden='true'>");
	//})
	//$('#selettorePrestazioni').on('shown.bs.collapse', function () {
	//	$("#collapseBtn").html("Nascondi Ricerca " + "<span class='glyphicon glyphicon-chevron-up' aria-hidden='true'>");
	//})

});


//function LoadPriorita() {

//	var prioritaSelect = $("#PrioritaSelect");

//	prioritaSelect.attr('disabled', 'disabled');

//	$.ajax({
//		type: "POST",
//		url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/GetLookupPriorita",
//		data: "{}",
//		contentType: "application/json; charset=utf-8",
//		dataType: "json",
//		async: false,
//		success: function (result) {

//			for (var priorita in result.d) {

//				prioritaSelect.append("<option value='" + priorita + "'>" + result.d[priorita] + "</option>");
//			}

//			prioritaSelect.removeAttr('disabled');
//		},
//		error: function (error) { }
//	});
//}

//function LoadAziende() {

//	var aziendaSelect = $("#ddlAziende");

//	$.ajax({
//		type: "POST",
//		url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/GetLookupAziende",
//		data: "{}",
//		contentType: "application/json; charset=utf-8",
//		dataType: "json",
//		success: function (result) {

//			for (var azienda in result.d) {

//				aziendaSelect.append("<option value='" + azienda + "'>" + result.d[azienda] + "</option>");
//			}

//			LoadSistemiEroganti();
//		},
//		error: function (error) { var message = GetMessageFromAjaxError(error.responseText); alert(message); }
//	});
//}

//function LoadSistemiEroganti() {

//	var sistemiSelect = $("#ddlSistemiEroganti");
//	var azienda = $("#AziendaEroganteSelect").val();

//	sistemiSelect.html('');
//	sistemiSelect.attr('disabled', 'disabled');

//	$.ajax({
//		type: "POST",
//		url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/GetLookupSistemiEroganti",
//		data: "{'azienda': '" + azienda + "'}",
//		contentType: "application/json; charset=utf-8",
//		dataType: "json",
//		success: function (result) {

//			sistemiSelect.append("<option value='" + "" + "'>" + "Tutti" + "</option>");

//			for (var sistema in result.d) {
//				var descrizione = result.d[sistema] ? result.d[sistema] : sistema;
//				sistemiSelect.append("<option value='" + sistema + "'>" + descrizione + "</option>");
//			}
//			sistemiSelect.removeAttr('disabled');
//		},
//		error: function (error) {

//		}
//	});
//}

function LoadListaGruppiPrestazioni() {
	var gruppiPreferitiSelect = $("#GruppiPreferitiSelect");

	var codiceDescrizione = $("#filtroSelettoreDescrizione").val();
	//var regime = $("#RegimeSelect").val();
	//var priorita = $("#PrioritaSelect").val();
	//var uo = $("#" + _idComboUO).val();

	var gpaziendaErogante = "";
	var gpsistemaErogante = "";

	gruppiPreferitiSelect.html('');
	gruppiPreferitiSelect.attr('disabled', 'disabled');

	$.ajax({
		type: "POST",
		url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/GetListaGruppiPrestazioniPreferiti",
		data: "{'uo':'" + uo + "','aziendaErogante':'" + gpaziendaErogante + "','sistemaErogante':'" + gpsistemaErogante + "','codiceDescrizione':'" + codiceDescrizione + "','regime':'" + regime + "','priorita':'" + priorita + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function (result) {
			if (result.d == null) {
				return;
			}

			for (var i = 0; i < result.d.length; i++) {

				var riga = result.d[i];

				var id = riga.Id;
				var descrizione = riga.Descrizione;
				var numeroPrestazioni = riga.NumeroPrestazioni;

				if (descrizione) {
					gruppiPreferitiSelect.append("<option value='" + id + "'>" + descrizione + "</option>");
				} else {
					gruppiPreferitiSelect.append("<option value='" + id + "'>" + id + "</option>");
				}
				gruppiPreferitiSelect.attr('NumeroPrestazioni', numeroPrestazioni)

			}
			gruppiPreferitiSelect.removeAttr('disabled');
		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText); alert(message);
		}
	});

}

function GetDatiAccessori() {

	var avantiButton = $("#VaiAComposizioneDatiAccessoriButton");
	avantiButton.unbind("click");

	var datiAccessori = $("#datiAccessori");

	datiAccessori.html('');
	datiAccessori.css('background', 'white url(../Images/refresh.gif) no-repeat center center');

	$.ajax({
		type: "POST",
		url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/GetDomandeDatiAccessori",
		data: "{'idRichiesta': '" + $.QueryString['IdRichiesta'] + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (!result.d) {

				datiAccessori.css('background-image', "none");
				avantiButton.click(function () {
					location.href = "ConfermaInoltro.aspx?IdRichiesta=" + $.QueryString['IdRichiesta'] + "&IdPaziente=" + $.QueryString['IdPaziente'] + ($.QueryString['Nosologico'] ? ('&Nosologico=' + $.QueryString['Nosologico']) : '');
				});
				return;
			}
			else {
				avantiButton.click(function () {
					location.href = "DatiAccessori.aspx?IdRichiesta=" + $.QueryString['IdRichiesta'] + "&IdPaziente=" + $.QueryString['IdPaziente'] + ($.QueryString['Nosologico'] ? ('&Nosologico=' + $.QueryString['Nosologico']) : '');
				});
			}

			var html = [];

			for (var domanda in result.d) {
				html.push("<li> " + result.d[domanda] + "</li>");
			}

			datiAccessori.css('background-image', "none");
			datiAccessori.html(html.join(''));
		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText); alert(message);
			datiAccessori.css('background-image', "none");
		}
	});
}

_canSave = true;

function LoadRichiesta() {


	var idRichiesta = $.QueryString['IdRichiesta'];

	if (!idRichiesta) return;

	$("#loaderGrigliaPrestazioni").show();

	$.ajax({
		type: "POST",
		url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/GetRichiesta",
		data: "{'id': '" + idRichiesta + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function (result) {

			//if (result.d == null) {

			//	$("#loaderGrigliaPrestazioni").fadeOut();
			//	return;
			//}

			//var uoSelect = $("#" + _idComboUO);
			//var prioritaSelect = $("#PrioritaSelect");
			//var regimeSelect = $("#RegimeSelect");
			//var dataPrenotazioneTextBox = $("#DataPrenotazioneTextBox");

			//$("#IdRichiestaText").html(result.d.Progressivo);
			//$("#StatoText").html(result.d.Stato);

			//LoadUnitaOperativa(result.d.Azienda + '-' + result.d.UnitaOperativa);
			//LoadRegimi(result.d.Regime);
			//MODIFICA ETTORE 2017-03-31: la selezione dell'item della combo veniva fatta con un valore sbagliato (veniva usato solo result.d.UnitaOperativa) 
			//nel caso di un solo item il problema non si evidenziava rimanendo visibile l'unico item. Con più item si selezionava sempre il primo
			//NOTA: la versione di IE usata da questo progetto se si tenta di eseguire la selezione di una combo con un valore che non esiste seleziona il primo item della combo)
			//uoSelect.val(result.d.Azienda + '-' + result.d.UnitaOperativa);

			//prioritaSelect.val(result.d.Priorita);
			//regimeSelect.val(result.d.Regime);

			//dataPrenotazioneTextBox.val(result.d.DataPrenotazione);

			//if (result.d.Stato != 'Inserito' && result.d.Stato != 'Modificato') {

			//	_canSave = false;

			//	location.href = "RiassuntoOrdine.aspx?IdRichiesta=" + $.QueryString['IdRichiesta'] + "&IdPaziente=" + $.QueryString['IdPaziente'] + ($.QueryString['Nosologico'] ? ('&Nosologico=' + $.QueryString['Nosologico']) : '');
			//}

			var prestazioni = result.d.Prestazioni;

			addPrestazioni(prestazioni);

			if (!result.d.Valido) {

				var validationIcon = $("#ValidationError");

				validationIcon.show();
				validationIcon.attr("title", result.d.DescrizioneStatoValidazione);
			}

			$("#loaderGrigliaPrestazioni").fadeOut();

			//GetDatiAccessori();
		},
		error: function (error) {

			$("#loaderGrigliaPrestazioni").fadeOut();
			var message = GetMessageFromAjaxError(error.responseText); alert(message);
		}
	});
}

function ReloadPrestazioni() {

	$("#loaderGrigliaPrestazioni").show();

	var idRichiesta = $.QueryString['IdRichiesta'];

	if (!idRichiesta) return;

	$.ajax({
		type: "POST",
		url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/GetRichiesta",
		data: "{'id': '" + idRichiesta + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (result.d == null) {
				$("#loaderGrigliaPrestazioni").fadeOut();
				return;
			}
			//body delle prestazioni inserite
			$("#tabellaPrestazioniBody a").each(function () {

				$(this).parent().parent().remove();

				$("#emptyGridRow").show();

				//disabilito il tasto avanti
				$("#VaiAComposizioneDatiAccessoriButton").attr("disabled", "disabled");
			});

			var prestazioni = result.d.Prestazioni;
			addPrestazioni(prestazioni);

			$("#loaderGrigliaPrestazioni").fadeOut();

			GetDatiAccessori();

			var validationIcon = $("#ValidationError");

			if (!result.d.Valido) {
				validationIcon.fadeIn();
				validationIcon.attr("title", result.d.DescrizioneStatoValidazione);
			} else {

				validationIcon.fadeOut();
			}

		},
		error: function (error) {

			$("#loaderGrigliaPrestazioni").fadeOut();

			var message = GetMessageFromAjaxError(error.responseText); alert(message);
		}
	});
}

function searchPrestazioni() {

	if ($('#searchPrestazioniButton').attr("disabled") == "disabled")
		return;

	var codiceDescrizione = $('#filtroSelettoreDescrizione').val();
	var regime = $("#RegimeSelect ").val();
	var priorita = $("#PrioritaSelect ").val();
	var uo = $("#" + _idComboUO).val();

	switch (_currentSelectorType) {

		case "gruppiprestazioni":

			var idGruppoPrestazioni = $("#GruppiPreferitiSelect").val();

			if (idGruppoPrestazioni != null) {
				loadData("AjaxWebMethods/ComposizioneOrdineMethods.aspx/GetListaPrestazioniPerGruppi", "{'regime':'" + regime + "','priorita':'" + priorita + "','uo':'" + uo + "','idGruppo':'" + idGruppoPrestazioni + "','descrizione':'" + codiceDescrizione + "'}");
			}

			break;
		case "erogante":

			var aziendaErogante = $('#ddlAziende').val();
			var sistemaErogante = $('#ddlSistemiEroganti').val();

			loadData("AjaxWebMethods/ComposizioneOrdineMethods.aspx/GetListaPrestazioniPerErogante", "{'uo':'" + uo + "','aziendaErogante':'" + aziendaErogante + "','sistemaErogante':'" + sistemaErogante + "','codiceDescrizione':'" + codiceDescrizione + "','regime':'" + regime + "','priorita':'" + priorita + "'}");
			break;

		case "recenti":

			loadData("AjaxWebMethods/ComposizioneOrdineMethods.aspx/GetListaPrestazioniRecentiPerUO", "{'uo':'" + uo + "','codiceDescrizione':'" + codiceDescrizione + "','regime':'" + regime + "','priorita':'" + priorita + "'}");
			break;

		case "recentiPaziente":

			loadData("AjaxWebMethods/ComposizioneOrdineMethods.aspx/GetListaPrestazioniRecentiPerPaziente", "{'uo':'" + uo + "','idPaziente':'" + $.QueryString['IdPaziente'] + "','codiceDescrizione':'" + codiceDescrizione + "','regime':'" + regime + "','priorita':'" + priorita + "'}");
			break;

		case "profili":

			loadData("AjaxWebMethods/ComposizioneOrdineMethods.aspx/GetListaProfili", "{'uo':'" + uo + "','codiceDescrizione':'" + codiceDescrizione + "','regime':'" + regime + "','priorita':'" + priorita + "'}");
			break;

		case "profiliPersonali":

			loadData("AjaxWebMethods/ComposizioneOrdineMethods.aspx/GetListaProfiliPersonali", "{'uo':'" + uo + "','codiceDescrizione':'" + codiceDescrizione + "','regime':'" + regime + "','priorita':'" + priorita + "'}");
			break;
	}
}

var _currentSelectorType = 'gruppiprestazioni';
function FiltroSelettoriClick(button, type) {
	$('#divNoPrestazioni').show();
	_currentSelectorType = type;
	$('.nav-stacked input').removeClass('btn-primary');
	button.addClass('btn-primary');
	$('#filtroSelettoreDescrizione').val('');
	$("#NumberOfPrestazioni").html('');
	switch (type) {

		case "gruppiprestazioni":

			$("#erogantePanel").hide();
			$("#gruppiprestazioniPanel").show();
			break;

		case "erogante":

			$("#gruppiprestazioniPanel").hide();
			$("#erogantePanel").show();
			break;

		default:

			$("#erogantePanel").hide();
			$("#gruppiprestazioniPanel").hide();
			break;
	}
}

function getPrestazioneFromBarcode() {

	var aziendaSistemaEroganteCodicePrestazione = $('#CodicePrestazioneTextBox').val();
	var regime = $("#RegimeSelect ").val();
	var priorita = $("#PrioritaSelect ").val();
	var uo = $("#" + _idComboUO).val();

	$('#CodicePrestazioneTextBox').val('');

	$.ajax({
		type: "POST",
		url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/GetPrestazione",
		data: "{'uo':'" + uo + "','aziendaSistemaEroganteCodicePrestazione':'" + aziendaSistemaEroganteCodicePrestazione + "','regime':'" + regime + "','priorita':'" + priorita + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (result.d == null) {

				//$("#loaderGrigliaPrestazioni").fadeOut();
				alert('Prestazione non trovata');
				return;
			}

			var prestazione = result.d;

			if (!prestazione.Descrizione) prestazione.Descrizione = '-';

			if (!isPrestazioneAlreadyAdded(prestazione))
				saveRequest(SalvaAggiungiPrestazione, prestazione.Id);

			//$('#barcodeContainer').dialog('close');
		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText); alert(message);
		}
	});
}

function loadData(methoName, parameters) {

	$('#searchPrestazioniButton').attr("disabled", "disabled");
	$("#loaderPrestazioni").show();

	$.ajax({
		type: "POST",
		url: methoName,
		data: parameters,
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (result.d == null || result.d.length == 0) {

				$("#divNoPrestazioni").show();
				//$("#grigliaSelettorePrestazioni").html("<span>Nessun Risultato</span>");
				$('#searchPrestazioniButton').removeAttr("disabled");
				$("#loaderPrestazioni").fadeOut();
				return;
			}
			else {
				$("#divNoPrestazioni").hide();
			}

			var html = new Array();

			html.push('<table id="grigliaPrestazioni" class="table table-bordered table-condensed table-striped small"><thead>');

			html.push('<th width="30px"></th>');

			html.push('<th>Codice</th>');
			html.push('<th>Descrizione</th>');
			html.push('<th style="display:none;">CodiceErogante</th>');
			html.push('<th>Erogante</th>');

			html.push('</thead><tbody>');

			for (var i = 0; i < result.d.length; i++) {

				var riga = result.d[i];

				html.push('<tr id="' + riga.Id + '">');
				html.push('<td class="text-center"><a class="btn btn-xs" onclick="AggiungiPrestazione(\'' + riga.Id + '\')" type="button" title="clicca per aggiungere" ><span class="glyphicon glyphicon-plus" aria-hidden="true"></span></a></td>');

				var eroganteOTipo = riga.Erogante;
				var tastoPreview = '<a class="btn btn-sm" onclick="ShowPreviewProfilo(\'' + riga.Id + '\');return false;"><span title="clicca per visualizzare le prestazione contenute nel profilo" class="glyphicon glyphicon-search" aria-hidden="true"></span></a>';

				switch (riga.Tipo) {

					case 1:
						eroganteOTipo = '(Profilo) ' + tastoPreview;
						break;

					case 2:
					// profilo non scomponibile
					case 4:
						eroganteOTipo = '(Profilo scomponibile) ' + tastoPreview;
						break;

					case 3:
						eroganteOTipo = '(Profilo utente) ' + tastoPreview;
						break;
				}

				html.push('<td class="Codice">' + riga.Codice + '</td>');
				html.push('<td class="Descrizione">' + riga.Descrizione + '</td>');
				html.push('<td class="CodiceErogante" style="display:none;">' + riga.CodiceErogante + '</td>');
				html.push('<td class="Erogante">' + eroganteOTipo + '</td>');

				html.push('</tr>');
			}

			html.push('</tbody></table>');

			var grigliaSelettorePrestazioni = $("#grigliaSelettorePrestazioni");

			grigliaSelettorePrestazioni.html(html.join(""));

			$('#searchPrestazioniButton').removeAttr("disabled");
			$("#loaderPrestazioni").fadeOut();

			var numeroPrestazioni = result.d.length

			var numberOfPrestazioni = $("#NumberOfPrestazioni");

			if (numeroPrestazioni > 100) {
				numberOfPrestazioni.html("La ricerca ha prodotto più di 100 risultati, ne sono stati mostrati solo i primi 100. Si prega di inserire ulteriori parametri di ricerca.");
			}
			else {
				numberOfPrestazioni.html("");
			}

			// var grigliaPrestazioni = $("#grigliaPrestazioni");
			//grigliaPrestazioni.tablesorter({

			//    headers: {
			//        0: { sorter: false }
			//    }
			//});

		},
		error: function (error) {

			$("#grigliaSelettorePrestazioni").html("<br />Errore nella ricerca delle prestazioni");
			$('#searchPrestazioniButton').removeAttr("disabled");
			$("#loaderPrestazioni").fadeOut();

			var message = GetMessageFromAjaxError(error.responseText); alert(message);
		}
	});
}

//function ShowPreviewProfilo(id) {
//	$.ajax({
//		type: "POST",
//		url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/ShowPreviewProfilo",
//		data: "{'idProfilo': '" + id + "'}",
//		contentType: "application/json; charset=utf-8",
//		dataType: "json",
//		success: function (result) {

//			$("#tabellaPrestazioniPreviewBody").html("");

//			if (result.d != null) {
//				var html = new Array();
//				for (var i = 0; i < result.d.length; i++) {
//					var prestazione = result.d[i];
//					html.push('<tr><td class="codicePrestazione">' + prestazione.Codice + '</td><td  class="descrizionePrestazione">' + prestazione.Descrizione + '</td><td class="sistemaErogante">' + prestazione.Erogante + '</td></tr>');
//				}
//				$("#trVuota").hide();
//				$("#tabellaPrestazioniPreviewBody").html(html.join(""));
//			}
//			else {
//				$("#trVuota").show();
//			}
//			$("#ModalePreviewProfilo").modal("show");
//		},
//		error: function (error) {
//			var message = GetMessageFromAjaxError(error.responseText); alert(message);
//		}
//	});

//}

//sul click del tasto aggiungi prestazione
//function AggiungiPrestazione(id) {

//	var riga = $('#' + id);

//	var prestazione = { 'Id': id, 'Codice': riga.find('.Codice').html(), 'Descrizione': riga.find('.Descrizione').html(), 'CodiceErogante': riga.find('.CodiceErogante').html(), 'SistemaErogante': riga.find('.Erogante').html(), 'Valido': true };

//	if (!isPrestazioneAlreadyAdded(prestazione))
//		saveRequest(SalvaAggiungiPrestazione, id);
//	//Valido l'intera richiesta per aggiornare l'anteprima
//	saveRequest(ValidaRichiesta);
//}

//function isPrestazioneAlreadyAdded(prestazione) {

//	var found = false;
//	$("#tabellaPrestazioniBody tr").each(function () {

//		var chiave = $(this).find(".codicePrestazione").html() + '' + $(this).find(".CodiceErogante").html();

//		if (chiave != 0 && chiave == (prestazione.Codice + '' + prestazione.CodiceErogante)) {

//			found = true;
//		}
//	});

//	return found;
//}

function addPrestazione(prestazione) {

	if (isPrestazioneAlreadyAdded(prestazione)) return false;

	if (!prestazione.DescrizioneStatoValidazione)
		prestazione.DescrizioneStatoValidazione = '';
	else {
		//prestazione.DescrizioneStatoValidazione = prestazione.DescrizioneStatoValidazione.replace(/'/g, "\'");
		//prestazione.DescrizioneStatoValidazione = prestazione.DescrizioneStatoValidazione.replace(/\r\n/g, "<br />");
	}

	var eroganteOTipo = prestazione.SistemaErogante;
	var tastoEspandi = '<a onclick="EspandiProfilo(\'' + prestazione.Id + '\')"> <img src="../Images/icon-expand.gif" alt="clicca per espandere il profilo" title="clicca per espandere il profilo" class="btn btn-xs" /></a>';
	var tastoPreview = '<a onclick="ShowPreviewProfilo(\'' + prestazione.Id + '\');return false;" class="btn btn-xs"><span class="glyphicon glyphicon-search" aria-hidden="true"></span></a>';

	switch (prestazione.Tipo) {

		case 1:
			eroganteOTipo = '(Profilo) ' + tastoPreview;
			break;

		case 2:
		case 4:
			eroganteOTipo = '(Profilo scomponibile) ' + tastoEspandi + ' ' + tastoPreview;;
			break;

		case 3:
			eroganteOTipo = '(Profilo utente) ' + tastoEspandi + ' ' + tastoPreview;
			break;
	}

	var validazioneHml = prestazione.Valido ? '<span class="glyphicon glyphicon-ok text-success" aria-hidden="true"></span>' : '<div title="' + prestazione.DescrizioneStatoValidazione + '"><span class="glyphicon glyphicon-exclamation-sign text-danger" aria-hidden="true"></span></div>';

	if (_canSave)
		$("#tabellaPrestazioniBody").append('<tr id="id_' + prestazione.Id + '"><td style="width:30px;" class="text-center"><a type="button" class="ImageButton" href="#" alt="elimina prestazione" title="elimina prestazione" onclick="removePrestazione(\'' +
			prestazione.Id + '\'); return false;"><span class="glyphicon glyphicon-remove text-danger" aria-hidden="true"></span></a></td><td class="codicePrestazione">' +
			prestazione.Codice + '</td><td  class="descrizionePrestazione">' +
			prestazione.Descrizione + '</td><td  class="sistemaErogante">' +
			eroganteOTipo + '</td><td class="CodiceErogante" style="display:none;">' +
			prestazione.CodiceErogante + '</td><td class="text-center">' + validazioneHml + '</td></tr>');
	else
		$("#tabellaPrestazioniBody").append('<tr><td></td><td class="codicePrestazione">' + prestazione.Codice + '</td><td  class="descrizionePrestazione">' + prestazione.Descrizione + '</td><td class="sistemaErogante">' + eroganteOTipo + '</td><td class="codiceErogante" style="display:none;">' + prestazione.CodiceErogante + '</td></tr>');

	$("#VaiAComposizioneDatiAccessoriButton").removeAttr("disabled");

	$("#emptyGridRow").hide();

	SetupPopup();

	return true;
}

//function removePrestazione(idPrestazione) {

//	saveRequest(SalvaRimuoviPrestazione, idPrestazione);
//	//Valido l'intera richiesta per aggiornare l'anteprima
//	//saveRequest(ValidaRichiesta);
//	//se le prestazioni vanno a 0, disabilito il tasto per compilare i dati accessori
//	if ($("#tabellaPrestazioniBody tr").length == 1) {
//		$("#emptyGridRow").show();
//		$("#VaiAComposizioneDatiAccessoriButton").attr("disabled", "disabled");
//	}
//	else {
//		$("#emptyGridRow").hide();
//	}
//}

function addPrestazioni(prestazioni) {

	for (var i = 0; i < prestazioni.length; i++) {

		addPrestazione(prestazioni[i]);
	}
}

function EspandiProfilo(idPrestazione) {

	$("#loaderGrigliaPrestazioni").show();

	var idRichiesta = $.QueryString["IdRichiesta"];

	$.ajax({
		type: "POST",
		url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/EspandiProfilo",
		data: "{'idRichiesta':'" + idRichiesta + "', 'idPrestazione':'" + idPrestazione + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (result.d == null || result.d.length == 0) {
				$("#loaderGrigliaPrestazioni").fadeOut();
				return;
			}

			ReloadPrestazioni();
			$("#loaderGrigliaPrestazioni").fadeOut();
		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText); alert(message);
			$("#loaderGrigliaPrestazioni").fadeOut();
		}
	});
}

/*funzione salvataggio automatico*/

var _currentXhrRequest = null;

//var SalvaAggiungiPrestazione = function (idPrestazione) {

//	if (!idPrestazione)
//		return;

//	var idRichiesta = $.QueryString["IdRichiesta"] ? $.QueryString["IdRichiesta"] : '';

//	_currentXhrRequest = $.ajax({
//		type: "POST",
//		url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/AggiungiPrestazione",
//		data: "{idRichiesta:'" + idRichiesta + "', idPrestazione:'" + idPrestazione + "'}",
//		contentType: "application/json; charset=utf-8",
//		dataType: "json",
//		success: manageResultWithReload,
//		error: manageError
//	});
//}

//var SalvaRimuoviPrestazione = function (idPrestazione) {

//	if (!idPrestazione)
//		return;

//	var idRichiesta = $.QueryString["IdRichiesta"] ? $.QueryString["IdRichiesta"] : '';

//	_currentXhrRequest = $.ajax({
//		type: "POST",
//		url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/EliminaPrestazione",
//		data: "{idRichiesta:'" + idRichiesta + "', idPrestazione:'" + idPrestazione + "'}",
//		contentType: "application/json; charset=utf-8",
//		dataType: "json",
//		success: manageResultWithReload,
//		error: manageError
//	});
//}

//var SalvaRichiesta = function () {

//	var idRichiesta = $.QueryString["IdRichiesta"] ? $.QueryString["IdRichiesta"] : '';
//	var regime = $("#RegimeSelect").val();
//	var priorita = $("#PrioritaSelect").val();
//	var dataPrenotazione = $("#DataPrenotazioneTextBox ").val();

//	var uo = $("#" + _idComboUO).val();

//	var prestazioni = JSON.stringify([]);


//	_currentXhrRequest = $.ajax({
//		type: "POST",
//		url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/SalvaRichiesta",
//		data: "{idRichiesta:'" + idRichiesta + "', idSac:'" + $.QueryString["IdPaziente"] + "', regime:'" + regime + "', priorita:'" + priorita + "', uo:'" + uo + "', dataPrenotazione:'" + dataPrenotazione + "', prestazioni:" + prestazioni + "}",
//		contentType: "application/json; charset=utf-8",
//		dataType: "json",
//		success: manageResult,
//		error: manageError
//	});

//	//Aggiorno la lista dei gruppi preferiti in quanto dipendono dal regime e dalla priorità
//	LoadListaGruppiPrestazioni();
//	//Ripulisco la griglia in quanto la ricerca delle prestazioni dipende dal regime e dalla priorità
//	$('#filtroSelettoreDescrizione').val('');
//	$("#grigliaSelettorePrestazioni").html('');
//	$("#NumberOfPrestazioni").html('');

//}

//var ValidaRichiesta = function () {

//	var idRichiesta = $.QueryString["IdRichiesta"] ? $.QueryString["IdRichiesta"] : '';

//	var prestazioni = [];

//	_currentXhrRequest = $.ajax({
//		type: "POST",
//		url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/ValidaRichiesta",
//		data: "{'idRichiesta': '" + idRichiesta + "'}",
//		contentType: "application/json; charset=utf-8",
//		dataType: "json",
//		success: manageResult,
//		error: manageError
//	});
//}

function saveRequest(functionToCall, parameter) {

	if (!_canSave)
		return

	try {
		//        if (_currentXhrRequest && _currentXhrRequest.readyState != 4) {

		//            _currentXhrRequest.abort();
		//            AbortSavePanel();
		//        }

		ShowSavePanel("Salvataggio in corso...");

		if (!parameter)
			functionToCall();
		else
			functionToCall(parameter);
	}
	catch (e) {

		CloseSavePanel('Si è verificato un errore nel salvataggio', true);
	}
}

function manageResult(result) {

	if (result.d == null) {

		CloseSavePanel('Si è verificato un errore nel caricamento', true);
		return;
	}

	CloseSavePanel();
}

function manageResultWithReload(result) {

	CloseSavePanel();

	ReloadPrestazioni();
}

function manageError(error) {
	if (error.statusText != 'abort')
		CloseSavePanel('Si è verificato un errore', true);
	CloseSavePanel('Si è verificato un errore nel caricamento', true);
	return;

	//se annullo la richiesta torna un messaggio d'errore con statusText 'abort'
}

