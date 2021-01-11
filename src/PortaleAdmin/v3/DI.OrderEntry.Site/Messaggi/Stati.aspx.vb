Imports System
Imports System.Web.UI
Imports System.Data

Imports DI.OrderEntry.Admin.Data
Imports DI.OrderEntry.Admin.Data.Messaggi

Imports System.Web.UI.WebControls
Imports System.Data.SqlTypes
Imports System.Web.Services
Imports System.Xml
Imports System.Xml.Xsl
Imports System.IO
Imports System.Text
Imports System.Web
Imports DI.Common

Namespace DI.OrderEntry.Admin

    Public Class Stati
        Inherits Page

        Private Const PageSessionIdPrefix As String = "MessaggiStati_"

        Private Property PageIndex() As Integer
            Get
                Dim sessionItem As Object = Session(PageSessionIdPrefix + "PageIndex")
                If sessionItem Is Nothing Then Return 0 Else Return DirectCast(sessionItem, Integer)
            End Get
            Set(ByVal value As Integer)
                Session(PageSessionIdPrefix + "PageIndex") = value
            End Set
        End Property

        Private Property SortExpression() As String
            Get
                Dim sessionItem As Object = Session(PageSessionIdPrefix + "SortExpression")
                If sessionItem Is Nothing Then Return String.Empty Else Return sessionItem.ToString()
            End Get
            Set(ByVal value As String)
                Session(PageSessionIdPrefix + "SortExpression") = value
            End Set
        End Property

        Private Property SortDirection() As SortDirection
            Get
                Dim sessionItem As Object = Session(PageSessionIdPrefix + "SortDirection")
                If sessionItem Is Nothing Then Return Nothing Else Return DirectCast(sessionItem, SortDirection)
            End Get
            Set(ByVal value As SortDirection)
                Session(PageSessionIdPrefix + "SortDirection") = value
            End Set
        End Property

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            If Not Page.IsPostBack Then

                Dim id = Request.QueryString("Id")

                If Not String.IsNullOrEmpty(id) Then

                    Me.PeriodoInserimentoDropDownList.SelectedValue = " "
                    Me.StatoDropDownList.SelectedValue = " "
                End If

                MainObjectDataSource.SelectParameters("dataModificaDa").DefaultValue = SqlDateTime.MinValue
                MainObjectDataSource.SelectParameters("dataModificaA").DefaultValue = DateTime.MaxValue

                StatiGridView.Sort(SortExpression, SortDirection)
                StatiGridView.PageIndex = PageIndex
            Else
                SaveFilters()

                Me.DataBind()
            End If

            LoadFilters()
        End Sub

        Private Sub MainObjectDataSource_Selecting(ByVal sender As Object, ByVal e As ObjectDataSourceSelectingEventArgs) Handles MainObjectDataSource.Selecting

            Dim codiceAzienda = e.InputParameters("codiceAziendaRichiedente").ToString()

            If codiceAzienda = " " Then
                e.InputParameters("codiceAziendaRichiedente") = Nothing
            End If

            Dim stato = DirectCast(filterPanel.FindControl("StatoDropDownList"), DropDownList).SelectedValue

            If stato = " " Then
                e.InputParameters("Stato") = Nothing
            Else
                e.InputParameters("Stato") = Byte.Parse(stato)
            End If

            Dim periodo = DirectCast(filterPanel.FindControl("PeriodoInserimentoDropDownList"), DropDownList).SelectedValue

            If periodo <> " " Then

                e.InputParameters("dataModificaDa") = Utility.GetDataDaPerFiltro(periodo)
                e.InputParameters("dataModificaA") = DateTime.Now
            End If
        End Sub

        Private Sub LoadFilters()

            For Each control As Control In filterPanel.Controls

                Dim value As String = If(String.IsNullOrEmpty(control.ID), String.Empty, Session(PageSessionIdPrefix + control.ID))

                If value Is Nothing Then
                    Continue For
                End If

                Dim filterTextBox = TryCast(control, TextBox)

                If filterTextBox IsNot Nothing Then

                    filterTextBox.Text = value
                Else
                    Dim filterComboBox = TryCast(control, DropDownList)

                    If filterComboBox IsNot Nothing Then

                        filterComboBox.SelectedValue = value
                    End If
                End If
            Next
        End Sub

        Private Sub SaveFilters()

            For Each control As Control In filterPanel.Controls

                If String.IsNullOrEmpty(control.ID) Then
                    Continue For
                End If

                Dim value As String = String.Empty

                Dim filterTextBox = TryCast(control, TextBox)

                If filterTextBox IsNot Nothing Then

                    value = filterTextBox.Text
                Else
                    Dim filterComboBox = TryCast(control, DropDownList)

                    If filterComboBox IsNot Nothing Then

                        value = filterComboBox.SelectedValue
                    End If
                End If

                If Session(PageSessionIdPrefix + control.ID) Is Nothing Then

                    Session.Add(PageSessionIdPrefix + control.ID, value)
                Else
                    Session(PageSessionIdPrefix + control.ID) = value
                End If
            Next
        End Sub

        Private Sub StatiGridView_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles StatiGridView.RowDataBound

            If (e.Row.RowType = DataControlRowType.Header) Then

                Dim cellIndex = -1
                For Each field As DataControlField In StatiGridView.Columns

                    e.Row.Cells(StatiGridView.Columns.IndexOf(field)).CssClass = "GridHeader"

                    If field.SortExpression = StatiGridView.SortExpression AndAlso StatiGridView.SortExpression.Length > 0 Then

                        cellIndex = StatiGridView.Columns.IndexOf(field)
                    End If
                Next

                If cellIndex > -1 Then

                    e.Row.Cells(cellIndex).CssClass = If(StatiGridView.SortDirection = SortDirection.Ascending, "GridHeaderSortAsc", "GridHeaderSortDesc")
                End If
            End If
        End Sub

        Protected Sub RichiesteGridView_Sorted(sender As Object, e As EventArgs) Handles StatiGridView.Sorted

            Me.SortExpression = StatiGridView.SortExpression
            Me.SortDirection = StatiGridView.SortDirection
        End Sub

        Protected Sub RichiesteGridView_PageIndexChanged(sender As Object, e As EventArgs) Handles StatiGridView.PageIndexChanged

            Me.PageIndex = StatiGridView.PageIndex
        End Sub

        <WebMethod()> _
        Public Shared Function GetMessaggioOriginale(ByVal id As String) As String

            Dim guid As Guid?

            If Not Utility.TryParseStringToGuid(id, guid) Then
                Return String.Empty
            End If

            Dim dataTable As New UiMessaggiStatiSelectDataTable()

            DataAdapterManager.Fill(dataTable, guid.Value)

            If dataTable.Count > 0 Then

                If dataTable(0).Messaggio.Length = 0 Then
                    Return My.Resources.NoDettaglio
                End If

                Dim xslTransform As New XslCompiledTransform()

                xslTransform.Load(HttpContext.Current.Server.MapPath("~/Styles/XmlView.xslt"))

                Using memoryStream As New MemoryStream()

                    Dim document As New XmlDocument()
                    document.LoadXml(dataTable(0).Messaggio)

                    Dim xmlTextWriter As New XmlTextWriter(memoryStream, Encoding.UTF8)

                    xslTransform.Transform(document.CreateNavigator(), xmlTextWriter)
                    memoryStream.Position = 0

                    Return Encoding.UTF8.GetString(memoryStream.ToArray())
                End Using
            Else
                Return My.Resources.NoDettaglio
            End If
        End Function

        Private Sub ClearFilterButton_Click(sender As Object, e As EventArgs) Handles ClearFilterButton.Click

            Me.StatoDropDownList.SelectedIndex = -1
            Me.StatoDropDownList.SelectedValue = 2

            Me.PageIndex = 0
            Me.StatiGridView.Sort(String.Empty, SortDirection.Ascending)
            Me.SortExpression = String.Empty
            Me.SortDirection = SortDirection.Ascending

            Me.DataBind()
        End Sub
    End Class

End Namespace