//si usa la funzione pageLoad(), che scatta alla fine del caricamento della pagina e tuitte le volte che si fa refresh di un update panel
function pageLoad(sender, args) {
    $(document).ready(function () {

        //Quando si clicca un preferito nella drop down list viene aperta la modale e viene aggiunto l'inririzzo email nella lista dei destinatari
        //Se la lista dei destinatari non è vuota si mette il focus sul corpo del messaggio altrimenti sulla textbox del cognome nella ricerca degli utenti
        $('#modaleInvioEmail').on('shown.bs.modal', function (e) {
            if ($('#txtListaDestinatari').tokenfield('getTokens').length == 0) {
                $('#txtCognome').focus();
            }
            else {
                $('#txtCorpoMessaggio').focus();
            }
        });


        //ogni volta che si preme un pulsante sulla tastiera eseguo la funzione myKeyDownHandler.
        document.onkeydown = function myKeyDownHandler() {
            //vado avanti solo se ho premuto "Enter" 
			if (event.keyCode === 13) {
				//event.preventDefault();
                //se è visibile il dive della ricerca dei destinatari iposto il focus sul pulsante di ricerca degli utenti
                //altrimenti sul pulsante di invio email (poichè è visibile il div di invio email)
				if ($('#divRicercaDestinatari').is(':visible')) {
					$('#btnCercaUtenti').focus();
				}
				//Questa parte consentiva di inviare la mail alla pressione del tasto Enter
				//All'inizio ce l'avevano richiesta, poi l'hanno voluta togliere
                //else {
                //    $('#btnInviaMail').focus();
                //}
            };
        };

        //Gestisce l'onclick sull'item selezionato fra i preferiti
        $(".btn-email").click(function () {
            //nascondo la rierca 
            $('#divRicercaDestinatari').hide();
            //motro il div per l'invio della mail
            $('#divInvioMail').show();
            //ottengo ll'indirizzo email selezionato tramite il custom attribute e llo aggiungo alla lista dei destinatari
            var email = $(this).data("email");
            $('#txtListaDestinatari').tokenfield('setTokens', email);
            //eseguo l'ìupdate dell'upsdate panel (la variabile upd è definita all'interno dello user control)
            __doPostBack(upd, '');
            //visualizzo la modale
            $('#modaleInvioEmail').modal('show');
        });



    });


    //gestisce il click sul pulsante che apre la modale
    $("#btnApriInvioMail").click(function () {
        //mostra il div della ricerca
        $('#divRicercaDestinatari').show();
        //nasconde il div dell'invio
        $('#divInvioMail').hide();
        //mostra la modale
        $('#modaleInvioEmail').modal('show');
    });


    /*  
    Funzione che crea i  dei tokenfield per la selezione degli utenti.
    Sito ufficiale: http://sliptree.github.io/bootstrap-tokenfield/
     */
    jQuery(function ($) {
        $('#txtListaDestinatari')
            .on('tokenfield:createtoken', function (e) {
                var data = e.attrs.value.split('|')
                e.attrs.value = data[1] || data[0]
                e.attrs.label = data[1] ? data[0] + ' (' + data[1] + ')' : data[0]
            })
            .on('tokenfield:createdtoken', function (e) {
                // Über-simplistic e-mail validation
                var re = /\S+@\S+\.\S+/
                var valid = re.test(e.attrs.value)
                if (!valid) {
                    $(e.relatedTarget).addClass('invalid')
                }
            })
            .on('tokenfield:edittoken', function (e) {
                if (e.attrs.label !== e.attrs.value) {
                    var label = e.attrs.label.split(' (')
                    e.attrs.value = label[0] + '|' + e.attrs.value
                }
            })
            .tokenfield({
                //Imposto come delimiter anche lo spazio in modo che venga creato un nuovo token alla pressione della spacebar.
                //Il delimeter di default è ","
                delimiter: [',', ' ']
            });
    });

};