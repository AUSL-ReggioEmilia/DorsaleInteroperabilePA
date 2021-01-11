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

End Class