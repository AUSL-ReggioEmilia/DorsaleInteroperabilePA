Imports System
Imports System.Data
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin

Public Class IstatComuniLista
    Inherits System.Web.UI.Page

    Private mbodsIstatComuni_CancelSelect As Boolean = False
    Private Const FILTERKEY As String = "IstatComuni"
    Private Const lblText As String = "Sono stati mostrati solo i primi 1000 record perchè la ricerca ha prodotto più di 1000 risultati."


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
                Cache("CacheIstatComuni") = New Object
                'tento il rebind
                gvIstatComuni.DataBind()
                gvIstatComuni.PageIndex = 0

            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try

    End Sub

    Private Sub odsIstatComuni_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsIstatComuni.Selecting
        Try
            'eseguo la ricerca solo se i filtri sono a posto
            e.Cancel = mbodsIstatComuni_CancelSelect
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub

    Private Sub odsIstatComuni_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsIstatComuni.Selected
        Try
            If e.Exception Is Nothing Then
                Dim gvTop As Integer = CInt(odsIstatComuni.SelectParameters.Item("Top").DefaultValue)
                Dim eG = CType(e.ReturnValue, DataTable)
                If eG.Rows.Count = gvTop Then
                    lblGvLista.Visible = True
                    lblGvLista.Text = lblText
                Else
                    lblGvLista.Visible = False
                End If
            Else
                ExceptionsManager.TraceException(e.Exception)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
                e.ExceptionHandled = True
                lblGvLista.Visible = False
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
            mbodsIstatComuni_CancelSelect = True
            lblGvLista.Visible = False
        End Try
    End Sub


    Private Sub ImpostaFiltriDataSource()

        odsIstatComuni.SelectParameters("Codice").DefaultValue = If(txtFiltriCodice.Text.Length > 0, txtFiltriCodice.Text, Nothing)
        odsIstatComuni.SelectParameters("Nome").DefaultValue = If(txtFiltriNome.Text.Length > 0, txtFiltriNome.Text, Nothing)
        odsIstatComuni.SelectParameters("Tipo").DefaultValue = ddlFiltriTipo.SelectedValue
        odsIstatComuni.SelectParameters("Provenienza").DefaultValue = If(ddlFiltriProvenienza.SelectedIndex > 0, ddlFiltriProvenienza.SelectedValue, Nothing)
        odsIstatComuni.SelectParameters("IdProvenienza").DefaultValue = If(txtFiltriIDProvenienza.Text.Length > 0, txtFiltriIDProvenienza.Text, Nothing)
        odsIstatComuni.SelectParameters("Stato").DefaultValue = ddlFiltriStato.SelectedValue

    End Sub

    Protected Function ValidazioneFiltri() As Boolean
        Dim bValidazione As Boolean = True
        'Dim sMess As String = ""

        'If txtFiltriCodice.Text.Length > 0 Then
        '    txtFiltriCodice.Text = txtFiltriCodice.Text.PadLeft(6, "0"c)
        'End If

        'LabelError.Visible = sMess.Length > 0
        'LabelError.Text = sMess
        'mbodsIstatComuni_CancelSelect = Not bValidazione
        Return bValidazione

    End Function




End Class