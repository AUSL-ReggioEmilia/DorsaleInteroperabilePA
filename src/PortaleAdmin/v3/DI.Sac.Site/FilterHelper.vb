Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web

' ULTIMA MODIFICA: 2015-11-26  V 1.1.1 


''' <summary>
''' CLASSE CHE IMPLEMENTA IL SALVATAGGIO DEL VALORE ATTUALMENTE PRESENTE NEI CONTROLLI:
''' TextBox, CheckBox, DropDownList, RadioButtonList
''' </summary>
''' <remarks>UTILIZZA LA SESSION PER LA PERSISTENZA DEI DATI</remarks>
Public NotInheritable Class FilterHelper

	''' <summary>
	''' Salva in Session il valore dei controlli nel contenitore passato 
	''' </summary>
	''' <param name="UniqueKey">chiave univoca per distinguere i controlli di pagine diverse</param>
	Public Shared Sub SaveInSession(Container As Control, UniqueKey As String)

		For Each child As Control In Container.Controls
			SaveInSession(child, UniqueKey)

			If child.ID Is Nothing Then Continue For
			Dim ControlKey As String = UniqueKey & child.ID
			If TypeOf child Is TextBox Then
				HttpContext.Current.Session(ControlKey) = TryCast(child, TextBox).Text
			ElseIf TypeOf child Is CheckBox Then
				HttpContext.Current.Session(ControlKey) = TryCast(child, CheckBox).Checked
			ElseIf TypeOf child Is DropDownList Then
				HttpContext.Current.Session(ControlKey) = TryCast(child, DropDownList).SelectedValue
			ElseIf TypeOf child Is RadioButtonList Then
				HttpContext.Current.Session(ControlKey) = TryCast(child, RadioButtonList).SelectedValue
			End If
		Next
	End Sub

	''' <summary>
	''' Recupera il valore salvato per il controllo passato
	''' </summary>
	Public Shared Function GetSavedValue(control As Control, UniqueKey As String) As Object

		If control.ID Is Nothing Then Return Nothing
		Return HttpContext.Current.Session(UniqueKey & control.ID)

	End Function


	''' <summary>
	''' Restore del valore dei controlli presenti nel contenitore passato
	''' </summary>
	''' <param name="Container">Contenitore o singolo controllo da caricare</param>
	''' <param name="UniqueKey">Chiave univoca per distinguere i controlli di pagine diverse</param>
	''' <remarks></remarks>
	Public Shared Sub Restore(Container As Control, UniqueKey As String)

		'ripristino il contenuto del parent qualora ne avesse uno
		RestoreSingleControl(Container, UniqueKey)
		'ciclo per ogni controllo child
		For Each child As Control In Container.Controls
			Restore(child, UniqueKey)
		Next

	End Sub


	Private Shared Sub RestoreSingleControl(control As Control, UniqueKey As String)
		Dim SavedValue As Object

		If control.ID Is Nothing Then Return
		'System.Diagnostics.Debug.Print("RestoreSingleControl : " & control.ID)
		If HttpContext.Current.Session(UniqueKey & control.ID) Is Nothing Then Return
		SavedValue = HttpContext.Current.Session(UniqueKey & control.ID)
		'System.Diagnostics.Debug.Print("    " & control.ID & " = " & SavedValue)

		If TypeOf control Is TextBox Then
			TryCast(control, TextBox).Text = SavedValue

		ElseIf TypeOf control Is CheckBox Then
			TryCast(control, CheckBox).Checked = SavedValue

		ElseIf TypeOf control Is DropDownList Then
			Dim ddlChild = TryCast(control, DropDownList)
			Try
				Dim itm As ListItem = ddlChild.Items.FindByValue(SavedValue)
				If itm IsNot Nothing Then
					ddlChild.SelectedIndex = -1
					itm.Selected = True
				End If
			Catch
			End Try

		ElseIf TypeOf control Is RadioButtonList Then
			Dim rbtChild = TryCast(control, RadioButtonList)
			Try
				Dim itm As ListItem = rbtChild.Items.FindByValue(SavedValue)
				If itm IsNot Nothing Then
					rbtChild.SelectedIndex = -1
					itm.Selected = True
				End If
			Catch
			End Try
		End If

	End Sub


	''' <summary>
	''' Clear dei filtri (sia dei controlli che del valore salvato nella session)
	''' </summary>
	''' <param name="parent">Contenitore dei controlli da ripulire</param>
	''' <remarks>Non cancella il contenuto del controllo se non lo trova salvato anche nella session</remarks>
	Public Shared Sub Clear(parent As Control, UniqueKey As String)

		For Each child As Control In parent.Controls

			Clear(child, UniqueKey)
			If child.ID Is Nothing Then Continue For
			HttpContext.Current.Session.Remove(UniqueKey & child.ID)

			If TypeOf child Is TextBox Then
				TryCast(child, TextBox).Text = String.Empty

			ElseIf TypeOf child Is CheckBox Then
				TryCast(child, CheckBox).Checked = False

			ElseIf TypeOf child Is DropDownList Then
				Try
					Dim ddlChild = TryCast(child, DropDownList)
					If ddlChild.Items.Count > 0 Then
						ddlChild.ClearSelection()
						'se presente cerco un elemento con value o text vuoto
						Dim itm As ListItem = ddlChild.Items.FindByValue("")
						If itm Is Nothing Then itm = ddlChild.Items.FindByText("")
						'altrimenti seleziono il primo in lista
						If itm Is Nothing Then itm = ddlChild.Items(0)
						itm.Selected = True
					End If
				Catch
				End Try

			ElseIf TypeOf child Is RadioButtonList Then
				Try
					TryCast(child, RadioButtonList).ClearSelection()
				Catch
				End Try

			End If
		Next

	End Sub

End Class

