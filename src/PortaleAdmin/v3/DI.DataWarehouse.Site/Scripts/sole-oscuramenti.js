
$(document).ready(function () {

    $(".DateTimeInput").datepicker($.datepicker.regional['it']);
});

/****************************************************/
//Cancella i filtri
function ClearFilters() {

    $(".filters select").each(function () {

        $(this).val(' ');
    });

    $(".filters input").each(function () {

        $(this).val('');
    });
}

function GetIdSac(id) {

    var control = $('#idSacButton_' + id).prev();

    $('#selettoreSac').dialog('destroy');
    $('#selettoreSac').dialog({
        height: 500,
        width: 790,
        modal: true,
        position: [240, 100],
        title: "Seleziona un paziente",
        buttons: {
            "Ok": function () {

                if ($('.GridSelected').length == 0) {
                    alert('Selezionare un paziente');
                } else {

                    var idSac = $('#grigliaSelettoreSac .GridSelected').attr('id');

                    control.val(idSac);

                    $(this).dialog("close");
                }
            },
            "Annulla": function () {

                $(this).dialog("close");
            }
        },
        close: function () {

            $("#grigliaSelettoreSac").html('');
            $('#filtroSelettoreCognomeSac').val('');
            $('#filtroSelettoreNomeSac').val('');
        }
    });

    $('#searchSacButton').unbind('click');
    $('#searchSacButton').bind('click', function () {

        var cognome = $('#filtroSelettoreCognomeSac').val();
        var nome = $('#filtroSelettoreNomeSac').val();

        if (cognome.length >= 3)
            loadData("SoleOscuramenti.aspx/GetPazientiSac", "{cognome:'" + cognome + "', nome:'" + nome + "'}", "Sac");
    });
}

function GetIdPaziente() {

    var control = $('#filtroSelettorePaziente');

    $('#selettorePazienti').dialog('destroy');
    $('#selettorePazienti').dialog({
        height: 500,
        width: 790,
        modal: true,
        position: [250, 110],
        title: "Seleziona un paziente",
        buttons: {
            "Ok": function () {

                if ($('.GridSelected').length == 0) {
                    alert('Selezionare un paziente');
                } else {

                    var idPaziente = $('#grigliaSelettorePazienti .GridSelected').attr('id');

                    control.val(idPaziente);

                    $("#searchRefertiButton").removeAttr('disabled');
                    $("#searchRefertiButton").click();

                    $(this).dialog("close");
                }
            },
            "Annulla": function () {

                $(this).dialog("close");
            }
        },
        close: function () {

            $("#grigliaSelettorePazienti").html('');
            $('#filtroSelettoreCognomePazienti').val('');
            $('#filtroSelettoreNomePazienti').val('');
        }
    });

    $('#searchPazientiButton').unbind('click');
    $('#searchPazientiButton').bind('click', function () {

        var cognome = $('#filtroSelettoreCognomePazienti').val();
        var nome = $('#filtroSelettoreNomePazienti').val();

        if (cognome.length >= 3)
            loadData("SoleOscuramenti.aspx/GetPazienti", "{cognome:'" + cognome + "', nome:'" + nome + "'}", "Pazienti");
    });
}

function GetIdReferto(id) {

    var control = $('#idRefertoButton_' + id).prev();

    $("#searchRefertiButton").attr('disabled', true);

    $('#selettoreReferti').dialog('destroy');
    $('#selettoreReferti').dialog({
        height: 500,
        width: 790,
        modal: true,
        position: [240, 100],
        title: "Seleziona un referto",
        buttons: {
            "Ok": function () {

                if ($('.GridSelected').length == 0) {
                    alert('Selezionare un referto');
                } else {

                    var idReferto = $('#grigliaSelettoreReferti .GridSelected').attr('id');

                    control.val(idReferto);

                    $(this).dialog("close");
                }
            },
            "Annulla": function () {

                $(this).dialog("close");
            }
        },
        close: function () {

            $("#grigliaSelettoreReferti").html('');
            $('#filtroSelettorePaziente').val('');
        }
    });

    $('#searchRefertiButton').unbind('click');
    $('#searchRefertiButton').bind('click', function () {

        var idPaziente = $('#filtroSelettorePaziente').val();

        if (idPaziente.length > 0)
            loadData("SoleOscuramenti.aspx/GetReferti", "{idPaziente:'" + idPaziente + "'}", "Referti");
    });
}

///typeName può essere Sac, Referti o Pazienti
function loadData(methoName, parameters, typeName) {

    $("#loader" + typeName).show();

    $.ajax({
        type: "POST",
        url: methoName,
        data: parameters,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            if (result.d == null) {

                $("#grigliaSelettore" + typeName).html("<br />Nessun Risultato");
                $("#loader" + typeName).hide();
                return;
            }

            var html = new Array();

            html.push('<table class="Grid" style="border:1px silver solid; border-collapse:collapse;" border="1" cellspacing="0"><thead>');

            html.push('<th></th>');

            for (var property in result.d[0]) {

                html.push('<th>' + property.replace(/_/g, ' ') + '</th>');
            }

            html.push('</thead><tbody>');

            for (var i = 0; i < result.d.length; i++) {

                var riga = result.d[i];

                var rowClass = i % 2 == 0 ? "GridItem" : "GridAlternatingItem";

                html.push('<tr id="' + riga.Id + '" class="' + rowClass + '">');

                html.push('<td><input type="checkbox" style="" class="gridCheckBox" /></td>');

                var count = 0;
                for (var rowProperty in riga) {

                    html.push('<td style="width:98px"><div style="margin: 0px 0px 0px 0px; height: 1px; width: 98px;">' + riga[rowProperty] + '</div></td>');

                    count++;
                }

                html.push('</tr>');
            }

            html.push('</tbody></table>');

            $("#grigliaSelettore" + typeName).html(html.join(""));

            $("#loader" + typeName).hide();

            $(".gridCheckBox").change(function () {

                $('.gridCheckBox').attr('checked', false);
                $('.gridCheckBox').parent().parent().removeClass('GridSelected');

                $(this).attr('checked', true);
                $(this).parent().parent().addClass('GridSelected');
            });
        },
        error: function (error) { var message = GetMessageFromAjaxError(error.responseText); alert(message); } //<----cambiare messaggio?
    });
}
