Imports System.ComponentModel
Imports System.Web.Configuration

Namespace CustomDataSource

#Region "AccessoStandard"
    <DataObjectAttribute()>
    Public Class PazientiCercaPerGeneralita
        Inherits CacheDataSource(Of List(Of WcfDwhClinico.PazienteListaType))

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, Cognome As String, Nome As String, AnnoNascita As Integer?) As List(Of WcfDwhClinico.PazienteListaType)
            Const MAX_NUM_RECORD As Integer = 1000
            Dim oPazienti As List(Of WcfDwhClinico.PazienteListaType)
            '
            ' Cerco prima nella cache
            '
            oPazienti = Me.CacheData
            If oPazienti Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)
                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oPazientiReturn As WcfDwhClinico.PazientiReturn = oWcf.PazientiCercaPerGeneralita(Token, MAX_NUM_RECORD, Ordinamento, Cognome, Nome, Nothing, AnnoNascita, Nothing)
                    If oPazientiReturn IsNot Nothing Then
                        If oPazientiReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista pazienti.", oPazientiReturn.Errore)
                        Else
                            oPazienti = oPazientiReturn.Pazienti
                        End If
                    End If
                End Using
                If Not oPazienti Is Nothing AndAlso oPazienti.Count > 0 Then
                    'ATTENZIONE: l'ordinamento basato sulle stringhe è CASE SENSITIVE, per questo è stato aggiunto il ToUpper
                    'L'ordinamento sulle date funziona correttamente anche se vuote (il null/nothing viene messo per ultimo)
                    oPazienti = (From c In oPazienti Order By c.Cognome.ToUpper, c.Nome.ToUpper, c.DataNascita).ToList
                End If
                '
                ' Salvo nella cache
                '
                Me.CacheData = oPazienti
            End If
            Return oPazienti
        End Function
    End Class

    <DataObjectAttribute()>
    Public Class PazienteOttieniPerId
        Inherits CacheDataSource(Of WcfDwhClinico.PazienteType)

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, idPaziente As Guid) As WcfDwhClinico.PazienteType
            Dim user As String = HttpContext.Current.User.Identity.Name
            Dim oPazienti As WcfDwhClinico.PazienteType

            '
            ' In questo caso creo una custom key NON basata sull' HashCode della pagina perchè la cache di questo DataSource deve essere condiviso da più pagine.
            '
            CacheDataKey = String.Format("{0}_PazienteOttieniPerId_{1}_{2}", user.ToUpper, idPaziente.ToString.ToUpper, Me.GetType)

            '
            ' Cerco prima nella cache
            '
            oPazienti = Me.CacheData
            If oPazienti Is Nothing Then
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)
                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oPazientiReturn As WcfDwhClinico.PazienteReturn = oWcf.PazienteOttieniPerId(Token, idPaziente, False)
                    If oPazientiReturn IsNot Nothing Then
                        If oPazientiReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista pazienti.", oPazientiReturn.Errore)
                        Else
                            oPazienti = oPazientiReturn.Paziente
                        End If
                    End If
                End Using
                '
                ' Salvo nella cache
                '
                Me.CacheData = oPazienti
            End If
            Return oPazienti
        End Function

        ''' <summary>
        ''' Metodo base DA NON UTILIZZARE --> utilizzare quello custom che usa il parametro idPaziente
        ''' </summary>
        Public Overloads Sub ClearCache()

            Throw New NotImplementedException

        End Sub

        ''' <summary>
        ''' Metodo custum per cancellare la cache dell'ObjectDataSource in base sull'Id del paziente.
        ''' </summary>
        ''' <param name="idPaziente"></param>
        Public Overloads Sub ClearCache(idPaziente As Guid)
            Dim user As String = HttpContext.Current.User.Identity.Name
            CacheDataKey = String.Format("{0}_PazienteOttieniPerId_{1}_{2}", user.ToUpper, idPaziente.ToString.ToUpper, Me.GetType)
            MyBase.ClearCache()
        End Sub
    End Class

    <DataObjectAttribute()>
    Public Class RefertiCercaPerIdPaziente
        Inherits CacheDataSource(Of List(Of WcfDwhClinico.RefertoListaType))

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, IdPaziente As Guid, DallaData As Date, ByPassaConsenso As Boolean, AllaData As Date?, lstFiltriTipiReferto As List(Of String)) As List(Of WcfDwhClinico.RefertoListaType)
            Const MAX_NUM_RECORD As Integer = 1000
            Dim oReferti As List(Of WcfDwhClinico.RefertoListaType)

            '
            ' In questo caso creo una custom key NON basata sull' HashCode della pagina perchè la cache di questo DataSource deve essere condiviso da più pagine.
            '
            CacheDataKey = GetCacheKey(IdPaziente)

            '
            ' Cerco prima nella cache
            '
            oReferti = Me.CacheData

            If oReferti Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)
                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oRefertiReturn As WcfDwhClinico.RefertiReturn = oWcf.RefertiCercaPerIdPaziente(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, IdPaziente, DallaData, AllaData, Nothing, Nothing, Nothing, Nothing)
                    If oRefertiReturn IsNot Nothing Then
                        If oRefertiReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista dei referti.", oRefertiReturn.Errore)
                        Else
                            oReferti = oRefertiReturn.Referti
                        End If
                    End If
                End Using
                If Not oReferti Is Nothing AndAlso oReferti.Count > 0 Then
                    '
                    ' Tolgo dalla lista dei referti i referti singoli( visualizzati in una tab a parte)
                    '
                    Dim queryReferti = Filtri.EsclusioneRefertiSingoli(oReferti)
                    oReferti = queryReferti
                End If

                '
                ' Salvo nella cache la lista dei referti senza i referti singoli
                '
                Me.CacheData = oReferti
            End If


            If Not oReferti Is Nothing AndAlso oReferti.Count > 0 Then
                '
                ' Filtro anche per la lista dei tipi di referto selezionati
                '
                If lstFiltriTipiReferto IsNot Nothing AndAlso lstFiltriTipiReferto.Count > 0 Then
                    'OTTENGO LA LISTA DEI TIPI REFERTI SPLITTANDO QUELLI CHE SONO COMPOSTI. 
                    '(ALCUNI ITEM DI LSTFILTRITIPIREFERTI SONO COMPOSTI DA PIÙ ID SEPARATI DA; PER EVITARE DI AVERE PIÙ ITEM NELLA LISTA DEI FILTRI LATERALI CON LA STESSA DESCRIZIONE)
                    Dim oLstFiltriTipiReferto As List(Of String) = Filtri.OttieniListaFiltriTipiReferti(lstFiltriTipiReferto)

                    Dim query = (From c In oReferti Where oLstFiltriTipiReferto.Contains(c.IdTipoReferto)).ToList
                    oReferti = query
                End If
            End If
            Return oReferti
        End Function

        ''' <summary>
        ''' Restituisce la lista dei tipi di referto
        ''' Deve essere eseguito dopo la funzione GetData perchè filtra la lista ottenuta dalla cache
        ''' </summary>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetSelectedTipiReferto(IdPaziente As Guid) As IEnumerable

            '
            ' In questo caso creo una custom key NON basata sull' HashCode della pagina. Uso l'id paziente per recuperare la cache condivisa
            '
            CacheDataKey = GetCacheKey(IdPaziente)

            Dim listaReferti As List(Of WcfDwhClinico.RefertoListaType) = Me.CacheData
            Dim ds As New DizionarioTipiRefertoOttieni
            Dim listaIcone As WcfDwhClinico.DizionarioTipiRefertoListaType = ds.GetData()
            If listaReferti Is Nothing Then
                Return Nothing
            End If

            '
            ' Ottengo il distinct della lista dei referti per ottenere i  tipi referto.
            '
            Dim filtriTipoReferto = (From c In listaReferti
                                     Select c.IdTipoReferto Where IdTipoReferto <> Nothing).Distinct

            Dim oReturn = Filtri.OttieniListaTipiReferti(listaIcone, filtriTipoReferto)

            Return oReturn
        End Function

        ''' <summary>
        ''' Metodo base DA NON UTILIZZARE --> utilizzare quello custom che usa il parametro idPaziente
        ''' </summary>
        Public Overloads Sub ClearCache()

            Throw New NotImplementedException

        End Sub

        ''' <summary>
        ''' Metodo custum per cancellare la cache dell'ObjectDataSource in base sull'Id del paziente.
        ''' </summary>
        ''' <param name="idPaziente"></param>
        Public Overloads Sub ClearCache(idPaziente As Guid)
            CacheDataKey = GetCacheKey(idPaziente)
            MyBase.ClearCache()
        End Sub


        ''' <summary>
        '''  Imposta lo stato di un referto a visionato nella Cache dei referti, per togliere l'evidenziamento dei referti nuovi
        ''' </summary>
        ''' <param name="idReferto"></param>
        ''' <param name="idPaziente"></param>
        Public Sub ImpostaRefertoVisionato(idReferto As Guid, idPaziente As Guid)

            Dim user As String = HttpContext.Current.User.Identity.Name

            '
            ' In questo caso creo una custom key NON basata sull' HashCode della pagina perchè la cache di questo DataSource deve essere condiviso da più pagine.
            '
            CacheDataKey = GetCacheKey(idPaziente)


            If Me.CacheData IsNot Nothing Then

                ' Imposto il referto in cache a visionato
                Dim refertoVariato As WcfDwhClinico.RefertoListaType = Me.CacheData.Where(Function(x) x.Id = idReferto.ToString().ToUpper()).FirstOrDefault()
                If refertoVariato IsNot Nothing Then

                    refertoVariato.Visionato = True
                End If
            End If

        End Sub

        ''' <summary>
        ''' Ottiene la key per la cache da usare all'interno della classe
        ''' </summary>
        ''' <param name="idPaziente"></param>
        ''' <returns></returns>
        Private Function GetCacheKey(idPaziente As Guid) As String
            Dim user As String = HttpContext.Current.User.Identity.Name

            Return $"{user.ToUpper}_RefertiCercaPerIdPaziente_{idPaziente.ToString().ToUpper()}_{Me.GetType}"

        End Function

    End Class

    <DataObjectAttribute()>
    Public Class RefertoPdfOttieniPerId

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, IdReferto As Guid, Modalita As WcfDwhClinico.RefertoPdfModalitaEnum) As WcfDwhClinico.AllegatiPdfType
            Dim oAllegati As WcfDwhClinico.AllegatiPdfType = Nothing

            '
            ' Recupero dati dal WS
            '
            Using oWcf As New WcfDwhClinico.ServiceClient
                Call Utility.SetWcfDwhClinicoCredential(oWcf)
                '
                ' Chiamata al metodo che restituisce i dati
                '
                Dim oRefertoPdfReturn As WcfDwhClinico.RefertoPdfReturn = oWcf.RefertoPdfOttieniPerId(Token, IdReferto, Modalita)
                If oRefertoPdfReturn IsNot Nothing Then
                    If oRefertoPdfReturn.Errore IsNot Nothing Then
                        Throw New WsDwhException("Si è verificato un errore durante la lettura dei pdf del referto.", oRefertoPdfReturn.Errore)
                    Else
                        If Not oRefertoPdfReturn.RefertoPdf Is Nothing Then
                            oAllegati = oRefertoPdfReturn.RefertoPdf.AllegatiPdf
                        End If
                    End If
                End If
            End Using
            Return oAllegati
        End Function
    End Class

    <DataObjectAttribute()>
    Public Class EpisodiCercaPerIdPaziente
        Inherits CacheDataSource(Of List(Of WcfDwhClinico.EpisodioListaType))

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, IdPaziente As Guid, ByPassaConsenso As Boolean, DallaData As Date, AllaData As Date?) As List(Of WcfDwhClinico.EpisodioListaType)
            Const MAX_NUM_RECORD As Integer = 1000
            Dim oEpisodi As List(Of WcfDwhClinico.EpisodioListaType)
            '
            ' Impostazione di un nome custum per la key della cache
            '
            Me.CacheDataKey = String.Format("{0}-EpisodiCercaPerIdPaziente-{1}", OriginalCacheDatakey, IdPaziente.ToString.ToUpper)
            '
            ' Cerco prima nella cache
            '
            oEpisodi = Me.CacheData
            If oEpisodi Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)
                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oEpisodiReturn As WcfDwhClinico.EpisodiReturn = oWcf.EpisodiCercaPerIdPaziente(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, IdPaziente, DallaData, AllaData)
                    If oEpisodiReturn IsNot Nothing Then
                        If oEpisodiReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista degli episodi.", oEpisodiReturn.Errore)
                        Else
                            oEpisodi = oEpisodiReturn.Episodi
                        End If
                    End If
                End Using


                If Not oEpisodi Is Nothing Then
                    '
                    ' Tolgo dalla lista degli episodi le prenotazioni nello stato ricoverato = 22
                    '
                    Dim queryEpisodi As List(Of WcfDwhClinico.EpisodioListaType) = (From c In oEpisodi Where c.StatoCodice <> "22").ToList
                    oEpisodi = queryEpisodi
                End If


                '
                ' Salvo nella cache
                '
                Me.CacheData = oEpisodi
            End If

            Return oEpisodi

        End Function

        ''' <summary>
        ''' Metodo base DA NON UTILIZZARE --> utilizzare quello custom che usa il parametro idPaziente
        ''' </summary>
        Public Overloads Sub ClearCache()

            Throw New NotImplementedException

        End Sub

        Public Overloads Sub ClearCache(idPaziente As Guid)
            Me.CacheDataKey = String.Format("{0}-EpisodiCercaPerIdPaziente-{1}", OriginalCacheDatakey, idPaziente.ToString.ToUpper)
            MyBase.ClearCache()
        End Sub

    End Class

    <DataObjectAttribute()>
    Public Class EventiEpisodioCercaPerId
        Inherits CacheDataSource(Of WcfDwhClinico.EventiType)

        ''' <summary>
        ''' Restituisce la lista degli eventi in base all'id dell'episodio
        ''' Sfrutta la cache della classe EpisodiCercaPerIdPaziente per ottenere la lista
        ''' </summary>
        ''' <param name="Token"></param>
        ''' <param name="IdRicovero"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, IdRicovero As Guid) As WcfDwhClinico.EventiType
            Dim oEventiEpisodio As WcfDwhClinico.EventiType
            '
            ' Cerco prima nella cache
            '
            oEventiEpisodio = Me.CacheData
            If oEventiEpisodio Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)
                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oEpisodioReturn As WcfDwhClinico.EpisodioReturn = oWcf.EpisodioOttieniPerId(Token, IdRicovero)

                    If oEpisodioReturn IsNot Nothing Then
                        If oEpisodioReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista degli eventi dell'episodio.", oEpisodioReturn.Errore)
                        End If
                        '
                        ' MODIFICA ETTORE 2017-05-17: aggiunta l'elenco degli eventi di prenotazione dell'eventuale nosologico di lista di attesa associato al corrente nosologico
                        '
                        Dim oEpisodio As WcfDwhClinico.EpisodioType = oEpisodioReturn.Episodio
                        If Not oEpisodio Is Nothing Then
                            '
                            ' Memorizzo la lista di eventi dell'episodio
                            '
                            oEventiEpisodio = oEpisodio.Eventi
                            '
                            ' MODIFICA ETTORE 2017-05-17: aggiunta l'elenco degli eventi di prenotazione dell'eventuale nosologico di lista di attesa associato al corrente nosologico
                            '
                            Dim oEventoPrenotazioneOttieniPerIdRIcovero As New CustomDataSource.EventoPrenotazioneOttieniPerIdRicovero
                            Dim oEventoPrenotazione As WcfDwhClinico.EventoType = oEventoPrenotazioneOttieniPerIdRIcovero.GetData(Token, oEpisodio)
                            If oEventoPrenotazione IsNot Nothing Then
                                '
                                ' Aggiungo l'evento dui prenotazione come primo elemento della lista degli eventi dell'episodio di ricovero
                                '
                                oEventiEpisodio.Insert(0, oEventoPrenotazione)
                            End If
                        End If 'If Not oEpisodio Is Nothing
                    End If 'If oEpisodioReturn IsNot Nothing
                End Using
                '
                ' Salvo nella cache
                '
                Me.CacheData = oEventiEpisodio
            End If

            Return oEventiEpisodio

        End Function

    End Class

    <DataObjectAttribute()>
    Public Class PrescrizioniCercaPerIdPaziente
        Inherits CacheDataSource(Of List(Of WcfDwhClinico.PrescrizioneListaType))

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, IdPaziente As Guid, DallaData As Date, ByPassaConsenso As Boolean, AllaData As Date?, lstFiltriTipiPrescrizione As List(Of String)) As List(Of WcfDwhClinico.PrescrizioneListaType)
            Const MAX_NUM_RECORD As Integer = 1000
            '
            ' Implementazione di una custom cache key
            '
            'Me.CacheDataKey = String.Format("{0}-PrescrizioniCercaPerIdPaziente-{1}", OriginalCacheDatakey, IdPaziente.ToString.ToUpper)

            Dim oPrescrizioni As List(Of WcfDwhClinico.PrescrizioneListaType)
            '
            ' Cerco prima nella cache
            '
            oPrescrizioni = Me.CacheData
            If oPrescrizioni Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)
                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oPrescrizioniReturn As WcfDwhClinico.PrescrizioniReturn = oWcf.PrescrizioniCercaPerIdPaziente(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, IdPaziente, DallaData, AllaData)

                    If oPrescrizioniReturn IsNot Nothing Then
                        If oPrescrizioniReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista delle prescrizioni.", oPrescrizioniReturn.Errore)
                        Else
                            oPrescrizioni = oPrescrizioniReturn.Prescrizioni
                        End If
                    End If
                End Using
                '
                ' Salvo nella cache
                '
                Me.CacheData = oPrescrizioni
            End If
            If lstFiltriTipiPrescrizione IsNot Nothing AndAlso lstFiltriTipiPrescrizione.Count > 0 Then
                Dim query = (From c In oPrescrizioni Where lstFiltriTipiPrescrizione.Contains(c.TipoPrescrizione)).ToList
                oPrescrizioni = query
            End If
            Return oPrescrizioni

        End Function

        'Public Overloads Sub ClearCache(idPaziente As Guid)
        '    Me.CacheDataKey = String.Format("{0}-PrescrizioniCercaPerIdPaziente-{1}", OriginalCacheDatakey, idPaziente.ToString.ToUpper)
        '    MyBase.ClearCache()
        'End Sub


        ''' <summary>
        ''' Restituisce la lista dei tipi di referto
        ''' Deve essere eseguito dopo la funzione GetData perchè filtra la lista ottenuta dalla cache
        ''' </summary>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetSelectedTipiPrescrizione() As IEnumerable
            Dim listaPrescrizioni As List(Of WcfDwhClinico.PrescrizioneListaType) = Me.CacheData
            If listaPrescrizioni Is Nothing Then
                Return Nothing
            End If
            Dim filtriTipoReferto = (From c In listaPrescrizioni
                                     Order By c.TipoPrescrizione
                                     Select c.TipoPrescrizione Where TipoPrescrizione <> Nothing).Distinct
            Return filtriTipoReferto
        End Function
    End Class

    <DataObjectAttribute()>
    Public Class PazientiRicoveratiCercaPerReparti
        Inherits CacheDataSource(Of List(Of WcfDwhClinico.PazienteListaType))

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, UnitaOperative As WcfDwhClinico.RepartiParam, TipoEpisodioCodice As String, Stato As Byte, Cognome As String, Nome As String, NumeroNosologico As String, maxNumRecord As Integer) As List(Of WcfDwhClinico.PazienteListaType)
            'Const MAX_NUM_RECORD As Integer = 1000
            Dim oPazienti As List(Of WcfDwhClinico.PazienteListaType)
            '
            ' Cerco prima nella cache
            '
            oPazienti = Me.CacheData

            If oPazienti Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)

                    '
                    ' Chiamata al metodo che restituisce i dati

                    Dim oPazientiReturn As WcfDwhClinico.PazientiReturn

                    Dim EnumStato As WcfDwhClinico.StatoRicoveroEnum = CType(Stato, WcfDwhClinico.StatoRicoveroEnum)
                    If EnumStato = 4 Then
                        '
                        ' Se EnumStato = 4 allora cerco tra i pazienti trasferiti
                        '
                        oPazientiReturn = oWcf.PazientiTrasferitiCercaPerReparti(Token, maxNumRecord, Ordinamento, UnitaOperative, TipoEpisodioCodice, Nothing, Nothing, Cognome, Nothing, Nothing, Nothing, Nothing, Nothing, NumeroNosologico)
                    Else
                        '
                        ' Se EnumStato <> 4 allora cerco tra i pazienti ricoverati
                        '
                        oPazientiReturn = oWcf.PazientiRicoveratiCercaPerReparti(Token, maxNumRecord, Ordinamento, UnitaOperative, EnumStato, TipoEpisodioCodice, Nothing, Nothing, Nothing, Nothing, Cognome, Nome, Nothing, Nothing, Nothing, Nothing, NumeroNosologico)
                    End If



                    If oPazientiReturn IsNot Nothing Then
                        If oPazientiReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista pazienti.", oPazientiReturn.Errore)
                        Else
                            oPazienti = oPazientiReturn.Pazienti
                        End If
                    End If
                End Using
                If Not oPazienti Is Nothing AndAlso oPazienti.Count > 0 Then
                    'ATTENZIONE: l'ordinamento basato sulle stringhe è CASE SENSITIVE, per questo è stato aggiunto il ToUpper
                    'L'ordinamento sulle date funziona correttamente anche se vuote (il null/nothing viene messo per ultimo)
                    oPazienti = (From c In oPazienti Order By c.Cognome.ToUpper, c.Nome.ToUpper, c.DataNascita).ToList
                End If
                '
                ' Salvo nella cache
                '
                Me.CacheData = oPazienti

            End If

            Return oPazienti

        End Function

    End Class

    <DataObjectAttribute()>
    Public Class MatricePrestazioniLabCercaPerIdPaziente
        Inherits CacheDataSource(Of WcfDwhClinico.MatricePrestazioniListaType)

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, IdPaziente As Guid, DallaData As Date, AllaData As Date?, ByPassaConsenso As Boolean, PrestazioneCodice As String, SezioneCodice As String) As WcfDwhClinico.MatricePrestazioniListaType
            Const MAX_NUM_RECORD As Integer = 1000
            '
            ' Implementazione di una custom key
            '
            Me.CacheDataKey = String.Format("{0}-MatricePrestazioniLabCercaPerIdPaziente-{1}", OriginalCacheDatakey, IdPaziente.ToString.ToUpper)
            Dim oMatriciPrescrizioni As WcfDwhClinico.MatricePrestazioniListaType
            '
            ' Cerco prima nella cache
            '
            oMatriciPrescrizioni = Me.CacheData
            If oMatriciPrescrizioni Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)

                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oMatricePrestazioniReturn As WcfDwhClinico.MatricePrestazioniReturn = oWcf.MatricePrestazioniLabCercaPerIdPaziente(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, IdPaziente, DallaData, AllaData, PrestazioneCodice, SezioneCodice)
                    If oMatricePrestazioniReturn IsNot Nothing Then
                        If oMatricePrestazioniReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista della matrice.", oMatricePrestazioniReturn.Errore)
                        Else
                            oMatriciPrescrizioni = oMatricePrestazioniReturn.MatricePrestazioni
                        End If
                    End If
                End Using
                '
                ' Salvo nella cache
                '
                Me.CacheData = oMatriciPrescrizioni
            End If

            Return oMatriciPrescrizioni

        End Function

        ''' <summary>
        ''' Metodo base DA NON UTILIZZARE --> utilizzare quello custom che usa il parametro idPaziente
        ''' </summary>
        Public Overloads Sub ClearCache()

            Throw New NotImplementedException

        End Sub

        Public Overloads Sub ClearCache(idPaziente As Guid)
            Me.CacheDataKey = String.Format("{0}-MatricePrestazioniLabCercaPerIdPaziente-{1}", OriginalCacheDatakey, idPaziente.ToString.ToUpper)
            MyBase.ClearCache()
        End Sub

    End Class

    <DataObjectAttribute()>
    Public Class MatricePrestazioniLabCercaPerSezioneCodice
        Inherits CacheDataSource(Of WcfDwhClinico.MatricePrestazioniListaType)

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, IdPaziente As Guid, DallaData As Date, AllaData As Date?, ByPassaConsenso As Boolean, PrestazioneCodice As String, SezioneCodice As String) As WcfDwhClinico.MatricePrestazioniListaType
            Const MAX_NUM_RECORD As Integer = 1000
            '
            ' Implementazione di una custom key
            '
            Me.CacheDataKey = String.Format("{0}-MatricePrestazioniLabCercaPerSezioneCodice-{1}-SezioneCodice_{2}", OriginalCacheDatakey, IdPaziente.ToString.ToUpper, SezioneCodice)
            Dim oMatriciPrescrizioni As WcfDwhClinico.MatricePrestazioniListaType
            '
            ' Cerco prima nella cache
            '
            oMatriciPrescrizioni = Me.CacheData
            If oMatriciPrescrizioni Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)

                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oMatricePrestazioniReturn As WcfDwhClinico.MatricePrestazioniReturn = oWcf.MatricePrestazioniLabCercaPerIdPaziente(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, IdPaziente, DallaData, AllaData, PrestazioneCodice, SezioneCodice)
                    If oMatricePrestazioniReturn IsNot Nothing Then
                        If oMatricePrestazioniReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista della matrice.", oMatricePrestazioniReturn.Errore)
                        Else
                            oMatriciPrescrizioni = oMatricePrestazioniReturn.MatricePrestazioni
                        End If
                    End If
                End Using
                '
                ' Salvo nella cache
                '
                Me.CacheData = oMatriciPrescrizioni
            End If

            Return oMatriciPrescrizioni

        End Function

        ''' <summary>
        ''' Metodo base DA NON UTILIZZARE --> utilizzare quello custom che usa il parametro idPaziente
        ''' </summary>
        Public Overloads Sub ClearCache()

            Throw New NotImplementedException

        End Sub

        Public Overloads Sub ClearCache(idPaziente As Guid, SezioneCodice As String)
            Me.CacheDataKey = String.Format("{0}-MatricePrestazioniLabCercaPerSezioneCodice-{1}-SezioneCodice_{2}", OriginalCacheDatakey, idPaziente.ToString.ToUpper, SezioneCodice)
            MyBase.ClearCache()
        End Sub

    End Class

    <DataObjectAttribute()>
    Public Class RefertiCercaPerNosologico
        Inherits CacheDataSource(Of WcfDwhClinico.RefertiListaType)

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, ByPassaConsenso As Boolean, Nosologico As String, Azienda As String, lstFiltriTipiReferto As List(Of String)) As List(Of WcfDwhClinico.RefertoListaType)


            Const MAX_NUM_RECORD As Integer = 1000

            Dim oReferti As List(Of WcfDwhClinico.RefertoListaType)

            '
            ' Esco se Nosologico e Azienda non solo valorizzati 
            '
            If String.IsNullOrEmpty(Nosologico) AndAlso String.IsNullOrEmpty(Azienda) Then
                Return Nothing
            End If


            Dim user As String = HttpContext.Current.User.Identity.Name

            '
            ' In questo caso creo una custom key formata da Azienda + Nosologico NON basata sull' HashCode della pagina 
            ' perchè la cache di questo DataSource deve essere condiviso da più pagine.
            '
            Me.CacheDataKey = GetCacheKey(Nosologico, Azienda)


            '
            ' Cerco prima nella cache
            '
            oReferti = Me.CacheData
            If oReferti Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)

                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oRefertiReturn As WcfDwhClinico.RefertiReturn = oWcf.RefertiCercaPerNosologico(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, Nosologico, Azienda)
                    If oRefertiReturn IsNot Nothing Then
                        If oRefertiReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista dei referti.", oRefertiReturn.Errore)
                        Else
                            oReferti = oRefertiReturn.Referti
                        End If
                    End If
                End Using
                '
                ' Salvo nella cache
                '
                If oReferti Is Nothing Then
                    Me.CacheData = New WcfDwhClinico.RefertiListaType
                Else
                    Me.CacheData = oReferti
                End If
            End If


            If Not oReferti Is Nothing AndAlso oReferti.Count > 0 Then
                '
                ' Filtro anche per la lista dei tipi di referto selezionati
                '
                If lstFiltriTipiReferto IsNot Nothing AndAlso lstFiltriTipiReferto.Count > 0 Then
                    'OTTENGO LA LISTA DEI TIPI REFERTI SPLITTANDO QUELLI CHE SONO COMPOSTI. 
                    '(ALCUNI ITEM DI LSTFILTRITIPIREFERTI SONO COMPOSTI DA PIÙ ID SEPARATI DA; PER EVITARE DI AVERE PIÙ ITEM NELLA LISTA DEI FILTRI LATERALI CON LA STESSA DESCRIZIONE)
                    Dim oLstFiltriTipiReferto As List(Of String) = Filtri.OttieniListaFiltriTipiReferti(lstFiltriTipiReferto)

                    Dim query = (From c In oReferti Where oLstFiltriTipiReferto.Contains(c.IdTipoReferto)).ToList
                    oReferti = query
                End If
            End If

            Return oReferti

        End Function

        ''' <summary>
        ''' Restituisce la lista dei tipi di referto
        ''' Deve essere eseguito dopo la funzione GetData perchè filtra la lista ottenuta dalla cache
        ''' </summary>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetSelectedTipiReferto(listaReferti As List(Of WcfDwhClinico.RefertoListaType)) As IEnumerable
            Dim ds As New DizionarioTipiRefertoOttieni
            Dim listaIcone As WcfDwhClinico.DizionarioTipiRefertoListaType = ds.GetData()
            If listaReferti Is Nothing Then
                Return Nothing
            End If
            '
            ' Ottengo il distinct della lista dei referti per ottenere i tipi referto.
            '
            Dim filtriTipoReferto = (From c In listaReferti
                                     Select c.IdTipoReferto Where IdTipoReferto <> Nothing).Distinct

            Dim oReturn = Filtri.OttieniListaTipiReferti(listaIcone, filtriTipoReferto)
            Return oReturn
        End Function

        ''' <summary>
        ''' Metodo base DA NON UTILIZZARE --> utilizzare quello custom che usa il parametro idPaziente
        ''' </summary>
        Public Overloads Sub ClearCache()

            Throw New NotImplementedException

        End Sub

        Public Overloads Sub ClearCache(Nosologico As String, Azienda As String)

            Dim user As String = HttpContext.Current.User.Identity.Name

            '
            ' Prima di cancellare i dati in cache rigenero la key formata da nosologico e azienda
            '
            Me.CacheDataKey = GetCacheKey(Nosologico, Azienda)
            MyBase.ClearCache()
        End Sub


        ''' <summary>
        '''  Imposta lo stato di un referto a visionato nella Cache dei Referti negli Episodi, per togliere l'evidenziamento dei referti nuovi
        ''' </summary>
        ''' <param name="Nosologico"></param>
        ''' <param name="Azienda"></param>
        Public Sub ImpostaRefertoVisionato(idRefero As Guid, nosologico As String, azienda As String)

            Dim user As String = HttpContext.Current.User.Identity.Name

            '
            ' In questo caso creo una custom key NON basata sull' HashCode della pagina perchè la cache di questo DataSource deve essere condiviso da più pagine.
            '
            Me.CacheDataKey = GetCacheKey(nosologico, azienda)


            If Me.CacheData IsNot Nothing Then

                ' Imposto il referto in cache a visionato
                Dim refertoVariato As WcfDwhClinico.RefertoListaType = Me.CacheData.Where(Function(x) x.Id = idRefero.ToString().ToUpper() And x.NumeroNosologico = nosologico And x.AziendaErogante = azienda).FirstOrDefault()
                If refertoVariato IsNot Nothing Then

                    refertoVariato.Visionato = True
                End If
            End If

        End Sub

        ''' <summary>
        ''' Ottiene la key per la cache da usare all'interno della classe
        ''' </summary>
        ''' <param name="nosologico"></param>
        ''' <param name="azienda"></param>
        ''' <returns></returns>
        Private Function GetCacheKey(nosologico As String, azienda As String) As String
            Dim user As String = HttpContext.Current.User.Identity.Name

            Return $"{user.ToUpper}_RefertiCercaPerNosologico_{nosologico}_{azienda}_{Me.GetType}"

        End Function

    End Class

    <DataObjectAttribute()>
    Public Class RefertiCercaRefertiSingoli
        Inherits CacheDataSource(Of List(Of WcfDwhClinico.RefertoListaType))

        ''' <summary>
        ''' Filtra la lista dei referti per ottenere la lista dei referti singoli
        ''' Se AziendaErogante = "AUSL",SistemaErogante = "EIM" e RepartoErogante = "VACCINAZIONI" allora il referto è un referto singolo
        ''' </summary>
        ''' <param name="Token"></param>
        ''' <param name="Ordinamento"></param>
        ''' <param name="IdPaziente"></param>
        ''' <param name="DallaData"></param>
        ''' <param name="ByPassaConsenso"></param>
        ''' <param name="AllaData"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, IdPaziente As Guid, DallaData As Date, ByPassaConsenso As Boolean, AllaData As Date?) As List(Of WcfDwhClinico.RefertoListaType)
            Const MAX_NUM_RECORD As Integer = 1000

            '
            ' creo una custom key per la cache basata sull'id
            ' altrimenti la lista dei referti e la lista dei referti singoli avrebbero la stessa cache key
            '
            CacheDataKey = String.Format("{0}_RefertiCercaRefertiSingoli_{1}", OriginalCacheDatakey, IdPaziente.ToString.ToUpper)
            Dim oRefertiSingoli As List(Of WcfDwhClinico.RefertoListaType) = Nothing
            Dim oReferti As List(Of WcfDwhClinico.RefertoListaType) = Nothing

            '
            ' Cerco prima nella cache
            '
            oRefertiSingoli = Me.CacheData
            If oRefertiSingoli Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)

                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oRefertiReturn As WcfDwhClinico.RefertiReturn = oWcf.RefertiCercaPerIdPaziente(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, IdPaziente, DallaData, AllaData, Nothing, Nothing, Nothing, Nothing)
                    If oRefertiReturn IsNot Nothing Then
                        If oRefertiReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista dei referti singoli.", oRefertiReturn.Errore)
                        Else
                            oReferti = oRefertiReturn.Referti
                        End If
                    End If
                End Using

                If Not oReferti Is Nothing AndAlso oReferti.Count > 0 Then
                    '
                    ' Tramite linq ottengo i referti singoli dalla lista dei referti
                    '
                    oRefertiSingoli = Filtri.OttengoRefertiSingoli(oReferti)

                    If oRefertiSingoli.Count <= 0 Or oRefertiSingoli Is Nothing Then
                        oRefertiSingoli = Nothing
                    End If
                End If

                '
                ' Salvo nella cache la lista dei referti singoli
                '
                Me.CacheData = oRefertiSingoli
            End If
            Return oRefertiSingoli
        End Function

        ''' <summary>
        ''' Metodo base DA NON UTILIZZARE --> utilizzare quello custom che usa il parametro idPaziente
        ''' </summary>
        Public Overloads Sub ClearCache()

            Throw New NotImplementedException

        End Sub

        ''' <summary>
        ''' Metodo utilizzato per invalidare la cache basato su una CacheDataKey custom.
        ''' </summary>
        ''' <param name="IdPaziente"></param>
        Public Overloads Sub ClearCache(IdPaziente As Guid)
            CacheDataKey = String.Format("{0}_RefertiCercaRefertiSingoli_{1}", OriginalCacheDatakey, IdPaziente.ToString.ToUpper)
            MyBase.ClearCache()
        End Sub
    End Class

    <DataObjectAttribute()>
    Public Class EpisodioOttieniPerId
        Inherits CacheDataSource(Of WcfDwhClinico.EpisodioType)

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, IdEpisodio As Guid) As WcfDwhClinico.EpisodioType
            '
            ' Creo una custom key per la cache
            '
            CacheDataKey = BuildCacheDataKey(IdEpisodio.ToString)
            Dim oEpisodio As WcfDwhClinico.EpisodioType
            '
            ' Cerco prima nella cache
            '
            oEpisodio = Me.CacheData
            If oEpisodio Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)

                    Dim oEpisodioReturn As WcfDwhClinico.EpisodioReturn = oWcf.EpisodioOttieniPerId(Token, IdEpisodio)
                    If oEpisodioReturn IsNot Nothing Then
                        If oEpisodioReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista degli episodi.", oEpisodioReturn.Errore)
                        Else
                            oEpisodio = oEpisodioReturn.Episodio
                        End If
                    End If
                End Using

                Me.CacheData = oEpisodio
            End If
            Return oEpisodio
        End Function

        ''' <summary>
        ''' Sovrascrive la CacheDataKey di default aggiungendo l'Id dell'episodio
        ''' In questo modo cancelliamo la cache per utente e non per l'intera applicazione
        ''' </summary>
        ''' <param name="IdEpisodio"></param>
        ''' <returns></returns>
        Private Function BuildCacheDataKey(IdEpisodio As String) As String
            Return String.Format("{0}_EpisodioOttieniPerId_{1}", CacheDataKey, IdEpisodio.ToUpper)
        End Function

        ''' <summary>
        ''' Metodo base DA NON UTILIZZARE --> utilizzare quello custom che usa il parametro idPaziente
        ''' </summary>
        Public Overloads Sub ClearCache()

            Throw New NotImplementedException

        End Sub

        ''' <summary>
        ''' Overloads del metodo che cancella la cache
        ''' Accetta il parametro IdEpisodio per ricreare la CacheDataKey corretta prima di cancellare la cache
        ''' </summary>
        ''' <param name="IdEpisodio"></param>
        Public Overloads Sub ClearCache(IdEpisodio As String)
            CacheDataKey = BuildCacheDataKey(IdEpisodio)
            MyBase.ClearCache()
        End Sub
    End Class

    <DataObjectAttribute()>
    Public Class RefertoOttieniPerId
        Inherits CacheDataSource(Of WcfDwhClinico.RefertoType)

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, IdReferto As Guid) As WcfDwhClinico.RefertoType
            '
            ' Creo una custom key per la cache
            '
            CacheDataKey = BuildCacheDataKey(IdReferto.ToString)
            Dim oReferto As WcfDwhClinico.RefertoType
            '
            ' Cerco prima nella cache
            '
            oReferto = Me.CacheData
            If oReferto Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)

                    Dim oRefertoReturn As WcfDwhClinico.RefertoReturn = oWcf.RefertoOttieniPerId(Token, IdReferto)
                    If oRefertoReturn IsNot Nothing Then
                        If oRefertoReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura del referto", oRefertoReturn.Errore)
                        Else
                            oReferto = oRefertoReturn.Referto
                        End If
                    End If
                End Using

                Me.CacheData = oReferto
            End If
            Return oReferto
        End Function

        ''' <summary>
        ''' Sovrascrive la CacheDataKey aggiungendo l'Id dell'episodio
        ''' In questo modo cancelliamo la cache per utente e non per l'intera applicazione
        ''' </summary>
        ''' <param name="IdReferto"></param>
        ''' <returns></returns>
        Private Function BuildCacheDataKey(IdReferto As String) As String
            Return String.Format("{0}_RefertoOttieniPerId_{1}", CacheDataKey, IdReferto.ToUpper)

        End Function

        ''' <summary>
        ''' Metodo base DA NON UTILIZZARE --> utilizzare quello custom che usa il parametro idPaziente
        ''' </summary>
        Public Overloads Sub ClearCache()

            Throw New NotImplementedException

        End Sub

        ''' <summary>
        ''' Overloads del metodo che cancella la cache
        ''' Accetta il parametro IdEpisodio per ricreare la CacheDataKey corretta prima di cancellare la cache
        ''' </summary>
        ''' <param name="IdReferto"></param>
        Public Overloads Sub ClearCache(IdReferto As String)
            CacheDataKey = BuildCacheDataKey(IdReferto)
            MyBase.ClearCache()
        End Sub
    End Class

    <DataObjectAttribute()>
    Public Class ListaConsensi

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(ByVal sIdPazienteSAC As String) As SacConsensiDataAccess.ConsensiCercaByIdPazienteResult
            Dim oSacConsensiWs As New SacConsensiDataAccess.ConsensiSoapClient

            If oSacConsensiWs Is Nothing Then
                Throw New Exception("Errore: il Web Service SacConsensiDataAccess.Consensi è nothing.")
            End If

            Call Utility.SetWsConsensiCredential(oSacConsensiWs)

            Dim oConsensiResult As SacConsensiDataAccess.ConsensiCercaByIdPazienteResult
            oConsensiResult = oSacConsensiWs.ConsensiCercaByIdPaziente(sIdPazienteSAC)
            If (oConsensiResult IsNot Nothing) AndAlso
             (oConsensiResult.Count > 0) Then
                If My.Settings.NuovaGestioneConsensi = True Then
                    '
                    ' MODIFICA ETTORE 2019-03-07: Il consenso "GENERICO POSITIVO" non deve essere più visto nella GRID, lo tolgo da dataset
                    ' 
                    Dim itemGenericoPositivoLista As List(Of SacConsensiDataAccess.Consensi) = (From c In oConsensiResult Where c.Tipo.ToUpper = "GENERICO" And c.Stato = True).ToList
                    If Not itemGenericoPositivoLista Is Nothing AndAlso itemGenericoPositivoLista.Count > 0 Then
                        oConsensiResult.Remove(itemGenericoPositivoLista(0))
                    End If
                    If (oConsensiResult.Count = 0) Then
                        Return Nothing
                    End If
                End If

                '
                ' Imposto la data source della lista all'array
                '
                Return oConsensiResult
            Else
                Return Nothing
            End If

        End Function
    End Class

    <DataObjectAttribute()>
    Public Class DizionarioTipiRefertoOttieni

        Public Sub InitializeData()
            '
            ' Cerco prima nella cache
            '
            Dim oDizionario As WcfDwhClinico.DizionarioTipiRefertoListaType = DirectCast(HttpContext.Current.Application("KEY_DIZIONARIO_TIPI_REFERTO"), WcfDwhClinico.DizionarioTipiRefertoListaType)

            If oDizionario Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)

                    Dim oDizionarioReturn As WcfDwhClinico.DizionarioTipiRefertoReturn = oWcf.DizionarioTipiRefertoOttieni()
                    If oDizionarioReturn IsNot Nothing Then
                        If oDizionarioReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura del dizionario dei tipi di referto", oDizionarioReturn.Errore)
                        Else
                            oDizionario = oDizionarioReturn.DizionarioTipiReferto
                        End If
                    End If
                End Using
                '
                ' MODIFICA ETTORE 2019-02-07: se nella descrizione del tipo di referto c'è "[RefertoSingolo]" allora:
                ' 1) ricavo l'elenco dei referti singoli e li salvo nell'APPLICATION
                ' 2) tolgo il testo "[RefertoSingolo]" dalla descrizione in oDizionario
                '
                Const MARKER_REFERTO_SINGOLO As String = "[REFERTOSINGOLO]"
                Dim oDizionarioRefertiSingoli As New WcfDwhClinico.DizionarioTipiRefertoListaType
                Try
                    Dim oList As List(Of WcfDwhClinico.DizionarioTipoRefertoListaType) = (From c In oDizionario Where c.Descrizione.ToUpper.Contains(MARKER_REFERTO_SINGOLO) = True).ToList
                    For Each oItem As WcfDwhClinico.DizionarioTipoRefertoListaType In oList
                        'questa toglie il testo "[RefertoSingolo]" anche dal dizionario oDizionario
                        oItem.Descrizione = Replace(oItem.Descrizione, MARKER_REFERTO_SINGOLO, "",,, CompareMethod.Text)
                        oDizionarioRefertiSingoli.Add(oItem)
                    Next
                Catch ex As Exception
                    'Scrivo errore ma vado avanti
                    Call Data.Logging.WriteError(ex, Me.GetType.Name)
                End Try
                '
                ' Salvo nall'application
                '
                HttpContext.Current.Application.Lock()
                HttpContext.Current.Application("KEY_DIZIONARIO_TIPI_REFERTO") = oDizionario
                HttpContext.Current.Application("KEY_DIZIONARIO_REFERTI_SINGOLI") = oDizionarioRefertiSingoli
                HttpContext.Current.Application.UnLock()
            End If

        End Sub

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData() As WcfDwhClinico.DizionarioTipiRefertoListaType
            '
            ' Cerco prima nella cache
            '
            Dim oDizionario As WcfDwhClinico.DizionarioTipiRefertoListaType = DirectCast(HttpContext.Current.Application("KEY_DIZIONARIO_TIPI_REFERTO"), WcfDwhClinico.DizionarioTipiRefertoListaType)
            If oDizionario Is Nothing Then
                'Ri-inizializzo i dati nell'application (non dovrebbe mai accadere)
                Call InitializeData()
                oDizionario = DirectCast(HttpContext.Current.Application("KEY_DIZIONARIO_TIPI_REFERTO"), WcfDwhClinico.DizionarioTipiRefertoListaType)
            End If
            Return oDizionario
        End Function

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetDataRefertiSingoli() As WcfDwhClinico.DizionarioTipiRefertoListaType
            '
            ' Cerco prima nella cache
            '
            Dim oDizionario As WcfDwhClinico.DizionarioTipiRefertoListaType = DirectCast(HttpContext.Current.Application("KEY_DIZIONARIO_REFERTI_SINGOLI"), WcfDwhClinico.DizionarioTipiRefertoListaType)
            If oDizionario Is Nothing Then
                'Ri-inizializzo i dati nell'application (non dovrebbe mai accadere)
                Call InitializeData()
                oDizionario = DirectCast(HttpContext.Current.Application("KEY_DIZIONARIO_REFERTI_SINGOLI"), WcfDwhClinico.DizionarioTipiRefertoListaType)
            End If
            Return oDizionario
        End Function

    End Class

    <DataObjectAttribute()>
    Public Class NoteAnamnesticheCercaPerIdPaziente
        Inherits CacheDataSource(Of WcfDwhClinico.NoteAnamnesticheListaType)

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, IdPaziente As Guid, DallaData As Date, ByPassaConsenso As Boolean, AllaData As Date?) As WcfDwhClinico.NoteAnamnesticheListaType
            Const MAX_NUM_RECORD As Integer = 1000

            '
            'Definisco l'oggetto da restituire.
            '
            Dim oNoteAnamnestiche As WcfDwhClinico.NoteAnamnesticheListaType

            '
            ' Cerco prima nella cache
            '
            oNoteAnamnestiche = Me.CacheData

            '
            'Se nella cache non c'è niente allora chiamo il metodo del ws.s
            '
            If oNoteAnamnestiche Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)
                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oNoteAnamnesticheReturn As WcfDwhClinico.NoteAnamnesticheReturn = oWcf.NoteAnamnesticheCercaPerIdPaziente(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, IdPaziente, DallaData, AllaData)
                    If oNoteAnamnesticheReturn IsNot Nothing Then
                        If oNoteAnamnesticheReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista delle note anamnestiche.", oNoteAnamnesticheReturn.Errore)
                        Else
                            oNoteAnamnestiche = oNoteAnamnesticheReturn.NoteAnamnestiche
                        End If
                    End If
                End Using

                '
                'Salvo nella cache le note anamnestiche.
                '
                Me.CacheData = oNoteAnamnestiche
            End If

            Return oNoteAnamnestiche
        End Function
    End Class

    <DataObjectAttribute()>
    Public Class NotaAnamnesticaOttieniPerId
        Inherits CacheDataSource(Of WcfDwhClinico.NotaAnamnesticaType)

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, IdNotaAnamnestica As Guid) As WcfDwhClinico.NotaAnamnesticaType
            Dim oNotaAnamnestica As WcfDwhClinico.NotaAnamnesticaType

            '
            ' Creo una custom key per la cache
            '
            CacheDataKey = BuildCacheDataKey(IdNotaAnamnestica.ToString)

            '
            ' Cerco prima nella cache
            '
            oNotaAnamnestica = Me.CacheData
            If oNotaAnamnestica Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)

                    Dim oNotaAnamnesticaReturn As WcfDwhClinico.NotaAnamnesticaReturn = oWcf.NotaAnamnesticaOttieniPerId(Token, IdNotaAnamnestica)
                    If oNotaAnamnesticaReturn IsNot Nothing Then
                        If oNotaAnamnesticaReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della nota anamnestica.", oNotaAnamnesticaReturn.Errore)
                        Else
                            oNotaAnamnestica = oNotaAnamnesticaReturn.NotaAnamnestica
                        End If
                    End If
                End Using

                Me.CacheData = oNotaAnamnestica
            End If

            Return oNotaAnamnestica
        End Function

        ''' <summary>
        ''' Sovrascrive la CacheDataKey di default aggiungendo l'Id della nota
        ''' In questo modo cancelliamo la cache per utente e non per l'intera applicazione
        ''' </summary>
        ''' <param name="IdNota"></param>
        ''' <returns></returns>
        Private Function BuildCacheDataKey(IdNota As String) As String
            Return String.Format("{0}_NotaAnamnesticaOttieniPerId_{1}", CacheDataKey, IdNota.ToUpper)
        End Function

        ''' <summary>
        ''' Metodo base DA NON UTILIZZARE --> utilizzare quello custom che usa il parametro idPaziente
        ''' </summary>
        Public Overloads Sub ClearCache()

            Throw New NotImplementedException

        End Sub

        ''' <summary>
        ''' Overloads del metodo che cancella la cache
        ''' </summary>
        ''' <param name="IdNota"></param>
        Public Overloads Sub ClearCache(IdNota As String)
            CacheDataKey = BuildCacheDataKey(IdNota)
            MyBase.ClearCache()
        End Sub
    End Class
#End Region




#Region "AccessoDiretto"
    <DataObjectAttribute()>
    Public Class AccessoDirettoPazientiCerca
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, Cognome As String, Nome As String, DataNascita As Date?, CodiceFiscale As String, CodiceSanitario As String) As WcfDwhClinico.PazientiListaType
            Const MAX_NUM_RECORD As Integer = 1000
            Dim oPazienti As WcfDwhClinico.PazientiListaType = Nothing

            If oPazienti Is Nothing Then

                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)
                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oPazientiReturn As WcfDwhClinico.PazientiReturn = Nothing 'oWcf.PazientiCercaPerGeneralita(Token, MAX_NUM_RECORD, Ordinamento, Cognome, Nome, Nothing, AnnoNascita, LuogoNascita)

                    If Not String.IsNullOrEmpty(Cognome) AndAlso Not String.IsNullOrEmpty(Nome) Then
                        If Not String.IsNullOrEmpty(CodiceFiscale) Then
                            oPazientiReturn = oWcf.PazientiCercaPerCodiceFiscale(Token, MAX_NUM_RECORD, Ordinamento, CodiceFiscale, Cognome, Nome)
                        ElseIf DataNascita.HasValue Then
                            oPazientiReturn = oWcf.PazientiCercaPerGeneralita(Token, MAX_NUM_RECORD, Ordinamento, Cognome, Nome, DataNascita.Value, Nothing, Nothing)
                        End If
                    Else
                        '
                        ' Questo errore viene gestito nel selected dell'ObjectDataSource a cui questo metodo è collegato
                        '
                        Throw New ApplicationException("La combinazione dei parametri non è valida. Combinazioni valide: [Cognome,Nome,Codice Fiscale], [Cognome,Nome,Data Nascita]")
                    End If

                    If oPazientiReturn IsNot Nothing Then
                        If oPazientiReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Accesso Diretto: Si è verificato un errore durante la lettura della lista pazienti.", oPazientiReturn.Errore)
                        Else
                            oPazienti = oPazientiReturn.Pazienti
                        End If
                    End If
                End Using
            End If
            Return oPazienti
        End Function
    End Class

    <DataObjectAttribute()>
    Public Class AccessoDirettoRefertiCercaPerIdPaziente
        Inherits CacheDataSource(Of List(Of WcfDwhClinico.RefertoListaType))

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, IdPaziente As Guid, DallaData As Date, ByPassaConsenso As Boolean, AllaData As Date?, lstFiltriTipiReferto As List(Of String)) As List(Of WcfDwhClinico.RefertoListaType)
            Const MAX_NUM_RECORD As Integer = 1000
            Dim oReferti As List(Of WcfDwhClinico.RefertoListaType)

            CacheDataKey = GetCacheKey(IdPaziente)

            '
            ' Cerco prima nella cache
            '
            oReferti = Me.CacheData
            If oReferti Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)
                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oRefertiReturn As WcfDwhClinico.RefertiReturn = oWcf.RefertiCercaPerIdPaziente(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, IdPaziente, DallaData, AllaData, Nothing, Nothing, Nothing, Nothing)
                    If oRefertiReturn IsNot Nothing Then
                        If oRefertiReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista dei referti.", oRefertiReturn.Errore)
                        Else
                            oReferti = oRefertiReturn.Referti
                        End If
                    End If
                End Using
                If Not oReferti Is Nothing AndAlso oReferti.Count > 0 Then
                    '
                    ' Tolgo dalla lista dei referti i referti singoli( visualizzati in una tab a parte)
                    '
                    Dim queryReferti = Filtri.EsclusioneRefertiSingoli(oReferti)
                    oReferti = queryReferti
                End If

                '
                ' Salvo nella cache la lista dei referti senza i referti singoli
                '
                Me.CacheData = oReferti
            End If


            If Not oReferti Is Nothing AndAlso oReferti.Count > 0 Then
                '
                ' Filtro anche per la lista dei tipi di referto selezionati
                '
                If lstFiltriTipiReferto IsNot Nothing AndAlso lstFiltriTipiReferto.Count > 0 Then
                    'OTTENGO LA LISTA DEI TIPI REFERTI SPLITTANDO QUELLI CHE SONO COMPOSTI. 
                    '(ALCUNI ITEM DI LSTFILTRITIPIREFERTI SONO COMPOSTI DA PIÙ ID SEPARATI DA; PER EVITARE DI AVERE PIÙ ITEM NELLA LISTA DEI FILTRI LATERALI CON LA STESSA DESCRIZIONE)
                    Dim oLstFiltriTipiReferto As List(Of String) = Filtri.OttieniListaFiltriTipiReferti(lstFiltriTipiReferto)


                    Dim query = (From c In oReferti Where oLstFiltriTipiReferto.Contains(c.IdTipoReferto)).ToList
                    oReferti = query
                End If
            End If
            Return oReferti
        End Function

        ''' <summary>
        ''' Restituisce la lista dei tipi di referto
        ''' Deve essere eseguito dopo la funzione GetData perchè filtra la lista ottenuta dalla cache
        ''' </summary>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetSelectedTipiReferto(IdPaziente As Guid) As IEnumerable

            CacheDataKey = GetCacheKey(IdPaziente)

            Dim listaReferti As List(Of WcfDwhClinico.RefertoListaType) = Me.CacheData
            Dim ds As New DizionarioTipiRefertoOttieni
            Dim listaIcone As WcfDwhClinico.DizionarioTipiRefertoListaType = ds.GetData()
            If listaReferti Is Nothing Then
                Return Nothing
            End If
            '
            ' Ottengo il distinct della lista dei referti per ottenere i  tipi referto.
            '
            Dim filtriTipoReferto = (From c In listaReferti
                                     Select c.IdTipoReferto Where IdTipoReferto <> Nothing).Distinct


            Dim oReturn = Filtri.OttieniListaTipiReferti(listaIcone, filtriTipoReferto)

            Return oReturn
        End Function

        ''' <summary>
        ''' Metodo base DA NON UTILIZZARE --> utilizzare quello custom che usa il parametro idPaziente
        ''' </summary>
        Public Overloads Sub ClearCache()

            Throw New NotImplementedException

        End Sub

        ''' <summary>
        ''' Metodo custum per cancellare la cache dell'ObjectDataSource in base sull'Id del paziente.
        ''' </summary>
        ''' <param name="idPaziente"></param>
        Public Overloads Sub ClearCache(idPaziente As Guid)
            CacheDataKey = GetCacheKey(idPaziente)
            MyBase.ClearCache()
        End Sub

        ''' <summary>
        '''  Imposta lo stato di un referto a visionato nella Cache dei referti, per togliere l'evidenziamento dei referti nuovi
        ''' </summary>
        ''' <param name="idReferto"></param>
        ''' <param name="idPaziente"></param>
        Public Sub ImpostaRefertoVisionato(idReferto As Guid, idPaziente As Guid)

            Dim user As String = HttpContext.Current.User.Identity.Name

            '
            ' In questo caso creo una custom key NON basata sull' HashCode della pagina perchè la cache di questo DataSource deve essere condiviso da più pagine.
            '
            CacheDataKey = GetCacheKey(idPaziente)


            If Me.CacheData IsNot Nothing Then

                ' Imposto il referto in cache a visionato
                Dim refertoVariato As WcfDwhClinico.RefertoListaType = Me.CacheData.Where(Function(x) x.Id = idReferto.ToString().ToUpper()).FirstOrDefault()
                If refertoVariato IsNot Nothing Then

                    refertoVariato.Visionato = True
                End If
            End If

        End Sub

        ''' <summary>
        ''' Ottiene la key per la cache da usare all'interno della classe
        ''' </summary>
        ''' <param name="idPaziente"></param>
        ''' <returns></returns>
        Private Function GetCacheKey(idPaziente As Guid) As String
            Dim user As String = HttpContext.Current.User.Identity.Name

            Return $"{user.ToUpper}_AccessoDirettoRefertiCercaPerIdPaziente_{idPaziente.ToString().ToUpper()}_{Me.GetType}"

        End Function

    End Class


    <DataObjectAttribute()>
    Public Class AccessoDirettoEpisodiCercaPerIdPaziente
        Inherits CacheDataSource(Of List(Of WcfDwhClinico.EpisodioListaType))

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, IdPaziente As Guid, ByPassaConsenso As Boolean, DallaData As Date, AllaData As Date?) As List(Of WcfDwhClinico.EpisodioListaType)
            Const MAX_NUM_RECORD As Integer = 1000
            CacheDataKey = String.Format("{0}-AccessoDirettoEpisodiCercaPerIdPaziente-{1}", OriginalCacheDatakey, IdPaziente.ToString.ToUpper)
            Dim oEpisodi As List(Of WcfDwhClinico.EpisodioListaType) = Nothing
            '
            ' Cerco prima nella cache
            '
            oEpisodi = Me.CacheData
            If oEpisodi Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)
                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oEpisodiReturn As WcfDwhClinico.EpisodiReturn = oWcf.EpisodiCercaPerIdPaziente(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, IdPaziente, DallaData, AllaData)
                    If oEpisodiReturn IsNot Nothing Then
                        If oEpisodiReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista degli episodi.", oEpisodiReturn.Errore)
                        Else
                            oEpisodi = oEpisodiReturn.Episodi
                        End If
                    End If
                End Using

                If Not oEpisodi Is Nothing Then
                    '
                    ' Tolgo dalla lista degli episodi le prenotazioni nello stato ricoverato = 22
                    '
                    Dim queryEpisodi As List(Of WcfDwhClinico.EpisodioListaType) = (From c In oEpisodi Where c.StatoCodice <> "22").ToList
                    oEpisodi = queryEpisodi
                End If

                '
                ' Salvo nella cache
                '
                Me.CacheData = oEpisodi
            End If
            Return oEpisodi
        End Function

        ''' <summary>
        ''' Metodo base DA NON UTILIZZARE --> utilizzare quello custom che usa il parametro idPaziente
        ''' </summary>
        Public Overloads Sub ClearCache()

            Throw New NotImplementedException

        End Sub

        Public Overloads Sub ClearCache(idPaziente As Guid)
            CacheDataKey = String.Format("{0}-AccessoDirettoEpisodiCercaPerIdPaziente-{1}", OriginalCacheDatakey, idPaziente.ToString.ToUpper)
            MyBase.ClearCache()
        End Sub

    End Class

    <DataObjectAttribute()>
    Public Class AccessoDirettoRefertiCercaPerNosologico
        Inherits CacheDataSource(Of WcfDwhClinico.RefertiListaType)

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, ByPassaConsenso As Boolean, Nosologico As String, Azienda As String, lstFiltriTipiReferto As List(Of String)) As List(Of WcfDwhClinico.RefertoListaType)
            Const MAX_NUM_RECORD As Integer = 1000
            Dim oReferti As List(Of WcfDwhClinico.RefertoListaType) = Nothing

            '
            ' Creo una nuova key per ottenere e cancellare i dati in cache formata da Azienda + Nosologico
            '
            Me.CacheDataKey = GetCacheKey(Nosologico, Azienda)

            '
            ' Esco se Nosologico e Azienda non solo valorizzati 
            '
            If String.IsNullOrEmpty(Nosologico) AndAlso String.IsNullOrEmpty(Azienda) Then
                Return Nothing
            End If

            '
            ' Cerco prima nella cache
            '
            oReferti = Me.CacheData
            If oReferti Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)

                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oRefertiReturn As WcfDwhClinico.RefertiReturn = oWcf.RefertiCercaPerNosologico(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, Nosologico, Azienda)
                    If oRefertiReturn IsNot Nothing Then
                        If oRefertiReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista dei referti.", oRefertiReturn.Errore)
                        Else
                            oReferti = oRefertiReturn.Referti
                        End If
                    End If
                End Using
                '
                ' Salvo nella cache
                '
                If oReferti Is Nothing Then
                    Me.CacheData = New WcfDwhClinico.RefertiListaType
                Else
                    Me.CacheData = oReferti
                End If
            End If
            If Not oReferti Is Nothing AndAlso oReferti.Count > 0 Then
                '
                ' Filtro anche per la lista dei tipi di referto selezionati
                '
                If lstFiltriTipiReferto IsNot Nothing AndAlso lstFiltriTipiReferto.Count > 0 Then
                    'OTTENGO LA LISTA DEI TIPI REFERTI SPLITTANDO QUELLI CHE SONO COMPOSTI. 
                    '(ALCUNI ITEM DI LSTFILTRITIPIREFERTI SONO COMPOSTI DA PIÙ ID SEPARATI DA; PER EVITARE DI AVERE PIÙ ITEM NELLA LISTA DEI FILTRI LATERALI CON LA STESSA DESCRIZIONE)
                    Dim oLstFiltriTipiReferto As List(Of String) = Filtri.OttieniListaFiltriTipiReferti(lstFiltriTipiReferto)

                    Dim query = (From c In oReferti Where oLstFiltriTipiReferto.Contains(c.IdTipoReferto)).ToList
                    oReferti = query
                End If
            End If
            Return oReferti
        End Function

        ''' <summary>
        ''' Restituisce la lista dei tipi di referto
        ''' Deve essere eseguito dopo la funzione GetData perchè filtra la lista ottenuta dalla cache
        ''' </summary>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetSelectedTipiReferto(listaReferti As List(Of WcfDwhClinico.RefertoListaType)) As IEnumerable
            Dim ds As New DizionarioTipiRefertoOttieni
            Dim listaIcone As WcfDwhClinico.DizionarioTipiRefertoListaType = ds.GetData()
            If listaReferti Is Nothing Then
                Return Nothing
            End If
            '
            ' Ottengo il distinct della lista dei referti per ottenere i  tipi referto.
            '
            Dim filtriTipoReferto = (From c In listaReferti
                                     Select c.IdTipoReferto Where IdTipoReferto <> Nothing).Distinct

            Dim oReturn = Filtri.OttieniListaTipiReferti(listaIcone, filtriTipoReferto)

            Return oReturn
        End Function

        ''' <summary>
        ''' Metodo base DA NON UTILIZZARE --> utilizzare quello custom che usa il parametro idPaziente
        ''' </summary>
        Public Overloads Sub ClearCache()

            Throw New NotImplementedException

        End Sub

        Public Overloads Sub ClearCache(Nosologico As String, Azienda As String)

            Dim user As String = HttpContext.Current.User.Identity.Name

            '
            ' Prima di cancellare i dati in cache rigenero la key formata da nosologico e azienda
            '
            Me.CacheDataKey = GetCacheKey(Nosologico, Azienda)
            MyBase.ClearCache()
        End Sub

        ''' <summary>
        '''  Imposta lo stato di un referto a visionato nella Cache dei Referti negli Episodi, per togliere l'evidenziamento dei referti nuovi
        ''' </summary>
        ''' <param name="Nosologico"></param>
        ''' <param name="Azienda"></param>
        Public Sub ImpostaRefertoVisionato(idRefero As Guid, nosologico As String, azienda As String)

            Dim user As String = HttpContext.Current.User.Identity.Name

            '
            ' In questo caso creo una custom key NON basata sull' HashCode della pagina perchè la cache di questo DataSource deve essere condiviso da più pagine.
            '
            Me.CacheDataKey = GetCacheKey(nosologico, azienda)


            If Me.CacheData IsNot Nothing Then

                ' Imposto il referto in cache a visionato
                Dim refertoVariato As WcfDwhClinico.RefertoListaType = Me.CacheData.Where(Function(x) x.Id = idRefero.ToString().ToUpper() And x.NumeroNosologico = nosologico And x.AziendaErogante = azienda).FirstOrDefault()
                If refertoVariato IsNot Nothing Then

                    refertoVariato.Visionato = True
                End If
            End If
        End Sub

        ''' <summary>
        ''' Ottiene la key per la cache da usare all'interno della classe
        ''' </summary>
        ''' <param name="nosologico"></param>
        ''' <param name="azienda"></param>
        ''' <returns></returns>
        Private Function GetCacheKey(nosologico As String, azienda As String) As String
            Dim user As String = HttpContext.Current.User.Identity.Name

            Return $"{user.ToUpper}_RefertiCercaPerNosologico_{nosologico}_{azienda}_{Me.GetType}"

        End Function

    End Class

    <DataObjectAttribute()>
    Public Class AccessoDirettoPrescrizioniCercaPerIdPaziente
        Inherits CacheDataSource(Of List(Of WcfDwhClinico.PrescrizioneListaType))

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, IdPaziente As Guid, DallaData As Date, ByPassaConsenso As Boolean, AllaData As Date?, lstFiltriTipiPrescrizione As List(Of String)) As List(Of WcfDwhClinico.PrescrizioneListaType)
            Const MAX_NUM_RECORD As Integer = 1000
            Dim sCurrentUser As String = HttpContext.Current.User.Identity.Name.ToUpper
            Dim oPrescrizioni As List(Of WcfDwhClinico.PrescrizioneListaType)
            'CacheDataKey = String.Format("{0}-AccessoDirettoPrescrizioniCercaPerIdPaziente-{1}", OriginalCacheDatakey, IdPaziente.ToString)

            '
            ' Cerco prima nella cache
            '
            oPrescrizioni = Me.CacheData
            If oPrescrizioni Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)
                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oPrescrizioniReturn As WcfDwhClinico.PrescrizioniReturn = oWcf.PrescrizioniCercaPerIdPaziente(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, IdPaziente, DallaData, AllaData)

                    If oPrescrizioniReturn IsNot Nothing Then
                        If oPrescrizioniReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista delle prescrizioni.", oPrescrizioniReturn.Errore)
                        Else
                            oPrescrizioni = oPrescrizioniReturn.Prescrizioni
                        End If
                    End If
                End Using
                '
                ' Salvo nella cache
                '
                Me.CacheData = oPrescrizioni
            End If
            If lstFiltriTipiPrescrizione IsNot Nothing AndAlso lstFiltriTipiPrescrizione.Count > 0 Then
                Dim query = (From c In oPrescrizioni Where lstFiltriTipiPrescrizione.Contains(c.TipoPrescrizione)).ToList
                oPrescrizioni = query
            End If
            Return oPrescrizioni

        End Function


        ''' <summary>
        ''' Restituisce la lista dei tipi di referto
        ''' Deve essere eseguito dopo la funzione GetData perchè filtra la lista ottenuta dalla cache
        ''' </summary>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetSelectedTipiPrescrizione() As IEnumerable
            Dim listaPrescrizioni As List(Of WcfDwhClinico.PrescrizioneListaType) = Me.CacheData
            If listaPrescrizioni Is Nothing Then
                Return Nothing
            End If
            Dim filtriTipoReferto = (From c In listaPrescrizioni
                                     Order By c.TipoPrescrizione
                                     Select c.TipoPrescrizione Where TipoPrescrizione <> Nothing).Distinct
            Return filtriTipoReferto
        End Function
    End Class

    <DataObjectAttribute()>
    Public Class AccessoDirettoMatricePrestazioniLabCercaPerIdPaziente
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, IdPaziente As Guid, DallaData As Date, AllaData As Date?, ByPassaConsenso As Boolean, PrestazioneCodice As String, SezioneCodice As String) As WcfDwhClinico.MatricePrestazioniListaType
            Const MAX_NUM_RECORD As Integer = 1000
            Dim oMatriciPrescrizioni As WcfDwhClinico.MatricePrestazioniListaType = Nothing

            If oMatriciPrescrizioni Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)

                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oMatricePrestazioniReturn As WcfDwhClinico.MatricePrestazioniReturn = oWcf.MatricePrestazioniLabCercaPerIdPaziente(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, IdPaziente, DallaData, AllaData, PrestazioneCodice, SezioneCodice)
                    If oMatricePrestazioniReturn IsNot Nothing Then
                        If oMatricePrestazioniReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista della matrice.", oMatricePrestazioniReturn.Errore)
                        Else
                            oMatriciPrescrizioni = oMatricePrestazioniReturn.MatricePrestazioni
                        End If
                    End If
                End Using
            End If

            Return oMatriciPrescrizioni

        End Function
    End Class

    <DataObjectAttribute()>
    Public Class AccessoDirettoMatricePrestazioniLabCercaPerSezioneCodice

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, IdPaziente As Guid, DallaData As Date, AllaData As Date?, ByPassaConsenso As Boolean, PrestazioneCodice As String, SezioneCodice As String) As WcfDwhClinico.MatricePrestazioniListaType
            Const MAX_NUM_RECORD As Integer = 1000

            '
            ' IMPLEMENTAZIONE DI UNA CUSTOM KEY
            '
            Dim oMatriciPrescrizioni As WcfDwhClinico.MatricePrestazioniListaType = Nothing

            '
            ' RECUPERO DATI DAL WS
            '
            Using oWcf As New WcfDwhClinico.ServiceClient
                Call Utility.SetWcfDwhClinicoCredential(oWcf)

                '
                ' CHIAMATA AL METODO CHE RESTITUISCE I DATI
                '
                Dim oMatricePrestazioniReturn As WcfDwhClinico.MatricePrestazioniReturn = oWcf.MatricePrestazioniLabCercaPerIdPaziente(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, IdPaziente, DallaData, AllaData, PrestazioneCodice, SezioneCodice)
                If oMatricePrestazioniReturn IsNot Nothing Then
                    If oMatricePrestazioniReturn.Errore IsNot Nothing Then
                        Throw New WsDwhException("Si è verificato un errore durante la lettura della lista della matrice.", oMatricePrestazioniReturn.Errore)
                    Else
                        oMatriciPrescrizioni = oMatricePrestazioniReturn.MatricePrestazioni
                    End If
                End If
            End Using

            Return oMatriciPrescrizioni
        End Function
    End Class

    <DataObjectAttribute()>
    Public Class AccessoDirettoRefertiCercaRefertiSingoli
        'Inherits CacheDataSource(Of List(Of WcfDwhClinico.RefertoListaType))
        ''' <summary>
        ''' Filtra la lista dei referti per ottenere la lista dei referti singoli
        ''' Se AziendaErogante = "AUSL",SistemaErogante = "EIM" e RepartoErogante = "VACCINAZIONI" allora il referto è un referto singolo
        ''' </summary>
        ''' <param name="Token"></param>
        ''' <param name="Ordinamento"></param>
        ''' <param name="IdPaziente"></param>
        ''' <param name="DallaData"></param>
        ''' <param name="ByPassaConsenso"></param>
        ''' <param name="AllaData"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, IdPaziente As Guid, DallaData As Date, ByPassaConsenso As Boolean, AllaData As Date?) As List(Of WcfDwhClinico.RefertoListaType)
            Const MAX_NUM_RECORD As Integer = 1000

            'CacheDataKey = String.Format("{0}-AccessoDirettoRefertiCercaRefertiSingoli-{1}", OriginalCacheDatakey, IdPaziente.ToString)

            Dim oRefertiSingoli As List(Of WcfDwhClinico.RefertoListaType) = Nothing
            Dim oreferti As List(Of WcfDwhClinico.RefertoListaType) = Nothing
            '
            ' Cerco prima nella cache
            '
            'oRefertiSingoli = Me.CacheData
            If oRefertiSingoli Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)

                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oRefertiReturn As WcfDwhClinico.RefertiReturn = oWcf.RefertiCercaPerIdPaziente(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, IdPaziente, DallaData, AllaData, Nothing, Nothing, Nothing, Nothing)
                    If oRefertiReturn IsNot Nothing Then
                        If oRefertiReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista dei referti singoli.", oRefertiReturn.Errore)
                        Else
                            oreferti = oRefertiReturn.Referti
                        End If
                    End If
                End Using

                If Not oreferti Is Nothing AndAlso oreferti.Count > 0 Then
                    '
                    ' Tramite linq ottengo i referti singoli dalla lista dei referti
                    '
                    oRefertiSingoli = Filtri.OttengoRefertiSingoli(oreferti)
                    If oRefertiSingoli.Count <= 0 Or oRefertiSingoli Is Nothing Then
                        oRefertiSingoli = Nothing
                    End If
                End If
                '
                ' Salvo nella cache la lista dei referti singoli
                '
                'Me.CacheData = oRefertiSingoli
            End If
            Return oRefertiSingoli
        End Function

        '''' <summary>
        '''' Metodo utilizzato per invalidare la cache basato su una CacheDataKey custom.
        '''' </summary>
        '''' <param name="IdPaziente"></param>
        'Public Overloads Sub ClearCache(IdPaziente As String)
        '    CacheDataKey = String.Format("{0}-AccessoDirettoRefertiCercaRefertiSingoli-{1}", OriginalCacheDatakey, IdPaziente.ToString)
        '    MyBase.ClearCache()
        'End Sub
    End Class

    <DataObjectAttribute()>
    Public Class AccessoDirettoEventiEpisodioCercaPerId

        ''' <summary>
        ''' Restituisce la lista degli eventi in base all'id dell'episodio
        ''' Sfrutta la cache della classe AccessoDirettoEpisodioOttieniPerId per ottenere la lista degli eventi
        ''' </summary>
        ''' <param name="Token"></param>
        ''' <param name="IdRicovero"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, IdRicovero As Guid) As WcfDwhClinico.EventiType
            '
            ' La gestione degli errori è all'interno della AccessoDirettoEpisodioOttieniPerId.GetData 
            '
            Dim oEventiEpisodio As WcfDwhClinico.EventiType = Nothing
            Dim EpisodioOttieniPerId As New CustomDataSource.AccessoDirettoEpisodioOttieniPerId
            Dim oEpisodio As WcfDwhClinico.EpisodioType = EpisodioOttieniPerId.GetData(Token, IdRicovero)

            If Not oEpisodio Is Nothing Then
                oEventiEpisodio = oEpisodio.Eventi
                '
                ' MODIFICA ETTORE 2017-05-17: aggiunta l'elenco degli eventi di prenotazione dell'eventuale nosologico di lista di attesa associato al corrente nosologico
                '
                Dim oEventoPrenotazioneOttieniPerIdRIcovero As New CustomDataSource.EventoPrenotazioneOttieniPerIdRicovero
                Dim oEventoPrenotazione As WcfDwhClinico.EventoType = oEventoPrenotazioneOttieniPerIdRIcovero.GetData(Token, oEpisodio)
                If oEventoPrenotazione IsNot Nothing Then
                    '
                    ' Aggiungo l'evento dui prenotazione come primo elemento della lista degli eventi dell'episodio di ricovero
                    '
                    oEventiEpisodio.Insert(0, oEventoPrenotazione)
                End If
            End If
            '
            '
            '
            Return oEventiEpisodio
        End Function
    End Class

    <DataObjectAttribute()>
    Public Class AccessoDirettoEpisodioOttieniPerId
        'Inherits CacheDataSource(Of WcfDwhClinico.EpisodioType)

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, IdEpisodio As Guid) As WcfDwhClinico.EpisodioType
            '
            ' Creo una custom key per la cache
            '
            'CacheDataKey = String.Format("{0}-AccessoDirettoEpisodioOttieniPerId-{1}", OriginalCacheDatakey, IdEpisodio.ToString)
            Dim oEpisodio As WcfDwhClinico.EpisodioType = Nothing
            '
            ' Cerco prima nella cache
            '
            'oEpisodio = Me.CacheData
            'If oEpisodio Is Nothing Then
            '
            ' Recupero dati dal WS
            '
            Using oWcf As New WcfDwhClinico.ServiceClient
                Call Utility.SetWcfDwhClinicoCredential(oWcf)

                Dim oEpisodioReturn As WcfDwhClinico.EpisodioReturn = oWcf.EpisodioOttieniPerId(Token, IdEpisodio)
                If oEpisodioReturn IsNot Nothing Then
                    If oEpisodioReturn.Errore IsNot Nothing Then
                        Throw New WsDwhException("Si è verificato un errore durante la lettura della lista degli episodi.", oEpisodioReturn.Errore)
                    Else
                        oEpisodio = oEpisodioReturn.Episodio
                    End If
                End If
            End Using
            'Me.CacheData = oEpisodio
            'End If
            Return oEpisodio
        End Function

        '''' <summary>
        '''' Metodo utilizzato per invalidare la cache basato su una CacheDataKey custom.
        '''' </summary>
        '''' <param name="IdEpisodio"></param>
        'Public Overloads Sub ClearCache(IdEpisodio As String)
        '    CacheDataKey = String.Format("{0}-AccessoDirettoEpisodioOttieniPerId-{1}", OriginalCacheDatakey, IdEpisodio.ToString)
        '    MyBase.ClearCache()
        'End Sub
    End Class

    <DataObjectAttribute()>
    Public Class AccessoDirettoRefertiCercaPerNumeroPrenotazione
        Inherits CacheDataSource(Of List(Of WcfDwhClinico.RefertoListaType))

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, ByPassaConsenso As Boolean, NumeroPrenotazione As String, DallaData As Date, AllaData As Date?, SistemaErogante As String, RepartoErogante As String, RepartoRichiedenteCodice As String, lstFiltriTipiReferto As List(Of String)) As List(Of WcfDwhClinico.RefertoListaType)
            Const MAX_NUM_RECORD As Integer = 1000
            Return GetData(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, NumeroPrenotazione, DallaData, AllaData, SistemaErogante, RepartoErogante, RepartoRichiedenteCodice, lstFiltriTipiReferto)
        End Function

        Public Function GetData(Token As WcfDwhClinico.TokenType, NumRecord As Integer, Ordinamento As String, ByPassaConsenso As Boolean, NumeroPrenotazione As String, DallaData As Date, AllaData As Date?, SistemaErogante As String, RepartoErogante As String, RepartoRichiedenteCodice As String, lstFiltriTipiReferto As List(Of String)) As List(Of WcfDwhClinico.RefertoListaType)
            Dim oReferti As List(Of WcfDwhClinico.RefertoListaType)
            'CacheDataKey = String.Format("{0}-AccessoDirettoRefertiCercaPerNumeroPrenotazione-{1}", OriginalCacheDatakey, NumeroPrenotazione.ToString.ToUpper)
            '
            ' Cerco prima nella cache
            '
            oReferti = Me.CacheData
            If oReferti Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)
                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oRefertiReturn As WcfDwhClinico.RefertiReturn = oWcf.RefertiCercaPerNumeroPrenotazione(Token, NumRecord, Ordinamento, ByPassaConsenso, NumeroPrenotazione, DallaData, AllaData, SistemaErogante, RepartoErogante, RepartoRichiedenteCodice, Nothing)
                    If oRefertiReturn IsNot Nothing Then
                        If oRefertiReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista dei referti.", oRefertiReturn.Errore)
                        Else
                            oReferti = oRefertiReturn.Referti
                        End If
                    End If
                End Using
                If Not oReferti Is Nothing AndAlso oReferti.Count > 0 Then
                    '
                    ' Tolgo dalla lista dei referti i referti singoli( visualizzati in una tab a parte)
                    '
                    Dim queryReferti = Filtri.EsclusioneRefertiSingoli(oReferti)
                    oReferti = queryReferti
                End If

                '
                ' Salvo nella cache la lista dei referti senza i referti singoli
                '
                Me.CacheData = oReferti
            End If


            If Not oReferti Is Nothing AndAlso oReferti.Count > 0 Then
                '
                ' Filtro anche per la lista dei tipi di referto selezionati
                '
                If lstFiltriTipiReferto IsNot Nothing AndAlso lstFiltriTipiReferto.Count > 0 Then
                    'OTTENGO LA LISTA DEI TIPI REFERTI SPLITTANDO QUELLI CHE SONO COMPOSTI. 
                    '(ALCUNI ITEM DI LSTFILTRITIPIREFERTI SONO COMPOSTI DA PIÙ ID SEPARATI DA; PER EVITARE DI AVERE PIÙ ITEM NELLA LISTA DEI FILTRI LATERALI CON LA STESSA DESCRIZIONE)
                    Dim oLstFiltriTipiReferto As List(Of String) = Filtri.OttieniListaFiltriTipiReferti(lstFiltriTipiReferto)

                    Dim query = (From c In oReferti Where oLstFiltriTipiReferto.Contains(c.IdTipoReferto)).ToList
                    oReferti = query
                End If
            End If
            Return oReferti
        End Function

        ''' <summary>
        ''' Restituisce la lista dei tipi di referto
        ''' Deve essere eseguito dopo la funzione GetData perchè filtra la lista ottenuta dalla cache
        ''' </summary>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetSelectedTipiReferto() As IEnumerable
            Dim listaReferti As List(Of WcfDwhClinico.RefertoListaType) = Me.CacheData
            If listaReferti Is Nothing Then
                Return Nothing
            End If
            Dim ds As New DizionarioTipiRefertoOttieni
            Dim listaIcone As WcfDwhClinico.DizionarioTipiRefertoListaType = ds.GetData()

            'ATTENZIONE: l'ordinamento basato sulle stringhe è CASE SENSITIVE, per questo è stato aggiunto il ToUpper
            Dim filtriTipoReferto = (From c In listaReferti
                                     Order By c.TipoRefertoDescrizione.ToUpper
                                     Select c.TipoRefertoDescrizione, c.IdTipoReferto Where IdTipoReferto <> Nothing Or TipoRefertoDescrizione <> Nothing).Distinct

            Dim oReturn = Filtri.OttieniListaTipiReferti(listaIcone, filtriTipoReferto)

            Return oReturn
        End Function

        '''' <summary>
        '''' Overloads del metodo che cancella la cache
        '''' Accetta il parametro IdPaziente per ricreare la CacheDataKey corretta prima di cancellare la cache
        '''' </summary>
        '''' <param name="NumeroPrenotazione"></param>
        'Public Overloads Sub ClearCache(NumeroPrenotazione As String)
        '    CacheDataKey = String.Format("{0}-AccessoDirettoRefertiCercaPerNumeroPrenotazione-{1}", OriginalCacheDatakey, NumeroPrenotazione.ToString.ToUpper)
        '    MyBase.ClearCache()
        'End Sub
    End Class

    <DataObjectAttribute()>
    Public Class AccessoDirettoRefertiCercaPerIdOrderEntry
        Inherits CacheDataSource(Of List(Of WcfDwhClinico.RefertoListaType))

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, ByPassaConsenso As Boolean, IdOrderEntry As String, DallaData As Date, AllaData As Date?, lstFiltriTipiReferto As List(Of String)) As List(Of WcfDwhClinico.RefertoListaType)
            Const MAX_NUM_RECORD As Integer = 1000
            Dim oReferti As List(Of WcfDwhClinico.RefertoListaType)
            'CacheDataKey = String.Format("{0}-AccessoDirettoRefertiCercaPerNumeroPrenotazione-{1}", OriginalCacheDatakey, NumeroPrenotazione.ToString.ToUpper)
            '
            ' Cerco prima nella cache
            '
            oReferti = Me.CacheData
            If oReferti Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)
                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oRefertiReturn As WcfDwhClinico.RefertiReturn = oWcf.RefertiCercaPerIdOrderEntry(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, IdOrderEntry)
                    If oRefertiReturn IsNot Nothing Then
                        If oRefertiReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista dei referti.", oRefertiReturn.Errore)
                        Else
                            oReferti = oRefertiReturn.Referti
                        End If
                    End If
                End Using
                If Not oReferti Is Nothing AndAlso oReferti.Count > 0 Then
                    '
                    ' Tolgo dalla lista dei referti i referti singoli( visualizzati in una tab a parte)
                    '
                    If Not AllaData.HasValue Then
                        AllaData = Now
                    End If
                    'TODO: filtro comunque i referti singoli anche se non dovrebbe servire
                    Dim queryReferti = Filtri.EsclusioneRefertiSingoli(oReferti)
                    queryReferti = (From c In queryReferti Where c.DataReferto >= DallaData And c.DataReferto <= AllaData).ToList

                    oReferti = queryReferti
                End If

                '
                ' Salvo nella cache la lista dei referti senza i referti singoli
                '
                Me.CacheData = oReferti
            End If


            If Not oReferti Is Nothing AndAlso oReferti.Count > 0 Then
                '
                ' Filtro anche per la lista dei tipi di referto selezionati
                '
                If lstFiltriTipiReferto IsNot Nothing AndAlso lstFiltriTipiReferto.Count > 0 Then
                    'OTTENGO LA LISTA DEI TIPI REFERTI SPLITTANDO QUELLI CHE SONO COMPOSTI. 
                    '(ALCUNI ITEM DI LSTFILTRITIPIREFERTI SONO COMPOSTI DA PIÙ ID SEPARATI DA; PER EVITARE DI AVERE PIÙ ITEM NELLA LISTA DEI FILTRI LATERALI CON LA STESSA DESCRIZIONE)
                    Dim oLstFiltriTipiReferto As List(Of String) = Filtri.OttieniListaFiltriTipiReferti(lstFiltriTipiReferto)

                    Dim query = (From c In oReferti Where oLstFiltriTipiReferto.Contains(c.IdTipoReferto)).ToList
                    oReferti = query
                End If
            End If
            Return oReferti
        End Function

        ''' <summary>
        ''' Restituisce la lista dei tipi di referto
        ''' Deve essere eseguito dopo la funzione GetData perchè filtra la lista ottenuta dalla cache
        ''' </summary>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetSelectedTipiReferto() As IEnumerable
            Dim listaReferti As List(Of WcfDwhClinico.RefertoListaType) = Me.CacheData
            If listaReferti Is Nothing Then
                Return Nothing
            End If
            Dim ds As New DizionarioTipiRefertoOttieni
            Dim listaIcone As WcfDwhClinico.DizionarioTipiRefertoListaType = ds.GetData()

            'ATTENZIONE: l'ordinamento basato sulle stringhe è CASE SENSITIVE, per questo è stato aggiunto il ToUpper
            Dim filtriTipoReferto = (From c In listaReferti
                                     Order By c.TipoRefertoDescrizione.ToUpper
                                     Select c.TipoRefertoDescrizione, c.IdTipoReferto Where IdTipoReferto <> Nothing Or TipoRefertoDescrizione <> Nothing).Distinct
            Dim oReturn = Filtri.OttieniListaTipiReferti(listaIcone, filtriTipoReferto)

            Return oReturn
        End Function
    End Class

    <DataObjectAttribute()>
    Public Class AccessoDirettoRefertiCercaPerNosologico2
        Inherits CacheDataSource(Of List(Of WcfDwhClinico.RefertoListaType))

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, ByPassaConsenso As Boolean, NumeroNosologico As String, AziendaErogante As String, DallaData As Date, AllaData As Date?, lstFiltriTipiReferto As List(Of String)) As List(Of WcfDwhClinico.RefertoListaType)
            Const MAX_NUM_RECORD As Integer = 1000
            Dim oReferti As List(Of WcfDwhClinico.RefertoListaType)

            Me.CacheDataKey = GetCacheKey(NumeroNosologico, AziendaErogante)

            '
            ' Cerco prima nella cache
            '
            oReferti = Me.CacheData
            If oReferti Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)
                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oRefertiReturn As WcfDwhClinico.RefertiReturn = oWcf.RefertiCercaPerNosologico(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, NumeroNosologico, AziendaErogante)
                    If oRefertiReturn IsNot Nothing Then
                        If oRefertiReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista dei referti.", oRefertiReturn.Errore)
                        Else
                            oReferti = oRefertiReturn.Referti
                        End If
                    End If
                End Using
                If Not oReferti Is Nothing AndAlso oReferti.Count > 0 Then
                    '
                    ' Tolgo dalla lista dei referti i referti singoli( visualizzati in una tab a parte) e filtro per le date
                    '
                    If Not AllaData.HasValue Then
                        AllaData = Now
                    End If
                    'TODO: filtro comunque i referti singoli anche se non dovrebbe servire
                    Dim queryReferti = Filtri.EsclusioneRefertiSingoli(oReferti)
                    queryReferti = (From c In queryReferti Where c.DataReferto >= DallaData And c.DataReferto <= AllaData).ToList
                    oReferti = queryReferti
                End If

                '
                ' Salvo nella cache la lista dei referti senza i referti singoli
                '

                Me.CacheData = oReferti

            End If


            If Not oReferti Is Nothing AndAlso oReferti.Count > 0 Then
                '
                ' Filtro anche per la lista dei tipi di referto selezionati
                '
                If lstFiltriTipiReferto IsNot Nothing AndAlso lstFiltriTipiReferto.Count > 0 Then
                    'OTTENGO LA LISTA DEI TIPI REFERTI SPLITTANDO QUELLI CHE SONO COMPOSTI. 
                    '(ALCUNI ITEM DI LSTFILTRITIPIREFERTI SONO COMPOSTI DA PIÙ ID SEPARATI DA; PER EVITARE DI AVERE PIÙ ITEM NELLA LISTA DEI FILTRI LATERALI CON LA STESSA DESCRIZIONE)
                    Dim oLstFiltriTipiReferto As List(Of String) = Filtri.OttieniListaFiltriTipiReferti(lstFiltriTipiReferto)

                    Dim query = (From c In oReferti Where oLstFiltriTipiReferto.Contains(c.IdTipoReferto)).ToList
                    oReferti = query
                End If
            End If
            Return oReferti
        End Function

        ''' <summary>
        ''' Restituisce la lista dei tipi di referto
        ''' Deve essere eseguito dopo la funzione GetData perchè filtra la lista ottenuta dalla cache
        ''' </summary>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetSelectedTipiReferto(NumeroNosologico As String, AziendaErogante As String) As IEnumerable

            Me.CacheDataKey = GetCacheKey(NumeroNosologico, AziendaErogante)

            Dim listaReferti As List(Of WcfDwhClinico.RefertoListaType) = Me.CacheData
            If listaReferti Is Nothing Then
                Return Nothing
            End If
            Dim ds As New DizionarioTipiRefertoOttieni
            Dim listaIcone As WcfDwhClinico.DizionarioTipiRefertoListaType = ds.GetData()

            'ATTENZIONE: l'ordinamento basato sulle stringhe è CASE SENSITIVE, per questo è stato aggiunto il ToUpper
            Dim filtriTipoReferto = (From c In listaReferti
                                     Order By c.TipoRefertoDescrizione.ToUpper
                                     Select c.TipoRefertoDescrizione, c.IdTipoReferto Where IdTipoReferto <> Nothing Or TipoRefertoDescrizione <> Nothing).Distinct
            Dim oReturn = Filtri.OttieniListaTipiReferti(listaIcone, filtriTipoReferto)

            Return oReturn
        End Function

        ''' <summary>
        ''' Metodo base DA NON UTILIZZARE --> utilizzare quello custom che usa il parametro idPaziente
        ''' </summary>
        Public Overloads Sub ClearCache()

            Throw New NotImplementedException

        End Sub

        Public Overloads Sub ClearCache(Nosologico As String, Azienda As String)

            Dim user As String = HttpContext.Current.User.Identity.Name

            '
            ' Prima di cancellare i dati in cache rigenero la key formata da nosologico e azienda
            '
            Me.CacheDataKey = GetCacheKey(Nosologico, Azienda)
            MyBase.ClearCache()
        End Sub

        ''' <summary>
        '''  Imposta lo stato di un referto a visionato nella Cache dei Referti negli Episodi, per togliere l'evidenziamento dei referti nuovi
        ''' </summary>
        ''' <param name="Nosologico"></param>
        ''' <param name="Azienda"></param>
        Public Sub ImpostaRefertoVisionato(idRefero As Guid, nosologico As String, azienda As String)

            Dim user As String = HttpContext.Current.User.Identity.Name

            '
            ' In questo caso creo una custom key NON basata sull' HashCode della pagina perchè la cache di questo DataSource deve essere condiviso da più pagine.
            '
            Me.CacheDataKey = GetCacheKey(nosologico, azienda)


            If Me.CacheData IsNot Nothing Then

                ' Imposto il referto in cache a visionato
                Dim refertoVariato As WcfDwhClinico.RefertoListaType = Me.CacheData.Where(Function(x) x.Id = idRefero.ToString().ToUpper() And x.NumeroNosologico = nosologico And x.AziendaErogante = azienda).FirstOrDefault()
                If refertoVariato IsNot Nothing Then

                    refertoVariato.Visionato = True
                End If
            End If
        End Sub

        ''' <summary>
        ''' Ottiene la key per la cache da usare all'interno della classe
        ''' </summary>
        ''' <param name="nosologico"></param>
        ''' <param name="azienda"></param>
        ''' <returns></returns>
        Private Function GetCacheKey(nosologico As String, azienda As String) As String
            Dim user As String = HttpContext.Current.User.Identity.Name

            Return $"{user.ToUpper}_AccessoDirettoRefertiCercaPerNosologico2_{nosologico}_{azienda}_{Me.GetType}"

        End Function

    End Class

    <DataObjectAttribute()>
    Public Class AccessoDirettoRefertiCercaPerNumeroReferto
        Inherits CacheDataSource(Of List(Of WcfDwhClinico.RefertoListaType))

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, ByPassaConsenso As Boolean, IdPaziente As Guid, DallaData As Date, AllaData As Date?, NumeroReferto As String, lstFiltriTipiReferto As List(Of String)) As List(Of WcfDwhClinico.RefertoListaType)
            Const MAX_NUM_RECORD As Integer = 1000
            Dim oReferti As List(Of WcfDwhClinico.RefertoListaType)
            'CacheDataKey = String.Format("{0}-AccessoDirettoRefertiCercaPerIdPaziente-{1}", OriginalCacheDatakey, IdPaziente.ToString.ToUpper)
            '
            ' Cerco prima nella cache
            '
            oReferti = Me.CacheData
            If oReferti Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)
                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oRefertiReturn As WcfDwhClinico.RefertiReturn = oWcf.RefertiCercaPerIdPaziente(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, IdPaziente, DallaData, AllaData, Nothing, Nothing, Nothing, Nothing)
                    If oRefertiReturn IsNot Nothing Then
                        If oRefertiReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista dei referti.", oRefertiReturn.Errore)
                        Else
                            oReferti = oRefertiReturn.Referti
                        End If
                    End If
                End Using
                If (Not oReferti Is Nothing) AndAlso (oReferti.Count > 0) AndAlso (Not String.IsNullOrEmpty(NumeroReferto)) Then
                    '
                    ' Filtro i referti per il NumeroReferto solo se NumeroReferto è valorizzato
                    '
                    Dim queryReferti = (From c In oReferti Where c.NumeroReferto = NumeroReferto).ToList
                    oReferti = queryReferti
                End If
                '
                ' Salvo nella cache la lista dei referti senza i referti singoli
                '
                Me.CacheData = oReferti
            End If


            If Not oReferti Is Nothing AndAlso oReferti.Count > 0 Then
                '
                ' Filtro anche per la lista dei tipi di referto selezionati
                '
                If lstFiltriTipiReferto IsNot Nothing AndAlso lstFiltriTipiReferto.Count > 0 Then
                    'OTTENGO LA LISTA DEI TIPI REFERTI SPLITTANDO QUELLI CHE SONO COMPOSTI. 
                    '(ALCUNI ITEM DI LSTFILTRITIPIREFERTI SONO COMPOSTI DA PIÙ ID SEPARATI DA; PER EVITARE DI AVERE PIÙ ITEM NELLA LISTA DEI FILTRI LATERALI CON LA STESSA DESCRIZIONE)
                    Dim oLstFiltriTipiReferto As List(Of String) = Filtri.OttieniListaFiltriTipiReferti(lstFiltriTipiReferto)

                    Dim query = (From c In oReferti Where oLstFiltriTipiReferto.Contains(c.IdTipoReferto)).ToList
                    oReferti = query
                End If
            End If
            Return oReferti
        End Function

        ''' <summary>
        ''' Restituisce la lista dei tipi di referto
        ''' Deve essere eseguito dopo la funzione GetData perchè filtra la lista ottenuta dalla cache
        ''' </summary>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetSelectedTipiReferto() As IEnumerable
            Dim listaReferti As List(Of WcfDwhClinico.RefertoListaType) = Me.CacheData
            If listaReferti Is Nothing Then
                Return Nothing
            End If
            Dim ds As New DizionarioTipiRefertoOttieni
            Dim listaIcone As WcfDwhClinico.DizionarioTipiRefertoListaType = ds.GetData()

            'ATTENZIONE: l'ordinamento basato sulle stringhe è CASE SENSITIVE, per questo è stato aggiunto il ToUpper
            Dim filtriTipoReferto = (From c In listaReferti
                                     Order By c.TipoRefertoDescrizione.ToUpper
                                     Select c.TipoRefertoDescrizione, c.IdTipoReferto Where IdTipoReferto <> Nothing Or TipoRefertoDescrizione <> Nothing).Distinct
            Dim oReturn = Filtri.OttieniListaTipiReferti(listaIcone, filtriTipoReferto)

            Return oReturn
        End Function

        '''' <summary>
        '''' Overloads del metodo che cancella la cache
        '''' Accetta il parametro IdPaziente per ricreare la CacheDataKey corretta prima di cancellare la cache
        '''' </summary>
        '''' <param name="IdPaziente"></param>
        'Public Overloads Sub ClearCache(IdPaziente As String)
        '    CacheDataKey = String.Format("{0}-AccessoDirettoRefertiCercaPerIdPaziente-{1}", OriginalCacheDatakey, IdPaziente.ToString.ToUpper)
        '    MyBase.ClearCache()
        'End Sub
    End Class

    <DataObjectAttribute()>
    Public Class AccessoDirettoPazienteOttieniPerAnagrafica

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, CodiceAnagrafica As String, NomeAnagrafica As String) As WcfDwhClinico.PazienteType
            Dim oPazienti As WcfDwhClinico.PazienteType = Nothing
            If oPazienti Is Nothing Then
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)
                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oPazientiReturn As WcfDwhClinico.PazienteReturn = oWcf.PazienteOttieniPerAnagrafica(Token, CodiceAnagrafica, NomeAnagrafica, False)
                    If oPazientiReturn IsNot Nothing Then
                        If oPazientiReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista pazienti.", oPazientiReturn.Errore)
                        Else
                            oPazienti = oPazientiReturn.Paziente
                        End If
                    End If
                End Using
            End If
            Return oPazienti
        End Function
    End Class

    <DataObjectAttribute()>
    Public Class AccessoDirettoRefertoOttieniPerIdEsterno
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, IdEsternoReferto As String) As WcfDwhClinico.RefertoType
            Dim oReferto As WcfDwhClinico.RefertoType = Nothing
            If oReferto Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)

                    Dim oRefertoReturn As WcfDwhClinico.RefertoReturn = oWcf.RefertoOttieniPerIdEsterno(Token, IdEsternoReferto)
                    If oRefertoReturn IsNot Nothing Then
                        If oRefertoReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura del referto", oRefertoReturn.Errore)
                        Else
                            oReferto = oRefertoReturn.Referto
                        End If
                    End If
                End Using
            End If
            Return oReferto
        End Function
    End Class

    <DataObjectAttribute()>
    Public Class AccessoDirettoRefertoOttieniPerId

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, IdReferto As Guid) As WcfDwhClinico.RefertoType
            Dim oReferto As WcfDwhClinico.RefertoType = Nothing
            If oReferto Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)

                    Dim oRefertoReturn As WcfDwhClinico.RefertoReturn = oWcf.RefertoOttieniPerId(Token, IdReferto)
                    Utility.VerificaInformazioni(oRefertoReturn)
                    If oRefertoReturn IsNot Nothing Then
                        If oRefertoReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura del referto", oRefertoReturn.Errore)
                        Else
                            oReferto = oRefertoReturn.Referto
                        End If
                    End If
                End Using
            End If
            Return oReferto
        End Function
    End Class

    <DataObjectAttribute()>
    Public Class AccessoDirettoEpisodioOttieniPerNosologico
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, NumeroNosologico As String, AziendaErogante As String) As WcfDwhClinico.EpisodioType

            Dim oEpisodio As WcfDwhClinico.EpisodioType = Nothing
            If oEpisodio Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Call Utility.SetWcfDwhClinicoCredential(oWcf)

                    Dim oEpisodioReturn As WcfDwhClinico.EpisodioReturn = oWcf.EpisodioOttieniPerNosologico(Token, NumeroNosologico, AziendaErogante)

                    If oEpisodioReturn IsNot Nothing Then
                        If oEpisodioReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista degli episodi.", oEpisodioReturn.Errore)
                        Else
                            oEpisodio = oEpisodioReturn.Episodio
                        End If
                    End If
                End Using

            End If
            Return oEpisodio
        End Function
    End Class

    <DataObjectAttribute()>
    Public Class AccessoDirettoNoteAnamnesticheCercaPerIdPaziente

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, IdPaziente As Guid, DallaData As Date, ByPassaConsenso As Boolean, AllaData As Date?) As WcfDwhClinico.NoteAnamnesticheListaType
            Const MAX_NUM_RECORD As Integer = 1000

            '
            'Definisco l'oggetto da restituire.
            '
            Dim oNoteAnamnestiche As WcfDwhClinico.NoteAnamnesticheListaType = Nothing

            '
            ' Recupero dati dal WS
            '
            Using oWcf As New WcfDwhClinico.ServiceClient
                Call Utility.SetWcfDwhClinicoCredential(oWcf)
                '
                ' Chiamata al metodo che restituisce i dati
                '
                Dim oNoteAnamnesticheReturn As WcfDwhClinico.NoteAnamnesticheReturn = oWcf.NoteAnamnesticheCercaPerIdPaziente(Token, MAX_NUM_RECORD, Ordinamento, ByPassaConsenso, IdPaziente, DallaData, AllaData)
                If oNoteAnamnesticheReturn IsNot Nothing Then
                    If oNoteAnamnesticheReturn.Errore IsNot Nothing Then
                        Throw New WsDwhException("Si è verificato un errore durante la lettura della lista delle note anamnestiche.", oNoteAnamnesticheReturn.Errore)
                    Else
                        oNoteAnamnestiche = oNoteAnamnesticheReturn.NoteAnamnestiche
                    End If
                End If
            End Using

            Return oNoteAnamnestiche
        End Function
    End Class

    <DataObjectAttribute()>
    Public Class AccessoDirettoNotaAnamnesticaOttieniPerId

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, IdNotaAnamnestica As Guid) As WcfDwhClinico.NotaAnamnesticaType
            Dim oNotaAnamnestica As WcfDwhClinico.NotaAnamnesticaType = Nothing

            '
            ' Recupero dati dal WS
            '
            Using oWcf As New WcfDwhClinico.ServiceClient
                Call Utility.SetWcfDwhClinicoCredential(oWcf)

                Dim oNotaAnamnesticaReturn As WcfDwhClinico.NotaAnamnesticaReturn = oWcf.NotaAnamnesticaOttieniPerId(Token, IdNotaAnamnestica)
                If oNotaAnamnesticaReturn IsNot Nothing Then
                    If oNotaAnamnesticaReturn.Errore IsNot Nothing Then
                        Throw New WsDwhException("Si è verificato un errore durante la lettura della nota anamnestica.", oNotaAnamnesticaReturn.Errore)
                    Else
                        oNotaAnamnestica = oNotaAnamnesticaReturn.NotaAnamnestica
                    End If
                End If
            End Using

            Return oNotaAnamnestica
        End Function
    End Class


#End Region

    Public Class Filtri
        Public Shared Function EsclusioneRefertiSingoli(oReferti As WcfDwhClinico.RefertiListaType) As List(Of WcfDwhClinico.RefertoListaType)
            'MODIFICA ETTORE 2019-02-07: ottengo la lista dei referti singoli dalla tabella TipiReferto
            Dim oDsTipiReferto As New CustomDataSource.DizionarioTipiRefertoOttieni
            Dim oRefertiSingoli As WcfDwhClinico.DizionarioTipiRefertoListaType = oDsTipiReferto.GetDataRefertiSingoli()
            Dim queryReferti As List(Of WcfDwhClinico.RefertoListaType) = (From r In oReferti Where Not (If((From rs In oRefertiSingoli Where r.AziendaErogante.ToUpper = rs.AziendaErogante.ToUpper And r.SistemaErogante.ToUpper = rs.SistemaErogante.ToUpper Select rs).ToList.Count > 0, True, False))).ToList

            Return queryReferti
        End Function

        Public Shared Function OttengoRefertiSingoli(oReferti As WcfDwhClinico.RefertiListaType) As List(Of WcfDwhClinico.RefertoListaType)
            'MODIFICA ETTORE 2019-02-07: ottengo la lista dei referti singoli dalla tabella TipiReferto
            Dim oDsTipiReferto As New CustomDataSource.DizionarioTipiRefertoOttieni
            Dim oRefertiSingoli As WcfDwhClinico.DizionarioTipiRefertoListaType = oDsTipiReferto.GetDataRefertiSingoli()
            Dim queryReferti As List(Of WcfDwhClinico.RefertoListaType) = (From r In oReferti Where (If((From rs In oRefertiSingoli Where r.AziendaErogante.ToUpper = rs.AziendaErogante.ToUpper And r.SistemaErogante.ToUpper = rs.SistemaErogante.ToUpper Select rs).ToList.Count > 0, True, False))).ToList

            Return queryReferti
        End Function

        Public Shared Function OttieniListaTipiReferti(listaIcone As WcfDwhClinico.DizionarioTipiRefertoListaType, filtriTipoReferto As IEnumerable(Of String)) As List(Of ChkBoxListItem)
            'OTTENGO IL DISTINC DELLE DESCRIZIONI.
            'PER EVITARE CHE VENGANO MOSTRATI PIÙ FILTRI CON LA STESSA DESCRIZIONE.
            Dim oDescDistinct As List(Of String) = (From c In listaIcone Join lr In filtriTipoReferto On c.Id Equals lr Select c.Descrizione).Distinct.ToList

            Dim oReturn As New List(Of ChkBoxListItem)

            'TROVO I CODICI ASSOCIATI AD OGNI DESCRIZIONE
            For Each sDesc As String In oDescDistinct
                Dim listaId As List(Of String) = (From c In listaIcone Where c.Descrizione = sDesc Select c.Id).ToList

                'CREO L'OGGETTO CONTENENTE L'ID E LA DESCRIZIONE.
                Dim oItem As New ChkBoxListItem

                Dim sListaId As String = String.Empty
                For Each sId As String In listaId
                    sListaId = sListaId & sId & ";"
                Next

                'TOLGO L'ULTIMO ;
                sListaId = sListaId.TrimEnd(";")

                'VALORIZZO L'OGGETTO.
                oItem.Id = sListaId
                oItem.Descrizione = sDesc

                'AGGIUNGO L'OGGETTO ALLA LISTA DA RESTITURIE.
                oReturn.Add(oItem)
            Next

            Return oReturn
        End Function

        'RAPPRESENTA L'OGGETTO RESTITUITO ALLA CHECKBOXLIST DEI TIPI REFERTO.
        Public Class ChkBoxListItem
            Public Property Id As String
            Public Property Descrizione As String
        End Class


        Public Shared Function OttieniListaFiltriTipiReferti(lstFiltriTipiReferto As List(Of String)) As List(Of String)
            Dim oLstFiltriTipiReferto As New List(Of String)

            'ALCUNI ELEMENTI DI LSTFILTRITIPIREFERTO POTREBBERO ESSERE 2 O PIÙ ID CONCATENATI DA ;.
            'QUESTO PER EVITARE CHE NELLA LISTA DEI TIPI REFERTO VENGANO MOSTRATI PIÙ FILTRI CON LA STESSA DESCRIZIONE
            For Each sId As String In lstFiltriTipiReferto
                Dim oIds As String() = sId.Split(";")
                For Each s As String In oIds
                    oLstFiltriTipiReferto.Add(s)
                Next
            Next

            Return oLstFiltriTipiReferto
        End Function
    End Class

    Public Class EventoPrenotazioneOttieniPerIdRicovero
        '
        ' Questa funzione viene usata per ricavare eventuale evento di prenotazione di un ricovero sia per accesso standard che accesso diretto
        '
        Public Function GetData(Token As WcfDwhClinico.TokenType, oEpisodio As WcfDwhClinico.EpisodioType) As WcfDwhClinico.EventoType
            Dim oEventoListaAttesa As WcfDwhClinico.EventoType = Nothing

            If oEpisodio IsNot Nothing Then
                If String.Compare(oEpisodio.Categoria, "Ricovero", True) = 0 Then
                    Using oWcf As New WcfDwhClinico.ServiceClient
                        Call Utility.SetWcfDwhClinicoCredential(oWcf)

                        Dim sNumeroNosologico As String = oEpisodio.NumeroNosologico
                        Dim sAziendaERogante As String = oEpisodio.AziendaErogante
                        '
                        ' Cerco eventuale lista di prenotazione se l'episodio corrente non è una prenotazione
                        '
                        Dim oListaAttesaPerNosologicoReturn As WcfDwhClinico.StringReturn = Nothing
                        '
                        ' La ricerca delle prenotazioni la faccio solo se l'episodio corente è un RICOVERO (non la faccio se è una PRENOTAZIONE) 
                        '
                        oListaAttesaPerNosologicoReturn = oWcf.ListaAttesaPerNosologico(Token, sNumeroNosologico, sAziendaERogante)

                        If Not oListaAttesaPerNosologicoReturn Is Nothing Then
                            If oListaAttesaPerNosologicoReturn.Errore IsNot Nothing Then
                                Throw New WsDwhException("Si è verificato un errore durante la ricerca della lista di attesa associata all'episodio.", oListaAttesaPerNosologicoReturn.Errore)
                            Else
                                Dim sNumeroNosologicoListaAttesa As String = oListaAttesaPerNosologicoReturn.Valore
                                If Not String.IsNullOrEmpty(sNumeroNosologicoListaAttesa) Then
                                    '
                                    ' Cerco il dettaglio della lista di attesa per poi ottenerne la lista degli eventi
                                    '
                                    Dim oEpisodioListaAttesaReturn As WcfDwhClinico.EpisodioReturn = oWcf.EpisodioOttieniPerNosologico(Token, sNumeroNosologicoListaAttesa, sAziendaERogante)
                                    If oEpisodioListaAttesaReturn IsNot Nothing Then
                                        If oEpisodioListaAttesaReturn.Errore IsNot Nothing Then
                                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista degli eventi dell'episodio di lista di attesa.", oEpisodioListaAttesaReturn.Errore)
                                        Else
                                            Dim oEventiListaAttesa As WcfDwhClinico.EventiType = Nothing
                                            If oEpisodioListaAttesaReturn.Episodio IsNot Nothing Then
                                                If oEpisodioListaAttesaReturn.Episodio.Stato IsNot Nothing Then
                                                    Dim sCodice As String = oEpisodioListaAttesaReturn.Episodio.Stato.Codice
                                                    '
                                                    ' Solo se l'episodio di è CHIUSO (codice=22), devo fare vedere i suoi eventi nella lista degli eventi del nosologico associato
                                                    '
                                                    If sCodice = "22" Then 'Prenotazione CHIUSA
                                                        '
                                                        ' Scelgo l'evento a data minima 
                                                        ' Sostituisco TipoEventoCodice con "P" 
                                                        ' Sostituisco TipoEventoCodiceDesscrizione con "Prenotazione" 
                                                        '
                                                        oEventiListaAttesa = oEpisodioListaAttesaReturn.Episodio.Eventi
                                                        '
                                                        ' Aggiungo gli eventi di lista di attesa 
                                                        '
                                                        If oEventiListaAttesa IsNot Nothing Then
                                                            If oEventiListaAttesa.Count > 0 Then
                                                                '
                                                                ' Prendo il primo evento, quello con dataEvento minima (dovrebbe essere IL) e poi ne modifico il codice e la descrizione:
                                                                '                                                                    '
                                                                Dim oEventiListaAttesaOrdinati As List(Of WcfDwhClinico.EventoType) = (From p In oEventiListaAttesa Order By p.DataEvento).ToList
                                                                '
                                                                ' Modifico il primo evento della lista di attesa con TipoEventoCodice con "P" 
                                                                ' Modifico il primo evento della lista di attesa TipoEventoCodiceDesscrizione con "Prenotazione" 
                                                                '
                                                                oEventiListaAttesaOrdinati(0).TipoEventoCodice = "P"
                                                                oEventiListaAttesaOrdinati(0).TipoEventoDescrizione = "Prenotazione"
                                                                '
                                                                ' Valorizzo la variabile da restituire
                                                                '
                                                                oEventoListaAttesa = oEventiListaAttesaOrdinati(0)
                                                            End If 'If oEventiListaAttesa.Count > 0
                                                        End If 'If oEventiListaAttesa IsNot Nothing
                                                    End If 'If codice = "22"
                                                End If 'If oEpisodioListaAttesaReturn.Episodio.Stato IsNot Nothing
                                            End If 'If oEpisodioListaAttesaReturn.Episodio IsNot Nothing
                                        End If ' If oEpisodioListaAttesaReturn.Errore IsNot Nothing
                                    End If 'If oEpisodioListaAttesaReturn IsNot Nothing The
                                End If 'If Not String.IsNullOrEmpty(sNumeroNosologicoListaAttesa)
                            End If 'If oListaAttesaPerNosologicoReturn.Errore IsNot Nothing
                        End If 'If Not oListaAttesaPerNosologicoReturn Is Nothing
                    End Using
                End If
            End If
            '
            '
            '
            Return oEventoListaAttesa
        End Function

    End Class

    <DataObjectAttribute()>
    Public Class SacUtentiCerca
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Ordinamento As String, Utente As String, Descrizione As String, Cognome As String, Nome As String, CodiceFiscale As String, Matricola As String, Email As String, Attivo As Boolean?, CodiceRuolo As String) As WcfSacRoleManager.UtentiListaType
            Const MAX_NUM_RECORD As Integer = 1000
            Dim oUtenti As WcfSacRoleManager.UtentiListaType = Nothing

            '
            'Eseguo la chiamata al wcf del SAC.
            '
            Using wcfSac As New WcfSacRoleManager.RoleManagerClient
                Call Utility.SetWcfSacCredential(wcfSac)
                Dim oUtentiReturn As WcfSacRoleManager.UtentiReturn = wcfSac.UtentiCerca(MAX_NUM_RECORD, Ordinamento, Utente, Descrizione, Cognome, Nome, CodiceFiscale, Matricola, Email, Attivo, CodiceRuolo)

                If oUtentiReturn IsNot Nothing Then
                    If oUtentiReturn.Errore IsNot Nothing Then
                        Throw New WsSacException("Si è verificato un errore durante la lettura degli utenti.", oUtentiReturn.Errore)
                    Else
                        oUtenti = oUtentiReturn.Utenti
                    End If
                End If
            End Using

            '
            'Restituisco gli utenti.
            '
            Return oUtenti
        End Function

        ''' <summary>
        ''' Funzione che restituisce la distinct degli utenti SAC.
        ''' Utilizzata nella modale di invio link ad accesso diretto, per cercare gli utenti.
        ''' </summary>
        ''' <param name="Ordinamento"></param>
        ''' <param name="Utente"></param>
        ''' <param name="Descrizione"></param>
        ''' <param name="Cognome"></param>
        ''' <param name="Nome"></param>
        ''' <param name="CodiceFiscale"></param>
        ''' <param name="Matricola"></param>
        ''' <param name="Email"></param>
        ''' <param name="Attivo"></param>
        ''' <param name="CodiceRuolo"></param>
        ''' <returns></returns>
        Public Function GetDataDistinct(Ordinamento As String, Utente As String, Descrizione As String, Cognome As String, Nome As String, CodiceFiscale As String, Matricola As String, Email As String, Attivo As Boolean?, CodiceRuolo As String) As List(Of Utente)
            Const MAX_NUM_RECORD As Integer = 1000
            Dim oUtenti As List(Of Utente) = Nothing

            '
            'Eseguo la chiamata al wcf del SAC.
            '
            Using wcfSac As New WcfSacRoleManager.RoleManagerClient
                Call Utility.SetWcfSacCredential(wcfSac)
                Dim oUtentiReturn As WcfSacRoleManager.UtentiReturn = wcfSac.UtentiCerca(MAX_NUM_RECORD, Ordinamento, Utente, Descrizione, Cognome, Nome, CodiceFiscale, Matricola, Email, Attivo, CodiceRuolo)

                If oUtentiReturn IsNot Nothing Then
                    If oUtentiReturn.Errore IsNot Nothing Then
                        Throw New WsSacException("Si è verificato un errore durante la lettura degli utenti.", oUtentiReturn.Errore)
                    Else
                        oUtenti = getDistinctUtenti(oUtentiReturn.Utenti)
                    End If
                End If
            End Using

            '
            'Restituisco gli utenti.
            '
            Return oUtenti
        End Function

        Private Function getDistinctUtenti(Utenti As WcfSacRoleManager.UtentiListaType) As List(Of Utente)
            Dim listaUtenti As New List(Of Utente)

            If Utenti IsNot Nothing AndAlso Utenti.Count > 0 Then
                Dim listaEmail = (From i In Utenti Where Not String.IsNullOrEmpty(i.Email) Select Email = i.Email?.ToLower, i?.Nome, i?.Cognome)?.Distinct.ToList()

                If listaEmail IsNot Nothing AndAlso listaEmail.Count > 0 Then
                    listaUtenti = (From i In listaEmail Select New Utente With {.Nome = i.Nome?.ToLower, .Cognome = i.Cognome?.ToLower, .Email = i.Email}).ToList()
                End If
            End If

            Return listaUtenti
        End Function
    End Class

    Public Class Utente
        Public Property Nome() As String
        Public Property Cognome() As String
        Public Property Email() As String
    End Class

    Public Class SistemiErogantiDocumenti
        Inherits CacheDataSource(Of Data.DocumentiDataSet.FevsSistemiErogantiDocumentiRow)

        Public Function GetData(ByVal sAziendaErogante As String, ByVal sSistemaErogante As String) As Data.DocumentiDataSet.FevsSistemiErogantiDocumentiRow
            Dim oRet As Data.DocumentiDataSet.FevsSistemiErogantiDocumentiRow
            '
            ' Cerco prima nella cache
            '
            oRet = Me.CacheData
            If oRet Is Nothing Then
                Dim odt As Data.DocumentiDataSet.FevsSistemiErogantiDocumentiDataTable
                Using oDataReferti As New Data.Documenti
                    odt = oDataReferti.GetDataSistemiErogantiDocumenti(sAziendaErogante, sSistemaErogante)
                End Using
                If Not odt Is Nothing AndAlso odt.Rows.Count > 0 Then
                    oRet = odt(0)
                    Me.CacheData = oRet
                End If
            End If
            '
            '
            '
            Return oRet
        End Function

    End Class

    <DataObjectAttribute()>
    Public Class EmailDestinatariPreferitiCerca
        Inherits CacheDataSource(Of Data.EmailDataSet.DestinatariPreferitiCercaDataTable)

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(ByVal EmailMittente As String) As Data.EmailDataSet.DestinatariPreferitiCercaDataTable
            Dim user As String = HttpContext.Current.User.Identity.Name
            Dim oPreferiti As Data.EmailDataSet.DestinatariPreferitiCercaDataTable
            '
            ' Ceeo cache custom per questa classe
            '
            CacheDataKey = Me.CustomChacheKey
            '
            ' Modifico la durata della cache rispetto al valore originale
            '
            CacheDuration = 10
            '
            ' Cerco prima nella cache
            '
            oPreferiti = Me.CacheData
            If oPreferiti Is Nothing Then
                Dim oEmail As New Data.Email
                oPreferiti = oEmail.DestinatariPreferitiCerca(EmailMittente)
                '
                ' Salvo nella cache
                '
                Me.CacheData = oPreferiti
            End If
            Return oPreferiti
        End Function

        ''' <summary>
        ''' Restituisce la custom key
        ''' In questo caso creo una custom key NON basata sull' HashCode della pagina perchè la cache di questo DataSource deve essere condiviso da più pagine.
        ''' </summary>
        ''' <returns></returns>
        Public ReadOnly Property CustomChacheKey() As String
            Get
                Dim user As String = HttpContext.Current.User.Identity.Name
                Return String.Format("{0}_DestinatariPreferitiCerca_{1}", user.ToUpper, Me.GetType)
            End Get
        End Property

        ''' <summary>
        ''' Elimina la cache utilizzando la custom key
        ''' </summary>
        Public Overloads Sub ClearCache()
            CacheDataKey = Me.CustomChacheKey
            MyBase.ClearCache()
        End Sub
    End Class

End Namespace