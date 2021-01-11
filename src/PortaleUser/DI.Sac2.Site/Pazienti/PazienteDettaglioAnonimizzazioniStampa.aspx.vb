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
' Questa pagina esegue lo stesso codice della pagina PazientiDettaglioAnonimizzazioni.aspx, ma formatta la 
' visualizzazione in maniera diversa per la stampa
'
'***************************************************************************************************************

Public Class PazienteDettaglioAnonimizzazioniStampa
    Inherits System.Web.UI.Page

    Private Shared ReadOnly _className As String = MethodBase.GetCurrentMethod().ReflectedType.Name

    Private mbDettaglioPazienteObjectDataSource_CancelSelect As Boolean = False
    Private mbDettaglioAnonimizzazioneObjectDataSource_CancelSelect As Boolean = False
    Private mbEsenzioniObjectDataSource_CancelaSelect As Boolean = False
    Private mIdPaziente As Guid = Nothing
    Private mIdPazienteAnonimo As Guid = Nothing
    Private mbCanCreateAnonimizzazione As Boolean = False

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
            ' Memorizzo l'id paziente da anonimizzare (lo faccio sempre)
            '
            mIdPaziente = New Guid(sIdPaziente)
            '
            ' MODIFICA ETTORE 2016-02-11: utilizzo il GUID IdPazienteAnonimo invece del codice di anonimizzazione (del tipo=AN16A001)
            '
            Dim sIdPazienteAnonimo As String = Request("IdPazienteAnonimo")
            If String.IsNullOrEmpty(sIdPazienteAnonimo) Then
                Throw New ApplicationException("Il parametro IdPazienteAnonimo è obbligatorio.")
            End If
            mIdPazienteAnonimo = New Guid(sIdPazienteAnonimo)


            If Not IsPostBack Then
                '
                ' Verifico i diritti utente
                '
                ' Verifico se l'ha i diritti di anonimizzazione
                mbCanCreateAnonimizzazione = Utility.IsUserAnonimizzatore()
                If Not (mbCanCreateAnonimizzazione) Then
                    MainDiv.Visible = False
                    LabelError.Visible = True
                    LabelError.Text = "L'utente non ha i diritti per accedere alla pagina."
                    Exit Sub
                End If
                '
                ' MODIFICA ETTORE 2016-02-11: valorizzo l'avviso nella parte sopra e sotto del modulo di stampa
                '
                Dim sProceduraAnonimizzazione As String = String.Format("PROCEDURA DI ANONIMIZZAZIONE - Codice generato il {0:d} dall'operatore {1}", Now.Date, GetCognomeNomeOperatore())
                lblProceduraTop.Text = sProceduraAnonimizzazione
                lblProceduraBottom.Text = sProceduraAnonimizzazione
                IdModuloStampaAvviso.InnerHtml = My.Settings.Anonimizzazioni_ModuloStampa_Avviso

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
            mbDettaglioAnonimizzazioneObjectDataSource_CancelSelect = True
            mbEsenzioniObjectDataSource_CancelaSelect = True
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
                Dim dt As PazientiAnonimizzazioniDataSet.PazientiAnonimizzazioniPazienteSelectDataTable = CType(e.ReturnValue, PazientiAnonimizzazioniDataSet.PazientiAnonimizzazioniPazienteSelectDataTable)
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

#Region " DettaglioAnonimizzazioneObjectDataSource "

    Private Sub DettaglioAnonimizzazioneObjectDataSource_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DettaglioAnonimizzazioneObjectDataSource.Selected
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
                ' Controllo la presenza del record anonimo: ci deve essere perchè appena inserito.
                '
                Dim dt As PazientiAnonimizzazioniDataSet.PazientiAnonimizzazioniSelectByIdSacAnonimoDataTable = CType(e.ReturnValue, PazientiAnonimizzazioniDataSet.PazientiAnonimizzazioniSelectByIdSacAnonimoDataTable)
                If Not ((Not dt Is Nothing) AndAlso (dt.Rows.Count > 0)) Then
                    'Record non trovato: nascondo tutto
                    MainDiv.Visible = False
                    Throw New ApplicationException("Il record anagrafico anonimo non esiste! Contattare l'amministratore")
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

    Private Sub DettaglioAnonimizzazioneObjectDataSource_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DettaglioAnonimizzazioneObjectDataSource.Selecting
        Try
            e.Cancel = mbDettaglioAnonimizzazioneObjectDataSource_CancelSelect
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



#Region "Funzioni usate nella parte ASPX"
    ''' <summary>
    ''' Restituisce il testo dell'esenzione contenuta dentro il campo TestoEsenzione.
    ''' </summary>
    ''' <param name="row"></param>
    ''' <returns></returns>
    Protected Function GetTestoEsenzione(ByVal row As Object) As String
        Dim testoEsenzione As String = String.Empty

        Try
            If row IsNot Nothing Then
                Dim esenzione As WcfSacPazienti.EsenzioneType = CType(row, WcfSacPazienti.EsenzioneType)

                If esenzione IsNot Nothing Then
                    If esenzione.TestoEsenzione IsNot Nothing Then
                        testoEsenzione = esenzione.TestoEsenzione.Descrizione
                    End If
                End If
            End If
        Catch ex As Exception
            '
            'Non faccio nulla e vado avanti
            '
        End Try

        Return testoEsenzione
    End Function

#End Region



#Region "EsenzioniObjectDataSource"

    Private Sub EsenzioniObjectDataSource_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles EsenzioniObjectDataSource.Selected
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
                ' Verifico se ho delle esenzioni da visualizzare
                '
                divEsenzioni.Visible = False
                Dim oEsenzioni As WcfSacPazienti.EsenzioniType = CType(e.ReturnValue, WcfSacPazienti.EsenzioniType)
                If Not oEsenzioni Is Nothing AndAlso oEsenzioni.Count > 0 Then
                    divEsenzioni.Visible = True
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

    Private Sub EsenzioniObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles EsenzioniObjectDataSource.Selecting
        Try
            If mbEsenzioniObjectDataSource_CancelaSelect = True Then
                e.Cancel = True
            End If
            '
            ' Voglio solo le esenzioni attive
            '
            e.InputParameters("Attive") = True

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

End Class