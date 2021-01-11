Imports System.Collections.Generic
Imports System.ComponentModel
Imports System.Linq
Imports System.Text
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.OrderEntry.Services
Imports DI.PortalUser2.Data

Namespace DI.OrderEntry.User

	Public Class RiassuntoOrdine
		Inherits Page

#Region "Properties"
		Public Property IdRichiesta() As String
			Get
				Return Me.ViewState("IdRichiesta")
			End Get
			Set(ByVal value As String)
				Me.ViewState.Add("IdRichiesta", value)
			End Set
		End Property
		Public Property Nosologico() As String
			Get
				Return Me.ViewState("Nosologico")
			End Get
			Set(ByVal value As String)
				Me.ViewState.Add("Nosologico", value)
			End Set
		End Property
		Public Property isAccessoDiretto() As Boolean
			Get
				Return Me.ViewState("isAccessoDiretto")
			End Get
			Set(ByVal value As Boolean)
				Me.ViewState.Add("isAccessoDiretto", value)
			End Set
		End Property

		Public Property IdPaziente() As String
			Get
				Return Me.ViewState("IdPaziente")
			End Get
			Set(ByVal value As String)
				Me.ViewState.Add("IdPaziente", value)
			End Set
		End Property

		Dim ExecuteErogantiSelect As Boolean = False
#End Region

		Private Sub RiassuntoOrdine_PreInit(sender As Object, e As EventArgs) Handles Me.PreInit
			Try
				If RouteData.Values("AccessoDiretto") IsNot Nothing Then
					isAccessoDiretto = CType(RouteData.Values("AccessoDiretto"), Boolean)
					If isAccessoDiretto Then
						Me.MasterPageFile = "~/SiteAccessoDiretto.master"
					End If
				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
			Try
				'Ricavo dai parametri della querystring i dati necessari perchè alcune operazioni da effettuare in seguito funzionino
				If Not Page.IsPostBack Then

					'Cancello la cache per evitare di utilizzare dati vecchi o sbagliati
					Dim dataSource2 As New DI.OrderEntry.User.PrestazioniErogate
					dataSource2.ClearCache()

					Me.IdRichiesta = Request.QueryString("IdRichiesta")
					Me.Nosologico = Request.QueryString("Nosologico")
					Me.IdPaziente = Request.QueryString("IdPaziente")

					'Inizializzo il Custom control relativo al dettaglio paziente coi giusti dati
					DettaglioPaziente.Nosologico = Me.Nosologico
					DettaglioPaziente.IdPaziente = Me.IdPaziente
					DettaglioPaziente.ExecuteQuery = True
					DettaglioPaziente.DataBind()

					UcToolbar.IsAccessoDiretto = RouteData.Values("AccessoDiretto")
					UcToolbar.IdRichiesta = Me.IdRichiesta
					UcToolbar.Nosologico = Me.Nosologico
					UcToolbar.IdPaziente = Me.IdPaziente

					'
					'2020-07-15 Kyrylo: Traccia Operazioni
					'
					Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalUser)
					oTracciaOp.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Visualizzato dettaglio ordine", New Guid(IdPaziente), Nothing, IdRichiesta, "IdRichiesta")

				End If

				Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
					Dim userData = UserDataManager.GetUserData()
					' Modifica al nome request in wsRequest causa ambiguità con la request del http
					Dim wsRequest = New OttieniOrdinePerIdGuidRequest(userData.Token, Me.IdRichiesta)
					Dim resp = webService.OttieniOrdinePerIdGuid(wsRequest)
					Dim Richiesta As StatoType = resp.OttieniOrdinePerIdGuidResult

					If Richiesta IsNot Nothing Then

						'inizializzo i campi con i relativi valori
						lblIdRichiesta.InnerText = CType(Richiesta.Ordine.IdRichiestaOrderEntry, String)
						lblUo.InnerText = CType(Richiesta.Ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione, String)
						lblRegime.InnerText = CType(Richiesta.Ordine.Regime.Descrizione, String)
						lblPriorita.InnerText = CType(Richiesta.Ordine.Priorita.Descrizione, String)
						'Imposto il tasto "Elimina" abilitato o disabilitato tramite l'attrributo Cancellabile della Richiesta
						UcToolbar.IsEliminabile = CType(Richiesta.Ordine.Cancellabile, Boolean)

						Dim dataPrenotazione As String = If(Not Richiesta.Ordine.DataPrenotazione.HasValue OrElse Richiesta.Ordine.DataPrenotazione = DateTime.MinValue, "-", Richiesta.Ordine.DataPrenotazione.Value.ToString("dd/MM/yy HH:mm"))
						lblDataPrenotazione.InnerText = CType(dataPrenotazione, String)
						ExecuteErogantiSelect = True
						gvEroganti.DataBind()
					End If

				End Using

                '2020-01-21 Kyrylo: Se si è in accesso diretto controllo la presenza del parametro ShowPannelloPaziente e visualizzo o meno il pannello paziente
                If Me.isAccessoDiretto Then
                    Dim showPannelloPaziente As String = Request.QueryString("ShowPannelloPaziente")
                    If Not String.IsNullOrEmpty(showPannelloPaziente) Then
                        Dim bShowPannelloPaziente As Boolean = True
                        If Boolean.TryParse(showPannelloPaziente, bShowPannelloPaziente) Then
                            DettaglioPaziente.Visible = bShowPannelloPaziente
                        End If
                    End If
                End If

            Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Private Sub odsEroganti_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsEroganti.Selecting
			Try
				e.Cancel = Not ExecuteErogantiSelect
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Private Sub gvEroganti_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvEroganti.RowDataBound
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

				If e.Row.RowType = DataControlRowType.DataRow Then

					'Ottengo la riga corrente.
					Dim rigaCorrente As GridViewRow = e.Row
					Dim erogante = rigaCorrente.DataItem

					Dim gvPrestazioni As GridView = CType(rigaCorrente.FindControl("gvPrestazioni"), GridView)
					Dim odsPrestazioni As ObjectDataSource = CType(rigaCorrente.FindControl("odsPrestazioni"), ObjectDataSource)
					odsPrestazioni.SelectParameters.Item("Sistema").DefaultValue = erogante
					gvPrestazioni.DataBind()

					If gvPrestazioni.Rows.Count > 0 Then

						'
						' Creo il bottone per collassare la riga
						'
						Dim sbCellDiv As New StringBuilder
						sbCellDiv.AppendFormat("<button data-target='.{0}'", erogante)
						sbCellDiv.AppendFormat("        class='btn-link btn-xs'")
						sbCellDiv.AppendFormat("        data-toggle='collapse'")
						sbCellDiv.AppendFormat("        type='button'>")
						sbCellDiv.AppendFormat(" <div class='{0} collapse in ' id='id-{1}'>", erogante, erogante)
						sbCellDiv.AppendFormat("            <span class='glyphicon glyphicon-minus'></span>")
						sbCellDiv.AppendFormat("        </div>")
						sbCellDiv.AppendFormat("        <div class='{0} collapse {1}'>", erogante, erogante)
						sbCellDiv.AppendFormat("            <span class='glyphicon glyphicon-plus'></span>")
						sbCellDiv.AppendFormat("        </div>")
						sbCellDiv.AppendFormat("</button>")

						rigaCorrente.Cells(0).Text = sbCellDiv.ToString()

						Dim sbCellDiv2 As New StringBuilder
						sbCellDiv2.AppendFormat("<button data-target='.{0}'", erogante)
						sbCellDiv2.AppendFormat("        class='btn-link btn-xs'")
						sbCellDiv2.AppendFormat("        data-toggle='collapse'")
						sbCellDiv2.AppendFormat("        type='button'>")
						sbCellDiv2.AppendFormat(" <div class='{0} collapse in' id='id-{1}'>", erogante, erogante)
						sbCellDiv2.AppendFormat("             <strong>{0}</strong>", erogante)
						sbCellDiv2.AppendFormat("        </div>")
						sbCellDiv2.AppendFormat("        <div class='{0} collapse {1}'>", erogante, erogante)
						sbCellDiv2.AppendFormat("            <strong>{0}</strong>", erogante)
						sbCellDiv2.AppendFormat("        </div>")
						sbCellDiv2.AppendFormat("</button>")

						rigaCorrente.Cells(1).Text = sbCellDiv2.ToString()

						'
						' Cerco la tabella della griglia
						'
						Dim gvEroganti As GridView = CType(sender, GridView)
						Dim tblGrid As Table = CType(gvEroganti.Controls(0), Table)

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
						gvrSubFooter.CssClass = String.Format("collapse in {0}", erogante)

						' Creo una nuova cella per la riga aggiuntiva
						' Con il contenuto dell'ultima cella
						'
						Dim cellExpanded As TableCell
						cellExpanded = rigaCorrente.Cells(rigaCorrente.Cells.Count - 1)
						cellExpanded.ColumnSpan = gvPrestazioni.Columns.Count - 1


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

		Protected Sub gvPrestazioni_RowCommand(sender As Object, e As GridViewCommandEventArgs)
			Try
				If String.Equals(e.CommandName, "ApriDatiAccessori") Then

					Dim idPrestazione As String = e.CommandArgument

					'Imposto il parametro su cui l'odsProfilo deve effettuare la query di selezione
					odsModalDatiAccessori.SelectParameters("idPrestazione").DefaultValue = idPrestazione

					'Faccio il DataBind della listView associata ai dati accessori delle singole prestazioni
					lwDatiAccessori.DataBind()

					'Ottengo la row
					Dim gvr As GridViewRow = CType(CType(e.CommandSource, LinkButton).NamingContainer, GridViewRow)

					'Ottengo l'index della row
					Dim RowIndex As Integer = gvr.RowIndex

					Dim gridview As GridView = CType(sender, GridView)

					'Ottengo la descrizione della prestazione relativa alla row selezionata
					Dim descrizioneprestazione As String = gridview.DataKeys(RowIndex)("Descrizione")

					lblDatiAccessoriRichiestaTitle.InnerText = $"Dati accessori prestazione ""{descrizioneprestazione}"""

					'Apro la modale contestuale
					ClientScript.RegisterStartupScript(Me.GetType(), "DatiAccessoriPrestazione", "$('#modalDatiAccessori').modal('show');", True)

				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		''' <summary>
		''' Ottiene la lista dei distinti CodiciEroganti tramite query LINQ sull'oggetto restituito da GetPrestazioniInseriteFromRichiesta
		''' </summary>
		''' <param name="IdRichiesta"></param>
		''' <returns></returns>
		<DataObjectMethod(DataObjectMethodType.Select)>
		Public Shared Function GetDistinctSistemiFromPrestazioni(IdRichiesta As String) As List(Of String)
			Dim eroganti As New List(Of String)
			Try
				Dim datasource As New PrestazioniErogate
				'ottengo tutte le prestazioni della richiesta
				Dim listaPrestazioni As List(Of PrestazioneErogata) = datasource.GetData(IdRichiesta)

				eroganti = (From prestazione In listaPrestazioni
							Select prestazione.SistemaErogante).Distinct().ToList()
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
			End Try
			Return eroganti
		End Function

		''' <summary>
		''' Ottiene la lista delle prestazioni per l'erogante e id richiesta
		''' </summary>
		''' <param name="IdRichiesta"></param>
		''' <param name="Sistema"></param>
		''' <returns></returns>
		<DataObjectMethod(DataObjectMethodType.Select)>
		Public Shared Function GetPrestazioniBySistema(IdRichiesta As String, Sistema As String) As List(Of PrestazioneErogata)

			Dim prestazioni As New List(Of PrestazioneErogata)

			Try
				Dim datasource As New PrestazioniErogate
				'ottengo tutte le prestazioni della richiesta
				Dim listaPrestazioni As List(Of PrestazioneErogata) = datasource.GetData(IdRichiesta)

				If listaPrestazioni IsNot Nothing AndAlso listaPrestazioni.Count > 0 Then
					prestazioni = (From prestazione In listaPrestazioni
								   Where String.Equals(prestazione.SistemaErogante, Sistema)
								   Select prestazione).ToList()
				End If
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
			End Try

			Return prestazioni
		End Function

		Private Sub odsDatiAccessoriTestata_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDatiAccessoriTestata.Selected
			Try
				If (Not (CType(e.ReturnValue, DatiAggiuntiviType).Count = 0) AndAlso (Not (e.ReturnValue) Is Nothing)) Then
					DatiAccessoriIcon.Visible = True
				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Private Sub gvEroganti_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvEroganti.RowCommand
			Try
				If String.Equals(e.CommandName, "ApriDatiAccessori") Then

					Dim sistemaErogante As String = e.CommandArgument

					'Imposto il parametro su cui l'odsProfilo deve effettuare la query di selezione
					odsDatiAggiuntiviSistemaErogante.SelectParameters("SistemaErogante").DefaultValue = sistemaErogante

					'Faccio il DataBind della listView associata ai dati accessori delle singole prestazioni
					lvDatiAggiuntiviErogante.DataBind()

					'Apro la modale contestuale
					ClientScript.RegisterStartupScript(Me.GetType(), "DatiAccessoriPrestazione", "$('#modalDatiAccessoriSistemaErogante').modal('show');", True)
				End If

			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Protected Sub gvPrestazioni_RowDataBound(sender As Object, e As GridViewRowEventArgs)
			Try
				If e.Row.RowType = DataControlRowType.DataRow Then
					'Ottengo la riga corrente.
					Dim rigaCorrente As GridViewRow = e.Row
					Dim prestazione As PrestazioneErogata = CType(rigaCorrente.DataItem, PrestazioneErogata)

					If prestazione.SoloErogato Then
						e.Row.CssClass = "active"
					Else
						Select Case prestazione.CodiceStatoErogante
							Case "CA"
								e.Row.CssClass = "danger"
							Case "CM"
								e.Row.CssClass = "success"
							Case "IC"
								e.Row.CssClass = "info"
							Case "IP"
								e.Row.CssClass = "info"
							Case Else
								e.Row.CssClass = "success"
						End Select
					End If
				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

#Region "Utilities"
		Protected Function SaveBase64AndGetId(base64 As String) As String
			Dim hash As String = String.Empty
			Try
				hash = base64.GetHashCode().ToString

				If HttpContext.Current.Cache(hash) IsNot Nothing Then
					Return hash
				Else
					HttpContext.Current.Cache.Add(hash, base64, Nothing, System.Web.Caching.Cache.NoAbsoluteExpiration, New TimeSpan(0, 30, 0), System.Web.Caching.CacheItemPriority.BelowNormal, Nothing)

					Return hash
				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
			Return hash
		End Function

		''' <summary>
		''' Controlla se la prestazione contiene dei dati accessori.
		''' </summary>
		''' <param name="IdPrestazione"></param>
		''' <returns></returns>
		Protected Function HasPrestazioneDatiAccessori(IdPrestazione As String) As Boolean
			Dim res As Boolean = False
			Try
				Dim ds As New DI.OrderEntry.User.RiassuntoOrdineMethods
				Dim datiAgg As List(Of DatoNomeValoreType) = ds.DatiAggiuntiviPrestazione(Me.IdRichiesta, IdPrestazione)
				If datiAgg IsNot Nothing AndAlso datiAgg.Count > 0 Then
					res = True
				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
			Return res
		End Function

		''' <summary>
		''' Controlla se il sistema ha dei dati accessori
		''' </summary>
		''' <param name="IdSistema"></param>
		''' <returns></returns>
		Protected Function HasSistemaDatiAccessori(IdSistema As String) As Boolean
			Dim res As Boolean = False
			Try
				Dim datiAgg As List(Of DatoNomeValoreType) = RiassuntoOrdineMethods.DatiAggiuntiviSistemaErogante(Me.IdRichiesta, IdSistema)
				If datiAgg IsNot Nothing AndAlso datiAgg.Count > 0 Then
					res = True
				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
			Return res
		End Function

		''' <summary>
		''' Recupero il campo etichetta dall'oggetto DatoAccessorio
		''' </summary>
		''' <param name="oDatoAccessorio"></param>
		''' <returns></returns>
		Protected Function GetEtichetta(oDatoAccessorio As Object) As String
			Dim etichetta As String = String.Empty

			Try


				Try
					Dim datoAccessorio As DatoAccessorioType = CType(oDatoAccessorio, DatoAccessorioType)
					etichetta = datoAccessorio.Etichetta
				Catch ex As Exception
					'
					'Vado avanti
					'
				End Try
			Catch ex As Exception

			End Try
			Return etichetta
		End Function

		Protected Function GetDatoAccessorioVisibility(oTipoContenuto As Object) As Integer
			Dim isVisible As Boolean = False
			Try
				If oTipoContenuto IsNot Nothing Then
					If oTipoContenuto.ToString().ToUpper() = "PDF" Then
						isVisible = True
					End If
				End If
			Catch ex As Exception
				'NON FACCIO NULLA
			End Try
			Return isVisible
		End Function

		Protected Function GetStatoErogante(oRow As Object) As String
			Dim statoErogante As String = String.Empty
			Try

				If oRow IsNot Nothing Then
					Dim prestazione As PrestazioneErogata = CType(oRow, PrestazioneErogata)

					If Not String.IsNullOrEmpty(prestazione.StatoErogante) Then
						statoErogante = prestazione.StatoErogante
					Else
						If Not String.IsNullOrEmpty(prestazione.DescrizioneOperazioneRigaRichiesta) Then
							statoErogante = prestazione.DescrizioneOperazioneRigaRichiesta
						End If
					End If
				End If
			Catch ex As Exception
				'NON FACCIO NULLA
			End Try

			Return statoErogante
		End Function

		''' <summary>
		''' funzione di utility per eliminare la classe bootstrap Form-control-static se il valore del dato accessorio è troppo lungo
		''' (perchè si presenta un errore grafico causato da un bug bootstrap)
		''' </summary>
		''' <param name="oValoreDato"></param>
		''' <returns></returns>
		Protected Function GetClassValoreDato(oValoreDato As Object)
			Dim sClass As String = "form-control-static"

			Try
				If oValoreDato IsNot Nothing Then
					Dim valoreDato As String = CType(oValoreDato, String)

					If valoreDato.Length > 80 Then
						sClass = ""
					End If
				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try

			Return sClass
		End Function

		''' <summary>
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
#End Region

	End Class
End Namespace