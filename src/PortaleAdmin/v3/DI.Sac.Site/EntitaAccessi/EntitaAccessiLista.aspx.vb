Imports System
Imports System.Diagnostics
Imports System.Collections
Imports System.Web.UI.WebControls
Imports System.Reflection
Imports System.Web.UI

Namespace DI.Sac.Admin

    Partial Public Class EntitaAccessiLista
        Inherits Page

        Private Shared ReadOnly _className As String = String.Concat("Gestione.", MethodBase.GetCurrentMethod().ReflectedType.Name)

		Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
			Dim a = 0

		End Sub

        Protected Function ConfirmDelete(Dominio As Object, Utente As Object, Tipo As Object) As String
            Dim sMessage As String = "return confirm('Procedere con l\'eliminazione?');"
            If (Not Dominio Is DBNull.Value) AndAlso (Not Utente Is DBNull.Value) AndAlso (Not Tipo Is DBNull.Value) Then
                If CType(Tipo, Integer) = 1 Then 'Gruppo
                    sMessage = String.Format("return confirm('Procedere con l\'eliminazione del gruppo {0}\\{1}?');", CType(Dominio, String), CType(Utente, String))
                Else
                    sMessage = String.Format("return confirm('Procedere con l\'eliminazione dell\'utente {0}\\{1}?');", CType(Dominio, String), CType(Utente, String))
                End If
            End If
            Return sMessage
        End Function

        Protected Sub gvEntitaAccessi_RowCommand(ByVal sender As Object, ByVal e As GridViewCommandEventArgs) Handles gvEntitaAccessi.RowCommand

            If e.CommandName = DataControlCommands.DeleteCommandName OrElse e.CommandName = DataControlCommands.UpdateCommandName Then

                ' Nome,Dominio,Tipo
                Dim oValues As String() = e.CommandArgument.ToString().Split(","c)

                RolesHelper.ResetRolesCache(oValues(0), oValues(1), CByte(oValues(2)))
            End If
        End Sub

        Protected Sub MainObjectDataSource_Selected(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles MainObjectDataSource.Selected

            If e.Exception IsNot Nothing Then
                'ExceptionsManager.TraceException(e.Exception)
                'LabelError.Visible = True
                'LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
                Dim ex As Exception = e.Exception.InnerException
                If ex Is Nothing Then ex = e.Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
                e.ExceptionHandled = True
            End If
        End Sub

        Protected Sub MainObjectDataSource_Updated(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles MainObjectDataSource.Updated

            If e.Exception IsNot Nothing Then
                'ExceptionsManager.TraceException(e.Exception)
                'LabelError.Visible = True
                'LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Aggiornamento)
                Dim ex As Exception = e.Exception.InnerException
                If ex Is Nothing Then ex = e.Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If

                e.ExceptionHandled = True
            End If
        End Sub

        Protected Sub MainObjectDataSource_Deleted(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles MainObjectDataSource.Deleted

            If e.Exception IsNot Nothing Then
                'ExceptionsManager.TraceException(e.Exception)
                'LabelError.Visible = True
                'LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Eliminazione)
                Dim ex As Exception = e.Exception.InnerException
                If ex Is Nothing Then ex = e.Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
                e.ExceptionHandled = True
            End If
        End Sub

		
	End Class

End Namespace
