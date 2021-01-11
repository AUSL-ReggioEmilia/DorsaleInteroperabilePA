Imports Sac.Msg.Wcf
Imports Sac.Msg.Wcf.sac.bt.consenso.schema.dataaccess
Imports Asmn.Sac.Msg.DataAccess
Imports Microsoft.ApplicationInsights.Extensibility
Imports DI.Wcf.Instrumentation

<ApplicationInsightsBehavior()>
<ServiceBehavior(Namespace:="http://SAC.BT.Consenso.Schema.DataAccess/v1.0")>
Public Class Consensi
    Implements IConsensi

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

    Public Sub New()
        Try
            SyncLock gConfigSingleton_SynckLockObject
                ConfigSingleton.ConnectionString = My.Settings.SAC_ConnectionString
                ConfigSingleton.LogSource = My.Settings.LogSource
                ConfigSingleton.LogError = My.Settings.LogError
                ConfigSingleton.LogWarning = My.Settings.LogWarning
                ConfigSingleton.LogInformation = My.Settings.LogInformation
                ConfigSingleton.DatabaseIsolationLevel = Utility.GetIsolationLevel()
            End SyncLock
        Catch ex As Exception
            LogEvent.WriteError(ex, "Errore in Sac.Msg.Wcf.Consensi.New() durante la configurazione della classe 'ConfigSingleton'.")
        End Try
    End Sub

    Public Function ProcessaMessaggio(ByVal Tipo As MessaggioConsensoTipoEnum, ByVal Messaggio As MessaggioConsensoParameter) As MessaggioConsensoReturn Implements IConsensi.ProcessaMessaggio
        Dim oReturn As New MessaggioConsensoReturn
        Const NOME_METODO As String = "ProcessaMessaggio"
        Try
            '
            ' Controlli su validità del messaggio
            '
            If Messaggio Is Nothing Then
                Throw New CustomException("Il Messaggio è vuoto!", ErrorCodes.ParametroMancante)
            End If
            If Messaggio.Utente Is Nothing OrElse String.IsNullOrEmpty(Messaggio.Utente) Then
                Throw New CustomException("Il campo Messaggio.Utente è vuoto!", ErrorCodes.ParametroMancante)
            End If
            If Messaggio.Consenso Is Nothing Then
                Throw New CustomException("Il Consenso è vuoto!", ErrorCodes.ParametroMancante)
            End If
            If String.IsNullOrEmpty(Messaggio.Consenso.PazienteProvenienza) Then
                Throw New CustomException("Il campo Consenso.PazienteProvenienza è vuoto", ErrorCodes.ParametroMancante)
            End If
            If String.IsNullOrEmpty(Messaggio.Consenso.PazienteIdProvenienza) Then
                Throw New CustomException("Il campo Consenso.PazienteIdProvenienza è vuoto", ErrorCodes.ParametroMancante)
            End If
            If String.IsNullOrEmpty(Messaggio.Consenso.PazienteCodiceFiscale) Then
                Throw New CustomException("Il campo Consenso.PazienteCodiceFiscale è vuoto", ErrorCodes.ParametroMancante)
            End If
            '
            ' Se vuoto il campo Messaggio.Consenso.Id lo valorizzo con un GUID (-->diventerà l'IdProvenienza del consenso)
            '
            If String.IsNullOrEmpty(Messaggio.Consenso.Id) Then
                Messaggio.Consenso.Id = Guid.NewGuid().ToString()
            End If
            '
            ' Loop di retry
            '
            For iRetry As Integer = 0 To My.Settings.RetryCount
                Try
                    '
                    ' Processo il messaggio chiamando il metodo della DLL (non c'è la risposta)
                    '
                    Call _ProcessaMessaggio(Tipo, Messaggio)
                    '
                    ' Se nessun errore allora il messaggio è stato processato: esce dal loop
                    '
                    Exit For
                Catch ex As CustomException
                    LogEvent.WriteError(ex, String.Empty)
                    ' Le CustomException interrompono il ciclo di retry e passano fuori
                    Throw ex

                Catch ex As Exception
                    ' Controlla il tipo di errore
                    Dim sError As String = ex.Message.ToLower
                    If sError.Contains("timeout") Then
                        ' Timeout
                        If iRetry = My.Settings.RetryCount Then
                            Dim sMsgErr As String = String.Format("Errore di timeout '{0}' - Consenso {1}-{2}.", NOME_METODO, Messaggio.Utente, Messaggio.Consenso.Id)
                            Throw New CustomException(LogEvent.FormatException(ex, sMsgErr), ErrorCodes.Timeout)
                        Else
                            ' Attesa WaitAfterTimeout
                            If My.Settings.WaitAfterTimeout > 0 Then Threading.Thread.Sleep(My.Settings.WaitAfterTimeout)
                        End If

                    ElseIf sError.Contains("deadlocked") Then
                        ' Deadlock
                        If iRetry = My.Settings.RetryCount Then
                            Dim sMsgErr As String = String.Format("Errore di deadlock in '{0}' - Consenso {1}-{2}.", NOME_METODO, Messaggio.Utente, Messaggio.Consenso.Id)
                            Throw New CustomException(LogEvent.FormatException(ex, sMsgErr), ErrorCodes.Deadlocked)
                        Else
                            ' Attesa WaitAfterDeadlocked
                            If My.Settings.WaitAfterDeadlocked > 0 Then Threading.Thread.Sleep(My.Settings.WaitAfterDeadlocked)
                        End If

                    ElseIf sError.Contains("was not found or was not accessible") OrElse sError.Contains(ERRORE_APERTURA_CONNESSIONE.ToLower) Then
                        ' Network error/errore di connessione
                        If iRetry = My.Settings.RetryCount Then
                            Dim sMsgErr As String = String.Format("Errore di rete/connessione '{0}' - Consenso {1}-{2}.", NOME_METODO, Messaggio.Utente, Messaggio.Consenso.Id)
                            Throw New CustomException(LogEvent.FormatException(ex, sMsgErr), ErrorCodes.NetError)
                        Else
                            ' Attesa WaitAfterNetError
                            If My.Settings.WaitAfterNetError > 0 Then Threading.Thread.Sleep(My.Settings.WaitAfterNetError)
                        End If

                    Else
                        Dim sMsgErr As String = String.Format("Errore in '{0}' - Consenso {1}-{2}.", NOME_METODO, Messaggio.Utente, Messaggio.Consenso.Id)
                        sMsgErr = LogEvent.FormatException(ex, sMsgErr)
                        ' Altri errori: interrompo il ciclo di retry
                        Throw New Exception(sMsgErr)

                    End If

                End Try
            Next


        Catch ex As CustomException
            LogEvent.WriteError(ex, String.Empty)
            oReturn.Errore = New ErroreType
            oReturn.Errore.Codice = ex.ErrorCode
            oReturn.Errore.Descrizione = ex.Message

        Catch ex As Exception

            LogEvent.WriteError(ex, String.Empty)
            oReturn.Errore = New ErroreType
            oReturn.Errore.Codice = ErrorCodes.ErroreGenerico.ToString
            oReturn.Errore.Descrizione = ex.Message
        End Try
        '
        ' Restituzione all'orchestrazione
        '
        Return oReturn

    End Function

    Private Sub _ProcessaMessaggio(ByVal Tipo As MessaggioConsensoTipoEnum, ByVal Messaggio As MessaggioConsensoParameter)
        Dim oRet As New MessaggioConsensoReturn
        Dim oMessaggioConsenso As Asmn.Sac.Msg.DataAccess.MessaggioConsenso = Nothing
        Dim oMessaggioTipo As Asmn.Sac.Msg.DataAccess.Consensi.MessaggioTipo
        Dim oConsensi As New Asmn.Sac.Msg.DataAccess.Consensi
        '
        ' Determino la stringa per il synclock
        '
        Dim sLockObject As String = Replace(Messaggio.Utente, "\", "") & "_" & Messaggio.Consenso.Id
        Try
            '
            ' Traslo il Tipo di messaggio in quello accettato dalla DLL
            '
            Select Case Tipo
                Case MessaggioConsensoTipoEnum.Insert
                    oMessaggioTipo = Asmn.Sac.Msg.DataAccess.Consensi.MessaggioTipo.Insert
                Case Else
                    Throw New CustomException("Il parametro Tipo non valorizzato: valore permesso 'Insert'.", ErrorCodes.ParametroNonValido)
            End Select
            '
            ' Determino il oMessaggioConsenso
            '
            oMessaggioConsenso = TypeExtension.ToMessaggioConsenso(Messaggio)
            '
            '
            ' Invoco il metodo di inserimento consenso della DLL (nessuna risposta)
            ' Gestione della concorrenza multithread
            '
            SyncLock ConcurrentDictionary.GetLockobject(sLockObject)
                oConsensi.ProcessaMessaggio(oMessaggioTipo, oMessaggioConsenso)
            End SyncLock

        Finally
            ConcurrentDictionary.Remove(sLockObject)
        End Try
    End Sub
End Class
