//Funzione chiamata quando usciamo dalle pagina di composizione di un ordine.
function ConfirmMessage(message, url) {
    var i = confirm(message);
    if (i === true) {
        window.location.href = url;
    } else {
        return false;
    }
}

function trackError(event) {
	try {
		console.log("OrderEntry: " + event.message);
		appInsights.TrackException("OrderEntry: eccezione " + event.message);
		alert("OrderEntry: " + event.message);
	} catch (e) {
		console.log("OrderEntry: " + e.message);
	}
}


//Script per validatori.
function extendedValidatorUpdateDisplay(obj) {
    if (typeof originalValidatorUpdateDisplay === "function") {
        originalValidatorUpdateDisplay(obj);
    }
    var control = document.getElementById(obj.controltovalidate);
    if (control) {
        var isValid = true;
        for (var i = 0; i < control.Validators.length; i += 1) {
            if (!control.Validators[i].isvalid) {
                isValid = false;
                break;
            }
        }
        if (isValid) {
            $(control).closest(".form-group").removeClass("has-error");
        } else {
            $(control).closest(".form-group").addClass("has-error");
        }
    }
}

var originalValidatorUpdateDisplay = extendedValidatorUpdateDisplay;

//Apre la modale di caricamento
function ShowModalCaricamento() {
    try {
        //$("#modalCaricamento").modal("show");
    }
    catch (ex) {
        alert("Si è verificato un errore durante la visualizzazione dei dati.");
    }
}

function ShowModalCaricamentoConValidatori() {
    try {
        //Se Page_ClientValidate <> "function" allora non ci sono validatori nella pagina.
        //if (typeof Page_ClientValidate === "function") {
        //    if (Page_ClientValidate()) {
        //        $("#modalCaricamento").modal("show");
        //    }
        //} else {
        //    $("#modalCaricamento").modal("show");
        //}
    }
    catch (ex) {
        alert("Si è verificato un errore durante la visualizzazione dei dati.");
    }
}