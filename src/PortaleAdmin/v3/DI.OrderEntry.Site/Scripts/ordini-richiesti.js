$(document).ready(function () {

	$(".DateInput").datepicker();

	DateChanged('inserimento', true);
	DateChanged('richiesta', true);
	
	var filterState = ReadCookie('filter');
	if (filterState && filterState == 'aperto') {
	    $("#linkFiltroAvanzato").text('semplice');
	    $(".NoRequiredField").each(function () {
	        $(this).fadeIn(0, function () { this.removeAttribute('filter') }); //IE FIX
	    });
	    CreateCookie('filter', 'aperto', 365);
	}
	else {
	    $("#linkFiltroAvanzato").text('avanzata');
	    $(".NoRequiredField").each(function () {
	        $(this).fadeOut(0);
	    });
	    CreateCookie('filter', 'chiuso', 365);
	}
});

function ToggleFilter() {    
    if ($("#linkFiltroAvanzato").text() == 'avanzata') {
        $("#linkFiltroAvanzato").text('semplice');
        $(".NoRequiredField").each(function () {
            $(this).fadeIn(200, function () { this.removeAttribute('filter') }); //IE FIX
        });
        CreateCookie('filter', 'aperto', 365);
    }
    else {
        $("#linkFiltroAvanzato").text('avanzata');
        $(".NoRequiredField").each(function () {
            $(this).fadeOut(200);
        });
        CreateCookie('filter', 'chiuso', 365);
    }
}
