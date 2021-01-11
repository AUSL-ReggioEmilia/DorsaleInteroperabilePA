using OrderEntryPlanner.WcfPazienti;
using OrderEntryPlanner.Components;
using Serilog;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using static DI.OrderEntryPlanner.Data.DataSet.Ordini;

namespace OrderEntryPlanner.Pages
{
    public partial class RicercaOrdini : System.Web.UI.Page
    {
        private const string SESSIONFILTER = "SESSIONFILTER_RicercaOrdini";
        static bool cancelSelect = true;

        public bool FiltriAdvancedState
        {
            get
            {
                bool? val = (bool?)ViewState["collapse"];

                if (!val.HasValue) return false;
                return val.Value;
            }

            set
            {
                ViewState["collapse"] = value;
            }
        }

        public string FiltriAdvancedCss
        {
            get
            {
                if (FiltriAdvancedState) return "collpase in";
                else return "collapse";
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (!IsPostBack)
                {
                    //setto i valori dei filtri con i dati presenti in sessione
                    SetFilterValues();
                }
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        protected void odsRicerche_Selecting(object sender, ObjectDataSourceSelectingEventArgs e)
        {
            try
            {
                if (cancelSelect)
                {
                    e.Cancel = true;
                    return;
                }

                String sDataDal = txtDataDal.Text;
                String sDataAl = txtDataAl.Text;

                //Se i campi data sono vuoti allora leggo le date dalla combo
                if (String.IsNullOrEmpty(sDataDal) && String.IsNullOrEmpty(sDataAl))
                {
                    switch (ddlPeriodo.SelectedValue)
                    {
                        case "-1":
                            // Caso non Prenotati
                            e.InputParameters["Prenotato"] = false;
                            // Filtro "Tutti"
                            e.InputParameters["DataDal"] = null;
                            e.InputParameters["DataAl"] = null;
                            break;

                        case "0":
                            // Filtro "Tutti"
                            e.InputParameters["DataDal"] = null;
                            e.InputParameters["DataAl"] = null;
                            break;

                        case "1":
                            // Parse del filtro "Oggi"(1) 
                            e.InputParameters["DataDal"] = DateTime.Today;
                            e.InputParameters["DataAl"] = DateTime.Today.AddDays(1).AddSeconds(-1);
                            break;
                        
                        case "2":
                            // Parse del filtro "Domani"(2) 
                            e.InputParameters["DataDal"] = DateTime.Today;
                            e.InputParameters["DataAl"] = DateTime.Today.AddDays(2).AddSeconds(-1);
                            break;

                        default:
                            // Parse del filtro "Prossimi 3 giorni"(3) , "Prossimi 7 giorni"(7) e "Prossimi 30 giorni"(30)

                            e.InputParameters["DataDal"] = DateTime.Today;
                            //days +1 perchè esempio: i prossimi 3 giorni sono da oggi a +3 giorni
                            int days = int.Parse(ddlPeriodo.SelectedValue) +1 ;
                            e.InputParameters["DataAl"] = DateTime.Today.AddDays(days).AddSeconds(-1);
                            break;
                    }
                }
                else
                {
                    //Data Dal
                    if (!String.IsNullOrEmpty(sDataDal) &&  DateTime.TryParse(sDataDal, out DateTime dataDal))
                    {
                        //Solo se la DataDal è una data valida
                        e.InputParameters["DataDal"] = dataDal;
                    }

                    //Data Al
                    if (!String.IsNullOrEmpty(sDataAl) && DateTime.TryParse(sDataAl, out DateTime dataAl))
                    {
                        //Solo se la DataAl è una data valida
                        //Imposto le 23:59 del giorno scelto
                        e.InputParameters["DataAl"] = dataAl.AddDays(1).AddSeconds(-1);
                    }
                }

                //Chiamo la funzione "GetParamSistemiErogantiDataTable" per costruire la data table da usare come parametro per il campo SistemiEroganti
                e.InputParameters["SistemiEroganti"] = GetParamSistemiErogantiDataTable();
            }

            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        protected void btnCerca_Click(object sender, EventArgs e)
        {
            try
            {
                //Salvo i valori dei filtri in sessione
                SaveFilterValues();

                //Forzo l'aggiornamento della GridView
                cancelSelect = false;
                gvRicerche.DataBind();

                UpdPanelGriglia.Update();
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        protected void btnAnnulla_Click(object sender, EventArgs e)
        {
            try
            {
                Components.Utility.ClearTextBoxes(divFiltri);
                UpdPanelFiltri.Update();

                gvRicerche.Columns.Clear();
                UpdPanelGriglia.Update();

            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        protected void gvRicerche_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            try
            {
                if (e.CommandName.ToLower() == "apri")
                {
                    //Navigo alla pagina di riassunto ordine
                    GridViewRow row = (GridViewRow)((Control)e.CommandSource).NamingContainer;
                    string Id = gvRicerche.DataKeys[row.RowIndex].Values["Id"].ToString();

                    //Salvo in sessione i filtri con i rispettivi valori
                    SaveFilterValues();

                    //Eseguo il redirect alla pagina di dettaglio ordine
                    Response.Redirect($"DettaglioOrdine?IdOrdine={Id}", false);
                }
                else if (e.CommandName.ToLower() == "pianifica")
                {
                    // Navigo al calendario per la pianificazione dell'ordine selezionato
                    GridViewRow row = (GridViewRow)((Control)e.CommandSource).NamingContainer;
                    string Id = gvRicerche.DataKeys[row.RowIndex].Values["Id"].ToString();

                    //Salvo in sessione i filtri con i rispettivi valori
                    SaveFilterValues();

                    //Eseguo il redirect alla pagina di dettaglio ordine specificando il Paret (la pagina di origine)
                    Response.Redirect($"PianificaOrdine?IdOrdine={Id}&Parent=List", false);
                }
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        protected void gvRicerche_PreRender(object sender, EventArgs e)
        {
            try
            {
                GridView grid = (GridView)sender;

                //Bootstrap Setup per le gridview
                HelperGridView.SetUpGridView(grid, this.Page);
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        protected void gvRicerche_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            try
            {
                if (e.Row.RowType == DataControlRowType.DataRow)
                {
                    DataRowView dataRow = (DataRowView)(e.Row.DataItem);

                    if (dataRow != null)
                    {
                        OrdiniTestateCercaRow rowOrdine = (OrdiniTestateCercaRow)(dataRow.Row);

                        //Cambio il colore del record in base allo stato dell'ordine
                        if (rowOrdine.Prenotato == false)
                        {
                            e.Row.CssClass = "table-warning"; //sfondo giallo
                        }
                        else if (rowOrdine.PrenotazioneVariata == true)
                        {
                            e.Row.CssClass = "table-info"; //sfondo azzurro
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        /// <summary>
		///  Funzione usata per costruire la datatable dei SistemiEroganti da passare come parametro all'ObjectDataSource degli ordini.
		/// </summary>
		protected DataTable GetParamSistemiErogantiDataTable()
        {
            //Dichiaro una nuova DataTable e aggiungo due colonne "CodiceAzienda" e "Codice".
            DataTable result = new DataTable();
            try
            {
                //Se il SelectedValue della dropdownlist è vuoto allora ho selezionato il valore "Tutti" quindi creo una DataTable composta da tutti i sistemi eroganti.
                result.Columns.Add("CodiceAzienda", typeof(string));
                result.Columns.Add("Codice", typeof(string));

                if (string.IsNullOrEmpty(ddlErogante.SelectedValue))
                {
                    //ciclo tutti gli item della dropdownlist.
                    foreach (ListItem item in ddlErogante.Items)
                    {
                        // scarto il primo item "Tutti".
                        if (!string.IsNullOrEmpty(item.Value))
                        {
                            //Il value della dropdownlist è composta dal codice dell'azienda + il codice del sistema separati da "@".
                            //creo un'array con i valori del value della combo splittati per il carattete "@".
                            string[] arrayCodiceAziendaESistema = item.Value.Split('@');

                            //ottengo il codice del sistema e il codice dell'azienda.
                            string codiceSistema = arrayCodiceAziendaESistema[0];
                            string codiceAzienda = arrayCodiceAziendaESistema[1];

                            //Aggiungo i valori alla DataTable.
                            result.Rows.Add(codiceAzienda, codiceSistema);
                        }
                    }
                }
                else
                {
                    //Se sono qui allora è stato selezionato un Sistema Erogante.
                    //Prendo il selected value e lo splitto per il carattere "@".
                    string[] arrayCodiceAziendaESistema = ddlErogante.SelectedValue.Split('@');

                    //Ottengo il codice del sistema e il codice dell'azienda.
                    string codiceSistema = arrayCodiceAziendaESistema[0];
                    string codiceAzienda = arrayCodiceAziendaESistema[1];

                    //inserisco i valori all'interno della DataTable.
                    result.Rows.Add(codiceAzienda, codiceSistema);
                }
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
            return result;
        }


        #region GestioneFiltri

        /// <summary>
        /// Metodo che permette il salvataggio dei filtri e dei relativi valori per poter essere reimpostati in caso di un non-postback
        /// </summary>
        private void SaveFilterValues()
        {
            try
            {
                Session[SESSIONFILTER + txtCognome.ID] = txtCognome.Text;
                Session[SESSIONFILTER + txtNome.ID] = txtNome.Text;
                Session[SESSIONFILTER + ddlPeriodo.ID] = ddlPeriodo.Text;
                Session[SESSIONFILTER + txtAnnoNascita.ID] = txtAnnoNascita.Text;
                Session[SESSIONFILTER + txtDataNascita.ID] = txtDataNascita.Text;
                Session[SESSIONFILTER + txtNumeroNosologico.ID] = txtNumeroNosologico.Text;
                Session[SESSIONFILTER + txtDataDal.ID] = txtDataDal.Text;
                Session[SESSIONFILTER + txtDataAl.ID] = txtDataAl.Text;
                Session[SESSIONFILTER + ddlPriorita.ID] = ddlPriorita.Text;
                Session[SESSIONFILTER + ddlRegime.ID] = ddlRegime.Text;
                Session[SESSIONFILTER + ddlErogante.ID] = ddlErogante.Text;
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        /// <summary>
        /// Reimposta i valori dei filtri con i dati presenti in sessione
        /// </summary>
        private void SetFilterValues()
        {
            try
            {
                txtCognome.Text = (string)Session[SESSIONFILTER + txtCognome.ID];
                txtNome.Text = (string)Session[SESSIONFILTER + txtNome.ID];
                //txtUnitaOperativa.Text = (string)Session[SESSIONFILTER + txtUnitaOperativa.ID];

                if (!string.IsNullOrEmpty((string)Session[SESSIONFILTER + ddlPeriodo.ID])) ddlPeriodo.Text = (string)Session[SESSIONFILTER + ddlPeriodo.ID];

                txtAnnoNascita.Text = (string)Session[SESSIONFILTER + txtAnnoNascita.ID];
                txtDataNascita.Text = (string)Session[SESSIONFILTER + txtDataNascita.ID];
                txtNumeroNosologico.Text = (string)Session[SESSIONFILTER + txtNumeroNosologico.ID];
                txtDataDal.Text = (string)Session[SESSIONFILTER + txtDataDal.ID];
                txtDataAl.Text = (string)Session[SESSIONFILTER + txtDataAl.ID];

                if (!string.IsNullOrEmpty((string)Session[SESSIONFILTER + ddlPriorita.ID])) ddlPriorita.Text = (string)Session[SESSIONFILTER + ddlPriorita.ID];

                if (!string.IsNullOrEmpty((string)Session[SESSIONFILTER + ddlRegime.ID])) ddlRegime.Text = (string)Session[SESSIONFILTER + ddlRegime.ID];

                if (!string.IsNullOrEmpty((string)Session[SESSIONFILTER + ddlErogante.ID])) ddlErogante.Text = (string)Session[SESSIONFILTER + ddlErogante.ID];
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }


        #endregion

        protected void BtnRicercaAvanzata_Click(object sender, EventArgs e)
        {
            FiltriAdvancedState = !FiltriAdvancedState;
            UpdPanelFiltri.Update();
        }
    }
}
