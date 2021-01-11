using DI.PortalUser2;
using DI.PortalUser2.Data;
using System;

namespace OrderEntryPlanner.Components
{

	/// <summary>
	/// Classe SINGLETON inizializzata nel global.asax per condividere le property in tutto il progetto.
	/// </summary>
	public sealed class PortalUserSingleton
	{

		#region PublicProperties

		public readonly RoleManagerUtility2 RoleManagerUtility;
		public readonly SessioneUtente SessioneUtente;
		public readonly PortalDataAdapterManager PortalDataAdapterManager;

		#endregion

		private PortalUserSingleton()
		{
			//Ottengo la connection string del database DiPortalUser.
			string portalUserConnectionString = Properties.Settings.Default.PortalUserConnectionString;

			//Ottengo la connection string del database SAC.
			string sacConnectionString = Properties.Settings.Default.SacConnectionString;

			//Ottengo l'utente SAC.
			string SacWs_User = Properties.Settings.Default.SacWs_User;

			//Ottengo la password SAC.
			string SacWs_Password = Properties.Settings.Default.SacWs_Password;

			//Controllo che "portalUserConnectionString" sia valorizzata.
			if (string.IsNullOrEmpty(portalUserConnectionString))
			{
				throw new Exception("Parametro di configurazione assente: PortalUserConnectionString.");
			}

			//Controllo che "sacConnectionString" sia valorizzata.
			if (string.IsNullOrEmpty(sacConnectionString))
			{
				throw new Exception("Parametro di configurazione assente: SacConnectionString.");
			}

			SessioneUtente = new SessioneUtente(sacConnectionString, portalUserConnectionString, SacWs_User, SacWs_Password);
			RoleManagerUtility = new RoleManagerUtility2(portalUserConnectionString, sacConnectionString, SacWs_User, SacWs_Password);
			PortalDataAdapterManager = new PortalDataAdapterManager(portalUserConnectionString);
		}

		private static PortalUserSingleton _instance;

		public static PortalUserSingleton instance
		{
			get
			{
				if (_instance == null)
				{
					_instance = new PortalUserSingleton();
				}
				return _instance;
			}
		}


	}
}