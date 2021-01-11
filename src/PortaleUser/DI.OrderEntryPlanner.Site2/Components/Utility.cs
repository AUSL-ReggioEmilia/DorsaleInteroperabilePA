using Microsoft.ApplicationInsights;
using OrderEntryPlanner.Pages;
using Serilog;
using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;

namespace OrderEntryPlanner.Components
{
    public static class Utility
    {
        // <summary>
        // Applica la trasformazione XSLT all'xmlSource e scrive l'output sul controllo OutputAspXml
        // </summary>
        public static void ApplyXsltTransform(string xmlSource, string sPathXSLT, ref System.Web.UI.WebControls.Xml OutputAspXml)
        {
            try
            {
                XmlDocument oXmlDocument = new XmlDocument();
                oXmlDocument.LoadXml(xmlSource);
                OutputAspXml.XPathNavigator = oXmlDocument.CreateNavigator();
                OutputAspXml.TransformSource = sPathXSLT;
            }
            catch (Exception ex)
            {
                // 
                // Error
                // 
                throw new Exception(ex.Message + " Errore durante ApplyXsltTransform()!", ex);
            }
        }



        #region Costanti

        public const string sess_dati_ultimo_accesso = "sess_dati_ultimo_accesso";
        public const string sess_user_name = "sess_user_name";
        public const string sess_write_dati_accesso = "sess_write_dati_accesso";
        public const string sess_ricerca_avanzata = "sess_ricerca_avanzata";

        #endregion

        #region LogErrori

        public static void LogError(Exception ex)
        {
            //Scrivo l'errore su application insights.
            TelemetryClient telemetry = new TelemetryClient();
            telemetry.TrackException(ex);

            //Scrivo l'errore su event viewer.
            Log.Error(ex, ex.Message);
        }

        #endregion

        /// <summary>
        /// Ricavo la versione dell'assembly
        /// </summary>
        public static string GetAssemblyVersion()
        {
            string result;
            try
            {
                var assembly = System.Reflection.Assembly.GetExecutingAssembly();
                result = $"Versione: {assembly.GetName().Version}";
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                throw;
            }
            return result;
        }

        /// <summary>
        /// Imposto l'enum relativo ai codici d'errore
        /// </summary>
        public enum ErrorCode
        {
            Unknown,
            AccessDenied,
            NoRights,
            MissingResource,
            Exception,
        }

        /// <summary>
        /// Ricavo il path dell'applicazione
        /// </summary>
        public static string GetApplicationPath()
        {
            string result = string.Empty;
            try
            {
                result = HttpContext.Current.Request.ApplicationPath.TrimEnd('/') + "/";
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                throw;
            }
            return result;
        }

        /// <summary>
        /// Funzione per navigare alla pagina di errore
        /// </summary>
        public static void NavigateToErrorPage(ErrorCode errorCode, string description, bool endResponse)
        {
            try
            {
                string absoluteUri = HttpContext.Current.Request.Url.AbsoluteUri.ToString().ToLower();
                if (!absoluteUri.Contains("errorpage"))
                {

                    ErrorPage.SetErrorDescription(errorCode, description);
                    HttpContext.Current.Response.Redirect("~/ErrorPage.aspx", endResponse);
                }
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                throw;
            }

        }

        /// <summary>
        /// Ricavo l'hostName dell'utente
        /// </summary>
        public static string GetUserHostName()
        {
            string result = string.Empty;

            try
            {
                if (HttpContext.Current.Session["SESS_HOST_NAME"] == null)
                {
                    result = _GetUserHostName();
                    HttpContext.Current.Session["SESS_HOST_NAME"] = result;
                }
                else
                {
                    result = HttpContext.Current.Session["SESS_HOST_NAME"].ToString();
                }
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                throw;
            }
            return result;
        }

        /// <summary>
        /// Metodo secondario per il retrieve dell'hostName dell'utente
        /// </summary>
        /// <returns></returns>
        private static string _GetUserHostName()
        {
            string result = string.Empty;
            try
            {
                string remoteAddr = HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"];

                //Controllo se remoteAddr sia vuoto. Se lo è allora uso la ServerVariabiable "remote_addr"
                if (remoteAddr == null)
                {
                    remoteAddr = HttpContext.Current.Request.ServerVariables["remote_addr"];
                }

                try
                {
                    result = System.Net.Dns.GetHostEntry(remoteAddr).HostName;
                }
                catch (Exception ex)
                {
                    Log.Error(ex, ex.Message);
                    result = remoteAddr;
                    throw;
                }
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                throw;
            }
            return result;
        }

        /// <summary>
        /// Cancella il contenuto di tutte le textbox dentro ad un un div di filtri
        /// </summary>
        /// <param name="divFiltri"></param>
        internal static void ClearTextBoxes(Control divFiltri)
        {
            try
            {
                foreach (Control item in divFiltri.Controls)
                {
                    if (divFiltri.Controls.Count > 0) ClearTextBoxes(item);

                    if (item is TextBox) ((TextBox)(item)).Text = "";
                }
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                throw;
            }
        }

        internal static int CalculateAge(DateTime? dataNascita, DateTime dataRiferimento)
        {
            int result = 0;
            try
            {
                if (dataNascita.HasValue)
                {
                    int eta = dataNascita.Value.Year - dataRiferimento.Year;
                    if (dataNascita > dataRiferimento.AddYears(eta))
                    {
                        eta -= 1;
                    }
                    result = eta;
                }
            }
            catch (Exception ex)
            {
                Log.Error(ex, ex.Message);
                throw;
            }
            return result;
        }
    }
}