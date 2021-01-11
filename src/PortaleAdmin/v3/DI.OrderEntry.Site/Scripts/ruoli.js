
$(document).ready(function () {

    $('body').css('overflow', 'hidden');

    LoadAziende();
    //CaricaRuoli();

    SetupHeights();
});

$(document).keypress(function (e) {
    if (e.which == "13") {
        //enter pressed 
        return false; 
    }
});

$(window).resize(function () {

    SetupHeights();
});

function SetupHeights() {

    var height = $("#mainContainer").parent().height() - $("#Ruolifieldset").outerHeight(true);

    $("#splitter").height(height);
    $("#splitterUtenti").height(height);

    SetupGridHeightsUnitaOperative();
    SetupGridHeightsUtenti();
}

function GetFilter(controlId) {

    var paramValue;

    $.ajax({
        async: false,
        type: "POST",
        url: "Ruoli.aspx/GetFilter",
        data: "{'controlId':'" + controlId + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            paramValue = result.d;

        },
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
        } 
    });

    return paramValue;
}

function SetupGridHeightsUnitaOperative() {

    //uo
    var height = $("#selettoreUnitaOperative").parent().height() - $("#selettoreUnitaOperativeFiltro").outerHeight(true);

    $("#listaUnitaOperative").height(height - 40);

    $("#UnitaOperative").height($("#UnitaOperative").parent().height() - 20);

    var heightSelettoreUnitaOperativeRuolo = $("#selettoreUnitaOperativeRuolo").parent().height() - $("#selettoreUnitaOperativeFiltroRuolo").outerHeight(true);

    $("#UnitaOperative").height(heightSelettoreUnitaOperativeRuolo - 40);        
   

}


function SetupGridHeightsUtenti() {

    //utenti
    height = $("#selettoreUtenti").parent().height() - $("#selettoreUtentiFiltro").outerHeight(true);

    $("#listaUtenti").height(height - 40);

    $("#Utenti").height($("#Utenti").parent().height() - 20);

    var heightSelettoreUtentiRuolo = $("#selettoreUtenteRuolo").parent().height() - $("#selettoreUtenteFiltroRuolo").outerHeight(true);

    $("#Utenti").height(heightSelettoreUtentiRuolo - 40);

}

function SwitchPanels() {

    var uoSplitter = $("#splitter");
    var utentiSplitter = $("#splitterUtenti");
             
    if (uoSplitter.css("display") == "none") {

        uoSplitter.show();
        utentiSplitter.hide();
        
    }
    else {

        utentiSplitter.show();
        uoSplitter.hide();
    }

    $("#loaderUtenteRuolo").fadeOut();
    $("#loaderUORuolo").fadeOut();
       
}

function LoadAziende() {

    var aziendeSelect = $("#aziende");
    aziendeSelect.attr('disabled', 'disabled');

    var aziendaFiltroRuoloSelect = $("#aziendaUOFiltroRuolo");
    aziendaFiltroRuoloSelect.attr('disabled', 'disabled');

    $.ajax({
        type: "POST",
        url: "Ruoli.aspx/GetLookupAziende",
        data: "{}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            for (var azienda in result.d) {

                aziendeSelect.append("<option value='" + azienda + "'>" + result.d[azienda] + "</option>");
                aziendaFiltroRuoloSelect.append("<option value='" + azienda + "'>" + result.d[azienda] + "</option>");
            }

            aziendeSelect.removeAttr('disabled');
            aziendaFiltroRuoloSelect.removeAttr('disabled');
        },
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
        } 
    });
}


function CaricaRuoliGetFilter(idRuolo) {

    var codiceDescrizione;
    codiceDescrizione = GetFilter('CodiceDescrizioneFiltroTextBox');
    var attivo;
    attivo = GetFilter('AttivoCheckBox');

    CaricaRuoli(idRuolo, codiceDescrizione, attivo);

}

function CaricaRuoli(idRuolo, descrizione, attivo) {

    if (!descrizione) {
        descrizione = "";
    }
    if (attivo == undefined || attivo == null) {
        attivo = true;
    }

//    var descrizione = $("#filtroRuoliDescrizione").val();
//    var attivoCheckBox = $("#AttivoCheckBox");
//    var attivo = attivoCheckBox.attr('checked') == 'checked';

    $.ajax({
        type: "POST",
        url: "Ruoli.aspx/GetRuoli",
        data: "{'descrizione':'" + descrizione + "', 'attivo':'" + attivo + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            if (!result.d) {

                $("#Ruoli").html("Nessun ruolo");                
                return;
            }

            var html = [];

            for (var property in result.d) {

                html.push('<a href="#" id="' + property + '" class="linkRuoli" ondblclick="ModificaRuolo(\'' + property + '\')" onclick="CaricaUnitaOperative(\'' + property + '\');  CaricaUtenti(\'' + property + '\'); return false;" alt="clicca due volte per modificare" title="clicca due volte per modificare">' + result.d[property] + '</a><br />');
            }

            $("#Ruoli").html(html.join(""));
                                    
            if (!idRuolo)
                $("#Ruoli .linkRuoli:first").addClass("selectedLinkRuoli");
            else
                $("#" + idRuolo).addClass("selectedLinkRuoli");

            $("#UnitaOperative").html("<div style='background-color:#DBDBDB; height:100%;'></div>");

            var id = $(".selectedLinkRuoli").attr("id");

            CaricaUnitaOperative(id);
            CaricaUtenti(id);
        },
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
        } 
    });
}

function ModificaRuolo(idRuolo) {

    var descrizione = $("#Ruoli .selectedLinkRuoli").html();

    var descrizioneTextBox = $("#ruolo_descrizione");

    descrizioneTextBox.val(descrizione);
    descrizioneTextBox.next().hide();

    $('#modificaRuolo').dialog({
        height: 200,
        width: 300,
        modal: true,
        position: 'center',
        title: "Modifica ruolo",
        resizable: true,
        buttons: {
            "Ok": function () {

                var descrizione = descrizioneTextBox.val();

                if (descrizione == '') {

                    descrizioneTextBox.next().fadeIn();
                    return;
                }

                SalvaRuolo(idRuolo, descrizioneTextBox.val());

                CaricaRuoliGetFilter(idRuolo);

                $(this).dialog("close");
            },
            "Annulla": function () {

                $(this).dialog("close");
            }
        }
    });
}

function AggiungiRuolo() {

    var descrizioneTextBox = $("#ruolo_descrizione");

    descrizioneTextBox.val('');
    descrizioneTextBox.next().hide();

    $('#modificaRuolo').dialog({
        height: 200,
        width: 300,
        modal: true,
        position: 'center',
        title: "Modifica ruolo",
        resizable: true,
        buttons: {
            "Ok": function () {

                var descrizione = descrizioneTextBox.val();

                if (descrizione == '') {

                    descrizioneTextBox.next().fadeIn();
                    return;
                }

                var idRuolo = SalvaRuolo('', descrizioneTextBox.val());

                CaricaRuoliGetFilter(idRuolo);

                $(this).dialog("close");
            },
            "Annulla": function () {

                $(this).dialog("close");
            }
        }
    });
}

function SalvaRuolo(idRuolo, descrizione) {

    $.ajax({
        type: "POST",
        url: "Ruoli.aspx/UpdateRuolo",
        data: "{'idRuolo':'" + idRuolo + "','descrizione':'" + escape(descrizione) + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {

            if (!result.d) {

                return;
            }

            idRuolo = result.d;

        },
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
        } 
    });

    return idRuolo;
}

function EliminaRuolo() {

    if (!confirm("Il ruolo verrà eliminato, continuare?")) {
        return;
    }

    var idRuolo = $(".selectedLinkRuoli").attr("id");

    $.ajax({
        type: "POST",
        url: "Ruoli.aspx/DeleteRuolo",
        data: "{'idRuolo':'" + idRuolo + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {

            response = result.d;

            if (response == 'error') {

                alert("Impossibile eliminare il ruolo.");
            }
            else CaricaRuoliGetFilter();
        },
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
        } 
    });
}

/**UO**/
function FiltraUnitaOperativeRuolo() {

    var idRuolo = $("#Ruoli .selectedLinkRuoli").attr("id");

    if (idRuolo)
        CaricaUnitaOperative(idRuolo)
    else
        alert('Occorre prima selezionare un ruolo');

    error: function (error) {

        var message = GetMessageFromAjaxError(error.responseText);
        alert(message);
    } 

}
function CaricaUnitaOperative(idRuolo) {


    if (!idRuolo || idRuolo == '')
        return;

    $("#Ruoli .selectedLinkRuoli").removeClass("selectedLinkRuoli");
    $("#" + idRuolo).addClass("selectedLinkRuoli");

    var descrizioneUOFiltroRuolo = $("#descrizioneUOFiltroRuolo").val();
    var aziendaUOFiltroRuolo = $("#aziendaUOFiltroRuolo").val();

    $("#loaderUORuolo").show();

    $.ajax({
        type: "POST",
        url: "Ruoli.aspx/GetUnitaOperative",
        data: "{'idRuolo':'" + idRuolo + "', 'codiceAzienda':'" + aziendaUOFiltroRuolo + "', 'codiceUO':'" + escape(descrizioneUOFiltroRuolo) + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            if (!result.d) {

                $("#UnitaOperative").html("Nessun unità operativa");
                $("#loaderUORuolo").fadeOut();
                if ($("#selettoreGrid").length > 0) CercaUnitaOperative();                
                return;
            }

            var html = [];

            html.push('<table id="unitaOperativeGrid" class="tablesorter" style="border:1px silver solid; border-collapse:collapse; width:98%; margin-top:5px;"><thead>');
            html.push('<th style="text-align:center; width:30px; padding:0px;"><input type="checkbox" style="background: transparent; border-style: none; cursor: pointer;" onclick="SelectDeselectAll($(this), $(\'#unitaOperativeGrid\'));" /></th><th>Azienda</th><th>Codice</th><th>Descrizione</th>');
            html.push('</thead><tbody>');

            for (var property in result.d) {

                var unitaOperativa = result.d[property];

                html.push('<tr id="' + property + '" class="GridItem" style="height: 25px;">');

                html.push('<td style="text-align:center; padding: 0px;"><input type="checkbox" class="gridCheckBox" /></td>');
                html.push('<td style="text-align:center; width:80px;">' + unitaOperativa.CodiceAzienda + '</td>');
                html.push('<td style="text-align:center;">' + unitaOperativa.Codice + '</td>');
                html.push('<td style="text-align:center;">' + unitaOperativa.Descrizione + '</td>');
                html.push('</tr>');
            }

            html.push('</tbody></table>');

            $("#UnitaOperative").html(html.join(""));

            $("#unitaOperativeGrid").tablesorter({

                headers: {
                    0: { sorter: false }
                }
            });

            $("#loader").fadeOut();
            $("#loaderUORuolo").fadeOut();

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

            if ($("#selettoreGrid").length > 0) CercaUnitaOperative();

                  
        },
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
        } 
    });
}

function AddUnitaOperative() {

    if ($('#selettoreGrid .GridSelected').length > 0) {

        var idRuolo = $("#Ruoli .selectedLinkRuoli").attr("id");
        
        if (idRuolo) {
            var idUnitaOperative = new Array();
            var idUnitaOperativeDelRuolo = $("#unitaOperativeGrid .GridItem").map(function () { return $(this).attr("id"); }).get();

            $('#selettoreGrid .GridSelected').each(function () {

                var idUnitaOperativa = $(this).attr("id");

                if ($.inArray(idUnitaOperativa, idUnitaOperativeDelRuolo) == -1)
                    idUnitaOperative.push(idUnitaOperativa);
            });

            AggiungiUnitaOperativeARuolo(idRuolo, idUnitaOperative);

            CaricaUnitaOperative(idRuolo);
        }
        else
        { alert('Occorre prima selezionare un ruolo'); }
               
    }
}

function RemoveUnitaOperative() {

    if ($('#unitaOperativeGrid .GridSelected').length > 0) {

        var idRuolo = $("#Ruoli .selectedLinkRuoli").attr("id");
        var unitaOperative = $("#unitaOperativeGrid .GridSelected").map(function () { return $(this).attr("id"); }).get();

        RimuoviUnitaOperativaDaRuolo(idRuolo, unitaOperative);
    }
}

function RimuoviUnitaOperativaDaRuolo(idRuolo, unitaOperative) {

    $.ajax({
        type: "POST",
        url: "Ruoli.aspx/DeleteUnitaOperativeDaRuolo",
        data: "{'idRuolo':'" + idRuolo + "', 'unitaOperative':'" + escape(unitaOperative.join(";")) + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {

            CaricaUnitaOperative(idRuolo);
        },
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
        } 
    });
}

function CercaUnitaOperative() {

    var azienda = $("#aziende").val();
    var descrizione = $("#descrizioneFiltro").val();

    $("#loader").show();

    $.ajax({
        type: "POST",
        url: "Ruoli.aspx/GetListaUnitaOperative",
        data: "{'codiceAzienda':'" + azienda + "', 'descrizione':'" + escape(descrizione) + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            if (result.d == null) {

                $("#listaUnitaOperative").html("<br />Nessun risultato");
                $("#loader").fadeOut();
                return;
            }

            var html = [];

            html.push('<table id="selettoreGrid" class="tablesorter" style="border:1px silver solid; border-collapse:collapse; width:96%; margin-top:5px;"><thead>');
            html.push('<th style="text-align:center; width:30px; padding:0px;"><input type="checkbox" style="background: transparent; border-style: none; cursor: pointer;" onclick="SelectDeselectAll($(this), $(\'#selettoreGrid\'));" /></th><th>Azienda</th><th>Codice</th><th>Descrizione</th>');
            html.push('</thead><tbody>');

            for (var i = 0; i < result.d.length; i++) {

                var unitaOperativa = result.d[i];

                var idUnitaOperativeDelRuolo = $("#unitaOperativeGrid .GridItem").map(function () { return $(this).attr("id"); }).get();

                html.push('<tr id="' + unitaOperativa.CodiceAzienda + "-" + unitaOperativa.Codice + '" class="GridItem" style="height: 25px;' + (unitaOperativa.Attivo ? '' : 'background-color: silver;') + '">');

                if ($.inArray(unitaOperativa.CodiceAzienda + "-" + unitaOperativa.Codice, idUnitaOperativeDelRuolo) == -1)
                    html.push('<td style="text-align:center; padding:0px;"><input type="checkbox" class="gridCheckBox" /></td>');
                else
                    html.push('<td style="text-align:center; padding:0px;"></td>');

                html.push('<td style="text-align:center; width:80px;">' + unitaOperativa.CodiceAzienda + '</td>');
                html.push('<td style="text-align:center;">' + unitaOperativa.Codice + '</td>');
                html.push('<td style="text-align:center;">' + unitaOperativa.Descrizione + '</td>');
                html.push('</tr>');
            }

            html.push('</tbody></table>');

            $("#listaUnitaOperative").html(html.join(""));

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

            SetupGridHeightsUnitaOperative();         
        },
        error: function (error) {

            $("#loader").fadeOut();

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message); 
        } 
    });
}

function AggiungiUnitaOperativeARuolo(idRuolo, unitaOperative) {

    $.ajax({
        type: "POST",
        url: "Ruoli.aspx/InsertUnitaOperativeInRuolo",
        data: "{'idRuolo':'" + idRuolo + "','unitaOperative':'" + escape(unitaOperative.join(";")) + "'}",
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


/**Utenti**/
function FiltraUtentiRuolo() {

    var idRuolo = $("#Ruoli .selectedLinkRuoli").attr("id");

    if (idRuolo)
        CaricaUtenti(idRuolo)
    else
        alert('Manca Id del Ruolo: si è verificato un errore');

    error: function (error) {

        var message = GetMessageFromAjaxError(error.responseText);
        alert(message);
    } 

}

function CaricaUtenti(idRuolo) {

    if (!idRuolo || idRuolo == '')
        return;

    $("#Ruoli .selectedLinkRuoli").removeClass("selectedLinkRuoli");
    $("#" + idRuolo).addClass("selectedLinkRuoli");

    var descrizioneUtenteFiltroRuolo = $("#descrizioneUtenteFiltroRuolo").val();

    $("#loaderUtenteRuolo").show();

    $.ajax({
        type: "POST",
        url: "Ruoli.aspx/GetUtenti",
        data: "{'idRuolo':'" + idRuolo + "', 'descrizione':'" + escape(descrizioneUtenteFiltroRuolo) + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            if (!result.d) {

                $("#Utenti").html("Nessun utente");
                if ($("#selettoreUtentiGrid").length > 0) CercaUtenti();
                $("#loaderUtenteRuolo").fadeOut();
                return;
            }

            var html = [];

            html.push('<table id="utentiGrid" class="tablesorter" style="border:1px silver solid; border-collapse:collapse; width:98%; margin-top:5px;"><thead>');
            html.push('<th style="text-align:center; width:30px; padding:0px;"><input type="checkbox" style="background: transparent; border-style: none; cursor: pointer;" onclick="SelectDeselectAll($(this), $(\'#utentiGrid\'));" /></th><th>Nome utente</th>');
            html.push('</thead><tbody>');

            for (var property in result.d) {

                var utente = result.d[property];

                html.push('<tr id="' + property + '" class="GridItem" style="height: 25px;">');

                html.push('<td style="text-align:center; padding: 0px;"><input type="checkbox" class="gridCheckBox" /></td>');
                html.push('<td style="text-align:center;">' + utente + '</td>');
                html.push('</tr>');
            }

            html.push('</tbody></table>');

            $("#Utenti").html(html.join(""));

            $("#utentiGrid").tablesorter({

                headers: {
                    0: { sorter: false }
                }
            });

            $("#loaderUtenteRuolo").fadeOut();
            $("#loader").fadeOut();

            $("#utentiGrid .GridItem").hover(function () {

                $(this).addClass("GridHover");

            }, function () {

                $(this).removeClass("GridHover");
            });

            $("#utentiGrid .gridCheckBox").change(function () {

                var checked = $(this).attr('checked');

                if (checked == 'checked') {

                    $(this).parent().parent().addClass('GridSelected');

                } else {

                    $(this).parent().parent().removeClass('GridSelected');
                }
            });

            if ($("#selettoreUtentiGrid").length > 0) CercaUtenti();

           
        },
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
        } 
    });
}

function AddUtenti() {

    if ($('#selettoreUtentiGrid .GridSelected').length > 0) {

        var idRuolo = $("#Ruoli .selectedLinkRuoli").attr("id");
        var idUtenti = new Array();
        var idUtentiDelRuolo = $("#utentiGrid .GridItem").map(function () { return $(this).attr("id"); }).get();

        $('#selettoreUtentiGrid .GridSelected').each(function () {

            var idUtente = $(this).attr("id");

            if ($.inArray(idUtente, idUtentiDelRuolo) == -1)
                idUtenti.push(idUtente);
        });

        AggiungiUtentiARuolo(idRuolo, idUtenti);

        CaricaUtenti(idRuolo);
    }
}

function RemoveUtenti() {

    if ($('#utentiGrid .GridSelected').length > 0) {

        var idRuolo = $("#Ruoli .selectedLinkRuoli").attr("id");
        var utenti = $("#utentiGrid .GridSelected").map(function () { return $(this).attr("id"); }).get();

        RimuoviUtenteDaRuolo(idRuolo, utenti);
    }
}

function RimuoviUtenteDaRuolo(idRuolo, utenti) {

    $.ajax({
        type: "POST",
        url: "Ruoli.aspx/DeleteUtentiDaRuolo",
        data: "{'idRuolo':'" + idRuolo + "', 'utenti':'" + escape(utenti.join(";")) + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {

            CaricaUtenti(idRuolo);
        },
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
        } 
    });
}

function CercaUtenti() {

    var descrizione = $("#descrizioneUtenteFiltro").val();

    $("#loaderUtenti").show();

    $.ajax({
        type: "POST",
        url: "Ruoli.aspx/GetListaUtenti",
        data: "{'descrizione':'" + escape(descrizione) + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            if (result.d == null) {

                $("#listaUtenti").html("<br />Nessun risultato");
                $("#loaderUtenti").fadeOut();
                return;
            }

            var html = [];

            html.push('<table id="selettoreUtentiGrid" class="tablesorter" style="border:1px silver solid; border-collapse:collapse; width:96%; margin-top:5px;"><thead>');
            html.push('<th style="text-align:center; width:30px; padding:0px;"><input type="checkbox" style="background: transparent; border-style: none; cursor: pointer;" onclick="SelectDeselectAll($(this), $(\'#selettoreUtentiGrid\'));" /></th><th>Nome utente</th><th>Nome completo</th>');
            html.push('</thead><tbody>');

            for (var i = 0; i < result.d.length; i++) {

                var utente = result.d[i];

                var idUtentiDelRuolo = $("#utentiGrid .GridItem").map(function () { return $(this).attr("id"); }).get();

                html.push('<tr id="' + utente.NomeUtente + '" class="GridItem" style="height: 25px;">');

                if ($.inArray(utente.NomeUtente, idUtentiDelRuolo) == -1)
                    html.push('<td style="text-align:center; padding:0px;"><input type="checkbox" class="gridCheckBox" /></td>');
                else
                    html.push('<td style="text-align:center; padding:0px;"></td>');

                html.push('<td style="text-align:center;">' + utente.NomeUtente + '</td>');
                html.push('<td style="text-align:center;">' + (utente.Descrizione ? utente.Descrizione : '') + '</td>');
                //html.push('<td style="text-align:center;">' + '' + '</td>');
                html.push('</tr>');
            }

            html.push('</tbody></table>');

            $("#listaUtenti").html(html.join(""));

            $("#selettoreUtentiGrid").tablesorter({

                headers: {
                    0: { sorter: false }
                }
            });

            $("#loaderUtenti").fadeOut();

            $("#selettoreUtentiGrid .GridItem").hover(function () {

                $(this).addClass("GridHover");

            }, function () {

                $(this).removeClass("GridHover");
            });

            $("#selettoreUtentiGrid .gridCheckBox").change(function () {

                var checked = $(this).attr('checked');

                if (checked == 'checked') {

                    $(this).parent().parent().addClass('GridSelected');

                } else {

                    $(this).parent().parent().removeClass('GridSelected');
                }
            });

            SetupGridHeightsUtenti();
        },
        error: function (error) {

            $("#loader").fadeOut();

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message); 
        } 
    });
}

function AggiungiUtentiARuolo(idRuolo, utenti) {

    $.ajax({
        type: "POST",
        url: "Ruoli.aspx/InsertUtentiInRuolo",
        data: "{'idRuolo':'" + idRuolo + "','utenti':'" + escape(utenti.join(";")) + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {

            if (!result.d) {

                return;
            }
        },
//        error: function (error) { alert('Aggiungi un utente ad un ruolo: si è verificato un errore'); }
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
        } 
    });
}