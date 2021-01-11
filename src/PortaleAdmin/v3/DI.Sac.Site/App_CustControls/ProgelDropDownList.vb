Imports System.ComponentModel
Imports System.Security.Permissions
Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports AjaxControlToolkit
Imports System
Imports System.Web.UI.WebControls
Imports System.Web.UI.HtmlControls
Imports System.Web.UI
Imports System.Text
Imports System.Web.UI.Design

Namespace DI.Sac.Admin

    < _
    AspNetHostingPermission(SecurityAction.Demand, _
        Level:=AspNetHostingPermissionLevel.Minimal), _
    AspNetHostingPermission(SecurityAction.InheritanceDemand, _
        Level:=AspNetHostingPermissionLevel.Minimal), _
    DefaultProperty("ServicePath"), _
    ToolboxData("<{0}:ProgelDropDownList runat=server></{0}:ProgelDropDownList>"), _
    Designer(GetType(ProgelDropDownListDesigner), GetType(System.ComponentModel.Design.IDesigner)) _
    > _
    Public Class ProgelDropDownList
        Inherits WebControl
        Implements INamingContainer

        '
        ' Class members
        '
        Private oParentDropDownList As DropDownList
        Private oParentCascadingDropDown As CascadingDropDown
        Private oChildDropDownList As DropDownList
        Private oChildCascadingDropDown As CascadingDropDown

        '
        ' Property ServicePath
        '
        < _
        Category("Progel"), _
        DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Description("Path to a web service that returns the data used to populate the DropDownList. ") _
        > _
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

        '
        ' Property Category
        '
        < _
        Category("Progel"), _
        DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Description("The name of the category this DropDownList represents.") _
        > _
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

        '
        ' Property ServiceMethod
        '
        < _
        Category("Progel"), _
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

        '
        ' Property PromptText
        '
        < _
        Category("Progel"), _
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

        '
        ' Property LoadingText
        '
        < _
        Category("Progel"), _
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

        '
        ' Property BindValue
        '
        < _
        Category("Progel"), _
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

        '
        ' Property Category
        '
        < _
        Category("Progel"), _
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

        '
        ' Property ServiceMethod
        '
        < _
        Category("Progel"), _
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

        '
        ' Property PromptText
        '
        < _
        Category("Progel"), _
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

        '
        ' Property LoadingText
        '
        < _
        Category("Progel"), _
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

        '
        ' Property BindValue
        '
        < _
        Category("Progel"), _
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

            '
            ' Parent DropDownList
            '
            oParentDropDownList = New DropDownList()
            oParentDropDownList.ID = String.Concat(Me.ID, "_", "ParentDropDownList")
            AddHandler oParentDropDownList.TextChanged, AddressOf oParentDropDownList_TextChanged
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

        '
        ' Handler
        '
        Protected Sub oParentDropDownList_TextChanged(ByVal sender As Object, ByVal e As EventArgs)
            ParentBindValue = CType(sender, DropDownList).SelectedValue
        End Sub

        Protected Sub oChildDropDownList_TextChanged(ByVal sender As Object, ByVal e As EventArgs)
            ChildBindValue = CType(sender, DropDownList).SelectedValue
        End Sub

        Protected Overrides Sub OnPreRender(ByVal e As EventArgs)

            MyBase.OnPreRender(e)

            oParentCascadingDropDown.SelectedValue = ParentBindValue
            oChildCascadingDropDown.SelectedValue = ChildBindValue
        End Sub

    End Class

    Public Class ProgelDropDownListDesigner
        Inherits ControlDesigner

        Public Overrides Function GetDesignTimeHtml() As String

            Dim sddl As ProgelDropDownList = CType(Me.Component, ProgelDropDownList)
            Dim sString As StringBuilder = New StringBuilder()

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