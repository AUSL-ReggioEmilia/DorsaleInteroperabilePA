Imports System.Web.UI
Imports System
Imports System.Data
Imports System.Web.UI.WebControls

Namespace DI.DataWarehouse.Admin

    Partial Class SistemiErogantiDocumentiLista
        Inherits Page

        Private _pageId As String
        Private _cancelSelectOperation As Boolean

#Region "Registrazione script lato client"

        Protected Overrides Sub OnPreRender(ByVal e As EventArgs)

            If Not ClientScript.IsClientScriptBlockRegistered(Me.GetType.Name) Then

                ClientScript.RegisterClientScriptBlock(GetType(Page), Me.GetType.Name, Constants.JSBuildScript(Constants.JSOpenWindowFunction() & Environment.NewLine))
            End If
        End Sub

#End Region

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
            Try
                Me.Form.DefaultButton = Me.SearchButton.UniqueID
                _pageId = Me.GetType.Name
                If Not IsPostBack Then
                    LoadFilterValues()
                    ExecuteSearch()
                End If
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Protected Sub CercaButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles SearchButton.Click

            ExecuteSearch()
        End Sub

        Protected Sub DataSourceMain_Selected(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles DataSourceMain.Selected

			If Not ObjectDataSource_TrapError(sender, e) AndAlso DirectCast(e.ReturnValue, DataTable).Rows.Count = 0 Then
				If IsPostBack Then
					Utility.ShowErrorLabel(NoRecordFoundLabel, "Non è stato trovato nessun record.")
				End If
			End If
        End Sub

        Protected Sub DataSourceMain_Selecting(ByVal sender As Object, ByVal e As ObjectDataSourceSelectingEventArgs) Handles DataSourceMain.Selecting

            If _cancelSelectOperation Then
                e.Cancel = True
            End If
        End Sub

        Private Sub ExecuteSearch()
            Try
                DataSourceMain.SelectParameters("AziendaErogante").DefaultValue = AziendaEroganteTextBox.Text
                GridViewMain.DataBind()
                SaveFilterValues()
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Private Sub LoadFilterValues()
            AziendaEroganteTextBox.Text = CStr(Me.Session(_pageId & AziendaEroganteTextBox.ID))
        End Sub

        Private Sub SaveFilterValues()
            Me.Session(_pageId & AziendaEroganteTextBox.ID) = AziendaEroganteTextBox.Text
        End Sub

        Protected Sub NewButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles NewButton.Click

            Response.Redirect(Me.ResolveUrl("~/Pages/SistemiErogantiDocumentiDettaglio.aspx"), False)
        End Sub

        Protected Function GetViewerUrl(ByVal idDocumento As Object) As String

            If idDocumento IsNot DBNull.Value Then
                Return String.Format("{0}?{1}={2}&{3}={4}", Me.ResolveUrl("~/DocumentViewer.ashx"), Constants.IdDocument, idDocumento, Constants.DocumentTableName, "SistemiErogantiDocumenti")
            Else
                Return Nothing
            End If
        End Function

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