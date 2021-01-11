/*
*VERSIONI:
*   ver 1.0.0: 2017-07-13-SimoneB - Corretto un errore che impediva la visualizzazione dei pdf delle etichette dei dati accessori erogati di testata.
*
*
*
*
*
*/


$(document).ready(function () {

    //$(".DateInput").datepicker({ onSelect: function () { this.fireEvent && this.fireEvent('onchange') || $(this).change(); } });
    //$(".DateTimeInput").datetimepicker({ onSelect: function () { this.fireEvent && this.fireEvent('onchange') || $(this).change(); } });
    //$(".TimeInput").timepicker({ onSelect: function () { this.fireEvent && this.fireEvent('onchange') || $(this).change(); } });

    LoadRichiesta();

    //$('#dettaglioPaziente').load('DettaglioPaziente.aspx?Id=' + $.QueryString["IdPaziente"] + ($.QueryString["Nosologico"] ? '&Nosologico=' + $.QueryString["Nosologico"] : '') + ' #dettaglio', function () {
    //    LoadEsenzioniContainer();
    //    LoadRicoveriContainer();
    //    LoadRefertiContainer();
    //});

    //$(".gridCheckBox").change(function () {

    //    var checked = $(this).attr('checked');

    //    if (checked == 'checked') {

    //        $(this).parent().parent().addClass('GridSelected');

    //    } else {

    //        $(this).parent().parent().removeClass('GridSelected');
    //    }
    //});
});

function LoadRichiesta() {

    var idRichiesta //= $.QueryString['IdRichiesta'];

    //SOLO PER TEST
    idRichiesta = 'b7fae0bb-4470-49da-a7bf-61b5c2b81fae';

    if (!idRichiesta) return;

    $("#loaderGrigliaPrestazioni").show();

    $.ajax({
        type: "POST",
        url: "AjaxWebMethods/RiassuntoOrdineMethods.aspx/GetRichiesta",
        data: "{'id': '" + idRichiesta + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            if (result.d == null) {

                $("#loaderGrigliaPrestazioni").fadeOut();
                alert("L'ordine è inesistente.");
                location.href = "ListaOrdini.aspx";
                return;
            }

            var ordine = result.d;

            $("#IdRichiestaText").html(result.d.Progressivo);

            $("#UOText").html(result.d.UnitaOperativa);
            $("#PrioritaText").html(result.d.Priorita);
            $("#RegimeText").html(result.d.Regime);
            $("#DataPrenotazioneText").html(result.d.DataPrenotazione);


            if (!result.d.Valido) {

                var validationIcon = $("#ValidationError");

                validationIcon.show();
                validationIcon.attr("title", result.d.DescrizioneStatoValidazione);
                validationIcon.addClass("tooltip");
            }

            //Dati Accessori Testata Richiesta
            if (ordine.DatiAccessori != null && ordine.DatiAccessori.length > 0) {

                var html = [];

                html.push('<a type="button" onclick="ShowDatiAccessoriTestata(); return false;" class="infoButton" href="#" title="mostra i dati accessori di testata"><span class="glyphicon glyphicon-info-sign" aria-hidden="true"></a>');
                html.push('<div id="datiAccessoriTestata" style="display:none;"><ul id="datiAccessoriTestataList" class="list-group">');

                for (var j = 0; j < result.d.DatiAccessori.length; j++) {

                    var domanda = result.d.DatiAccessori[j];

                    html.push("<li class='list-group-item'><strong>" + domanda.DatoAccessorio.Etichetta + ":</strong>  " + domanda.ValoreDato + "</li>");
                }

                html.push('</ul></div>');

                $("#datiAccessoriContainer").html(html.join(""));
            }

            LoadPrestazioni(ordine);

            $("#loaderGrigliaPrestazioni").fadeOut();

            if (result.d.Cancellabile) {

                $("#cancellaButton").removeAttr("disabled");
            }
        },
        error: function (error) {

            $("#loaderGrigliaPrestazioni").fadeOut();
            var message = GetMessageFromAjaxError(error.responseText); alert(message);
        }
    });
}

function LoadPrestazioni(ordine) {

    var prestazioni = ordine.Prestazioni
    var html = [];
    var sistemaEroganteCorrente;
    var nomeErogante;
    var DataPrenotazioneErogante;

    if (prestazioni.length > 0) {
        sistemaEroganteCorrente = prestazioni[0].SistemaErogante;
        nomeErogante = prestazioni[0].Tipo > 0 ? 'Profili' : sistemaEroganteCorrente;
        DataPrenotazioneErogante = prestazioni[0].DataPrenotazioneErogante != null ? prestazioni[0].DataPrenotazioneErogante : '-';
    }

    var StatoErogante = '-';
    html.push('<table class="tablesorter table table-bordered table-condensed table-striped"><tbody>');

    for (var i = 0; i < prestazioni.length; i++) {

        var prestazione = prestazioni[i];

        sistemaEroganteCorrente = prestazioni[i].Tipo > 0 ? 'Profili' : prestazione.SistemaErogante;

        if (i == 0 || nomeErogante != sistemaEroganteCorrente) {

            nomeErogante = prestazioni[i].Tipo > 0 ? 'Profili' : sistemaEroganteCorrente;

            html.push('<tr>');
            html.push('<th> <a href="#" onclick="TogglePanel($(this), \'' + nomeErogante + '\'); return false;">'
                + '<img src="../Images/minus.gif" alt="" /></a>' + nomeErogante + ' (stato: ' + StatoErogante + ')</th>');


            // Dati Accessori Testata Erogante
            html.push('<th>');
            if ((prestazione.DatiAccessoriTestataErogato != null && prestazione.DatiAccessoriTestataErogato.length > 0) || (prestazione.DatiPersistentiTestataErogato != null && prestazione.DatiPersistentiTestataErogato.length > 0)) {

                html.push('Dati Accessori: <a type="button" onclick="ShowDatiAccessoriTestataErogato(\'' + sistemaEroganteCorrente + '\'); return false;" class="infoButton" href="#" title="mostra i dati accessori restituiti dal sistema erogante"><span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span></a>');
                // POP-UP con i dati accessori del sistema erogante:
                html.push('<div id="datiAccessoriTestataErogato_' + sistemaEroganteCorrente + '" style="display:none;">');
                html.push('<div class="row"><div class="form-horizontal col-sm-12" id="datiAccessoriTestataErogato_List_' + sistemaEroganteCorrente + '">');
                html.push("<div class='form-group form-group-sm'><label class='col-sm-6 control-label'>" + "Erogante: " + "</label><div class='col-sm-6'> <p class='form-control-static'></div>");

                //Dati Persistenti 
                if (prestazione.DatiPersistentiTestataErogato != null && prestazione.DatiPersistentiTestataErogato.length > 0) {
                    var datiPersistentiTestataErogato = prestazione.DatiPersistentiTestataErogato[0];
                    for (var z = 0; z < datiPersistentiTestataErogato.length; z++) {
                        var domandaTestataErogato = datiPersistentiTestataErogato[z];
                        if (domandaTestataErogato.DatoAccessorio != null) {
                            if (domandaTestataErogato.TipoContenuto = "PDF") {
                                /*
                                *COSTRUISCE IL BOTTONE (CONTENUTO NELL'ELENCO DEI DATI ACCESSORI EROGATI DI TESTATA) USATO PER VISUALIZZARE IL PDF DELLE ETICHETTE
                                */
                                html.push("<div class='form-group form-group-sm'><label class='col-sm-6 control-label'>" + domandaTestataErogato.DatoAccessorio.Etichetta + "</label>");
                                //OTTENGO IL PDF
                                pdfvalue = domandaTestataErogato.ValoreDato
                                //CREO IL BOTTONE E IL SUO EVENTO ONCLICK USATO PER APRIRE IL PDF.
                                html.push('<div class="col-sm-6"><a type="button" class="pdfButton" alt="clicca per vedere il documento" href="#"  onclick="sendByPost(\'' + pdfvalue + '\');return false;" pdfvalue="' + pdfvalue + '"><span class="glyphicon glyphicon-file" aria-hidden="true"></span></a></div></div>');
                                //html.push("</li>");
                            }
                            else {
                                html.push("<div class='form-group form-group-sm'><label class='col-sm-6 control-label'>" + domandaTestataErogato.DatoAccessorio.Etichetta + "</label><div class='col-sm-6'> <p class='form-control-static'> " + domandaTestataErogato.ValoreDato + "</p></div></div>");
                            }
                        }
                    }
                }

                
                //*ATTENZIONE
                //*NON CANCELLARE IL SEGUENTE CODICE.
                //*SERVE PER TESTARE IL BOTTONE PER VISUALIZZARE IL PDF DELLE ETICCHETTE DEI DATI ACCESSORI EROGATI DI TESTATA.
                //*UTILIZZARE IL PAZIENTE "REGGIANI ANNAMARIA".
                //html.push("<li class='list-group-item'><b>PDF</b>: ");
                //pdfvalue = "JVBERi0xLjMKJaqrrK0KNCAwIG9iago8PCAvVHlwZSAvSW5mbwovUHJvZHVjZXIgKG51bGwpID4+ CmVuZG9iago1IDAgb2JqCjw8IC9MZW5ndGggMTczIC9GaWx0ZXIgL0ZsYXRlRGVjb2RlIAogPj4K c3RyZWFtCnicdY89D4JADIb3+xUdcTjoB+CdGxIwGmXQczIOhETj4KT/P3IJeMSPdmja9Hn7dulU UguYGMFdFPrSKYSrIsA+CYhiEQO5ja1lcHc4RdtiBprnnolWx926mfT1vmjK6lD2ozO4zZcMBpmm fXS3Z7tA0ZhqsmIHJqlpNPSBZxRw9JFyjvkbkz9YygEj1v1BkmB5KjTOjCX8/YFI0GIk8WyGwtmw Xjn1Au3URWIKZW5kc3RyZWFtCmVuZG9iago2IDAgb2JqCjw8IC9UeXBlIC9QYWdlCi9QYXJlbnQg MSAwIFIKL01lZGlhQm94IFsgMCAwIDE1MyA3OSBdCi9SZXNvdXJjZXMgMyAwIFIKL0NvbnRlbnRz IDUgMCBSCj4+CmVuZG9iago3IDAgb2JqCjw8IC9MZW5ndGggNzYwIC9GaWx0ZXIgL0ZsYXRlRGVj b2RlIAogPj4Kc3RyZWFtCnic7VpNb9swDL3rV+jYHaJJlKyPY1ukxYatwDYPOww7Deh6iAf0uH8/ yfqwLWGXgQbSRg0K8DE0+fLIhBaSm5EcR/LsH3Jg2ilqBmalphMRoNeOU3Go7EhXFPxEvpHfRDBO w+MQjG3SnxMBZrlT1po5ZoWYNDBYq73Xhz2T8PREJDABgzdP2RScaWNF8PAt4IUCp7/8/z0Z5hwD SxlmI17CXcBbEK9/JJ+wqrNc3+T6ZluSNRCbg55z6KyArhTQW4BePSmgswK6UkCzBmJzMHMOw3RK Ea1VUbMF2PVt1H7yhk0qRGtV1VZtsblfmERcaobLzXBVMxxrIDYHEZP4qJQjWquqglcIn0LSwRum kDAVCdZidCIi0hBlNJO5LiwqhE4C8nh6K89nMteVoW4T7DGiQubeyNIbWfdGshajE1GRhipzqmoB VIXwKWQtVNFC1Voo1mJ0IonGsMzp0MxpjdBJ6DKneplT3cxpveCE3mVOTbp6CqbMdKK5rm5Wqdce dEI2kimLQ9QrxUdsET6FPK+upEnmpjBrMTqVtOL83WZ8GrZLpV58oqxETBbA0xsm0Cgzm8xV9RTX etAJiTK13sx8RCVGimo96HQgUimbBOol4yO2CJ9CmllvmEKi0gNYi9GJyPQp4qnEVQKb/ZKebz3o RNQytOXcBPXBKUW1HnQ6+QwF5RAF9SkKqmMU7HGOgniQCifgLIpuNNAVwieRPkY8kWWPQLNkoNmL sCxN5K3MNyJMratx/OkxZxTz1JvYRbvImN7ELtplxvQmdtEuM6Y3sYt2mTG9ibuJdnrhLtxXiZnt BYzI2cd0WXeS9b8H/dxeSo+5iJh+B9CF7TG9iedwf/wCXluPeX0x/U2+m7DhS+XwuBnJ2ztBLeN0 fJy/KA4/WuRUUCGYlJZKyyTQcaLfrz5cv6EHMCH26v7rx3cPK3z3+frh9vjl1rt+0PF9nQVcySLg wOVyoXWCL4jLA1cH4aT7Rx5e8vDwp0BznUKPI/kLDLAjiQplbmRzdHJlYW0KZW5kb2JqCjggMCBv YmoKPDwgL1R5cGUgL1BhZ2UKL1BhcmVudCAxIDAgUgovTWVkaWFCb3ggWyAwIDAgMTUzIDc5IF0K L1Jlc291cmNlcyAzIDAgUgovQ29udGVudHMgNyAwIFIKPj4KZW5kb2JqCjkgMCBvYmoKPDwgL0xl bmd0aCA3NjAgL0ZpbHRlciAvRmxhdGVEZWNvZGUgCiA+PgpzdHJlYW0KeJztWk1v2zAMvetX6Ngd okmUrI9jW6TFhq3ANg87DDsN6HqIB/S4fz/J+rAtYZeBBtJGDQrwMTT58siEFpKbkRxH8uwfcmDa KWoGZqWmExGg145TcajsSFcU/ES+kd9EME7D4xCMbdKfEwFmuVPWmjlmhZg0MFirvdeHPZPw9EQk MAGDN0/ZFJxpY0Xw8C3ghQKnv/z/PRnmHANLGWYjXsJdwFsQr38kn7Cqs1zf5PpmW5I1EJuDnnPo rICuFNBbgF49KaCzArpSQLMGYnMwcw7DdEoRrVVRswXY9W3UfvKGTSpEa1XVVm2xuV+YRFxqhsvN cFUzHGsgNgcRk/iolCNaq6qCVwifQtLBG6aQMBUJ1mJ0IiLSEGU0k7kuLCqETgLyeHorz2cy15Wh bhPsMaJC5t7I0htZ90ayFqMTUZGGKnOqagFUhfApZC1U0ULVWijWYnQiicawzOnQzGmN0EnoMqd6 mVPdzGm94ITeZU5NunoKpsx0ormublap1x50QjaSKYtD1CvFR2wRPoU8r66kSeamMGsxOpW04vzd ZnwatkulXnyirERMFsDTGybQKDObzFX1FNd60AmJMrXezHxEJUaKaj3odCBSKZsE6iXjI7YIn0Ka WW+YQqLSA1iL0YnI9CniqcRVApv9kp5vPehE1DK05dwE9cEpRbUedDr5DAXlEAX1KQqqYxTscY6C eJAKJ+Asim400BXCJ5E+RjyRZY9As2Sg2YuwLE3krcw3Ikytq3H86TFnFPPUm9hFu8iY3sQu2mXG 9CZ20S4zpjexi3aZMb2Ju4l2euEu3FeJme0FjMjZx3RZd5L1vwf93F5Kj7mImH4H0IXtMb2J53B/ /AJeW495fTH9Tb6bsOFL5fC4GcnbO0Et43R8nL8oDj9a5FRQIZiUlkrLJNBxot+vPly/oQcwIfbq /uvHdw8rfPf5+uH2+OXWu37Q8X2dBVzJIuDA5XKhdYIviMsDVwfhpPtHHl7y8PCnQHOdQo8j+QsM sCOJCmVuZHN0cmVhbQplbmRvYmoKMTAgMCBvYmoKPDwgL1R5cGUgL1BhZ2UKL1BhcmVudCAxIDAg UgovTWVkaWFCb3ggWyAwIDAgMTUzIDc5IF0KL1Jlc291cmNlcyAzIDAgUgovQ29udGVudHMgOSAw IFIKPj4KZW5kb2JqCjExIDAgb2JqCjw8IC9MZW5ndGggNzYwIC9GaWx0ZXIgL0ZsYXRlRGVjb2Rl IAogPj4Kc3RyZWFtCnic7VpNb9swDL3rV+jYHaJJlKyPY1ukxYatwDYPOww7Deh6iAf0uH8/yfqw LWGXgQbSRg0K8DE0+fLIhBaSm5EcR/LsH3Jg2ilqBmalphMRoNeOU3Go7EhXFPxEvpHfRDBOw+MQ jG3SnxMBZrlT1po5ZoWYNDBYq73Xhz2T8PREJDABgzdP2RScaWNF8PAt4IUCp7/8/z0Z5hwDSxlm I17CXcBbEK9/JJ+wqrNc3+T6ZluSNRCbg55z6KyArhTQW4BePSmgswK6UkCzBmJzMHMOw3RKEa1V UbMF2PVt1H7yhk0qRGtV1VZtsblfmERcaobLzXBVMxxrIDYHEZP4qJQjWquqglcIn0LSwRumkDAV CdZidCIi0hBlNJO5LiwqhE4C8nh6K89nMteVoW4T7DGiQubeyNIbWfdGshajE1GRhipzqmoBVIXw KWQtVNFC1Voo1mJ0IonGsMzp0MxpjdBJ6DKneplT3cxpveCE3mVOTbp6CqbMdKK5rm5WqdcedEI2 kimLQ9QrxUdsET6FPK+upEnmpjBrMTqVtOL83WZ8GrZLpV58oqxETBbA0xsm0Cgzm8xV9RTXetAJ iTK13sx8RCVGimo96HQgUimbBOol4yO2CJ9CmllvmEKi0gNYi9GJyPQp4qnEVQKb/ZKebz3oRNQy tOXcBPXBKUW1HnQ6+QwF5RAF9SkKqmMU7HGOgniQCifgLIpuNNAVwieRPkY8kWWPQLNkoNmLsCxN 5K3MNyJMratx/OkxZxTz1JvYRbvImN7ELtplxvQmdtEuM6Y3sYt2mTG9ibuJdnrhLtxXiZntBYzI 2cd0WXeS9b8H/dxeSo+5iJh+B9CF7TG9iedwf/wCXluPeX0x/U2+m7DhS+XwuBnJ2ztBLeN0fJy/ KA4/WuRUUCGYlJZKyyTQcaLfrz5cv6EHMCH26v7rx3cPK3z3+frh9vjl1rt+0PF9nQVcySLgwOVy oXWCL4jLA1cH4aT7Rx5e8vDwp0BznUKPI/kLDLAjiQplbmRzdHJlYW0KZW5kb2JqCjEyIDAgb2Jq Cjw8IC9UeXBlIC9QYWdlCi9QYXJlbnQgMSAwIFIKL01lZGlhQm94IFsgMCAwIDE1MyA3OSBdCi9S ZXNvdXJjZXMgMyAwIFIKL0NvbnRlbnRzIDExIDAgUgo+PgplbmRvYmoKMTMgMCBvYmoKPDwgL0xl bmd0aCA3NjAgL0ZpbHRlciAvRmxhdGVEZWNvZGUgCiA+PgpzdHJlYW0KeJztWk1v2zAMvetX6Ngd okmUrI9jW6TFhq3ANg87DDsN6HqIB/S4fz/J+rAtYZeBBtJGDQrwMTT58siEFpKbkRxH8uwfcmDa KWoGZqWmExGg145TcajsSFcU/ES+kd9EME7D4xCMbdKfEwFmuVPWmjlmhZg0MFirvdeHPZPw9EQk MAGDN0/ZFJxpY0Xw8C3ghQKnv/z/PRnmHANLGWYjXsJdwFsQr38kn7Cqs1zf5PpmW5I1EJuDnnPo rICuFNBbgF49KaCzArpSQLMGYnMwcw7DdEoRrVVRswXY9W3UfvKGTSpEa1XVVm2xuV+YRFxqhsvN cFUzHGsgNgcRk/iolCNaq6qCVwifQtLBG6aQMBUJ1mJ0IiLSEGU0k7kuLCqETgLyeHorz2cy15Wh bhPsMaJC5t7I0htZ90ayFqMTUZGGKnOqagFUhfApZC1U0ULVWijWYnQiicawzOnQzGmN0EnoMqd6 mVPdzGm94ITeZU5NunoKpsx0ormublap1x50QjaSKYtD1CvFR2wRPoU8r66kSeamMGsxOpW04vzd ZnwatkulXnyirERMFsDTGybQKDObzFX1FNd60AmJMrXezHxEJUaKaj3odCBSKZsE6iXjI7YIn0Ka WW+YQqLSA1iL0YnI9CniqcRVApv9kp5vPehE1DK05dwE9cEpRbUedDr5DAXlEAX1KQqqYxTscY6C eJAKJ+Asim400BXCJ5E+RjyRZY9As2Sg2YuwLE3krcw3Ikytq3H86TFnFPPUm9hFu8iY3sQu2mXG 9CZ20S4zpjexi3aZMb2Ju4l2euEu3FeJme0FjMjZx3RZd5L1vwf93F5Kj7mImH4H0IXtMb2J53B/ /AJeW495fTH9Tb6bsOFL5fC4GcnbO0Et43R8nL8oDj9a5FRQIZiUlkrLJNBxot+vPly/oQcwIfbq /uvHdw8rfPf5+uH2+OXWu37Q8X2dBVzJIuDA5XKhdYIviMsDVwfhpPtHHl7y8PCnQHOdQo8j+QsM sCOJCmVuZHN0cmVhbQplbmRvYmoKMTQgMCBvYmoKPDwgL1R5cGUgL1BhZ2UKL1BhcmVudCAxIDAg UgovTWVkaWFCb3ggWyAwIDAgMTUzIDc5IF0KL1Jlc291cmNlcyAzIDAgUgovQ29udGVudHMgMTMg MCBSCj4+CmVuZG9iagoxNSAwIG9iago8PCAvTGVuZ3RoIDc2MCAvRmlsdGVyIC9GbGF0ZURlY29k ZSAKID4+CnN0cmVhbQp4nO1aTW/bMAy961fo2B2iSZSsj2NbpMWGrcA2DzsMOw3oeogH9Lh/P8n6 sC1hl4EG0kYNCvAxNPnyyIQWkpuRHEfy7B9yYNopagZmpaYTEaDXjlNxqOxIVxT8RL6R30QwTsPj EIxt0p8TAWa5U9aaOWaFmDQwWKu914c9k/D0RCQwAYM3T9kUnGljRfDwLeCFAqe//P89GeYcA0sZ ZiNewl3AWxCvfySfsKqzXN/k+mZbkjUQm4Oec+isgK4U0FuAXj0poLMCulJAswZiczBzDsN0ShGt VVGzBdj1bdR+8oZNKkRrVdVWbbG5X5hEXGqGy81wVTMcayA2BxGT+KiUI1qrqoJXCJ9C0sEbppAw FQnWYnQiItIQZTSTuS4sKoROAvJ4eivPZzLXlaFuE+wxokLm3sjSG1n3RrIWoxNRkYYqc6pqAVSF 8ClkLVTRQtVaKNZidCKJxrDM6dDMaY3QSegyp3qZU93Mab3ghN5lTk26egqmzHSiua5uVqnXHnRC NpIpi0PUK8VHbBE+hTyvrqRJ5qYwazE6lbTi/N1mfBq2S6VefKKsREwWwNMbJtAoM5vMVfUU13rQ CYkytd7MfEQlRopqPeh0IFIpmwTqJeMjtgifQppZb5hCotIDWIvRicj0KeKpxFUCm/2Snm896ETU MrTl3AT1wSlFtR50OvkMBeUQBfUpCqpjFOxxjoJ4kAon4CyKbjTQFcInkT5GPJFlj0CzZKDZi7As TeStzDciTK2rcfzpMWcU89Sb2EW7yJjexC7aZcb0JnbRLjOmN7GLdpkxvYm7iXZ64S7cV4mZ7QWM yNnHdFl3kvW/B/3cXkqPuYiYfgfQhe0xvYnncH/8Al5bj3l9Mf1Nvpuw4Uvl8LgZyds7QS3jdHyc vygOP1rkVFAhmJSWSssk0HGi368+XL+hBzAh9ur+68d3Dyt89/n64fb45da7ftDxfZ0FXMki4MDl cqF1gi+IywNXB+Gk+0ceXvLw8KdAc51CjyP5CwywI4kKZW5kc3RyZWFtCmVuZG9iagoxNiAwIG9i ago8PCAvVHlwZSAvUGFnZQovUGFyZW50IDEgMCBSCi9NZWRpYUJveCBbIDAgMCAxNTMgNzkgXQov UmVzb3VyY2VzIDMgMCBSCi9Db250ZW50cyAxNSAwIFIKPj4KZW5kb2JqCjE3IDAgb2JqCjw8IC9U eXBlIC9Gb250Ci9TdWJ0eXBlIC9UeXBlMQovTmFtZSAvRjMKL0Jhc2VGb250IC9IZWx2ZXRpY2Et Qm9sZAovRW5jb2RpbmcgL1dpbkFuc2lFbmNvZGluZyA+PgplbmRvYmoKMTggMCBvYmoKPDwgL1R5 cGUgL0ZvbnQKL1N1YnR5cGUgL1R5cGUxCi9OYW1lIC9GMQovQmFzZUZvbnQgL0hlbHZldGljYQov RW5jb2RpbmcgL1dpbkFuc2lFbmNvZGluZyA+PgplbmRvYmoKMSAwIG9iago8PCAvVHlwZSAvUGFn ZXMKL0NvdW50IDYKL0tpZHMgWzYgMCBSIDggMCBSIDEwIDAgUiAxMiAwIFIgMTQgMCBSIDE2IDAg UiBdID4+CmVuZG9iagoyIDAgb2JqCjw8IC9UeXBlIC9DYXRhbG9nCi9QYWdlcyAxIDAgUgogPj4K ZW5kb2JqCjMgMCBvYmoKPDwgCi9Gb250IDw8IC9GMyAxNyAwIFIgL0YxIDE4IDAgUiA+PiAKL1By b2NTZXQgWyAvUERGIC9JbWFnZUMgL1RleHQgXSA+PiAKZW5kb2JqCnhyZWYKMCAxOQowMDAwMDAw MDAwIDY1NTM1IGYgCjAwMDAwMDUzMzcgMDAwMDAgbiAKMDAwMDAwNTQyOSAwMDAwMCBuIAowMDAw MDA1NDc5IDAwMDAwIG4gCjAwMDAwMDAwMTUgMDAwMDAgbiAKMDAwMDAwMDA2NSAwMDAwMCBuIAow MDAwMDAwMzExIDAwMDAwIG4gCjAwMDAwMDA0MTYgMDAwMDAgbiAKMDAwMDAwMTI0OSAwMDAwMCBu IAowMDAwMDAxMzU0IDAwMDAwIG4gCjAwMDAwMDIxODcgMDAwMDAgbiAKMDAwMDAwMjI5MyAwMDAw MCBuIAowMDAwMDAzMTI3IDAwMDAwIG4gCjAwMDAwMDMyMzQgMDAwMDAgbiAKMDAwMDAwNDA2OCAw MDAwMCBuIAowMDAwMDA0MTc1IDAwMDAwIG4gCjAwMDAwMDUwMDkgMDAwMDAgbiAKMDAwMDAwNTEx NiAwMDAwMCBuIAowMDAwMDA1MjI5IDAwMDAwIG4gCnRyYWlsZXIKPDwKL1NpemUgMTkKL1Jvb3Qg MiAwIFIKL0luZm8gNCAwIFIKPj4Kc3RhcnR4cmVmCjU1NjkKJSVFT0YK"
                //html.push('<a type="button" class="pdfButton" alt="clicca per vedere il documento" href="#"  onclick="sendByPost(\'' + pdfvalue + '\');return false;" pdfvalue="' + pdfvalue + '"><span class="glyphicon glyphicon-file" aria-hidden="true"></span></a>');
                //html.push("</li>"); 
                


                //Dati Accessori
                if (prestazione.DatiAccessoriTestataErogato != null && prestazione.DatiAccessoriTestataErogato.length > 0) {
                    var datiAccessoriTestataErogato = prestazione.DatiAccessoriTestataErogato[0];
                    for (var z = 0; z < datiAccessoriTestataErogato.length; z++) {
                        var domandaTestataErogato = datiAccessoriTestataErogato[z];
                        if (domandaTestataErogato.DatoAccessorio != null) {
                            html.push("<div class='form-group form-group-sm'><label class='col-sm-6 control-label'>" + domandaTestataErogato.DatoAccessorio.Etichetta + "</label><div class='col-sm-6'> <p class='form-control-static'>" + domandaTestataErogato.ValoreDato + "</p></div></div>");
                        }
                    }
                }
                html.push('</div></div></div>');
                // --- fine POP-UP con i dati accessori del sistema erogante
            }

            html.push('</th>');
            html.push('<th colspan="4">Data Prenotazione: ' + DataPrenotazioneErogante + '</th></tr>');

            // SECONDA RIGA DI INTESTAZIONE:
            html.push('<tr class="rowHide' + nomeErogante + '">'
                + '<th>Codice</th>'
                + '<th>Descrizione</th>'
                + '<th>Dati accessori</th>'
                + '<th>Stato erogante</th>'
                + '<th>Data Pianificata</th>'
                + '</tr>');

        }

        var color = (prestazione.SoloErogato ? 'active' : getColorForErogante(prestazione.CodiceStatoErogante));

        html.push('<tr class="rowHide' + nomeErogante + " " + color + '">'
            + '<td>' + prestazione.Codice + '</td>'
            + '<td>' + prestazione.Descrizione + '</td>'
            + '<td>');

        // Dati Accessori Prestazione Richiesta
        if ((prestazione.DatiAccessoriRichiesta != null && prestazione.DatiAccessoriRichiesta.length > 0) || (prestazione.DatiAccessoriErogato != null && prestazione.DatiAccessoriErogato.length > 0)) {

            html.push('<a type="button" onclick="ShowDatiAccessori(\'' + prestazione.Codice + '\'); return false;" class="infoButton" href="#" title="mostra i dati accessori della prestazione"><span class="glyphicon glyphicon-info-sign" aria-hidden="true"></a>');

            html.push('<div id="datiAccessori_' + prestazione.Codice + '" style="display:none;"><ul id="datiAccessoriList_' + prestazione.Codice + '" class="list-group">');

            // Dati Accessori Prestazione Richiesta
            if (prestazione.DatiAccessoriRichiesta != null && prestazione.DatiAccessoriRichiesta.length > 0) {

                html.push("<li class='list-group-item'><b>" + "Richiedente: " + "</b></li>");

                for (var j = 0; j < prestazione.DatiAccessoriRichiesta.length; j++) {
                    var domandaRichiesta = prestazione.DatiAccessoriRichiesta[j];
                    if (domandaRichiesta.DatoAccessorio != null) {
                        html.push("<li class='list-group-item'><b>" + domandaRichiesta.DatoAccessorio.Etichetta + "</b>: " + domandaRichiesta.ValoreDato + "</li>");
                    }
                }
            }

            // Dati Accessori Prestazione Erogata
            if (prestazione.DatiAccessoriErogato != null && prestazione.DatiAccessoriErogato.length > 0) {

                html.push("<li class='list-group-item'><b>" + "Erogante: " + "</b></li>");

                for (var y = 0; y < prestazione.DatiAccessoriErogato.length; y++) {
                    var domandaErogato = prestazione.DatiAccessoriErogato[y];
                    if ((typeof (domandaErogato) != "undefined") && (domandaErogato != null) && (domandaErogato[0] != null) && (domandaErogato[0].DatoAccessorio != null)) {
                        html.push("<li class='list-group-item'><b>" + domandaErogato[0].DatoAccessorio.Etichetta + "</b>: " + domandaErogato[0].ValoreDato + "</li>");
                    }
                    else {

                    }

                }

            }

            html.push('</ul></div>');
        }

        //

        html.push('</td>');

        var statoErogante = '';

        if (!prestazione.StatoErogante || prestazione.StatoErogante == null) {
            if (!prestazione.DescrizioneOperazioneRigaRichiesta || prestazione.DescrizioneOperazioneRigaRichiesta == null) { }
            else {
                statoErogante = prestazione.DescrizioneOperazioneRigaRichiesta;
            }
        }
        else {
            statoErogante = prestazione.StatoErogante;
        }

        html.push('<td>' + statoErogante + '</td>');

        var DataPianificata = prestazione.DataPianificata != null ? formatJSONDate(prestazione.DataPianificata) : '-';
        html.push('<td>' + DataPianificata + '</td>');

        html.push('</tr>');
    }

    html.push('</tbody></table>');

    $("#richiestaDiv").html(html.join(""));

    $("#datiAccessoriDiv").show();

    SetupPopup();

    //acrrocc per hover in IE
    $(".infoButton").hover(function () {
        $(this).addClass("inputHover");
    }, function () {
        $(this).removeClass("inputHover");
    });
}

function LoadDatiAccessori(ordine) {

    var html = [];

    for (var i = 0; i < ordine.DatiAccessori.length; i++) {
        var dato = ordine.DatiAccessori[i];
        html.push("<tr><td>" + dato.DatoAccessorio.Etichetta + "</td><td>" + dato.ValoreDato.replace('§;', ', ') + "</td></tr>");
    }
    html.push("<tr><td colspan=2>Etichette</td></tr>");
    for (var j = 0; j < ordine.DatiPersistenti.length; j++) {
        var etichetta = ordine.DatiPersistenti[j];
        html.push("<tr><td>" + etichetta.DatoAccessorio.Descrizione + "</td><td>" + etichetta.ValoreDato + "</td></tr>");
    }
    $("#datiAccessoriTable tbody").html(html.join(""));
}

function TogglePanel(link, sistemaErogante) {
    var rows = $('.rowHide' + sistemaErogante)
    if (rows.css('display') == 'none') {
        link.find('img').attr('src', '../Images/minus.gif')
        rows.show();
    }
    else {
        link.find('img').attr('src', '../Images/new.gif')
        rows.hide();
    }
}

function getColorForErogante(statusCode) {
    // Restituisce il colore applicato alla riga della tabella di riepilogo in base a StatusCode
    // Il colore viene applicato con una classe css Bootstrap.
    switch (statusCode) {

        case 'CA':

            return 'danger';
            break;

        case 'CM':

            return 'success';
            break;

        case 'IC':
        case 'IP':

            return 'info';
            break;


        default:
            return 'success';
            break;
    }
}

/*
*   METODO USATO DAI BOTTONI (CONTENUTI NELLA MODALE DEI DATI ACCESSORI EROGATI DI TESTATA) PER RENDERIZZARE I PDF DELLE ETICHETTE.
*/
function sendByPost(base64) {
    /*
    *1)GLI VIENE PASSAYO IL BASE64 DEL PDF DA VISUALIZZARE.
    *2)APRE UN'ALTRA TAB DEL BROWSER PER VISUALIZZARE IL PDF.
    */
    $.ajax({
        type: "POST",
        url: "AjaxWebMethods/RiassuntoOrdineMethods.aspx/SaveBase64AndGetId",
        data: "{base64:'" + base64 + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            if (base64 && base64 != '')
                window.open('PdfViewer.aspx?id=' + encodeURIComponent(result.d));
            else
                alert("File non trovato.")
        },
        error: function (error) {

            var message = GetMessageFromAjaxError(error.responseText);
            alert(message);
        }
    });
}

/*
* Codice relativo alla gestione delle modali Bootstrap contenute nella pagina RiassuntoOrdine.aspx
*/

function ShowDatiAccessoriTestataErogato(sistemaErogante) {
    // Il codice html della modale viene definito all'inteno del Markup della pagina aspx.
    // Elimino il contenuto e il titolo della modale.
    $(".modal-body").empty();
    $("#myModalLabel").empty();

    //  $('#datiAccessoriTestataErogato_' + sistemaErogante); ---> codice html generato nel codice JS al momento della creazione della tabella. Si trova all'interno del <th> dei Dati Accessori.
    var popup = $('#datiAccessoriTestataErogato_' + sistemaErogante);

    //Aggiungo alla modale il codice html cotenuto dentro la variabile popup.
    $("#modalBody").append(popup.html());

    // Modifico il titolo della modale.
    $("#myModalLabel").html("Dati accessori prestazione " + sistemaErogante);

    // Mostro la modale.
    $('#myModal').modal('show');
}

function ShowDatiAccessori(codicePrestazione) {
    // Codice per visualizzare la modale dei DatiAccessori in stile Bootstrap. 
    // Il codice html della modale viene definito all'inteno del Markup della pagina aspx.
    // Elimino il contenuto e il titolo della modale.
    $(".modal-body").empty();
    $("#myModalLabel").empty();

    // Inserisco nel body della modale il contenuto di datiAccessori_codicePrestazione.
    $("#modalBody").append($('#datiAccessori_' + codicePrestazione).html());

    // Inserisco il titolo della modale.
    $("#myModalLabel").html("Dati accessori prestazione " + codicePrestazione);

    // Mostro la modale.
    $('#myModal').modal('show');
}

function ShowDatiAccessoriTestata() {
    // Codice per visualizzare la modale dei DatiAccessori in stile Bootstrap. 
    // Il codice html della modale viene definito all'inteno del Markup della pagina aspx.
    // Elimino il contenuto e il titolo della modale.
    $(".modal-body").empty();
    $("#myModalLabel").empty();

    // Inserisco nel body della modale il contenuto di datiAccessoriTestata(ul contenente tutte le informazione dei dati accessori).
    $("#modalBody").append($('#datiAccessoriTestata').html());

    // Inserisco il titolo della modale.
    $("#myModalLabel").html("Dati accessori ordine");

    // Mostro la modale
    $('#myModal').modal('show');
}