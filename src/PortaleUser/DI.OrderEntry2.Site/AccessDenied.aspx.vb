Imports System
Imports System.Web.UI

Namespace DI.DataWarehouse.Admin

    Public Class AccessDenied
        Inherits Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            If Request("message") IsNot Nothing Then

                Me.MessageLabel.Text = Request("message")
            End If
        End Sub

    End Class

End Namespace