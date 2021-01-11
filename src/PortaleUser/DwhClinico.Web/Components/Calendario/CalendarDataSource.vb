Imports System.ComponentModel
Imports DwhClinico.Web.CustomDataSource

Public Class CalendarDataSource
    Inherits CacheDataSource(Of List(Of WcfDwhClinico.RefertoListaType))

    Const MAX_NUM_RECORD As Integer = 1000

    '
    ' ************************************************** REFERTI *************************************************   
    '
    Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, IdPaziente As Guid, DallaData As Date, ByPassaConsenso As Boolean, AllaData As Date?, lstFiltriTipiReferto As List(Of String)) As List(Of WcfDwhClinico.RefertoListaType)
        Dim oReferti As List(Of WcfDwhClinico.RefertoListaType)


        Dim user As String = HttpContext.Current.User.Identity.Name

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
    ''' Ottiene la key per la cache da usare all'interno della classe
    ''' </summary>
    ''' <param name="idPaziente"></param>
    Private Function GetCacheKey(idPaziente As Guid) As String
        Dim user As String = HttpContext.Current.User.Identity.Name

        Return $"{user.ToUpper}_RefertiCalendarioCercaPerIdPaziente_{idPaziente.ToString().ToUpper()}_{Me.GetType}"

    End Function

    Public Function GetRefertiByData(Data As Date, idPaziente As Guid) As List(Of WcfDwhClinico.RefertoListaType)
        Dim oReferti As List(Of WcfDwhClinico.RefertoListaType)

        CacheDataKey = GetCacheKey(idPaziente)

        '
        ' Cerco prima nella cache
        '
        oReferti = Me.CacheData

        If oReferti IsNot Nothing Then
            oReferti = oReferti.Where(Function(x) x.DataEvento.Date = Data.Date).ToList()
        End If

        Return oReferti

    End Function

    ''' <summary>
    '''  Imposta lo stato di un referto a visionato nella Cache del calendario, per togliere l'evidenziamento dei referti nuovi
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


    '
    ' ************************************************** EPISODI *************************************************   
    '
    Public Class EpisodiCercaPerIdPaziente
        Inherits CacheDataSource(Of List(Of WcfDwhClinico.EpisodioListaType))

        Public Function GetData(Token As WcfDwhClinico.TokenType, Ordinamento As String, IdPaziente As Guid, ByPassaConsenso As Boolean, DallaData As Date, AllaData As Date?) As List(Of WcfDwhClinico.EpisodioListaType)
            Dim oEpisodi As List(Of WcfDwhClinico.EpisodioListaType)
            '
            ' Impostazione di un nome custum per la key della cache
            '
            Me.CacheDataKey = GetCacheKey(IdPaziente)
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

        ''' <summary>
        ''' Metodo custum per cancellare la cache dell'ObjectDataSource in base sull'Id del paziente.
        ''' </summary>
        ''' <param name="idPaziente"></param>
        Public Overloads Sub ClearCache(idPaziente As Guid)
            Me.CacheDataKey = GetCacheKey(idPaziente)
            MyBase.ClearCache()
        End Sub

        ''' <summary>
        ''' Ottiene la key per la cache da usare all'interno della classe
        ''' </summary>
        ''' <param name="idPaziente"></param>
        Private Function GetCacheKey(idPaziente As Guid) As String
            Dim user As String = HttpContext.Current.User.Identity.Name

            Return $"{user.ToUpper}_EpisodiCalendarioCercaPerIdPaziente_{idPaziente.ToString().ToUpper()}_{Me.GetType}"

        End Function

    End Class

End Class


