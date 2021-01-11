

function pageLoad() {

	$('#btnAvanti').click(function () {
		var count = 0; //vuol dire che è tutto a posto
		$('.form-control[data-tipo]:not(.form-control-ripetibile)').each(function () {

			if (!$.isNumeric($(this).val())) {
				if (!$(this).parent().next().hasClass("error-message")) {
					$(this).parent().after("<span class='label label-danger small error-message' aria-hidden='true'>Inserire un valore numerico valido</span>");
				}
				
				count = count + 1;
			}
		});

		if (count !== 0) {
			return false;
		}
	});

	$('.DateTimeInput').datetimepicker({
		//inline: true,
		sideBySide: true,
		locale: 'it',
		format: "DD/MM/YYYY HH:mm"
	});

	$('.TimeInput').datetimepicker({
		locale: 'it',
		format: 'HH:mm:ss'
	});

	$('.DateInput').datetimepicker({
		locale: 'it',
		format: "DD/MM/YYYY"
	});


	$(document).ready(function () {

		/*
		* Modifica di SimoneB il 26/01/2017
		* Quando navigo in un'altra pagina segnalo che l'ordine non è stato inoltrato.
		*/
		$(".navbar li:not('.has-popup,.dropdown') a").click(function () {
			var message = 'Attenzione: Ordine non inserito. Continuare comunque?';
			var url = $(this).attr('href');
			var result = ConfirmMessage(message, url);
			if (result === false) {
				return false;
			}
		});

		$(".form-control-ripetibile").each(function () {
			GenerateRepeatableControl($(this).data("codice"));
		});
	});
}

//Funzione chiamata lato server.
function GenerateRepeatableControl(codiceDomanda) {
	//ottengo il valore della textbox.
	//var valoreTextbox = $("#ctl" + codiceDomanda).val();
	var valoreTextbox = $("#hdf" + codiceDomanda).val();

	//Splitto il valore per il carattere "§;".
	var arrayValoriRipetibili = valoreTextbox.split("§;");

	//Creo un controllo per ogni valore dell'array.
	for (var i = 0; i < arrayValoriRipetibili.length; i++) {
		AggiungiNuovoControlloRipetibile(codiceDomanda, arrayValoriRipetibili[i]);
	}
}

//Aggiunge un nuovo controllo di tipo ripetibile.
function AggiungiNuovoControlloRipetibile(codiceDomanda, valore) {
	//ottengo tutti gli Input-group dentro al div("#" + codiceDomanda).
	var inputGroups = $("#" + codiceDomanda + " >.input-group");

	txt = $("#ctl" + codiceDomanda).eq(0).clone();
	txt.removeAttr("name");
	txt.removeAttr("id");
	txt.removeClass("form-control-ripetibile");
	txt.show();

	if (txt.is('select')) {


		for (var i = 0; i < txt[0].options.length; i++) {
			txt[0].options[i].removeAttribute("selected");

			if (txt[0].options[i].value === valore) {
				txt[0].options[i].setAttribute("selected", "selected");
			}
		}

		txt.attr("onchange", "SalvaDati('" + codiceDomanda + "')");
	} else {
		txt.attr("value", valore);
		txt.attr("onkeyup", "SalvaDati('" + codiceDomanda + "')");
	}

	//Creo un nuovo input-group.
	var html = "<div class='input-group input-group-custom-margin'>";

	//aggiungo la textbox all'input-group.
	html += txt[0].outerHTML; // textbox.outerHTML;

	//aggiungo il bottone.
	html += '<div class="input-group-btn">';

	//se nel div ci sono altri input-group allora devo mostrare il pulsante "-" altrimenti "+".
	if (inputGroups === null || inputGroups.length === 0) {
		html += '<button id="${codiceDomanda}" type="button" title="aggiungi un nuovo campo" alt="aggiungi un nuovo campo" class="btn btn-default" onclick="AggiungiNuovoControlloRipetibile(\'' + codiceDomanda + '\',\'\')">';
		html += '<span class="glyphicon glyphicon glyphicon-plus" aria-hidden="true"></span>';
		html += '</button>';
	}
	else {
		html += '<button id="${codiceDomanda}" type="button" title="aggiungi un nuovo campo" alt="aggiungi un nuovo campo" class="btn btn-default" onclick="RimuoviControlloRipetibile(this,\'' + codiceDomanda + '\')">';
		html += '<span class="glyphicon glyphicon glyphicon-minus" aria-hidden="true"></span>';
		html += '</button>';
	}

	html += '</div></div>';

	//Aggiungo l'html al div.
	$("#" + codiceDomanda).append(html);

	if (txt.hasClass("DateTimeInput")) {
		$('.DateTimeInput').datetimepicker({
			//inline: true,
			sideBySide: true,
			locale: 'it',
			format: "DD/MM/YYYY HH:mm"
		}).on("dp.hide", function (e) {
			SalvaDati(codiceDomanda);
		});
	}

	if (txt.hasClass("TimeInput")) {
		$('.TimeInput').datetimepicker({
			locale: 'it',
			format: 'HH:mm:ss'
		}).on("dp.hide", function (e) {
			SalvaDati(codiceDomanda);
		});
	}
	if (txt.hasClass("DateInput")) {
		$('.DateInput').datetimepicker({
			locale: 'it',
			format: "DD/MM/YYYY"
		}).on("dp.hide", function (e) {
			SalvaDati(codiceDomanda);
		});
	}
}

//rimuove un controllo ripetibile.
function RimuoviControlloRipetibile(e, codiceDomanda) {
	//rimuovo il controllo e risalvo i dati.
	$(e).parent().parent().remove();
	SalvaDati(codiceDomanda, "");
}

//Aggiorna la textbox "padre" contenente tutti i valori ripetibili.
function SalvaDati(codiceDomanda) {
	//ottengo la textbox.
	var textbox = $("#hdf" + codiceDomanda);

	//dichiaro una variabile per il valore.
	var textboxValue = "";

	//per ogni input-group nel div, ottengo il controllo e salvo il valore dentro textboxValue.
	$("#" + codiceDomanda + " .input-group .form-control").each(function () {
		if ($(this).val() !== "" && $(this).val() !== null) {
			if (textboxValue === "") {
				textboxValue = $(this).val();
			} else {
				textboxValue += "§;" + $(this).val();
			}
		}
	});

	//cambio il valore della textbox "padre".
	textbox.val(textboxValue);
}


function CopyValueFromCheckBoxList(codiceDomanda) {

    var checkBoxList = $('#datiAggiuntivi table[clientId="' + codiceDomanda + '_checklist"]');
    var textBox = $('#datiAggiuntivi input[clientId="' + codiceDomanda + '"]');

    checkBoxList.find("input").each(function () {

        $(this).change(function () {

            textBox.val('');

            var values = [];

            checkBoxList.find("input").each(function () {

                if ($(this).is(':checked')) {
                    var etichetta = $(this).next().html();
                    var valore = $(this).parent().attr("KeyValue");
                    values.push(valore);
                }
            });
            textBox.val(values.join("§;"));
		});
    });
}