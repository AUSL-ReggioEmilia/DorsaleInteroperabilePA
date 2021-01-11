Imports System.ComponentModel
Imports System.Security.Permissions
Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports AjaxControlToolkit
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.UI.HtmlControls
Imports System.Text
'
Namespace DI.Common.Controls

    <AspNetHostingPermission(SecurityAction.Demand, Level:=AspNetHostingPermissionLevel.Minimal), _
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level:=AspNetHostingPermissionLevel.Minimal), _
    DefaultProperty("ServicePath"), ToolboxData("<{0}:CascadingDropDownList runat=server></{0}:CascadingDropDownList>"), _
    Designer(GetType(CascadingDropDownListDesigner), GetType(System.ComponentModel.Design.IDesigner))> _
    Public Class CascadingDropDownList
        Inherits WebControl
        Implements INamingContainer

        Private _parentDropDownList As DropDownList
        Private _parentCascadingDropDown As CascadingDropDown
        Private _childTopDropDownList As DropDownList
        Private _childTopCascadingDropDown As CascadingDropDown
        Private _childDownDropDownList As DropDownList
        Private _childDownCascadingDropDown As CascadingDropDown

        <Category("CascadingDropDownList"), DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), Description("Path to a web service that returns the data used to populate the DropDownList. ")> _
        Public Property ServicePath() As String
            Get
                If ViewState("ServicePath") Is Nothing Then

                    Return String.Empty
                Else
                    Return ViewState("ServicePath").ToString()
                End If
            End Get
            Set(ByVal value As String)
                ViewState("ServicePath") = value
            End Set
        End Property

#Region "Parent Property"

        <Category("CascadingDropDownList"), DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), Description("The name of the category this DropDownList represents.")> _
        Public Property ParentCategory() As String
            Get
                If ViewState("ParentCategory") Is Nothing Then

                    Return String.Empty
                Else
                    Return ViewState("ParentCategory").ToString()
                End If
            End Get
            Set(ByVal value As String)
                ViewState("ParentCategory") = value
            End Set
        End Property

        <Category("CascadingDropDownList"), DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), Description("Web service method that returns the data used to populate the DropDownList.")> _
        Public Property ParentServiceMethod() As String
            Get
                If ViewState("ParentServiceMethod") Is Nothing Then

                    Return String.Empty
                Else
                    Return ViewState("ParentServiceMethod").ToString()
                End If
            End Get
            Set(ByVal value As String)
                ViewState("ParentServiceMethod") = value
            End Set
        End Property

        <Category("CascadingDropDownList"), DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), Description("Optional text to display before the user has selected a value from the DropDownList.")> _
        Public Property ParentPromptText() As String
            Get
                If ViewState("ParentPromptText") Is Nothing Then

                    Return String.Empty
                Else
                    Return ViewState("ParentPromptText").ToString()
                End If
            End Get
            Set(ByVal value As String)
                ViewState("ParentPromptText") = value
            End Set
        End Property

        <Category("CascadingDropDownList"), DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), Description("Optional text to display while the data for the DropDownList is being loaded.")> _
        Public Property ParentLoadingText() As String
            Get
                If ViewState("ParentLoadingText") Is Nothing Then

                    Return String.Empty
                Else
                    Return ViewState("ParentLoadingText").ToString()
                End If
            End Get
            Set(ByVal value As String)
                ViewState("ParentLoadingText") = value
            End Set
        End Property

        <Category("CascadingDropDownList"), DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), Bindable(True, BindingDirection.TwoWay)> _
        Public Property ParentBindValue() As String
            Get
                If ViewState("ParentBindValue") Is Nothing Then

                    Return String.Empty
                Else
                    Return ViewState("ParentBindValue").ToString()
                End If
            End Get
            Set(ByVal value As String)
                ViewState("ParentBindValue") = value
            End Set
        End Property

#End Region

#Region "ChildTop Property"

        <Category("CascadingDropDownList"), DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), Description("The name of the category this DropDownList represents.")> _
        Public Property ChildTopCategory() As String
            Get
                If ViewState("ChildTopCategory") Is Nothing Then

                    Return String.Empty
                Else
                    Return ViewState("ChildTopCategory").ToString()
                End If
            End Get
            Set(ByVal value As String)
                ViewState("ChildTopCategory") = value
            End Set
        End Property

        <Category("CascadingDropDownList"), DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), Description("Web service method that returns the data used to populate the DropDownList.")> _
        Public Property ChildTopServiceMethod() As String
            Get
                If ViewState("ChildTopServiceMethod") Is Nothing Then

                    Return String.Empty
                Else
                    Return ViewState("ChildTopServiceMethod").ToString()
                End If
            End Get
            Set(ByVal value As String)
                ViewState("ChildTopServiceMethod") = value
            End Set
        End Property

        <Category("CascadingDropDownList"), DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), Description("Optional text to display before the user has selected a value from the DropDownList.")> _
        Public Property ChildTopPromptText() As String
            Get
                If ViewState("ChildTopPromptText") Is Nothing Then

                    Return String.Empty
                Else
                    Return ViewState("ChildTopPromptText").ToString()
                End If
            End Get
            Set(ByVal value As String)
                ViewState("ChildTopPromptText") = value
            End Set
        End Property

        <Category("CascadingDropDownList"), DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), Description("Optional text to display while the data for the DropDownList is being loaded.")> _
        Public Property ChildTopLoadingText() As String
            Get
                If ViewState("ChildTopLoadingText") Is Nothing Then

                    Return String.Empty
                Else
                    Return ViewState("ChildTopLoadingText").ToString()
                End If
            End Get
            Set(ByVal value As String)
                ViewState("ChildTopLoadingText") = value
            End Set
        End Property

        <Category("CascadingDropDownList"), DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), Bindable(True, BindingDirection.TwoWay)> _
        Public Property ChildTopBindValue() As String
            Get
                If ViewState("ChildTopBindValue") Is Nothing Then

                    Return String.Empty
                Else
                    Return ViewState("ChildTopBindValue").ToString()
                End If
            End Get
            Set(ByVal value As String)
                ViewState("ChildTopBindValue") = value
            End Set
        End Property

#End Region

#Region "ChildDown Property"

        <Category("CascadingDropDownList"), DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), Description("The name of the category this DropDownList represents.")> _
        Public Property ChildDownCategory() As String
            Get
                If ViewState("ChildDownCategory") Is Nothing Then

                    Return String.Empty
                Else
                    Return ViewState("ChildDownCategory").ToString()
                End If
            End Get
            Set(ByVal value As String)
                ViewState("ChildDownCategory") = value
            End Set
        End Property

        <Category("CascadingDropDownList"), DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), Description("Web service method that returns the data used to populate the DropDownList.")> _
        Public Property ChildDownServiceMethod() As String
            Get
                If ViewState("ChildDownServiceMethod") Is Nothing Then

                    Return String.Empty
                Else
                    Return ViewState("ChildDownServiceMethod").ToString()
                End If
            End Get
            Set(ByVal value As String)
                ViewState("ChildDownServiceMethod") = value
            End Set
        End Property

        <Category("CascadingDropDownList"), DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), Description("Optional text to display before the user has selected a value from the DropDownList.")> _
        Public Property ChildDownPromptText() As String
            Get
                If ViewState("ChildDownPromptText") Is Nothing Then

                    Return String.Empty
                Else
                    Return ViewState("ChildDownPromptText").ToString()
                End If
            End Get
            Set(ByVal value As String)
                ViewState("ChildDownPromptText") = value
            End Set
        End Property

        <Category("CascadingDropDownList"), DefaultValue(""), _
        PersistenceMode(PersistenceMode.Attribute), Description("Optional text to display while the data for the DropDownList is being loaded.")> _
        Public Property ChildDownLoadingText() As String
            Get
                If ViewState("ChildDownLoadingText") Is Nothing Then

                    Return String.Empty
                Else
                    Return ViewState("ChildDownLoadingText").ToString()
                End If
            End Get
            Set(ByVal value As String)
                ViewState("ChildDownLoadingText") = value
            End Set
        End Property

        <Category("CascadingDropDownList"), PersistenceMode(PersistenceMode.Attribute), _
        Bindable(True, BindingDirection.TwoWay)> _
        Public Property ChildDownBindValue() As String
            Get
                If ViewState("ChildDownBindValue") Is Nothing Then

                    Return String.Empty
                Else
                    Return ViewState("ChildDownBindValue").ToString()
                End If
            End Get
            Set(ByVal value As String)
                ViewState("ChildDownBindValue") = value
            End Set
        End Property

#End Region

        Protected Overrides Sub CreateChildControls()

            _parentDropDownList = New DropDownList()
            _parentDropDownList.ID = String.Concat(Me.ID, "_", "ParentDropDownList")

            AddHandler _parentDropDownList.TextChanged, AddressOf oParentDropDownList_TextChanged

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

            _childTopDropDownList = New DropDownList()
            _childTopDropDownList.ID = String.Concat(Me.ID, "_", "ChildTopDropDownList")

            AddHandler _childTopDropDownList.TextChanged, AddressOf oChildTopDropDownList_TextChanged

            Controls.Add(_childTopDropDownList)

            _childTopCascadingDropDown = New CascadingDropDown()
            _childTopCascadingDropDown.ID = String.Concat(Me.ID, "_", "ChildTopCascadingDropDown")
            _childTopCascadingDropDown.TargetControlID = _childTopDropDownList.ID
            _childTopCascadingDropDown.ParentControlID = _parentDropDownList.ID
            _childTopCascadingDropDown.PromptText = ChildTopPromptText
            _childTopCascadingDropDown.LoadingText = ChildTopLoadingText
            _childTopCascadingDropDown.Category = ChildTopCategory
            _childTopCascadingDropDown.ServicePath = ServicePath
            _childTopCascadingDropDown.ServiceMethod = ChildTopServiceMethod

            Controls.Add(_childTopCascadingDropDown)

            br = New HtmlGenericControl()
            br.InnerHtml = "<br />"
            Controls.Add(br)

            _childDownDropDownList = New DropDownList()
            _childDownDropDownList.ID = String.Concat(Me.ID, "_", "ChildDownDropDownList")

            AddHandler _childDownDropDownList.TextChanged, AddressOf oChildDownDropDownList_TextChanged

            Controls.Add(_childDownDropDownList)

            _childDownCascadingDropDown = New CascadingDropDown()
            _childDownCascadingDropDown.ID = String.Concat(Me.ID, "_", "ChildDownCascadingDropDown")
            _childDownCascadingDropDown.TargetControlID = _childDownDropDownList.ID
            _childDownCascadingDropDown.ParentControlID = _childTopDropDownList.ID
            _childDownCascadingDropDown.PromptText = ChildDownPromptText
            _childDownCascadingDropDown.LoadingText = ChildDownLoadingText
            _childDownCascadingDropDown.Category = ChildDownCategory
            _childDownCascadingDropDown.ServicePath = ServicePath
            _childDownCascadingDropDown.ServiceMethod = ChildDownServiceMethod

            Controls.Add(_childDownCascadingDropDown)
        End Sub

        Protected Sub oParentDropDownList_TextChanged(ByVal sender As Object, ByVal e As EventArgs)

            ParentBindValue = DirectCast(sender, DropDownList).SelectedValue
        End Sub

        Protected Sub oChildTopDropDownList_TextChanged(ByVal sender As Object, ByVal e As EventArgs)

            ChildTopBindValue = DirectCast(sender, DropDownList).SelectedValue
        End Sub

        Protected Sub oChildDownDropDownList_TextChanged(ByVal sender As Object, ByVal e As EventArgs)

            ChildDownBindValue = DirectCast(sender, DropDownList).SelectedValue
        End Sub

        Protected Overrides Sub OnPreRender(ByVal e As EventArgs)
            MyBase.OnPreRender(e)

            _parentCascadingDropDown.SelectedValue = ParentBindValue
            _childTopCascadingDropDown.SelectedValue = ChildTopBindValue
            _childDownCascadingDropDown.SelectedValue = ChildDownBindValue
        End Sub

    End Class

    Public Class CascadingDropDownListDesigner
        Inherits System.Web.UI.Design.ControlDesigner

        Public Overrides Function GetDesignTimeHtml() As String

            Dim sddl As CascadingDropDownList = DirectCast(Me.Component, CascadingDropDownList)
            Dim builder As New StringBuilder()

            builder.Append("<select name='{0}' id='{0}'>")
            builder.Append("<option value=''></option>")
            builder.Append("</select>")
            builder.Append("<br />")
            builder.Append("<select name='{0}' id='{0}'>")
            builder.Append("<option value=''></option>")
            builder.Append("</select>")
            builder.Append("<br />")
            builder.Append("<select name='{0}' id='{0}'>")
            builder.Append("<option value=''></option>")
            builder.Append("</select>")

            Return builder.ToString()
        End Function

    End Class

End Namespace