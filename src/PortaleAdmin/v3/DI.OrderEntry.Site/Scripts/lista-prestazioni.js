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
        url: "ListaPrestazioni.aspx/SaveFilter",
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

//
//Funzione che si occupa di creare la tabella delle prestazioni
//
function LoadPrestazioni(codiceDescrizione, sistema, attivo, sistemaAttivo, richiedibileSoloDaProfilo) {

    //Salva i filtri
    SaveFilter('CodiceDescrizioneFiltroTextBox', codiceDescrizione);
    SaveFilter('SistemaEroganteFiltroDropDownList', sistema);
    SaveFilter('AttivoCheckBox', attivo);
    SaveFilter('ddlSistemaAttivo', sistemaAttivo);
    SaveFilter('ddlRichiedibileSoloDaProfilo', richiedibileSoloDaProfilo);

    SetLoaderForButton('.cercaFlag', true);

    //esegue una chiamata AJAX per ottenere la lista delle prestazioni in base ai filtri selezionati.
    $.ajax({
        type: "POST",
        url: "ListaPrestazioni.aspx/LoadPrestazioni",
        data: "{'codiceDescrizione':'" + escape(escapeHtmlEntities(codiceDescrizione)) + "', 'sistema':'" + sistema + "', 'attivo':'" + attivo + "','sistemaAttivo':'" + sistemaAttivo + "','richiedibileSoloDaProfilo':'" + richiedibileSoloDaProfilo + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            if (!result.d) {

                $("#Prestazioni").html("Nessun risultato");
                if ($("#selettoreGrid").length > 0) CercaPrestazioni();
                SetLoaderForButton('.cercaFlag', false);
                return;
            }

            var count = 0;
            var maxrows = 500;
            var html = [];

            html.push('<table id="prestazioniGrid" class="tablesorter" style="border:1px silver solid; border-collapse:collapse; width:100%; margin-top:5px;"><thead>');
            html.push('<th style="width:30px;"><input type="checkbox" style="background: transparent; border-style: none; cursor: pointer;" onclick="SelectDeselectAll($(this), $(\'#prestazioniGrid\'));" /></th>');
            html.push('<th style="text-align:center; width:30px;">Modifica</th>');
            html.push('<th style="text-align:center; width:30px; ">Dati Accessori</th>');
            html.push('<th>Codice</th><th>Descrizione</th><th>Erogante</th><th>Attivo</th><th>Sinonimo</th>');
            html.push('<th>Richiedibile solo da profilo</th>');
            html.push('</thead><tbody>');

            for (var property in result.d) {
                if (count++ > maxrows) break;

                var prestazione = result.d[property];

                html.push('<tr id="' + prestazione.Id + '" class="GridItem">');

                html.push('<td><input type="checkbox" class="gridCheckBox" /></td>');
                html.push('<td><input type="button" title="modifica" class="editButton" onclick="ModificaPrestazione(\'' + prestazione.Id + '\')" /></td>');
                html.push('<td><input title="modifica dati accessori" class="toolsButton" onclick="OpenDatiAccesoriDialog(\'' + prestazione.Id + '\',$(this))" descrizione="' + prestazione.Descrizione + '" codice="' + prestazione.Codice + '"/></td>');
                html.push('<td style="width:80px;">' + prestazione.Codice + '</td>');
                html.push('<td>' + prestazione.Descrizione + '</td>');
                html.push('<td>' + prestazione.SistemaErogante + '</td>');
                html.push('<td>' + (prestazione.Attivo ? '<img src="../Images/ok.png" />' : '<img src="../Images/PixelTrasparente.gif" />') + '</td>');
                html.push('<td style="width:80px;">' + prestazione.CodiceSinonimo + '</td>');
                html.push('<td style="width:160px;">' + (prestazione.RichiedibileSoloDaProfilo ? '<img title="Richiedibile solo da profilo" src="../Images/ok.png" />' : '<img src="../Images/PixelTrasparente.gif" />') + '</td>');
                html.push('</tr>');
            }
            html.push('</tbody></table>');

            if (count > maxrows) {
                html.push('<p class="Error">Lista limitata alle prime ' + maxrows.toString() + ' righe.</p>');
            }

            $("#Prestazioni").html(html.join(""));


            $("#prestazioniGrid").tablesorter({

                headers: {
                    0: { sorter: false },
                    1: { sorter: false },
                    2: { sorter: false }
                }
            });

            $("#prestazioniGrid .gridCheckBox").change(function () {
                $(this).parent().parent().toggleClass('GridSelected');
            });

            SetLoaderForButton('.cercaFlag', false);
            $("#loader").fadeOut();

        },
        error: function (error) {

            SetLoaderForButton('.cercaFlag', false);
            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
        }

    });
}

function AggiungiPrestazione() {

    var codiceTextBox = $("#prestazione_codice");
    var descrizioneTextBox = $("#prestazione_descrizione");
    var eroganteComboBox = $("#" + _eroganteComboId);
    var attivoCheckBox = $("#prestazione_attivo");
    var codiceSinonimoTextBox = $("#prestazione_codiceSinonimo");
    var richiedibileSoloDaProfiloCheckbox = $("#prestazione_richiedibileSoloDaProfilo");


    codiceTextBox.val('');
    descrizioneTextBox.val('');
    attivoCheckBox.attr('checked', true);
    codiceSinonimoTextBox.val('');
    richiedibileSoloDaProfiloCheckbox.attr('checked', false);

    codiceTextBox.next().hide();
    descrizioneTextBox.next().hide();


    $('#modificaPrestazione').dialog({
        height: 600,
        width: 400,
        modal: true,
        position: 'center',
        title: "Nuova Prestazione",
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

                if (descrizioneTextBox.val() == '') {

                    descrizioneTextBox.next().fadeIn();
                    return;
                }

                if (SalvaPrestazione('', codiceTextBox.val(), descrizioneTextBox.val(), eroganteComboBox.val(), attivoCheckBox.attr('checked') == 'checked', codiceSinonimoTextBox.val(), richiedibileSoloDaProfiloCheckbox.attr('checked') == 'checked') != null) {
                    PageLoadPrestazioni();
                    $(this).dialog("close");
                }
            },
            "Annulla": function () {

                $(this).dialog("close");
            }
        }
    });
}

function ModificaPrestazione(idPrestazione) {

    var prestazione = CaricaPrestazione(idPrestazione);

    var codiceTextBox = $("#prestazione_codice");
    var descrizioneTextBox = $("#prestazione_descrizione");
    var eroganteComboBox = $("#" + _eroganteComboId);
    var attivoCheckBox = $("#prestazione_attivo");
    var codiceSinonimoTextBox = $("#prestazione_codiceSinonimo");
    var richiedibileSoloDaProfiloCheckbox = $("#prestazione_richiedibileSoloDaProfilo");

    codiceTextBox.val(prestazione.Codice);
    descrizioneTextBox.val(prestazione.Descrizione);
    eroganteComboBox.val(prestazione.idErogante);
    attivoCheckBox.attr('checked', prestazione.Attivo);
    codiceSinonimoTextBox.val(prestazione.CodiceSinonimo)
    richiedibileSoloDaProfiloCheckbox.attr('checked', prestazione.RichiedibileSoloDaProfilo);

    codiceTextBox.next().hide();
    descrizioneTextBox.next().hide();

    $('#modificaPrestazione').dialog({
        height: 600,
        width: 400,
        modal: true,
        position: 'center',
        title: "Modifica prestazione",
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

                if (descrizioneTextBox.val() == '') {

                    descrizioneTextBox.next().fadeIn();
                    return;
                }

                SalvaPrestazione(idPrestazione, codiceTextBox.val(), descrizioneTextBox.val(), eroganteComboBox.val(), attivoCheckBox.attr('checked') == 'checked', codiceSinonimoTextBox.val(), richiedibileSoloDaProfiloCheckbox.attr('checked') == 'checked');

                PageLoadPrestazioni();

                $(this).dialog("close");
            },
            "Annulla": function () {

                $(this).dialog("close");
            }
        }
    });
}

function CaricaPrestazione(idPrestazione) {

    var prestazione;

    $.ajax({
        type: "POST",
        url: "ListaPrestazioni.aspx/GetPrestazione",
        data: "{'idPrestazione':'" + idPrestazione + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {

            if (!result.d) {

                return;
            }

            prestazione = result.d;
        },
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
        }
    });

    return prestazione;
}

function SalvaPrestazione(idPrestazione, codice, descrizione, erogante, attivo, codiceSinonimo, richiedibileSoloDaProfilo) {

    $.ajax({
        type: "POST",
        url: "ListaPrestazioni.aspx/UpdatePrestazione",
        data: "{'idPrestazione':'" + idPrestazione +
            "','codice':'" + escape(escapeHtmlEntities(codice)) +
            "','descrizione':'" + escape(escapeHtmlEntities(descrizione)) +
            "','erogante':'" + erogante +
            "','attivo':'" + attivo +
            "','codiceSinonimo':'" + escape(escapeHtmlEntities(codiceSinonimo)) +
            "','richiedibileSoloDaProfilo':'" + richiedibileSoloDaProfilo +
            "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {
            if (!result.d) {
                return null;
            }

            idPrestazione = result.d;
        },
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);

            if (message.indexOf('duplicate key') > -1)
                alert('Il codice della prestazione deve essere univoco per sistema erogante');
            else
                alert(message);

            idPrestazione = null;
        }
    });

    return idPrestazione;
}

function RemovePrestazioni() {

    if ($('#prestazioniGrid .GridSelected').length > 0) {

        var idPrestazioni = $("#prestazioniGrid .GridSelected").map(function () { return $(this).attr("id"); }).get();

        $.ajax({
            type: "POST",
            url: "ListaPrestazioni.aspx/DeletePrestazioni",
            data: "{'idPrestazioni':'" + idPrestazioni.join(";") + "'}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            async: false,
            success: function (result) {

                $('#prestazioniGrid .GridSelected').remove();
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
                //__doPostBack('ImportButton', ''); 
            },
            "Annulla": function () {

                $(this).dialog("close");
            }
        }
    });

    dialog.parent().appendTo(jQuery("form:first"));
}


/********Dialog dati accessori**********/

function OpenDatiAccesoriDialog(idPrestazione, button) {
    $('body').css('cursor', 'wait');
    var codice = button.attr('codice');
    var descrizione = button.attr('descrizione')
    $('#aggiungiDatiAccessori').dialog({
        width: 1200,
        height: 650 + "px",
        modal: true,
        position: 'center',
        title: "Modifica Dati Accessori &nbsp; &nbsp; &nbsp; [" + codice + "] - " + descrizione,
        resizable: false,
        open: function (event, ui) {

            $('body').css({ 'overflow-y': 'hidden', 'overflow-x': 'hidden' });
            CaricaDatiAccessori(idPrestazione);
            $('#aggiungiDatiAccessori').attr("idPrestazione", idPrestazione);
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
function CaricaDatiAccessori(idPrestazione) {

    $.ajax({
        type: "POST",
        url: "ListaPrestazioni.aspx/GetDatiAccessori",
        data: "{'idPrestazione':'" + idPrestazione + "'}",
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
                html.push('<tr id="' + datoAccessorio.Codice + '" class="GridItem">');
                html.push('<td><input type="checkbox" class="gridCheckBox" /></td>');
                html.push('<td><input type="button" title="modifica dati accessori prestazioni" class="editButton" onclick="ModificaDatiAccessoriPrestazioni(\'' + idPrestazione + '\', \'' + datoAccessorio.Codice + '\',\'' + datoAccessorio.Descrizione + '\' )" /></td>');
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
        url: "ListaPrestazioni.aspx/GetListaDatiAccessori",
        data: "{'codice':'" + codice + "','descrizione':'" + descrizione + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            if (result.d == null) {

                $("#listaDatiAccessori").html("<br />Nessun risultato");
                $("#loader").fadeOut();
                return;
            }

            var idDatiAccessoriDelPrestazione = $("#datiAccessoriGrid .GridItem").map(function () { return $(this).attr("Id"); }).get();
            var html = [];

            html.push('<table id="selettoreGrid" class="tablesorter" style="border:1px silver solid; border-collapse:collapse; width:100%; height:auto;"><thead>');
            html.push('<th style="width:26px;"><input type="checkbox" style="background: transparent; border-style: none; cursor: pointer;" onclick="SelectDeselectAll($(this), $(\'#selettoreGrid\'));" /></th>');
            html.push('<th style="width:80px;">Codice</th><th>Etichetta</th><th>Tipo</th>');
            html.push('</thead><tbody>');

            for (var i = 0; i < result.d.length; i++) {
                var datoAccessorio = result.d[i];
                html.push('<tr id="' + datoAccessorio.Codice + '" class="GridItem">');
                html.push('<td><input type="checkbox" class="gridCheckBox" ');
                if (idDatiAccessoriDelPrestazione.length > 0) {
                    var idx = $.inArray(datoAccessorio.Codice, idDatiAccessoriDelPrestazione);
                    if (idx > -1) {
                        html.push(' style="display:none;"');
                        idDatiAccessoriDelPrestazione.splice(idx, 1);
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

        var idPrestazione = $('#aggiungiDatiAccessori').attr("idPrestazione");
        var idDatiAccessori = new Array();
        var idDatiAccessoriDelPrestazione = $("#datiAccessoriGrid .GridItem").map(function () { return $(this).attr("id"); }).get();

        //ELEMENTI SELEZIONATI A DESTRA
        $('#selettoreGrid .GridSelected').each(function () {

            var idDatoAccessorio = $(this).attr("id");

            if ($.inArray(idDatoAccessorio, idDatiAccessoriDelPrestazione) == -1)
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
            AggiungiDatiAccessoriAPrestazione(idPrestazione, idDatiAccessori);
            //RICARICO LA LISTA DI SINISTRA
            CaricaDatiAccessori(idPrestazione);
        }
        else { alert('Selezionare i dati accessori da aggiungere.'); }

    }
}

function AggiungiDatiAccessoriAPrestazione(idPrestazione, idDatiAccessori) {

    $.ajax({
        type: "POST",
        url: "ListaPrestazioni.aspx/InsertDatiAccessoriInPrestazione",
        data: "{'idPrestazione':'" + idPrestazione + "','codiciDatiAccessori':'" + idDatiAccessori.join(";") + "'}",
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

    var idPrestazione = $('#aggiungiDatiAccessori').attr("idPrestazione");
    var idDatiAccessori = $("#datiAccessoriGrid .GridSelected").map(function () { return $(this).attr("id"); }).get();

    if (idDatiAccessori.length > 0) {
        //CHIAMATA AL METODO DELETE SU DB
        RimuoviDatoAccessorioDaPrestazione(idPrestazione, idDatiAccessori);

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
    else { alert('Selezionare i dati accessori da rimuovere.'); }
}

function RimuoviDatoAccessorioDaPrestazione(idPrestazione, idDatiAccessori) {

    $.ajax({
        type: "POST",
        url: "ListaPrestazioni.aspx/DeleteDatiAccessoriDaPrestazione",
        data: "{'idPrestazione':'" + idPrestazione + "', 'codiciDatiAccessori':'" + idDatiAccessori.join(";") + "'}",
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


/********Dialog dati accessori prestazioni**********/

function ModificaDatiAccessoriPrestazioni(idPrestazione, codiceDatoAccessorio, descrizioneDatoAccessorio) {

    var dato = CaricaDatiAccessoriPrestazioni(idPrestazione, codiceDatoAccessorio);

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

    EnableEreditaDatiAccessoriPrestazioni();
    EnableValoreDefault()
    valoreDefaultTextBox.next().hide();

    $('#modificaDatiAccessoriPrestazioni').dialog({
        height: 550,
        width: 550,
        modal: true,
        position: 'center',
        title: "Modifica Dati Accessori Prestazioni   [" + dato.CodiceDatoAccessorio + "] - " + descrizioneDatoAccessorio,
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

                AggiornaDatiAccessoriPrestazioni(dato.ID, dato.IdPrestazione, dato.CodiceDatoAccessorio, attivoCheckBox.attr('checked') == 'checked', ereditaCheckBox.attr('checked') == 'checked', sistemaCheckBox.attr('checked') == 'checked', valoreDefaultTextBox.val());

                CaricaDatiAccessori(idPrestazione);

                $(this).dialog("close");
            },
            "Annulla": function () {

                $(this).dialog("close");
            }
        }
    });
}

function AggiornaDatiAccessoriPrestazioni(id, idPrestazione, codiceDatoAccessorio, attivo, eredita, sistema, valoreDefault) {

    $.ajax({
        type: "POST",
        url: "ListaPrestazioni.aspx/UpdateDatiAccessoriPrestazioni",
        data: "{'id':'" + id + "','idPrestazione':'" + idPrestazione + "','codiceDatoAccessorio':'" + escape(codiceDatoAccessorio) + "','attivo':'" + attivo + "','eredita':'" + eredita + "','sistema':'" + sistema + "','valoreDefault':'" + escape(escapeHtmlEntities(valoreDefault)) + "'}",
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

function EnableEreditaDatiAccessoriPrestazioni() {

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
        url: "ListaPrestazioni.aspx/GetDatiSistemaDiDefault",
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

function CaricaDatiAccessoriPrestazioni(idPrestazione, codiceDatoAccessorio) {

    var dato;

    $.ajax({
        type: "POST",
        url: "ListaPrestazioni.aspx/GetDatiAccessoriPrestazioni",
        data: "{'idPrestazione':'" + idPrestazione + "', 'codiceDatoAccessorio':'" + codiceDatoAccessorio + "'}",
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