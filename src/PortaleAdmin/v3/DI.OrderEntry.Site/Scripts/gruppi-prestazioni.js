$(document).ready(function () {

	//$('body').css('overflow', 'hidden');
	LoadSistemiEroganti();
});

$(document).keypress(function (e) {
	if (e.which == "13") {
		//enter pressed 
		return false;
	}
});

function LoadSistemiEroganti() {

	
	var sistemaSelect = $("#sistemiEroganti");
	var sistemiErogantiFiltroPrestazioneGruppoSelect = $("#sistemiErogantiFiltroPrestazioneGruppo");

	sistemaSelect.attr('disabled', 'disabled');
	sistemiErogantiFiltroPrestazioneGruppoSelect.attr('disabled', 'disabled');

	$.ajax({
		type: "POST",
		url: "GruppiPrestazioni.aspx/GetLookupSistemiEroganti",
		data: "{}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function (result) {

			sistemaSelect.append("<option value='" + '00000000-0000-0000-0000-000000000000' + "'>" + 'Profili' + "</option>");
			sistemiErogantiFiltroPrestazioneGruppoSelect.append("<option value='" + '00000000-0000-0000-0000-000000000000' + "'>" + 'Profili' + "</option>");

			for (var sistema in result.d) {
				sistemaSelect.append("<option value='" + sistema + "'>" + result.d[sistema] + "</option>");
				sistemiErogantiFiltroPrestazioneGruppoSelect.append("<option value='" + sistema + "'>" + result.d[sistema] + "</option>");
			}

			sistemaSelect.removeAttr('disabled');
			sistemiErogantiFiltroPrestazioneGruppoSelect.removeAttr('disabled');
		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});
}

function FiltraPrestazioniGruppo() {

	var idGruppo = $("#PrestazioniGruppoPrestazioni ").attr("idGruppo");

	if (idGruppo)
		CaricaPrestazioni(idGruppo);
	else
		alert('Occorre prima selezionare un gruppo di prestazioni');

}

function OpenPrestazioniDialog(idGruppo,descrizioneGruppo) {
	$('body').css('cursor', 'wait');

	$('#PrestazioniGruppoPrestazioni').dialog({
		width: 1200,
		height: 650 + "px",
		modal: true,
		position: 'center',
		title: "Aggiungi o Rimuovi Prestazioni al Gruppo&nbsp; &nbsp; &nbsp; [" + descrizioneGruppo +"]",
		resizable: false,
		open: function (event, ui) {

			$('body').css({ 'overflow-y': 'hidden', 'overflow-x': 'hidden' });
			CaricaPrestazioni(idGruppo);
			$('#PrestazioniGruppoPrestazioni').attr("idGruppo", idGruppo);			
			$('body').css('cursor', 'default');
		},
		close: function (event, ui) {

			$('body').css('cursor', 'wait');
			//pulisce le due liste, così se si riapre il popup risulta pulito
			$("#Prestazioni").html("");
			$("#listaPrestazioni").html("");
			$('body').css({ 'overflow-y': 'scroll', 'overflow-x': 'auto' });
			$('body').css('cursor', 'default');
		},
		buttons: {
			"Ok": function () {
				$(this).dialog("close");
			}
		}
	});
}

//LISTA DI SINISTRA
function CaricaPrestazioni(idGruppo) {

	if (!idGruppo || idGruppo == '') {
		$("#Prestazioni").html("");
		return;
	}
	var descrizioneFiltroPrestazioneGruppo = $("#descrizioneFiltroPrestazioneGruppo").val();
	var idSistemiErogantiFiltroPrestazioneGruppo = $("#sistemiErogantiFiltroPrestazioneGruppo").val();

	$("#loaderGruppo").show();

	$.ajax({
		type: "POST",
		url: "GruppiPrestazioni.aspx/GetPrestazioni",
		data: "{'idGruppo':'" + idGruppo + "', 'descrizioneFiltroPrestazioneGruppo':'" + escape(descrizioneFiltroPrestazioneGruppo) + "', 'idSistemiErogantiFiltroPrestazioneGruppo':'" + idSistemiErogantiFiltroPrestazioneGruppo + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (!result.d) {

				$("#Prestazioni").html("Nessuna prestazione");
				$("#loaderGruppo").fadeOut();
				return;
			}

			var html = [];
			html.push('<table id="prestazioniGrid" class="tablesorter" style="border:1px silver solid; border-collapse:collapse; width:100%;height:auto;"><thead>');
			html.push('<th style="width:25px;height:29px;"><input type="checkbox" style="background: transparent; border-style: none; cursor: pointer;" onclick="SelectDeselectAll($(this), $(\'#prestazioniGrid\'));" /></th>');
			html.push('<th>Codice</th><th>Descrizione</th><th>Erogante</th>');
			html.push('</thead><tbody>');
			for (var property in result.d) {
				var prestazione = result.d[property];
				html.push('<tr id="' + prestazione.Id + '" class="GridItem" >');
				html.push('<td><input type="checkbox" class="gridCheckBox" /></td>');
				html.push('<td style="width:80px;">' + prestazione.Codice + '</td>');
				html.push('<td>' + prestazione.Descrizione + '</td>');
				html.push('<td>' + prestazione.SistemaErogante + '</td>');
				html.push('</tr>');
			}

			html.push('</tbody></table>');
			$("#Prestazioni").html(html.join(""));

			$("#prestazioniGrid").tablesorter({
				headers: {
					0: { sorter: false }
				}
			});

			$("#prestazioniGrid .gridCheckBox").change(function () {
				$(this).parent().parent().toggleClass('GridSelected');
			});
			
			$("#loaderGruppo").fadeOut();

		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});
}

//LISTA DI DESTRA
function CercaPrestazioni() {

	var descrizione = $("#descrizioneFiltro").val();
	var idSistemaErogante = $("#sistemiEroganti").val();

	$("#loader").show();

	$.ajax({
		type: "POST",
		url: "GruppiPrestazioni.aspx/GetListaPrestazioni",
		data: "{'descrizione':'" + escape(descrizione) + "', 'idSistemaErogante':'" + idSistemaErogante + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (result.d == null) {

				$("#listaPrestazioni").html("<br />Nessun risultato");
				$("#loader").fadeOut();
				return;
			}

			var idPrestazioniDelGruppo = $("#prestazioniGrid .GridItem").map(function () { return $(this).attr("id"); }).get();
						
			var html = '<table id="selettoreGrid" class="tablesorter" style="border:1px silver solid; border-collapse:collapse; width:100%;height:auto;"><thead>';
			html += '<th style="width:25px;height:29px;"><input type="checkbox" style="background: transparent; border-style: none; cursor: pointer;" onclick="SelectDeselectAll($(this), $(\'#selettoreGrid\'));" /></th>';
			html += '<th>Codice</th><th>Descrizione</th><th>Erogante</th>';
			html += '</thead><tbody>';
			for (var i = 0; i < result.d.length; i++) {
				var riga = result.d[i];
				html += '<tr id="' + riga.Id + '" class="GridItem">';
				html += '<td><input type="checkbox" class="gridCheckBox" ';

				if (idPrestazioniDelGruppo.length > 0) {
					var idx = $.inArray(riga.Id, idPrestazioniDelGruppo);
					if (idx > -1) {
						html += ' style="display:none;"';
						idPrestazioniDelGruppo.splice(idx, 1);
					}
				}
				html += '/></td>';
				html += '<td style="width:80px;">' + riga.Codice + '</td>';
				html += '<td>' + riga.Descrizione + '</td>';
				html += '<td>' + riga.SistemaErogante + '</td>';
				html += '</tr>';
			}
			html += '</tbody></table>';
			$("#listaPrestazioni").html(html);

			$("#selettoreGrid").tablesorter({
				headers: {
					0: { sorter: false }
				}
			});			

			$("#selettoreGrid .gridCheckBox").change(function () {
				$(this).parent().parent().toggleClass('GridSelected');
			});

			$("#loader").fadeOut();
			
		},
		error: function (error) {

			$("#loader").fadeOut();

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});
}

//TASTO AGGIUNGI
function AddPrestazioni() {

	var idGruppo = $("#PrestazioniGruppoPrestazioni ").attr("idGruppo");

	if (idGruppo) {
		var idPrestazioni = new Array();
		var idPrestazioniDelGruppo = $("#prestazioniGrid .GridItem").map(function () { return $(this).attr("id"); }).get();

		//PRESTAZIONI SELEZIONATE A DESTRA
		$('#selettoreGrid .GridSelected').each(function () {

			var idPrestazione = $(this).attr("id");

			if ($.inArray(idPrestazione, idPrestazioniDelGruppo) == -1)
				idPrestazioni.push(idPrestazione);

			//NASCONDO IL CHECKBOX DALLA LISTA DI DESTRA
			var riga = $(this);
			var checkbox = riga.children().children('input');
			riga.removeClass('GridSelected');
			checkbox.attr("checked", "");
			checkbox.hide();

		});

		if (idPrestazioni.length > 0) {
			//CHIAMATA AL METODO INSERT SU DB
			AggiungiPrestazioniAGruppo(idGruppo, idPrestazioni);
			//RICARICO LA LISTA DI SINISTRA
			CaricaPrestazioni(idGruppo);
		}
		else
		{ alert('Selezionare le prestazioni da aggiungere.'); }
	}
	else
	{ alert('Occorre prima selezionare un gruppo di prestazioni'); }
}

function AggiungiPrestazioniAGruppo(idGruppo, idPrestazioni) {

	$.ajax({
		type: "POST",
		url: "GruppiPrestazioni.aspx/InsertPrestazioniInGruppo",
		data: "{'idGruppo':'" + idGruppo + "','idPrestazioni':'" + idPrestazioni.join(";") + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function (result) {
			if (!result.d) {
				return;
			}
		},
		error: function (error) {
			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});
}

//TASTO RIMUOVI
function RemovePrestazioni() {
	var idGruppo = $("#PrestazioniGruppoPrestazioni ").attr("idGruppo");
	//array con gli id delle prestazioni marcate a sinistra
	var idPrestazioni = $("#prestazioniGrid .GridSelected").map(function () { return $(this).attr("id"); }).get();

	if (idPrestazioni.length > 0) {
		//CHIAMATA AL METODO DELETE SU DB
		RimuoviPrestazioneDaGruppo(idGruppo, idPrestazioni);

		//RIMUOVO LE RIGHE <tr> MARCATE NELLA TABLE A SINISTRA		
		$("#prestazioniGrid .GridSelected").remove();

		for (var i = 0; i < idPrestazioni.length; i = i + 1) {
			//CERCO LA RIGA NELLA LISTA DI DESTRA PER MOSTRARE IL SUO CHECHBOX
			$('#selettoreGrid .GridItem[id="' + idPrestazioni[i] + '"]').each(function () {
				var riga = $(this);
				var checkbox = riga.children().children('input');
				checkbox.show();
				checkbox.attr("checked", "");
			});
		}
	}
	else
	{ alert('Selezionare le prestazioni da rimuovere.'); }
}

function RimuoviPrestazioneDaGruppo(idGruppo, idPrestazioni) {

	$.ajax({
		type: "POST",
		url: "GruppiPrestazioni.aspx/DeletePrestazioneDaGruppo",
		data: "{'idGruppo':'" + idGruppo + "', 'idPrestazioni':'" + idPrestazioni.join(";") + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function (result) {
			if (!result.d) {
				return;
			}			
		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});
}

//
// Apre la modale per la modifica di un gruppo di prestazioni
//
function ModificaGruppo(idGruppo, descrizione, preferiti,note) {
    //ottengo le textbox  della Descrizione,Preferiti e Note
	var descrizioneTextBox = $("#gruppo_prestazioni_descrizione");
	var preferitoCheckBox = $("#gruppo_prestazioni_preferito");
	var noteTextBox = $("#gruppo_prestazioni_note");

    //Valorizzo la textbox con il valore corrente del campo note
	noteTextBox.val(note);

    //Valorizzo la textbox con il valore corrente della descrizione
	descrizioneTextBox.val(descrizione);
	descrizioneTextBox.next().hide();

    //valorizzo la checkbox Preferiti
	if (preferiti == 'true') {
		preferitoCheckBox.attr('checked', 'checked');
	} else {
		preferitoCheckBox.removeAttr('checked');
	}

    //Apro la modale di Modifica/Inserimento di un gruppo di prestazioni
	$('#NewOrEditGruppoPrestazioni').dialog({
		height: 350,
		width: 300,
		modal: true,
		position: 'center',
		title: "Modifica gruppo",
		resizable: true,
		buttons: {
			"Ok": function () {

				var descrizione = descrizioneTextBox.val();

				if (descrizione == '') {

					descrizioneTextBox.next().fadeIn();

					return;
				}

                //Chiamo la funzione che salva il gruppo
				SalvaGruppo(idGruppo, descrizioneTextBox.val(), preferitoCheckBox.attr('checked') == 'checked', null,noteTextBox.val());

				$(this).dialog("close");
			},
			"Annulla": function () {

				$(this).dialog("close");
			}
		}
	});
}

//
// Apre la modale per l'inserimento di un nuovo gruppo di prestazioni
//
function AggiungiGruppo(CopiaDaGruppoId, CopiaDaGruppoNome, CopiaDaGruppoPreferito) {
    // i parametri sono opzionali; se mancano si procede con un semplice inserimento
    //Ottengo le textbox per la descrizione,preferiti e note
    var descrizioneTextBox = $("#gruppo_prestazioni_descrizione");
    var noteTextBox = $("#gruppo_prestazioni_note");
    var preferitoCheckBox = $("#gruppo_prestazioni_preferito");

    //siccome sono in inserimento sbianco le checkbox e metto a false l'attributo checked della checkbox
	descrizioneTextBox.val('');
	descrizioneTextBox.next().hide();
	noteTextBox.val('');
	preferitoCheckBox.attr('checked', false);
	
	var Title = "Inserimento nuovo gruppo";
	if (typeof CopiaDaGruppoId != 'undefined') {
		Title = "Creazione copia del gruppo " + CopiaDaGruppoNome;
		descrizioneTextBox.val('Copia di ' + CopiaDaGruppoNome);
		if (CopiaDaGruppoPreferito.toLowerCase() == 'true') {
			preferitoCheckBox.attr('checked', 'checked');
		} else {
			preferitoCheckBox.removeAttr('checked');
		}
	}
	else {
		CopiaDaGruppoId = ''; 
	}

	descrizioneTextBox.focus();

    //Apro la modale di inserimento
	$('#NewOrEditGruppoPrestazioni').dialog({
		height: 350,
		width: 400,
		modal: true,
		position: 'center',
		title: Title,
		resizable: true,
		buttons: {
			"Ok": function () {
				var descrizione = descrizioneTextBox.val();
				if (descrizione == '') {
					descrizioneTextBox.next().fadeIn();
					return;
				}
                //Salvo il gruppo
				var idGruppo = SalvaGruppo('', descrizioneTextBox.val(), preferitoCheckBox.attr('checked') == 'checked', CopiaDaGruppoId, noteTextBox.val());
				$(this).dialog("close");
			},
			"Annulla": function () {
				$(this).dialog("close");
			}
		}
	});
}

//
//Salva il gruppo di prestazioni chiamando un metodo della pagina gruppiPrestazioni.aspx
//
function SalvaGruppo(idGruppo, descrizione, preferito, CopiaDaGruppoId,note) {
	$.ajax({
		type: "POST",
		url: "GruppiPrestazioni.aspx/UpdateGruppo",
		data: "{'idGruppo':'" + idGruppo +
                "','descrizione':'" + escape(escapeHtmlEntities(descrizione)) +
                "','preferito':'" + preferito +
                "','CopiaDaGruppoId':'" + CopiaDaGruppoId +
                "','note':'" + note +
                "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function (result) {
			if (!result.d) {
				return;
			}
			idGruppo = result.d;
			window.location.href = window.location.href;
		},
		//        error: function (error) { alert('Salvataggio del Gruppo di Prestazioni: si è verificato un errore'); } 
		error: function (error) {
			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});

	return idGruppo;
}

//
//Elimina il gruppo di prestazioni
//
function EliminaGruppo() {

	if (!confirm("Il gruppo verrà eliminato, continuare?")) {
		return;
	}

	var idGruppo = $(".selectedLinkGruppi").attr("id");

	$.ajax({
		type: "POST",
		url: "GruppiPrestazioni.aspx/DeleteGruppo",
		data: "{'idGruppo':'" + idGruppo + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function (result) {
			response = result.d;
			if (response == 'error') {
				alert("Impossibile eliminare il gruppo poiché è utilizzato nelle ennuple.");
			}
			else CaricaGruppiGetFilter();
		},
		error: function (error) {
			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});
}
