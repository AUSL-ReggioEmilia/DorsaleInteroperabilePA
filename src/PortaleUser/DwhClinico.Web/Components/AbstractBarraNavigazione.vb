Imports Microsoft.VisualBasic

Public MustInherit Class AbstractBarraNavigazione
    Inherits System.Web.UI.UserControl

    Public MustOverride ReadOnly Property NavBarList() As Collections.ArrayList
    Public MustOverride Sub SetCurrentItem(ByVal Caption As String, ByVal NavigateURL As String)
    Public MustOverride Sub ClearAll()
End Class
