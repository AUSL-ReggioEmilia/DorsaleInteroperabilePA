Imports System
Imports System.Web
Imports System.Web.UI

Module ResponseHelper
    <System.Runtime.CompilerServices.Extension>
    Public Sub Redirect(response As HttpResponse, url As String, target As String, windowFeatures As String)

        If ([String].IsNullOrEmpty(target) OrElse target.Equals("_self", StringComparison.OrdinalIgnoreCase)) AndAlso [String].IsNullOrEmpty(windowFeatures) Then
            response.Redirect(url, False)
        Else
            Dim page As Page = DirectCast(HttpContext.Current.Handler, Page)

            If page Is Nothing Then
                Throw New InvalidOperationException("Cannot redirect to new window outside Page context.")
            End If
            url = page.ResolveClientUrl(url)

            Dim script As String
            If Not [String].IsNullOrEmpty(windowFeatures) Then
                script = "window.open(""{0}"", ""{1}"", ""{2}"");"
            Else
                script = "window.open(""{0}"", ""{1}"");"
            End If
            script = [String].Format(script, url, target, windowFeatures)
            ScriptManager.RegisterStartupScript(page, GetType(Page), "Redirect", script, True)
        End If
    End Sub
End Module
