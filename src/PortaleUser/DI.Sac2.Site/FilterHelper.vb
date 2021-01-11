Imports System
Imports System.Diagnostics
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web
Imports System.Reflection

Namespace DI.Sac.User

    Public NotInheritable Class FilterHelper

        Private Sub New()
        End Sub

        Private Shared ReadOnly _className As String = MethodBase.GetCurrentMethod().ReflectedType.Name

        ''' <summary>
        ''' Salvo i filtri in una Session
        ''' </summary>
        ''' <param name="parent"></param>
        ''' <remarks></remarks>
        Public Shared Sub SaveInSession(parent As Control)

            For Each child As Control In parent.Controls

                Dim textBoxChild = TryCast(child, TextBox)
                Dim dropDownListChild = TryCast(child, DropDownList)
                Dim checkBoxBoxChild = TryCast(child, CheckBox)
                Dim radioButtonListChild = TryCast(child, RadioButtonList)

                If textBoxChild IsNot Nothing Then
                    HttpContext.Current.Session(textBoxChild.ID) = textBoxChild.Text

                ElseIf dropDownListChild IsNot Nothing Then
                    HttpContext.Current.Session(dropDownListChild.ID) = dropDownListChild.SelectedValue

                ElseIf checkBoxBoxChild IsNot Nothing Then
                    HttpContext.Current.Session(checkBoxBoxChild.ID) = checkBoxBoxChild.Checked

                ElseIf radioButtonListChild IsNot Nothing Then
                    HttpContext.Current.Session(radioButtonListChild.ID) = radioButtonListChild.SelectedValue
                End If

                SaveInSession(child)
            Next
        End Sub

        ''' <summary>
        ''' Clear dei filtri
        ''' </summary>
        ''' <param name="parent"></param>
        ''' <remarks></remarks>
        Public Shared Sub Clear(parent As Control)

            For Each child As Control In parent.Controls

                Dim textBoxChild = TryCast(child, TextBox)
                Dim dropDownListChild = TryCast(child, DropDownList)
                Dim checkBoxBoxChild = TryCast(child, CheckBox)
                Dim radioButtonListChild = TryCast(child, RadioButtonList)

                If textBoxChild IsNot Nothing Then

                    textBoxChild.Text = String.Empty
                    If HttpContext.Current.Session(textBoxChild.ID) IsNot Nothing Then HttpContext.Current.Session(textBoxChild.ID) = Nothing

                ElseIf dropDownListChild IsNot Nothing Then

                    dropDownListChild.SelectedIndex = -1
                    If HttpContext.Current.Session(dropDownListChild.ID) IsNot Nothing Then HttpContext.Current.Session(dropDownListChild.ID) = Nothing

                ElseIf checkBoxBoxChild IsNot Nothing Then

                    checkBoxBoxChild.Checked = False
                    If HttpContext.Current.Session(checkBoxBoxChild.ID) IsNot Nothing Then HttpContext.Current.Session(checkBoxBoxChild.ID) = Nothing

                ElseIf radioButtonListChild IsNot Nothing Then

                    radioButtonListChild.SelectedIndex = -1
                    If HttpContext.Current.Session(radioButtonListChild.ID) IsNot Nothing Then HttpContext.Current.Session(radioButtonListChild.ID) = Nothing
                End If

                Clear(child)
            Next
        End Sub

        ''' <summary>
        ''' Salvo i filtri in un Cookie
        ''' </summary>
        ''' <param name="parent"></param>
        ''' <param name="cookie"></param>
        ''' <remarks></remarks>
        Public Shared Sub SaveInCookie(parent As Control, cookie As HttpCookie)

            For Each child As Control In parent.Controls

                Dim textBoxChild = TryCast(child, TextBox)
                Dim dropDownListChild = TryCast(child, DropDownList)
                Dim checkBoxBoxChild = TryCast(child, CheckBox)
                Dim radioButtonListChild = TryCast(child, RadioButtonList)

                If textBoxChild IsNot Nothing Then
                    cookie(textBoxChild.ID) = textBoxChild.Text

                ElseIf dropDownListChild IsNot Nothing Then
                    cookie(dropDownListChild.ID) = dropDownListChild.SelectedValue

                ElseIf checkBoxBoxChild IsNot Nothing Then
                    cookie(checkBoxBoxChild.ID) = checkBoxBoxChild.Checked.ToString()

                ElseIf radioButtonListChild IsNot Nothing Then
                    cookie(radioButtonListChild.ID) = radioButtonListChild.SelectedValue
                End If

                SaveInCookie(child, cookie)
            Next
        End Sub

        ''' <summary>
        ''' Restore dei filtri salvati
        ''' </summary>
        ''' <param name="parent"></param>
        ''' <param name="cookie"></param>
        ''' <remarks></remarks>
        Public Shared Sub Restore(parent As Control, cookie As HttpCookie)

            For Each child As Control In parent.Controls

                Dim textBoxChild = TryCast(child, TextBox)
                Dim dropDownListChild = TryCast(child, DropDownList)
                Dim checkBoxBoxChild = TryCast(child, CheckBox)
                Dim radioButtonListChild = TryCast(child, RadioButtonList)

                If textBoxChild IsNot Nothing Then

                    If HttpContext.Current.Session(textBoxChild.ID) IsNot Nothing Then

                        textBoxChild.Text = HttpContext.Current.Session(textBoxChild.ID).ToString()
                    ElseIf cookie IsNot Nothing Then

                        textBoxChild.Text = cookie(textBoxChild.ID).ToString()
                    End If
                ElseIf checkBoxBoxChild IsNot Nothing Then

                    If HttpContext.Current.Session(checkBoxBoxChild.ID) IsNot Nothing Then

                        checkBoxBoxChild.Checked = Boolean.Parse(HttpContext.Current.Session(checkBoxBoxChild.ID).ToString())
                    ElseIf cookie IsNot Nothing Then

                        checkBoxBoxChild.Checked = (cookie(checkBoxBoxChild.ID))
                    End If
                ElseIf dropDownListChild IsNot Nothing Then

                    If HttpContext.Current.Session(dropDownListChild.ID) IsNot Nothing AndAlso _
                            Not HttpContext.Current.Session(dropDownListChild.ID).ToString().Length = 0 Then

                        dropDownListChild.SelectedIndex = -1
                        dropDownListChild.Items.FindByValue(HttpContext.Current.Session(dropDownListChild.ID).ToString()).Selected = True
                    ElseIf cookie IsNot Nothing Then

                        dropDownListChild.SelectedIndex = -1
                        dropDownListChild.Items.FindByValue(cookie(dropDownListChild.ID).ToString()).Selected = True
                    End If
                ElseIf radioButtonListChild IsNot Nothing Then

                    If HttpContext.Current.Session(radioButtonListChild.ID) IsNot Nothing AndAlso _
                            Not HttpContext.Current.Session(radioButtonListChild.ID).ToString().Length = 0 Then

                        radioButtonListChild.SelectedIndex = -1
                        radioButtonListChild.Items.FindByValue(HttpContext.Current.Session(radioButtonListChild.ID).ToString()).Selected = True
                    ElseIf Not cookie Is Nothing Then

                        radioButtonListChild.SelectedIndex = -1
                        radioButtonListChild.Items.FindByValue(cookie(radioButtonListChild.ID).ToString()).Selected = True
                    End If
                End If

                Restore(child, cookie)
            Next
        End Sub



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
    End Class

End Namespace