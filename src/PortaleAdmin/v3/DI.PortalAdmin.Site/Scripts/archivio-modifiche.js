
$(document).ready(function () {


});

function OpenPopup(id, tabella, identificativo) {

    $('#dettaglioContainer').dialog('destroy');
    $('#dettaglioContainer').dialog({
        height: 450,
        width: 790,
        modal: true,
        position: [200, 100],
        title: "Modifica a tabella " + tabella + ", id: " + identificativo,
        buttons: {

            "Chiudi": function () {

                $(this).dialog("close");
            }
        },
        close: function () {

            $("#dettaglioDiv").html('');
        }
    });

    CaricaDettaglio(id);
}

function CaricaDettaglio(id) {

    $("#loader").show();
    $("#dettaglioDiv").html("");

    $.ajax({
        type: "POST",
        url: "ArchivioModifiche.aspx/CaricaDettaglioModifiche",
        data: "{id:" + id + "}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            if (result.d.length == 0) {

                $("#dettaglioDiv").html("Nessun Risultato");
                $("#loader").hide();
                return;
            }

            var html = new Array();

            html.push('<table id="detailGrid" class="Grid" style="display:none; border:1px silver solid; border-collapse:collapse; width:100%;" border="1" cellspacing="0"><thead>');

            for (var property in result.d[0]) {

                html.push('<th>' + property + '</th>');
            }

            html.push('</thead><tbody>');

            for (var i = 0; i < result.d.length; i++) {

                var riga = result.d[i];

                html.push('<tr id="' + riga.Tipo + '" class="GridAlternatingItem">');

                var count = 0;
                for (var property in riga) {

                    if (count == 0)
                        html.push('<td style="background-color:#C0E9D6;">' + riga[property] + '</td>');
                    else
                        html.push('<td style="">' + riga[property] + '</td>');

                    count++;
                }

                html.push('</tr>');
            }

            html.push('</tbody></table>');

            $("#dettaglioDiv").height(15 * (result.d.length + 1));

            $("#dettaglioDiv").html(html.join(""));
            $("#detailGrid").fadeIn('slow');
            $("#loader").hide();
        },
        error: function (error) { var message = GetMessageFromAjaxError(error.responseText); alert(message); } //<----cambiare messaggio?
    });
}

