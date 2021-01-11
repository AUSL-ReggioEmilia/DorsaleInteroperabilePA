Imports DI.Sac.Admin
Imports System.Web.UI.WebControls
Imports System
Imports System.Diagnostics
Imports DI.Sac.Admin.Data
Imports System.Reflection
Imports System.Web.UI
Imports System.Web
Imports System.ComponentModel
Imports System.Collections.Generic
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
    Private mbEsenzioniObjectDataSource_CancelSelect As Boolean = False
    Private mIdPaziente As Guid = Nothing
    Private mIdPazienteAnonimo As Guid = Nothing
    Private ReadOnly mbCanCreateAnonimizzazione As Boolean = User.IsInRole(TypeRoles.ROLE_PAZIENTI_CREATE_ANONIMIZZAZIONE.ToString())
    Private ReadOnly mbCanReadAnonimizzazione As Boolean = User.IsInRole(TypeRoles.ROLE_PAZIENTI_READ_ANONIMIZZAZIONE.ToString())

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
                ' Verifico i diritti utente: testo solo il diritto di creazione poichè a quatsa pagina si arriva solo dopo avere creato una anonimizzazione
                '
                If Not (mbCanCreateAnonimizzazione Or mbCanReadAnonimizzazione) Then
                    MainDiv.Visible = False
                    LabelError.Visible = True
                    LabelError.Text = "L'utente non ha i diritti per accedere alla pagina."
                    Exit Sub
                End If

                '
                ' MODIFICA ETTORE 2016-02-11: valorizzo l'avviso nella parte sopra e sotto del modulo di stampa
                '
                Dim sProceduraAnonimizzazione As String = String.Format("PROCEDURA DI ANONIMIZZAZIONE - Codice generato il {0:d} dall'operatore {1}", Date.Now.Date, GetCognomeNomeOperatore())
                lblProceduraTop.Text = sProceduraAnonimizzazione
                lblProceduraBottom.Text = sProceduraAnonimizzazione
                IdModuloStampaAvviso.InnerHtml = My.Settings.Anonimizzazioni_ModuloStampa_Avviso
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
            ' In caso di errore NON eseguiamo la select degli object data source
            mbDettaglioPazienteObjectDataSource_CancelSelect = True
            mbDettaglioAnonimizzazioneObjectDataSource_CancelSelect = True
            mbEsenzioniObjectDataSource_CancelSelect = True
        End Try

    End Sub


#Region " DettaglioPazienteObjectDataSource "

    Private Sub DettaglioPazienteObjectDataSource_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DettaglioPazienteObjectDataSource.Selected
        Try
            If e.Exception IsNot Nothing Then
                Dim ex As Exception = e.Exception.InnerException
                If ex Is Nothing Then ex = e.Exception
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
        '
        ' Questa funzione è differente da quella in SAC-USER: qui usiamo il dataset OrganigrammaDataset
        '
        Dim sRet As String = String.Empty
        Using oTa As New OrganigrammaDataSetTableAdapters.OggettiActiveDirectoryTableAdapter
            Dim odt As OrganigrammaDataSet.OggettiActiveDirectoryDataTable = oTa.GetData(HttpContext.Current.User.Identity.Name, "Utente", Nothing, False, 1)
            If (Not odt Is Nothing) AndAlso (odt.Rows.Count > 0) Then
                Dim oRow As OrganigrammaDataSet.OggettiActiveDirectoryRow = odt(0)
                If (Not oRow.IsCognomeNull) AndAlso (Not oRow.IsNomeNull) Then
                    Dim sCognome As String = oRow.Cognome
                    Dim sNome As String = oRow.Nome
                    If (Not String.IsNullOrEmpty(sCognome)) AndAlso (Not String.IsNullOrEmpty(sNome)) Then
                        sRet = String.Concat(sCognome, " ", sNome)
                    End If
                End If
            End If
        End Using
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



#Region "EsenzioniObjectDataSource"

    Private Sub EsenzioniObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles EsenzioniObjectDataSource.Selecting
        Try
            e.Cancel = mbEsenzioniObjectDataSource_CancelSelect
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub

    Private Sub EsenzioniObjectDataSource_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles EsenzioniObjectDataSource.Selected
        Try
            If e.Exception IsNot Nothing Then
                Dim ex As Exception = e.Exception.InnerException
                If ex Is Nothing Then ex = e.Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
                e.ExceptionHandled = True
            Else
                '
                ' Controllo la presenza delle esenzioni
                '
                divEsenzioni.Visible = False
                Dim dt As Data.DataTable = CType(e.ReturnValue, Data.DataTable)
                If (Not dt Is Nothing) AndAlso (dt.Rows.Count > 0) Then
                    divEsenzioni.Visible = True
                End If
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try

    End Sub

#End Region


#Region "Funzioni usate nella parte ASPX"
    ''' <summary>
    ''' Restituisce il testo dell'esenzione contenuta dentro il campo TestoEsenzione.
    ''' </summary>
    ''' <param name="row"></param>
    ''' <returns></returns>
    Protected Function GetTestoEsenzione(ByVal row As Object) As String
        Dim testoEsenzione As String = String.Empty

        Try
            'row è di tipo DataRowView
            If row IsNot Nothing Then
                'Prendo la DataRow
                If row.Row IsNot Nothing Then
                    Dim oRowEsenzione As Data.DataRow = CType(row.Row, Data.DataRow)
                    If oRowEsenzione IsNot Nothing Then
                        If Not oRowEsenzione("TestoEsenzione") Is DBNull.Value Then
                            testoEsenzione = oRowEsenzione("TestoEsenzione")
                        End If
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

End Class



<DataObject(True)>
Public Class EsenzioniPaziente

    <DataObjectMethod(DataObjectMethodType.Select, True)>
    Public Function GetData(ByVal Id As Guid) As Data.DataTable
        Dim oRet As Data.DataTable = Nothing
        Dim oDataInizioValidita As DateTime?
        Dim oDataFineValidita As DateTime?
        '
        ' Leggo dal database
        '
        Dim odt As PazientiDataSet.EsenzioniListaDataTable
        Using ota As New PazientiDataSetTableAdapters.EsenzioniListaTableAdapter
            odt = ota.GetDataByPaziente(Id, oDataFineValidita)
        End Using
        '
        ' Restituisco solo le esenzioni attive
        '
        If Not odt Is Nothing AndAlso odt.Rows.Count > 0 Then
            '
            ' Filtro le attive 
            '
            Dim oOggi As DateTime = Date.Now.Date
            For Each oRow As PazientiDataSet.EsenzioniListaRow In odt
                oDataInizioValidita = oOggi
                oDataFineValidita = oOggi
                If Not oRow.IsDataInizioValiditaNull Then oDataInizioValidita = oRow.DataInizioValidita
                If Not oRow.IsDataFineValiditaNull Then oDataFineValidita = oRow.DataFineValidita

                If Not (oDataInizioValidita.Value <= oOggi And oOggi <= oDataFineValidita.Value) Then
                    oRow.Delete()
                End If
            Next
            odt.AcceptChanges()

            '
            ' Ordino DataInizioValidita ASC
            '
            Dim oDataView As New Data.DataView(odt)
            oDataView.Sort = " DataInizioValidita ASC"
            oRet = oDataView.ToTable()

        End If
        '
        '
        '
        Return oRet
    End Function


    Private Function GetDataValidita(ByVal oData1 As DateTime?, ByVal oOggi As DateTime) As DateTime
        If Not oData1.HasValue Then oData1 = oOggi
        Return oData1.Value
    End Function

End Class