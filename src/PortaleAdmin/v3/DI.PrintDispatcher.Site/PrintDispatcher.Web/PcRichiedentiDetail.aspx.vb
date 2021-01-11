Public Class PcRichiedentiDetail
    Inherits System.Web.UI.Page

    Private _className As String = System.Reflection.MethodBase.GetCurrentMethod().ReflectedType.Name
    Private _id As String
    Private _errorMessageArea As Label = Nothing
    Private _MainDataSourceCancelSelecting As Boolean = False
    Private _DropDownTipiStampante As DropDownList
    Private _CancelMainListDataSourceSelectOperation As Boolean = False

    '
    ' Definisco i nomi di lista e dettaglio
    '
    Private Const PAGE_LIST As String = "PcRichiedentiList.aspx"
    Private Const PAGE_DETAIL As String = "PcRichiedentiDetail.aspx"

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
            ' Get QueryString values
            '
            _id = Request.Params("id")
            '
            ' Error message area
            '
            _errorMessageArea = DirectCast(Me.Master.FindControl("ErrorMessageArea"), Label)

            If Not Page.IsPostBack Then
                '
                ' Imposto il link per creare nuovo "modulo"
                '
                lnkNuovo.NavigateUrl = GetNewItemNavigateUrl()
                '
                ' Set FormView & Title

                '
                If Not String.IsNullOrEmpty(_id) Then

                    MainFormView.DefaultMode = FormViewMode.Edit
                Else

                    MainFormView.DefaultMode = FormViewMode.Insert
                    divElencoStampanti.Visible = False

                End If

            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante il caricamento della pagina."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante Page_Load().")
            Utility.GestisciErroriApplicationInsights(ex, "Page_Load")

        End Try
    End Sub

#Region "Redirect"

    Private Sub ParentRedirect()
        Response.Redirect(Me.ResolveUrl("~/" & PAGE_LIST), False)
    End Sub

    Private Sub SelfRedirect()
        Response.Redirect(Me.ResolveUrl("~/" & PAGE_DETAIL) & "?id=" & _id, False)
    End Sub

#End Region

#Region "MainFormView"

    Protected Sub MainFormView_ItemCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.FormViewCommandEventArgs) Handles MainFormView.ItemCommand
        Try
            Select Case e.CommandName
                Case DataControlCommands.InsertCommandName
                    If e.CommandArgument.ToString().Equals("ParentRedirect") Then
                        RedirectType = UtilHelper.RedirectType.Parent
                        _MainDataSourceCancelSelecting = True
                    Else
                        RedirectType = UtilHelper.RedirectType.Self
                    End If
                Case DataControlCommands.UpdateCommandName
                    If e.CommandArgument.ToString().Equals("ParentRedirect") Then
                        RedirectType = UtilHelper.RedirectType.Parent
                        _MainDataSourceCancelSelecting = True
                    Else
                        RedirectType = UtilHelper.RedirectType.Self
                    End If
                Case DataControlCommands.DeleteCommandName
                    RedirectType = UtilHelper.RedirectType.Parent

                Case DataControlCommands.CancelCommandName
                    '
                    ' Eseguo subito redirect alla pagina parent

                    _MainDataSourceCancelSelecting = True
                    ParentRedirect()

            End Select
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante la selezione del comando da eseguire."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainFormView_ItemCommand().")
            Utility.GestisciErroriApplicationInsights(ex, "MainFormView_ItemCommand")

        End Try
    End Sub

    Private Sub MainFormView_ItemUpdating(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.FormViewUpdateEventArgs) Handles MainFormView.ItemUpdating
        Try
            Dim sValidateError As String = MyValidate(e.NewValues)
            If Not String.IsNullOrEmpty(sValidateError) Then
                _errorMessageArea.Text = sValidateError
                e.Cancel = True
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante l'aggiornamento."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainFormView_ItemUpdating().")
            Utility.GestisciErroriApplicationInsights(ex, "MainFormView_ItemUpdating")

        End Try

    End Sub

    Private Sub MainFormView_ItemUpdated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.FormViewUpdatedEventArgs) Handles MainFormView.ItemUpdated
        Try
            If Not e.Exception Is Nothing Then
                My.Log.WriteException(e.Exception, TraceEventType.Error, UtilHelper.GetInnerException(e.Exception.InnerException, _className))
                _errorMessageArea.Visible = True
                _errorMessageArea.Text = "Si è verificato un errore durante l'aggiornamento."

                e.ExceptionHandled = True
                e.KeepInEditMode = True
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante l'aggiornamento."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainFormView_ItemUpdated().")
            Utility.GestisciErroriApplicationInsights(ex, "MainFormView_ItemUpdated")

        End Try
    End Sub

    Private Sub MainFormView_ItemInserting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.FormViewInsertEventArgs) Handles MainFormView.ItemInserting
        Try
            Dim sValidateError As String = MyValidate(e.Values)
            If Not String.IsNullOrEmpty(sValidateError) Then
                _errorMessageArea.Text = sValidateError
                e.Cancel = True
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante l'aggiornamento."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainFormView_ItemUpdating().")
            Utility.GestisciErroriApplicationInsights(ex, "MainFormView_ItemInserting")

        End Try

    End Sub

    Private Sub MainFormView_ItemInserted(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.FormViewInsertedEventArgs) Handles MainFormView.ItemInserted
        Try
            If Not e.Exception Is Nothing Then
                My.Log.WriteException(e.Exception, TraceEventType.Error, UtilHelper.GetInnerException(e.Exception.InnerException, _className))
                _errorMessageArea.Visible = True
                _errorMessageArea.Text = "Si è verificato un errore durante l'inserimento."

                e.ExceptionHandled = True
                e.KeepInInsertMode = True
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante l'aggiornamento."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainFormView_ItemUpdated().")
            Utility.GestisciErroriApplicationInsights(ex, "MainFormView_ItemInserted")

        End Try
    End Sub

#End Region

#Region "MainFormDataSource"

    Private Sub MainDataSource_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles MainDataSource.Selecting
        Try
            If _MainDataSourceCancelSelecting = True Then
                e.Cancel = True
                Exit Sub
            Else
                e.Cancel = False
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante la selezione dei dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainDataSource_Selecting().")
            Utility.GestisciErroriApplicationInsights(ex, "MainDataSource_Selecting")

        End Try
    End Sub

    Protected Sub MainDataSource_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles MainDataSource.Selected
        Try
            If Not e.Exception Is Nothing Then
                My.Log.WriteException(e.Exception, TraceEventType.Error, UtilHelper.GetInnerException(e.Exception.InnerException, _className))
                _errorMessageArea.Visible = True
                _errorMessageArea.Text = UtilHelper.GetErrorMessage(UtilHelper.TypeError.CaricamentoDati)
                e.ExceptionHandled = True
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante la selezione dei dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainDataSource_Selected().")
            Utility.GestisciErroriApplicationInsights(ex, "MainDataSource_Selected")

        End Try
    End Sub

    Private Sub MainDataSource_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles MainDataSource.Inserting
        Try
            e.InputParameters("UtenteInserimento") = HttpContext.Current.User.Identity.Name
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante l'inserimento dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainDataSource_Inserted().")
            Utility.GestisciErroriApplicationInsights(ex, "MainDataSource_Inserting")
        End Try
    End Sub

    Protected Sub MainDataSource_Inserted(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles MainDataSource.Inserted
        Try
            If Not e.Exception Is Nothing Then
                My.Log.WriteException(e.Exception, TraceEventType.Error, UtilHelper.GetInnerException(e.Exception.InnerException, _className))
                _errorMessageArea.Visible = True
                _errorMessageArea.Text = UtilHelper.GetErrorMessage(UtilHelper.TypeError.Creazione)
                e.ExceptionHandled = True
            Else
                If RedirectType = UtilHelper.RedirectType.Parent Then
                    ParentRedirect()
                End If
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante l'inserimento dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainDataSource_Inserted().")
            Utility.GestisciErroriApplicationInsights(ex, "MainDataSource_Inserted")

        End Try
    End Sub

    Private Sub MainDataSource_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles MainDataSource.Updating
        Try
            e.InputParameters("UtenteModifica") = HttpContext.Current.User.Identity.Name
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante l'aggiornamento dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainDataSource_Updated().")
            Utility.GestisciErroriApplicationInsights(ex, "MainDataSource_Updating")
        End Try
    End Sub

    Protected Sub MainDataSource_Updated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles MainDataSource.Updated
        Try
            If Not e.Exception Is Nothing Then
                My.Log.WriteException(e.Exception, TraceEventType.Error, UtilHelper.GetInnerException(e.Exception.InnerException, _className))
                _errorMessageArea.Visible = True
                _errorMessageArea.Text = UtilHelper.GetErrorMessage(UtilHelper.TypeError.Aggiornamento)
                e.ExceptionHandled = True
            Else
                '
                ' In base al pulsante premuto
                '
                If RedirectType = UtilHelper.RedirectType.Parent Then
                    ParentRedirect()
                End If
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante l'aggiornamento dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainDataSource_Updated().")
            Utility.GestisciErroriApplicationInsights(ex, "MainDataSource_Updated")

        End Try

    End Sub

    Protected Sub MainDataSource_Deleted(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles MainDataSource.Deleted
        Try
            If Not e.Exception Is Nothing Then
                My.Log.WriteException(e.Exception, TraceEventType.Error, UtilHelper.GetInnerException(e.Exception.InnerException, _className))
                '
                ' Segnalo se errore di integrità referenziale
                '
                Dim sErr As String = String.Empty
                If e.Exception.InnerException.Message.ToUpper.Contains("DELETE STATEMENT CONFLICTED WITH THE REFERENCE CONSTRAINT") Then
                    sErr = "<br/>Si è verificato un errore di integrità referenziale (Il record è in uso in altre tabelle)."
                End If
                '
                '
                '
                _errorMessageArea.Visible = True
                _errorMessageArea.Text = UtilHelper.GetErrorMessage(UtilHelper.TypeError.Eliminazione) & sErr
                e.ExceptionHandled = True
            Else
                _MainDataSourceCancelSelecting = True
                '
                ' Se tutto OK torno alla pagina parent
                '
                ParentRedirect()
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante la cancellazione dei dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainDataSource_Deleted().")
            Utility.GestisciErroriApplicationInsights(ex, "MainDataSource_Deleted")

        End Try
    End Sub

    Private Function MyValidate(ByVal oValue As IOrderedDictionary) As String
        Dim sMsgError As String = String.Empty
        Dim sNome As String = String.Empty
        '
        ' Business Logic
        '
        For Each sKey As String In oValue.Keys
            If sKey = "Nome" Then
                sNome = oValue(sKey).ToString
                If String.IsNullOrEmpty(sNome) Then sMsgError = sMsgError & String.Concat(vbCrLf, String.Format("Il campo '{0}' è obbligatorio.", "Nome"))
            ElseIf sKey = "Id" Then
                'Non faccio niente
            Else
                Throw New ApplicationException(String.Format("Il parametro di input '{0}' non è gestito!", sKey))
            End If
        Next

        If sNome.Contains("\\") Then
            sMsgError = sMsgError & "Il nome del Pc non deve contenere '\\'<BR>"
        End If

        If Not String.IsNullOrEmpty(sMsgError) Then
            Return sMsgError
        End If
        '
        '
        '
        Return sMsgError
    End Function

#End Region

#Region "MainListDataSource"

    Private Sub MainListDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles MainListDataSource.Selecting
        '
        '
        ' Imposto il parametro della select della lista dei "moduli"
        Try
            If _CancelMainListDataSourceSelectOperation Then
                e.Cancel = True
            Else
                '
                ' passo i parametri di filtro alla stored procedure
                '
                e.InputParameters("IdPcRichiedenti") = _id
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante il caricamento dei dati della lista."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainListDataSource_Selecting().")

        End Try
    End Sub

    Private Sub MainListDataSource_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles MainListDataSource.Selected
        Try
            If Not e.Exception Is Nothing Then
                My.Log.WriteException(e.Exception, TraceEventType.Error, UtilHelper.GetInnerException(e.Exception.InnerException, _className))
                _errorMessageArea.Visible = True
                _errorMessageArea.Text = UtilHelper.GetErrorMessage(UtilHelper.TypeError.CaricamentoDati)
                e.ExceptionHandled = True
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante il caricamento dei dati della lista."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainListDataSource_Selected().")
        End Try
    End Sub

#End Region

#Region "Funzioni chiamate nel markup"

    Protected Function GetEditItemImageUrl() As String
        Return "~/Images/edititem.gif"
    End Function

    Protected Function GetEditItemNavigateUrl(ByVal Id As Object, ByVal IdSistemiEroganti As Object) As String
        Dim sUrl As String = Me.ResolveUrl("~/PcRichiedentiStampantiDetail.aspx")
        sUrl = String.Concat(sUrl, "?Id=", DirectCast(Id, Guid).ToString, "&IdPcRichiedenti=", DirectCast(IdSistemiEroganti, Guid).ToString)
        Return sUrl
    End Function

    Protected Function GetNewItemNavigateUrl() As String
        Dim sUrl As String = Me.ResolveUrl("~/PcRichiedentiStampantiDetail.aspx")
        Return sUrl & "?IdPcRichiedenti=" & _id
    End Function

#End Region

End Class