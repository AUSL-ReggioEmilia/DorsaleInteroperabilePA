Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web


Public NotInheritable Class FilterHelper

    Private Sub New()
    End Sub

    'Private Shared ReadOnly _className As String = MethodBase.GetCurrentMethod().ReflectedType.Name

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
                HttpContext.Current.Session(child.ID) = textBoxChild.Text
            ElseIf dropDownListChild IsNot Nothing Then
                HttpContext.Current.Session(child.ID) = dropDownListChild.SelectedValue
            ElseIf checkBoxBoxChild IsNot Nothing Then
                HttpContext.Current.Session(child.ID) = checkBoxBoxChild.Checked
            ElseIf radioButtonListChild IsNot Nothing Then
                HttpContext.Current.Session(child.ID) = radioButtonListChild.SelectedValue
            End If

            SaveInSession(child)
        Next
    End Sub


    ''' <summary>
    ''' Salvo i filtri in una Session
    ''' </summary>
    ''' <param name="UniqueKey">chiave univoca per distinguere i controlli di pagine diverse</param>
    Public Shared Sub SaveInSession(parent As Control, UniqueKey As String)

        For Each child As Control In parent.Controls
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
    ''' Restore dei filtri salvati
    ''' </summary>
    ''' <param name="parent">Contenitore o singolo controllo da caricare</param>
    ''' <param name="UniqueKey">Chiave univoca per distinguere i controlli di pagine diverse</param>
    ''' <remarks></remarks>
    Public Shared Sub Restore(parent As Control, UniqueKey As String)

        'ripristino il contenuto del parent qualora ne avesse uno
        RestoreSingleControl(parent, UniqueKey)
        'ciclo per ogni controllo child
        For Each child As Control In parent.Controls
            Restore(child, UniqueKey)
        Next

    End Sub


    Private Shared Sub RestoreSingleControl(control As Control, UniqueKey As String)
        Dim SavedValue As String

        If control.ID Is Nothing Then Return
        'System.Diagnostics.Debug.Print("RestoreSingleControl : " & control.ID)
        If HttpContext.Current.Session(UniqueKey & control.ID) Is Nothing Then Return
        SavedValue = HttpContext.Current.Session(UniqueKey & control.ID).ToString
        'System.Diagnostics.Debug.Print("    " & control.ID & " = " & SavedValue)

        If TypeOf control Is TextBox Then
            TryCast(control, TextBox).Text = SavedValue

        ElseIf TypeOf control Is CheckBox Then
            Dim bBool As Boolean = False
            Boolean.TryParse(SavedValue, bBool)
            TryCast(control, CheckBox).Checked = bBool

        ElseIf TypeOf control Is DropDownList Then
            Dim ddlChild = TryCast(control, DropDownList)
            Try
                ddlChild.SelectedIndex = -1
                ddlChild.Items.FindByValue(SavedValue).Selected = True
            Catch
            End Try

        ElseIf TypeOf control Is RadioButtonList Then
            Dim rbtChild = TryCast(control, RadioButtonList)
            Try
                rbtChild.SelectedIndex = -1
                rbtChild.Items.FindByValue(SavedValue).Selected = True
            Catch
            End Try

        End If

    End Sub

    ''' <summary>
    ''' Restore dei filtri salvati
    ''' </summary>
    Public Shared Sub Restore(parent As Control)

        For Each child As Control In parent.Controls

            Dim textBoxChild = TryCast(child, TextBox)
            Dim dropDownListChild = TryCast(child, DropDownList)
            Dim checkBoxBoxChild = TryCast(child, CheckBox)
            Dim radioButtonListChild = TryCast(child, RadioButtonList)

            If textBoxChild IsNot Nothing Then
                If HttpContext.Current.Session(textBoxChild.ID) IsNot Nothing Then
                    textBoxChild.Text = HttpContext.Current.Session(textBoxChild.ID).ToString()
                End If
            ElseIf checkBoxBoxChild IsNot Nothing Then
                If HttpContext.Current.Session(checkBoxBoxChild.ID) IsNot Nothing Then
                    checkBoxBoxChild.Checked = Boolean.Parse(HttpContext.Current.Session(checkBoxBoxChild.ID).ToString())
                End If
            ElseIf dropDownListChild IsNot Nothing Then
                If HttpContext.Current.Session(dropDownListChild.ID) IsNot Nothing AndAlso _
                        Not HttpContext.Current.Session(dropDownListChild.ID).ToString().Length = 0 Then
                    dropDownListChild.SelectedIndex = -1
                    Try
                        dropDownListChild.Items.FindByValue(HttpContext.Current.Session(dropDownListChild.ID).ToString()).Selected = True
                    Catch
                    End Try

                End If
            ElseIf radioButtonListChild IsNot Nothing Then
                If HttpContext.Current.Session(radioButtonListChild.ID) IsNot Nothing AndAlso _
                        Not HttpContext.Current.Session(radioButtonListChild.ID).ToString().Length = 0 Then
                    radioButtonListChild.SelectedIndex = -1
                    Try
                        radioButtonListChild.Items.FindByValue(HttpContext.Current.Session(radioButtonListChild.ID).ToString()).Selected = True
                    Catch
                    End Try
                End If
            End If
            Restore(child)
        Next
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
                    TryCast(child, DropDownList).ClearSelection()
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


    ' ''' <summary>
    ' ''' Salvo i filtri in un Cookie
    ' ''' </summary>
    ' ''' <param name="parent"></param>
    ' ''' <param name="cookie"></param>
    ' ''' <remarks></remarks>
    'Public Shared Sub SaveInCookie(parent As Control, cookie As HttpCookie)

    '    For Each child As Control In parent.Controls

    '        Dim textBoxChild = TryCast(child, TextBox)
    '        Dim dropDownListChild = TryCast(child, DropDownList)
    '        Dim checkBoxBoxChild = TryCast(child, CheckBox)
    '        Dim radioButtonListChild = TryCast(child, RadioButtonList)

    '        If textBoxChild IsNot Nothing Then
    '            cookie(textBoxChild.ID) = textBoxChild.Text

    '        ElseIf dropDownListChild IsNot Nothing Then
    '            cookie(dropDownListChild.ID) = dropDownListChild.SelectedValue

    '        ElseIf checkBoxBoxChild IsNot Nothing Then
    '            cookie(checkBoxBoxChild.ID) = checkBoxBoxChild.Checked.ToString()

    '        ElseIf radioButtonListChild IsNot Nothing Then
    '            cookie(radioButtonListChild.ID) = radioButtonListChild.SelectedValue
    '        End If

    '        SaveInCookie(child, cookie)
    '    Next
    'End Sub


End Class

