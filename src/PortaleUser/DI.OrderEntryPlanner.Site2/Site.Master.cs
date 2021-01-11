using System;
using System.Web;
using System.Web.UI;
using System.Net.NetworkInformation;
using System.Collections;
using DI.PortalUser2;
using System.Web.UI.WebControls;
using Serilog;
using DI.PortalUser2.Data;
using System.Collections.Generic;
using OrderEntryPlanner.Properties;
using DI.PortalUser2.RoleManager;
using OrderEntryPlanner.Components;

namespace OrderEntryPlanner
{
    public partial class SiteMaster : MasterPage
    {
        #region Properties

        private UserInterface userInterface = new UserInterface(Properties.Settings.Default.PortalUserConnectionString);
        private string currentUserName = HttpContext.Current.User.Identity.Name.ToUpper();

        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                //Valorizzo il titolo della pagina.
                Page.Title = PortalsTitles.OrderEntryPlanner;

                //Valorizzo la versione del progetto.
                lblVersioneAssembly.Text = Components.Utility.GetAssemblyVersion();

                //Valorizzo il nome del server.
                var oProperties = IPGlobalProperties.GetIPGlobalProperties();
                lblNomeHost.Text = string.Format("{0}.{1}", oProperties.HostName, oProperties.DomainName);

                //Imposto l'header
                HeaderPlaceholder.Text = userInterface.GetBootstrapHeader2(PortalsTitles.OrderEntryPlanner);

                if (!IsPostBack)
                {

                    //Popolo il menu orizzontale
                    PopolaMenuPrincipale();

                    //Popolo le info relative all'utente
                    PopolaInfoUtente();
                }

                //Traccio gli accessi al portale.
                PortalUserTracciaAccessi();
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        protected void ddlRuoliUtente_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                DropDownList ddlRuoliUtente = (DropDownList)(sender);

                //Salvo nella tabella DatiUtente l'ultimo ruolo scelto dall'utente
                PortalUserSingleton.instance.PortalDataAdapterManager.DatiUtenteSalvaValore(currentUserName, RoleManagerUtility2.DI_USER_RUOLO_CORRENTE_CODICE, ddlRuoliUtente.SelectedItem.Value);

                //Scrivo la data di accesso corrente e il ruolo corrente: sarà quella letta alla prossima ripartenza della sessione
                PortalUserSingleton.instance.SessioneUtente.SetUltimoAccesso(currentUserName, PortalsNames.OrderEntryPlanner, DateTime.Now, ddlRuoliUtente.SelectedItem.Value);

                //Imposto endResponse = false per non generarare ThreadAbortException
                Response.Redirect(Request.RawUrl, false);
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        #region FunzioniUtility
        /// <summary>
        /// Metodo che popola il menu principale (cross-application)
        /// </summary>
        private void PopolaMenuPrincipale()
        {
            try
            {
                //Elimino tutti gli elementi dal menu.
                MenuMain.Items.Clear();

                //Ottengo l'id del portale.
                int idPortale = (int)PortalDataAdapterManager.EnumPortalId.OrderEntryPlanner;

                //Ottengo le voci del menu.
                List<PortalUserMenuItem> listaPortalUserMenuItem = PortalUserSingleton.instance.PortalDataAdapterManager.GetMainMenu(idPortale);

                //Aggiungo le voci del menu.
                foreach (var menuItem in listaPortalUserMenuItem)
                {
                    MenuItem newMenuItem = new MenuItem(menuItem.Descrizione, null, null, ResolveUrl(menuItem.Url), string.Empty);
                    MenuMain.Items.Add(newMenuItem);
                    newMenuItem.Selected = menuItem.IsSelected;
                }
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        /// <summary>
        /// Funzione utilizzata per visualizzare il messaggio di errore.
        /// </summary>
        /// <param name="text"></param>
        public void showAlert(string text)
        {
            try
            {
                DivError.Visible = text.Length > 0;
                DivError.InnerText = text;

                if (text.Length > 0) DivError.Style.Remove("display");
                else DivError.Style.Add("display", "none");
                updError.Update();

            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }


        /// <summary>
        /// Metodo che popola le info relative all'utente
        /// </summary>
        private void PopolaInfoUtente()
        {
            try
            {
                //Popolo la combo dei ruoli.
                List<Ruolo> listaRuoli = PortalUserSingleton.instance.RoleManagerUtility.GetRuoli();

                //Se l'utente non ha ruoli allora restituisco un errore.
                if (listaRuoli == null || listaRuoli.Count == 0)
                {
                    throw new ApplicationException("L'utente corrente non ha ruoli associati.");
                }

                //Popolo la combo dei ruoli
                PopolaComboRuoliUtente(listaRuoli);

                string nomeCognomeUtente = string.Empty;

                //Questo oggetto viene salvato in sessione all'interno del global.asax
                SessioneUtente.UltimoAccesso ultimoAccesso = (SessioneUtente.UltimoAccesso)Session[Components.Utility.sess_dati_ultimo_accesso];
                if (ultimoAccesso != null)
                {
                    nomeCognomeUtente = $"{ultimoAccesso.Utente?.Nome} {ultimoAccesso.Utente?.Cognome}";
                    lblUltimoAccesso.Text = ultimoAccesso.UltimoAccessoDescrizione;
                }

                //valorizzo il nome-cognome dell'utente e il ruolo corrente.
                lblInfoUtente.Text = $"{nomeCognomeUtente} - {ddlRuoliUtente.SelectedItem.Text}";

                //Valorizzo il nome utente e la postazione contenuti nella dropdownlist dei ruoli.
                lblUtente.Text = currentUserName;
                lblPostazione.Text = Components.Utility.GetUserHostName();
            }
            catch (ApplicationException ex)
            {
                //Nascondo la riga della tabella con la combo dei ruoli.
                divRuoli.Visible = false; //TODO: @SimoneB - Verificare se serve.
                Log.Error(ex, ex.Message);
                Components.Utility.NavigateToErrorPage(Components.Utility.ErrorCode.Exception, ex.Message, false);
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        /// <summary>
        ///  Metodo per popolare la combo dei ruoli
        /// </summary>
        private void PopolaComboRuoliUtente(List<Ruolo> listaRuoli)
        {
            try
            {
                //ottengo il ruolo corrente
                string ruoloCorrenteCodice = PortalUserSingleton.instance.RoleManagerUtility.RuoloCorrente.Codice;

                //Cancello gli item della combo
                ddlRuoliUtente.Items.Clear();

                //Popolo la combo con i ruoli dell'utente
                ddlRuoliUtente.DataSource = listaRuoli;
                ddlRuoliUtente.DataValueField = "Codice";
                ddlRuoliUtente.DataTextField = "Descrizione";
                ddlRuoliUtente.DataBind();

                //Effettuo il bind della combo
                if (ruoloCorrenteCodice != null)
                {
                    ListItem item = ddlRuoliUtente.Items.FindByValue(ruoloCorrenteCodice);
                    if (item != null)
                    {
                        item.Selected = true;
                    }
                }
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }

        /// <summary>
        /// Funzione che traccia gli accessi al PortalUser
        /// </summary>
        private void PortalUserTracciaAccessi()
        {
            try
            {
                //Arrivato a questo punto scrivo in sessione i dati di accesso: lo faccio una volta sola a sessione
                if (Session[Components.Utility.sess_write_dati_accesso] == null)
                {
                    //In caso di errore dovuto alla mancanza di ruoli per l'utente cmbRuoliUtente.SelectedItem è null
                    if (ddlRuoliUtente.SelectedItem != null)
                    {
                        //Setto a true la relativa variabile di sessione
                        Session[Components.Utility.sess_write_dati_accesso] = true;

                        //Scrivo la data e il ruolo dell'accesso corrente. La prossima sessione ripartirà da questi elementi
                        PortalUserSingleton.instance.SessioneUtente.SetUltimoAccesso(currentUserName, PortalsNames.OrderEntryPlanner, DateTime.Now, ddlRuoliUtente.SelectedItem.Value);

                        //Traccio l'accesso al portale.
                        string msgTracciamentoAccessi = $"Accesso effettuato il {DateTime.Now.ToString("dd/MM/yyyy")} alle ore {DateTime.Now.ToString("HH:mm:ss")}";
                        PortalUserSingleton.instance.PortalDataAdapterManager.TracciaAccessi(HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntryPlanner, msgTracciamentoAccessi, ddlRuoliUtente.SelectedValue);
                    }
                }
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }
        #endregion
    }
}