Imports DI.Sac.User
Imports System.Web.UI.WebControls
Imports System
Imports System.Diagnostics
Imports DI.Sac.User.Data
Imports System.Reflection
Imports System.Web.UI
Imports System.Web

Public Class PazienteCreaPosCollegata
    Inherits System.Web.UI.Page

    Private Shared ReadOnly _className As String = MethodBase.GetCurrentMethod().ReflectedType.Name

    Private mbPazienteDettaglioObjectDataSource_CancelSelect As Boolean = False
    Private mIdPaziente As Guid = Nothing
    Private mbCanCreatePosCollegata As Boolean = False


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            '
            ' Prelevo l'Id del paziente
            '
            Dim sIdPaziente As String = Request("Id")
            If String.IsNullOrEmpty(sIdPaziente) Then
                Throw New ApplicationException("Il parametro Id è obbligatorio.")
            End If
            '
            ' Memorizzo l'id paziente originale di cui bisogna creare la "posizione collegata" (lo faccio sempre)
            '
            mIdPaziente = New Guid(sIdPaziente)

            If Not IsPostBack Then
                'Carico lo UserControl del dettaglio paziente.
                DettaglioPaziente.IdPaziente = mIdPaziente
                DettaglioPaziente.DataBind()

                '-----------------------------------------------------------------
                ' MODIFICA ETTORE 2016-02-10: Anonimizzazioni
                '-----------------------------------------------------------------
                '
                ' Verifico se l'ha i diritti di anonimizzazione
                '
                mbCanCreatePosCollegata = Utility.IsUserPosizioniCollegate()
                '
                ' Modifico url per il menu orizzontale
                '
                'If Not SiteMap.CurrentNode Is Nothing Then
                '    Call Utility.SetSiteMapNodeQueryString(SiteMap.CurrentNode.ParentNode, String.Format("id={0}", sIdPaziente))
                'End If
                '
                ' Memorizzo url di ritorno
                ' ATTENZIONE: Request.UrlReferrer cambia se ci sono dei postback e diventa uguale alla pagina corrente (per questo il default...)
                '
                Call SetUrlBack(Request.UrlReferrer, "~/Pazienti/PazientiLista.aspx")
                '
                ' Verifico i diritti utente
                '
                If Not mbCanCreatePosCollegata Then
                    MainTable.Visible = False
                    divErrorMessage.Visible = True
                    LabelError.Text = "<br/>L'utente non ha i diritti per accedere alla pagina."
                    Exit Sub
                End If
            End If

        Catch ex As Exception
            'Scrivo solo nell'event log
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                divErrorMessage.Visible = True
                LabelError.Text = sErrorMessage
            End If
            ' In caso di errore NON FA eseguire la select all'object data source
            mbPazienteDettaglioObjectDataSource_CancelSelect = True
        End Try

    End Sub

    ''' <summary>
    ''' Naviga alla pagina chiamante
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub btnAnnulla_Click(sender As Object, e As EventArgs) Handles btnAnnulla.Click
        Try
            Call GoBack()
        Catch ex As Exception
            'Scrivo solo nell'event log
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                divErrorMessage.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub

    ''' <summary>
    ''' Esegue il codice per creare l'anonimizzazione
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub btnConferma_Click(sender As Object, e As EventArgs) Handles btnConferma.Click
        Dim sUrlToNavigate As String = String.Empty
        Try
            '-------------------------------------------------------------------------
            ' Leggo i valori della posizione collegata modificabili dall'utente
            '-------------------------------------------------------------------------
            '
            ' Leggo il codice del comune di nascita
            '
            Dim oCustomDropDownListPosCollegata As ProgelDropDownList = CType(PazienteDettaglioFormView.FindControl("pddlComuneNascitaPosCollegata"), ProgelDropDownList)
            Dim sCodiceComuneNascitaPosCollegata As String = oCustomDropDownListPosCollegata.ChildBindValue
            '
            ' Leggo txtDataNascitaPosCollegata
            '
            Dim otxtDataNascitaPosCollegata As TextBox = CType(PazienteDettaglioFormView.FindControl("txtDataNascitaPosCollegata"), TextBox)
            Dim oDataNascitaPosCollegata As DateTime
            If Not DateTime.TryParse(otxtDataNascitaPosCollegata.Text, oDataNascitaPosCollegata) Then
                Throw New ApplicationException("La data di nascita non è una data di nascita valida!")
            End If
            '
            ' Leggo il sesso ddlSessoPosCollegata
            '
            Dim oddlSessoPosCollegata As DropDownList = CType(PazienteDettaglioFormView.FindControl("ddlSessoPosCollegata"), DropDownList)
            Dim sSessoPosCollegata As String = oddlSessoPosCollegata.SelectedValue

            Dim oTextNote As TextBox = CType(PazienteDettaglioFormView.FindControl("txtNote"), TextBox)
            Dim sNote As String = oTextNote.Text
            If String.IsNullOrEmpty(sNote) Then sNote = Nothing

            '
            ' Eseguo SP di inserimento del "paziente collegato" e del record associato nella tabella "PazientiPosizioniCollegate"
            ' La SP restituisce il record inserito nella tabella "PazientiPosizioniCollegate", da cui posso ricavare l'IdPaziente della "posizione collegata"
            '
            Dim odt As PazientiPosizioniCollegateDataSet.PazientiPosizioniCollegateInserisciDataTable
            Using ota As New PazientiPosizioniCollegateDataSetTableAdapters.PazientiPosizioniCollegateInserisciTableAdapter
                '
                ' Creo la nuova riga: i primi due parametri li passo con valori dummy poichè vengono calcolati dalla stored procedure di inserimento
                '
                odt = ota.GetData(mIdPaziente, HttpContext.Current.User.Identity.Name, sNote, sSessoPosCollegata, oDataNascitaPosCollegata, sCodiceComuneNascitaPosCollegata)
            End Using
            '
            ' A questo punto navigo al dettaglio della "posizione collegata"
            '
            If Not odt Is Nothing AndAlso odt.Rows.Count > 0 Then
                sUrlToNavigate = String.Format("~/Pazienti/PazienteDettaglioPosCollegata.aspx?Id={0}&IdSacPosizioneCollegata={1}", mIdPaziente, odt(0).IdSacPosizioneCollegata)
                '
                ' Attenzione: non torno alla pagina chiamante ma navigo alla pagina che visualizza il risultato dell'azione di creazione della "posizione collegata"
                ' Se è avvenuto un errore nel codice precedente, sUrlToNavigate non è stata valorizzata, il redirect non viene eseguito
                '
                Response.Redirect(sUrlToNavigate, False)
            Else
                'Non dovrebbe mai verificarsi
                Throw New ApplicationException("Non è stato possibile creare la 'posizione collegata'. Contattare l'amministratore.")
            End If


        Catch ex As Exception
            'Scrivo solo nell'event log
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                divErrorMessage.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub


#Region "BackUrl"

    ''' <summary>
    ''' Per memorizzare l'url di ritorno
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Property UrlBack() As String
        Get
            Return CType(ViewState("UrlBack"), String)
        End Get
        Set(ByVal Value As String)
            ViewState("UrlBack") = Value
        End Set
    End Property

    ''' <summary>
    ''' Da chiamare solo la prima volta all'inizio del codice
    ''' </summary>
    ''' <param name="sDefaultUrl"></param>
    ''' <remarks></remarks>
    Private Sub SetUrlBack(oUri As System.Uri, sDefaultUrl As String)
        Dim oUrl As Object = oUri
        If Not oUrl Is Nothing Then
            UrlBack = oUri.ToString()
        Else
            UrlBack = sDefaultUrl
        End If
    End Sub
    ''' <summary>
    ''' Da chiamare solo la prima volta all'inizio del codice
    ''' </summary>
    ''' <param name="sDefaultUrl"></param>
    ''' <remarks></remarks>
    Private Sub SetUrlBack(sUrl As String, sDefaultUrl As String)
        If Not String.IsNullOrEmpty(sUrl) Then
            UrlBack = sUrl
        Else
            UrlBack = sDefaultUrl
        End If
    End Sub

    Private Sub GoBack()
        Dim sUrlBack As String = UrlBack
        Response.Redirect(sUrlBack, False)
    End Sub

#End Region

#Region "PazienteDettaglioObjectDataSource"
    Dim mdtPazienteCorrente As PazientiPosizioniCollegateDataSet.PazientiPosizioniCollegatePazienteSelectDataTable
    Private Sub PazienteDettaglioObjectDataSource_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles PazienteDettaglioObjectDataSource.Selected
        Try
            If e.Exception IsNot Nothing Then
                Dim ex As Exception = e.Exception.InnerException
                If ex Is Nothing Then ex = e.Exception
                'Scrivo solo nell'event log
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    divErrorMessage.Visible = True
                    LabelError.Text = sErrorMessage
                End If
                e.ExceptionHandled = True
            Else
                mdtPazienteCorrente = CType(e.ReturnValue, PazientiPosizioniCollegateDataSet.PazientiPosizioniCollegatePazienteSelectDataTable)
            End If
        Catch ex As Exception
            'Scrivo solo nell'event log
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                divErrorMessage.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub

    Private Sub PazienteDettaglioObjectDataSource_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles PazienteDettaglioObjectDataSource.Selecting
        Try
            e.Cancel = mbPazienteDettaglioObjectDataSource_CancelSelect
        Catch ex As Exception
            'Scrivo solo nell'event log
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                divErrorMessage.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub

#End Region

    Protected Sub ddlSessoPosCollegata_DataBinding(sender As Object, e As EventArgs)
        '
        ' Aggiungo alla dropdown Sesso un eventuale codice non presente in lista 
        '
        Try
            Dim paziente As PazientiPosizioniCollegateDataSet.PazientiPosizioniCollegatePazienteSelectRow = mdtPazienteCorrente(0)
            Dim ddlSesso As DropDownList = sender
            If ddlSesso.Items.FindByValue(paziente.Sesso) Is Nothing Then
                ddlSesso.Items.Add(New ListItem(paziente.Sesso, paziente.Sesso))
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub
End Class