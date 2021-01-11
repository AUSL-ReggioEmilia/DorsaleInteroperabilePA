using System;
using Serilog;
using System.Web.UI.WebControls;
using System.Data;
using System.Web.UI;
using DI.OrderEntryPlanner.Data.CustomDataSet;
using DI.OrderEntryPlanner.Data.WcfSacPazienti;
using OrderEntryPlanner.Components;
using static DI.OrderEntryPlanner.Data.DataSet.Ordini;
using System.Drawing;

namespace OrderEntryPlanner.Pages
{
	public partial class RicercaOrdini : System.Web.UI.Page
	{

		private const string SESSIONFILTER = "SESSIONFILTER_RicercaOrdini";
		static bool cancelSelect = true;

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
				e.Cancel = cancelSelect;

                switch (ddlPeriodo.SelectedValue)
                {
                    case "0":
                        e.InputParameters["DataDal"] = null;
                        break;
                    default:
                        int days = int.Parse(ddlPeriodo.SelectedValue);
                        e.InputParameters["DataDal"] = DateTime.Now.AddDays(-days);
                        break;
                }

                e.InputParameters["DataAl"] = DateTime.Today.AddDays(1);

                //Chiamo la funzione "GetParamSistemiErogantiDataTable" per costruire la data table da usare come parametro per il campo SistemiEroganti
                e.InputParameters["SistemiEroganti"] = GetParamSistemiErogantiDataTable();

				switch (ddlProgrammato.SelectedValue)
				{
					case "0":
						e.InputParameters["Programmato"] = false;
						break;
					case "1":
						e.InputParameters["Programmato"] = true;
						break;
					default:
						e.InputParameters["Programmato"] = null;
						break;
				}

				switch (ddlProgrammabile.SelectedValue)
				{
					case "0":
						e.InputParameters["Programmabile"] = false;
						break;
					case "1":
						e.InputParameters["Programmabile"] = true;
						break;
					default:
						e.InputParameters["Programmabile"] = null;
						break;
				}
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

		protected void btnAnnulla_Click(object sender, EventArgs e)
		{
			try
			{
				Components.Utility.ClearTextBoxes(divFiltri);
				gvRicerche.Columns.Clear();
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
                        if (rowOrdine.Programmato == 1)
                        {
                            e.Row.CssClass = "table-warning"; //sfondo giallo
                        }
                         if (rowOrdine.IsRichiedenteProgrammabileNull() || !rowOrdine.RichiedenteProgrammabile)
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
        /// Funzione che ottiene le informazioni del paziente da mettere in riga
        /// </summary>
        /// <param name="stringIdSac"></param>
        /// <returns></returns>
		public string GetColumnPaziente(string stringIdSac)
		{
			string result = string.Empty;
			try
			{
				PazientiDataSource.Paziente pazienteDataSource = new PazientiDataSource.Paziente();

				Guid IdSac = Guid.Parse(stringIdSac);
				PazienteType paziente = pazienteDataSource.GetDataById(null, IdSac);
                

                result += "<b>";                                                                                                    
				if (!string.IsNullOrEmpty(paziente.Generalita.Cognome)) result += paziente.Generalita.Cognome.ToUpper();           
                if (!string.IsNullOrEmpty(paziente.Generalita.Nome)) result += ", " + paziente.Generalita.Nome.ToUpper();          
				if (!string.IsNullOrEmpty(paziente.Generalita.Sesso)) result += " (" + paziente.Generalita.Sesso.ToUpper() + ")";   
                result += "</b>";                                                                                                   

                if (paziente.Generalita.DataNascita != null)
				{
					result += "<br />nato il " + ((DateTime)paziente.Generalita.DataNascita).ToString("MM/dd/yyyy HH:mm");
					if (!string.IsNullOrEmpty(paziente.Generalita.ComuneNascitaNome)) result += " a " + paziente.Generalita.ComuneNascitaNome;
				}
				if (!string.IsNullOrEmpty(paziente.Generalita.CodiceFiscale)) result += "<br />CF: " + paziente.Generalita.CodiceFiscale;
			}
			catch (Exception ex)
			{
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
			}
			return result;
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
                Session[SESSIONFILTER + ddlProgrammato.ID] = ddlProgrammato.Text;
                Session[SESSIONFILTER + ddlProgrammabile.ID] = ddlProgrammabile.Text;
                Session[SESSIONFILTER + ddlStato.ID] = ddlStato.Text;
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

                if (!string.IsNullOrEmpty((string)Session[SESSIONFILTER + ddlStato.ID])) ddlStato.Text = (string)Session[SESSIONFILTER + ddlStato.ID];

                if (!string.IsNullOrEmpty((string)Session[SESSIONFILTER + ddlProgrammato.ID])) ddlProgrammato.Text = (string)Session[SESSIONFILTER + ddlProgrammato.ID];

                if (!string.IsNullOrEmpty((string)Session[SESSIONFILTER + ddlProgrammabile.ID])) ddlProgrammabile.Text = (string)Session[SESSIONFILTER + ddlProgrammabile.ID];

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
    }
}