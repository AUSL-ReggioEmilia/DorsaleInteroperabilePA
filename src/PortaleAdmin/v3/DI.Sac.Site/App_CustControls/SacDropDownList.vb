Imports System.ComponentModel
Imports System.Web
Imports AjaxControlToolkit
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Text
Imports System
Imports System.Diagnostics
Imports System.Collections
Imports System.Web.UI.HtmlControls
Imports System.Web.UI.Design

Namespace DI.Sac.Admin

    <ControlValueProperty("ServiceMethod", GetType(String)), _
    DefaultProperty("ServiceMethod"), _
    ToolboxData("<{0}:SacDropDownList runat=server></{0}:SacDropDownList>"), _
    Designer(GetType(SacDropDownListDesigner), GetType(System.ComponentModel.Design.IDesigner))> _
    Public Class SacDropDownList
        Inherits WebControl
        Implements INamingContainer

        '
        ' Class members
        '
        Dim oParentDropDownList As DropDownList
        Dim oParentCascadingDropDown As CascadingDropDown
        Dim oChildDropDownList As DropDownList
        Dim oChildCascadingDropDown As CascadingDropDown

        '
        ' Property ServicePath
        '
        < _
        CategoryAttribute("Progel"), _
        DefaultValueAttribute(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Bindable(True), _
        Localizable(True), _
        BrowsableAttribute(True), _
        DescriptionAttribute("Path to a web service that returns the data used to populate the DropDownList. " & _
                             "This property should be left null if ServiceMethod refers to a page method. " & _
                             "The web service should be decorated with the System.Web.Script.Services.ScriptService attribute.") _
        > _
        Public Property ServicePath() As String
            Get
                If ViewState("ServicePath") IsNot Nothing Then
                    Return ViewState("ServicePath").ToString()
                End If

                Return String.Empty
            End Get
            Set(ByVal value As String)
                ViewState("ServicePath") = value
            End Set
        End Property

        '
        ' Property ParentServiceMethod
        '
        < _
        CategoryAttribute("Progel"), _
        DefaultValueAttribute(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Bindable(True), _
        Localizable(True), _
        BrowsableAttribute(True), _
        DescriptionAttribute("Web service method that returns the data used to populate the DropDownList.") _
        > _
        Public Property ParentServiceMethod() As String
            Get
                If ViewState("ParentServiceMethod") IsNot Nothing Then
                    Return ViewState("ParentServiceMethod").ToString()
                End If

                Return String.Empty
            End Get
            Set(ByVal value As String)
                ViewState("ParentServiceMethod") = value
            End Set
        End Property

        '
        ' Property ParentPromptText
        '
        < _
        CategoryAttribute("Progel"), _
        DefaultValueAttribute(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Bindable(True), _
        Localizable(True), _
        BrowsableAttribute(True), _
        DescriptionAttribute("Optional text to display before the user has selected a value from the DropDownList.") _
        > _
        Public Property ParentPromptText() As String
            Get
                If ViewState("ParentPromptText") IsNot Nothing Then
                    Return ViewState("ParentPromptText").ToString
                End If

                Return String.Empty
            End Get
            Set(ByVal value As String)
                ViewState("ParentPromptText") = value
            End Set
        End Property

        '
        ' Property ParentLoadingText
        '
        < _
        CategoryAttribute("Progel"), _
        DefaultValueAttribute(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Bindable(True), _
        Localizable(True), _
        BrowsableAttribute(True), _
        DescriptionAttribute("Optional text to display while the data for the DropDownList is being loaded.") _
        > _
        Public Property ParentLoadingText() As String
            Get
                If ViewState("ParentLoadingText") IsNot Nothing Then
                    Return ViewState("ParentLoadingText").ToString()
                End If

                Return String.Empty
            End Get
            Set(ByVal value As String)
                ViewState("ParentLoadingText") = value
            End Set
        End Property

        '
        ' Property ParentCategory
        '
        < _
        CategoryAttribute("Progel"), _
        DefaultValueAttribute(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Bindable(True), _
        Localizable(True), _
        BrowsableAttribute(True), _
        DescriptionAttribute("The name of the category this DropDownList represents.") _
        > _
        Public Property ParentCategory() As String
            Get
                If ViewState("ParentCategory") IsNot Nothing Then
                    Return ViewState("ParentCategory").ToString
                End If

                Return String.Empty
            End Get
            Set(ByVal value As String)
                ViewState("ParentCategory") = value
            End Set
        End Property

        '
        ' Property ChildServiceMethod
        '
        < _
        CategoryAttribute("Progel"), _
        DefaultValueAttribute(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Bindable(True), _
        Localizable(True), _
        BrowsableAttribute(True), _
        DescriptionAttribute("Web service method that returns the data used to populate the DropDownList.") _
        > _
        Public Property ChildServiceMethod() As String
            Get
                If ViewState("ChildServiceMethod") IsNot Nothing Then
                    Return ViewState("ChildServiceMethod").ToString
                End If

                Return String.Empty
            End Get
            Set(ByVal value As String)
                ViewState("ChildServiceMethod") = value
            End Set
        End Property

        '
        ' Property ChildPromptText
        '
        < _
        CategoryAttribute("Progel"), _
        DefaultValueAttribute(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Bindable(True), _
        Localizable(True), _
        BrowsableAttribute(True), _
        DescriptionAttribute("Optional text to display before the user has selected a value from the DropDownList.") _
        > _
        Public Property ChildPromptText() As String
            Get
                If ViewState("ChildPromptText") IsNot Nothing Then
                    Return ViewState("ChildPromptText").ToString()
                End If

                Return String.Empty
            End Get
            Set(ByVal value As String)
                ViewState("ChildPromptText") = value
            End Set
        End Property

        '
        ' Property ChildLoadingText
        '
        < _
        CategoryAttribute("Progel"), _
        DefaultValueAttribute(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Bindable(True), _
        Localizable(True), _
        BrowsableAttribute(True), _
        DescriptionAttribute("Optional text to display while the data for the DropDownList is being loaded.") _
        > _
        Public Property ChildLoadingText() As String
            Get
                If ViewState("ChildLoadingText") IsNot Nothing Then
                    Return ViewState("ChildLoadingText").ToString()
                End If

                Return String.Empty
            End Get
            Set(ByVal value As String)
                ViewState("ChildLoadingText") = value
            End Set
        End Property

        '
        ' Property ChildCategory
        '
        < _
        CategoryAttribute("Progel"), _
        DefaultValueAttribute(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Bindable(True), _
        Localizable(True), _
        BrowsableAttribute(True), _
        DescriptionAttribute("The name of the category this DropDownList represents.") _
        > _
        Public Property ChildCategory() As String
            Get
                If ViewState("ChildCategory") IsNot Nothing Then
                    Return ViewState("ChildCategory").ToString
                End If

                Return String.Empty
            End Get
            Set(ByVal value As String)
                ViewState("ChildCategory") = value
            End Set
        End Property

        '
        ' Property BindValue
        '
        < _
        CategoryAttribute("Progel"), _
        DefaultValueAttribute(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Bindable(True, BindingDirection.TwoWay), _
        Localizable(True), _
        BrowsableAttribute(True), _
        DescriptionAttribute("") _
        > _
        Public Property BindValue() As String
            Get
                If ViewState("BindValue") IsNot Nothing Then
                    Return ViewState("BindValue").ToString
                End If

                Return String.Empty
            End Get
            Set(ByVal value As String)
                ViewState("BindValue") = value
            End Set
        End Property

        '
        ' Create child controls
        '
        Protected Overrides Sub CreateChildControls()

            '
            ' Parent DropDownList
            '
            oParentDropDownList = New DropDownList()
            oParentDropDownList.ID = String.Concat(Me.ID, "_", "ParentDropDownList")
            Controls.Add(oParentDropDownList)
            '
            ' Parent CascadingDropDown
            '
            oParentCascadingDropDown = New CascadingDropDown()
            oParentCascadingDropDown.ID = String.Concat(Me.ID, "_", "ParentCascadingDropDown")
            oParentCascadingDropDown.TargetControlID = oParentDropDownList.ID
            oParentCascadingDropDown.PromptText = ParentPromptText
            oParentCascadingDropDown.LoadingText = ParentLoadingText
            oParentCascadingDropDown.Category = ParentCategory
            oParentCascadingDropDown.ServicePath = ServicePath
            oParentCascadingDropDown.ServiceMethod = ParentServiceMethod
            Controls.Add(oParentCascadingDropDown)

            '
            ' <br />
            '
            Dim br As New HtmlGenericControl()
            br.InnerHtml = "<br />"
            Controls.Add(br)

            '
            ' Child DropDownList in bind
            '
            oChildDropDownList = New DropDownList()
            oChildDropDownList.ID = String.Concat(Me.ID, "_", "ChildDropDownList")
            AddHandler oChildDropDownList.TextChanged, AddressOf oChildDropDownList_TextChanged
            Controls.Add(oChildDropDownList)
            '
            ' Child CascadingDropDown
            '
            oChildCascadingDropDown = New CascadingDropDown()
            oChildCascadingDropDown.ID = String.Concat(Me.ID, "_", "ChildCascadingDropDown")
            oChildCascadingDropDown.TargetControlID = oChildDropDownList.ID
            oChildCascadingDropDown.ParentControlID = oParentDropDownList.ID
            oChildCascadingDropDown.PromptText = ChildPromptText
            oChildCascadingDropDown.LoadingText = ChildLoadingText
            oChildCascadingDropDown.Category = ChildCategory
            oChildCascadingDropDown.ServicePath = ServicePath
            oChildCascadingDropDown.ServiceMethod = ChildServiceMethod
            Controls.Add(oChildCascadingDropDown)

        End Sub

        Protected Sub oChildDropDownList_TextChanged(ByVal sender As Object, ByVal e As EventArgs)
            BindValue = CType(sender, DropDownList).SelectedValue
        End Sub

        Protected Overrides Sub OnPreRender(ByVal e As System.EventArgs)
            MyBase.OnPreRender(e)

            If Not BindValue.Equals(String.Empty) Then

                oChildDropDownList.Enabled = True
                oChildDropDownList.Items.Insert(0, New ListItem(oChildDropDownList.SelectedItem.Text, oChildDropDownList.SelectedItem.Value))
            End If

        End Sub

    End Class

    Public Class SacDropDownListDesigner
        Inherits ControlDesigner

        Public Overrides Function GetDesignTimeHtml() As String

            Dim sddl As SacDropDownList = CType(Me.Component, SacDropDownList)
            Dim sString As New StringBuilder()

            sString.Append("<select name='{0}' id='{0}'>")
            sString.Append("<option value=''></option>")
            sString.Append("</select>")
            sString.Append("<br />")
            sString.Append("<select name='{0}' id='{0}'>")
            sString.Append("<option value=''></option>")
            sString.Append("</select>")

            Return sString.ToString()
        End Function

    End Class

End Namespace