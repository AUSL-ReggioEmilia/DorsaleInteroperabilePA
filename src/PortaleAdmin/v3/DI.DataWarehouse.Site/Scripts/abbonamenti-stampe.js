
$(document).ready(function () {

    $(".DateInput").datepicker($.datepicker.regional['it']);
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


function cambiaAttivazione(id, idStato) {

    var button = $("#CambiaAttivazioneButton_" + id);

    button.attr("disabled", true);
    button.css("background-image", "url(../Images/refresh.gif)");

    $.ajax({
        type: "POST",
        url: "AbbonamentiStampe.aspx/CambiaStatoAttivazioneSottoscrizione",
        data: "{'id':'" + id + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {

            response = result.d;

            if (response == 'error') {

                alert("Impossibile attivare/disattivare la sottoscrizione");
                button.removeAttr("disabled");
            }
            else {
               //location.href = "AbbonamentiStampe.aspx";
            }
        },
        error: function (error) { alert('Si è verificato un errore'); button.removeAttr("disabled"); }
    });
}

function elimina(id) {

    if (!confirm("La sottoscrizione verrà eliminata, continuare?")) {
        return;
    }

    var button = $("#EliminaButton_" + id);

    button.attr("disabled", true);
    button.css("background-image", "url(../Images/refresh.gif)");

    $.ajax({
        type: "POST",
        url: "AbbonamentiStampe.aspx/CancellaSottoscrizione",
        data: "{'id':'" + id + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            response = result.d;

            if (response == 'error') {

                alert("Impossibile eliminare la sottoscrizione");
                button.removeAttr("disabled");
            }
            else {
                button.parent().parent().fadeOut(1000);
            }
        },
        error: function (error) { alert('Si è verificato un errore'); button.removeAttr("disabled"); }
    });
}