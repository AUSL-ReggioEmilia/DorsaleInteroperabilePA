

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

//    var rows = $('.rowHide' + codiceUO)

//    if (rows.css('display') == 'none') {

//        link.find('img').attr('src', '../Images/minus.gif')

//        rows.show();
//    }
//    else {

//        link.find('img').attr('src', '../Images/new.gif')

//        rows.hide();
//    }

//    rows.each(function () {

//        var idPaziente = $(this).attr("idpaziente");
//        var pazienteLink = $("#" + idPaziente);

//        TogglePanel(codiceUO, pazienteLink, idPaziente, true);
//    });
//}

//function TogglePanel(codiceUO, link, idSac, forceHide) {

//    var rows = $('.rowHide' + idSac + codiceUO)

//    if (!forceHide && rows.css('display') == 'none') {

//        link.find('img').attr('src', '../Images/minus.gif')

//        rows.show();
//    }
//    else {

//        link.find('img').attr('src', '../Images/new.gif')

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
