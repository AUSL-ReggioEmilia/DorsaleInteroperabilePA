Imports System
Imports System.Web.UI.WebControls

Public Class SimulazioneEnnupleDatiAccessori
    Inherits System.Web.UI.Page

    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
    Private Const PageSessionIdPrefix As String = "Simulazione_"
    Private eseguiQuery

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub

    Private Sub SimulazioneEnnuple_PreRenderComplete(sender As Object, e As EventArgs) Handles Me.PreRenderComplete

        If Not Page.IsPostBack Then
            '
            ' Ricarico i filtri prendendoli dalla sessione
            '
            FilterHelper.Restore(filterPanel, msPAGEKEY)

            '
            ' Se le textbox dei filtri Utente e Data non sono popolate allora le popolo con l'User e la data corrente
            '
            If UtenteFiltroTextBox.Text.Length = 0 Then UtenteFiltroTextBox.Text = My.User.Name
            If DataFiltroTextBox.Text.Length = 0 Then DataFiltroTextBox.Text = String.Format("{0:dd/MM/yyyy HH:mm}", Date.Now)

            '
            ' Eseguo il DataBind della griglie e delle ennuple interessate
            '
            EnnupleInteressateRepeater.DataBind()
            SimulazioneEnnupleGridView.DataBind()
        End If

        'EnnupleInteressate.Visible = Page.IsPostBack
    End Sub

    Protected Sub CercaButton_Click(sender As Object, e As EventArgs) Handles CercaButton.Click

        '
        ' Salvo in sessione i filtri e eseguo il DataBind della griglia e del repeater delle ennuple interessate
        '
        FilterHelper.SaveInSession(filterPanel, msPAGEKEY)
        EnnupleInteressateRepeater.DataBind()
        SimulazioneEnnupleGridView.DataBind()

    End Sub

    Protected Sub SimulazioneEnnupleObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles SimulazioneEnnupleObjectDataSource.Selecting

        '
        ' Il campo nomeUtente è obbligatorio
        '
        If e.InputParameters("nomeUtente") Is Nothing Then
            e.Cancel = True
            Exit Sub
        End If

        If e.InputParameters("giorno") Is Nothing Then
            e.InputParameters("giorno") = DateTime.Now
        End If

        If String.IsNullOrEmpty(e.InputParameters("filtroCodiceDescrizione")) Then
            e.InputParameters("filtroCodiceDescrizione") = Nothing
        End If

    End Sub

    Private Sub EnnupleInteressateObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles EnnupleInteressateObjectDataSource.Selecting

        '
        ' Il campo nomeUtente è obbligatorio
        '
        If e.InputParameters("nomeUtente") Is Nothing Then
            e.Cancel = True
            Exit Sub
        End If
    End Sub

End Class