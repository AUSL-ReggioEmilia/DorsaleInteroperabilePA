Public Class _Default
	Inherits System.Web.UI.Page

	Dim bCanRunSelect As Boolean = False

	Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
		Try
			divRicerca.Visible = Not Master.ErroreCaricamento

			' ACCESSO DIRETTO #1
			' SE SI PASSA L'IDPAZIENTE O (PROVENIENZA + IDPROVENIENZA) NAVIGO DIRETTAMENTE ALLA PAGINA CONSENSI
			If Not String.IsNullOrEmpty(Request.QueryString("Id")) Or Not String.IsNullOrEmpty(Request.QueryString("IdProvenienza")) Then
				MySession.IsAccessoDiretto = True
				Response.Redirect(String.Format("Consensi.aspx?{0}", Request.QueryString.ToString), False)
				Exit Sub
			End If

			' ACCESSO DIRETTO #2
			' SE SI PASSA IL CODICE FISCALE DEVO ESEGUIRE LA RICERCA PERCHE' POTREBBERO 
			' ESSERCI PIÙ RECORD DI ANAGRAFICA CON LO STESSO CODICE FISCALE
			If Not String.IsNullOrEmpty(Request.QueryString("CF")) Then
				MySession.IsAccessoDiretto = True
				txtCodfisc.Text = Request.QueryString("CF")
				pannelloFiltri.Visible = False
				bCanRunSelect = True
				gvLista.DataBind()
				Exit Sub
			End If


			' NORMALE
			MySession.IsAccessoDiretto = False
			If Not Page.IsPostBack Then
				FilterHelper.Restore(pannelloFiltri)
			End If

			txtFiltriCognome.Focus()
			Form.DefaultButton = butFiltriRicerca.UniqueID

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Master.ShowErrorLabel(sErrorMessage)
		End Try
	End Sub

	Private Sub butFiltriRicerca_Click(sender As Object, e As System.EventArgs) Handles butFiltriRicerca.Click
		Try
			If txtFiltriCognome.Text.Length = 0 And _
			  txtFiltriNome.Text.Length = 0 And
			  txtAnnoNascita.Text.Length = 0 And _
			  txtCodfisc.Text.Length = 0 Then
				gvLista.EmptyDataText = "Compilare almeno un filtro di ricerca e premere Cerca."
			Else
				'RICERCA CONSENTITA
				bCanRunSelect = True
				gvLista.EmptyDataText = "Nessun risultato!"
				FilterHelper.SaveInSession(pannelloFiltri)
				gvLista.DataBind()
			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Master.ShowErrorLabel(sErrorMessage)
		End Try
	End Sub

	Protected Sub odsLista_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles odsLista.Selecting
		Try
			If Not Page.IsPostBack Then
				gvLista.EmptyDataText = ""
			End If

			e.Cancel = Not bCanRunSelect

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Master.ShowErrorLabel(sErrorMessage)
		End Try
	End Sub


	Private Sub odsLista_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
		Try
			If Not ObjectDataSource_TrapError(e, Master) Then
				' SE C'È UN SOLO RISULTATO NAVIGO ALLA PAGINA CONSENSI
				Dim result As Wcf.SacPazienti.PazientiCerca3ResponsePazientiCerca2() = e.ReturnValue
				If result.Length = 1 Then
					Response.Redirect(String.Format("Consensi.aspx?Id={0}", result(0).Id), False)
				End If
			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Master.ShowErrorLabel(sErrorMessage)
		End Try
	End Sub

    Private Sub gvLista_PreRender(sender As Object, e As EventArgs) Handles gvLista.PreRender
        '
        'Render per Bootstrap
        'Crea la Table con Theader e Tbody se l'header non è nothing.
        '
        If Not gvLista.HeaderRow Is Nothing Then
            gvLista.UseAccessibleHeader = True
            gvLista.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
    End Sub
End Class