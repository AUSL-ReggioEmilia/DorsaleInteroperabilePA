$(document).ready(function () {

    $(".DateInput").datepicker($.datepicker.regional['it']);
    $(".DateTimeInput").datetimepicker($.datepicker.regional['it']);

    $("input[type = 'checkbox']").css("border-style", "none")
                                 .css("background-color", "transparent");

    $.ajax({
        type: "POST",
        url: "Login.aspx/GetLookupAziende",
        data: "{}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            var aziendaSelect = $("#aziendaSelect");

            for (var azienda in result.d) {

                aziendaSelect.append("<option value='" + azienda + "'>" + result.d[azienda] + "</option>");
            }

            LoadUnitaOperativa();          
        },
        error: function (error) { var message = GetMessageFromAjaxError(error.responseText); alert(message); } //<----cambiare messaggio?
    });
});

function LoadUnitaOperativa() {

    var azienda = $("#aziendaSelect").val();
    var uoSelect = $("#uoSelect");

    uoSelect.html('');

    $.ajax({
        type: "POST",
        url: "Login.aspx/GeLookupUnitaOperative",
        data: "{'azienda': '" + azienda + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            for (var uo in result.d) {

                uoSelect.append("<option value='" + uo + "'>" + result.d[uo] + "</option>");
            }
        },
        error: function (error) { var message = GetMessageFromAjaxError(error.responseText); alert(message); } //<----cambiare messaggio?
    });
}

function Login() {

    var azienda = $("#aziendaSelect").val();
    var uo = $("#uoSelect").val();
    var sistemaRichiedente = $("#sistemaSelect").val();

    if (azienda == '' || uo == '') return;

    $.ajax({
        type: "POST",
        url: "Login.aspx/Login",
        data: "{'codiceAzienda': '" + azienda + "','codiceUnitaOperativa': '" + uo + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {

            location.href = "Home.aspx";
        },
        error: function (error) {
            alert("Errore di autenticazione. Riprovare o contattare un amministratore.");
        }
    });
}