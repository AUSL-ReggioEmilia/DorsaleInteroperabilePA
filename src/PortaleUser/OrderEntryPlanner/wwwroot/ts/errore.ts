import { SingletonAppInsights } from './application-insights';

export class Errore {

    public tracciaErrore(ex: any, nomeMetodo: string) {
        //Mostra un div di errore.
        this.showError();

        //Scrivo l'errore in console.
        console.log("Errore in:" + nomeMetodo);

        //Traccio l'errore su AppInsights.
        SingletonAppInsights.getInstance().appInsights.trackException(ex, nomeMetodo, null);
    }

    //Funzione che visualizza un div di errore contenuto nella master page.
    private showError() {
        let divError: JQuery<HTMLElement> = $("#DivError");
        divError.text("Si è verificato un errore.");
        divError.show();
    }
}
