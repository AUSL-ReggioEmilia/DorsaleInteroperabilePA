import 'eonasdan-bootstrap-datetimepicker';
import { SingletonAppInsights } from './application-insights';
import { Errore } from './errore';

export function attivatorePaginaRicercaOrdine() {
    attivaDateTimePicker($(".form-control-datatimepicker"));
    gestisciRicercaAvanzata();
}

/// <summary>
///  Crea i DateTimePicker.
/// </summary>
function attivaDateTimePicker(dateTimePicker: JQuery) {
    try {
        $(".form-control-datatimepicker").datetimepicker({
            locale: 'it',
            format: "DD/MM/YYYY"
        });

    }
    catch (ex) {
        SingletonAppInsights.getInstance().appInsights.trackException(ex, "Metodo: attivaDateTimePicker", null);
    }
}

/// <summary>
///  Gestisce il collapse per la ricerca avanzata.
/// </summary>
function gestisciRicercaAvanzata() {
    try {

        // cambio il testo del link "ricercaavanzata" quando collasso il pannello dei filtri
        $('#ricercaAvanzata').click(function () {
            $(this).text(function (i, testo) {
                return testo == '(Ricerca avanzata)' ? '(Chiudi ricerca avanzata)' : '(Ricerca avanzata)';
            });
        });

        $("#pannelloRicercaAvanzata").on('shown.bs.collapse', function () {
            // salvo il valore dalla session storage quando sto mostrando il pannello dei filtri
            var active = $(this).attr('id');
            sessionStorage.setItem("collapsedDivState", active);
        });

        $("#pannelloRicercaAvanzata").on('hidden.bs.collapse', function () {
            // rimuovo il valore dalla session storage quando sto nascondendo il pannello dei filtri            
            sessionStorage.removeItem('collapsedDivState');
        });

        var last = sessionStorage.getItem('collapsedDivState');

        console.log("last = " + last);

        if (last != null) {
            // se il campo e' valorizzato alloro imposto la classe in ( espanso )
            $("#pannelloRicercaAvanzata").removeClass('in');
            $("#" + last).addClass("in");

            // setto il testo nel link
            $('#ricercaAvanzata').text('(Chiudi ricerca avanzata)');
        }

    }
    catch (ex) {
        let err: Errore = new Errore
        err.tracciaErrore(ex, "Metodo: gestisciRicercaAvanzata");
    }
}

