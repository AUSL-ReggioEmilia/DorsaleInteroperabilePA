using DI.OrderEntryPlanner.Data.DataSet.OrdiniTableAdapters;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

using DatasetCustom = DI.OrderEntryPlanner.Data.DataSet.Ordini;
using OrdiniCustom = DI.OrderEntryPlanner.Data.Ordini;

namespace OrderEntryPlanner.Components.DataSources
{
    [DataObjectAttribute()]
    public class OrdiniTestateCercaDataSource : CacheDataSource<DatasetCustom.OrdiniTestateCercaDataTable>
    {
        private const string SESSION_KEY_CACHE_LIST = "KeyCacheList";

        private List<string> KeyCacheList
        {
            get => (List<string>)HttpContext.Current.Session[SESSION_KEY_CACHE_LIST];
            set => HttpContext.Current.Session[SESSION_KEY_CACHE_LIST] = value;
        }

        /// <summary>
        /// Aggiunge la chiave alla lista se non esiste
        /// </summary>
        /// <param name="keyToAdd"></param>
        private void AddCachekey(string keyToAdd)
        {
            if (KeyCacheList == null) KeyCacheList = new List<string>();
            if (!KeyCacheList.Contains(keyToAdd)) KeyCacheList.Add(keyToAdd);
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public List<DatasetCustom.OrdiniTestateCercaRow> GetDataPrenotati(DateTime start, DateTime end, String sistemaErogante)
        {
            DatasetCustom.OrdiniTestateCercaDataTable ordiniRet;

            // Custom CacheKey per utilizzare il datasource condiviso tra il web method e il postback
            int hashParameters = $"{start}_{end}_{sistemaErogante}".GetHashCode();
            this.CacheDataKey = $"{HttpContext.Current.User.Identity.Name}_{GetUrlPageHash()}_{hashParameters}_{typeof(DatasetCustom.OrdiniTestateCercaDataTable).Name}";
            AddCachekey(this.CacheDataKey);

            // Cerco prima nella cache
            ordiniRet = this.CacheData;
            if (ordiniRet == null)
            {
                OrdiniTestateCercaTableAdapter tableAdapter = new OrdiniCustom.OrdiniTestateCercaTableAdapter();

                DataTable sistemiEroganti = GetParamSistemiErogantiDataTable(sistemaErogante);
                ordiniRet = tableAdapter.GetData(5000, start, end, sistemiEroganti, true, null, null, null, null, null, null, null, null, null);

                this.CacheData = ordiniRet;
            }

            return ordiniRet.ToList();
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public List<DatasetCustom.OrdiniTestateCercaRow> GetDataNonPrenotati(String sistemaErogante)
        {
            DatasetCustom.OrdiniTestateCercaDataTable ordiniRet;

            // Custom CacheKey per sistema erogante
            int hashParameters = $"{sistemaErogante}".GetHashCode();
            this.CacheDataKey = $"{HttpContext.Current.User.Identity.Name}_{GetUrlPageHash()}_{hashParameters}_{typeof(DatasetCustom.OrdiniTestateCercaDataTable).Name}";
            AddCachekey(this.CacheDataKey);

            // Cerco prima nella cache
            ordiniRet = this.CacheData;
            if (ordiniRet == null)
            {
                OrdiniTestateCercaTableAdapter tableAdapter = new OrdiniCustom.OrdiniTestateCercaTableAdapter();

                DataTable sistemiEroganti = GetParamSistemiErogantiDataTable(sistemaErogante);
                ordiniRet = tableAdapter.GetData(5000, null, null, sistemiEroganti, false, true, false, null, null, null, null, null, null, null);

                this.CacheData = ordiniRet;
            }

            //Ordinate per data richiesta (prima le più vecchie!)
            return ordiniRet.OrderBy(x => x.DataRichiesta).ToList();
        }

        public new void ClearCache()
        {
            if (KeyCacheList != null)
            {
                //Ciclo tutte le chiavi per pulire tutte le cache
                foreach (string key in KeyCacheList)
                {
                    //Pulisco la cache con quella chiava
                    this.CacheDataKey = key;
                    base.ClearCache();
                }
            }
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

        private string GetUrlPageHash()
        {
            string sPath = HttpContext.Current.Request.Url.ToString();

            int index = sPath.IndexOf(".aspx");
            if (index != -1)
            {
                return sPath.Substring(0, index - 1).GetHashCode().ToString();
            }

            index = sPath.IndexOf("?");
            if (index != -1)
            {
                return sPath.Substring(0, index - 1).GetHashCode().ToString();
            }

            return sPath.GetHashCode().ToString();
        }
    }
}