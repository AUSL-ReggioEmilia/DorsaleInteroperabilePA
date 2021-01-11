using System;
using System.Collections.Generic;
using System.Diagnostics.Eventing.Reader;
using System.Linq;
using System.Web;

namespace OrderEntryPlanner.Components.DataSources
{
    [global::System.ComponentModel.DataObjectAttribute(true)]
    public class PazienteDettaglioDataSource : CacheDataSource<WcfPazienti.PazienteType>
    {
        [global::System.ComponentModel.DataObjectMethod(System.ComponentModel.DataObjectMethodType.Select)]
        public WcfPazienti.PazienteType GetDataById(WcfPazienti.TokenType Token, Guid Id)
        {
            this.CacheDataKey = $"{typeof(WcfPazienti.PazienteType).Name}_{Id}";

            WcfPazienti.PazienteType pazienteType = null;

            // Cerco prima nella cache
            pazienteType = this.CacheData;
            if (pazienteType == null)
            {

                WcfPazienti.PazientiClient wcf = new WcfPazienti.PazientiClient();
                using (wcf)
                {
                    WcfUtility.SetCredentials(wcf);

                    WcfPazienti.PazienteReturn pazienteReturn = wcf.PazienteOttieniPerId(Token, Id);

                    //controllo che non ci siano errori
                    if (pazienteReturn == null || pazienteReturn.Paziente == null || pazienteReturn.Errore != null)
                    {
                        Serilog.Log.Error($"Si è verificato un errore durante la lettura del paziente con id: {Id}");
                        throw new Exception($"PazienteReturn = null per id: {Id}");
                    }
                    else
                    {
                        pazienteType = pazienteReturn.Paziente;

                        //Salvo in Cache
                        this.CacheData = pazienteType;
                    }
                }
            }

            return pazienteType;
        }

    }
}