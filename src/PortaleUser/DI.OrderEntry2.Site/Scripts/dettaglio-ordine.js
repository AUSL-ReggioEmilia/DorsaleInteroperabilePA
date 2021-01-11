$(document).ready(function () {

    $(".DateInput").datepicker({ onSelect: function () { this.fireEvent && this.fireEvent('onchange') || $(this).change(); } });
    $(".DateTimeInput").datetimepicker({ onSelect: function () { this.fireEvent && this.fireEvent('onchange') || $(this).change(); } });
    $(".TimeInput").timepicker({ onSelect: function () { this.fireEvent && this.fireEvent('onchange') || $(this).change(); } });
    
    var idTestata = $.QueryString["IdRichiesta"];
    LoadTestata(idTestata);

  //  $('#dettaglioPaziente').load('DettaglioPaziente.aspx?Id=' + $.QueryString["IdPaziente"] + ($.QueryString["Nosologico"] ? '&Nosologico=' + $.QueryString["Nosologico"] : '') + ' #dettaglio', function () {

  //      $('#dettaglioPaziente').prepend("<legend>Paziente</legend>")
  //                             .css("background-image", "none");

		//LoadEsenzioniContainer();

  //      LoadRicoveriContainer();
  //      LoadRefertiContainer();
        
  //      setRichiestaDivHeight();
  //  });

    //$(".gridCheckBox").change(function () {

    //    var checked = $(this).attr('checked');

    //    if (checked == 'checked') {

    //        $(this).parent().parent().addClass('GridSelected');

    //    } else {

    //        $(this).parent().parent().removeClass('GridSelected');
    //    }
    //});

    //setRichiestaDivHeight();

    //setInterval(function () {
    //    setRichiestaDivHeight();
    //}, 5000);

   
    //LoadOrdiniData(idTestata);

    $("#aggiornaLink").attr('title', formatDateTime(new Date()));
});

$(window).resize(function () {

    setRichiestaDivHeight();
});

function setRichiestaDivHeight() {

    var height = $("#mainContainer").height() - $("#dettaglioPaziente").outerHeight(true) - $("#toolbar").outerHeight(true);

    $("#richiestaDiv").height(height - 61);
}

function Reload(idTestata) {

    if ($(".ordineRefresh").css("display") != 'none')
        return;

    LoadTestata(idTestata);

    $("#aggiornaLink").attr('title', formatDateTime(new Date()));
}

function LoadTestata(idTestata) {

    $.ajax({
        type: "POST",
        url: "AjaxWebMethods/DettaglioOrdineMethods.aspx/GetDatiTestata",
        data: "{id:'" + idTestata + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            var ordine = result.d;

            $("#NumeroOrdine").html(ordine.NumeroOrdine);
            $("#SistemaRichiedente").html(ordine.SistemaRichiedente);
            $("#Regime").html(ordine.Regime);
            $("#Priorita").html(ordine.Priorita);
            $("#UnitaOperativaRichiedente").html(ordine.UnitaOperativaRichiedente);
            $("#IdRichiestaRichiedente").html(ordine.IdRichiestaRichiedente);
            $("#CodiceAnagrafica").html(ordine.IdRichiestaRichiedente);
            $("#Nosologico").html(ordine.Nosologico);
            $("#DataRichiesta").html(ordine.DataRichiesta);
//            $("#DataInserimento").html(ordine.DataInserimento);
//            $("#DataModifica").html(ordine.DataModifica);
            $("#DataPrenotazione").html(ordine.DataPrenotazione);
            $("#StatoOrderEntryDescrizione").html(ordine.StatoOrderEntryDescrizione);

            var html = new Array();
            //http://localhost:58290/Pages/RiassuntoOrdine.aspx?IdRichiesta=ecdedabf-4c6a-4127-ac07-6107b7c11bcb&IdPaziente=55cd73c7-0750-406e-bf7a-08f6f473e6a0

            for (var i = 0; i < ordine.OrdiniErogati.length; i++) {

                var ordineErogato = ordine.OrdiniErogati[i];
                var testata = ordineErogato.TestataErogato;

                html.push('<table class="Grid" style="width:100%; border-bottom-width:0px;"><caption style="text-align:left; padding: 1px 4px; background-color: white; border-style:none; font-size 13px;">Struttura Erogante - ' + (testata.SistemaErogante.Sistema.Codice == '???' ? 'Profilo' : testata.SistemaErogante.Azienda.Codice + ' ' + testata.SistemaErogante.Sistema.Codice) + ' <img class="ordineRefresh" src="../Images/refresh.gif" width="14" height="14" /></caption><thead>'
                               + '<th>Numero Ordine</th>'
                               + '<th>Stato O.E.</th>'
                               + '<th>Stato Erogante</th>'
                //+ '<th>Stato Esteso</th>'
                               + '</thead><tbody><tr>'
                               + '<td>' + (testata.IdRichiestaErogante ? testata.IdRichiestaErogante : '-') + '</td>'
                               + '<td>' + (testata.StatoErogante ? testata.StatoErogante.Descrizione : '') + '</td>'
//                             + '<td>' + (testata.StatoErogante ? testata.StatoErogante : '') + '</td>'
                               + '<td>-</td>'
                               + '</tr></tbody></table>');

                html.push('<table class="Grid" style="width:100%;border-collapse:collapse;" border="1" cellspacing="0"><tr><th class="rigaRR" colspan="3">Righe Richiedente</th><th class="gridWhiteSpaceHeader"></th><th colspan="1">Righe Erogante</th></tr><tr>'
                //                               + '<th>Data Inserimento</th>'
                //                               + '<th>Data Modifica</th>'
                //                               + '<th>Data Modifica Stato</th>'
                               + '<th>Codice Prestazione</th>'
                               + '<th>Prestazione</th>'
                               + '<th>Stato O.E.</th>'
                //+ '<th>Dati Aggiuntivi</th>'
                               + '<th class="gridWhiteSpaceHeader"></th>'
                //                               + '<th>Data Inserimento</th>'
                //                               + '<th>Data Modifica</th>'
                //                               + '<th>Data Modifica Stato</th>'
                               + '<th>Stato O.E.</th>'
                //+ '<th>Dati Aggiuntivi</th>'
                               + '</tr><tbody>');

                var prestazioni = [];
                for (var j = 0; j < ordineErogato.Righe.length; j++) {

                    var riga = ordineErogato.Righe[j];

                    var richiedenteColor = getColorForRichiedente(riga.StatoOrderEntryRichiedente);
                    var eroganteColor = getColorForErogante(riga.StatoOrderEntryErogante);

                    var arrowImageUrl = !riga.StatoOrderEntryRichiedente ? '../Images/back.gif' : '../Images/next.gif';

                    if (!prestazioni[riga.PrestazioneCodice]) {

                        prestazioni[riga.PrestazioneCodice] = 1
                    }
                    else {

                        prestazioni[riga.PrestazioneCodice]++;
                    }

                    html.push('<tr class="RigaErogata" prestazione="' + riga.PrestazioneCodice + '">'
                    //                               + '<td style="background-color:' + richiedenteColor + '">' + riga.DataInserimentoRigaRichiesta + '</td>'
                    //                               + '<td style="background-color:' + richiedenteColor + '">' + riga.DataModificaRigaRichiesta + '</td>'
                    //                               + '<td style="background-color:' + richiedenteColor + '">' + riga.DataModificaStatoRigaRichiesta + '</td>'
                               + '<td style="background-color:' + richiedenteColor + '">' + (riga.PrestazioneCodice ? riga.PrestazioneCodice : '') + '</td>'
                               + '<td style="background-color:' + richiedenteColor + '">' + (riga.PrestazioneDescrizione ? HtmlEncode(riga.PrestazioneDescrizione) : '') + '</td>'
                               + '<td style="background-color:' + richiedenteColor + '">' + (riga.StatoOrderEntryRichiedenteDescrizione ? riga.StatoOrderEntryRichiedenteDescrizione : '') + '</td>'
                               + '<td class="gridWhiteSpaceHeader"><img src="' + arrowImageUrl + '" /></td>'
                    //                               + '<td style="background-color:' + eroganteColor + '">' + riga.DataInserimentoRigaErogata + '</td>'
                    //                               + '<td style="background-color:' + eroganteColor + '">' + riga.DataModificaRigaErogata + '</td>'
                    //                               + '<td style="background-color:' + eroganteColor + '">' + riga.DataModificaStatoRigaErogata + '</td>'
                               + '<td style="background-color:' + eroganteColor + '">' + (riga.StatoOrderEntryEroganteDescrizione ? riga.StatoOrderEntryEroganteDescrizione : '') + '</td>'
                               + '</tr>');
                }

                html.push('</tbody></table><br /><br />');
            }

            $("#newGridPanel").html(html.join(""));

            //SetLensVisibility();
            SetColumnToSameWidth();

            $(".ordineRefresh").fadeOut();

            //unisce le righe con prestazione
            for (prestazione in prestazioni) {

                var count = 0;
                $('.RigaErogata[prestazione="' + prestazione + '"]').each(function () {

                    if (count == 0) {
                        //prime 7 righe
                        $(this).find("td:nth-child(-n+7)").each(function () {

                            $(this).attr("rowSpan", prestazioni[prestazione] + "");
                        });
                    }
                    else {

                        $(this).find("td:nth-child(-n+7)").each(function () {

                            $(this).remove();
                        });
                    }

                    count++;
                });
            }
        },
        error: function (error) { alert('Si è verificato un errore'); } //<----cambiare messaggio?
    });

}

function SetColumnToSameWidth() {

    $('.rigaRR').width(Math.max.apply(Math, $('.rigaRR').map(function () { return $(this).width(); }).get()));
}

function getColorForErogante(statusCode) {

    switch (statusCode) {

        case 'CA':

            return '#FA8C8C';
            break;

        case 'CM':

            return '#90EE90';
            break;

        case 'IC':

            return '#63C3FF';
            break;

        case 'IP':

            return '#63C3FF';
            break;


        default:
            return '#D3D3D3';
            break;
    }
}

function getColorForRichiedente(statusCode) {

    switch (statusCode) {

        case 'CA':

            return '#FA8C8C';
            break;

        case 'IS':

            return '#90EE90';
            break;

        case 'MD':

            return '#63C3FF';
            break;

        default:
            return '#D3D3D3';
            break;
    }
}
