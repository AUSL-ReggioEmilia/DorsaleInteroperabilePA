function pageLoad() {

	moment.locale('it');
	//Nascondo la modale di caricamento.
	$('.form-control-datatimepicker').datetimepicker({
		//inline: true,
		sideBySide: true,
		locale: 'it',
		format: "DD/MM/YYYY"
	});

	//2020-07-09 Leo: spostate le seguenti funzioni nel pageLoad in seguito all'aggiunta degli UpdatePanel e ProgressPanel
	$(".btn-dati-accessoripdf").click(function () {
		try {
			let ajaxParameter = JSON.stringify({ 'IdRichiesta': $(this).data("id") });
			$.ajax({
				type: "POST",
				url: getUrlDatiAggiuntivi() + $(this).data("id"),
				data: ajaxParameter,
				contentType: "application/json; charset=utf-8",
				dataType: "json",
				success: (function (result) {
					if (result != null && result.d != null) {
						let array = JSON.parse(result.d);
						$('#modalListaDatiAccessori').modal('show');
						if (array.length > 0) {
							$('#bodyDatiAccessori').empty();
							for (let i = 0; i < array.length; i++) {

								let chiave = array[i].Chiave;
								let valore = array[i].Valore;

								valore = getAnchorDatiAccessoriPdf(valore);

								let result = '<label class="col-sm-6 control-label" style="text-align:right;">' + chiave + '</label><div class="col-sm-6"><p>' + valore + '</p></div>';
								$('#bodyDatiAccessori').append(result);

							}
						}
					}
				}),
				error: function (result) {
					alert('Errore. Contattare un amministratore.');
				}
			});
		} catch (e) {
			trackError(e);
		}
	});

	function getUrlDatiAggiuntivi() {
		try {
			let paginaCorrente = window.location.pathname.split("/")[(window.location.pathname.split("/")).length - 1];
			let searchParameters = window.location.search;
			let urlCorrente = window.location.href;

			if (urlCorrente.indexOf("AccessoDiretto") !== -1) {
				console.log("isAccessoD");
				urlCorrente = urlCorrente.replace("AccessoDiretto/", "");
				urlCorrente = urlCorrente.replace(searchParameters, "");
				urlCorrente = urlCorrente.replace(paginaCorrente, "");

				return urlCorrente = urlCorrente + "AjaxWebMethods/RiassuntoOrdineMethods.asmx/OttieniDatiAggiuntiviRichiestaPdf?id=";
			}
			else {
				urlCorrente = "AjaxWebMethods/RiassuntoOrdineMethods.asmx/OttieniDatiAggiuntiviRichiestaPdf?id=";
			}
			return urlCorrente;
		}
		catch (e) {
			trackError(e);
		}
	}

	function getAnchorDatiAccessoriPdf(valorepdf) {
		return "<a href='PdfViewer.aspx?id=" + valorepdf + "' target='_blank'>pdf</a>";
	}

	$(".btn-dati-accessori").click(function () {
		var id = $(this).attr('data-id');
		window.location.href = window.location.href.replace("ListaOrdini", "RiepilogoDatiAccessori") + '?IdRichiesta=' + id;
		return false;
	});
}

