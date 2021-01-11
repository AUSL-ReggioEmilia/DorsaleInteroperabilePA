Imports System.ComponentModel
Imports System.Security.Permissions
Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports AjaxControlToolkit
Imports System.Web.UI.WebControls
Imports System.Web.UI.HtmlControls
Imports System.Text
Imports System
Imports System.Web.UI
Imports System.Web.UI.Design

Namespace DI.Sac.Admin

    < _
    AspNetHostingPermission(SecurityAction.Demand, _
        Level:=AspNetHostingPermissionLevel.Minimal), _
    AspNetHostingPermission(SecurityAction.InheritanceDemand, _
        Level:=AspNetHostingPermissionLevel.Minimal), _
    DefaultProperty("ServicePath"), _
    ToolboxData("<{0}:Progel3DropDownList runat=server></{0}:Progel3DropDownList>"), _
    Designer(GetType(Progel3DropDownListDesigner), GetType(System.ComponentModel.Design.IDesigner)) _
    > _
    Public Class Progel3DropDownList
        Inherits WebControl
        Implements INamingContainer

        '
        ' Class members
        '
        Private oParentDropDownList As DropDownList
        Private oParentCascadingDropDown As CascadingDropDown
        Private oChildTopDropDownList As DropDownList
        Private oChildTopCascadingDropDown As CascadingDropDown
        Private oChildDownDropDownList As DropDownList
        Private oChildDownCascadingDropDown As CascadingDropDown

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

#Region "ChildTop Property"

        '
        ' Property Category
        '
        < _
        Category("Progel"), _
        DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Description("The name of the category this DropDownList represents.") _
        > _
        Public Property ChildTopCategory() As String
            Get
                Dim s As String = CStr(ViewState("ChildTopCategory"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ChildTopCategory") = value
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
        Public Property ChildTopServiceMethod() As String
            Get
                Dim s As String = CStr(ViewState("ChildTopServiceMethod"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ChildTopServiceMethod") = value
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
        Public Property ChildTopPromptText() As String
            Get
                Dim s As String = CStr(ViewState("ChildTopPromptText"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ChildTopPromptText") = value
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
        Public Property ChildTopLoadingText() As String
            Get
                Dim s As String = CStr(ViewState("ChildTopLoadingText"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ChildTopLoadingText") = value
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
        Public Property ChildTopBindValue() As String
            Get
                Dim s As String = CStr(ViewState("ChildTopBindValue"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ChildTopBindValue") = value
            End Set
        End Property

#End Region

#Region "ChildDown Property"

        '
        ' Property Category
        '
        < _
        Category("Progel"), _
        DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), _
        Description("The name of the category this DropDownList represents.") _
        > _
        Public Property ChildDownCategory() As String
            Get
                Dim s As String = CStr(ViewState("ChildDownCategory"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ChildDownCategory") = value
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
        Public Property ChildDownServiceMethod() As String
            Get
                Dim s As String = CStr(ViewState("ChildDownServiceMethod"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ChildDownServiceMethod") = value
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
        Public Property ChildDownPromptText() As String
            Get
                Dim s As String = CStr(ViewState("ChildDownPromptText"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ChildDownPromptText") = value
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
        Public Property ChildDownLoadingText() As String
            Get
                Dim s As String = CStr(ViewState("ChildDownLoadingText"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ChildDownLoadingText") = value
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
        Public Property ChildDownBindValue() As String
            Get
                Dim s As String = CStr(ViewState("ChildDownBindValue"))
                If s Is Nothing Then s = String.Empty
                Return s
            End Get
            Set(ByVal value As String)
                ViewState("ChildDownBindValue") = value
            End Set
        End Property

#End Region

        '
        ' Create child controls
        '
        Protected Overrides Sub CreateChildControls()
            Dim br As HtmlGenericControl = Nothing

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

            '
            ' <br />
            '
            br = New HtmlGenericControl()
            br.InnerHtml = "<br />"
            Controls.Add(br)

            '
            ' ChildTop DropDownList in bind
            '
            oChildTopDropDownList = New DropDownList()
            oChildTopDropDownList.ID = String.Concat(Me.ID, "_", "ChildTopDropDownList")
            AddHandler oChildTopDropDownList.TextChanged, AddressOf oChildTopDropDownList_TextChanged
            Controls.Add(oChildTopDropDownList)
            '
            ' ChildTop CascadingDropDown
            '
            oChildTopCascadingDropDown = New CascadingDropDown()
            oChildTopCascadingDropDown.ID = String.Concat(Me.ID, "_", "ChildTopCascadingDropDown")
            oChildTopCascadingDropDown.TargetControlID = oChildTopDropDownList.ID
            oChildTopCascadingDropDown.ParentControlID = oParentDropDownList.ID
            oChildTopCascadingDropDown.PromptText = ChildTopPromptText
            oChildTopCascadingDropDown.LoadingText = ChildTopLoadingText
            oChildTopCascadingDropDown.Category = ChildTopCategory
            oChildTopCascadingDropDown.ServicePath = ServicePath
            oChildTopCascadingDropDown.ServiceMethod = ChildTopServiceMethod
            Controls.Add(oChildTopCascadingDropDown)

            '
            ' <br />
            '
            br = New HtmlGenericControl()
            br.InnerHtml = "<br />"
            Controls.Add(br)

            '
            ' ChildDown DropDownList in bind
            '
            oChildDownDropDownList = New DropDownList()
            oChildDownDropDownList.ID = String.Concat(Me.ID, "_", "ChildDownDropDownList")
            AddHandler oChildDownDropDownList.TextChanged, AddressOf oChildDownDropDownList_TextChanged
            Controls.Add(oChildDownDropDownList)
            '
            ' ChildDown CascadingDropDown
            '
            oChildDownCascadingDropDown = New CascadingDropDown()
            oChildDownCascadingDropDown.ID = String.Concat(Me.ID, "_", "ChildDownCascadingDropDown")
            oChildDownCascadingDropDown.TargetControlID = oChildDownDropDownList.ID
            oChildDownCascadingDropDown.ParentControlID = oChildTopDropDownList.ID
            oChildDownCascadingDropDown.PromptText = ChildDownPromptText
            oChildDownCascadingDropDown.LoadingText = ChildDownLoadingText
            oChildDownCascadingDropDown.Category = ChildDownCategory
            oChildDownCascadingDropDown.ServicePath = ServicePath
            oChildDownCascadingDropDown.ServiceMethod = ChildDownServiceMethod
            Controls.Add(oChildDownCascadingDropDown)
        End Sub

        '
        ' Handler
        '
        Protected Sub oParentDropDownList_TextChanged(ByVal sender As Object, ByVal e As EventArgs)
            ParentBindValue = CType(sender, DropDownList).SelectedValue
        End Sub

        Protected Sub oChildTopDropDownList_TextChanged(ByVal sender As Object, ByVal e As EventArgs)
            ChildTopBindValue = CType(sender, DropDownList).SelectedValue
        End Sub

        Protected Sub oChildDownDropDownList_TextChanged(ByVal sender As Object, ByVal e As EventArgs)
            ChildDownBindValue = CType(sender, DropDownList).SelectedValue
        End Sub

        Protected Overrides Sub OnPreRender(ByVal e As System.EventArgs)
            MyBase.OnPreRender(e)

            '
            ' Setting della proprietà SelectedValue
            '
            oParentCascadingDropDown.SelectedValue = ParentBindValue
            oChildTopCascadingDropDown.SelectedValue = ChildTopBindValue
            oChildDownCascadingDropDown.SelectedValue = ChildDownBindValue
        End Sub

    End Class

    Public Class Progel3DropDownListDesigner
        Inherits ControlDesigner

        Public Overrides Function GetDesignTimeHtml() As String

            Dim sddl As Progel3DropDownList = CType(Me.Component, Progel3DropDownList)
            Dim sString As StringBuilder = New StringBuilder()

            sString.Append("<select name='{0}' id='{0}'>")
            sString.Append("<option value=''></option>")
            sString.Append("</select>")
            sString.Append("<br />")
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