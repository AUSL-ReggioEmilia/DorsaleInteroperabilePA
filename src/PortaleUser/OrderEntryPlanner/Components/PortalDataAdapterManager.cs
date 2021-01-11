using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using DI.PortalUser2.Data;

namespace OrderEntryPlanner.Components
{
	public sealed class PortalDataAdapterManagerSingleton
	{
		private PortalDataAdapterManagerSingleton()
		{
		}

		private static PortalDataAdapterManager instance = null;

		public static PortalDataAdapterManager Instance
		{
			get
			{
				if (instance == null)
				{
					string portalUserConnectionString = Properties.Settings.Default.PortalUserConnectionString;
					instance = new PortalDataAdapterManager(portalUserConnectionString);
				}
				return Instance;
			}
		}


	}
}