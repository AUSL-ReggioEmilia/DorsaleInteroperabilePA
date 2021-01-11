$(document).ready(function () {
	//$('body').css('overflow', 'hidden');
});

$(window).resize(function () {

});

function FiltraUtentiGruppo() {

	var idGruppo = $("#UtentiGruppoUtenti ").attr("idGruppo");

	if (idGruppo)
		CaricaUtenti(idGruppo);
	else
		alert('Occorre prima selezionare un gruppo di utenti');
}

function OpenUtentiDialog(idGruppo,descrizioneGruppo) {
	$('body').css('cursor', 'wait');

	$('#UtentiGruppoUtenti').dialog({
		width: 1200,
		height: 650 + "px",
		modal: true,
		position: 'center',
		title: "Aggiungi o Rimuovi Utenti al Gruppo &nbsp; &nbsp; &nbsp; [" + descrizioneGruppo + "]",
		resizable: false,
		open: function (event, ui) {

			$('body').css({ 'overflow-y': 'hidden', 'overflow-x': 'hidden' });
			CaricaUtenti(idGruppo);
			$('#UtentiGruppoUtenti').attr("idGruppo", idGruppo);
			$('body').css('cursor', 'default');
		},
		close: function (event, ui) {

			$('body').css('cursor', 'wait');
			//pulisce le due liste, così se si riapre il popup risulta pulito
			$("#Utenti").html("");
			$("#listaUtenti").html("");
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
function CaricaUtenti(idGruppo) {

	if (!idGruppo || idGruppo == '') {
		$("#Utenti").html("");
		return;
	}

	var descrizioneFiltroUtenteGruppo = $("#descrizioneFiltroUtenteGruppo").val();
	$("#loaderGruppo").show();

	$.ajax({
		type: "POST",
		url: "GruppiUtenti.aspx/GetUtenti",
		data: "{'idGruppo':'" + idGruppo + "', 'descrizioneFiltroUtenteGruppo':'" + escape(descrizioneFiltroUtenteGruppo) + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (!result.d) {

				$("#Utenti").html("Nessun utente");
				$("#loaderGruppo").fadeOut();
				return;
			}

			var html = [];
			html.push('<table id="utentiGrid" class="tablesorter" style="border:1px silver solid; border-collapse:collapse; width:100%;height:auto;"><thead>');
			html.push('<th style="width:25px;"><input type="checkbox" style="background: transparent; border-style: none; cursor: pointer;" onclick="SelectDeselectAll($(this), $(\'#utentiGrid\'));" /></th>');
			html.push('<th>Tipo</th><th>Utente</th><th>Nome</th><th>Attivo</th>');
			html.push('</thead><tbody>');

			for (var property in result.d) {
				var utente = result.d[property];
				html.push('<tr id="' + property + '" class="GridItem" ' + (utente.Attivo ? '' : ' style="background-color: silver;"') + '>');
				html.push('<td><input type="checkbox" class="gridCheckBox" /></td>');
				html.push('<td>' + utente.DescrizioneTipo + '</td>');
				html.push('<td>' + utente.NomeUtente + '</td>');
				html.push('<td>' + utente.Descrizione + '</td>');
				html.push('<td>' + (utente.Attivo ? '<img src="../Images/ok.png" />' : '<img src="../Images/PixelTrasparente.gif" />') + '</td>');
				html.push('</tr>');
			}
			html.push('</tbody></table>');
			$("#Utenti").html(html.join(""));

			$("#utentiGrid").tablesorter({
				headers: {
					0: { sorter: false }
				}
			});
		
			$("#utentiGrid .gridCheckBox").change(function () {
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
function CercaUtenti() {

	var descrizione = $("#descrizioneFiltro").val();

	$("#loader").show();

	$.ajax({
		type: "POST",
		url: "GruppiUtenti.aspx/GetListaUtenti",
		data: "{'descrizione':'" + escape(descrizione) + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (result.d == null) {

				$("#listaUtenti").html("<br />Nessun risultato");
				$("#loader").fadeOut();
				return;
			}

			var idUtentiDelGruppo = $("#utentiGrid .GridItem").map(function () { return $(this).attr("id"); }).get();
			var html = [];

			html.push('<table id="selettoreGrid" class="tablesorter" style="border:1px silver solid; width:100%;height:auto;"><thead>');
			html.push('<th style="width:25px;height:29px;"><input type="checkbox" style="background: transparent; border-style: none; cursor: pointer;" onclick="SelectDeselectAll($(this), $(\'#selettoreGrid\'));" /></th>');
			html.push('<th>Tipo</th><th>Utente</th><th>Nome</th><th>Attivo</th>');
			html.push('</thead><tbody>');

			for (var i = 0; i < result.d.length; i++) {
				var utente = result.d[i];
				html.push('<tr id="' + utente.Id + '" class="GridItem" ' + (utente.Attivo ? '' : 'style="background-color: silver;"') + '>');
				html.push('<td><input type="checkbox" class="gridCheckBox" ');

				if (idUtentiDelGruppo.length > 0) {
					var idx = $.inArray(utente.Id, idUtentiDelGruppo);
					if (idx > -1) {
						html.push(' style="display:none;"');
						idUtentiDelGruppo.splice(idx, 1);
					}
				}
				html.push('/></td>');
				html.push('<td>' + utente.DescrizioneTipo + '</td>');
				html.push('<td>' + utente.NomeUtente + '</td>');
				html.push('<td>' + utente.Descrizione + '</td>');
				html.push('<td>' + (utente.Attivo ? '<img src="../Images/ok.png" />' : '<img src="../Images/PixelTrasparente.gif" />') + '</td>');
				html.push('</tr>');
			}

			html.push('</tbody></table>');
			$("#listaUtenti").html(html.join(""));

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
function AddUtenti() {
	var idGruppo = $("#UtentiGruppoUtenti ").attr("idGruppo");

	if (idGruppo) {
		var idUtenti = new Array();
		var idUtentiDelGruppo = $("#utentiGrid .GridItem").map(function () { return $(this).attr("id"); }).get();

		//UTENTI SELEZIONATI A DESTRA
		$('#selettoreGrid .GridSelected').each(function () {

			var idUtente = $(this).attr("id");

			if ($.inArray(idUtente, idUtentiDelGruppo) == -1)
				idUtenti.push(idUtente);

			//NASCONDO IL CHECKBOX DALLA LISTA DI DESTRA
			var riga = $(this);
			var checkbox = riga.children().children('input');
			riga.removeClass('GridSelected');
			checkbox.attr("checked", "");
			checkbox.hide();
		});
		
		if (idUtenti.length > 0) {
			//CHIAMATA AL METODO INSERT SU DB
			AggiungiUtentiAGruppo(idGruppo, idUtenti);
			//RICARICO LA LISTA DI SINISTRA
			CaricaUtenti(idGruppo);
		}
		else
		{ alert('Selezionare gli utenti da aggiungere.'); }

	}
	else
	{ alert('Occorre prima selezionare un gruppo di utenti'); }
}

function AggiungiUtentiAGruppo(idGruppo, idUtenti) {

	$.ajax({
		type: "POST",
		url: "GruppiUtenti.aspx/InsertUtentiInGruppo",
		data: "{'idGruppo':'" + idGruppo + "','idUtenti':'" + idUtenti.join(";") + "'}",
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
function RemoveUtenti() {

	var idGruppo = $("#UtentiGruppoUtenti ").attr("idGruppo");
	//array con gli id degli utenti marcati a sinistra
	var idUtenti = $("#utentiGrid .GridSelected").map(function () { return $(this).attr("id"); }).get();
	
	if (idUtenti.length > 0) {
		//CHIAMATA AL METODO DELETE SU DB
		RimuoviUtenteDaGruppo(idGruppo, idUtenti);

		//RIMUOVO LE RIGHE <tr> MARCATE NELLA TABLE A SINISTRA		
		$("#utentiGrid .GridSelected").remove();

		for (var i = 0; i < idUtenti.length; i = i + 1) {
			//CERCO LA RIGA NELLA LISTA DI DESTRA PER MOSTRARE IL SUO CHECHBOX
			$('#selettoreGrid .GridItem[id="' + idUtenti[i] + '"]').each(function () {
				var riga = $(this);
				var checkbox = riga.children().children('input');
				checkbox.show();
				checkbox.attr("checked", "");
			});
		}
	}
	else
	{ alert('Selezionare gli utenti da rimuovere.'); }

}

function RimuoviUtenteDaGruppo(idGruppo, idUtenti) {

	$.ajax({
		type: "POST",
		url: "GruppiUtenti.aspx/DeleteUserDaGruppo",
		data: "{'idGruppo':'" + idGruppo + "', 'idUtenti':'" + idUtenti.join(";") + "'}",
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
//Apre la modale per la modifica di un gruppo
//
function ModificaGruppo(idGruppo, descrizione,note) {
    //ottengo le textbox per la descrizione e le note
    var descrizioneTextBox = $("#gruppo_utenti_descrizione");
    var noteTextBox = $("#gruppo_utenti_note");

    //riempo le textbox con i valori del gruppo corrente
	descrizioneTextBox.val(descrizione);
	descrizioneTextBox.next().hide();
	noteTextBox.val(note);

    //Apro la modale
	$('#NewOrEditGruppoUtenti').dialog({
		height: 400,
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

                //Salvo il gruppo
				SalvaGruppo(idGruppo, descrizioneTextBox.val(),noteTextBox.val());

				$(this).dialog("close");
			},
			"Annulla": function () {

				$(this).dialog("close");
			}
		}
	});
}

//
//Apre la modale per l'inserimento di un gruppo
//
function AggiungiGruppo() {
    //Ottengo le textbox per la descrizione e le note
    var descrizioneTextBox = $("#gruppo_utenti_descrizione");
    var noteTextBox = $("#gruppo_utenti_note");

    //Sbianco le textbox perchè sono in inserimento
	descrizioneTextBox.val('');
	descrizioneTextBox.next().hide();
	noteTextBox.val('');

    //Apro la modale
	$('#NewOrEditGruppoUtenti').dialog({
		height: 400,
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

                //all'ok salva il gruppo
				var idGruppo = SalvaGruppo('', descrizioneTextBox.val(),noteTextBox.val());

				$(this).dialog("close");
			},
			"Annulla": function () {

				$(this).dialog("close");
			}
		}
	});
}

//
//Salva il gruppo chiamando una funzione ajax lato backend
//
function SalvaGruppo(idGruppo, descrizione,note) {
    //escape(escapeHtmlEntities(codice))
	$.ajax({
		type: "POST",
		url: "GruppiUtenti.aspx/UpdateGruppo",
		data: "{'idGruppo':'" + idGruppo + "','descrizione':'" + escape(escapeHtmlEntities(descrizione)) + "','note':'"+escape(escapeHtmlEntities(note)) +"'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function (result) {

			if (!result.d) {

				return;
			}

			idGruppo = result.d;

            //ricarico la pagina
			window.location.href = window.location.href;

		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});

	return idGruppo;
}

//
//Elimina un gruppo in base al suo id
//
function EliminaGruppo() {

	if (!confirm("Il gruppo verrà eliminato, continuare?")) {
		return;
	}

    //Ottengo l'id del gruppo
	var idGruppo = $("#UtentiGruppoUtenti ").attr("idGruppo");

    //Chiamata al metodo backend
	$.ajax({
		type: "POST",
		url: "GruppiUtenti.aspx/DeleteGruppo",
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
