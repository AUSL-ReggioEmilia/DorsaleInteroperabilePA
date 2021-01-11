Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls

Namespace DI.Sac.Admin

    Public Class PazientiFusi
        Inherits Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load


        End Sub

        Protected Sub PazientiFusiGridView_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles PazientiFusiGridView.RowDataBound

            If e.Row.RowIndex = 0 Then
                e.Row.Style.Add(HtmlTextWriterStyle.Display, "none")
                e.Row.ID = "originalRow"
            Else
                e.Row.ID = "childRow" & e.Row.RowIndex
                e.Row.CssClass = "childRow"
            End If
        End Sub
    End Class

End Namespace