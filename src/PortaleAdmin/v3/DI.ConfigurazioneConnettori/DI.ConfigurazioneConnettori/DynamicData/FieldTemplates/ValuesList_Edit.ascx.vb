'
'  Questo controllo mostra una dropdown con la lista di valori possibili passati in questo modo:
'  <UIHint("ValuesList", Nothing, "ValueList", "Referto,Evento")>
'
Class ValuesList_EditField
	Inherits FieldTemplateUserControl


	Protected Sub Page_Load(sender As Object, e As EventArgs)
		SetUpValidator(RequiredFieldValidator1)

		If DropDownList1.Items.Count = 0 Then
			' add [Not Set] in insert mode as the field would
			' otherwise just take on the first value in the list
			' if the user clicks save without changing it.
			If Not Column.IsRequired OrElse Mode = DataBoundControlMode.Insert Then
				DropDownList1.Items.Add(New ListItem("[Non impostato]", ""))
			End If

			' fill the dropdown list with the 
			' values in the ValuesList attribute
			PopulateListControl(DropDownList1)
		End If
	End Sub

	''' <summary>
	''' Populates a list control with all the values from a parent table.
	''' </summary>
	''' <param name="listControl">The list control to populate.</param>
	Protected Shadows Sub PopulateListControl(listControl As ListControl)

		Dim uiHint = Column.GetAttribute(Of UIHintAttribute)()
		If uiHint Is Nothing OrElse uiHint.ControlParameters.Count = 0 OrElse Not uiHint.ControlParameters.Keys.Contains("ValueList") Then
			Throw New InvalidOperationException(String.Format("ValuesList for FieldTemplate {0} field is missing from UIHint", Column.Name))
		End If

		Dim valuesList = ValuesListAttribute(uiHint.ControlParameters("ValueList").ToString())
		If valuesList.Count() = 0 Then
			Throw New InvalidOperationException(String.Format("ValuesList for FieldTemplate {0} field, is empty", Column.Name))
		End If

		listControl.Items.AddRange(valuesList)
	End Sub

	Public Function ValuesListAttribute(values As String) As ListItem()
		Dim items = values.Split(New Char() {","c, ";"c})
		Dim listItems = (From item In items Select New ListItem() With {.Text = item, .Value = item}).ToArray()
		Return listItems
	End Function

	' added page init to hookup the event handler
	Protected Overrides Sub OnDataBinding(e As EventArgs)
		If Mode = DataBoundControlMode.Edit Then
			Dim item As ListItem = DropDownList1.Items.FindByValue(FieldValueString)
			If item IsNot Nothing Then
				DropDownList1.SelectedValue = FieldValueString
			End If
		End If

		If Mode = DataBoundControlMode.Insert Then
			DropDownList1.SelectedIndex = 0
		End If

		MyBase.OnDataBinding(e)
	End Sub

	''' <summary>
	''' Provides dictionary access to all data in the current row.
	''' </summary>
	''' <param name="dictionary">The dictionary that contains all the new values.</param>
	Protected Overrides Sub ExtractValues(dictionary As IOrderedDictionary)
		' If it's an empty string, change it to null
		Dim val As String = DropDownList1.SelectedValue
		If val = String.Empty Then
			val = Nothing
		End If

		dictionary(Column.Name) = ConvertEditedValue(val)
	End Sub

	Public Overrides ReadOnly Property DataControl() As Control
		Get
			Return DropDownList1
		End Get
	End Property


End Class
