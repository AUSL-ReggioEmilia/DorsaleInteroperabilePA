Imports System
Imports System.Diagnostics
Imports System.Collections
Imports System.Web.UI.WebControls
Imports System.Reflection
Imports System.Web.UI

Namespace DI.Sac.Admin

    Partial Public Class EsenzioneDettaglio
        Inherits Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
         
            Dim qsIdPaziente As String = Request.Params("idPaziente")

            If Not Page.IsPostBack Then
               
                lnkIndietro.NavigateUrl = String.Format(lnkIndietro.NavigateUrl, qsIdPaziente)
            End If
        End Sub

        Protected Sub EsenzioneDettaglioObjectDataSource_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles EsenzioneDettaglioObjectDataSource.Selected

            If  e.Exception IsNot Nothing Then

                ExceptionsManager.TraceException(e.Exception)

                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
                e.ExceptionHandled = True
            End If
        End Sub

        Private Sub HyperLinkStyle(ByRef sender As System.Web.UI.WebControls.HyperLink, ByVal enabled As Boolean)

            If enabled Then
                sender.Enabled = True
                sender.Text = sender.Text.Replace("_grey.gif", ".gif")
            Else
                sender.Enabled = False
                sender.Text = sender.Text.Replace(".gif", "_grey.gif")
            End If
        End Sub

        Private Sub HyperLinkStyle(ByRef sender As System.Web.UI.WebControls.LinkButton, ByVal enabled As Boolean)

            If enabled Then
                sender.Enabled = True
                sender.Text = sender.Text.Replace("_grey.gif", ".gif")
            Else
                sender.Enabled = False
                sender.Text = sender.Text.Replace(".gif", "_grey.gif")
                sender.OnClientClick = String.Empty
            End If
        End Sub

    End Class

End Namespace