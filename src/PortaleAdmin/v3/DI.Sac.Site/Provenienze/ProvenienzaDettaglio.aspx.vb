Imports System.Web.UI.WebControls
Imports System
Imports System.Reflection
Imports System.Web.UI
Imports System.Diagnostics

Namespace DI.Sac.Admin

    Partial Public Class ProvenienzaDettaglio
        Inherits Page

        Private Shared ReadOnly _ClassName As String = String.Concat("Gestione.", MethodBase.GetCurrentMethod().ReflectedType.Name)

        Private _mode As String

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
          
            _mode = Request.Params("mode")

            If Not Page.IsPostBack Then
                '
                ' Set dello stato della FormView
                '
                If _mode IsNot Nothing Then

                    If _mode.ToString().Equals("insert") Then
                        MainFormView.DefaultMode = FormViewMode.Insert
                    ElseIf _mode.ToString().Equals("edit") Then
                        MainFormView.DefaultMode = FormViewMode.Edit
                    End If
                Else
                    LabelError.Visible = True
                    LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.ElaborazionePagina)
                End If
            End If
        End Sub

        Protected Sub PazienteDettaglioFormView_ItemCommand(ByVal sender As Object, ByVal e As FormViewCommandEventArgs) Handles MainFormView.ItemCommand
            If e.CommandName = DataControlCommands.CancelCommandName Then
                Response.Redirect("ProvenienzeLista.aspx", False)
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
                Response.Redirect("ProvenienzeLista.aspx", False)
            End If
        End Sub

        Protected Sub MainObjectDataSource_Inserted(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles MainObjectDataSource.Inserted

            If e.Exception IsNot Nothing Then

                ExceptionsManager.TraceException(e.Exception)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Inserimento)
                e.ExceptionHandled = True
            Else
                Response.Redirect("ProvenienzeLista.aspx", False)
            End If

        End Sub

        Protected Sub ProvenienzeUiUtentiListaObjectDataSource_Selected(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles ProvenienzeUiUtentiListaObjectDataSource.Selected

            If e.Exception IsNot Nothing Then

                ExceptionsManager.TraceException(e.Exception)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
                e.ExceptionHandled = True
            End If
        End Sub

    End Class
End Namespace