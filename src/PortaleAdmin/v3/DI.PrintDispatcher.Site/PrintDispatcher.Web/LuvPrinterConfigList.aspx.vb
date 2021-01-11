Partial Public Class LuvPrinterConfigList
    Inherits System.Web.UI.Page
    '
    ' Usata per non fare eseguire le operazioni di select alla/e data source in caso di errori precedenti
    '
    Private _CancelDataSorceSelectOperation As Boolean = False

    Private _className As String = System.Reflection.MethodBase.GetCurrentMethod().ReflectedType.Name
    Private _errorMessageArea As Label = Nothing

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            _CancelDataSorceSelectOperation = False
            '
            ' Error message area
            '
            _errorMessageArea = DirectCast(Me.Master.FindControl("ErrorMessageArea"), Label)

            If Not Page.IsPostBack Then
                Call LoadComboServerVirtuali()
                Call LoadComboTipiStampanti()
                '
                ' Restore dei filtri
                '
                FilterHelper.Restore(DirectCast(pannelloFiltri, Control))
            End If

        Catch ex As Exception
            _CancelDataSorceSelectOperation = True
            _errorMessageArea.Text = "Errore durante il caricamento della pagina."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante Page_Load().")
            Utility.GestisciErroriApplicationInsights(ex, "Page_Load")
        End Try
    End Sub

    Protected Sub btnRicerca_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnRicerca.Click
        Try
            FilterHelper.SaveInSession(DirectCast(pannelloFiltri, Control))
            MainListGridView.DataBind()

        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante la ricerca dei dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante btnRicerca_Click().")
            Utility.GestisciErroriApplicationInsights(ex, "btnRicerca_Click")
        End Try
    End Sub

    Private Sub btnFiltroOff_ServerClick(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnFiltroOff.ServerClick
        Try
            FilterHelper.Clear(DirectCast(pannelloFiltri, Control))
            FilterHelper.EmptyControlsValue(DirectCast(pannelloFiltri, Control))
            MainListGridView.DataBind()

        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante la cancellazione dei filtri."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante btnFiltroOff_ServerClick().")
            Utility.GestisciErroriApplicationInsights(ex, "btnFiltroOff_ServerClick")
        End Try
    End Sub

#Region "GridView"

    Protected Sub MainListGridView_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles MainListGridView.RowDataBound
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
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainListGridView_RowDataBound().")

        End Try

    End Sub

    'Protected Sub MainListGridView_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles MainListGridView.PageIndexChanging
    '    Try

    '    Catch ex As Exception
    '        _errorMessageArea.Text = "Errore durante la paginazione."
    '        My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainListGridView_PageIndexChanging().")
    '    End Try
    'End Sub
    'Protected Sub MainListGridView_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles MainListGridView.Sorting
    '    Try

    '    Catch ex As Exception
    '        _errorMessageArea.Text = "Errore durante l'ordinamento."
    '        My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainListGridView_Sorting().")
    '    End Try
    'End Sub

#End Region

#Region "MainListDataSource"

    Protected Sub MainListDataSource_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles MainListDataSource.Selecting
        Try
            If _CancelDataSorceSelectOperation Then
                e.Cancel = True
            Else
                '
                ' passo i parametri di filtro alla stored procedure
                '
                e.InputParameters("Periferica") = If(String.IsNullOrEmpty(txtPeriferica.Text), Nothing, txtPeriferica.Text)
                e.InputParameters("ServerDiStampa") = If(String.IsNullOrEmpty(txtServerDiStampa.Text), Nothing, txtServerDiStampa.Text)
                e.InputParameters("Stampante") = If(String.IsNullOrEmpty(txtStampante.Text), Nothing, txtStampante.Text)

                If ddlServerVirtuali.Items.Count > 0 Then
                    Dim sValue As String = ddlServerVirtuali.SelectedItem.Value
                    If String.IsNullOrEmpty(sValue) Then sValue = Nothing
                    e.InputParameters("ServerVirtuale") = sValue
                Else
                    e.InputParameters("ServerVirtuale") = Nothing
                End If

                If ddlTipiStampante.Items.Count > 0 Then
                    Dim sValue As String = ddlTipiStampante.SelectedItem.Value
                    If String.IsNullOrEmpty(sValue) Then sValue = Nothing
                    e.InputParameters("IdTipiStampante") = sValue
                Else
                    e.InputParameters("IdTipiStampante") = Nothing
                End If

            End If

        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante il caricamento dei dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainListDataSource_Selecting().")

        End Try


    End Sub

    Protected Sub MainListDataSource_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles MainListDataSource.Selected
        Try
            If Not e.Exception Is Nothing Then
                My.Log.WriteException(e.Exception, TraceEventType.Error, UtilHelper.GetInnerException(e.Exception.InnerException, _className))
                _errorMessageArea.Visible = True
                _errorMessageArea.Text = UtilHelper.GetErrorMessage(UtilHelper.TypeError.CaricamentoDati)
                e.ExceptionHandled = True
            End If

        Catch ex As Exception
            _errorMessageArea.Text = "Errore durante il caricamento dei dati."
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante MainListDataSource_Selected().")

        End Try
    End Sub

#End Region

#Region "Caricamento dropdownlist"
    Private Sub LoadComboServerVirtuali()
        '
        ' Carico la lista dei server virtuali
        '
        Using oTa As New DataAccess.LuvPrinterConfigDatasetTableAdapters.LuvPrinterConfigServerVirtualiComboTableAdapter
            Dim dt As DataAccess.LuvPrinterConfigDataset.LuvPrinterConfigServerVirtualiComboDataTable = oTa.GetData()
            ddlServerVirtuali.DataTextField = "Nome"
            ddlServerVirtuali.DataValueField = "Nome"
            ddlServerVirtuali.DataSource = dt
            ddlServerVirtuali.DataBind()
            '
            ' Aggiungo item Value="" Text="<Tutti>" all'inizio della lista
            '
            Dim oItem As New System.Web.UI.WebControls.ListItem("<Tutti>", "")
            ddlServerVirtuali.Items.Insert(0, oItem)

            ''
            '' Aggiungo item vuoto all'inizio della lista, solo se manca
            ''
            'Dim oItem As System.Web.UI.WebControls.ListItem
            'oItem = ddlServerVirtuali.Items.FindByValue("")
            'If oItem Is Nothing Then
            '    oItem = New System.Web.UI.WebControls.ListItem("", "")
            '    ddlServerVirtuali.Items.Insert(0, oItem)
            'End If
        End Using
    End Sub

    ''' <summary>
    ''' Carica la combo dei tipi di stampante
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub LoadComboTipiStampanti()
        Using oTa As New DataAccess.LuvPrinterConfigDatasetTableAdapters.TipiStampanteComboTableAdapter
            Dim dt As DataAccess.LuvPrinterConfigDataset.TipiStampanteComboDataTable = oTa.GetData()
            ddlTipiStampante.DataTextField = "Descrizione"
            ddlTipiStampante.DataValueField = "Id"
            ddlTipiStampante.DataSource = dt
            ddlTipiStampante.DataBind()
            '
            ' Aggiungo item Value="" Text="<Tutti>" all'inizio della lista
            '
            Dim oItem As New System.Web.UI.WebControls.ListItem("<Tutti>", "-1")
            ddlTipiStampante.Items.Insert(0, oItem)
        End Using

    End Sub

#End Region

#Region "Funzioni chiamate nel markup"

    Protected Function GetEditItemImageUrl() As String
        Return "~/Images/edititem.gif"
    End Function

    Protected Function GetEditItemNavigateUrl(ByVal Id As Object) As String
        Dim sUrl As String = Me.ResolveUrl("~/LuvPrinterConfigDetail.aspx")
        Return sUrl & "?Id=" & DirectCast(Id, Guid).ToString
    End Function

#End Region

End Class