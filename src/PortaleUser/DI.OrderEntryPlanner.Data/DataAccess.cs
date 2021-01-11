using System;

namespace DI.OrderEntryPlanner.Data.DataSet.OrdiniTableAdapters
{

	public sealed class DataAccess
	{
		public readonly string OePlannerConnectionString;
        public readonly string WcfSacUser;
        public readonly string WcfSacPassword;

        private DataAccess(string oePlannerConnectionString,string wcfSacUser, string wcfSacPassword)
		{
			try
			{
				OePlannerConnectionString = oePlannerConnectionString;
                WcfSacPassword = wcfSacPassword;
                WcfSacUser = wcfSacUser;
			}
			catch (Exception)
			{
				throw;
			}
		}

		public static DataAccess instance { get; private set; }

		public static void Create(string oePlannerConnectionString,string wcfSacUser, string wcfSacPassword)
		{
			try
			{
				if (string.IsNullOrEmpty(oePlannerConnectionString))
				{
					throw new Exception("Parametro obbligatorio mancante: oePlannerConnectionString");
				}

				if (instance == null)
				{
					instance = new DataAccess(oePlannerConnectionString, wcfSacUser,wcfSacPassword);
				}
			}
			catch (Exception)
			{
				throw;
			}
		}
	}
}