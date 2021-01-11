Imports System
Imports System.Web.UI
Imports system.Web.UI.WebControls

Namespace DI.OrderEntry.Admin

    Partial Public Class OrderEntry
        Inherits MasterPage

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            Dim master As Site = Page.Master.Master

            master.ChangeLeftMenuVisibility(True)

			'  Dim image = DirectCast(master.FindControl("ImageLogoToolbar"), Image)
			'  image.ImageUrl = "~/Images/LogoToolbarOrderEntry.jpg"
        End Sub

    End Class

End Namespace