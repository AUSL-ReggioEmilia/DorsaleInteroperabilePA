Imports System.ComponentModel.DataAnnotations
Imports System.Web.DynamicData
Imports System.Web

Class Username_EditField
    Inherits FieldTemplateUserControl

    'Public Property NavigateUrl As String

    'Public Property AllowNavigation As Boolean = True

    Public Overrides ReadOnly Property DataControl As Control
        Get
            'Return DropDownList1
            Return HyperLink1
        End Get
    End Property

    Protected Function GetDisplayString() As String
        Dim value As Object = FieldValue
        If (value Is Nothing) Then
            Dim ddl As New DropDownList() ' = New ListControl()
            PopulateListControl(ddl)
            Dim selectedValueString As String = "1" 'GetSelectedValueString()
            Dim item As ListItem = ddl.Items.FindByValue(selectedValueString)
            Return item.Text
            'Return FormatFieldValue(ForeignKeyColumn.GetForeignKeyString(Row))
            'Return FormatFieldValue(ForeignKeyColumn.ParentTable.GetDisplayString(value))
        Else
            Return FormatFieldValue(ForeignKeyColumn.ParentTable.GetDisplayString(value))
        End If
    End Function

    'Protected Function GetNavigateUrl() As String
    '    If Not AllowNavigation Then
    '        Return Nothing
    '    End If
    '    If String.IsNullOrEmpty(NavigateUrl) Then
    '        Dim value As Object = FieldValue

    '        If ForeignKeyPath = String.Empty Then
    '            HyperLink1.Enabled = False
    '        End If
    '        Return ForeignKeyPath
    '    Else
    '        Return BuildForeignKeyPath(NavigateUrl)
    '    End If
    'End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)

    End Sub

    'Protected Overrides Sub OnDataBinding(ByVal e As EventArgs)
    '    MyBase.OnDataBinding(e)
    '    Dim selectedValueString As String = "1" 'GetSelectedValueString()
    '    Dim item As ListItem = DropDownList1.Items.FindByValue(selectedValueString)
    '    If item IsNot Nothing Then
    '        DropDownList1.SelectedValue = selectedValueString
    '    End If
    'End Sub

    'Protected Overrides Sub ExtractValues(ByVal dictionary As IOrderedDictionary)
    '    ' If it's an empty string, change it to null
    '    Dim value As String = DropDownList1.SelectedValue
    '    If String.IsNullOrEmpty(value) Then
    '        value = Nothing
    '    End If
    '    ExtractForeignKey(dictionary, value)
    'End Sub

End Class
