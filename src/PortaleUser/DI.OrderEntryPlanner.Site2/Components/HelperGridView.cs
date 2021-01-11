using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace OrderEntryPlanner.Components
{
	public static class HelperGridView
	{


		public static string GetScriptPaginationForBootstrap()
		{
			StringBuilder sbScript = new StringBuilder();
			try
			{
				// Lo script converte i tag html generati dalla GridView per la paginazione
				//e li adatta alle necessita dei CSS Bootstrap
				// Aggiungere alla GridView la classe 'pagination - gridview' nel PagerStyle
				//PagerStyle-CssClass="pagination-gridview"
				//

				sbScript.AppendLine("$('.pagination-gridview td table').each(function (index, obj) {");

				sbScript.AppendLine("       convertToPagination(obj)");

				sbScript.AppendLine("       });");

				sbScript.AppendLine("");

				sbScript.AppendLine("function convertToPagination(obj) {");

				sbScript.AppendLine("   var liststring = '<ul class=\"pagination\">';");

				sbScript.AppendLine("   $(obj).find(\"tbody tr\").each(function () {");

				sbScript.AppendLine("       $(this).children().map(function () {");

				sbScript.AppendLine("           liststring = liststring + \"<li>\" + $(this).html() + \"</li>\";");

				sbScript.AppendLine("       });");

				sbScript.AppendLine("   });");

				sbScript.AppendLine("   liststring = liststring + \"</ul>\";");

				sbScript.AppendLine("   var list = $(liststring);");

				sbScript.AppendLine("   list.find('span').parent().addClass('active');");

				sbScript.AppendLine("");

				sbScript.AppendLine("   $(obj).replaceWith(list);");

				sbScript.AppendLine("}");
			}
			catch (Exception ex)
			{
				throw ex;
			}
			return sbScript.ToString();
		}

		//Metodo che si occupa di renderizzare le gridview in stile bootstrap
		public static void SetUpGridView(GridView gridView, Page page)
		{
			//Render per Bootstrap
			//Crea la Table con Theader e Tbody se l'header non è nothing.
			try
			{
				if (gridView.HeaderRow != null)
				{
					gridView.UseAccessibleHeader = true;
					gridView.HeaderRow.TableSection = TableRowSection.TableHeader;
				}

				//Converte i tag html generati dalla GridView per la paginazione
				//e li adatta alle necessita dei CSS Bootstrap
				gridView.PagerStyle.CssClass = "pagination-gridview";
				ScriptManager.RegisterStartupScript(page, page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), true);
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}
	}
}