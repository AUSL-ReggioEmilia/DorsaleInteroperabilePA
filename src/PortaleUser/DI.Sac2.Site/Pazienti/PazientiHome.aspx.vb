Namespace DI.Sac.User

    Partial Public Class PazientiHome
        Inherits System.Web.UI.Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
            Response.Redirect("PazientiLista.aspx", False)
        End Sub

    End Class

End Namespace