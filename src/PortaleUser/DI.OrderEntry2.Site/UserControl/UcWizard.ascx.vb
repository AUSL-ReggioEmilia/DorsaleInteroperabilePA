Imports System.Web.UI
Imports System.Web.UI.HtmlControls
Imports System.Web.UI.WebControls

Public Class UcWizard
	Inherits System.Web.UI.UserControl

	Public Property CurrentStep() As Integer
		Get
			Return Me.ViewState("CurrentStep")
		End Get
		Set(ByVal value As Integer)
			Me.ViewState.Add("CurrentStep", value)
		End Set
	End Property

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
		Try
			Dim listWizard As UI.ControlCollection = wizardList.Controls
			If Me.CurrentStep = 1 Then divTitle.Visible = False
			Dim currentStep As Integer = Me.CurrentStep - 1
			lnk1.Attributes.Add("href", "#")
			lnk2.Attributes.Add("href", "#")
			lnk3.Attributes.Add("href", "#")
			lnk4.Attributes.Add("href", "#")
			If listWizard IsNot Nothing AndAlso listWizard.Count > 0 Then

				'Disabilito gli step successivi
				For index = Me.CurrentStep To 4
					Dim nextA As LinkButton = wizardList.FindControl("lnk" & index.ToString)
					nextA.CssClass = "disabled"
				Next

				'Aggiungo la classe "list-group-item-success" agli step completati.
				For index = 1 To Me.CurrentStep
					Dim nextA As LinkButton = wizardList.FindControl("lnk" & index.ToString)
					nextA.CssClass = "list-group-item-success"
				Next

				'Aggiungo la classe "list-group-item-warning" allo step corrente.
				Dim currentA As LinkButton = wizardList.FindControl("lnk" & Me.CurrentStep.ToString)
				currentA.CssClass = "list-group-item-warning"
			End If
		Catch ex As Exception

		End Try
	End Sub

End Class