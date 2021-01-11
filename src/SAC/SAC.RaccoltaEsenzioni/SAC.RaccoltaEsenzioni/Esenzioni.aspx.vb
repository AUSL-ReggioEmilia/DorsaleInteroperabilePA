Public Class Esenzioni
	Inherits System.Web.UI.Page

	''' <summary>
	''' Ottengo la versione dell'assembly
	''' </summary>
	''' <returns></returns>
	Protected ReadOnly Property AssemblyVersion() As String
		Get
			Return Utility.GetAssemblyVersion()
		End Get
	End Property


#Region "ViewStateVariables"
	''' <summary>
	''' Property contente l'id del paziente.
	''' Salva nel ViewState della pagina l'id del paziente.
	''' </summary>
	''' <returns></returns>
	Public Property IdPaziente() As Guid
		Get
			Return CType(ViewState("IdPaziente"), Guid)
		End Get
		Set(ByVal value As Guid)
			ViewState("IdPaziente") = value
		End Set
	End Property

	''' <summary>
	''' Id provenienza del paziente. (usata per l'inserimento di una nuova esenzione)
	''' </summary>
	''' <returns></returns>
	Public Property PazienteIdProvenienza() As String
		Get
			Return CType(ViewState("PazienteIdProvenienza"), String)
		End Get
		Set(ByVal value As String)
			ViewState("PazienteIdProvenienza") = value
		End Set
	End Property

	''' <summary>
	''' Provenienza del paziente. (usata per l'inserimento di una nuova esenzione)
	''' </summary>
	''' <returns></returns>
	Public Property PazienteProvenienza() As String
		Get
			Return CType(ViewState("PazienteProvenienza"), String)
		End Get
		Set(ByVal value As String)
			ViewState("PazienteProvenienza") = value
		End Set
	End Property

	''' <summary>
	''' Cognome del paziente. (usata per l'inserimento di una nuova esenzione)
	''' </summary>
	''' <returns></returns>
	Public Property PazienteCognome() As String
		Get
			Return CType(ViewState("PazienteCognome"), String)
		End Get
		Set(ByVal value As String)
			ViewState("PazienteCognome") = value
		End Set
	End Property

	''' <summary>
	''' Nome del paziente. (usata per l'inserimento di una nuova esenzione)
	''' </summary>
	''' <returns></returns>
	Public Property PazienteNome() As String
		Get
			Return CType(ViewState("PazienteNome"), String)
		End Get
		Set(ByVal value As String)
			ViewState("PazienteNome") = value
		End Set
	End Property

	''' <summary>
	''' Codice Fiscale del paziente. (usata per l'inserimento di una nuova esenzione)
	''' </summary>
	''' <returns></returns>
	Public Property PazienteCodiceFiscale() As String
		Get
			Return CType(ViewState("PazienteCodiceFiscale"), String)
		End Get
		Set(ByVal value As String)
			ViewState("PazienteCodiceFiscale") = value
		End Set
	End Property

#End Region

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
		Try
			'ottengo l'id del paziente
			Dim idPaziente As String = Request.QueryString("Id")
			' inizializzo la data inizio validità solo se non valorizzata
			If String.IsNullOrEmpty(txtDataInizioValidita.Text) Then
				txtDataInizioValidita.Text = Date.Now.ToString("dd/MM/yyyy")
			End If

			'Se l'id del paziente è null oppure non è un guid valido allora restituisco un errore.
			If String.IsNullOrEmpty(idPaziente) OrElse Not Guid.TryParse(idPaziente, Me.IdPaziente) Then
				Throw New Exception("Si è verificato un errore. L'id del paziente non è valido.")
			End If

			If Not Page.IsPostBack Then
				'solo la prima volta.
				'eseguo una query per ottenere le informazioni sul paziente.
				Dim odsPazienti As New CustomDataSource()
				Dim paziente As WcfSacPazienti.PazienteType = odsPazienti.PazientiOttieniPerId(Nothing, Me.IdPaziente)

				'testo se il paziente è stato trovato
				If Not paziente Is Nothing Then
					'compilo la label con i dati del paziente.
					lblPaziente.Text = paziente.Generalita.Cognome.NullSafeToString("-") & " " & paziente.Generalita.Nome.NullSafeToString("-")
					If paziente.Generalita.DataNascita.HasValue Then lblPaziente.Text += ", nato/a il " & paziente.Generalita.DataNascita.Value.ToShortDateString
					If paziente.Generalita.ComuneNascitaCodice.NullSafeToString("000000") <> "000000" Then
						lblPaziente.Text += " a " & paziente.Generalita.ComuneNascitaNome.NullSafeToString
					End If
					lblPaziente.Text += " , CF. " + paziente.Generalita.CodiceFiscale

					'valorizzo i dati necessari per l'inserimento delle esenzioni
					Me.PazienteIdProvenienza = paziente.IdProvenienza
					Me.PazienteProvenienza = paziente.Provenienza
					Me.PazienteCognome = paziente.Generalita.Cognome
					Me.PazienteNome = paziente.Generalita.Nome
					Me.PazienteCodiceFiscale = paziente.Generalita.CodiceFiscale
				End If
			End If
		Catch ex As Exception
			'ATTENZIONE:
			'Chiamo il metodo CustomDataSourceException.TrapError(ex) al posto di GestioneErrori.TrapError perchè questa objectdatasource chiama una CustomDataSource
			' che ottiene i dati da un WCF.
			'iN questo modo trappo anche gli errori generati dal WCF.
			Master.ShowErrorLabel(CustomDataSourceException.TrapError(ex))
		End Try
	End Sub

#Region "ObjectDataSource"
	Private Sub odsEsenzioni_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsEsenzioni.Selecting
		Try
			'valorizzo l'id del paziente
			e.InputParameters("Id") = Me.IdPaziente
		Catch ex As Exception
			'Si è verificato un errore.
			Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
		End Try
	End Sub

	Private Sub odsEsenzioni_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsEsenzioni.Selected
		Try
			'testo se si è verificato un errore.
			If e.Exception IsNot Nothing Then
				e.ExceptionHandled = True
				'ottengo il messaggio di errore.
				Throw e.Exception
			End If

			'Non si è verificato nessun errore.
			Dim result As WcfSacPazienti.EsenzioniType = CType(e.ReturnValue, WcfSacPazienti.EsenzioniType)
			If result Is Nothing OrElse result.Count = 0 Then
				divEmptyRow.Visible = True
				gvEsenzioni.Visible = False
			End If
		Catch ex As Exception
			'Si è verificato un errore.
			'
			'ATTENZIONE:
			'Chiamo il metodo CustomDataSourceException.TrapError(ex) al posto di GestioneErrori.TrapError perchè questa objectdatasource chiama una CustomDataSource
			' che ottiene i dati da un WCF.
			'iN questo modo trappo anche gli errori generati dal WCF.
			Master.ShowErrorLabel(CustomDataSourceException.TrapError(ex))
		End Try
	End Sub
#End Region

	Private Sub gvEsenzioni_PreRender(sender As Object, e As EventArgs) Handles gvEsenzioni.PreRender
		Try
			'Bootstrap SetUp per le gridView
			HelperGridView.SetUpGridView(gvEsenzioni, Me.Page)

		Catch ex As Exception
			'Si è verificato un errore.
			Master.ShowErrorLabel(TrapError(ex))
		End Try
	End Sub

	Private Sub btnNuovaEsenzione_Click(sender As Object, e As EventArgs) Handles btnNuovaEsenzione.Click
		Try
			ShowHideModaleEsenzioni(True)
		Catch ex As Exception
			'Si è verificato un errore.
			Master.ShowErrorLabel(TrapError(ex))
		End Try
	End Sub

	Private Sub gvEsenzioni_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvEsenzioni.RowCommand
		Try
			'Testo il command name del bottone
			If e.CommandName.ToUpper = "ELIMINA" Then
				'ottengo l'id dell'esenzione da eliminare
				Dim id As Guid = Guid.Parse(e.CommandArgument)

				'elimino l'esenzione
				Dim customDataSource As New CustomDataSource
				customDataSource.EsenzioneEliminaPerIdEsenzione(Nothing, id)

				'refresh della griglia
				gvEsenzioni.DataBind()
			End If
		Catch ex As Exception
			'Si è verificato un errore.
			Master.ShowErrorLabel(TrapError(ex))
		End Try
	End Sub

	Private Sub btnSalva_Click(sender As Object, e As EventArgs) Handles btnSalva.Click
		Try
			'ottengo il codice dell'esenzione.
			Dim codiceEsenzione As String = txtCodiceEsenzione.Text
			'codiceEsenzione è un campo obbligatorio.
			If String.IsNullOrEmpty(codiceEsenzione) Then
				Throw New ApplicationException("Il codice dell'esenzione è obbligatorio.")
			End If

			'ottengo la data di inizio validità.
			Dim sDataInizioValidita As String = txtDataInizioValidita.Text
			Dim dataInizioValidita As Date
			'dataInizioValidita è un campo obbligatorio.
			If String.IsNullOrEmpty(sDataInizioValidita) Then
				Throw New ApplicationException("Data inzio validità è un campo obbligatorio.")
			ElseIf Not Date.TryParse(sDataInizioValidita, dataInizioValidita) Then
				Throw New ApplicationException("Data inzio validità non è una data valida.")
			End If

			'dataFineValiditaPerTryParse è una variabile usata per verificare se la data di fine validità è una data valida.
			'necessario perchè NON posso fare il DateTime.tryparse di una stringa direttamente in una nullable of Datetime.
			Dim dataFineValiditaPerTryParse As DateTime

			'variabile da passare al wcf, di default è nothing
			Dim dataFineValidita As Date? = Nothing

			'controllo se la textbox è vuota: questo campo non è obbligatorio.
			If Not String.IsNullOrEmpty(txtDataFineValidita.Text) Then
				'eseguo il tryParse della textbox a DateTime per verificare se è una data valida.
				'devo usare la varibile dataFineValiditaPerTryParse perchè non posso castare direttamente in una nullable of Datetime.
				If Not Date.TryParse(txtDataFineValidita.Text, dataFineValiditaPerTryParse) Then
					'throw dell'errore.
					Throw New ApplicationException("Data inzio validità non è una data valida.")
				Else
					'valorizzo la variabile dataFineValidita di tipo Nullable of DateTime da passare al WCF.
					dataFineValidita = dataFineValiditaPerTryParse
				End If
			End If


			'dichiaro l'oggetto customDataSource per eseguire le chiamate al WCF.
			Dim customDataSource As New CustomDataSource()
			'aggiungo la nuova esenzione.
			'customDataSource.EsenzioniAggiungi(Nothing, codiceEsenzione, txtCodiceDiagnosi.Text, chkPatologica.Checked,
			'                                   dataInizioValidita, dataFineValidita, txtNumeroAutorizzazioneEsenzione.Text,
			'                                   txtNoteAggiuntive.Text, txtCodiceDescrizioneEsenzione.Text,
			'                                   txtDescrizioneEsenzione.Text, txtDecodificaEsenzioneDiagnosi.Text, txtAttributoEsenzioneDiagnosi.Text,
			'                                   Me.IdPaziente)

			'Modifiche effettuate a seguito della mail con oggetto: "Portale raccolta esenzioni - Appunti" inviata da valerio.
			customDataSource.EsenzioniAggiungi(Nothing, codiceEsenzione, txtCodiceDiagnosi.Text, chkPatologica.Checked,
											   dataInizioValidita, dataFineValidita, String.Empty,
											   txtNoteAggiuntive.Text, String.Empty,
											   txtDescrizioneEsenzione.Text, String.Empty, String.Empty,
											   Me.IdPaziente)

			'nascondo la modale
			ShowHideModaleEsenzioni(False)

			gvEsenzioni.DataBind()

			'refresh dell'update panel contenente la tabella.
			updGvEsenzioni.Update()

		Catch ex As ApplicationException
			'mostro l'errore all'interno della modale.
			divModalError.Visible = True
			lblModalError.Text = ex.Message
		Catch ex As Exception
			'
			'in questo caso mostro l'alert d'errore nella modale.
			'
			divModalError.Visible = True

			'
			'ATTENZIONE
			'Questo evento chiama dei metodi del WCF del SAC.
			'Per trappare gli errori che potrebbero verficarsi nel WS bisogna usare il metodo TrapCustomObjectDataSourceError della classe CustomDataSource.
			'
			lblModalError.Text = GestioneErrori.TrapError(ex)
		End Try
	End Sub




#Region "PrivateFunctions"

	''' <summary>
	''' Metodo che apre/chiude la modale Bootstrap di inserimento/modifica delle esenzioni
	''' </summary>
	''' <param name="showModal"></param>
	Private Sub ShowHideModaleEsenzioni(showModal As Boolean)
		Try

			Dim modalAction As String = "show"
			If Not showModal Then
				modalAction = "hide"
			End If

			'script per l'apertura della modale di  inserimento/modifica delle esenzioni
			Dim script As String = "$('#modaleEsenzioni').modal('" & modalAction & "');"
			ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", script, True)
		Catch ex As Exception
			'Si è verificato un errore.
			Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
		End Try
	End Sub

	Private Sub ShowHideModaleCaricamentoEsenzioni(showModal As Boolean)
		Try

			Dim modalAction As String = "show"
			If Not showModal Then
				modalAction = "hide"
			End If

			'script per l'apertura della modale di  inserimento/modifica delle esenzioni
			Dim script As String = "$('#modaleCaricamentoEsenzioni').modal('" & modalAction & "');"
			ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", script, True)
		Catch ex As Exception
			'Si è verificato un errore.
			Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
		End Try
	End Sub

#End Region

	Protected Function CancellaEsenzioniVisibility(ByVal Provenienza As String, ByVal DataFineValidita As String) As Boolean
		Dim isVisible As Boolean = False
		Try
			If My.Settings.ProvenienzaPortale.ToUpper = Provenienza.ToUpper AndAlso (DataFineValidita > Date.Now OrElse String.IsNullOrEmpty(DataFineValidita)) Then
				isVisible = True
			End If
		Catch ex As Exception
			'
			'non scrivo l'errore.
			'
		End Try
		Return isVisible
	End Function

	Protected Function GetNomeCognomeOperatore(ByVal row As Object) As String
		Dim sReturn As String = String.Empty
		Try
			If Not row Is Nothing Then
				Dim pazienteRow As WcfSacPazienti.EsenzioneType = CType(row, WcfSacPazienti.EsenzioneType)
				If pazienteRow IsNot Nothing Then
					If pazienteRow.Operatore IsNot Nothing AndAlso Not String.IsNullOrEmpty(pazienteRow.Operatore.Cognome) AndAlso Not String.IsNullOrEmpty(pazienteRow.Operatore.Nome) Then
						sReturn = String.Format("{0} {1}", pazienteRow.Operatore.Nome, pazienteRow.Operatore.Cognome)
					End If
				End If
			End If
		Catch ex As Exception
			'
			'non scrivo l'errore.
			'
		End Try
		Return sReturn
	End Function

	Protected Function GetDescrizione(ByVal row As Object) As String
		Dim sReturn As String = String.Empty
		Try
			If Not row Is Nothing Then
				Dim pazienteRow As WcfSacPazienti.EsenzioneType = CType(row, WcfSacPazienti.EsenzioneType)
				If pazienteRow IsNot Nothing Then
					sReturn = String.Format("{0}", pazienteRow.TestoEsenzione.Descrizione)
				End If
			End If
		Catch ex As Exception
			'
			'non scrivo l'errore.
			'
		End Try
		Return sReturn
	End Function

	Private Sub btnCaricaEsenzioni_Click(sender As Object, e As EventArgs) Handles btnCaricaEsenzioni.Click
		Try
			ShowHideModaleCaricamentoEsenzioni(True)
		Catch ex As Exception
			'Si è verificato un errore.
			Master.ShowErrorLabel(TrapError(ex))
		End Try
	End Sub

	Private Sub btnCercaEsenzioni_Click(sender As Object, e As EventArgs) Handles btnCercaEsenzioni.Click
		Try
			gvCaricamentoEsenzioni.DataBind()

			'refresh dell'update panel contenente la tabella.
			updGvEsenzioni.Update()
		Catch ex As Exception
			'Si è verificato un errore.
			Master.ShowErrorLabel(TrapError(ex))
		End Try
	End Sub

	Private Sub gvCaricamentoEsenzioni_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvCaricamentoEsenzioni.RowCommand
		Try
			'Testo il command name del bottone
			If e.CommandName.ToLower = "inserisci" Then
				'ottengo l'id dell'esenzione da eliminare

				Dim codiceEsenzione = Split(e.CommandArgument, ";")

				txtCodiceEsenzione.Text = codiceEsenzione(0)
                txtDescrizioneEsenzione.Text = codiceEsenzione(1)
                txtCodiceDiagnosi.Text = codiceEsenzione(2)

                ScriptManager.RegisterStartupScript(Me, Page.GetType, "Script", "$('#modaleCaricamentoEsenzioni').modal('hide'); $('#modaleEsenzioni').modal('show'); ", True)

			End If
		Catch ex As Exception
			'Si è verificato un errore.
			Master.ShowErrorLabel(TrapError(ex))
		End Try
	End Sub
End Class