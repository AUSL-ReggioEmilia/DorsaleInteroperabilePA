using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DI.BiztalkMonitor.Site.State
{
    public class MessaggiScartatiFilterState
    {
        public int Periodo { get; set; } = 1;
        public string Errore { get; set; } = "";
        public string NomeOrchestrazione { get; set; } = "";
        public string Utente { get; set; } = "";
        public int IdStato { get; set; } = 3;

        // Bool Utente Readonly
        public bool UtenteReadonly { 
            get
            {
                return IdStato == 4;
            }
        }


        public void Clear()
        {
            this.Periodo = 1;
            this.Errore = "";
            this.NomeOrchestrazione = "";
            this.Utente = "";
            this.IdStato = 3;
        }

    }
}
