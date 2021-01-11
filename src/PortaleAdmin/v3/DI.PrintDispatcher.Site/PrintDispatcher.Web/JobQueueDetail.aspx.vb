Partial Public Class JobQueueDetail
    Inherits System.Web.UI.Page

    Private _className As String = System.Reflection.MethodBase.GetCurrentMethod().ReflectedType.Name
    Private _id As String
    Private _errorMessageArea As Label = Nothing

    Private _UiJobQueueSelectObjectDataSourceCancelSelecting As Boolean = False

    Private Property RedirectType() As UtilHelper.RedirectType
        Get
            Return DirectCast(ViewState("ViewState-RedirectType"), UtilHelper.RedirectType)
        End Get
        Set(ByVal value As UtilHelper.RedirectType)
            ViewState("ViewState-RedirectType") = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            '
            ' Error message area
            '
            _errorMessageArea = DirectCast(Me.Master.FindControl("ErrorMessageArea"), Label)

            '
            ' Get QueryString values
            '
            _id = Request.Params("id")
            If String.IsNullOrEmpty(_id) Then
                Throw New Exception("Il parametro 'Id' è obbligatorio.")
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante il caricamento della pagina."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante Page_Load().")
            Utility.GestisciErroriApplicationInsights(ex, "Page_Load")

        End Try
    End Sub

    Protected ReadOnly Property CurrentRow() As DataAccess.JobQueueDataSet.UiJobQueueSelectRow
        Get
            If CurrentTable IsNot Nothing Then
                Return CurrentTable(0)
            Else
                Throw New Exception("Dettaglio non disponibile!")
            End If
        End Get
    End Property

    Private Property CurrentTable() As DataAccess.JobQueueDataSet.UiJobQueueSelectDataTable
        Get
            Dim o As Object = ViewState("CurrentTable")
            If o IsNot Nothing Then
                Return DirectCast(o, DataAccess.JobQueueDataSet.UiJobQueueSelectDataTable)
            End If
            Return Nothing
        End Get
        Set(ByVal value As DataAccess.JobQueueDataSet.UiJobQueueSelectDataTable)
            ViewState.Add("CurrentTable", value)
        End Set
    End Property

    Private Sub ParentRedirect()
        If String.IsNullOrEmpty(UtilHelper.IdOrderEntry) Then
            Response.Redirect("JobQueueList.aspx", False)
        Else
            Response.Redirect(String.Format("JobQueueList.aspx?IdOrderEntry={0}", UtilHelper.IdOrderEntry), False)
        End If

    End Sub

    Private Sub SelfRedirect()
        Response.Redirect("JobQueue.aspx?id=" & _id, False)
    End Sub

    Private Sub UiJobQueueSelectFormView_ModeChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.FormViewModeEventArgs) Handles UiJobQueueSelectFormView.ModeChanging
        '
        ' Altrimenti premendo il pulsante Annulla viene richiamato una seconda volta l'evento UiJobQueueSelectFormView_ItemCreated
        ' che da errore "ObjectReference not set"
        '
        Try
            If e.CancelingEdit Then
                e.Cancel = True
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Si è verificato un errore. Contattare l'amministratore."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante UiJobQueueSelectFormView_ModeChanging().")
            Utility.GestisciErroriApplicationInsights(ex, "UiJobQueueSelectFormView_ModeChanging")

        End Try
    End Sub

    Protected Sub UiJobQueueSelectFormView_ItemCreated(ByVal sender As Object, ByVal e As EventArgs) Handles UiJobQueueSelectFormView.ItemCreated
        Try
            Dim updateRePrintButton As Button = DirectCast(UiJobQueueSelectFormView.FindControl("UpdateRePrintButton"), Button)
            UtilHelper.AggiornaPulsantiAzione(updateRePrintButton, CurrentRow)
            '---------------------------------------------------------------------------
            ' Pulsanti di visualizzazione dei documenti
            '---------------------------------------------------------------------------
            Call AggiornaDocumentViewerButton()
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante la creazione del dettaglio."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante UiJobQueueSelectFormView_ItemCreated().")
            Utility.GestisciErroriApplicationInsights(ex, "UiJobQueueSelectFormView_ItemCreated")

        End Try

    End Sub

    Protected Sub UiJobQueueSelectFormView_ItemCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.FormViewCommandEventArgs) Handles UiJobQueueSelectFormView.ItemCommand
        Try
            Dim sCommandName As String = e.CommandName

            Select Case sCommandName
                Case DataControlCommands.CancelCommandName
                    '
                    ' Ritorna al parent
                    ' impedisco l'operazione di select dell'object data source e faccio subito il redirect al parent
                    '
                    _UiJobQueueSelectObjectDataSourceCancelSelecting = True
                    ParentRedirect()

                Case "RePrintCommand"
                    '
                    ' Eseguo subito il comando di Riinvio in stampa e torno alla lista
                    '
                    If RePrint() Then
                        ParentRedirect()
                    End If

                Case "ShowDoc"
                    '
                    ' Apro il document viewer
                    '
                    Call OpenDocumentViewer(New Guid(_id))

                Case Else
                    Throw New Exception(String.Format("Il comando '{0}' non è supportato", sCommandName))

            End Select
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante la selezione del comando da eseguire."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante UiJobQueueSelectFormView_ItemCommand().")
            Utility.GestisciErroriApplicationInsights(ex, "UiJobQueueSelectFormView_ItemCommand")

        End Try

    End Sub

    Private Function RePrint() As Boolean
        Try
            Dim Ts As Byte() = CurrentRow.Ts
            'Using ta As New DataAccess.JobQueueDataSetTableAdapters.QueriesTableAdapter()
            '    ta.UiJobQueueUpdate(New Guid(_id), Ts, True, My.User.Name)
            'End Using
            Return UtilHelper.RePrint(New Guid(_id), Ts)
        Catch ex As Exception
            My.Log.WriteException(ex, TraceEventType.Error, UtilHelper.GetInnerException(ex.InnerException, _className))
            _errorMessageArea.Visible = True
            _errorMessageArea.Text = "Errore durante l'operazione di ri-invio della stampa."
            Utility.GestisciErroriApplicationInsights(ex, "RePrint")

            Return False
        End Try

    End Function

    Protected Sub UiJobQueueSelectObjectDataSource_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles UiJobQueueSelectObjectDataSource.Selecting
        Try
            e.Cancel = _UiJobQueueSelectObjectDataSourceCancelSelecting
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante la selezione dei dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante UiJobQueueSelectObjectDataSource_Selecting().")
            Utility.GestisciErroriApplicationInsights(ex, "UiJobQueueSelectObjectDataSource_Selecting")

        End Try

    End Sub

    Protected Sub UiJobQueueSelectObjectDataSource_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles UiJobQueueSelectObjectDataSource.Selected
        Try
            If Not e.Exception Is Nothing Then
                My.Log.WriteException(e.Exception, TraceEventType.Error, UtilHelper.GetInnerException(e.Exception.InnerException, _className))
                _errorMessageArea.Visible = True
                _errorMessageArea.Text = UtilHelper.GetErrorMessage(UtilHelper.TypeError.Creazione)
                e.ExceptionHandled = True
            Else
                CurrentTable = DirectCast(e.ReturnValue, DataAccess.JobQueueDataSet.UiJobQueueSelectDataTable)
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante la selezione dei dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante UiJobQueueSelectObjectDataSource_Selected().")
            Utility.GestisciErroriApplicationInsights(ex, "UiJobQueueSelectObjectDataSource_Selected")

        End Try
    End Sub

    Protected Function GetError(ByVal oPrintJobError As Object) As String
        Dim sRet As String = String.Empty
        If Not oPrintJobError Is DBNull.Value Then
            sRet = DirectCast(oPrintJobError, String)
        End If
        '
        '
        '
        Return sRet

    End Function

    Protected Function GetStatus(ByVal oPrintJobStatus As Object) As String
        Dim sRet As String = String.Empty
        If Not oPrintJobStatus Is DBNull.Value Then
            sRet = DirectCast(oPrintJobStatus, String)
        End If
        '
        '
        '
        Return sRet

    End Function

    Private Sub AggiornaDocumentViewerButton()
        If Not CurrentTable Is Nothing Then
            If CurrentTable.Rows.Count > 0 Then
                If Not CurrentTable(0).IsInHistoryNull AndAlso CurrentTable(0).InHistory = False Then
                    Dim divDocViewer As HtmlControl = DirectCast(UiJobQueueSelectFormView.FindControl("divDocViewer"), HtmlControl)
                    Dim showDocButton As Button = DirectCast(UiJobQueueSelectFormView.FindControl("showDocButton"), Button)
                    '
                    ' Visualizzo/Nascondo i pulsanti per visualizzare i documenti
                    ' Ora sempre True perchè applicazione per amministratori
                    '
                    divDocViewer.Visible = True
                    '
                    ' showDocButton è sempre visibile
                    '
                    showDocButton.Visible = True
                End If
            End If
        End If
    End Sub

    ''' <summary>
    ''' Funzione per aprire in una nuova pagina l'url del visualizzatore documenti
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub OpenDocumentViewer(ByVal IdJob As Guid)
        Dim sUrl As String = String.Empty
        sUrl = Me.ResolveUrl(String.Format("~/DocumentViewer.ashx?IdJob={0}", IdJob))

        Dim sScript As String = JSFunctionOpenWindow() & vbCrLf &
                                JSOpenWindowCode(sUrl, True, False, False, False, True, False, False, True, 400, 400)

        sScript = JSBuildScript(sScript)
        Page.ClientScript.RegisterStartupScript(GetType(Page), "OpenDocumentViewer", sScript)
    End Sub

#Region "Funzioni Java per apertura di una nuova finestra"

    Private Function JSBuildScript(ByVal code As String) As String
        '
        ' Da usare con RegisterStartupScript()
        '
        Const OPEN_COMMENT_TAG As String = "<!--"
        Const CLOSE_COMMENT_TAG As String = "// -->"
        code = code.Trim()
        If Not code.StartsWith(OPEN_COMMENT_TAG) Then
            code = OPEN_COMMENT_TAG & vbCrLf & code
        End If
        If Not code.EndsWith(CLOSE_COMMENT_TAG) Then
            code = code & vbCrLf & CLOSE_COMMENT_TAG
        End If
        Return "<script language=""javascript"" type=""text/javascript"">" & code & "</script>"
    End Function

    Private Function JSFunctionOpenWindow() As String
        '
        ' Prima si registra la funzione poi si registra JSOpenWindow
        '
        Return "function OpenWindow(sURL, sOptions, bReplace, iWidth, iHeight)" & vbCrLf &
                 "{" & vbCrLf &
                 "var w = 640, h = 480;" & vbCrLf &
                 "var newwindow;" & vbCrLf &
                 "if (document.all || document.layers)" & vbCrLf &
                 "{" & vbCrLf &
                 "w = screen.availWidth;" & vbCrLf &
                 "h = screen.availHeight;" & vbCrLf &
                 "}" & vbCrLf &
                 "var iLeft = (w-iWidth)/2;" & vbCrLf &
                 "var iTop = (h-iHeight)/2;" & vbCrLf &
                 "var Options = sOptions + ',left=' + iLeft + ',top=' + iTop + ',width=' + iWidth + ',height=' + iHeight;" & vbCrLf &
                 "newwindow =  window.open(sURL,'_blank',Options, bReplace);" & vbCrLf &
                 "newwindow.opener = self;" & vbCrLf &
                 "newwindow.focus();" & vbCrLf &
                 "}" & vbCrLf
    End Function

    Private Function JSOpenWindowCode(ByVal sURL As String, ByVal bResizable As Boolean,
                                            ByVal bLocation As Boolean, ByVal bMenuBar As Boolean,
                                            ByVal bToolbar As Boolean, ByVal bScrolbars As Boolean,
                                            ByVal bStatus As Boolean, ByVal bTitlebar As Boolean,
                                            ByVal bReplace As Boolean,
                                            ByVal iHeight As Integer, ByVal iWidth As Integer) As String
        '
        ' Apre una nuova finestra
        '
        Dim iTop As Integer = 0
        Dim iLeft As Integer = 0
        Dim sOptions As String = String.Empty
        Dim sLocation As String = "no"
        Dim sMenuBar As String = "no"
        Dim sResizable As String = "no"
        Dim sToolbar As String = "no"
        Dim sScrolbars As String = "no"
        Dim sStatus As String = "no"
        Dim sTitleBar As String = "no"
        Dim sReplace As String = "false"

        If bResizable Then sResizable = "yes"
        If bToolbar Then sToolbar = "yes"
        If bScrolbars Then sScrolbars = "yes"
        If bStatus Then sStatus = "yes"
        If bTitlebar Then sTitleBar = "yes"
        If bReplace Then sReplace = "true"
        If bLocation Then sLocation = "yes"
        If bMenuBar Then sMenuBar = "yes"

        sOptions &= "location=" & sLocation & ",menubar=" & sMenuBar
        sOptions &= ",resizable=" & sResizable & ",toolbar=" & sToolbar & ",scrollbars=" & sScrolbars
        sOptions &= ",status=" & sStatus & ",titlebar=" & sTitleBar

        Return "OpenWindow('" & sURL & "','" & sOptions & "'," & sReplace & "," & iWidth & "," & iHeight & ");"

    End Function

#End Region

End Class