////$(document).ready(function () {
//$(document).ready(function () {
//	// When any checkbox is checked

//	$("#chkboxPrestazioniPerProfiloMaster").click(function () {
//		var checked = document.getElementById('chkboxPrestazioniPerProfiloMaster').checked;
//		$(this).closest('div').find('input:checkbox').not(this).prop('checked', this.checked);
//	});

//	$("#chkboxPrestazioniPrestazioniMaster").click(function () {
//		var checked = document.getElementById('chkboxPrestazioniPoMaster').checked;
//		$(this).closest('div').find('input:checkbox').not(this).prop('checked', this.checked);
//	});

//		});

////    $('body').css('overflow', 'hidden');

////	/*LoadSistemiEroganti();*/

//// //   CaricaProfili();
//// //   CercaPrestazioni();

////	//SetupHeights();
////});


////$(window).resize(function () {
////    SetupHeights();
////});

//////
//////Funzione eseguita al click sul pulsante "aggiungi".
//////Apre la modale, sbianca la textbox della descrizione e nasconde il form-group del codice (perchè non serve in inserimento).
//////
////function OpenModalAggingiProfilo() {
////    //Sbianca le textbox
////    $('#txtDescrizioneProfilo').val('');
////    //sbianca l'hidden filed usato per salvare l'id del profilo corrente (Siamo in inserimento, quindi l'id del profilo non c'è)
////    $("#hdIdProfiloDaModificare").val('');
////    //cambio il titolo della modale.
////    $("#modalProfiloTitle").text("Crea un nuovo profilo");
////    //Nascondo il form-group contenente il codice del profilo.
////    $('#rowCodiceProfilo').hide();
////    //Mostro la modale.
////    $('#modalAggiungiProfilo').modal('show');
////}

//////Funzione che apre la modale di modifica di un profilo.
////function OpenModalModificaProfilo(idProfilo) {
////    // Dal profilo selezionato ottengo il codice e la descrizione.
////    var codice = $("#Profili .selectedLinkProfili").attr('codice');
////    var descrizione = $("#Profili .selectedLinkProfili").attr('descrizione');
////    // Ottengo la Textbox per il codice contenuta all'interno della modale Bootstrap.
////    $("#pCodiceProfilo").text(codice);
////    $("#txtDescrizioneProfilo").val(descrizione);
////    $("#hdIdProfiloDaModificare").val(idProfilo);
////    // Modifico il titolo della modale.
////    $("#myModalLabel").empty();
////    $("#myModalLabel").html("Modifica profilo");

////    //mostro il form-group contenente il codice del profilo.
////    $('#rowCodiceProfilo').show();

////    //Imposto il titolo della modale.
////    $("#modalProfiloTitle").html("Modifica il profilo <strong>" + descrizione + "</strong>");
////    //mostro la modale.
////    $("#modalAggiungiProfilo").modal("show");
////}

////function LoadSistemiEroganti() {

////    var sistemaSelect = $("#sistemiEroganti");

////    sistemaSelect.attr('disabled', 'disabled');
	
////    $.ajax({
////        type: "POST",
////        url: "AjaxWebMethods/ProfiliUtenteMethods.aspx/GetLookupSistemiEroganti",
////        data: "{}",
////        contentType: "application/json; charset=utf-8",
////        dataType: "json",
////        async: false,
////        success: function (result) {

////            for (var sistema in result.d) {

////                sistemaSelect.append("<option value='" + sistema + "'>" + result.d[sistema] + "</option>");
////            }

////            sistemaSelect.removeAttr('disabled');
////        },
////        error: function (error) { var message = GetMessageFromAjaxError(error.responseText); alert(message); }
////    });
////}

////function SetupHeights() {

////    var height = $("#mainContainer").parent().height() - $("#Profilifieldset").outerHeight(true);
////    //splitter è la parte bassa con i riquadri Prestazioni e Aggiungi Prestazioni
////    $("#splitter").height(height - 24);

////    //SetupGridHeights();
////}

//////function CaricaProfili(idProfilo) {
//////    var codiceDescrizione = $("#filtroProfiliDescrizione").val();

//////    if ($("#Profili .list-group-item").not("#Profili .disabled").length == 0) {
//////        $("#divNoProfili").show();
//////        $("#splitter").hide();
//////        $("#filtroProfiliDescrizione").attr("title", "Nessun profilo da filtrare.");
//////        $("#Profili").html("<a href='#' class='list-group-item disabled'>Nessun profilo</a>");
//////        return;
//////    } else {
//////        $("#divNoProfili").hide();
//////        $("#splitter").show();
//////        $("#filtroProfiliDescrizione").removeAttr("disabled");
//////        $("#filtroProfiliDescrizione").removeAttr("title");
//////    }

//////    $("#Profili .list-group-item").not("#Profili .disabled").each(function () {
//////        var desc = $(this).attr("descrizione");
//////        if (desc.indexOf(codiceDescrizione) == -1) {
//////            $(this).hide();
//////        } else {
//////            $(this).show();
//////        };
//////    });

//////    if (!idProfilo) {
//////        $("#Profili .linkProfili:first").addClass("selectedLinkProfili");
//////        $("#hfCurrentProfilo").val($("#Profili .linkProfili:first").attr("id"));
//////        $("#divHeadingPanel").html("Prestazioni del profilo <strong>" + $("#Profili .linkProfili:first").attr("descrizione") + "</strong>");
//////    } else {
//////        $("#" + idProfilo).addClass("selectedLinkProfili");
//////        $("#divHeadingPanel").html("Prestazioni del profilo <strong>" + $("#" + idProfilo).attr("descrizione") + "</strong>");
//////        $("#hfCurrentProfilo").val(idProfilo);
//////    }

//////    $("#Prestazioni").html("<div></div>");

//////    CaricaPrestazioni($(".selectedLinkProfili").attr("id"));
//////}

//////function CaricaPrestazioni(idProfilo) {

//////    $("#Profili .selectedLinkProfili").removeClass("selectedLinkProfili");
//////    $("#Profili .active").removeClass("active");
//////    $("#" + idProfilo).addClass("selectedLinkProfili");
//////    $("#" + idProfilo).addClass("active");
//////    $("#hfCurrentProfilo").val(idProfilo);
//////    $("#divHeadingPanel").html("Prestazioni del profilo <strong>" + $("#" + idProfilo).attr("descrizione") + "</strong>");

//////    $.ajax({
//////        type: "POST",
//////        url: "AjaxWebMethods/ProfiliUtenteMethods.aspx/GetPrestazioni",
//////        data: "{'idProfilo':'" + idProfilo + "'}",
//////        contentType: "application/json; charset=utf-8",
//////        dataType: "json",
//////        success: function (result) {

//////            if (!result.d) {

//////                $("#Prestazioni").html("<div class='panel-body'><div class='well well-sm col-sm-12'>Nessuna prestazione</div></div>");
//////                if ($("#selettoreGrid").length > 0) CercaPrestazioni();
//////                return;
//////            }

//////            var html = [];

//////            html.push('<table id="prestazioniGrid" class="tablesorter table table-condensed"><thead>');
//////            html.push('<th style="width:2%"><input type="checkbox" onclick="SelectDeselectAll($(this), $(\'#prestazioniGrid\'));" /></th><th>Codice</th><th>Descrizione</th><th>Erogante</th>');
//////            html.push('</thead><tbody>');

//////            for (var property in result.d) {

//////                var prestazione = result.d[property];

//////                html.push('<tr id="' + prestazione.Id + '" class="GridItem">');

//////                html.push('<td><input type="checkbox" class="gridCheckBox" /></td>');
//////                html.push('<td>' + prestazione.Codice + '</td>');
//////                html.push('<td>' + prestazione.Descrizione + '</td>');
//////                html.push('<td>' + prestazione.SistemaErogante + '</td>');
//////                html.push('</tr>');
//////            }

//////            html.push('</tbody></table>');

//////            $("#Prestazioni").html(html.join(""));

//////            $("#prestazioniGrid").tablesorter({

//////                headers: {
//////                    0: { sorter: false }
//////                }
//////            });

//////            $("#loader").fadeOut();

//////            $("#prestazioniGrid .GridItem").hover(function () {

//////                $(this).addClass("GridHover");

//////            }, function () {

//////                $(this).removeClass("GridHover");
//////            });

//////            $("#prestazioniGrid .gridCheckBox").change(function () {

//////                var checked = $("#prestazioniGrid .gridCheckBox:checked").length;

//////                if (checked > 0) {

//////                    $(this).parent().parent().addClass('GridSelected');

//////                } else {

//////                    $(this).parent().parent().removeClass('GridSelected');
//////                }
//////            });

//////            if ($("#selettoreGrid").length > 0) CercaPrestazioni();
//////        },
//////        error: function (error) { var message = GetMessageFromAjaxError(error.responseText); alert(message); }
//////    });
//////}

////var varIdProfilo = null;

////function SalvaProfilo(idProfilo, descrizione) {

////    $.ajax({
////        type: "POST",
////        url: "AjaxWebMethods/ProfiliUtenteMethods.aspx/UpdateProfilo",
////        data: "{'idProfilo':'" + idProfilo + "','descrizione':'" + escape(descrizione) + "'}",
////        contentType: "application/json; charset=utf-8",
////        dataType: "json",
////        async: false,
////        success: function (result) {

////            if (!result.d) {

////                return;
////            }

////            idProfilo = result.d;

////        },
////        error: function (error) {

////            var message = GetMessageFromAjaxError(error.responseText);

////            if (message.indexOf('duplicate key') > -1)
////                alert('Il codice del profilo deve essere univoco');
////            else
////                alert(message);
////        }
////    });

////    return idProfilo;
////}

//////function AddPrestazioni() {

//////    if ($('#selettoreGrid .GridSelected').length > 0) {

//////        var idProfilo = $("#Profili .selectedLinkProfili").attr("id");
//////        var idPrestazioni = new Array();
//////        var idPrestazioniDelProfilo = $("#prestazioniGrid .GridItem").map(function () { return $(this).attr("id"); }).get();

//////        $('#selettoreGrid .GridSelected').each(function () {

//////            var idPrestazione = $(this).attr("id");

//////            if ($.inArray(idPrestazione, idPrestazioniDelProfilo) == -1)
//////                idPrestazioni.push(idPrestazione);
//////        });

//////        AggiungiPrestazioniAProfilo(idProfilo, idPrestazioni);

//////        CaricaPrestazioni(idProfilo);
//////    }
//////}

//////function RemovePrestazioni() {

//////    if ($('#prestazioniGrid .GridSelected').length > 0) {

//////        var idProfilo = $("#Profili .selectedLinkProfili").attr("id");
//////        var idPrestazioni = $("#prestazioniGrid .GridSelected").map(function () { return $(this).attr("id"); }).get();

//////        RimuoviPrestazioneDaProfilo(idProfilo, idPrestazioni);
//////    }
//////}

//////function RimuoviPrestazioneDaProfilo(idProfilo, idPrestazioni) {

//////    $.ajax({
//////        type: "POST",
//////        url: "AjaxWebMethods/ProfiliUtenteMethods.aspx/DeletePrestazioneDaProfilo",
//////        data: "{'idProfilo':'" + idProfilo + "', 'idPrestazioni':'" + idPrestazioni.join(";") + "'}",
//////        contentType: "application/json; charset=utf-8",
//////        dataType: "json",
//////        async: false,
//////        success: function (result) {

//////            CaricaPrestazioni(idProfilo);
//////        },
//////        error: function (error) { var message = GetMessageFromAjaxError(error.responseText); alert(message); }
//////    });
//////}

//////function CercaPrestazioni() {

//////    var descrizione = $("#descrizioneFiltro").val();
//////    var erogante = $("#sistemiEroganti").val();

//////    $("#loader").show();

//////    $.ajax({
//////        type: "POST",
//////        url: "AjaxWebMethods/ProfiliUtenteMethods.aspx/GetListaPrestazioni",
//////        data: "{'descrizione':'" + escape(descrizione) + "', 'erogante':'" + erogante + "'}",
//////        contentType: "application/json; charset=utf-8",
//////        dataType: "json",
//////        success: function (result) {

//////            if (result.d == null) {

//////                $("#listaPrestazioni").html("<div class='panel-body'><div class='well well-sm col-sm-12'>Nessun risultato</div>");
//////                $("#loader").fadeOut();
//////                return;
//////            }

//////            var html = [];

//////            html.push('<table id="selettoreGrid" class="tablesorter table table-condensed"><thead>');
//////            html.push('<th style="width:2%;"><input type="checkbox" cursor: pointer;" onclick="SelectDeselectAll($(this), $(\'#selettoreGrid\'));" /></th><th>Codice</th><th>Descrizione</th><th>Erogante</th>');
//////            html.push('</thead><tbody>');

//////            for (var element in result.d) {

//////                var riga = result.d[element];

//////                var idPrestazioniDelProfilo = $("#prestazioniGrid .GridItem").map(function () { return $(this).attr("id"); }).get();

//////                html.push('<tr id="' + riga.Id + '" class="GridItem">');

//////                if ($.inArray(riga.Id, idPrestazioniDelProfilo) == -1)
//////                    html.push('<td ><input type="checkbox" class="gridCheckBox" /></td>');
//////                else
//////                    html.push('<td></td>');

//////                html.push('<td>' + riga.Codice + '</td>');
//////                html.push('<td>' + riga.Descrizione + '</td>');
//////                html.push('<td>' + riga.SistemaErogante + '</td>');
//////                html.push('</tr>');
//////            }

//////            html.push('</tbody></table>');

//////            $("#listaPrestazioni").html(html.join(""));

//////            $("#selettoreGrid").tablesorter({

//////                headers: {
//////                    0: { sorter: false }
//////                }
//////            });

//////            $("#loader").fadeOut();

//////            $("#selettoreGrid .GridItem").hover(function () {

//////                $(this).addClass("GridHover");

//////            }, function () {

//////                $(this).removeClass("GridHover");
//////            });

//////            $("#selettoreGrid .gridCheckBox").change(function () {

//////                var checked = $("#selettoreGrid .gridCheckBox:checked").length

//////                if (checked > 0) {

//////                    $(this).parent().parent().addClass('GridSelected');

//////                } else {

//////                    $(this).parent().parent().removeClass('GridSelected');
//////                }
//////            });

//////            //SetupGridHeights();
//////        },
//////        error: function (error) {

//////            $("#loader").fadeOut();
//////            var message = GetMessageFromAjaxError(error.responseText); alert(message);
//////        } //<----cambiare messaggio?
//////    });
//////}

//////function AggiungiPrestazioniAProfilo(idProfilo, idPrestazioni) {

//////    $.ajax({
//////        type: "POST",
//////        url: "AjaxWebMethods/ProfiliUtenteMethods.aspx/InsertPrestazioniInProfilo",
//////        data: "{'idProfilo':'" + idProfilo + "','idPrestazioni':'" + idPrestazioni.join(";") + "'}",
//////        contentType: "application/json; charset=utf-8",
//////        dataType: "json",
//////        async: false,
//////        success: function (result) {

//////            if (!result.d) {

//////                return;
//////            }
//////        },
//////        error: function (error) { var message = GetMessageFromAjaxError(error.responseText); alert(message); }
//////    });
//////}

