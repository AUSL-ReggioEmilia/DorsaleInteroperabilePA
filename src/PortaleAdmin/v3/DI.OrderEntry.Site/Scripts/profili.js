$(document).ready(function () {

	LoadSistemiEroganti()

});

$(document).keypress(function (e) {

	if (e.which == "13") {
		//enter pressed
		return false;
	}
});

function LoadSistemiEroganti() {

	var sistemaSelect = $("#sistemiEroganti");
	var sistemiErogantiFiltroPrestazioneProfiloSelect = $("#sistemiErogantiFiltroPrestazioneProfilo");

	sistemaSelect.attr('disabled', 'disabled');
	sistemiErogantiFiltroPrestazioneProfiloSelect.attr('disabled', 'disabled');

	$.ajax({
		type: "POST",
		url: "Profili.aspx/GetLookupSistemiEroganti",
		data: "{}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function (result) {

			for (var sistema in result.d) {

				sistemaSelect.append("<option value='" + sistema + "'>" + result.d[sistema] + "</option>");
				sistemiErogantiFiltroPrestazioneProfiloSelect.append("<option value='" + sistema + "'>" + result.d[sistema] + "</option>");
			}

			sistemaSelect.removeAttr('disabled');
			sistemiErogantiFiltroPrestazioneProfiloSelect.removeAttr('disabled');
		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});
}


function FiltraPrestazioniProfilo() {

	var idProfilo = $("#PrestazioniProfili ").attr("idProfilo");

	if (idProfilo)
		CaricaPrestazioni(idProfilo);
	else
		alert('Occorre prima selezionare un profilo di prestazioni');

}

function OpenPrestazioniDialog(idProfilo,codiceProfilo,descrizioneProfilo) {
	$('body').css('cursor', 'wait');

	$('#PrestazioniProfili').dialog({
		width: 1200,
		height: 650 + "px",
		modal: true,
		position: 'center',
		title: "Aggiungi o Rimuovi Prestazioni al Profilo &nbsp; &nbsp; &nbsp; [" +codiceProfilo +"] - " +descrizioneProfilo,
		resizable: false,
		open: function (event, ui) {

			$('body').css({ 'overflow-y': 'hidden', 'overflow-x': 'hidden' });
			CaricaPrestazioni(idProfilo);
			$('#PrestazioniProfili').attr("idProfilo", idProfilo);
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
function CaricaPrestazioni(idProfilo) {

	if (!idProfilo || idProfilo == '') {
		$("#Prestazioni").html("");
		return;
	}

	var descrizioneFiltroPrestazioneProfilo = $("#descrizioneFiltroPrestazioneProfilo").val();
	var idSistemiErogantiFiltroPrestazioneProfilo = $("#sistemiErogantiFiltroPrestazioneProfilo").val();
	$("#loaderProfilo").show();

	$.ajax({
		type: "POST",
		url: "Profili.aspx/GetPrestazioni",
		data: "{'idProfilo':'" + idProfilo + "', 'descrizioneFiltroPrestazioneProfilo':'" + escape(descrizioneFiltroPrestazioneProfilo) + "', 'idSistemiErogantiFiltroPrestazioneProfilo':'" + idSistemiErogantiFiltroPrestazioneProfilo + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (!result.d) {

				$("#Prestazioni").html("Nessuna prestazione");			
				$("#loaderProfilo").fadeOut();
				return;
			}

			var html = [];
			html.push('<table id="prestazioniGrid" class="tablesorter" style="border:1px silver solid; border-collapse:collapse; width:100%;height:auto;"><thead>');
			html.push('<th style="width:25px;height:29px;"><input type="checkbox" style="background: transparent; border-style: none; cursor: pointer;" onclick="SelectDeselectAll($(this), $(\'#prestazioniGrid\'));" /></th>');
			html.push('<th>Codice</th><th>Descrizione</th><th>Erogante</th>');
			html.push('</thead><tbody>');

			for (var property in result.d) {
				var prestazione = result.d[property];
				html.push('<tr id="' + prestazione.Id + '" class="GridItem">');
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

			$("#loaderProfilo").fadeOut();
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
		url: "Profili.aspx/GetListaPrestazioni",
		data: "{'descrizione':'" + escape(descrizione) + "', 'idSistemaErogante':'" + idSistemaErogante + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (result.d == null) {

				$("#listaPrestazioni").html("<br />Nessun risultato");
				$("#loader").fadeOut();
				return;
			}

			var idPrestazioniDelProfilo = $("#prestazioniGrid .GridItem").map(function () { return $(this).attr("id"); }).get();
			var html = [];

			html.push('<table id="selettoreGrid" class="tablesorter" style="border:1px silver solid; border-collapse:collapse; width:100%;height:auto;"><thead>');
			html.push('<th style="width:25px;height:29px;"><input type="checkbox" style="background: transparent; border-style: none; cursor: pointer;" onclick="SelectDeselectAll($(this), $(\'#selettoreGrid\'));" /></th>');
			html.push('<th>Codice</th><th>Descrizione</th><th>Erogante</th>');
			html.push('</thead><tbody>');

			for (var i = 0; i < result.d.length; i++) {
				var riga = result.d[i];
				html.push('<tr id="' + riga.Id + '" class="GridItem">');
				html.push('<td><input type="checkbox" class="gridCheckBox" ');

				if (idPrestazioniDelProfilo.length > 0) {
					var idx = $.inArray(riga.Id, idPrestazioniDelProfilo);
					if (idx > -1) {
						html.push(' style="display:none;"');
						idPrestazioniDelProfilo.splice(idx, 1);
					}
				}
				html.push('/></td>');
				html.push('<td style="width:80px;">' + riga.Codice + '</td>');
				html.push('<td >' + riga.Descrizione + '</td>');
				html.push('<td >' + riga.SistemaErogante + '</td>');
				html.push('</tr>');
			}

			html.push('</tbody></table>');
			$("#listaPrestazioni").html(html.join(""));

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
	var idProfilo = $("#PrestazioniProfili ").attr("idProfilo");

	if (idProfilo) {
		var idPrestazioni = new Array();
		var idPrestazioniDelProfilo = $("#prestazioniGrid .GridItem").map(function () { return $(this).attr("id"); }).get();

		//RIGHE SELEZIONATE A DESTRA
		$('#selettoreGrid .GridSelected').each(function () {

			var idPrestazione = $(this).attr("id");

			if ($.inArray(idPrestazione, idPrestazioniDelProfilo) == -1)
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
			AggiungiPrestazioniAProfilo(idProfilo, idPrestazioni);
			//RICARICO LA LISTA DI SINISTRA
			CaricaPrestazioni(idProfilo);
		}
		else
		{ alert('Selezionare le prestazioni da aggiungere.'); }
	}
	else
	{ alert('Occorre prima selezionare un profilo'); }
}


function AggiungiPrestazioniAProfilo(idProfilo, idPrestazioni) {

	$.ajax({
		type: "POST",
		url: "Profili.aspx/InsertPrestazioniInProfilo",
		data: "{'idProfilo':'" + idProfilo + "','idPrestazioni':'" + idPrestazioni.join(";") + "'}",
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

	var idProfilo = $("#PrestazioniProfili ").attr("idProfilo");
	//array con gli id delle prestazioni marcate a sinistra
	var idPrestazioni = $("#prestazioniGrid .GridSelected").map(function () { return $(this).attr("id"); }).get();

	if (idPrestazioni.length > 0) {
		//CHIAMATA AL METODO DELETE SU DB
		RimuoviPrestazioneDaProfilo(idProfilo, idPrestazioni);

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

function RimuoviPrestazioneDaProfilo(idProfilo, idPrestazioni) {

	$.ajax({
		type: "POST",
		url: "Profili.aspx/DeletePrestazioneDaProfilo",
		data: "{'idProfilo':'" + idProfilo + "', 'idPrestazioni':'" + idPrestazioni.join(";") + "'}",
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
//Apre la modale di modifica di un profilo
//
function ModificaProfilo(idProfilo, codice, descrizione, tipo, attivo,note) {
    //ottengo le textbox/checkbox dei parametri
	var codiceTextBox = $("#profilo_prestazioni_codice");
	var descrizioneTextBox = $("#profilo_prestazioni_descrizione");
	var tipoComboBox = $("#profilo_prestazioni_tipo");
	var attivoCheckBox = $("#profilo_prestazioni_attivo");
	var noteTextBox = $("#profilo_prestazioni_note");

	codiceTextBox.val(codice);

	if (attivo == 'true') {
		attivoCheckBox.attr('checked', 'checked');
	} else {
		attivoCheckBox.removeAttr('checked');
	}

	$("#codiceRow").show();

	descrizioneTextBox.val(descrizione);
	descrizioneTextBox.next().hide();

	tipoComboBox.val(tipo);

	noteTextBox.val(note);

	$('#NewOrEditProfili').dialog({
		height: 500,
		width: 300,
		modal: true,
		position: 'center',
		title: "Modifica profilo",
		resizable: true,
		buttons: {
			"Ok": function () {

				var codice = codiceTextBox.val();

				if (codice == '') {

					codice.next().fadeIn();
					return;
				}

				if (codice.toLowerCase().indexOf("usr") != -1) {
					codiceTextBox.next().next().fadeIn();
					return;
				}

				var descrizione = descrizioneTextBox.val();

				if (descrizione == '') {

					descrizioneTextBox.next().fadeIn();
					return;
				}

                //salvo il profilo
				SalvaProfilo(idProfilo, codice, descrizione, tipoComboBox.val(), attivoCheckBox.attr('checked') == 'checked',null,noteTextBox.val());

				$(this).dialog("close");
			},
			"Annulla": function () {

				$(this).dialog("close");
			}

		}
	});
}

//
//Apre la modale di inserimento di un nuovo profilo
//
function AggiungiProfilo(CopiaDaProfiloId, CopiaDaProfiloNome, CopiaDaProfiloTipo, CopiaDaProfiloAttivo) {
	// i parametri sono opzionali; se mancano si procede con un semplice inserimento

	var codiceTextBox = $("#profilo_prestazioni_codice");
	var descrizioneTextBox = $("#profilo_prestazioni_descrizione");
	var noteTextBox = $("#profilo_prestazioni_note");
	var tipoComboBox = $("#profilo_prestazioni_tipo");
	var attivoCheckBox = $("#profilo_prestazioni_attivo");

	codiceTextBox.val('');
	codiceTextBox.next().hide();
	$("#codiceRow").show();
	//$("#codiceRow").hide();

	descrizioneTextBox.val('');
	descrizioneTextBox.next().hide();

	tipoComboBox.val(1);

	attivoCheckBox.attr('checked', 'checked');

    //Sbianco la textbox
	noteTextBox.val('');

	var Title = "Inserimento nuovo profilo";
	if (typeof CopiaDaProfiloId != 'undefined') 
	{
		Title = "Creazione copia del profilo " + CopiaDaProfiloNome;
		descrizioneTextBox.val('Copia di ' + CopiaDaProfiloNome);

		if (CopiaDaProfiloAttivo == 'true') {
			attivoCheckBox.attr('checked', 'checked');
		} else {
			attivoCheckBox.removeAttr('checked');
		}

		tipoComboBox.val(CopiaDaProfiloTipo);
	}
	else {
		CopiaDaProfiloId = '';
	}

	codiceTextBox.focus();

	$('#NewOrEditProfili').dialog({
		height: 500,
		width: 300,
		modal: true,
		position: 'center',
		title: Title,
		resizable: true,
		buttons: {
			"Ok": function () {
				var codice = codiceTextBox.val();

				if (codice == '') {
					codiceTextBox.next().fadeIn();
					return;
				}

				if (codice.toLowerCase().indexOf("usr") != -1) {
					codiceTextBox.next().next().fadeIn();
					return;
				}
				var descrizione = descrizioneTextBox.val();
				if (descrizione == '') {

					descrizioneTextBox.next().fadeIn();
					return;
				}

				var idProfilo = SalvaProfilo('', codice, descrizione, tipoComboBox.val(), attivoCheckBox.attr('checked') == 'checked', CopiaDaProfiloId,noteTextBox.val());

				$(this).dialog("close");
			},
			"Annulla": function () {

				$(this).dialog("close");
			}
		}
	});
}

function SalvaProfilo(idProfilo, codice, descrizione, tipo, attivo, CopiaDaProfiloId,note) {

	$.ajax({
		type: "POST",
		url: "Profili.aspx/UpdateProfilo",
		data: "{'idProfilo':'" + idProfilo + "','codice':'" + escape(escapeHtmlEntities(codice)) + "','descrizione':'" + escape(escapeHtmlEntities(descrizione)) + "','tipo':'" + parseInt(tipo) + "','attivo':'" + attivo + "','CopiaDaProfiloId':'" + CopiaDaProfiloId + "','note':'" + escape(escapeHtmlEntities(note)) + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function (result) {

			if (!result.d) {

				return;
			}

			idProfilo = result.d;

			window.location.href = window.location.href;

		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText);

			if (message.indexOf('duplicate key') > -1)
				alert('Il codice del profilo deve essere univoco');
			else
				alert(message);
		}
	});

	return idProfilo;
}


function ImportaDaCsv() {

	var dialog = $("#importaDaCsv").dialog({
		height: 250,
		width: 400,
		modal: true,
		position: 'center',
		title: "Importa da file .csv",
		resizable: true,
		open: function (event, ui) {
			$('body').css({ 'overflow-y': 'hidden', 'overflow-x': 'hidden' });
		},
		close: function (event, ui) {
			$('body').css({ 'overflow-y': 'scroll', 'overflow-x': 'auto' });
		},
		buttons:
             {
             	"OK": function () { $(".importFake").trigger('click'); },
             	"Annulla": function () { $(this).dialog('close'); }
             }

	});

	dialog.parent().appendTo($("form:first"));
}
