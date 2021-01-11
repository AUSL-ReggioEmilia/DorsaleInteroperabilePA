//$(document).ready(function () {
//    SetupPopup();
//});

//function ShowUoPanel() {

//    $(".uoRow").each(function () {

//        var codiceUO = $(this).attr("codiceuo");

//        if ($('.rowHide' + codiceUO).length > 0) {

//            $(this).show();

//            ToggleUOPanel($("#" + codiceUO), codiceUO);
//        }
//    });
//}

//function ToggleUOPanel(link, codiceUO) {
//    /*
//    * Questa funzione viene richiamata nel MarkUp della pagina Home.aspx.
//    * Funzione che si occupa del collassamento delle righe della tabella.
//    */

//    var rows = $('.rowHide' + codiceUO)

//    if (rows.css('display') == 'none') {

//        link.find('span').attr('class', 'glyphicon glyphicon-minus');
//        rows.show();
//    }
//    else {

//        link.find('span').attr('class', 'glyphicon glyphicon-plus');
//        rows.hide();
//    }

//    rows.each(function () {

//        var idPaziente = $(this).attr("idpaziente");
//        var pazienteLink = $("#" + idPaziente);

//        TogglePanel(codiceUO, pazienteLink, idPaziente, true);
//    });
//}

//function TogglePanel(codiceUO, link, idSac, forceHide) {
//    /*
//    * Questa funzione viene richiamata nel MarkUp della pagina Home.aspx.
//    * Funzione che si occupa del collassamento delle righe all'interno della tabella.
//    */
//    var rows = $('.rowHide' + idSac + codiceUO)

//    if (!forceHide && rows.css('display') == 'none') {

//        link.find('span').attr('class', 'glyphicon glyphicon-minus');

//        rows.show();
//    }
//    else {

//        link.find('span').attr('class', 'glyphicon glyphicon-plus');

//        rows.hide();
//    }
//}

//function LoadInfoRicovero(nosologico, idRiga, idPaziente) {

//    if (!nosologico)
//        return;

//    var loader = $("#loader" + idRiga);
//    loader.show();

//    $.ajax({
//        type: "POST",
//        url: "AjaxWebMethods/HomeMethods.aspx/GetInfoRicovero",
//        data: "{'idPaziente': '" + idPaziente + "', 'nosologico': '" + nosologico + "'}",
//        contentType: "application/json; charset=utf-8",
//        dataType: "json",
//        success: function (result) {

//            loader.fadeOut(300, function () {

//                $("#infoRicovero" + idRiga).html(result.d);

//                loader.remove();
//            });
//        },
//        error: function (error) { loader.hide(); var message = GetMessageFromAjaxError(error.responseText); alert(message); }
//    });
//}