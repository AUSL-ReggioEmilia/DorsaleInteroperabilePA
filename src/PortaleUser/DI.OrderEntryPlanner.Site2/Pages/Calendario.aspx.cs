using OrderEntryPlanner.Components;
using OrderEntryPlanner.Components.DataSources;
using Serilog;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static DI.OrderEntryPlanner.Data.DataSet.Ordini;


namespace OrderEntryPlanner.Pages
{
    public partial class Calendario : System.Web.UI.Page
    {
        #region Property

        //Serve per lo script lato client
        protected String SistemaErogante { get => DdlSistemiEroganti.SelectedValue; }

        #endregion


        /// <summary>
        /// Ottiene la lista degli ordini programmati per sistema erogante.
        /// </summary>
        /// <param name="periodo"></param>
        /// <param name="sistemaErogante"></param>
        /// <param name="variati"></param>
        /// <returns></returns>
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string ListaOrdiniProgrammati(string start, string end, string sistemaErogante)
        {
            try
            {
                List<Event> listaEventi = new List<Event>();

                //Vado avanti solo se il SistemaErogante è valorizzato
                if (!(string.IsNullOrEmpty(sistemaErogante)))
                {
                    OrdiniTestateCercaDataSource ds = new OrdiniTestateCercaDataSource();
                    List<OrdiniTestateCercaRow> dt = ds.GetDataPrenotati(Convert.ToDateTime(start), Convert.ToDateTime(end), sistemaErogante);

                    if (dt != null && dt.Any())
                    {
                        foreach (OrdiniTestateCercaRow ordine in dt)
                        {
                            string colore = "";
                            bool dataEditable = true;

                            if (ordine.PrenotazioneVariata) colore = "#160b8c";

                            //Se non è modificabile impostiamo editable = false per il calendario e li diamo un colore rosa!
                            if (!ordine.PrenotazioneModificabile)
                            {
                                colore = "#f0c9ee";
                                dataEditable = false;
                            }

                            Event evento = new Event
                            {
                                id = ordine.Id.ToString(),
                                idOrderEntry = ordine.IdOrderEntry,
                                title = ordine.AnteprimaPrestazioni,
                                color = colore,
                                start = ordine.DataPrenotazione.ToString("s"),
                                end = ordine.DataPrenotazione.AddMinutes(30).ToString("s"),
                                paziente = $"{ordine.PazienteCognome} {ordine.PazienteNome} ({ordine.PazienteDataNascita.ToString("d")})",
                                regime = $"{ordine.RegimeDescrizione}",
                                priorita = $"{ordine.PrioritaDescrizione}",
                                dataEditable = dataEditable,
                            };

                            listaEventi.Add(evento);
                        }
                    }
                }
                return new JavaScriptSerializer().Serialize(listaEventi);
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                return null;
            }
        }

        protected void DdlSistemiEroganti_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdatePanelCalendario.Update();
            RepeaterOrdiniDaPianificare.DataBind();
        }

        protected void OdsOrdiniDaPianificare_Selecting(object sender, ObjectDataSourceSelectingEventArgs e)
        {
            //Nessun SistemaErogante Selezionato!
            if (String.IsNullOrEmpty(this.SistemaErogante))
            {
                e.Cancel = true;
            }
            //Chiamo la funzione "GetParamSistemiErogantiDataTable" per costruire la data table da usare come parametro per il campo SistemiEroganti
            e.InputParameters["sistemaErogante"] = this.SistemaErogante;
        }

        protected void BtnModalConferma_Click(object sender, EventArgs e)
        {
            string sDataPianificazione = TxtDataRiprogramma.Text;
            string sOraPianificazione = TxtOraRiprogramma.Text;

            // Creo due DateTime, uno per la data e uno per l'ora, poi casto le stringhe
            DateTime dataSelezionata;
            DateTime oraSelezionata;
            DateTime.TryParse(sDataPianificazione, out dataSelezionata);
            DateTime.TryParse(sOraPianificazione, out oraSelezionata);

            string allKeys = Convert.ToString(HiddenIdOrdine.Value);

            string[] arrKeys = new string[1];
            char[] splitter = { '@' };
            arrKeys = allKeys.Split(splitter);

            string idOrdine = arrKeys[0];
            string idOrderEntry = arrKeys[1];

            // Creo un'unica data con Data e Ora
            DateTime dataPianificazione = new DateTime(dataSelezionata.Year, dataSelezionata.Month, dataSelezionata.Day, oraSelezionata.Hour, oraSelezionata.Minute, 0);

            if (dataPianificazione != DateTime.MinValue)
            {
                try
                {
                    //Aggiorno la data di prenotazione, sia sul DB locale che su quello di OrderEntry
                    OrdiniRiprogrammatiInserisceDataSource ds = new OrdiniRiprogrammatiInserisceDataSource();
                    ds.CambiaDataPrenotazione(idOrdine, dataPianificazione.ToString(), idOrderEntry);

                    //Svuoto tutte le Cache, sia del calendario per che della lista a destra
                    OrdiniTestateCercaDataSource dsOrdini = new OrdiniTestateCercaDataSource();
                    dsOrdini.ClearCache();

                    //Svuoto per sicurezza il campo ID
                    HiddenIdOrdine.Value = "";

                    // Aggiorno l'update panel del calendario per aggiornare la selezione
                    UpdatePanelCalendario.Update();
                    UpdatePanelModal.Update();

                }
                catch (Exception ex)
                {
                    Log.Error(ex, ex.Message);
                    Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
                }
            }
        }

        protected string GetAnteprimaPrestazioni(string anteprima)
        {
            int lunghezzaMax = 55;

            //Se è maggiore di lunghezzaMax caratteri la tronco e aggiungo i puntini per far capire che non si vedono tutte
            if (anteprima.Length > lunghezzaMax)
            {
                return $"{anteprima.Substring(0, lunghezzaMax)}...";
            }
            else
            {
                return anteprima;
            }
        }
    }
}