using Serilog;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace OrderEntryPlanner.Pages
{
	public partial class ErrorPage : System.Web.UI.Page
	{
		private const string ERRORE_CODICE = "ERRORPAGE_ERRORE_CODICE";
		private const string ERRORE_DESCRIZIONE = "ERRORPAGE_ERRORE_DESCRIZIONE";

		protected void Page_Load(object sender, EventArgs e)
		{
			try
			{
				string errorDescription = string.Empty;
				Components.Utility.ErrorCode errorCode = Components.Utility.ErrorCode.Unknown;
				if (HttpContext.Current.Session[ERRORE_DESCRIZIONE] != null) errorDescription = HttpContext.Current.Session[ERRORE_DESCRIZIONE].ToString();
				if (HttpContext.Current.Session[ERRORE_CODICE] != null) errorCode = (Components.Utility.ErrorCode)HttpContext.Current.Session[ERRORE_CODICE];

				if (!IsPostBack)
				{
					//Non posso usare il costrutto switch per elementi che vengono calcolati a runtime, ad esempio gli enum
					if (errorCode == Components.Utility.ErrorCode.Unknown)
					{
						imgErrorImage.ImageUrl = ResolveUrl("~/Images/ErrorUnknown.gif");
						lblErroreDescrizioneBreve.Text = errorDescription;
					}
					else if (errorCode == Components.Utility.ErrorCode.NoRights)
					{
						imgErrorImage.ImageUrl = ResolveUrl("~/Images/ErrorAccessDenied.gif");
						lblErroreDescrizioneBreve.Text = errorDescription;
					}
					else if (errorCode == Components.Utility.ErrorCode.AccessDenied)
					{
						imgErrorImage.ImageUrl = ResolveUrl("~/Images/ErrorAccessDenied.gif");
						lblErroreDescrizioneBreve.Text = errorDescription;
					}
					else if (errorCode == Components.Utility.ErrorCode.MissingResource)
					{
						imgErrorImage.ImageUrl = ResolveUrl("~/Images/ErrorMissingResource.gif");
						lblErroreDescrizioneBreve.Text = errorDescription;
					}
					else if (errorCode == Components.Utility.ErrorCode.Exception)
					{
						imgErrorImage.ImageUrl = ResolveUrl("~/Images/ErrorUnknown.gif");
						lblErroreDescrizioneBreve.Text = errorDescription;
					}
					else
					{
						Log.Error("Passato un parametro non valido alla pagina ErrorPage");
						imgErrorImage.ImageUrl = ResolveUrl("~/Images/ErrorUnknown.gif");
						lblErroreDescrizioneBreve.Text = "ERRORE SCONOSCIUTO, CONTATTARE L'AMMINISTRATORE";
					}
				}
			}
			catch (Exception ex)
			{
                Components.Utility.LogError(ex);
			}
		}

		public static void SetErrorDescription(Components.Utility.ErrorCode errorCode, string errorDescription)
		{
			try
			{
				HttpContext.Current.Session[ERRORE_CODICE] = errorCode;
				HttpContext.Current.Session[ERRORE_DESCRIZIONE] = errorDescription;
			}
			catch (Exception ex)
			{
                Components.Utility.LogError(ex);
			}
		}
	}
}