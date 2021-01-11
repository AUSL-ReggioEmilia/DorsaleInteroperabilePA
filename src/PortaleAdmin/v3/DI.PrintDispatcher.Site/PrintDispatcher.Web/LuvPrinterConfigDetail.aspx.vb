Partial Public Class LuvPrinterConfigDetail
    Inherits System.Web.UI.Page

    Private _className As String = System.Reflection.MethodBase.GetCurrentMethod().ReflectedType.Name
    Private _id As String
    Private _errorMessageArea As Label = Nothing
    Private _MainDataSourceCancelSelecting As Boolean = False
    Private _DropDownTipiStampante As DropDownList

    Private Enum TipiSTampanteEnum
        Standard = 1
        Sinteco = 2
    End Enum

    '
    ' Definisco i nomi di lista e dettaglio
    '
    Private Const PAGE_LIST As String = "LuvPrinterConfigList.aspx"
    Private Const PAGE_DETAIL As String = "LuvPrinterConfigDetail.aspx"

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
                ' Set FormView & Title
                '
                If Not String.IsNullOrEmpty(_id) Then
                    MainFormView.DefaultMode = FormViewMode.Edit
                Else
                    MainFormView.DefaultMode = FormViewMode.Insert
                End If
            End If
            '
            ' Aggiungo handler a dropdownlist (dopo avere impostato la modalità di funzionamento del form view)
            '
            _DropDownTipiStampante = DirectCast(Me.MainFormView.FindControl("ddlTipoStampante"), DropDownList)
            'AddHandler _DropDownTipiStampante.SelectedIndexChanged, AddressOf ddlTipoStampante_SelectedIndexChanged
            'Call ddlTipoStampante_SelectedIndexChanged(_DropDownTipiStampante, Nothing)

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
                    '
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
            e.Cancel = _MainDataSourceCancelSelecting

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
                _errorMessageArea.Visible = True
                _errorMessageArea.Text = UtilHelper.GetErrorMessage(UtilHelper.TypeError.Eliminazione)
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
        Dim sPerifericaValue As String = String.Empty
        Dim sServerDiStampaValue As String = String.Empty
        Dim sStampanteValue As String = String.Empty
        Dim sServerVirtualeValue As String = String.Empty
        Dim iTipiStampante As TipiSTampanteEnum
        '
        ' Business Logic
        '
        For Each sKey As String In oValue.Keys
            If sKey = "Periferica" Then
                sPerifericaValue = oValue(sKey).ToString
            ElseIf sKey = "ServerDiStampa" Then
                sServerDiStampaValue = oValue(sKey).ToString
            ElseIf sKey = "Stampante" Then
                sStampanteValue = oValue(sKey).ToString
            ElseIf sKey = "ServerVirtuale" Then
                sServerVirtualeValue = oValue(sKey).ToString
            ElseIf sKey = "IdTipiStampante" Then
                iTipiStampante = CType(oValue(sKey), TipiSTampanteEnum)
            ElseIf sKey = "Id" Then
                'Non faccio niente
            Else
                Throw New ApplicationException(String.Format("Il parametro di input '{0}' non è gestito!", sKey))
            End If
        Next

        If sPerifericaValue.Contains("\\") Then
            sMsgError = sMsgError & "Il nome di 'Pc invio richiesta' non deve contenere '\\'<BR>"
        End If
        If sServerDiStampaValue.Contains("\\") Then
            sMsgError = sMsgError & "Il nome del 'Server di stampa' non deve contenere '\\'<BR>"
        End If
        If sStampanteValue.StartsWith("\\") Then
            sMsgError = sMsgError & "Il nome della 'Stampante' non deve contenere '\\'<BR>"
        End If
        If sServerVirtualeValue.StartsWith("\\") Then
            sMsgError = sMsgError & "Il nome del 'Server virtuale' non deve contenere '\\'<BR>"
        End If
        If iTipiStampante <> TipiSTampanteEnum.Standard AndAlso (Not String.IsNullOrEmpty(sServerDiStampaValue)) Then
            sMsgError = sMsgError & "Il nome del 'Server di stampa' deve essere vuoto per un 'Tipo Stampante' diverso da ""STANDARD""<BR>"
        ElseIf iTipiStampante = TipiSTampanteEnum.Standard AndAlso (String.IsNullOrEmpty(sServerDiStampaValue)) Then
            sMsgError = sMsgError & "Il nome del 'Server di stampa' deve essere valorizzato per il 'Tipo Stampante' ""STANDARD""<BR>"
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

#Region "ddlServerVirtualeDataSource"

    Private Sub ddlServerVirtualeDataSource_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles ddlServerVirtualeDataSource.Selected
        Try
            If Not e.Exception Is Nothing Then
                My.Log.WriteException(e.Exception, TraceEventType.Error, UtilHelper.GetInnerException(e.Exception.InnerException, _className))
                _errorMessageArea.Visible = True
                _errorMessageArea.Text = UtilHelper.GetErrorMessage(UtilHelper.TypeError.CaricamentoDati)
                e.ExceptionHandled = True
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante la selezione dei dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante ddlServerVirtualeDataSource_Selected().")
            Utility.GestisciErroriApplicationInsights(ex, "ddlServerVirtualeDataSource_Selected")

        End Try
    End Sub

#End Region


#Region "ddlTipiStampanteDataSource"

    Private Sub ddlTipiStampanteDataSource_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles ddlTipiStampanteDataSource.Selected
        Try
            If Not e.Exception Is Nothing Then
                My.Log.WriteException(e.Exception, TraceEventType.Error, UtilHelper.GetInnerException(e.Exception.InnerException, _className))
                _errorMessageArea.Visible = True
                _errorMessageArea.Text = UtilHelper.GetErrorMessage(UtilHelper.TypeError.CaricamentoDati)
                e.ExceptionHandled = True
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante la selezione dei dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante ddlTipiStampanteDataSource_Selected().")
            Utility.GestisciErroriApplicationInsights(ex, "ddlTipiStampanteDataSource_Selected")

        End Try
    End Sub

#End Region



#Region "Gestione ddlTipiStampante e txtPrinterServerName "

    ' ''' <summary>
    ' ''' Funzione d'evento per il selected index changed della drop down list del tipo stampante
    ' ''' </summary>
    ' ''' <param name="sender"></param>
    ' ''' <param name="e"></param>
    ' ''' <remarks></remarks>
    'Private Sub ddlTipoStampante_SelectedIndexChanged(sender As Object, e As System.EventArgs)
    '    Call UpdateUI_TipiStampante()
    'End Sub

    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks>Ho usato questo evento perchè riesce sempre a settare le proprietà degli oggetti interessati</remarks>
    Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
        Call UpdateUI_TipiStampante()
    End Sub

    Private Sub UpdateUI_TipiStampante()
        Try
            Dim oddlTipoStampante As DropDownList = _DropDownTipiStampante
            Dim otxtPrinterServerName As TextBox = DirectCast(Me.MainFormView.FindControl("txtPrintServerName"), TextBox)
            '
            ' Se uno dei due controlli è nothing esco.
            '
            If oddlTipoStampante Is Nothing OrElse otxtPrinterServerName Is Nothing Then
                Exit Sub
            End If

			If oddlTipoStampante.SelectedValue <> "1" Then
				otxtPrinterServerName.Text = ""
				otxtPrinterServerName.Enabled = False
				otxtPrinterServerName.ReadOnly = True
				otxtPrinterServerName.Style.Add("background-color", "lightgray")
			Else
				otxtPrinterServerName.Enabled = True
				otxtPrinterServerName.ReadOnly = False
				otxtPrinterServerName.Style.Remove("background-color")
			End If
		Catch ex As Exception
            _errorMessageArea.Text = "Errore durante l'aggiornamento dell'interfaccia."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante UpdateUI_TipiStampante().")
            Utility.GestisciErroriApplicationInsights(ex, "UpdateUI_TipiStampante")

        End Try
    End Sub
#End Region
End Class