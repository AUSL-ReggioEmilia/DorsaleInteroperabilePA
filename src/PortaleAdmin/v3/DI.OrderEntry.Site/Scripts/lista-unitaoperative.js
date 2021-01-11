
$(document).ready(function () {


});

function SaveFilter(controlId, value) {

    $.ajax({
        type: "POST",
        url: "ListaUnitaOperative.aspx/SaveFilter",
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

function LoadUnitaOperative(codiceDescrizione, azienda, attivo) {

    SaveFilter('CodiceDescrizioneFiltroTextBox', codiceDescrizione);
    SaveFilter('AziendaFiltroDropDownList', azienda);
    SaveFilter('AttivoCheckBox', attivo);

    SetLoaderForButton('.cercaFlag', true);

    $.ajax({
        type: "POST",
        url: "ListaUnitaOperative.aspx/LoadUnitaOperative",
        data: "{'codiceDescrizione':'" + codiceDescrizione + "', 'azienda':'" + azienda + "', 'attivo':'" + attivo + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            if (!result.d) {

                $("#UnitaOperative").html("Nessun risultato");
                if ($("#selettoreGrid").length > 0) CercaUnitaOperative();
                SetLoaderForButton('.cercaFlag', false);
                return;
            }

            var html = [];

            html.push('<table id="unitaOperativeGrid" class="tablesorter" style="border:1px silver solid; border-collapse:collapse; width:100%; margin-top:5px;"><thead>');
            html.push('<th style="text-align:center; width:30px; padding:0px;"><input type="checkbox" style="background: transparent; border-style: none; cursor: pointer;" onclick="SelectDeselectAll($(this), $(\'#unitaOperativeGrid\'));" /></th><th style="text-align:center; width:30px; padding:0px;"></th><th>Codice</th><th>Descrizione</th><th>Azienda</th><th>Attivo</th>');
            html.push('</thead><tbody>');

            for (var property in result.d) {

                var unitaOperativa = result.d[property];

                html.push('<tr id="' + unitaOperativa.Id + '" class="GridItem" style="height: 25px;">');

                html.push('<td style="text-align:center; padding:0px;"><input type="checkbox" class="gridCheckBox" /></td>');
                html.push('<td style="text-align:center; padding:0px;"><input type="button" class="editButton" onclick="ModificaUnitaOperativa(\'' + unitaOperativa.Id + '\')" /></td>');
                html.push('<td style="text-align:center; width:80px;">' + unitaOperativa.Codice + '</td>');
                html.push('<td style="text-align:center;">' + unitaOperativa.Descrizione + '</td>');
                html.push('<td style="text-align:center;">' + unitaOperativa.Azienda + '</td>');
                html.push('<td style="text-align:center; padding: 0px;">' + (unitaOperativa.Attivo ? '<img src="../Images/ok.png" />' : '<img src="../Images/PixelTrasparente.gif" />') + '</td>'); 
                html.push('</tr>');
            }

            html.push('</tbody></table>');

            $("#UnitaOperative").html(html.join(""));

            $("#unitaOperativeGrid").tablesorter({

                headers: {
                    0: { sorter: false },
                    1: { sorter: false }
                }
            });

            $("#loader").fadeOut();

            $("#unitaOperativeGrid .GridItem").hover(function () {

                $(this).addClass("GridHover");

            }, function () {

                $(this).removeClass("GridHover");
            });

            $("#unitaOperativeGrid .gridCheckBox").change(function () {

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

function AggiungiUnitaOperativa() {

    var codiceTextBox = $("#unitaOperativa_codice");
    var descrizioneTextBox = $("#unitaOperativa_descrizione");
    var aziendaComboBox = $("#" + _aziendaComboId);
    var attivoCheckBox = $("#unitaOperativa_attivo");

    codiceTextBox.val('');
    descrizioneTextBox.val('');
    attivoCheckBox.attr('checked', true);

    codiceTextBox.next().hide();
    descrizioneTextBox.next().hide();

    $('#modificaUnitaOperativa').dialog({
        height: 350,
        width: 400,
        modal: true,
        position: 'center',
        title: "Nuova UnitaOperativa",
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

                SalvaUnitaOperativa('', codiceTextBox.val(), descrizioneTextBox.val(), aziendaComboBox.val(), attivoCheckBox.attr('checked') == 'checked');

                PageLoadUnitaOperative();

                $(this).dialog("close");
            },
            "Annulla": function () {

                $(this).dialog("close");
            }
        }
    });
}

function ModificaUnitaOperativa(idUnitaOperativa) {

    var unitaOperativa = CaricaUnitaOperativa(idUnitaOperativa);

    var codiceTextBox = $("#unitaOperativa_codice");
    var descrizioneTextBox = $("#unitaOperativa_descrizione");
    var aziendaComboBox = $("#" + _aziendaComboId);
    var attivoCheckBox = $("#unitaOperativa_attivo");


    codiceTextBox.val(unitaOperativa.Codice);
    descrizioneTextBox.val(unitaOperativa.Descrizione);
    aziendaComboBox.val('checked', unitaOperativa.idErogante);
    attivoCheckBox.attr('checked', unitaOperativa.Attivo);

    codiceTextBox.next().hide();
    descrizioneTextBox.next().hide();

    $('#modificaUnitaOperativa').dialog({
        height: 350,
        width: 400,
        modal: true,
        position: 'center',
        title: "Modifica unitaOperativa",
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

                SalvaUnitaOperativa(idUnitaOperativa, codiceTextBox.val(), descrizioneTextBox.val(), aziendaComboBox.val(), attivoCheckBox.attr('checked') == 'checked');

                PageLoadUnitaOperative();

                $(this).dialog("close");
            },
            "Annulla": function () {

                $(this).dialog("close");
            }
        }
    });
}

function CaricaUnitaOperativa(idUnitaOperativa) {

    var unitaOperativa;

    $.ajax({
        type: "POST",
        url: "ListaUnitaOperative.aspx/GetUnitaOperativa",
        data: "{'idUnitaOperativa':'" + idUnitaOperativa + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {

            if (!result.d) {

                return;
            }

            unitaOperativa = result.d;
        },
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
        } 
    });

    return unitaOperativa;
}

function SalvaUnitaOperativa(idUnitaOperativa, codice, descrizione, azienda, attivo) {

    $.ajax({
        type: "POST",
        url: "ListaUnitaOperative.aspx/UpdateUnitaOperativa",
        data: "{'idUnitaOperativa':'" + idUnitaOperativa + "','codice':'" + escape(codice) + "','descrizione':'" + escape(descrizione) + "','azienda':'" + escape(azienda) + "','attivo':'" + attivo + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {

            if (!result.d) {

                return;
            }

            idUnitaOperativa = result.d;
        },
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);

            if (message.indexOf('duplicate key') > -1)
                alert('Il codice dell\'unità operativa deve essere univoco per azienda');
            else
                alert(message);
        }
    });

    return idUnitaOperativa;
}

function RemoveUnitaOperative() {

    if ($('#unitaOperativeGrid .GridSelected').length > 0) {

        var idUnitaOperative = $("#unitaOperativeGrid .GridSelected").map(function () { return $(this).attr("id"); }).get();

        $.ajax({
            type: "POST",
            url: "ListaUnitaOperative.aspx/DeleteUnitaOperative",
            data: "{'idUnitaOperative':'" + idUnitaOperative.join(";") + "'}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            async: false,
            success: function (result) {

                $('#unitaOperativeGrid .GridSelected').remove();
            },
            error: function (error) {

                var message = GetMessageFromAjaxError(error.responseText);
                alert(message);
            } 
        });
    }
}