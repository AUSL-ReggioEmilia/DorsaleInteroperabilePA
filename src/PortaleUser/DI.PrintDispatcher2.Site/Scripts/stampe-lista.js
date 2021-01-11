
$(document).ready(function () {

    $(".DateTimeInput").datepicker($.datepicker.regional['it']);
});

/****************************************************/
//Cancella i filtri
function ClearFilters() {

    $(".filters input[type='text']").each(function () {

        if (!$(this).hasClass("form-control-dataPicker")) {

            $(this).val('');
        }
    });
}

/****************************************************/

function Reprint(id, usePrintDispatcher) {

    var errorImage = $("#error_" + id);
    var okImage = $("#ok_" + id);
    var refresh = $("#refresh_" + id);

    errorImage.attr("title", "");
    errorImage.fadeOut();
    okImage.fadeOut();

    refresh.fadeIn(500, function () {

        $.ajax({
            type: "POST",
            url: "StampeLista.aspx/Reprint",
            data: "{id:'" + id + "', usePrintDispatcher: " + usePrintDispatcher + "}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (result) {

                refresh.fadeOut(200, function () {

                    if (result.d.Stato) {

                        okImage.fadeIn();
                        okImage.attr("title", result.d.Messaggio);
                    }
                    else {

                        errorImage.fadeIn();
                        errorImage.attr("title", result.d.Messaggio);
                    }

                    alert(result.d.Messaggio);
                });
            },
            error: function (error) {

                refresh.fadeOut(200, function () {

                    var message = GetMessageFromAjaxError(error.responseText);

                    errorImage.attr("title", message);
                    errorImage.fadeIn();

                    alert("Si è verificato un errore.");
                });
            }
        });
    });
}

function ReprintLocal(id, usePrintDispatcher) {

    var errorImage = $("#error_" + id);
    var okImage = $("#ok_" + id);
    var refresh = $("#refresh_" + id);

    errorImage.attr("title", "");
    errorImage.fadeOut();
    okImage.fadeOut();

    refresh.fadeIn(500, function () {

        $.ajax({
            type: "POST",
            url: "StampeLista.aspx/ReprintLocal",
            data: "{id:'" + id + "', usePrintDispatcher: " + usePrintDispatcher + "}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (result) {

                refresh.fadeOut(200, function () {

                    if (result.d.Stato) {

                        okImage.fadeIn();
                        okImage.attr("title", result.d.Messaggio);
                    }
                    else {

                        errorImage.fadeIn();
                        errorImage.attr("title", result.d.Messaggio);
                    }

                    alert(result.d.Messaggio);
                });
            },
            error: function (error) {

                refresh.fadeOut(200, function () {

                    var message = GetMessageFromAjaxError(error.responseText);

                    errorImage.attr("title", error.message);
                    errorImage.fadeIn();

                    alert("Si è verificato un errore.");
                });
            }
        });
    });
}

function ShowFile(id) {

    var pdfImage = $("#file_" + id);
    var refresh = $("#fileRefresh_" + id);
    var error = $("#fileError_" + id);

    error.hide();
    pdfImage.hide();

    refresh.fadeIn(400, function () {

        $.ajax({
            type: "POST",
            url: "StampeLista.aspx/SaveBase64AndGetId",
            data: "{id:'" + id + "'}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (result) {

                refresh.fadeOut(200, function () {

                    switch (result.d) {

                        case "-1":

                            error.attr("title", "Errore: file mancante");
                            error.fadeIn();
                            break

                        default:

                            window.open('PdfViewer.aspx?id=' + encodeURIComponent(result.d));
                            pdfImage.fadeIn();
                            break;
                    }
                });
            },
            error: function (error) {

                refresh.fadeOut(200, function () {

                    var message = GetMessageFromAjaxError(error.responseText);

                    error.attr("title", message);
                    error.fadeIn();
                });
            }
        });
    });
}