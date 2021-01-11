Imports DI.Sac.User
Imports System.Web.UI.WebControls
Imports System
Imports System.Diagnostics
Imports DI.Sac.User.Data
Imports System.Reflection
Imports System.Web.UI
Imports System.Web

Public Class PazienteDettaglioAnonimizzazione
    Inherits System.Web.UI.Page

    Private Shared ReadOnly _className As String = MethodBase.GetCurrentMethod().ReflectedType.Name

    Private mbDettaglioPazienteObjectDataSource_CancelSelect As Boolean = False
    Private mbDettaglioAnonimizzazioneObjectDataSource_CancelSelect As Boolean = False
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
                hlShowModuleToPrint.Visible = False
                '
                ' Modifico url per il menu orizzontale: il link precedente è sempre "Dettaglio paziente" per come è costruito il sitemap
                '
                'If Not SiteMap.CurrentNode Is Nothing Then
                '    Call Utility.SetSiteMapNodeQueryString(SiteMap.CurrentNode.ParentNode, String.Format("id={0}", sIdPaziente))
                'End If
                '
                ' Memorizzo url di ritorno: il default in questo caso sarebbe inutile
                '
                Call SetUrlBack(String.Format("~/Pazienti/PazienteDettaglio.aspx?Id={0}", sIdPaziente), "~/Pazienti/PazientiLista.aspx")
                '
                ' A questa pagina si arriva solo dopo avere creato una anonimizzazione
                ' Verifico se l'ha i diritti di anonimizzazione
                '
                mbCanCreateAnonimizzazione = Utility.IsUserAnonimizzatore()
                If Not (mbCanCreateAnonimizzazione) Then
                    MainTable.Visible = False
                    divErrorMessage.Visible = True
                    LabelError.Text = "L'utente non ha i diritti per accedere alla pagina."
                    Exit Sub
                End If
                '-----------------------------------------------------------------------------------------
                ' Configuro URL per visualizzare la pagina per la stampa
                '-----------------------------------------------------------------------------------------
                ' MODIFICA ETTORE 2016-02-11: navigo alla pagina passando IdPazienteAnonimo
                Dim sUrl As String = Me.ResolveUrl(String.Format("~/Pazienti/PazienteDettaglioAnonimizzazioniStampa.aspx?Id={0}&IdPazienteAnonimo={1}", sIdPaziente, sIdPazienteAnonimo))
                'ATTENZIONE: il parametro ReturnValue deve essere false per interrompere la catena degli eventi dopo l'esecuzione della window.open (*)
                hlShowModuleToPrint.Attributes("OnClick") = JsWindowOpen(sUrl, "Stampa", 100, 100, 800, 500, True, True, False, False, False, True, False)
                'ATTENZIONE: Compilo correttamente la proprietà NavigateUrl anche se non verrà eseguita (vedi (*)) cosi l'hyperlink si comporterà come un LINK
                hlShowModuleToPrint.NavigateUrl = sUrl
                hlShowModuleToPrint.Visible = True
            End If

        Catch ex As Exception
            'Scrivo solo nell'event log
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                divErrorMessage.Visible = True
                LabelError.Text = sErrorMessage
            End If
            ' In caso di errore NON eseguiamo la select degli object data source
            mbDettaglioPazienteObjectDataSource_CancelSelect = True
            mbDettaglioAnonimizzazioneObjectDataSource_CancelSelect = True
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

#Region " DettaglioPazienteObjectDataSource "

    Private Sub DettaglioPazienteObjectDataSource_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DettaglioPazienteObjectDataSource.Selected
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
                '
                ' Controllo la presenza del record anagrafico originale
                '
                Dim dt As PazientiAnonimizzazioniDataSet.PazientiAnonimizzazioniPazienteSelectDataTable = CType(e.ReturnValue, PazientiAnonimizzazioniDataSet.PazientiAnonimizzazioniPazienteSelectDataTable)
                If Not ((Not dt Is Nothing) AndAlso (dt.Rows.Count > 0)) Then
                    'Record non trovato: nascondo tutto
                    MainTable.Visible = False
                    Throw New ApplicationException("Il record anagrafico originale non esiste! Contattare l'amministratore")
                End If
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

    Private Sub DettaglioPazienteObjectDataSource_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DettaglioPazienteObjectDataSource.Selecting
        Try
            e.Cancel = mbDettaglioPazienteObjectDataSource_CancelSelect
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

#Region " DettaglioAnonimizzazioneObjectDataSource "

    Private Sub DettaglioAnonimizzazioneObjectDataSource_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DettaglioAnonimizzazioneObjectDataSource.Selected
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
                '
                ' Controllo la presenza del record anonimo: ci deve essere perchè appena inserito.
                '
                Dim dt As PazientiAnonimizzazioniDataSet.PazientiAnonimizzazioniSelectByIdSacAnonimoDataTable = CType(e.ReturnValue, PazientiAnonimizzazioniDataSet.PazientiAnonimizzazioniSelectByIdSacAnonimoDataTable)
                If Not ((Not dt Is Nothing) AndAlso (dt.Rows.Count > 0)) Then
                    'Record non trovato: nascondo tutto
                    MainTable.Visible = False
                    Throw New ApplicationException("Il record anagrafico anonimo non esiste! Contattare l'amministratore")
                End If
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

    Private Sub DettaglioAnonimizzazioneObjectDataSource_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DettaglioAnonimizzazioneObjectDataSource.Selecting
        Try
            e.Cancel = mbDettaglioAnonimizzazioneObjectDataSource_CancelSelect
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


    ''' <summary>
    ''' Restituisce il codice JavaScript per aprire una finestra
    ''' </summary>
    ''' <param name="Url">Url della finestra da aprire</param>
    ''' <param name="WindowName">Nome della finestra</param>
    ''' <param name="Width_Px">Larghezza in pixel</param>
    ''' <param name="Height_Px">Altezza in pixel</param>
    ''' <param name="Resizable">Se true la finestra potrà essere ridimensionata</param>
    ''' <param name="Replace">Se true verrà riutilizzata la stessa finestra</param>
    ''' <param name="ReturnValue">Se false interrompe la catena degli eventi dopo l'esecuzione della window.open</param>
    ''' <returns>Il codice JavaScript per aprire una finestra</returns>
    ''' <remarks></remarks>
    Private Function JsWindowOpen(Url As String, WindowName As String, Left_Px As Integer, Top_Px As Integer, Width_Px As Integer, Height_Px As Integer, Resizable As Boolean, _
                                  ScrollBars As Boolean, MenuBar As Boolean, StatusBar As Boolean, ToolBar As Boolean, _
                                  Replace As Boolean, ReturnValue As Boolean) As String
        Dim sRet As String = String.Empty
        Dim sResizable As String = "0"
        Dim sReplace As String = "false"
        Dim sScrollBars As String = "0"
        Dim sMenuBar As String = "0"
        Dim sStatus As String = "0"
        Dim sToolBar As String = "0"
        Dim sReturnValue As String = "false"

        If Resizable Then sResizable = "1"
        If Replace Then sReplace = "true"
        If ScrollBars Then sScrollBars = "1"
        If MenuBar Then sMenuBar = "1"
        If StatusBar Then sStatus = "1"
        If ToolBar Then sToolBar = "1"

        If ReturnValue Then sReturnValue = "true"
        sRet = String.Format("var popup = window.open('{0}', '{1}', 'left={2}, top={3}, width={4},height={5},resizable={6},scrollbars={7},menubar={8}, status={9},toolbar={10}', {11}); popup.opener = self; popup.focus(); return {12};", _
                             Url, WindowName, Left_Px, Top_Px, Width_Px, Height_Px, sResizable, sScrollBars, sMenuBar, sStatus, sToolBar, sReplace, sReturnValue)

        Return sRet
    End Function
End Class