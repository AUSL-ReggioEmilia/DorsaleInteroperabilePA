Imports System
Imports System.Web.UI
Imports System.Configuration

Namespace DI.DataWarehouse.Admin

    Public Class RefertiListaAdmin
        Inherits Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            Dim urlContent As String = Me.ResolveUrl("~/" & My.Settings.ReportRefertiAdmin)

            Me.IframeMain.Attributes.Add("src", urlContent)
        End Sub

    End Class

End Namespace