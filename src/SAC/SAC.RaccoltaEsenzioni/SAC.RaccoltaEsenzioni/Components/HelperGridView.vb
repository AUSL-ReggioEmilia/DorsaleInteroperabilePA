Public Class HelperGridView

    Public Shared Function GetScriptPaginationForBootstrap() As String
        '
        ' Lo script converte i tag html generati dalla GridView per la paginazione
        '   e li adatta alle necessita dei CSS Bootstrap
        '
        ' Aggiungere alla GridView la classe 'pagination-gridview' nel PagerStyle
        ' PagerStyle-CssClass="pagination-gridview"
        '
        Dim sbScript As New StringBuilder

        sbScript.AppendLine("$('.pagination-gridview td table').each(function (index, obj) {")
        sbScript.AppendLine("       convertToPagination(obj)")
        sbScript.AppendLine("       });")
        sbScript.AppendLine("")
        sbScript.AppendLine("function convertToPagination(obj) {")
        sbScript.AppendLine("   var liststring = '<ul class=""pagination"">';")
        sbScript.AppendLine("   $(obj).find(""tbody tr"").each(function () {")
        sbScript.AppendLine("       $(this).children().map(function () {")
        sbScript.AppendLine("           liststring = liststring + ""<li>"" + $(this).html() + ""</li>"";")
        sbScript.AppendLine("       });")
        sbScript.AppendLine("   });")
        sbScript.AppendLine("   liststring = liststring + ""</ul>"";")
        sbScript.AppendLine("   var list = $(liststring);")
        sbScript.AppendLine("   list.find('span').parent().addClass('active');")
        sbScript.AppendLine("")
        sbScript.AppendLine("   $(obj).replaceWith(list);")
        sbScript.AppendLine("}")

        Return sbScript.ToString

    End Function

    ''' <summary>
    ''' Aggiunge allo header della colonna l'icona che indica il verso di ordinamento
    ''' </summary>
    Public Shared Sub AddHeaderSortingIcon(sender As Object, e As GridViewRowEventArgs, SortExpression As String, SortDirection As SortDirection?)
        If (e.Row.RowType = DataControlRowType.Header) Then
            If Not String.IsNullOrEmpty(SortExpression) Then
                Dim gridView = CType(sender, GridView)
                For Each col As DataControlField In gridView.Columns
                    If col.SortExpression = SortExpression Then
                        Dim iColIndex = gridView.Columns.IndexOf(col)
                        Dim span As New HtmlGenericControl
                        If SortDirection.Value = WebControls.SortDirection.Ascending Then
                            span.InnerHtml = "&nbsp;<span class='glyphicon glyphicon-sort-by-attributes' aria-hidden='True' title='Ordine Crescente'></span>"
                        Else
                            span.InnerHtml = "&nbsp;<span class='glyphicon glyphicon-sort-by-attributes-alt' aria-hidden='True' title='Ordine Descrescente'></span>"
                        End If
                        e.Row.Cells(iColIndex).Controls.Add(span)
                        Exit For
                    End If
                Next
            End If
        End If
    End Sub

    ''' <summary>
    ''' Metodo che si occupa di renderizzare le grid view in stile bootstrap
    ''' </summary>
    ''' <param name="gridView"></param>
    ''' <param name="page"></param>
    Public Shared Sub SetUpGridView(gridView As GridView, page As Page)
        'Render per Bootstrap
        'Crea la Table con Theader e Tbody se l'header non è nothing.
        If Not gridView.HeaderRow Is Nothing Then
            gridView.UseAccessibleHeader = True
            gridView.HeaderRow.TableSection = TableRowSection.TableHeader
        End If

        'Converte i tag html generati dalla GridView per la paginazione
        ' e li adatta alle necessita dei CSS Bootstrap
        gridView.PagerStyle.CssClass = "pagination-gridview"
        ScriptManager.RegisterStartupScript(page, page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)
    End Sub

End Class
