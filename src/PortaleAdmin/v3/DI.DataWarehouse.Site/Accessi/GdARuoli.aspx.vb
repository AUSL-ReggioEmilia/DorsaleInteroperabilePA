Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin
Imports System.Data
Imports AccessiDataSetTableAdapters
Imports System.Web


Public Class GdARuoli
	Inherits System.Web.UI.Page

	Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
	Private Const KEY_DESCRIZIONE As String = "KEY_DESCRIZIONE"
	Private msBACKPAGE As String
	Private msID As String

	Private Property mbModalitàInserimento() As Boolean
		Get
			Return ViewState("mbModalitàInserimento")
		End Get
		Set(ByVal value As Boolean)
			ViewState("mbModalitàInserimento") = value
		End Set
	End Property

	Private Property mbODS_CanSelect() As Boolean
		Get
			Return ViewState("mbODS_CanSelect")
		End Get
		Set(ByVal value As Boolean)
			ViewState("mbODS_CanSelect") = value
		End Set
	End Property


	Private Sub Page_PreInit(sender As Object, e As System.EventArgs) Handles Me.PreInit
		Try
			'
			' NEL PREINIT PULISCO LA CACHE DEL OBJECTDATASOURCE
			'
			If Not Page.IsPostBack Then
				'
				' ALL'AVVIO LA PAGINA VIENE MOSTRATA IN MODALITA' LISTA
				'
				mbModalitàInserimento = False
				Cache.Remove("CacheGdARuoli")
			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
		Try
			'
			' CONTROLLO DEI PARAMETRI IN QUERYSTRING
			'
			If String.IsNullOrEmpty(Request.QueryString("Id")) Then
				Utility.ShowErrorLabel(LabelError, "Parametro ID assente!")
				mbODS_CanSelect = False
			Else
				mbODS_CanSelect = True
				msID = Request.QueryString("Id")
			End If

			msBACKPAGE = "GdALista.aspx"

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
		Try
			If Not Page.IsPostBack Then
				If mbODS_CanSelect Then
					Using ta As New GdATableAdapter()
						Using dt = ta.GetData(New Guid(msID), Nothing, Nothing)
							If dt.Rows.Count = 1 Then
								Dim dr = dt(0)
								ViewState.Add(KEY_DESCRIZIONE, dr.AziendaCodice & " - " & dr.Descrizione)
							Else
								Utility.ShowErrorLabel(LabelError, "GdA " & msID & " non trovato!")
							End If
						End Using
					End Using
				End If
			End If

			If mbModalitàInserimento Then
				lblTitolo.Text = "Selezionare i Ruoli per gli utenti di: " & ViewState(KEY_DESCRIZIONE)
			Else
				lblTitolo.Text = "Ruoli per gli utenti di: " & ViewState(KEY_DESCRIZIONE)
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
				Cache.Remove(odsLista.CacheKeyDependency)
				gvLista.PageIndex = 0
				mbODS_CanSelect = True
				gvLista.DataBind()
			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Private Sub odsLista_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles odsLista.Inserting
		e.InputParameters("UtenteInserimento") = User.Identity.Name
	End Sub

	Private Sub odsLista_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
		ObjectDataSource_TrapError(sender, e)
	End Sub

	Private Sub odsLista_Deleted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Deleted
		ObjectDataSource_TrapError(sender, e)
	End Sub

	Private Sub odsLista_Inserted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Inserted
		ObjectDataSource_TrapError(sender, e)
	End Sub

	Private Sub odsLista_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsLista.Selecting
		Try
			If mbModalitàInserimento Then
				'@@IdGdA=NULL fa caricare la lista completa degli oggetti
				e.InputParameters("IdGdA") = Nothing
			End If

			e.Cancel = Not mbODS_CanSelect
			gvLista.EmptyDataText = If(mbODS_CanSelect, "Nessun risultato!", "Impostare i filtri e premere Cerca.")

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Protected Function ValidazioneFiltri() As Boolean

		'nulla da validare
		Return True

	End Function

#Region "Comandi in modalità LISTA"

	Protected Sub butElimina_Click(sender As Object, e As EventArgs) Handles butElimina.Click, butEliminaTop.Click
		Try
			For Each row As GridViewRow In gvLista.Rows
				Dim chkItem As CheckBox = row.FindControl("CheckBox")
				If chkItem.Checked Then
					odsLista.DeleteParameters("Id").DefaultValue = gvLista.DataKeys(row.RowIndex).Values("Id").ToString
					odsLista.Delete()
				End If
			Next
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Protected Sub butAggiungi_Click(sender As Object, e As EventArgs) Handles butAggiungi.Click, butAggiungiTop.Click
		Try
			'
			' PASSO ALLA MODALITA' INSERIMENTO
			'
			mbModalitàInserimento = True
			mbODS_CanSelect = False	'non mostro la lista di tutti gli oggetti AD prima che l'utente prema cerca
			Cache.Remove(odsLista.CacheKeyDependency)
			txtFiltriCodice.Text = ""
			txtFiltriDescrizione.Text = ""
			gvLista.DataBind()
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

#End Region


#Region "Comandi in modalità INSERIMENTO"


	Protected Sub butAnnulla_Click(sender As Object, e As EventArgs) Handles butAnnulla.Click, butAnnullaTop.Click
		Try
			If mbModalitàInserimento Then
				'
				' PASSO ALLA MODALITA' LISTA
				'
				mbModalitàInserimento = False
				mbODS_CanSelect = True
				Cache.Remove(odsLista.CacheKeyDependency)
				txtFiltriCodice.Text = ""
				txtFiltriDescrizione.Text = ""

				gvLista.DataBind()
			Else
				' BACK
				Response.Redirect(msBACKPAGE)
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Protected Sub butConferma_Click(sender As Object, e As EventArgs) Handles butConferma.Click, butConfermaTop.Click
		Dim iNumChecked As Integer = 0
		Try
			For Each row As GridViewRow In gvLista.Rows
				Dim chkItem As CheckBox = row.FindControl("CheckBox")
				If chkItem.Checked Then
					odsLista.InsertParameters("IdGdA").DefaultValue = msID
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
				Utility.ShowErrorLabel(LabelError, "Selezionare i Ruoli da assegnare agli utenti.")
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

#End Region


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


#End Region



End Class