
//Funzione per ricavare dei parametri dalla queryString
function pageLoad() {
	//appInsights.trackEvent("OrderEntry: Avvio chiamata dati accessori");

	//Ricavo l'idRichiesta dall'URL
	let IdRichiesta = getParameterByName('IdRichiesta');

	//Per ogni tabella di tipo prestazione eseguo una chiamata ajax che mi torna le righe
	$('.tabella-erogante').each(function () {
		let table = $(this);
		let tableId = table.data("id");
		let ajaxParameter = JSON.stringify({ "IdRichiesta": IdRichiesta, "SistemaErogante": tableId });
		$.ajax({
			type: "POST",
			url: getUrlDatiAggiuntivi(false),
			data: ajaxParameter,
			contentType: "application/json; charset=utf-8",
			dataType: "json",
			success: (function (result) {
				if (result != null && result.d != null) {
					let array = JSON.parse(result.d);
					if (array.length > 0) {
						for (let i = 0; i < array.length; i++) {
							let chiave = array[i].Chiave;
							let valore = array[i].Valore;
							let tipo = array[i].Tipo;
							if (tipo == "pdf") {
								valore = getAnchorDatiAccessoriPdf(valore);
							}

							table.find('tbody').append($('<tr>').append($('<td class="col-sm-6">').text(chiave)).append($('<td class="col-sm-6">').html(valore)));
						}
						table.parent().parent().parent().show();
						$('#' + tableId + ' thead').show();
					}
				}
			}),
			error: function (result) {
				alert('Errore. Contattare un amministratore.');
			}
		});
	});

	$('.tabella-prestazione').each(function () {
		let table = $(this);
		let tableId = $(this).data("id");

		let ajaxParameter = JSON.stringify({ 'IdRichiesta': IdRichiesta, 'IdPrestazione': tableId });
		$.ajax({
			type: "POST",
			url: getUrlDatiAggiuntivi(true),
			data: ajaxParameter,
			contentType: "application/json; charset=utf-8",
			dataType: "json",
			success: (function (result) {
				if (result != null && result.d != null) {
					let array = JSON.parse(result.d);

					if (array.length > 0) {
						for (let i = 0; i < array.length; i++) {
							let chiave = array[i].Chiave;
							let valore = array[i].Valore;
							let tipo = array[i].Tipo;
							if (tipo == "pdf") {
								valore = getAnchorDatiAccessoriPdf(valore);
							}
							table.find('tbody').append($('<tr>').append($('<td class="col-sm-6">').text(chiave)).append($('<td class="col-sm-6">').html(valore)));
						}

						//Mostro gli header delle tabelle papà
						table.parent().parent().parent().show();
						table.parent().parent().parent().parent().show();
						table.parent().parent().parent().parent().parent().show();
					}
				}
			}),
			error: function (result) {
				alert('Errore. Contattare un amministratore.');
			}
		});
	});
}

function getUrlDatiAggiuntivi(IsPrestazioni) {
	let paginaCorrente = window.location.pathname.split("/")[(window.location.pathname.split("/")).length - 1];
	let searchParameters = window.location.search;
	let urlCorrente = window.location.href;

	if (urlCorrente.indexOf("AccessoDiretto") !== -1) {
		console.log("isAccessoD");
		urlCorrente = urlCorrente.replace("AccessoDiretto/", "");
		urlCorrente = urlCorrente.replace(searchParameters, "");
		urlCorrente = urlCorrente.replace(paginaCorrente, "");

		if (IsPrestazioni) {
			urlCorrente = urlCorrente + "AjaxWebMethods/RiassuntoOrdineMethods.asmx/DatiAggiuntiviPrestazione?id=" + getParameterByName('IdRichiesta');
		} else {
			urlCorrente = urlCorrente + "AjaxWebMethods/RiassuntoOrdineMethods.asmx/DatiAggiuntiviSistemaErogante2?id=" + getParameterByName('IdRichiesta');
		}
	}
	else {
		if (IsPrestazioni) {
			urlCorrente = "AjaxWebMethods/RiassuntoOrdineMethods.asmx/DatiAggiuntiviPrestazione?id=" + getParameterByName('IdRichiesta');
		} else {
			urlCorrente = "AjaxWebMethods/RiassuntoOrdineMethods.asmx/DatiAggiuntiviSistemaErogante2?id=" + getParameterByName('IdRichiesta');

		}
	}

	return urlCorrente;
}

function getParameterByName(name, url) {
	if (!url) url = window.location.href;
	name = name.replace(/[\[\]]/g, '\\$&');
	var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
		results = regex.exec(url);
	if (!results) return null;
	if (!results[2]) return '';
	return decodeURIComponent(results[2].replace(/\+/g, ' '));
};

function getAnchorDatiAccessoriPdf(valorepdf) {
	return "<a href='PdfViewer.aspx?id=" + valorepdf + "' target='_blank'>pdf</a>";
}
