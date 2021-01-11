//librerie esterne
import * as $ from 'jquery'
import 'fullcalendar'
import 'jqueryui'

//css librerie esterne
import 'bootstrap/dist/css/bootstrap.min.css';
import '../../wwwroot/css/bootstrap.min.css';
import 'fullcalendar/dist/fullcalendar.min.css';
import 'eonasdan-bootstrap-datetimepicker/build/css/bootstrap-datetimepicker.min.css';

//css interni
import '../../wwwroot/css/fullcalendar.css';
import '../../wwwroot/css/site.css';
import '../../wwwroot/css/menu.css';

//librerie interne
import { arrayPageModules } from './site-map';
import { Errore } from './errore';

$(document).ready(function () {
    try {
        //ottengo l'url corrente.
        let currentUrl: string = document.URL;

        //in base alla pagina corrente attivo la funzione corretta.
        for (let i = 0; i < arrayPageModules.length; i++) {
            if (currentUrl.indexOf(arrayPageModules[i].page) !== -1) {
                if (arrayPageModules[i].function) {
                    arrayPageModules[i].function();
                }
                //attivo l'item corretto del menu.
                attivaMenuItemCorrente(arrayPageModules[i].menuItem);
            }
        }

        //Rendering per Bootstrap: permette di non chiudere il dropdown-menu al click nel suo contenuto
        $('.dropdown-menu').click(function (e) {
            e.stopPropagation();
        });

    } catch (ex) {
        let err: Errore = new Errore
        err.tracciaErrore(ex, "document.ready_main.ts");
    }
});

//Funzione che attiva l'item corretto nel menu.
function attivaMenuItemCorrente(idMenuItem: string) {
    console.log(idMenuItem);
    $(`#${idMenuItem}`).addClass("active");
}

