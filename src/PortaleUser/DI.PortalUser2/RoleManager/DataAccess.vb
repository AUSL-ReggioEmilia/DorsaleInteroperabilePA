Imports System.ComponentModel
Imports System.Collections.Generic
Imports System
Imports System.Collections
Imports System.Web

Namespace DI.PortalUser2.RoleManager

    ''' <summary>
    ''' Lettura di ruoli e permessi utente
    ''' </summary>
    Public Class DataAccess
        Private Const MINUTI_CACHE As Integer = 5 'durata della cache

        Private mSACConnectionString As String
        Private mSacUser As String
        Private mSacPassword As String

        Private mCurrentUser As String = HttpContext.Current.User.Identity.Name.ToUpper 'ottengo l'utente corrente

        Private Sub New()
            'costruttore senza parametri non accessibile dall'esterno
        End Sub

        ''' <summary>
        ''' PASSARE LA CONNECTION STRING AL SAC
        ''' </summary>
        Public Sub New(SACConnectionString As String, ByVal SacUser As String, ByVal SacPassword As String)
            mSACConnectionString = SACConnectionString
            mSacUser = SacUser
            mSacPassword = SacPassword
        End Sub

        Public Sub New(ByVal SacUser As String, ByVal SacPassword As String)
            mSacUser = SacUser
            mSacPassword = SacPassword
        End Sub

        ''' <summary>
        ''' OTTIENE IL DETTAGLIO DELLE INFORMAZIONI PER L'UTENTE PASSATO.
        ''' </summary>
        ''' <param name="Utente"></param>
        ''' <returns></returns>
        Public Function UtenteOttieniDettaglio(ByVal Utente As String) As Utente
            'DEFINISCO L'OGGETTO DA RESTITUIRE.
            Dim oReturn As New Utente

            Dim cacheKey As String = String.Format("{0}_{1}_{2}", mCurrentUser, "UtenteOttieniDettaglio", Utente).ToUpper

            oReturn = ReadCache(cacheKey)

            If oReturn Is Nothing Then
                'DEFINISCO LA DATATBLE DELL'UTENTE.
                Dim dtUtente As WcfSacRoleManager.UtenteReturn = Nothing

                'CHIAMO IL WS PER OTTENERE IL DETTAGLIO DELL'UTENTE PASSATO.
                Using wcf As New WcfSacRoleManager.RoleManagerClient
                    Call Utility.SetWcfSacCredential(wcf, mSacUser, mSacPassword)

                    dtUtente = wcf.UtenteOttieniPerNomeUtente(Utente)
                End Using

                'TESTO SE LA DATATABLE È VUOTA.
                If dtUtente IsNot Nothing Then
                    'VERIFICO SE IL WS HA RESTITUITO UN ERRORE.
                    If dtUtente.Errore IsNot Nothing Then
                        'SE SI È VERIFICATO UN ERRORE ALLORA ESEGUO UN THROW DEL MESSAGGIO DI ERRORE.
                        Dim sErrore As String = GetWcfError(dtUtente.Errore)
                        Throw New Exception(sErrore)
                    Else
                        'TESTO SE L'UTENTE NON È VUOTO.
                        If dtUtente.Utente IsNot Nothing Then
                            oReturn = New Utente
                            'VALORIZZO L'OGGETTO DA RESTITUIRE.
                            oReturn.IdUtente = New Guid(dtUtente.Utente.Id)
                            oReturn.Utente = dtUtente.Utente.Utente
                            oReturn.Attivo = dtUtente.Utente.Attivo
                            oReturn.Descrizione = dtUtente.Utente.Descrizione
                            oReturn.Cognome = dtUtente.Utente.Cognome
                            oReturn.Nome = dtUtente.Utente.Nome
                            oReturn.CodiceFiscale = dtUtente.Utente.CodiceFiscale
                            oReturn.Matricola = dtUtente.Utente.Matricola
                            oReturn.Email = dtUtente.Utente.Email
                            oReturn.NomeCompleto = String.Format("{0} {1}", oReturn.Cognome, oReturn.Nome)
                        End If
                    End If
                End If

                WriteCache(cacheKey, oReturn, MINUTI_CACHE)
            End If

            'RESTITUISCO L'OGGETTO.
            Return oReturn
        End Function

        ''' <summary>
        ''' OTTIENE IL CONTESTO UTENTE UTILIZZABILE PER GLI UTENTI DEL RUOLO PASSATO
        ''' </summary>
        ''' 
        Public Function ContestoUtenteOttieniPerRuolo(ByVal CodiceRuolo As String, ByVal Utente As String) As WcfSacRoleManager.RuoloDettagliType

            Dim oReturn As WcfSacRoleManager.RuoloDettagliType = Nothing

            Dim cacheKey As String = String.Format("{0}_{1}_{2}_{3}", mCurrentUser, "ContestoUtenteOttieniPerRuolo", CodiceRuolo, Utente).ToUpper
            oReturn = ReadCache(cacheKey)

            If oReturn Is Nothing Then
                Dim dtRuoloReturn As WcfSacRoleManager.RuoloDettagliReturn = Nothing

                'ESEGUO LA CHIAMATA AL WS.
                Using wcf As New WcfSacRoleManager.RoleManagerClient
                    Call Utility.SetWcfSacCredential(wcf, mSacUser, mSacPassword)

                    dtRuoloReturn = wcf.RuoloDettagliOttieni(Utente, CodiceRuolo)
                End Using

                'TESTO SE NON È NOTHING.
                If dtRuoloReturn IsNot Nothing Then
                    If dtRuoloReturn.Errore IsNot Nothing Then
                        Dim sErrore As String = GetWcfError(dtRuoloReturn.Errore)
                        Throw New Exception(sErrore)
                    ElseIf dtRuoloReturn.RuoloDettaglio IsNot Nothing Then
                        oReturn = dtRuoloReturn.RuoloDettaglio
                    ElseIf dtRuoloReturn.RuoloDettaglio Is Nothing Then
                        Utility.TraceWriteLine($"ContestoUtenteOttieniPerRuolo(): Utente={Utente} CodiceRuolo={CodiceRuolo} dtRuoloReturn.RuoloDettaglio=nothing")
                    End If
                Else
                    Utility.TraceWriteLine($"ContestoUtenteOttieniPerRuolo(): Utente={Utente} CodiceRuolo={CodiceRuolo} dtRuoloReturn=nothing")
                End If

                If oReturn Is Nothing Then
                    Utility.TraceWriteLine($"ContestoUtenteOttieniPerRuolo(): Utente={Utente} CodiceRuolo={CodiceRuolo} oReturn=nothing")
                End If

                WriteCache(cacheKey, oReturn, MINUTI_CACHE)
            End If

            'RESTITUISCO L'OGGETTO.
            Return oReturn
        End Function

        ''' <summary>
        ''' OTTIENE LA LISTA DI RUOLI ASSOCIATI ALL'UTENTE PASSATO
        ''' </summary>
        ''' <param name="Utente">Account name</param>
        Public Function RuoliOttieniPerUtente(Utente As String) As List(Of Ruolo)
            'DEFINISCO L'OGGETTO DA RESTITUIRE.
            Dim lReturn As New List(Of Ruolo)

            Dim cacheKey As String = String.Format("{0}_{1}_{2}", mCurrentUser, "RuoliOttieniPerUtente", Utente).ToUpper
            lReturn = ReadCache(cacheKey)

            If lReturn Is Nothing OrElse lReturn.Count = 0 Then
                lReturn = New List(Of Ruolo)

                'DEFINISCO LA DATATABLE.
                Dim dtRuoli As WcfSacRoleManager.RuoliReturn = Nothing

                'ESEGUO LA CHIAMATA AL WS.
                Using wcf As New WcfSacRoleManager.RoleManagerClient
                    Call Utility.SetWcfSacCredential(wcf, mSacUser, mSacPassword)

                    dtRuoli = wcf.RuoliOttieniPerUtente(Utente)
                End Using

                'TESTO SE LA DATATABLE È VUOTA.
                If dtRuoli IsNot Nothing Then
                    'VERIFICO SE IL WS HA RESTITUITO UN ERRORE.
                    If dtRuoli.Errore IsNot Nothing Then
                        'SE SI È VERIFICATO UN ERRORE ALLORA ESEGUO UN THROW DEL MESSAGGIO DI ERRORE.
                        Dim sErrore As String = GetWcfError(dtRuoli.Errore)
                        Throw New Exception(sErrore)
                    Else
                        'TESTO SE L'UTENTE NON È VUOTO.
                        If dtRuoli.Ruoli IsNot Nothing AndAlso dtRuoli.Ruoli.Count > 0 Then
                            For Each oRuolo As WcfSacRoleManager.RuoloType In dtRuoli.Ruoli
                                'CREO UN OGGETTO DI TIPO RUOLO E LO VALORIZZO.
                                Dim ruolo As New Ruolo
                                ruolo.Codice = oRuolo.Codice
                                ruolo.Descrizione = oRuolo.Descrizione

                                'AGGIUNGO ALLA LISTA IL RUOLO CORRENTE.
                                lReturn.Add(ruolo)
                            Next
                        End If
                    End If
                End If

                WriteCache(cacheKey, lReturn, MINUTI_CACHE)
            End If
            'RESTITUISCO LA LISTA DEI RUOLI.
            Return lReturn
        End Function

        ''' <summary>
        ''' OTTIENE LA LISTA DEGLI ACCESSI (ATTRIBUTI CALCOLATI) PER IL RUOLO PASSATO
        ''' </summary>
        ''' <param name="CodiceRuolo">Codice Ruolo</param>
        Public Function AccessiOttienePerCodiceRuolo(CodiceRuolo As String) As List(Of String)
            'DEFINISCO L'OGGETTO DA RESTITUIRE.
            Dim lReturn As New List(Of String)

            Dim cacheKey As String = String.Format("{0}_{1}_{2}", mCurrentUser, "AccessiOttienePerCodiceRuolo", CodiceRuolo).ToUpper
            lReturn = ReadCache(cacheKey)

            If lReturn Is Nothing OrElse lReturn.Count = 0 Then

                lReturn = New List(Of String)

                'DEFINISCO LA DATA TABLE.
                Dim dtAccessi As WcfSacRoleManager.AccessiReturn = Nothing

                'CHIAMO IL WS PER OTTENERE LA LISTA DEGLI ACCESSI IN BASE AL CODICE DEL RUOLO PASSATO.
                Using wcf As New WcfSacRoleManager.RoleManagerClient
                    Call Utility.SetWcfSacCredential(wcf, mSacUser, mSacPassword)

                    dtAccessi = wcf.AccessiOttieniPerRuolo(CodiceRuolo)
                End Using

                'TESTO SE LA DATATABLE È VUOTA.
                If dtAccessi IsNot Nothing Then
                    'VERIFICO SE IL WS HA RESTITUITO UN ERRORE.
                    If dtAccessi.Errore IsNot Nothing Then
                        'SE SI È VERIFICATO UN ERRORE ALLORA ESEGUO UN THROW DEL MESSAGGIO DI ERRORE.
                        Dim sErrore As String = GetWcfError(dtAccessi.Errore)
                        Throw New Exception(sErrore)
                    Else
                        'TESTO SE LA LISTA DEGLI ACCESSI È VALORIZZATA.
                        If dtAccessi.Accessi IsNot Nothing AndAlso dtAccessi.Accessi.Count > 0 Then
                            'CICLO TUTTLA LA LISTA DEGLI ACCESSI.
                            For Each oAccesso As WcfSacRoleManager.AccessoType In dtAccessi.Accessi
                                'AGGIUNGO ALLA LISTA DI RITORNO IL CODICE DELL'ACCESSO.
                                lReturn.Add(oAccesso.Codice)
                            Next
                        End If
                    End If
                End If
                WriteCache(cacheKey, lReturn, MINUTI_CACHE)
            End If

            '
            'RESTITUISCO LA LISTA.
            '
            Return lReturn
        End Function


        ''' <summary>
        ''' Ottiene la lista di tutti i regimi.
        ''' </summary>
        Public Function RegimiListaOttieni() As List(Of RoleManager.Regime)

            Dim lReturn As New List(Of RoleManager.Regime)

            Dim cacheKey As String = String.Format("{0}_{1}", mCurrentUser, "RegimiListaOttieni").ToUpper
            lReturn = ReadCache(cacheKey)

            If lReturn Is Nothing OrElse lReturn.Count = 0 Then

                lReturn = New List(Of Regime)

                Using da As New RegimiOttieniPerUnitaOperativaTableAdapter_Custom(mSACConnectionString)
                    Dim dt = da.GetData(Nothing, Nothing)
                    For Each dr In dt
                        Dim itm As New RoleManager.Regime With {.Codice = dr.Codice, .Descrizione = dr.Descrizione}
                        lReturn.Add(itm)
                    Next
                End Using
                WriteCache(cacheKey, lReturn, MINUTI_CACHE)
            End If

            Return lReturn
        End Function

        ''' <summary>
        ''' Restituisce un messaggio di errore composto dal codice e dalla descrizione.
        ''' </summary>
        ''' <param name="oErrore"></param>
        ''' <returns></returns>
        Private Function GetWcfError(ByVal oErrore As WcfSacRoleManager.ErroreType) As String
            Dim sReturn As String = String.Empty

            If Not oErrore Is Nothing Then
                sReturn = String.Format("CodiceErrore: {0}; DescrizioneErrore: {1}", oErrore.Codice, oErrore.Descrizione)
            End If

            Return sReturn
        End Function

#Region "Gestione Cache"
        Private Sub WriteCache(ByVal sKey As String, ByVal oValue As Object, iMinutiDurata As Integer)
            Dim oHttpContextCurrent = HttpContext.Current
            If iMinutiDurata = 0 Then
                oHttpContextCurrent.Cache.Insert(sKey & "_" & mCurrentUser, oValue, Nothing, Caching.Cache.NoAbsoluteExpiration, New TimeSpan(0, 60, 0))
            Else
                oHttpContextCurrent.Cache.Insert(sKey & "_" & mCurrentUser, oValue, Nothing, DateTime.UtcNow.AddMinutes(iMinutiDurata), Caching.Cache.NoSlidingExpiration, Caching.CacheItemPriority.Normal, Nothing)
            End If
        End Sub

        ''' <summary>
        ''' Legge dall'oggetto CACHE
        ''' </summary>
        ''' <param name="sKey"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Private Function ReadCache(ByVal sKey As String) As Object

            Return HttpContext.Current.Cache(sKey & "_" & mCurrentUser)

        End Function
#End Region

    End Class

End Namespace

