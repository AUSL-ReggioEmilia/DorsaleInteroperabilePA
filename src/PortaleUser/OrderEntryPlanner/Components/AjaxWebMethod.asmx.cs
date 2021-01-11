using DI.OrderEntryPlanner.Data.Ordini;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using static DI.OrderEntryPlanner.Data.DataSet.Ordini;

namespace OrderEntryPlanner.Components
{
    /// <summary>
    /// Elenco dei metodi utilizzati dal calendario per visualizzare/modificare gli ordini.
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    [System.Web.Script.Services.ScriptService]
    public class AjaxWebMethod : System.Web.Services.WebService
    {
        /// <summary>
        /// Ottiene l'InstrumentationKey per Application Insights.
        /// </summary>
        /// <returns></returns>
        [WebMethod]
        [ScriptMethod(UseHttpGet = true)]
        public string GetInstrumentationKey()
        {
            return Properties.Settings.Default.InstrumentationKey;
        }

        /// <summary>
        /// Ottiene la lista degli ordini da programmare in base al sistema erogante.
        /// </summary>
        /// <param name="SistemaErogante"></param>
        /// <returns></returns>
        [WebMethod]
        public string ListaOrdiniDaRiprogrammare(string SistemaErogante)
        {
            List<Event> listaEventi = new List<Event>();

            //Vado avanti solo se il SistemaErogante è valorizzato
            if (!(string.IsNullOrEmpty(SistemaErogante)))
            {
                OrdiniTestateCercaTableAdapter ta = new OrdiniTestateCercaTableAdapter();
                using (ta)
                {
                    DataTable sistemiEroganti = GetParamSistemiErogantiDataTable(SistemaErogante);
                    OrdiniTestateCercaDataTable dt = ta.GetData(100, null, null, null, null, null, null, null, null, null, null, sistemiEroganti, null, null, false, true);

                    if (dt != null && dt.Rows.Count > 0)
                    {
                        foreach (OrdiniTestateCercaRow ordine in dt.Rows)
                        {
                            Event evento = new Event { id = $"{ordine.Id.ToString()}@{ordine.IdOrderEntry.ToString()}", title = ordine.AnteprimaPrestazioni, paziente = $"{ordine.PazienteNome} {ordine.PazienteCognome}", className = $"id-{ordine.Id.ToString()}" };
                            listaEventi.Add(evento);
                        }
                    }
                }
            }

            return new JavaScriptSerializer().Serialize(listaEventi);
        }


        /// <summary>
        /// Cambia la data di prenotazione di un ordine.
        /// </summary>
        /// <param name="IdOrdineTestata"></param>
        /// <param name="DataPrenotazioneNew"></param>
        /// <param name="IdOrderEntry"></param>
        /// <returns></returns>
        [WebMethod(enableSession:true)]
        public string CambiaDataPrenotazione(string IdOrdineTestata, string DataPrenotazioneNew, string IdOrderEntry)
        {
            if (!string.IsNullOrEmpty(IdOrdineTestata) && !string.IsNullOrEmpty(DataPrenotazioneNew) && !string.IsNullOrEmpty(IdOrderEntry))
            {
                DateTime dataPrenotazioneNew = DateTime.Parse(DataPrenotazioneNew);

                dataPrenotazioneNew = dataPrenotazioneNew.ToUniversalTime();

                //Scrivo nella tabella di OrderEntryPlanner la nuova data di pianificazione.
                QueriesTableAdapter ta = new QueriesTableAdapter();
                using (ta)
                {
                    ta.OrdiniRiprogrammatiInserisce(new Guid(IdOrdineTestata), HttpContext.Current.User.Identity.Name, dataPrenotazioneNew);
                }

                //Contatto il metodo del WCF OE per la ripianificazione dell'ordine.
                WcfOrderEntry.OrderEntryV1Client wcfOe = new WcfOrderEntry.OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1"); //"BasicHttpBinding_IOrderEntryAdmin");
                using (wcfOe)
                {
                    OeUserToken oeUserToken = WcfOeToken.GetOeToken();
                    wcfOe.RipianificaOrdineIdRichiesta(oeUserToken.Token, IdOrderEntry, dataPrenotazioneNew);
                }
            }

            return "";
        }

        /// <summary>
        /// Ottiene la lista degli ordini programmati per sistema erogante.
        /// </summary>
        /// <param name="SistemaErogante"></param>
        /// <returns></returns>
        [WebMethod]
        public string ListaOrdiniProgrammati(string SistemaErogante)
        {
            List<Event> listaEventi = new List<Event>();

            //Vado avanti solo se il SistemaErogante è valorizzato
            if (!(string.IsNullOrEmpty(SistemaErogante)))
            {
                OrdiniTestateCercaTableAdapter ta = new OrdiniTestateCercaTableAdapter();
                using (ta)
                {
                    DataTable sistemiEroganti = GetParamSistemiErogantiDataTable(SistemaErogante);
                    OrdiniTestateCercaDataTable dt = ta.GetData(100, null, null, null, null, null, null, null, null, null, null, sistemiEroganti, null, null, true, null);

                    if (dt != null && dt.Rows.Count > 0)
                    {
                        foreach (OrdiniTestateCercaRow ordine in dt.Rows)
                        {
                            Event evento = new Event { id = $"{ordine.Id.ToString()}@{ordine.IdOrderEntry.ToString()}", title = ordine.AnteprimaPrestazioni, color = "", start = ordine.DataPianificazione.ToString("s"), end = ordine.DataPianificazione.AddMinutes(30).ToString("s"), paziente = $"{ordine.PazienteNome} {ordine.PazienteCognome}", className = $"id-{ordine.Id.ToString()}" };

                            listaEventi.Add(evento);
                        }
                    }
                }
            }

            return new JavaScriptSerializer().Serialize(listaEventi);
        }

        /// <summary>
        /// Ottiene un ordine in base al suo id.
        /// </summary>
        /// <param name="IdOrdine"></param>
        /// <returns></returns>
        [WebMethod]
        public string OttieniOrdineById(string IdOrdine)
        {
            string JSONresult = string.Empty;
            if (!string.IsNullOrEmpty(IdOrdine))
            {

                OrdiniTestateOttieniTableAdapter ta = new OrdiniTestateOttieniTableAdapter();
                using (ta)
                {
                    OrdiniTestateOttieniDataTable dt = ta.GetData(new Guid(IdOrdine));

                    if (dt != null && dt.Rows.Count > 0)
                    {
                        JSONresult = ConvertDataTabletoString(dt);
                    }
                }
            }

            return JSONresult;
        }



        /// <summary>
        ///  Funzione usata per costruire la datatable dei SistemiEroganti da passare come parametro all'ObjectDataSource degli ordini.
        /// </summary>
        private DataTable GetParamSistemiErogantiDataTable(string SistemaErogante)
        {
            //Dichiaro una nuova DataTable e aggiungo due colonne "CodiceAzienda" e "Codice".
            DataTable result = new DataTable();
            //try
            //{
                //Se il SelectedValue della dropdownlist è vuoto allora ho selezionato il valore "Tutti" quindi creo una DataTable composta da tutti i sistemi eroganti.
                result.Columns.Add("CodiceAzienda", typeof(string));
                result.Columns.Add("Codice", typeof(string));

                //Se sono qui allora è stato selezionato un Sistema Erogante.
                //Prendo il selected value e lo splitto per il carattere "@".
                string[] arrayCodiceAziendaESistema = SistemaErogante.Split('@');

                //Ottengo il codice del sistema e il codice dell'azienda.
                string codiceSistema = arrayCodiceAziendaESistema[0];
                string codiceAzienda = arrayCodiceAziendaESistema[1];

                //inserisco i valori all'interno della DataTable.
                result.Rows.Add(codiceAzienda, codiceSistema);
            //}
            //catch (Exception)
            //{
            //    //Log.Error(ex, ex.Message);
            //    //Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            //}
            return result;
        }


        /// <summary>
        /// Funzione che converte i datatable in json.
        /// (funziona correttamente anche con i DBnull)
        /// </summary>
        /// <param name="dt"></param>
        /// <returns></returns>
        public string ConvertDataTabletoString(DataTable dt)
        {
            System.Web.Script.Serialization.JavaScriptSerializer serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();
            Dictionary<string, object> row;
            foreach (DataRow dr in dt.Rows)
            {
                row = new Dictionary<string, object>();
                foreach (DataColumn col in dt.Columns)
                {
                    row.Add(col.ColumnName, dr[col]);
                }
                rows.Add(row);
            }

            return JsonConvert.SerializeObject(rows);
        }
    }
}
