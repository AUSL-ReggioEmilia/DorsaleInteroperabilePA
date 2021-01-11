
$(document).ready(function () {

    $(".TimeInput").timepicker({ onSelect: function () { } });

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


function AggiungiDato(button) { //button è opzionale, si passa solo in caso di copia dato

    var codiceTextBox = $("#dato_codice");
    var descrizioneTextBox = $("#dato_descrizione");
    var etichettaTextBox = $("#dato_etichetta");
    var tipoComboBox = $("#" + _tipoComboId);
    var obbligatorioCheckBox = $("#dato_obbligatorio");
    var ripetibileCheckBox = $("#dato_ripetibile");
    var ordinamentoTextBox = $("#dato_ordinamento");
    var valoriTextBox = $("#dato_valori");
    var gruppoTextBox = $("#dato_gruppo");
    var validazioneRegExTextBox = $("#dato_validazioneRegEx");
    var validazioneMessaggioTextBox = $("#dato_validazioneMessaggio");
    var sistemaCheckBox = $("#dato_sistema");
    var valoreDefaultTextBox = $("#dato_valoreDefault");
    var nomeDatoAggiuntivoTextBox = $("#dato_nomeDatoAggiuntivo");
    var concatenaCheckBox = $("#dato_concatena");
    var Title;

    //se è stato premuto il tasto copia su un dato esistente, precarico i valori da copiare nei controlli
    if (typeof button != 'undefined') {
        var codice = button.attr('codicedato');
        var dato = CaricaDato(codice);

        Title = "Creazione copia del dato accessorio " + codice;
        descrizioneTextBox.val(htmlDecode(dato.Descrizione));
        etichettaTextBox.val(htmlDecode(dato.Etichetta));
        tipoComboBox.val(dato.Tipo);
        obbligatorioCheckBox.attr('checked', dato.Obbligatorio);
        ripetibileCheckBox.attr('checked', dato.Ripetibile);
        valoriTextBox.val(htmlDecode(dato.Valori));
        ordinamentoTextBox.val(dato.Ordinamento);
        gruppoTextBox.val(htmlDecode(dato.Gruppo));
        validazioneRegExTextBox.val(htmlDecode(dato.ValidazioneRegEx));
        validazioneMessaggioTextBox.val(htmlDecode(dato.ValidazioneMessaggio));
        sistemaCheckBox.attr('checked', dato.Sistema);
        nomeDatoAggiuntivoTextBox.val(htmlDecode(dato.NomeDatoAggiuntivo));
        concatenaCheckBox.attr('checked', dato.Concatena);

        var datoDefault;
        for (var i = 0; i < _datiDefault.length; i++) {
            if (_datiDefault[i].Codice == dato.ValoreDefault) {
                datoDefault = _datiDefault[i];
                break;
            }
        }

        if (!datoDefault)
            valoreDefaultTextBox.val(dato.ValoreDefault);

        else {
            valoreDefaultTextBox.val(datoDefault.Descrizione);
            valoreDefaultTextBox.attr("codice", datoDefault.Codice);
        }
    }
    else { //INSERIMENTO NUOVO RECORD

        Title = "Inserimento dato accessorio";
        descrizioneTextBox.val('');
        etichettaTextBox.val('');
        tipoComboBox[0].selectedIndex = 0
        obbligatorioCheckBox.attr('checked', false);
        ripetibileCheckBox.attr('checked', false);
        ordinamentoTextBox.val('');
        valoriTextBox.val('');
        gruppoTextBox.val('');
        validazioneRegExTextBox.val('');
        validazioneMessaggioTextBox.val('');
        sistemaCheckBox.attr('checked', false);
        valoreDefaultTextBox.val('');
        nomeDatoAggiuntivoTextBox.val('');
        concatenaCheckBox.attr('checked', false);
        concatenaCheckBox.prop("disabled", true);
    }

    codiceTextBox.val('');
    codiceTextBox.removeAttr('disabled');
    codiceTextBox.next().hide();
    etichettaTextBox.next().hide();
    valoreDefaultTextBox.next().hide();

    $('#modificaDato').dialog({
        height: 400,
        width: 400,
        modal: true,
        position: 'center',
        title: Title,
        resizable: true,
        open: function (event, ui) {

            $('body').css({ 'overflow-y': 'hidden', 'overflow-x': 'hidden' });
        },
        close: function (event, ui) {

            $('body').css({ 'overflow-y': 'scroll', 'overflow-x': 'auto' });
        },
        buttons: {
            "Ok": function () {

                codiceTextBox.next().hide();
                etichettaTextBox.next().hide();
                valoreDefaultTextBox.next().hide();

                if (codiceTextBox.val() == '') {

                    codiceTextBox.next().fadeIn();
                    return;
                }

                if (etichettaTextBox.val() == '') {

                    etichettaTextBox.next().fadeIn();
                    return;
                }

                if (sistemaCheckBox.attr('checked') == 'checked' && valoreDefaultTextBox.val() == '') {

                    valoreDefaultTextBox.next().fadeIn();
                    return;
                }

                if (!IsCodeUnique(codiceTextBox.val())) {
                    alert('Esiste già un dato accessorio con il codice immesso.');
                    return;
                }

                var ordinamento = ordinamentoTextBox.val();
                ordinamento = (!ordinamento || isNaN(ordinamento)) ? "0" : ordinamento;

                var valoreDefault;

                if (valoreDefaultTextBox.attr("codice"))
                    valoreDefault = valoreDefaultTextBox.attr("codice");
                else
                    valoreDefault = valoreDefaultTextBox.val();

                SalvaDato(true, codiceTextBox.val(), descrizioneTextBox.val(), etichettaTextBox.val(), tipoComboBox.val(),
                    obbligatorioCheckBox.attr('checked') == 'checked', ripetibileCheckBox.attr('checked') == 'checked',
                    valoriTextBox.val(), ordinamento, gruppoTextBox.val(), validazioneRegExTextBox.val(),
                    validazioneMessaggioTextBox.val(), sistemaCheckBox.attr('checked') == 'checked', valoreDefault,
                    nomeDatoAggiuntivoTextBox.val(), concatenaCheckBox.attr('checked') == 'checked');


                $(this).dialog("close");
            },
            "Annulla": function () {

                $(this).dialog("close");
            }
        }
    });
}


function ModificaDato(button) {

    var codice = button.attr('codicedato');
    var dato = CaricaDato(codice);

    var codiceTextBox = $("#dato_codice");
    var descrizioneTextBox = $("#dato_descrizione");
    var etichettaTextBox = $("#dato_etichetta");
    var tipoComboBox = $("#" + _tipoComboId);
    var obbligatorioCheckBox = $("#dato_obbligatorio");
    var ripetibileCheckBox = $("#dato_ripetibile");
    var ordinamentoTextBox = $("#dato_ordinamento");
    var valoriTextBox = $("#dato_valori");
    var gruppoTextBox = $("#dato_gruppo");
    var validazioneRegExTextBox = $("#dato_validazioneRegEx");
    var validazioneMessaggioTextBox = $("#dato_validazioneMessaggio");
    var sistemaCheckBox = $("#dato_sistema");
    var valoreDefaultTextBox = $("#dato_valoreDefault");
    var nomeDatoAggiuntivoTextBox = $("#dato_nomeDatoAggiuntivo");
    var concatenaCheckBox = $("#dato_concatena");

    codiceTextBox.val(htmlDecode(dato.Codice));
    descrizioneTextBox.val(htmlDecode(dato.Descrizione));
    etichettaTextBox.val(htmlDecode(dato.Etichetta));
    tipoComboBox.val(dato.Tipo);
    obbligatorioCheckBox.attr('checked', dato.Obbligatorio);
    ripetibileCheckBox.attr('checked', dato.Ripetibile);
    valoriTextBox.val(htmlDecode(dato.Valori));
    ordinamentoTextBox.val(dato.Ordinamento);
    gruppoTextBox.val(htmlDecode(dato.Gruppo));
    validazioneRegExTextBox.val(htmlDecode(dato.ValidazioneRegEx));
    validazioneMessaggioTextBox.val(htmlDecode(dato.ValidazioneMessaggio));
    sistemaCheckBox.attr('checked', dato.Sistema);
    nomeDatoAggiuntivoTextBox.val(htmlDecode(dato.NomeDatoAggiuntivo));
    concatenaCheckBox.attr('checked', dato.Concatena);

    AbilitaCheckbox(nomeDatoAggiuntivoTextBox[0])

    var datoDefault;
    for (var i = 0; i < _datiDefault.length; i++) {

        if (_datiDefault[i].Codice == dato.ValoreDefault) {

            datoDefault = _datiDefault[i];
            break;
        }
    }

    if (!datoDefault)
        valoreDefaultTextBox.val(dato.ValoreDefault);

    else {
        valoreDefaultTextBox.val(datoDefault.Descrizione);
        valoreDefaultTextBox.attr("codice", datoDefault.Codice);
    }

    codiceTextBox.attr('disabled', 'disabled');
    codiceTextBox.next().hide();
    etichettaTextBox.next().hide();
    valoreDefaultTextBox.next().hide();

    $('#modificaDato').dialog({
        height: 400,
        width: 400,
        modal: true,
        position: 'center',
        title: "Modifica dato accessorio",
        resizable: true,
        open: function (event, ui) {

            $('body').css({ 'overflow-y': 'hidden', 'overflow-x': 'hidden' });
        },
        close: function (event, ui) {

            $('body').css({ 'overflow-y': 'scroll', 'overflow-x': 'auto' });
        },
        buttons: {
            "Ok": function () {

                if (codiceTextBox.val() == '') {

                    codiceTextBox.next().fadeIn();
                    return;
                }

                if (etichettaTextBox.val() == '') {

                    etichettaTextBox.next().fadeIn();
                    return;
                }

                if (sistemaCheckBox.attr('checked') == 'checked' && valoreDefaultTextBox.val() == '') {

                    valoreDefaultTextBox.next().fadeIn();
                    return;
                }

                var ordinamento = ordinamentoTextBox.val();
                ordinamento = (!ordinamento || isNaN(ordinamento)) ? "0" : ordinamento;

                var valoreDefault;

                if (valoreDefaultTextBox.attr("codice"))
                    valoreDefault = valoreDefaultTextBox.attr("codice");
                else
                    valoreDefault = valoreDefaultTextBox.val();

                SalvaDato(false, codiceTextBox.val(), descrizioneTextBox.val(), etichettaTextBox.val(), tipoComboBox.val(),
                    obbligatorioCheckBox.attr('checked') == 'checked', ripetibileCheckBox.attr('checked') == 'checked', valoriTextBox.val(),
                    ordinamento, gruppoTextBox.val(), validazioneRegExTextBox.val(), validazioneMessaggioTextBox.val(),
                    sistemaCheckBox.attr('checked') == 'checked', valoreDefault, nomeDatoAggiuntivoTextBox.val(),
                    concatenaCheckBox.attr('checked') == 'checked');

                //window.location.href = window.location.href;

                $(this).dialog("close");
            },
            "Annulla": function () {

                $(this).dialog("close");
            }
        }
    });
}

function CaricaDatiAccessoriDefault() {

    var datiAccessoriSistemaDefault;

    $.ajax({
        type: "POST",
        url: "DatiAccessori.aspx/GetDatiSistemaDiDefault",
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

function IsCodeUnique(codice) {

    var risultato;

    $.ajax({
        type: "POST",
        url: "DatiAccessori.aspx/CheckCodeUnicity",
        data: "{'codice':'" + escape(escapeHtmlEntities(codice)) + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {

            risultato = result.d;
        },
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
        }
    });

    return risultato != 'True';
}

function CaricaDato(codice) {

    var dato;

    $.ajax({
        type: "POST",
        url: "DatiAccessori.aspx/GetDato",
        data: "{'codice':'" + escape(escapeHtmlEntities(codice)) + "'}",
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

function SalvaDato(insert, codice, descrizione, etichetta, tipo, obbligatorio, ripetibile, valori, ordinamento, gruppo,
    validazioneRegEx, validazioneMessaggio, sistema, valoreDefault, nomeDatoAggiuntivo, concatena) {
    $.ajax({
        type: "POST",
        url: "DatiAccessori.aspx/UpdateDato",
        data: "{'insert':'" + insert +
            "','codice':'" + escape(escapeHtmlEntities(codice)) +
            "','descrizione':'" + escape(escapeHtmlEntities(descrizione)) +
            "','etichetta':'" + escape(escapeHtmlEntities(etichetta)) +
            "','tipo':'" + tipo +
            "','obbligatorio':'" + obbligatorio +
            "','ripetibile':'" + ripetibile +
            "','valori':'" + escape(escapeHtmlEntities(valori)) +
            "','ordinamento':'" + ordinamento +
            "','gruppo':'" + escape(escapeHtmlEntities(gruppo)) +
            "','validazioneRegEx':'" + escape(escapeHtmlEntities(validazioneRegEx)) +
            "','validazioneMessaggio':'" + escape(escapeHtmlEntities(validazioneMessaggio)) +
            "','sistema':'" + sistema +
            "','valoreDefault':'" + escape(escapeHtmlEntities(valoreDefault)) +
            "','nomeDatoAggiuntivo':'" + escape(escapeHtmlEntities(nomeDatoAggiuntivo)) +
            "','concatena':'" + concatena +
            "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {
            if (!result.d) {
                return;
            }
            setTimeout(function () { $("#" + _cercaButton).trigger("click"); }, 100);
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

function ShowPreview(button) {

    var codice = button.attr('codicedato');
    var descrizione = button.attr('descrizionedato')
    var divSistemi = $("#previewDatiSistemi");
    var divPrestazioni = $("#previewDatiPrestazioni");

    divSistemi.html("");
    divPrestazioni.html("");

    $('#previewDati').dialog({
        height: 550,
        width: 500,
        modal: true,
        position: 'center',
        title: "Sistemi e prestazioni associati al dato  &nbsp;  &nbsp;  &nbsp; [" + codice + "] - " + descrizione,
        resizable: true,
        open: function (event, ui) {

            $('body').css({ 'overflow-y': 'hidden', 'overflow-x': 'hidden' });

            $.ajax({
                type: "POST",
                url: "DatiAccessori.aspx/GetDatiAccessoriPreview",
                data: "{'codice':'" + codice + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (result) {

                    if (!result.d) {

                        return;
                    }

                    for (var i = 0; i < result.d.length; i++) {

                        var element = result.d[i];

                        switch (element.Tipo) {

                            case "Sistema":

                                divSistemi.append(element.Descrizione + "<br />");
                                break;

                            case "Prestazione":

                                divPrestazioni.append(element.Descrizione + "<br />");
                                break;
                        }
                    }

                    if (divSistemi.html() == "") divSistemi.html("Nessun risultato<br />");
                    if (divPrestazioni.html() == "") divPrestazioni.html("Nessun risultato<br />");

                    divSistemi.append("<br />");
                    divPrestazioni.append("<br />");
                },
                error: function (error) {

                    var message = GetMessageFromAjaxError(error.responseText);

                    alert(message);
                }
            });
        },
        close: function (event, ui) {

            $('body').css({ 'overflow-y': 'scroll', 'overflow-x': 'auto' });
        },
        buttons: {
            "Ok": function () {

                $(this).dialog("close");
            }
        }
    });
}




function ShowPopUpSistemi(idDatoAccessorio,descrizioneDatoAccessorio) {

    if (idDatoAccessorio == undefined || idDatoAccessorio == '') {
        commonModalDialogOpen('DettaglioSistemiDatoAccessorio.aspx', '', 1200, 650);
    }
    else {
        commonModalDialogOpen('DettaglioSistemiDatoAccessorio.aspx?Id=' + idDatoAccessorio+'&descrizione=' + descrizioneDatoAccessorio,'Aggiungi Sistemi al Dato Accessorio   [' + idDatoAccessorio +'] - ' + descrizioneDatoAccessorio , 1020, 560);
    }
    return false;
}

function ShowPopUpPrestazioni(idDatoAccessorio, descrizioneDatoAccessorio) {

    if (idDatoAccessorio == undefined || idDatoAccessorio == '') {
        commonModalDialogOpen('DettaglioPrestazioniDatoAccessorio.aspx', '', 1200, 650);
    }
    else {
        commonModalDialogOpen('DettaglioPrestazioniDatoAccessorio.aspx?Id=' + idDatoAccessorio + '&descrizione=' + descrizioneDatoAccessorio, 'Aggiungi Prestazioni al Dato Accessorio   [' + idDatoAccessorio + '] - ' + descrizioneDatoAccessorio, 1020, 560);
    }
    return false;
}



function AbilitaCheckbox(txtBox) {
    if (txtBox.value.length == 0) {
        $("#dato_concatena").prop("checked", false);
        $("#dato_concatena").prop("disabled", true);
    } else {
        $("#dato_concatena").prop("disabled", false);
    }

}


/*
* Apre una modale di import massivo dei dati accessori tramite CSV
*/
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