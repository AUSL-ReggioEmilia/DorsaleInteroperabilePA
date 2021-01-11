Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin

Public Class IstatProvinceLista
    Inherits System.Web.UI.Page

    Private mbodsIstatProvince_CancelSelect As Boolean = False
    Private Const FILTERKEY As String = "IstatProvince"

    Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
        Try
            If Not Page.IsPostBack Then
                FilterHelper.Restore(pannelloFiltri, FILTERKEY)
                ImpostaFiltriDataSource()
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub

    Protected Sub RicercaButton_Click(sender As Object, e As EventArgs) Handles butFiltriRicerca.Click

        Try
            LabelError.Visible = False

            If ValidazioneFiltri() Then

                ImpostaFiltriDataSource()
                FilterHelper.SaveInSession(pannelloFiltri, FILTERKEY)
                Cache("CacheIstatProvince") = New Object
                'tento il rebind
                gvIstatProvince.DataBind()
                gvIstatProvince.PageIndex = 0

            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try

    End Sub

    Private Sub odsIstatProvince_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsIstatProvince.Selecting
        Try
            'eseguo la ricerca solo se i filtri sono a posto
            e.Cancel = mbodsIstatProvince_CancelSelect
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub

    Private Sub odsIstatProvince_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsIstatProvince.Selected
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
            mbodsIstatProvince_CancelSelect = True
        End Try
    End Sub


    Private Sub ImpostaFiltriDataSource()

        odsIstatProvince.SelectParameters("Codice").DefaultValue = If(txtFiltriCodice.Text.Length > 0, txtFiltriCodice.Text, Nothing)
        odsIstatProvince.SelectParameters("Nome").DefaultValue = If(txtFiltriNome.Text.Length > 0, txtFiltriNome.Text, Nothing)
        odsIstatProvince.SelectParameters("CodiceRegione").DefaultValue = ddlFiltriRegione.SelectedValue
        
    End Sub

    Protected Function ValidazioneFiltri() As Boolean
       
        Return True

    End Function

End Class