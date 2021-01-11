using DI.OrderEntryPlanner.Data.Ordini;
using Serilog;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Web;

namespace OrderEntryPlanner.Components.DataSources
{
    [DataObjectAttribute()]
    public class OrdiniRiprogrammatiInserisceDataSource
    {
        [DataObjectMethod(DataObjectMethodType.Update)]
        public void CambiaDataPrenotazione(string IdOrdineTestata, string DataPrenotazioneNew, string IdOrderEntry)
        {
            if (!string.IsNullOrEmpty(IdOrdineTestata) && !string.IsNullOrEmpty(DataPrenotazioneNew) && !string.IsNullOrEmpty(IdOrderEntry))
            {
                try
                {


                    DateTime dataPrenotazioneNew = DateTime.Parse(DataPrenotazioneNew);

                    // TODO: Verificare la necessità di convertire la data in UTC, è veramente necessario ? Cambia il giorno se si è vicino alla mezzanotte
                    //dataPrenotazioneNew = dataPrenotazioneNew.ToUniversalTime();

                    // Contatto il metodo del WCF OE per la ripianificazione dell'ordine.
                    // NB:   I dati vengo aggiornati su OE, il quale aggiorna i dati sul DataBase OE-Planner con qualche secondo di ritardo, 
                    //       poiché c'è una sincronia tra i due DataBase (job di BitzTalk)
                    WcfOrderEntry.OrderEntryV1Client wcfOe = new WcfOrderEntry.OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1"); //"BasicHttpBinding_IOrderEntryAdmin");
                    using (wcfOe)
                    {
                        OeUserToken oeUserToken = WcfOeToken.GetOeToken();
                        wcfOe.RipianificaOrdineIdRichiesta(oeUserToken.Token, IdOrderEntry, dataPrenotazioneNew);
                    }

                    // Scrivo nella tabella di OrderEntryPlanner la nuova data di pianificazione.
                    QueriesTableAdapter ta = new QueriesTableAdapter();
                    using (ta)
                    {
                        ta.OrdiniRiprogrammatiInserisce(new Guid(IdOrdineTestata), HttpContext.Current.User.Identity.Name, dataPrenotazioneNew);
                    }
                }
                catch (Exception ex)
                {
                    Log.Error(ex, ex.Message);
                    throw;
                }
            }
        }
    }
}