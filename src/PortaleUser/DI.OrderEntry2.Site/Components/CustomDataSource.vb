Imports System.Collections.Generic
Imports System.ComponentModel
Imports System.Diagnostics
Imports System.Linq
Imports System.Net
Imports System.ServiceModel
Imports DI.OrderEntry.SacServices
Imports DI.OrderEntry.Services
Imports DI.OrderEntry.User
Imports DI.OrderEntry.User.Data
Imports DI.PortalUser2.Data
Imports DI.PortalUser2

Public Class CustomDataSource

#Region "Properties"
    Public Shared MAX_NUM_RECORD As Integer = 50

    Public Shared ReadOnly Property Token As WcfDwhClinico.TokenType
        '
        ' Ottiene il token da passare come parametro agli ObjectDataSource all'interno delle tab.
        ' Utilizza la property CodiceRuolo per creare il token
        '
        Get
            Dim TokenViewState As WcfDwhClinico.TokenType = Tokens.GetToken(CodiceRuolo)

            Return TokenViewState
        End Get
    End Property

    Public Shared ReadOnly Property CodiceRuolo As String
        '
        ' Salva nel ViewState il codice ruolo dell'utente
        ' Utilizzata per creare il token da passare come parametro all'ObjectDataSource all'interno delle tab.
        '
        Get
            Dim sCodiceRuolo As String = String.Empty
            '
            ' Prendo il ruolo dell'utente
            '
            Dim oRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
            Dim oRuoloCorrente As RoleManager.Ruolo = oRoleManagerUtility.RuoloCorrente
            '
            ' Salvo in ViewState
            '
            sCodiceRuolo = oRuoloCorrente.Codice

            Return sCodiceRuolo
        End Get
    End Property

#End Region

    <DataObject(True)>
    Public Class Reparti
        Inherits CacheDataSource(Of List(Of Reparto))

        ''' <summary>
        ''' Restituisce la lista dei reparti, pazienti e ordini.
        ''' </summary>
        ''' <param name="Uo"></param>
        ''' <param name="Stato"></param>
        ''' <param name="Nosologico"></param>
        ''' <param name="Cognome"></param>
        ''' <param name="Nome"></param>
        ''' <param name="DataNascita"></param>
        ''' <param name="DaysToShow"></param>
        ''' <param name="SistemaErogante"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Uo As String, Stato As String, Nosologico As String, Cognome As String, Nome As String, DataNascita As String, DaysToShow As Integer, SistemaErogante As String, Optional ByVal AziendaErogante As String = "", Optional ByVal IdPaziente As String = "") As List(Of Reparto)

            'Creo una nuova lista di reparti.
            Dim reparti As List(Of Reparto)
            Try
                'Controllo se la lista è già in cache.
                reparti = Me.CacheData

                'se reparti è null allora rieseguo la query.
                If reparti Is Nothing Then

                    Try
                        Dim ordini As OrdineListaType() = Nothing

                        'Ottengo i dati dell'utente.
                        Dim userData = UserDataManager.GetUserData()

                        Dim filter = HttpContext.Current.Request("mode")

                        'Valorizzo i filtri per data inizio e fine.
                        Dim dataInizio As DateTime = DateTime.MinValue
                        Dim dataFine As DateTime = DateTime.MaxValue
                        If DaysToShow <> 0 Then
                            dataInizio = DateTime.Now.AddDays(-DaysToShow)
                            dataFine = DateTime.Now
                        End If

                        'Creo la lista con gli stati.
                        Dim filtroStati As List(Of StatoDescrizioneEnum)
                        Select Case Stato
                            Case 1 'inseriti
                                filtroStati = New List(Of StatoDescrizioneEnum)() From {StatoDescrizioneEnum.Inserito}

                            Case 2 'inviati
                                filtroStati = New List(Of StatoDescrizioneEnum)() From {StatoDescrizioneEnum.Modificato, StatoDescrizioneEnum.Inoltrato, StatoDescrizioneEnum.Accettato, StatoDescrizioneEnum.Programmato, StatoDescrizioneEnum.Incarico}

                            Case 3 'errati
                                filtroStati = New List(Of StatoDescrizioneEnum)() From {StatoDescrizioneEnum.Rifiutato, StatoDescrizioneEnum.Errato, StatoDescrizioneEnum.Cancellato, StatoDescrizioneEnum.Annullato}

                            Case 4 'erogati
                                filtroStati = New List(Of StatoDescrizioneEnum)() From {StatoDescrizioneEnum.Erogato}

                            Case Else
                                filtroStati = New List(Of StatoDescrizioneEnum)() From {StatoDescrizioneEnum.Inserito, StatoDescrizioneEnum.Modificato, StatoDescrizioneEnum.Inoltrato, StatoDescrizioneEnum.Accettato, StatoDescrizioneEnum.Programmato, StatoDescrizioneEnum.Incarico, StatoDescrizioneEnum.Rifiutato, StatoDescrizioneEnum.Errato, StatoDescrizioneEnum.Cancellato, StatoDescrizioneEnum.Annullato, StatoDescrizioneEnum.Erogato}
                        End Select

                        'Controllo se la dataNascita esiste ed è valida.
                        Dim dataDiNascita As DateTime
                        If Not String.IsNullOrEmpty(DataNascita) Then
                            Dim dataTester As DateTime
                            If DateTime.TryParse(DataNascita, dataTester) Then
                                dataDiNascita = DataNascita
                            End If
                        End If

                        'Chiammate al WS.
                        Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                            If Not String.IsNullOrEmpty(IdPaziente) Then
                                Dim request = New CercaOrdiniPerPazienteRequest(userData.Token, dataInizio, dataFine, IdPaziente)
                                ordini = webService.CercaOrdiniPerPaziente(request).CercaOrdiniPerPazienteResult.ToArray
                            Else
                                Select Case filter
                                    Case "evasi"
                                        Dim request = New CercaOrdiniEvasiRequest(userData.Token, dataInizio, dataFine, Nosologico, Cognome, Nome, dataDiNascita)
                                        ordini = webService.CercaOrdiniEvasi(request).CercaOrdiniEvasiResult.ToArray
                                    Case Else
                                        Dim uoList = New List(Of StrutturaType)()
                                        If String.IsNullOrEmpty(Uo) Then 'mostro tutte le UO
                                            Dim cds As New CustomDataSource.UnitaOperative
                                            Dim uos = cds.GetData()
                                            If uos IsNot Nothing AndAlso uos.Count > 0 Then
                                                For Each unita In uos
                                                    uoList.Add(New StrutturaType() With
                                                       {
                                                             .Azienda = New CodiceDescrizioneType() With {.Codice = unita.CodiceAzienda},
                                                             .UnitaOperativa = New CodiceDescrizioneType() With {.Codice = unita.CodiceUO.Substring(unita.CodiceUO.IndexOf("-") + 1)}
                                                       })
                                                Next
                                            Else
                                                '
                                                'l'utente non ha i permessi sulle UO quindi mostro un messaggio di errore.
                                                '
                                                Throw New ApplicationException("Per il ruolo corrente non sono state configurate le Unità Operative. Contattare l'amministratore.")
                                            End If

                                        Else 'solo la UO selezionata
                                            uoList.Add(New StrutturaType() With
                                              {
                                               .Azienda = New CodiceDescrizioneType() With {.Codice = Uo.Split("-")(0)},
                                               .UnitaOperativa = New CodiceDescrizioneType() With {.Codice = Uo.Substring(Uo.IndexOf("-") + 1)}
                                              })
                                        End If


                                        Dim azienda As String = Nothing
                                        Dim sistema As String = Nothing

                                        If Not String.IsNullOrEmpty(SistemaErogante) Then
                                            Dim sSplitted = SistemaErogante.Split(LookupManager.Separator)
                                            azienda = sSplitted(0)
                                            sistema = sSplitted(1)
                                        ElseIf String.IsNullOrEmpty(SistemaErogante) AndAlso (Not String.IsNullOrEmpty(AziendaErogante)) Then
                                            azienda = AziendaErogante
                                        End If

                                        Dim request = New CercaOrdiniPerUnitaOperative2Request(userData.Token, dataInizio, dataFine, uoList, Nosologico, Cognome, Nome, dataDiNascita, filtroStati, azienda, sistema)
                                        ordini = webService.CercaOrdiniPerUnitaOperative2(request).CercaOrdiniPerUnitaOperative2Result.ToArray
                                End Select
                            End If

                        End Using

                        If ordini IsNot Nothing AndAlso ordini.Count > 0 Then

                            'Creo una nuova lista di reparti.
                            reparti = (From ordine In ordini
                                       Select New Reparto With
                                        {
                                            .CodiceAzienda = ordine.UnitaOperativaRichiedente.Azienda.Codice,
                                            .Codice = ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice,
                                            .Descrizione = If(String.IsNullOrEmpty(ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione), ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice, ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione),
                                            .Pazienti = Nothing
                                        }).GroupBy(Function(p) p.CodiceAzienda & "-" & p.Codice).Select(Function(p) p.First).ToList()


                            'Per ogni reparto ottengo i suoi pazienti.
                            For Each reparto In reparti

                                Dim codiceAzienda = reparto.CodiceAzienda
                                Dim codiceUO = reparto.Codice

                                reparto.Pazienti = (From ordine In ordini
                                                    Where ordine.Paziente IsNot Nothing AndAlso (ordine.Paziente.IdSac IsNot Nothing OrElse Not String.IsNullOrEmpty(ordine.Paziente.IdSac)) _
                                                            AndAlso ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice = codiceUO _
                                                            AndAlso ordine.UnitaOperativaRichiedente.Azienda.Codice = codiceAzienda
                                                    Select New Paziente With
                                                       {
                                                               .Id = ordine.Paziente.IdSac.ToLower(),
                                                               .DatiAnagraficiPaziente = String.Format("{0} {1} ({2}), nat{3} il {4:d} CF {5}", ordine.Paziente.Cognome, ordine.Paziente.Nome, If(ordine.Paziente.Sesso IsNot Nothing, ordine.Paziente.Sesso.ToUpper(), "-"), If(String.Compare(ordine.Paziente.Sesso, "f", True) = 0, "a", "o"), ordine.Paziente.DataNascita, ordine.Paziente.CodiceFiscale),
                                                               .Uo = codiceAzienda & "-" & codiceUO,
                                                               .Ordini = Nothing
                                                       }).GroupBy(Function(p) p.Id).Select(Function(p) p.First).ToList()

                                'Per ogni paziente del reparto ottengo i suoi ordini.
                                For Each paziente In reparto.Pazienti
                                    'ottengo l'id del paziente.
                                    Dim sIdPaziente = paziente.Id

                                    'ottengo gli ordini del paziente.
                                    paziente.Ordini = (From ordine In ordini
                                                       Where ordine.Paziente IsNot Nothing AndAlso ordine.Paziente.IdSac IsNot Nothing AndAlso sIdPaziente IsNot Nothing _
                                               AndAlso String.Equals(ordine.Paziente.IdSac, sIdPaziente, StringComparison.InvariantCultureIgnoreCase) _
                                                                                   AndAlso ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice = codiceUO _
                                                                                   AndAlso ordine.UnitaOperativaRichiedente.Azienda.Codice = codiceAzienda
                                                       Order By ordine.DataRichiesta Descending
                                                       Select New Ordine With
                                               {
                                                .Id = ordine.IdGuidOrderEntry.ToLower(),
                                                .DataRichiesta = ordine.DataRichiesta,
                                                .AnteprimaPrestazioni = ordine.AnteprimaPrestazioni,
                                                .NumeroOrdine = ordine.IdRichiestaOrderEntry,
                                                .StatoOrderEntryDescrizione = ordine.DescrizioneStato.ToString(),
                                                .SistemaRichiedente = String.Format("{0}-{1}", ordine.SistemaRichiedente.Azienda.Codice, ordine.SistemaRichiedente.Sistema.Codice),
                                                .IdRichiestaRichiedente = ordine.IdRichiestaRichiedente,
                                                .CodiceAnagrafica = ordine.Paziente.AnagraficaCodice,
                                                .DatiAnagraficiPaziente = String.Format("{0} {1}<br />nat{2} il {3:d}<br />CF:{4}", ordine.Paziente.Nome, ordine.Paziente.Cognome, If(String.Compare(ordine.Paziente.Sesso, "m", True) = 0, "o", "a"), ordine.Paziente.DataNascita, ordine.Paziente.CodiceFiscale),
                                                .PazienteIdSac = sIdPaziente,
                                                .Eroganti = If(String.IsNullOrEmpty(ordine.SistemiEroganti), "-", String.Join(", ", ordine.SistemiEroganti.Split(";"c)).Replace("@", "-").TrimEnd(New Char() {","c, " "c})),
                                                .NumeroNosologico = ordine.NumeroNosologico,
                                                .InfoRicovero = Utility.GetInfoRicovero(codiceAzienda, ordine.NumeroNosologico),
                                                .UnitaOperativa = String.Format("{0}-{1}", ordine.UnitaOperativaRichiedente.Azienda.Codice, If(String.IsNullOrEmpty(ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione), ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice, ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione)),
                                                .UO = codiceAzienda & "-" & codiceUO,
                                                .Utente = If(ordine.Operatore Is Nothing, "---", If(String.IsNullOrEmpty(ordine.Operatore.Nome) AndAlso String.IsNullOrEmpty(ordine.Operatore.Cognome), ordine.Operatore.ID, ordine.Operatore.Nome & " " & ordine.Operatore.Cognome)),
                                                .Priorita = If(String.IsNullOrEmpty(ordine.Priorita.Descrizione), LookupManager.GetPriorita()(ordine.Priorita.Codice), ordine.Priorita.Descrizione),
                                                .Valido = ordine.StatoValidazione.Stato = StatoValidazioneEnum.AA,
                                                .DescrizioneStatoValidazione = ordine.StatoValidazione.Descrizione
                                               }).ToList()


                                Next
                            Next

                            'Elimino tutti quelli che non hanno pazienti
                            reparti = (From reparto In reparti Where reparto.Pazienti.Count > 0 Select reparto).ToList()
                        End If

                    Catch ex As FaultException(Of DataFault)
                        Throw New Exception(ex.Detail.Message)

                    Catch ex As Exception
                        ExceptionsManager.TraceException(ex)
                        Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                        portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                        Throw
                    End Try

                    Me.CacheData = reparti
                End If

            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Throw
            End Try
            Return reparti
        End Function

    End Class

    <DataObject(True)>
    Public Class Pazienti

        ''' <summary>
        ''' Ottiene la lista dei pazienti di un reparto in base al codice reparto e codice azienda.
        ''' ATTENZIONE: Internamente richiama il metodo GetData di Reparti (questa query utilizza la cache quindi è ottimizzata, NON richiama il WS di OE)
        ''' </summary>
        ''' <param name="Uo"></param>
        ''' <param name="Stato"></param>
        ''' <param name="Nosologico"></param>
        ''' <param name="Cognome"></param>
        ''' <param name="Nome"></param>
        ''' <param name="DataNascita"></param>
        ''' <param name="DaysToShow"></param>
        ''' <param name="SistemaErogante"></param>
        ''' <param name="Codice"></param>
        ''' <param name="CodiceAzienda"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetDataByReparto(Uo As String, Stato As String, Nosologico As String, Cognome As String, Nome As String, DataNascita As String, DaysToShow As Integer, SistemaErogante As String, Codice As String, CodiceAzienda As String) As List(Of Paziente)
            'Creo una nuova lista di pazienti da restituire.
            Dim pazienti As New List(Of Paziente)
            Dim reparti As New Reparti
            Dim reparto As New Reparto

            Try
                'Ottengo gli ordini
                Dim listaReparti = reparti.GetData(Uo, Stato, Nosologico, Cognome, Nome, DataNascita, DaysToShow, SistemaErogante)

                'ottengo il reparto in base al codice reparto e codice azienda.
                Dim listaDiReparti As List(Of Reparto) = (From rep In listaReparti Select rep Where rep.Codice = Codice And rep.CodiceAzienda = CodiceAzienda).ToList()
                If Not (listaDiReparti Is Nothing) AndAlso listaDiReparti.Count > 0 Then
                    reparto = listaDiReparti.First()
                    'restituisco i pazienti del reparto.
                    pazienti = reparto.Pazienti
                End If
            Catch ex As FaultException(Of DataFault)
                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return pazienti
        End Function


        ''' <summary>
        ''' Ottengo la lista dei pazienti SAC.
        ''' </summary>
        ''' <param name="cognome"></param>
        ''' <param name="nome"></param>
        ''' <param name="dataNascita"></param>
        ''' <param name="luogoNascita"></param>
        ''' <param name="codiceFiscale"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetDataSac(cognome As String, nome As String, dataNascita As String, luogoNascita As String, codiceFiscale As String) As List(Of PazientiCercaResponsePazientiCerca)
            Const MAX_RECORD As Integer = 500 'ne leggo di più di quelli restituiti cosi nella lista dei restituiti ho più record che matchano il criterio di ricerca
            Const RECORD_TO_VIEW As Integer = 110
            Try
                Using webService As New PazientiSoapClient("PazientiSoap")

                    'Valorizzo la data di nascita.
                    If String.IsNullOrEmpty(dataNascita) Then
                        dataNascita = Nothing
                    Else
                        Dim dataDiNascita As DateTime
                        If DateTime.TryParse(dataNascita, dataDiNascita) Then
                            dataNascita = dataDiNascita.ToString("yyyy-MM-dd")
                        Else
                            dataNascita = Nothing
                        End If
                    End If
                    Dim request = New DI.OrderEntry.SacServices.PazientiCercaRequest(cognome & "*", nome & "*", dataNascita, luogoNascita & "*", codiceFiscale, "", MAX_RECORD)
                    Dim response = webService.PazientiCerca(request)
                    Dim pazienti As PazientiCercaResponsePazientiCerca() = response.PazientiCercaResult
                    Dim returnValue As New List(Of PazientiCercaResponsePazientiCerca)

                    If Not pazienti Is Nothing AndAlso pazienti.Length > 0 Then
                        returnValue = pazienti.Take(RECORD_TO_VIEW).ToList()
                    End If

                    Return returnValue
                End Using


            Catch ex As WebException
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Throw
            End Try
        End Function


        ''' <summary>
        ''' Ottengo la lista dei pazienti ricoverati.
        ''' </summary>
        ''' <param name="cognome"></param>
        ''' <param name="nome"></param>
        ''' <param name="uo"></param>
        ''' <param name="tipoRicovero"></param>
        ''' <param name="idStatoEpisodio"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Shared Function GetDataDwh(cognome As String, nome As String, uo As String, tipoRicovero As String, idStatoEpisodio As Integer) As List(Of WcfDwhClinico.PazienteListaType)
            Dim pazienti As List(Of WcfDwhClinico.PazienteListaType) = Nothing
            Try

                Dim dataDimissioneDal As DateTime = DateTime.Now.AddDays(Int32.Parse(My.Settings.IntervalloChiusuraRicovero) * -1)
                Dim RepartiRicovero As New WcfDwhClinico.RepartiParam
                Dim aziendacodice = uo.Split("-")(0)
                Dim repartocodice = uo.Substring(uo.IndexOf("-") + 1)

                Dim pazientiRicoverati As New WcfDwhClinico.PazientiListaType
                Dim DataConclusione As Nullable(Of Date) = Nothing
                Dim consenso As Nullable(Of Boolean) = Nothing

                If SessionHandler.UnitàOperativeAssenti Then
                    Return Nothing
                End If

                If aziendacodice = "*" And repartocodice = "*" Then
                    '
                    ' Se non è stato selezionato un reparto allora ottengo tutta la lista dei reparti
                    '
                    Dim cds As New CustomDataSource.UnitaOperative
                    Dim listaUOPerRuolo = cds.GetData()
                    For Each reparto In listaUOPerRuolo
                        repartocodice = reparto.CodiceUO.Substring(reparto.CodiceUO.IndexOf("-") + 1)
                        RepartiRicovero.Add(New WcfDwhClinico.RepartoParam With {.AziendaCodice = reparto.CodiceAzienda, .RepartoCodice = repartocodice})
                    Next
                Else
                    '
                    ' Se è stato selezionato un reparto allora ottengo solo quel reparto.
                    '
                    RepartiRicovero.Add(New WcfDwhClinico.RepartoParam With {.AziendaCodice = aziendacodice, .RepartoCodice = repartocodice})
                End If

                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)

                    '
                    ' Ottengo un enum contenente l'id dello Stato dell'episodio, necessario per la chiamata al metodo del ws.
                    '
                    Dim EnumStato As WcfDwhClinico.StatoRicoveroEnum = CType(idStatoEpisodio, WcfDwhClinico.StatoRicoveroEnum)

                    ' 0 -> Dimesso
                    ' 1 -> In Corso
                    ' 2 -> Dimissione oppure in corso
                    ' 3 -> prenotazione
                    If EnumStato = 0 Then
                        DataConclusione = dataDimissioneDal
                    End If

                    '==========================================================================================================================
                    'IMPORTANTE
                    'Se le setting "My.Settings.ByPassOscuramenti_Utente" e "My.Settings.ByPassOscuramenti_Ruolo" sono valorizzate TokenByPassOscuramenti 
                    ' è valorizzato e bypassa gli oscuramenti
                    'Se GetTokenPerByPassOscuramenti restituisce nothing creo il token nel metodo standard
                    '==========================================================================================================================
                    Dim oToken As WcfDwhClinico.TokenType = Tokens.GetTokenPerByPassOscuramenti()
                    If oToken Is Nothing Then
                        oToken = Token
                    End If

                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oPazientiReturn As WcfDwhClinico.PazientiReturn = oWcf.PazientiRicoveratiCercaPerReparti(oToken, MAX_NUM_RECORD, Nothing, RepartiRicovero, EnumStato, tipoRicovero, Nothing, Nothing, DataConclusione, Nothing, cognome, nome, Nothing, Nothing, Nothing, Nothing, Nothing)

                    '
                    ' oPazientiReturn contiene anche l'errore nel caso se ne verifichi uno, quindi va gestito.
                    '
                    If oPazientiReturn IsNot Nothing Then
                        If oPazientiReturn.Errore IsNot Nothing Then
                            '
                            ' Se il nodo Errore è valorizzato allora faccio il throw di una CustomException di ErroreType per loggare l'errore.
                            '
                            Throw New CustomException(Of WcfDwhClinico.ErroreType)(oPazientiReturn.Errore.Descrizione, oPazientiReturn.Errore)
                        Else
                            pazientiRicoverati = oPazientiReturn.Pazienti
                        End If
                    End If
                End Using

                '
                ' se la lista è vuota allora restituisco nothing
                '
                If pazientiRicoverati Is Nothing OrElse pazientiRicoverati.Count = 0 Then
                    Return Nothing
                End If

                '
                'Viene mostrato un messaggio se le righe sono > 100
                '
                'Dim returnValue = From result In pazientiRicoverati.Take(101)
                '                  Order By result.Cognome, result.Nome
                '                  Select result


                pazienti = (From paziente In pazientiRicoverati.Take(101)
                            Order By paziente.Cognome, paziente.Nome
                            Select paziente).ToList()

            Catch ex As CustomException(Of WcfDwhClinico.ErroreType)
                '
                ' Eseguito solo se l'errore è restituito dalla chiamata al metodo del ws.
                '
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                '
                ' eseguo il throw in modo che possa essere catturato dal codcie lato client
                '
                Throw New ApplicationException("Se il tipo di ricovero è 'DAY HOSPITAL' o 'DAY SERVICE' il cognome del paziente è obbligatorio.")
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                If ex.Message.IndexOf("timeout", StringComparison.InvariantCultureIgnoreCase) > -1 Then
                    Throw New Exception("Timeout del server, specificare ulteriori parametri di ricerca.")
                End If
            End Try
            Return pazienti
        End Function
    End Class

    <DataObject(True)>
    Public Class UnitaOperative
        ''' <summary>
        ''' Restituisce la lista delle unità operative del ruolo.
        ''' </summary>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData() As List(Of UnitaOperativa)
            Dim unitaOperative As New List(Of UnitaOperativa)
            Try
                'ottengo il ruolo
                Dim ruolo = New RoleManagerUtility2(Global_asax.ConnectionStringPortalUser, My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)

                'ottengo le unità operative del ruolo
                Dim result = ruolo.GetUnitaOperative()


                If result IsNot Nothing Then
                    Dim returnValue = From uo In result
                                      Select New UnitaOperativa(uo.CodiceAzienda, uo.CodiceAzienda & "-" & uo.Codice, uo.Descrizione)
                    unitaOperative = returnValue.OrderBy(Function(uo) uo.DescrizioneUO).ToList()
                End If

            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return unitaOperative
        End Function

        ''' <summary>
        ''' Ottiene le unità operative per Nosologico e Azienda.
        ''' </summary>
        ''' <param name="Nosologico"></param>
        ''' <param name="AziendaUo"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetDataByNosologicoAziendaUo(Nosologico As String, AziendaUo As String) As List(Of UnitaOperativa)
            Dim unitaOperative As New List(Of UnitaOperativa)
            Try
                Dim customDataSource As New CustomDataSource.UnitaOperative
                unitaOperative = customDataSource.GetData()

                If Not String.IsNullOrEmpty(Nosologico) Then
                    unitaOperative = (From uo In unitaOperative Where String.Equals(uo.CodiceUO, AziendaUo) Select uo).Distinct().ToList()
                End If

            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return unitaOperative
        End Function

    End Class

    <DataObject(True)>
    Public Class Ricoveri

        ''' <summary>
        ''' Ottiene la lista dei regimi di ricovero per una unità operativa.
        ''' </summary>
        ''' <param name="AziendaUnitaOperativa"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Shared Function GetData(AziendaUnitaOperativa As String) As List(Of RoleManager.Regime)
            Dim CodiceAzienda As String = Nothing
            Dim CodiceUnitaOperativa As String = Nothing
            Try
                If Not String.IsNullOrEmpty(AziendaUnitaOperativa) Then
                    CodiceAzienda = AziendaUnitaOperativa.Split("-")(0)
                    CodiceUnitaOperativa = AziendaUnitaOperativa.Substring(AziendaUnitaOperativa.IndexOf("-") + 1)

                    If CodiceAzienda = "*" Then CodiceAzienda = Nothing
                    If CodiceUnitaOperativa = "*" Then CodiceUnitaOperativa = Nothing
                End If
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Throw
            End Try


            Return DataAdapterManager.GetRegimiDiRicoveroPerUO(CodiceAzienda, CodiceUnitaOperativa)
        End Function
    End Class

    'TODO: controllare se viene utilizzata. se no, cancellare.
    <DataObject(True)>
    Public Class PazienteDettaglio
        Inherits CacheDataSource(Of PazientiDettaglio2ByIdResponsePazientiDettaglio2)

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetDettaglioPaziente(Id As String) As PazientiDettaglio2ByIdResponsePazientiDettaglio2
            Dim paziente As New PazientiDettaglio2ByIdResponsePazientiDettaglio2
            Try
                paziente = Me.CacheData

                If paziente Is Nothing Then
                    Using webService As New PazientiSoapClient("PazientiSoap")
                        Dim result As PazientiDettaglio2ByIdResponsePazientiDettaglio2() = webService.PazientiDettaglio2ById(New PazientiDettaglio2ByIdRequest(Id)).PazientiDettaglio2ByIdResult
                        If result IsNot Nothing AndAlso result.Count > 0 Then
                            paziente = result(0)

                            Me.CacheData = paziente
                        End If
                    End Using
                End If

                Return paziente
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

                Dim errorText As String = PortalDataAdapterManager.FormatException(ex)

                portal.TracciaErrori("id Paziente: " & Id & Environment.NewLine & errorText, HttpContext.Current.User.Identity.Name, TraceEventType.Error, PortalsNames.OrderEntry)
            End Try
            Return paziente
        End Function
    End Class

    <DataObject(True)>
    Public Class Ordini

        ''' <summary>
        ''' Ottiene la lista degli ordini di un paziente di un reparto.
        '''  ATTENZIONE: Internamente richiama il metodo GetData di Reparti (questa query utilizza la cache quindi è ottimizzata, NON richiama il WS di OE)
        ''' </summary>
        ''' <param name="Uo"></param>
        ''' <param name="Stato"></param>
        ''' <param name="Nosologico"></param>
        ''' <param name="Cognome"></param>
        ''' <param name="Nome"></param>
        ''' <param name="DataNascita"></param>
        ''' <param name="DaysToShow"></param>
        ''' <param name="SistemaErogante"></param>
        ''' <param name="Codice"></param>
        ''' <param name="CodiceAzienda"></param>
        ''' <param name="IdPaziente"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetDataByPazienti(Uo As String, Stato As String, Nosologico As String, Cognome As String, Nome As String, DataNascita As String, DaysToShow As Integer, SistemaErogante As String, Codice As String, CodiceAzienda As String, IdPaziente As String) As List(Of Ordine)
            'Creo una nuova lista di pazienti da restituire.
            Dim ordini As New List(Of Ordine)


            Try
                'Ottengo i pazienti per reparto
                Dim pazienti As New Pazienti
                Dim listaPazienti As List(Of Paziente) = pazienti.GetDataByReparto(Uo, Stato, Nosologico, Cognome, Nome, DataNascita, DaysToShow, SistemaErogante, Codice, CodiceAzienda)

                'ottengo il reparto in base al codice reparto e codice azienda.
                Dim listaDiPazienti As List(Of Paziente) = (From paz In listaPazienti Select paz Where paz.Id = IdPaziente).ToList()
                If Not (listaDiPazienti Is Nothing) AndAlso listaDiPazienti.Count > 0 Then
                    Dim paziente As New Paziente
                    paziente = listaDiPazienti.First()
                    'ottengo gli ordini.
                    ordini = paziente.Ordini
                End If
            Catch ex As FaultException(Of DataFault)
                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try
            Return ordini
        End Function
    End Class

    <DataObject(True)>
    Public Class RepartiPendenti
        Inherits CacheDataSource(Of List(Of Reparto))

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(daysToShow As Integer, type As String, onlyPersonalOrders As Boolean) As List(Of Reparto)
            'Creo una nuova lista di reparti.
            Dim reparti As List(Of Reparto)
            Try

                'Controllo se la lista è già in cache.
                reparti = Me.CacheData

                'se reparti è null allora rieseguo la query.
                If reparti Is Nothing Then

                    Try
                        Dim ordini As OrdiniListaType = Nothing

                        Dim userData = UserDataManager.GetUserData()

                        Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                            Dim now = DateTime.Now

                            Dim dataInizio As DateTime
                            Dim dataFine As DateTime

                            If daysToShow = 0 Then

                                dataInizio = DateTime.MinValue
                                dataFine = DateTime.MaxValue
                            Else
                                dataInizio = now.AddDays(-daysToShow)
                                dataFine = now
                            End If

                            If onlyPersonalOrders Then

                                Dim request = New CercaOrdiniPerUtenteRequest(userData.Token, dataInizio, dataFine, My.User.Name, Nothing, Nothing, Nothing, Nothing, New List(Of StatoDescrizioneEnum)() From {StatoDescrizioneEnum.Inserito, StatoDescrizioneEnum.Modificato})

                                Dim result = webService.CercaOrdiniPerUtente(request).CercaOrdiniPerUtenteResult

                                If result Is Nothing Then
                                    Return Nothing
                                End If

                                ordini = New OrdiniListaType()

                                Dim uo = type
                                Dim uoList = New List(Of StrutturaType)()

                                If String.IsNullOrEmpty(uo) Then

                                    Dim cds As New CustomDataSource.UnitaOperative
                                    Dim uos = cds.GetData()
                                    If uos IsNot Nothing AndAlso uos.Count > 0 Then

                                        For Each unita In uos

                                            uoList.Add(New StrutturaType() With
                                           {
                                         .Azienda = New CodiceDescrizioneType() With {.Codice = unita.CodiceAzienda},
                                         .UnitaOperativa = New CodiceDescrizioneType() With {.Codice = unita.CodiceUO.Substring(unita.CodiceUO.IndexOf("-") + 1)}
                                           })
                                        Next

                                    Else
                                        '
                                        'l'utente non ha i permessi sulle UO
                                        '
                                        'Throw New Exception("DataAdapterManager.GetLookupUOPerRuolo(UserDataManager.CurrentRoleId non ha restituito righe.)")
                                        Throw New ApplicationException("Per il ruolo corrente non sono state configurate le Unità Operative. Contattare l'amministratore.")

                                    End If
                                Else
                                    uoList.Add(New StrutturaType() With
                                  {
                                   .Azienda = New CodiceDescrizioneType() With {.Codice = uo.Split("-")(0)},
                                   .UnitaOperativa = New CodiceDescrizioneType() With {.Codice = uo.Substring(uo.IndexOf("-") + 1)}
                                  })
                                End If

                                For Each ordine In result

                                    Dim ok As Boolean = False
                                    For Each unita In uoList

                                        'TODO: verificare se il seguente split è veramente non necessario.
                                        'unita.UnitaOperativa.Codice.Substring(unita.UnitaOperativa.Codice.IndexOf("-") + 1)
                                        If ordine.UnitaOperativaRichiedente.Azienda.Codice = unita.Azienda.Codice AndAlso
                                       ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice = unita.UnitaOperativa.Codice Then

                                            ok = True
                                        End If
                                    Next

                                    If ok Then
                                        ordini.Add(ordine)
                                    End If
                                Next
                            Else
                                'uo
                                Dim uo = type

                                Dim uoList = New List(Of StrutturaType)()

                                If String.IsNullOrEmpty(uo) Then

                                    Dim cds As New CustomDataSource.UnitaOperative
                                    Dim uos = cds.GetData()
                                    If uos IsNot Nothing AndAlso uos.Count > 0 Then

                                        For Each unita In uos

                                            uoList.Add(New StrutturaType() With
                                           {
                                         .Azienda = New CodiceDescrizioneType() With {.Codice = unita.CodiceAzienda},
                                         .UnitaOperativa = New CodiceDescrizioneType() With {.Codice = unita.CodiceUO.Substring(unita.CodiceUO.IndexOf("-") + 1)}
                                           })
                                        Next

                                    Else
                                        '
                                        'l'utente non ha i permessi sulle UO
                                        '
                                        'Throw New Exception("DataAdapterManager.GetLookupUOPerRuolo(UserDataManager.CurrentRoleId non ha restituito righe. )")
                                        Throw New ApplicationException("Per il ruolo corrente non sono state configurate le Unità Operative. Contattare l'amministratore.")
                                    End If

                                Else
                                    uoList.Add(New StrutturaType() With
                                  {
                                   .Azienda = New CodiceDescrizioneType() With {.Codice = uo.Split("-")(0)},
                                   .UnitaOperativa = New CodiceDescrizioneType() With {.Codice = uo.Substring(uo.IndexOf("-") + 1)}
                                  })
                                End If

                                Dim request = New CercaOrdiniPerUnitaOperative2Request(userData.Token, dataInizio, dataFine, uoList, Nothing, Nothing, Nothing, Nothing, New List(Of StatoDescrizioneEnum)() From {StatoDescrizioneEnum.Inserito, StatoDescrizioneEnum.Modificato}, Nothing, Nothing)

                                ordini = webService.CercaOrdiniPerUnitaOperative2(request).CercaOrdiniPerUnitaOperative2Result
                            End If
                        End Using

                        If ordini Is Nothing OrElse ordini.Count = 0 Then
                            Return Nothing
                        End If



                        reparti = (From ordine In ordini
                                   Select New Reparto With
                                  {
                                  .CodiceAzienda = ordine.UnitaOperativaRichiedente.Azienda.Codice,
                                  .Codice = ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice,
                                  .Descrizione = If(String.IsNullOrEmpty(ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione), ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice, ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione),
                                  .Pazienti = Nothing
                                  }).GroupBy(Function(p) p.CodiceAzienda & "-" & p.Codice).Select(Function(p) p.First).ToList()

                        For Each reparto In reparti

                            Dim codiceAzienda = reparto.CodiceAzienda
                            Dim codiceUO = reparto.Codice

                            reparto.Pazienti = (From ordine In ordini
                                                Where ordine.Paziente IsNot Nothing AndAlso ordine.Paziente.IdSac IsNot Nothing _
                                             AndAlso ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice = codiceUO _
                                             AndAlso ordine.UnitaOperativaRichiedente.Azienda.Codice = codiceAzienda
                                                Select New Paziente With
                                           {
                                           .Id = ordine.Paziente.IdSac.ToLower(),
                                           .DatiAnagraficiPaziente = String.Format("{0} {1} ({2}), nat{3} il {4:d} CF {5}", ordine.Paziente.Cognome, ordine.Paziente.Nome, If(ordine.Paziente.Sesso IsNot Nothing, ordine.Paziente.Sesso.ToUpper(), "-"), If(String.Compare(ordine.Paziente.Sesso, "f", True) = 0, "a", "o"), ordine.Paziente.DataNascita, ordine.Paziente.CodiceFiscale),
                                           .Uo = codiceAzienda & "-" & codiceUO,
                                           .Ordini = Nothing
                                           }).GroupBy(Function(p) p.Id).Select(Function(p) p.First).ToList()


                            For Each paziente In reparto.Pazienti

                                Dim idPaziente = paziente.Id

                                paziente.Ordini = (From ordine In ordini
                                                   Where ordine.Paziente IsNot Nothing AndAlso ordine.Paziente.IdSac IsNot Nothing AndAlso idPaziente IsNot Nothing _
                                               AndAlso String.Equals(ordine.Paziente.IdSac, idPaziente, StringComparison.InvariantCultureIgnoreCase) _
                                               AndAlso ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice = codiceUO _
                                               AndAlso ordine.UnitaOperativaRichiedente.Azienda.Codice = codiceAzienda
                                                   Select New Ordine With
                                               {
                                                     .Id = ordine.IdGuidOrderEntry.ToLower(),
                                                     .DataRichiesta = ordine.DataRichiesta,
                                                     .AnteprimaPrestazioni = ordine.AnteprimaPrestazioni,
                                                     .NumeroOrdine = ordine.IdRichiestaOrderEntry,
                                                     .StatoOrderEntryDescrizione = ordine.DescrizioneStato.ToString(),
                                                     .SistemaRichiedente = String.Format("{0}-{1}", ordine.SistemaRichiedente.Azienda.Codice, ordine.SistemaRichiedente.Sistema.Codice),
                                                     .IdRichiestaRichiedente = ordine.IdRichiestaRichiedente,
                                                     .DatiAnagraficiPaziente = String.Format("{0} {1}<br />nat{2} il {3:d}<br />CF:{4}", ordine.Paziente.Nome, ordine.Paziente.Cognome, If(String.Compare(ordine.Paziente.Sesso, "m", True) = 0, "o", "a"), ordine.Paziente.DataNascita, ordine.Paziente.CodiceFiscale),
                                                     .CodiceAnagrafica = ordine.Paziente.AnagraficaCodice,
                                                     .DataPrenotazione = If(Not ordine.DataPrenotazione.HasValue OrElse ordine.DataPrenotazione = DateTime.MinValue, "-", ordine.DataPrenotazione.Value.ToString("G")),
                                                     .PazienteIdSac = idPaziente,
                                                     .Eroganti = If(String.IsNullOrEmpty(ordine.SistemiEroganti), "-", String.Join(", ", ordine.SistemiEroganti.Split(";"c)).Replace("@", "-").TrimEnd(New Char() {","c, " "c})),
                                                     .NumeroNosologico = ordine.NumeroNosologico,
                                                     .InfoRicovero = Utility.GetInfoRicovero(codiceAzienda, ordine.NumeroNosologico),
                                                     .UnitaOperativa = String.Format("{0}-{1}", ordine.UnitaOperativaRichiedente.Azienda.Codice, If(String.IsNullOrEmpty(ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione), ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice, ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione)),
                                                     .UO = codiceAzienda & "-" & codiceUO,
                                                     .Utente = If(ordine.Operatore Is Nothing, "---", If(String.IsNullOrEmpty(ordine.Operatore.Nome) AndAlso String.IsNullOrEmpty(ordine.Operatore.Cognome), ordine.Operatore.ID, ordine.Operatore.Nome & " " & ordine.Operatore.Cognome)),
                                                     .Priorita = If(String.IsNullOrEmpty(ordine.Priorita.Descrizione), LookupManager.GetPriorita()(ordine.Priorita.Codice), ordine.Priorita.Descrizione),
                                                     .Valido = ordine.StatoValidazione.Stato = StatoValidazioneEnum.AA,
                                                     .DescrizioneStatoValidazione = ordine.StatoValidazione.Descrizione
                                                       }).ToList()
                            Next
                        Next

                    Catch ex As FaultException(Of DataFault)
                        Throw New Exception(ex.Detail.Message)

                    Catch ex As Exception
                        ExceptionsManager.TraceException(ex)
                        Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                        portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                        Throw
                    End Try

                End If

                Me.CacheData = reparti
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Throw
            End Try
            Return reparti
        End Function
    End Class

    <DataObject(True)>
    Public Class PazientiPendenti

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetDataByReparto(daysToShow As Integer, type As String, onlyPersonalOrders As Boolean, Codice As String, CodiceAzienda As String) As List(Of Paziente)
            'Creo una nuova lista di pazienti da restituire.
            Dim pazienti As New List(Of Paziente)

            Try
                'Ottengo gli ordini
                Dim reparti As New RepartiPendenti
                Dim listaReparti = reparti.GetData(daysToShow, type, onlyPersonalOrders)
                'ottengo il reparto in base al codice reparto e codice azienda.
                Dim listaDiReparti As List(Of Reparto) = (From rep In listaReparti Select rep Where rep.Codice = Codice And rep.CodiceAzienda = CodiceAzienda).ToList()
                If Not (listaDiReparti Is Nothing) AndAlso listaDiReparti.Count > 0 Then
                    Dim reparto As Reparto = listaDiReparti.First()
                    'restituisco i pazienti del reparto.
                    pazienti = reparto.Pazienti
                End If
            Catch ex As FaultException(Of DataFault)
                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try
            Return pazienti
        End Function
    End Class

    <DataObject(True)>
    Public Class OrdiniPendenti

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetDataByPazienti(daysToShow As Integer, type As String, onlyPersonalOrders As Boolean, Codice As String, CodiceAzienda As String, IdPaziente As String) As List(Of Ordine)
            'Creo una nuova lista di pazienti da restituire.
            Dim ordini As New List(Of Ordine)

            Try
                'Ottengo i pazienti per reparto
                Dim pazienti As New PazientiPendenti
                Dim listaPazienti As List(Of Paziente) = pazienti.GetDataByReparto(daysToShow, type, onlyPersonalOrders, Codice, CodiceAzienda)

                'ottengo il reparto in base al codice reparto e codice azienda.
                Dim listaDiPazienti As List(Of Paziente) = (From paz In listaPazienti Select paz Where paz.Id = IdPaziente).ToList()
                If Not (listaDiPazienti Is Nothing) AndAlso listaDiPazienti.Count > 0 Then
                    Dim paziente As Paziente = listaDiPazienti.First()
                    'ottengo gli ordini.
                    ordini = paziente.Ordini
                End If
            Catch ex As FaultException(Of DataFault)
                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return ordini
        End Function
    End Class

    <DataObject(True)>
    Public Class ProfiliUtente

        ''' <summary>
        ''' Ottiene la lista dei profili in base al codice/descrizione.
        ''' </summary>
        ''' <param name="codiceDescrizione"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(codiceDescrizione As String) As ProfiliUtenteListaType

            Dim result As ProfiliUtenteListaType

            Try
                Dim userData = UserDataManager.GetUserData()

                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                    Dim request = New CercaProfiliUtentePerCodiceODescrizioneRequest(userData.Token, codiceDescrizione)

                    Dim response = webService.CercaProfiliUtentePerCodiceODescrizione(request)

                    result = response.CercaProfiliUtentePerCodiceODescrizioneResult
                End Using

                Return result
            Catch ex As FaultException(Of DataFault)

                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Return Nothing
            End Try
        End Function

        ''' <summary>
        ''' Aggiorna un profilo.
        ''' </summary>
        ''' <param name="idProfilo"></param>
        ''' <param name="descrizione"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Update, True)>
        Public Shared Function UpdateData(idProfilo As String, descrizione As String) As String
            Try
                Dim userData = UserDataManager.GetUserData()
                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                    Dim profilo As ProfiloUtenteType
                    If String.IsNullOrEmpty(idProfilo) Then
                        profilo = New ProfiloUtenteType()
                        profilo.Prestazioni = New ProfiloUtentePrestazioniType()
                    Else
                        profilo = webService.OttieniProfiloUtentePerId(New OttieniProfiloUtentePerIdRequest(userData.Token, idProfilo)).OttieniProfiloUtentePerIdResult
                    End If
                    profilo.Descrizione = descrizione
                    Dim request = New AggiungiOppureModificaProfiloUtenteRequest(userData.Token, profilo)
                    Dim response = webService.AggiungiOppureModificaProfiloUtente(request)
                    Dim result = response.AggiungiOppureModificaProfiloUtenteResult
                    If result Is Nothing Then
                        Return Nothing
                    End If
                    Return result.Id
                End Using
            Catch ex As FaultException(Of DataFault)
                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Return Nothing
            End Try
        End Function

        ''' <summary>
        ''' Elimina un profilo.
        ''' </summary>
        ''' <param name="idProfilo"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Delete, True)>
        Public Shared Function DeleteData(idProfilo As String) As Boolean
            Dim res As Boolean = False
            Try
                Dim userData = UserDataManager.GetUserData()
                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                    Dim request = New CancellaProfiloUtentePerIdRequest(userData.Token, idProfilo)
                    Dim response = webService.CancellaProfiloUtentePerId(request)
                    res = True
                End Using
            Catch ex As FaultException(Of DataFault)
                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try
            Return res
        End Function

        ''' <summary>
        ''' Ottiene un profilo in base al suo Id.
        ''' </summary>
        ''' <param name="idProfilo"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select)>
        Public Shared Function GetDataById(idProfilo As String) As ProfiloUtenteType
            Try
                Dim userData = UserDataManager.GetUserData()
                Dim result As ProfiloUtenteType = Nothing
                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                    Dim request = New OttieniProfiloUtentePerIdRequest(userData.Token, idProfilo)
                    Dim response = webService.OttieniProfiloUtentePerId(request)
                    result = response.OttieniProfiloUtentePerIdResult
                    If result Is Nothing Then
                        Return Nothing
                    End If
                    Return result
                End Using
            Catch ex As FaultException(Of DataFault)
                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Return Nothing
            End Try
        End Function
    End Class

    <DataObject(True)>
    Public Class Profili
        ''' <summary>
        ''' Cerca la lista dei profili "generici" (non creati dall'utente)
        ''' </summary>
        ''' <param name="uo"></param>
        ''' <param name="codiceDescrizione"></param>
        ''' <param name="regime"></param>
        ''' <param name="priorita"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select)>
        Public Function GetData(uo As String, codiceDescrizione As String, regime As String, priorita As String) As List(Of PrestazioneListaType)
            Try
                Dim userData = UserDataManager.GetUserData()
                Dim listaPrestazioni As New List(Of PrestazioneListaType)
                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                    Dim tipoList = New List(Of TipoPrestazioneErogabileEnum)() From {TipoPrestazioneErogabileEnum.ProfiloBlindato, TipoPrestazioneErogabileEnum.ProfiloScomponibile}

                    Dim request = New CercaProfiliPerCodiceODescrizioneRequest(userData.Token, Utility.StringToEnum(Of RegimeEnum)(regime), Utility.StringToEnum(Of PrioritaEnum)(priorita), uo.Split("-")(0), uo.Substring(uo.IndexOf("-") + 1), DI.Common.Utility.GetAziendaRichiedente2(), My.Settings.SistemaRichiedente, codiceDescrizione, tipoList)

                    Dim response = webService.CercaProfiliPerCodiceODescrizione(request)

                    Dim prestazioni = response.CercaProfiliPerCodiceODescrizioneResult

                    If prestazioni Is Nothing Then
                        Return Nothing
                    End If

                    If prestazioni IsNot Nothing AndAlso prestazioni.Count > 0 Then
                        listaPrestazioni = (From prestazione
                                            In prestazioni.Take(110)
                                            Order By prestazione.Descrizione
                                            Select prestazione
                                            ).ToList()
                    End If

                    Return listaPrestazioni
                End Using
            Catch ex As FaultException(Of DataFault)

                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Return Nothing
            End Try
        End Function

    End Class

    <DataObject(True)>
    Public Class Prestazioni
        Inherits CacheDataSource(Of List(Of Prestazione))

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Shared Function GetListaPrestazioniProfilo(descrizione As String, erogante As String) As PrestazioniListaType
            If Not String.IsNullOrEmpty(descrizione) Then
                descrizione = HttpUtility.UrlDecode(descrizione)
            Else
                descrizione = Nothing
            End If
            Dim azienda = erogante.Split("-")(0)
            Dim sistema = erogante.Substring(erogante.IndexOf("-") + 1)
            Try
                Dim userData = UserDataManager.GetUserData()
                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                    Dim request = New CercaPrestazioniProfiliUtentePerCodiceODescrizioneRequest(userData.Token, DI.Common.Utility.GetAziendaRichiedente2(), My.Settings.SistemaRichiedente, azienda, sistema, descrizione)
                    Dim response = webService.CercaPrestazioniProfiliUtentePerCodiceODescrizione(request)
                    Dim result = response.CercaPrestazioniProfiliUtentePerCodiceODescrizioneResult

                    If result Is Nothing Then
                        Return Nothing
                    End If

                    Return result
                End Using
            Catch ex As FaultException(Of DataFault)
                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Return Nothing
            End Try
        End Function

        ''' <summary>
        ''' Ottiene la lista di tutte le prestazioni di un profilo utente
        ''' </summary>
        ''' <param name="idProfilo"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select)>
        Public Shared Function GetPrestazioniByProfilo(idProfilo As String) As ProfiloUtentePrestazioniType
            Try
                Dim userData = UserDataManager.GetUserData()
                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                    Dim request = New OttieniProfiloUtentePerIdRequest(userData.Token, idProfilo)
                    Dim response = webService.OttieniProfiloUtentePerId(request)
                    Dim result = response.OttieniProfiloUtentePerIdResult
                    If result Is Nothing Then
                        Return Nothing
                    End If
                    'For Each row In result.Prestazioni
                    '    Dim prestazione = New With {.Id = row.Id, .Codice = row.Codice, .Descrizione = row.Descrizione, .SistemaErogante = String.Format("{0}-{1}", row.SistemaErogante.Azienda.Codice, row.SistemaErogante.Sistema.Codice)}
                    '    list.Add(row.Id.ToString(), prestazione)
                    'Next
                    Return result.Prestazioni
                End Using
            Catch ex As FaultException(Of DataFault)
                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Return Nothing
            End Try
        End Function

        ''' <summary>
        ''' Inserisce le prestazioni in un profilo utente.
        ''' </summary>
        ''' <param name="idProfilo"></param>
        ''' <param name="idPrestazioni"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Update, True)>
        Public Shared Function InsertPrestazioniInProfilo(idProfilo As String, idPrestazioni As String) As String
            Try
                Dim userData = UserDataManager.GetUserData()

                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                    Dim profilo = webService.OttieniProfiloUtentePerId(New OttieniProfiloUtentePerIdRequest(userData.Token, idProfilo)).OttieniProfiloUtentePerIdResult

                    For Each idPrestazione In idPrestazioni.Split(";"c)

                        profilo.Prestazioni.Add(New ProfiloUtentePrestazioneType() With {.Id = idPrestazione})
                    Next

                    Dim request = New AggiungiOppureModificaProfiloUtenteRequest(userData.Token, profilo)

                    Dim response = webService.AggiungiOppureModificaProfiloUtente(request)

                    Dim result = response.AggiungiOppureModificaProfiloUtenteResult

                    If result Is Nothing Then
                        Return Nothing
                    End If

                    Return "Ok"
                End Using
            Catch ex As FaultException(Of DataFault)

                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Return Nothing
            End Try
        End Function

        ''' <summary>
        ''' Rimuove una prestazione dal profilo
        ''' </summary>
        ''' <param name="idProfilo"></param>
        ''' <param name="idPrestazioni"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Delete)>
        Public Shared Function DeletePrestazioneDaProfilo(idProfilo As String, idPrestazioni As String) As String
            Try
                Dim userData = UserDataManager.GetUserData()

                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                    Dim profilo = webService.OttieniProfiloUtentePerId(New OttieniProfiloUtentePerIdRequest(userData.Token, idProfilo)).OttieniProfiloUtentePerIdResult

                    Dim ids = idPrestazioni.Split(";"c)

                    profilo.Prestazioni.RemoveAll(Function(e) Array.IndexOf(ids, e.Id) > -1)

                    Dim request = New AggiungiOppureModificaProfiloUtenteRequest(userData.Token, profilo)

                    Dim response = webService.AggiungiOppureModificaProfiloUtente(request)

                    Dim result = response.AggiungiOppureModificaProfiloUtenteResult

                    If result Is Nothing Then
                        Return Nothing
                    End If

                    Return "Ok"
                End Using
            Catch ex As FaultException(Of DataFault)

                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Return Nothing
            End Try
        End Function

        ''' <summary>
        ''' Ottiene i gruppi di prestazioni
        ''' </summary>
        ''' <param name="UnitaOperative"></param>
        ''' <param name="AziendaErogante"></param>
        ''' <param name="SistemaErogante"></param>
        ''' <param name="CodiceDescrizione"></param>
        ''' <param name="Regime"></param>
        ''' <param name="Priorita"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetGruppiPrestazioni(UnitaOperative As String, AziendaErogante As String, SistemaErogante As String, CodiceDescrizione As String, Regime As String, Priorita As String) As GruppiPrestazioniListaType

            Dim gruppiPrestazioni As New GruppiPrestazioniListaType

            Try
                Dim userData = UserDataManager.GetUserData()

                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                    Dim enumRegimi As RegimeEnum = Utility.StringToEnum(Of RegimeEnum)(Regime)
                    Dim enumPriorita As PrioritaEnum = Utility.StringToEnum(Of PrioritaEnum)(Priorita)

                    Dim request As New CercaGruppiPrestazioniPerDescrizioneRequest(userData.Token, enumRegimi, enumPriorita, UnitaOperative.Split("-")(0), UnitaOperative.Substring(UnitaOperative.IndexOf("-") + 1), DI.Common.Utility.GetAziendaRichiedente2(), My.Settings.SistemaRichiedente, CodiceDescrizione)
                    Dim response As CercaGruppiPrestazioniPerDescrizioneResponse = webService.CercaGruppiPrestazioniPerDescrizione(request)

                    If response?.CercaGruppiPrestazioniPerDescrizioneResult IsNot Nothing Then
                        gruppiPrestazioni = response.CercaGruppiPrestazioniPerDescrizioneResult

                    End If
                End Using

            Catch ex As FaultException(Of DataFault)

                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return gruppiPrestazioni
        End Function

        ''' <summary>
        ''' Ottiene le prestazioni per IdRichiesta
        ''' </summary>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetDataByIdRichiesta(IdRichiesta As String) As List(Of Prestazione)
            Dim prestazioni As New List(Of Prestazione)

            Try
                prestazioni = Me.CacheData

                If prestazioni Is Nothing Then
                    Dim userData = UserDataManager.GetUserData()
                    Dim ordineTestata = New OrdineTestata
                    Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                        Dim request = New OttieniOrdinePerIdGuidRequest(userData.Token, IdRichiesta)
                        Dim response = ordineTestata.OttieniOrdinePerIdGuid(IdRichiesta)

                        'Ottengo la richiesta
                        Dim richiestaWs As StatoType = response.OttieniOrdinePerIdGuidResult

                        'Creo le prestazioni
                        prestazioni = (From riga In richiestaWs.Ordine.RigheRichieste
                                       Order By riga.SistemaErogante.Azienda.Codice, riga.SistemaErogante.Sistema.Codice, riga.Prestazione.Codice
                                       Select New Prestazione With
                                           {
                                              .Id = riga.Prestazione.Id,
                                              .Codice = riga.Prestazione.Codice,
                                              .Descrizione = If(String.IsNullOrEmpty(riga.Prestazione.Descrizione), "-", riga.Prestazione.Descrizione),
                                              .SistemaErogante = String.Format("{0}-{1}", riga.SistemaErogante.Azienda.Codice, riga.SistemaErogante.Sistema.Codice),
                                              .Valido = If(richiestaWs.StatoValidazione.Righe IsNot Nothing, richiestaWs.StatoValidazione.Righe.Where(Function(e) e.Index = (richiestaWs.Ordine.RigheRichieste.IndexOf(riga) + 1)).First().Stato = StatoValidazioneEnum.AA, Nothing),
                                              .DescrizioneStatoValidazione = If(richiestaWs.StatoValidazione.Righe IsNot Nothing, richiestaWs.StatoValidazione.Righe.Where(Function(e) e.Index = (richiestaWs.Ordine.RigheRichieste.IndexOf(riga) + 1)).First().Descrizione, Nothing),
                                              .DatiAccessori = riga.DatiAggiuntivi,
                                              .Tipo = riga.PrestazioneTipo
                                           }).Reverse().ToList()


                        ''Ottengo i dati accessori
                        Dim domandeDatiAccessori = webService.OttieniDatiAccessoriPerIdGuid(New OttieniDatiAccessoriPerIdGuidRequest(userData.Token, IdRichiesta)).OttieniDatiAccessoriPerIdGuidResult

                        'Aggiungo i dati accessori ad ogni prestazione
                        For Each prestazione In prestazioni
                            Utility.NormalizzaDatiAccessori(prestazione.DatiAccessori, domandeDatiAccessori)
                        Next
                        Me.CacheData = prestazioni
                    End Using

                End If
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return prestazioni
        End Function

        ''' <summary>
        ''' Restituisce la lista delle prestazioni recenti su una Unità Operativa
        ''' </summary>
        ''' <param name="Uo"></param>
        ''' <param name="CodiceDescrizione"></param>
        ''' <param name="Regime"></param>
        ''' <param name="Priorita"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetDataByUo(Uo As String, CodiceDescrizione As String, Regime As String, Priorita As String) As List(Of PrestazioneListaType)
            Dim listaPrestazioni As New List(Of PrestazioneListaType)
            Try
                Dim userData = UserDataManager.GetUserData()

                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                    Dim request = New CercaPrestazioniPerUnitaOperativaRequest(userData.Token, Utility.StringToEnum(Of RegimeEnum)(Regime), Utility.StringToEnum(Of PrioritaEnum)(Priorita), Uo.Split("-")(0), Uo.Substring(Uo.IndexOf("-") + 1), DI.Common.Utility.GetAziendaRichiedente2(), My.Settings.SistemaRichiedente, Nothing, Nothing, CodiceDescrizione)
                    Dim response = webService.CercaPrestazioniPerUnitaOperativa(request)
                    Dim prestazioni = response.CercaPrestazioniPerUnitaOperativaResult

                    If prestazioni IsNot Nothing AndAlso prestazioni.Count > 0 Then
                        listaPrestazioni = (From prestazione
                                            In prestazioni.Take(110)
                                            Order By prestazione.Descrizione
                                            Select prestazione
                                            ).ToList()
                    End If
                End Using

            Catch ex As FaultException(Of DataFault)
                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return listaPrestazioni
        End Function


        ''' <summary>
        ''' Ottiene la lista delle prestazioni recenti sul paziente.
        ''' </summary>
        ''' <param name="Uo"></param>
        ''' <param name="IdPaziente"></param>
        ''' <param name="CodiceDescrizione"></param>
        ''' <param name="Regime"></param>
        ''' <param name="Priorita"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetDataByIdPaziente(Uo As String, IdPaziente As String, CodiceDescrizione As String, Regime As String, Priorita As String) As List(Of PrestazioneListaType)
            Dim listaPrestazioni As New List(Of PrestazioneListaType)

            Try
                Dim userData = UserDataManager.GetUserData()
                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                    Dim request = New CercaPrestazioniPerPazienteRequest(userData.Token, Utility.StringToEnum(Of RegimeEnum)(Regime), Utility.StringToEnum(Of PrioritaEnum)(Priorita), Uo.Split("-")(0), Uo.Substring(Uo.IndexOf("-") + 1), DI.Common.Utility.GetAziendaRichiedente2(), My.Settings.SistemaRichiedente, Nothing, Nothing, IdPaziente, CodiceDescrizione)
                    Dim response = webService.CercaPrestazioniPerPaziente(request)
                    Dim prestazioni = response.CercaPrestazioniPerPazienteResult

                    If prestazioni IsNot Nothing AndAlso prestazioni.Count > 0 Then
                        listaPrestazioni = (From prestazione
                                                In prestazioni.Take(110)
                                            Order By prestazione.Descrizione
                                            Select prestazione
                                                ).ToList()
                    End If
                End Using

            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return listaPrestazioni
        End Function

        ''' <summary>
        ''' Ottiene la lista delle prestazioni in base al Sistema Erogante
        ''' </summary>
        ''' <param name="Uo"></param>
        ''' <param name="AziendaErogante"></param>
        ''' <param name="SistemaErogante"></param>
        ''' <param name="CodiceDescrizione"></param>
        ''' <param name="Regime"></param>
        ''' <param name="Priorita"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetDataByErogante(Uo As String, AziendaErogante As String, SistemaErogante As String, CodiceDescrizione As String, Regime As String, Priorita As String) As List(Of PrestazioneListaType)
            Dim listaPrestazioni As New List(Of PrestazioneListaType)

            Try
                Dim userData = UserDataManager.GetUserData()

                Dim prestazioni As PrestazioniListaType

                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                    If Not String.IsNullOrEmpty(SistemaErogante) Then
                        'ricerca sul singolo sistema erogante
                        Dim request = New CercaPrestazioniPerSistemaEroganteRequest(userData.Token, Utility.StringToEnum(Of RegimeEnum)(Regime), Utility.StringToEnum(Of PrioritaEnum)(Priorita), Uo.Split("-")(0), Uo.Substring(Uo.IndexOf("-") + 1), DI.Common.Utility.GetAziendaRichiedente2(), My.Settings.SistemaRichiedente, AziendaErogante, SistemaErogante, CodiceDescrizione)
                        Dim response = webService.CercaPrestazioniPerSistemaErogante(request)
                        prestazioni = response.CercaPrestazioniPerSistemaEroganteResult
                    Else
                        'ricerca per tutti i sistemi eroganti
                        Dim request = New CercaPrestazioniPerCodiceODescrizioneRequest(userData.Token, Utility.StringToEnum(Of RegimeEnum)(Regime), Utility.StringToEnum(Of PrioritaEnum)(Priorita), Uo.Split("-")(0), Uo.Substring(Uo.IndexOf("-") + 1), DI.Common.Utility.GetAziendaRichiedente2(), My.Settings.SistemaRichiedente, AziendaErogante, SistemaErogante, CodiceDescrizione)
                        Dim response = webService.CercaPrestazioniPerCodiceODescrizione(request)
                        prestazioni = response.CercaPrestazioniPerCodiceODescrizioneResult
                    End If
                End Using

                If prestazioni IsNot Nothing AndAlso prestazioni.Count > 0 Then
                    listaPrestazioni = (From prestazione
                                            In prestazioni.Take(110)
                                        Order By prestazione.Descrizione
                                        Select prestazione
                                            ).ToList()
                End If
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return listaPrestazioni
        End Function

        ''' <summary>
        ''' Ottiene la lista delle prestazioni in base all'id del gruppo.
        ''' </summary>
        ''' <param name="Regime"></param>
        ''' <param name="Priorita"></param>
        ''' <param name="Uo"></param>
        ''' <param name="IdGruppo"></param>
        ''' <param name="Descrizione"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetDataByIdGruppo(Regime As String, Priorita As String, Uo As String, IdGruppo As String, Descrizione As String) As List(Of PrestazioneListaType)
            Dim listaPrestazioni As New List(Of PrestazioneListaType)

            Try
                Dim userData = UserDataManager.GetUserData()

                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                    Dim request = New CercaPrestazioniPerGruppoPrestazioniRequest(userData.Token, Utility.StringToEnum(Of RegimeEnum)(Regime), Utility.StringToEnum(Of PrioritaEnum)(Priorita), Uo.Split("-")(0), Uo.Substring(Uo.IndexOf("-") + 1), DI.Common.Utility.GetAziendaRichiedente2(), My.Settings.SistemaRichiedente, Nothing, Nothing, IdGruppo, Descrizione)

                    Dim response = webService.CercaPrestazioniPerGruppoPrestazioni(request)

                    Dim prestazioni = response.CercaPrestazioniPerGruppoPrestazioniResult

                    If prestazioni IsNot Nothing AndAlso prestazioni.Count > 0 Then
                        listaPrestazioni = (From prestazione
                                            In prestazioni.Take(110)
                                            Order By prestazione.Descrizione
                                            Select prestazione
                                            ).ToList()
                    End If

                End Using
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return listaPrestazioni
        End Function
    End Class

    <DataObject(True)>
    Public Class DatiAccessori

        <DataObjectMethod(DataObjectMethodType.Select)>
        Public Function GetDataByIdRichiesta(IdRichiesta As String) As List(Of DatoAccessorioListaType)
            Dim datiAccessori As New List(Of DatoAccessorioListaType)

            Try
                Dim userData = UserDataManager.GetUserData()
                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                    Dim request = New OttieniDatiAccessoriPerIdGuidRequest(userData.Token, IdRichiesta)
                    Dim response As OttieniDatiAccessoriPerIdGuidResponse = webService.OttieniDatiAccessoriPerIdGuid(request)
                    Dim result As DatiAccessoriListaType = response.OttieniDatiAccessoriPerIdGuidResult

                    datiAccessori = (From domande In result
                                     Order By domande.DatoAccessorio.Ordinamento
                                     Select domande).ToList()

                    datiAccessori.GroupBy(Function(x) x.DatoAccessorio.Etichetta).Distinct()
                End Using
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Throw
            End Try

            Return datiAccessori
        End Function


        <DataObjectMethod(DataObjectMethodType.Select)>
        Public Function GetDataByPrestazione(IdRichiesta As String, IdPrestazione As String) As List(Of DatoAccessorioListaType)
            Dim datiAccessori As New List(Of DatoAccessorioListaType)
            Try
                Dim da As New DatiAccessori
                Dim tuttiDatiAccessori = da.GetDataByIdRichiesta(IdRichiesta)

                For Each datoAccessorio In tuttiDatiAccessori
                    Dim prestaz = (From p In datoAccessorio.Prestazioni Where String.Equals(p.Id, IdPrestazione) Select p).ToList
                    If prestaz IsNot Nothing AndAlso prestaz.Count > 0 Then
                        datiAccessori.Add(datoAccessorio)
                    End If
                Next

            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Throw
            End Try

            Return datiAccessori
        End Function
    End Class

    <DataObject(True)>
    Public Class DatiAggiuntivi

        <DataObjectMethod(DataObjectMethodType.Select)>
        Public Function GetDataByIdRichiesta(IdRichiesta As String) As DatiAggiuntiviType
            Dim datiAggiuntivi As New DatiAggiuntiviType

            Try
                Dim userData = UserDataManager.GetUserData()

                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                    Dim request = New OttieniOrdinePerIdGuidRequest(userData.Token, IdRichiesta)
                    Dim response = webService.OttieniOrdinePerIdGuid(request)
                    Dim richiestaWs As StatoType = response.OttieniOrdinePerIdGuidResult

                    If richiestaWs IsNot Nothing OrElse richiestaWs.Ordine.RigheRichieste IsNot Nothing OrElse richiestaWs.Ordine.RigheRichieste.Count > 0 Then
                        datiAggiuntivi = richiestaWs.Ordine.DatiAggiuntivi
                    End If

                    Dim listaDatiAccessori As DatiAccessoriListaType = webService.OttieniDatiAccessoriPerIdGuid(New OttieniDatiAccessoriPerIdGuidRequest(userData.Token, IdRichiesta)).OttieniDatiAccessoriPerIdGuidResult

                    If listaDatiAccessori.Count > 0 Then
                        'Dati Accessori Testata Richiesta
                        Utility.NormalizzaDatiAccessori(datiAggiuntivi, listaDatiAccessori)
                    End If
                End Using

            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return datiAggiuntivi
        End Function


        <DataObjectMethod(DataObjectMethodType.Select)>
        Public Function GetDataByPrestazione(IdRichiesta As String, IdPrestazione As String) As DatiAggiuntiviType
            Dim datiAggiuntiviPrestazioni As New DatiAggiuntiviType

            Try
                Dim datasource As New Prestazioni
                'ottengo tutte le prestazioni della richiesta
                Dim listaPrestazioni As List(Of Prestazione) = datasource.GetDataByIdRichiesta(IdRichiesta)

                If listaPrestazioni IsNot Nothing AndAlso listaPrestazioni.Count > 0 Then
                    'ottengo tutte le prestazione con id = IdPrestazione (dovrebbe essere una sola)
                    listaPrestazioni = (From prest In listaPrestazioni Where String.Equals(prest.Id, IdPrestazione) Select prest).ToList()

                    If listaPrestazioni IsNot Nothing AndAlso listaPrestazioni.Count > 0 Then
                        'Ottengo la prima prestazione della lista
                        Dim prestazione As Prestazione = listaPrestazioni.First()

                        'Se non è vuota prendo i suoi dati accessori
                        If prestazione IsNot Nothing Then
                            datiAggiuntiviPrestazioni = prestazione.DatiAccessori
                        End If
                    End If
                End If
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return datiAggiuntiviPrestazioni
        End Function
    End Class

    <DataObject(True)>
    Public Class Regimi

        <DataObjectMethod(DataObjectMethodType.Select)>
        Public Function GetData(IdPaziente As String, Nosologico As String, RegimeCorrente As String, AziendaUo As String) As List(Of KeyValuePair(Of String, String))
            Dim listaRegimi As New List(Of KeyValuePair(Of String, String))

            Try
                Dim TipoEpisodio As String = String.Empty

                '
                ' MODIFICA ETTORE 2017-03-28: passato "aziendauo" nel formato <Azienda>-<CodiceUO>
                ' Ricavo la parte Azienda e eseguo lettura del ricovero per ottente il tipo di ricovero
                '
                Dim azienda As String = Split(AziendaUo, "-")(0)

                ' Leggo i dati del ricovero e ricavo il tipo di ricovero
                Dim ricovero As WcfDwhClinico.EpisodioType = CustomDataSourceDettaglioPaziente.GetDatiRicoveroByNosologicoAzienda(Nosologico, azienda)

                ' Se ho trovato il ricovero leggo leggo il tipo di ricovero e lo uso sotto per popolare la combo dei regimi
                If Not ricovero Is Nothing AndAlso Not ricovero.TipoEpisodio Is Nothing Then
                    TipoEpisodio = ricovero.TipoEpisodio.Codice
                End If

                'Ricavo tutti i possibili regimi
                Dim regimi = LookupManager.GetRegime()

                ' Restituisco gli item con cui popolare la combo dei regimi a seconda dei vari casi
                'MODIFICA ETTORE/LEO 2019-10-25: se manca il nosologico tolgo dalla lista dei regimi il DSA
                If String.IsNullOrEmpty(Nosologico) Then
                    listaRegimi = (From regime In regimi
                                   Where (regime.Key = RegimeEnum.AMB.ToString OrElse
                                         regime.Key = RegimeEnum.LP.ToString OrElse
                                         regime.Key = RegimeEnum.SCR.ToString)
                                   Select regime
                                   Order By regime.Value).ToList()
                ElseIf TipoEpisodio.ToUpper = "A" Then
                    listaRegimi = (From regime In regimi
                                   Where (regime.Key = RegimeEnum.AMB.ToString OrElse
                                         regime.Key = RegimeEnum.DSA.ToString OrElse
                                         regime.Key = RegimeEnum.LP.ToString OrElse
                                         regime.Key = RegimeEnum.SCR.ToString)
                                   Select regime
                                   Order By regime.Value).ToList()

                Else
                    listaRegimi = regimi.Where(Function(e) e.Key = RegimeCorrente).Distinct().ToList()
                End If

            Catch ex As FaultException(Of DataFault)

                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return listaRegimi
        End Function
    End Class

    <DataObject(True)>
    Public Class OrdineTestata
        Inherits CacheDataSource(Of OttieniOrdinePerIdGuidResponse)

        Public Function OttieniOrdinePerIdGuid(IdRichiesta As String) As OttieniOrdinePerIdGuidResponse
            Dim ordineTestata As New OttieniOrdinePerIdGuidResponse

            Try
                ordineTestata = Me.CacheData

                If ordineTestata Is Nothing Then
                    Dim userData = UserDataManager.GetUserData()
                    Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                        Dim request = New OttieniOrdinePerIdGuidRequest(userData.Token, IdRichiesta)
                        Dim resp = webService.OttieniOrdinePerIdGuid(request)
                        ordineTestata = resp
                        Me.CacheData = resp
                    End Using
                End If

            Catch ex As Exception
                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Return Nothing
            End Try

            Return ordineTestata
        End Function
    End Class

    <DataObject(True)>
    Public Class OrdiniPianificati
        Inherits CacheDataSource(Of List(Of OrdinePianificato))

        ''' <summary>
        ''' Restituisce la lista degli ordini PROGRAMMATI
        ''' </summary>
        ''' <param name="Uo"></param>
        ''' <param name="Nosologico"></param>
        ''' <param name="Cognome"></param>
        ''' <param name="Nome"></param>
        ''' <param name="DataNascita"></param>
        ''' <param name="SistemaErogante"></param>
        ''' <param name="DataPrenotazioneDal"></param>
        ''' <param name="DataPrenotazioneAl"></param>
        ''' <param name="AziendaErogante"></param>
        ''' <param name="IdPaziente"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Uo As String, Nosologico As String, Cognome As String, Nome As String, DataNascita As String, SistemaErogante As String, DataPrenotazioneDal As String, DataPrenotazioneAl As String, Optional ByVal AziendaErogante As String = "", Optional ByVal IdPaziente As String = "") As List(Of OrdinePianificato)

            'Creo una nuova lista di reparti.
            Dim pazienti As List(Of OrdinePianificato)
            Try
                'Controllo se la lista è già in cache.
                pazienti = Me.CacheData

                'se pazienti è null allora rieseguo la query.
                If pazienti Is Nothing Then

                    Try
                        Dim ordini As OrdineListaType() = Nothing

                        'Ottengo i dati dell'utente.
                        Dim userData = UserDataManager.GetUserData()

                        Dim filter = HttpContext.Current.Request("mode")

                        'Controllo se la dataNascita esiste ed è valida.
                        Dim dataDiNascita As DateTime?
                        If Not String.IsNullOrEmpty(DataNascita) Then
                            Dim dataTester As DateTime
                            If DateTime.TryParse(DataNascita, dataTester) Then
                                dataDiNascita = DataNascita
                            End If
                        End If

                        'Controllo se la dataPrenotazioneDal esiste ed è valida.
                        Dim dataDal As Date = Date.Today
                        If Not String.IsNullOrEmpty(DataPrenotazioneDal) Then
                            Dim dataTemp As DateTime
                            If DateTime.TryParse(DataPrenotazioneDal, dataTemp) Then
                                dataDal = DataPrenotazioneDal
                            End If
                        End If

                        'Controllo se la dataPrenotazioneAl esiste ed è valida.
                        Dim dataAl As Date
                        If Not String.IsNullOrEmpty(DataPrenotazioneAl) Then
                            Dim dataTemp As DateTime
                            If DateTime.TryParse(DataPrenotazioneAl, dataTemp) Then
                                dataAl = DataPrenotazioneAl
                                dataAl = dataAl.AddDays(+1).AddSeconds(-1)
                            End If
                        Else
                            ' TODO: KYRY --> Non potendo passare nullo stimo una data abbastanza futura (30 giorni da oggi) 
                            '                ma non eccessivamente per via dell'aggioranmento ogni minuto.
                            dataAl = DateTime.Today.AddDays(30)
                        End If

                        'Chiamate al WS.
                        Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                            If Not String.IsNullOrEmpty(IdPaziente) Then
                                Dim request = New CercaOrdiniPerPazienteRequest(userData.Token, dataDal, dataAl, IdPaziente)
                                ordini = webService.CercaOrdiniPerPaziente(request).CercaOrdiniPerPazienteResult.ToArray
                            Else

                                '14/05/2020 Leo: Aggiunta lista di unità operative
                                Dim uoList = New List(Of StrutturaType)()
                                If String.IsNullOrEmpty(Uo) Then 'mostro tutte le UO
                                    Dim cds As New CustomDataSource.UnitaOperative
                                    Dim uos = cds.GetData()
                                    If uos IsNot Nothing AndAlso uos.Count > 0 Then
                                        For Each unita In uos
                                            uoList.Add(New StrutturaType() With
                                                       {
                                                             .Azienda = New CodiceDescrizioneType() With {.Codice = unita.CodiceAzienda},
                                                             .UnitaOperativa = New CodiceDescrizioneType() With {.Codice = unita.CodiceUO.Substring(unita.CodiceUO.IndexOf("-") + 1)}
                                                       })
                                        Next
                                    Else
                                        '
                                        'l'utente non ha i permessi sulle UO quindi mostro un messaggio di errore.
                                        '
                                        Throw New ApplicationException("Per il ruolo corrente non sono state configurate le Unità Operative. Contattare l'amministratore.")
                                    End If

                                Else 'solo la UO selezionata
                                    uoList.Add(New StrutturaType() With
                                              {
                                               .Azienda = New CodiceDescrizioneType() With {.Codice = Uo.Split("-")(0)},
                                               .UnitaOperativa = New CodiceDescrizioneType() With {.Codice = Uo.Substring(Uo.IndexOf("-") + 1)}
                                              })
                                End If
                                '

                                Dim azienda As String = Nothing
                                Dim sistema As String = Nothing

                                If Not String.IsNullOrEmpty(SistemaErogante) Then
                                    Dim sSplitted = SistemaErogante.Split(LookupManager.Separator)
                                    azienda = sSplitted(0)
                                    sistema = sSplitted(1)
                                ElseIf String.IsNullOrEmpty(SistemaErogante) AndAlso (Not String.IsNullOrEmpty(AziendaErogante)) Then
                                    azienda = AziendaErogante
                                End If

                                Dim sNosologico As String = Nothing
                                If Not String.IsNullOrEmpty(Nosologico) Then sNosologico = Nosologico
                                Dim sCognome As String = Nothing
                                If Not String.IsNullOrEmpty(Cognome) Then sCognome = Cognome
                                Dim sNome As String = Nothing
                                If Not String.IsNullOrEmpty(Nome) Then sNome = Nome

                                Dim request = New CercaOrdiniPerStatoPianificatoRequest(userData.Token, dataDal, dataAl, Nothing, azienda, sistema, uoList, sNosologico, sCognome, sNome, dataDiNascita, Nothing, 151)
                                ordini = webService.CercaOrdiniPerStatoPianificato(request).CercaOrdiniPerStatoPianificatoResult.ToArray

                            End If

                        End Using

                        If ordini IsNot Nothing AndAlso ordini.Count > 0 Then

                            pazienti = New List(Of OrdinePianificato)

                            'Per ogni ordine ottengo i suoi pazienti.
                            For Each ordine In ordini


                                If ordine.Paziente IsNot Nothing _
                                    AndAlso (ordine.Paziente.IdSac IsNot Nothing OrElse Not String.IsNullOrEmpty(ordine.Paziente.IdSac)) _
                                    AndAlso Not String.IsNullOrEmpty(ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice) _
                                    AndAlso Not String.IsNullOrEmpty(ordine.UnitaOperativaRichiedente.Azienda.Codice) Then

                                    Dim sDataPrenotazioneRichiesta As String = ""
                                    Dim sDataPrenotazioneErogante As String = ""

                                    ' Data Prenmotazione Richiesta --> Data preferita  in interfaccia
                                    If ordine.DataPrenotazioneRichiesta.HasValue Then
                                        sDataPrenotazioneRichiesta = ordine.DataPrenotazioneRichiesta.Value.ToString("g")
                                    End If

                                    '
                                    ' Data Prenotazione Erogante --> Data Programmata in interfaccia
                                    '
                                    If ordine.DataPianificazioneErogante.HasValue Then
                                        sDataPrenotazioneErogante = ordine.DataPianificazioneErogante.Value.ToString("g")

                                        ' Se la data pianificazione non è valorizzata allora uso la data prenotazione
                                    ElseIf ordine.DataPrenotazioneErogante.HasValue Then
                                        sDataPrenotazioneErogante = ordine.DataPrenotazioneErogante.Value.ToString("g")
                                    End If

                                    ' Se invece entrambe sono valorizzate, prendo la più vecchia delle due
                                    If ordine.DataPianificazioneErogante.HasValue AndAlso ordine.DataPrenotazioneErogante.HasValue Then
                                        Dim compareDatesResult = DateTime.Compare(ordine.DataPianificazioneErogante.Value, ordine.DataPrenotazioneErogante.Value)
                                        If compareDatesResult < 0 Then
                                            sDataPrenotazioneErogante = ordine.DataPianificazioneErogante.Value.ToString("g")
                                        Else
                                            sDataPrenotazioneErogante = ordine.DataPrenotazioneErogante.Value.ToString("g")
                                        End If
                                    End If


                                    pazienti.Add(New OrdinePianificato() With {
                                        .Uo = ordine.UnitaOperativaRichiedente.Azienda.Codice & "-" & ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice,
                                        .CodiceAzienda = ordine.UnitaOperativaRichiedente.Azienda.Codice,
                                        .CodiceReparto = ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice,
                                        .DescrizioneReparto = If(String.IsNullOrEmpty(ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione), ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice, ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione),
                                        .Ordine = New Ordine() With {
                                                    .Id = ordine.IdGuidOrderEntry.ToLower(),
                                                    .DataRichiesta = ordine.DataRichiesta.ToString("g"),
                                                    .AnteprimaPrestazioni = ordine.AnteprimaPrestazioni,
                                                    .NumeroOrdine = ordine.IdRichiestaOrderEntry,
                                                    .StatoOrderEntryDescrizione = ordine.DescrizioneStato.ToString(),
                                                    .SistemaRichiedente = String.Format("{0}-{1}", ordine.SistemaRichiedente.Azienda.Codice, ordine.SistemaRichiedente.Sistema.Codice),
                                                    .IdRichiestaRichiedente = ordine.IdRichiestaRichiedente,
                                                    .DatiAnagraficiPaziente = String.Format("{0} {1} ({2})<br />{3:d}<br />{4}", ordine.Paziente.Cognome, ordine.Paziente.Nome, ordine.Paziente.Sesso, ordine.Paziente.DataNascita, ordine.NumeroNosologico),
                                                    .CodiceAnagrafica = ordine.Paziente.AnagraficaCodice,
                                                    .PazienteIdSac = ordine.Paziente.IdSac,
                                                    .Eroganti = If(String.IsNullOrEmpty(ordine.SistemiEroganti), "-", String.Join(", ", ordine.SistemiEroganti.Split(";"c)).Replace("@", "-").TrimEnd(New Char() {","c, " "c})),
                                                    .NumeroNosologico = ordine.NumeroNosologico,
                                                    .InfoRicovero = Utility.GetInfoRicovero(ordine.UnitaOperativaRichiedente.Azienda.Codice, ordine.NumeroNosologico),
                                                    .UnitaOperativa = String.Format("{0}-{1}", ordine.UnitaOperativaRichiedente.Azienda.Codice, If(String.IsNullOrEmpty(ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione), ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice, ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione)),
                                                    .UO = ordine.UnitaOperativaRichiedente.Azienda.Codice & "-" & ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice,
                                                    .Utente = If(ordine.Operatore Is Nothing, "---", If(String.IsNullOrEmpty(ordine.Operatore.Nome) AndAlso String.IsNullOrEmpty(ordine.Operatore.Cognome), ordine.Operatore.ID, ordine.Operatore.Nome & " " & ordine.Operatore.Cognome)),
                                                    .Priorita = If(String.IsNullOrEmpty(ordine.Priorita.Descrizione), LookupManager.GetPriorita()(ordine.Priorita.Codice), ordine.Priorita.Descrizione),
                                                    .Valido = ordine.StatoValidazione.Stato = StatoValidazioneEnum.AA,
                                                    .DescrizioneStatoValidazione = ordine.StatoValidazione.Descrizione},
                                        .DataPreferita = sDataPrenotazioneRichiesta,
                                        .DataProgrammata = sDataPrenotazioneErogante
                                         })


                                End If

                            Next

                        End If

                    Catch ex As FaultException(Of DataFault)
                        Throw New Exception(ex.Detail.Message)

                    Catch ex As Exception
                        ExceptionsManager.TraceException(ex)
                        Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                        portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                        Throw
                    End Try

                    Me.CacheData = pazienti
                End If

            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Throw
            End Try

            'Return
            Return pazienti

        End Function

    End Class

#Region "GenericClasses"
    Public Class Reparto
        Public Property CodiceAzienda() As String

        Public Property Codice() As String

        Public Property Descrizione() As String

        Public Property Pazienti() As List(Of Paziente)
    End Class

    Public Class Paziente
        Public Property Id() As String

        Public Property DatiAnagraficiPaziente() As String

        Public Property Uo() As String

        Public Property Ordini() As List(Of Ordine)
    End Class

    Public Class Ordine
        Public Property Id() As String
        Public Property DataRichiesta() As String
        Public Property AnteprimaPrestazioni() As String
        Public Property NumeroOrdine() As String
        Public Property StatoOrderEntryDescrizione() As String
        Public Property SistemaRichiedente() As String
        Public Property IdRichiestaRichiedente() As String
        Public Property DatiAnagraficiPaziente() As String
        Public Property CodiceAnagrafica() As String
        Public Property DataPrenotazione() As String
        Public Property PazienteIdSac() As String
        Public Property Eroganti() As String
        Public Property NumeroNosologico() As String
        Public Property InfoRicovero() As String
        Public Property UnitaOperativa() As String
        Public Property UO() As String
        Public Property Utente() As String
        Public Property Priorita() As String
        Public Property Valido() As Boolean
        Public Property DescrizioneStatoValidazione() As String
    End Class

    'Classi per la pagina Lista Ordini Pianificati
    'Paziente per tal ordine e di tal reparto (Uo, CodiceAzienda, CodiceReparto, DescrizioneReparto fanno riferimento al reparto dell'ordine )
    Public Class OrdinePianificato

        Public Property Uo() As String

        Public Property CodiceAzienda() As String

        Public Property CodiceReparto() As String

        Public Property DescrizioneReparto() As String

        Public Property Ordine() As Ordine

        Public Property DataPreferita As String

        Public Property DataProgrammata As String

    End Class

    Public Class Prestazione
        Public Property Id As String
        Public Property Codice As String
        Public Property Descrizione As String
        Public Property CodiceErogante As String
        Public Property SistemaErogante As String
        Public Property Valido As String
        Public Property DescrizioneStatoValidazione As String
        Public Property DatiAccessori As DatiAggiuntiviType
        Public Property Tipo As TipoPrestazioneErogabileEnum
    End Class
#End Region

End Class
