Public Class SistemiErogantiModuliDetail
    Inherits System.Web.UI.Page

    Private _className As String = System.Reflection.MethodBase.GetCurrentMethod().ReflectedType.Name
    Private _id As String
    Private _errorMessageArea As Label = Nothing
    Private _MainDataSourceCancelSelecting As Boolean = False
    Private _CancelMainListDataSourceSelectOperation As Boolean = False

    Private Property IdSistemaErogante() As String
        Get
            Return DirectCast(ViewState("ViewState-IdSistemaErogante"), String)
        End Get
        Set(ByVal value As String)
            ViewState("ViewState-IdSistemaErogante") = value
        End Set
    End Property

    Private Property FormatoModulo() As String
        Get
            Return DirectCast(ViewState("ViewState-FormatoModulo"), String)
        End Get
        Set(ByVal value As String)
            ViewState("ViewState-FormatoModulo") = value
        End Set
    End Property

    '
    ' Definisco i nomi delle pagin verso cui fare redirect
    '
    Private Const PAGE_LIST As String = "SistemiErogantiDetail.aspx"

    Private Const PAGE_DETAIL As String = "SistemiErogantiModuliDetail.aspx"

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
            _id = Request.Params("Id")
            '
            ' Error message area
            '
            _errorMessageArea = DirectCast(Me.Master.FindControl("ErrorMessageArea"), Label)

            If Not Page.IsPostBack Then
                '
                ' Lo leggo solo all'inizio
                '
                IdSistemaErogante = Request.Params("IdSistemiEroganti")
                '
                ' Leggo dettaglio del sistema erogante per creare un titolo
                '
                lblTitle.Text = GetTitle(IdSistemaErogante, _id)
                '
                ' Set della proprietà url del CurrentNode.ParentNode con l'id del paziente fuso
                '
                If SiteMap.CurrentNode IsNot Nothing Then
                    SiteMap.CurrentNode.ParentNode.ReadOnly = False
                    SiteMap.CurrentNode.ParentNode.Url = String.Concat(SiteMap.CurrentNode.ParentNode.Url.Split("?"c)(0), "?id=", IdSistemaErogante)
                End If
                '
                ' Set FormView & Title
                '
                If Not String.IsNullOrEmpty(_id) Then
                    MainFormView.DefaultMode = FormViewMode.Edit
                Else
                    MainFormView.DefaultMode = FormViewMode.Insert
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
        'Torno alla pagina di dettaglio del sistema erogante
        Response.Redirect(Me.ResolveUrl("~/" & PAGE_LIST) & "?id=" & IdSistemaErogante, False)
    End Sub

    Private Sub SelfRedirect()
        'Riapre la pagina corrente
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
            Else
                '
                ' Memorizzo _idSistemaErogante
                '
                Dim odt As DataAccess.SistemiErogantiDataSet.SistemiErogantiModuliSelectDataTable = CType(e.ReturnValue, DataAccess.SistemiErogantiDataSet.SistemiErogantiModuliSelectDataTable)
                If Not odt Is Nothing AndAlso odt.Rows.Count > 0 Then
                    IdSistemaErogante = odt(0).IdSistemiEroganti.ToString
                    'Memorizzo il valore sul record
                    FormatoModulo = odt(0).FormatoModulo
                Else
                    Throw New Exception(String.Format("La query non ha restituito record per Id={0}", _id))
                End If
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
            '
            ' NON HO MESSO LA Property SelectedValue nell'aspx: quindi valorizzo qui il nuovo valore di FormatoModulo
            '
            Dim oddlFormatoModulo As DropDownList = CType(MainFormView.FindControl("ddlFormatoModulo"), DropDownList)
            e.InputParameters("FormatoModulo") = oddlFormatoModulo.SelectedValue
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
            '
            ' NON HO MESSO LA Property SelectedValue nell'aspx: quindi valorizzo qui il nuovo valore di FormatoModulo
            '
            Dim oddlFormatoModulo As DropDownList = CType(MainFormView.FindControl("ddlFormatoModulo"), DropDownList)
            e.InputParameters("FormatoModulo") = oddlFormatoModulo.SelectedValue
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante l'aggiornamento dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainDataSource_Updated().")
            Utility.GestisciErroriApplicationInsights(ex, "MainDataSource_Updated")
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
        Dim sCodice As String = String.Empty
        Dim sCodiceAzienda As String = String.Empty
        Dim sDescrizione As String = String.Empty
        Dim bAttivo As Boolean = False
        '
        ' Business Logic
        '
        For Each sKey As String In oValue.Keys
            If sKey = "TipoModulo" Then
                sCodice = oValue(sKey).ToString
                If String.IsNullOrEmpty(sCodice) Then sMsgError = sMsgError & String.Concat(vbCrLf, String.Format("Il campo '{0}' è obbligatorio.", "TipoModulo"))
            ElseIf sKey = "FormatoModulo" Then
                sCodiceAzienda = oValue(sKey).ToString
                If String.IsNullOrEmpty(sCodiceAzienda) Then sMsgError = sMsgError & String.Concat(vbCrLf, String.Format("Il campo '{0}' è obbligatorio.", "FormatoModulo"))
            ElseIf sKey = "NomeDocumento" Then
                sDescrizione = oValue(sKey).ToString
                If String.IsNullOrEmpty(sDescrizione) Then sMsgError = sMsgError & String.Concat(vbCrLf, String.Format("Il campo '{0}' è obbligatorio.", "NomeDocumento"))
            ElseIf sKey = "OrdineDocumento" Then
                bAttivo = CType(oValue(sKey), Boolean)
            ElseIf sKey = "IdSistemaErogante" Then
                'Non faccio niente

            ElseIf sKey = "Id" Then
                'Non faccio niente
            Else
                Throw New ApplicationException(String.Format("Il parametro di input '{0}' non è gestito!", sKey))
            End If
        Next

        If Not String.IsNullOrEmpty(sMsgError) Then
            Return sMsgError
        End If
        '
        '
        '
        Return sMsgError
    End Function

#End Region

#Region "Funzioni chiamate nel markup"

    Protected Function GetEditItemImageUrl() As String
        Return "~/Images/edititem.gif"
    End Function

    ''' <summary>
    ''' Usata per modificare il dettaglio di un record figlio
    ''' </summary>
    ''' <param name="Id">Id della tabella SistemiErogantiModuli</param>
    ''' <returns></returns>
    Protected Function GetEditItemNavigateUrl(ByVal Id As Object) As String
        Dim sUrl As String = Me.ResolveUrl("~/SistemiErogantiModuliDetail.aspx")
        Return sUrl & "?Id=" & DirectCast(Id, Guid).ToString
    End Function

    Protected Function GetNewItemNavigateUrl() As String
        Return Me.ResolveUrl("~/SistemiErogantiModuliDetail.aspx")
    End Function

#End Region

    Private Function GetTitle(ByVal sIdSistemaErogante As String, sId As String) As String
        Dim sRet As String = String.Empty
        Try
            Using oTa As New DataAccess.SistemiErogantiDataSetTableAdapters.SistemiErogantiSelectTableAdapter
                Using oDt As DataAccess.SistemiErogantiDataSet.SistemiErogantiSelectDataTable = oTa.GetData(New Guid(sIdSistemaErogante))
                    If Not oDt Is Nothing AndAlso oDt.Rows.Count > 0 Then
                        Dim oRow As DataAccess.SistemiErogantiDataSet.SistemiErogantiSelectRow = oDt(0)
                        If String.IsNullOrEmpty(sId) Then
                            sRet = String.Format("Inserimento nuovo modulo per il sistema {0}-{1}", oRow.CodiceAzienda, oRow.Codice)
                        Else
                            sRet = String.Format("Modifica modulo per il sistema {0}-{1}", oRow.CodiceAzienda, oRow.Codice)
                        End If
                    End If
                End Using
            End Using
        Catch ex As Exception
            _errorMessageArea.Text = "Errore la lettura dei dati del sistema erogante."
            My.Log.WriteException(ex, TraceEventType.Error, "Durante la funzione GetTitle()")
            Utility.GestisciErroriApplicationInsights(ex, "GetTitle")
        End Try
        '
        '
        '
        Return sRet
    End Function

    Private Sub FormatoModuloDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles FormatoModuloDataSource.Selecting
        Try
            Dim oddlTipoModulo As DropDownList = CType(MainFormView.FindControl("ddlTipoModulo"), DropDownList)
            e.InputParameters("TipoModulo") = oddlTipoModulo.SelectedValue
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante l'inserimento dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante FormatoModuloDataSource_Selecting().")
            Utility.GestisciErroriApplicationInsights(ex, "FormatoModuloDataSource_Selecting")
        End Try
    End Sub

    Private Sub FormatoModuloDataSource_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles FormatoModuloDataSource.Selected
        Try
            If Not e.Exception Is Nothing Then
                My.Log.WriteException(e.Exception, TraceEventType.Error, UtilHelper.GetInnerException(e.Exception.InnerException, _className))
                _errorMessageArea.Visible = True
                _errorMessageArea.Text = UtilHelper.GetErrorMessage(UtilHelper.TypeError.CaricamentoDati)
                e.ExceptionHandled = True
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante la lettura dei formati dei moduli."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante FormatoModuloDataSource_Selected().")
            Utility.GestisciErroriApplicationInsights(ex, "FormatoModuloDataSource_Selected")

        End Try
    End Sub

    Protected Sub ddlTipoModulo_SelectedIndexChanged(sender As Object, e As EventArgs)
        '
        ' Gestione SelectedIndexChanged per ddlTipoModulo
        '
        Try
            Dim oddlFormatoModulo As DropDownList = CType(MainFormView.FindControl("ddlFormatoModulo"), DropDownList)
            oddlFormatoModulo.DataBind()
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante la selezione del tipo di modulo."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante ddlTipoModulo_SelectedIndexChanged().")
            Utility.GestisciErroriApplicationInsights(ex, "ddlTipoModulo_SelectedIndexChanged")
        End Try

    End Sub

    Protected Sub ddlFormatoModulo_PreRender(sender As Object, e As EventArgs)
        '
        ' Gestione PreRender per ddlFormatoModulo
        '
        Try
            Dim oddlFormatoModulo As DropDownList = CType(MainFormView.FindControl("ddlFormatoModulo"), DropDownList)
            If oddlFormatoModulo.Items.FindByValue("") Is Nothing Then
                'Se manca lo aggiungo
                oddlFormatoModulo.Items.Insert(0, New ListItem(String.Empty, String.Empty))
            End If
            If Not oddlFormatoModulo.Items.FindByValue(FormatoModulo) Is Nothing Then
                'Se è presente lo seleziono
                oddlFormatoModulo.SelectedValue = FormatoModulo
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante il prerender di ddlFormatoModulo."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante ddlFormatoModulo_PreRender().")
            Utility.GestisciErroriApplicationInsights(ex, "ddlFormatoModulo_PreRender")

        End Try

    End Sub

End Class