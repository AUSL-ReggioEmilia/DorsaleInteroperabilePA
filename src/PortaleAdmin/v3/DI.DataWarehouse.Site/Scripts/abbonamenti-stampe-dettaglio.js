
var _isNew = false;

$(document).ready(function () {

    $(".DateInput").datepicker($.datepicker.regional['it']);

    var id = $.QueryString["Id"];

    caricaTipiReferti();
    //caricaTipiAbbonamenti();
    caricaAziende();

    if (id)
        caricaDettaglio();
    else {

        _isNew = true;

        setButtonState();

        $("#AccountTextBox").parent().hide();
        $("#StatoText").parent().hide();
        //$("#TipoAbbonamentoSelect").parent().hide();
    }

    $("#testata input[data-validate], #testata select[data-validate], #testata textarea[data-validate]").each(function () {

        $(this).bind("focusout", function () { valida("#" + $(this).attr("Id")); });
    });
});

function setButtonState() {

    if (_isNew) {

        $("#AttivaDisattivaButton").fadeTo("fast", .5).removeAttr("href");
        $("#EliminaButton").fadeTo("fast", .5).removeAttr("href");

        $("#EliminaSelezionatiButton").attr("disabled", "disabled");
        $("#AggiungiRepartiButton").attr("disabled", "disabled");
    }
    else {

    }
}

/****************************************************/

function caricaTipiReferti() {

    var tipiRefertiSelect = $("#TipoRefertoSelect");

    tipiRefertiSelect.attr('disabled', 'disabled');

    $.ajax({
        type: "POST",
        url: "AbbonamentiStampeDettaglio.aspx/GeLookupTipiReferti",
        data: "",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {

            for (var tipo in result.d) {

                tipiRefertiSelect.append("<option value='" + tipo + "'>" + result.d[tipo] + "</option>");
            }

            tipiRefertiSelect.removeAttr('disabled');
        },
        error: function (error) { var message = GetMessageFromAjaxError(error.responseText); alert(message); }
    });
}

//function caricaTipiAbbonamenti() {

//    var tipiAbbonamentiSelect = $("#TipoAbbonamentoSelect");

//    tipiAbbonamentiSelect.attr('disabled', 'disabled');

//    $.ajax({
//        type: "POST",
//        url: "AbbonamentiStampeDettaglio.aspx/GeLookupTipiAbbonamento",
//        data: "",
//        contentType: "application/json; charset=utf-8",
//        dataType: "json",
//        async: false,
//        success: function (result) {

//            for (var tipo in result.d) {

//                tipiAbbonamentiSelect.append("<option value='" + tipo + "'>" + result.d[tipo] + "</option>");
//            }

//            //tipiAbbonamentiSelect.removeAttr('disabled');
//        },
//        error: function (error) { var message = GetMessageFromAjaxError(error.responseText); alert(message); }
//    });
//}

function caricaAziende() {

    var AziendeSelect = $("#aziendaFiltro");

    AziendeSelect.attr('disabled', 'disabled');

    $.ajax({
        type: "POST",
        url: "AbbonamentiStampeDettaglio.aspx/GeLookupAziende",
        data: "",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {

            for (var azienda in result.d) {

                AziendeSelect.append("<option value='" + azienda + "'>" + result.d[azienda] + "</option>");
            }

            AziendeSelect.removeAttr('disabled');
        },
        error: function (error) { var message = GetMessageFromAjaxError(error.responseText); alert(message); }
    });
}

function caricaSistemi() {

    var azienda = $("#aziendaFiltro").val();
    var SistemiSelect = $("#sistemaFiltro");

    SistemiSelect.attr('disabled', 'disabled');

    $("#sistemaFiltro option:not(:first)").remove();

    if (!azienda || azienda == '') return;

    $.ajax({
        type: "POST",
        url: "AbbonamentiStampeDettaglio.aspx/GeLookupSistemi",
        data: "{'codiceAzienda':'" + azienda + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {

            for (var sistema in result.d) {

                SistemiSelect.append("<option value='" + sistema + "'>" + sistema + "</option>");
            }

            SistemiSelect.removeAttr('disabled');
        },
        error: function (error) { var message = GetMessageFromAjaxError(error.responseText); alert(message); }
    });
}

function caricaDettaglio() {

    var id = $.QueryString["Id"];

    if (!id)
        location.href = "AbbonamentiStampe.aspx";

    $.ajax({
        type: "POST",
        url: "AbbonamentiStampeDettaglio.aspx/CaricaDettaglio",
        data: "{'id':'" + id + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {

            var dettaglio = result.d;

            if (dettaglio == null)
                location.href = "AbbonamentiStampe.aspx";

            BindControls(dettaglio);

            var html;

            if (dettaglio.RepartiRichiedenti.length > 0)

                html = BindGrid("#rowTemplate", dettaglio.RepartiRichiedenti);
            else
                html = "<tr><td colspan='5'>Nessun risultato</td></tr>";

            $("#sistemiGrid tbody").html(html);

            $("#sistemiGrid").tablesorter({

                headers: {
                    0: { sorter: false }
                }
            });

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

            //tasto cambia attivazione
            var attivazioneButton = $("#AttivaDisattivaButton");

            switch (dettaglio.IdStato) {

                case 3:
                    attivazioneButton.text("Attiva");
                    break;

                case 1:
                    attivazioneButton.text("Disattiva");
                    break;

                default:
                    attivazioneButton.fadeTo("fast", .5).removeAttr("href");
                    break;
            }

            attivazioneButton.unbind("onclick");
            attivazioneButton.bind("onclick", function () { cambiaAttivazione(dettaglio.IdStato); });

            //SetLoaderForButton('.cercaFlag', false);
        },
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
            location.href = "AbbonamentiStampe.aspx";
        }
    });
}

function salva(esciDopoIlSalvataggio) {

    if (!valida())
        return;

    var buttonId = esciDopoIlSalvataggio ? "#SalvaButton" : "#ApplicaButton";

    SetLoaderForAnchor(buttonId, true);

    var idSottoscrizione = !$.QueryString["Id"] ? '' : $.QueryString["Id"];
    var dataFine = $("#DataFineAlTextBox").val();
    var idTipoReferto = $("#TipoRefertoSelect").val();
    //var idTipoAbbonamento = $("#TipoAbbonamentoSelect").val();
    var serverDiStampa = $("#ServerDiStampaTextBox").val();
    var stampante = $("#StampanteTextBox").val();
    var nome = $("#NomeTextBox").val();
    var descrizione = $("#DescrizioneTextarea").val();
    var stampaConfidenziali = $("#chkStampaConfidenziali").prop("checked");
    var stampaOscurati = $("#chkStampaOscurati").prop("checked");
    var listaIdReparti = $('#sistemiGrid tbody tr').map(function () { return $(this).attr("id"); }).get();
    var numeroCopie = $("#NumeroCopieTextBox").val();

    $.ajax({
        type: "POST",
        url: "AbbonamentiStampeDettaglio.aspx/Salva",
        data: "{'idSottoscrizione':'" + idSottoscrizione + "','dataFine':'" + dataFine + "', 'idTipoReferto':" + idTipoReferto + ",'serverDiStampa':'" + escape(serverDiStampa) + "','stampante':'" + escape(stampante) + "','nome':'" + escape(nome) + "','descrizione':'" + escape(escapeHtmlEntities(descrizione)) + "','listaIdReparti':'" + escape(listaIdReparti.join(";")) + "','stampaConfidenziali':'" + stampaConfidenziali + "','stampaOscurati':'" + stampaOscurati + "','numeroCopie':'" + numeroCopie + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            SetLoaderForButton(buttonId, false);

            if (esciDopoIlSalvataggio) {
                location.href = "AbbonamentiStampe.aspx";
                return;
            }

            var id = result.d;

            location.href = "AbbonamentiStampeDettaglio.aspx?Id=" + id;
        },
        error: function (error) { alert('Si è verificato un errore'); SetLoaderForAnchor(buttonId, false); }
    });
}

function cambiaAttivazione(idStato) {

    var id = $.QueryString["Id"];

    if (!id)
        return;

    var buttonId = "#AttivaDisattivaButton";

    SetLoaderForAnchor(buttonId, true);

    $.ajax({
        type: "POST",
        url: "AbbonamentiStampe.aspx/CambiaStatoAttivazioneSottoscrizione",
        data: "{'id':'" + id + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {

            response = result.d;

            if (response == 'error') {

                alert("Impossibile attivare/disattivare la sottoscrizione");
                SetLoaderForAnchor(buttonId, false);
            }
            else {

                location.href = "AbbonamentiStampeDettaglio.aspx?Id=" + id;
            }
        },
        error: function (error) { alert('Si è verificato un errore'); SetLoaderForAnchor(buttonId, false); }
    });
}

function elimina() {

    var id = $.QueryString["Id"];

    if (!id)
        return;

    if (!confirm("La sottoscrizione verrà eliminata, continuare?")) {
        return;
    }

    var buttonId = "#EliminaButton";

    SetLoaderForAnchor(buttonId, false);

    $.ajax({
        type: "POST",
        url: "AbbonamentiStampe.aspx/CancellaSottoscrizione",
        data: "{'id':'" + id + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {

            response = result.d;

            if (response == 'error') {

                alert("Impossibile eliminare la sottoscrizione");
                SetLoaderForAnchor(buttonId, false);
            }
            else {

                location.href = "AbbonamentiStampe.aspx";
            }
        },
        error: function (error) { alert('Si è verificato un errore'); SetLoaderForAnchor(buttonId, false); }
    });
}

//RR

function mostraDialogAggiungiRepartiRichiedenti() {

    $('#selettoreGrid tbody').html('');

    $('#AggiungiRepartiRichiedentiDiv').dialog({
        width: 900,
        height: 650 + "px",
        modal: true,
        position: 'center',
        title: "Aggiungi Reparti Richiedenti",
        resizable: false,
        open: function (event, ui) {

            $('body').css({ 'overflow-y': 'hidden', 'overflow-x': 'hidden' });
        },
        close: function (event, ui) {

            $('body').css({ 'overflow-y': 'scroll', 'overflow-x': 'auto' });
        },
        buttons: {
            "Ok": function () {

                aggiungiRepartiRichiedenti();

                $(this).dialog("close");
            }
        }
    });
}

function CercaReparti() {

    var azienda = $("#aziendaFiltro").val();
    var sistema = $("#sistemaFiltro").val();
    var descrizione = $("#descrizioneFiltro").val();

    $("#loader").show();

    $.ajax({
        type: "POST",
        url: "AbbonamentiStampeDettaglio.aspx/CercaReparti",
        data: "{'azienda':'" + escape(azienda) + "','sistema':'" + escape(sistema) + "','descrizione':'" + escape(descrizione) + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            if (result.d == null || result.d.length == 0) {

                $("#selettoreGrid tbody").html("<tr><td colspan='5'>Nessun risultato</td></tr>");
                $("#loader").fadeOut();
                return;
            }

            var reparti = result.d;

            var html = BindGrid("#selettoreTemplate", reparti);

            $("#selettoreGrid tbody").html(html);

            $("#selettoreGrid").tablesorter({

                headers: {
                    0: { sorter: false }
                }
            });

            $("#loader").fadeOut();

            $("#selettoreGrid .GridItem").hover(function () {

                $(this).addClass("GridHover");

            }, function () {

                $(this).removeClass("GridHover");
            });

            $("#selettoreGrid .gridCheckBox").change(function () {

                var checked = $(this).attr('checked');

                if (checked == 'checked') {

                    $(this).parent().parent().addClass('GridSelected');

                } else {

                    $(this).parent().parent().removeClass('GridSelected');
                }
            });
        },
        error: function (error) {

            $("#loader").fadeOut();

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
        }
    });
}

function aggiungiRepartiRichiedenti() {

    var selectedRows = $('#selettoreGrid tbody tr.GridSelected');

    if (selectedRows.length > 0) {

        var id = $.QueryString["Id"];

        var listaIdPresenti = $('#sistemiGrid tbody tr').map(function () { return $(this).attr("id"); }).get();
        var listaIdReparti = selectedRows.map(function () { return $(this).attr("id"); }).get();

        var listaDaAggiungere = $.grep(listaIdReparti, function (n, i) {
            return $.inArray(n, listaIdPresenti) == -1;
        });

        if (listaDaAggiungere.length == 0)
            return;

        $.ajax({
            type: "POST",
            url: "AbbonamentiStampeDettaglio.aspx/AggiungiReparti",
            data: "{'idSottoscrizione':'" + id + "','listaId':'" + escape(listaDaAggiungere.join(";")) + "'}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (result) {

                var gridBody = $('#sistemiGrid tbody');

                if ($('#sistemiGrid tbody tr.GridItem').length == 0)
                    gridBody.html("");

                selectedRows.each(function () {

                    var selectedRow = $(this);

                    if ($.inArray(selectedRow.attr("id"), listaIdPresenti) == -1)
                        gridBody.append(selectedRow);
                });
            },
            error: function (error) {

                $("#loader").fadeOut();

                var message = GetMessageFromAjaxError(error.responseText);
                alert(message);
            }
        });
    }
}

function eliminaRepartiRichiedenti() {

    var selectedRows = $('#sistemiGrid tbody tr.GridSelected');

    if (selectedRows.length > 0) {

        var id = $.QueryString["Id"];
        var listaIdReparti = selectedRows.map(function () { return $(this).attr("id"); }).get();

        $.ajax({
            type: "POST",
            url: "AbbonamentiStampeDettaglio.aspx/RimuoviReparti",
            data: "{'idSottoscrizione':'" + id + "','listaId':'" + escape(listaIdReparti.join(";")) + "'}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (result) {

                selectedRows.fadeOut(500);
                selectedRows.remove();
            },
            error: function (error) {

                $("#loader").fadeOut();

                var message = GetMessageFromAjaxError(error.responseText);
                alert(message);
            }
        });
    }
}

//Binding
function BindControls(row) {

    $("#testata input[data-bind], #testata select[data-bind], #testata textarea[data-bind]").each(function () {

        var fieldName = $(this).attr("data-bind");

        if ($(this).is(':checkbox')) {
            $(this).attr('checked', row[fieldName]);
        }
        else {
            $(this).val(row[fieldName]);
        }

    });
}

function BindGrid(templateId, rows) {

    var template = $(templateId).html();
    var html = [];

    for (var index in rows) {

        var row = rows[index];

        var formattedRow = template;

        //var test = template.formatWithName(row);

        for (var property in row) {

            formattedRow = formattedRow.replace("{" + property + "}", row[property]);
        }

        html.push(formattedRow)
    }

    return htmlDecode(html.join(""));
}

function valida(selettoreControllo) {

    //se non specifico un controllo, valida tutto
    if (!selettoreControllo)
        selettoreControllo = "#testata input[data-validate], #testata select[data-validate], #testata textarea[data-validate]";

    var validated = true;

    $(selettoreControllo).each(function () {

        var value = $(this).val();

        if (value == '') {

            $(this).addClass("validationError");
            $(this).attr("alt", "Campo obbligatorio");

            validated = false;
        }
        else {
            $(this).removeClass("validationError");
            $(this).removeAttr("alt");
        }
    });

    return validated;
}