
$(document).ready(function () {

    setIsFiltroEspanso();
    ToggleFilter();
    setIsFiltroEspanso();

    //$(".DateTimeInput").datepicker($.datepicker.regional['it']);

    BindServerXmlPreview(".xmlFixedPreviewLink", "Stati.aspx/GetMessaggioOriginale", "Messaggio Originale", "idmessaggio");

    DateChanged();
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

/****************************************************/

function ToggleFilter() {

    var filtroEspanso = getIsFiltroEspanso();

//    $(".filters").each(function () {

//        if (filtroEspanso == 'chiuso') {

//            $(this).css('height', '210px');

//        } else {

//            $(this).css('height', '90px');
//        }
//    });

    $(".NoRequiredField").each(function () {

        if (filtroEspanso == 'chiuso') {
        	$("#linkFiltroAvanzato").text('semplice');
            $(this).fadeIn(200, function () { this.removeAttribute('filter') }); //IE FIX

        } else {
           	$("#linkFiltroAvanzato").text('avanzata');
            $(this).fadeOut(200);
        }
    });
}
