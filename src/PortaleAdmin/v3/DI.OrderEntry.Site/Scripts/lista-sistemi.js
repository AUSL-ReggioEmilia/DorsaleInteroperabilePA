$(document).ready(function () {

	SetupValoreDefaultAutoComplete();
});

var _datiDefault;

function SetupValoreDefaultAutoComplete() {

	var valoreDefaultTextBox = $("#dato_valoreDefault");

	_datiDefault = CaricaDatiAccessoriDefault();

	valoreDefaultTextBox.autocomplete({
		source: _datiDefault,
		minLength: 0,
		select: function (event, ui) {

			valoreDefaultTextBox.val(ui.item.Descrizione);
			valoreDefaultTextBox.attr("codice", ui.item.Codice);

			setTimeout(function () {
				valoreDefaultTextBox.autocomplete("close");
			});

			return false;
		}
	}).data("autocomplete")._renderItem = function (ul, item) {
		return $("<li>")
        .data("item.autocomplete", item)
        .append("<a>" + item.Descrizione + "</a>")
        .appendTo(ul);
	};

	//apre la tendina sul focus
	valoreDefaultTextBox.focus(function () {

		valoreDefaultTextBox.autocomplete("search", "");
	});

	//cancella il codice se l'utente scrive nella textbox
	valoreDefaultTextBox.keypress(function () {

		valoreDefaultTextBox.removeAttr("codice");
	});
}

function SaveFilter(controlId, value) {

	$.ajax({
		type: "POST",
		url: "ListaSistemi.aspx/SaveFilter",
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

/*
*Metodo che si occupa della creazione della griglia dei sistemi in base ai parametri passati.
*/
function LoadSistemi(codiceDescrizione, azienda, erogante, richiedente, attivo, cancellazionePostInoltro,cancellazionePostInCarico) {
	SaveFilter('CodiceDescrizioneFiltroTextBox', codiceDescrizione);
	SaveFilter('AziendaFiltroDropDownList', azienda);
	SaveFilter('EroganteCheckBox', erogante);
	SaveFilter('RichiedenteCheckBox', richiedente);
	//SaveFilter('AttivoCheckBox', attivo);
	SaveFilter('AttivoDropDown', attivo);
	//SaveFilter('CancellazionePostInoltroCheckBox', cancellazionePostInoltro);
	SaveFilter('CancellazionePostInoltroDropDown', cancellazionePostInoltro);
	SaveFilter('CancellazionePostInCaricoDropDown', cancellazionePostInCarico);

	SetLoaderForButton('.cercaFlag', true);

    //Chiamata ajax per ottenere i sistemi
	$.ajax({
		type: "POST",
		url: "ListaSistemi.aspx/LoadSistemi",
		data: "{'codiceDescrizione':'" + codiceDescrizione + "', 'azienda':'" + azienda + "', 'erogante':'" + erogante + "', 'richiedente':'" + richiedente + "', 'attivo':'" + attivo + "', 'cancellazionePostInoltro':'" + cancellazionePostInoltro + "', 'cancellazionePostInCarico':'" + cancellazionePostInCarico + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (!result.d) {

				$("#Sistemi").html("Nessun risultato");
				if ($("#selettoreGrid").length > 0) CercaSistemi();
				SetLoaderForButton('.cercaFlag', false);
				return;
			}

			var html = [];
			var i = 0;

            //Creazione della tabella dei sistemi.
			html.push('<table id="sistemiGrid" class="tablesorter" style="border:1px silver solid; border-collapse:collapse; width:100%; margin-top:5px;"><thead>');
			html.push('<th style="width:25px;">Modifica</th>');
			html.push('<th style="width:25px;">Dati Accessori</th>');
			html.push('<th>Azienda</th>');
			html.push('<th>Codice</th>');
			html.push('<th>Descrizione</th>');
			html.push('<th style="width:50px;">Erogante</th>');
			html.push('<th style="width:50px;">Richiedente</th>');
			html.push('<th style="width:90px;">Cancellazione Post-Inoltro</th>');
			html.push('<th style="width:90px;">Cancellazione Post-InCarico</th>');
			html.push('<th style="width:50px;">Attivo</th>');
			html.push('</thead><tbody>');

			for (var property in result.d) {
				i++;
				var sistema = result.d[property];
				html.push('<tr id="' + sistema.Id + '">');

				html.push('<td><input type="button" class="editButton" onclick="ModificaSistema(\'' + sistema.Id + '\')" /></td>');

				if (sistema.Erogante)
				    html.push('<td><input type="button" title="modifica dati accessori" class="toolsButton" onclick="OpenDatiAccesoriDialog(\'' + sistema.Id + '\',\''+ sistema.Codice + '\',\'' +sistema.Descrizione +'\' )"  codice=' + sistema.Codice + ' descrizione=' + sistema.Descrizione + ' /></td>');
				else
					html.push('<td></td>');

				html.push('<td>' + sistema.Azienda + '</td>');
				html.push('<td>' + sistema.Codice + '</td>');
				html.push('<td style="text-align:center;">' + sistema.Descrizione + '</td>');
				html.push('<td>' + (sistema.Erogante ? '<img src="../Images/ok.png" />' : '<img src="../Images/PixelTrasparente.gif" />') + '</td>');
				html.push('<td>' + (sistema.Richiedente ? '<img src="../Images/ok.png" />' : '<img src="../Images/PixelTrasparente.gif" />') + '</td>');
				html.push('<td>' + (sistema.CancellazionePostInoltro ? '<img src="../Images/ok.png" />' : '<img src="../Images/PixelTrasparente.gif" />') + '</td>');
				html.push('<td>' + (sistema.CancellazionePostInCarico ? '<img src="../Images/ok.png" />' : '<img src="../Images/PixelTrasparente.gif" />') + '</td>');
				html.push('<td>' + (sistema.Attivo ? '<img src="../Images/ok.png" />' : '<img src="../Images/PixelTrasparente.gif" />') + '</td>');
				html.push('</tr>');

			}

			html.push('</tbody></table>');

			$("#Sistemi").html(html.join(""));

			$("#sistemiGrid").tablesorter({

				headers: {
					0: { sorter: false },
					1: { sorter: false },
					2: { sorter: false }
				}
			});
			/*
			$("#loader").fadeOut();

			$("#sistemiGrid .GridItem").hover(function () {

			$(this).addClass("GridHover");

			}, function () {

			$(this).removeClass("GridHover");
			});
    		
			$("#sistemiGrid .gridCheckBox").change(function () {

			var checked = $(this).attr('checked');

			if (checked == 'checked') {

			$(this).parent().parent().addClass('GridSelected');

			} else {

			$(this).parent().parent().removeClass('GridSelected');
			}
			});
			*/

			SetLoaderForButton('.cercaFlag', false);

			//GridApplyRowStyle('sistemiGrid');
		},
		error: function (error) {

			SetLoaderForButton('.cercaFlag', false);
			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}

	});
}

function ModificaSistema(idSistema) {

	var sistema = CaricaSistema(idSistema);

	var sistema_codice = $("#sistema_codice");
	var sistema_descrizione = $("#sistema_descrizione");
	var sistema_azienda = $("#sistema_azienda");
	var attivoCheckBox = $("#sistema_attivo");
	var cancellazionePostInoltroCheckBox = $("#sistema_cancellazionePostInoltro");
	var cancellazionePostInCaricoCheckBox = $("#sistema_cancellazionePostInCarico");

	sistema_azienda.html(sistema.Azienda);
	sistema_codice.html(sistema.Codice);
	sistema_descrizione.html(sistema.Descrizione);
	attivoCheckBox.attr('checked', sistema.Attivo);
	cancellazionePostInoltroCheckBox.attr('checked', sistema.CancellazionePostInoltro);
	cancellazionePostInCaricoCheckBox.attr('checked', sistema.CancellazionePostInCarico);

	$('#modificaSistema').dialog({
		height: 500,
		width: 400,
		modal: true,
		position: 'center',
		title: "Modifica sistema",
		resizable: true,
		open: function (event, ui) {

			$('body').css({ 'overflow-y': 'hidden', 'overflow-x': 'hidden' });
		},
		close: function (event, ui) {

			$('body').css({ 'overflow-y': 'scroll', 'overflow-x': 'auto' });
		},
		buttons: {
			"Ok": function () {

			    SalvaSistema(idSistema, sistema.Codice, sistema.Descrizione, sistema.Azienda, sistema.Erogante, sistema.Richiedente, attivoCheckBox.attr('checked') == 'checked', cancellazionePostInoltroCheckBox.attr('checked') == 'checked', cancellazionePostInCaricoCheckBox.attr('checked') == 'checked');

				//SalvaSistema(idSistema, attivoCheckBox.attr('checked') == 'checked', cancellazionePostInoltroCheckBox.attr('checked') == 'checked');

				PageLoadSistemi();

				$(this).dialog("close");
			},
			"Annulla": function () {

				$(this).dialog("close");
			}
		}
	});
}

function CaricaSistema(idSistema) {

	var sistema;

	$.ajax({
		type: "POST",
		url: "ListaSistemi.aspx/GetSistema",
		data: "{'idSistema':'" + idSistema + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function (result) {

			if (!result.d) {

				return;
			}

			sistema = result.d;
		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});

	return sistema;
	// riceve: {.Id = row.ID, .Codice = row.Codice, .Descrizione = row.Descrizione, 
	//  .Azienda = row.Azienda, .Erogante = row.Erogante, .Richiedente = row.Richiedente, 
	//  .Attivo = row.Attivo, .CancellazionePostInoltro = row.CancellazionePostInoltro}

}


function SalvaSistema(idSistema, Codice, Descrizione, Azienda, Erogante, Richiedente, Attivo, CancellazionePostInoltro,CancellazionePostInCarico)
{
//UpdateSistema(idSistema As String, codice As String, descrizione As String, azienda As String, erogante As Boolean, richiedente As Boolean, attivo As Boolean, cancellazionePostInoltro As Boolean) As String

	$.ajax({
		type: "POST",
		url: "ListaSistemi.aspx/UpdateSistema",
		data: "{'idSistema':'" + idSistema + "','codice':'" + escape(Codice) + "','descrizione':'" + escape(Descrizione) + "','azienda':'" + escape(Azienda) + "','erogante':'" + Erogante + "','richiedente':'" + Richiedente + "','attivo':'" + Attivo + "','cancellazionePostInoltro':'" + CancellazionePostInoltro + "','cancellazionePostInCarico':'" + CancellazionePostInCarico + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function (result) {

			if (!result.d) {

				return;
			}

			idSistema = result.d;
		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText);

			if (message.indexOf('duplicate key') > -1)
				alert('Il codice del sistema deve essere univoco per azienda');
			else
				alert(message);
		}
	});

	return idSistema;
}


/********Dialog dati accessori**********/

function OpenDatiAccesoriDialog(idSistema,codiceSistema,descrizioneSistema) {
	$('body').css('cursor', 'wait');

	$('#aggiungiDatiAccessori').dialog({
		width: 1200,
		height: 650 + "px",
		modal: true,
		position: 'center',
		title: "Modifica Dati Accessori &nbsp; &nbsp; &nbsp; [" + codiceSistema + "] - " + descrizioneSistema,
		resizable: false,
		open: function (event, ui) {

			$('body').css({ 'overflow-y': 'hidden', 'overflow-x': 'hidden' });

			CaricaDatiAccessori(idSistema);

			$('#aggiungiDatiAccessori').attr("idSistema", idSistema);
			$('body').css('cursor', 'default');
		},
		close: function (event, ui) {

			$('body').css('cursor', 'wait');
			//pulisce le due liste, così se si riapre il popup risulta pulito
			$("#DatiAccessori").html("");
			$("#listaDatiAccessori").html("");
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
function CaricaDatiAccessori(idSistema) {

	$.ajax({
		type: "POST",
		url: "ListaSistemi.aspx/GetDatiAccessori",
		data: "{'idSistema':'" + idSistema + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (!result.d) {

				$("#DatiAccessori").html("Nessun dato accessorio.");			
				return;
			}

			var html = [];
			html.push('<table id="datiAccessoriGrid" class="tablesorter" style="border:1px silver solid; border-collapse:collapse; width:100%; height:auto;"><thead>');
			html.push('<th style="width:26px;"><input type="checkbox" style="background: transparent; border-style: none; cursor: pointer;" onclick="SelectDeselectAll($(this), $(\'#datiAccessoriGrid\'));" /></th>');
			html.push('<th style="width:26px;"></th><th style="width:80px;">Codice</th><th>Etichetta</th><th>Tipo</th>');
			html.push('</thead><tbody>');

			for (var property in result.d) {
				var datoAccessorio = result.d[property];
				html.push('<tr id="' + datoAccessorio.Codice + '" class="GridItem" >');
				html.push('<td><input type="checkbox" class="gridCheckBox" /></td>');
				html.push('<td><input type="button" title="modifica dati accessori sistemi" class="editButton" onclick="ModificaDatiAccessoriSistemi(\'' + idSistema + '\', \'' + datoAccessorio.Codice + '\', \'' + datoAccessorio.Etichetta + '\' )" /></td>');
				html.push('<td>' + datoAccessorio.Codice + '</td>');
				html.push('<td>' + datoAccessorio.Etichetta + '</td>');
				html.push('<td>' + datoAccessorio.Tipo + '</td>');
				html.push('</tr>');
			}

			html.push('</tbody></table>');
			$("#DatiAccessori").html(html.join(""));

			$("#datiAccessoriGrid").tablesorter({

				headers: {
					0: { sorter: false },
					1: { sorter: false }
				}
			});

			$("#datiAccessoriGrid .gridCheckBox").change(function () {
				$(this).parent().parent().toggleClass('GridSelected');
			});

			$("#loader").fadeOut();
		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});
}

//LISTA DI DESTRA
function CercaDatiAccessori() {

	var codice = $("#codiceFiltro").val();
	var descrizione = $("#descrizioneFiltro").val();

	$("#loader").show();

	$.ajax({
		type: "POST",
		url: "ListaSistemi.aspx/GetListaDatiAccessori",
		data: "{'codice':'" + escape(codice) + "','descrizione':'" + escape(descrizione) + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (result) {

			if (result.d == null) {

				$("#listaDatiAccessori").html("<br />Nessun risultato");
				$("#loader").fadeOut();
				return;
			}

			var idDatiAccessoriDelSistema = $("#datiAccessoriGrid .GridItem").map(function () { return $(this).attr("Id"); }).get();
			var html = [];

			html.push('<table id="selettoreGrid" class="tablesorter" style="border:1px silver solid; border-collapse:collapse; width:100%; height:auto;"><thead>');
			html.push('<th style="width:26px;"><input type="checkbox" style="background: transparent; border-style: none; cursor: pointer;" onclick="SelectDeselectAll($(this), $(\'#selettoreGrid\'));" /></th>');
			html.push('<th>Codice</th><th>Etichetta</th><th>Tipo</th>');
			html.push('</thead><tbody>');

			for (var i = 0; i < result.d.length; i++) {
				var datoAccessorio = result.d[i];
				html.push('<tr id="' + datoAccessorio.Codice + '" class="GridItem">');
				html.push('<td><input type="checkbox" class="gridCheckBox" ');
				if (idDatiAccessoriDelSistema.length > 0) {
					var idx = $.inArray(datoAccessorio.Codice, idDatiAccessoriDelSistema);
					if (idx > -1) {
						html.push(' style="display:none;"');
						idDatiAccessoriDelSistema.splice(idx, 1);
					}
				}
				html.push('/></td>');
				html.push('<td>' + datoAccessorio.Codice + '</td>');
				html.push('<td>' + datoAccessorio.Etichetta + '</td>');
				html.push('<td>' + datoAccessorio.Tipo + '</td>');
				html.push('</tr>');
			}

			html.push('</tbody></table>');
			$("#listaDatiAccessori").html(html.join(""));

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
function AddDatiAccessori() {

	if ($('#selettoreGrid .GridSelected').length > 0) {

		var idSistema = $('#aggiungiDatiAccessori').attr("idSistema");
		var idDatiAccessori = new Array();
		var idDatiAccessoriDelSistema = $("#datiAccessoriGrid .GridItem").map(function () { return $(this).attr("id"); }).get();

		//ELEMENTI SELEZIONATI A DESTRA
		$('#selettoreGrid .GridSelected').each(function () {

			var idDatoAccessorio = $(this).attr("id");

			if ($.inArray(idDatoAccessorio, idDatiAccessoriDelSistema) == -1)
				idDatiAccessori.push(idDatoAccessorio);

			//NASCONDO IL CHECKBOX DALLA LISTA DI DESTRA
			var riga = $(this);
			var checkbox = riga.children().children('input');
			riga.removeClass('GridSelected');
			checkbox.attr("checked", "");
			checkbox.hide();
		});

		if (idDatiAccessori.length > 0) {
			//CHIAMATA AL METODO INSERT SU DB
			AggiungiDatiAccessoriASistema(idSistema, idDatiAccessori);
			//RICARICO LA LISTA DI SINISTRA
			CaricaDatiAccessori(idSistema);
		}
		else
		{ alert('Selezionare i dati accessori da aggiungere.'); }		
		
	}
}



function AggiungiDatiAccessoriASistema(idSistema, idDatiAccessori) {

	$.ajax({
		type: "POST",
		url: "ListaSistemi.aspx/InsertDatiAccessoriInSistema",
		data: "{'idSistema':'" + idSistema + "','codiciDatiAccessori':'" + idDatiAccessori.join(";") + "'}",
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
function RemoveDatiAccessori() {

	var idSistema = $('#aggiungiDatiAccessori').attr("idSistema");
	var idDatiAccessori = $("#datiAccessoriGrid .GridSelected").map(function () { return $(this).attr("id"); }).get();

	if (idDatiAccessori.length > 0) {
		//CHIAMATA AL METODO DELETE SU DB
		RimuoviDatoAccessorioDaSistema(idSistema, idDatiAccessori);

		//RIMUOVO LE RIGHE <tr> MARCATE NELLA TABLE A SINISTRA		
		$("#datiAccessoriGrid .GridSelected").remove();

		for (var i = 0; i < idDatiAccessori.length; i = i + 1) {
			//CERCO LA RIGA NELLA LISTA DI DESTRA PER MOSTRARE IL SUO CHECHBOX
			$('#selettoreGrid .GridItem[id="' + idDatiAccessori[i] + '"]').each(function () {
				var riga = $(this);
				var checkbox = riga.children().children('input');
				checkbox.show();
				checkbox.attr("checked", "");
			});
		}
	}
	else
	{ alert('Selezionare i dati accessori da rimuovere.'); }

}

function RimuoviDatoAccessorioDaSistema(idSistema, idDatiAccessori) {

	$.ajax({
		type: "POST",
		url: "ListaSistemi.aspx/DeleteDatiAccessoriDaSistema",
		data: "{'idSistema':'" + idSistema + "', 'codiciDatiAccessori':'" + idDatiAccessori.join(";") + "'}",
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


/********Dialog dati accessori sistemi**********/

function ModificaDatiAccessoriSistemi(idSistema, codiceDatoAccessorio, etichettaDatoAccessorio) {

	var dato = CaricaDatiAccessoriSistemi(idSistema, codiceDatoAccessorio);

	var labelCodiceDatoAccessorio = $(".labelCodiceDatoAccessorio")

	var codiceDatoAccessorioTextBox = $("#dato_codiceDatoAccessorio")
	var attivoCheckBox = $("#dato_attivo");
	var ereditaCheckBox = $("#dato_eredita");
	var sistemaCheckBox = $("#dato_sistema");
	var valoreDefaultTextBox = $("#dato_valoreDefault");


	labelCodiceDatoAccessorio.text(dato.CodiceDatoAccessorio);
	codiceDatoAccessorioTextBox.val(dato.CodiceDatoAccessorio);
	attivoCheckBox.attr('checked', dato.Attivo);
	ereditaCheckBox.attr('checked', dato.Eredita);
	sistemaCheckBox.attr('checked', dato.Sistema);
	valoreDefaultTextBox.val(dato.ValoreDefault);

	codiceDatoAccessorioTextBox.attr('disabled', 'disabled');
	codiceDatoAccessorioTextBox.next().hide();

	EnableEreditaDatiAccessorisistemi();
	EnableValoreDefault()
	valoreDefaultTextBox.next().hide();

	$('#modificaDatiAccessoriSistemi').dialog({
		height: 550,
		width: 550,
		modal: true,
		position: 'center',
		title: "Modifica Dati Accessori Sistemi &nbsp; &nbsp; &nbsp; [" + codiceDatoAccessorio + "] - " + etichettaDatoAccessorio,
		resizable: true,
		open: function (event, ui) {

			$('body').css({ 'overflow-y': 'hidden', 'overflow-x': 'hidden' });
		},
		close: function (event, ui) {

			$('body').css({ 'overflow-y': 'scroll', 'overflow-x': 'auto' });
		},
		buttons: {
			"Ok": function () {

				if (codiceDatoAccessorioTextBox.val() == '') {

					codiceDatoAccessorioTextBox.next().fadeIn();
					return;
				}

				if (sistemaCheckBox.attr('checked') == 'checked' && valoreDefaultTextBox.val() == '') {

					valoreDefaultTextBox.next().fadeIn();
					return;
				}

				AggiornaDatiAccessoriSistemi(dato.ID, dato.IdSistema, dato.CodiceDatoAccessorio, attivoCheckBox.attr('checked') == 'checked', ereditaCheckBox.attr('checked') == 'checked', sistemaCheckBox.attr('checked') == 'checked', valoreDefaultTextBox.val());

				CaricaDatiAccessori(idSistema);

				$(this).dialog("close");
			},
			"Annulla": function () {

				$(this).dialog("close");
			}
		}
	});
}

function AggiornaDatiAccessoriSistemi(id, idSistema, codiceDatoAccessorio, attivo, eredita, sistema, valoreDefault) {

	$.ajax({
		type: "POST",
		url: "ListaSistemi.aspx/UpdateDatiAccessoriSistemi",
		data: "{'id':'" + id + "','idSistema':'" + idSistema + "','codiceDatoAccessorio':'" + escape(codiceDatoAccessorio) + "','attivo':'" + attivo + "','eredita':'" + eredita + "','sistema':'" + sistema + "','valoreDefault':'" + escape(escapeHtmlEntities(valoreDefault)) + "'}",
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

			if (message.indexOf('duplicate key') > -1)
				alert('Il codice deve essere univoco');
			else
				alert(message);
		}
	});
}

function EnableEreditaDatiAccessorisistemi() {

	var ereditaCheckBox = $("#dato_eredita");
	var sistemaCheckBox = $("#dato_sistema");
	var valoreDefaultTextBox = $("#dato_valoreDefault");

	if (ereditaCheckBox.attr('checked') == 'checked') {

		sistemaCheckBox.attr('disabled', 'disabled');
		valoreDefaultTextBox.attr('disabled', 'disabled');

	}
	else {

		sistemaCheckBox.removeAttr('disabled');
		valoreDefaultTextBox.removeAttr('disabled');
		EnableValoreDefault()
	}

	//        if (sistemaCheckBox.attr('checked') == 'checked') {

	//            valoreDefaultTextBox.removeAttr('disabled');
	//        }
	//        else {

	//            valoreDefaultTextBox.attr('disabled', 'disabled');
	//        }

	//        return (ereditaCheckBox.attr('checked') == 'checked');
}

function EnableValoreDefault() {

	var sistemaCheckBox = $("#dato_sistema");
	var valoreDefaultTextBox = $("#dato_valoreDefault");

	if (sistemaCheckBox.attr('checked') == 'checked') {

		valoreDefaultTextBox.removeAttr('disabled');
	}
	else {

		valoreDefaultTextBox.attr('disabled', 'disabled');
	}

	return (sistemaCheckBox.attr('checked') == 'checked');
}

function CaricaDatiAccessoriDefault() {

	var datiAccessoriSistemaDefault;

	$.ajax({
		type: "POST",
		url: "ListaSistemi.aspx/GetDatiSistemaDiDefault",
		data: "",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function (result) {

			datiAccessoriSistemaDefault = result.d;
		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});

	return datiAccessoriSistemaDefault;
}

function CaricaDatiAccessoriSistemi(idSistema, codiceDatoAccessorio) {

	var dato;

	$.ajax({
		type: "POST",
		url: "ListaSistemi.aspx/GetDatiAccessoriSistemi",
		data: "{'idSistema':'" + idSistema + "', 'codiceDatoAccessorio':'" + escape(codiceDatoAccessorio) + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function (result) {

			if (!result.d) {

				return;
			}

			dato = result.d;
		},
		error: function (error) {

			var message = GetMessageFromAjaxError(error.responseText);
			alert(message);
		}
	});

	return dato;
}