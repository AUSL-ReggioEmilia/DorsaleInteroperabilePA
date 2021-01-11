using DI.OrderEntryPlanner.Data;
using DI.OrderEntryPlanner.Data.DataSet.OrdiniTableAdapters;
using DI.PortalUser2;
using DI.PortalUser2.Data;
using Microsoft.ApplicationInsights.Extensibility;
using OrderEntryPlanner.Components;
using OrderEntryPlanner.Components.CustomInitializer.Telemetry;
using OrderEntryPlanner.Properties;
using Serilog;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.Optimization;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;

namespace OrderEntryPlanner
{
	//TODO: Gestire RoleManager tramite la dll DiPortalUser2

	public class Global : HttpApplication
	{
		private static System.Collections.Generic.Dictionary<string, DateTime> usersLastRequestDateTime = new System.Collections.Generic.Dictionary<string, DateTime>();

		void Application_Start(object sender, EventArgs e)
		{
			// Code that runs on application startup.
			RouteConfig.RegisterRoutes(RouteTable.Routes);
			BundleConfig.RegisterBundles(BundleTable.Bundles);

			// Configura Serilog Event trace su File.
			Log.Logger = new LoggerConfiguration()
				.ReadFrom.AppSettings()
				.WriteTo.EventLog("OrderEntryPlanner", manageEventSource: true)
				.CreateLogger();

			//Fondamentale per il debug degli errori durante la fase di start dell'applicazione.
			Serilog.Debugging.SelfLog.Enable(msg => Debug.WriteLine(msg));

            //Inizializzazione della telemetry.
            TelemetryConfiguration.Active.TelemetryInitializers.Add(new MyTelemetryInitializer());
        }

		void Session_Start(object sender, EventArgs e)
		{
			try
			{
				//Traccio l'accesso al portale.
				string msgTracciamentoAccessi = $"Accesso effettuato il {DateTime.Now.ToString("dd/MM/yyyy")} alle ore {DateTime.Now.ToString("HH:mm:ss")}";
				PortalUserSingleton.instance.PortalDataAdapterManager.TracciaAccessi(User.Identity.Name, PortalsNames.OrderEntryPlanner, msgTracciamentoAccessi);

				//Memorizzo in sessione le informazioni sull'ultimo accesso. Verranno utilizzati nella master page.
				Session.Add(Components.Utility.sess_dati_ultimo_accesso, PortalUserSingleton.instance.SessioneUtente.GetUltimoAccesso(User.Identity.Name, PortalsNames.OrderEntryPlanner));

				//Memorizzo il nome utente, utilizzato nella funzione SessionEnd per sapere chi è l'utente che si è disconnesso.
				Session.Add(Components.Utility.sess_user_name, User.Identity.Name);

				//Creo le table adapter per l'accesso ai dati.
				DataAccess.Create(Settings.Default.OrderEntryPlannerConnectionString, Settings.Default.SacWs_User, Settings.Default.SacWs_Password);
			}

			catch (Exception ex)
			{
				Log.Error(ex, ex.Message);
				Components.Utility.NavigateToErrorPage(Components.Utility.ErrorCode.Exception, ex.Message, false);
			}
		}

		void Session_End(object sender, EventArgs e)
		{
			try
			{
				//Ottengo lo user name dell'utente che si è disconnesso.
				string userName = Session[Components.Utility.sess_user_name]?.ToString();

				//Ottengo la connection string del database DiPortalUser.
				string portalUserConnectionString = Settings.Default.PortalUserConnectionString;

				//Controllo se la connection string è valorizzata.
				if (!(string.IsNullOrEmpty(portalUserConnectionString)))
				{
					lock (usersLastRequestDateTime)
					{
						DateTime accessDate = DateTime.Now;

						if (usersLastRequestDateTime.ContainsKey(userName))
						{
							accessDate = usersLastRequestDateTime[userName];
						}
					}

					//Traccio l'accesso al portale.
					string msgTracciamentoAccessi = $"L'utente si è disconnesso il {DateTime.Now.ToString("dd/MM/yyyy")} alle ore {DateTime.Now.ToString("HH:mm:ss")}";
					PortalUserSingleton.instance.PortalDataAdapterManager.TracciaAccessi(userName, PortalsNames.OrderEntryPlanner, msgTracciamentoAccessi);
				}
				else
				{
					lock (usersLastRequestDateTime)
					{
						usersLastRequestDateTime.Remove(userName);
					}
				}
			}
			catch (Exception ex)
			{
				Log.Error(ex, ex.Message);
				Components.Utility.NavigateToErrorPage(Components.Utility.ErrorCode.Exception, ex.Message, false);

			}
		}

		void Application_PostAuthenticateRequest(object sender, EventArgs e)
		{
			try
			{
				lock (usersLastRequestDateTime)
				{
					if (!(usersLastRequestDateTime.ContainsKey(User.Identity.Name)))
					{
						usersLastRequestDateTime.Add(User.Identity.Name, DateTime.Now);
					}
					else
					{
						usersLastRequestDateTime[User.Identity.Name] = DateTime.Now;
					}
				}
			}
			catch (Exception ex)
			{
				Log.Error(ex, ex.Message);
				Components.Utility.NavigateToErrorPage(Components.Utility.ErrorCode.Exception, ex.Message, false);

			}
		}

		void Application_AuthenticateRequest(object sender, EventArgs e)
		{
			try
			{
				//
				// Questo evento viene chiamato per ogni risorsa non solo per le pagine ASPX
				// ATTENZIONE: tutto il codice deve essere scritto all'interno dell'"If Request.IsAuthenticated Then"
				// E' stato testato il CONTAINS perchè questo progetto invoca dei Web Methods e l'url invocato può essere del tipo "xxx.aspx/NomeMetodo"
				//
				if (Request.IsAuthenticated)
				{
					string currentUrl = Request.Url.AbsolutePath.ToLower();

					//TODO: @Simone - Si può spostare in un altro punto?
					if (currentUrl.Contains("/pages") || currentUrl.Contains("/default"))
					{
						//Inizializzo l'utente.
						PortalUserSingleton.instance.RoleManagerUtility.InitializeUser();
					}
				}
			}
			catch (Exception ex)
			{
				Log.Error(ex, ex.Message);
				Components.Utility.NavigateToErrorPage(Components.Utility.ErrorCode.Exception, ex.Message, false);

			}
		}

		void Application_Error(object sender, EventArgs e)
		{
			// Code that runs when an unhandled error occurs
			// Give the user some information, but
			Exception ex = Server.GetLastError();

			// Write LOG
			Log.Error(ex, "Application_Error()!");

			// Se abilitato il CUSTOM error lo visualizza
			if (HttpContext.Current.IsCustomErrorEnabled && ex != null)
			{
				// stay on the default page
				Response.Write("<h2>Global Page Error</h2>\n");
				Response.Write("<p>" + ex.Message + "</p>\n");
				Response.Write("Return to the <a href='Default.aspx'>Default Page</a>\n");

				// Clear the error from the server
				Server.ClearError();
			}
		}
	}
}