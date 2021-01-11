
//
// PUNTATORE MOUSE ATTESA DURANTE LE CHIAMATE AJAX
//
var prm = Sys.WebForms.PageRequestManager.getInstance();
prm.add_initializeRequest(InitializeRequest);
prm.add_endRequest(EndRequest);

function InitializeRequest(sender, args) {
    try {
        // DISABILITO IL PULSANTE CHE HA CAUSATO IL POSTBACK
        $get(args._postBackElement.id).disabled = true;
    }
    catch (error) { }
    finally {
        //PUNTATORE ATTESA                
        document.body.style.cursor = 'wait';
    }
}

function EndRequest(sender, args) {
    try {
        // RIABILITO IL PULSANTE CHE AVEVA CAUSATO IL POSTBACK
        $get(sender._postBackSettings.sourceElement.id).disabled = false;
    }
    catch (error) { }
    finally {
        //PUNTATORE NORMALE
        document.body.style.cursor = 'auto';
    }
}

$(document).ready(function () {
    $('.navbar-collapsMenu1 .selected').parent().addClass('active');
    $('.navbarMenu2 .selected').parent().addClass('active');

    //Rendering per Bootstrap: permette di non chiudere il dropdown-menu al click nel suo contenuto
    $('.dropdown-menu').click(function (e) {
        e.stopPropagation();
    });

    // CREO I TOOLTIP BOOTSTRAP PER LE ANTEPRIME DEI REFERTI CONTENUTE NELLE TABELLE
    $(function () {
        $('[data-toggle="tooltip"]').tooltip()
    })
});

//CREO I BOOTSTRAP DATETIMEPICKER
$('.form-control-dataPicker').datepicker({
    format: "dd/mm/yyyy",
    weekStart: 1,
    language: "it",
    todayHighlight: true,
    todayBtn: "linked",
    orientation: "bottom left"
});


//

// COLORAZIONE DEI form-group IN CASO DI VALIDAZIONE FALLITA

//

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

var originalValidatorUpdateDisplay = window.ValidatorUpdateDisplay;
window.ValidatorUpdateDisplay = extendedValidatorUpdateDisplay;


