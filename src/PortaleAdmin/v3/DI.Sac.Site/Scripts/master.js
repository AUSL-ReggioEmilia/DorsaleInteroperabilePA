
$(document).ready(function () {

    //acrrocc per hover in IE 'input'
    $("input").hover(function () {

    $(this).addClass("inputHover");

    }, function () {

    $(this).removeClass("inputHover");
    });

    //acrrocc per hover in IE 'textarea'
    $("textarea").hover(function () {

    $(this).addClass("textareaHover");

    }, function () {

    $(this).removeClass("textareaHover");
    });


    $("input[type = 'checkbox']").css("border-style", "none")
                                 .css("background-color", "transparent");

    $("input[type = 'radio']").css("border-style", "none")
                              .css("background-color", "transparent");

    //$(".TreeLeafNode").prev().prev().hide(); QUESTO E' LA CAUSA DELL'ERRATA VISUALIZZAZIONE DEL TREEVIEW
});


var _index = 0;

/*****************BindXmlPreview******************/
//function BindXmlPreview(selector) {

//    $(selector).each(function () {

//        if ($(this).html().length == 0) return true;

//        $(this).hide()
//               .closest("td")
//               .append("<a href='#' class='xmlPreviewLink' onclick='return false;'><img src='../Images/view.png' alt='visualizza dati' title='visualizza dati'/></a>");
//    });

//    $(".xmlPreviewLink").click(function (e) {

//        _index++;

//        var index = _index;

//        var title = $(this).prev().attr("title");

//        setupPopupPanel(index, title);

//        $("#loaderContainer" + index).hide().html($(this).prev().html()).fadeIn("fast", function () { this.removeAttribute('filter') }); //IE FIX
//    });
//}

/*****************Dati Aggiuntivi******************/

function BindServerXmlPreview(selector, serverSideMethodToCall, title, attributeName, labelField) {

    $(selector).click(function () {

        _index++;

        var index = _index;

        setupPopupPanel(index, title);

        var idTestata = $(this).attr(attributeName);

        var label;

        if (labelField) label = $(this).attr(labelField);

        //esegue una chiamata ajax su un metodo
        $.ajax({
            type: "POST",
            url: serverSideMethodToCall,
            data: "{id:'" + idTestata + "'}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (result) {

                var resultText = (result.d == 'undefined' ? 'Nessun dettaglio disponibile' : result.d);

                if (label) {

                    resultText = '<b><span style="width:100%; text-align: center;">' + label + '</span></b><br />' + resultText;
                }

                $("#loaderContainer" + index).hide()
                                             .html(resultText)
                                             .fadeIn("fast", function () { this.removeAttribute('filter') }); //IE FIX
            },
            error: function (error) { alert(msg.d); } //<----cambiare messaggio?
        });
    });
}

/*****************Funzioni******************/

function formatDateTime(date) {

    var day = (date.getDate()) + '';
    if (day.length == 1) day = "0" + day;

    var month = (date.getMonth() + 1) + '';
    if (month.length == 1) month = "0" + month;

    var hours = (date.getHours()) + '';
    if (hours.length == 1) hours = "0" + hours;

    var minutes = (date.getMinutes()) + '';
    if (minutes.length == 1) minutes = "0" + minutes;

    var seconds = (date.getSeconds()) + '';
    if (seconds.length == 1) seconds = "0" + seconds;

    return day + "/" + month + "/" + date.getYear() + " " + hours + ":" + minutes + ":" + seconds;
}

function setupPopupPanel(index, title) {

    $("#PageContent").append('<div class="loaderDiv" id="loader' + index + '"><table class="GridHeader" style="width: 100%;"><tr><td><div class="loaderDivTitle">' + title + '</div></td><td style="width:20px;"><div idloader="' + index + '" class="closeButton"></div></td></tr></table>'
                           + '<div style="clear:both;" />'
                           + '<div class="loaderContainer" id="loaderContainer' + index + '"><div style="background:url(/Images/refresh.gif) no-repeat center center; width:100%; height:100%;"></div></div></div>');

    var loader = $("#loader" + index);

    loader.resizable({

        minWidth: 300,
        minHeight: 300,
        maxWidth: 600,
        maxHeight: 600,
        helper: "resize-helper",
        //animate: true,
        //alsoResize: '#loaderContainer' + index,
        stop: function (event, ui) {

            $("#loaderContainer" + index).css("width", (loader.width()) + "px")
                                         .css("height", (loader.height() - 30) + "px");
        }
    });

    loader.draggable({

        handle: ".loaderDivTitle",
        containment: "#PageContent",
        scroll: false
    });

    //stabilisce la funzione di chiusura del tasto close
    setupCloseButton();

    //gestisce lo scroll
    $(window).scroll(function () {

        loader.stop()
              .animate({ top: ($("body").scrollTop() + $("#PageContent").offset().top + 10 * index) + "px" }, 200);
    });

    loader.css("top", ($("body").scrollTop() + $("#PageContent").offset().top + 10 * index) + "px")
          .css("left", ($("body").scrollLeft() + $("#PageContent").offset().left + 10 * index) + "px")
          .css("z-index", index * 100)
          .fadeIn("fast", function () { this.removeAttribute('filter') }); //IE FIX
}

/*****************CloseButton******************/
function setupCloseButton() {

    $(".closeButton").click(function () {

        var idloader = $(this).attr("idloader");

        var loader = $("#loader" + idloader);

        loader.fadeOut(300, function () {

            loader.remove();

            if ($(".loaderDiv").length == 0) _index = 0;
        });
    });

    $(".closeButton").hover(function () {

        $(this).addClass("closeButtonHover");

    }, function () {

        $(this).removeClass("closeButtonHover");
    });
}

//funzione per la localizzazione in italiano (lingua e formato)
jQuery(function ($) {

    $.datepicker.regional['it'] = {
        closeText: 'Chiudi',
        prevText: '&#x3c;Prec',
        nextText: 'Succ&#x3e;',
        currentText: 'Oggi',
        monthNames: ['Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
                'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'],
        monthNamesShort: ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu',
                'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'],
        dayNames: ['Domenica', 'Luned&#236', 'Marted&#236', 'Mercoled&#236', 'Gioved&#236', 'Venerd&#236', 'Sabato'],
        dayNamesShort: ['Dom', 'Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab'],
        dayNamesMin: ['Do', 'Lu', 'Ma', 'Me', 'Gio', 'Ve', 'Sa'],
        dateFormat: 'dd/mm/yy',
        firstDay: 1,
        isRTL: false
    };

    $.datepicker.setDefaults($.datepicker.regional['it']);

    //    $.timepicker.regional['it'] = {
    //        timeOnlyTitle: 'Seleziona un orario',
    //        timeText: 'Orario',
    //        hourText: 'Ora',
    //        minuteText: 'Minuti',
    //        secondText: 'Secondi',
    //        currentText: 'Ora',
    //        closeText: 'Ok',
    //        ampm: false
    //    };
    //    $.timepicker.setDefaults($.timepicker.regional['it']);
});

//funzione per il parsing dei parametri del querystring
(function ($) {
    $.QueryString = (function (a) {
        if (a == "") return {};
        var b = {};
        for (var i = 0; i < a.length; ++i) {
            var p = a[i].split('=');
            if (p.length != 2) continue;
            b[p[0]] = decodeURIComponent(p[1].replace(/\+/g, " "));
        }
        return b;
    })(window.location.search.substr(1).split('&'))
})(jQuery);

function formatJSONDate(jsonDate) {

    if (!jsonDate) return '';

    return formatDateTime(new Date(parseInt(jsonDate.substr(6))));
}

function GetMessageFromAjaxError(responseText) {

    return eval("(" + responseText + ")").Message;
}

// MOSTRA UNA MESSAGEBOX CON DUE PULSANTI 'YES' 'NO', 
// RITORNA TRUE O FALSE, SETTA ANCHE UNA VARIABILE DI SESSIONE confirm_value CON IL RISULTATO 'Yes' O 'No'
function msgboxYESNO(MessageText) {
    var confirm_value = document.createElement("INPUT");
    var ret
    confirm_value.type = "hidden";
    confirm_value.name = "confirm_value";
    ret = confirm(MessageText);
    if (ret) { confirm_value.value = "Yes"; }
    else { confirm_value.value = "No"; }
    document.forms[0].appendChild(confirm_value);
    return ret;
}                