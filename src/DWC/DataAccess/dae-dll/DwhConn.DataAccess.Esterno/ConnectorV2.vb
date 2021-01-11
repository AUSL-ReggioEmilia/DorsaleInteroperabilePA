Imports System.Xml.Serialization
Imports System.Threading
Imports System.Text

<Serializable()> _
Public Class ConnectorV2

#Region " TipoMessaggio "

    Public Enum TipoMessaggio As Byte
        Aggiunge = 0
        Modifica = 1
        Rimuove = 2
        Fusione = 3
    End Enum

#End Region

#Region " Risultato "

    <Serializable()> _
    Public Class Risultato
        Public ErrorNumber As Int16
        Public ErrorDescription As String

        Public Sub New()
            Me.ErrorNumber = 0
            Me.ErrorDescription = ""
        End Sub

        Public Sub New(ByVal ErrorNumber As Int16, ByVal ErrorDescription As String)
            Me.ErrorNumber = ErrorNumber
            Me.ErrorDescription = ErrorDescription
        End Sub
    End Class

#End Region

#Region " Riferimento "

    <Serializable()> _
    Public Class Riferimento
        Public Nome As String
        Public Valore As String

        Public Sub New()
        End Sub

        Public Sub New(ByVal Nome As String, _
                        ByVal Valore As String)

            Me.Nome = Nome
            Me.Valore = Valore
        End Sub
    End Class

#End Region

#Region " Attributo "

    <Serializable()> _
    Public Class Attributo
        Public Nome As String
        Public Valore As String

        Public Sub New()
            Me.Nome = ""
            Me.Valore = ""
        End Sub

        Public Sub New(ByVal Nome As String, ByVal Valore As String)
            Me.Nome = Nome
            Me.Valore = Valore
        End Sub
    End Class

#End Region

#Region " Paziente "

    <Serializable()> _
    Public Class Paziente
        Public IdEsternoPaziente As String
        Public CodiceAnagraficaCentrale As String
        Public NomeAnagraficaCentrale As String
        Public Cognome As String
        Public Nome As String
        Public Sesso As String
        Public DataNascita As String
        Public LuogoNascita As String
        Public CodiceFiscale As String
        Public CodiceSanitario As String
        Public Attributi() As ConnectorV2.Attributo

        Public Sub New()
            Me.IdEsternoPaziente = ""
            Me.CodiceAnagraficaCentrale = ""
            Me.NomeAnagraficaCentrale = ""
            Me.Cognome = ""
            Me.Nome = ""
            Me.Sesso = ""
            Me.DataNascita = ""
            Me.LuogoNascita = ""
            Me.CodiceFiscale = ""
            Me.CodiceSanitario = ""
            Me.Attributi = Nothing
        End Sub

        Public Sub New(ByVal IdEsternoPaziente As String, _
                                ByVal CodiceAnagraficaCentrale As String, _
                                ByVal NomeAnagraficaCentrale As String)

            Me.IdEsternoPaziente = IdEsternoPaziente
            Me.CodiceAnagraficaCentrale = CodiceAnagraficaCentrale
            Me.NomeAnagraficaCentrale = NomeAnagraficaCentrale
            Me.Cognome = ""
            Me.Nome = ""
            Me.Sesso = ""
            Me.DataNascita = ""
            Me.LuogoNascita = ""
            Me.CodiceFiscale = ""
            Me.CodiceSanitario = ""
            Me.Attributi = Nothing
        End Sub

        Public Sub New(ByVal IdEsternoPaziente As String, ByVal CodiceAnagraficaCentrale As String _
                , ByVal NomeAnagraficaCentrale As String, ByVal Cognome As String _
                , ByVal Nome As String, ByVal Sesso As String _
                , ByVal DataNascita As String, ByVal LuogoNascita As String _
                , ByVal CodiceFiscale As String, ByVal CodiceSanitario As String)

            Me.IdEsternoPaziente = IdEsternoPaziente
            Me.CodiceAnagraficaCentrale = CodiceAnagraficaCentrale
            Me.NomeAnagraficaCentrale = NomeAnagraficaCentrale
            Me.Cognome = Cognome
            Me.Nome = Nome
            Me.Sesso = Sesso
            Me.DataNascita = DataNascita
            Me.LuogoNascita = LuogoNascita
            Me.CodiceFiscale = CodiceFiscale
            Me.CodiceSanitario = CodiceSanitario
            Me.Attributi = Nothing
        End Sub

        Public Sub New(ByVal IdEsternoPaziente As String, ByVal CodiceAnagraficaCentrale As String _
                        , ByVal NomeAnagraficaCentrale As String, ByVal Cognome As String _
                        , ByVal Nome As String, ByVal Sesso As String _
                        , ByVal DataNascita As String, ByVal LuogoNascita As String _
                        , ByVal CodiceFiscale As String, ByVal CodiceSanitario As String _
                        , ByVal Attributi() As ConnectorV2.Attributo)

            Me.IdEsternoPaziente = IdEsternoPaziente
            Me.CodiceAnagraficaCentrale = CodiceAnagraficaCentrale
            Me.NomeAnagraficaCentrale = NomeAnagraficaCentrale
            Me.Cognome = Cognome
            Me.Nome = Nome
            Me.Sesso = Sesso
            Me.DataNascita = DataNascita
            Me.LuogoNascita = LuogoNascita
            Me.CodiceFiscale = CodiceFiscale
            Me.CodiceSanitario = CodiceSanitario
            Me.Attributi = Attributi
        End Sub

    End Class

#End Region

#Region " Referto "

    <Serializable()> _
    Public Class Referto
        Public IdEsternoReferto As String
        Public AziendaErogante As String
        Public SistemaErogante As String
        Public RepartoErogante As String
        Public SezioneErogante As String
        Public SpecialitaErogante As String
        Public DataReferto As String
        Public NumeroReferto As String
        Public NumeroPrenotazione As String
        Public NumeroNosologico As String
        Public PrioritaCodice As String
        Public PrioritaDescrizione As String
        Public StatoRichiestaCodice As String
        Public StatoRichiestaDescrizione As String
        Public TipoRichiestaCodice As String
        Public TipoRichiestaDescrizione As String
        Public RepartoRichiedenteCodice As String
        Public RepartoRichiedenteDescrizione As String
        Public MedicoRefertanteCodice As String
        Public MedicoRefertanteDescrizione As String
        Public Attributi() As ConnectorV2.Attributo

        Public Sub New()
        End Sub

        Public Sub New(ByVal IdEsternoReferto As String, _
                    ByVal AziendaErogante As String, _
                    ByVal SistemaErogante As String, _
                    ByVal RepartoErogante As String, _
                    ByVal SezioneErogante As String, _
                    ByVal SpecialitaErogante As String, _
                    ByVal DataReferto As String, _
                    ByVal NumeroReferto As String, _
                    ByVal NumeroPrenotazione As String, _
                    ByVal NumeroNosologico As String, _
                    ByVal PrioritaCodice As String, _
                    ByVal PrioritaDescrizione As String, _
                    ByVal StatoRichiestaCodice As String, _
                    ByVal StatoRichiestaDescrizione As String, _
                    ByVal TipoRichiestaCodice As String, _
                    ByVal TipoRichiestaDescrizione As String, _
                    ByVal RepartoRichiedenteCodice As String, _
                    ByVal RepartoRichiedenteDescrizione As String, _
                    ByVal MedicoRefertanteCodice As String, _
                    ByVal MedicoRefertanteDescrizione As String)

            Me.IdEsternoReferto = IdEsternoReferto
            Me.AziendaErogante = AziendaErogante
            Me.SistemaErogante = SistemaErogante
            Me.RepartoErogante = RepartoErogante
            Me.SezioneErogante = SezioneErogante
            Me.SpecialitaErogante = SpecialitaErogante
            Me.DataReferto = DataReferto
            Me.NumeroReferto = NumeroReferto
            Me.NumeroPrenotazione = NumeroPrenotazione
            Me.NumeroNosologico = NumeroNosologico
            Me.PrioritaCodice = PrioritaCodice
            Me.PrioritaDescrizione = PrioritaDescrizione
            Me.StatoRichiestaCodice = StatoRichiestaCodice
            Me.StatoRichiestaDescrizione = StatoRichiestaDescrizione
            Me.TipoRichiestaCodice = TipoRichiestaCodice
            Me.TipoRichiestaDescrizione = TipoRichiestaDescrizione
            Me.RepartoRichiedenteCodice = RepartoRichiedenteCodice
            Me.RepartoRichiedenteDescrizione = RepartoRichiedenteDescrizione
            Me.MedicoRefertanteCodice = MedicoRefertanteCodice
            Me.MedicoRefertanteDescrizione = MedicoRefertanteDescrizione
        End Sub

        Public Sub New(ByVal IdEsternoReferto As String, _
                            ByVal AziendaErogante As String, _
                            ByVal SistemaErogante As String, _
                            ByVal RepartoErogante As String, _
                            ByVal SezioneErogante As String, _
                            ByVal SpecialitaErogante As String, _
                            ByVal DataReferto As String, _
                            ByVal NumeroReferto As String, _
                            ByVal NumeroPrenotazione As String, _
                            ByVal NumeroNosologico As String, _
                            ByVal PrioritaCodice As String, _
                            ByVal PrioritaDescrizione As String, _
                            ByVal StatoRichiestaCodice As String, _
                            ByVal StatoRichiestaDescrizione As String, _
                            ByVal TipoRichiestaCodice As String, _
                            ByVal TipoRichiestaDescrizione As String, _
                            ByVal RepartoRichiedenteCodice As String, _
                            ByVal RepartoRichiedenteDescrizione As String, _
                            ByVal MedicoRefertanteCodice As String, _
                            ByVal MedicoRefertanteDescrizione As String, _
                            ByVal Attributi() As ConnectorV2.Attributo)

            Me.IdEsternoReferto = IdEsternoReferto
            Me.AziendaErogante = AziendaErogante
            Me.SistemaErogante = SistemaErogante
            Me.RepartoErogante = RepartoErogante
            Me.SezioneErogante = SezioneErogante
            Me.SpecialitaErogante = SpecialitaErogante
            Me.DataReferto = DataReferto
            Me.NumeroReferto = NumeroReferto
            Me.NumeroPrenotazione = NumeroPrenotazione
            Me.NumeroNosologico = NumeroNosologico
            Me.PrioritaCodice = PrioritaCodice
            Me.PrioritaDescrizione = PrioritaDescrizione
            Me.StatoRichiestaCodice = StatoRichiestaCodice
            Me.StatoRichiestaDescrizione = StatoRichiestaDescrizione
            Me.TipoRichiestaCodice = TipoRichiestaCodice
            Me.TipoRichiestaDescrizione = TipoRichiestaDescrizione
            Me.RepartoRichiedenteCodice = RepartoRichiedenteCodice
            Me.RepartoRichiedenteDescrizione = RepartoRichiedenteDescrizione
            Me.MedicoRefertanteCodice = MedicoRefertanteCodice
            Me.MedicoRefertanteDescrizione = MedicoRefertanteDescrizione
            Me.Attributi = Attributi
        End Sub

    End Class

#End Region

#Region " Prestazione "

    <Serializable()> _
    Public Class Prestazione
        Public IdEsternoPrestazione As String
        Public DataErogazione As String    'Date
        Public PrestazioneCodice As String
        Public PrestazioneDescrizione As String
        Public PrestazionePosizione As Short
        Public SezioneCodice As String
        Public SezioneDescrizione As String
        Public SezionePosizione As Short
        Public GravitaCodice As String
        Public GravitaDescrizione As String
        Public Quantita As String
        Public Risultato As String
        Public ValoriRiferimento As String
        Public PrestazioneCommenti As String
        Public Attributi() As ConnectorV2.Attributo

        Public Sub New()
        End Sub

        Public Sub New(ByVal IdEsternoPrestazione As String, _
                            ByVal DataErogazione As String, _
                            ByVal PrestazioneCodice As String, _
                            ByVal PrestazioneDescrizione As String, _
                            ByVal PrestazionePosizione As Short, _
                            ByVal SezioneCodice As String, _
                            ByVal SezioneDescrizione As String, _
                            ByVal SezionePosizione As Short, _
                            ByVal GravitaCodice As String, _
                            ByVal GravitaDescrizione As String, _
                            ByVal Quantita As String, _
                            ByVal Risultato As String, _
                            ByVal ValoriRiferimento As String, _
                            ByVal PrestazioneCommenti As String)

            Me.IdEsternoPrestazione = IdEsternoPrestazione
            Me.DataErogazione = DataErogazione
            Me.PrestazioneCodice = PrestazioneCodice
            Me.PrestazioneDescrizione = PrestazioneDescrizione
            Me.PrestazionePosizione = PrestazionePosizione
            Me.SezioneCodice = SezioneCodice
            Me.SezioneDescrizione = SezioneDescrizione
            Me.SezionePosizione = SezionePosizione
            Me.GravitaCodice = GravitaCodice
            Me.GravitaDescrizione = GravitaDescrizione
            Me.Quantita = Quantita
            Me.Risultato = Risultato
            Me.ValoriRiferimento = ValoriRiferimento
            Me.PrestazioneCommenti = PrestazioneCommenti
        End Sub

        Public Sub New(ByVal IdEsternoPrestazione As String, _
                            ByVal DataErogazione As String, _
                            ByVal PrestazioneCodice As String, _
                            ByVal PrestazioneDescrizione As String, _
                            ByVal PrestazionePosizione As Short, _
                            ByVal SezioneCodice As String, _
                            ByVal SezioneDescrizione As String, _
                            ByVal SezionePosizione As Short, _
                            ByVal GravitaCodice As String, _
                            ByVal GravitaDescrizione As String, _
                            ByVal Quantita As String, _
                            ByVal Risultato As String, _
                            ByVal ValoriRiferimento As String, _
                            ByVal PrestazioneCommenti As String, _
                            ByVal Attributi() As ConnectorV2.Attributo)

            Me.IdEsternoPrestazione = IdEsternoPrestazione
            Me.DataErogazione = DataErogazione
            Me.PrestazioneCodice = PrestazioneCodice
            Me.PrestazioneDescrizione = PrestazioneDescrizione
            Me.PrestazionePosizione = PrestazionePosizione
            Me.SezioneCodice = SezioneCodice
            Me.SezioneDescrizione = SezioneDescrizione
            Me.SezionePosizione = SezionePosizione
            Me.GravitaCodice = GravitaCodice
            Me.GravitaDescrizione = GravitaDescrizione
            Me.Quantita = Quantita
            Me.Risultato = Risultato
            Me.ValoriRiferimento = ValoriRiferimento
            Me.PrestazioneCommenti = PrestazioneCommenti
            Me.Attributi = Attributi
        End Sub

    End Class

#End Region

#Region " Allegato "

    <Serializable()> _
    Public Class Allegato
        Public IdEsternoAllegato As String
        Public DataFile As String
        Public NomeFile As String
        Public Descrizione As String
        Public Posizione As Short
        Public StatoCodice As String
        Public StatoDescrizione As String
        Public MimeType As String
        Public MimeData As String
        Public Attributi() As ConnectorV2.Attributo

        Public Sub New()
        End Sub

        Public Sub New(ByVal IdEsternoAllegato As String, _
                    ByVal DataFile As String, _
                    ByVal NomeFile As String, _
                    ByVal Descrizione As String, _
                    ByVal Posizione As Short, _
                    ByVal StatoCodice As String, _
                    ByVal StatoDescrizione As String, _
                    ByVal MimeType As String, _
                    ByVal MimeData As String)

            Me.IdEsternoAllegato = IdEsternoAllegato
            Me.DataFile = DataFile
            Me.NomeFile = NomeFile
            Me.Descrizione = Descrizione
            Me.Posizione = Posizione
            Me.StatoCodice = StatoCodice
            Me.StatoDescrizione = StatoDescrizione
            Me.MimeType = MimeType
            Me.MimeData = MimeData
        End Sub

        Public Sub New(ByVal IdEsternoAllegato As String, _
                            ByVal DataFile As String, _
                            ByVal NomeFile As String, _
                            ByVal Descrizione As String, _
                            ByVal Posizione As Short, _
                            ByVal StatoCodice As String, _
                            ByVal StatoDescrizione As String, _
                            ByVal MimeType As String, _
                            ByVal MimeData As String, _
                            ByVal Attributi() As ConnectorV2.Attributo)

            Me.IdEsternoAllegato = IdEsternoAllegato
            Me.DataFile = DataFile
            Me.NomeFile = NomeFile
            Me.Descrizione = Descrizione
            Me.Posizione = Posizione
            Me.StatoCodice = StatoCodice
            Me.StatoDescrizione = StatoDescrizione
            Me.MimeType = MimeType
            Me.MimeData = MimeData
            Me.Attributi = Attributi
        End Sub

    End Class
#End Region

#Region " MessaggioAnagrafica "

    <Serializable()> _
    Public Class MessaggioAnagrafica
        Public IdEsternoPaziente As String
        Public AziendaErogante As String
        Public SistemaErogante As String
        Public RepartoErogante As String
        Public Cognome As String
        Public Nome As String
        Public Sesso As String
        Public DataNascita As String
        Public LuogoNascita As String
        Public CodiceFiscale As String
        Public CodiceSanitario As String
        Public DatiAnamnestici As String
        Public Attributi() As ConnectorV2.Attributo
        Public Riferimenti() As ConnectorV2.Riferimento

        Public Sub New()
        End Sub

        Public Sub New(ByVal IdEsternoPaziente As String, _
                        ByVal AziendaErogante As String, _
                        ByVal SistemaErogante As String, _
                        ByVal RepartoErogante As String, _
                        ByVal Cognome As String, _
                        ByVal Nome As String, _
                        ByVal Sesso As String, _
                        ByVal DataNascita As String, _
                        ByVal LuogoNascita As String, _
                        ByVal CodiceFiscale As String, _
                        ByVal CodiceSanitario As String, _
                        ByVal DatiAnamnestici As String)

            Me.IdEsternoPaziente = IdEsternoPaziente
            Me.AziendaErogante = AziendaErogante
            Me.SistemaErogante = SistemaErogante
            Me.RepartoErogante = RepartoErogante
            Me.Cognome = Cognome
            Me.Nome = Nome
            Me.Sesso = Sesso
            Me.DataNascita = DataNascita
            Me.LuogoNascita = LuogoNascita
            Me.CodiceFiscale = CodiceFiscale
            Me.CodiceSanitario = CodiceSanitario
            Me.DatiAnamnestici = DatiAnamnestici
        End Sub

        Public Sub New(ByVal IdEsternoPaziente As String, _
                        ByVal AziendaErogante As String, _
                        ByVal SistemaErogante As String, _
                        ByVal RepartoErogante As String, _
                        ByVal Cognome As String, _
                        ByVal Nome As String, _
                        ByVal Sesso As String, _
                        ByVal DataNascita As String, _
                        ByVal LuogoNascita As String, _
                        ByVal CodiceFiscale As String, _
                        ByVal CodiceSanitario As String, _
                        ByVal DatiAnamnestici As String, _
                        ByVal Attributi() As ConnectorV2.Attributo)

            Me.IdEsternoPaziente = IdEsternoPaziente
            Me.AziendaErogante = AziendaErogante
            Me.SistemaErogante = SistemaErogante
            Me.RepartoErogante = RepartoErogante
            Me.Cognome = Cognome
            Me.Nome = Nome
            Me.Sesso = Sesso
            Me.DataNascita = DataNascita
            Me.LuogoNascita = LuogoNascita
            Me.CodiceFiscale = CodiceFiscale
            Me.CodiceSanitario = CodiceSanitario
            Me.DatiAnamnestici = DatiAnamnestici
            Me.Attributi = Attributi
        End Sub

        Public Sub New(ByVal IdEsternoPaziente As String, _
                        ByVal AziendaErogante As String, _
                        ByVal SistemaErogante As String, _
                        ByVal RepartoErogante As String, _
                        ByVal Cognome As String, _
                        ByVal Nome As String, _
                        ByVal Sesso As String, _
                        ByVal DataNascita As String, _
                        ByVal LuogoNascita As String, _
                        ByVal CodiceFiscale As String, _
                        ByVal CodiceSanitario As String, _
                        ByVal DatiAnamnestici As String, _
                        ByVal Riferimenti() As ConnectorV2.Riferimento)

            Me.IdEsternoPaziente = IdEsternoPaziente
            Me.AziendaErogante = AziendaErogante
            Me.SistemaErogante = SistemaErogante
            Me.RepartoErogante = RepartoErogante
            Me.Cognome = Cognome
            Me.Nome = Nome
            Me.Sesso = Sesso
            Me.DataNascita = DataNascita
            Me.LuogoNascita = LuogoNascita
            Me.CodiceFiscale = CodiceFiscale
            Me.CodiceSanitario = CodiceSanitario
            Me.DatiAnamnestici = DatiAnamnestici
            Me.Riferimenti = Riferimenti
        End Sub

        Public Sub New(ByVal IdEsternoPaziente As String, _
                        ByVal AziendaErogante As String, _
                        ByVal SistemaErogante As String, _
                        ByVal RepartoErogante As String, _
                        ByVal Cognome As String, _
                        ByVal Nome As String, _
                        ByVal Sesso As String, _
                        ByVal DataNascita As String, _
                        ByVal LuogoNascita As String, _
                        ByVal CodiceFiscale As String, _
                        ByVal CodiceSanitario As String, _
                        ByVal DatiAnamnestici As String, _
                        ByVal Attributi() As ConnectorV2.Attributo, _
                        ByVal Riferimenti() As ConnectorV2.Riferimento)

            Me.IdEsternoPaziente = IdEsternoPaziente
            Me.AziendaErogante = AziendaErogante
            Me.SistemaErogante = SistemaErogante
            Me.RepartoErogante = RepartoErogante
            Me.Cognome = Cognome
            Me.Nome = Nome
            Me.Sesso = Sesso
            Me.DataNascita = DataNascita
            Me.LuogoNascita = LuogoNascita
            Me.CodiceFiscale = CodiceFiscale
            Me.CodiceSanitario = CodiceSanitario
            Me.DatiAnamnestici = DatiAnamnestici
            Me.Attributi = Attributi
            Me.Riferimenti = Riferimenti
        End Sub

        Public Shared Function Deserialize(ByVal XmlData As String) As ConnectorV2.MessaggioAnagrafica

            Dim oStream As IO.MemoryStream = Nothing
            Dim oTextReader As Xml.XmlTextReader = Nothing

            Try
                Dim oEnc As Encoding = Encoding.UTF8

                oStream = New IO.MemoryStream
                oStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
                oStream.Position = 0

                oTextReader = New Xml.XmlTextReader(oStream)

                Dim oMessaggio As MessaggioAnagrafica

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(ConnectorV2.MessaggioAnagrafica))
                oMessaggio = CType(oSerializer.Deserialize(oTextReader), ConnectorV2.MessaggioAnagrafica)

                Return oMessaggio

            Catch ex As Exception
                '
                ' Error
                '
                Dim sMessage As String = "ConnectorV2 MessaggioAnagrafica.Deserialize(); Errore durante la deserializzazione!"
                '
                ' Log e eccezione
                '
                LogEvent.WriteError(ex, sMessage)
                Throw New System.Exception(sMessage, ex)

            Finally
                '
                ' Rilascio
                '
                Try
                    If Not oStream Is Nothing Then
                        oStream.Close()
                    End If
                    If Not oTextReader Is Nothing Then
                        oTextReader.Close()
                    End If
                Catch ex As Exception
                End Try
            End Try

        End Function

        Public Shared Function Serialize(ByVal Messaggio As ConnectorV2.MessaggioAnagrafica) As String
            '
            ' Serializzo
            '
            Dim oStream As IO.MemoryStream = Nothing
            Dim oTextWriter As Xml.XmlTextWriter = Nothing

            Try
                Dim oEnc As Encoding = Encoding.UTF8

                oStream = New IO.MemoryStream
                oTextWriter = New Xml.XmlTextWriter(oStream, oEnc)

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(ConnectorV2.MessaggioAnagrafica))
                oSerializer.Serialize(oTextWriter, Messaggio)

                Dim sMessaggio As String = oEnc.GetString(oStream.ToArray())
                Return sMessaggio

            Catch ex As Exception
                '
                ' Error
                '
                Dim sMessage As String = "ConnectorV2 MessaggioAnagrafica.Serialize(); Errore durante la serializzazione!"
                '
                ' Log e eccezione
                '
                LogEvent.WriteError(ex, sMessage)
                Throw New System.Exception(sMessage, ex)

            Finally
                '
                ' Rilascio
                '
                Try
                    If Not oStream Is Nothing Then
                        oStream.Close()
                    End If
                    If Not oTextWriter Is Nothing Then
                        oTextWriter.Close()
                    End If
                Catch ex As Exception
                End Try
            End Try

        End Function

    End Class

#End Region

#Region " MessaggioConsenso "

    <Serializable()> _
    Public Class MessaggioConsenso
        Public IdEsterno As String
        Public AziendaErogante As String
        Public SistemaErogante As String
        Public Data As String
        Public Abilitato As Boolean
        Public Tipo As String
        Public AccountUtente As String
        Public NomeUtente As String
        Public Paziente As ConnectorV2.Paziente

        Public Sub New()
            Me.IdEsterno = ""
            Me.AziendaErogante = ""
            Me.SistemaErogante = ""
            Me.Data = ""
            Me.Abilitato = False
            Me.Tipo = "Generico"
            Me.AccountUtente = ""
            Me.NomeUtente = ""
            Me.Paziente = Nothing
        End Sub

        Public Sub New(ByVal IdEsterno As String, ByVal AziendaErogante As String _
                            , ByVal SistemaErogante As String, ByVal Data As String _
                            , ByVal Abilitato As Boolean, ByVal AccountUtente As String _
                            , ByVal NomeUtente As String, ByVal Paziente As ConnectorV2.Paziente)
            Me.IdEsterno = IdEsterno
            Me.AziendaErogante = AziendaErogante
            Me.SistemaErogante = SistemaErogante
            Me.Data = Data
            Me.Abilitato = Abilitato
            Me.Tipo = "Generico"
            Me.AccountUtente = AccountUtente
            Me.NomeUtente = NomeUtente
            Me.Paziente = Paziente
        End Sub

        Public Sub New(ByVal IdEsterno As String, ByVal AziendaErogante As String _
                    , ByVal SistemaErogante As String, ByVal Data As String _
                    , ByVal Abilitato As Boolean, ByVal Tipo As String _
                    , ByVal AccountUtente As String, ByVal NomeUtente As String _
                    , ByVal Paziente As ConnectorV2.Paziente)
            Me.IdEsterno = IdEsterno
            Me.AziendaErogante = AziendaErogante
            Me.SistemaErogante = SistemaErogante
            Me.Data = Data
            Me.Abilitato = Abilitato
            Me.Tipo = Tipo
            Me.AccountUtente = AccountUtente
            Me.NomeUtente = NomeUtente
            Me.Paziente = Paziente
        End Sub

        Public Sub New(ByVal Data As String, ByVal Abilitato As Boolean _
                    , ByVal Tipo As String, ByVal Paziente As ConnectorV2.Paziente)

            Me.Data = Data
            Me.Abilitato = Abilitato
            Me.Tipo = Tipo
            Me.Paziente = Paziente
        End Sub

        Public Sub New(ByVal Data As String, ByVal Abilitato As Boolean _
                     , ByVal Tipo As String, ByVal IdEsternoPaziente As String)

            Me.Data = Data
            Me.Abilitato = Abilitato
            Me.Tipo = Tipo
            Me.Paziente = New Paziente(IdEsternoPaziente, "", "")

        End Sub


        Public Shared Function Deserialize(ByVal XmlData As String) As ConnectorV2.MessaggioConsenso

            Dim oStream As IO.MemoryStream = Nothing
            Dim oTextReader As Xml.XmlTextReader = Nothing

            Try
                Dim oEnc As Encoding = Encoding.UTF8

                oStream = New IO.MemoryStream
                oStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
                oStream.Position = 0

                oTextReader = New Xml.XmlTextReader(oStream)

                Dim oMessaggio As MessaggioConsenso

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(ConnectorV2.MessaggioConsenso))
                oMessaggio = CType(oSerializer.Deserialize(oTextReader), ConnectorV2.MessaggioConsenso)

                Return oMessaggio

            Catch ex As Exception
                '
                ' Error
                '
                Dim sMessage As String = "ConnectorV2 MessaggioConsenso.Deserialize(); Errore durante la deserializzazione!"
                '
                ' Log e eccezione
                '
                LogEvent.WriteError(ex, sMessage)
                Throw New System.Exception(sMessage, ex)

            Finally
                '
                ' Rilascio
                '
                Try
                    If Not oStream Is Nothing Then
                        oStream.Close()
                    End If
                    If Not oTextReader Is Nothing Then
                        oTextReader.Close()
                    End If
                Catch ex As Exception
                End Try
            End Try

        End Function

        Public Shared Function Serialize(ByVal Messaggio As ConnectorV2.MessaggioConsenso) As String
            '
            ' Serializzo
            '
            Dim oStream As IO.MemoryStream = Nothing
            Dim oTextWriter As Xml.XmlTextWriter = Nothing

            Try
                Dim oEnc As Encoding = Encoding.UTF8

                oStream = New IO.MemoryStream
                oTextWriter = New Xml.XmlTextWriter(oStream, oEnc)

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(ConnectorV2.MessaggioConsenso))
                oSerializer.Serialize(oTextWriter, Messaggio)

                Dim sMessaggio As String = oEnc.GetString(oStream.ToArray())
                Return sMessaggio

            Catch ex As Exception
                '
                ' Error
                '
                Dim sMessage As String = "ConnectorV2 MessaggioConsenso.Serialize(); Errore durante la serializzazione!"
                '
                ' Log e eccezione
                '
                LogEvent.WriteError(ex, sMessage)
                Throw New System.Exception(sMessage, ex)

            Finally
                '
                ' Rilascio
                '
                Try
                    If Not oStream Is Nothing Then
                        oStream.Close()
                    End If
                    If Not oTextWriter Is Nothing Then
                        oTextWriter.Close()
                    End If
                Catch ex As Exception
                End Try
            End Try

        End Function

    End Class

#End Region

#Region " MessaggioEpisodio"

    <Serializable()> _
    Public Class MessaggioEpisodio
        Public Paziente As ConnectorV2.Paziente
        Public Referto As ConnectorV2.Referto
        Public Prestazioni() As ConnectorV2.Prestazione
        Public Allegati() As ConnectorV2.Allegato

        Public StileVisualizzazione As String
        Public DatiSoloPerCercare As Boolean

        Public Sub New()
        End Sub

        Public Sub New(ByVal Paziente As ConnectorV2.Paziente, _
                        ByVal Referto As ConnectorV2.Referto, _
                        ByVal StileVisualizzazione As String, _
                        ByVal DatiSoloPerCercare As Boolean)

            Me.Paziente = Paziente
            Me.Referto = Referto

            Me.StileVisualizzazione = StileVisualizzazione
            Me.DatiSoloPerCercare = DatiSoloPerCercare
        End Sub

        Public Sub New(ByVal Paziente As ConnectorV2.Paziente, _
                        ByVal Referto As ConnectorV2.Referto, _
                        ByVal Allegati() As ConnectorV2.Allegato, _
                        ByVal StileVisualizzazione As String, _
                        ByVal DatiSoloPerCercare As Boolean)

            Me.Paziente = Paziente
            Me.Referto = Referto
            Me.Allegati = Allegati

            Me.StileVisualizzazione = StileVisualizzazione
            Me.DatiSoloPerCercare = DatiSoloPerCercare
        End Sub

        Public Sub New(ByVal Paziente As ConnectorV2.Paziente, _
                        ByVal Referto As ConnectorV2.Referto, _
                        ByVal Prestazioni() As ConnectorV2.Prestazione, _
                        ByVal StileVisualizzazione As String, _
                        ByVal DatiSoloPerCercare As Boolean)

            Me.Paziente = Paziente
            Me.Referto = Referto
            Me.Prestazioni = Prestazioni

            Me.StileVisualizzazione = StileVisualizzazione
            Me.DatiSoloPerCercare = DatiSoloPerCercare
        End Sub

        Public Sub New(ByVal Paziente As ConnectorV2.Paziente, _
                        ByVal Referto As ConnectorV2.Referto, _
                        ByVal Prestazioni() As ConnectorV2.Prestazione, _
                        ByVal Allegati() As ConnectorV2.Allegato, _
                        ByVal StileVisualizzazione As String, _
                        ByVal DatiSoloPerCercare As Boolean)

            Me.Paziente = Paziente
            Me.Referto = Referto
            Me.Prestazioni = Prestazioni
            Me.Allegati = Allegati

            Me.StileVisualizzazione = StileVisualizzazione
            Me.DatiSoloPerCercare = DatiSoloPerCercare
        End Sub

        Public Shared Function Deserialize(ByVal XmlData As String) As ConnectorV2.MessaggioEpisodio

            Dim oStream As IO.MemoryStream = Nothing
            Dim oTextReader As Xml.XmlTextReader = Nothing

            Try
                Dim oEnc As Encoding = Encoding.UTF8

                oStream = New IO.MemoryStream
                oStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
                oStream.Position = 0

                oTextReader = New Xml.XmlTextReader(oStream)

                Dim oMessaggio As MessaggioEpisodio

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(ConnectorV2.MessaggioEpisodio))
                oMessaggio = CType(oSerializer.Deserialize(oTextReader), ConnectorV2.MessaggioEpisodio)

                Return oMessaggio

            Catch ex As Exception
                '
                ' Error
                '
                Dim sMessage As String = "ConnectorV2 MessaggioEpisodio.Deserialize(); Errore durante la deserializzazione!"
                '
                ' Log e eccezione
                '
                LogEvent.WriteError(ex, sMessage)
                Throw New System.Exception(sMessage, ex)

            Finally
                '
                ' Rilascio
                '
                Try
                    If Not oStream Is Nothing Then
                        oStream.Close()
                    End If
                    If Not oTextReader Is Nothing Then
                        oTextReader.Close()
                    End If
                Catch ex As Exception
                End Try
            End Try

        End Function

        Public Shared Function Serialize(ByVal Messaggio As ConnectorV2.MessaggioEpisodio) As String
            '
            ' Serializzo
            '
            Dim oStream As IO.MemoryStream = Nothing
            Dim oTextWriter As Xml.XmlTextWriter = Nothing

            Try
                Dim oEnc As Encoding = Encoding.UTF8

                oStream = New IO.MemoryStream
                oTextWriter = New Xml.XmlTextWriter(oStream, oEnc)

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(ConnectorV2.MessaggioEpisodio))
                oSerializer.Serialize(oTextWriter, Messaggio)

                Dim sMessaggio As String = oEnc.GetString(oStream.ToArray())
                Return sMessaggio

            Catch ex As Exception
                '
                ' Error
                '
                Dim sMessage As String = "ConnectorV2 MessaggioEpisodio.Serialize(); Errore durante la serializzazione!"
                '
                ' Log e eccezione
                '
                LogEvent.WriteError(ex, sMessage)
                Throw New System.Exception(sMessage, ex)

            Finally
                '
                ' Rilascio
                '
                Try
                    If Not oStream Is Nothing Then
                        oStream.Close()
                    End If
                    If Not oTextWriter Is Nothing Then
                        oTextWriter.Close()
                    End If
                Catch ex As Exception
                End Try
            End Try

        End Function

    End Class

#End Region

    Public Function Consenso(ByVal Tipo As ConnectorV2.TipoMessaggio, _
                            ByVal Messaggio As ConnectorV2.MessaggioConsenso) As Risultato
        Dim iDelayMs As Integer = 0
        Dim iCounterRetry As Integer = 0
        While True
            Try
                ' Esecuzione delle operazioni di aggiornamento
                iCounterRetry = iCounterRetry + 1
                Return _Consenso(Tipo, Messaggio)

            Catch ex As ConnectionException
                ' Se ho raggiunto il numero max di retry esco con throw dell'eccezione: l'orchestrazione eseguirà il suo loop di retry
                If iCounterRetry >= My.Config.ConnectionErrorNumRetry Then
                    Throw New System.Exception(ex.Message)
                End If
                ' Imposto il delay
                iDelayMs = My.Config.ConnectionErrorDelayRetry * 1000

            Catch ex As CommandTimeoutException
                ' Se ho raggiunto il numero max di retry esco con throw dell'eccezione: l'orchestrazione eseguirà il suo loop di retry
                If iCounterRetry >= My.Config.CommandTimeoutNumRetry Then
                    Throw New System.Exception(ex.Message)
                End If
                ' Imposto il delay
                iDelayMs = My.Config.CommandTimeoutDelayRetry * 1000

            Catch ex As SqlException
                If ex.Number = SqlExceptionNumber.Timeout Then
                    If iCounterRetry >= My.Config.CommandTimeoutNumRetry Then
                        Throw New System.Exception(ex.Message)
                    End If
                    iDelayMs = My.Config.CommandTimeoutDelayRetry * 1000

                ElseIf ex.Number = SqlExceptionNumber.DeadLock Then
                    If iCounterRetry >= My.Config.DeadLockNumRetry Then
                        Throw New System.Exception(ex.Message)
                    End If
                    iDelayMs = My.Config.DeadLockDelayRetry * 1000

                End If

            Catch ex As System.ApplicationException
                ' L'orchestrazione eseguirà il suo loop di retry
                Throw

            Catch ex As Exception
                ' L'orchestrazione eseguirà il suo loop di retry
                Throw

            End Try
            '
            ' Attendo il tempo di Delay (in millisecondi)
            '
            Thread.Sleep(iDelayMs)
        End While
        ' Qui non ci arriva mai
        Return Nothing


    End Function

    Private Function _Consenso(ByVal Tipo As ConnectorV2.TipoMessaggio, _
                            ByVal Messaggio As ConnectorV2.MessaggioConsenso) As Risultato

        Dim mutSync As Mutex = Nothing

        Dim oConsensiAdapter As ConsensiAdapter = Nothing
        Dim nErrNumber As Int16 = 0
        '
        ' Verifiche dei parametri
        '
        If Messaggio Is Nothing Then
            Throw New System.ArgumentException("Il parametro Messaggio è vuoto!", "Messaggio")
        End If

        If Messaggio.Paziente Is Nothing Then
            Throw New System.ApplicationException("Manca il nodo Paziente nel Messaggio!")
        End If

        Dim sIdEsternoPaziente As String = Messaggio.Paziente.IdEsternoPaziente & ""
        If sIdEsternoPaziente.Length = 0 Then
            Throw New System.ApplicationException("Il campo IdEsternoPaziente del messaggio è vuoto!")
        End If
        '
        ' Controllo operazioni
        '
        If Tipo = TipoMessaggio.Modifica Then
            Throw New System.InvalidOperationException("Non è posibile modificare un Consenso!")
        ElseIf Tipo = TipoMessaggio.Rimuove Then
            Throw New System.InvalidOperationException("Non è posibile rimuovere un Consenso!")
        ElseIf Tipo = TipoMessaggio.Fusione Then
            Throw New System.InvalidOperationException("Non è posibile fondere un Consenso!")
        End If

        Try
            '
            ' Serializzo accesso
            '
            Dim sSyncLock As String
            Select Case ConfigUtil.GetSyncLevel
                Case ConfigUtil.SyncLevel.IdEsterno : sSyncLock = GetType(ConsensiAdapter).ToString & "_" & sIdEsternoPaziente
                Case ConfigUtil.SyncLevel.Sistema : sSyncLock = GetType(ConsensiAdapter).ToString & "_" & Messaggio.SistemaErogante
                Case ConfigUtil.SyncLevel.Tipo : sSyncLock = GetType(ConsensiAdapter).ToString
                Case Else : sSyncLock = GetType(ConsensiAdapter).ToString
            End Select
            mutSync = ConfigUtil.GetMutex(sSyncLock)
            '
            ' Creo adapter e apro connessione
            '
            oConsensiAdapter = New ConsensiAdapter
            Try
                oConsensiAdapter.ConnectionOpen(My.Config.ConnectionString)
            Catch ex As Exception
                Throw New ConnectionException(GetDatabaseInfo(My.Config.ConnectionString) & vbCrLf & ex.Message)
            End Try
            oConsensiAdapter.TransactionBegin(ConfigUtil.GetIsolationLevel())
            '
            ' Controllo se anagrafica esiste per IdEsterno
            '
            If Not oConsensiAdapter.AnagraficaEsiste(sIdEsternoPaziente) Then
                '
                ' Controllo se riferimenti anagrafici sono compliati
                '
                sIdEsternoPaziente = Nothing
                If Not String.IsNullOrEmpty(Messaggio.Paziente.NomeAnagraficaCentrale) AndAlso _
                                        Not String.IsNullOrEmpty(Messaggio.Paziente.CodiceAnagraficaCentrale) Then
                    '
                    ' Cerco per riferimenti anagrafici
                    '
                    sIdEsternoPaziente = oConsensiAdapter.AnagraficaRiferimento(Messaggio.Paziente.NomeAnagraficaCentrale & "", _
                                                                                   Messaggio.Paziente.CodiceAnagraficaCentrale & "")
                End If
            End If

            If String.IsNullOrEmpty(sIdEsternoPaziente) Then
                '
                ' Paziente non trovato Log eventi
                '
                Throw New System.Exception(String.Format("Paziente non trovato! IdEsterno='{0}'!", _
                                                            Messaggio.Paziente.IdEsternoPaziente))
            End If
            '
            ' Aggiunge consenso
            '
            Dim dtDataConsenso As Date = XmlUtil.ParseDatetime(Messaggio.Data & "")

            oConsensiAdapter.ConsensoAggiorna(sIdEsternoPaziente, Messaggio.Tipo, _
                                                                Messaggio.Abilitato, dtDataConsenso)
            '
            ' Confermo le modifiche
            '
            oConsensiAdapter.TransactionCommit()
            '
            ' Log eventi
            '
            LogEvent.WriteInformation("Aggiunto o modificato stato consenso!" & vbCrLf & _
                            "IdEsternoPaziente = '" & sIdEsternoPaziente & "'" & vbCrLf & _
                            "Sistema = '" & Messaggio.SistemaErogante & "'" & vbCrLf & _
                            "Cognome = '" & Messaggio.Paziente.Cognome & "'" & vbCrLf & _
                            "Nome = '" & Messaggio.Paziente.Nome & "'")
            '
            ' Ritorna OK
            '
            Return New Risultato(0, "")

        Catch ex As Exception
            '
            ' Abbandono le modifiche
            '
            Dim sErrRollBack As String = String.Empty
            Try
                If Not oConsensiAdapter Is Nothing Then
                    oConsensiAdapter.TransactionRoolback()
                End If
            Catch ex2 As Exception
                sErrRollBack = String.Format("Errore durante il rollback della transazione relativa a ConnectorV2.Consenso(): Tipo={0}, IdEsterno={1}{2}{3}", _
                                                        Tipo, sIdEsternoPaziente, vbCrLf, ex2.Message)

                LogEvent.WriteError(ex2, sErrRollBack)
            End Try
            '
            ' Scrive Log
            '
            Dim sMessage As String
            sMessage = String.Format("Errore durante ConnectorV2.Consenso(); Tipo={0}, IdEsterno={1}{2}{3}", _
                                                                        Tipo, sIdEsternoPaziente, vbCrLf, ex.Message)
            '
            ' Log
            '
            LogEvent.WriteError(ex, sMessage)
            '
            ' A questo punto verifico se l'eccezione è ConnectionException 
            ' oppure una SqlException dovuta ad un timeout, deadlock
            '
            If TypeOf ex Is ConnectionException Then
                Throw New ConnectionException(sMessage)
            ElseIf TypeOf ex Is CommandTimeoutException Then
                'Cosi posso usare anche questo tipo di eccezione volendo, invece di controllare una SqlException con Number=-2 
                Throw New CommandTimeoutException(sMessage)
            ElseIf TypeOf ex Is SqlClient.SqlException Then
                Dim ExSql As SqlClient.SqlException = CType(ex, SqlClient.SqlException)
                If ExSql.Number = SqlExceptionNumber.Timeout Then 'TimeoutError
                    Throw New CommandTimeoutException(sMessage)
                ElseIf ExSql.Number = SqlExceptionNumber.DeadLock Then
                    Throw
                End If
            End If
            '
            ' Risultato o eccezione
            '
            If nErrNumber > 0 Then
                Throw New System.ApplicationException(sMessage & vbCrLf & "ErrNumber=" & nErrNumber.ToString, ex)
            Else
                Throw New System.Exception(sMessage, ex)
            End If

        Finally
            '
            ' Rilascia sincronismo
            '
            If Not mutSync Is Nothing Then
                Try
                    mutSync.ReleaseMutex()
                    mutSync.Close()
                Catch ex As Exception
                End Try
            End If
            '
            ' Chiude connessione se aperta
            '
            If Not oConsensiAdapter Is Nothing Then
                oConsensiAdapter.Dispose()
            End If

        End Try

    End Function


    Public Function Episodio(ByVal Tipo As ConnectorV2.TipoMessaggio, _
                            ByVal Data As DateTime, _
                            ByVal Messaggio As ConnectorV2.MessaggioEpisodio) As Risultato
        Return Episodio2(Tipo, Data, Messaggio, Nothing)
    End Function

    Public Function Episodio2(ByVal Tipo As ConnectorV2.TipoMessaggio, _
                            ByVal Data As DateTime, _
                            ByVal Messaggio As ConnectorV2.MessaggioEpisodio, _
                            ByVal IdEsternoPrecedente As String) As Risultato
        Dim iDelayMs As Integer = 0
        Dim iCounterRetry As Integer = 0
        While True
            Try
                ' Esecuzione delle operazioni di aggiornamento
                iCounterRetry = iCounterRetry + 1
                Return _Episodio(Tipo, Data, Messaggio, IdEsternoPrecedente)

            Catch ex As ConnectionException
                ' Se ho raggiunto il numero max di retry esco con throw dell'eccezione: l'orchestrazione eseguirà il suo loop di retry
                If iCounterRetry >= My.Config.ConnectionErrorNumRetry Then
                    Throw New System.Exception(ex.Message)
                End If
                ' Imposto il delay
                iDelayMs = My.Config.ConnectionErrorDelayRetry * 1000

            Catch ex As CommandTimeoutException
                ' Se ho raggiunto il numero max di retry esco con throw dell'eccezione: l'orchestrazione eseguirà il suo loop di retry
                If iCounterRetry >= My.Config.CommandTimeoutNumRetry Then
                    Throw New System.Exception(ex.Message)
                End If
                ' Imposto il delay
                iDelayMs = My.Config.CommandTimeoutDelayRetry * 1000

            Catch ex As SqlException
                If ex.Number = SqlExceptionNumber.Timeout Then
                    If iCounterRetry >= My.Config.CommandTimeoutNumRetry Then
                        Throw New System.Exception(ex.Message)
                    End If
                    iDelayMs = My.Config.CommandTimeoutDelayRetry * 1000

                ElseIf ex.Number = SqlExceptionNumber.DeadLock Then
                    If iCounterRetry >= My.Config.DeadLockNumRetry Then
                        Throw New System.Exception(ex.Message)
                    End If
                    iDelayMs = My.Config.DeadLockDelayRetry * 1000

                End If

            Catch ex As System.ApplicationException
                ' L'orchestrazione eseguirà il suo loop di retry
                Throw

            Catch ex As Exception
                ' L'orchestrazione eseguirà il suo loop di retry
                Throw

            End Try
            '
            ' Attendo il tempo di Delay (in millisecondi)
            '
            Thread.Sleep(iDelayMs)
        End While
        ' Qui non ci arriva mai
        Return Nothing
    End Function

    Private Function _Episodio(ByVal Tipo As ConnectorV2.TipoMessaggio, _
                            ByVal Data As DateTime, _
                            ByVal Messaggio As ConnectorV2.MessaggioEpisodio, _
                            ByVal IdEsternoPrecedente As String) As Risultato

        '
        ' IdEsternoPrecedente viene utilizzato per la gestione delle catene dei referti
        '
        Dim xmlAttributiReferti As Xml.XmlDocument = Nothing
        Dim xmlAttributiPrestazione As Xml.XmlDocument = Nothing
        Dim xmlAttributiAllegato As Xml.XmlDocument = Nothing

        Dim mutSync As Mutex = Nothing

        Dim oEpisodioAdapter As EpisodioAdapter = Nothing
        Dim bRefertoEsiste As Boolean
        Dim nErrNumber As Int16 = 0
        Dim oSacAdapter As SacAdapter = Nothing
        Dim uotRepartoRichiedenteTranscodificato As UnitaOperativaTranscodificata = Nothing
        '
        ' Verifiche dei parametri
        '
        If Messaggio Is Nothing Then
            Throw New System.ArgumentException("Il parametro Messaggio è vuoto!", "Messaggio")
        End If

        If Data = Nothing Then
            Throw New System.ArgumentException("Il parametro Data è vuoto!", "Data")
        End If

        If Messaggio.Paziente Is Nothing Then
            Throw New System.ApplicationException("Manca il nodo Paziente nel Messaggio!")
        End If

        If Messaggio.Referto Is Nothing Then
            Throw New System.ApplicationException("Manca il nodo Referto nel Messaggio!")
        End If

        Dim sIdEsterno As String = Messaggio.Referto.IdEsternoReferto & ""
        If sIdEsterno.Length = 0 Then
            Throw New System.ApplicationException("Il campo IdEsterno del messaggio è vuoto!")
        End If
        '
        ' Controllo operazioni
        '
        If Tipo = TipoMessaggio.Fusione Then
            Throw New System.InvalidOperationException("Non è posibile fondere un Episodio!")
        End If

        Try
            'MODIFICA ETTORE 2020-02-26: Tolgo spazi dall'azienda e del sistema erogante e verifico che non siano vuoti
            Messaggio.Referto.AziendaErogante = Trim(Messaggio.Referto.AziendaErogante & "")
            Messaggio.Referto.SistemaErogante = Trim(Messaggio.Referto.SistemaErogante & "")
            If String.IsNullOrEmpty(Messaggio.Referto.AziendaErogante) Then
                '
                ' AziendaErogante non valorizzata
                '
                Throw New System.Exception("L'azienda erogante del referto non è valorizzata!")
            End If
            If String.IsNullOrEmpty(Messaggio.Referto.SistemaErogante) Then
                '
                ' SistemaErogante non valorizzato
                '
                Throw New System.Exception("Il sistema erogante del referto non è valorizzato!")
            End If

            '
            ' Serializzo accesso
            '
            Dim sSyncLock As String
            Select Case ConfigUtil.GetSyncLevel
                Case ConfigUtil.SyncLevel.IdEsterno : sSyncLock = GetType(EpisodioAdapter).ToString & "_" & sIdEsterno
                Case ConfigUtil.SyncLevel.Sistema : sSyncLock = GetType(EpisodioAdapter).ToString & "_" & Messaggio.Referto.SistemaErogante
                Case ConfigUtil.SyncLevel.Tipo : sSyncLock = GetType(EpisodioAdapter).ToString
                Case Else : sSyncLock = GetType(EpisodioAdapter).ToString
            End Select
            mutSync = ConfigUtil.GetMutex(sSyncLock)
            '
            ' Creo adapter, apro connessione e transazione
            '
            oEpisodioAdapter = New EpisodioAdapter

            '
            ' MODIFICA ETTORE 2018-02-20: verifico la dimensione degli allegati
            '
            If Not Messaggio.Allegati Is Nothing Then
                If My.Config.MaxTotalSizeAllegatiRefertoMb > 0 Then
                    Dim iTotalSizeAllegati_Byte As Integer = 0
                    For Each oAllegato As Allegato In Messaggio.Allegati
                        Dim abyteMimeData As Byte() = System.Convert.FromBase64String(oAllegato.MimeData & "")
                        iTotalSizeAllegati_Byte = iTotalSizeAllegati_Byte + abyteMimeData.GetLength(0)
                    Next
                    Dim iTotalSizeAllegati_Mb As Double = iTotalSizeAllegati_Byte / (1024 * 1024)
                    If iTotalSizeAllegati_Mb > My.Config.MaxTotalSizeAllegatiRefertoMb Then
                        Throw New System.Exception(String.Format("Il referto non può essere inserito/aggiornato perchè la dimensione totale degli allegati ({0} Mb) è maggiore della dimensione massima consentita ({1} Mb)", Format(iTotalSizeAllegati_Mb, "0.00"), My.Config.MaxTotalSizeAllegatiRefertoMb))
                    End If
                End If
            End If

            '
            ' Apro la connesione al database
            '
            Try
                oEpisodioAdapter.ConnectionOpen(My.Config.ConnectionString)
            Catch ex As Exception
                Throw New ConnectionException(GetDatabaseInfo(My.Config.ConnectionString) & vbCrLf & ex.Message)
            End Try

            oEpisodioAdapter.TransactionBegin(ConfigUtil.GetIsolationLevel())
            '
            ' MODIFICA ETTORE 2020-02-26: controllo dell'azienda erogante e del sistema erogante (fuori dalla transazione)
            '
            If Not VerificaAziendaEroganteSistemaEroganteReferto(Messaggio.Referto.AziendaErogante, Messaggio.Referto.SistemaErogante) Then
                '
                ' AziendaErogante/SistemaErogante non configurato
                '
                Throw New System.Exception(String.Format("Il sistema [AziendaErogante, SistemaErogante]=['{0}','{1}'] non è configurato per i referti!", Messaggio.Referto.AziendaErogante, Messaggio.Referto.SistemaErogante))
            End If
            '
            ' MODIFICA ETTORE 2019-02-22: Leggo le Aziende eroganti dal database (fuori dalla transazione)
            '
            Dim oListAziendeEroganti As System.Collections.Generic.List(Of String) = ConfigSingleton.AziendeErogantiLista
            '
            ' Autoprefix: aggiungo il prefisso AziendaErogante all'IdEsterno del referto, se non è già presente
            ' MODIFICA ETTORE 2019-02-22: spostato qui. Originariamente era prima del MUTEX
            '
            If AutoprefixIdEsterno(Messaggio.Referto.IdEsternoReferto, Messaggio.Referto.AziendaErogante, oListAziendeEroganti, sIdEsterno) Then
                '
                ' Scrivo nella tabella LogAutoprefix
                '
                oEpisodioAdapter.LogAutoPrefixAdd(Messaggio.Referto.AziendaErogante, Messaggio.Referto.SistemaErogante, Messaggio.Referto.RepartoErogante, sIdEsterno)
            End If
            Messaggio.Referto.IdEsternoReferto = sIdEsterno

            '
            ' Chiamo la ExtRefertiBeforeProcess...
            '
            '-------------------------------------------------------------------------------------------------------
            ' Modifica Ettore 2013-03-04:
            ' passiamo alla ExtBeforeProcess() e ExtAfterProcess() il parametro ImportazioneStorica
            ' in base al quale le SP decidono se notificare l'operazione sul referto
            '-------------------------------------------------------------------------------------------------------
            Dim sImportazioneStorica As String = GetValoreAttributo(Messaggio.Referto.Attributi, "ImportazioneStorica", "0")
            Dim bImportazioneStorica As Boolean = False
            If sImportazioneStorica = "1" Then bImportazioneStorica = True
            oEpisodioAdapter.RefertiBeforeProcess(sIdEsterno, Tipo, bImportazioneStorica)
            '
            ' Gestione delle catene di referti
            '
            If Not String.IsNullOrEmpty(IdEsternoPrecedente) Then
                '
                ' Mi assicuro che anche l'IdEsternoPrecedente abbia il prefisso con l'AziendaErogante
                ' MODIFICA ETTORE 2019-02-22: uso nuova funzione di Autoprefix)
                If AutoprefixIdEsterno(IdEsternoPrecedente, Messaggio.Referto.AziendaErogante, oListAziendeEroganti, IdEsternoPrecedente) Then
                    '
                    ' Scrivo nella tabella LogAutoprefix
                    '
                    oEpisodioAdapter.LogAutoPrefixAdd(Messaggio.Referto.AziendaErogante, Messaggio.Referto.SistemaErogante, Messaggio.Referto.RepartoErogante, IdEsternoPrecedente)
                End If

                oEpisodioAdapter.RefertiRiferimentiAggiungi(sIdEsterno, IdEsternoPrecedente, Data)
            End If
            '
            ' Verifico versione del referto tramite data esterna
            '
            Dim dtDataEsterno As Date = Data
            Dim dtDataModifica As Date = oEpisodioAdapter.RefertiContains(sIdEsterno)
            If dtDataModifica <> Nothing Then
                '
                ' Modifica Ettore 2013-03-04 
                ' Il controllo della data sequenza lo faccio solo per importazioni non storiche, 
                ' cioè il flusso standard di importazione
                '
                If bImportazioneStorica = False Then
                    '
                    ' Esiste. Verifico se data esterna è maggiore
                    '
                    If dtDataEsterno < dtDataModifica Then
                        '
                        ' Errore di versione
                        ' Non modifica il referto e i suoi figli
                        '
                        nErrNumber = 6
                        Dim sError As String = String.Format("Referto già modificato con data esterna maggiore! DataEsterno={0:s}, DataModifica={1:s}.", _
                                                                dtDataEsterno, dtDataModifica)
                        Throw New System.Exception(sError)
                    End If
                End If
            End If
            '
            ' Referto esiste se data modifica non nulla
            '
            bRefertoEsiste = (dtDataModifica <> Nothing)
            '
            ' Dati episodio e paziente
            '
            Dim sIdEsternoAssociato As String = ""

            Dim dtDataNascita As Date
            Dim dtDataReferto As Date
            Dim sXmlAttributiReferti As String = ""
            Dim oIdPazienteSac As Guid = Nothing
            '
            ' Controllo azione
            '
            Select Case Tipo
                Case TipoMessaggio.Aggiunge, TipoMessaggio.Modifica
                    '
                    ' ------------------------------------------------------------------------------------------
                    '  Aggiorno referto
                    ' ------------------------------------------------------------------------------------------
                    ' Estraggo campi referto
                    '
                    dtDataNascita = XmlUtil.ParseDatetime(Messaggio.Paziente.DataNascita & "")
                    dtDataReferto = XmlUtil.ParseDatetime(Messaggio.Referto.DataReferto & "")

                    '
                    ' Creo un XmlDoc contenente gli attributi del referto
                    '
                    xmlAttributiReferti = XmlUtil.CreateXdocAttributi(Messaggio.Referto.Attributi)
                    ' ------------------------------------------------------------------------------------------
                    ' Collegamento al paziente
                    ' Join paziente con il SAC
                    ' ------------------------------------------------------------------------------------------

                    Dim sNomeAnagraficaDiRicerca As String = _
                                    oEpisodioAdapter.PazientiLookUpNomeAnagraficaDiRicerca(Messaggio.Paziente.NomeAnagraficaCentrale & "", _
                                                                                           Messaggio.Referto.AziendaErogante & "")
                    '
                    ' Instazio adapter per il SAC
                    '
                    oSacAdapter = New SacAdapter
                    Try
                        oSacAdapter.ConnectionOpen(My.Config.ConnectionStringSac)
                    Catch ex As Exception
                        Throw New ConnectionException(GetDatabaseInfo(My.Config.ConnectionStringSac) & vbCrLf & ex.Message)
                    End Try
                    oIdPazienteSac = JoinPazienteSacReferto(oSacAdapter, Messaggio, sNomeAnagraficaDiRicerca)
                    ' ------------------------------------------------------------------------------------------
                    ' Transcodifica delle Unita Operative (per il referto è il "reparto richiedente")
                    ' ------------------------------------------------------------------------------------------
                    If My.Config.TranscodificaUoReferti Then
                        If Not String.IsNullOrEmpty(Messaggio.Referto.RepartoRichiedenteCodice) Then
                            uotRepartoRichiedenteTranscodificato = TranscodificaUnitaOperativa( _
                                                                oSacAdapter, _
                                                                Messaggio.Referto.AziendaErogante, Messaggio.Referto.SistemaErogante, _
                                                                Messaggio.Referto.AziendaErogante, Messaggio.Referto.RepartoRichiedenteCodice, Messaggio.Referto.RepartoRichiedenteDescrizione)
                        End If
                    End If
                    '
                    ' 2018-05-29 - MODIFICA ETTORE: Transcodifica del Regime (=TipoRichiestaCodice)
                    '
                    If Not String.IsNullOrEmpty(Messaggio.Referto.TipoRichiestaCodice) Then
                        Dim oTipoRichiesta As DataAccess.Esterno.EpisodioAdapter.CodiceDescrizioneType = oEpisodioAdapter.TranscodificaRegimi(Messaggio.Referto.AziendaErogante, _
                                                                                                                                            Messaggio.Referto.SistemaErogante, _
                                                                                                                                            Messaggio.Referto.TipoRichiestaCodice)
                        If Not oTipoRichiesta Is Nothing Then
                            'Ho trovato la transcodifica per TipoRichiestaCodice: modifico i valori originali di codice e descrizione
                            Messaggio.Referto.TipoRichiestaCodice = oTipoRichiesta.Codice
                            Messaggio.Referto.TipoRichiestaDescrizione = oTipoRichiesta.Descrizione
                        End If
                    End If

                    '
                    ' 2018-05-29 - MODIFICA ETTORE: Transcodifica della priorita
                    '
                    If Not String.IsNullOrEmpty(Messaggio.Referto.PrioritaCodice) Then
                        Dim oPriorita As DataAccess.Esterno.EpisodioAdapter.CodiceDescrizioneType = oEpisodioAdapter.TranscodificaPriorita(Messaggio.Referto.AziendaErogante, _
                                                                                                                                        Messaggio.Referto.SistemaErogante, _
                                                                                                                                        Messaggio.Referto.PrioritaCodice)
                        If Not oPriorita Is Nothing Then
                            'Ho trovato la transcodifica per PrioritaCodice: modifico i valori originali di codice e descrizione
                            Messaggio.Referto.PrioritaCodice = oPriorita.Codice
                            Messaggio.Referto.PrioritaDescrizione = oPriorita.Descrizione
                        End If
                    End If

                    '
                    ' Aggiungo agli attributi del referto gli attributi del paziente
                    '
                    Dim oAttributo1 As ConnectorV2.Attributo = New ConnectorV2.Attributo("CodiceAnagraficaCentrale", Messaggio.Paziente.CodiceAnagraficaCentrale & "")
                    Dim oAttributo2 As ConnectorV2.Attributo = New ConnectorV2.Attributo("NomeAnagraficaCentrale", Messaggio.Paziente.NomeAnagraficaCentrale & "")
                    Dim oAttributo3 As ConnectorV2.Attributo = New ConnectorV2.Attributo("Cognome", Messaggio.Paziente.Cognome & "")
                    Dim oAttributo4 As ConnectorV2.Attributo = New ConnectorV2.Attributo("Nome", Messaggio.Paziente.Nome & "")
                    Dim oAttributo5 As ConnectorV2.Attributo = New ConnectorV2.Attributo("Sesso", Messaggio.Paziente.Sesso & "")
                    Dim oAttributo6 As ConnectorV2.Attributo = New ConnectorV2.Attributo("DataNascita", XmlUtil.FormatDatetime(dtDataNascita))
                    Dim oAttributo7 As ConnectorV2.Attributo = New ConnectorV2.Attributo("ComuneNascita", Messaggio.Paziente.LuogoNascita & "")
                    Dim oAttributo8 As ConnectorV2.Attributo = New ConnectorV2.Attributo("CodiceFiscale", Messaggio.Paziente.CodiceFiscale & "")
                    Dim oAttributo9 As ConnectorV2.Attributo = New ConnectorV2.Attributo("CodiceSanitario", Messaggio.Paziente.CodiceSanitario & "")
                    '
                    ' Aggiungo Attributi di visualizzazione al referto
                    '
                    Dim oAttributo10 As ConnectorV2.Attributo = New ConnectorV2.Attributo("NomeStile", Messaggio.StileVisualizzazione & "")
                    Dim oAttributo11 As ConnectorV2.Attributo = New ConnectorV2.Attributo("TipoDati", _
                                                                    CType(IIf(Messaggio.DatiSoloPerCercare, "XML", "DWH"), String))
                    'Aggiungo anche l'IdEsternoPaziente agli attributi del referto
                    Dim oAttributo12 As ConnectorV2.Attributo = New ConnectorV2.Attributo("IdEsternoPaziente", Messaggio.Paziente.IdEsternoPaziente & "")
                    '
                    ' Creo array e aggiungo a stream
                    '
                    Dim oAttributi() As ConnectorV2.Attributo = New ConnectorV2.Attributo() {oAttributo1, oAttributo2, oAttributo3, _
                                                                                            oAttributo4, oAttributo5, oAttributo6, _
                                                                                            oAttributo7, oAttributo8, oAttributo9, _
                                                                                            oAttributo10, oAttributo11, oAttributo12}

                    '
                    ' Aggiungo all'XmlDoc contenente gli attributi del referto gli attributi anagrafici del paziente
                    '
                    xmlAttributiReferti = XmlUtil.AddXdocAttributi(xmlAttributiReferti, oAttributi)

                    '
                    ' MODIFICA ETTORE 2018-02-05: Autogenerazione attributo "Anteprima"
                    '
                    ' XmlUtil.FindXdocAttributo restituisce nothing se no lo trova e se lo trova è valorizzato!!!
                    '
                    Dim oNodeAnteprima As Xml.XmlNode = XmlUtil.FindXdocAttributo(xmlAttributiReferti, "Anteprima")
                    If oNodeAnteprima Is Nothing Then
                        '
                        ' Lo devo aggiungere
                        ' Lo posso sempre aggiungere al "document xml" xmlAttributiReferti perchè XmlUtil.AddXdocAttributi() non aggiunge all'XML attributi con valore vuoto
                        '
                        Dim bGeneraAnteprimaReferto As Boolean = oEpisodioAdapter.RefertiGeneraAnteprima(Messaggio.Referto.AziendaErogante, Messaggio.Referto.SistemaErogante)
                        If bGeneraAnteprimaReferto Then
                            Dim sAttributo_Anteprima_Valore As String = BuildAnteprimaReferto(Messaggio.Prestazioni)
                            If Not String.IsNullOrEmpty(sAttributo_Anteprima_Valore) Then
                                '
                                ' Aggiungo l'attributo "Anteprima"
                                '
                                Dim oAttributo_Anteprima As ConnectorV2.Attributo = New ConnectorV2.Attributo("Anteprima", sAttributo_Anteprima_Valore)
                                Dim oAttrib() As ConnectorV2.Attributo = New ConnectorV2.Attributo() {oAttributo_Anteprima}
                                xmlAttributiReferti = XmlUtil.AddXdocAttributi(xmlAttributiReferti, oAttrib)
                            End If
                        End If
                    End If
                    '
                    ' Se è avvenuta una transcodifica del reparto richiedente aggiungo due attributi del referto
                    '       UnitaOperativaRichiedenteCodice <- Messaggio.Referto.RepartoRichiedenteCodice
                    '       UnitaOperativaRichiedenteDescrizione <- Messaggio.Referto.RepartoRichiedenteDescrizione
                    ' e sostituisco Messaggio.Referto.RepartoRichiedenteCodice <= codice_transcodificato@azienda_transcodificata 
                    ' e Messaggio.Referto.RepartoRichiedenteDescrizione <= descrizione_transcodificata
                    '
                    If Not uotRepartoRichiedenteTranscodificato Is Nothing Then
                        If (Messaggio.Referto.RepartoRichiedenteCodice <> uotRepartoRichiedenteTranscodificato.Codice) OrElse _
                            (Messaggio.Referto.AziendaErogante <> uotRepartoRichiedenteTranscodificato.Azienda) Then
                            Dim oAttrRepartoRichiedenteCodice As ConnectorV2.Attributo = New ConnectorV2.Attributo("UnitaOperativaRichiedenteCodice", Messaggio.Referto.RepartoRichiedenteCodice)
                            Dim oAttrRepartoRichiedenteDescrizione As ConnectorV2.Attributo = New ConnectorV2.Attributo("UnitaOperativaRichiedenteDescrizione ", Messaggio.Referto.RepartoRichiedenteDescrizione)
                            Dim oAttributiRepRich() As ConnectorV2.Attributo = New ConnectorV2.Attributo() {oAttrRepartoRichiedenteCodice, oAttrRepartoRichiedenteDescrizione}
                            xmlAttributiReferti = XmlUtil.AddXdocAttributi(xmlAttributiReferti, oAttributiRepRich)
                            '
                            ' A questo punto aggiorno il Messaggio.Referto con i nuovi valori transcodificati
                            '
                            Messaggio.Referto.RepartoRichiedenteCodice = String.Format("{0}@{1}", uotRepartoRichiedenteTranscodificato.Codice, uotRepartoRichiedenteTranscodificato.Azienda)
                            Messaggio.Referto.RepartoRichiedenteDescrizione = uotRepartoRichiedenteTranscodificato.Descrizione
                        End If
                    End If
                    '
                    ' Dall'XmlDocument contenente gli attributi del referto ottengo una stringa codificata ISO-8859-1
                    '
                    sXmlAttributiReferti = XmlUtil.GetXmlWriterAttributi(xmlAttributiReferti)

                    '
                    ' ------------------------------------------------------------------------------------------
                    ' Controllo se referto esiste già
                    ' ------------------------------------------------------------------------------------------
                    '
                    If bRefertoEsiste Then
                        '
                        ' Aggiorno se c'è
                        '
                        If oEpisodioAdapter.RefertiUpdate(sIdEsterno, oIdPazienteSac, _
                                                Messaggio.Referto.AziendaErogante & "", _
                                                Messaggio.Referto.SistemaErogante & "", _
                                                Messaggio.Referto.RepartoErogante & "", _
                                                Messaggio.Referto.SezioneErogante & "", _
                                                Messaggio.Referto.SpecialitaErogante & "", _
                                                dtDataReferto, _
                                                Messaggio.Referto.NumeroReferto & "", _
                                                Messaggio.Referto.NumeroPrenotazione & "", _
                                                Messaggio.Referto.NumeroNosologico & "", _
                                                Messaggio.Referto.PrioritaCodice & "", _
                                                Messaggio.Referto.PrioritaDescrizione & "", _
                                                Messaggio.Referto.StatoRichiestaCodice & "", _
                                                Messaggio.Referto.StatoRichiestaDescrizione & "", _
                                                Messaggio.Referto.TipoRichiestaCodice & "", _
                                                Messaggio.Referto.TipoRichiestaDescrizione & "", _
                                                Messaggio.Referto.RepartoRichiedenteCodice & "", _
                                                Messaggio.Referto.RepartoRichiedenteDescrizione & "", _
                                                Messaggio.Referto.MedicoRefertanteCodice & "", _
                                                Messaggio.Referto.MedicoRefertanteDescrizione & "", _
                                                sXmlAttributiReferti) Then
                            '
                            ' Aggiorno data modifica esterna
                            '
                            oEpisodioAdapter.RefertiDataModificaUpdate(sIdEsterno, dtDataEsterno)
                            '
                            ' Log evento
                            '
                            LogEvent.WriteInformation("Modificato refeto!" & vbCrLf & _
                                            "IdEsterno = '" & sIdEsterno & "'" & vbCrLf & _
                                            "Azienda = '" & Messaggio.Referto.AziendaErogante & "'" & vbCrLf & _
                                            "Sistema = '" & Messaggio.Referto.SistemaErogante & "'" & vbCrLf & _
                                            "Reparto = '" & Messaggio.Referto.RepartoErogante & "'" & vbCrLf & _
                                            "DataReferto = '" & Messaggio.Referto.DataReferto & "'" & vbCrLf & _
                                            "NumeroReferto = '" & Messaggio.Referto.NumeroReferto & "'")
                        Else
                            '
                            ' Errore se non c'è
                            '
                            nErrNumber = 12
                            Throw New System.Exception("Errore durante modifica referto!")
                        End If
                        '
                        ' Rimuovo prestazioni e allegati, dopo saranno riaggiunti
                        '
                        oEpisodioAdapter.PrestazioniRemove(sIdEsterno, "")
                        oEpisodioAdapter.AllegatiRemove(sIdEsterno, "")
                    Else
                        '
                        ' Inserisco nuovo
                        '
                        If oEpisodioAdapter.RefertiAddNew(sIdEsterno, oIdPazienteSac, _
                                                Messaggio.Referto.AziendaErogante & "", _
                                                Messaggio.Referto.SistemaErogante & "", _
                                                Messaggio.Referto.RepartoErogante & "", _
                                                Messaggio.Referto.SezioneErogante & "", _
                                                Messaggio.Referto.SpecialitaErogante & "", _
                                                dtDataReferto, _
                                                Messaggio.Referto.NumeroReferto & "", _
                                                Messaggio.Referto.NumeroPrenotazione & "", _
                                                Messaggio.Referto.NumeroNosologico & "", _
                                                Messaggio.Referto.PrioritaCodice & "", _
                                                Messaggio.Referto.PrioritaDescrizione & "", _
                                                Messaggio.Referto.StatoRichiestaCodice & "", _
                                                Messaggio.Referto.StatoRichiestaDescrizione & "", _
                                                Messaggio.Referto.TipoRichiestaCodice & "", _
                                                Messaggio.Referto.TipoRichiestaDescrizione & "", _
                                                Messaggio.Referto.RepartoRichiedenteCodice & "", _
                                                Messaggio.Referto.RepartoRichiedenteDescrizione & "", _
                                                Messaggio.Referto.MedicoRefertanteCodice & "", _
                                                Messaggio.Referto.MedicoRefertanteDescrizione & "", _
                                                sXmlAttributiReferti) Then
                            '
                            ' Aggiorno data modifica esterna
                            '
                            oEpisodioAdapter.RefertiDataModificaUpdate(sIdEsterno, dtDataEsterno)
                            '
                            ' Log evento
                            '
                            LogEvent.WriteInformation("Aggiunto refeto mancante!" & vbCrLf & _
                                            "IdEsterno = '" & sIdEsterno & "'" & vbCrLf & _
                                            "Azienda = '" & Messaggio.Referto.AziendaErogante & "'" & vbCrLf & _
                                            "Sistema = '" & Messaggio.Referto.SistemaErogante & "'" & vbCrLf & _
                                            "Reparto = '" & Messaggio.Referto.RepartoErogante & "'" & vbCrLf & _
                                            "DataReferto = '" & Messaggio.Referto.DataReferto & "'" & vbCrLf & _
                                            "NumeroReferto = '" & Messaggio.Referto.NumeroReferto & "'")
                        Else
                            '
                            ' Errore se non c'è
                            '
                            nErrNumber = 13
                            Throw New System.Exception("Errore durante inserimento referto!")
                        End If
                    End If
                    '
                    ' ------------------------------------------------------------------------------------------
                    ' Aggiungo prestazioni
                    ' ------------------------------------------------------------------------------------------
                    '
                    If Not Messaggio.Prestazioni Is Nothing Then
                        For Each oPrestazione As Prestazione In Messaggio.Prestazioni
                            '
                            ' Creo strea attributi
                            '
                            xmlAttributiPrestazione = XmlUtil.CreateXdocAttributi(oPrestazione.Attributi)
                            Dim sXmlAttributiPrestazione As String = XmlUtil.GetXmlWriterAttributi(xmlAttributiPrestazione)
                            '
                            ' Lo pongo a nothing per ciclo successivo
                            '
                            xmlAttributiPrestazione = Nothing

                            Dim dtDataPrestazione As Date = XmlUtil.ParseDatetime(oPrestazione.DataErogazione & "")

                            If Not oEpisodioAdapter.PrestazioniAddNew(sIdEsterno, _
                                                                oPrestazione.IdEsternoPrestazione & "", _
                                                                dtDataPrestazione, _
                                                                oPrestazione.PrestazioneCodice & "", _
                                                                oPrestazione.PrestazioneDescrizione & "", _
                                                                oPrestazione.PrestazionePosizione, _
                                                                oPrestazione.SezioneCodice & "", _
                                                                oPrestazione.SezioneDescrizione & "", _
                                                                oPrestazione.SezionePosizione, _
                                                                oPrestazione.GravitaCodice & "", _
                                                                oPrestazione.GravitaDescrizione & "", _
                                                                oPrestazione.Quantita & "", _
                                                                oPrestazione.Risultato & "", _
                                                                oPrestazione.ValoriRiferimento & "", _
                                                                oPrestazione.PrestazioneCommenti & "", _
                                                                sXmlAttributiPrestazione) Then
                                '
                                ' Errore se non c'è
                                '
                                nErrNumber = 21
                                Throw New System.Exception("Errore durante inserimento prestazione!" & vbCrLf & _
                                                        "IdEsternoPrestazione = '" & oPrestazione.IdEsternoPrestazione & "'")
                            End If
                        Next
                    End If
                    '
                    ' ------------------------------------------------------------------------------------------
                    ' Riaggiungo allegati
                    ' ------------------------------------------------------------------------------------------
                    '
                    If Not Messaggio.Allegati Is Nothing Then
                        For Each oAllegato As Allegato In Messaggio.Allegati
                            '
                            ' Creo strea attributi
                            '
                            xmlAttributiAllegato = XmlUtil.CreateXdocAttributi(oAllegato.Attributi)
                            Dim sXmlAttributiAllegato As String = XmlUtil.GetXmlWriterAttributi(xmlAttributiAllegato)
                            '
                            ' Lo pongo a nothing per ciclo successivo
                            '
                            xmlAttributiAllegato = Nothing

                            Dim dtDataAllegato As Date = XmlUtil.ParseDatetime(oAllegato.DataFile & "")
                            Dim abyteMimeData As Byte() = System.Convert.FromBase64String(oAllegato.MimeData & "")

                            If Not oEpisodioAdapter.AllegatiAddNew(sIdEsterno, _
                                                                oAllegato.IdEsternoAllegato & "", _
                                                                dtDataAllegato, _
                                                                oAllegato.NomeFile & "", _
                                                                oAllegato.Descrizione & "", _
                                                                oAllegato.Posizione, _
                                                                oAllegato.StatoCodice & "", _
                                                                oAllegato.StatoDescrizione & "", _
                                                                oAllegato.MimeType & "", _
                                                                abyteMimeData, _
                                                                sXmlAttributiAllegato) Then
                                '
                                ' Errore se non c'è
                                '
                                nErrNumber = 21
                                Throw New System.Exception("Errore durante inserimento allegato!" & vbCrLf & _
                                                        "IdEsternoAllegato = '" & oAllegato.IdEsternoAllegato & "'")
                            End If
                        Next
                    End If

                Case TipoMessaggio.Rimuove

                    ' ------------------------------------------------------------------------------------------
                    ' Rimuovo
                    ' ------------------------------------------------------------------------------------------

                    If bRefertoEsiste Then
                        '
                        ' Rimuovo se c'è
                        '
                        ' MODIFICA ETTORE 2015-02-16: Memorizzo l'IdPaziente del referto per usarlo per impostare il ricalcolo dell'anteprima
                        '
                        oIdPazienteSac = oEpisodioAdapter.RefertiGetIdPaziente(sIdEsterno)
                        '
                        ' Operazioni di cancellazione referto
                        '
                        oEpisodioAdapter.AllegatiRemove(sIdEsterno, "")
                        oEpisodioAdapter.PrestazioniRemove(sIdEsterno, "")
                        If oEpisodioAdapter.RefertiRemove(sIdEsterno) Then
                            '
                            ' Log evento
                            '
                            LogEvent.WriteInformation("Rimosso referto!" & vbCrLf & _
                                            "IdEsterno = '" & sIdEsterno & "'" & vbCrLf & _
                                            "Azienda = '" & Messaggio.Referto.AziendaErogante & "'" & vbCrLf & _
                                            "Sistema = '" & Messaggio.Referto.SistemaErogante & "'" & vbCrLf & _
                                            "Reparto = '" & Messaggio.Referto.RepartoErogante & "'" & vbCrLf & _
                                            "DataReferto = '" & Messaggio.Referto.DataReferto & "'" & vbCrLf & _
                                            "NumeroReferto = '" & Messaggio.Referto.NumeroReferto & "'")
                        End If
                    Else
                        '
                        ' Se non c'è warning
                        '
                        LogEvent.WriteWarning("Referto non trovata durante la cancellazione! IdEsterno=" & sIdEsterno)
                    End If

            End Select
            '
            ' Chiamo la ExtRefertiAfterProcess...
            '
            oEpisodioAdapter.RefertiAfterProcess(sIdEsterno, Tipo, bImportazioneStorica)
            '
            ' ------------------------------------------------------------------------------------------
            ' Commit tutte le modifiche
            ' ------------------------------------------------------------------------------------------
            '
            oEpisodioAdapter.TransactionCommit()
            '
            ' MODIFICA ETTORE 2015-02-16: imposto il ricalcolo dell'anteprima paziente (parte referto) (fuori dalla transazione)
            ' L'errore è controllato internamente
            '
            Dim oAnteprimaPazienti As New AnteprimaPazienti
            oAnteprimaPazienti.RefertiCalcolaAnteprimaPaziente(oIdPazienteSac)
            '
            ' Ritorna OK
            '
            Return New Risultato(0, "")

        Catch ex As Exception
            '
            ' Roolback tutte le modifiche
            '
            Dim sErrRollBack As String = String.Empty
            Try
                If Not oEpisodioAdapter Is Nothing Then
                    oEpisodioAdapter.TransactionRoolback()
                End If
            Catch ex2 As Exception
                sErrRollBack = String.Format("Errore durante il rollback della transazione relativa a ConnectorV2.Episodio(); Tipo={0}, IdEsterno={1}{2}{3}", _
                                                        Tipo, sIdEsterno, vbCrLf, ex2.Message)
                LogEvent.WriteError(ex2, sErrRollBack)
            End Try
            '
            ' Scrive Log
            '
            Dim sMessage As String
            sMessage = String.Format("Errore durante ConnectorV2.Episodio(); Tipo={0}, IdEsterno={1}{2}{3}", _
                                                                        Tipo, sIdEsterno, vbCrLf, ex.Message)

            '
            ' Log error o warning
            '
            If nErrNumber = 6 Then
                '
                ' Data sequenza
                '
                LogEvent.WriteWarning(sMessage)
            Else
                LogEvent.WriteError(ex, sMessage)
            End If
            '
            ' A questo punto verifico se l'eccezione è un errore di connessione
            ' oppure una SqlException dovuta ad un timeout, deadlock
            '
            If TypeOf ex Is ConnectionException Then
                Throw New ConnectionException(sMessage)
            ElseIf TypeOf ex Is CommandTimeoutException Then
                'Cosi posso usare anche questo tipo di eccezione volendo, invece di controllare una SqlException con Number=-2 
                Throw New CommandTimeoutException(sMessage)
            ElseIf TypeOf ex Is SqlClient.SqlException Then
                Dim ExSql As SqlClient.SqlException = CType(ex, SqlClient.SqlException)
                If ExSql.Number = SqlExceptionNumber.Timeout Then 'TimeoutError
                    Throw New CommandTimeoutException(sMessage)
                ElseIf ExSql.Number = SqlExceptionNumber.DeadLock Then
                    Throw
                End If
            End If
            '
            ' Risultato o eccezione
            '
            If nErrNumber > 0 Then
                Throw New System.ApplicationException(sMessage & vbCrLf & "ErrNumber=" & nErrNumber.ToString, ex)
            Else
                Throw New System.Exception(sMessage, ex)
            End If

        Finally
            '
            ' Rilascia sincronismo
            '
            If Not mutSync Is Nothing Then
                Try
                    mutSync.ReleaseMutex()
                    mutSync.Close()
                Catch ex As Exception
                End Try
            End If
            '
            ' Chiude connessione se aperta
            '
            If Not oEpisodioAdapter Is Nothing Then
                oEpisodioAdapter.Dispose()
            End If
            '
            ' Pongo a nothing gli XmlDocument creati per la gestione degli attributi
            '
            xmlAttributiReferti = Nothing
            xmlAttributiPrestazione = Nothing
            xmlAttributiAllegato = Nothing
            '
            ' Chiude connessione al SAC se aperta
            '
            If Not oSacAdapter Is Nothing Then
                oSacAdapter.Dispose()
            End If
            '
            ' Pongo a nothing la classe che contiene la transcodifica del reparto richiedente
            '
            uotRepartoRichiedenteTranscodificato = Nothing
        End Try


    End Function

    Public Function Anagrafica(ByVal Tipo As ConnectorV2.TipoMessaggio, _
                        ByVal Data As DateTime, _
                        ByVal Messaggio As ConnectorV2.MessaggioAnagrafica) As Risultato
        Dim iDelayMs As Integer = 0
        Dim iCounterRetry As Integer = 0
        While True
            Try
                ' Esecuzione delle operazioni di aggiornamento
                iCounterRetry = iCounterRetry + 1
                Return _Anagrafica(Tipo, Data, Messaggio)

            Catch ex As ConnectionException
                ' Se ho raggiunto il numero max di retry esco con throw dell'eccezione: l'orchestrazione eseguirà il suo loop di retry
                If iCounterRetry >= My.Config.ConnectionErrorNumRetry Then
                    Throw New System.Exception(ex.Message)
                End If
                ' Imposto il delay
                iDelayMs = My.Config.ConnectionErrorDelayRetry * 1000

            Catch ex As CommandTimeoutException
                ' Se ho raggiunto il numero max di retry esco con throw dell'eccezione: l'orchestrazione eseguirà il suo loop di retry
                If iCounterRetry >= My.Config.CommandTimeoutNumRetry Then
                    Throw New System.Exception(ex.Message)
                End If
                ' Imposto il delay
                iDelayMs = My.Config.CommandTimeoutDelayRetry * 1000

            Catch ex As SqlException
                If ex.Number = SqlExceptionNumber.Timeout Then
                    If iCounterRetry >= My.Config.CommandTimeoutNumRetry Then
                        Throw New System.Exception(ex.Message)
                    End If
                    iDelayMs = My.Config.CommandTimeoutDelayRetry * 1000

                ElseIf ex.Number = SqlExceptionNumber.DeadLock Then
                    If iCounterRetry >= My.Config.DeadLockNumRetry Then
                        Throw New System.Exception(ex.Message)
                    End If
                    iDelayMs = My.Config.DeadLockDelayRetry * 1000

                End If

            Catch ex As System.ApplicationException
                ' L'orchestrazione eseguirà il suo loop di retry
                Throw

            Catch ex As Exception
                ' L'orchestrazione eseguirà il suo loop di retry
                Throw

            End Try
            '
            ' Attendo il tempo di Delay (in millisecondi)
            '
            Thread.Sleep(iDelayMs)
        End While
        ' Qui non ci arriva mai
        Return Nothing

    End Function

    Private Function _Anagrafica(ByVal Tipo As ConnectorV2.TipoMessaggio, _
                            ByVal Data As DateTime, _
                            ByVal Messaggio As ConnectorV2.MessaggioAnagrafica) As Risultato

        Dim mutSync As Mutex = Nothing
        Dim xmlAttributiAnagrafica As Xml.XmlDocument = Nothing

        Dim oAnagraficaAdapter As AnagraficaAdapter = Nothing
        Dim sIdEsterno As String
        Dim bAnagraficaEsiste As Boolean
        Dim nErrNumber As Int16 = 0
        '
        ' Verifiche dei parametri
        '
        If Messaggio Is Nothing Then
            Throw New System.ArgumentException("Il parametro Messaggio è vuoto!", "Messaggio")
        End If

        If Data = Nothing Then
            Throw New System.ArgumentException("Il parametro Data è vuoto!", "Data")
        End If

        sIdEsterno = Messaggio.IdEsternoPaziente & ""
        If sIdEsterno.Length = 0 Then
            Throw New System.ArgumentException("Il campo IdEsternoPaziente del messaggio è vuoto!", "Messaggio.IdEsternoPaziente")
        End If

        Try
            '
            ' Serializzo accesso tramite un Mutex
            '
            Dim sSyncLock As String
            Select Case ConfigUtil.GetSyncLevel
                Case ConfigUtil.SyncLevel.IdEsterno : sSyncLock = GetType(AnagraficaAdapter).ToString & "_" & sIdEsterno
                Case ConfigUtil.SyncLevel.Sistema : sSyncLock = GetType(AnagraficaAdapter).ToString & "_" & Messaggio.SistemaErogante
                Case ConfigUtil.SyncLevel.Tipo : sSyncLock = GetType(AnagraficaAdapter).ToString
                Case Else : sSyncLock = GetType(AnagraficaAdapter).ToString
            End Select
            mutSync = ConfigUtil.GetMutex(sSyncLock)
            '
            ' Creo adapter e apro connessione
            '
            oAnagraficaAdapter = New AnagraficaAdapter
            Try
                oAnagraficaAdapter.ConnectionOpen(My.Config.ConnectionString)
            Catch ex As Exception
                Throw New ConnectionException(GetDatabaseInfo(My.Config.ConnectionString) & vbCrLf & ex.Message)
            End Try
            oAnagraficaAdapter.TransactionBegin(ConfigUtil.GetIsolationLevel())
            '
            ' Verifico versione del referto tramite data esterna
            '
            Dim dtDataEsterno As Date = Data
            Dim dtDataModifica As Date = oAnagraficaAdapter.Contains(sIdEsterno)
            If dtDataModifica <> Nothing Then
                '
                ' Esiste. Verifico se data esterna è maggiore
                '
                If dtDataEsterno <= dtDataModifica Then
                    '
                    ' Errore di versione
                    ' Non modifica l'anagrafica e i suoi figli
                    '
                    nErrNumber = 6
                    Dim sError As String = String.Format("Anagrafica già modificata con data esterna maggiore! DataEsterno={0:s}, DataModifica={1:s}.", _
                                                            dtDataEsterno, dtDataModifica)
                    Throw New System.Exception(sError)
                End If
            End If
            '
            ' Anagrafica esiste se data modifica non nulla
            '
            bAnagraficaEsiste = (dtDataModifica <> Nothing)
            '
            ' Estraggo campi
            '
            Dim dtDataNascita As Date = XmlUtil.ParseDatetime(Messaggio.DataNascita & "")
            '
            ' Estraggo attributi e creo stream
            '
            'Dim sXmlAttributi As String = XmlUtil.CreateXmlAttributi(Messaggio.Attributi)
            xmlAttributiAnagrafica = XmlUtil.CreateXdocAttributi(Messaggio.Attributi)
            Dim sXmlAttributi As String = XmlUtil.GetXmlWriterAttributi(xmlAttributiAnagrafica)
            '
            ' Controllo azione
            '
            Select Case Tipo
                Case TipoMessaggio.Aggiunge, TipoMessaggio.Modifica
                    If bAnagraficaEsiste Then
                        '
                        ' Aggiorno anagrafica
                        '
                        If Not oAnagraficaAdapter.Update(sIdEsterno, dtDataEsterno, _
                                                        Messaggio.AziendaErogante & "", _
                                                        Messaggio.SistemaErogante & "", _
                                                        Messaggio.RepartoErogante & "", _
                                                        Messaggio.Cognome & "", _
                                                        Messaggio.Nome & "", _
                                                        Messaggio.Sesso & "", _
                                                        dtDataNascita, _
                                                        Messaggio.LuogoNascita & "", _
                                                        Messaggio.CodiceFiscale & "", _
                                                        Messaggio.CodiceSanitario & "", _
                                                        Messaggio.DatiAnamnestici & "", _
                                                        sXmlAttributi) Then
                            '
                            ' Errore
                            '
                            nErrNumber = 2
                            Dim sError As String = "Errore durante modifica anagrafica"
                            Throw New System.Exception(sError)
                        Else
                            '
                            ' Log evento
                            '
                            LogEvent.WriteInformation("Modificata anagrafica!" & vbCrLf & _
                                            "IdEsterno = '" & Messaggio.IdEsternoPaziente & "'" & vbCrLf & _
                                            "Azienda = '" & Messaggio.AziendaErogante & "'" & vbCrLf & _
                                            "Sistema = '" & Messaggio.SistemaErogante & "'" & vbCrLf & _
                                            "Cognome = '" & Messaggio.Cognome & "'" & vbCrLf & _
                                            "Nome = '" & Messaggio.Nome & "'" & vbCrLf & _
                                            "DataNascita = '" & Messaggio.DataNascita & "'")
                        End If
                    Else
                        '
                        ' Inserisco nuovo
                        '
                        If Not oAnagraficaAdapter.AddNew(sIdEsterno, dtDataEsterno, _
                                                        Messaggio.AziendaErogante & "", _
                                                        Messaggio.SistemaErogante & "", _
                                                        Messaggio.RepartoErogante & "", _
                                                        Messaggio.Cognome & "", _
                                                        Messaggio.Nome & "", _
                                                        Messaggio.Sesso & "", _
                                                        dtDataNascita, _
                                                        Messaggio.LuogoNascita & "", _
                                                        Messaggio.CodiceFiscale & "", _
                                                        Messaggio.CodiceSanitario & "", _
                                                        Messaggio.DatiAnamnestici & "", _
                                                        sXmlAttributi) Then
                            '
                            ' Errore
                            '
                            nErrNumber = 3
                            Dim sError As String = "Errore durante inserimento anagrafica!"
                            Throw New System.Exception(sError)
                        Else
                            '
                            ' Log evento
                            '
                            LogEvent.WriteInformation("Aggiunta nuova anagrafica!" & vbCrLf & _
                                            "IdEsterno = '" & Messaggio.IdEsternoPaziente & "'" & vbCrLf & _
                                            "Azienda = '" & Messaggio.AziendaErogante & "'" & vbCrLf & _
                                            "Sistema = '" & Messaggio.SistemaErogante & "'" & vbCrLf & _
                                            "Cognome = '" & Messaggio.Cognome & "'" & vbCrLf & _
                                            "Nome = '" & Messaggio.Nome & "'" & vbCrLf & _
                                            "DataNascita = '" & Messaggio.DataNascita & "'")
                            '
                            ' Aggiungo i riferimenti
                            '
                            If Not Messaggio.Riferimenti Is Nothing Then
                                For Each oRiferimento As Riferimento In Messaggio.Riferimenti
                                    '
                                    ' Riferimenti anagrafici
                                    '
                                    Dim sAnagrafica As String = oRiferimento.Nome & ""
                                    Dim sValore As String = oRiferimento.Valore & ""
                                    '
                                    ' Controllo se c'è, perche potrebbe essere di un'altro paziente
                                    '
                                    Dim sIdEsternoRif As String = oAnagraficaAdapter.Reference(sAnagrafica, sValore)
                                    If sIdEsternoRif Is Nothing Then
                                        '
                                        ' Aggiungo riferimenti
                                        '
                                        If Not oAnagraficaAdapter.ReferenceAddNew(sIdEsterno, sAnagrafica, sValore) Then
                                            '
                                            ' Errore
                                            '
                                            nErrNumber = 4
                                            Dim sError As String = String.Format("Errore durante inserimento riferimento anagrafica! Anagrafica={0}, Valore={1}.", _
                                                                                sAnagrafica, sValore)
                                            Throw New System.Exception(sError)
                                        Else
                                            '
                                            ' Log evento
                                            '
                                            LogEvent.WriteInformation("Aggiunto riferimento anagrafica!" & vbCrLf & _
                                                            "IdEsterno = '" & Messaggio.IdEsternoPaziente & "'" & vbCrLf & _
                                                            "Anagrafica = '" & sAnagrafica & "'" & vbCrLf & _
                                                            "Valore = '" & sValore & "'")
                                        End If
                                    Else
                                        '
                                        ' Log evento
                                        '
                                        LogEvent.WriteInformation("Riferimento anagrafica già presente!" & vbCrLf & _
                                                        "IdEsterno = '" & Messaggio.IdEsternoPaziente & "'" & vbCrLf & _
                                                        "Anagrafica = '" & sAnagrafica & "'" & vbCrLf & _
                                                        "Valore = '" & sValore & "'")
                                    End If
                                Next
                            End If

                        End If
                    End If

                Case TipoMessaggio.Rimuove
                    If bAnagraficaEsiste Then
                        '
                        ' Rimuovo se c'è
                        '
                        If Not oAnagraficaAdapter.ReferenceRemove(sIdEsterno, Nothing) Then
                            '
                            ' Warning
                            '
                            LogEvent.WriteWarning("Nessun riferimento anagrafico da cancellare!" & vbCrLf & _
                                            "IdEsterno = '" & Messaggio.IdEsternoPaziente & "'")
                        Else
                            '
                            ' Log evento
                            '
                            LogEvent.WriteInformation("Cancellati i riferimenti anagrafici!" & vbCrLf & _
                                            "IdEsterno = '" & Messaggio.IdEsternoPaziente)
                        End If

                        If Not oAnagraficaAdapter.Remove(sIdEsterno) Then
                            '
                            ' Warning
                            '
                            LogEvent.WriteWarning("Nessun anagrafica da cancellare!" & vbCrLf & _
                                            "IdEsterno = '" & Messaggio.IdEsternoPaziente & "'" & vbCrLf & _
                                            "Azienda = '" & Messaggio.AziendaErogante & "'" & vbCrLf & _
                                            "Sistema = '" & Messaggio.SistemaErogante & "'" & vbCrLf & _
                                            "Cognome = '" & Messaggio.Cognome & "'" & vbCrLf & _
                                            "Nome = '" & Messaggio.Nome & "'" & vbCrLf & _
                                            "DataNascita = '" & Messaggio.DataNascita & "'")
                        Else
                            '
                            ' Log evento
                            '
                            LogEvent.WriteInformation("Rimossa anagrafica!" & vbCrLf & _
                                            "IdEsterno = '" & Messaggio.IdEsternoPaziente & "'" & vbCrLf & _
                                            "Azienda = '" & Messaggio.AziendaErogante & "'" & vbCrLf & _
                                            "Sistema = '" & Messaggio.SistemaErogante & "'" & vbCrLf & _
                                            "Cognome = '" & Messaggio.Cognome & "'" & vbCrLf & _
                                            "Nome = '" & Messaggio.Nome & "'" & vbCrLf & _
                                            "DataNascita = '" & Messaggio.DataNascita & "'")
                        End If
                    Else
                        '
                        ' Se non c'è warning
                        '
                        LogEvent.WriteWarning("Anagrafica non trovata durante la cancellazione! IdEsterno=" & sIdEsterno)
                    End If

                Case TipoMessaggio.Fusione

                    If bAnagraficaEsiste Then
                        '
                        ' Verifico se l'IdEsterno e un record nella Tabella PazientiBase; se non lo è
                        ' allora è un riferimento, e quindi deve essre creato
                        ' 
                        bAnagraficaEsiste = oAnagraficaAdapter.IsAnagrafica(sIdEsterno)
                    End If


                    If bAnagraficaEsiste Then
                        '
                        ' Aggiorno anagrafica del padre
                        '
                        If Not oAnagraficaAdapter.Update(sIdEsterno, dtDataEsterno, _
                                                        Messaggio.AziendaErogante & "", _
                                                        Messaggio.SistemaErogante & "", _
                                                        Messaggio.RepartoErogante & "", _
                                                        Messaggio.Cognome & "", _
                                                        Messaggio.Nome & "", _
                                                        Messaggio.Sesso & "", _
                                                        dtDataNascita, _
                                                        Messaggio.LuogoNascita & "", _
                                                        Messaggio.CodiceFiscale & "", _
                                                        Messaggio.CodiceSanitario & "", _
                                                        Messaggio.DatiAnamnestici & "", _
                                                        sXmlAttributi) Then
                            '
                            ' Errore
                            '
                            nErrNumber = 2
                            Dim sError As String = "Errore durante modifica anagrafica fusa"
                            Throw New System.Exception(sError)
                        Else
                            '
                            ' Log evento
                            '
                            LogEvent.WriteInformation("Modificata anagrafica fusa!" & vbCrLf & _
                                            "IdEsterno = '" & Messaggio.IdEsternoPaziente & "'" & vbCrLf & _
                                            "Azienda = '" & Messaggio.AziendaErogante & "'" & vbCrLf & _
                                            "Sistema = '" & Messaggio.SistemaErogante & "'" & vbCrLf & _
                                            "Cognome = '" & Messaggio.Cognome & "'" & vbCrLf & _
                                            "Nome = '" & Messaggio.Nome & "'" & vbCrLf & _
                                            "DataNascita = '" & Messaggio.DataNascita & "'")
                        End If
                    Else
                        '
                        ' Inserisco nuovo
                        '
                        If Not oAnagraficaAdapter.AddNew(sIdEsterno, dtDataEsterno, _
                                                        Messaggio.AziendaErogante & "", _
                                                        Messaggio.SistemaErogante & "", _
                                                        Messaggio.RepartoErogante & "", _
                                                        Messaggio.Cognome & "", _
                                                        Messaggio.Nome & "", _
                                                        Messaggio.Sesso & "", _
                                                        dtDataNascita, _
                                                        Messaggio.LuogoNascita & "", _
                                                        Messaggio.CodiceFiscale & "", _
                                                        Messaggio.CodiceSanitario & "", _
                                                        Messaggio.DatiAnamnestici & "", _
                                                        sXmlAttributi) Then
                            '
                            ' Errore
                            '
                            nErrNumber = 3
                            Dim sError As String = "Errore durante inserimento anagrafica fusa!"
                            Throw New System.Exception(sError)
                        Else
                            '
                            ' Log evento
                            '
                            LogEvent.WriteInformation("Aggiunta nuova anagrafica fusa!" & vbCrLf & _
                                            "IdEsterno = '" & Messaggio.IdEsternoPaziente & "'" & vbCrLf & _
                                            "Azienda = '" & Messaggio.AziendaErogante & "'" & vbCrLf & _
                                            "Sistema = '" & Messaggio.SistemaErogante & "'" & vbCrLf & _
                                            "Cognome = '" & Messaggio.Cognome & "'" & vbCrLf & _
                                            "Nome = '" & Messaggio.Nome & "'" & vbCrLf & _
                                            "DataNascita = '" & Messaggio.DataNascita & "'")

                        End If
                    End If
                    '
                    ' A questo punto fondo...
                    '
                    If Not Messaggio.Riferimenti Is Nothing Then
                        '
                        ' Rimuovo tutti i riferimenti (dopo saranno riaggiunti)
                        '
                        If Not oAnagraficaAdapter.ReferenceRemove(sIdEsterno, Nothing) Then
                            '
                            ' Warning
                            '
                            LogEvent.WriteWarning("Nessun riferimento anagrafico da cancellare!" & vbCrLf & _
                                            "IdEsterno = '" & Messaggio.IdEsternoPaziente & "'")
                        Else
                            '
                            ' Log evento
                            '
                            LogEvent.WriteInformation("Cancellati i riferimenti anagrafici!" & vbCrLf & _
                                            "IdEsterno = '" & Messaggio.IdEsternoPaziente)
                        End If
                        '
                        ' Aggiungo i riferimenti
                        '
                        For Each oRiferimento As Riferimento In Messaggio.Riferimenti
                            '
                            ' Riferimenti anagrafici
                            '
                            Dim sAnagrafica As String = oRiferimento.Nome & ""
                            Dim sValore As String = oRiferimento.Valore & ""
                            '
                            ' Anche se li ho rimossi controllo se c'è, perche potrebbe essere 
                            '  di un'altro paziente (allora fondo), o aggiunto in seguito 
                            '  ad una altra fusione.
                            '
                            Dim sIdEsternoRif As String = oAnagraficaAdapter.Reference(sAnagrafica, sValore)
                            '
                            ' ATTENZIONE: gli id esterni possono essere scritti con lettere maiuscole e/minuscole
                            ' per questo motivo bisogna fare il ToUpper, altrimenti poichè nell'elenco dei riferimenti
                            ' c'è l'intero elenco si rischia di chiamare il merge con i medesimi IDEsterni!!!
                            '
                            If (sIdEsternoRif IsNot Nothing) AndAlso (sIdEsternoRif.ToUpper <> sIdEsterno.ToUpper) Then
                                '
                                ' Il riferimento c'è già ed è un paziente diverso, faccio il merge
                                '
                                If Not oAnagraficaAdapter.Merge(sIdEsternoRif, sIdEsterno) Then
                                    '
                                    ' Errore
                                    '
                                    nErrNumber = 5
                                    Dim sError As String = String.Format("Errore durante la fusione riferimento anagrafica! Sorgente={0}, Destinatario={1}.", _
                                                                        sIdEsternoRif, sIdEsterno)
                                    Throw New System.Exception(sError)
                                Else
                                    '
                                    ' Log evento
                                    '
                                    LogEvent.WriteInformation("Fusione riferimento anagrafica!" & vbCrLf & _
                                                    "IdEsterno = '" & Messaggio.IdEsternoPaziente & "'" & vbCrLf & _
                                                    "Anagrafica = '" & sAnagrafica & "'" & vbCrLf & _
                                                    "Valore = '" & sValore & "'")
                                End If

                            ElseIf (sIdEsternoRif Is Nothing) Then
                                '
                                ' Aggiungo riferimenti
                                '
                                If Not oAnagraficaAdapter.ReferenceAddNew(sIdEsterno, sAnagrafica, sValore) Then
                                    '
                                    ' Errore
                                    '
                                    nErrNumber = 4
                                    Dim sError As String = String.Format("Errore durante inserimento riferimento anagrafica! Anagrafica={0}, Valore={1}.", _
                                                                        sAnagrafica, sValore)
                                    Throw New System.Exception(sError)
                                Else
                                    '
                                    ' Log evento
                                    '
                                    LogEvent.WriteInformation("Aggiunto riferimento anagrafica!" & vbCrLf & _
                                                    "IdEsterno = '" & Messaggio.IdEsternoPaziente & "'" & vbCrLf & _
                                                    "Anagrafica = '" & sAnagrafica & "'" & vbCrLf & _
                                                    "Valore = '" & sValore & "'")
                                End If
                            End If
                        Next
                    End If

            End Select
            '
            ' Confermo le modifiche
            '
            oAnagraficaAdapter.TransactionCommit()
            '
            ' Risultato OK
            '
            Return New Risultato(0, "")

        Catch ex As Exception
            '
            ' Abbandono le modifiche
            '
            Dim sErrRollBack As String = String.Empty
            Try
                If Not oAnagraficaAdapter Is Nothing Then
                    oAnagraficaAdapter.TransactionRoolback()
                End If
            Catch ex2 As Exception
                sErrRollBack = String.Format("Errore durante il rollback della transazione relativa a ConnectorV2.Anagrafica(); Tipo={0}, IdEsterno={1}{2}{3}", _
                                                        Tipo, sIdEsterno, vbCrLf, ex2.Message)
                LogEvent.WriteError(ex2, sErrRollBack)
            End Try

            '
            ' Scrive Log
            '
            Dim sMessage As String
            sMessage = String.Format("Errore durante ConnectorV2.Anagrafica(); Tipo={0}, IdEsterno={1}{2}{3}", _
                                                                        Tipo, sIdEsterno, vbCrLf, ex.Message)
            '
            ' Log error o warning
            '
            If nErrNumber = 6 Then
                '
                ' Data sequenza
                '
                LogEvent.WriteWarning(sMessage)
            Else
                LogEvent.WriteError(ex, sMessage)
            End If
            '
            ' A questo punto verifico se l'eccezione è un errore di connessione
            ' oppure una SqlException dovuta ad un timeout, deadlock
            '
            If TypeOf ex Is ConnectionException Then
                Throw New ConnectionException(sMessage)
            ElseIf TypeOf ex Is CommandTimeoutException Then
                'Cosi posso usare anche questo tipo di eccezione volendo, invece di controllare una SqlException con Number=-2 
                Throw New CommandTimeoutException(sMessage)
            ElseIf TypeOf ex Is SqlClient.SqlException Then
                Dim ExSql As SqlClient.SqlException = CType(ex, SqlClient.SqlException)
                If ExSql.Number = SqlExceptionNumber.Timeout Then 'TimeoutError
                    Throw New CommandTimeoutException(sMessage)
                ElseIf ExSql.Number = SqlExceptionNumber.DeadLock Then
                    Throw
                End If
            End If
            '
            ' Risultato o eccezione
            '
            If nErrNumber > 0 Then
                Throw New System.ApplicationException(sMessage & vbCrLf & "ErrNumber=" & nErrNumber.ToString, ex)
            Else
                Throw New System.Exception(sMessage, ex)
            End If

        Finally
            '
            ' Rilascia sincronismo
            '
            If Not mutSync Is Nothing Then
                Try
                    mutSync.ReleaseMutex()
                    mutSync.Close()
                Catch ex As Exception
                End Try
            End If
            '
            ' Chiude connessione se aperta
            '
            If Not oAnagraficaAdapter Is Nothing Then
                oAnagraficaAdapter.Dispose()
            End If

            xmlAttributiAnagrafica = Nothing

        End Try

    End Function

    Private Function BuildAnteprimaReferto(oPrestazioni As ConnectorV2.Prestazione()) As String
        Const SEP As String = ";"
        Dim sRet As String = String.Empty

        If Not oPrestazioni Is Nothing AndAlso oPrestazioni.GetLength(0) > 0 Then
            Dim sDesc As String = String.Empty
            '
            ' oList la uso per realizzare il distinct
            '
            Dim oList As New System.Collections.Specialized.StringCollection
            For Each oPrestazione As ConnectorV2.Prestazione In oPrestazioni

                sDesc = oPrestazione.PrestazioneDescrizione
                If String.IsNullOrEmpty(sDesc) Then
                    sDesc = oPrestazione.PrestazioneCodice
                End If
                '
                ' Aggiungo alla lista solo se sDesc è valorizzato
                '
                If Not String.IsNullOrEmpty(sDesc) Then
                    If Not oList.Contains(sDesc) Then
                        oList.Add(sDesc)
                    End If
                End If
            Next
            '
            ' Se oList contiene degli elementi li concateno
            '
            If oList.Count > 0 Then
                For Each oItem As String In oList
                    sRet = String.Concat(sRet, oItem, SEP)
                Next
            End If
            '
            ' Tolgo separatore finale 
            '
            sRet = sRet.TrimEnd(SEP.ToCharArray)
        End If
        '
        ' Restituisco
        '
        Return sRet

    End Function




#Region " Gestione Eventi  "

    '
    ' Prefisso degli attributi degli eventi che rappresentano "Info di ricovero"
    ' (le funzioni che lo usano eseguono un uppercase del nome dell'attributo)
    '
    Private Const EV_ATTR_PREFIX_INFO_RICOVERO As String = "RIC@"

#Region " TipoMessaggioEvento "
    Public Enum TipoMessaggioEvento As Byte
        Aggiornamento = 0
        Rimozione = 1
    End Enum
#End Region

#Region " Evento "

    <Serializable()> _
    Public Class Evento
        Public IdEsternoEvento As String
        Public AziendaErogante As String
        Public SistemaErogante As String
        Public RepartoErogante As String
        Public DataEvento As String
        Public StatoCodice As String
        Public TipoEventoCodice As String
        Public NumeroNosologico As String
        Public TipoEpisodio As String
        Public TipoEpisodioDescrizione As String
        Public RepartoCodice As String
        Public RepartoDescrizione As String
        Public Diagnosi As String
        Public Attributi() As ConnectorV2.Attributo

        Public Sub New()
        End Sub

        Public Sub New(ByVal IdEsternoEvento As String, _
                        ByVal AziendaErogante As String, _
                        ByVal SistemaErogante As String, _
                        ByVal RepartoErogante As String, _
                        ByVal DataEvento As String, _
                        ByVal StatoCodice As String, _
                        ByVal TipoEventoCodice As String, _
                        ByVal NumeroNosologico As String, _
                        ByVal TipoEpisodio As String, _
                        ByVal TipoEpisodioDescrizione As String, _
                        ByVal RepartoCodice As String, _
                        ByVal RepartoDescrizione As String, _
                        ByVal Diagnosi As String, _
                        ByVal Attributi() As ConnectorV2.Attributo)

            Me.IdEsternoEvento = IdEsternoEvento
            Me.AziendaErogante = AziendaErogante
            Me.SistemaErogante = SistemaErogante
            Me.RepartoErogante = RepartoErogante
            Me.DataEvento = DataEvento
            Me.StatoCodice = StatoCodice
            Me.TipoEventoCodice = TipoEventoCodice
            Me.NumeroNosologico = NumeroNosologico
            Me.TipoEpisodio = TipoEpisodio
            Me.TipoEpisodioDescrizione = TipoEpisodioDescrizione
            Me.RepartoCodice = RepartoCodice
            Me.RepartoDescrizione = RepartoDescrizione
            Me.Diagnosi = Diagnosi
            Me.Attributi = Attributi
        End Sub

        Public Sub New(ByVal IdEsternoEvento As String, _
                        ByVal AziendaErogante As String, _
                        ByVal SistemaErogante As String, _
                        ByVal RepartoErogante As String, _
                        ByVal DataEvento As String, _
                        ByVal StatoCodice As String, _
                        ByVal TipoEventoCodice As String, _
                        ByVal NumeroNosologico As String, _
                        ByVal TipoEpisodio As String, _
                        ByVal TipoEpisodioDescrizione As String, _
                        ByVal RepartoCodice As String, _
                        ByVal RepartoDescrizione As String, _
                        ByVal Diagnosi As String)

            Me.IdEsternoEvento = IdEsternoEvento
            Me.AziendaErogante = AziendaErogante
            Me.SistemaErogante = SistemaErogante
            Me.RepartoErogante = RepartoErogante
            Me.DataEvento = DataEvento
            Me.StatoCodice = StatoCodice
            Me.TipoEventoCodice = TipoEventoCodice
            Me.NumeroNosologico = NumeroNosologico
            Me.TipoEpisodio = TipoEpisodio
            Me.TipoEpisodioDescrizione = TipoEpisodioDescrizione
            Me.RepartoCodice = RepartoCodice
            Me.RepartoDescrizione = RepartoDescrizione
            Me.Diagnosi = Diagnosi
        End Sub

    End Class

#End Region

#Region " MessaggioEvento"

    <Serializable()> _
    Public Class MessaggioEvento
        Public Paziente As ConnectorV2.Paziente
        Public Evento As ConnectorV2.Evento


        Public Sub New()
        End Sub

        Public Sub New(ByVal Paziente As ConnectorV2.Paziente, _
                        ByVal Evento As ConnectorV2.Evento)
            Me.Paziente = Paziente
            Me.Evento = Evento
        End Sub


        Public Shared Function Deserialize(ByVal XmlData As String) As ConnectorV2.MessaggioEvento

            Dim oStream As IO.MemoryStream = Nothing
            Dim oTextReader As Xml.XmlTextReader = Nothing

            Try
                Dim oEnc As Encoding = Encoding.UTF8

                oStream = New IO.MemoryStream
                oStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
                oStream.Position = 0

                oTextReader = New Xml.XmlTextReader(oStream)

                Dim oMessaggio As MessaggioEvento

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(ConnectorV2.MessaggioEvento))
                oMessaggio = CType(oSerializer.Deserialize(oTextReader), ConnectorV2.MessaggioEvento)

                Return oMessaggio

            Catch ex As Exception
                '
                ' Error
                '
                Dim sMessage As String = "ConnectorV2 MessaggioEvento.Deserialize(); Errore durante la deserializzazione!"
                '
                ' Log e eccezione
                '
                LogEvent.WriteError(ex, sMessage)
                Throw New System.Exception(sMessage, ex)

            Finally
                '
                ' Rilascio
                '
                Try
                    If Not oStream Is Nothing Then
                        oStream.Close()
                    End If
                    If Not oTextReader Is Nothing Then
                        oTextReader.Close()
                    End If
                Catch ex As Exception
                End Try
            End Try

        End Function

        Public Shared Function Serialize(ByVal Messaggio As ConnectorV2.MessaggioEvento) As String
            '
            ' Serializzo
            '
            Dim oStream As IO.MemoryStream = Nothing
            Dim oTextWriter As Xml.XmlTextWriter = Nothing

            Try
                Dim oEnc As Encoding = Encoding.UTF8

                oStream = New IO.MemoryStream
                oTextWriter = New Xml.XmlTextWriter(oStream, oEnc)

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(ConnectorV2.MessaggioEvento))
                oSerializer.Serialize(oTextWriter, Messaggio)

                Dim sMessaggio As String = oEnc.GetString(oStream.ToArray())
                Return sMessaggio

            Catch ex As Exception
                '
                ' Error
                '
                Dim sMessage As String = "ConnectorV2 MessaggioEvento.Serialize(); Errore durante la serializzazione!"
                '
                ' Log e eccezione
                '
                LogEvent.WriteError(ex, sMessage)
                Throw New System.Exception(sMessage, ex)

            Finally
                '
                ' Rilascio
                '
                Try
                    If Not oStream Is Nothing Then
                        oStream.Close()
                    End If
                    If Not oTextWriter Is Nothing Then
                        oTextWriter.Close()
                    End If
                Catch ex As Exception
                End Try
            End Try

        End Function

    End Class

#End Region

    Public Function Ricovero(ByVal Tipo As ConnectorV2.TipoMessaggioEvento, _
                    ByVal Data As DateTime, _
                    ByVal Messaggio As ConnectorV2.MessaggioEvento) As Risultato
        Dim iDelayMs As Integer = 0
        Dim iCounterRetry As Integer = 0
        While True
            Try
                ' Esecuzione delle operazioni di aggiornamento
                iCounterRetry = iCounterRetry + 1
                Return _Ricovero(Tipo, Data, Messaggio)

            Catch ex As ConnectionException
                ' Se ho raggiunto il numero max di retry esco con throw dell'eccezione: l'orchestrazione eseguirà il suo loop di retry
                If iCounterRetry >= My.Config.ConnectionErrorNumRetry Then
                    Throw New System.Exception(ex.Message)
                End If
                ' Imposto il delay
                iDelayMs = My.Config.ConnectionErrorDelayRetry * 1000

            Catch ex As CommandTimeoutException
                ' Se ho raggiunto il numero max di retry esco con throw dell'eccezione: l'orchestrazione eseguirà il suo loop di retry
                If iCounterRetry >= My.Config.CommandTimeoutNumRetry Then
                    Throw New System.Exception(ex.Message)
                End If
                ' Imposto il delay
                iDelayMs = My.Config.CommandTimeoutDelayRetry * 1000

            Catch ex As SqlException
                If ex.Number = SqlExceptionNumber.Timeout Then
                    If iCounterRetry >= My.Config.CommandTimeoutNumRetry Then
                        Throw New System.Exception(ex.Message)
                    End If
                    iDelayMs = My.Config.CommandTimeoutDelayRetry * 1000

                ElseIf ex.Number = SqlExceptionNumber.DeadLock Then
                    If iCounterRetry >= My.Config.DeadLockNumRetry Then
                        Throw New System.Exception(ex.Message)
                    End If
                    iDelayMs = My.Config.DeadLockDelayRetry * 1000

                End If

            Catch ex As System.ApplicationException
                ' L'orchestrazione eseguirà il suo loop di retry
                Throw

            Catch ex As Exception
                ' L'orchestrazione eseguirà il suo loop di retry
                Throw

            End Try
            '
            ' Attendo il tempo di Delay (in millisecondi)
            '
            Thread.Sleep(iDelayMs)
        End While
        ' Qui non ci arriva mai
        Return Nothing

    End Function

    Private Function _Ricovero(ByVal Tipo As ConnectorV2.TipoMessaggioEvento, _
                        ByVal Data As DateTime, _
                        ByVal Messaggio As ConnectorV2.MessaggioEvento) As Risultato
        '
        ' Questa funzione è specializzata per eventi di tipo ADT (Ricovero)
        '
        Dim mutSync As Mutex = Nothing
        Dim oEventoAdapter As EventoAdapter = Nothing
        Dim nErrNumber As Int16 = 0
        Dim sTipoEventoCodice As String = ""
        '
        ' Verifiche dei parametri
        '
        If Messaggio Is Nothing Then
            Throw New System.ArgumentException("Il parametro Messaggio è vuoto!", "Messaggio")
        End If

        If Data = Nothing Then
            Throw New System.ArgumentException("Il parametro Data è vuoto!", "Data")
        End If

        If Messaggio.Evento Is Nothing Then
            Throw New System.ApplicationException("Manca il nodo Evento nel Messaggio!")
        End If

        Dim sIdEsterno As String = Messaggio.Evento.IdEsternoEvento & ""
        If sIdEsterno.Length = 0 Then
            Throw New System.ApplicationException("Il campo IdEsterno del messaggio è vuoto!")
        End If

        ' 
        ' Prelevo il codice del tipo di evento
        '
        sTipoEventoCodice = Messaggio.Evento.TipoEventoCodice.ToUpper
        '
        ' ...e verifico se il tipo di evento è corretto
        ' "A", "T", "D", "M", "X", "R", "E" -> eventi ADT STANDARD
        ' "IL", "ML", "DL", "RL", "SL" -> eventi ADT "LISTA DI ATTESA"
        '
        ' Modifica Ettore 2013-05-29: non controllo più il codice dell'evento: entra tutto, ovviamente gli eventi di azione dovranno essere gestiti
        '
        'Select Case sTipoEventoCodice.ToUpper
        '    Case "A", "T", "D", "M", "X", "R", "E"
        '        '
        '        ' OK 
        '        '
        '    Case Else
        '        Throw New System.Exception(String.Format("Il TipoEventoCodice='{0}' non è valido!", Messaggio.Evento.TipoEventoCodice))
        'End Select
        '
        ' Il paziente deve essere presente
        ' devono essere sempre presenti i dati del paziente per fare join con il paziente 
        ' per poter inserire il record di evento
        '
        If Messaggio.Paziente Is Nothing Then
            Throw New System.ApplicationException("Manca il nodo Paziente nel Messaggio!")
        End If

        'TODO: 2020-10-06 Verificare come viene usato messaggio.Paziente.IdEsternoPaziente negli eventi. Perchè qui è obbligatorio??? E' usato nel codice?
        Dim sIdEsternoPaziente As String = Messaggio.Paziente.IdEsternoPaziente & ""
        If String.IsNullOrEmpty(sIdEsternoPaziente) Then
            Throw New System.ApplicationException("Manca l'IdEsterno del paziente!")
        End If


        Try

            'MODIFICA ETTORE 2020-02-26: controllo la presenza del NumeroNosologico
            Messaggio.Evento.NumeroNosologico = Trim(Messaggio.Evento.NumeroNosologico & "")
            If Messaggio.Evento.NumeroNosologico.Length = 0 Then
                Throw New System.ApplicationException("Il campo NumeroNosologico del messaggio è vuoto!")
            End If

            'MODIFICA ETTORE 2020-02-26: Tolgo spazi dall'azienda e dal sistema erogante e verifico che non siano vuote.
            Messaggio.Evento.AziendaErogante = Trim(Messaggio.Evento.AziendaErogante & "")
            Messaggio.Evento.SistemaErogante = Trim(Messaggio.Evento.SistemaErogante & "")
            If String.IsNullOrEmpty(Messaggio.Evento.AziendaErogante) Then
                '
                ' AziendaErogante non valorizzata
                '
                Throw New System.Exception("L'azienda erogante dell'evento/ricovero non è valorizzata!")
            End If
            If String.IsNullOrEmpty(Messaggio.Evento.SistemaErogante) Then
                '
                ' SistemaErogante non valorizzato
                '
                Throw New System.Exception("Il sistema erogante dell'evento/ricovero non è valorizzato!")
            End If

            '
            ' Serializzo accesso
            '
            Dim sSyncLock As String
            Select Case ConfigUtil.GetSyncLevel
                '
                ' IdEsterno in questo caso è da considerare come IdESterno del Ricovero = AziendaErogante + SistemaErogante + NumeroNosologico
                '
                Case ConfigUtil.SyncLevel.IdEsterno : sSyncLock = GetType(EventoAdapter).ToString & "_" & _
                                                                    Messaggio.Evento.AziendaErogante & "_" & _
                                                                    Messaggio.Evento.SistemaErogante & "_" & _
                                                                    Messaggio.Evento.NumeroNosologico
                Case ConfigUtil.SyncLevel.Sistema : sSyncLock = GetType(EventoAdapter).ToString & "_" & Messaggio.Evento.SistemaErogante
                Case ConfigUtil.SyncLevel.Tipo : sSyncLock = GetType(EventoAdapter).ToString
                Case Else : sSyncLock = GetType(EventoAdapter).ToString
            End Select

            mutSync = ConfigUtil.GetMutex(sSyncLock)
            '
            ' Creo adapter, apro connessione e transazione
            '
            oEventoAdapter = New EventoAdapter

            Try
                oEventoAdapter.ConnectionOpen(My.Config.ConnectionString)
            Catch ex As Exception
                Throw New ConnectionException(GetDatabaseInfo(My.Config.ConnectionString) & vbCrLf & ex.Message)
            End Try

            Dim oRisultato As Risultato = New Risultato(0, "")

            ' ------------------------------------------------------------------------------------------
            ' Collego al paziente (solo messaggi di tipo aggiornamento sono permessi)
            ' Crea attributi del paziente e se necessario inserisce nuovo record
            ' La eseguo all'esterno della transazione per evitare deadlock
            ' ------------------------------------------------------------------------------------------
            Dim oIdPazienteSac As Guid = Nothing
            If Tipo = TipoMessaggioEvento.Aggiornamento Then
                '--------------------------------------------------------------------------------------
                ' Join dell'evento con il Paziente SAC
                '--------------------------------------------------------------------------------------
                Dim sNomeAnagraficaDiRicerca As String = _
                                oEventoAdapter.PazientiLookUpNomeAnagraficaDiRicerca(Messaggio.Paziente.NomeAnagraficaCentrale & "", _
                                                                                       Messaggio.Evento.AziendaErogante & "")
                oIdPazienteSac = JoinPazienteSacEvento(My.Config.ConnectionStringSac, Messaggio, sNomeAnagraficaDiRicerca)
            End If

            '
            ' Apro la transazione sul connettore degli eventi
            '
            oEventoAdapter.TransactionBegin(ConfigUtil.GetIsolationLevel())
            '
            ' MODIFICA ETTORE 2020-02-26: controllo dell'azienda erogante e del sistema erogante (fuori dalla transazione)
            '
            If Not VerificaAziendaEroganteSistemaEroganteEvento(Messaggio.Evento.AziendaErogante, Messaggio.Evento.SistemaErogante) Then
                '
                ' AziendaErogante/SistemaErogante non configurato
                '
                Throw New System.Exception(String.Format("Il sistema [AziendaErogante, SistemaErogante]=['{0}','{1}'] non è configurato per gli eventi!", Messaggio.Evento.AziendaErogante, Messaggio.Evento.SistemaErogante))
            End If
            '
            ' MODIFICA ETTORE 2019-02-22: Leggo le Aziende eroganti dal database (fuori dalla transazione)
            '
            Dim oListAziendeEroganti As System.Collections.Generic.List(Of String) = ConfigSingleton.AziendeErogantiLista
            '
            ' MODIFICA ETTORE 2019-02-22: eseguo autoprefix ed eventualmente scrivo nel LogAutoprefix
            '
            If AutoprefixIdEsterno(Messaggio.Evento.IdEsternoEvento, Messaggio.Evento.AziendaErogante, oListAziendeEroganti, sIdEsterno) Then
                '
                ' Scrivo nella tabella LogAutoprefix
                '
                oEventoAdapter.LogAutoPrefixAdd(Messaggio.Evento.AziendaErogante, Messaggio.Evento.SistemaErogante, Nothing, sIdEsterno)
            End If
            Messaggio.Evento.IdEsternoEvento = sIdEsterno
            '
            ' Se "Rimozione" di un evento che non esiste non devo fare nulla. 
            ' Se si cancella un evento che non esiste il ricovero non cambia.
            '
            ' Eseguo la ExtEventiBeforeProcess prima di tutto
            ' In caso di rimozione di un evento che non esiste la "EventiBeforeProcess" non fa nulla
            ' Questa deve essere fatta prima perchè si incarica di inserire nella coda
            '
            oEventoAdapter.EventiBeforeProcess(sIdEsterno, Tipo)
            '
            ' MODIFICA ETTORE 2019-05-24: decido esternamente se l'evento esiste
            '
            Dim bEventoEsiste As Boolean = EventoEsiste(oEventoAdapter, Messaggio)
            '
            ' Se TipoMessaggioEvento.Rimozione e l'evento non esiste non aggiorno eventi e ricovero
            '
            If (Tipo = TipoMessaggioEvento.Rimozione And Not bEventoEsiste) Then
                'Messaggio rimozione e l'evento da rimuovere no esiste: scrivo in event log
                Dim sMessage As String = String.Format("ConnectorV2.Ricovero(): Tipo={0}, IdEsterno={1}, TipoEventoCodice={2}{3}{4}", _
                                                                        Tipo, sIdEsterno, sTipoEventoCodice, vbCrLf, "Richiesta di rimozione di un evento che non esiste.")
                LogEvent.WriteWarning(sMessage)
            Else
                '
                ' Inserimento/modifica/Rimozione evento: Inserisco tutti i tipi di evento
                '
                oRisultato = RicoveroEventi(oEventoAdapter, Tipo, Data, Messaggio, oIdPazienteSac, bEventoEsiste)
                If oRisultato.ErrorNumber > 0 Then
                    nErrNumber = oRisultato.ErrorNumber
                    Throw New Exception(oRisultato.ErrorDescription)
                End If

                '-------------------------------------------------------------------------------------------
                ' Aggiornamento tabella Ricoveri (all'interno di unica transazione)
                '-------------------------------------------------------------------------------------------
                oRisultato = EventiRicoveroAggiornaRicovero(oEventoAdapter, Tipo, Messaggio, oIdPazienteSac)
                If oRisultato.ErrorNumber > 0 Then
                    nErrNumber = oRisultato.ErrorNumber
                    Throw New Exception(oRisultato.ErrorDescription)
                End If

            End If
            '
            ' Eseguo la ExtEventiAfterProcess prima di eseguire il commit
            '
            oEventoAdapter.EventiAfterProcess(sIdEsterno, Tipo)
            ' ------------------------------------------------------------------------------------------
            ' Commit tutte le modifiche
            ' ------------------------------------------------------------------------------------------
            '
            oEventoAdapter.TransactionCommit()
            '
            ' MODIFICA ETTORE 2015-02-16: imposto il ricalcolo dell'anteprima (fuori dalla transazione) 
            ' L'errore è controllato internamente
            '
            Dim oAnteprimaPazienti As New AnteprimaPazienti
            oAnteprimaPazienti.EventiCalcolaAnteprimaPaziente(oIdPazienteSac)
            '
            ' Ritorna OK
            '
            Return New Risultato(0, "")

        Catch ex As Exception
            '
            ' Roolback tutte le modifiche
            '
            Dim sErrRollBack As String = String.Empty
            Try
                If Not oEventoAdapter Is Nothing Then
                    oEventoAdapter.TransactionRoolback()
                End If
            Catch ex2 As Exception
                sErrRollBack = String.Format("Errore durante il rollback della transazione relativa a ConnectorV2.Ricovero(); Tipo={0}, IdEsterno={1}{2}{3}", _
                                                        Tipo, sIdEsterno, vbCrLf, ex2.Message)
                LogEvent.WriteError(ex2, sErrRollBack)
            End Try

            '
            ' Scrive Log
            '
            Dim sMessage As String
            sMessage = String.Format("Errore durante ConnectorV2.Ricovero(); Tipo={0}, IdEsterno={1}{2}{3}", _
                                                                        Tipo, sIdEsterno, vbCrLf, ex.Message)
            '
            ' Log error o warning
            '
            If nErrNumber = 6 Then
                '
                ' Data sequenza
                '
                LogEvent.WriteWarning(sMessage)
            Else
                LogEvent.WriteError(ex, sMessage)
            End If
            '
            ' A questo punto verifico se l'eccezione è un errore di connessione
            ' oppure una SqlException dovuta ad un timeout, deadlock
            '
            If TypeOf ex Is ConnectionException Then
                Throw New ConnectionException(sMessage)
            ElseIf TypeOf ex Is CommandTimeoutException Then
                'Cosi posso usare anche questo tipo di eccezione volendo, invece di controllare una SqlException con Number=-2 
                Throw New CommandTimeoutException(sMessage)
            ElseIf TypeOf ex Is SqlClient.SqlException Then
                Dim ExSql As SqlClient.SqlException = CType(ex, SqlClient.SqlException)
                If ExSql.Number = SqlExceptionNumber.Timeout Then 'TimeoutError
                    Throw New CommandTimeoutException(sMessage)
                ElseIf ExSql.Number = SqlExceptionNumber.DeadLock Then
                    Throw
                End If
            End If
            '
            ' Risultato o eccezione
            '
            If nErrNumber > 0 Then
                Throw New System.ApplicationException(sMessage & vbCrLf & "ErrNumber=" & nErrNumber.ToString, ex)
            Else
                Throw New System.Exception(sMessage, ex)
            End If

        Finally
            '
            ' Rilascia sincronismo
            '
            If Not mutSync Is Nothing Then
                Try
                    mutSync.ReleaseMutex()
                    mutSync.Close()
                Catch ex As Exception
                End Try
            End If
            '
            ' Chiude connessione se aperta
            '
            If Not oEventoAdapter Is Nothing Then
                oEventoAdapter.Dispose()
            End If
        End Try

    End Function

    Private Function RicoveroEventi(ByVal oEventoAdapter As EventoAdapter, _
                                    ByVal Tipo As ConnectorV2.TipoMessaggioEvento, _
                                    ByVal Data As DateTime, _
                                    ByVal Messaggio As ConnectorV2.MessaggioEvento, ByVal IdPazienteAssociato As Guid, ByVal bEventoEsiste As Boolean) As Risultato
        '
        ' sIdEsternoPazienteAssociato è l'id esterno del paziente che la procedura di insert/update devono utilizzare
        '
        Dim sIdEsterno As String = Nothing
        Dim nErrNumber As Int16 = 0
        Dim sError As String = Nothing
        Dim oRisultato As Risultato = Nothing
        Dim xmlAttributiEvento As Xml.XmlDocument = Nothing
        '
        '
        '
        sIdEsterno = Messaggio.Evento.IdEsternoEvento & ""
        '
        ' Verifico versione dell'evento tramite data esterna (questo va fatto solo per eventi che non sono azioni)
        '
        Dim dtDataEsterno As Date = Data
        '
        ' Dati Evento e Paziente
        '
        Dim dtDataNascita As Date
        Dim dtDataEvento As Date

        Dim sXmlAttributiEvento As String = ""
        '
        ' Controllo sul tipo di messaggio
        '
        Select Case Tipo
            Case TipoMessaggioEvento.Aggiornamento
                '
                ' ------------------------------------------------------------------------------------------
                '  Aggiorno Evento
                ' ------------------------------------------------------------------------------------------
                ' Estraggo campi Evento
                '
                dtDataNascita = XmlUtil.ParseDatetime(Messaggio.Paziente.DataNascita & "")
                dtDataEvento = XmlUtil.ParseDatetime(Messaggio.Evento.DataEvento & "")
                '
                ' Modifica Ettore 2012-12-11: elimino gli attributi che iniziano con il prefisso "Ric@"
                '
                Dim oAttributiEvento() As ConnectorV2.Attributo = ReadAttributiEventoSenzaInfoRicovero(Messaggio)

                '
                ' Estraggo attributi e creo stream
                '
                xmlAttributiEvento = XmlUtil.CreateXdocAttributi(oAttributiEvento)
                '
                ' Modifica Ettore 2013-06-03: Aggiungo gli Attributi anagrafici del Paziente sempre
                '
                Dim oAttributiAnagrafici() As ConnectorV2.Attributo = CreateAttributiAnagrafici(Messaggio)
                xmlAttributiEvento = XmlUtil.AddXdocAttributi(xmlAttributiEvento, oAttributiAnagrafici)
                '
                ' Ricavo stringa codificata ISO-8859-1 da passare alla Stored Procedure
                '
                sXmlAttributiEvento = XmlUtil.GetXmlWriterAttributi(xmlAttributiEvento)
                '
                ' l'xml document non serve più
                '
                xmlAttributiEvento = Nothing
                '
                ' Se sono qui il Join con il paziente ha avuto successo
                ' 

                Dim sTipoEventoDescrizione As String = GetEventiRicoveroTipoEventoDescrizione(Messaggio.Evento.TipoEventoCodice)
                '
                ' ------------------------------------------------------------------------------------------
                ' Controllo se l'Evento esiste già
                ' ------------------------------------------------------------------------------------------
                '
                If bEventoEsiste Then
                    '
                    ' Aggiorno se c'è
                    '
                    If oEventoAdapter.EventiUpdate(sIdEsterno, _
                                                     IdPazienteAssociato, _
                                                     Messaggio.Evento.AziendaErogante & "", _
                                                     Messaggio.Evento.SistemaErogante & "", _
                                                     Messaggio.Evento.RepartoErogante & "", _
                                                     dtDataEvento, _
                                                     Messaggio.Evento.NumeroNosologico & "", _
                                                     Messaggio.Evento.TipoEventoCodice & "", _
                                                     sTipoEventoDescrizione, _
                                                     Messaggio.Evento.TipoEpisodio & "", _
                                                     Messaggio.Evento.TipoEpisodioDescrizione & "", _
                                                     Messaggio.Evento.RepartoCodice & "", _
                                                     Messaggio.Evento.RepartoDescrizione & "", _
                                                     Messaggio.Evento.Diagnosi & "", _
                                                     sXmlAttributiEvento) Then
                        '
                        ' Aggiorno data modifica esterna
                        '
                        oEventoAdapter.EventiDataModificaUpdate(sIdEsterno, dtDataEsterno)
                        '
                        ' Log evento
                        '
                        LogEvent.WriteInformation("Modificato evento!" & vbCrLf & _
                                        "IdEsterno = '" & sIdEsterno & "'" & vbCrLf & _
                                        "Azienda = '" & Messaggio.Evento.AziendaErogante & "'" & vbCrLf & _
                                        "Sistema = '" & Messaggio.Evento.SistemaErogante & "'" & vbCrLf & _
                                        "Reparto = '" & Messaggio.Evento.RepartoErogante & "'" & vbCrLf & _
                                        "DataEvento = '" & Messaggio.Evento.DataEvento & "'" & vbCrLf & _
                                        "NumeroNosologico = '" & Messaggio.Evento.NumeroNosologico & "'")
                    Else
                        '
                        ' Errore se non c'è
                        '
                        nErrNumber = 12
                        sError = "Errore durante modifica referto!"
                        oRisultato = New Risultato(nErrNumber, sError)
                        Return oRisultato
                    End If
                Else
                    '
                    ' Inserisco nuovo
                    '
                    If oEventoAdapter.EventiAddNew(sIdEsterno, _
                                                     IdPazienteAssociato, _
                                                     Messaggio.Evento.AziendaErogante & "", _
                                                     Messaggio.Evento.SistemaErogante & "", _
                                                     Messaggio.Evento.RepartoErogante & "", _
                                                     dtDataEvento, _
                                                     Messaggio.Evento.NumeroNosologico & "", _
                                                     Messaggio.Evento.TipoEventoCodice & "", _
                                                     sTipoEventoDescrizione, _
                                                     Messaggio.Evento.TipoEpisodio & "", _
                                                     Messaggio.Evento.TipoEpisodioDescrizione & "", _
                                                     Messaggio.Evento.RepartoCodice & "", _
                                                     Messaggio.Evento.RepartoDescrizione & "", _
                                                     Messaggio.Evento.Diagnosi & "", _
                                                     sXmlAttributiEvento) Then
                        '
                        ' Aggiorno data modifica esterna
                        '
                        oEventoAdapter.EventiDataModificaUpdate(sIdEsterno, dtDataEsterno)
                        '
                        ' Log evento
                        '
                        LogEvent.WriteInformation("Aggiunto evento mancante!" & vbCrLf & _
                                        "IdEsterno = '" & sIdEsterno & "'" & vbCrLf & _
                                        "Azienda = '" & Messaggio.Evento.AziendaErogante & "'" & vbCrLf & _
                                        "Sistema = '" & Messaggio.Evento.SistemaErogante & "'" & vbCrLf & _
                                        "Reparto = '" & Messaggio.Evento.RepartoErogante & "'" & vbCrLf & _
                                        "DataEvento = '" & Messaggio.Evento.DataEvento & "'" & vbCrLf & _
                                        "NumeroNosologico = '" & Messaggio.Evento.NumeroNosologico & "'")
                    Else
                        '
                        ' Errore se non c'è
                        '
                        nErrNumber = 13
                        sError = "Errore durante inserimento evento!"
                        oRisultato = New Risultato(nErrNumber, sError)
                        Return oRisultato
                    End If
                End If
                '
                ' Se l'evento corrente è una azione eseguo l'azione sull'episodio associato
                ' "M", "X", "R", "E"
                ' "DL", "RL", "SL"  -> azioni per "Eventi Lista di Attesa" 
                '
                Select Case Messaggio.Evento.TipoEventoCodice.ToUpper
                    Case "M", "X", "R", "E"
                        oRisultato = RicoveroAzioni(oEventoAdapter, Tipo, Data, Messaggio)
                        If oRisultato.ErrorNumber > 0 Then
                            nErrNumber = oRisultato.ErrorNumber
                            Throw New Exception(oRisultato.ErrorDescription)
                        End If
                    Case "DL", "RL", "SL"
                        oRisultato = RicoveroAzioniListaDiAttesa(oEventoAdapter, Tipo, Data, Messaggio, IdPazienteAssociato)
                        If oRisultato.ErrorNumber > 0 Then
                            nErrNumber = oRisultato.ErrorNumber
                            Throw New Exception(oRisultato.ErrorDescription)
                        End If
                End Select
                '
                ' A questo punto per eventi A,T,D (elaborati in ordine cronologico sbagliato) è necessario 
                ' eseguire una SP di consolidamento per aggiustare lo stato di eventi che dovrebbero essere 
                ' ANNULLATI/ERASED/FUSI
                '
                Select Case Messaggio.Evento.TipoEventoCodice.ToUpper
                    Case "A", "T", "D"
                        oRisultato = EventiRicoveroConsolida(oEventoAdapter, Messaggio)
                        If oRisultato.ErrorNumber > 0 Then
                            nErrNumber = oRisultato.ErrorNumber
                            Throw New Exception(oRisultato.ErrorDescription)
                        End If
                End Select

            Case TipoMessaggioEvento.Rimozione
                '
                ' Preparo messaggio di info evento
                '
                Dim sMsgEvento As String = String.Concat(String.Format("IdEsterno = '{0}'", sIdEsterno), vbCrLf, _
                                                         String.Format("Azienda = '{0}'", Messaggio.Evento.AziendaErogante), vbCrLf, _
                                                         String.Format("Sistema = '{0}'", Messaggio.Evento.SistemaErogante), vbCrLf, _
                                                         String.Format("NumeroNosologico = '{0}'", Messaggio.Evento.NumeroNosologico))

                ' ------------------------------------------------------------------------------------------
                ' Rimuovo
                ' ------------------------------------------------------------------------------------------
                If bEventoEsiste Then
                    If oEventoAdapter.EventiRemove(sIdEsterno) Then
                        '
                        ' Log evento
                        '
                        LogEvent.WriteInformation(String.Concat("Cancellazione evento:", vbCrLf, sMsgEvento))
                    End If
                Else
                    '
                    ' Se non c'è scrivo warning
                    '
                    LogEvent.WriteWarning(String.Concat("Evento non trovato durante la cancellazione:", vbCrLf, sMsgEvento))
                End If

        End Select
        '
        ' Ritorna OK
        '
        Return New Risultato(0, "")

    End Function

    Private Function RicoveroAzioni(ByVal oEventoAdapter As EventoAdapter, _
                                    ByVal Tipo As ConnectorV2.TipoMessaggioEvento, _
                                    ByVal Data As DateTime, _
                                    ByVal Messaggio As ConnectorV2.MessaggioEvento) As Risultato
        '
        ' nErrNumber da 50 in su
        '
        Dim iWarningCode As Integer = 0
        Dim nErrNumber As Int16 = 0
        Dim sError As String = Nothing
        Dim oRisultato As Risultato = Nothing
        Dim sIdEsterno As String = Messaggio.Evento.IdEsternoEvento & ""
        '
        ' Controllo sul tipo di messaggio
        '
        Select Case Messaggio.Evento.TipoEventoCodice.ToUpper
            Case "X"
                ' ------------------------------------------------------------------------------------------
                ' RimuovoEpisodio
                ' ------------------------------------------------------------------------------------------
                If oEventoAdapter.EventiRicoveroAnnulla(sIdEsterno, iWarningCode) Then
                    Dim sLogMsg As String = ""
                    Select Case iWarningCode
                        Case 1004
                            '
                            ' Se viene restituito il codice di errore 1004 significa che l'evento di corrente
                            ' ha una data di evento inferiore ad un evento dello stesso tipo presente nel db 
                            '
                            sLogMsg = "Evento di annullamento obsoleto!"
                        Case Else
                            sLogMsg = "Annullato episodio"
                    End Select
                    '
                    ' Log evento
                    '
                    LogEvent.WriteInformation(sLogMsg & vbCrLf & _
                                    "IdEsterno = '" & sIdEsterno & "'" & vbCrLf & _
                                    "Azienda = '" & Messaggio.Evento.AziendaErogante & "'" & vbCrLf & _
                                    "Sistema = '" & Messaggio.Evento.SistemaErogante & "'" & vbCrLf & _
                                    "Reparto = '" & Messaggio.Evento.RepartoErogante & "'" & vbCrLf & _
                                    "DataEvento = '" & Messaggio.Evento.DataEvento & "'" & vbCrLf & _
                                    "NumeroNosologico = '" & Messaggio.Evento.NumeroNosologico & "'")
                Else
                    nErrNumber = 50
                    sError = "Errore durante l'Annullamento di un episodio."
                    oRisultato = New Risultato(nErrNumber, sError)
                    Return oRisultato
                End If

            Case "M"
                ' ------------------------------------------------------------------------------------------
                ' Fusione
                ' In questo caso messaggio.Paziente.IdEsternoPaziente rappresenta il paziente che va a sostituire
                ' quello attuale
                ' ATTENZIONE: Si devono cancellare e inserire i soli attributi anagrafici!!!
                ' ------------------------------------------------------------------------------------------
                '
                ' Se sono qui l'evento di Merge/Fusione è stato inserito con e l'IdPaziente di tale evento è il nuovo IdPaziente 
                ' con cui bisogna sostituire l'IdPaziente degli eventi appartenenti allo stesso ricovero [Azienda,Nosologico]
                '
                Dim xmlAttributiAnagrafici As Xml.XmlDocument = Nothing
                Dim oAttributiAnagrafici() As ConnectorV2.Attributo = CreateAttributiAnagrafici(Messaggio)
                xmlAttributiAnagrafici = XmlUtil.CreateXdocAttributi(oAttributiAnagrafici)
                Dim sXmlAttributi As String = XmlUtil.GetXmlWriterAttributi(xmlAttributiAnagrafici)
                '
                ' L'xml document non serve più
                '
                xmlAttributiAnagrafici = Nothing

                If oEventoAdapter.EventiRicoveroFondi(sIdEsterno, sXmlAttributi, iWarningCode) Then
                    Dim sLogMsg As String = ""
                    Select Case iWarningCode
                        Case 1004
                            '
                            ' Se viene restituito il codice di errore 1004 significa che l'evento di fusione corrente
                            ' ha una data di evento inferiore ad un evento di fusione già presente nel db (quindi i dati 
                            ' dell'evento corrente sono obsoleti)
                            '
                            sLogMsg = "Evento di fusione obsoleto!"
                        Case Else
                            sLogMsg = "Fusione episodio!"
                    End Select
                    '
                    ' Log evento
                    '
                    LogEvent.WriteInformation(sLogMsg & vbCrLf & _
                                    "IdEsterno = '" & sIdEsterno & "'" & vbCrLf & _
                                    "Azienda = '" & Messaggio.Evento.AziendaErogante & "'" & vbCrLf & _
                                    "Sistema = '" & Messaggio.Evento.SistemaErogante & "'" & vbCrLf & _
                                    "Reparto = '" & Messaggio.Evento.RepartoErogante & "'" & vbCrLf & _
                                    "DataEvento = '" & Messaggio.Evento.DataEvento & "'" & vbCrLf & _
                                    "NumeroNosologico = '" & Messaggio.Evento.NumeroNosologico & "'" & vbCrLf & _
                                    "IdEsternoPazienteFuso = '" & Messaggio.Paziente.IdEsternoPaziente)
                Else
                    nErrNumber = 51
                    sError = "Errore durante la Fusione di un episodio."
                    oRisultato = New Risultato(nErrNumber, sError)
                    Return oRisultato
                End If

            Case "R"
                ' ------------------------------------------------------------------------------------------
                ' RiaperturaEpisodio
                ' ------------------------------------------------------------------------------------------
                If oEventoAdapter.EventiRicoveroRiapri(sIdEsterno, iWarningCode) Then
                    Dim sLogMsg As String = ""
                    Select Case iWarningCode
                        Case 1004
                            '
                            ' Se viene restituito il codice di errore 1004 significa che l'evento di corrente
                            ' ha una data di evento inferiore ad un evento dello stesso tipo presente nel db 
                            '
                            sLogMsg = "Evento di riapertura obsoleto!"
                        Case Else
                            sLogMsg = "Riaperto episodio"
                    End Select
                    '
                    ' Log evento
                    '
                    LogEvent.WriteInformation(sLogMsg & vbCrLf & _
                                    "IdEsterno = '" & sIdEsterno & "'" & vbCrLf & _
                                    "Azienda = '" & Messaggio.Evento.AziendaErogante & "'" & vbCrLf & _
                                    "Sistema = '" & Messaggio.Evento.SistemaErogante & "'" & vbCrLf & _
                                    "Reparto = '" & Messaggio.Evento.RepartoErogante & "'" & vbCrLf & _
                                    "DataEvento = '" & Messaggio.Evento.DataEvento & "'" & vbCrLf & _
                                    "NumeroNosologico = '" & Messaggio.Evento.NumeroNosologico & "'")
                Else
                    nErrNumber = 52
                    sError = "Errore durante la Riapertura di un episodio."
                    oRisultato = New Risultato(nErrNumber, sError)
                    Return oRisultato
                End If

            Case "E"
                ' ------------------------------------------------------------------------------------------
                ' Rimuovo Episodio
                ' ------------------------------------------------------------------------------------------
                If oEventoAdapter.EventiRicoveroRimuovi(sIdEsterno, iWarningCode) Then
                    Dim sLogMsg As String = ""
                    Select Case iWarningCode
                        Case 1004
                            '
                            ' Se viene restituito il codice di errore 1004 significa che l'evento di corrente
                            ' ha una data di evento inferiore ad un evento dello stesso tipo presente nel db 
                            '
                            sLogMsg = "Evento di erase obsoleto!"
                        Case Else
                            sLogMsg = "Rimosso episodio"
                    End Select
                    '
                    ' Log evento
                    '
                    LogEvent.WriteInformation("Rimosso episodio!" & vbCrLf & _
                                    "IdEsterno = '" & sIdEsterno & "'" & vbCrLf & _
                                    "Azienda = '" & Messaggio.Evento.AziendaErogante & "'" & vbCrLf & _
                                    "Sistema = '" & Messaggio.Evento.SistemaErogante & "'" & vbCrLf & _
                                    "Reparto = '" & Messaggio.Evento.RepartoErogante & "'" & vbCrLf & _
                                    "DataEvento = '" & Messaggio.Evento.DataEvento & "'" & vbCrLf & _
                                    "NumeroNosologico = '" & Messaggio.Evento.NumeroNosologico & "'")
                Else
                    nErrNumber = 53
                    sError = "Errore durante la Rimozione di un episodio."
                    oRisultato = New Risultato(nErrNumber, sError)
                    Return oRisultato
                End If
        End Select
        '
        ' Ritorna OK
        '
        Return New Risultato(0, "")

    End Function

    Private Function EventiRicoveroConsolida(ByVal oEventoAdapter As EventoAdapter, _
                                            ByVal Messaggio As ConnectorV2.MessaggioEvento) As Risultato
        Dim nErrNumber As Int16 = 0
        Dim sError As String = Nothing
        Dim oRisultato As Risultato = Nothing
        Dim sIdEsterno As String = Messaggio.Evento.IdEsternoEvento & ""

        If oEventoAdapter.EventiRicoveroConsolida(sIdEsterno) Then
            '
            ' Log evento
            '
            LogEvent.WriteInformation("Consolidamento episodio!" & vbCrLf & _
                            "IdEsterno = '" & sIdEsterno & "'" & vbCrLf & _
                            "Azienda = '" & Messaggio.Evento.AziendaErogante & "'" & vbCrLf & _
                            "Sistema = '" & Messaggio.Evento.SistemaErogante & "'" & vbCrLf & _
                            "Reparto = '" & Messaggio.Evento.RepartoErogante & "'" & vbCrLf & _
                            "DataEvento = '" & Messaggio.Evento.DataEvento & "'" & vbCrLf & _
                            "NumeroNosologico = '" & Messaggio.Evento.NumeroNosologico & "'")
        Else
            nErrNumber = 54
            sError = "Errore durante Consolidamento di un evento."
            oRisultato = New Risultato(nErrNumber, sError)
            Return oRisultato
        End If
        '
        ' Ritorna OK
        '
        Return New Risultato(0, "")

    End Function


    Private Function CreateAttributiAnagrafici(ByVal oMessaggio As ConnectorV2.MessaggioEvento) As ConnectorV2.Attributo()
        '
        ' Crea gli attributi del paziente
        '
        Dim dtDataNascita As DateTime = XmlUtil.ParseDatetime(oMessaggio.Paziente.DataNascita & "")
        Dim oAttibuto1 As ConnectorV2.Attributo = New ConnectorV2.Attributo("CodiceAnagraficaCentrale", oMessaggio.Paziente.CodiceAnagraficaCentrale & "")
        Dim oAttibuto2 As ConnectorV2.Attributo = New ConnectorV2.Attributo("NomeAnagraficaCentrale", oMessaggio.Paziente.NomeAnagraficaCentrale & "")
        Dim oAttibuto3 As ConnectorV2.Attributo = New ConnectorV2.Attributo("Cognome", oMessaggio.Paziente.Cognome & "")
        Dim oAttibuto4 As ConnectorV2.Attributo = New ConnectorV2.Attributo("Nome", oMessaggio.Paziente.Nome & "")
        Dim oAttibuto5 As ConnectorV2.Attributo = New ConnectorV2.Attributo("Sesso", oMessaggio.Paziente.Sesso & "")
        Dim oAttibuto6 As ConnectorV2.Attributo = New ConnectorV2.Attributo("DataNascita", XmlUtil.FormatDatetime(dtDataNascita))
        Dim oAttibuto7 As ConnectorV2.Attributo = New ConnectorV2.Attributo("ComuneNascita", oMessaggio.Paziente.LuogoNascita & "")
        Dim oAttibuto8 As ConnectorV2.Attributo = New ConnectorV2.Attributo("CodiceFiscale", oMessaggio.Paziente.CodiceFiscale & "")
        Dim oAttibuto9 As ConnectorV2.Attributo = New ConnectorV2.Attributo("CodiceSanitario", oMessaggio.Paziente.CodiceSanitario & "")
        Dim oAttibuto10 As ConnectorV2.Attributo = New ConnectorV2.Attributo("IdEsternoPaziente", oMessaggio.Paziente.IdEsternoPaziente & "")

        Return New ConnectorV2.Attributo() {oAttibuto1, oAttibuto2, oAttibuto3, _
                                            oAttibuto4, oAttibuto5, oAttibuto6, _
                                            oAttibuto7, oAttibuto8, oAttibuto9, _
                                            oAttibuto10}

    End Function

    Private Function GetEventiRicoveroTipoEventoDescrizione(ByVal sTipoEventoCodice As String) As String
        Dim sRet As String = ""
        Select Case sTipoEventoCodice.ToUpper
            Case "A"
                sRet = "Accettazione"
            Case "T"
                sRet = "Trasferimento"
            Case "D"
                sRet = "Dimissione"
            Case "M"
                sRet = "Fusione"
            Case "X"
                sRet = "Annullamento"
            Case "R"
                sRet = "Riapertura"
            Case "E"
                sRet = "Cancellazione"
                '------------------------------------------------------------------
                ' I codici degli eventi lista di attesa
                '------------------------------------------------------------------
            Case "IL"
                sRet = "Inserimento"
            Case "ML"
                sRet = "Modifica"
            Case "DL"
                sRet = "Chiusura"
            Case "RL"
                sRet = "Riapertura"
            Case "SL"
                sRet = "Spostamento"
        End Select
        Return sRet
    End Function


    ''' <summary>
    ''' Restituisce un array di attributi dell'evento che non contiene gli attributi che non devono essere scritti nella tabella EventiAttributi
    ''' </summary>
    ''' <param name="oMessaggio">Il messaggio dell'evento</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function ReadAttributiEventoSenzaInfoRicovero(ByVal oMessaggio As ConnectorV2.MessaggioEvento) As ConnectorV2.Attributo()
        '
        ' ESCLUDE gli attributi il cui nome inizia con "Ric@" 
        ' (cioè gli attributi che devono essere scritti solo come attributi del ricovero)
        '
        Dim oListAttributi As New Collections.Generic.List(Of ConnectorV2.Attributo)
        For Each oAttr As ConnectorV2.Attributo In oMessaggio.Evento.Attributi
            '
            ' Trasfomo in maiuscolo il nome
            '
            Dim sAttribNome As String = (oAttr.Nome & "").ToUpper()
            '
            ' Tengo solo gli attributi che NON INIZIANO con "RIC@"
            '
            If Not sAttribNome.StartsWith(EV_ATTR_PREFIX_INFO_RICOVERO) Then
                oListAttributi.Add(oAttr)
            End If
        Next
        Return oListAttributi.ToArray()
    End Function

    ''' <summary>
    ''' Restituisce un array di attributi che contiene solo gli attributi relativi alle "Info di ricovero"
    ''' </summary>
    ''' <param name="oMessaggio"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function ReadAttributiInfoDiRicovero(ByVal oMessaggio As ConnectorV2.MessaggioEvento) As ConnectorV2.Attributo()
        '
        ' Crea un array che contiene SOLO gli attributi il cui nome inizia con "Ric@"
        ' (cioè gli attributi che devono essere scritti solo come attributi del ricovero)
        '
        Dim oListAttributi As New Collections.Generic.List(Of ConnectorV2.Attributo)
        For Each oAttr As ConnectorV2.Attributo In oMessaggio.Evento.Attributi
            '
            ' Trasfomo in maiuscolo il nome
            '
            Dim sAttribNome As String = (oAttr.Nome & "").ToUpper()
            '
            ' Tengo solo gli attributi che INIZIANO con "RIC@"
            '
            If sAttribNome.StartsWith(EV_ATTR_PREFIX_INFO_RICOVERO) Then
                'Modifica Ettore 2013-06-03: Tolgo il prefisso "Ric@"
                If Not String.IsNullOrEmpty(oAttr.Nome) Then
                    oAttr.Nome = oAttr.Nome.Remove(0, 4)
                    oListAttributi.Add(oAttr)
                End If
            End If
        Next
        Return oListAttributi.ToArray()
    End Function


#End Region


    Private Function EventiRicoveroAggiornaRicovero(ByVal oEventoAdapter As EventoAdapter, _
                                                    ByVal Tipo As ConnectorV2.TipoMessaggioEvento, _
                                                    ByVal Messaggio As ConnectorV2.MessaggioEvento, ByVal IdPazienteAssociato As Guid) As Risultato
        Dim oDtRicovero As DataTable = Nothing
        Dim sIdEsternoRicovero As String = String.Empty
        Dim sNumeroNosologico As String = String.Empty
        Dim sAziendaErogante As String = String.Empty
        Dim sSistemaErogante As String = String.Empty
        Dim sIdEsternoEvento As String = String.Empty
        Dim xmlAttributiRicovero As Xml.XmlDocument = Nothing
        Dim sTipoEventoCodice As String = Messaggio.Evento.TipoEventoCodice.ToUpper
        Try
            '
            ' Verifico se il Ricovero esiste -> Inserimento/Modifica
            ' 
            sNumeroNosologico = Messaggio.Evento.NumeroNosologico
            sAziendaErogante = Messaggio.Evento.AziendaErogante
            sSistemaErogante = Messaggio.Evento.SistemaErogante
            sIdEsternoEvento = Messaggio.Evento.IdEsternoEvento
            'MODIFICA ETTORE 2016-09-08: utilizzato il sistema erogante del messaggio per comporre l'IdEsternoRicovero 
            sIdEsternoRicovero = String.Format("{0}_{1}_{2}", sAziendaErogante, sSistemaErogante, sNumeroNosologico)
            Dim dtDataModificaEsternoRicovero As Date = oEventoAdapter.RicoveriContains(sIdEsternoRicovero)
            Dim bRicoveroEsiste As Boolean = (dtDataModificaEsternoRicovero <> Nothing)
            '
            ' MODIFICA ETTORE 2019-05-27: chiamo due differenti SP per consolidare in i dati del record del ricovero  in base al fatto che sia un RICOVERO ADT o una PRENOTAZIONE
            '
            If IsEventoRicovero(sTipoEventoCodice) Then
                oDtRicovero = oEventoAdapter.EventiConsolidaRicovero(sNumeroNosologico, sAziendaErogante, bRicoveroEsiste, sTipoEventoCodice)
            Else
                oDtRicovero = oEventoAdapter.EventiConsolidaPrenotazione(sNumeroNosologico, sAziendaErogante, bRicoveroEsiste, sIdEsternoEvento)
            End If
            If oDtRicovero Is Nothing OrElse oDtRicovero.Rows.Count = 0 Then
                '
                ' Anche in caso di cancellazione logica degli eventi, il record del ricovero comunque già esiste; 
                ' se non c'è nessun evento valido con StatoCodice=0 verrà restituito un ricovero nello stato MALFORMATO
                '
                ' Se oDtRicovero è vuota è accaduto qualcosa e quindi interrompo il processamento facendo throw di una eccezione
                ' Poichè l'eccezione è controllata anche in oEventoAdapter.RicoveroFromEventiADT questo codice dovrebbe mai essere eseguito
                '
                Dim sMsgErr As String = String.Format("Impossibile ricavare i dati del ricovero per [AziendaErogante, NumeroNosologico]=['{0}', '{1}'] relativi all'evento con IdEsterno {2}", sAziendaErogante, sNumeroNosologico, sIdEsternoEvento)
                If IsEventoRicovero(sTipoEventoCodice) Then
                    sMsgErr = String.Concat(sMsgErr, " durante il consolidamento del ricovero.")
                Else
                    sMsgErr = String.Concat(sMsgErr, " durante il consolidamento della prenotazione.")
                End If
                Throw New DatiMancantiException(sMsgErr)
            End If
            '
            ' A questo punto ho il record del ricovero...
            '
            Dim oRowRicovero As DataRow = oDtRicovero.Rows(0)
            '
            ' ...Se evento A o M ricavo dal messaggio dell'evento gli attributi XML anagrafici...NON CORRETTO
            ' Nella parte Paziente ci sono sempre i dati anagrafici corretti da scrivere negli attributi
            '
            Dim sXmlAttributiRicovero As String = String.Empty
            '
            ' Creo gli attributi anagrafici e li aggiungo al document xml
            '
            Dim oAttributiAnagrafici() As ConnectorV2.Attributo = CreateAttributiAnagrafici(Messaggio)
            xmlAttributiRicovero = XmlUtil.CreateXdocAttributi(oAttributiAnagrafici)
            '
            ' Creo gli attributi contenenti le informazioni di ricovero e li aggiungo al document xml
            '
            Dim oAttributiRicovero() As ConnectorV2.Attributo = ReadAttributiInfoDiRicovero(Messaggio)
            xmlAttributiRicovero = XmlUtil.AddXdocAttributi(xmlAttributiRicovero, oAttributiRicovero)
            '
            ' Converto in stringa da passare alle stored procedure
            '
            sXmlAttributiRicovero = XmlUtil.GetXmlWriterAttributi(xmlAttributiRicovero)
            '
            ' Aggiorno/Inserisco il record del ricovero
            '
            If bRicoveroEsiste Then
                '
                ' Aggiorno se c'è
                ' MODIFICA ETTORE 2016-09-08: utilizzato il sistema erogante del messaggio per creare il record del ricovero
                '
                If oEventoAdapter.RicoveriUpdate(sIdEsternoRicovero, _
                                                    IdPazienteAssociato, _
                                                    CType(oRowRicovero("StatoCodice"), Integer), _
                                                    sNumeroNosologico, _
                                                    sAziendaErogante, _
                                                    sSistemaErogante, _
                                                    DbNull2Nothing(oRowRicovero, "RepartoErogante", ""), _
                                                    DbNull2Nothing(oRowRicovero, "OspedaleCodice", ""), _
                                                    DbNull2Nothing(oRowRicovero, "OspedaleDescr", ""), _
                                                    DbNull2Nothing(oRowRicovero, "TipoRicoveroCodice", ""), _
                                                    DbNull2Nothing(oRowRicovero, "TipoRicoveroDescr", ""), _
                                                    DbNull2Nothing(oRowRicovero, "Diagnosi", ""), _
                                                    DbNull2Nothing(oRowRicovero, "DataAccettazione", #1/1/1753#), _
                                                    DbNull2Nothing(oRowRicovero, "RepartoAccettazioneCodice", ""), _
                                                    DbNull2Nothing(oRowRicovero, "RepartoAccettazioneDescr", ""), _
                                                    DbNull2Nothing(oRowRicovero, "DataTrasferimento", #1/1/1753#), _
                                                    DbNull2Nothing(oRowRicovero, "RepartoCodice", ""), _
                                                    DbNull2Nothing(oRowRicovero, "RepartoDescr", ""), _
                                                    DbNull2Nothing(oRowRicovero, "SettoreCodice", ""), _
                                                    DbNull2Nothing(oRowRicovero, "SettoreDescr", ""), _
                                                    DbNull2Nothing(oRowRicovero, "LettoCodice", ""), _
                                                    DbNull2Nothing(oRowRicovero, "DataDimissione", #1/1/1753#), _
                                                    sXmlAttributiRicovero) Then
                    '
                    ' Aggiorno data modifica esterna con la data restituita dalla SP RicoveroFromEventiADT(...)
                    '
                    oEventoAdapter.RicoveriDataModificaUpdate(sIdEsternoRicovero, DirectCast(oRowRicovero("DataModificaEsterno"), Date))
                    '
                    ' Log Ricovero
                    '
                    LogEvent.WriteInformation("Modificato Ricovero!" & vbCrLf & _
                                    "IdEsterno = '" & sIdEsternoRicovero & "'" & vbCrLf & _
                                    "Azienda = '" & sAziendaErogante & "'" & vbCrLf & _
                                    "Sistema = 'ADT'" & vbCrLf & _
                                    "NumeroNosologico = '" & sNumeroNosologico & "'")
                Else
                    '
                    ' Errore se non c'è
                    '
                    Return New Risultato(12, "Errore durante modifica record Ricovero!")
                End If
            Else
                '
                ' Insert
                '
                If oEventoAdapter.RicoveriAddNew(sIdEsternoRicovero, _
                                                    IdPazienteAssociato, _
                                                    CType(oRowRicovero("StatoCodice"), Integer), _
                                                    sNumeroNosologico, _
                                                    sAziendaErogante, _
                                                    sSistemaErogante, _
                                                    DbNull2Nothing(oRowRicovero, "RepartoErogante", ""), _
                                                    DbNull2Nothing(oRowRicovero, "OspedaleCodice", ""), _
                                                    DbNull2Nothing(oRowRicovero, "OspedaleDescr", ""), _
                                                    DbNull2Nothing(oRowRicovero, "TipoRicoveroCodice", ""), _
                                                    DbNull2Nothing(oRowRicovero, "TipoRicoveroDescr", ""), _
                                                    DbNull2Nothing(oRowRicovero, "Diagnosi", ""), _
                                                    DbNull2Nothing(oRowRicovero, "DataAccettazione", #1/1/1753#), _
                                                    DbNull2Nothing(oRowRicovero, "RepartoAccettazioneCodice", ""), _
                                                    DbNull2Nothing(oRowRicovero, "RepartoAccettazioneDescr", ""), _
                                                    DbNull2Nothing(oRowRicovero, "DataTrasferimento", #1/1/1753#), _
                                                    DbNull2Nothing(oRowRicovero, "RepartoCodice", ""), _
                                                    DbNull2Nothing(oRowRicovero, "RepartoDescr", ""), _
                                                    DbNull2Nothing(oRowRicovero, "SettoreCodice", ""), _
                                                    DbNull2Nothing(oRowRicovero, "SettoreDescr", ""), _
                                                    DbNull2Nothing(oRowRicovero, "LettoCodice", ""), _
                                                    DbNull2Nothing(oRowRicovero, "DataDimissione", #1/1/1753#), _
                                                    sXmlAttributiRicovero) Then
                    '
                    ' Aggiorno data modifica esterna
                    '
                    oEventoAdapter.RicoveriDataModificaUpdate(sIdEsternoRicovero, DirectCast(oRowRicovero("DataModificaEsterno"), Date))
                    '
                    ' Log evento
                    '
                    LogEvent.WriteInformation("Aggiunto ricovero mancante!" & vbCrLf & _
                                    "IdEsterno = '" & sIdEsternoRicovero & "'" & vbCrLf & _
                                    "Azienda = '" & sAziendaErogante & "'" & vbCrLf & _
                                    "Sistema = 'ADT'" & vbCrLf & _
                                    "NumeroNosologico = '" & sNumeroNosologico & "'")
                Else
                    '
                    ' Errore se non c'è
                    '
                    Return New Risultato(13, "Errore durante inserimento record Ricovero!")
                End If
            End If

            '
            ' Tutto OK
            '
            Return New Risultato(0, "")

        Catch ex As SqlException
            Select Case ex.Number
                Case SqlExceptionNumber.Timeout, SqlExceptionNumber.DeadLock
                    Throw
            End Select
            Return New Risultato(101, ex.Message)
        Catch ex As Exception
            Return New Risultato(101, ex.Message)

        Finally
            If Not oDtRicovero Is Nothing Then
                oDtRicovero.Dispose()
            End If
            xmlAttributiRicovero = Nothing
        End Try
    End Function

    Private Function DbNull2Nothing(ByVal DataRow As DataRow, ByVal Column As String, ByVal DefValue As Guid) As Guid

        Try
            If DataRow(Column) Is DBNull.Value Then
                Return DefValue
            Else
                Return CType(DataRow(Column), Guid)
            End If
        Catch ex As Exception
            Throw New ApplicationException("Errore in DbNull2Nothing! " & ex.Message)
        End Try

    End Function

    Private Function DbNull2Nothing(ByVal DataRow As DataRow, ByVal Column As String, ByVal DefValue As String) As String

        Try
            If DataRow(Column) Is DBNull.Value Then
                Return DefValue
            Else
                If DataRow(Column).GetType Is GetType(Guid) Then
                    Return DataRow(Column).ToString
                Else
                    Return CType(DataRow(Column), String)
                End If
            End If
        Catch ex As Exception
            Throw New ApplicationException("Errore in DbNull2Nothing! " & ex.Message)
        End Try

    End Function

    Private Function DbNull2Nothing(ByVal DataRow As DataRow, ByVal Column As String, ByVal DefValue As Date) As Date

        Try
            If DataRow(Column) Is DBNull.Value Then
                Return DefValue
            Else
                Return CType(DataRow(Column), Date)
            End If
        Catch ex As Exception
            Throw New ApplicationException("Errore in DbNull2Nothing! " & ex.Message)
        End Try

    End Function

    Private Function DbNull2Nothing(ByVal DataRow As DataRow, ByVal Column As String, ByVal DefValue As Integer) As Integer

        Try
            If DataRow(Column) Is DBNull.Value Then
                Return DefValue
            Else
                Return CType(DataRow(Column), Integer)
            End If
        Catch ex As Exception
            Throw New ApplicationException("Errore in DbNull2Nothing! " & ex.Message)
        End Try

    End Function

    Private Function DbNull2Nothing(ByVal DataRow As DataRow, ByVal Column As String, ByVal DefValue As Byte()) As Byte()

        Try
            If DataRow(Column) Is DBNull.Value Then
                Return DefValue
            Else
                Return CType(DataRow(Column), Byte())
            End If
        Catch ex As Exception
            Throw New ApplicationException("Errore in DbNull2Nothing! " & ex.Message)
        End Try

    End Function

    Private Function AutoprefixIdEsterno(ByVal IdEsterno As String, ByVal AziendaErogante As String, oListAziendeEroganti As System.Collections.Generic.List(Of String), ByRef IdEsternoNew As String) As Boolean
        Dim sIdEsternoUpper As String = IdEsterno.ToUpper
        IdEsternoNew = sIdEsternoUpper

        For Each sAziendaErogante As String In oListAziendeEroganti
            sAziendaErogante = sAziendaErogante.ToUpper
            If sIdEsternoUpper.StartsWith(sAziendaErogante & "_") Then
                Return False
            End If
        Next
        '
        ' Se sono qui devo prefissare
        '
        IdEsternoNew = AziendaErogante.ToUpper & "_" & IdEsterno
        Return True
    End Function




#Region "  Gestione Ricovero (Tabella Ricoveri) - COMMENTATO"

#Region " TipoMessaggioRicovero - COMMENTATO"

    'Public Enum TipoMessaggioRicovero As Byte
    '    Aggiornamento = 0 'Creazione/Modifica
    '    Rimozione = 1
    'End Enum

#End Region

#Region " Ricovero - COMMENTATO"

    '<Serializable()> _
    'Public Class Ricovero_1
    '    Public IdEsternoRicovero As String
    '    Public StatoCodice As String
    '    Public NumeroNosologico As String
    '    Public AziendaErogante As String
    '    Public SistemaErogante As String
    '    Public RepartoErogante As String
    '    Public OspedaleCodice As String
    '    Public OspedaleDescrizione As String
    '    Public TipoRicoveroCodice As String
    '    Public TipoRicoveroDescrizione As String
    '    Public Diagnosi As String
    '    Public DataAccettazione As String
    '    Public RepartoAccettazioneCodice As String
    '    Public RepartoAccettazioneDescrizione As String
    '    Public TipoUltimoEvento As String
    '    Public DataUltimoEvento As String
    '    Public UltimoRepartoCodice As String
    '    Public UltimoRepartoDescrizione As String
    '    Public UltimoLettoCodice As String
    '    Public DataDimissione As String
    '    Public Attributi() As ConnectorV2.Attributo

    '    Public Sub New()
    '    End Sub

    '    Public Sub New(ByVal IdEsternoRicovero As String, _
    '                    ByVal StatoCodice As String, _
    '                    ByVal NumeroNosologico As String, _
    '                    ByVal AziendaErogante As String, _
    '                    ByVal SistemaErogante As String, _
    '                    ByVal RepartoErogante As String, _
    '                    ByVal OspedaleCodice As String, _
    '                    ByVal OspedaleDescrizione As String, _
    '                    ByVal TipoRicoveroCodice As String, _
    '                    ByVal TipoRicoveroDescrizione As String, _
    '                    ByVal Diagnosi As String, _
    '                    ByVal DataAccettazione As String, _
    '                    ByVal RepartoAccettazioneCodice As String, _
    '                    ByVal RepartoAccettazioneDescrizione As String, _
    '                    ByVal TipoUltimoEvento As String, _
    '                    ByVal DataUltimoEvento As String, _
    '                    ByVal UltimoRepartoCodice As String, _
    '                    ByVal UltimoRepartoDescrizione As String, _
    '                    ByVal UltimoLettoCodice As String, _
    '                    ByVal DataDimissione As String, _
    '                    ByVal Attributi() As ConnectorV2.Attributo)

    '        Me.StatoCodice = StatoCodice
    '        Me.NumeroNosologico = NumeroNosologico
    '        Me.AziendaErogante = AziendaErogante
    '        Me.SistemaErogante = SistemaErogante
    '        Me.RepartoErogante = RepartoErogante
    '        Me.OspedaleCodice = OspedaleCodice
    '        Me.OspedaleDescrizione = OspedaleDescrizione
    '        Me.TipoRicoveroCodice = TipoRicoveroCodice
    '        Me.TipoRicoveroDescrizione = TipoRicoveroDescrizione
    '        Me.Diagnosi = Diagnosi
    '        Me.DataAccettazione = DataAccettazione
    '        Me.RepartoAccettazioneCodice = RepartoAccettazioneCodice
    '        Me.RepartoAccettazioneDescrizione = RepartoAccettazioneDescrizione
    '        Me.TipoUltimoEvento = TipoUltimoEvento
    '        Me.DataUltimoEvento = DataUltimoEvento
    '        Me.UltimoRepartoCodice = UltimoRepartoCodice
    '        Me.UltimoRepartoDescrizione = UltimoRepartoDescrizione
    '        Me.UltimoLettoCodice = UltimoLettoCodice
    '        Me.DataDimissione = DataDimissione
    '        Me.Attributi = Attributi

    '    End Sub

    '    Public Sub New(ByVal IdEsternoRicovero As String, _
    '                    ByVal StatoCodice As String, _
    '                    ByVal NumeroNosologico As String, _
    '                    ByVal AziendaErogante As String, _
    '                    ByVal SistemaErogante As String, _
    '                    ByVal RepartoErogante As String, _
    '                    ByVal OspedaleCodice As String, _
    '                    ByVal OspedaleDescrizione As String, _
    '                    ByVal TipoRicoveroCodice As String, _
    '                    ByVal TipoRicoveroDescrizione As String, _
    '                    ByVal Diagnosi As String, _
    '                    ByVal DataAccettazione As String, _
    '                    ByVal RepartoAccettazioneCodice As String, _
    '                    ByVal RepartoAccettazioneDescrizione As String, _
    '                    ByVal TipoUltimoEvento As String, _
    '                    ByVal DataUltimoEvento As String, _
    '                    ByVal UltimoRepartoCodice As String, _
    '                    ByVal UltimoRepartoDescrizione As String, _
    '                    ByVal UltimoLettoCodice As String, _
    '                    ByVal DataDimissione As String)

    '        Me.StatoCodice = StatoCodice
    '        Me.NumeroNosologico = NumeroNosologico
    '        Me.AziendaErogante = AziendaErogante
    '        Me.SistemaErogante = SistemaErogante
    '        Me.RepartoErogante = RepartoErogante
    '        Me.OspedaleCodice = OspedaleCodice
    '        Me.OspedaleDescrizione = OspedaleDescrizione
    '        Me.TipoRicoveroCodice = TipoRicoveroCodice
    '        Me.TipoRicoveroDescrizione = TipoRicoveroDescrizione
    '        Me.Diagnosi = Diagnosi
    '        Me.DataAccettazione = DataAccettazione
    '        Me.RepartoAccettazioneCodice = RepartoAccettazioneCodice
    '        Me.RepartoAccettazioneDescrizione = RepartoAccettazioneDescrizione
    '        Me.TipoUltimoEvento = TipoUltimoEvento
    '        Me.DataUltimoEvento = DataUltimoEvento
    '        Me.UltimoRepartoCodice = UltimoRepartoCodice
    '        Me.UltimoRepartoDescrizione = UltimoRepartoDescrizione
    '        Me.UltimoLettoCodice = UltimoLettoCodice
    '        Me.DataDimissione = DataDimissione

    '    End Sub

    'End Class

#End Region

#Region " MessaggioRicovero - COMMENTATO"

    'TO DO: da aggiungere alla Schema.vb come fatto per gli eventi

    'Public Class MessaggioRicovero
    '    Public Paziente As ConnectorV2.Paziente
    '    Public Ricovero As ConnectorV2.Ricovero_1

    '    Public Sub New()
    '    End Sub

    '    Public Sub New(ByVal Paziente As ConnectorV2.Paziente, ByVal Ricovero As ConnectorV2.Ricovero_1)
    '        Me.Paziente = Paziente
    '        Me.Ricovero = Ricovero
    '    End Sub

    '    Public Shared Function Deserialize(ByVal XmlData As String) As ConnectorV2.MessaggioRicovero

    '        Dim oStream As IO.MemoryStream = Nothing
    '        Dim oTextReader As Xml.XmlTextReader = Nothing

    '        Try
    '            Dim oEnc As Encoding = Encoding.UTF8

    '            oStream = New IO.MemoryStream
    '            oStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
    '            oStream.Position = 0

    '            oTextReader = New Xml.XmlTextReader(oStream)

    '            Dim oMessaggio As MessaggioRicovero

    '            Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(ConnectorV2.MessaggioEvento))
    '            oMessaggio = CType(oSerializer.Deserialize(oTextReader), ConnectorV2.MessaggioRicovero)

    '            Return oMessaggio

    '        Catch ex As Exception
    '            '
    '            ' Error
    '            '
    '            Dim sMessage As String = "ConnectorV2 MessaggioRicovero.Deserialize(); Errore durante la deserializzazione!"
    '            '
    '            ' Log e eccezione
    '            '
    '            LogEvent.WriteError(ex, sMessage)
    '            Throw New System.Exception(sMessage, ex)

    '        Finally
    '            '
    '            ' Rilascio
    '            '
    '            Try
    '                If Not oStream Is Nothing Then
    '                    oStream.Close()
    '                End If
    '                If Not oTextReader Is Nothing Then
    '                    oTextReader.Close()
    '                End If
    '            Catch ex As Exception
    '            End Try
    '        End Try

    '    End Function

    '    Public Shared Function Serialize(ByVal Messaggio As ConnectorV2.MessaggioRicovero) As String
    '        '
    '        ' Serializzo
    '        '
    '        Dim oStream As IO.MemoryStream = Nothing
    '        Dim oTextWriter As Xml.XmlTextWriter = Nothing

    '        Try
    '            Dim oEnc As Encoding = Encoding.UTF8

    '            oStream = New IO.MemoryStream
    '            oTextWriter = New Xml.XmlTextWriter(oStream, oEnc)

    '            Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(ConnectorV2.MessaggioRicovero))
    '            oSerializer.Serialize(oTextWriter, Messaggio)

    '            Dim sMessaggio As String = oEnc.GetString(oStream.ToArray())
    '            Return sMessaggio

    '        Catch ex As Exception
    '            '
    '            ' Error
    '            '
    '            Dim sMessage As String = "ConnectorV2 MessaggioRicovero.Serialize(); Errore durante la serializzazione!"
    '            '
    '            ' Log e eccezione
    '            '
    '            LogEvent.WriteError(ex, sMessage)
    '            Throw New System.Exception(sMessage, ex)

    '        Finally
    '            '
    '            ' Rilascio
    '            '
    '            Try
    '                If Not oStream Is Nothing Then
    '                    oStream.Close()
    '                End If
    '                If Not oTextWriter Is Nothing Then
    '                    oTextWriter.Close()
    '                End If
    '            Catch ex As Exception
    '            End Try
    '        End Try

    '    End Function

    'End Class

#End Region

#End Region


#Region "Join paziente con il SAC"

    Private Function JoinSacBuildCodiceAnagraficaDiInserimento(ByVal sIdEsternoPaziente As String) As String
        '
        ' Se l'IdEsterno del paziente è vuoto uso un Guid
        '
        ' MODIFICA ETTORE 2014-12-24: 
        '       se finisce con un "_" probabilmente l'IdEsternoPaziente è composto solo dal nome dell'anagrafica
        '       (Es.: "SAC_") e quindi non è corretto; anche in questo caso restotuisco un guid per assicurare l'univocità
        '
        Dim sRet As String
        If String.IsNullOrEmpty(sIdEsternoPaziente) OrElse sIdEsternoPaziente.EndsWith("_") Then
            sRet = Guid.NewGuid().ToString()
        Else
            sRet = sIdEsternoPaziente
        End If
        Return sRet
    End Function

    Private Function JoinPazienteSacReferto(ByVal oSacAdapter As SacAdapter, ByVal oMessaggio As MessaggioEpisodio, ByVal sNomeAnagraficaDiRicerca As String) As Guid
        Dim oIdPaziente As Guid = Nothing
        Try
            Dim dtDataNascita As DateTime = XmlUtil.ParseDatetime(oMessaggio.Paziente.DataNascita & "")
            Dim sCognome As String = oMessaggio.Paziente.Cognome & ""
            Dim sNome As String = oMessaggio.Paziente.Nome & ""
            Dim sCodiceSanitario As String = oMessaggio.Paziente.CodiceSanitario & ""
            Dim sSesso As String = oMessaggio.Paziente.Sesso & ""
            Dim sCodiceAnagraficaDiRicerca As String = oMessaggio.Paziente.CodiceAnagraficaCentrale & ""
            Dim sCodiceFiscale As String = oMessaggio.Paziente.CodiceFiscale & ""
            '
            '
            '
            Dim sIdEsternoPaziente As String = oMessaggio.Paziente.IdEsternoPaziente & ""
            Dim sCodiceAnagraficaDiInserimento As String = JoinSacBuildCodiceAnagraficaDiInserimento(sIdEsternoPaziente)
            '
            ' Eseguo la query
            '
            oIdPaziente = oSacAdapter.PazientiCercaAggancioPaziente(sNomeAnagraficaDiRicerca, _
                                                     sCodiceAnagraficaDiRicerca, _
                                                     sCodiceAnagraficaDiInserimento, _
                                                     sCodiceSanitario & "", _
                                                     sCognome, _
                                                     sNome, _
                                                     dtDataNascita, _
                                                     sSesso, _
                                                     sCodiceFiscale)

            If oIdPaziente = Nothing Then
                Dim sMsg As String = "Mancano i dati anagrafici minimi per il collegamento al paziente per il referto:" & vbCrLf & _
                                    "IdEsterno = '" & oMessaggio.Referto.IdEsternoReferto & "'" & vbCrLf & _
                                    "Azienda = '" & oMessaggio.Referto.AziendaErogante & "'" & vbCrLf & _
                                    "Sistema = '" & oMessaggio.Referto.SistemaErogante & "'" & vbCrLf & _
                                    "Reparto = '" & oMessaggio.Referto.RepartoErogante & "'" & vbCrLf & _
                                    "DataReferto = '" & oMessaggio.Referto.DataReferto & "'" & vbCrLf & _
                                    "NumeroReferto = '" & oMessaggio.Referto.NumeroReferto & "'" & vbCrLf & _
                                    "Il referto verrà associato al paziente anonimo."
                LogEvent.WriteWarning(sMsg)
            End If
        Catch ex As SqlClient.SqlException
            Select Case ex.Number
                Case SqlExceptionNumber.Timeout
                    Throw New CommandTimeoutException("Errore durante aggancio paziente al referto: " & ex.Message)
                Case Else
                    'Throw anche in caso di DeadLock
                    Throw
            End Select
        Catch ex As Exception
            Throw New ApplicationException("Errore durante aggancio paziente al referto: " & ex.Message)
        End Try
        ' 
        ' Restituisco il guid del paziente trovato, può essere nothing
        '
        Return oIdPaziente

    End Function

    Private Function JoinPazienteSacEvento(ByVal sConnectionString As String, ByVal oMessaggio As MessaggioEvento, ByVal sNomeAnagraficaDiRicerca As String) As Guid
        Dim oIdPaziente As Guid = Guid.Empty
        Dim oSacAdapter As SacAdapter = Nothing
        Try
            Dim dtDataNascita As DateTime = XmlUtil.ParseDatetime(oMessaggio.Paziente.DataNascita & "")
            Dim sCognome As String = oMessaggio.Paziente.Cognome & ""
            Dim sNome As String = oMessaggio.Paziente.Nome & ""
            Dim sCodiceSanitario As String = oMessaggio.Paziente.CodiceSanitario & ""
            Dim sSesso As String = oMessaggio.Paziente.Sesso & ""
            Dim sCodiceAnagraficaDiRicerca As String = oMessaggio.Paziente.CodiceAnagraficaCentrale & ""
            Dim sCodiceFiscale As String = oMessaggio.Paziente.CodiceFiscale & ""
            '
            '
            '
            Dim sIdEsternoPaziente As String = oMessaggio.Paziente.IdEsternoPaziente & ""
            Dim sCodiceAnagraficaDiInserimento As String = JoinSacBuildCodiceAnagraficaDiInserimento(sIdEsternoPaziente)
            '
            ' Instanzio adapter e imposto la stringa di connessione
            '
            oSacAdapter = New SacAdapter
            Try
                oSacAdapter.ConnectionOpen(sConnectionString)
            Catch ex As Exception
                Throw New ConnectionException(GetDatabaseInfo(sConnectionString) & vbCrLf & ex.Message)
            End Try
            '
            ' Eseguo la query
            '
            oIdPaziente = oSacAdapter.PazientiCercaAggancioPaziente(sNomeAnagraficaDiRicerca, _
                                                     sCodiceAnagraficaDiRicerca, _
                                                     sCodiceAnagraficaDiInserimento, _
                                                     sCodiceSanitario, _
                                                     sCognome, _
                                                     sNome, _
                                                     dtDataNascita, _
                                                     sSesso, _
                                                     sCodiceFiscale)

            If oIdPaziente = Nothing Then
                Dim sMsg As String = "Modificato evento!" & vbCrLf & _
                                    "IdEsterno = '" & oMessaggio.Evento.IdEsternoEvento & "'" & vbCrLf & _
                                    "Azienda = '" & oMessaggio.Evento.AziendaErogante & "'" & vbCrLf & _
                                    "Sistema = '" & oMessaggio.Evento.SistemaErogante & "'" & vbCrLf & _
                                    "Reparto = '" & oMessaggio.Evento.RepartoErogante & "'" & vbCrLf & _
                                    "DataEvento = '" & oMessaggio.Evento.DataEvento & "'" & vbCrLf & _
                                    "NumeroNosologico = '" & oMessaggio.Evento.NumeroNosologico & "'" & vbCrLf & _
                                    "L'evento di ricovero verrà associato al paziente anonimo."
                LogEvent.WriteWarning(sMsg)
            End If
        Catch ex As ConnectionException
            Throw
        Catch ex As SqlClient.SqlException
            Select Case ex.Number
                Case SqlExceptionNumber.Timeout
                    Throw New CommandTimeoutException("Errore durante aggancio paziente all'evento di ricovero: " & ex.Message)
                Case Else
                    'Throw anche in caso di DeadLock
                    Throw
            End Select
        Catch ex As Exception
            Throw New ApplicationException("Errore durante aggancio paziente all'evento di ricovero: " & ex.Message)
        Finally
            If Not oSacAdapter Is Nothing Then
                oSacAdapter.Dispose()
            End If
        End Try
        ' 
        ' Restituisco il guid del paziente trovato, può essere nothing
        '
        Return oIdPaziente

    End Function

#End Region

#Region "Transcodifica Unità Operative"

    Private Class UnitaOperativaTranscodificata
        Public Azienda As String
        Public Codice As String
        Public Descrizione As String

        Public Sub New(Azienda As String, Codice As String, Descrizione As String)
            Me.Azienda = Azienda
            Me.Codice = Codice
            Me.Descrizione = Descrizione
        End Sub
    End Class

    Private Function TranscodificaUnitaOperativa(oSacAdapter As SacAdapter, _
                                                ByVal sSistemaAzienda As String, ByVal sSistemaCodice As String, _
                                                ByVal sUnitaOperativaAzienda As String, ByVal sUnitaOperativaCodice As String, ByVal sUnitaOperativaDescrizione As String) As UnitaOperativaTranscodificata
        Dim sUoTransAzienda As String = String.Empty
        Dim sUoTransCodice As String = String.Empty
        Dim sUoTransDescrizione As String = String.Empty
        Try
            '-------------------------------------------------------------------------------------
            ' Mi assicuro che non ci siano dei nothing
            '-------------------------------------------------------------------------------------
            sSistemaAzienda = sSistemaAzienda & String.Empty
            sSistemaCodice = sSistemaCodice & String.Empty
            sUnitaOperativaAzienda = sUnitaOperativaAzienda & String.Empty
            sUnitaOperativaCodice = sUnitaOperativaCodice & String.Empty
            sUnitaOperativaDescrizione = sUnitaOperativaDescrizione & String.Empty
            '-------------------------------------------------------------------------------------

            oSacAdapter.TranscodificaUnitaOperativaDaSistemaACentrale(sSistemaAzienda, sSistemaCodice, _
                                                                      sUnitaOperativaAzienda, sUnitaOperativaCodice, sUnitaOperativaDescrizione, _
                                                                      sUoTransAzienda, sUoTransCodice, sUoTransDescrizione)
            Return New UnitaOperativaTranscodificata(sUoTransAzienda, sUoTransCodice, sUoTransDescrizione)

        Catch ex As SqlClient.SqlException
            Select Case ex.Number
                Case SqlExceptionNumber.Timeout
                    Throw New CommandTimeoutException("Errore in TranscodificaUnitaOperativa: " & ex.Message)
                Case Else
                    'Throw anche in caso di DeadLock
                    Throw
            End Select
        Catch ex As Exception
            Throw New ApplicationException("Errore in TranscodificaUnitaOperativa: " & ex.Message)
        End Try
    End Function


#End Region

    '
    ' Usata per determinare informazioni sul db che ha dato errore durante la connessione
    '
    Private Function GetDatabaseInfo(ByVal sConnectionString As String) As String
        Dim sb As New SqlConnectionStringBuilder(sConnectionString)
        Return String.Format("DataSource={0}, InitialCatalog={1}", sb.DataSource, sb.InitialCatalog)
    End Function

    ''' <summary>
    ''' Lettura del valore di attributo
    ''' </summary>
    ''' <param name="oAttributi"></param>
    ''' <param name="sNomeAttributo"></param>
    ''' <param name="sDefaultValue"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function GetValoreAttributo(ByVal oAttributi() As ConnectorV2.Attributo, ByVal sNomeAttributo As String, ByVal sDefaultValue As String) As String
        sNomeAttributo = sNomeAttributo.ToUpper
        Dim sRet As String = sDefaultValue
        If Not oAttributi Is Nothing Then
            For Each oAttr As ConnectorV2.Attributo In oAttributi
                If oAttr.Nome.ToUpper = sNomeAttributo Then
                    sRet = oAttr.Valore
                    Exit For
                End If
            Next
        End If
        Return sRet
    End Function



    Private Function RicoveroAzioniListaDiAttesa(ByVal oEventoAdapter As EventoAdapter, _
                                    ByVal Tipo As ConnectorV2.TipoMessaggioEvento, _
                                    ByVal Data As DateTime, _
                                    ByVal Messaggio As ConnectorV2.MessaggioEvento, ByVal IdPazienteAssociato As Guid) As Risultato
        '
        ' In generale questa funzione deve restituire errori con nErrNumber da 50 in su
        '
        Select Case Messaggio.Evento.TipoEventoCodice.ToUpper
            Case "DL"
                ' ------------------------------------------------------------------------------------------
                ' Inserimento del record fittizio con codice LA dove NumeroNosologico=<vero nosologico> ricavato
                ' dagli attributi dell'evento DL e con attributo di nome "CodiceListaAttesa" valorizzato con il valore 
                ' del campo nosologico presente nell'evento DL. Come attributi del record LA metto tutti 
                ' gli attributi anagrafici  presenti in DL + "CodiceListaAttesa"
                ' ------------------------------------------------------------------------------------------
                Return RicoveroAzioniListaAttesa_DL(oEventoAdapter, Tipo, Data, Messaggio, IdPazienteAssociato)

            Case "RL"
                ' ------------------------------------------------------------------------------------------
                ' Riapertura lista di attesa: esecuzione della SP delle azioni che gestisce nuovo codice "RL":
                ' nasconde "DL" ponendo EventiBase.StatoCodice=1 - funziona se gli IdEsterni sono scritti come
                ' ADT_<codiceprenotazione>_<DATA VARIABILE>_<codice evento> (1) in questo modo il nascondere equivale
                ' a cancellare e abbiamo nel db tutte le notifiche
                ' Se l'IdEsterno è scritto come ADT_<codiceprenotazione>_<DATA FISSATA>_<codice evento> (2) non posso
                ' usare StatoCodice=1 perchè dopo RL e successivo DL lo StatoCodice rimarrebbe a 1 (a meno che 
                ' non usi una nuova SP anche per gestire l'evento DL, a quel punto faccio ciò che voglio)
                ' ------------------------------------------------------------------------------------------

                'se si vuole tenere tutti gli eventi lista di attesa devo usare IdEsterno in modo (1)
                'e a questo punto la gestione del DL attuale è OK, bisogna fare la SP per RL

                'se si vuole usare usare IdEsterno in modo (2) allora devo fare una nuova SP per "DL" 
                '(che fa quello che faccio ora: cancella se esiste LA e come parametri ha gli stessi che passo ora + il "CodiceListaAttesa")
                'e la SP per RL

                Return RicoveroAzioniListaAttesa_RL(oEventoAdapter, Tipo, Data, Messaggio, IdPazienteAssociato)

            Case "SL"
                ' ------------------------------------------------------------------------------------------
                ' Spostamento anagrafico dell'intera lista di attesa verso nuovo paziente
                ' Se sono qui l'evento SL è stato inserito e l'IdPaziente di tale evento è il nuovo IdPaziente 
                ' con cui bisogna sostituire l'IdPaziente degli eventi appartenenti allo stessa lista attesa
                ' ------------------------------------------------------------------------------------------
                Return RicoveroAzioniListaAttesa_SL(oEventoAdapter, Tipo, Data, Messaggio, IdPazienteAssociato)

        End Select
        '
        ' Ritorna OK
        '
        Return New Risultato(0, "")

    End Function


    Private Function RicoveroAzioniListaAttesa_DL(ByVal oEventoAdapter As EventoAdapter, _
                                    ByVal Tipo As ConnectorV2.TipoMessaggioEvento, _
                                    ByVal Data As DateTime, _
                                    ByVal Messaggio As ConnectorV2.MessaggioEvento, ByVal IdPazienteAssociato As Guid) As Risultato
        ' ------------------------------------------------------------------------------------------
        ' Inserimento del record fittizio con codice LA dove NumeroNosologico=<vero nosologico> ricavato
        ' dagli attributi dell'evento DL e con attributo di nome "CodiceListaAttesa" valorizzato con il valore 
        ' del campo nosologico presente nell'evento DL. Come attributi del record LA metto tutti 
        ' gli attributi anagrafici  presenti in DL + "CodiceListaAttesa"
        ' ATTENZIONE: il numeronsologico potrebbe non essere presente, dipende da quando il connettore legge i dati
        ' se viene inviato l'RL prima che il DL sia stato elaborato il connettore quando legge il DL avrà come attributi
        ' quelli dell'RL, dove manca il nosologico in quanto riapertura. In questo caso la SP nasconde tutti gli LA e 
        ' non aggiorna ne crea il record LA; dopo viene elaborato l'RL 
        ' ------------------------------------------------------------------------------------------
        '
        ' nErrNumber da 60 in su
        '
        Dim nErrNumber As Int16 = 0
        Dim sError As String = Nothing
        Dim oRisultato As Risultato = Nothing
        Dim sIdEsterno As String = Messaggio.Evento.IdEsternoEvento & ""

        If oEventoAdapter.EventiListaAttesaChiusuraLista(sIdEsterno) Then
            Dim sLogMsg As String = "Creato evento fittizio LA (lista attesa)"
            '
            ' Log evento
            '
            LogEvent.WriteInformation(sLogMsg & vbCrLf & _
                            "IdEsterno = '" & sIdEsterno & "'" & vbCrLf & _
                            "Azienda = '" & Messaggio.Evento.AziendaErogante & "'" & vbCrLf & _
                            "Sistema = '" & Messaggio.Evento.SistemaErogante & "'" & vbCrLf & _
                            "Reparto = '" & Messaggio.Evento.RepartoErogante & "'" & vbCrLf & _
                            "DataEvento = '" & Messaggio.Evento.DataEvento & "'" & vbCrLf & _
                            "CodiceListaAttesa = '" & Messaggio.Evento.NumeroNosologico & "'")
        Else
            nErrNumber = 60
            sError = "Errore durante la creazione dell'evento fittizio LA per la lista di attesa: CodiceListaAttesa = '" & Messaggio.Evento.NumeroNosologico & "'"
            oRisultato = New Risultato(nErrNumber, sError)
            Return oRisultato
        End If
        '
        ' Ritorna OK
        '
        Return New Risultato(0, "")
    End Function

    Private Function RicoveroAzioniListaAttesa_RL(ByVal oEventoAdapter As EventoAdapter, _
                                    ByVal Tipo As ConnectorV2.TipoMessaggioEvento, _
                                    ByVal Data As DateTime, _
                                    ByVal Messaggio As ConnectorV2.MessaggioEvento, ByVal IdPazienteAssociato As Guid) As Risultato
        ' ------------------------------------------------------------------------------------------
        ' Riapertura lista di attesa: esecuzione della SP delle azioni che gestisce nuovo codice "RL":
        ' nasconde "DL" ponendo EventiBase.StatoCodice=1 - funziona se gli IdEsterni sono scritti come
        ' ADT_<codiceprenotazione>_<DATA VARIABILE>_<codice evento> (1) in questo modo il nascondere equivale
        ' a cancellare e abbiamo nel db tutte le notifiche
        ' Se l'IdEsterno è scritto come ADT_<codiceprenotazione>_<DATA FISSATA>_<codice evento> (2) non posso
        ' usare StatoCodice=1 perchè dopo RL e successivo DL lo StatoCodice rimarrebbe a 1 (a meno che 
        ' non usi una nuova SP anche per gestire l'evento DL, a quel punto faccio ciò che voglio)
        ' ------------------------------------------------------------------------------------------
        '
        ' nErrNumber da 60 in su
        '
        Dim nErrNumber As Int16 = 0
        Dim sError As String = Nothing
        Dim oRisultato As Risultato = Nothing
        Dim sIdEsterno As String = Messaggio.Evento.IdEsternoEvento & ""

        If oEventoAdapter.EventiListaAttesaRiaperturaLista(sIdEsterno) Then
            Dim sLogMsg As String = "Riapertura lista di attesa"
            '
            ' Log evento
            '
            LogEvent.WriteInformation(sLogMsg & vbCrLf & _
                            "IdEsterno = '" & sIdEsterno & "'" & vbCrLf & _
                            "Azienda = '" & Messaggio.Evento.AziendaErogante & "'" & vbCrLf & _
                            "Sistema = '" & Messaggio.Evento.SistemaErogante & "'" & vbCrLf & _
                            "Reparto = '" & Messaggio.Evento.RepartoErogante & "'" & vbCrLf & _
                            "DataEvento = '" & Messaggio.Evento.DataEvento & "'" & vbCrLf & _
                            "CodiceListaAttesa = '" & Messaggio.Evento.NumeroNosologico & "'")
        Else
            nErrNumber = 61
            sError = "Errore durante la riapertura della lista di attesa: CodiceListaAttesa = '" & Messaggio.Evento.NumeroNosologico & "'"
            oRisultato = New Risultato(nErrNumber, sError)
            Return oRisultato
        End If
        '
        ' Ritorna OK
        '
        Return New Risultato(0, "")
    End Function

    Private Function RicoveroAzioniListaAttesa_SL(ByVal oEventoAdapter As EventoAdapter, _
                                    ByVal Tipo As ConnectorV2.TipoMessaggioEvento, _
                                    ByVal Data As DateTime, _
                                    ByVal Messaggio As ConnectorV2.MessaggioEvento, ByVal IdPazienteAssociato As Guid) As Risultato
        ' ------------------------------------------------------------------------------------------
        ' Spostamento anagrafico dell'intera lista di attesa verso nuovo paziente
        ' Se sono qui l'evento SL è stato inserito e l'IdPaziente di tale evento è il nuovo IdPaziente 
        ' con cui bisogna sostituire l'IdPaziente degli eventi appartenenti allo stessa lista attesa
        ' ------------------------------------------------------------------------------------------
        '
        ' Se sono qui l'evento di spostamento anagrafico SL è stato inserito e l'IdPaziente di tale evento è il nuovo IdPaziente 
        ' con cui bisogna sostituire l'IdPaziente degli eventi appartenenti allo stesso ricovero [Azienda,Nosologico]
        '
        Dim nErrNumber As Int16 = 0
        Dim sError As String = Nothing
        Dim oRisultato As Risultato = Nothing
        Dim sIdEsterno As String = Messaggio.Evento.IdEsternoEvento & ""

        Dim xmlAttributiAnagrafici As Xml.XmlDocument = Nothing
        Dim oAttributiAnagrafici() As ConnectorV2.Attributo = CreateAttributiAnagrafici(Messaggio)
        xmlAttributiAnagrafici = XmlUtil.CreateXdocAttributi(oAttributiAnagrafici)
        Dim sXmlAttributi As String = XmlUtil.GetXmlWriterAttributi(xmlAttributiAnagrafici)
        ' L'xml document non serve più
        xmlAttributiAnagrafici = Nothing

        If oEventoAdapter.EventiListaAttesaSpostamentoAnagrafico(sIdEsterno, sXmlAttributi) Then
            Dim sLogMsg As String = "Spostamento anagrafico lista di attesa."
            '
            ' Log evento
            '
            LogEvent.WriteInformation(sLogMsg & vbCrLf & _
                            "IdEsterno = '" & sIdEsterno & "'" & vbCrLf & _
                            "Azienda = '" & Messaggio.Evento.AziendaErogante & "'" & vbCrLf & _
                            "Sistema = '" & Messaggio.Evento.SistemaErogante & "'" & vbCrLf & _
                            "Reparto = '" & Messaggio.Evento.RepartoErogante & "'" & vbCrLf & _
                            "DataEvento = '" & Messaggio.Evento.DataEvento & "'" & vbCrLf & _
                            "CodiceListaAttesa = '" & Messaggio.Evento.NumeroNosologico & "'" & vbCrLf & _
                            "IdEsternoPaziente = '" & Messaggio.Paziente.IdEsternoPaziente & "'" & vbCrLf & _
                            "IdPaziente = '" & IdPazienteAssociato.ToString())
        Else
            nErrNumber = 62
            sError = "Errore durante lo spostamento anagrafico relativo alla lista di attesa: CodiceListaAttesa = '" & Messaggio.Evento.NumeroNosologico & "'"
            oRisultato = New Risultato(nErrNumber, sError)
            Return oRisultato
        End If
        '
        ' Ritorna OK
        '
        Return New Risultato(0, "")
    End Function



    ''' <summary>
    ''' Restitusce true se l'evento esiste
    ''' </summary>
    ''' <param name="oEventoAdapter"></param>
    ''' <param name="Messaggio"></param>
    ''' <returns>true se l'evento esiste</returns>
    ''' <remarks></remarks>
    Private Function EventoEsiste(ByVal oEventoAdapter As EventoAdapter, ByVal Messaggio As ConnectorV2.MessaggioEvento) As Boolean
        Dim sIdEsterno As String = Messaggio.Evento.IdEsternoEvento & ""
        '
        ' Verifico versione dell'evento tramite data esterna (questo va fatto solo per eventi che non sono azioni)
        '
        Dim dtDataModificaEsterno As Date = oEventoAdapter.EventiContains(sIdEsterno)
        '
        ' L'Evento esiste se data modifica non nulla
        '
        Return (dtDataModificaEsterno <> Nothing)
    End Function

    ''' <summary>
    ''' Serve a discriminare se si tratta di un evento associato ad un RICOVERO o ad una PRENOTAZIONE 
    ''' </summary>
    ''' <param name="sTipoEventoCodice"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function IsEventoRicovero(ByVal sTipoEventoCodice As String) As Boolean
        Select Case sTipoEventoCodice.ToUpper
            Case "A", "T", "D", "M", "X", "R", "E" '-> eventi ADT STANDARD
                Return True
            Case Else
                Return False
        End Select
    End Function


    ''' <summary>
    ''' Verifica AziendaERogante e SistemaErogante per i referti
    ''' </summary>
    ''' <param name="sAziendaErogante"></param>
    ''' <param name="sSistemaErogante"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function VerificaAziendaEroganteSistemaEroganteReferto(ByVal sAziendaErogante As String, ByVal sSistemaErogante As String) As Boolean
        If (Not sAziendaErogante Is Nothing) AndAlso (Not sSistemaErogante Is Nothing) Then
            Dim oDtSistemiEroganti As DataTable = ConfigSingleton.SistemiErogantiLista
            If (Not oDtSistemiEroganti Is Nothing) AndAlso (oDtSistemiEroganti.Rows.Count > 0) Then
                Dim sFilterExpression As String = String.Format("AziendaErogante='{0}' AND SistemaErogante='{1}' AND TipoReferti=1", sAziendaErogante, sSistemaErogante)
                Dim oDataRow() As DataRow = oDtSistemiEroganti.Select(sFilterExpression)
                If oDataRow.Length > 0 Then
                    Return True
                End If
            End If
        End If
        '
        '
        '
        Return False
    End Function


    ''' <summary>
    ''' Verifica AziendaERogante e SistemaErogante per gli eventi di ricovero
    ''' </summary>
    ''' <param name="sAziendaErogante"></param>
    ''' <param name="sSistemaErogante"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function VerificaAziendaEroganteSistemaEroganteEvento(ByVal sAziendaErogante As String, ByVal sSistemaErogante As String) As Boolean
        If (Not sAziendaErogante Is Nothing) AndAlso (Not sSistemaErogante Is Nothing) Then
            Dim oDtSistemiEroganti As DataTable = ConfigSingleton.SistemiErogantiLista
            If (Not oDtSistemiEroganti Is Nothing) AndAlso (oDtSistemiEroganti.Rows.Count > 0) Then
                Dim sFilterExpression As String = String.Format("AziendaErogante='{0}' AND SistemaErogante='{1}' AND TipoRicoveri=1", sAziendaErogante, sSistemaErogante)
                Dim oDataRow() As DataRow = oDtSistemiEroganti.Select(sFilterExpression)
                If oDataRow.Length > 0 Then
                    Return True
                End If
            End If
        End If
        '
        '
        '
        Return False
    End Function

End Class
