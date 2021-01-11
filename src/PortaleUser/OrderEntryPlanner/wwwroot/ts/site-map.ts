import { attivatorePaginaCalendario } from "./pagina-calendario";
import { attivatorePaginaRicercaOrdine } from "./ricerca-ordini";

export interface pageModule {
    page?: string;
    function?: (destination?: JQuery, template?: any) => void
    menuItem?: string;
}

export var arrayPageModules: pageModule[] = [
    {
        page: "/Pages/Calendario",
        function: function (destination, template) { attivatorePaginaCalendario() },
        menuItem: "pagCalendario"
    },
    {
        page: "/Default",
        menuItem: "pagHome"
    },
    {
        page: "/Pages/RicercaOrdini",
        function: function (destination, template) { attivatorePaginaRicercaOrdine() },
        menuItem: "pagRicerca"
    },
    {
        page: "/Pages/DettaglioOrdine",
        menuItem: "pagRicerca"
    }
];


