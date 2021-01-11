Imports DI.Wcf.Instrumentation
Imports Dwh.DataAccess.Wcf.Types.NoteAnamnestiche
Imports Microsoft.ApplicationInsights.Extensibility
Imports System.Text

<ApplicationInsightsBehavior()>
<ServiceBehavior(Namespace:="http://schemas.progel.it/BT/DWH/DataAccess/NoteAnamnestiche/1.0")>
Public Class NoteAnamnestiche
    Implements INoteAnamnestiche

    Shared Sub New()

        ' ##########################################################################################
        ' DIVERSAMNETE DA public Service(), static Service() sarà invocata solo 1 volta alla prima invocazione
        ' e NON per tutte le istanze della CLASSE
        ' ##########################################################################################
        '
        ' Only called first time it's used.
        ' Initialize Application Insight aggiungendo un custom Initializer se non c'è già

        Dim Initializers As IList(Of ITelemetryInitializer) = TelemetryConfiguration.Active.TelemetryInitializers
        Dim bDone As Boolean = Initializers.Where(Function(i) i.[GetType]() = GetType(TelemetryInitializer)).Any()

        If Not bDone Then
            Dim sInstrumentationKey As String = My.Settings.InstrumentationKey
            TelemetryConfiguration.Active.TelemetryInitializers.Add(New TelemetryInitializer())
        End If
    End Sub

    Public Function Processa(Par As NotaAnamnesticaParameter) As NotaAnamnesticaReturn Implements INoteAnamnestiche.Processa
        Dim oNotaAnamnesticaReturn As New NotaAnamnesticaReturn
        Dim bRetNotificaByOrch As Boolean = False
        Try
            '
            ' Controllo parametri
            '
            If Par Is Nothing Then
                Throw New CustomException("Parametro NotaAnamnesticaParameter vuoto.", ErrorCodes.ParametroMancante)
            End If
            If Par.NotaAnamnestica Is Nothing Then
                Throw New CustomException("Parametro NotaAnamnestica vuoto", ErrorCodes.ParametroMancante)
            End If
            If Par.NotaAnamnestica.Paziente Is Nothing Then
                Throw New CustomException("Parametro NotaAnamnestica.Paziente vuoto", ErrorCodes.ParametroMancante)
            End If
            '
            ' Verifico i valori di "Azione"
            '
            Select Case Par.Azione
                Case AZIONE_INSERIMENTO, AZIONE_AGGIORNAMENTO, AZIONE_CANCELLAZIONE ' 0=Inserimento, 1=Aggiornamento, 2=CANCELLAZIONE 
                    'OK: proseguo
                Case Else
                    Dim sErrMsg As String = String.Concat(String.Format("Parametro Azione={0} non valido!", Par.Azione), vbCrLf, Par.NotaAnamnestica.Descrizione)
                    Throw New CustomException(sErrMsg, ErrorCodes.ParametroNonValido)
            End Select
            '
            ' Controllo presenza AziendaErogante della nota anamnestica e che sia azienda giusta
            '
            If String.IsNullOrEmpty(Par.NotaAnamnestica.AziendaErogante.Trim) Then
                Dim sErrMsg As String = String.Concat("Parametro AziendaErogante vuoto.", vbCrLf, Par.NotaAnamnestica.Descrizione)
                Throw New CustomException(sErrMsg, ErrorCodes.ParametroNonValido)
            End If
            If Not (Par.NotaAnamnestica.AziendaErogante.ToUpper = "ASMN" OrElse Par.NotaAnamnestica.AziendaErogante.ToUpper = "AUSL") Then
                Dim sErrMsg As String = String.Concat("Parametro AziendaErogante non valido. I valori possibili sono ASMN e AUSL.", vbCrLf, Par.NotaAnamnestica.Descrizione)
                Throw New CustomException(sErrMsg, ErrorCodes.ParametroNonValido)
            End If
            '
            ' Controllo presenza SistemaErogante
            '
            If String.IsNullOrEmpty(Par.NotaAnamnestica.SistemaErogante.Trim) Then
                Dim sErrMsg As String = String.Concat("Parametro SistemaErogante vuoto.", vbCrLf, Par.NotaAnamnestica.Descrizione)
                Throw New CustomException(sErrMsg, ErrorCodes.ParametroNonValido)
            End If
            '
            ' Controllo presenza IdEsterno della nota anamnestica
            '
            If String.IsNullOrEmpty(Par.NotaAnamnestica.IdEsterno) Then
                Dim sErrMsg As String = String.Concat("Parametro IdEsterno vuoto.", vbCrLf, Par.NotaAnamnestica.Descrizione)
                Throw New CustomException(sErrMsg, ErrorCodes.ParametroNonValido)
            End If
            '
            ' Eseguo l'inserimento/aggiornamento/cancellazione (con eventuali retry)
            '
            oNotaAnamnesticaReturn = ProcessaNotaAnamnestica(Par)

        Catch ex As CustomException
            oNotaAnamnesticaReturn.Errore = New ErroreType
            oNotaAnamnesticaReturn.Errore.Codice = ex.ErrorCode
            oNotaAnamnesticaReturn.Errore.Descrizione = ex.Message
            Log.WriteError(ex)

        Catch ex As Exception
            oNotaAnamnesticaReturn.Errore = New ErroreType
            oNotaAnamnesticaReturn.Errore.Codice = ErrorCodes.ErroreGenerico.ToString
            oNotaAnamnesticaReturn.Errore.Descrizione = ex.Message
            Log.WriteError(ex)

        End Try
        '
        ' Restituisco il dato di ritorno
        '
        Return oNotaAnamnesticaReturn

    End Function


    ''' <summary>
    ''' La funzione processa l'inserimento/update/cancellazione della nota anamnestica (esegue retry in seguito a errori di timeout/deadlock/connessione)
    ''' </summary>
    ''' <param name="Par"></param>
    ''' <returns></returns>
    Private Function ProcessaNotaAnamnestica(Par As NotaAnamnesticaParameter) As NotaAnamnesticaReturn
        Dim oNotaAnamnesticaReturn As New NotaAnamnesticaReturn
        '
        '
        '
        Dim oNotaAnamensticaBuilder As New NotaAnamnesticaBuilder(Par.NotaAnamnestica)
        '
        ' Aggiungo se manca il prefisso con l'azienda erogante: modifico il valore presente nell'oggetto NotaAnamnestica
        '
        oNotaAnamensticaBuilder.AutoPrefixIdEsterno()
        '
        ' Aggiunge agli attributi della NotaAnamnestica i dati anagrafici del paziente (solo se non sono in cancellazione)
        '
        If Par.Azione <> AZIONE_CANCELLAZIONE Then
            oNotaAnamensticaBuilder.AggiungiAttributiPaziente()
        End If
        '
        ' Tentativi su errori controllati (timeout ecc...)
        '
        For iRetry As Integer = 0 To My.Settings.RetryCount
            Try
                If iRetry > 0 Then
                    '
                    ' Log dal secondo tentativo in poi
                    '
                    Dim sMsg As String = String.Concat(String.Format("Riprova numero {0} invio messaggio!", iRetry), vbCrLf, Par.NotaAnamnestica.Descrizione)
                    Log.TraceWriteLine(sMsg, TraceLevel.Info.ToString, TraceLevel.Info.ToString)
                End If
                '
                ' Gestione della concorrenza multithread
                '
                SyncLock ConcurrentDictionary.GetLockobject(oNotaAnamensticaBuilder.NotaAnamnestica.IdEsterno)
                    Select Case Par.Azione
                        Case AZIONE_INSERIMENTO, AZIONE_AGGIORNAMENTO ' 0=Inserimento, 1=Aggiornamento
                            '
                            ' SAC : RICERCA / INSERIMENTO DELL'ANAGRAFICA PAZIENTE MEDIANTE STORED PROCEDURE
                            '
                            oNotaAnamensticaBuilder.IdPazienteSAC = SacHelper.PazientiOutputCercaAggancioPaziente(oNotaAnamensticaBuilder.NotaAnamnestica)
                            '
                            ' DWH : Chiamata alla SP di inserimento/modifica (sotto transazione) e costruzione del messaggio per l'orchestrazione/coda di output
                            '
                            oNotaAnamnesticaReturn = DwhHelper.AggiungiOrAggiorna(Par.Azione, Par.DataModificaEsterno, oNotaAnamensticaBuilder.NotaAnamnestica, oNotaAnamensticaBuilder.IdPazienteSAC)

                        Case AZIONE_CANCELLAZIONE '2=CANCELLAZIONE
                            '
                            '  DWH: Chiamata alla SP di cancellazione della nota anamnestica e costruzione del messaggio per l'orchestrazione/coda di output
                            ' 
                            oNotaAnamnesticaReturn = DwhHelper.Rimuovi(oNotaAnamensticaBuilder.NotaAnamnestica, Par.DataModificaEsterno)
                    End Select

                End SyncLock
                '
                ' Se processato esce dal loop
                '
                Exit For

            Catch ex As CustomException
                ' Le CustomException interrompono il ciclo di retry e passano fuori
                Throw ex

            Catch ex As Exception
                '
                ' Controlla il tipo di errore
                '
                Dim sError As String = ex.Message.ToLower
                Dim sMetodo = "ProcessaNotaAnamnestica"
                Dim sMsgErr As String = String.Concat(String.Format("Errore in '{0}'.", sMetodo), vbCrLf, Par.NotaAnamnestica.Descrizione)
                Log.WriteError(ex, sMsgErr)

                If sError.Contains("timeout") Then
                    '
                    ' Timeout
                    '
                    If iRetry = My.Settings.RetryCount Then
                        Dim sMsgErrTimeout As String = String.Concat(String.Format("Errore di timeout in '{0}'.", sMetodo), vbCrLf, Par.NotaAnamnestica.Descrizione)
                        Throw New CustomException(sMsgErrTimeout, ErrorCodes.Timeout)
                    Else
                        '
                        ' Attesa WaitAfterTimeout
                        '
                        If My.Settings.WaitAfterTimeout > 0 Then
                            Threading.Thread.Sleep(My.Settings.WaitAfterTimeout)
                        End If
                    End If

                ElseIf sError.Contains("deadlocked") Then
                    '
                    ' Deadlock
                    '
                    If iRetry = My.Settings.RetryCount Then
                        Dim sMsgErrDeadLock As String = String.Concat(String.Format("Errore di deadlock in '{0}'.", sMetodo), vbCrLf, Par.NotaAnamnestica.Descrizione)
                        Throw New CustomException(sMsgErrDeadLock, ErrorCodes.Deadlocked)
                    Else
                        '
                        ' Attesa WaitAfterDeadlocked
                        '
                        If My.Settings.WaitAfterDeadlocked > 0 Then
                            Threading.Thread.Sleep(My.Settings.WaitAfterDeadlocked)
                        End If
                    End If

                ElseIf sError.Contains("was not found or was not accessible") OrElse sError.Contains(ERRORE_APERTURA_CONNESSIONE.ToLower) Then
                    '
                    ' Network error/errore di connessione
                    '
                    If iRetry = My.Settings.RetryCount Then
                        Dim sMsgErrRete As String = String.Concat(String.Format("Errore di rete/connessione in '{0}'.", sMetodo), vbCrLf, Par.NotaAnamnestica.Descrizione)
                        Throw New CustomException(sMsgErrRete, ErrorCodes.NetError)
                    Else
                        '
                        ' Attesa WaitAfterNetError
                        '
                        If My.Settings.WaitAfterNetError > 0 Then
                            Threading.Thread.Sleep(My.Settings.WaitAfterNetError)
                        End If
                    End If
                Else
                    '
                    ' Altri errori: interrompo il ciclo di retry
                    '
                    Throw ex
                End If
            Finally
                '
                ' Rimuovo il LOCKOBJECT dal dizionario
                '
                If Par IsNot Nothing AndAlso Par.NotaAnamnestica IsNot Nothing AndAlso Par.NotaAnamnestica.IdEsterno IsNot Nothing Then
                    ConcurrentDictionary.Remove(Par.NotaAnamnestica.IdEsterno)
                End If
            End Try
        Next
        '
        '
        '
        Return oNotaAnamnesticaReturn
    End Function
End Class
