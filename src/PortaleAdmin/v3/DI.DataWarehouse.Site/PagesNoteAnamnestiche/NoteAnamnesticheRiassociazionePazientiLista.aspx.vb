Imports System
Imports System.Drawing
Imports System.Web
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin
Imports DI.PortalAdmin.Data

Public Class NoteAnamnesticheRiassociazionePazientiLista
    Inherits System.Web.UI.Page

#Region "Property"
    ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

    Dim objectDataSourceCancelSelect As Boolean = True

    ''' <summary>
    ''' Salva nel view state l'id della nota anamnestica.
    ''' </summary>
    ''' <returns></returns>
    Public Property IdNotaAnamnestica() As Guid
        Get
            Return Me.ViewState("IdNotaAnamnestica")
        End Get
        Set(ByVal value As Guid)
            Me.ViewState.Add("IdNotaAnamnestica", value)
        End Set
    End Property
#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            '
            'Ottengo l'id della nota anamnestica dal query string.
            '
            Dim sIdNotaAnamnestica As String = Request.QueryString(Constants.PAR_ID_NOTA_ANAMNESTICA)

            '
            'Verifico che l'id della nota anamnestica sia valorizzato e che sia un guid valido.
            '
            If String.IsNullOrEmpty(sIdNotaAnamnestica) OrElse Not Utility.SQLTypes.IsValidGuid(sIdNotaAnamnestica) Then
                lblError.Visible = True
                lblError.Text = "Il parametro 'Id Nota Anamnestica' non è un guid valido."
            Else
                '
                'Salvo nel view state l'id della nota anamnestica.
                '
                Me.IdNotaAnamnestica = New Guid(sIdNotaAnamnestica)
            End If

            If Not Page.IsPostBack Then
                '
                'Modifico url per il menu orizzontale in modo da permettere al sitemap di tornare alla pagina corretta.
                '
                If Not SiteMap.CurrentNode Is Nothing Then
                    Utility.SetSiteMapNodeQueryString(SiteMap.CurrentNode.ParentNode, String.Format("{0}={1}", Constants.PAR_ID_NOTA_ANAMNESTICA, Me.IdNotaAnamnestica.ToString))
                End If
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
        Try
            If Not Page.IsPostBack Then
                FilterHelper.Restore(pannelloFiltri, msPAGEKEY)
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(lblError, sErrorMessage)
        End Try
    End Sub

    ''' <summary>
    ''' Valida i filtri.
    ''' </summary>
    ''' <returns></returns>
    Protected Function ValidaFIltri() As Boolean
        Dim bRet As Boolean = True

        '
        'Se l'id del paziente è valorizzato allora verifico che sia un guid valido.
        '
        If Not String.IsNullOrEmpty(txtIdPaziente.Text) AndAlso Not Utility.SQLTypes.IsValidGuid(txtIdPaziente.Text) Then
            Utility.ShowErrorLabel(lblError, "il Campo 'Id Paziente SAC' contiene un codice non valido.")
            Return False
        End If

        '
        'Controllo gli altri valori di filtro.
        '
        If String.IsNullOrEmpty(txtCognome.Text) AndAlso String.IsNullOrEmpty(txtCodiceFiscale.Text) AndAlso String.IsNullOrEmpty(txtIdPaziente.Text) AndAlso String.IsNullOrEmpty(txtAnnoNascita.Text) _
            AndAlso String.IsNullOrEmpty(txtProvenienza.Text) AndAlso String.IsNullOrEmpty(txtIdProvenienza.Text) Then
            Utility.ShowErrorLabel(lblError, "Valorizzare almeno uno dei seguenti filtri: Cognome, Codice fiscale, Anno di nascita, Id Paziente SAC, Provenienza e IdProvenienza")
            Return False
        End If

        Return bRet
    End Function

#Region "ObjectDataSource"
    Private Sub PazientiListaObjectDataSource_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles PazientiListaObjectDataSource.Selected
        GestioneErrori.ObjectDataSource_TrapError(e, lblError)
    End Sub

    Private Sub PazientiListaObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles PazientiListaObjectDataSource.Selecting
        Try
            If objectDataSourceCancelSelect Then
                e.Cancel = True
                Exit Sub
            End If

            e.InputParameters("IdPaziente") = Utility.StringEmptyDBNullToNothing(txtIdPaziente.Text)
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(lblError, sErrorMessage)
        End Try
    End Sub
#End Region

#Region "Eventi_Bottoni"
    Private Sub btnRicerca_Click(sender As Object, e As EventArgs) Handles btnRicerca.Click
        Try
            If ValidaFIltri() Then
                '
                'Salvo in sessione i valori dei filtri.
                '
                FilterHelper.SaveInSession(pannelloFiltri, msPAGEKEY)

                '
                'Valido la cache.
                '
                objectDataSourceCancelSelect = False

                '
                'Eseguo il bind dei dati.
                '
                gvPazienti.DataBind()

                '
                '2020-07-03 Kyrylo: Traccia Operazioni
                '
                Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Ricerca paziente", pannelloFiltri, Nothing)
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(lblError, sErrorMessage)
        End Try
    End Sub

    Private Sub btnAnnulla_Click(sender As Object, e As EventArgs) Handles btnAnnulla.Click
        Try
            '
            'Torno indietro.
            '
            Response.Redirect(String.Format("~/PagesNoteAnamnestiche/NoteAnamnesticheRiassociazioneDettaglio.aspx?{0}={1}", Constants.PAR_ID_NOTA_ANAMNESTICA, Me.IdNotaAnamnestica.ToString))
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(lblError, sErrorMessage)
        End Try
    End Sub
#End Region

#Region "Eventi_gvPazienti"
    Private Sub gvPazienti_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvPazienti.RowCommand
        If e.CommandName.ToUpper = "SELEZIONAPAZIENTE" Then
            '
            'Ottengo l'id del paziente selezionato.
            '
            Dim sIDPazienteScelto As String = e.CommandArgument

            '
            'Eseguo un redirect alla pagina di dettaglio passando anche l'id del paziente.
            '
            Response.Redirect(String.Format("~/PagesNoteAnamnestiche/NoteAnamnesticheRiassociazioneDettaglio.aspx?{0}={1}&{2}={3}", Constants.PAR_ID_NOTA_ANAMNESTICA, Me.IdNotaAnamnestica.ToString, Constants.IdPaziente, sIDPazienteScelto))
        End If
    End Sub

    Protected Sub gvPazienti_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvPazienti.RowDataBound
        '
        'Cambio il colore della row in base allo stato del paziente (cancellato, fuso o attivo)
        '
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim stato = DirectCast(e.Row.DataItem("Disattivato"), Byte)
            Select Case stato
                Case 0 'Attivo
                    e.Row.BackColor = Color.FromArgb(192, 240, 192) '#C0F0C0
                Case 1 'Fuso
                    e.Row.BackColor = Color.FromArgb(252, 192, 192) '#FCC2C2
                Case Else 'Cancellato
                    e.Row.BackColor = Color.FromArgb(204, 225, 232) '#CCE1E8
            End Select
        End If
    End Sub
#End Region

End Class