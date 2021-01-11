Imports System.Web.UI
Imports DI.OrderEntry.Services
Imports DI.PortalUser2.Data
Imports System.Web.UI.WebControls
Imports System.Text
Imports System.ComponentModel
Imports System.Collections.Generic
Imports System.Linq
Imports CustomDataSource

Namespace DI.OrderEntry.User

	Public Class ConfermaInoltro
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
		Public Property IdPaziente() As String
			Get
				Return Me.ViewState("IdPaziente")
			End Get
			Set(ByVal value As String)
				Me.ViewState.Add("IdPaziente", value)
			End Set
		End Property

		Dim ExecuteErogantiSelect As Boolean = False
		Dim isAccessoDiretto As Boolean = False
#End Region

#Region "Metodi"
		Private Sub ConfermaInoltro_PreInit(sender As Object, e As EventArgs) Handles Me.PreInit
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
		Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
			Try
				'Ricavo dai parametri della querystring i dati necessari perchè alcune operazioni da effettuare in seguito funzionino
				If Not Page.IsPostBack Then
					Me.IdRichiesta = Request.QueryString("IdRichiesta")
					Me.Nosologico = Request.QueryString("Nosologico")
					Me.IdPaziente = Request.QueryString("IdPaziente")
				End If

				'Inizializzo il Custom control relativo al dettaglio paziente coi giusti dati
				DettaglioPaziente.Nosologico = Me.Nosologico
				DettaglioPaziente.IdPaziente = Me.IdPaziente
				DettaglioPaziente.ExecuteQuery = True
                DettaglioPaziente.DataBind()

                'Carico la toolbar
                UcToolbar.IsAccessoDiretto = RouteData.Values("AccessoDiretto")
				UcToolbar.IdRichiesta = Me.IdRichiesta
				UcToolbar.Nosologico = Me.Nosologico
				UcToolbar.IdPaziente = Me.IdPaziente


                'Controllo che il parametro IdRichiesta venga passato nella querystring
                If (IdRichiesta Is Nothing) Then
                    InizializzaCampiTestataOrdine()
                    Throw New ApplicationException("Il parametro IdRichiesta non è presente nella querystring o è in un formato non leggibile")
                End If

                Dim userData = UserDataManager.GetUserData()

                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                    ' Modifica al nome request in wsRequest causa ambiguità con la request del http
                    Dim wsRequest = New OttieniOrdinePerIdGuidRequest(userData.Token, Me.IdRichiesta)
                    Dim resp = webService.OttieniOrdinePerIdGuid(wsRequest)
                    Dim Richiesta As StatoType = resp.OttieniOrdinePerIdGuidResult

                    If Richiesta IsNot Nothing Then
                        If String.Equals(Richiesta.DescrizioneStato.ToString(), "Inoltrato") Then
                            Response.Redirect(Utility.buildUrl($"~/Pages/ListaOrdini.aspx", Me.isAccessoDiretto))
                        End If

                        'Controllo che il tipo di ritorno del WS sia valorizzato
                        'Se non lo è entro in questo if e visualizzo un messaggio di errore
                        If (Richiesta Is Nothing) Then
                            Throw New ApplicationException("L'ordine è inesistente o non contiene prestazioni.")
                            InizializzaCampiTestataOrdine()
                        End If


                        Dim valido As Boolean = Richiesta.StatoValidazione.Stato = StatoValidazioneEnum.AA
                        'Se entro qui vuol dire che Richiesta è valorizzato e procedo con la compilazione dei campi
                        If (valido = False) Then
                            ValidoError.Visible = True
                            ValidoError.Attributes.Item("Title") = CType(Richiesta.StatoValidazione.Descrizione, String)
                        End If

                        Dim dataPrenotazione As String = If(Not Richiesta.Ordine.DataPrenotazione.HasValue OrElse Richiesta.Ordine.DataPrenotazione = DateTime.MinValue, "-", Richiesta.Ordine.DataPrenotazione.Value.ToString("dd/MM/yy HH:mm"))

                        'inizializzo i campi con i relativi valori
                        lblIdRichiesta.InnerText = CType(Richiesta.Ordine.IdRichiestaOrderEntry, String)
                        lblUo.InnerText = CType(Richiesta.Ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione, String)
                        lblRegime.InnerText = CType(Richiesta.Ordine.Regime.Descrizione, String)
                        lblPriorita.InnerText = CType(Richiesta.Ordine.Priorita.Descrizione, String)
                        lblDataPrenotazione.InnerText = CType(dataPrenotazione, String)
                        ExecuteErogantiSelect = True
                        gvEroganti.DataBind()
                    End If

                    '2020-01-21 Kyrylo: Se si è in accesso diretto controllo la presenza del parametro ShowPannelloPaziente e visualizzo o meno il pannello paziente
                    If isAccessoDiretto Then
                        Dim showPannelloPaziente As String = Request.QueryString("ShowPannelloPaziente")
                        If Not String.IsNullOrEmpty(showPannelloPaziente) Then
                            Dim bShowPannelloPaziente As Boolean = True
                            If Boolean.TryParse(showPannelloPaziente, bShowPannelloPaziente) Then
                                DettaglioPaziente.Visible = bShowPannelloPaziente
                            End If
                        End If
                    End If

                End Using

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
                        sbCellDiv.AppendFormat(" <div class='{0} collapse ' id='id-{1}'>", erogante, erogante)
                        sbCellDiv.AppendFormat("            <span class='glyphicon glyphicon-minus'></span>")
                        sbCellDiv.AppendFormat("        </div>")
                        sbCellDiv.AppendFormat("        <div class='{0} collapse in {1}'>", erogante, erogante)
                        sbCellDiv.AppendFormat("            <span class='glyphicon glyphicon-plus'></span>")
                        sbCellDiv.AppendFormat("        </div>")
                        sbCellDiv.AppendFormat("</button>")

                        rigaCorrente.Cells(0).Text = sbCellDiv.ToString()

                        Dim sbCellDiv2 As New StringBuilder
                        sbCellDiv2.AppendFormat("<button data-target='.{0}'", erogante)
                        sbCellDiv2.AppendFormat("        class='btn-link btn-xs'")
                        sbCellDiv2.AppendFormat("        data-toggle='collapse'")
                        sbCellDiv2.AppendFormat("        type='button'>")
                        sbCellDiv2.AppendFormat(" <div class='{0} collapse ' id='id-{1}'>", erogante, erogante)
                        sbCellDiv2.AppendFormat("             <strong>{0}</strong>", erogante)
                        sbCellDiv2.AppendFormat("        </div>")
                        sbCellDiv2.AppendFormat("        <div class='{0} collapse in {1}'>", erogante, erogante)
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
                        gvrSubFooter.CssClass = String.Format("collapse {0}", erogante)

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
        Private Sub odsDatiAccessoriTestata_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDatiAccessoriTestata.Selected
            Try
                If (Not (CType(e.ReturnValue, DatiAggiuntiviType).Count = 0) AndAlso (Not (e.ReturnValue) Is Nothing)) Then
                    DatiAccessoriIcon.Visible = True
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
#End Region

#Region "Utilities"

        'Recupero il campo etichetta dall'oggetto DatoAccessorio
        Protected Function GetEtichetta(oDatoAccessorio As Object) As String
            Dim etichetta As String = String.Empty
            Try
                Dim datoAccessorio As DatoAccessorioType = CType(oDatoAccessorio, DatoAccessorioType)
                etichetta = datoAccessorio.Etichetta
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return etichetta
        End Function

        'Controllo se la prestazione contiene dei dati accessori.
        Function HasPrestazioneDatiAccessori(IdPrestazione As String) As Boolean
            Dim res As Boolean = False
            Try
                Dim dataSource As New CustomDataSource.DatiAggiuntivi

                res = If(dataSource.GetDataByPrestazione(IdRichiesta, IdPrestazione) Is Nothing, False, True)
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return res
        End Function

        'Controllo se la richiesta contiene dei dati accessori.
        Function HasDatiAccessori() As Boolean
            Dim res As Boolean = False
            Try
                Dim temp = New CustomDataSource.DatiAccessori
                Dim datiaccessoririchiesta = temp.GetDataByIdRichiesta(Me.IdRichiesta)
                res = datiaccessoririchiesta IsNot Nothing AndAlso datiaccessoririchiesta.Count > 0
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return res
        End Function

        'Sbianco i campi della testata dell'ordine.
        Private Sub InizializzaCampiTestataOrdine()
            lblIdRichiesta.InnerText = "-"
            lblUo.InnerText = "-"
            lblRegime.InnerText = "-"
            lblPriorita.InnerText = "-"
            lblDataPrenotazione.InnerText = "-"
            DatiAccessoriIcon.Visible = False
        End Sub


        ''' <summary>
        ''' Ottiene la lista dei distinti CodiciEroganti tramite query LINQ sull'oggetto restituito da GetPrestazioniInseriteFromRichiesta
        ''' </summary>
        ''' <param name="Id"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select)>
        Public Shared Function GetDistinctSistemiFromPrestazioni(Id As String) As List(Of String)
            Dim eroganti As New List(Of String)
            Try
                Dim datasource As New CustomDataSource.Prestazioni
                'ottengo tutte le prestazioni della richiesta
                Dim listaPrestazioni As List(Of Prestazione) = datasource.GetDataByIdRichiesta(Id)

                eroganti = (From prestazione In listaPrestazioni
                            Select prestazione.SistemaErogante).Distinct().ToList()
            Catch ex As Exception
                Throw New Exception()
            End Try
            Return eroganti
        End Function

        <DataObjectMethod(DataObjectMethodType.Select)>
        Public Shared Function GetPrestazioniBySistema(Id As String, Sistema As String) As List(Of Prestazione)
            Dim prestazioni As New List(Of Prestazione)

            Try
                Dim datasource As New CustomDataSource.Prestazioni
                'ottengo tutte le prestazioni della richiesta
                Dim listaPrestazioni As List(Of Prestazione) = datasource.GetDataByIdRichiesta(Id)

                If listaPrestazioni IsNot Nothing AndAlso listaPrestazioni.Count > 0 Then
                    prestazioni = (From prestazione In listaPrestazioni
                                   Where String.Equals(prestazione.SistemaErogante, Sistema)
                                   Select prestazione).ToList()
                End If
            Catch ex As Exception
                Throw New Exception()
            End Try
            Return prestazioni
        End Function

#End Region

#Region "Toolbar"

        'Metodo per inoltrare un ordine.
        Public Sub Inoltra()
            Dim resp As New InoltraOrdinePerIdGuidResponse
            Try
                Dim userData = UserDataManager.GetUserData()
                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                    Dim inoltraRequest = New InoltraOrdinePerIdGuidRequest(userData.Token, Me.IdRichiesta)
                    resp = webService.InoltraOrdinePerIdGuid(inoltraRequest)
                    If resp.InoltraOrdinePerIdGuidResult.Ordine IsNot Nothing Then
                        If resp.InoltraOrdinePerIdGuidResult.StatoValidazione.Stato = StatoValidazioneEnum.AE Then
                            Throw New ApplicationException($"{resp.InoltraOrdinePerIdGuidResult.StatoValidazione.Descrizione.ToString().Replace("'", "\'")}")
                        Else

                            ' Modifica Leo: 2019-11-05 aggiunto controllo come nel metodo: InoltraEStampa
                            If resp IsNot Nothing AndAlso resp.InoltraOrdinePerIdGuidResult.StatoValidazione.Stato <> StatoValidazioneEnum.AA Then
                                Throw New ApplicationException($"{resp.InoltraOrdinePerIdGuidResult.StatoValidazione.Descrizione.ToString().Replace("'", "\'")}")
                            End If

                            If Me.isAccessoDiretto Then
                                Dim parametri As String = $"?IdRichiesta={Me.IdRichiesta}&IdPaziente={Me.IdPaziente}"
                                If Not String.IsNullOrEmpty(Me.Nosologico) Then
                                    parametri += $"&Nosologico={Me.Nosologico}"
                                End If

                                ' 2020-01-20 Kyrylo : Se da QueryString è presente il parametro ShowPannelloPaziente allora lo aggiungo all'url della pagina successiva
                                Dim showPannelloPaziente As String = Request.QueryString("ShowPannelloPaziente")
                                If Not String.IsNullOrEmpty(showPannelloPaziente) Then
                                    Dim bShowPannelloPaziente As Boolean = True
                                    If Boolean.TryParse(showPannelloPaziente, bShowPannelloPaziente) Then
                                        parametri += $"&ShowPannelloPaziente={bShowPannelloPaziente}"
                                    End If
                                End If

                                ' Modifica Leo: 2019-11-05  Sostituito parametro EndResponse = Me.isAccessoDiretto con True (poichè sempre True se entro in questo If)
                                Response.Redirect(Utility.buildUrl($"~/Pages/RiassuntoOrdine.aspx{parametri}", True))
                            End If

                            '
                            '2020-07-16 Kyrylo: Traccia Operazioni 
                            '
                            Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalUser)
                            oTracciaOp.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Inoltrato ordine", New Guid(Me.IdPaziente), Nothing, Me.IdRichiesta, "IdRichiesta")


                            Response.Redirect($"~/Pages/ListaOrdini.aspx")
                        End If
                    Else
                        Throw New ApplicationException("Si è verificato un errore. Contattare l'amministratore del sito.")
                    End If
                End Using

            Catch ex As Exception
                gestioneErrori(ex)
            End Try

        End Sub

        'Metodo per salvare in bozza un ordine.
        Public Sub Salva()
            Try
                'Modifica Leo 2019-11-05: modificato comportamento del calcolo dell'url in cui navigare (prima andava sempre in "AccessoDirettoMessage.aspx?mode=Saved")
                Dim nextPage As String = String.Empty
                If Me.isAccessoDiretto Then
                    nextPage = Utility.buildUrl("AccessoDirettoMessage.aspx?mode=Saved", Me.isAccessoDiretto)
                Else
                    If Session("entryPage") IsNot Nothing Then
                        Dim url = Session("entryPage").ToString()
                        nextPage = url.Substring(url.IndexOf("Pages/") + 6)
                    End If
                End If

                '
                ' Quando salvo in bozza segnalo che  l'ordine non è stato inoltrato.
                '
                Dim script As String = "ConfirmMessage('Attenzione: Ordine non inserito. Continuare comunque?','" + nextPage + "');"
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "Script", script, True)
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        'Metodo per inoltrare e stampare un ordine.
        Public Sub InoltraEStampa()
            Try
                Dim scriptErrore As String = String.Empty
                Dim userData = UserDataManager.GetUserData()
                Dim oResponse As InoltraOrdinePerIdGuidResponse
                If String.IsNullOrEmpty(Me.IdRichiesta) Then
                    '
                    'Se idRichiesta non è valorizzato allora mostro un errore.
                    '
                    Throw New ApplicationException("Si è verificato un errore: il parametro IdRichiesta non è valorizzato correttamente")
                End If

                'Ricavo l'oggetto oResponse, risultato dell'operazione di inoltro
                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                    Dim inoltraRequest = New InoltraOrdinePerIdGuidRequest(userData.Token, Me.IdRichiesta)
                    oResponse = webService.InoltraOrdinePerIdGuid(inoltraRequest)
                    If oResponse.InoltraOrdinePerIdGuidResult.Ordine IsNot Nothing Then
                        If oResponse.InoltraOrdinePerIdGuidResult.StatoValidazione.Stato = StatoValidazioneEnum.AE Then
                            Throw New ApplicationException($"{oResponse.InoltraOrdinePerIdGuidResult.StatoValidazione.Descrizione.ToString().Replace(" '", "\'")}")
                        End If
                    Else
                        Throw New Exception
                    End If
                End Using

                '
                'Se l'inserimento non è andato a buon fine allora mostro l'errore.
                '
                If oResponse IsNot Nothing AndAlso oResponse.InoltraOrdinePerIdGuidResult.StatoValidazione.Stato <> StatoValidazioneEnum.AA Then
                    Throw New ApplicationException($"{oResponse.InoltraOrdinePerIdGuidResult.StatoValidazione.Descrizione.ToString().Replace("'", "\'")}")
                End If

                'Se sono arrivato fin qui allora non si sono verificati errori
                'Eseguo un redirect alla pagina di anteprima di stampa dell'ordine.
                Response.Redirect($"~\Reports\StampaOrdine.aspx?IdRichiesta={Me.IdRichiesta}", False)

            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

#End Region

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