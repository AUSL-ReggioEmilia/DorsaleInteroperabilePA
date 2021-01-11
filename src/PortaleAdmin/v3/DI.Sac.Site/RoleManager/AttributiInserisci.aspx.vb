Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin
Imports OrganigrammaDataSetTableAdapters
Imports System.Web.UI
Imports System.Collections.Generic

Public Class AttributiInserisci
	Inherits System.Web.UI.Page
	Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
	Private mgIDRuolo As Guid
	Private mbErroreSalvataggio As Boolean = False
	Private mbDDLAttributi_CanSelect As Boolean = False

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

		Try
			If Request.QueryString("Id") Is Nothing Then
				Throw New ApplicationException("Parametro Id assente")
			Else
				mgIDRuolo = New Guid(Request.QueryString("ID").ToString)
			End If
		
			If Not Page.IsPostBack Then
				Using ta As New RuoliTableAdapter()
					Using dt As OrganigrammaDataSet.RuoliDataTable = ta.GetData(mgIDRuolo)
						If dt.Rows.Count = 1 Then
							Dim dr As OrganigrammaDataSet.RuoliRow = dt.Rows(0)
							lblTitolo.Text = "Aggiunta Accessi al Ruolo: " & dr.Codice & " - " & dr.Descrizione
						Else
							Utility.ShowErrorLabel(LabelError, "Ruolo " & mgIDRuolo.ToString & " non trovato!")
						End If
					End Using
				End Using
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub


	Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
		Try
			mbDDLAttributi_CanSelect = True

			If Page.IsPostBack And mbErroreSalvataggio Then
				FilterHelper.Restore(FormViewDettaglio, msPAGEKEY)
			End If
			'
			' PREDISPONE L'INTERFACCIA GRAFICA
			'
			TipoRuolo_OptionChanged(Nothing, Nothing)
			'
			' RICARICO LA DROPDOWN CON GLI ATTRIBUTI SPECIFICI PER QUEL TIPO
			'
			Dim ddlCodice As DropDownList = FormViewDettaglio.FindControl("ddlCodice")
			Dim sSelVal As String = ddlCodice.SelectedValue
			ddlCodice.DataBind()
			Try ' SE POSSIBILE RISELEZIONO L'ELEMENTO PRECEDENTE AL DATABIND
				ddlCodice.SelectedValue = sSelVal
			Catch
			End Try

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub


	' AGGIUNGO ALLA DROPDOWN CODICE ATTRIBUTO UN ELEMENTO VUOTO
	Sub ddlCodice_DataBound(sender As Object, ByVal e As System.EventArgs)

		Dim ddlCodiciAttr As DropDownList = DirectCast(sender, DropDownList)
		ddlCodiciAttr.Items.Insert(0, New ListItem("", ""))

	End Sub

	Private Sub FormViewDettaglio_ItemInserted(sender As Object, e As FormViewInsertedEventArgs) Handles FormViewDettaglio.ItemInserted
		e.KeepInInsertMode = True
	End Sub

	Sub TipoRuolo_OptionChanged(sender As Object, e As EventArgs)
		Try
			Dim rblTipoAtt As RadioButtonList = If(sender Is Nothing, FormViewDettaglio.FindControl("rblTipiAttributo"), sender)
			Dim ddlSistemi As DropDownList = FormViewDettaglio.FindControl("ddlSistemi")
			Dim ddlUnità As DropDownList = FormViewDettaglio.FindControl("ddlUnità")
			Dim reqddlSistemi As RequiredFieldValidator = FormViewDettaglio.FindControl("Required_ddlSistemi")
			Dim reqddlUnità As RequiredFieldValidator = FormViewDettaglio.FindControl("Required_ddlUnità")

			'' ATTRIBUTO PER IL SISTEMA FORZATO DALL'ESTERNO
			If Request.QueryString("IDSistema") IsNot Nothing Then

				rblTipoAtt.SelectedValue = "1"
				rblTipoAtt.Enabled = False
				ddlSistemi.SelectedValue = Request.QueryString("IDSistema").ToString
				ddlSistemi.Enabled = False
				ddlUnità.SelectedValue = Nothing
				ddlUnità.Enabled = False
				reqddlSistemi.Enabled = False
				reqddlUnità.Enabled = False

				'' ATTRIBUTO PER L'UNITA' OPERATIVA FORZATA DALL'ESTERNO
			ElseIf Request.QueryString("IDUnita") IsNot Nothing Then

				rblTipoAtt.SelectedValue = "2"
				rblTipoAtt.Enabled = False
				ddlSistemi.SelectedValue = Nothing
				ddlSistemi.Enabled = False
				ddlUnità.SelectedValue = Request.QueryString("IDUnita").ToString
				ddlUnità.Enabled = False
				reqddlSistemi.Enabled = False
				reqddlUnità.Enabled = False

			Else ' LIBERA SCELTA DELL'UTENTE SE INSERIRE UN ATTRIBUTO DEL RUOLO, DEL SISTEMA O UNITA' OP.

				Select Case rblTipoAtt.SelectedValue
					Case "0" 'attributo di ruolo -> tabella RuoliAttributi
						ddlUnità.SelectedValue = Nothing
						ddlSistemi.SelectedValue = Nothing
						ddlUnità.Enabled = False
						ddlSistemi.Enabled = False
						reqddlSistemi.Enabled = False
						reqddlUnità.Enabled = False

					Case "1" 'attributo di sistema -> tabella RuoliSistemiAttributi
						ddlUnità.SelectedValue = Nothing
						ddlSistemi.Enabled = True
						reqddlSistemi.Enabled = True
						ddlUnità.Enabled = False
						reqddlUnità.Enabled = False

					Case "2" 'attributo di unità operativa -> tabella RuoliUnitaOperativeAttributi
						ddlSistemi.SelectedValue = Nothing
						ddlUnità.Enabled = True
						reqddlUnità.Enabled = True
						ddlSistemi.Enabled = False
						reqddlSistemi.Enabled = False

				End Select
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub


#Region "ObjectDataSource"

	Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Selected, odsAttributi.Selected
		ObjectDataSource_TrapError(sender, e)
	End Sub

	Private Sub ods_Inserted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Inserted
		If ObjectDataSource_TrapError(sender, e) Then
			mbErroreSalvataggio = True
		Else
			ObjectDataSource_DiscardCache()
			ChiudiPopUp(True)
		End If
	End Sub

	Protected Sub odsDettaglio_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles odsDettaglio.Inserting
		Try
			e.InputParameters("UtenteInserimento") = User.Identity.Name
			e.InputParameters("IdRuolo") = mgIDRuolo
			Dim ddlCodice As DropDownList = FormViewDettaglio.FindControl("ddlCodice")
			e.InputParameters("CodiceAttributo") = ddlCodice.SelectedValue

			' salvo i valori attuali perchè se c'è un errore 
			' di salvataggio li dovrò rileggere
			FilterHelper.SaveInSession(FormViewDettaglio, msPAGEKEY)

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Protected Sub odsAttributi_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles odsAttributi.Selecting
		Try
			If mbDDLAttributi_CanSelect Then
				Dim rbl As RadioButtonList = FormViewDettaglio.FindControl("rblTipiAttributo")
				e.InputParameters("UsoPerRuolo") = rbl.SelectedValue = "0"
				e.InputParameters("UsoPerSistemaErogante") = rbl.SelectedValue = "1"
				e.InputParameters("UsoPerUnitaOperativa") = rbl.SelectedValue = "2"
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
			e.Cancel = True
		End Try
	End Sub


#End Region


#Region "Funzioni"

	Private Sub ChiudiPopUp(ReloadParent As Boolean)

		Dim cstype As Type = Me.[GetType]()
		ClientScript.RegisterStartupScript(cstype, "popup", "<script type=text/javascript> window.parent.commonModalDialogClose('" & ReloadParent.ToString & "'); </script>")

	End Sub


	''' <summary>
	''' Gestisce gli errori del ObjectDataSource in maniera pulita
	''' </summary>
	''' <returns>True se si è verificato un errore</returns>
	Private Function ObjectDataSource_TrapError(ods As ObjectDataSourceView, e As ObjectDataSourceStatusEventArgs) As Boolean
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

	Private Sub ObjectDataSource_DiscardCache()
		If odsDettaglio.EnableCaching Then
			Cache(msPAGEKEY) = New Object
		End If
	End Sub

#End Region


End Class
