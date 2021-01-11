
$(document).ready(function () {

	//acrrocc per hover in IE
	$("input").hover(function () {

		$(this).addClass("inputHover");

	}, function () {

		$(this).removeClass("inputHover");
	});

	//accroccs
	$("input[type = 'checkbox'], input[type = 'radio']").css({ "background": "transparent", "border-style": "none" });

	//$(".TreeLeafNode").prev().prev().hide()  QUESTO E' LA CAUSA DELL'ERRATA VISUALIZZAZIONE DEL TREEVIEW
});


var _index = 0;

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
			// error: function (error) { alert(msg.d); } //<----cambiare messaggio?
			error: function (error) {

				var message = GetMessageFromAjaxError(error.responseText);
				alert(message);
			}
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

	$.timepicker.regional['it'] = {
		timeOnlyTitle: 'Seleziona un orario',
		timeText: 'Orario',
		hourText: 'Ora',
		minuteText: 'Minuti',
		secondText: 'Secondi',
		currentText: 'Ora',
		closeText: 'Ok',
		ampm: false
	};
	$.timepicker.setDefaults($.timepicker.regional['it']);
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

/**Cookie**/

function CreateCookie(name, value, days) {

	var expires = '';

	if (days) {

		var date = new Date();
		date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));

		expires = "; expires=" + date.toGMTString();
	}

	document.cookie = name + "=" + value + expires + "; path=/";
}

function ReadCookie(nomeCookie) {

	if (document.cookie.length > 0) {

		var inizio = document.cookie.indexOf(nomeCookie + "=");

		if (inizio != -1) {

			inizio = inizio + nomeCookie.length + 1;
			var fine = document.cookie.indexOf(";", inizio);

			if (fine == -1) fine = document.cookie.length;

			return unescape(document.cookie.substring(inizio, fine));
		} else {
			return '';
		}
	}
	return '';
}


/******** GRID  ***************/
//seleziona/deseleziona tutte le checkbox di una griglia
function SelectDeselectAll(caller, grid) {

	var checked = caller.attr('checked');

	if (checked == 'checked') {

		grid.find(".gridCheckBox").each(function () {

			$(this).attr('checked', 'checked');

			$(this).parent().parent().addClass('GridSelected');
		});

	} else {

		grid.find(".gridCheckBox").each(function () {

			$(this).removeAttr('checked');

			$(this).parent().parent().removeClass('GridSelected');
		});
	}
}

/*
CICLA SULLE RIGHE DELLA TABLE E APPLICA LE CLASSI GridItem/GridAlternatingItem A RIGHE ALTERNE   */
function GridApplyRowStyle(id) {
	if (document.getElementsByTagName) {
		var table = document.getElementById(id);
		var rows = table.getElementsByTagName("tr");
		for (i = 0; i < rows.length; i++) {
			if (i % 2 == 0) {
				rows[i].className = "GridAlternatingItem";
			} else {
				rows[i].className = "GridItem";
			}
		}
	}
}

/******** ENDN GRID ***************/

function GetMessageFromAjaxError(responseText) {

	return eval("(" + responseText + ")").Message;
}

function SetLoaderForButton(buttonSelector, setLoaderOn) {

	var button = $(buttonSelector);

	if (setLoaderOn) {

		button.attr("disabled", "disabled");
		button.css("background-image", "url(../Images/refresh.gif)");
	}
	else {

		button.css("background-image", "none");
		button.removeAttr("disabled");
	}
}

function HtmlEncode(source) {

	var div = document.createElement("div");

	div.innerText = div.textContent = source;

	return div.innerHTML;
}

function FillSelectFromGridColumnDistinctValues(gridId, columnIndex, selectId) {

	var items = [], options = [], distinctItems = [];

	$('#' + gridId + '>tbody>tr>td:nth-child(' + columnIndex + ')').each(function () {

		var value = $.trim($(this).text());

		if (value && value != '')
			items.push(value);
	});

	distinctItems = unique(items);

	$.each(distinctItems, function (i, item) {
		options.push('<option value="' + item + '">' + item + '</option>');
	});

	$('#' + selectId).append(options.join());
}

function unique(array) {
	return $.grep(array, function (el, index) {
		return index == $.inArray(el, array);
	});
}

function htmlDecode(value) {

	if (value) {
		return $('<div />').html(value).text();
	} else {
		return '';
	}
}

if (typeof escapeHtmlEntities == 'undefined') {
	escapeHtmlEntities = function (text) {
		return text.replace(/[\u00A0-\u2666<>\&]/g, function (c) {
			return '&' +
                (escapeHtmlEntities.entityTable[c.charCodeAt(0)] || '#' + c.charCodeAt(0)) + ';';
		});
	};

	escapeHtmlEntities.entityTable = {
		34: 'quot',
		38: 'amp',
		39: 'apos',
		60: 'lt',
		62: 'gt',
		160: 'nbsp',
		161: 'iexcl',
		162: 'cent',
		163: 'pound',
		164: 'curren',
		165: 'yen',
		166: 'brvbar',
		167: 'sect',
		168: 'uml',
		169: 'copy',
		170: 'ordf',
		171: 'laquo',
		172: 'not',
		173: 'shy',
		174: 'reg',
		175: 'macr',
		176: 'deg',
		177: 'plusmn',
		178: 'sup2',
		179: 'sup3',
		180: 'acute',
		181: 'micro',
		182: 'para',
		183: 'middot',
		184: 'cedil',
		185: 'sup1',
		186: 'ordm',
		187: 'raquo',
		188: 'frac14',
		189: 'frac12',
		190: 'frac34',
		191: 'iquest',
		192: 'Agrave',
		193: 'Aacute',
		194: 'Acirc',
		195: 'Atilde',
		196: 'Auml',
		197: 'Aring',
		198: 'AElig',
		199: 'Ccedil',
		200: 'Egrave',
		201: 'Eacute',
		202: 'Ecirc',
		203: 'Euml',
		204: 'Igrave',
		205: 'Iacute',
		206: 'Icirc',
		207: 'Iuml',
		208: 'ETH',
		209: 'Ntilde',
		210: 'Ograve',
		211: 'Oacute',
		212: 'Ocirc',
		213: 'Otilde',
		214: 'Ouml',
		215: 'times',
		216: 'Oslash',
		217: 'Ugrave',
		218: 'Uacute',
		219: 'Ucirc',
		220: 'Uuml',
		221: 'Yacute',
		222: 'THORN',
		223: 'szlig',
		224: 'agrave',
		225: 'aacute',
		226: 'acirc',
		227: 'atilde',
		228: 'auml',
		229: 'aring',
		230: 'aelig',
		231: 'ccedil',
		232: 'egrave',
		233: 'eacute',
		234: 'ecirc',
		235: 'euml',
		236: 'igrave',
		237: 'iacute',
		238: 'icirc',
		239: 'iuml',
		240: 'eth',
		241: 'ntilde',
		242: 'ograve',
		243: 'oacute',
		244: 'ocirc',
		245: 'otilde',
		246: 'ouml',
		247: 'divide',
		248: 'oslash',
		249: 'ugrave',
		250: 'uacute',
		251: 'ucirc',
		252: 'uuml',
		253: 'yacute',
		254: 'thorn',
		255: 'yuml',
		402: 'fnof',
		913: 'Alpha',
		914: 'Beta',
		915: 'Gamma',
		916: 'Delta',
		917: 'Epsilon',
		918: 'Zeta',
		919: 'Eta',
		920: 'Theta',
		921: 'Iota',
		922: 'Kappa',
		923: 'Lambda',
		924: 'Mu',
		925: 'Nu',
		926: 'Xi',
		927: 'Omicron',
		928: 'Pi',
		929: 'Rho',
		931: 'Sigma',
		932: 'Tau',
		933: 'Upsilon',
		934: 'Phi',
		935: 'Chi',
		936: 'Psi',
		937: 'Omega',
		945: 'alpha',
		946: 'beta',
		947: 'gamma',
		948: 'delta',
		949: 'epsilon',
		950: 'zeta',
		951: 'eta',
		952: 'theta',
		953: 'iota',
		954: 'kappa',
		955: 'lambda',
		956: 'mu',
		957: 'nu',
		958: 'xi',
		959: 'omicron',
		960: 'pi',
		961: 'rho',
		962: 'sigmaf',
		963: 'sigma',
		964: 'tau',
		965: 'upsilon',
		966: 'phi',
		967: 'chi',
		968: 'psi',
		969: 'omega',
		977: 'thetasym',
		978: 'upsih',
		982: 'piv',
		8226: 'bull',
		8230: 'hellip',
		8242: 'prime',
		8243: 'Prime',
		8254: 'oline',
		8260: 'frasl',
		8472: 'weierp',
		8465: 'image',
		8476: 'real',
		8482: 'trade',
		8501: 'alefsym',
		8592: 'larr',
		8593: 'uarr',
		8594: 'rarr',
		8595: 'darr',
		8596: 'harr',
		8629: 'crarr',
		8656: 'lArr',
		8657: 'uArr',
		8658: 'rArr',
		8659: 'dArr',
		8660: 'hArr',
		8704: 'forall',
		8706: 'part',
		8707: 'exist',
		8709: 'empty',
		8711: 'nabla',
		8712: 'isin',
		8713: 'notin',
		8715: 'ni',
		8719: 'prod',
		8721: 'sum',
		8722: 'minus',
		8727: 'lowast',
		8730: 'radic',
		8733: 'prop',
		8734: 'infin',
		8736: 'ang',
		8743: 'and',
		8744: 'or',
		8745: 'cap',
		8746: 'cup',
		8747: 'int',
		8756: 'there4',
		8764: 'sim',
		8773: 'cong',
		8776: 'asymp',
		8800: 'ne',
		8801: 'equiv',
		8804: 'le',
		8805: 'ge',
		8834: 'sub',
		8835: 'sup',
		8836: 'nsub',
		8838: 'sube',
		8839: 'supe',
		8853: 'oplus',
		8855: 'otimes',
		8869: 'perp',
		8901: 'sdot',
		8968: 'lceil',
		8969: 'rceil',
		8970: 'lfloor',
		8971: 'rfloor',
		9001: 'lang',
		9002: 'rang',
		9674: 'loz',
		9824: 'spades',
		9827: 'clubs',
		9829: 'hearts',
		9830: 'diams',
		338: 'OElig',
		339: 'oelig',
		352: 'Scaron',
		353: 'scaron',
		376: 'Yuml',
		710: 'circ',
		732: 'tilde',
		8194: 'ensp',
		8195: 'emsp',
		8201: 'thinsp',
		8204: 'zwnj',
		8205: 'zwj',
		8206: 'lrm',
		8207: 'rlm',
		8211: 'ndash',
		8212: 'mdash',
		8216: 'lsquo',
		8217: 'rsquo',
		8218: 'sbquo',
		8220: 'ldquo',
		8221: 'rdquo',
		8222: 'bdquo',
		8224: 'dagger',
		8225: 'Dagger',
		8240: 'permil',
		8249: 'lsaquo',
		8250: 'rsaquo',
		8364: 'euro'
	};
}


// MOSTRA UNA MESSAGEBOX CON DUE PULSANTI 'YES' 'NO', 
// RITORNA TRUE/FALSE, CREA ANCHE UN HIDDEN FIELD 'confirm_value' CON IL RISULTATO 'Yes'/'No'
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



// MOSTRA UNA MESSAGEBOX DIALOG JQUERY-UI CON UN TASTO OK
function msgboxDIALOG(Messaggio, Titolo) {
	$(function () {
		var newDiv = $(document.createElement('div'));
		newDiv.html(Messaggio);
		newDiv.dialog(
		{
			modal: true,
			height: 250,
			position: 'center',
			resizable: false,
			title: Titolo,
			buttons: {
				Close: function () {
					$(this).dialog('close');
				}
			},
			open: function (event, ui) {
				$('body').addClass('stop-scrolling')
			},
			close: function (event, ui) {
				$('body').removeClass('stop-scrolling')
			}
		});
	});
}


//Popup Standard per selezione file CSV
function PopUpDialogImportaDaCsv(Width, Height) {
	var dialog = $("#importaDaCsv").dialog({
		width: Width,
		height: Height,
		modal: true,
		position: 'center',
		title: "Importa da file .csv",
		resizable: false,
		open: function (event, ui) {
			$('body').addClass('stop-scrolling')
		},
		close: function (event, ui) {
			$('body').removeClass('stop-scrolling')
		},
		buttons:
             {
             	"OK": function () { $(".importFake").trigger('click'); },
             	"Annulla": function () { $(this).dialog('close'); }
             }
	});
	dialog.parent().appendTo($("form:first"));
}        