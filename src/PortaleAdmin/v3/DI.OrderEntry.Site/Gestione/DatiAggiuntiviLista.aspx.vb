Imports System
Imports System.Web.UI

Namespace DI.OrderEntry.Admin

	Public Class DatiAggiuntiviLista
		Inherits Page

		Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

		Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

			Form.DefaultButton = CercaButton.UniqueID

			If Not Page.IsPostBack Then
				FilterHelper.Restore(filterPanel, msPAGEKEY)
			End If

		End Sub

		Private Sub ObjectDataSourceMain_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles ObjectDataSourceMain.Selected
			If e.Exception Is Nothing Then
				FilterHelper.SaveInSession(filterPanel, msPAGEKEY)
			End If
		End Sub



	End Class

End Namespace