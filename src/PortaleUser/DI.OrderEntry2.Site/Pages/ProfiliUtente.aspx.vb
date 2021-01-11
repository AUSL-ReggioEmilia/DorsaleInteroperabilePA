Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Data
Imports System.Linq
Imports DI.OrderEntry.Services
Imports DI.PortalUser2.Data

Namespace DI.OrderEntry.User

	Public Class ProfiliUtente
		Inherits Page

#Region "Properties"

		''' <summary>
		''' Proprietà che serve per salvare il viewstate contenente la listaprestazioni del profilo per controllare quali aggiungere e quali no.
		''' </summary>
		''' <returns></returns>
		Public Property ListaPrestazioni() As ProfiloUtentePrestazioniType
			Get
				Return Me.ViewState("ListaPrestazioni")
			End Get
			Set(ByVal value As ProfiloUtentePrestazioniType)
				Me.ViewState.Add("ListaPrestazioni", value)
			End Set
		End Property


		''' <summary>
		''' Salvo l'ID del profilo selezionato attraverso il commandargument del linkbutton
		''' </summary>
		''' <returns></returns>
		Public Property ProfiloSelezionato() As String
			Get
				Return Me.ViewState("ProfiloSelezionato")
			End Get
			Set(ByVal value As String)
				Me.ViewState.Add("ProfiloSelezionato", value)
			End Set
		End Property

		''' <summary>
		''' Variabili che servono come parametri per capire se eseguire o no i databind delle due gv
		''' </summary>
		Dim ExecuteSelectPrestazioniPerProfilo As Boolean = False
		Dim ExecuteSelectPrestazioniPerErogante As Boolean = False
#End Region


#Region "Utilities"

		''' <summary>
		''' 
		''' Metodo che serve per valutare la visibilità delle checkbox nella gvprestazionierogante
		''' </summary>
		Protected Function GetCheckboxVisibility(oIdProfilo As Object, oAziendaSistema As Object) As Boolean
			Dim ret As Boolean = True
			Try
				Dim idProfilo As String = CType(oIdProfilo, String)
				Dim aziendaSistema As String = CType(oAziendaSistema, String)
				If ListaPrestazioni IsNot Nothing Then
					Dim profilo = (From p In ListaPrestazioni
								   Where p.Codice = idProfilo _
								   And (String.Equals(GetAziendaSistema(p.SistemaErogante), aziendaSistema)) Select p).ToList()
					If profilo IsNot Nothing AndAlso profilo.Count > 0 Then
						Return False
					Else
						Return True
					End If
				Else Return True
				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
			Return ret
		End Function

		''' <summary>
		''' Metodo Custom per comporre la stringa formata da  codice del sistema e codice dell'azienda
		''' Viene utilizzata nell'eval nel markup relativo ad entrambe le gv
		''' </summary>
		Protected Function GetAziendaSistema(oSistema As Object) As String
			Dim res As String = String.Empty
			Try
				Dim sistema As SistemaType = CType(oSistema, SistemaType)
				res = String.Format("{0}-{1}", sistema.Azienda.Codice, sistema.Sistema.Codice)
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
			Return res
		End Function
#End Region

		Private Sub odsPrestazioniPerProfilo_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsPrestazioniPerProfilo.Selecting
			Try
				'in base alla variabile ExecuteSelectPrestazioniPerProfilo (settato a true dopo il click sul pulsante "cerca" e una volta aggiunte delle prestazioni al profilo)
				'e  decido se eseguire il bind della gvPrestazioniPerProfilo
				e.Cancel = Not ExecuteSelectPrestazioniPerProfilo
				e.InputParameters("idProfilo") = ProfiloSelezionato
			Catch ex As Exception
				gestioneErrori(ex)
			End Try

		End Sub


		''' <summary>
		''' Salvo la lista dei pazienti in una property di pagina per averla disponibile nel metodo GetCheckboxVisibility
		''' </summary>
		Private Sub odsPrestazioniPerProfilo_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsPrestazioniPerProfilo.Selected
			Try
				'Mi creo una variabile ListaPrestazioni dotata di ViewState in modo che non si resetti ad ogni postback
				'Essa mi sarà utile per settare le checkbox nel modo giusto
				If (e.ReturnValue IsNot Nothing) Then
					ListaPrestazioni = CType(e.ReturnValue, ProfiloUtentePrestazioniType)
				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try

		End Sub

		''' <summary>
		''' Elimino le prestazioni da un profilo già creato in precedenza 
		''' </summary>
		Protected Sub btnRimuoviPrestazioni_Click(sender As Object, e As EventArgs) Handles btnRimuoviPrestazioni.Click
			Try
				'Mi ricavo gli idprestazioni selezionati da aggiungere al profilo
				Dim listaPrestazioni As String = String.Empty
				For Each row As GridViewRow In gvPrestazioniPerProfilo.Rows
					If row.RowType = DataControlRowType.DataRow Then
						Dim prestazioneId As String = gvPrestazioniPerProfilo.DataKeys.Item(row.RowIndex)("Id")
						Dim checkbox As CheckBox = CType(row.Cells(0).Controls(1), CheckBox)
						If checkbox.Checked = True Then
							listaPrestazioni += prestazioneId + ";"
						End If
					End If
				Next

				'Elimino le prestazioni dal profilo selezionato
				If Not String.IsNullOrEmpty(listaPrestazioni) Then
					Dim customDataSource As New CustomDataSource
					CustomDataSource.Prestazioni.DeletePrestazioneDaProfilo(ProfiloSelezionato, listaPrestazioni)
				End If

				'Per far sì che sia possibile il bind delle due gv imposto a true le due variabili executeSelect
				ExecuteSelectPrestazioniPerProfilo = True
				ExecuteSelectPrestazioniPerErogante = True

				'Attenzione bisogna eseguire sempre il bind della gvprestazioniperprofilo prima dell'altra, altrimenti smette tutto di funzionare
				gvPrestazioniPerProfilo.DataBind()
				gvPrestazioniErogante.DataBind()
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		''' <summary>
		''' Aggiungo le prestazioni in un profilo già creato in precedenza 
		''' </summary>
		Protected Sub btnAggiungiPrestazioni_Click(sender As Object, e As EventArgs) Handles btnAggiungiPrestazioni.Click
			Try
				'Mi ricavo gli idprestazioni selezionati da aggiungere al profilo
				Dim listaPrestazioni As String = String.Empty
				For Each row As GridViewRow In gvPrestazioniErogante.Rows
					If row.RowType = DataControlRowType.DataRow Then
						Dim prestazioneId As String = gvPrestazioniErogante.DataKeys.Item(row.RowIndex)("Id")
						Dim checkbox As CheckBox = CType(row.Cells(0).Controls(1), CheckBox)
						If checkbox.Checked = True Then
							listaPrestazioni += prestazioneId + ";"
						End If
					End If
				Next

				'Se la lista delle prestazioni da aggiungere non è vuota faccio un insert
				If Not String.IsNullOrEmpty(listaPrestazioni) Then
					Dim customDataSource As New CustomDataSource
					CustomDataSource.Prestazioni.InsertPrestazioniInProfilo(ProfiloSelezionato, listaPrestazioni)
				End If

				'Per far sì che sia possibile il bind delle due gv imposto a true le due variabili executeSelect
				ExecuteSelectPrestazioniPerProfilo = True
				ExecuteSelectPrestazioniPerErogante = True

				'Attenzione bisogna eseguire sempre il bind della gvprestazioniperprofilo prima dell'altra, altrimenti smette tutto di funzionare
				gvPrestazioniPerProfilo.DataBind()
				gvPrestazioniErogante.DataBind()
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub


		''' <summary>
		''' Cerco le prestazioni disponibili filtrando per erogante
		''' </summary>
		Protected Sub btnCercaPrestazioni_Click(sender As Object, e As EventArgs) Handles btnCercaPrestazioni.Click
			Try
				'Ricarico i dati della gvPrestazioniErogante
				gvPrestazioniErogante.DataBind()
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Protected Sub btnCercaProfilo_Click(sender As Object, e As EventArgs) Handles btnCercaProfilo.Click
			Try
				'Ricarico i dati della gvProfili
				gvProfili.DataBind()
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Private Sub gvProfili_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvProfili.RowCommand
			Try
				'Intercetto la pressione dei vari button di ogni row della gvProfili
				Dim command As String = e.CommandName
				Dim linkButton As LinkButton = CType(e.CommandSource, LinkButton)

				Select Case command
					'Se clicco sul pulsante di modifica, cambio la descrizione del profilo
					Case "ModificaProfilo"
						'Modifico il titolo della modale in modo che compaia anche la descrizione del profilo che sto modificando
						'Essa la ricavo da un data-attribute aggiunto sul pulsante su cui intercetto il click
						Dim Descrizione As String = linkButton.Attributes("data-descrizioneprofilo").ToString()
						modalProfiloTitle.InnerText = $"Modifica profilo ""{Descrizione}"""

						'Imposto il parametro su cui l'odsProfilo deve effettuare la query di selezione
						odsProfilo.SelectParameters("idProfilo").DefaultValue = CType(e.CommandArgument, String)

						'Imposto la modalità della formView su Edit poichè sono in modifica
						fvProfilo.ChangeMode(FormViewMode.Edit)
						fvProfilo.DataBind()

						'Ricavo l'id del profilo selezionato e lo setto nella variabile di pagina ProfiloSelezionato in modo che sia
						'visibile in tutta la pagina
						Dim id As String = CType(e.CommandArgument, String)
						ProfiloSelezionato = id

						'Apro la modale contestuale
						ClientScript.RegisterStartupScript(Me.GetType(), "Modificaprestazioniprofilo", "$('#modalNuovoeModificaProfilo').modal('show');", True)

					'Se clicco sul pulsante di modifica delle prestazioni del profilo si apre la modale che mi permette di aggiungere o 
					'rimuovere prestazioni dal profilo selezionato
					Case "ModificaPrestazioniProfilo"
						'Modifico il titolo della modale in modo che compaia anche la descrizione del profilo che sto modificando
						'Essa la ricavo da un data-attribute aggiunto sul pulsante su cui intercetto il click
						Dim Descrizione As String = linkButton.Attributes("data-descrizioneprofilo").ToString()
						modalModificaPrestazioniProfiloTitle.InnerText = $"Modifica prestazioni del profilo ""{Descrizione}"""

						'Ricavo l'id del profilo selezionato e lo setto nella variabile di pagina ProfiloSelezionato in modo che sia
						'visibile in tutta la pagina
						Dim id As String = CType(e.CommandArgument, String)
						ProfiloSelezionato = id

						'Per far sì che sia possibile il bind delle due gv imposto a true le due variabili executeSelect
						ExecuteSelectPrestazioniPerProfilo = True
						ExecuteSelectPrestazioniPerErogante = True

						'Attenzione bisogna eseguire sempre il bind della gvprestazioniperprofilo prima dell'altra, altrimenti smette tutto di funzionare
						gvPrestazioniPerProfilo.DataBind()
						gvPrestazioniErogante.DataBind()

						'Apro la modale contestuale
						ClientScript.RegisterStartupScript(Me.GetType(), "Modificaprestazioniprofilo", "$('#modalModificaPrestazioniProfilo').modal('show');", True)

						'Se premo sulla 'X' rossa in fondo ad ogni riga, elimino tale row e quindi tale profilo
					Case "EliminaProfilo"
						'Ricavo l'id del profilo selezionato e che voglio venga cancellato
						Dim id As String = CType(e.CommandArgument, String)
						odsProfili.DeleteParameters("idProfilo").DefaultValue = id
						odsProfili.Delete()

						'Rieffettuo il databind della gvProfili per refreshare i risultati dopo aver effettuato la cancellazione di un determinato profilo
						gvProfili.DataBind()
				End Select
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Private Sub btnNuovoProfilo_Click(sender As Object, e As EventArgs) Handles btnNuovoProfilo.Click
			Try
				'imposto la modalità della formView su 'inserimento' poichè sono in fase di creazione di un nuovo profilo
				fvProfilo.ChangeMode(FormViewMode.Insert)

				'Modifico il titolo della modale
				modalProfiloTitle.InnerText = "Crea nuovo profilo"

				'Mostro la modale
				ClientScript.RegisterStartupScript(Me.GetType(), "Nuovoprofilo", "$('#modalNuovoeModificaProfilo').modal('show');", True)

				'Rieffettuo il databind della gvProfili per refreshare i risultati dopo aver effettuato la creazione di un nuovo profilo
				gvProfili.DataBind()

			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Private Sub odsProfili_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles odsProfili.Updating
			Try
				'Imposto il parametro su cui l'odsProfili deve effettuare la query di aggiornamento
				odsProfili.UpdateParameters("Id").DefaultValue = ProfiloSelezionato
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Private Sub odsProfilo_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles odsProfilo.Updating
			Try
				'Imposto il parametro su cui l'odsProfilo deve effettuare la query di selezione
				e.InputParameters("idProfilo") = ProfiloSelezionato
			Catch ex As Exception
				gestioneErrori(ex)
			End Try

		End Sub

		Private Sub odsProfilo_Updated(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsProfilo.Updated
			Try
				'Effettuo nuovamente il databind della gvProfili dopo aver aggiornato un determinato profilo
				gvProfili.DataBind()
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Private Sub odsProfilo_Inserted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsProfilo.Inserted
			Try
				'Effettuo nuovamente il databind della gvProfili dopo aver inserito un nuovo profilo
				gvProfili.DataBind()
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		'''<summary>
		''' Funzione per trappare gli errori e mostrare il div d'errore.
		''' </summary>
		''' <param name="ex"></param>
		Private Sub gestioneErrori(ex As Exception)

			'Testo di errore generico da visualizzare nel divError della pagina.
			Dim errorMessage As String = "Si è verificato un errore. Contattare l'amministratore del sito"

			'Se ex è una ApplicationException, allora contiene un messaggio di errore personalizzato che viene visualizzato poi
			'nel divError della pagina.
			If TypeOf ex Is ApplicationException Then
				errorMessage = ex.Message
			End If

			'Scrivo l'errore nell'event viewer.
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

			'Visualizzo il messaggio di errore nella pagina.
			divErrorMessage.Visible = True
			lblError.Text = errorMessage
		End Sub
	End Class
End Namespace