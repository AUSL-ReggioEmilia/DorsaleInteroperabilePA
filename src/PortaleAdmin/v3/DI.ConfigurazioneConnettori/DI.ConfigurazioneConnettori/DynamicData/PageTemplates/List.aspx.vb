Imports System.IO
Imports System.Web.Routing
Imports System.Web.UI.WebControls.Expressions

Class List
    Inherits Page

    Protected table As MetaTable
    Protected ListOfEntity As IList
    Protected bEsportaExcel As Boolean = False

    Private Sub Page_Init(sender As Object, e As EventArgs) Handles Me.Init
        Try
            table = DynamicDataRouteHandler.GetRequestMetaTable(Context)
            GridView1.SetMetaTable(table, table.GetColumnValuesFromRoute(Context))
            GridDataSource.EntityTypeName = table.EntityType.AssemblyQualifiedName
            If table.EntityType <> table.RootEntityType Then
                GridQueryExtender.Expressions.Add(New OfTypeExpression(table.EntityType))
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Master.ShowAlert(sErrorMessage)
        End Try
    End Sub


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
        Try

            Title = table.DisplayName


            '
            'CONTROLLO ACCESSO -> PRESENZA ATTRIBUTO RuoloAccesso
            '
            Dim attrRuoloAccesso As RuoloAccesso =
                CType(Attribute.GetCustomAttribute(table.RootEntityType, GetType(RuoloAccesso)), RuoloAccesso)

            If Not RuoloAccessoManager.IsInRole(attrRuoloAccesso) Then

                Throw New AccessViolationException("L'utente non ha accesso alla pagina!")

            End If


            '
            'CONTROLLO PRESENZA ATTRIBUTO ExcelImport
            '
            Dim attrExcelImport = Attribute.GetCustomAttribute(table.RootEntityType, GetType(ExcelImport))
            If attrExcelImport Is Nothing Then
                butImportaExcelTop.Visible = False
                butImportaExcelDown.Visible = False
            End If

            ' Disable various options if the table is readonly
            If table.IsReadOnly Then
                GridView1.Columns(0).Visible = False
                btnAggiungiTop.Visible = False
                btnAggiungiDown.Visible = False
                GridView1.EnablePersistedSelection = False
                butImportaExcelTop.Visible = False
                butImportaExcelDown.Visible = False
                'Nascondo il pulsante di cancellazione
                GridView1.Columns(GridView1.Columns.Count - 1).Visible = False
            End If

            '
            '  Nascondo la colonna con il pulsante per l'importazione LHA-CUP
            '
            Dim attrImport = Attribute.GetCustomAttribute(table.RootEntityType, GetType(OeConnCupWizardAgende))
            If attrImport Is Nothing Then
                GridView1.Columns(1).Visible = False
            End If


            'Implementiamo l’importazione Excel solo per le tabelle relative a GST, CUP e ARTEXE.

            '
            ' RENDERING PER BOOTSTRAP
            ' Converte i tag html generati dalla GridView per la paginazione
            ' e li adatta alle necessita dei CSS Bootstrap
            '
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Master.ShowAlert(sErrorMessage)
        End Try
    End Sub

    Protected Sub Label_PreRender(ByVal sender As Object, ByVal e As EventArgs)
        Try
            Dim label = CType(sender, Label)
            Dim dynamicFilter = CType(label.FindControl("DynamicFilter"), DynamicFilter)
            Dim fuc = CType(dynamicFilter.FilterTemplate, QueryableFilterUserControl)
            If fuc IsNot Nothing AndAlso fuc.FilterControl IsNot Nothing Then
                label.AssociatedControlID = fuc.FilterControl.GetUniqueIDRelativeTo(label)
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Master.ShowAlert(sErrorMessage)
        End Try
    End Sub

    Protected Overrides Sub OnPreRenderComplete(ByVal e As EventArgs)
        Try
            Dim routeValues As New RouteValueDictionary(GridView1.GetDefaultValues)
            btnAggiungiTop.NavigateUrl = table.GetActionPath(PageAction.Insert, routeValues)
            btnAggiungiDown.NavigateUrl = btnAggiungiTop.NavigateUrl
            MyBase.OnPreRenderComplete(e)
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Master.ShowAlert(sErrorMessage)
        End Try
    End Sub

    Protected Sub DynamicFilter_FilterChanged(ByVal sender As Object, ByVal e As EventArgs)
        GridView1.PageIndex = 0
    End Sub

    Private Sub GridView1_PreRender(sender As Object, e As EventArgs) Handles GridView1.PreRender
        Try
            '
            ' Render per Bootstrap
            ' Crea la Table con Theader e Tbody se l'header non è nothing.
            '
            If Not GridView1.HeaderRow Is Nothing Then
                GridView1.UseAccessibleHeader = True
                GridView1.HeaderRow.TableSection = TableRowSection.TableHeader
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Master.ShowAlert(sErrorMessage)
        End Try
    End Sub

    Private Sub FilterRepeater_PreRender(sender As Object, e As EventArgs) Handles FilterRepeater.PreRender
        Try
            '
            ' Nascondo il panel booststrap definito nel markup nel caso in cui non ci siano Controls nel FilterRepeater
            '
            Dim controlsNumber As Integer = FilterRepeater.Controls.Count
            If controlsNumber <= 0 Then
                filterRow.Visible = False
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Master.ShowAlert(sErrorMessage)
        End Try
    End Sub

    Private Sub GridView1_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles GridView1.RowDataBound
        Try

            '
            ' Rimuovo la colonna che ha come proprietà ShortName dell'attributo DisplayName = "[HIDE]" 
            '

            Dim displayAttr As DisplayAttribute = CType(Attribute.GetCustomAttribute(table.RootEntityType, GetType(DisplayAttribute)), DisplayAttribute)
            ' Ottengo le colonne da rimuovere
            Dim columnsToHide As List(Of MetaColumn) = table.Columns.Where(Function(x) x.ShortDisplayName = "[HIDE]").ToList()

            For Each column As MetaColumn In columnsToHide

                If e.Row.RowType = DataControlRowType.Header Then
                    ' Rimuovo l'header della colonna
                    ' Cerco la posizione in cui si trova la colonna
                    Dim columnIndex As Integer = 0
                    For Each cell As DataControlFieldHeaderCell In e.Row.Cells
                        If cell.ContainingField.HeaderText = column.ShortDisplayName Then
                            Exit For
                        End If
                        columnIndex += 1
                    Next
                    ' Rimuovo la cella individuata
                    e.Row.Cells.RemoveAt(columnIndex)

                ElseIf e.Row.RowType = DataControlRowType.DataRow Then
                    ' Rimuovo la le celle della colonna
                    ' Cerco la posizione in cui si trova la colonna
                    Dim columnIndex As Integer = 0
                    For Each cell As DataControlFieldCell In e.Row.Cells
                        If cell.ContainingField.HeaderText = column.ShortDisplayName Then
                            Exit For
                        End If
                        columnIndex += 1
                    Next
                    ' Rimuovo la cella individuata
                    e.Row.Cells.RemoveAt(columnIndex)
                End If
            Next


            If bEsportaExcel Then
                'in esportazione verso excel rimuovo le prime due colonne con i pulsanti
                e.Row.Cells.RemoveAt(0)
                e.Row.Cells.RemoveAt(0)
                For Each cell As TableCell In e.Row.Cells
                    cell.CssClass = "textmode"
                Next
            Else
                '
                ' ATTENZIONE: Non è possibile farlo dal Markup a causa dei DynamicControl.
                ' Sposta il bottone di cancellazione nell'ultima colonna. 
                '
                If e.Row.RowType = DataControlRowType.DataRow OrElse e.Row.RowType = DataControlRowType.Header Then
                    '
                    ' 2 è l'indice della colonna con il tasto elimina. (abbiamo aggiunto pulsante per Importazione diff LHA-CUP)
                    '
                    Dim GridViewCell As TableCell = e.Row.Cells(2)
                    e.Row.Cells.RemoveAt(2)
                    e.Row.Cells.Add(GridViewCell)
                End If
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Master.ShowAlert(sErrorMessage)
        End Try
    End Sub

    Public Overrides Sub VerifyRenderingInServerForm(control As Control)
        ' Verifies that the control is rendered
        ' NON RIMUOVERE QUESTO EVENT HANDLER
    End Sub

    Private Sub EsportaExcel_Click(sender As Object, e As EventArgs) Handles btnEsportaExcelTop.Click, btnEsportaExcelDown.Click
        Try
            bEsportaExcel = True
            GridView1.AllowPaging = False
            GridView1.DataBind()
            bEsportaExcel = False
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Master.ShowAlert(sErrorMessage)
        End Try
    End Sub


    Private Sub GridDataSource_Selected(sender As Object, e As LinqDataSourceStatusEventArgs) Handles GridDataSource.Selected
        Try
            If Not Me.Master.ShowAlertIfError(e) Then
                ListOfEntity = TryCast(e.Result, IList)

                '
                ' SE È STATO CLICCATO IL PULSANTE ESPORTA IN EXCEL
                '
                If bEsportaExcel Then
                    If ListOfEntity Is Nothing OrElse ListOfEntity.Count = 0 Then
                        bEsportaExcel = False
                        Master.ShowAlert("Nessun dato da esportare.")
                    Else
                        Using str As MemoryStream = Excel.AnyListToExcel(ListOfEntity, table.Name)
                            If str IsNot Nothing Then
                                Response.Clear()
                                Response.Buffer = True
                                Response.AddHeader("content-disposition", "attachment;filename=" & table.Name & ".xlsx")
                                'Response.Charset = ""
                                Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                                '	Response.AddHeader("Content-Type", "application/vnd.openxmlformats")
                                str.WriteTo(Response.OutputStream)
                                Response.Flush()
                                Response.[End]()
                            End If
                        End Using
                    End If
                End If
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Master.ShowAlert(sErrorMessage)
        End Try
    End Sub

    Private Sub GridDataSource_Deleted(sender As Object, e As LinqDataSourceStatusEventArgs) Handles GridDataSource.Deleted
        Try

            If e.Exception Is Nothing Then

                '
                ' SimoneB 16-11-2016
                ' Faccio un redirect alla pagina corrente per refreshare anche i filtri (facendo un dataBind() di FilterRepeater non funziona)
                '
                Response.Redirect(HttpContext.Current.Request.Url.PathAndQuery, True)
            Else

                Dim sErrorMessage As String = GestioneErrori.TrapError(e.Exception)
                Master.ShowAlert(sErrorMessage)
                e.ExceptionHandled = True

            End If

        Catch ex As Threading.ThreadAbortException
            ' Non faccio nulla
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Master.ShowAlert(sErrorMessage)
        End Try
    End Sub

    Private Sub GridView1_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles GridView1.RowCommand
        Try
            '
            ' SE SI PREME COPIA SALVO IN SESSION LA RIGA CORRENTE, VERRÀ POI LETTA DALLA PAGINA DI INSERT
            '
            If e.CommandName.ToUpper = "COPIA" Then
                Dim iRowIndex = CInt(e.CommandArgument)
                If ListOfEntity.Count > iRowIndex Then
                    Session(Utility.CURRENT_ROW) = ListOfEntity(iRowIndex)
                End If
                Response.Redirect(table.GetActionPath("Insert") & "?Copy=1")

            ElseIf e.CommandName.ToUpper = "OECONCUPWIZARDAGENDE" Then
                Dim iRowIndex = CInt(e.CommandArgument)

                Dim sCodiceAgendaCup As String = String.Empty
                If ListOfEntity.Count > iRowIndex Then

                    Dim olist = ListOfEntity(iRowIndex)

                    'Prelevo l'id della Agenda
                    If TypeOf olist Is DiffAgendeCup Then

                        Dim oData As DiffAgendeCup = Nothing
                        oData = CType(olist, DiffAgendeCup)

                        sCodiceAgendaCup = oData.CodiceAgendaCup

                        'Vado alla pagina di importazione AgendePrestazioni
                        Response.Redirect(String.Format("~/OeConnCup/WizardAgende/Step1.Aspx?CodiceAgendaCup={0}&ListaOrigine=OeConnCup-AgendeCupDaConfigurare", sCodiceAgendaCup), False)

                    ElseIf TypeOf olist Is DiffAgendeEsistentiPrestazioniMancanti Then

                        Dim oData As DiffAgendeEsistentiPrestazioniMancanti = Nothing
                        oData = CType(olist, DiffAgendeEsistentiPrestazioniMancanti)

                        sCodiceAgendaCup = oData.CodiceAgendaCup

                        'Vado alla pagina di importazione AgendePrestazioni
                        Response.Redirect(String.Format("~/OeConnCup/WizardAgende/Step1.Aspx?CodiceAgendaCup={0}&ListaOrigine=OeConnCup-AgendeEsistentiPrestazioniMancanti", sCodiceAgendaCup), False)

                    End If

                End If
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Master.ShowAlert(sErrorMessage)
        End Try
    End Sub

End Class
