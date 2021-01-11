
//$(document).ready(function () {

//    $("#nosologico").focus();
//});

//function CercaPaziente() {
//    var nosologico = $("#nosologico").val();
//    var azienda = $("#CmbAzienda").val();

//    if (nosologico === '')
//        return false;

//    if (azienda === '')
//        return false;


//    /**
//    * Trascodifica prime 2 cifre [ASMN = 3226]
//    * Ottengo le prime due cifre del nosologico e le sostituisco con i valori I o D o P
//    */
//    var primiCaratteri = nosologico.substr(0, 2);
//    var ultimiCaratteri = nosologico.substr(2, nosologico.length)
    
//    switch (primiCaratteri){
//        case "10":
//            nosologico = "I" + ultimiCaratteri;
//            break;
//        case "12":
//            nosologico = "I" + ultimiCaratteri;
//            break;
//        case "11":
//            nosologico = "D" + ultimiCaratteri;
//            break;
//        case "13":
//            nosologico = "P" + ultimiCaratteri;
//            break;
//    }
       
//    var resultText = $("#resultText");
//    resultText.hide()

//    var button = $("#searchButton");

//    button.attr("disabled", "disabled");
//    $("#loader").show();
//    //button.css("background-image", "url(../Images/refresh.gif)");

//    $.ajax({
//    	type: "POST",
//    	url: "AjaxWebMethods/PazientePerNosologicoMethods.aspx/GetIdPaziente",
//    	data: '{"nosologico":"' + nosologico + '","azienda":"'+ azienda +'"}',
//    	contentType: "application/json; charset=utf-8",
//    	dataType: "json",
//    	success: function (result) {

//    		if (result.d == "NoReparto") {

//    			resultText.html("L'utente corrente non è abilitato alla creazione di un ordine per il reparto relativo al nosologico specificato.");
//    			resultText.show();
//    			$("#loader").hide();
//    			button.removeAttr("disabled");
//    			return;
//    		}

//    		if (result.d == "NoRicovero") {

//    			resultText.html("Il nosologico è inesistente.");
//    			resultText.show();
//    			$("#loader").hide();
//    			button.removeAttr("disabled");
//    			return;
//    		}

//    		if (result.d == "NoEventi") {
//    		    resultText.html("Il nosologico non consente di recuperare le informazioni necessarie per procedere perchè il ricovero non possiede eventi.");
//    		    resultText.show();
//    		    $("#loader").hide();
//    		    button.removeAttr("disabled");
//    		    return;
//    		}

//    		if (result.d == "NoInfoRicovero") {
//    			resultText.html("Il nosologico non consente di recuperare le informazioni necessarie per procedere.");
//    			resultText.show();
//    			$("#loader").hide();
//    			button.removeAttr("disabled");
//    			return;
//    		}

//    		if (result.d == "RicoveroChiuso") {
//    			resultText.html("Il ricovero è chiuso.");
//    			resultText.show();
//    			$("#loader").hide();
//    			button.removeAttr("disabled");
//    			return;
//    		}

//    		if (result.d == "RepartoNonValorizzato") {
//    		    resultText.html("Per questo nosologico non è stato valorizzato il reparto di ricovero.");
//    		    resultText.show();
//    		    $("#loader").hide();
//    		    button.removeAttr("disabled");
//    		    return;
//    		}


//    		// formato : [idpaziente]§[codice unità operativa]
//    		var idPazienteUO = result.d;
//    		var sArray = idPazienteUO.split("§");
//    		var idPaziente = sArray[0];
//    		var uo = sArray[1];
//    		//var azienda = $('.hidAzienda input').val();
//    		var aziendauo = azienda + '-' + uo
//    		SalvaBozzaRichiesta(idPaziente, nosologico, aziendauo);
//    	    //button.css("background-image", "url(../Images/find.png)");
//    		$("#loader").hide();
//    		button.removeAttr("disabled");
//    	},
//    	error: function (error) {
//    		resultText.html("Si è verificato un errore.");
//    		resultText.show();
//    	    //button.css("background-image", "url(../Images/find.png)");
//    		$("#loader").hide();
//    		button.removeAttr("disabled");
//    		var message = GetMessageFromAjaxError(error.responseText); alert(message);
//    	}
//    });
//}

//function SalvaBozzaRichiesta(idSac, nosologico, aziendauo) {


	
//    $.ajax({
//        type: "POST",
//        url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/SalvaBozzaRichiesta",
//        data: '{"idSac":"' + idSac + '","nosologico":"' + nosologico + '","aziendauo":"' + aziendauo + '"}',
//        contentType: "application/json; charset=utf-8",
//        dataType: "json",
//        success: function (result) {

//            if (result.d == null) {

//                alert('Si è verificato un errore');
                
//                return false;
//            }

//            var idRichiesta = result.d;

//            location.href = "ComposizioneOrdine.aspx?IdPaziente=" + idSac + "&IdRichiesta=" + idRichiesta + (nosologico ? ('&Nosologico=' + nosologico) : '') + (aziendauo ? ('&AziendaUo=' + aziendauo) : '');
//        },
//        error: function (error) {

            
//            var message = GetMessageFromAjaxError(error.responseText); alert(message);
//        }
//    });
//}

