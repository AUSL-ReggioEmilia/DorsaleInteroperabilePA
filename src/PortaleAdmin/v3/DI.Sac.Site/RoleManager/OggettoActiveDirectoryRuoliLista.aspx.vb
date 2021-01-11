Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin
Imports System.Data
Imports OrganigrammaDataSetTableAdapters
Imports Aspose.Cells
Imports System.Drawing

Public Class OggettoActiveDirectoryRuoliLista
	Inherits System.Web.UI.Page

	Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
	Private msBACKPAGE As String = "OggettiAD.aspx"
	Private Const KEY_DESCOGGETTOAD As String = "DescOggettoAD"

	Shared msUtente As String

	Public Property mbModalitàInserimento() As Boolean
		Get
			Return ViewState("mbModalitàInserimento")
		End Get
		Set(ByVal value As Boolean)
			ViewState("mbModalitàInserimento") = value
		End Set
	End Property

	Private Sub Page_PreInit(sender As Object, e As System.EventArgs) Handles Me.PreInit
		'
		' NEL PREINIT PULISCO LA CACHE DEL OBJECTDATASOURCE
		'
		If Not Page.IsPostBack Then
			'
			' ALL'AVVIO LA PAGINA VIENE MOSTRATA IN MODALITA' LISTA
			'
			mbModalitàInserimento = False
			Cache.Remove("CacheOggettoActiveDirectoryRuoli")
		End If

	End Sub

	Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
		Try
			Dim mgIDOggettoAD As Guid = New Guid(Request.QueryString("Id"))

			If Not Page.IsPostBack Then

				Using ta As New OggettiActiveDirectoryTableAdapter()
					Using dt As OrganigrammaDataSet.OggettiActiveDirectoryDataTable = ta.GetDataById(mgIDOggettoAD)
						If dt.Rows.Count = 1 Then
							Dim dr As OrganigrammaDataSet.OggettiActiveDirectoryRow = dt.Rows(0)
							msUtente = dr.Utente
							If dr.Tipo.ToUpper = "UTENTE" Then
								ViewState.Add(KEY_DESCOGGETTOAD, "all'utente " & dr.Utente & If(dr.IsDescrizioneNull, "", " [" & dr.Descrizione & "]"))
							Else
								ViewState.Add(KEY_DESCOGGETTOAD, "al gruppo " & dr.Utente & If(dr.IsDescrizioneNull, "", " [" & dr.Descrizione & "]"))
							End If
						Else
							Utility.ShowErrorLabel(LabelError, "Oggetto Active Directory ID: " & Request.QueryString("Id") & " non trovato!")
						End If
					End Using
				End Using
			End If

			If mbModalitàInserimento Then
				lblTitolo.Text = "Selezionare i Ruoli da assegnare " & ViewState(KEY_DESCOGGETTOAD)
			Else
				lblTitolo.Text = "Ruoli assegnati " & ViewState(KEY_DESCOGGETTOAD)
			End If

			'mostro / nascondo i pulsanti
			butConfermaTop.Visible = mbModalitàInserimento
			butEliminaTop.Visible = Not mbModalitàInserimento
			butAggiungiTop.Visible = Not mbModalitàInserimento
			butConferma.Visible = mbModalitàInserimento
			butElimina.Visible = Not mbModalitàInserimento
			butAggiungi.Visible = Not mbModalitàInserimento

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Protected Sub RicercaButton_Click(sender As Object, e As EventArgs) Handles butFiltriRicerca.Click

		Try
			LabelError.Visible = False
			If ValidazioneFiltri() Then
				'FilterHelper.SaveInSession(pannelloFiltri, msPAGEKEY)
				Cache.Remove(odsLista.CacheKeyDependency)
				gvLista.PageIndex = 0
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try

	End Sub

	Private Sub odsLista_Inserted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsLista.Inserted
		ObjectDataSource_TrapError(sender, e)
	End Sub

	Private Sub odsLista_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
		ObjectDataSource_TrapError(sender, e)
	End Sub

	Private Sub odsLista_Deleted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsLista.Deleted
		ObjectDataSource_TrapError(sender, e)
	End Sub

	Private Sub odsLista_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsLista.Selecting
		Try

			If mbModalitàInserimento Then
				'@OggettiActiveDirectoryID=NULL fa caricare la lista completa degli oggetti
				e.InputParameters("OggettiActiveDirectoryID") = Nothing
				'	Else
				'	e.InputParameters("Utente") = msUtente
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Protected Function ValidazioneFiltri() As Boolean

		'nulla da validare
		Return True

	End Function


	Protected Sub butAnnulla_Click(sender As Object, e As EventArgs) Handles butAnnulla.Click, butAnnullaTop.Click

		If mbModalitàInserimento Then
			'
			' PASSO ALLA MODALITA' LISTA
			'
			mbModalitàInserimento = False
			Cache.Remove(odsLista.CacheKeyDependency)
			txtFiltriCodice.Text = String.Empty
			txtFiltriDescrizione.Text = String.Empty
			gvLista.DataBind()
		Else
			' BACK
			Response.Redirect(msBACKPAGE)
		End If
	End Sub

	Protected Sub butElimina_Click(sender As Object, e As EventArgs) Handles butElimina.Click, butEliminaTop.Click
		Try
			For Each row As GridViewRow In gvLista.Rows
				Dim chkItem As CheckBox = row.FindControl("CheckBox")
				If chkItem.Checked Then
					odsLista.DeleteParameters("ID").DefaultValue = gvLista.DataKeys(row.RowIndex).Values("ID").ToString
					odsLista.Delete()
				End If
			Next
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Protected Sub butAggiungi_Click(sender As Object, e As EventArgs) Handles butAggiungi.Click, butAggiungiTop.Click

		'
		' PASSO ALLA MODALITA' INSERIMENTO
		'
		mbModalitàInserimento = True
		Cache.Remove(odsLista.CacheKeyDependency)
		txtFiltriCodice.Text = String.Empty
		txtFiltriDescrizione.Text = String.Empty
		gvLista.DataBind()

	End Sub

	Protected Sub butConferma_Click(sender As Object, e As EventArgs) Handles butConferma.Click, butConfermaTop.Click
		Dim iNumChecked As Integer = 0
		Try
			For Each row As GridViewRow In gvLista.Rows
				Dim chkItem As CheckBox = row.FindControl("CheckBox")
				If chkItem.Checked Then
					odsLista.InsertParameters("IdRuolo").DefaultValue = gvLista.DataKeys(row.RowIndex).Values("IdRuolo").ToString
					odsLista.InsertParameters("UtenteInserimento").DefaultValue = User.Identity.Name
					odsLista.Insert()
					iNumChecked += 1
				End If
			Next

			If iNumChecked > 0 Then
				'
				' PASSO ALLA MODALITA' LISTA
				'
				butAnnulla_Click(Nothing, Nothing)

			Else
				Utility.ShowErrorLabel(LabelError, "Selezionare i ruoli assegnare.")
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Protected Sub chkboxSelectAll_CheckedChanged(ByVal sender As Object, ByVal e As EventArgs)
		Try
			Dim ChkBoxHeader As CheckBox = CType(gvLista.HeaderRow.FindControl("chkboxSelectAll"), CheckBox)
			For Each row As GridViewRow In gvLista.Rows
				CType(row.FindControl("CheckBox"), CheckBox).Checked = ChkBoxHeader.Checked
			Next
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub


#Region "Funzioni"

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

	Private Sub gvLista_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvLista.RowDataBound
		If e.Row.RowType = DataControlRowType.DataRow Then
			Dim checkBox As CheckBox = TryCast(e.Row.FindControl("CheckBox"), CheckBox)
			Dim tipoAbilitazione As String = e.Row.Cells(3).Text

			If String.Equals(tipoAbilitazione, "Gruppo") Then
				checkBox.Visible = False
				e.Row.ForeColor = Color.DarkSlateGray
			End If
		End If
	End Sub



#End Region



End Class