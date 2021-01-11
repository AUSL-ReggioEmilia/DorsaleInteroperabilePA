using DI.OrderEntryPlanner.Data.DataSet;
using DI.OrderEntryPlanner.Data.WcfSacPazienti;
using OrderEntryPlanner.Components;
using Serilog;
using System;
using System.Data;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

namespace OrderEntryPlanner.Pages
{
    public partial class DettaglioOrdine : System.Web.UI.Page
    {
        #region Properties&Variables
        public Guid? IdOrdine
        {
            get
            {
                Guid? idOrdine = null;

                //Verifico che il viewState relativo all'IdOrdine non sia già stato settato in precedenza
                string idOrdineVS = ViewState["IdOrdine"]?.ToString();

                //Se il campo è valorizzato ne prendo il valore
                if (!string.IsNullOrEmpty(idOrdineVS))
                {
                    idOrdine = new Guid(idOrdineVS);
                }
                return idOrdine;
            }
            set
            {
                //Valorizzo il viewState inserendo il parametro IdOrdine
                ViewState.Add("IdOrdine", value);
            }
        }
        public Guid? IdSac
        {
            get
            {
                Guid? idSac = null;

                //Verifico che il viewState relativo all'IdSac non sia già stato settato in precedenza.
                string idSacVS = ViewState["IdSac"]?.ToString();

                //Se il campo è valorizzato ne prendo il valore
                if (!String.IsNullOrEmpty(idSacVS))
                {
                    idSac = new Guid(idSacVS);
                }
                return idSac;
            }
            set
            {
                //Valorizzo il viewState inserendo il parametro IdOrdine
                ViewState.Add("IdSac", value);
            }
        }

        private bool cancelSelect = true;
        private string nome = string.Empty;
        private string cognome = string.Empty;
        private string codiceFiscale = string.Empty;
        private string comuneNascita = string.Empty;
        private DateTime? dataNascita = DateTime.Now;
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                //Controllo che non sia un postBack
                if (!IsPostBack)
                {
                    //Nella pagina di lista degli ordini faccio il redirect a questa passando nella queryString l'IdOrdine
                    //Lo ricavo e lo scrivo nel viewState
                    if (Request.QueryString["IdOrdine"] != null)
                    {
                        //Controllo che IdOrdine sia presente in queryString. Se non c'è lancio un'eccezione.
                        if (!(Guid.TryParse(Request.QueryString["IdOrdine"], out Guid idOrdineTemp)))
                        {
                            throw new ApplicationException("Il parametro Id non è un guid valido.");
                        }
                        //Se è presente nella queryString allora valorizzo la relativa variabile di pagina
                        else IdOrdine = idOrdineTemp;
                    }
                    else
                    {
                        //Se non riesco a ricavare l'IdOrdine non riesco a eseguire nessun metodo nella pagina.
                        //Nascondo quindi tutti i div tranne quello di errore
                        divTestataOrdine.Visible = false;
                        divTestataPaziente.Visible = false;
                        divPrestazioni.Visible = false;
                        throw new ApplicationException("Impossibile caricare le informazioni relative al paziente. Contattare un amministratore.");
                    }
                }
            }
            catch (ApplicationException ex)
            {
                Master.showAlert(ex.Message);
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        // <summary>
        // Controlla la presenza di Dati Accessori di Testata
        // </summary>
        protected bool TestataContieneDatiAggiuntivi(DataRowView drw)
        {
            try
            {
                var row = (Ordini.OrdiniTestateOttieniRow)drw.Row;
                if (row.IsRichiestaNull() || (string.IsNullOrEmpty(row.Richiesta)))
                    return false;
                var xRichiesta = XElement.Parse(row.Richiesta);
                var xDatiAgg = xRichiesta.Element("DatiAggiuntivi");
                if (xDatiAgg == null)
                    return false;
                var xDatoAgg = xDatiAgg.Elements("DatoAggiuntivo");
                return xDatoAgg.Any();
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
                return false;
            }
        }

        // <summary>
        // Visualizza i dati accessori di Testata recuparati dal campo XML Richiesta
        // </summary>
        protected void btnDatiAccessori_Click(object sender, EventArgs e)
        {
            try
            {
                // Se il campo XML Richiesta non è null recupero i Dati Accessori
                if (fvTestataOrdine.DataKey["Richiesta"] != null)
                {
                    var sRichiesta = fvTestataOrdine.DataKey["Richiesta"].ToString();
                    Components.Utility.ApplyXsltTransform(sRichiesta, "~/Xsl/DatiAccessoriTestata.xslt", ref XmlDatiAccessoriTestata);
                    // 
                    // Open ModalDatiAccessori
                    // 
                    ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ModalDatiAccessoriTestata", "$('#ModalDatiAccessoriTestata').modal('show');", true);
                }
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }

        }

        // <summary>
        // Controlla la presenza di Dati Accessori di Riga
        // </summary>
        protected bool RigaRichiestaContieneDatiAggiuntivi(DataRowView drw)
        {
            try
            {
                var row = (Ordini.OrdiniRigheOttieniByIdOrdineTestataRow)drw.Row;
                if (row.IsRigaRichiestaNull() || (string.IsNullOrEmpty(row.RigaRichiesta)))
                    return false;
                var xRigaRichiesta = XElement.Parse(row.RigaRichiesta);
                var xDatiAgg = xRigaRichiesta.Elements("DatiAggiuntivi");
                if (xDatiAgg == null)
                    return false;
                var xDatoAgg = xDatiAgg.Elements("DatoAggiuntivo");
                if (xDatoAgg == null)
                    return false;
                return xDatoAgg.Any();
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
                return false;
            }
        }

        //<summary>
        //Visualizza i dati accessori di Riga recuparati dal campo XML RigaRichiesta
        //</summary>
        protected void btnDatiAccessoriRiga_Click(object sender, EventArgs e)
        {
            try
            {
                GridViewRow gRow = (GridViewRow)(sender as Control).Parent.Parent;
                var iRowIndex = gRow.RowIndex;
                var sDatiAggiuntivi = gvPrestazioni.DataKeys[iRowIndex]["RigaRichiesta"].ToString();

                Components.Utility.ApplyXsltTransform(sDatiAggiuntivi, "~/Xsl/DatiAccessoriRigaRichiesta.xslt", ref XmlDatiAccessoriRigaRichiesta);
                // 
                // Open ModalDatiAccessoriRiga
                // 
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ModalDatiAccessori", "$('#ModalDatiAccessori').modal('show');", true);
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        /// <summary>
        /// Recupero il campo etichetta dall'oggetto DatoAccessorio
        /// </summary>
        /// <param name="oDatoAccessorio"></param>
        /// <returns></returns>
        protected string GetEtichetta(object oDatoAccessorio)
        {
            string etichetta = string.Empty;

            try
            {
                try
                {
                    WcfOrderEntry.DatoAccessorioType datoAccessorio = (WcfOrderEntry.DatoAccessorioType)oDatoAccessorio;
                    etichetta = datoAccessorio.Etichetta;
                }
                catch (Exception ex)
                {
                    Components.Utility.LogError(ex);
                    Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
                }
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
            return etichetta;
        }

        /// <summary>
        /// funzione di utility per eliminare la classe bootstrap Form-control-static se il valore del dato accessorio è troppo lungo
        /// (perchè si presenta un errore grafico causato da un bug bootstrap)
        /// </summary>
        /// <param name="oValoreDato"></param>
        /// <returns></returns>
        protected string GetClassValoreDato(object oValoreDato)
        {
            string sClass = "form-control-static";

            try
            {
                if (oValoreDato != null)
                {
                    string valoreDato = System.Convert.ToString(oValoreDato);

                    if (valoreDato.Length > 80)
                        sClass = "";
                }
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }

            return sClass;
        }

        /// <summary>
        /// Funzione che mi permette di ricavare una stringa contenente nome e cognome a partire da un oggetto di tipo PazienteType
        /// </summary>
        /// <param name="paziente"></param>
        /// <returns>string</returns>
        public string GetNomeCognome(Object paziente2)
        {
            string result = string.Empty;
            try
            {
                PazienteType paziente = (PazienteType)paziente2;
                result = $"{paziente.Generalita.Cognome} {paziente.Generalita.Nome}";
            }
            catch (ApplicationException ex)
            {
                Master.showAlert(ex.Message);
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
            return result;
        }



        /// <summary>
        /// Funzione che a partire da un oggetto di tipo PazienteType ricava tutti i dati anagrafici e li compone in una stringa descrittiva
        /// </summary>
        /// <param name="paziente"></param>
        /// <returns>string</returns>
        public string GetInfoPaziente(object paziente2)
        {
            string result = string.Empty;
            try
            {
                PazienteType paziente = (PazienteType)paziente2;

                if (paziente.Generalita.DataNascita != null)
                {
                    result += string.Format(" CF: <strong>{0}</strong> nato il <strong>{1:d} </strong> a <strong>{2}</strong>", codiceFiscale.ToUpper(), dataNascita, comuneNascita.ToUpper());
                }
                else
                {
                    result += string.Format(" CF: <strong>{0}</strong> nato a <strong>{1}</strong>", codiceFiscale.ToUpper(), comuneNascita.ToUpper());
                }
                if (paziente.Generalita.DataDecesso != null)
                {
                    result += string.Format(". Deceduto il <label class='text-danger'>{1:d}</label>.", paziente.Generalita.DataDecesso);
                }
            }
            catch (ApplicationException ex)
            {
                Master.showAlert(ex.Message);
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
            return result;
        }

        /// <summary>
        /// Funzione che ricava l'url SAC del paziente
        /// </summary>
        /// <param name="paziente"></param>
        /// <returns></returns>
        public string GetPazienteSacUrl()
        {
            string result = string.Empty;
            try
            {
                //La radice dell'url base del SAC di un paziente è scritto in una setting del progetto.
                //Qui la prendo e le aggiungo il parametro relativo all'IdSac del paziente in esame
                result = Properties.Settings.Default.SacUrl + IdSac;

                //Controllo che result non sia vuoto e nel caso lancio un'applicationException
                if (string.IsNullOrEmpty(result))
                {
                    throw new ApplicationException("L'url SAC non è definito nei parametri dell'applicazione");
                }
            }
            catch (ApplicationException ex)
            {
                Master.showAlert(ex.Message);
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
            return result;
        }

        /// <summary>
        /// Imposto gli stili bootstrap alla gridview passata come parametro
        /// </summary>
        /// <param name="sender"></param>
        private void CreateBootstrapGridViewHeader(GridView sender)
        {
            try
            {
                //Bootstrap Setup per le gridview
                HelperGridView.SetUpGridView(sender, this.Page);
            }
            catch (ApplicationException ex)
            {
                Master.showAlert(ex.Message);
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        /// <summary>
        /// Quando un utente clicca sul pulsante "Ripianifica" si apre la pagina di visualizzazione a calendario
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnRipianifica_Click(object sender, EventArgs e)
        {
            try
            {
                //Eseguo il redirect alla pagine di calendario passando in querystring l'IdOrdine
                Response.Redirect($"Calendario?IdOrdine={IdOrdine}", false);
            }
            catch (ApplicationException ex)
            {
                Master.showAlert(ex.Message);
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        /// <summary>
        /// Metodo che reindirizza l'utente alla pagine di ricerca ordini
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnIndietro_Click(object sender, EventArgs e)
        {
            try
            {
                Response.Redirect($"RicercaOrdini", false);
            }
            catch (ApplicationException ex)
            {
                Master.showAlert(ex.Message);
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }


        protected void odsPaziente_Selecting(object sender, ObjectDataSourceSelectingEventArgs e)
        {
            try
            {
                //Blocco l'esecuzione della select se il parametro cancelSelect è settato a true
                e.Cancel = cancelSelect;
                //Se la select viene eseguita passo manualmente i valori all'ods
                e.InputParameters["Token"] = null;
                e.InputParameters["Id"] = IdSac;
            }
            catch (ApplicationException ex)
            {
                Master.showAlert(ex.Message);
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }
        protected void odsPaziente_Selected(object sender, ObjectDataSourceStatusEventArgs e)
        {
            try
            {
                //Casto il valore di ritorno della select dell'odsPaziente ad un oggetto di tipo PazienteType e poi ne ricavo 
                //i principali dati anagrafici per salvarli nelle rispettive variabili di pagina.
                PazienteType paziente = (PazienteType)e.ReturnValue;
                nome = paziente.Generalita.Nome;
                cognome = paziente.Generalita.Cognome;
                codiceFiscale = paziente.Generalita.CodiceFiscale;
                dataNascita = paziente.Generalita.DataNascita;
                comuneNascita = paziente.Generalita.ComuneNascitaNome;

            }
            catch (ApplicationException ex)
            {
                Master.showAlert(ex.Message);
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        protected void odsTestataOrdine_Selecting(object sender, ObjectDataSourceSelectingEventArgs e)
        {
            try
            {
                //Passo manualmente il parametro necessario per eseguire la query
                e.InputParameters["Id"] = IdOrdine;
            }
            catch (ApplicationException ex)
            {
                Master.showAlert(ex.Message);
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }
        protected void odsTestataOrdine_Selected(object sender, ObjectDataSourceStatusEventArgs e)
        {
            try
            {
                //Casto il valore di ritorno della select dell'odsTestataOrdine ad un oggetto di tipo DataTable
                //Per poter ciclarne le righe
                DataTable table = (DataTable)e.ReturnValue;

                //Controllo che il numero di righe sia diverso da zero
                if (table.Rows.Count != 0)
                {
                    //Per ricavare l'IdSac necessario ad altri metodi della pagina prendo la prima riga e 
                    //becco il valore relativo alla colonna giusta
                    DataRow row = table.Rows[0];
                    if (row != null)
                    {
                        IdSac = (Guid?)row["IdSac"];

                        //Controllo che il retrieve dell'IdSac sia andato a buon fine. Se non è così lancio un'applicationException
                        if (IdSac != null)
                        {
                            //Se sono arrivato a questo punto posso permettere al flusso della pagina di proseguire quindi:

                            // 1) Permetto che la select dell'odsPaziente possa avvenire settando a false la cancelSelect
                            cancelSelect = false;
                            fvInfoPaziente.DataBind();
                        }
                    }
                }
            }
            catch (ApplicationException ex)
            {
                Master.showAlert(ex.Message);
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        protected void odsPrestazioni_Selecting(object sender, ObjectDataSourceSelectingEventArgs e)
        {
            try
            {
                e.InputParameters["IdOrdineTestata"] = IdOrdine;
            }
            catch (ApplicationException ex)
            {
                Master.showAlert(ex.Message);
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }
        protected void gvPrestazioni_PreRender(object sender, EventArgs e)
        {
            try
            {
                GridView grid = (GridView)sender;
                CreateBootstrapGridViewHeader(grid);
            }
            catch (ApplicationException ex)
            {
                Master.showAlert(ex.Message);
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }


        #region SoloFirmeMetodi-NonAncoraImplementati
        public string GetUltimoEpisodioDescrizione(PazienteType paziente)
        {
            string result = string.Empty;
            try
            {

            }
            catch (ApplicationException ex)
            {
                Master.showAlert(ex.Message);
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                throw;
            }
            return result;
        }
        public string GetImgPresenzaReferti(PazienteType paziente)
        {
            string result = string.Empty;
            try
            {

            }
            catch (ApplicationException ex)
            {
                Master.showAlert(ex.Message);
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                throw;
            }
            return result;
        }
        public string GetSimboloTipoEpisodioRicovero(PazienteType paziente)
        {
            string result = string.Empty;
            try
            {

            }
            catch (ApplicationException ex)
            {
                Master.showAlert(ex.Message);
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                throw;
            }
            return result;
        }
        public string GetImgPresenzaNotaAnamnestica(PazienteType paziente)
        {
            string result = string.Empty;
            try
            {

            }
            catch (ApplicationException ex)
            {
                Master.showAlert(ex.Message);
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                throw;
            }
            return result;
        }
        #endregion
    }
}