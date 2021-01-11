Imports System.Diagnostics
Imports System
Imports System.Web.UI.WebControls
Imports System.Reflection

Namespace DI.Sac.Admin

    Partial Public Class UtenteDettaglio
        Inherits System.Web.UI.Page

		Protected Function GetLink(DetailPage As Object, Id As Object) As String
			Dim sId As String = If(Id Is DBNull.Value, "", Id.ToString)
			Return Utility.IsNull(DetailPage, "") & "?Id=" & sId & "&Utente=" & Request.Params("Utente").ToString
		End Function

        Protected Sub PazienteDettaglioFormView_ItemCommand(ByVal sender As Object, ByVal e As FormViewCommandEventArgs) Handles MainFormView.ItemCommand
            If e.CommandName = DataControlCommands.CancelCommandName Then
                Response.Redirect("UtentiLista.aspx", False)
            End If
        End Sub

        Protected Sub MainObjectDataSource_Selected(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles MainObjectDataSource.Selected

            If e.Exception IsNot Nothing Then

                ExceptionsManager.TraceException(e.Exception)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
                e.ExceptionHandled = True
            End If
        End Sub

        Protected Sub MainObjectDataSource_Updated(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles MainObjectDataSource.Updated

            If e.Exception IsNot Nothing Then

                ExceptionsManager.TraceException(e.Exception)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Aggiornamento)
                e.ExceptionHandled = True
            Else
                Response.Redirect("UtentiLista.aspx", False)
            End If
        End Sub

        Protected Sub UtentiServiziListaObjectDataSource_Selected(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles UtentiServiziListaObjectDataSource.Selected

			If e.Exception IsNot Nothing Then
				ExceptionsManager.TraceException(e.Exception)
				LabelError.Visible = True
				LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
				e.ExceptionHandled = True
			End If
        End Sub

    End Class

End Namespace