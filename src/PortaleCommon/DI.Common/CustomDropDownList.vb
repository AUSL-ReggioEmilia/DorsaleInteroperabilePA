Imports System.ComponentModel
Imports System.Security.Permissions
Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports AjaxControlToolkit
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Text
Imports System.Web.UI.HtmlControls
'
Namespace DI.Common.Controls

    <AspNetHostingPermission(SecurityAction.Demand, Level:=AspNetHostingPermissionLevel.Minimal), _
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level:=AspNetHostingPermissionLevel.Minimal), _
    DefaultProperty("ServicePath"), ToolboxData("<{0}:CustomDropDownList runat=server></{0}:CustomDropDownList>"), _
    Designer(GetType(CustomDropDownListDesigner), GetType(System.ComponentModel.Design.IDesigner))> _
    Public Class CustomDropDownList
        Inherits WebControl
        Implements INamingContainer


        Private _parentDropDownList As DropDownList
        Private _parentCascadingDropDown As CascadingDropDown
        Private _childDropDownList As DropDownList
        Private _childCascadingDropDown As CascadingDropDown

        <Category("CustomDropDownList"), DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), Description("Path to a web service that returns the data used to populate the DropDownList. ")> _
        Public Property ServicePath() As String
            Get
                Dim s As String = CStr(ViewState("ServicePath"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ServicePath") = value
            End Set
        End Property

#Region "Parent Property"

        <Category("CustomDropDownList"), DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), Description("The name of the category this DropDownList represents.")> _
        Public Property ParentCategory() As String
            Get
                Dim s As String = CStr(ViewState("ParentCategory"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ParentCategory") = value
            End Set
        End Property

        < _
        Category("CustomDropDownList"), _
        DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Description("Web service method that returns the data used to populate the DropDownList.") _
        > _
        Public Property ParentServiceMethod() As String
            Get
                Dim s As String = CStr(ViewState("ParentServiceMethod"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ParentServiceMethod") = value
            End Set
        End Property

        < _
        Category("CustomDropDownList"), _
        DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Description("Optional text to display before the user has selected a value from the DropDownList.") _
        > _
        Public Property ParentPromptText() As String
            Get
                Dim s As String = CStr(ViewState("ParentPromptText"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ParentPromptText") = value
            End Set
        End Property

        < _
        Category("CustomDropDownList"), _
        DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Description("Optional text to display while the data for the DropDownList is being loaded.") _
        > _
        Public Property ParentLoadingText() As String
            Get
                Dim s As String = CStr(ViewState("ParentLoadingText"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ParentLoadingText") = value
            End Set
        End Property

        < _
        Category("CustomDropDownList"), _
        DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Bindable(True, BindingDirection.TwoWay) _
        > _
        Public Property ParentBindValue() As String
            Get
                Dim s As String = CStr(ViewState("ParentBindValue"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ParentBindValue") = value
            End Set
        End Property

#End Region

#Region "Child Property"

        < _
        Category("CustomDropDownList"), _
        DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Description("The name of the category this DropDownList represents.") _
        > _
        Public Property ChildCategory() As String
            Get
                Dim s As String = CStr(ViewState("ChildCategory"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ChildCategory") = value
            End Set
        End Property

        < _
        Category("CustomDropDownList"), _
        DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Description("Web service method that returns the data used to populate the DropDownList.") _
        > _
        Public Property ChildServiceMethod() As String
            Get
                Dim s As String = CStr(ViewState("ChildServiceMethod"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ChildServiceMethod") = value
            End Set
        End Property

        < _
        Category("CustomDropDownList"), _
        DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Description("Optional text to display before the user has selected a value from the DropDownList.") _
        > _
        Public Property ChildPromptText() As String
            Get
                Dim s As String = CStr(ViewState("ChildPromptText"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ChildPromptText") = value
            End Set
        End Property

        < _
        Category("CustomDropDownList"), _
        DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Description("Optional text to display while the data for the DropDownList is being loaded.") _
        > _
        Public Property ChildLoadingText() As String
            Get
                Dim s As String = CStr(ViewState("ChildLoadingText"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ChildLoadingText") = value
            End Set
        End Property

        < _
        Category("CustomDropDownList"), _
        DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Bindable(True, BindingDirection.TwoWay) _
        > _
        Public Property ChildBindValue() As String
            Get
                Dim s As String = CStr(ViewState("ChildBindValue"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ChildBindValue") = value
            End Set
        End Property

#End Region

        Protected Overrides Sub CreateChildControls()

            _parentDropDownList = New DropDownList()
            _parentDropDownList.ID = String.Concat(Me.ID, "_", "ParentDropDownList")
            AddHandler _parentDropDownList.TextChanged, AddressOf ParentDropDownList_TextChanged
            Controls.Add(_parentDropDownList)

            _parentCascadingDropDown = New CascadingDropDown()
            _parentCascadingDropDown.ID = String.Concat(Me.ID, "_", "ParentCascadingDropDown")
            _parentCascadingDropDown.TargetControlID = _parentDropDownList.ID
            _parentCascadingDropDown.PromptText = ParentPromptText
            _parentCascadingDropDown.LoadingText = ParentLoadingText
            _parentCascadingDropDown.Category = ParentCategory
            _parentCascadingDropDown.ServicePath = ServicePath
            _parentCascadingDropDown.ServiceMethod = ParentServiceMethod
            Controls.Add(_parentCascadingDropDown)

            Dim br As New HtmlGenericControl()
            br.InnerHtml = "<br />"
            Controls.Add(br)

            _childDropDownList = New DropDownList()
            _childDropDownList.ID = String.Concat(Me.ID, "_", "ChildDropDownList")
            AddHandler _childDropDownList.TextChanged, AddressOf ChildDropDownList_TextChanged
            Controls.Add(_childDropDownList)

            _childCascadingDropDown = New CascadingDropDown()
            _childCascadingDropDown.ID = String.Concat(Me.ID, "_", "ChildCascadingDropDown")
            _childCascadingDropDown.TargetControlID = _childDropDownList.ID
            _childCascadingDropDown.ParentControlID = _parentDropDownList.ID
            _childCascadingDropDown.PromptText = ChildPromptText
            _childCascadingDropDown.LoadingText = ChildLoadingText
            _childCascadingDropDown.Category = ChildCategory
            _childCascadingDropDown.ServicePath = ServicePath
            _childCascadingDropDown.ServiceMethod = ChildServiceMethod

            Controls.Add(_childCascadingDropDown)
        End Sub

        Protected Sub ParentDropDownList_TextChanged(ByVal sender As Object, ByVal e As EventArgs)
            ParentBindValue = DirectCast(sender, DropDownList).SelectedValue
        End Sub

        Protected Sub ChildDropDownList_TextChanged(ByVal sender As Object, ByVal e As EventArgs)
            ChildBindValue = DirectCast(sender, DropDownList).SelectedValue
        End Sub

        Protected Overrides Sub OnPreRender(ByVal e As System.EventArgs)
            MyBase.OnPreRender(e)

            _parentCascadingDropDown.SelectedValue = ParentBindValue
            _childCascadingDropDown.SelectedValue = ChildBindValue
        End Sub

    End Class

    Public Class CustomDropDownListDesigner
        Inherits System.Web.UI.Design.ControlDesigner

        Public Overrides Function GetDesignTimeHtml() As String

            Dim sddl As CustomDropDownList = DirectCast(Me.Component, CustomDropDownList)
            Dim stringBuilder As New StringBuilder()

            stringBuilder.Append("<select name='{0}' id='{0}'>")
            stringBuilder.Append("<option value=''></option>")
            stringBuilder.Append("</select>")
            stringBuilder.Append("<br />")
            stringBuilder.Append("<select name='{0}' id='{0}'>")
            stringBuilder.Append("<option value=''></option>")
            stringBuilder.Append("</select>")

            Return stringBuilder.ToString()
        End Function

    End Class

End Namespace