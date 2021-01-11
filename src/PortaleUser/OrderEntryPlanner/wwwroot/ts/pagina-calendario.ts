//librerie esterne
import { EventObjectInput } from "fullcalendar";
import interactionPlugin from 'fullcalendar/Interaction';
import dayGridPlugin from 'fullcalendar/DayGrid';
import timeGridPlugin from 'fullcalendar/TimeGrid';
import * as moment from 'moment';

//librerie interne
import { Errore } from "./errore";
import { Utility } from "./utility";

//constanti interne
const templateEventoDaRiprogrammare = "<div class='fc-event ui-draggable ui-draggable-handle fc-event-daRiprogrammare'><div id='divTitle'></div></div>"
const localStorageSistemaErogante = "localstorage_sistema_erogante"

export function attivatorePaginaCalendario() {
    try {
        //chiamata ajax per la lista degli ordini riprogrammati.
        attivaCalendario($("#calendario"));

        //NB: tramite window[] in questo modo riesco a utilizzare la funzione dal markup.
        window["aggiornaEventi"] = aggiornaEventi;
        window["removeBlinkClass"] = removeBlinkClass;
        window["SetValoreSistemaErogante"] = SetValoreSistemaErogante(<HTMLSelectElement>document.getElementById("ddlSistema"));

        //Ottiene il dettaglio dell'ordine.
        OttieniDettaglioOrdine();

        //Serve per mostrare il tooltip quando si passa con il mouse su un evento.
        //TODO: dove posso spostarlo per farlo funzionare anche quando cambio visualizzazione del calendario? 
        //$(".fc-event").each(function () {
        //    $(this).attr("title", $(this + " .fc-title").text());
        //})
    } catch (ex) {
        let err: Errore = new Errore
        err.tracciaErrore(ex, "metodo: attivatorePaginaCalendario");
    }
}

//Funzione che ottine il dettaglio di un ordine.
function OttieniDettaglioOrdine() {
    try {
        let utility: Utility = new Utility();
        let idOrdine: string = utility.getParameterByName("IdOrdine");

        console.log(`IdOrdineDaRiprogrammare = ${idOrdine}.`);

        if (idOrdine != null && idOrdine != "") {
            let ajaxParameter: string = JSON.stringify({ 'IdOrdine': idOrdine });

            //eseguo la chiamata ajax
            $.ajax({
                type: "POST",
                url: "../Components/AjaxWebMethod.asmx/OttieniOrdineById",
                data: ajaxParameter,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (result) {
                    //ottengo l'array contenente gli ordini.
                    let array: any = JSON.parse(result.d);

                    if (array != null) {
                        let ddlSistemaErogante: HTMLSelectElement = <HTMLSelectElement>document.getElementById("ddlSistema");
                        ddlSistemaErogante.value = `${array[0].SistemaEroganteCodice}@${array[0].SistemaEroganteAziendaCodice}`;
                        AggiornaCalendario($("#calendario"));

                        //Attengo la conclusione di aggiornaCalendario.
                        $(document).ajaxStop(function () {
                            if (array[0].DataPianificazione != null) {
                                let dataPrenotazione: Date = new Date(array[0].DataPianificazione);
                                let dataPrenotazioneMoment = moment(dataPrenotazione);
                                $("#calendario").fullCalendar("gotoDate", dataPrenotazioneMoment);

                                console.log(`id-${array[0].Id}`);
                                let eventiCalendario: HTMLCollectionOf<Element> = document.getElementsByClassName(`id-${array[0].Id}`);
                                if (eventiCalendario != null && eventiCalendario.length > 0) {
                                    var evento = eventiCalendario[0];
                                    evento.className = `${evento.className} blink`;
                                    window.setTimeout('removeBlinkClass()', 5000);
                                }
                            } else {
                                // l'evento è nella lista degli ordini da riprogrammare.
                                //'data-idordine'
                                let divOrdiniDaProgrammare: JQuery<HTMLElement> = $("#divOrdiniDaRiprogrammare .fc-event");
                                if (divOrdiniDaProgrammare != null && divOrdiniDaProgrammare.length > 0) {
                                    divOrdiniDaProgrammare.each(function () {
                                        let idOridne: string = $(this).data("idordine");
                                        let idOrdineArray: string = <string>array[0].Id;
                                        if (idOridne.toUpperCase() == idOrdineArray.toUpperCase()) {
                                            $(this).addClass("blink");
                                            window.setTimeout('removeBlinkClass()', 5000);
                                        }
                                    });
                                }
                            }
                        });

                        caricaEventiDaRiprogrammare();
                    }
                }
            });
        } else {
            caricaEventiDaRiprogrammare();
        }
    } catch (ex) {
        let err: Errore = new Errore
        err.tracciaErrore(ex, "metodo: OttieniDettaglioOrdine");
    }
}

//Funzione che rimuove l'evento con la classe "Blink" usata per evidenziarlo.
function removeBlinkClass() {
    let blinkEvent: HTMLCollectionOf<Element> = document.getElementsByClassName("blink");

    if (blinkEvent != null && blinkEvent.length > 0) {
        blinkEvent[0].className = blinkEvent[0].className.replace("blink", "");
    }
};

//Funzione che crea il caledario contenente gli ordini riprogrammati
function attivaCalendario(divCalendario: JQuery) {
    try {
        //Ottiene la dropdownlist dei sistemi eroganti
        let sistemaErogante: HTMLSelectElement = <HTMLSelectElement>document.getElementById("ddlSistema");

        if (sistemaErogante != null) {
            divCalendario.fullCalendar({
                themeSystem: 'bootstrap3',
                editable: true,
                eventDurationEditable: false,
                droppable: true,
                locale: 'it',
                navLinks: true,
                nowIndicator: true,
                eventLimit: true,
                eventClick: function (calEvent) {
                    let arrayId: Array<string> = calEvent.id.toString().split("@");

                    let urlCorrente: string = window.location.href;
                    let siteName: string = "/OrderEntryPlanner";

                    if (urlCorrente != null && (urlCorrente.indexOf(siteName) == -1)) {
                        siteName = "";
                    }

                    //Navigo alla pagina di dettaglio dell'ordine.
                    window.location.href = `${siteName}/Pages/DettaglioOrdine.aspx?IdOrdine=${arrayId[0]}&FromCalendario=1`
                },
                eventDrop: function (calEvent, delta, revertFunc) {
                    if (confirm("Sei sicuro di voler modificare la data di prenotazione?")) {
                        let millisecond: number = Number(calEvent.start);
                        let dataNew: Date = new Date(millisecond);

                        let arrayId: Array<string> = calEvent.id.toString().split("@");

                        cambiaDataPrenotazione(arrayId[0], dataNew, arrayId[1], false);
                    } else {
                        revertFunc();
                    }
                },
                drop: function (date) {
                    if (confirm("Sei sicuro di voler modificare la data di prenotazione?")) {
                        let evento: EventObjectInput = $(this).data('event');
                        if (evento != null) {
                            let dataNew: Date = new Date(date.toString());
                            let arrayId: Array<string> = evento.id.toString().split("@");
                            cambiaDataPrenotazione(arrayId[0], dataNew, arrayId[1], true);
                        }
                    }
                },
                views: {
                    month: {
                        timeFormat: 'HH(:mm)',
                    },
                    week: {
                        columnHeaderFormat: "ddd D/M"
                    },
                    day: {
                        slotLabelFormat:
                            "HH(:mm)"
                    },
                    agenda: {
                        eventLimit: 6
                    }
                },
                header:
                {
                    left: 'title',
                    center: 'myCustomButton',
                    right: 'today,month,agendaWeek,agendaDay,prev,next'
                },
                buttonText: {
                    today: 'Oggi',
                    month: 'Mese',
                    week: 'Settimana',
                    day: 'Giorno',
                    list: 'Lista'
                },
                dayClick: function (data) {
                    divCalendario.fullCalendar('changeView', "agendaDay", data);
                }
            })
        }

        $("#divSistema").appendTo(".fc-center");
    }
    catch (ex) {
        let err: Errore = new Errore
        err.tracciaErrore(ex, "metodo: attivaCalendario");
    }
}

//Funzione che attiva il Drag&Drop per gli ordini da riprogrammare
function attivatoreDragAndDrop() {
    try {
        console.log(`Numero di ordini da riprogrammare: ${$('.external-events .fc-event').length}`);
        //Rendo attivo il drag&drop per gli ordini da riprogrammare
        $('.external-events .fc-event').each(function () {
            // store data so the calendar knows to render an event upon drop
            $(this).data('event', {
                title: $.trim($(this).text()), // use the element's text as the event title
                stick: true, // maintain when user navigates (see docs on the renderEvent method)
                id: $(this).data("idordine")
            });

            // make the event draggable using jQuery UI
            $(this).draggable({
                zIndex: 999,
                revert: true,      // will cause the event to go back to its
                revertDuration: 0
            });
        });

    }
    catch (ex) {
        let err: Errore = new Errore
        err.tracciaErrore(ex, "metodo: attivatoreDragAndDrop");
    }
}

//Funzione usata per aggiornare gli ordini presenti nel calendario.
function AggiornaCalendario(divCalendario: JQuery) {
    try {
        let sistemaErogante: HTMLSelectElement = <HTMLSelectElement>document.getElementById("ddlSistema");

        if (sistemaErogante != null) {
            let ajaxParameter: string = JSON.stringify({ 'SistemaErogante': sistemaErogante.value });

            //eseguo la chiamata ajax
            $.ajax({
                type: "POST",
                url: "../Components/AjaxWebMethod.asmx/ListaOrdiniProgrammati",
                data: ajaxParameter,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (result) {
                    //ottengo l'array contenente gli ordini.
                    let array: any = JSON.parse(result.d);

                    divCalendario.fullCalendar('removeEvents');
                    divCalendario.fullCalendar('addEventSource', array);
                    divCalendario.fullCalendar('rerenderEvents');

              
                }
            });
        }
    }
    catch (ex) {
        let err: Errore = new Errore
        err.tracciaErrore(ex, "metodo: AggiornaCalendario");
    }
}

//Funzione che ricarica la lista degli ordini da riprogrammare
function caricaEventiDaRiprogrammare() {
    try {
        //Creo il parametro da passare all'asmx
        //var ajaxParameter: string = JSON.stringify({ 'idOrdineTestata': idOrdineTestata, 'datiAccessoriCompilati': aDatiAccessori });
        let sistemaErogante: HTMLSelectElement = <HTMLSelectElement>document.getElementById("ddlSistema");

        console.log("valoreSistemaErogantePreEventi" + sistemaErogante.value);

        if (sistemaErogante != null) {
            let ajaxParameter: string = JSON.stringify({ 'SistemaErogante': sistemaErogante.value });
            //eseguo la chiamata ajax
            $.ajax({
                type: "POST",
                url: "../Components/AjaxWebMethod.asmx/ListaOrdiniDaRiprogrammare",
                data: ajaxParameter,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (result: any) {
                    //costruiamo la lista degli ordini da riprogrammare.
                    creaListaEventiDaRiprogrammare(result.d);
                    attivatoreDragAndDrop();
                },
                error: function (e) {
                    //gli passo TrapError = false per evitare di riscrivere l'errore nell'event viewer (lo fa già il metodo SalvaDatiAccessori)
                    alert("si è verificato un errore"); //gestisciErrore(e, false);
                }
            });
        }
    }
    catch (ex) {
        let err: Errore = new Errore
        err.tracciaErrore(ex, "metodo: caricaEventiDaRiprogrammare");
    }
}

//Funzione che crea l'html per la lista degli ordini da riprogrammare
function creaListaEventiDaRiprogrammare(listaEventi: any) {
    try {
        let listaEventiParsed = JSON.parse(listaEventi);
        let divOrdiniDaRiprogrammare: HTMLDivElement = <HTMLDivElement>document.getElementById("divOrdiniDaRiprogrammare");
        divOrdiniDaRiprogrammare.innerHTML = "";
        if (listaEventiParsed.length > 0) {
            for (let i = 0; i < listaEventiParsed.length; i++) {

                let divNuovoEvento: HTMLDivElement = <HTMLDivElement>jQuery.parseHTML(templateEventoDaRiprogrammare)[0];
                divNuovoEvento.children[0].innerHTML = listaEventiParsed[i]["title"];
                divNuovoEvento.setAttribute("data-idOrdine", listaEventiParsed[i]["id"])

                divOrdiniDaRiprogrammare.appendChild(divNuovoEvento);
            }
        } else {
            divOrdiniDaRiprogrammare.innerHTML = "Nessun ordine"
        }
    }
    catch (ex) {
        let err: Errore = new Errore
        err.tracciaErrore(ex, "metodo: creaListaEventiDaRiprogrammare");
    }
}

//Funzione chiamata al SelectIndexChanged della dropdownlist dei sistemi eroganti.
function aggiornaEventi(SistemaEroganteDdl: HTMLSelectElement) {
    try {
        if (SistemaEroganteDdl != null) {
            localStorage.setItem(localStorageSistemaErogante, SistemaEroganteDdl.value);

            AggiornaCalendario($("#calendario"));

            caricaEventiDaRiprogrammare();
        }
    }
    catch (ex) {
        let err: Errore = new Errore
        err.tracciaErrore(ex, "metodo: aggiornaEventi");
    }
}

//Funzione utilizzata per cambiare la data di prenotazione di un ordine.
function cambiaDataPrenotazione(idOrdine: string, dataPrenotazioneNew: Date, idOrderEntry: string, ricalcolaEventiDaProgrammare: boolean) {
    try {
        if (idOrdine != null && dataPrenotazioneNew != null) {
            let ajaxParameter: string = JSON.stringify({ 'IdOrdineTestata': idOrdine, 'DataPrenotazioneNew': dataPrenotazioneNew, 'IdOrderEntry': idOrderEntry });

            //eseguo la chiamata ajax
            $.ajax({
                type: "POST",
                url: "../Components/AjaxWebMethod.asmx/CambiaDataPrenotazione",
                data: ajaxParameter,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function () {
                    console.log(`L'ordine con ID = ${idOrdine} è stato riprogrammato con successo.`);

                    //ricalcolo la lista degli eventi da riprogrammare.
                    caricaEventiDaRiprogrammare();
                },
                error: function () {
                    console.log(`Si è verificato un errore nella riprogrammazione dell'ordine con ID = ${idOrdine}.`);
                }
            });
        }
    }
    catch (ex) {
        let err: Errore = new Errore
        err.tracciaErrore(ex, "metodo: cambiaDataPrenotazione");
    }
}

//Funzione che setta il valore della combo del sistema erogante prendendolo dal local storage
function SetValoreSistemaErogante(SistemaEroganteDll: HTMLSelectElement) {
    try {
        if (SistemaEroganteDll != null) {
            //ottengo il valore dal local storage di HTML
            let valoreSistemaErogante: string = localStorage.getItem(localStorageSistemaErogante);
            console.log("localStorage_valoreSistemaErogante = " + valoreSistemaErogante);

            //se il valore non è vuoto allora lo setto come value della combo
            if (valoreSistemaErogante != null && valoreSistemaErogante.length > 0) {
                SistemaEroganteDll.value = valoreSistemaErogante;

                AggiornaCalendario($("#calendario"));
            }
        }
    }
    catch (ex) {
        let err: Errore = new Errore
        err.tracciaErrore(ex, "metodo: setValoreSistemaErogante");
    }
}