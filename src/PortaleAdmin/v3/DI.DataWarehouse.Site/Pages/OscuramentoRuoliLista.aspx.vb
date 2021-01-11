Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin
Imports System.Data
Imports DI.DataWarehouse.Admin.Data

Public Class OscuramentoRuoliLista
	Inherits System.Web.UI.Page

	Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
	Private Const BACKPAGE As String = "OscuramentiLista.aspx"
	Private Const KEY_DESCRIZIONE As String = "DescOscuramento"
	Private Const KEY_IdOscuramento As String = "Id"

	Private Property mbModalitàInserimento() As Boolean
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
			Cache.Remove("CacheOscuramentoRuoli")
		End If

	End Sub


	Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
		Try
			Dim mID As String = Request.QueryString(KEY_IdOscuramento)

			If Not Page.IsPostBack Then

                Using ta As New OscuramentiDataSetTableAdapters.OscuramentiTableAdapter
                    Using dt = ta.GetData(New Guid(mID))
                        If dt.Rows.Count = 1 Then
                            Dim dr = dt(0)
                            Dim sTitolo As String = If(dr.IsTitoloNull(), "", " - " & dr.Titolo)
                            ViewState.Add(KEY_DESCRIZIONE, dr.CodiceOscuramento & sTitolo)
                        Else
                            Utility.ShowErrorLabel(LabelError, "Oscuramento " & mID & " non trovato!")
                        End If
                    End Using
                End Using
            End If

			If mbModalitàInserimento Then
				lblSottoTitolo.Text = "Scelta dei Ruoli che possono bypassare l'oscuramento"
			Else
				lblSottoTitolo.Text = "Lista dei Ruoli che possono bypassare l'oscuramento"
			End If

			lblTitolo.Text = "Oscuramento " & ViewState(KEY_DESCRIZIONE)

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
			Cache.Remove(odsLista.CacheKeyDependency)
			gvLista.PageIndex = 0

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Private Sub odsLista_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
		ObjectDataSource_TrapError(sender, e)
	End Sub

	Private Sub odsLista_Deleted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsLista.Deleted
		ObjectDataSource_TrapError(sender, e)
	End Sub

	Private Sub odsLista_Inserted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsLista.Inserted
		ObjectDataSource_TrapError(sender, e)
	End Sub

	Private Sub odsLista_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsLista.Selecting
		Try
			If mbModalitàInserimento Then
				'@IdOscuramento=NULL fa caricare la lista completa dei ruoli
				e.InputParameters("IdOscuramento") = Nothing
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Protected Sub butAnnulla_Click(sender As Object, e As EventArgs) Handles butAnnulla.Click, butAnnullaTop.Click

		If mbModalitàInserimento Then
			'
			' PASSO ALLA MODALITA' LISTA
			'
			mbModalitàInserimento = False
			Cache.Remove(odsLista.CacheKeyDependency)
			txtFiltriCodice.Text = ""
			txtFiltriDescrizione.Text = ""
			gvLista.DataBind()
		Else
			' BACK
			Response.Redirect(BACKPAGE)
		End If
	End Sub

	Protected Sub butElimina_Click(sender As Object, e As EventArgs) Handles butElimina.Click, butEliminaTop.Click
		Try
			For Each row As GridViewRow In gvLista.Rows
				Dim chkItem As CheckBox = row.FindControl("CheckBox")
				If chkItem.Checked Then
					odsLista.DeleteParameters("IdOscuramento").DefaultValue = Request.QueryString(KEY_IdOscuramento)
					odsLista.DeleteParameters("IdRuolo").DefaultValue = gvLista.DataKeys(row.RowIndex).Values("IdRuolo").ToString
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
		txtFiltriCodice.Text = ""
		txtFiltriDescrizione.Text = ""
		gvLista.DataBind()

	End Sub

	Protected Sub butConferma_Click(sender As Object, e As EventArgs) Handles butConferma.Click, butConfermaTop.Click
		Dim iNumChecked As Integer = 0
		Try
			For Each row As GridViewRow In gvLista.Rows
				Dim chkItem As CheckBox = row.FindControl("CheckBox")
				If chkItem.Checked Then
					odsLista.InsertParameters("UtenteInserimento").DefaultValue = User.Identity.Name
					odsLista.InsertParameters("IdOscuramento").DefaultValue = Request.QueryString(KEY_IdOscuramento)
					odsLista.InsertParameters("IdRuolo").DefaultValue = gvLista.DataKeys(row.RowIndex).Values("IdRuolo").ToString
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
				Utility.ShowErrorLabel(LabelError, "Selezionare i Ruoli da aggiungere.")
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

#End Region

End Class