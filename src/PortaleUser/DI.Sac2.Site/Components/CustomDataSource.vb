Imports System.ComponentModel

Namespace CustomDataSource

    Public Class CustomDataSourceUtility
        Public Const _MaxNumRecord As Integer = 100

        ''' <summary>
        ''' Metodo di creazione delle credenziali di accesso al wcf.
        ''' </summary>
        ''' <param name="oWs"></param>
        Public Shared Sub SetCredentials(ByVal oWs As WcfSacPazienti.PazientiClient)
            'autenticazione in BASIC con utente e password lette da file di configurazione
            Utility.SetWCFCredentials(oWs.ChannelFactory.Endpoint.Binding, oWs.ClientCredentials, My.Settings.WsSac_User, My.Settings.WsSac_Password)
        End Sub
    End Class

    <DataObject(True)>
    Public Class PazientiCerca
        ''' <summary>
        ''' Restituisce la lista dei pazienti in base al medico di base.
        ''' </summary>
        ''' <param name="Token"></param>
        ''' <param name="Ordinamento"></param>
        ''' <param name="MedicoDiBaseCodiceFiscale"></param>
        ''' <param name="Cognome"></param>
        ''' <param name="Nome"></param>
        ''' <param name="DataNascita"></param>
        ''' <param name="LuogoNascita"></param>
        ''' <param name="CodiceFiscale"></param>
        ''' <param name="TesseraSanitaria"></param>
        ''' <param name="AnnoNascita"></param>
        ''' <param name="ComuneResidenzaNome"></param>
        ''' <param name="MedicoDiBaseCognome"></param>
        ''' <param name="MedicoDiBaseNome"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfSacPazienti.TokenType, ByVal Ordinamento As String, ByVal MedicoDiBaseCodiceFiscale As String, ByVal Cognome As String, ByVal Nome As String, ByVal DataNascita As System.Nullable(Of Date), ByVal LuogoNascita As String, ByVal CodiceFiscale As String, ByVal TesseraSanitaria As String, ByVal AnnoNascita As System.Nullable(Of Integer), ByVal ComuneResidenzaNome As String, ByVal MedicoDiBaseCognome As String, ByVal MedicoDiBaseNome As String) As WcfSacPazienti.PazientiListaType
            'Dichiaro l'oggetto da restituire.
            Dim pazientiListaType As WcfSacPazienti.PazientiListaType

            Using Wcf As New WcfSacPazienti.PazientiClient

                'Setto le credenziali per connettermi al SAC.
                CustomDataSourceUtility.SetCredentials(Wcf)

                'Ottengo i dati
                Dim pazientiReturn As WcfSacPazienti.PazientiReturn = Wcf.PazientiCercaPerMedicoBase(Token, CustomDataSourceUtility._MaxNumRecord, Ordinamento, MedicoDiBaseCodiceFiscale, Cognome, Nome, DataNascita, LuogoNascita, CodiceFiscale, TesseraSanitaria, AnnoNascita, ComuneResidenzaNome, MedicoDiBaseCognome, MedicoDiBaseNome)

                'Testo se oReturn non è vuoto.
                If pazientiReturn IsNot Nothing Then

                    'Se il nodo Errore non è vuoto allora eseguo il throw di una custom exception.
                    If pazientiReturn.Errore IsNot Nothing Then
                        Throw New CustomDataSourceException("Si è verificato un errore durante la lettura della lista pazienti.", pazientiReturn.Errore.Codice, pazientiReturn.Errore.Descrizione)
                    Else
                        'Ottengo il nodo Pazienti
                        pazientiListaType = pazientiReturn.Pazienti
                    End If
                End If
            End Using

            'Restituisco l'oggetto.
            Return pazientiListaType
        End Function
    End Class

    <DataObject(True)>
    Public Class PazientiOttieniPerId
        Inherits CacheDataSource(Of WcfSacPazienti.PazienteType)

        ''' <summary>
        ''' Metodo che restituisce un paziente in base al suo id
        ''' </summary>
        ''' <param name="Token"></param>
        ''' <param name="Id"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfSacPazienti.TokenType, Id As Guid) As WcfSacPazienti.PazienteType
            'Dichiaro l'oggetto da restituire.
            Dim pazienteType As WcfSacPazienti.PazienteType

            pazienteType = Me.CacheData

            If pazienteType Is Nothing Then
                Using Wcf As New WcfSacPazienti.PazientiClient

                    'Setto le credenziali per connettermi al SAC.
                    CustomDataSourceUtility.SetCredentials(Wcf)

                    'Ottengo i dati
                    Dim pazienteReturn As WcfSacPazienti.PazienteReturn = Wcf.PazienteOttieniPerId(Token, Id)

                    'Testo se oReturn non è vuoto.
                    If pazienteReturn IsNot Nothing Then

                        'Se il nodo Errore non è vuoto allora eseguo il throw di una custom exception.
                        If pazienteReturn.Errore IsNot Nothing Then
                            Throw New CustomDataSourceException("Si è verificato un errore durante la lettura del paziente.", pazienteReturn.Errore.Codice, pazienteReturn.Errore.Descrizione)
                        Else
                            'Ottengo il nodo Paziente
                            pazienteType = pazienteReturn.Paziente
                        End If
                    End If
                End Using

                '
                ' Salvo nella cache la lista dei referti senza i referti singoli
                '
                Me.CacheData = pazienteType
            End If


            'Restituisco l'oggetto.
            Return pazienteType
        End Function

    End Class

#Region "Esenzioni"

    <DataObject(True)>
    Public Class EsenzioniPaziente

        ''' <summary>
        ''' Metodo che restituisce le esenzioni di un paziente in base al suo id
        ''' </summary>
        ''' <param name="Token"></param>
        ''' <param name="Id"></param>
        ''' <param name="Attive">True: solo le attive; False: solo le disattive; nothing: tutte</param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfSacPazienti.TokenType, Id As Guid, ByVal Attive As Boolean?) As WcfSacPazienti.EsenzioniType
            'Dichiaro l'oggetto da restituire.
            Dim esenzioniType As WcfSacPazienti.EsenzioniType = Nothing

            'uso la customDataSource "PazientiOttieniPerId" per ottenere il paziente.
            'ottengo i dati dalla cache per ottenere le esenzioni.
            Dim customDataSource As New PazientiOttieniPerId
            'Ottengo i dati
            Dim pazienteType As WcfSacPazienti.PazienteType = customDataSource.GetData(Token, Id)

            'Testo se oReturn non è vuoto.
            If pazienteType IsNot Nothing Then
                'Ottengo il nodo Esenzioni
                esenzioniType = pazienteType.Esenzioni
            End If

            '
            ' Filtro in base al parametro Attive
            '
            If (esenzioniType IsNot Nothing) AndAlso (esenzioniType.Count > 0) Then
                If Attive.HasValue Then
                    Dim oOggi As DateTime = Now.Date
                    Dim oTempList As List(Of WcfSacPazienti.EsenzioneType) = Nothing
                    Dim esenzioniTypeFiltered As New WcfSacPazienti.EsenzioniType
                    If Attive.Value = True Then
                        'Solo le attive
                        oTempList = (From c In esenzioniType Where IsNull(c.DataInizioValidita, oOggi) <= oOggi And oOggi <= IsNull(c.DataFineValidita, oOggi) Order By c.DataInizioValidita Ascending).ToList
                    Else
                        'Solo le disattive
                        oTempList = (From c In esenzioniType Where Not (IsNull(c.DataInizioValidita, oOggi) <= oOggi And oOggi <= IsNull(c.DataFineValidita, oOggi)) Order By c.DataInizioValidita Ascending).ToList
                    End If
                    For Each oItem As WcfSacPazienti.EsenzioneType In oTempList
                        esenzioniTypeFiltered.Add(oItem)
                    Next
                    '
                    ' Imposto l'oggetto da restituire con i dati filtrati
                    '
                    esenzioniType = esenzioniTypeFiltered
                End If
            End If
            '
            ' Restituisco l'oggetto
            '
            Return esenzioniType
        End Function

        Private Function IsNull(ByVal oData1 As DateTime?, ByVal oOggi As DateTime) As DateTime
            If Not oData1.HasValue Then oData1 = oOggi
            Return oData1.Value
        End Function

    End Class





    <DataObject(True)>
    Public Class EsenzionePaziente

        ''' <summary>
        ''' Restituisce una esenzione di un paziente per idEsenzione
        ''' </summary>
        ''' <param name="Token"></param>
        ''' <param name="IdPaziente"></param>
        ''' <param name="IdEsenzione"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfSacPazienti.TokenType, IdPaziente As Guid, IdEsenzione As Guid) As WcfSacPazienti.EsenzioneType
            'Dichiaro l'oggetto da restituire.
            Dim esenzioneType As WcfSacPazienti.EsenzioneType = Nothing

            'uso la customDataSource "PazientiOttieniPerId" per ottenere il paziente.
            'ottengo i dati dalla cache per ottenere le esenzioni.
            Dim customDataSource As New EsenzioniPaziente
            'Ottengo i dati
            Dim esenzioniType As WcfSacPazienti.EsenzioniType = customDataSource.GetData(Token, IdPaziente, Nothing)

            'Testo se oReturn non è vuoto.
            If esenzioniType IsNot Nothing Then
                Dim listaEsenzioniById = (From esenzione In esenzioniType Where esenzione.Id.ToUpper = IdEsenzione.ToString.ToUpper Select esenzione).ToList()

                If listaEsenzioniById IsNot Nothing AndAlso listaEsenzioniById.Count > 0 Then
                    esenzioneType = listaEsenzioniById.First()
                End If
            End If

            'Restituisco l'oggetto.
            Return esenzioneType
        End Function

    End Class
#End Region

#Region "Consensi"

    <DataObject(True)>
    Public Class ConsensiPaziente

        ''' <summary>
        ''' Metodo che restituisce i consensi di un paziente in base al suo id
        ''' </summary>
        ''' <param name="Token"></param>
        ''' <param name="Id"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfSacPazienti.TokenType, Id As Guid) As WcfSacPazienti.ConsensiType
            'Dichiaro l'oggetto da restituire.
            Dim consensiType As WcfSacPazienti.ConsensiType = Nothing

            'uso la customDataSource "PazientiOttieniPerId" per ottenere il paziente.
            'ottengo i dati dalla cache per ottenere le esenzioni.
            Dim customDataSource As New PazientiOttieniPerId
            'Ottengo i dati
            Dim pazienteType As WcfSacPazienti.PazienteType = customDataSource.GetData(Token, Id)

            'Testo se oReturn non è vuoto.
            If pazienteType IsNot Nothing Then
                'Ottengo il nodo Consensi
                consensiType = pazienteType.Consensi
            End If

            'Restituisco l'oggetto.
            Return consensiType
        End Function
    End Class

    <DataObject(True)>
    Public Class ConsensoPaziente

        ''' <summary>
        ''' Restituisce un consenso di un paziente per idConsenso
        ''' </summary>
        ''' <param name="Token"></param>
        ''' <param name="IdPaziente"></param>
        ''' <param name="IdConsenso"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfSacPazienti.TokenType, IdPaziente As Guid, IdConsenso As Guid) As WcfSacPazienti.ConsensoType
            'Dichiaro l'oggetto da restituire.
            Dim consensoType As WcfSacPazienti.ConsensoType = Nothing

            'uso la customDataSource "PazientiOttieniPerId" per ottenere il paziente.
            'ottengo i dati dalla cache per ottenere le esenzioni.
            Dim customDataSource As New ConsensiPaziente
            'Ottengo i dati
            Dim consensiType As WcfSacPazienti.ConsensiType = customDataSource.GetData(Token, IdPaziente)

            'Testo se oReturn non è vuoto.
            If consensiType IsNot Nothing Then
                Dim listaConsensiById = (From consenso In consensiType Where consenso.Id.ToUpper = IdConsenso.ToString.ToUpper Select consenso).ToList()

                If listaConsensiById IsNot Nothing AndAlso listaConsensiById.Count > 0 Then
                    consensoType = listaConsensiById.First()
                End If
            End If

            'Restituisco l'oggetto.
            Return consensoType
        End Function

    End Class
#End Region

#Region "Sinonimi"

    <DataObject(True)>
    Public Class SinonimiPaziente

        ''' <summary>
        ''' Metodo che restituisce i consensi di un paziente in base al suo id
        ''' </summary>
        ''' <param name="Token"></param>
        ''' <param name="Id"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfSacPazienti.TokenType, Id As Guid) As WcfSacPazienti.SinonimiType
            'Dichiaro l'oggetto da restituire.
            Dim sinonimiType As WcfSacPazienti.SinonimiType = Nothing

            'uso la customDataSource "PazientiOttieniPerId" per ottenere il paziente.
            'ottengo i dati dalla cache per ottenere i sinonimi.
            Dim customDataSource As New PazientiOttieniPerId
            'Ottengo i dati
            Dim pazienteType As WcfSacPazienti.PazienteType = customDataSource.GetData(Token, Id)

            'Testo se oReturn non è vuoto.
            If pazienteType IsNot Nothing Then
                'Ottengo il nodo Consensi
                sinonimiType = pazienteType.Sinonimi
            End If

            'Restituisco l'oggetto.
            Return sinonimiType
        End Function
    End Class
#End Region



    '''' <summary>
    '''' SIMONE: RIMUOVERE perchè verrà utuilizzata la classe quella nel file ChacheDataSource.vb
    '''' </summary>
    '''' <typeparam name="T"></typeparam>
    'Public Class CacheDataSource(Of T)
    '    Public Sub New()


    '        CacheDuration = 5
    '        CacheDataKey = OriginalCacheDatakey

    '    End Sub

    '    Public ReadOnly Property OriginalCacheDatakey As String
    '        Get
    '            '
    '            ' Per costruire la key sfrutto anche l'HashCode dell'Url.
    '            '
    '            Dim sPath As String = HttpContext.Current.Request.Url.GetHashCode.ToString

    '            Return String.Format("{0}_{1}_{2}", HttpContext.Current.User.Identity.Name,
    '                                            sPath.ToUpper,
    '                                           GetType(T).Name)
    '        End Get
    '    End Property

    '    Public Property CacheDuration As Integer
    '    Public Property CacheDataKey As String


    '    Public Sub ClearCache()
    '        '
    '        ' Vuota la cache
    '        '
    '        Me.CacheData = Nothing

    '    End Sub

    '    Public Property CacheData As T
    '        Get
    '            Dim oData As Object = HttpContext.Current.Cache.Item(CacheDataKey)
    '            If oData IsNot Nothing Then
    '                '
    '                ' Cast as T
    '                '
    '                If TypeOf oData Is T Then
    '                    Return CType(oData, T)
    '                Else
    '                    Return Nothing
    '                End If
    '            Else
    '                Return Nothing
    '            End If

    '        End Get
    '        Set(value As T)
    '            '
    '            ' Vuota, salva in cache
    '            '
    '            If value Is Nothing Then
    '                HttpContext.Current.Cache.Remove(CacheDataKey)
    '            Else
    '                HttpContext.Current.Cache.Insert(CacheDataKey, value, Nothing,
    '                                             DateTime.UtcNow.AddMinutes(CacheDuration),
    '                                             Cache.NoSlidingExpiration)
    '            End If
    '        End Set

    '    End Property


    'End Class


End Namespace