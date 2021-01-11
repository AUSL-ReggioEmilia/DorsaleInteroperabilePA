Partial Public Class JobQueueList
    Inherits System.Web.UI.Page

    Private _className As String = System.Reflection.MethodBase.GetCurrentMethod().ReflectedType.Name
    Private _errorMessageArea As Label = Nothing

    Private Enum MassiveOperation
        Pause
        Restore
        Delete
        RePrint
    End Enum

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            '
            ' Error message area
            '
            _errorMessageArea = DirectCast(Me.Master.FindControl("ErrorMessageArea"), Label)

            If Not Page.IsPostBack Then
                '
                ' Restore dei filtri
                '
                FilterHelper.Restore(DirectCast(panelFiltri, Control))
                '
                ' Hide massive command
                '
                MassiveCommandEnabled(False)
                '
                ' Imposto la visualizzazione della colonna dei check box per operazioni massive
                '
                UiJobQueueListGridView.Columns(0).Visible = True

                '
                ' Leggo QueryString e memorizzo/cancello
                '
                Dim sIdOrderEntry As String = HttpContext.Current.Request.QueryString("IdOrderEntry")
                UtilHelper.IdOrderEntry = sIdOrderEntry
                If Not String.IsNullOrEmpty(sIdOrderEntry) Then
                    '
                    ' Cancello eventuali filtri presenti
                    '
                    FilterHelper.Clear(DirectCast(panelFiltri, Control))
                    FilterHelper.EmptyControlsValue(DirectCast(panelFiltri, Control))
                    trRicercaByIdOrderEntry.Visible = True
                    lblMsgRicercaByIdOrderEntry.Text = "Ricerca per Numero Ordine OrderEntry=" & sIdOrderEntry
                    '
                    ' Imposto textbox
                    '
                    txtFiltroJobName.Text = sIdOrderEntry & ";"
                    FilterHelper.SaveInSession(DirectCast(panelFiltri, Control))
                End If
            Else
                trRicercaByIdOrderEntry.Visible = Not String.IsNullOrEmpty(UtilHelper.IdOrderEntry)
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante il caricamento della pagina."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante Page_Load().")
            Utility.GestisciErroriApplicationInsights(ex, "Page_Load")

        End Try

        ' Render per bootstrap
        ' Crea la TABLE con Theader e Tbody
        '
        UiJobQueueListGridView.UseAccessibleHeader = True
        '
        ' Converte i tag html generati dalla GridView per la paginazione
        '   e li adatta alle necessita dei CSS Bootstrap
        '
        UiJobQueueListGridView.PagerStyle.CssClass = "pagination-gridview"
        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)

        ' Load data
        ' Se il ViewState della GridView è attivo lo faccio solo se non è un PostBack
        ' Query iniziale dei dati della griglia
        '
        If Not IsPostBack Then
            UiJobQueueListGridView.DataBind()
        End If

    End Sub

    Protected Sub btnCerca_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnCerca.Click
        Try
            '
            ' L'utente ha agito sul pannello di ricerca: cancello IdOrderEntry dalla sessione
            '
            UtilHelper.IdOrderEntry = Nothing
            trRicercaByIdOrderEntry.Visible = False
            '
            '
            '
            FilterHelper.SaveInSession(DirectCast(panelFiltri, Control))
            UiJobQueueListGridView.DataBind()
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante la ricerca dei dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante btnCerca_Click().")
            Utility.GestisciErroriApplicationInsights(ex, "btnCerca_Click")

        End Try
    End Sub

    Private Sub btnFiltroOff_ServerClick(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnFiltroOff.Click
        Try
            '
            ' L'utente ha agito sul pannello di ricerca: cancello IdOrderEntry dalla sessione
            '
            UtilHelper.IdOrderEntry = Nothing
            trRicercaByIdOrderEntry.Visible = False
            '
            '
            '
            FilterHelper.Clear(DirectCast(panelFiltri, Control))
            FilterHelper.EmptyControlsValue(DirectCast(panelFiltri, Control))
            UiJobQueueListGridView.DataBind()
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante la cancellazione dei filtri."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante btnFiltroOff_ServerClick().")
            Utility.GestisciErroriApplicationInsights(ex, "btnFiltroOff_ServerClick")

        End Try
    End Sub

    Protected Sub SelectAllItems(ByVal sender As Object, ByVal e As EventArgs)
        Dim c As CheckBox
        Try
            For Each row As GridViewRow In UiJobQueueListGridView.Rows
                c = DirectCast(row.FindControl("chkSelectRow"), CheckBox)
                c.Checked = DirectCast(sender, CheckBox).Checked
            Next
            DisplayMassiveCommand(sender, e)
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante la selezione di tutti gli item della lista."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante SelectAllItems().")
            Utility.GestisciErroriApplicationInsights(ex, "SelectAllItems")

        End Try

    End Sub

    Protected Sub DisplayMassiveCommand(ByVal sender As Object, ByVal e As EventArgs)
        Dim c As CheckBox

        For Each row As GridViewRow In UiJobQueueListGridView.Rows
            c = DirectCast(row.FindControl("chkSelectRow"), CheckBox)

            If c.Checked Then
                MassiveCommandEnabled(True)
                Exit Sub
            End If
        Next
        MassiveCommandEnabled(False)
    End Sub

    Protected Sub btnMassiveRePrint_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnMassiveRePrint.Click
        Try
            For Each item As Selection In FindSelection(MassiveOperation.RePrint)
                RePrint(item.Id, item.Ts)
            Next
            UiJobQueueListGridView.DataBind()
            MassiveCommandEnabled(False)
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante l'operazione di ri-invio delle stampe."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante btnMassiveRePrint_Click().")
            Utility.GestisciErroriApplicationInsights(ex, "btnMassiveRePrint_Click")

        End Try
    End Sub

    Private Sub MassiveCommandEnabled(ByVal enabled As Boolean)

        btnMassiveRePrint.Visible = True
        btnMassiveRePrint.Enabled = enabled

        'Modifica 28/04/2020 Leo: disabilito il linkbutton
        If Not enabled Then
            btnMassiveRePrint.Attributes("disabled") = "disabled"
        Else
            btnMassiveRePrint.Attributes.Remove("disabled")
        End If

    End Sub

    Private Function RePrint(ByVal id As Guid, ByVal Ts As Byte()) As Boolean
        Try
            'Using ta As New DataAccess.JobQueueDataSetTableAdapters.QueriesTableAdapter()
            '    ta.UiJobQueueUpdate(id, Ts, True, My.User.Name)
            'End Using
            Return UtilHelper.RePrint(id, Ts)
        Catch ex As Exception
            My.Log.WriteException(ex, TraceEventType.Error, UtilHelper.GetInnerException(ex.InnerException, _className))
            _errorMessageArea.Visible = True
            _errorMessageArea.Text = UtilHelper.GetErrorMessage(UtilHelper.TypeError.RiinvioStampa)

            Utility.GestisciErroriApplicationInsights(ex, "RePrint")

            Return False
        End Try
    End Function

    Private Class Selection
        Public Id As Guid 'id della coda
        Public Ts As Byte() ' timestampa

        Public Sub New(ByVal Id As Guid, ByVal Ts As Byte())
            Me.Id = Id
            Me.Ts = Ts
        End Sub

    End Class

    Private Function FindSelection(ByVal operation As MassiveOperation) As List(Of Selection)
        'DataKeyNames="Id,PrintJobDateCompleted,PrintJobDateCompleted,InHistory,PrintJobError,Ts"
        Dim list As New List(Of Selection)
        Dim id As Guid
        Dim InHistory As Boolean
        Dim InError As Boolean
        Dim IsPrintJobDateCompleted As Boolean
        Dim oCheckBox As CheckBox
        Dim Ts As Byte() = Nothing

        For Each row As GridViewRow In UiJobQueueListGridView.Rows
            id = New Guid(UiJobQueueListGridView.DataKeys(row.RowIndex).Item(0).ToString())
            '
            ' Se la data è valorizzata allora il job è stato STAMPATO
            '
            IsPrintJobDateCompleted = CType(If(TypeOf (UiJobQueueListGridView.DataKeys(row.RowIndex).Item(2)) Is DBNull, False, True), Boolean)
            InHistory = CType(UiJobQueueListGridView.DataKeys(row.RowIndex).Item(3), Boolean)
            InError = CType(If(TypeOf (UiJobQueueListGridView.DataKeys(row.RowIndex).Item(4)) Is DBNull, False, True), Boolean)
            Ts = CType(UiJobQueueListGridView.DataKeys(row.RowIndex).Item(5), Byte())

            oCheckBox = DirectCast(row.FindControl("chkSelectRow"), CheckBox)
            '
            ' O stampata o errore: posso ritentare la stampa se il record non è nella history
            '
            If Not InHistory Then   ' se non è nella history
                If oCheckBox.Checked Then ' se selezionato il job
                    If IsPrintJobDateCompleted Then ' se è già stato STAMPATO
                        If operation = MassiveOperation.RePrint Then ' se è una ristampa
                            list.Add(New Selection(id, Ts))
                        End If
                    End If
                End If
            End If

        Next
        '
        ' Return
        '
        Return list

    End Function

    Protected Sub UiJobQueueListGridView_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles UiJobQueueListGridView.RowDataBound
        Try
            Dim gv As GridView = DirectCast(sender, GridView)
            '
            ' Sort style
            '
            If (gv.SortExpression.Length > 0) Then
                Dim cellIndex As Integer = -1
                For Each field As DataControlField In gv.Columns
                    If (field.SortExpression = gv.SortExpression) Then
                        cellIndex = gv.Columns.IndexOf(field)
                        Exit For
                    End If
                Next

                If (cellIndex > -1) Then
                    If e.Row.RowType = DataControlRowType.Header Then
                        e.Row.Cells(cellIndex).CssClass += If(gv.SortDirection = SortDirection.Ascending, "sortascheader", "sortdescheader")
                    ElseIf e.Row.RowType = DataControlRowType.DataRow Then
                        e.Row.Cells(cellIndex).CssClass += If(e.Row.RowIndex Mod 2 = 0, "sortaltrow", "sortrow")
                    End If
                End If
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante il caricamento di una riga della lista."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante UiJobQueueListGridView_RowDataBound().")
            Utility.GestisciErroriApplicationInsights(ex, "UiJobQueueListGridView_RowDataBound")

        End Try

    End Sub

    Protected Sub UiJobQueueListObjectDataSource_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles UiJobQueueListObjectDataSource.Selecting
        Try
            '
            ' Compongo i dati come per un utente amministratore
            '
            e.InputParameters("UserAccount") = If(String.IsNullOrEmpty(txtFiltroUserAccount.Text), Nothing, txtFiltroUserAccount.Text)
            e.InputParameters("UserSubmitter") = If(String.IsNullOrEmpty(txtFiltroUserSubmitter.Text), Nothing, txtFiltroUserSubmitter.Text)

            If String.IsNullOrEmpty(ddlFiltroStoricizzati.SelectedItem.Value) Then
                e.InputParameters("InHistory") = Nothing
            Else
                e.InputParameters("InHistory") = CType(ddlFiltroStoricizzati.SelectedValue, Boolean)
            End If

            e.InputParameters("JobName") = If(String.IsNullOrEmpty(txtFiltroJobName.Text), Nothing, txtFiltroJobName.Text)
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante il caricamento dei dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante UiJobQueueListObjectDataSource_Selecting().")
            Utility.GestisciErroriApplicationInsights(ex, "UiJobQueueListObjectDataSource_Selecting")

        End Try

    End Sub

    Protected Sub UiJobQueueListObjectDataSource_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles UiJobQueueListObjectDataSource.Selected
        Try
            If Not e.Exception Is Nothing Then
                My.Log.WriteException(e.Exception, TraceEventType.Error, UtilHelper.GetInnerException(e.Exception.InnerException, _className))
                _errorMessageArea.Visible = True
                _errorMessageArea.Text = UtilHelper.GetErrorMessage(UtilHelper.TypeError.CaricamentoDati)
                e.ExceptionHandled = True
            End If
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante il caricamento dei dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante UiJobQueueListObjectDataSource_Selected().")
            Utility.GestisciErroriApplicationInsights(ex, "UiJobQueueListObjectDataSource_Selected")

        End Try
    End Sub

    Protected Sub UiJobQueueListGridView_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles UiJobQueueListGridView.PageIndexChanging
        Try
            MassiveCommandEnabled(False)
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante la paginazione."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante UiJobQueueListGridView_PageIndexChanging().")
            Utility.GestisciErroriApplicationInsights(ex, "UiJobQueueListGridView_PageIndexChanging")

        End Try

    End Sub

    Protected Sub UiJobQueueListGridView_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles UiJobQueueListGridView.Sorting
        Try
            MassiveCommandEnabled(False)
        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante l'ordinamento."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante UiJobQueueListGridView_Sorting().")
            Utility.GestisciErroriApplicationInsights(ex, "UiJobQueueListGridView_Sorting")

        End Try

    End Sub

    Protected Function CheckBoxSelectionVisible(ByVal printJobInHistory As Object, ByVal printJobDateCompleted As Object) As Boolean
        '
        ' La visibilità del singolo checkbox deriva dallo stato del job di stampa
        '
        If DirectCast(printJobInHistory, Boolean) = True Then
            Return False
        End If
        'If Not TypeOf (printJobDateCompleted) Is DBNull Then
        '    Return False
        'End If
        'If CType(deletePrinting, Boolean) Then
        '    Return False
        'End If
        Return True
    End Function

    Protected Function GetEditItemImageUrl(ByVal printJobInHistory As Object) As String
        If DirectCast(printJobInHistory, Boolean) = True Then
            Return "<i class='fas fa-heading fa-lg text-muted'></i>"
        Else
            Return "<i class='fas fa-eye fa-lg'></i>"
        End If
    End Function

    Protected Function GetEditItemNavigateUrl(ByVal printJobId As Object) As String
        Dim sUrl As String = Me.ResolveUrl("~/JobQueueDetail.aspx")
        Return sUrl & "?Id=" & DirectCast(printJobId, Guid).ToString
    End Function

    Private Sub UiJobQueueListGridView_PreRender(sender As Object, e As EventArgs) Handles UiJobQueueListGridView.PreRender
        If UiJobQueueListGridView.HeaderRow IsNot Nothing Then
            UiJobQueueListGridView.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
    End Sub

End Class