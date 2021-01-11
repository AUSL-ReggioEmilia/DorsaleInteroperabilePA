
$(document).ready(function () {

});

function SaveFilter(controlId, value) {

	$.ajax({
		type: "POST",
		url: "ListaUtenti.aspx/SaveFilter",
		data: "{'controlId':'" + controlId + "', 'value':'" + value + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});
}

function LoadUtenti(codiceDescrizione, attivo, nonattivo, delega) {

	SaveFilter('CodiceDescrizioneFiltroTextBox', escape(escapeHtmlEntities(codiceDescrizione)));
	SaveFilter('AttivoCheckBox', attivo);
	SaveFilter('NonAttivoCheckBox', nonattivo);
	SaveFilter('ddlFiltroDelega', delega);

	SetLoaderForButton('.cercaFlag', true);

	$.ajax({
		type: "POST",
		url: "ListaUtenti.aspx/LoadUtenti",
		data: "{'codiceDescrizione':'" + escape(escapeHtmlEntities(codiceDescrizione)) + "', 'attivo':'" + attivo + "', 'nonattivo':'" + nonattivo + "', 'delega':'" + delega + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (!result.d) {

				$("#Utenti").html("Nessun risultato");
				if ($("#selettoreGrid").length > 0) CercaUtenti();
				SetLoaderForButton('.cercaFlag', false);
				return;
			}

			var html = [];

			html.push('<table id="utentiGrid" class="tablesorter" style="border:1px silver solid; border-collapse:collapse; width:100%; margin-top:5px;"><thead>');
			html.push('<th style="width:25px; padding:0px;"><input type="checkbox" style="background: transparent; border-style: none; cursor: pointer;" onclick="SelectDeselectAll($(this), $(\'#utentiGrid\'));" /></th>');
			html.push('<th style="width:25px; padding:0px;"></th>');
			html.push('<th>Nome utente</th>');
			html.push('<th>Descrizione</th>');
			html.push('<th>Tipo</th>');
			html.push('<th>Delega</th>');
			html.push('<th style="width:50px;">Attivo</th>');
			html.push('</thead><tbody>');

			for (var property in result.d) {
				var utente = result.d[property];
				html.push('<tr id="' + utente.Id + '" class="GridItem">');
				html.push('<td><input type="checkbox" class="gridCheckBox" /></td>');
				html.push('<td><input type="button" class="editButton" onclick="ApriPopUpUtente(\'' + utente.Id + '\');" /></td>');
				html.push('<td>' + utente.NomeUtente + '</td>');
				html.push('<td>' + utente.Descrizione + '</td>');
				html.push('<td>' + utente.DescrizioneTipo + '</td>');
				html.push('<td>' + utente.DescrizioneDelega + '</td>');
				html.push('<td>' + (utente.Attivo ? '<img src="../Images/ok.png" />' : '') + '</td>');
				html.push('</tr>');
			}

			html.push('</tbody></table>');
			$("#Utenti").html(html.join(""));

			$("#utentiGrid").tablesorter({

				headers: {
					0: { sorter: false },
					1: { sorter: false }
				}
			});
			$("#loader").fadeOut();           		

			$("#utentiGrid .gridCheckBox").change(function () {

				var checked = $(this).attr('checked');
				if (checked == 'checked') {
					$(this).parent().parent().addClass('GridSelected');
				} else {
					$(this).parent().parent().removeClass('GridSelected');
				}
			});

			SetLoaderForButton('.cercaFlag', false);
		},

		error: function (error) {
			SetLoaderForButton('.cercaFlag', false);
			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});
}

function ApriPopUpUtente(idUtente) {

	if (idUtente == undefined || idUtente == '') {
		commonModalDialogOpen('UtentiDettaglio.aspx', '', 520, 360);
	}
	else {
		commonModalDialogOpen('UtentiDettaglio.aspx?Id=' + idUtente, '', 520, 520);
	 }
	return false;	
}


function RemoveUtenti() {

	if ($('#utentiGrid .GridSelected').length > 0) {

		var idUtenti = $("#utentiGrid .GridSelected").map(function () { return $(this).attr("id"); }).get();

		$.ajax({
			type: "POST",
			url: "ListaUtenti.aspx/DeleteUtenti",
			data: "{'idUtenti':'" + idUtenti.join(";") + "'}",
			contentType: "application/json; charset=utf-8",
			dataType: "json",
			async: false,
			success: function (result) {

				$('#utentiGrid .GridSelected').remove();
			},
			error: function (error) {

				var message = GetMessageFromAjaxError(error.responseText);
				alert(message);
			}
		});
	}
}


function ImportaDaCsv() {

	var dialog = $('#importaDaCsv').dialog({
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
		buttons: {
			"Ok": function () {

				$(".importFake").trigger('click');
			},
			"Annulla": function () {

				$(this).dialog("close");
			}
		}
	});

	dialog.parent().appendTo(jQuery("form:first"));
}
