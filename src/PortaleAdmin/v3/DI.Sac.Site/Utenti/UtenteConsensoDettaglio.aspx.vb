Imports System.Web.UI.WebControls
Imports System
Imports System.Reflection
Imports System.Web.UI
Imports System.Diagnostics
Imports System.Web

Namespace DI.Sac.Admin

	Partial Public Class UtenteConsensoDettaglio
		Inherits Page

		Private sUtente As String
		Private sBACKPAGE As String

		Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

			If Request.QueryString("Utente") Is Nothing Then
				LabelError.Visible = True
				LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.ElaborazionePagina)
			Else
				sUtente = Request.QueryString("Utente").ToString
				sBACKPAGE = "UtenteDettaglio.aspx?utente=" & sUtente
			End If

			If Not Page.IsPostBack Then
				If String.IsNullOrEmpty(Request.QueryString("Id")) Then
					MainFormView.DefaultMode = FormViewMode.Insert
				Else
					MainFormView.DefaultMode = FormViewMode.Edit
				End If
				'
				' Modifico url del nodo padre nel menu orizzontale
				'
				If Not SiteMap.CurrentNode Is Nothing Then
					Call Utility.SetSiteMapNodeQueryString(SiteMap.CurrentNode.ParentNode, String.Format("utente={0}", Request.QueryString("Utente").ToString))
				End If

			Else
				LabelError.Visible = True
				LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.ElaborazionePagina)
			End If

		End Sub

		Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
			If MainFormView.CurrentMode = FormViewMode.Insert Then
				Dim lblUtente As Label = MainFormView.FindControl("lblUtente")
				lblUtente.Text = sUtente
			End If
		End Sub

		Protected Sub PazienteDettaglioFormView_ItemCommand(ByVal sender As Object, ByVal e As FormViewCommandEventArgs) Handles MainFormView.ItemCommand

			If e.CommandName = DataControlCommands.CancelCommandName Then
				Response.Redirect(sBACKPAGE, False)
			End If
		End Sub

		Private Sub MainObjectDataSource_Inserting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceMethodEventArgs) Handles MainObjectDataSource.Inserting
			e.InputParameters("IngressoAck") = False
			e.InputParameters("NotificheAck") = False
		End Sub

		Private Sub MainObjectDataSource_Updating(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceMethodEventArgs) Handles MainObjectDataSource.Updating
			e.InputParameters("IngressoAck") = False
			e.InputParameters("NotificheAck") = False
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
				Response.Redirect(sBACKPAGE, False)
			End If
		End Sub

		Protected Sub MainObjectDataSource_Inserted(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles MainObjectDataSource.Inserted

			If e.Exception IsNot Nothing Then
				ExceptionsManager.TraceException(e.Exception)
				LabelError.Visible = True
				LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Inserimento)
				e.ExceptionHandled = True
			Else
				Response.Redirect(sBACKPAGE, False)
			End If
		End Sub


	End Class

End Namespace