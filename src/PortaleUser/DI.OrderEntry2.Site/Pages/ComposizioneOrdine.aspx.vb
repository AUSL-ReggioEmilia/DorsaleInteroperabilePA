Imports System.Collections.Generic
Imports System.Linq
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports CustomDataSource
Imports DI.OrderEntry.Services
Imports DI.PortalUser2.Data

Namespace DI.OrderEntry.User
    Public Class ComposizioneOrdine
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

        Public Property AziendaUo() As String
            Get
                Return Me.ViewState("AziendaUo")
            End Get
            Set(ByVal value As String)
                Me.ViewState.Add("AziendaUo", value)
            End Set
        End Property

        Public Property DataPrenotazione() As DateTime?
            Get
                Return Me.ViewState("DataPrenotazione")
            End Get
            Set(ByVal value As DateTime?)
                Me.ViewState.Add("DataPrenotazione", value)
            End Set
        End Property

        Public Property Regime() As String
            Get
                Return Me.ViewState("Regime")
            End Get
            Set(ByVal value As String)
                Me.ViewState.Add("Regime", value)
            End Set
        End Property

        Public Property Priorita() As String
            Get
                Return Me.ViewState("Priorita")
            End Get
            Set(ByVal value As String)
                Me.ViewState.Add("Priorita", value)
            End Set
        End Property

        Public Property ListaIdPrestazioniInserite() As List(Of String)
            Get
                Return Me.ViewState("ListaIdPrestazioniInserite")
            End Get
            Set(ByVal value As List(Of String))
                Me.ViewState.Add("ListaIdPrestazioniInserite", value)
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
        Public Property asyncTestataPazientePostbackCompleted() As Boolean
            Get
                Return Me.ViewState("asyncTestataPazientePostbackCompleted")
            End Get
            Set(ByVal value As Boolean)
                Me.ViewState.Add("asyncTestataPazientePostbackCompleted", value)
            End Set
        End Property

        Public Property asyncTestataOrdinePostbackCompleted() As Boolean
            Get
                Return Me.ViewState("asyncTestataOrdinePostbackCompleted")
            End Get
            Set(ByVal value As Boolean)
                Me.ViewState.Add("asyncTestataOrdinePostbackCompleted", value)
            End Set
        End Property

#End Region

        Dim ExecuteSistemiErogantiSelect As Boolean = False
        Dim ExecuteListaPreferitiSelect As Boolean = False
        Dim ExecuteListaPrestazioniRecentiPerUoSelect As Boolean = False
        Dim ExecuteListaPrestazioniRecentiPerPazienteSelect As Boolean = False
        Dim ExecuteProfiliSelect As Boolean = False
        Dim ExecuteProfiliPersonaliSelect As Boolean = False
        Dim ExecuteListaPerEroganteSelect As Boolean = False
        Dim ExecuteListaPrestazioniProfiloSelect As Boolean = False

        Private Const errorMessage As String = "Errore nella combinazione di parametri passata nella querystring<br /> Le combinazioni accettate sono: Nosologico-Azienda Erogante e IdProvenienza-Provenienza."

        Private Sub ComposizioneOrdine_PreInit(sender As Object, e As EventArgs) Handles Me.PreInit
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

        Private Sub ComposizioneOrdine_Load(sender As Object, e As EventArgs) Handles Me.Load

            Try
                If Not Page.IsPostBack Then
                    'Questo parametro è presente sia in accessodiretto che standard
                    Me.Nosologico = Request.QueryString("Nosologico")
                    Me.IdRichiesta = Request.QueryString("IdRichiesta")
                    Me.IdPaziente = Request.QueryString("IdPaziente")

                    If isAccessoDiretto Then

                        If String.IsNullOrEmpty(Me.IdRichiesta) Then

                            'Setto l'url ricavato in precedenza come variabile in sessione
                            SessionHandler.EntryPointAccessoDiretto = Request.Url.AbsoluteUri

                            'Combinazioni possibili: 
                            '1) idProvenienza e Provenienza
                            '2) Nosologico e AziendaErogante
                            Dim idProvenienza As String = Request.QueryString("idProvenienza")
                            Dim provenienza As String = Request.QueryString("Provenienza")
                            Dim aziendaErogante As String = Request.QueryString("AziendaErogante")
                            Dim unitaOperativa As String = String.Empty

                            'Mostro nel divErrorMessage un messaggio se nella query string i parametri non sono forniti nelle rispettive coppie
                            If Not ((Not String.IsNullOrEmpty(idProvenienza) AndAlso Not String.IsNullOrEmpty(provenienza)) OrElse (Not String.IsNullOrEmpty(Nosologico) AndAlso Not String.IsNullOrEmpty(aziendaErogante))) Then
                                Throw New ApplicationException(errorMessage)
                            End If
                            'Ottengo l'idPaziente in base alla combinazione dei parametri
                            If Not String.IsNullOrEmpty(idProvenienza) AndAlso Not String.IsNullOrEmpty(provenienza) Then
                                Me.IdPaziente = Utility.GetIdPazienteByProvenienza(idProvenienza, provenienza)
                            ElseIf Not String.IsNullOrEmpty(Me.Nosologico) AndAlso Not String.IsNullOrEmpty(aziendaErogante) Then
                                Dim idpazienteUnitaOperativa As String() = Utility.GetIdPazienteByNosologico(Me.Nosologico, aziendaErogante).Split("§")
                                Me.IdPaziente = idpazienteUnitaOperativa(0)
                                unitaOperativa = idpazienteUnitaOperativa(1)
                            End If

                            If Me.IdPaziente IsNot Nothing OrElse Not String.IsNullOrEmpty(Me.IdPaziente) Then
                                'Salvo la richiesta e ottengo l'idRichiesta
                                Me.IdRichiesta = Utility.SalvaBozzaRichiesta(Me.IdPaziente, Me.Nosologico, $"{aziendaErogante}-{unitaOperativa}")
                            Else
                                'genero una nuova eccezione
                                Throw New ApplicationException("Il paziente non è stato trovato")
                            End If
                        End If

                        Dim linkButtonToolbar As LinkButton = CType(Me.UcToolbar.FindControl("realIndietroButton"), LinkButton)
                        linkButtonToolbar.Visible = False
                    End If

                    'Valorizzo le informazioni della testata paziente.
                    ucDettaglioPaziente2.IdPaziente = Me.IdPaziente
                    ucDettaglioPaziente2.Nosologico = Me.Nosologico

                    '2020-01-21 Kyrylo: Se si è in accesso diretto controllo la presenza del parametro ShowPannelloPaziente e visualizzo o meno il pannello paziente
                    If Me.isAccessoDiretto Then
                        Dim showPannelloPaziente As String = Request.QueryString("ShowPannelloPaziente")

                        If Not String.IsNullOrEmpty(showPannelloPaziente) Then
                            Dim bShowPannelloPaziente As Boolean = True
                            If Boolean.TryParse(showPannelloPaziente, bShowPannelloPaziente) Then
                                ucDettaglioPaziente2.Visible = bShowPannelloPaziente
                            End If
                        End If
                    End If

                    'Imposto le property de ucToolbar
                    UcToolbar.IdRichiesta = Me.IdRichiesta
                    UcToolbar.CurrentStep = 2
                    UcToolbar.IdPaziente = Me.IdPaziente
                    UcToolbar.Nosologico = Me.Nosologico
                    UcToolbar.IsAccessoDiretto = RouteData.Values("AccessoDiretto")


                    '
                    '2020-07-14 Kyrylo: Traccia Operazioni
                    '
                    Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalUser)
                    oTracciaOp.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Aperta composizione ordine", New Guid(IdPaziente), Nothing, IdRichiesta, "IdRichiesta")

                Else
                    'Cancello la cache per evitare di utilizzare dati vecchi o sbagliati
                    Dim dataSource As New Prestazioni
                    dataSource.ClearCache()
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Public Sub Avanti()
            Try
                If gvPrestazioniInserite.Rows.Count > 0 Then

                    Dim isSistemaEroganteSitFound As Boolean = False

                    For Each row As GridViewRow In gvPrestazioniInserite.Rows

                        'Controllo se tra le prestazioni ce n'è almeno una avente come erogante il SIT
                        'In questo caso la dataprenotazione deve essere obbligatoria

                        Dim sistemaErogante As String = gvPrestazioniInserite.DataKeys(row.RowIndex).Value

                        If sistemaErogante.ToUpper() = "ASMN-SIT" Then
                            isSistemaEroganteSitFound = True
                        End If

                    Next

                    If ((Not isSistemaEroganteSitFound) OrElse (isSistemaEroganteSitFound AndAlso Not String.IsNullOrEmpty(txtDataPrenotazione.Text))) Then
                        Dim parametri As String = $"?IdRichiesta={Me.IdRichiesta}&IdPaziente={Me.IdPaziente}"
                        If Not String.IsNullOrEmpty(Me.Nosologico) Then
                            parametri += $"&Nosologico={Me.Nosologico}"
                        End If

                        ' 2020-01-20 Kyrylo : Se da QueryString è presente il parametro ShowPannelloPaziente allora lo aggiungo all'url della pagina successiva
                        If Me.isAccessoDiretto Then

                            Dim showPannelloPaziente As String = Request.QueryString("ShowPannelloPaziente")
                            If Not String.IsNullOrEmpty(showPannelloPaziente) Then
                                Dim bShowPannelloPaziente As Boolean = True
                                If Boolean.TryParse(showPannelloPaziente, bShowPannelloPaziente) Then
                                    parametri += $"&ShowPannelloPaziente={bShowPannelloPaziente}"
                                End If
                            End If
                        End If

                        Dim returnUrl As String = Utility.buildUrl($"~/Pages/DatiAccessori.aspx{parametri}", Me.isAccessoDiretto)
                        Response.Redirect(returnUrl, True)
                    Else
                        Dim functionJS As String = "$(alert('Per tutte le richieste verso il Servizio Trasfusionale è obbligatorio inserire la data di prenotazione.'));"
                        ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide", functionJS, True)
                    End If

                Else
                    divErrorMessage.Visible = True
                    lblError.Text = "Occorre inserire almeno una prestazione per completare la richiesta."
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub CaricaTestataRichiesta()
            Try

                Dim ta As New OrdineTestata()
                Dim ordine As OttieniOrdinePerIdGuidResponse = ta.OttieniOrdinePerIdGuid(IdRichiesta)

                If ordine IsNot Nothing Then
                    Dim richiestaWs As StatoType = ordine.OttieniOrdinePerIdGuidResult

                    If richiestaWs IsNot Nothing Then
                        If Not String.Equals(richiestaWs.DescrizioneStato.ToString(), "Inserito") AndAlso Not String.Equals(richiestaWs.DescrizioneStato.ToString(), "Modificato") Then
                            Dim url As String = $"~/Pages/RiassuntoOrdine.aspx?IdRichiesta={Me.IdRichiesta}&IdPaziente={Me.IdPaziente}"

                            If Not String.IsNullOrEmpty(Me.Nosologico) Then
                                url += $"&Nosologico={Me.Nosologico}"
                            Else
                                url += "&Nosologico="
                            End If
                            Response.Redirect(Utility.buildUrl(url, Me.isAccessoDiretto), False)
                        End If
                        ValidationError.Visible = Not (richiestaWs.StatoValidazione.Stato = StatoValidazioneEnum.AA)
                        ValidationError.Attributes.Add("Title", richiestaWs.StatoValidazione.Descrizione)

                        spStato.InnerText = richiestaWs.DescrizioneStato.ToString()
                        spIdRichiesta.InnerText = richiestaWs.Ordine.IdRichiestaOrderEntry

                        'Valorizzo le properties del viewstate
                        Me.AziendaUo = $"{richiestaWs.Ordine.UnitaOperativaRichiedente.Azienda.Codice}-{richiestaWs.Ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice}"
                        Me.Regime = richiestaWs.Ordine.Regime.Codice
                        Me.Priorita = richiestaWs.Ordine.Priorita.Codice

                        Dim data As DateTime? = Nothing

                        If richiestaWs.Ordine.DataPrenotazione.HasValue AndAlso richiestaWs.Ordine.DataPrenotazione <> DateTime.MinValue Then
                            data = richiestaWs.Ordine.DataPrenotazione.Value
                        End If

                        Me.DataPrenotazione = data

                        'Effettuo il databind delle dropdownlist
                        ddlUo.DataBind()
                        ddlRegimi.DataBind()
                        ddlPreferiti.DataBind()

                        'Imposto i valori della testata dell'ordine.
                        ddlUo.SelectedValue = Me.AziendaUo
                        ddlRegimi.SelectedValue = Me.Regime
                        ddlPriorita.SelectedValue = Me.Priorita
                        txtDataPrenotazione.Text = Me.DataPrenotazione?.ToString("dd/MM/yyyy HH:mm")
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

#Region "UnitaOperative"

        Private Sub odsUnitaOperative_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsUnitaOperative.Selecting
            Try
                e.InputParameters("Nosologico") = Me.Nosologico
                e.InputParameters("Aziendauo") = Me.AziendaUo
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

#End Region

#Region "Regimi"
        Private Sub odsRegimi_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsRegimi.Selecting
            Try
                e.InputParameters("IdPaziente") = Me.IdPaziente
                e.InputParameters("Nosologico") = Me.Nosologico
                e.InputParameters("RegimeCorrente") = Me.Regime
                e.InputParameters("AziendaUo") = ddlUo.SelectedValue
            Catch ex As Exception
                gestioneErrori(ex)
            End Try

        End Sub

        'Private Sub odsRegimi_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsRegimi.Selected
        '	Try
        '		If Not String.IsNullOrEmpty(Me.Nosologico) Then
        '			Dim i As List(Of KeyValuePair(Of String, String)) = e.ReturnValue
        '			Dim temp As List(Of KeyValuePair(Of String, String)) = New List(Of KeyValuePair(Of String, String))
        '			Dim l As Boolean = False
        '			For Each pair In i
        '				If pair.Value = "Day service ambulatoriale" Then
        '					temp.Add(pair)
        '				End If
        '			Next
        '			If temp IsNot Nothing AndAlso temp.Count > 0 Then
        '				i.Remove(temp.FirstOrDefault)
        '			End If
        '		End If
        '	Catch ex As Exception
        '		gestioneErrori(ex)
        '	End Try
        'End Sub

#End Region

        Private Sub ddlAziende_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ddlAziendePerErogante.SelectedIndexChanged
            Try
                ExecuteSistemiErogantiSelect = True
                ddlErogante.DataBind()
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub odsAziende_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsAziende.Selected
            Try
                ExecuteSistemiErogantiSelect = True
                ddlErogante.DataBind()
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Public Shared Function GetErogante(SistemaErogante As Object) As String
            Dim res As String = String.Empty
            Try
                res = String.Format("{0}-{1}", SistemaErogante.Azienda.Codice, If(String.IsNullOrEmpty(SistemaErogante.Sistema.Descrizione), SistemaErogante.Sistema.Codice, SistemaErogante.Sistema.Descrizione))
            Catch ex As Exception
                Throw New ApplicationException("Errore: " + ex.Message)
            End Try
            Return res
        End Function

        Private Sub odsListaPreferiti_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsListaPreferiti.Selecting
            Try
                e.Cancel = Not ExecuteListaPreferitiSelect
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub btnCercaListePreferiti_Click(sender As Object, e As EventArgs) Handles btnCercaListePreferiti.Click
            Try
                ExecuteListaPreferitiSelect = True
                gvListaPreferiti.DataBind()

                '
                '2020-07-13 Kyrylo: Traccia Operazioni --> 2020-07-16 Kyrylo: NON SERVE
                '
                'TracciaOperazioniManager.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Ricercata lista preferiti", updFiltriListaPreferiti, New Guid(IdPaziente), IdRichiesta, "IdRichiesta")


            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub odsListaPrestazioniRecentiPerUo_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsListaPrestazioniRecentiPerUo.Selecting
            Try
                e.Cancel = Not ExecuteListaPrestazioniRecentiPerUoSelect
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub btnListaPrestazioniRecentiPerUo_Click(sender As Object, e As EventArgs) Handles btnListaPrestazioniRecentiPerUo.Click
            Try
                ExecuteListaPrestazioniRecentiPerUoSelect = True
                gvPrestazioniRecentiPerUo.DataBind()

                '
                '2020-07-13 Kyrylo: Traccia Operazioni --> 2020-07-16 Kyrylo: NON SERVE
                '
                'TracciaOperazioniManager.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Ricercate prestazioni per recenti per UO", updFiltriPerUo, New Guid(IdPaziente), IdRichiesta, "IdRichiesta")

            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub odsListaPrestazioniRecentiPerPaziente_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsListaPrestazioniRecentiPerPaziente.Selecting
            Try
                e.Cancel = Not ExecuteListaPrestazioniRecentiPerPazienteSelect
                If String.IsNullOrEmpty(Me.IdPaziente) Then
                    e.Cancel = True
                Else
                    e.InputParameters("IdPaziente") = Me.IdPaziente
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub btnListaPrestazioniRecentiPerPaziente_Click(sender As Object, e As EventArgs) Handles btnListaPrestazioniRecentiPerPaziente.Click
            Try
                ExecuteListaPrestazioniRecentiPerPazienteSelect = True
                gvListaPrestazioniRecentiPerPaziente.DataBind()

                '
                '2020-07-13 Kyrylo: Traccia Operazioni --> 2020-07-16 Kyrylo: NON SERVE
                '
                'TracciaOperazioniManager.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Ricercate prestazioni per recenti su paziente", updFiltriPerRecentiPaziente, New Guid(IdPaziente), IdRichiesta, "IdRichiesta")

            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub odsProfili_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsProfili.Selecting
            Try
                e.Cancel = Not ExecuteProfiliSelect
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub btnProfili_Click(sender As Object, e As EventArgs) Handles btnProfili.Click
            Try
                ExecuteProfiliSelect = True
                gvListaProfili.DataBind()

                '
                '2020-07-13 Kyrylo: Traccia Operazioni --> 2020-07-16 Kyrylo: NON SERVE
                '
                'TracciaOperazioniManager.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Ricerca profili", updFiltriPerProfili, New Guid(IdPaziente), IdRichiesta, "IdRichiesta")

            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub odsProfiliPersonali_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsProfiliPersonali.Selecting
            Try
                e.Cancel = Not ExecuteProfiliPersonaliSelect
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub btnProfiliPersonali_Click(sender As Object, e As EventArgs) Handles btnProfiliPersonali.Click
            Try
                ExecuteProfiliPersonaliSelect = True
                gvProfiliPersonali.DataBind()

                '
                '2020-07-13 Kyrylo: Traccia Operazioni --> 2020-07-16 Kyrylo: NON SERVE
                '
                'TracciaOperazioniManager.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Ricerca profili personali", updFiltriPerProfiliPersonali, New Guid(IdPaziente), IdRichiesta, "IdRichiesta")

            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub odsPerErogante_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsPerErogante.Selecting
            Try
                e.Cancel = Not ExecuteListaPerEroganteSelect
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub btnCercaPerErogante_Click(sender As Object, e As EventArgs) Handles btnCercaPerErogante.Click
            Try
                'Cancello la cache
                Dim dataSource As New CustomDataSource.Prestazioni
                dataSource.ClearCache()

                ExecuteListaPerEroganteSelect = True
                gvListaPerErogante.DataBind()

                '
                '2020-07-13 Kyrylo: Traccia Operazioni --> 2020-07-16 Kyrylo: NON SERVE
                '
                'TracciaOperazioniManager.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Ricercate prestazioni per erogante", updFiltriPerErogante, New Guid(IdPaziente), IdRichiesta, "IdRichiesta")


            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub gvListaPreferiti_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvListaPreferiti.RowCommand, gvListaPerErogante.RowCommand, gvPrestazioniRecentiPerUo.RowCommand, gvListaPrestazioniRecentiPerPaziente.RowCommand, gvListaProfili.RowCommand, gvProfiliPersonali.RowCommand
            Try
                Dim IdPrestazione As String = e.CommandArgument
                If String.Equals(e.CommandName, "Aggiungi") Then
                    If Not String.IsNullOrEmpty(IdPrestazione) Then
                        Dim idNuovaPrestazione As String = e.CommandArgument

                        'Controllo se la prestazione esiste già tra quelle inserite
                        Dim listaIdPrestazione As List(Of String) = (From prestazione In Me.ListaIdPrestazioniInserite Where prestazione.ToUpper() = idNuovaPrestazione.ToUpper() Select prestazione).ToList()

                        'Aggiungo la nuova prestazione solo se non già presente
                        If listaIdPrestazione.Count = 0 Then
                            Dim userData = UserDataManager.GetUserData()

                            Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                                'xxx Ordinamento per data modifica effettuato da sandro
                                'xxx vedere IdRigaOrderEntry se è utilizzato in giro
                                Dim return2 = webService.AggiungiPrestazionePerIdGuidPerIdPrestazione(New AggiungiPrestazionePerIdGuidPerIdPrestazioneRequest(userData.Token, Me.IdRichiesta, e.CommandArgument)).AggiungiPrestazionePerIdGuidPerIdPrestazioneResult
                            End Using

                            'Cancello la cache
                            Dim dataSourceOrdine As New OrdineTestata
                            dataSourceOrdine.ClearCache()

                            gvPrestazioniInserite.DataBind()
                            updPrestazioniInserite.Update()

                            CaricaTestataRichiesta()
                            updTestata.Update()

                            timerDatiAccessori.Interval = 100
                            timerDatiAccessori.Enabled = True
                        End If

                        '
                        '2020-07-13 Kyrylo: Traccia Operazioni --> 2020-07-16 Kyrylo: NON SERVE
                        '
                        'TracciaOperazioniManager.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Aggiunta prestazione", New Guid(IdPaziente), Nothing, IdRichiesta, "IdRichiesta")


                    End If
                ElseIf String.Equals(e.CommandName, "Preview") Then

                    odsPrestazioniProfilo.SelectParameters("idProfilo").DefaultValue = IdPrestazione
                    ExecuteListaPrestazioniProfiloSelect = True
                    gvPrestazioniProfilo.DataBind()

                    updPrestazioniProfilo.Update()

                    Dim functionJS As String = "$('#ModalePreviewProfilo').modal('show');"
                    ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide", functionJS, True)
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub odsPrestazionInserite_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsPrestazionInserite.Selected
            Try
                If e.Exception Is Nothing Then
                    If e.ReturnValue IsNot Nothing Then
                        Dim prestazioni As List(Of Prestazione) = CType(e.ReturnValue, List(Of Prestazione))
                        Dim listaIdPrestazioni As List(Of String) = (From prestazione In prestazioni Select prestazione.Id).ToList()
                        ListaIdPrestazioniInserite = listaIdPrestazioni
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub gvPrestazioniInserite_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvPrestazioniInserite.RowCommand
            Try
                Dim idPrestazione As String = e.CommandArgument
                If Not String.IsNullOrEmpty(idPrestazione) Then

                    If String.Equals(e.CommandName, "Elimina") Then
                        EliminaPrestazioneDallaRichiesta(Me.IdRichiesta, idPrestazione)

                        'Cancello la cache
                        Dim dataSourceOrdine As New CustomDataSource.OrdineTestata
                        dataSourceOrdine.ClearCache()
                        CaricaTestataRichiesta()
                        updTestata.Update()
                        gvPrestazioniInserite.DataBind()

                        timerDatiAccessori.Interval = 100
                        timerDatiAccessori.Enabled = True

                    ElseIf String.Equals(e.CommandName, "Preview") Then
                        odsPrestazioniProfilo.SelectParameters("idProfilo").DefaultValue = idPrestazione
                        ExecuteListaPrestazioniProfiloSelect = True
                        gvPrestazioniProfilo.DataBind()
                        updPrestazioniProfilo.Update()
                        Dim functionJS As String = "$('#ModalePreviewProfilo').modal('show');"
                        ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide", functionJS, True)
                    ElseIf String.Equals(e.CommandName, "Espandi") Then
                        EspandiProfilo(Me.IdRichiesta, idPrestazione)

                        'Cancello la cache
                        Dim dataSourceOrdine As New OrdineTestata
                        dataSourceOrdine.ClearCache()

                        gvPrestazioniInserite.DataBind()
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub ddl_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ddlUo.SelectedIndexChanged, ddlRegimi.SelectedIndexChanged
            Try
                SalvaRichiesta()
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub
        Private Sub ddlPriorita_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ddlPriorita.SelectedIndexChanged
            Try
                SalvaRichiesta()
                cancelSelectGruppiPrestazioni = False
                ddlPreferiti.DataBind()
                updFiltriListaPreferiti.Update()
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub txtDataPrenotazione_TextChanged(sender As Object, e As EventArgs) Handles txtDataPrenotazione.TextChanged
            Try
                Dim dataPrenotazioneNew As DateTime? = Nothing

                If (Not String.IsNullOrEmpty(txtDataPrenotazione.Text)) Then
                    Dim data As DateTime

                    If (DateTime.TryParse(txtDataPrenotazione.Text, data)) Then
                        dataPrenotazioneNew = data
                    End If
                End If

                If (Not dataPrenotazioneNew.HasValue AndAlso Me.DataPrenotazione.HasValue) OrElse (dataPrenotazioneNew.HasValue AndAlso Not Me.DataPrenotazione.HasValue) Then
                    SalvaRichiesta()
                ElseIf (dataPrenotazioneNew.Value <> Me.DataPrenotazione.Value) Then
                    SalvaRichiesta()
                End If

            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Public Sub SalvaRichiesta()
            Dim Prestazioni As Object() = Nothing
            Try
                If asyncTestataOrdinePostbackCompleted Then
                    If Page.IsPostBack Then

                        'Salvo la richiesta
                        SalvaRichiesta(Me.IdRichiesta, Me.IdPaziente, ddlRegimi.SelectedValue, ddlPriorita.SelectedValue, ddlUo.SelectedValue, txtDataPrenotazione.Text, Prestazioni)

                        'Cancello la cache
                        Dim dataSourceOrdine As New OrdineTestata
                        dataSourceOrdine.ClearCache()
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Protected Function IsTastoPreviewVisible(oTipo As Object) As Boolean
            Dim isVisible As Boolean = False
            Try
                If Not oTipo Is Nothing Then
                    Dim tipo As TipoPrestazioneErogabileEnum = CType(oTipo, TipoPrestazioneErogabileEnum)

                    If tipo = TipoPrestazioneErogabileEnum.ProfiloBlindato OrElse tipo = TipoPrestazioneErogabileEnum.ProfiloScomponibile OrElse tipo = TipoPrestazioneErogabileEnum.ProfiloUtente Then

                        isVisible = True
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return isVisible
        End Function

        Protected Function IsTastoEspandiVisible(oTipo As Object) As Boolean
            Dim isVisible As Boolean = False
            Try
                If Not oTipo Is Nothing Then
                    Dim tipo As TipoPrestazioneErogabileEnum = CType(oTipo, TipoPrestazioneErogabileEnum)

                    If tipo = TipoPrestazioneErogabileEnum.ProfiloScomponibile OrElse tipo = TipoPrestazioneErogabileEnum.ProfiloUtente Then
                        isVisible = True
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return isVisible
        End Function

        Protected Function GetProfiloDescrizione(oTipo As Object, oSistema As Object) As String
            Dim descrizione As String = String.Empty

            Try
                If Not oTipo Is Nothing Then
                    Dim tipo As TipoPrestazioneErogabileEnum = CType(oTipo, TipoPrestazioneErogabileEnum)
                    Select Case tipo
                        Case TipoPrestazioneErogabileEnum.Prestazione
                            Dim sistema As String = CType(oSistema, String)
                            descrizione = sistema
                        Case TipoPrestazioneErogabileEnum.ProfiloBlindato
                            descrizione = "(Profilo)"
                        Case TipoPrestazioneErogabileEnum.ProfiloScomponibile
                            descrizione = "(Profilo scomponibile)"
                        Case TipoPrestazioneErogabileEnum.ProfiloUtente
                            descrizione = "(Profilo utente)"
                    End Select
                End If

            Catch ex As Exception
                gestioneErrori(ex)
            End Try

            Return descrizione
        End Function

        Private Sub odsPrestazioniProfilo_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsPrestazioniProfilo.Selecting
            Try
                e.Cancel = Not ExecuteListaPrestazioniProfiloSelect
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Protected Function GetSistemaDescrizione(oSistemaErogante As Object)
            Dim sistemaErogante As String = String.Empty

            Try
                If oSistemaErogante IsNot Nothing Then
                    Dim sistemaType As SistemaType = CType(oSistemaErogante, SistemaType)
                    sistemaErogante = String.Format("{0}-{1}", sistemaType.Azienda.Codice, If(String.IsNullOrEmpty(sistemaType.Sistema.Descrizione), sistemaType.Sistema.Codice, sistemaType.Sistema.Descrizione))
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try

            Return sistemaErogante
        End Function


#Region "Funzioni di utility"
        Private Function EspandiProfilo(IdRichiesta As String, idPrestazione As String) As String
            Try
                Dim userData = UserDataManager.GetUserData()
                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                    Dim request = New OttieniOrdinePerIdGuidRequest(userData.Token, IdRichiesta)
                    Dim response = webService.OttieniOrdinePerIdGuid(request)
                    Dim result = response.OttieniOrdinePerIdGuidResult

                    If result Is Nothing Then
                        Return Nothing
                    End If

                    Dim profilo = webService.OttieniPrestazionePerId(New OttieniPrestazionePerIdRequest(userData.Token, idPrestazione)).OttieniPrestazionePerIdResult

                    If profilo Is Nothing Then
                        Return Nothing
                    End If

                    For Each prestazione In profilo.Prestazioni

                        Dim currentIdPrestazione = prestazione.Id

                        If result.Ordine.RigheRichieste.Where(Function(e) String.Compare(e.Prestazione.Id, currentIdPrestazione, True) = 0).Count > 0 Then
                            Continue For
                        End If

                        result.Ordine.RigheRichieste.Add(New RigaRichiestaType() With {
                          .Prestazione = New PrestazioneType() With {
                           .Id = String.Empty,
                           .Codice = prestazione.Codice
                          },
                          .SistemaErogante = prestazione.SistemaErogante
                          })
                    Next

                    Dim riga = result.Ordine.RigheRichieste.Find(Function(e) String.Compare(e.Prestazione.Id, idPrestazione, True) = 0)

                    If riga IsNot Nothing Then
                        result.Ordine.RigheRichieste.Remove(riga)
                    End If


                    Dim saveResponse = webService.AggiungiOppureModificaOrdine(New AggiungiOppureModificaOrdineRequest(userData.Token, result.Ordine))

                    Return "ok"
                End Using
            Catch ex As Exception
                gestioneErrori(ex)
                Return Nothing
            End Try
        End Function

        Public Function SalvaRichiesta(idRichiesta As String, idSac As String, regime As String, priorita As String, uo As String, dataPrenotazione As String, prestazioni As Object()) As String
            Try
                Dim userData = UserDataManager.GetUserData()

                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                    Dim richiesta As OrdineType

                    If Not String.IsNullOrEmpty(idRichiesta) Then

                        Dim ordineRequest = New OttieniOrdinePerIdGuidRequest(userData.Token, idRichiesta)

                        Dim ordineResponse = webService.OttieniOrdinePerIdGuid(ordineRequest)

                        richiesta = ordineResponse.OttieniOrdinePerIdGuidResult.Ordine
                    Else
                        richiesta = New OrdineType()
                    End If

                    Dim dataDiPrenotazione As DateTime = DateTime.MinValue

                    If String.IsNullOrEmpty(dataPrenotazione) OrElse Not DateTime.TryParse(dataPrenotazione, dataDiPrenotazione) Then
                        dataDiPrenotazione = DateTime.MinValue
                    End If

                    richiesta.DataPrenotazione = If(dataDiPrenotazione = DateTime.MinValue, Nothing, dataDiPrenotazione)

                    richiesta.DataRichiesta = DateTime.Now
                    richiesta.Regime = New RegimeType() With {.Codice = regime}
                    richiesta.Priorita = New PrioritaType() With {.Codice = priorita}

                    richiesta.SistemaRichiedente = New SistemaType() With {
                     .Azienda = New CodiceDescrizioneType() With {.Codice = DI.Common.Utility.GetAziendaRichiedente2()},
                     .Sistema = New CodiceDescrizioneType() With {.Codice = My.Settings.SistemaRichiedente}
                     }

                    richiesta.UnitaOperativaRichiedente = New StrutturaType() With
                       {
                     .Azienda = New CodiceDescrizioneType() With {.Codice = uo.Split("-")(0)},
                     .UnitaOperativa = New CodiceDescrizioneType() With {.Codice = uo.Substring(uo.IndexOf("-") + 1)}
                       }

                    Dim username = HttpContext.Current.User.Identity.Name
                    Dim userInfo = UserDataManager.GetDettaglioUtente(username)

                    richiesta.Operatore = New OperatoreType() With {
                       .ID = username,
                       .Nome = userInfo.Nome,
                       .Cognome = userInfo.Cognome
                      }

                    Dim ds As New CustomDataSourceDettaglioPaziente.Paziente
                    Dim paziente = ds.GetDataById(idSac)

                    richiesta.Paziente = New PazienteType() With {
                     .IdSac = idSac,
                     .Cognome = paziente.Cognome,
                     .Nome = paziente.Nome,
                     .CodiceFiscale = paziente.CodiceFiscale,
                     .DataNascita = paziente.DataNascita,
                     .AnagraficaCodice = paziente.IdProvenienza,
                     .AnagraficaNome = paziente.Provenienza,
                     .CapResidenza = paziente.CapRes,
                     .CodiceIstatComuneNascita = paziente.ComuneNascitaCodice,
                     .CodiceIstatComuneResidenza = paziente.ComuneResCodice,
                     .CodiceIstatNazionalita = paziente.NazionalitaCodice,
                     .ComuneNascita = paziente.ComuneNascitaNome,
                     .ComuneResidenza = paziente.ComuneResNome,
                     .IndirizzoResidenza = paziente.IndirizzoRes,
                     .Nazionalita = paziente.NazionalitaNome,
                     .Sesso = paziente.Sesso,
                     .DataModifica = paziente.DataModifica
                       }

                    Dim request = New AggiungiOppureModificaOrdineRequest(userData.Token, richiesta)
                    Dim response = webService.AggiungiOppureModificaOrdine(request)
                    Return response.AggiungiOppureModificaOrdineResult.Ordine.IdGuidOrderEntry

                End Using
            Catch ex As Exception
                gestioneErrori(ex)
                Return Nothing
            End Try
        End Function

        Private Sub ValidaRichiesta(idRichiesta As String)
            Try
                Dim userData = UserDataManager.GetUserData()

                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                    Dim request = New ValidaOrdinePerIdGuidRequest(userData.Token, idRichiesta)
                    Dim response = webService.ValidaOrdinePerIdGuid(request)

                    ValidationError.Visible = Not (response.ValidaOrdinePerIdGuidResult.StatoValidazione.Stato = StatoValidazioneEnum.AA)
                    ValidationError.Attributes.Add("Title", response.ValidaOrdinePerIdGuidResult.StatoValidazione.Descrizione)

                End Using
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Function EliminaPrestazioneDallaRichiesta(idRichiesta As String, idPrestazione As String) As Object
            Try
                Dim userData = UserDataManager.GetUserData()
                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                    Return webService.RimuoviPrestazionePerIdGuidPerIdPrestazione(New RimuoviPrestazionePerIdGuidPerIdPrestazioneRequest(userData.Token, idRichiesta, idPrestazione)).RimuoviPrestazionePerIdGuidPerIdPrestazioneResult
                End Using
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return Nothing
        End Function

        Private Sub gvProfiliPersonali_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvProfiliPersonali.RowDataBound
            Try
                'Testo se è una row.
                If e.Row.RowType = DataControlRowType.DataRow Then

                    'Ottengo la riga corrente.
                    Dim rigaCorrente As GridViewRow = e.Row
                    Dim profilo As ProfiloUtenteListaType = CType(rigaCorrente.DataItem, ProfiloUtenteListaType)
                    If profilo.NumeroPrestazioni < 1 Then
                        rigaCorrente.CssClass = "hidden"
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub ddlErogante_PreRender(sender As Object, e As EventArgs) Handles ddlErogante.PreRender
            Try
                Dim itemTutti As ListItem = New ListItem("Tutti", "", True)
                If Not ddlErogante.Items.Contains(itemTutti) Then
                    ddlErogante.Items.Insert(0, itemTutti)
                    ddlErogante.SelectedIndex = 0
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub odsListaPreferiti_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsListaPreferiti.Selected
            Try
                If Not e.ReturnValue Is Nothing Then
                    Dim preferiti = CType(e.ReturnValue, List(Of PrestazioneListaType))
                    If preferiti.Count >= 100 Then
                        divSuperati100Risultati1.Visible = True
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub odsPerErogante_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsPerErogante.Selected
            Try
                If Not e.ReturnValue Is Nothing Then
                    Dim preferiti = CType(e.ReturnValue, List(Of PrestazioneListaType))
                    If preferiti.Count >= 100 Then
                        divSuperati100Risultati2.Visible = True
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub odsListaPrestazioniRecentiPerUo_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsListaPrestazioniRecentiPerUo.Selected
            Try
                If Not e.ReturnValue Is Nothing Then
                    Dim preferiti = CType(e.ReturnValue, List(Of PrestazioneListaType))
                    If preferiti.Count >= 100 Then
                        divSuperati100Risultati.Visible = True
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub odsListaPrestazioniRecentiPerPaziente_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsListaPrestazioniRecentiPerPaziente.Selected
            Try
                If Not e.ReturnValue Is Nothing Then
                    Dim preferiti = CType(e.ReturnValue, List(Of PrestazioneListaType))
                    If preferiti.Count >= 100 Then
                        divSuperati100Risultati.Visible = True
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub odsPrestazionInserite_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsPrestazionInserite.Selecting
            Try
                If asyncTestataPazientePostbackCompleted Then
                    e.InputParameters("IdRichiesta") = Me.IdRichiesta
                Else
                    e.Cancel = True
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub odsDatiAccessori_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsDatiAccessori.Selecting
            Try
                If asyncTestataOrdinePostbackCompleted Then
                    e.InputParameters("IdRichiesta") = Me.IdRichiesta
                Else
                    e.Cancel = True
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Dim cancelSelectGruppiPrestazioni As Boolean = True

        Private Sub odsGruppiPrestazioni_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsGruppiPrestazioni.Selecting
            Try

                If cancelSelectGruppiPrestazioni Then
                    e.Cancel = cancelSelectGruppiPrestazioni
                Else
                    e.InputParameters("UnitaOperative") = ddlUo.SelectedValue
                    e.InputParameters("regime") = ddlRegimi.SelectedValue
                    e.InputParameters("priorita") = ddlPriorita.SelectedValue
                End If


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
                If isAccessoDiretto Then
                    divPage.Visible = False
                    errorMessage = ex.Message
                End If
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

        Private Sub odsSistemiErogantiPerErogante_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsSistemiErogantiPerErogante.Selecting
            Try
                e.Cancel = Not ExecuteSistemiErogantiSelect
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub
        Private Sub ddlAziendePerErogante_DataBound(sender As Object, e As EventArgs) Handles ddlAziendePerErogante.DataBound
            ExecuteSistemiErogantiSelect = True
            ddlErogante.DataBind()
        End Sub

        Private Sub timerPaziente_Tick(sender As Object, e As EventArgs) Handles timerPaziente.Tick
            Try
                timerPaziente.Enabled = False
                asyncTestataPazientePostbackCompleted = True

                ucDettaglioPaziente2.ExecuteQuery = True

                If ucDettaglioPaziente2.ExecuteQuery Then
                    ucDettaglioPaziente2.DataBind()
                    timerTestataOrdine.Enabled = True
                End If

            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub timerTestataOrdine_Tick(sender As Object, e As EventArgs) Handles timerTestataOrdine.Tick
            Try
                timerTestataOrdine.Enabled = False
                CaricaTestataRichiesta()

                'Forzo il caricamento della dropdownlist dei preferiti
                cancelSelectGruppiPrestazioni = False
                ddlPreferiti.DataBind()
                updFiltriListaPreferiti.Update()

                'Forzo il caricamento delle prestazioni inserite.
                gvPrestazioniInserite.DataBind()
                updPrestazioniInserite.Update()

                asyncTestataOrdinePostbackCompleted = True
                timerDatiAccessori.Enabled = True
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub timerDatiAccessori_Tick(sender As Object, e As EventArgs) Handles timerDatiAccessori.Tick
            Try
                timerDatiAccessori.Enabled = False
                rptDatiAccessori.DataBind()
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub
    End Class
End Namespace