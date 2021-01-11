Imports System.Web.UI.WebControls
Imports System
Imports System.Web.UI
Imports System.Web
Imports DI.Sac.Admin

Public Class UtenteEsenzioneDettaglio
    Inherits System.Web.UI.Page

    Public Property Utente() As String
        Get
            Return Me.ViewState("Utente")
        End Get
        Set(ByVal value As String)
            Me.ViewState("Utente") = value
        End Set
    End Property

    Private sBACKPAGE As String

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
        Try
            If Request.QueryString("Utente") Is Nothing Then
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.ElaborazionePagina)
            Else
                Me.Utente = Request.QueryString("Utente").ToString
                sBACKPAGE = "UtenteDettaglio.aspx?utente=" & Me.Utente
            End If

            If Not Page.IsPostBack Then
                If String.IsNullOrEmpty(Request.QueryString("Id")) Then
                    MainFormView.DefaultMode = FormViewMode.Insert
                Else
                    MainFormView.DefaultMode = FormViewMode.Edit
                End If
                '
                ' Modifico url del nodo padre nel menu orizzontale
                '
                If Not SiteMap.CurrentNode Is Nothing Then
                    Call Utility.SetSiteMapNodeQueryString(SiteMap.CurrentNode.ParentNode, String.Format("utente={0}", Request.QueryString("Utente").ToString))
                End If

            Else
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.ElaborazionePagina)
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
        Try
            If MainFormView.CurrentMode = FormViewMode.Insert Then
                Dim lblUtente As Label = MainFormView.FindControl("lblUtente")
                lblUtente.Text = Me.Utente
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Protected Sub PazienteDettaglioFormView_ItemCommand(ByVal sender As Object, ByVal e As FormViewCommandEventArgs) Handles MainFormView.ItemCommand
        Try
            If e.CommandName = DataControlCommands.CancelCommandName Then
                Response.Redirect(sBACKPAGE, False)
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Protected Sub MainObjectDataSource_Selected(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles MainObjectDataSource.Selected
        Try
            If e.Exception IsNot Nothing Then
                ExceptionsManager.TraceException(e.Exception)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
                e.ExceptionHandled = True
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Protected Sub MainObjectDataSource_Updated(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles MainObjectDataSource.Updated
        Try
            If e.Exception IsNot Nothing Then
                ExceptionsManager.TraceException(e.Exception)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Aggiornamento)
                e.ExceptionHandled = True
            Else
                Response.Redirect(sBACKPAGE, False)
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Protected Sub MainObjectDataSource_Inserted(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles MainObjectDataSource.Inserted
        Try
            If e.Exception IsNot Nothing Then
                ExceptionsManager.TraceException(e.Exception)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Inserimento)
                e.ExceptionHandled = True
            Else
                Response.Redirect(sBACKPAGE, False)
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub MainObjectDataSource_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles MainObjectDataSource.Inserting
        Try
            e.InputParameters("Utente") = Me.Utente
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub


End Class
