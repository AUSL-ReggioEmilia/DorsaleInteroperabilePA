using DI.OrderEntryPlanner.Data.Ordini;
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

    public partial class PianificaOrdine : System.Web.UI.Page
    {

        #region Costanti

        private const String SESSION_ORDINE_DT = "OrdineDettaglioDt";

        #endregion

        #region Property

        protected OrdiniTestateOttieniDataTable OrdineDettaglioDt { get => (OrdiniTestateOttieniDataTable)Session[SESSION_ORDINE_DT]; set => Session[SESSION_ORDINE_DT] = value; }
        protected OrdiniTestateOttieniRow OrdineDettaglio { get => OrdineDettaglioDt.FirstOrDefault(); }
        protected String SistemaErogante { get => (String)ViewState["SistemaErogante"]; set => ViewState["SistemaErogante"] = value; }
        protected String Paziente;

        #endregion

        /// <summary>
        /// Ottiene la lista degli ordini programmati per sistema erogante.
        /// </summary>
        /// <param name="sistemaErogante"></param>
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

                    if (dt != null && dt.Count > 0)
                    {
                        // Prendo dalla sessione l'ordine perchè il WebMethod non ha accesso alle variabili non statiche della pagina. Sono diponibili solo dopo un postback
                        OrdiniTestateOttieniDataTable ordineDt = (OrdiniTestateOttieniDataTable)HttpContext.Current.Session[SESSION_ORDINE_DT];
                        OrdiniTestateOttieniRow ordineDettaglio = ordineDt.FirstOrDefault();

                        foreach (OrdiniTestateCercaRow ordine in dt)
                        {

                            string colore = "";

                            // Se la prenotazione ha già subito una variazione allora assume un colore più intenso di BLU
                            if (ordine.PrenotazioneVariata) colore = "160b8";

                            // Mentre se non è modificabile assume un colore ROSA
                            if (!ordine.PrenotazioneModificabile) colore = "#f0c9ee";

                            Event evento = new Event
                            {
                                id = ordine.Id.ToString(),
                                idOrderEntry = ordine.IdOrderEntry,
                                title = ordine.AnteprimaPrestazioni,
                                color = colore,
                                start = ordine.DataPrenotazione.ToString("o"),
                                end = ordine.DataPrenotazione.AddMinutes(30).ToString("o"),
                                paziente = $"{ordine.PazienteCognome} {ordine.PazienteNome} ({ordine.PazienteDataNascita.ToString("d")})",
                                regime = $"{ordine.RegimeDescrizione}",
                                priorita = $"{ordine.PrioritaDescrizione}",
                            };

                            if (ordine.Id == ordineDettaglio.Id)
                            {
                                //VERDE
                                evento.color = "#69f542";
                                evento.borderColor = "#32a113";
                                evento.dataEditable = true;
                                // Bisogna gestire il drag and drop. per ora non implementato
                                //evento.editable = true;
                            }

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

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {

                if (!String.IsNullOrEmpty(Request.QueryString["IdOrdine"]))
                {
                    Guid idOrdine = new Guid(Request.QueryString["IdOrdine"]);

                    //DataAccess da = DataAccess.instance;
                    OrdiniTestateOttieniTableAdapter tableAdapter = new OrdiniTestateOttieniTableAdapter();
                    using (tableAdapter)
                    {
                        this.OrdineDettaglioDt = tableAdapter.GetData(idOrdine);
                    }

                    this.SistemaErogante = $"{OrdineDettaglio.SistemaEroganteCodice}@{OrdineDettaglio.SistemaEroganteAziendaCodice}";
                    this.Paziente = $"{OrdineDettaglio.PazienteCognome} {OrdineDettaglio.PazienteNome}";

                    // Svuoto la cache
                    OrdiniTestateCercaDataSource ds = new OrdiniTestateCercaDataSource();
                    ds.ClearCache();

                    // Imposto la data e l'ora dell'ordine
                    SetDateAndTime();

                    Page.DataBind();
                }
            }
        }

        // Bottone indietro della Toolbar
        protected void BtnIndietro_Click(object sender, EventArgs e)
        {
            // Recupero l'idOrdine da QueryString e il Parent (aggiunto dalla )
            String idOrdine = Request.QueryString["IdOrdine"];
            String parent = Request.QueryString["Parent"];

            // Controllo da dove viene navigata la pagina 
            if (parent.ToLower() == "detail")
            {
                // Se presente l'idOrdine reindirizzo alla pagine di dettaglio
                if (!String.IsNullOrEmpty(idOrdine))
                {
                    Response.Redirect($"~/Pages/DettaglioOrdine.aspx?IdOrdine={idOrdine}", false);
                }
                // Diversamente torno alla Lista
                else
                {
                    Response.Redirect("~/Pages/RicercaOrdini.aspx", false);
                }
            }
            // Se proveniva dalla lista reindirizzo alla lista
            else if (parent.ToLower() == "list")
            {
                Response.Redirect("~/Pages/RicercaOrdini.aspx", false);
            }
        }

        // Bottone annulla nel dettaglio per azzerare i campi
        protected void btnAnnulla_Click(object sender, EventArgs e)
        {
            SetDateAndTime();
            // Aggiorno l'update panel del calendario per aggiornare la selezione
            UpdatePanelCalendario.Update();
        }

        // Bottone conferma nel dettaglio per la modifica della data di prenotazione
        protected void btnConferma_Click(object sender, EventArgs e)
        {
            try
            {
                // Recupero data e ora sotto forma di stringhe dalle Textbox
                String sDataSelezionata = TxtDataPianificata.Text;
                String sOraSelezionata = TxtOraPianificata.Text;

                // Creo due DateTime, uno per la data e uno per l'ora, poi casto le stringhe
                DateTime dataSelezionata;
                DateTime oraSelezionata;
                DateTime.TryParse(sDataSelezionata, out dataSelezionata);
                DateTime.TryParse(sOraSelezionata, out oraSelezionata);

                // Creo un'unica data con Data e Ora
                DateTime dataPianificazione = new DateTime(dataSelezionata.Year, dataSelezionata.Month, dataSelezionata.Day, oraSelezionata.Hour, oraSelezionata.Minute, 0);

                if (dataPianificazione != DateTime.MinValue)
                {
                    // Aggiorno la data nella pagina 
                    OrdineDettaglioDt.FirstOrDefault().DataPrenotazione = dataPianificazione;

                    //Aggiorno la data di prenotazione, sia sul DB locale che su quello di OrderEntry
                    OrdiniRiprogrammatiInserisceDataSource ds = new OrdiniRiprogrammatiInserisceDataSource();
                    ds.CambiaDataPrenotazione(OrdineDettaglio.Id.ToString(), dataPianificazione.ToString(), OrdineDettaglio.IdOrderEntry);

                    // Svuoto la cache per forzare il caricamento dei dati
                    OrdiniTestateCercaDataSource dsOrdini = new OrdiniTestateCercaDataSource();
                    dsOrdini.ClearCache();

                    // Aggiorno l'update panel del calendario per aggiornare la selezione
                    UpdatePanelCalendario.Update();
                    // Aggiorno l'updatePanel del Dettaglio per aggiornare i dati
                    UpdatePanelDettaglio.Update();
                }
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }

        }

        protected void btnConfermaEdEsci_Click(object sender, EventArgs e)
        {
            try
            {
                // Recupero data e ora sotto forma di stringhe dalle Textbox
                String sDataSelezionata = TxtDataPianificata.Text;
                String sOraSelezionata = TxtOraPianificata.Text;

                // Creo due DateTime, uno per la data e uno per l'ora, poi casto le stringhe
                DateTime dataSelezionata;
                DateTime oraSelezionata;
                DateTime.TryParse(sDataSelezionata, out dataSelezionata);
                DateTime.TryParse(sOraSelezionata, out oraSelezionata);

                // Creo un'unica data con Data e Ora
                DateTime dataPianificazione = new DateTime(dataSelezionata.Year, dataSelezionata.Month, dataSelezionata.Day, oraSelezionata.Hour, oraSelezionata.Minute, 0);

                if (dataPianificazione != DateTime.MinValue)
                {
                    // Aggiorno la data nella pagina 
                    OrdineDettaglioDt.FirstOrDefault().DataPrenotazione = dataPianificazione;

                    //Aggiorno la data di prenotazione, sia sul DB locale che su quello di OrderEntry
                    OrdiniRiprogrammatiInserisceDataSource ds = new OrdiniRiprogrammatiInserisceDataSource();
                    ds.CambiaDataPrenotazione(OrdineDettaglio.Id.ToString(), dataPianificazione.ToString(), OrdineDettaglio.IdOrderEntry);

                    // Torno alla lista
                    Response.Redirect("~/Pages/RicercaOrdini.aspx", false);
                }
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        // Imposta la Data e l'ora delle TextBox con i valori corretti
        private void SetDateAndTime()
        {
            // Se presente la DataPinificazione allora imposto le TextBox con i suoi valori di Data e Ora
            if (!OrdineDettaglio.IsDataPrenotazioneNull())
            {
                TxtDataPianificata.Text = OrdineDettaglio.DataPrenotazione.ToString("d");
                TxtOraPianificata.Text = OrdineDettaglio.DataPrenotazione.ToString("t");
            }

        }
    }
}