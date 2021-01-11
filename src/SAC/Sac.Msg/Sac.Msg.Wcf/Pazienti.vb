Imports Sac.Msg.Wcf
Imports Sac.Msg.Wcf.sac.bt.paziente.schema.dataaccess
Imports Asmn.Sac.Msg.DataAccess
Imports DI.Wcf.Instrumentation
Imports Microsoft.ApplicationInsights.Extensibility

<ApplicationInsightsBehavior()>
<ServiceBehavior(Namespace:="http://SAC.BT.Paziente.Schema.DataAccess/v1.0")>
Public Class Pazienti
    Implements IPazienti
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
            LogEvent.WriteError(ex, "Errore in Sac.Msg.Wcf.Pazienti.New() durante la configurazione della classe 'ConfigSingleton'.")
            Throw
        End Try

    End Sub

    Public Function ProcessaMessaggio(ByVal Tipo As MessaggioPazienteTipoEnum,
                                              ByVal Messaggio As MessaggioPazienteParameter) As MessaggioPazienteReturn Implements IPazienti.ProcessaMessaggio

        Dim oReturn As New MessaggioPazienteReturn
        Const NOME_METODO As String = "ProcessaMessaggio"
        Try
            '
            ' Eseguo qualche controllo sulla validità del messaggio
            '
            If Messaggio.Utente Is Nothing OrElse String.IsNullOrEmpty(Messaggio.Utente) Then
                Throw New CustomException("Il campo Messaggio.Utente è vuoto!", ErrorCodes.ParametroMancante)
            End If
            If (Messaggio.Paziente Is Nothing) OrElse (Messaggio.Paziente.Id Is Nothing) OrElse (Messaggio.Paziente.Id.Length = 0) Then
                Throw New CustomException("Il campo Paziente.Id è vuoto!", ErrorCodes.ParametroMancante)
            End If
            If Tipo = MessaggioPazienteTipoEnum.Merge Then
                If (Messaggio.Fusione Is Nothing) OrElse String.IsNullOrEmpty(Messaggio.Fusione.Id) Then
                    Throw New CustomException("Il campo Fusione.Id è vuoto!", ErrorCodes.ParametroMancante)
                End If
            End If
            If String.IsNullOrEmpty(Messaggio.Paziente.CodiceFiscale) Then
                Throw New CustomException("Il campo Paziente.CodiceFiscale è vuoto!", ErrorCodes.ParametroMancante)
            End If

            '
            ' Loop di retry
            '
            For iRetry As Integer = 0 To My.Settings.RetryCount
                Try
                    '
                    ' Processo il messaggio chiamando il metodo della DLL
                    '
                    oReturn = _ProcessaMessaggio(Tipo, Messaggio)
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
                            Dim sMsgErr As String = String.Format("Errore di timeout '{0}' - Anagrafica {1}-{2}.", NOME_METODO, Messaggio.Utente, Messaggio.Paziente.Id)
                            Throw New CustomException(LogEvent.FormatException(ex, sMsgErr), ErrorCodes.Timeout)
                        Else
                            ' Attesa WaitAfterTimeout
                            If My.Settings.WaitAfterTimeout > 0 Then Threading.Thread.Sleep(My.Settings.WaitAfterTimeout)
                        End If

                    ElseIf sError.Contains("deadlocked") Then
                        ' Deadlock
                        If iRetry = My.Settings.RetryCount Then
                            Dim sMsgErr As String = String.Format("Errore di deadlock in '{0}' - Anagrafica {1}-{2}.", NOME_METODO, Messaggio.Utente, Messaggio.Paziente.Id)
                            Throw New CustomException(LogEvent.FormatException(ex, sMsgErr), ErrorCodes.Deadlocked)
                        Else
                            ' Attesa WaitAfterDeadlocked
                            If My.Settings.WaitAfterDeadlocked > 0 Then Threading.Thread.Sleep(My.Settings.WaitAfterDeadlocked)
                        End If

                    ElseIf sError.Contains("was not found or was not accessible") OrElse sError.Contains(ERRORE_APERTURA_CONNESSIONE.ToLower) Then
                        ' Network error/errore di connessione
                        If iRetry = My.Settings.RetryCount Then
                            Dim sMsgErr As String = String.Format("Errore di rete/connessione '{0}' - Anagrafica {1}-{2}.", NOME_METODO, Messaggio.Utente, Messaggio.Paziente.Id)
                            Throw New CustomException(LogEvent.FormatException(ex, sMsgErr), ErrorCodes.NetError)
                        Else
                            ' Attesa WaitAfterNetError
                            If My.Settings.WaitAfterNetError > 0 Then Threading.Thread.Sleep(My.Settings.WaitAfterNetError)
                        End If

                    Else
                        Dim sMsgErr As String = String.Format("Errore in '{0}' - Anagrafica {1}-{2}.", NOME_METODO, Messaggio.Utente, Messaggio.Paziente.Id)
                        sMsgErr = LogEvent.FormatException(ex, sMsgErr)
                        ' Altri errori: interrompo il ciclo di retry
                        Throw New Exception(sMsgErr)

                    End If

                End Try
            Next
        Catch ex As CustomException
            'Queste eccezioni sono generate all'interno di Sac.Msg.Wcf 
            LogEvent.WriteError(ex, String.Empty)
            oReturn.Errore = New ErroreType
            oReturn.Errore.Codice = ex.ErrorCode
            oReturn.Errore.Descrizione = ex.Message

        Catch ex As Exception
            'Queste eccezioni sono generate all'interno di Sac.Msg.Wcf WCF o all'interno di Sac.Msg.DataAccess
            Dim sExMessageToUpper As String = ex.Message.ToUpper
            If sExMessageToUpper.Contains("SINONIMO") OrElse sExMessageToUpper.Contains("DATA SEQUENZA") Then
                'MODIFICA ETTORE 2020-09-11: in questo caso non faccio NULLA, non genero più la warning in event log
                'LogEvent.WriteWarning(ex.Message)
            Else
                LogEvent.WriteError(ex, String.Empty)
            End If

            oReturn.Errore = New ErroreType
            oReturn.Errore.Codice = ErrorCodes.ErroreGenerico.ToString
            oReturn.Errore.Descrizione = ex.Message

        End Try
        '
        ' Restituzione all'orchestrazione
        '
        Return oReturn
    End Function



    Private Function _ProcessaMessaggio(ByVal Tipo As MessaggioPazienteTipoEnum,
                                              ByVal Messaggio As MessaggioPazienteParameter) As MessaggioPazienteReturn
        Dim oReturn As New MessaggioPazienteReturn
        Dim oRispostaPaziente As Asmn.Sac.Msg.DataAccess.RispostaPaziente = Nothing
        Dim oMessaggioTipo As Asmn.Sac.Msg.DataAccess.Pazienti.MessaggioTipo = Asmn.Sac.Msg.DataAccess.Pazienti.MessaggioTipo.Modify
        Dim oMessaggioPaziente As Asmn.Sac.Msg.DataAccess.MessaggioPaziente = Nothing
        Dim sLockObject As String = Replace(Messaggio.Utente, "\", "") & "_" & Messaggio.Paziente.Id
        Try
            '
            ' Converto WCF.MessaggioPazienteParameter in DLL.MessaggioPaziente
            '
            Dim oPaziente As New Asmn.Sac.Msg.DataAccess.MessaggioPaziente
            Dim oPaz As New Asmn.Sac.Msg.DataAccess.Pazienti
            '
            ' Determino il TipoMessaggio 
            '
            Select Case Tipo
                Case MessaggioPazienteTipoEnum.Modify
                    oMessaggioTipo = Asmn.Sac.Msg.DataAccess.Pazienti.MessaggioTipo.Modify
                Case MessaggioPazienteTipoEnum.Merge
                    oMessaggioTipo = Asmn.Sac.Msg.DataAccess.Pazienti.MessaggioTipo.Merge
                Case MessaggioPazienteTipoEnum.Delete
                    oMessaggioTipo = Asmn.Sac.Msg.DataAccess.Pazienti.MessaggioTipo.Delete
                Case Else
                    Throw New CustomException("Il parametro 'Tipo' non è valorizzato con uno dei valori validi (0=Modify,1=Delete,2=Merge).", ErrorCodes.ParametroNonValido)
            End Select
            '
            ' MODIFICA ETTORE 2019-01-15: Transcodifica del codice terminazione
            ' Se Il codice terminazione è presente in Messaggio.Paziente, invoco la SP di transcodifica
            ' Se la SP restituisce la transcodifica sostituisco il valore di CodiceTerminazione e DescrizioneTerminazione nel Messaggio.Paziente altrimenti non faccio nulla
            '
            If Not String.IsNullOrEmpty(Messaggio.Paziente.CodiceTerminazione) Then
                Using ota As New TranscodificheDataSetTableAdapters.PazientiMsgTranscodificaCodiceTerminazioneTableAdapter(My.Settings.SAC_ConnectionString)
                    Dim odt As TranscodificheDataSet.PazientiMsgTranscodificaCodiceTerminazioneDataTable = ota.GetData(Messaggio.Utente, Messaggio.Paziente.CodiceTerminazione)
                    If (Not odt Is Nothing) AndAlso (odt.Rows.Count > 0) Then
                        '
                        ' Sostituisco i valori nel messaggio
                        '
                        Dim oRow As TranscodificheDataSet.PazientiMsgTranscodificaCodiceTerminazioneRow = odt(0)
                        Messaggio.Paziente.CodiceTerminazione = oRow.Codice
                        Messaggio.Paziente.DescrizioneTerminazione = oRow.Descrizione
                    End If
                End Using
            End If

            '
            ' Determino il oMessaggioPaziente
            '
            oMessaggioPaziente = TypeExtension.ToMessaggioPaziente(Messaggio)
            '
            ' Invoco il metodo
            '
            '
            ' Gestione della concorrenza multithread
            '
            SyncLock ConcurrentDictionary.GetLockobject(sLockObject)
                oRispostaPaziente = oPaz.ProcessaMessaggio(oMessaggioTipo, oMessaggioPaziente)
            End SyncLock
            '
            ' Converto la risposta paziente della DLL nella clase MessaggioPazienteReturn
            ' serviranno comunque dei dati di ritorno NUOVI dalla DLL
            '
            oReturn = TypeExtension.ToMessaggioPazienteReturn(oRispostaPaziente)

        Finally
            ConcurrentDictionary.Remove(sLockObject)
        End Try
        '
        ' Rstituisco
        '
        Return oReturn
    End Function


    Public Function ListaPazientiByGeneralita(ByVal MaxRecord As Integer, ByVal SortOrder As PazientiSortOrderEnum,
                                              ByVal RestituisciSinonimi As Boolean, ByVal RestituisciEsenzioni As Boolean, ByVal RestituisciConsensi As Boolean,
                                              ByVal IdPaziente As String, ByVal Cognome As String, ByVal Nome As String, ByVal DataNascita As DateTime?,
                                              ByVal CodiceFiscale As String, ByVal Sesso As String) As ListaPazientiReturn Implements IPazienti.ListaPazientiByGeneralita
        Const NOME_METODO As String = "ListaPazientiByGeneralita"
        Dim oReturn As New ListaPazientiReturn
        Dim iSortOrder As Asmn.Sac.Msg.DataAccess.Pazienti.SortOrder = Asmn.Sac.Msg.DataAccess.Pazienti.SortOrder.Cognome
        Dim sInfoParametri As String = String.Empty
        Dim oIdPaziente As Guid? = Nothing
        Try
            If Not String.IsNullOrEmpty(IdPaziente) Then oIdPaziente = New Guid(IdPaziente)
            '
            ' Verifico parametri
            '
            If Not oIdPaziente.HasValue And
                    String.IsNullOrEmpty(Cognome) And
                    String.IsNullOrEmpty(Nome) And
                    Not DataNascita.HasValue And
                    String.IsNullOrEmpty(CodiceFiscale) And
                    String.IsNullOrEmpty(Sesso) Then
                Throw New CustomException("Tutti i parametri sono vuoti!", ErrorCodes.ParametroMancante)
            End If
            '
            ' Determino info sui parametri 
            '
            If oIdPaziente.HasValue Then sInfoParametri = sInfoParametri & " IdPaziente:" & oIdPaziente.ToString
            If Not String.IsNullOrEmpty(Cognome) Then sInfoParametri = sInfoParametri & " Cognome:" & Cognome
            If Not String.IsNullOrEmpty(Nome) Then sInfoParametri = sInfoParametri & " Nome:" & Nome
            If DataNascita.HasValue Then sInfoParametri = sInfoParametri & " DataNascita:" & DataNascita.Value.ToString("yyyy-MM-dd")
            If Not String.IsNullOrEmpty(CodiceFiscale) Then sInfoParametri = sInfoParametri & " CodiceFiscale:" & CodiceFiscale
            '
            '
            '
            Dim oPaz As New Asmn.Sac.Msg.DataAccess.Pazienti
            '
            ' Converto l'ordinamento: PazientiSortOrderEnum -> Asmn.Sac.Msg.DataAccess.SortOrder
            '
            Select Case SortOrder
                Case PazientiSortOrderEnum.Cognome
                    iSortOrder = Asmn.Sac.Msg.DataAccess.Pazienti.SortOrder.Cognome
                Case PazientiSortOrderEnum.Nome
                    iSortOrder = Asmn.Sac.Msg.DataAccess.Pazienti.SortOrder.Nome
                Case PazientiSortOrderEnum.CodiceFiscale
                    iSortOrder = Asmn.Sac.Msg.DataAccess.Pazienti.SortOrder.CodiceFiscale
                Case PazientiSortOrderEnum.Sesso
                    iSortOrder = Asmn.Sac.Msg.DataAccess.Pazienti.SortOrder.Sesso
                Case Else
                    iSortOrder = Asmn.Sac.Msg.DataAccess.Pazienti.SortOrder.Cognome
            End Select
            '
            ' Chiamo la DLL
            '
            Dim oRispostaPazienteWcf As Asmn.Sac.Msg.DataAccess.RispostaListaPazientiWcf
            oRispostaPazienteWcf = oPaz.ListaPazientiByGeneralitaWcf(MaxRecord, iSortOrder,
                                                                     RestituisciSinonimi, RestituisciEsenzioni, RestituisciConsensi,
                                                                     oIdPaziente, Cognome, Nome, DataNascita, CodiceFiscale, Sesso)
            '
            ' Converto DLL.RispostaListaPazientiWcf in WCF.PazientiReturn
            '
            oReturn = ToPazientiReturn(oRispostaPazienteWcf)

        Catch ex As CustomException
            oReturn.Errore = New ErroreType
            oReturn.Errore.Codice = ex.ErrorCode
            oReturn.Errore.Descrizione = String.Concat(String.Format("Errore in '{0} Parametri: {1}.'", NOME_METODO, sInfoParametri), vbCrLf, ex.Message)
            LogEvent.WriteError(ex, String.Empty)
        Catch ex As Exception
            oReturn.Errore = New ErroreType
            oReturn.Errore.Codice = ErrorCodes.ErroreGenerico.ToString
            oReturn.Errore.Descrizione = String.Concat(String.Format("Errore in '{0} Parametri: {1}.'", NOME_METODO, sInfoParametri), vbCrLf, ex.Message)
            LogEvent.WriteError(ex, String.Empty)
        End Try
        '
        ' Restituzione all'orchestrazione
        '
        Return oReturn
    End Function

    Public Function DettaglioPaziente(IdPaziente As String) As DettaglioPazienteReturn Implements IPazienti.DettaglioPaziente
        Const NOME_METODO As String = "DettaglioPaziente"
        Dim oReturn As New DettaglioPazienteReturn
        Dim oIdPaziente As Guid = Guid.Empty
        Try
            If String.IsNullOrEmpty(IdPaziente) Then
                Throw New CustomException("Il campo IdPaziente è vuoto", ErrorCodes.ParametroMancante)
            End If
            oIdPaziente = New Guid(IdPaziente)
            If oIdPaziente = Guid.Empty Then
                Throw New CustomException("Il campo IdPaziente è un Guid.Empty", ErrorCodes.ParametroNonValido)
            End If
            '
            '
            '
            Dim oRisposta As New Asmn.Sac.Msg.DataAccess.RispostaDettaglioPazienteWCF
            Dim oPaz As New Asmn.Sac.Msg.DataAccess.Pazienti

            oRisposta = oPaz.DettaglioPazienteWcf(oIdPaziente)
            If Not oRisposta Is Nothing Then
                '
                ' Converto Asmn.Sac.Msg.DataAccess.RispostaDettaglioPazienteWCF in DettaglioPazienteReturn
                '
                oReturn = oRisposta.ToDettaglioPazienteReturn
            End If

        Catch ex As CustomException
            oReturn.Errore = New ErroreType
            oReturn.Errore.Codice = ex.ErrorCode
            oReturn.Errore.Descrizione = String.Concat(String.Format("Errore in '{0}' - IdPaziente={1}.", NOME_METODO, oIdPaziente), vbCrLf, ex.Message)
            LogEvent.WriteError(ex, String.Empty)
        Catch ex As Exception
            oReturn.Errore = New ErroreType
            oReturn.Errore.Codice = ErrorCodes.ErroreGenerico.ToString
            oReturn.Errore.Descrizione = String.Concat(String.Format("Errore in '{0}' - IdPaziente={1}.", NOME_METODO, oIdPaziente), vbCrLf, ex.Message)
            LogEvent.WriteError(ex, String.Empty)
        End Try
        '
        ' Restituzione all'orchestrazione
        '
        Return oReturn
    End Function


End Class
