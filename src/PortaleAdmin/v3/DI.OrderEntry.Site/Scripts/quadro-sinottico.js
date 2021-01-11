
$(document).ready(function () {

    LoadSinottico();

    $("#periodoSelect").change(function () {

        LoadSinottico();
    });
});

function LoadSinottico() {

    $("#loader").show();

    var periodo = $("#periodoSelect");

    var today = new Date();
    var dataDa = new Date();

    switch (periodo.val()) {

        case "0": //ultima ora
            dataDa.setHours(today.getHours() - 1);
            break;

        case "1": //ultime 24 ore
            dataDa.setDate(today.getDate() - 1);
            break;

        case "2": //ultima settimana
            dataDa.setDate(today.getDate() - 7);
            break;

        case "3": //ultimo mese
            dataDa.setDate(today.getDate() - 30);
            break;
    }

    $.ajax({
        type: "POST",
        url: "QuadroSinottico.aspx/GetSinotticoData",
        data: "{dataDa:'" + formatDateTime(dataDa) + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            if (result.d.length == 0) {

                $("#sinotticoGrid").html("Nessun Risultato");
                $("#loader").hide();
                return;
            }

            var html = new Array();

            html.push('<table class="Grid" style="border:1px silver solid; border-collapse:collapse;" border="1" cellspacing="0"><thead>');

            for (var property in result.d[0]) {

                html.push('<th>' + property + '</th>');
            }

            html.push('</thead><tbody>');

            for (var i = 0; i < result.d.length; i++) {

                var riga = result.d[i];

                html.push('<tr id="' + riga.Tipo + '" class="GridAlternatingItem">');

                var count = 0;
                for (var property2 in riga) {

                    if (count == 0)
                        html.push('<td style="background-color:#C0E9D6; width:150px; min-width:100px;"><div style="margin: 0px 0px 0px 0px; padding:2px; text-align:left; height: 1px; width: 150px;"><a href="#" onclick="DrillDown(\'' + riga.Tipo + '\'); return false;">' + riga[property2] + '</a></div></td>');
                    else
                        html.push('<td style="width:100px"><div style="margin: 0px 0px 0px 0px;height: 1px; width: 100px;">' + riga[property2] + '</div></td>');

                    count++;
                }

                html.push('</tr>');
            }

            html.push('</tbody></table>');

            $("#sinotticoGrid").html(html.join(""));

            $("#loader").hide();
        },
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
        } 
    });
}

function DrillDown(tipo) {

    var next = $("#" + tipo).next();

    if (next.length > 0 && !next.attr("id")) {

        next.remove();

        return false;
    }

    var columnCount = $("#" + tipo + " td").length;

    $("#" + tipo).after('<tr colspan="' + columnCount + '"><td colspan="' + columnCount + '" class="dettaglioSinottico" id="td' + tipo + '"><img src="../Images/refresh.gif" /></td></tr>');

    var periodo = $("#periodoSelect");

    var today = new Date();
    var dataDa = new Date();

    switch (periodo.val()) {

        case "0": //ultima ora

            dataDa.setHours(today.getHours() - 1);
            break;

        case "1": //ultime 24 ore

            dataDa.setDate(today.getDate() - 1);
            break;

        case "2": //ultima settimana

            dataDa.setDate(today.getDate() - 7);
            break;

        case "3": //ultimo mese

            dataDa.setDate(today.getDate() - 30);
            break;
    }

    $.ajax({
        type: "POST",
        url: "QuadroSinottico.aspx/GetSinotticoDettaglioData",
        data: "{sistema:'" + tipo + "', dataDa:'" + formatDateTime(dataDa) + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            var html = new Array();

            html.push('<table cellpadding="0" cellspacing="0"><thead>');

            html.push('</thead><tbody>');

            for (var i = 0; i < result.d.length; i++) {

                var riga = result.d[i];

                var count = 0;
                for (var property in riga) {

                    if (count == 0)
                        html.push('<td style="background-color:#E1FAEE; width:150px;"><div style="margin: 0px 0px 0px 0px; padding:2px 2px 2px 8px; text-align:left; height: 1px; width: 150px;">' + riga[property] + '</div></td>');
                    else
                        html.push('<td style="background-color:#E1FAEE; width:100px;"><div style="margin: 0px 0px 0px 0px; height: 1px; width: 100px;">' + riga[property] + '</div></td>');

                    count++;
                }

                html.push('</tr>');
            }

            html.push('</tbody></table>');

            $("#td" + tipo).html(html.join(""));
        },
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
        } 
    });
}
