Imports System
Imports System.Web.UI
Imports System.Data

Imports System.Web.UI.WebControls
Imports System.Data.SqlTypes
Imports System.Web.Services
Imports System.Text
Imports System.Web

'Imports DI.Common
Imports DI.PortalAdmin.Data
Imports System.Collections
Imports DI.DataWarehouse.Admin.Data
Imports System.Configuration

Namespace DI.DataWarehouse.Admin

    Public Class AbbonamentiStampe
        Inherits Page

        Private Const PageSessionIdPrefix As String = "AbbonamentiStampe_"

        Dim mbObjectDataSource_CancelSelect As Boolean = True

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
            Try
                Me.Form.DefaultButton = Me.SearchButton.UniqueID
                If Not Page.IsPostBack Then
                    StampeGridView.Sort(SortExpression, SortDirection)
                    StampeGridView.PageIndex = PageIndex
                    StampeGridView.EmptyDataText = ""

                    LoadFilters()
                    'se almeno un filtro è valorizzato dopo il LoadFilters
                    'allora posso lanciare la ricerca
                    If ValidateFilters() Then
                        mbObjectDataSource_CancelSelect = False
                        StampeGridView.EmptyDataText = "Nessun risultato!"
                    End If
                Else
                    StampeGridView.EmptyDataText = "Nessun risultato!"
                End If

            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub


        Private Property PageIndex() As Integer
            Get
                Dim o As Object = Session(PageSessionIdPrefix + "PageIndex")
                If o Is Nothing Then Return 0 Else Return DirectCast(o, Integer)
            End Get
            Set(ByVal value As Integer)
                Session(PageSessionIdPrefix + "PageIndex") = value
            End Set
        End Property

        Private Property SortExpression() As String
            Get
                Dim o As Object = Session(PageSessionIdPrefix + "SortExpression")
                If o Is Nothing Then Return String.Empty Else Return o.ToString()
            End Get
            Set(ByVal value As String)
                Session(PageSessionIdPrefix + "SortExpression") = value
            End Set
        End Property

        Private Property SortDirection() As SortDirection
            Get
                Dim o As Object = Session(PageSessionIdPrefix + "SortDirection")
                If o Is Nothing Then Return Nothing Else Return DirectCast(o, SortDirection)
            End Get
            Set(ByVal value As SortDirection)
                Session(PageSessionIdPrefix + "SortDirection") = value
            End Set
        End Property

        Protected Shared Function GetCambiaAttivazioneButtonText(ByVal idStato As Object) As String

            Select Case idStato
                Case 3
                    Return "Attiva"
                Case 1
                    Return "Disattiva"
                Case Else
                    Return String.Empty
            End Select

        End Function


        Protected Function GetChecked(ByVal StampaConfidenziali As Object) As String
            Dim bStampaConfidenziali As Boolean = CType(StampaConfidenziali, Boolean)
            If bStampaConfidenziali Then
                Return Me.ResolveUrl("~/Images/ok.png")
            Else
                Return Me.ResolveUrl("~/Images/PixelTrasparente.gif")
            End If
        End Function

		Private Sub RefertiListaObjectDataSource_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles RefertiListaObjectDataSource.Selected
			ObjectDataSource_TrapError(sender, e)
		End Sub

        Private Sub MainObjectDataSource_Selecting(ByVal sender As Object, ByVal e As ObjectDataSourceSelectingEventArgs) Handles RefertiListaObjectDataSource.Selecting
            Try
                e.Cancel = mbObjectDataSource_CancelSelect

                If Not mbObjectDataSource_CancelSelect Then
                    Dim text = "Lista Referti|Parametri: "
                    For Each item As DictionaryEntry In e.InputParameters
                        If item.Value IsNot Nothing Then
                            text &= item.Key & "=" & item.Value.ToString() & "; "
                        End If
                    Next
                    DataAdapterManager.PortalAdminDataAdapterManager.TracciaAccessi(User.Identity.Name, PortalsNames.DwhClinico, text)

                    'default combo
                    Dim comboParameters = New String() {"IdStato", "IdTipoReferti"}
                    For Each comboParameter In comboParameters
                        Dim idStato As String = e.InputParameters(comboParameter).ToString()
                        If idStato = "-1" Then
                            e.InputParameters(comboParameter) = Nothing
                        End If
                    Next
                End If
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Protected Sub StampeGridView_RowDataBound(ByVal sender As Object, ByVal e As GridViewRowEventArgs) Handles StampeGridView.RowDataBound
            Try
                If e.Row.RowType = DataControlRowType.Header Then
                    Dim cellIndex = -1
                    For Each field As DataControlField In StampeGridView.Columns
                        e.Row.Cells(StampeGridView.Columns.IndexOf(field)).CssClass = "GridHeader"
                        If field.SortExpression = StampeGridView.SortExpression AndAlso StampeGridView.SortExpression.Length > 0 Then
                            cellIndex = StampeGridView.Columns.IndexOf(field)
                        End If
                    Next

                    If cellIndex > -1 Then
                        e.Row.Cells(cellIndex).CssClass = If(StampeGridView.SortDirection = SortDirection.Ascending, "GridHeaderSortAsc", "GridHeaderSortDesc")
                    End If
                ElseIf e.Row.RowType = DataControlRowType.DataRow Then
                    e.Row.Attributes("idSottoscrizione") = DirectCast(e.Row.DataItem, DataRowView)("Id").ToString()
                End If
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
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

        Private Function ValidateFilters() As Boolean

            Return NomeTextBox.Text.Length > 0 OrElse
                   AccountTextBox.Text.Length > 0 OrElse
                   DataFineAlTextBox.Text.Length > 0 OrElse
                   TipoRefertoDropDownList.SelectedItem IsNot Nothing OrElse
                   ServerDiStampaTextBox.Text.Length > 0 OrElse
                   StampanteTextBox.Text.Length > 0 OrElse
                   StatoDropDownList.SelectedItem IsNot Nothing

        End Function

        Protected Sub StampeGridView_Sorted(sender As Object, e As EventArgs) Handles StampeGridView.Sorted
            Me.SortExpression = StampeGridView.SortExpression
            Me.SortDirection = StampeGridView.SortDirection
            'consento la riesecuzione della select dopo il postback solo se l'utente ha impostato un filtro
            mbObjectDataSource_CancelSelect = Not Page.IsPostBack
        End Sub

        Protected Sub StampeGridView_PageIndexChanged(sender As Object, e As EventArgs) Handles StampeGridView.PageIndexChanged
            Me.PageIndex = StampeGridView.PageIndex
        End Sub

        Private Sub StampeGridView_PageIndexChanging(sender As Object, e As GridViewPageEventArgs) Handles StampeGridView.PageIndexChanging
            'Abilito object data source ad eseguire la query
            mbObjectDataSource_CancelSelect = False
        End Sub

        Protected Sub SearchButton_Click(sender As Object, e As EventArgs) Handles SearchButton.Click
            SaveFilters()
            mbObjectDataSource_CancelSelect = False
            StampeGridView.DataBind()
        End Sub

#Region "<WebMethod()>"

        <WebMethod()>
        Public Shared Function CancellaSottoscrizione(id As String) As String
            Try
                DataAdapterManager.DeleteSottoscrizione(New Guid(id))
                Return "ok"
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Return "error"
            End Try
        End Function

        <WebMethod()>
        Public Shared Function CambiaStatoAttivazioneSottoscrizione(id As String) As String
            Try
                DataAdapterManager.ChangeActivationState(New Guid(id))
                Return "ok"
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Return "error"
            End Try
        End Function
#End Region


#Region "Funzioni"

		''' <summary>
		''' Gestisce gli errori del ObjectDataSource in maniera pulita
		''' </summary>
		''' <returns>True se si è verificato un errore</returns>
		Private Function ObjectDataSource_TrapError(ods As ObjectDataSourceView, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) As Boolean
			Try
				If e.Exception IsNot Nothing AndAlso e.Exception.InnerException IsNot Nothing Then
					Utility.ShowErrorLabel(LabelError, GestioneErrori.TrapError(e.Exception.InnerException))
					e.ExceptionHandled = True
					Return True
				Else
					Return False
				End If
			Catch ex As Exception
				Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
				Utility.ShowErrorLabel(LabelError, sErrorMessage)
				Return True
			End Try

		End Function



#End Region

    End Class

End Namespace