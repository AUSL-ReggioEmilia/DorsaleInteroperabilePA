Imports System
Imports System.Web.UI.WebControls
Imports System.Web.UI
Imports System.Reflection
Imports DI.Sac.Admin.Data.ConsensiUiDataSetTableAdapters


Namespace DI.Sac.Admin

    Partial Public Class ConsensoDettaglio
        Inherits Page

        Private Shared ReadOnly _className As String = MethodBase.GetCurrentMethod().ReflectedType.Name

        Private ReadOnly _roleConsensiDelete As Boolean = User.IsInRole(TypeRoles.ROLE_CONSENSI_DELETE.ToString())

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            Dim idPaziente As String = Request.Params("idPaziente")

            If Not Page.IsPostBack Then

                lnkIndietro.NavigateUrl = String.Format(lnkIndietro.NavigateUrl, idPaziente)

                HyperLinkStyle(lnkElimina, _roleConsensiDelete)
            End If
        End Sub

        Protected Sub lnkElimina_Click(ByVal sender As Object, ByVal e As EventArgs) Handles lnkElimina.Click
            Try
                Dim idConsenso As String = Request.Params("idConsenso")

                Using query As New ConsensiTableAdapter()
                    query.Delete(New Guid(idConsenso), User.Identity.Name)
                End Using

                Response.Redirect(String.Format(lnkIndietro.NavigateUrl, Request.Params("idPaziente")), False)

            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Eliminazione)
            End Try
        End Sub

        Protected Sub ConsensoDettaglioObjectDataSource_Selected(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles ConsensoDettaglioObjectDataSource.Selected

            If e.Exception IsNot Nothing Then

                ExceptionsManager.TraceException(e.Exception)

                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
                e.ExceptionHandled = True
            End If

        End Sub

        Protected Sub ConsensoDettaglioObjectDataSource_Deleted(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles ConsensoDettaglioObjectDataSource.Deleted

            If e.Exception IsNot Nothing Then

                ExceptionsManager.TraceException(e.Exception)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Eliminazione)
                e.ExceptionHandled = True
            End If
        End Sub

        Private Sub HyperLinkStyle(ByRef sender As HyperLink, ByVal enabled As Boolean)

            If enabled Then

                sender.Enabled = True
                sender.Text = sender.Text.Replace("_grey.gif", ".gif")
            Else
                sender.Enabled = False
                sender.Text = sender.Text.Replace(".gif", "_grey.gif")
            End If
        End Sub

        Private Sub HyperLinkStyle(ByRef sender As LinkButton, ByVal enabled As Boolean)

            If enabled Then

                sender.Enabled = True
                sender.Text = sender.Text.Replace("_grey.gif", ".gif")
            Else
                sender.Enabled = False
                sender.Text = sender.Text.Replace(".gif", "_grey.gif")
                sender.OnClientClick = String.Empty
            End If
        End Sub


        ''' <summary>
        ''' Funzione usata nella parte ASPX per visualizzare gli attributi
        ''' </summary>
        ''' <param name="oAttributi"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Protected Function ShowAttributi(oAttributi As Object) As String
            Return Utility.ShowAttributi(oAttributi)
        End Function

    End Class

End Namespace