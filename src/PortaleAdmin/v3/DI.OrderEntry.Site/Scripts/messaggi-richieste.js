
$(document).ready(function () {

	setIsFiltroEspanso();
	ToggleFilter();
	setIsFiltroEspanso();

	$(".DateTimeInput").datepicker($.datepicker.regional['it']);

	BindServerXmlPreview(".xmlFixedPreviewLink", "Richieste.aspx/GetMessaggioOriginale", "Messaggio Originale", "idmessaggio");

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

function ShowHidePageMenu() {

	var pageMenu = $('#MenuColumn');

	if (pageMenu.width() < 100) {

		$(".LeftContent").show();

		pageMenu.width(_menuWidth);

		$("#leftShowHideLink").html('Nascondi')
                              .css('background-image', 'url(../Images/left.gif)');

		CreateCookie('pageMenu', 'visible', 365);
	}
	else {

		$(".LeftContent").hide();

		pageMenu.width(50);

		$("#leftShowHideLink").html('Mostra')
                              .css('background-image', 'url(../Images/right.gif)');

		CreateCookie('pageMenu', 'hidden', 365);
	}

	SetHeights();
}

function ToggleFilter() {

	var filtroEspanso = getIsFiltroEspanso();

	$(".NoRequiredField").each(function () {

		if (filtroEspanso == 'chiuso') {
			$("#linkFiltroAvanzato").text('semplice');
			$(this).fadeIn(200, function () { this.removeAttribute('filter') }); //IE FIX

		} else {
			$("#linkFiltroAvanzato").text('avanzata');
			$(this).fadeOut(200);
		}
	});

//	$(".filters").each(function () {
//		if (filtroEspanso == 'chiuso') {
//			$(this).css('height', '210px');
//		} else {
//			$(this).css('height', '90px');
//		}
//	});
}

