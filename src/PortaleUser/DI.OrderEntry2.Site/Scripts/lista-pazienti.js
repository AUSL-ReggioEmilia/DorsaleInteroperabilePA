//$(document).ready(function () {

//    $(".DateInput").datepicker($.datepicker.regional['it'])
//    $(".DateTimeInput").datetimepicker($.datepicker.regional['it']);

//    var mode = $.QueryString["mode"];

//    if (mode == "ricoverati") {

//        $("#pannelloFiltriRicoverati").show();

//        var idStatoEpisodio = GetLastSelectedComboValue("idStatoEpisodio");
//        //preseleziono l'unità operativa usata in precedenza
//        var AziendaUnitaOperativa = GetLastSelectedComboValue("uo");
//        $('#' + _idComboUO).val(AziendaUnitaOperativa);
//        //carico i regimi di ricovero previsti 
//        LoadTipiRicovero(AziendaUnitaOperativa);
//        //preseleziono il regime di ricovero usato in precedenza
//        var tipoRicovero = GetLastSelectedComboValue("tipoRicovero");
//        $('#tipoSelect').val(tipoRicovero);

//        $('#statoEpisodioSelect').val(idStatoEpisodio);
//        var uo = $('#' + _idComboUO + ' option');

//        if (uo.length == 0) {
//            var button = $("#cercaRicoveratiButton");
//            button.attr("disabled", "disabled");
//            $("#pazientiGrigliaDiv").html("<br />Nessuna unità operativa configurata per il ruolo corrente.");
//        }
//        else {
//            LoadPazientiDwh();
//        }
//    }
//    else {
//        $("#pannelloFiltriRicerca").show();
//    }

//    //setListaPazientiDivHeight();

//    setInterval(function () {
//        setListaPazientiDivHeight();
//    }, 5000)
//});

////$(window).resize(function () {
////    setListaPazientiDivHeight();
////});

////function setListaPazientiDivHeight() {
////    var height = $("#mainContainer").height() - $("#wizard").outerHeight(true) - ($("#ErrorSpan").css("display") == 'none' ? 0 : $("#ErrorSpan").outerHeight(true)) - $("#pannelloFiltri").outerHeight(true);
////}

///*
//*OTTIENE LA LISTA DEI REGIMI IN BASE ALLA UNITÀ OPERATIVA SELEZIONATA.
//*SE NON SONO STATE SELEZIONATE UNITÀ OPERATIVE ALLORA MOSTRA TUTTI I REGIMI.
//*/
//function LoadTipiRicovero(AziendaUnitaOperativa) {
//    //OTTINE LA DROPDOWNLIST DEL TIPO DI RICOVERO DEFINITA NEL MARKUP 
//    var tipoSelect = $("#tipoSelect");

//    //DISABILITA LA COMBO. 
//    //IN QUESTO MODO SE SI DOVESSERO VERIFICARE DEGLI ERRORI LA COMBO SAREBBE DISABILITATA.
//    tipoSelect.attr('disabled', 'disabled');
//    $.ajax({
//        type: "POST",
//        url: "AjaxWebMethods/ListaPazientiMethods.aspx/GetLookupTipiRicoveri",
//        data: '{"AziendaUnitaOperativa":"' + AziendaUnitaOperativa + '"}',
//        contentType: "application/json; charset=utf-8",
//        dataType: "json",
//        async: false,
//        success: function (result) {
//            //SVUOTA LA COMBO DEI TIPI RICOVERO.
//            tipoSelect.empty();

//            //CICLA LA LISTA DEI REGIMI OTTENUTA.
//            for (var i in result.d) {
//                //PER OGNI ITEM NELLA LISTA AGGIONGE UN ITEM ALLA DROPDWONLIST.
//                tipoSelect.append("<option value='" + result.d[i].Codice + "'>" + result.d[i].Descrizione + "</option>");
//            }

//            //RIMUOVE L'ATTRIBUTO DISABLED DALLA COMBO
//            tipoSelect.removeAttr('disabled');
//        },
//        error: function (error) { var message = GetMessageFromAjaxError(error.responseText); alert(message); }
//    });
//}

//function GetLastSelectedComboValue(key) {

//    var value = null;

//    $.ajax({
//        type: "POST",
//        url: "AjaxWebMethods/ListaPazientiMethods.aspx/GetLastSelectedComboValue",
//        data: "{'key':'" + key + "'}",
//        contentType: "application/json; charset=utf-8",
//        dataType: "json",
//        async: false,
//        success: function (result) {

//            value = result.d;
//        },
//        error: function (error) { } //<----cambiare messaggio?
//    });

//    return value;
//}

//function SaveLastSelectedComboValue(key, value) {

//    $.ajax({
//        type: "POST",
//        url: "AjaxWebMethods/ListaPazientiMethods.aspx/SaveLastSelectedComboValue",
//        data: "{'key':'" + key + "', 'value':'" + value + "'}",
//        contentType: "application/json; charset=utf-8",
//        dataType: "json",
//        success: function (result) {

//        },
//        error: function (error) { } //<----cambiare messaggio?
//    });
//}

//function GetParametersSac() {

//    var cognome = $('#CognomeTextBox').val();
//    var nome = $('#NomeTextBox').val();
//    var dataNascita = $('#DataNascitaTextBox').val();
//    var luogoNascita = $('#LuogoNascitaTextBox').val();
//    var codiceFiscale = $('#CodiceFiscaleTextBox').val();

//    return '{"cognome":"' + cognome + '", "nome":"' + nome + '", "dataNascita":"' + dataNascita + '", "luogoNascita":"' + luogoNascita + '", "codiceFiscale":"' + codiceFiscale + '"}';
//}

//function GetParametersDwh() {

//    var cognome = $('#CognomeRicoveratiText').val();
//    var uo = $('#' + _idComboUO).val();
//    var tipoRicovero = $('#tipoSelect').val();
//    var idStatoEpisodio = $('#statoEpisodioSelect').val();
//    var nome = $('#NomeRicoveratiText').val();

//    SaveLastSelectedComboValue("uo", uo);
//    SaveLastSelectedComboValue("tipoRicovero", tipoRicovero);
//    SaveLastSelectedComboValue("idStatoEpisodio", idStatoEpisodio);

//    return '{"cognome":"' + cognome + '", "nome":"' + nome + '", "uo":"' + uo + '", "tipoRicovero":"' + tipoRicovero + '","idStatoEpisodio":"' + idStatoEpisodio + '"}';
//}

////METODO USATO PER RICAVARE I PAZIENTI RICOVERATI.
////RICHIAMATO DALLA PAGINA ListaPazienti.aspx
//function LoadPazientiDwh() {

//    //OTTENGO IL DIV DI ERRORE PRESENTE NELLA PAGINA E LO NASCONDE.
//    var errorText = $("#ErrorSpan");
//    errorText.hide();

//    //OTTENGO I PARAMETRI DA PASSARE ALLA CHIAMATA AJAX.
//    var parameters = GetParametersDwh();

//    //OTTENGO TIPORICOVERO E IDSTATOEPISODIO
//    var tipoRicovero = jQuery.parseJSON(parameters).tipoRicovero;
//    var idStatoEpisodio = jQuery.parseJSON(parameters).idStatoEpisodio;
//    var nome = jQuery.parseJSON(parameters).nome;
//    var cognome = jQuery.parseJSON(parameters).cognome;


//    //VALIDAZIONE DEI FILTRI
//    if ((tipoRicovero == "D" || tipoRicovero == "S" || idStatoEpisodio == 3 || idStatoEpisodio == 0) && jQuery.parseJSON(parameters).cognome.length < 2) {

//        errorText.html('Specificare almeno 2 lettere del cognome');
//        errorText.show();
//        $("#PazientiGrid tr").remove();
//        return;
//    };

//    //SE IL NOME È VALORIZZATO...
//    if (nome.length > 0) {
//        // E IL COGNOME NO ALLORA MOSTRO UN MESSAGGIO DI ERRORE.
//        if (cognome.length == 0) {
//            errorText.html('Se il filtro "Nome" è valorizzato allora specificare anche il cognome.');
//            errorText.show();
//            $("#PazientiGrid tr").remove();
//            return;
//        };
//    };

//    //CHIAMATA AJAX PER OTTENERE I DATI.
//    LoadPazienti("AjaxWebMethods/ListaPazientiMethods.aspx/GetPazientiDwh", parameters);
//}

//function LoadPazientiSac() {
//    //Faccio scattare il regular expression validator
//    if (Page_IsValid) {

//        var errorText = $("#ErrorSpan");
//        errorText.hide();
//        var parameters = GetParametersSac()

//        if (jQuery.parseJSON(parameters).cognome.length < 3 && jQuery.parseJSON(parameters).codiceFiscale.length != 16) {

//            errorText.html('Specificare almeno 3 lettere del cognome o il codice fiscale');
//            errorText.show();
//            $("#PazientiGrid tr").remove();
//            return;
//        }

//        LoadPazienti("AjaxWebMethods/ListaPazientiMethods.aspx/GetPazientiSac", parameters);

//    }
//}

//function LoadPazienti(methodName, parameters) {

//    var errorText = $("#ErrorSpan");
//    errorText.hide();
//    //var button = $("#cercaButton, #cercaRicoveratiButton");
//    var button = $("#cercaButton,#cercaRicoveratiButton");
//    button.attr("disabled", "disabled");
//    //button.css("background-image", "url(../Images/refresh.gif)");
//    $(".loader").show();
//    $.ajax({
//        type: "POST",
//        url: methodName,
//        data: parameters,
//        contentType: "application/json; charset=utf-8",
//        dataType: "json",
//        success: function (result) {

//            if (result.d == null) {

//                errorText.html('Nessun Risultato');
//                errorText.show();
//                $(".loader").hide();
//                button.removeAttr("disabled");
//                $("#PazientiGrid tr").remove();
//                return;
//            }

//            if (result.d.length >= 100)
//                alert("La ricerca ha prodotto più di 100 risultati, ne sono stati mostrati solo i primi 100. Si prega di inserire ulteriori parametri di ricerca.");

//            var html = new Array();
//            html.push('<table id="PazientiGrid" class="tablesorter table table-bordered table-hover table-striper table-condensed"><thead>');

//            //headers
//            for (var property in result.d[0]) {

//                if (property == 'Id' || property == 'Nosologico' || property == 'AziendaUO') continue;
//                html.push('<th>' + property.replace(/_/g, ' ') + '</th>');
//            }
//            html.push('</thead><tbody>');

//            //righe
//            for (var i = 0; i < result.d.length; i++) {

//                var riga = result.d[i];

//                if (riga.Nosologico) //azienda e nologico mi arrivano solo dal DWH
//                    html.push('<tr id="' + riga.Id + '" nosologico="' + riga.Nosologico + '" AziendaUO="' + riga.AziendaUO + '" class="SelectableRow">')
//                else
//                    html.push('<tr id="' + riga.Id + '" class="SelectableRow">');

//                //celle
//                for (var rowProperty in riga) {
//                    if (rowProperty == 'Id' || rowProperty == 'Nosologico' || rowProperty == 'AziendaUO') continue;

//                    if (rowProperty == 'Consenso') {
//                        if (riga[rowProperty] == null)
//                            html.push('<td></td>')
//                        else if (riga[rowProperty] == true)
//                            html.push('<td style="text-align:center;"><img src="../Images/ok.png" alt="Sì" title="Sì"/></td>')
//                        else
//                            //Con i Ws2 del dwh veniva restituito se il consenso era negato. Con i ws3 viene restituito l'ultimo consenso espresso positivo.
//                            //Mostro una cella vuota sia che il consenso sia negato che se il consenso sia non espresso.
//                            //html.push('<td style="text-align:center;"><img src="../Images/alert.png" alt="No" title="No" /></td>');
//                            html.push('<td></td>')
//                        continue;
//                    }
//                    html.push('<td>' + riga[rowProperty] + '</td>');
//                }
//                html.push('</tr>');
//            }

//            html.push('</tbody></table>');

//            $("#pazientiGrigliaDiv").html(html.join(""));

//            $("#pazientiGrigliaDiv tr").hover(function () {
//                $(this).addClass("SelectableRowHover");
//            }, function () {
//                $(this).removeClass("SelectableRowHover");
//            });

//            $("#pazientiGrigliaDiv tr").click(function () {


//                var id = $(this).attr('id');
//                var nosologico = $(this).attr('nosologico');
//                var AziendaUO = $(this).attr('AziendaUO');
//                //var azienda = GetLastSelectedComboValue("uo");

//                if (id) {
//                    //se manca il nosologico (paziente letto da sac) passo alla SalvaBozzaRichiesta soltanto l'ID
//                    if (!nosologico) {
//                        nosologico = '';
//                        AziendaUO = '';
//                    }
//                    SalvaBozzaRichiesta(id, nosologico, AziendaUO);
//                }
//            });

//            $("#PazientiGrid").tablesorter();
//            $(".loader").hide();
//            button.removeAttr("disabled");
//        },
//        error: function (error) {

//            $(".loader").hide();
//            button.removeAttr("disabled");
//            var message = GetMessageFromAjaxError(error.responseText);
//            alert(message);
//        }
//    });
//}

//function SalvaBozzaRichiesta(idSac, nosologico, azienda) {

//    $.ajax({
//        type: "POST",
//        url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/SalvaBozzaRichiesta",
//        data: '{"idSac":"' + idSac + '","nosologico":"' + nosologico + '","aziendauo":"' + azienda + '"}',
//        contentType: "application/json; charset=utf-8",
//        dataType: "json",
//        success: function (result) {

//            if (result.d == null) {


//                alert('00 - Si è verificato un errore');
//                return;
//            }
//            else if (result.d == "NoRicovero") {


//                alert('01 - Informazioni di ricovero non trovate');
//                //se non trovo le informazioni di ricovero procedo comunque con la composizione dell'ordine
//                //return;
//            }
//            else if (result.d == "NoUO") {

//                alert('Per il ruolo corrente non sono state configurate le Unità Operative. Contattare l\'amministratore.');
//                return;
//            }

//            var idRichiesta = result.d;
//            var url = "ComposizioneOrdine.aspx?IdPaziente=" + idSac + "&IdRichiesta=" + idRichiesta + (nosologico ? ('&Nosologico=' + nosologico) : '') + (azienda ? ('&AziendaUo=' + azienda) : '');
//            $("body").append("<a id='fakeLink' href='" + url + "' style='display:none;'></a>");
//            $("#fakeLink")[0].click();
//        },
//        error: function (error) {


//            var message = GetMessageFromAjaxError(error.responseText);
//            alert('02 - Si è verificato un errore');
//        }
//    });
//}

