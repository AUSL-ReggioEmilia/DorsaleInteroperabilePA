using System;
using System.Web;
using System.Web.UI.WebControls;

namespace OrderEntryPlanner.Pages
{
    public partial class Calendario : System.Web.UI.Page
    {
        protected void ddlSistema_PreRender(object sender, EventArgs e)
        {
            try
            {
                ddlSistema.Items.Insert(0, new ListItem("Selezionare un sistema", ""));
            }
            catch (Exception ex)
            {
                Components.Utility.LogError(ex);
                Master.showAlert("Si è verificato un errore. Contattare un amministratore di sistema.");
            }
        }
    }
}
