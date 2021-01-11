$(document).ready(function () {
    //ottengo l'url corrente.
    let urlCorrente = window.location.href;

    //testo se l'url corrente è vuoto
    if (urlCorrente !== null) {
        //se non sono nell'accesso diretto registro l'evento per il onKeyDown.
        if(urlCorrente.toUpperCase().indexOf("ACCESSODIRETTO") === -1) {
            document.onkeydown = myKeyDownHandler;
        }
    }

    //attenzione: #modaleInvioEmai è contenuta nello usercontrol ucModaleInvioLinkPerAccessoDiretto
    //quando si apre la modale di inivio link ad accesso diretto nascondo l'iframe.
    $("#modaleInvioEmail").on("show.bs.modal", function (e) {
        if (BrowserIsIE) {
            $("#divIframePdf").hide();
            $("#divIframeEsterno").hide();
        }
    });

    //quando si nasconde la modale di invio link ad accesso diretto mostro l'iframe.
    $("#modaleInvioEmail").on("hide.bs.modal", function (e) {
        if (BrowserIsIE) {
            $("#divIframePdf").show();
            $("#divIframeEsterno").show();
        }
    });
});

function myKeyDownHandler() {
    if (event.keyCode === 116) {
        event.keyCode = 0;
        event.cancelBubble = true;
        return false;
    }
}

//Funzione che stabilisce se il browser corrrente è IE.
function BrowserIsIE() {
    let isIE = false;

    try {
        let ua = window.navigator.userAgent;
        let msie = ua.indexOf("MSIE ");

        if (msie > 0) {
            isIE = true;
        }

        Console.log(isIE);
    } catch (e) {
        console.log("Si è verificato un errore.");
    }

    return isIE;
}

//Funzione per sistemare bug Iframe e Bootstrap Modal, l'iframe compre la modal senza questo FIX
function fixPDFzIndexIssue(idToFix) {
    if (!idToFix) return "Please provide the id of the div to fix";

    var $divToFix = $('#' + idToFix);

    $divToFix.wrap("<div class='outer'></div>");

    $(".outer").append("<iframe src='about:blank' class='cover'>");
    $(".cover").css({
        'min-width': '100%',
        'min-height': '100%',
        'overflow': 'hidden',
        'position': 'absolute',
        'border': 'none',
        'left': 0,
        'top': 0,
        'z-index': -1
    });
}