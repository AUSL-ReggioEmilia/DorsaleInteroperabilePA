Imports DwhClinico.Data

Public Class ucModaleInvioLinkPerAccessoDiretto
	Inherits System.Web.UI.UserControl

#Region "Property"
	''' <summary>
	''' Restituisce le informazioni sull'utente corrente (utiizzato per ottenere le informazioni sul mittente)
	''' </summary>
	''' <returns></returns>
	Public ReadOnly Property Mittente() As WcfSacRoleManager.UtenteType
		Get
			'Ottengo l'oggetto Utente
			Using ta As New WcfSacRoleManager.RoleManagerClient
				Dim oUtente As WcfSacRoleManager.UtenteReturn = ta.UtenteOttieniPerNomeUtente(HttpContext.Current.User.Identity.Name)
				If Not oUtente Is Nothing Then
					If Not oUtente.Errore Is Nothing Then
						Throw New WsSacException("Si è verificato un errore durante la lettura dell'utente.", oUtente.Errore)
					Else
						If String.IsNullOrEmpty(oUtente.Utente.Email) Then
							oUtente.Utente.Email = My.Settings.MittenteMail
							chkInviaMessaggioAlMittente.Checked = False
							chkInviaMessaggioAlMittente.Enabled = False
						End If
						Return oUtente.Utente
					End If
				End If
			End Using
			Return Nothing
		End Get
	End Property

	Public Property InizialiPaziente As String
		Get
			Return ViewState("InizialiPaziente")
		End Get
		Set(value As String)
			ViewState("InizialiPaziente") = value
		End Set
	End Property

    Public Property NumeroReferto As String
        Get
            Return ViewState("NumeroReferto")
        End Get
        Set(value As String)
            ViewState("NumeroReferto") = value
        End Set
    End Property

    Public Property DataReferto As DateTime
        Get
            Return ViewState("DataReferto")
        End Get
        Set(value As DateTime)
            ViewState("DataReferto") = value
        End Set
    End Property

#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
		Try
			If Not Page.IsPostBack Then

				'
				' RENDERING PER BOOTSTRAP
				' Converte i tag html generati dalla GridView per la paginazione
				' e li adatta alle necessita dei CSS Bootstrap
				'

				'Ottengo il nome e cognome dell'utente per compilare l'oggetto e il corpo della mail.
				Dim oMittente As WcfSacRoleManager.UtenteType = Me.Mittente
				oMittente.Email = Nothing
				Dim sNomeUtente As String = oMittente.Nome
				Dim sCognomeUtente As String = oMittente.Cognome
				Dim sEmailUtente As String = oMittente.Email
				Dim currentUrl = My.Request.Url.AbsoluteUri.ToUpper
				'In base alla pagina corrente setto l'oggetto della mail.
				If currentUrl.Contains("REFERTILISTAPAZIENTE") Then
					txtOggettoMail.Text = $"Invito a visionare la storia clinica del paziente {InizialiPaziente}"
				ElseIf currentUrl.Contains("REFERTIDETTAGLIO") Then
                    txtOggettoMail.Text = $"Invito a visionare il referto {Me.NumeroReferto} del paziente {Me.InizialiPaziente} del {Me.DataReferto:dd/MM/yyyy}"
                Else
					txtOggettoMail.Text = String.Format("DwhClinico:Condivisione Link al DWH da {0} {1}", sNomeUtente, sCognomeUtente)
				End If

				gvListaDestinatari.PagerStyle.CssClass = "pagination-gridview"
				ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)
			End If

		Catch ex As ApplicationException
			lblErroreModale.Text = ex.Message
			divErroreModale.Visible = True

		Catch ex As Exception
			Logging.WriteError(ex, Me.GetType.Name)
			lblErroreModale.Text = "Errore durante il caricamento della modale di invio del link all'accesso diretto."
			divErroreModale.Visible = True
		End Try
	End Sub

#Region "Modale Invio Link Accesso Diretto"
	Private Sub odsListaDestinatari_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsListaDestinatari.Selecting
		Try
			'
			'Se Nome, Cognome, e Email sono vuoti non eseguo la query.
			'
			If String.IsNullOrEmpty(txtCognome.Text) AndAlso String.IsNullOrEmpty(txtNome.Text) AndAlso String.IsNullOrEmpty(txtEmail.Text) Then
				e.Cancel = True
				Exit Sub
			End If
		Catch ex As Exception
			Logging.WriteError(ex, Me.GetType.Name)
			lblErroreModale.Text = "Errore durante la ricerca dei dati."
			divErroreModale.Visible = True
		End Try
	End Sub

	Private Sub odsListaDestinatari_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsListaDestinatari.Selected
		Try
			If e.Exception IsNot Nothing Then
				Dim sErrore As String = "Errore durante l'operazione di ricerca dei dati!"
				If e.Exception.InnerException IsNot Nothing Then
					Throw e.Exception
				End If
				e.ExceptionHandled = True
			End If
		Catch ex As Exception
			Logging.WriteError(ex, Me.GetType.Name)
			lblErroreModale.Text = "Errore durante l'invio della mail."
			divErroreModale.Visible = True
		End Try
	End Sub

	Private Sub gvListaDestinatari_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvListaDestinatari.RowCommand
		Try
			'Controllo il command Name del bottone.
			If e.CommandName.ToUpper = "AGGIUNGIUTENTE" Then
				'
				'ottengo la mail.
				'
				Dim sDestinatarioMail As String = e.CommandArgument

				'controllo se txtListaDestinatari è valorizzata.
				If Not String.IsNullOrEmpty(txtListaDestinatari.Text) Then
					Dim olist As StringDictionary = GetListaDestinatari(txtListaDestinatari.Text)
					If Not olist.ContainsKey(sDestinatarioMail) Then
						'Se la mail non era già presente nella lista allora la aggiungo.
						txtListaDestinatari.Text = String.Format("{0}, {1}", txtListaDestinatari.Text, sDestinatarioMail)
					End If
				Else
					'se sono qui significa che la lista dei destinatari era vuota, quindi aggiungo la mail.
					txtListaDestinatari.Text = sDestinatarioMail
				End If
				'
				' Imposto il focus sul corpo del messagio visto che si visualizza il div di invio della mail
				'
				txtCorpoMessaggio.Focus()
				'
				' Nascondo il div di "ricerca"
				'
				divRicercaDestinatari.Style.Add("display", "none") 'Visible = False
				'
				' Visualizzo il div di "invio email"
				'
				divInvioMail.Style.Add("display", "block") 'Visible = True
			End If
		Catch ex As Exception
			Logging.WriteError(ex, Me.GetType.Name)
			lblErroreModale.Text = "Errore durante la ricerca dei dati."
			divErroreModale.Visible = True
		End Try
	End Sub

	Private Function GetListaDestinatari(ByVal sListaDestinatari As String) As System.Collections.Specialized.StringDictionary
		Dim oRet As New System.Collections.Specialized.StringDictionary
		If Not String.IsNullOrEmpty(sListaDestinatari) Then
			Dim oArray As String() = sListaDestinatari.Split(",")
			For Each sItem As String In oArray
				'Dal secondo in poi gli indirizzi sono separati da ", " 
				sItem = sItem.Trim
				oRet.Add(sItem, sItem)
			Next
		End If
		'
		'
		'
		Return oRet
	End Function

	Private Sub btnInviaMail_Click(sender As Object, e As EventArgs) Handles btnInviaMail.Click
		Try
			'
			'Controllo se la lista dei destinatari è vuota. 
			'Se è vuota allora mostro un messaggio di errore.
			'
			If Not String.IsNullOrEmpty(txtListaDestinatari.Text) Then

				'Ottengo la lista dei destinatari (i destinatari sono concatenati da una virgola).
				Dim sDestinatari As String = txtListaDestinatari.Text
				Dim oArrayDestinatari As String()

				'Ottengo un array contenente tutte le mail dei destinatari.
				oArrayDestinatari = sDestinatari.Split(",")

				'Ottengo il nome e cognome dell'utente per compilare l'oggetto e il corpo della mail.
				Dim oMittente As WcfSacRoleManager.UtenteType = Me.Mittente
				Dim sNomeUtente As String = oMittente.Nome
				Dim sCognomeUtente As String = oMittente.Cognome
				Dim sEmailUtente As String = oMittente.Email

				If String.IsNullOrEmpty(sEmailUtente) Then
					Throw New ApplicationException("Impossibile inviare l'email: l'indirizzo email dell'utente non è valorizzato.")
				End If

				If chkInviaMessaggioAlMittente.Checked Then
					Dim arrayDestinatariConMittente As List(Of String) = oArrayDestinatari.ToList
					arrayDestinatariConMittente.Add(sEmailUtente)
					oArrayDestinatari = arrayDestinatariConMittente.ToArray
				End If

				Dim sBodymessaggio As String = txtCorpoMessaggio.Text
				Dim sLinkAlDWh As String = String.Empty

				'
				'Distinguo in che pagina sono:
				'Se sono nella pagina di lista creo l'url per l'accesso diretto alla lista dei referti del paziente.
				'Se sono nella pagina di dettaglio del referto creo l'url per l'accesso diretto al singolo referto.
				'
				sLinkAlDWh = GeneraLinkAccessoDiretto()

				'
				'Creo un nuovo DataTable per permette la conversione in XMl e la trasformazione XSLT.
				'
				Dim odsMessaggio As New DataTable("Messaggio")
				odsMessaggio.Columns.Add("Messaggio")
				odsMessaggio.Columns.Add("Link")
				odsMessaggio.Columns.Add("Mittente")
				odsMessaggio.Rows.Add(sBodymessaggio, sLinkAlDWh, String.Format("{0} {1}", sNomeUtente, sCognomeUtente))

                '
                'Creo l'oggetto della mail
                '
                Dim sEmailOggetto As String = txtOggettoMail.Text

                Dim destinatariConcatenati As String = String.Join(";", oArrayDestinatari, 0, oArrayDestinatari.Length)

                Dim oNotificatore As New Notificatore
                'oNotificatore.CaricamentoMessaggio(sEmailUtente, odsMessaggio, oArrayDestinatari, sEmailOggetto)

                Dim oArrayDestinatariConcat As String() = New String() {destinatariConcatenati}
                oNotificatore.CaricamentoMessaggio(sEmailUtente, odsMessaggio, oArrayDestinatariConcat, sEmailOggetto)

                '
                '  Cancello i campi e chiudo la modale
                '
                Call ChiudoModale()

				'
				'Mostro l'alert di avvenuto invio e imposto una funzione jqeury per nasconderlo dopo 2 secondi.
				'
				lblMessage.Text = "Email inviata."
				customAlert.Visible = True
				Dim sScript2 As String = "window.setTimeout(function() { // hide alert message
                                             $('#customAlert').slideUp(); 
                                        }, 2000);"
				ScriptManager.RegisterStartupScript(Page, Page.GetType(), "HideAlert", sScript2, True)
				updatePanelAlertSuccess.Update()

				divRicercaDestinatari.Style.Add("display", "block") 'Visible = True
				divInvioMail.Style.Add("display", "none") 'Visible = False

				'
				' Faccio il refresh della lista dei preferiti
				'
				' Cancello la cache per forzare la riesecuzione della query SQL
				Dim oEmailDestinatari As New CustomDataSource.EmailDestinatariPreferitiCerca
				oEmailDestinatari.ClearCache()
				'forzo l'esecuaione dell'object data source
				rptPreferiti.DataBind()
				'refresh dell'update panel per refreshare la lista dei preferiti
				updPreferiti.Update()

			End If
		Catch ex As ApplicationException
			lblErroreModale.Text = ex.Message
			divErroreModale.Visible = True

		Catch ex As Exception
			Logging.WriteError(ex, Me.GetType.Name)
			lblErroreModale.Text = "Errore durante l'invio della mail."
			divErroreModale.Visible = True

		End Try
	End Sub


	Private Sub gvListaDestinatari_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvListaDestinatari.RowDataBound
		Try
			'
			'Per ogni utente trovato controllo che sia configurata la mail.
			'Se non è stata configurata disabilito il pulsante e mostro un tooltip.
			'
			If e.Row IsNot Nothing Then
				If e.Row.RowType = DataControlRowType.DataRow Then
					Dim oUtente As CustomDataSource.Utente = CType(e.Row.DataItem, CustomDataSource.Utente)
					If String.IsNullOrEmpty(oUtente.Email) Then
						e.Row.Visible = False
					End If
				End If
			End If
		Catch ex As Exception
			Logging.WriteError(ex, Me.GetType.Name)
			lblErroreModale.Text = "Errore durante la ricerca dei dati."
			divErroreModale.Visible = True
		End Try
	End Sub

	Private Sub btnCercaUtenti_Click(sender As Object, e As EventArgs) Handles btnCercaUtenti.Click
		Try
			'aggiorno la lista degli utenti.
			gvListaDestinatari.DataBind()
			divInvioMail.Style.Add("display", "none") 'Visible = False
			divRicercaDestinatari.Style.Add("display", "block") 'Visible = True

		Catch ex As Exception
			Logging.WriteError(ex, Me.GetType.Name)
			lblErroreModale.Text = "Errore durante la ricerca degli utenti."
			divErroreModale.Visible = True
		End Try
	End Sub

	Private Sub btnCancellaDest_Click(sender As Object, e As EventArgs) Handles btnCancellaDest.Click
		Try
			'svuoto la lista dei destinatari.
			txtListaDestinatari.Text = String.Empty
			'Visualizzo il div Invio email : se non lo faccio poichè i div sono impostati come non visibili nel markup rimarrebbero nascosti...
			divInvioMail.Style.Add("display", "block") 'Visible = True
			'Nasconfo il div di ricerca
			divRicercaDestinatari.Style.Add("display", "none") 'Visible = False
			'aggiorno l'update panel.
			'updInvioEmail.Update()
		Catch ex As Exception
			Logging.WriteError(ex, Me.GetType.Name)
			lblErroreModale.Text = "Errore durante la cancellazione dei destinatari."
			divErroreModale.Visible = True
		End Try
	End Sub

	Private Sub btnMostraRicerca_Click(sender As Object, e As EventArgs) Handles btnMostraRicerca.Click
		Try
			divRicercaDestinatari.Style.Add("display", "block") 'Visible = True
			divInvioMail.Style.Add("display", "none") 'Visible = False
			txtCognome.Focus()
		Catch
		End Try
	End Sub

	Private Sub btnAnnullaInvio_Click(sender As Object, e As EventArgs) Handles btnAnnullaInvio.Click
		Try
			Call ChiudoModale()
		Catch ex As Exception
			Logging.WriteError(ex, Me.GetType.Name)
			lblErroreModale.Text = "Errore durante annullamento invio mail."
			divErroreModale.Visible = True
		End Try
	End Sub


	Private Sub ChiudoModale()
		txtCorpoMessaggio.Text = String.Empty
		txtListaDestinatari.Text = String.Empty
		txtCognome.Text = String.Empty
		txtNome.Text = String.Empty
		txtEmail.Text = String.Empty
		Dim sScript As String = "$('#modaleInvioEmail').modal('hide');"
		ScriptManager.RegisterStartupScript(Page, Page.GetType(), "btnInviaLink_Click", sScript, True)
	End Sub

	Private Sub btnChiudiRicerca_Click(sender As Object, e As EventArgs) Handles btnChiudiRicerca.Click
		Try
			If Not String.IsNullOrEmpty(txtListaDestinatari.Text) Then
				txtCorpoMessaggio.Focus()
				'Mostro il div di invio delle email
				divRicercaDestinatari.Style.Add("display", "none") 'Visible = false
				divInvioMail.Style.Add("display", "block") 'Visible = True
			Else
				Call ChiudoModale()
			End If
		Catch ex As Exception
			Logging.WriteError(ex, Me.GetType.Name)
			lblErroreModale.Text = "Errore durante chiusura ricerca destinatri."
			divErroreModale.Visible = True
		End Try
	End Sub

	Private Sub DataSourcePreferiti_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles DataSourcePreferiti.Selecting
		Try
			e.InputParameters("EmailMittente") = Me.Mittente.Email
		Catch ex As Exception
			Logging.WriteError(ex, Me.GetType.Name)
			lblErroreModale.Text = "Errore durante l'operazione di ricerca dei destinatari preferiti!"
			divErroreModale.Visible = True
		End Try
	End Sub

	Private Sub DataSourcePreferiti_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DataSourcePreferiti.Selected
		Try
			If e.Exception IsNot Nothing Then
				If e.Exception.InnerException IsNot Nothing Then
					Throw e.Exception
				End If
				e.ExceptionHandled = True
			Else
				Const CSS_CLASS As String = "btn btn-default btn-sm"
				btnPreferiti.Attributes.Remove("class")
				btnPreferiti.Attributes.Add("class", CSS_CLASS & " disabled")

				btnPreferiti.Attributes.Remove("Title")
				btnPreferiti.Attributes.Add("Title", "Nessun destinatario preferito")

				Dim odt As Data.EmailDataSet.DestinatariPreferitiCercaDataTable = DirectCast(e.ReturnValue, Data.EmailDataSet.DestinatariPreferitiCercaDataTable)
				If Not odt Is Nothing Then
					'btnPreferiti.Disabled = Not CBool(odt.Count > 0)
					If odt.Count > 0 Then
						btnPreferiti.Attributes.Add("class", CSS_CLASS)
						btnPreferiti.Attributes.Add("Title", "Destinatari preferiti")

						Dim rowMittente = (From preferito In odt.Rows Where CType(preferito, EmailDataSet.DestinatariPreferitiCercaRow).Email.ToLower = "luca.bellavia@progel.it".ToLower Select preferito).FirstOrDefault
						If Not rowMittente Is Nothing Then
							odt.Rows.Remove(rowMittente)
						End If

					End If
				End If
			End If
		Catch ex As Exception
			Logging.WriteError(ex, Me.GetType.Name)
			lblErroreModale.Text = "Errore durante l'operazione di ricerca dei destinatari preferiti!"
			divErroreModale.Visible = True
		End Try
	End Sub

	'Private Sub btnCopyToClipboard_Click(sender As Object, e As EventArgs) Handles btnCopyToClipboard.Click
	'	Try
	'		Dim sLinkAlDWh As String = String.Empty

	'		'
	'		'Distinguo in che pagina sono:
	'		'Se sono nella pagina di lista creo l'url per l'accesso diretto alla lista dei referti del paziente.
	'		'Se sono nella pagina di dettaglio del referto creo l'url per l'accesso diretto al singolo referto.
	'		'
	'		sLinkAlDWh = GeneraLinkAccessoDiretto()
	'           txtCopyUrl.Text = sLinkAlDWh

	'           'Dim sScript As String = $"navigator.clipboard.writeText('{sLinkAlDWh}')"
	'           Dim sScript As String = $"$('#txtCopyUrl').select(); document.execCommand('copy');"
	'           ScriptManager.RegisterStartupScript(Page, Page.GetType(), "copiaUrl", sScript, True)


	'           lblMessage.Text = "Url copiato nella clipboard."
	'           customAlert.Visible = True
	'           Dim sScript2 As String = "window.setTimeout(function() { // hide alert message
	'                                            $('#customAlert').slideUp(); 
	'                                       }, 2000);"
	'           ScriptManager.RegisterStartupScript(Page, Page.GetType(), "HideAlert", sScript2, True)
	'           updatePanelAlertSuccess.Update()

	'       Catch ex As Exception
	'		Logging.WriteError(ex, Me.GetType.Name)
	'		lblErroreModale.Text = "Errore durante l'operazione di ricerca dei destinatari preferiti!"
	'		divErroreModale.Visible = True
	'	End Try
	'End Sub

	''' <summary>
	''' Genera il link per l'accesso diretto.
	''' </summary>
	''' <returns></returns>
	Protected Function GeneraLinkAccessoDiretto() As String
		Dim sLinkAlDWh As String = String.Empty

		If Request.Url.AbsolutePath.Contains("RefertiListaPaziente.aspx") Then
			Dim sCurrentUrl As String = Request.Url.AbsoluteUri
			If Not String.IsNullOrEmpty(My.Settings.UrlMailLinkAccessoDiretto) Then
				'MODIFICA ETTORE 2018-06-19: uso la configurazione con il DI-GO
				sLinkAlDWh = String.Format(My.Settings.UrlMailLinkAccessoDiretto, "AccessoDiretto/Referti.aspx" & Request.Url.Query)
			Else
				'Se My.Settings.UrlMailLinkAccessoDiretto non è configurato funziona come prima
				sLinkAlDWh = sCurrentUrl.Replace("Referti/RefertiListaPaziente.aspx", "AccessoDiretto/Referti.aspx")
			End If
		ElseIf Request.Url.AbsolutePath.Contains("RefertiDettaglio.aspx") Then
			Dim sCurrentUrl As String = Request.Url.AbsoluteUri
			If Not String.IsNullOrEmpty(My.Settings.UrlMailLinkAccessoDiretto) Then
				'MODIFICA ETTORE 2018-06-19: uso la configurazione con il DI-GO
				sLinkAlDWh = String.Format(My.Settings.UrlMailLinkAccessoDiretto, "AccessoDiretto/Referto.aspx" & Request.Url.Query)
			Else
				'Se My.Settings.UrlMailLinkAccessoDiretto non è configurato funziona come prima
				sLinkAlDWh = sCurrentUrl.Replace("Referti/RefertiDettaglio.aspx", "AccessoDiretto/Referto.aspx")
			End If
		ElseIf Request.Url.AbsolutePath.Contains("AccessoDiretto") Then
			Dim sCurrentUrl As String = Request.Url.AbsoluteUri
			sLinkAlDWh = sCurrentUrl
		End If

		Return sLinkAlDWh
	End Function

	Private Sub btnCopia_PreRender(sender As Object, e As EventArgs) Handles btnCopia.PreRender
		Try
			btnCopia.Attributes.Add("data-clipboard-text", GeneraLinkAccessoDiretto())
		Catch ex As Exception
			Logging.WriteError(ex, Me.GetType.Name)
			lblErroreModale.Text = "Si è verificato un errore, contattare l'amministratore."
			divErroreModale.Visible = True
		End Try
	End Sub

	Private Sub btnCopia_ServerClick(sender As Object, e As EventArgs) Handles btnCopia.ServerClick
		Try
			lblMessage.Text = "Link copiato."
			customAlert.Visible = True
			Dim sScript2 As String = "window.setTimeout(function() { // hide alert message
                                             $('#customAlert').slideUp(); 
                                        }, 2000);"
			ScriptManager.RegisterStartupScript(Page, Page.GetType(), "HideAlert", sScript2, True)
			updatePanelAlertSuccess.Update()
		Catch ex As Exception
			Logging.WriteError(ex, Me.GetType.Name)
			lblErroreModale.Text = "Si è verificato un errore, contattare l'amministratore."
			divErroreModale.Visible = True
		End Try
	End Sub

#End Region
End Class