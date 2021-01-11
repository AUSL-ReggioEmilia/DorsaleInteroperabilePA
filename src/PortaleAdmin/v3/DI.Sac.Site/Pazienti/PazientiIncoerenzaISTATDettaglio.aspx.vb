Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin

Public Class PazientiIncoerenzaISTATDettaglio
    Inherits System.Web.UI.Page

    Private Const BACKPAGE As String = "~/Pazienti/PazientiIncoerenzaISTATLista.aspx"
    Private mbodsDettaglioIncoerenzaIstat_CancelSelect As Boolean = False

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            If Not Page.IsPostBack Then
                'niente da fare
            End If
        Catch ex As Exception

            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If

            mbodsDettaglioIncoerenzaIstat_CancelSelect = True
            FormViewDettaglio.Visible = False
        End Try
    End Sub

    Protected Sub FormViewDettaglio_ItemDeleted(sender As Object, e As FormViewDeletedEventArgs) Handles FormViewDettaglio.ItemDeleted

        Try
            Cache("CacheIncoerenzeIstat") = New Object
            Response.Redirect(BACKPAGE)
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try

    End Sub

    Private Sub odsDettaglioIncoerenzaIstat_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsDettaglioIncoerenzaIstat.Selecting

        Try
            e.Cancel = mbodsDettaglioIncoerenzaIstat_CancelSelect
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try

    End Sub

    Private Sub odsDettaglioIncoerenzaIstat_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDettaglioIncoerenzaIstat.Selected
        Try
            If e.Exception IsNot Nothing Then
                ExceptionsManager.TraceException(e.Exception)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
                e.ExceptionHandled = True
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
            mbodsDettaglioIncoerenzaIstat_CancelSelect = True
        End Try
    End Sub

    Protected Sub FormViewDettaglio_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles FormViewDettaglio.ItemCommand
        If e.CommandName.ToUpper = "CANCEL" Then
            Response.Redirect(BACKPAGE)
        End If
    End Sub
End Class