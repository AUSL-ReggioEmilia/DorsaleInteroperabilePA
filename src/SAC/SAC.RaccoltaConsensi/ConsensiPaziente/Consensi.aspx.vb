Imports Wcf.SacPazienti
Imports Wcf.SacConsensi

Public Class Consensi
	Inherits System.Web.UI.Page

    '
    ' DATI RELATIVI AL PAZIENTE CORRENTE
    '
    Dim oPaziente As PazientiDettaglio2ByIdResponsePazientiDettaglio2 = Nothing
    Dim bConsBasePresente As Boolean = False
    Dim bConsDossierPresente As Boolean = False
    Dim bConsDossierStoricoPresente As Boolean = False
    Dim bPazienteMinorenne As Boolean = False
    Dim bConsensoBaseNegato As Boolean = False

    Const TUTTI_I_CONSENSI As Integer = 999


    Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
		Dim iTipo As Integer
		Try
			If Master.ErroreCaricamento Then Exit Sub
            If String.IsNullOrEmpty(Request.QueryString("Id")) And String.IsNullOrEmpty(Request.QueryString("IdProvenienza")) Then
                Master.ShowErrorLabel("Parametro assente.")
                Exit Sub
            End If

            ' SALVO L'URL ATTUALE
            MySession.ConsensiUrl = Request.Url.AbsoluteUri

			toolbar.Visible = Not MySession.IsAccessoDiretto

			' LANCIO ENTRAMBI I METODI RICERCA PAZIENTE, UNO DEI DUE SKIPPA
			odsPazientePerId.Select()
			odsPazientePerIdProvenienza.Select()

			' SE MI VIENE PASSATO ANCHE IL PARAMETRO TIPO SIGNIFICA CHE SONO DI RITORNO DALLA PAGINA
			' DatiTutore.aspx E DEVO IMMEDIATAMENTE PROCEDERE ALL'INSERIMENTO DEI CONSENSI
			If Integer.TryParse(Request.QueryString("Tipo"), iTipo) Then

				' CARICO GLI ATTRIBUTI DALLA SESSION; CE LI HA SALVATI LA PAGINA DatiTutore.aspx
				Dim oAttributi As Wcf.SacConsensi.AttributiType = MySession.PazienteAttributiInseriti(oPaziente.Id)
                If oAttributi Is Nothing Then Throw New CustomException("Attributi non caricati", ErrorCodes.ParametroMancante)

                'Verifico se è scaduta la sessione per evitare di inserire consensi positivi invece che negativi e viceversa
                If Not InserimentoConsensoNegato.HasValue Then
                    InserimentoConsensoNegato = False
                    'sessione scaduta
                    Master.ShowErrorLabel("La sessione è scaduta!")
                    Exit Sub
                End If

                If InserimentoConsensoNegato = True Then
                    InserimentoConsensoNegato = False
                    'Inserimento consenso GENERICO NEGATO
                    InserisciConsensiNegati(iTipo, oPaziente, oAttributi)

                ElseIf InserimentoConsensoNegato = False Then
                    'Inserimento consensi POSITIVI
                    InserisciConsensi(iTipo, oPaziente, oAttributi)

                End If


                ' RICARICO QUESTA STESSA PAGINA SENZA IL PARAMETRO TIPO PER NON RISCHIARE
                ' DI RIPETERE IL SALVATAGGIO DEI CONSENSI DUE VOLTE
                Response.Redirect("Consensi.aspx?Id=" & Request.QueryString("Id"), False)
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Master.ShowErrorLabel(sErrorMessage)
			divConsensi.Visible = False
			toolbar.Visible = False
		End Try
	End Sub

	' RICERCA PER ID PAZIENTE
	Private Sub odsPazientePerId_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsPazientePerId.Selecting
		If String.IsNullOrEmpty(Request.QueryString("Id")) Then
			e.Cancel = True
		End If
	End Sub

	' RICERCA PER PROVENIENZA + IDPROVENIENZA
	Private Sub odsPazientePerIdProvenienza_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsPazientePerIdProvenienza.Selecting
		If String.IsNullOrEmpty(Request.QueryString("IdProvenienza")) Then
			e.Cancel = True
		End If
	End Sub

	' STESSO EVENTO SELECTED PER I DUE OBJECTDATASOURCE
	Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsPazientePerId.Selected, odsPazientePerIdProvenienza.Selected
		Try
			If ObjectDataSource_TrapError(e, Master) Then
				'ERRORE IN CARICAMENTO
				Throw New CustomException("Paziente non trovato", ErrorCodes.PazienteNonTrovato)
			End If

			Dim oResponse As PazientiDettaglio2ByIdResponsePazientiDettaglio2() = e.ReturnValue
			If oResponse Is Nothing OrElse oResponse.Length = 0 Then Throw New CustomException("Paziente non trovato", ErrorCodes.PazienteNonTrovato)

			oPaziente = oResponse(0)

			Try
				' LABEL CON I DETTAGLI DEL PAZIENTE
				lblTitolo.Text = oPaziente.Cognome.NullSafeToString("-") & " " & oPaziente.Nome.NullSafeToString("-")
				If oPaziente.DataNascitaSpecified Then lblTitolo.Text += ", nato/a il " & oPaziente.DataNascita.ToShortDateString
				If oPaziente.ComuneNascitaCodice.NullSafeToString("000000") <> "000000" Then
					lblTitolo.Text += " a " & oPaziente.ComuneNascitaNome.NullSafeToString
					If Not String.IsNullOrEmpty(oPaziente.ProvinciaNascitaNome) AndAlso oPaziente.ProvinciaNascitaNome <> "??" Then lblTitolo.Text += " (" & oPaziente.ProvinciaNascitaNome & ")"
				End If
			Catch
				' PROCEDO COMUNQUE
			End Try

            ' Verifico se ho i diritti di gestire il consenso GENERICO
            Dim bConsensoGenericoModify As Boolean = System.Web.HttpContext.Current.User.IsInRole(ATTRIB_CONSENSO_GENERICO_MODIFY)

            ' MODIFICA ETTORE: 2019-03-08 Verifico che nella lista dei consensi del paziente non vi sia un GENERICO NEGATO
            divMessageConsensoGenericoNegato.Visible = False
            'Rilevo la presenza del GENERICO NEGATO
            Dim dataConsensoGenericoNegato As DateTime = Nothing
            If Not oPaziente.PazientiDettaglio2Consensi Is Nothing AndAlso oPaziente.PazientiDettaglio2Consensi.Count > 0 Then
                Dim olistGenericoNegato As List(Of Wcf.SacPazienti.PazientiDettaglio2ByIdResponsePazientiDettaglio2PazientiDettaglio2Consensi) = (From c In oPaziente.PazientiDettaglio2Consensi Where c.Tipo.ToUpper = "GENERICO" And c.Stato = False).ToList
                If Not olistGenericoNegato Is Nothing AndAlso olistGenericoNegato.Count > 0 Then
                    bConsensoBaseNegato = True
                    dataConsensoGenericoNegato = olistGenericoNegato(0).DataStato
                End If
            End If

            ' INIZIALIZZO IL TESTO DEI PULSANTI
            butBase.Text = "Acquisisci consenso Base" 'potrei chiamarlo anche "Rimuovi consenso Base Negato"
            butBaseNegato.Text = "Nega consenso Base"
            butDossier.Text = "Acquisisci consenso Dossier"
            butDossierStorico.Text = "Acquisisci consenso Dossier Storico"
            butTutti.Text = "Acquisisci tutti i consensi"

            butBase.Visible = False
            butBaseNegato.Visible = False
            'Visualizzo comunque messaggio del consenso negato
            If bConsensoBaseNegato Then
                ' Visualizzo che il consenso GENERICO è NEGATO
                divMessageConsensoGenericoNegato.Visible = True
                lblMessageConsensoGenericoNegato.Text = String.Format("Consenso Base negato! (Acquisito il {0})", dataConsensoGenericoNegato.ToShortDateString)

                'Se non posso gestire il GENERICO allora nel caso ci sia un GENERICO negato rendo invisibili i pulsanti
                If Not bConsensoGenericoModify Then
                    ' Rendo invisibili tutti i pulsanti di acquisizione consensi
                    butBase.Visible = False
                    butBaseNegato.Visible = False
                    butDossier.Visible = False
                    butDossierStorico.Visible = False
                    butTutti.Visible = False
                    ' ESCO dalla funzione
                    Exit Sub
                End If
            End If

            If bConsensoGenericoModify Then
                butBaseNegato.Visible = True
            End If


            bPazienteMinorenne = CalcolaEtà(oPaziente.DataNascita, DateTime.Today) < MAGGIORE_ETÀ
            Dim oAttributiConsensoGenerico As Wcf.SacPazienti.AttributoType() = Nothing
            Dim oAttributiConsensoDossier As Wcf.SacPazienti.AttributoType() = Nothing

            ' VALUTO I CONSENSI ATTUALMENTE PRESENTI
            If oPaziente.PazientiDettaglio2Consensi IsNot Nothing Then
				For Each cons In oPaziente.PazientiDettaglio2Consensi
                    Select Case cons.Tipo.ToUpper
                        Case TipoConsenso.Generico.ToString.ToUpper
                            If bConsensoGenericoModify Then
                                If cons.Stato = True Then
                                    'Se sono qui il GENERICO è stato acquisito POSITIVO
                                    bConsBasePresente = True
                                    'Do la possibilità il GENERICO NEGATIVO
                                    butBaseNegato.Visible = True 'Rendo visibile il pulsate di acquisizione GENERICO NEGATIVO
                                    butBase.Visible = False 'Nascondo il pulsate di acquisizione GENERICO POSITIVO
                                Else
                                    'Se sono qui il GENERICO è stato acquisito NEGATIVO
                                    bConsBasePresente = False
                                    'Do la possibilità di negare il GENERICO POSITIVO
                                    butBase.Visible = True 'Rendo visibile il pulsate di acquisizione GENERICO POSITIVO
                                    butBaseNegato.Visible = False 'Nascondo il pulsate di acquisizione GENERICO NEGATIVO
                                End If
                            Else
                                butBase.Visible = False
                                butBaseNegato.Visible = False
                            End If
                            ' SE IL PAZIENTE E' MINORENNE ED HA UN CONSENSO GENERICO, SALVO I DATI DEL TUTORE
                            If bPazienteMinorenne Then oAttributiConsensoGenerico = cons.Attributi

                        Case TipoConsenso.Dossier.ToString.ToUpper
                            If cons.Stato = True Then
                                bConsDossierPresente = True
                                DisableButton(butDossier)
                                butDossier.Text = "Consenso Dossier Acquisito (" & cons.DataStato.ToShortDateString & ")"
                                ' SE IL PAZIENTE E' MINORENNE ED HA UN CONSENSO DOSSIER, SALVO I DATI DEL TUTORE
                                If cons.Attributi IsNot Nothing And bPazienteMinorenne Then
                                    oAttributiConsensoDossier = cons.Attributi
                                End If
                            End If

                        Case TipoConsenso.DossierStorico.ToString.ToUpper
                            If cons.Stato = True Then
                                bConsDossierStoricoPresente = True
                                DisableButton(butDossierStorico)
                                butDossierStorico.Text = "Consenso Dossier Storico Acquisito (" & cons.DataStato.ToShortDateString & ")"
                            End If
                    End Select
                Next

                ' DETERMINO QUALI ATTRIBUTI CONSIDERARE VALIDI E LI CONSERVO IN SESSION
                If oAttributiConsensoDossier IsNot Nothing Then
                    MySession.PazienteAttributiDB(oPaziente.Id) = oAttributiConsensoDossier
                ElseIf oAttributiConsensoGenerico IsNot Nothing Then
                    MySession.PazienteAttributiDB(oPaziente.Id) = oAttributiConsensoGenerico
                End If

            End If

            ' CONTROLLI PER SEQUENZIALITÀ DELLA PRESA DEI CONSENSI
            If bConsensoBaseNegato Then
                'Se il base è negato disabilito pulsanti per Dossier e DossierStorico
                DisableButton(butDossier)
                DisableButton(butDossierStorico)
            Else
                If Not bConsDossierPresente Then
                    'Se il Dossier non è presenete disabilitopulsante per DossierStorico
                    DisableButton(butDossierStorico)
                End If
            End If

            ' BUTTON TUTTI
            Dim bAcquisitoTuttiIConsensi As Boolean
            bAcquisitoTuttiIConsensi = bConsDossierPresente AndAlso bConsDossierStoricoPresente
            If bAcquisitoTuttiIConsensi OrElse bConsensoBaseNegato Then
                DisableButton(butTutti)
            End If

        Catch ex As CustomException
			Master.ShowErrorLabel(ex.Message)
			divConsensi.Visible = False

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Master.ShowErrorLabel(sErrorMessage)
			divConsensi.Visible = False
		End Try
	End Sub


    Private Sub DisableButton(But As Button)
        But.Enabled = False
        But.CssClass += " disabledbutton"
    End Sub

    Private Sub EnableButton(But As Button)
        But.Enabled = True
        But.CssClass = But.CssClass.Replace(" disabledbutton", "")
    End Sub


    ' STESSO HANDLER PER I 4 PULSANTI
    Protected Sub butConsenso_Click(sender As Object, e As EventArgs) Handles butBase.Click, butDossier.Click, butDossierStorico.Click, butTutti.Click
        Dim Tipo As Integer
        Try
            If oPaziente Is Nothing Then Exit Sub

            If sender Is butBase Then Tipo = TipoConsenso.Generico
            If sender Is butDossier Then Tipo = TipoConsenso.Dossier
            If sender Is butDossierStorico Then Tipo = TipoConsenso.DossierStorico
            If sender Is butTutti Then Tipo = TUTTI_I_CONSENSI

            If bPazienteMinorenne Then
                InserimentoConsensoNegato = False
                ' RICHIEDO LE GENERALITÀ DEL TUTORE
                Response.Redirect("DatiTutore.aspx?Id=" & oPaziente.Id & "&Tipo=" & Tipo.ToString, False)
            Else
                ' ALTRIMENTI PROCEDO CON L'INSERIMENTO
                InserisciConsensi(Tipo, oPaziente, Nothing)

                ' RICARICO QUESTA STESSA PAGINA PER NON RISCHIARE
                ' DI RIPETERE IL SALVATAGGIO DEI CONSENSI SE SI AGGIORNA LA PAGINA (F5)
                Response.Redirect(MySession.ConsensiUrl, False)
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Master.ShowErrorLabel(sErrorMessage)
        End Try
    End Sub

    Private Sub butBaseNegato_Click(sender As Object, e As EventArgs) Handles butBaseNegato.Click
        Dim Tipo As Integer
        Try
            If oPaziente Is Nothing Then Exit Sub
            Tipo = TipoConsenso.Generico

            If bPazienteMinorenne Then
                InserimentoConsensoNegato = True
                ' RICHIEDO LE GENERALITÀ DEL TUTORE
                Response.Redirect("DatiTutore.aspx?Id=" & oPaziente.Id & "&Tipo=" & Tipo.ToString, False)
            Else
                InserimentoConsensoNegato = False
                ' ALTRIMENTI PROCEDO CON L'INSERIMENTO
                InserisciConsensiNegati(Tipo, oPaziente, Nothing)

                ' RICARICO QUESTA STESSA PAGINA PER NON RISCHIARE
                ' DI RIPETERE IL SALVATAGGIO DEI CONSENSI SE SI AGGIORNA LA PAGINA (F5)
                Response.Redirect(MySession.ConsensiUrl, False)
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Master.ShowErrorLabel(sErrorMessage)
        End Try
    End Sub


    Private Sub InserisciConsensi(Tipo As Integer, Paziente As PazientiDettaglio2ByIdResponsePazientiDettaglio2, Attributi As Wcf.SacConsensi.AttributiType)

        If Paziente Is Nothing Then Throw New CustomException("Paziente non caricato", ErrorCodes.ParametroMancante)

        If Tipo <> TUTTI_I_CONSENSI Then
            ' INSERISCO IL SINGOLO CONSENSO
            WcfSacConsensiHelper.ConsensoAggiungi(Paziente, Tipo, Attributi, Master.UtenteCorrente)
        Else
            ' INSERISCO TUTTI I CONSENSI MANCANTI
            ' In caso di ACQUISISCI TUTTI non acquisisco mai il GENERICO
            'If Not bConsBasePresente Then
            '    WcfSacConsensiHelper.ConsensoAggiungi(Paziente, TipoConsenso.Generico, Attributi, Master.UtenteCorrente)
            'End If
            If Not bConsDossierPresente Then
                WcfSacConsensiHelper.ConsensoAggiungi(Paziente, TipoConsenso.Dossier, Attributi, Master.UtenteCorrente)
            End If
            If Not bConsDossierStoricoPresente Then
                WcfSacConsensiHelper.ConsensoAggiungi(Paziente, TipoConsenso.DossierStorico, Attributi, Master.UtenteCorrente)
            End If
        End If

    End Sub


    Private Sub InserisciConsensiNegati(Tipo As Integer, Paziente As PazientiDettaglio2ByIdResponsePazientiDettaglio2, Attributi As Wcf.SacConsensi.AttributiType)

        If Paziente Is Nothing Then Throw New CustomException("Paziente non caricato", ErrorCodes.ParametroMancante)

        WcfSacConsensiHelper.ConsensoNegatoAggiungi(Paziente, Tipo, Attributi, Master.UtenteCorrente)

    End Sub



End Class