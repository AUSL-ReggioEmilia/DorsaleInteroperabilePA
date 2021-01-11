Imports System.Web.DynamicData

Partial Class EmailAddress
    Inherits System.Web.DynamicData.FieldTemplateUserControl


    Protected Overrides Sub OnDataBinding(e As EventArgs)
        Dim url As String = FieldValueString
        If Not url.StartsWith("mailto:", StringComparison.OrdinalIgnoreCase) Then
            url = Convert.ToString("mailto:") & url
        End If
        HyperLink1.NavigateUrl = url
    End Sub

    Public Overrides ReadOnly Property DataControl() As Control
        Get
            Return HyperLink1
        End Get
    End Property

End Class
