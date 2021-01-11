Imports DI.Sac.User
Imports System.Web.UI.WebControls
Imports System
Imports System.Diagnostics
Imports DI.Sac.User.Data
Imports System.Reflection
Imports System.Web.UI
Imports System.Web
'***************************************************************************************************************
'
' Questa pagina esegue lo stesso codice della pagina PazientiDettaglioPosCollegata.aspx, ma formatta la 
' visualizzazione in maniera diversa per la stampa
'
'***************************************************************************************************************
Public Class PazienteDettaglioPosCollegataStampa
    Inherits System.Web.UI.Page

    'Private Shared ReadOnly _className As String = MethodBase.GetCurrentMethod().ReflectedType.Name

    Private mbDettaglioPazienteObjectDataSource_CancelSelect As Boolean = False
    Private mbDettaglioPosizioneCollegataObjectDataSource_CancelSelect As Boolean = False
    Private mIdPaziente As Guid = Nothing
    Private mIdPosizioneCollegata As Guid = Nothing
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
            ' Memorizzo l'id paziente da per iol quale è stata creata la "posizione collegata" (lo faccio sempre)
            '
            mIdPaziente = New Guid(sIdPaziente)

            Dim sIdSacPosizioneCollegata As String = Request("IdSacPosizioneCollegata")
            If String.IsNullOrEmpty(sIdSacPosizioneCollegata) Then
                Throw New ApplicationException("Il parametro IdSacPosizioneCollegata è obbligatorio.")
            End If
            mIdPosizioneCollegata = New Guid(sIdSacPosizioneCollegata)


            If Not IsPostBack Then
                '
                ' Verifico i diritti utente
                '
                ' Verifico se l'ha i diritti di creare*/leggere una "posizione collegata"
                mbCanCreatePosCollegata = Utility.IsUserPosizioniCollegate()
                If Not (mbCanCreatePosCollegata) Then
                    MainDiv.Visible = False
                    LabelError.Visible = True
                    LabelError.Text = "L'utente non ha i diritti per accedere alla pagina."
                    Exit Sub
                End If
                '
                ' Valorizzo l'avviso nella parte sopra e sotto del modulo di stampa
                '
                Dim sProcedura As String = String.Format("PROCEDURA DI CREAZIONE POSIZIONE COLLEGATA - Codice generato il {0:d} dall'operatore {1}", Now.Date, GetCognomeNomeOperatore())
                lblProceduraTop.Text = sProcedura
                lblProceduraBottom.Text = sProcedura
            End If

        Catch ex As Exception
            'Scrivo solo nell'event log
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
            ' In caso di errore NON eseguiamo la select degli object data source
            mbDettaglioPazienteObjectDataSource_CancelSelect = True
            mbDettaglioPosizioneCollegataObjectDataSource_CancelSelect = True
        End Try

    End Sub


#Region " DettaglioPazienteObjectDataSource "

    Private Sub DettaglioPazienteObjectDataSource_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DettaglioPazienteObjectDataSource.Selected
        Try
            If e.Exception IsNot Nothing Then
                Dim ex As Exception = e.Exception.InnerException
                If ex Is Nothing Then ex = e.Exception
                'Scrivo solo nell'event log
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
                e.ExceptionHandled = True
            Else
                '
                ' Controllo la presenza del record anagrafico originale
                '
                Dim dt As PazientiPosizioniCollegateDataSet.PazientiPosizioniCollegatePazienteSelectDataTable = CType(e.ReturnValue, PazientiPosizioniCollegateDataSet.PazientiPosizioniCollegatePazienteSelectDataTable)
                If Not ((Not dt Is Nothing) AndAlso (dt.Rows.Count > 0)) Then
                    'Record non trovato: nascondo tutto
                    MainDiv.Visible = False
                    Throw New ApplicationException("Il record anagrafico originale non esiste! Contattare l'amministratore")
                End If
            End If
        Catch ex As Exception
            'Scrivo solo nell'event log
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub

    Private Sub DettaglioPazienteObjectDataSource_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DettaglioPazienteObjectDataSource.Selecting
        Try
            e.Cancel = mbDettaglioPazienteObjectDataSource_CancelSelect
        Catch ex As Exception
            'Scrivo solo nell'event log
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub

#End Region

#Region " DettaglioPosizioniCollegateObjectDataSource "

    Private Sub DettaglioPosizioneCollegataObjectDataSource_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DettaglioPosizioneCollegataObjectDataSource.Selected
        Try
            If e.Exception IsNot Nothing Then
                Dim ex As Exception = e.Exception.InnerException
                If ex Is Nothing Then ex = e.Exception
                'Scrivo solo nell'event log
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
                e.ExceptionHandled = True
            Else
                '
                ' Controllo la presenza del record della "posizione collegata": ci deve essere perchè appena inserito.
                '
                Dim dt As PazientiPosizioniCollegateDataSet.PazientiPosizioniCollegateSelectByIdSacPosizioneCollegataDataTable = CType(e.ReturnValue, PazientiPosizioniCollegateDataSet.PazientiPosizioniCollegateSelectByIdSacPosizioneCollegataDataTable)
                If Not ((Not dt Is Nothing) AndAlso (dt.Rows.Count > 0)) Then
                    'Record non trovato: nascondo tutto
                    MainDiv.Visible = False
                    Throw New ApplicationException("Il record anagrafico collegato non esiste! Contattare l'amministratore")
                End If
            End If
        Catch ex As Exception
            'Scrivo solo nell'event log
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub

    Private Sub DettaglioPosizioneCollegataObjectDataSource_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DettaglioPosizioneCollegataObjectDataSource.Selecting
        Try
            e.Cancel = mbDettaglioPosizioneCollegataObjectDataSource_CancelSelect
        Catch ex As Exception
            'Scrivo solo nell'event log
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub

#End Region

    ''' <summary>
    ''' Preleva il nome e cognome dell'operatore
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks>Se non trova nome e cognome restituisce l'account</remarks>
    Private Function GetCognomeNomeOperatore()
        Dim sRet As String = String.Empty
        '
        ' Prelevo il nome e il cognome dell'utente operatore
        ' 
        Dim oUltimoAccesso As DI.PortalUser2.SessioneUtente.UltimoAccesso = CType(Session(Utility.SESS_DATI_ULTIMO_ACCESSO), DI.PortalUser2.SessioneUtente.UltimoAccesso)
        If (Not oUltimoAccesso Is Nothing) AndAlso (Not oUltimoAccesso.Utente Is Nothing) Then
            Dim sCognome As String = oUltimoAccesso.Utente.Cognome
            Dim sNome As String = oUltimoAccesso.Utente.Nome
            If (Not String.IsNullOrEmpty(sCognome)) AndAlso (Not String.IsNullOrEmpty(sNome)) Then
                sRet = String.Concat(sCognome, " ", sNome)
            End If
        End If
        '
        ' Se non ho trovato Cognome e Nome imposto l'account
        '
        If String.IsNullOrEmpty(sRet) Then
            sRet = HttpContext.Current.User.Identity.Name
        End If
        '
        ' Restituisco
        '
        Return sRet.ToUpper
    End Function

End Class