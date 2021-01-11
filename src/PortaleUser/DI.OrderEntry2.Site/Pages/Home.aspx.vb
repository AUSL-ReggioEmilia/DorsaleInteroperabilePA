Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.PortalUser2.Data
Imports System.Collections.Generic
Imports DI.OrderEntry.User.Data
Imports System.Text

Namespace DI.OrderEntry.User

	Public Class Home
		Inherits Page

		Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
			Try
				If Not Page.IsPostBack Then
					ClearCache()
				End If
				'
				'2020-07-13 Kyrylo: Traccia Operazioni
				'
				Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalUser)
				oTracciaOp.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Visualizzata lista ordini pendenti", pannelloFiltri, Nothing)

				Redirector.SetTarget(Request.Url.AbsoluteUri, True)
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Public Shared Function GetUrlRefertoOrdineDwh(annoNumero As String) As String
			Return String.Format("{0}{1}", My.Settings.DwhUrlRefertoOrdine, annoNumero)
		End Function

		Public Shared Function GetUrlRefertiDwh(idPaziente As String) As String
			Return String.Format("{0}{1}", My.Settings.DwhUrlReferti, idPaziente)
		End Function

		Protected Function GetDettaglioUrl(ByVal idRichiesta As Object, ByVal idPaziente As Object, stato As String, nosologico As String, aziendauo As Object) As String
			Return String.Format("{2}.aspx?IdRichiesta={0}&IdPaziente={1}{3}&{4}", idRichiesta, idPaziente, If(stato = "Inserito" OrElse stato = "Modificato", "ComposizioneOrdine", "RiassuntoOrdine"), If(nosologico Is Nothing, "", "&Nosologico=" & nosologico), If(aziendauo Is Nothing, "", "&AziendaUo=" & aziendauo))
		End Function

		'creo delle variabili di pagina che sono necessarie per il loading della gvPazienti in quanto formano parte della key su cui effettuo la select
		Dim codice As String
		Dim codiceAzienda As String
		Private Sub gvReparti_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvReparti.RowDataBound
			Try
				'Nascondo l'ultima cella dell'HEADER della tabella esterna.
				If e.Row.RowType = DataControlRowType.Header Then
					'
					' Nascondo l'ultima colonna della griglia esterna
					'
					Dim rigaCorrente As GridViewRow = e.Row
					Dim cellCurrent As TableCell = rigaCorrente.Cells(rigaCorrente.Cells.Count - 1)
					cellCurrent.CssClass = "hidden"
				End If

				'Testo se è una row.
				If e.Row.RowType = DataControlRowType.DataRow Then

					'Ottengo la riga corrente.
					Dim rigaCorrente As GridViewRow = e.Row
					Dim reparto As CustomDataSource.Reparto = CType(rigaCorrente.DataItem, CustomDataSource.Reparto)


					codice = reparto.Codice
					codiceAzienda = reparto.CodiceAzienda


					Dim odsPazienti As ObjectDataSource = CType(rigaCorrente.FindControl("odsPazienti"), ObjectDataSource)

					odsPazienti.SelectParameters.Item("Codice").DefaultValue = reparto.Codice
					odsPazienti.SelectParameters.Item("CodiceAzienda").DefaultValue = reparto.CodiceAzienda




					Dim gvPazienti As GridView = CType(rigaCorrente.FindControl("gvPazienti"), GridView)
					gvPazienti.DataBind()

					If gvPazienti.Rows.Count > 0 Then

						'
						' Creo il bottone per collassare la riga
						'
						Dim sbCellDiv As New StringBuilder
						sbCellDiv.AppendFormat("<button data-target='.{0}'", reparto.Codice & reparto.CodiceAzienda)
						sbCellDiv.AppendFormat("        class='btn-link'")
						sbCellDiv.AppendFormat("        data-toggle='collapse'")
						sbCellDiv.AppendFormat("        type='button'>")
						sbCellDiv.AppendFormat(" <div class='ricercaavanzata-collapsing {0} collapse in' id='id-{1}'>", reparto.Codice & reparto.CodiceAzienda, reparto.Codice & reparto.CodiceAzienda)
						sbCellDiv.AppendFormat("            <span class='glyphicon glyphicon-minus'></span>")
						sbCellDiv.AppendFormat("        </div>")
						sbCellDiv.AppendFormat("        <div class='ricercaavanzata-collapsing {0} collapse {1}'>", reparto.Codice & reparto.CodiceAzienda, reparto.Codice & reparto.CodiceAzienda)
						sbCellDiv.AppendFormat("            <span class='glyphicon glyphicon-plus'></span>")
						sbCellDiv.AppendFormat("        </div>")
						sbCellDiv.AppendFormat("</button>")

						rigaCorrente.Cells(0).Text = sbCellDiv.ToString()



						Dim sbCellDiv2 As New StringBuilder
						sbCellDiv2.AppendFormat("<button data-target='.{0}'", reparto.Codice & reparto.CodiceAzienda)
						sbCellDiv2.AppendFormat("        class='btn-link'")
						sbCellDiv2.AppendFormat("        data-toggle='collapse'")
						sbCellDiv2.AppendFormat("        type='button'>")
						sbCellDiv2.AppendFormat(" <div class='ricercaavanzata-collapsing {0} collapse in' id='id-{1}'>", reparto.Codice & reparto.CodiceAzienda, reparto.Codice & reparto.CodiceAzienda)
						sbCellDiv2.AppendFormat("             <strong>{0}</strong>", reparto.CodiceAzienda & "-" & reparto.Descrizione)
						sbCellDiv2.AppendFormat("        </div>")
						sbCellDiv2.AppendFormat("        <div class='ricercaavanzata-collapsing {0} collapse {1}'>", reparto.Codice & reparto.CodiceAzienda, reparto.Codice & reparto.CodiceAzienda)
						sbCellDiv2.AppendFormat("            <strong>{0}</strong>", reparto.CodiceAzienda & "-" & reparto.Descrizione)
						sbCellDiv2.AppendFormat("        </div>")
						sbCellDiv2.AppendFormat("</button>")

						rigaCorrente.Cells(1).Text = sbCellDiv2.ToString()

						'
						' Cerco la tabella della griglia
						'
						Dim tblGrid As Table = CType(gvReparti.Controls(0), Table)

						'
						' Recupero la posizione della riga corrente nella tabella
						'
						Dim nRowIndex As Integer = tblGrid.Rows.GetRowIndex(rigaCorrente)

						'
						' Crea una nuova riga e la posiziono dopo la riga corrente
						'
						Dim gvrSubFooter As New GridViewRow(nRowIndex + 1, 0, DataControlRowType.DataRow, DataControlRowState.Normal)

						'
						' Aggiungo classe Css alla riga per il collassamento della row tramite bootstrap
						'
						gvrSubFooter.CssClass = String.Format("ricercaavanzata-collapsing collapse {0} in", reparto.Codice & reparto.CodiceAzienda)

						' Creo una nuova cella per la riga aggiuntiva
						' Con il contenuto dell'ultima cella
						'
						Dim cellExpanded As TableCell
						cellExpanded = rigaCorrente.Cells(rigaCorrente.Cells.Count - 1)
						cellExpanded.ColumnSpan = gvReparti.Columns.Count - 1


						'
						' Aggiunge due celle alla nuova riga
						'
						gvrSubFooter.Cells.Add(New TableCell())
						gvrSubFooter.Cells.Add(cellExpanded)

						'
						' Aggiunge la nuova riga alla tabella della griglia
						'
						tblGrid.Controls.AddAt(nRowIndex + 1, gvrSubFooter)
						'
						' Sostituosce l'ultima colonna con una cella vuota e la nasconde
						'
						Dim cellReplace As New TableCell
						cellReplace.CssClass = "hidden"
						rigaCorrente.Cells.Add(cellReplace)
					Else
						'
						' Nasconde l'ultima colonna della riga
						'
						Dim cellCurrent As TableCell = rigaCorrente.Cells(rigaCorrente.Cells.Count - 1)
						cellCurrent.CssClass = "hidden"
					End If
				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Protected Sub gvPazienti_RowDataBound(sender As Object, e As GridViewRowEventArgs)
			Try
				'Nascondo l'ultima cella dell'HEADER della tabella esterna.
				If e.Row.RowType = DataControlRowType.Header Then
					'
					' Nascondo l'ultima colonna della griglia esterna
					'
					Dim rigaCorrente As GridViewRow = e.Row
					Dim cellCurrent As TableCell = rigaCorrente.Cells(rigaCorrente.Cells.Count - 1)
					cellCurrent.CssClass = "hidden"
				End If

				'Testo se è una row.
				If e.Row.RowType = DataControlRowType.DataRow Then

					'Ottengo la riga corrente.
					Dim rigaCorrente As GridViewRow = e.Row
					Dim paziente As CustomDataSource.Paziente = CType(rigaCorrente.DataItem, CustomDataSource.Paziente)


					Dim odsOrdini As ObjectDataSource = CType(rigaCorrente.FindControl("odsOrdini"), ObjectDataSource)
					odsOrdini.SelectParameters.Item("Codice").DefaultValue = codice
					odsOrdini.SelectParameters.Item("CodiceAzienda").DefaultValue = codiceAzienda
					odsOrdini.SelectParameters.Item("IdPaziente").DefaultValue = paziente.Id

					Dim gvOrdini As GridView = CType(rigaCorrente.FindControl("gvOrdini"), GridView)
					gvOrdini.DataBind()

					If gvOrdini.Rows.Count > 0 Then

						'
						' Creo il bottone per collassare la riga
						'
						Dim sbCellDiv As New StringBuilder
						sbCellDiv.AppendFormat("<button data-target='.{0}'", codice & codiceAzienda & paziente.Id)
						sbCellDiv.AppendFormat("        class='btn-link'")
						sbCellDiv.AppendFormat("        data-toggle='collapse'")
						sbCellDiv.AppendFormat("        type='button'>")
						sbCellDiv.AppendFormat(" <div class='ricercaavanzata-collapsing {0} collapse ' id='id-{1}'>", codice & codiceAzienda & paziente.Id, codice & codiceAzienda & paziente.Id)
						sbCellDiv.AppendFormat("            <span class='glyphicon glyphicon-minus'></span>")
						sbCellDiv.AppendFormat("        </div>")
						sbCellDiv.AppendFormat("        <div class='ricercaavanzata-collapsing {0} collapse in {1}'>", codice & codiceAzienda & paziente.Id, codice & codiceAzienda & paziente.Id)
						sbCellDiv.AppendFormat("            <span class='glyphicon glyphicon-plus'></span>")
						sbCellDiv.AppendFormat("        </div>")
						sbCellDiv.AppendFormat("</button>")

						rigaCorrente.Cells(0).Text = sbCellDiv.ToString()

						Dim sbCellDiv2 As New StringBuilder

						'Aggiungo l'icona per il link ai referti su DWH.
						sbCellDiv2.AppendFormat("<a id='DWHHyperLink' href='{0}' target='_blank'>", GetUrlRefertiDwh(paziente.Id))
						sbCellDiv2.AppendFormat("<img src ='../Images/dwh.gif' alt='visualizza i referti del paziente' title='visualizza i referti del paziente' />")
						sbCellDiv2.AppendFormat("</a>")

						'Aggiungo l'icona per il link al paziente su SAC.
						sbCellDiv2.AppendFormat("<a id='SacHyperLink' href='{0}' target='_blank'>", CustomDataSourceDettaglioPaziente.GetSacPazienteUrl(paziente.Id))
						sbCellDiv2.AppendFormat("<img src='../Images/person.gif' alt='visualizza il dettaglio del paziente' title='visualizza il dettaglio del paziente'/>")
						sbCellDiv2.AppendFormat("</a>")

						'Aggiungo il link per il collassamento della riga.
						sbCellDiv2.AppendFormat("<button data-target='.{0}'", codice & codiceAzienda & paziente.Id)
						sbCellDiv2.AppendFormat("        class='btn-link'")
						sbCellDiv2.AppendFormat("        data-toggle='collapse'")
						sbCellDiv2.AppendFormat("        type='button'>")
						sbCellDiv2.AppendFormat(" <div class='ricercaavanzata-collapsing {0} collapse ' id='id-{1}'>", codice & codiceAzienda & paziente.Id, codice & codiceAzienda & paziente.Id)
						sbCellDiv2.AppendFormat("             <strong>{0}</strong>", paziente.DatiAnagraficiPaziente)
						sbCellDiv2.AppendFormat("        </div>")
						sbCellDiv2.AppendFormat("        <div class='ricercaavanzata-collapsing {0} collapse in {1}'>", codice & codiceAzienda & paziente.Id, codice & codiceAzienda & paziente.Id)
						sbCellDiv2.AppendFormat("            <strong>{0}</strong>", paziente.DatiAnagraficiPaziente)
						sbCellDiv2.AppendFormat("        </div>")
						sbCellDiv2.AppendFormat("</button>")

						rigaCorrente.Cells(1).Text = sbCellDiv2.ToString()

						'
						' Cerco la tabella della griglia
						'
						Dim gvPazienti As GridView = CType(sender, GridView)
						Dim tblGrid As Table = CType(gvPazienti.Controls(0), Table)

						'
						' Recupero la posizione della riga corrente nella tabella
						'
						Dim nRowIndex As Integer = tblGrid.Rows.GetRowIndex(rigaCorrente)

						'
						' Crea una nuova riga e la posiziono dopo la riga corrente
						'
						Dim gvrSubFooter As New GridViewRow(nRowIndex + 1, 0, DataControlRowType.DataRow, DataControlRowState.Normal)

						'
						' Aggiungo classe Css alla riga per il collassamento della row tramite bootstrap
						'
						gvrSubFooter.CssClass = String.Format("ricercaavanzata-collapsing collapse {0}", codice & codiceAzienda & paziente.Id, codice & codiceAzienda & paziente.Id)

						' Creo una nuova cella per la riga aggiuntiva
						' Con il contenuto dell'ultima cella
						'
						Dim cellExpanded As TableCell
						cellExpanded = rigaCorrente.Cells(rigaCorrente.Cells.Count - 1)
						cellExpanded.ColumnSpan = gvPazienti.Columns.Count - 1


						'
						' Aggiunge due celle alla nuova riga
						'
						gvrSubFooter.Cells.Add(New TableCell())
						gvrSubFooter.Cells.Add(cellExpanded)

						'
						' Aggiunge la nuova riga alla tabella della griglia
						'
						tblGrid.Controls.AddAt(nRowIndex + 1, gvrSubFooter)
						'
						' Sostituosce l'ultima colonna con una cella vuota e la nasconde
						'
						Dim cellReplace As New TableCell
						cellReplace.CssClass = "hidden"
						rigaCorrente.Cells.Add(cellReplace)
					Else
						'
						' Nasconde l'ultima colonna della riga
						'
						Dim cellCurrent As TableCell = rigaCorrente.Cells(rigaCorrente.Cells.Count - 1)
						cellCurrent.CssClass = "hidden"
					End If
				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		''' <summary>
		''' Cancella la cache della objectdatasource.
		''' </summary>
		Private Sub ClearCache()
			Try
				Dim ds As New CustomDataSource.RepartiPendenti
				ds.ClearCache()
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Private Sub PeriodoDropDownList_SelectedIndexChanged(sender As Object, e As EventArgs) Handles PeriodoDropDownList.SelectedIndexChanged
			Try
				'Cancello la cache
				ClearCache()
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Private Sub PersonaliCheckBox_CheckedChanged(sender As Object, e As EventArgs) Handles PersonaliCheckBox.CheckedChanged
			Try
				'Cancello la cache
				ClearCache()
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Private Sub TipoDropDownList_SelectedIndexChanged(sender As Object, e As EventArgs) Handles TipoDropDownList.SelectedIndexChanged
			Try
				'Cancello la cache
				ClearCache()
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Private Sub odsReparti_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsReparti.Selected
			Try
				If e.Exception IsNot Nothing Then

					If (e.Exception.InnerException IsNot Nothing) AndAlso (TypeOf e.Exception.InnerException Is ApplicationException) Then
						divErrorMessage.Visible = True
						ErrorLabel.Text = e.Exception.InnerException.Message
						e.ExceptionHandled = True

					ElseIf e.Exception.InnerException IsNot Nothing AndAlso e.Exception.InnerException.Message.Contains("Accesso negato") Then

						ExceptionsManager.TraceException(e.Exception)
						DataAdapterManager.PortalAdminDataAdapterManager.TracciaErrori(e.Exception, User.Identity.Name, PortalsNames.OrderEntry)

						e.ExceptionHandled = True

						Dim parameters = New Dictionary(Of String, String)()
						parameters.Add("message", e.Exception.InnerException.Message)

						Global_asax.RedirectWithPost("~\AccessDenied.aspx", parameters)
					Else

						ExceptionsManager.TraceException(e.Exception)
						DataAdapterManager.PortalAdminDataAdapterManager.TracciaErrori(e.Exception, User.Identity.Name, PortalsNames.OrderEntry)
						e.ExceptionHandled = True


						ErrorLabel.Text = ExceptionsManager.ManageWebServiceException(e.Exception)
						divErrorMessage.Visible = True
					End If
				End If
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
			ErrorLabel.Text = errorMessage
		End Sub
	End Class
End Namespace