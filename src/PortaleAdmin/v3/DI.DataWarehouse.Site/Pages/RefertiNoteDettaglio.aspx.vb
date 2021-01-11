Imports System
Imports System.Web.UI
Imports DI.DataWarehouse.Admin.Data
Imports DI.DataWarehouse.Admin.Data.BackEndDataSet
Imports System.Web.UI.WebControls

Namespace DI.DataWarehouse.Admin

    Partial Class RefertiNoteDettaglio
        Inherits Page

        Private Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles MyBase.Load
            Try
                If Not IsPostBack Then

                    If String.IsNullOrEmpty(Request.QueryString(Constants.Id)) Then
                        ReturnToList()
                    End If

                    Me.DataBind()
                End If
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Private Sub RemoveButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles RemoveButton.Click
            Try
                Me.NoteObjectDataSource.Delete()
                ReturnToList()
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Private Sub ReturnToList()
            Try
                Response.Redirect("../Pages/RefertiNoteLista.aspx", False)
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Protected Sub NoteObjectDataSource_Deleting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles NoteObjectDataSource.Deleting
            Try
                e.InputParameters("id") = New Guid(Request.QueryString(Constants.Id))
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Private Sub NoteObjectDataSource_Deleted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles NoteObjectDataSource.Deleted
            ObjectDataSource_TrapError(sender, e)
        End Sub

		Private Sub NoteObjectDataSource_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles NoteObjectDataSource.Selected
			ObjectDataSource_TrapError(sender, e)
		End Sub


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