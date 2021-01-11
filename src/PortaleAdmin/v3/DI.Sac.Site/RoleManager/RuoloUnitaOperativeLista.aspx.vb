Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin
Imports System.Data
Imports OrganigrammaDataSetTableAdapters


Public Class RuoloUnitaOperativeLista
    Inherits System.Web.UI.Page

	Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
	Private Const BACKPAGE As String = "RuoliLista.aspx"
	Private Const KEY_DESCRUOLO As String = "DescRuolo"
    Private msIDRuolo As String
    Private Const lblText As String = "Sono stati mostrati solo i primi 1000 record perchè la ricerca ha prodotto più di 1000 risultati."

    Const FLAG_ATTIVO_TUTTI As String = ""
    Const FLAG_ATTIVO_SI As String = "1"
    Const FLAG_ATTIVO_NO As String = "0"

    Private Property mbModalitàInserimento As Boolean
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
			Cache.Remove("CacheRuoloUnitaOperative")
		End If

	End Sub

	Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        'Try
        '	If Not Page.IsPostBack Then
        '		FilterHelper.Restore(pannelloFiltri, msPAGEKEY)
        '	End If
        'Catch ex As Exception
        '	Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
        '	Utility.ShowErrorLabel(LabelError, sErrorMessage)
        'End Try
    End Sub

    Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
		Try
			msIDRuolo = Request.QueryString("ID")

			If Not Page.IsPostBack Then

				'FilterHelper.Restore(ddlFiltriAzienda, msPAGEKEY)
				'' SE AVEVO IMPOSTATO UN FILTRO NELLA DROPDOWN FORZO UN DATABIND 
				'' CHE ALTRIMENTI NON SCATTEREBBE IN AUTOMATICO
				'If ddlFiltriAzienda.SelectedValue.Length > 0 Then
				'	gvLista.DataBind()
				'End If

				Using ta As New RuoliTableAdapter()
					Using dt As OrganigrammaDataSet.RuoliDataTable = ta.GetData(New Guid(msIDRuolo))
						If dt.Rows.Count = 1 Then
							Dim dr As OrganigrammaDataSet.RuoliRow = dt.Rows(0)
							ViewState.Add(KEY_DESCRUOLO, dr.Codice & " - " & dr.Descrizione)
						Else
							Utility.ShowErrorLabel(LabelError, "Ruolo " & msIDRuolo & " non trovato!")
						End If
					End Using
				End Using
			End If

			If mbModalitàInserimento Then
				lblTitolo.Text = "Associazione delle Unità Operative al Ruolo: " & ViewState(KEY_DESCRUOLO)
			Else
				lblTitolo.Text = "Unità Operative associate al Ruolo: " & ViewState(KEY_DESCRUOLO)
			End If

			'mostro / nascondo i pulsanti
			butConfermaTop.Visible = mbModalitàInserimento
			butEliminaTop.Visible = Not mbModalitàInserimento
			butAggiungiTop.Visible = Not mbModalitàInserimento
			butConferma.Visible = mbModalitàInserimento
			butElimina.Visible = Not mbModalitàInserimento
			butAggiungi.Visible = Not mbModalitàInserimento
			'mostro la colonna 'imposta ruoli' solo in modalità lista
			gvLista.Columns(1).Visible = Not mbModalitàInserimento

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

	Private Sub odsLista_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
        Try
            If e.Exception Is Nothing Then
                Dim gvTop As Integer = CInt(odsLista.SelectParameters.Item("Top").DefaultValue)
                Dim eG = CType(e.ReturnValue, DataTable)
                If eG.Rows.Count = gvTop Then
                    lblGvLista.Visible = True
                    lblGvLista.Text = lblText
                Else
                    lblGvLista.Visible = False
                End If
            Else
                ObjectDataSource_TrapError(sender, e)
                lblGvLista.Visible = False
            End If
        Catch ex As Exception
            lblGvLista.Visible = False
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
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
                '@IdRuolo=NULL fa caricare la lista completa delle unità operative
                e.InputParameters("IdRuolo") = Nothing
            End If
            '
            ' MODIFICA ETTORE 2017-03-27: Passo il valore al paramtero @Attivo (BOOLEAN NULLABILE) della query 
            '
            Dim sValue As String = ddlAttivo.SelectedValue
            Dim bAttivo As Boolean? = Nothing
            Select Case sValue
                Case FLAG_ATTIVO_TUTTI
                    bAttivo = Nothing 'passo NOTHING alla SP arriva NULL
                Case FLAG_ATTIVO_NO
                    bAttivo = False
                Case FLAG_ATTIVO_SI
                    bAttivo = True
            End Select
            e.InputParameters("Attivo") = bAttivo

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
			ddlFiltriAzienda.SelectedValue = ""
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

		'
		' PASSO ALLA MODALITA' INSERIMENTO
		'
		mbModalitàInserimento = True
		Cache.Remove(odsLista.CacheKeyDependency)
		ddlFiltriAzienda.SelectedValue = ""
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
                    odsLista.InsertParameters("IdRuolo").DefaultValue = Request.QueryString("ID")
                    odsLista.InsertParameters("IdUnitaOperativa").DefaultValue = gvLista.DataKeys(row.RowIndex).Values("IdUnitaOperativa").ToString
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
                Utility.ShowErrorLabel(LabelError, "Selezionare le Unità Operative da aggiungere al Ruolo.")
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