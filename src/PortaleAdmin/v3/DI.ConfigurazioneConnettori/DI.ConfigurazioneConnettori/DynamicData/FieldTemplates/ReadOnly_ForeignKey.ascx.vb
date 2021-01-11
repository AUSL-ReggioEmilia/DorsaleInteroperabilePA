Imports System.ComponentModel.DataAnnotations
Imports System.Web.DynamicData
Imports System.Web

Class ReadOnlyForeignKeyField
    Inherits FieldTemplateUserControl

    Public Property NavigateUrl As String

    Public Property AllowNavigation As Boolean = True

    Public Overrides ReadOnly Property DataControl As Control
        Get
            Return textFk
        End Get
    End Property

    Protected Function GetDisplayString() As String
        Dim value As Object = FieldValue
        If (value Is Nothing) Then
            Return FormatFieldValue(ForeignKeyColumn.GetForeignKeyString(Row))
        Else
            Return FormatFieldValue(ForeignKeyColumn.ParentTable.GetDisplayString(value))
        End If
    End Function

End Class
