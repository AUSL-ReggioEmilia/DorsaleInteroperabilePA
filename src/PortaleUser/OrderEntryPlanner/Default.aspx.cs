using Serilog;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace OrderEntryPlanner
{
	public partial class _Default : Page
	{
		protected void Page_Load(object sender, EventArgs e)
		{
			try
			{
				//throw new ApplicationException("Errore di test");
			}
			catch (Exception ex)
			{
				Log.Error(ex, ex.Message);
			}
		}
	}
}