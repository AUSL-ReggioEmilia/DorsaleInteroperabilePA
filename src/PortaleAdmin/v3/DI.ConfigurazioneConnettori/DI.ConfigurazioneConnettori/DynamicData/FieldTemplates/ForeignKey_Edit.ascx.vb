Imports System.ComponentModel.DataAnnotations
Imports System.Web.DynamicData
Imports System.Web

Class ForeignKey_EditField
    Inherits FieldTemplateUserControl

    Public Overrides ReadOnly Property DataControl As Control
        Get
            Return DropDownList1
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)
        If (DropDownList1.Items.Count = 0) Then
            PopulateListControl(DropDownList1)


            If (Mode = DataBoundControlMode.Insert OrElse Not Column.IsRequired) _
                AndAlso DropDownList1.Items.FindByValue("") Is Nothing Then

                'DropDownList1.Items.Add(New ListItem("[Non impostato]", ""))
                'Se non c'è già un item con stringa vuota lo aggiungo con nome "[Non impostato]"
                DropDownList1.Items.Insert(0, New ListItem("[Non impostato]", ""))

            End If
        End If
        SetUpValidator(RequiredFieldValidator1)
        SetUpValidator(DynamicValidator1)
    End Sub

    Protected Overrides Sub OnDataBinding(ByVal e As EventArgs)
        MyBase.OnDataBinding(e)
        Dim selectedValueString As String = GetSelectedValueString()
        Dim item As ListItem = DropDownList1.Items.FindByValue(selectedValueString)
        If item IsNot Nothing Then
            DropDownList1.SelectedValue = selectedValueString
        End If
    End Sub

    Protected Overrides Sub ExtractValues(ByVal dictionary As IOrderedDictionary)

        Dim value As String = DropDownList1.SelectedValue

        ' 'If it's an empty string, change it to null
        '    If String.IsNullOrEmpty(value) Then
        '        value = Nothing
        '    End If

        'Modifica 2020-06-08 Leo: utilizzo ConvertEditedValue anzi che usare: If String.IsNullOrEmpty(value) Then value = Nothing
        'ConvertEditedValue si basa su l'attributo ConvertEmptyStringToNull
        value = CType(ConvertEditedValue(value), String)

        ExtractForeignKey(dictionary, value)
    End Sub

End Class
