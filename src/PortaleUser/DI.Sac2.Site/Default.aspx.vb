Namespace DI.Sac.User

    Partial Public Class _Default
        Inherits System.Web.UI.Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
            Response.Redirect("~/Pazienti/PazientiLista.aspx", False)
        End Sub

    End Class

End Namespace