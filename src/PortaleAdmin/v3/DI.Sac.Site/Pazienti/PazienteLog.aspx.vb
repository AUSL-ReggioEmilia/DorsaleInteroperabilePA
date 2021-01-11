Imports System.Web.UI
Imports System
Imports System.Web.UI.HtmlControls
Imports System.Diagnostics
Imports System.Web.UI.WebControls
Imports DI.Common
Imports System.Reflection
Imports System.Drawing
Imports DI.Sac.Admin.Data.PazientiDataSet

Namespace DI.Sac.Admin

    Partial Public Class PazienteLog
        Inherits Page

        Private Shared ReadOnly _className As String = String.Concat("Gestione.", MethodBase.GetCurrentMethod().ReflectedType.Name)

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            If Not Page.IsPostBack Then

                LoadGridViewPagingAndSorting()
            End If
        End Sub

#Region "Config DataGrid"

        Protected Sub LoadGridViewPagingAndSorting()

            PazientiNotificheGridView.Sort(SortExpression, SortDirection)
            PazientiNotificheGridView.PageIndex = PageIndex
        End Sub

        Protected Sub gvPazienti_PageIndexChanged(ByVal sender As Object, ByVal e As EventArgs) Handles PazientiNotificheGridView.PageIndexChanged

            PageIndex = PazientiNotificheGridView.PageIndex
        End Sub

        Protected Sub gvPazienti_Sorted(ByVal sender As Object, ByVal e As EventArgs) Handles PazientiNotificheGridView.Sorted

            SortExpression = PazientiNotificheGridView.SortExpression
            SortDirection = PazientiNotificheGridView.SortDirection
        End Sub

        Private Property PageIndex() As Integer
            Get
                Dim index As Object = ViewState("PageIndex")
                If index Is Nothing Then Return 0 Else Return DirectCast(index, Integer)
            End Get
            Set(ByVal value As Integer)
                ViewState("PageIndex") = value
            End Set
        End Property

        Private Property SortExpression() As String
            Get
                Dim expression As Object = ViewState("SortExpression")
                If expression Is Nothing Then Return String.Empty Else Return expression.ToString()
            End Get
            Set(ByVal value As String)
                ViewState("SortExpression") = value
            End Set
        End Property

        Private Property SortDirection() As SortDirection
            Get
                Dim direction As Object = ViewState("SortDirection")
                If direction Is Nothing Then Return Nothing Else Return DirectCast(direction, SortDirection)
            End Get
            Set(ByVal value As SortDirection)
                ViewState("SortDirection") = value
            End Set
        End Property
#End Region

    End Class

End Namespace