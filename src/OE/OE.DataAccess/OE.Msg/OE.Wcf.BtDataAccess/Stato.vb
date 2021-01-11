Imports System.Xml
Imports OE.Core.Schemas.Msg.StatoParameterTypes
Imports OE.Core.Schemas.Msg.StatoReturnTypes
Imports OE.Core.Schemas.Msg.QueueTypes
Imports Microsoft.ApplicationInsights.Extensibility
Imports Microsoft.ApplicationInsights
Imports Microsoft.ApplicationInsights.DataContracts
Imports Microsoft.ApplicationInsights.DependencyCollector
Imports OE.Core
Imports System.Threading
Imports Microsoft.ApplicationInsights.Extensibility.PerfCounterCollector

<ServiceBehavior(Namespace:="http://schemas.progel.it/OE/WCF/DataAccess/Stato")> _
Public Class Stato
    Implements IStato

    Private _telemetry As TelemetryClient
    Private Shared _Setting As ConfigurationSettings

    Shared Sub New()
        '
        ' NEW SHARED Eseguita solo 1 volta
        '
        ' ###########################################################
        '
        ' PRIMA cosa della CLASSE da fare INIT config
        '
        _Setting = Helper.InitCoreConfigurationSettings()
        '
        ' ###########################################################
        '
        ' Initialize Application Insight aggiungendo un custom Initializer se non c'è già
        '
        TelemetryHelper.Initialize()
        '
        ' Trace
        '
        DiagnosticsHelper.WriteDiagnostics("Stato.New() SHARED")

    End Sub

    Public Sub New()

        _telemetry = New TelemetryClient()
        '
        ' Trace
        '
        DiagnosticsHelper.WriteDiagnostics("Stato.New()")

    End Sub

    Public Function ProcessaMessaggio(ByVal value As StatoParameter) As StatoReturn _
        Implements IStato.ProcessaMessaggio

        Dim telemetryOperation As IOperationHolder(Of RequestTelemetry) = Nothing

        Try
            '
            ' Join evento per telemetry log
            '
            If Helper.AppInsightsEventLog Then
                AddHandler DiagnosticsHelper.EntryLogWritten, AddressOf DiagnosticsHelper_EntryLogWritten
            End If
            If Helper.AppInsightsTrace Then
                AddHandler DiagnosticsHelper.TraceWritten, AddressOf DiagnosticsHelper_TraceWritten
            End If
            '
            ' Track Operation
            '
            telemetryOperation = _telemetry.StartOperation(Of RequestTelemetry)("Stato.ProcessaMessaggio")
            '
            ' Valido parametri
            '
            If value Is Nothing Then
                '
                ' Error
                '
                Throw New ArgumentException("Il parametro è nullo!", "value")
            End If
            '
            ' Prova a connetersi
            '
            Helper.TryConnectToDatabase(_Setting)
            '
            ' Chiama la DLL di data access, che processa il messaggio sul DB, aggiunge i dati mancanti
            ' e ritorna il messaggio
            ' Lo stato viene inviato dal sistema erogante ed è sempre monosettore
            '
            Dim oDataAccess As New OE.DataAccess.MessaggioStato
            Dim oStatoReturn As StatoReturn = Nothing

            DiagnosticsHelper.WriteInformation("Stato.ProcessaMessaggio()")
            '
            ' Tentativi su errori controllati (timeout...)
            '
            For nRetry As Integer = 0 To My.Settings.RetryCount

                Try
                    If nRetry > 0 Then
                        '
                        ' Log info
                        '
                        DiagnosticsHelper.WriteInformation(String.Format("Riprova numero {0} invio messaggio!", nRetry))
                    End If
                    '
                    ' Processa il messaggio
                    ' Passare oSetting non servirebbe più, è un GLOBALONE di CORE, per ora rimane
                    '
                    oStatoReturn = oDataAccess.ProcessaMessaggio(value, _Setting)
                    '
                    ' Se processato esce dal loop
                    '
                    Exit For

                Catch ex As Exception
                    '
                    ' Controlla il tipo di errore
                    '
                    Dim sError As String = ex.Message
                    If sError.ToLower.Contains("timeout") Then
                        '
                        ' Timeout
                        '
                        If nRetry = My.Settings.RetryCount Then
                            Throw New FaultException(Of StatoFault)(New StatoFault(ex), "Timeout")
                        Else
                            '
                            ' Aspetta
                            '
                            Dim nRetryTime As Integer = My.Settings.WaitAfterTimeout
                            If nRetryTime < 0 Then
                                nRetryTime = 0
                            End If
                            Thread.Sleep(nRetryTime)
                        End If

                    ElseIf sError.ToLower.Contains("deadlocked") Then
                        '
                        ' Deadlocked
                        '
                        If nRetry = My.Settings.RetryCount Then
                            Throw New FaultException(Of StatoFault)(New StatoFault(ex), "Deadlocked")
                        Else
                            '
                            ' Aspetta
                            '
                            Dim nRetryTime As Integer = My.Settings.WaitAfterTimeout
                            If nRetryTime < 0 Then
                                nRetryTime = 0
                            End If
                            Thread.Sleep(nRetryTime)
                        End If

                    ElseIf sError.ToLower.Contains("was not found or was not accessible") Then
                        '
                        ' Network error
                        '
                        If nRetry = My.Settings.RetryCount Then
                            Throw New FaultException(Of StatoFault)(New StatoFault(ex), "NetError")
                        Else
                            '
                            ' Aspetta
                            '
                            Dim nRetryTime As Integer = My.Settings.WaitAfterNetError
                            If nRetryTime < 0 Then
                                nRetryTime = 0
                            End If
                            Thread.Sleep(nRetryTime)
                        End If

                    Else
                        '
                        ' Altri errori non riprova
                        '
                        If TypeOf ex Is OrderEntryDataVersioneMismatchException Then
                            '
                            ' Evito di segnalare come errore, solo INFO
                            '
                            DiagnosticsHelper.WriteInformation(DiagnosticsHelper.FormatException(ex))
                        Else
                            '
                            ' Log error
                            '
                            DiagnosticsHelper.WriteError(ex, "Errore durante DataAccess MessaggioStato.ProcessaMessaggi()!")
                        End If
                        '
                        ' Esce senza fault
                        '
                        Exit For
                    End If
                    '
                    ' Warning, RIPROVA
                    '
                    DiagnosticsHelper.WriteWarning(ex, "Errore durante DataAccess MessaggioStato.ProcessaMessaggio(); riprova!")

                End Try
            Next
            '
            ' Se NULL torna vuoto,  l'ORC NON eseguirà il send verso OUTPUT
            '
            If oStatoReturn Is Nothing Then
                '
                ' Creo uno stato vuoto con il minimo dei dati possibile dalle schema
                ' Non uso TipoStato o TipoOperazione perchè hanno dei default in quanto ENUM
                '
                oStatoReturn = New StatoReturn
                oStatoReturn.StatoQueue = New StatoQueueType With {.DataOperazione = value.StatoQueue.DataOperazione,
                                                                    .Utente = value.StatoQueue.Utente,
                                                                    .TipoOperazione = value.StatoQueue.TipoOperazione,
                                                                    .TipoStato = value.StatoQueue.TipoStato
                                                                    }

                oStatoReturn.StatoQueue.Testata = New TestataStatoType With {.SistemaErogante = New SistemaType _
                                                                             With {.Azienda = New CodiceDescrizioneType,
                                                                                   .Sistema = New CodiceDescrizioneType}
                                                                             }

                ' SE Azienda.Codice e Sistema.Codice sono vuotio, l'ORC NON eseguirà il send verso OUTPUT
                oStatoReturn.StatoQueue.Testata.SistemaErogante.Azienda.Codice = ""
                oStatoReturn.StatoQueue.Testata.SistemaErogante.Sistema.Codice = ""
            End If

            Return oStatoReturn

        Catch ex As FaultException
            '
            ' Scrive log errore
            '
            DiagnosticsHelper.WriteError(ex, "Fault durante Stato.ProcessaMessaggio()!")
            '
            ' E' già un SoapException
            '
            Throw

        Catch ex As Exception
            '
            ' Scrive log errore
            '
            DiagnosticsHelper.WriteError(ex, "Errore durante Stato.ProcessaMessaggi()!")
            '
            ' Fault
            '
            Throw New FaultException(Of StatoFault)(New StatoFault(ex), "Errore durante l'esecuzione!")

        Finally
            '
            ' Completo la Telemetry Operation
            '
            If telemetryOperation IsNot Nothing Then
                _telemetry.StopOperation(telemetryOperation)
            End If
            '
            ' Release evento per telemetry log
            '
            If Helper.AppInsightsEventLog Then
                RemoveHandler DiagnosticsHelper.EntryLogWritten, AddressOf DiagnosticsHelper_EntryLogWritten
            End If
            If Helper.AppInsightsTrace Then
                RemoveHandler DiagnosticsHelper.TraceWritten, AddressOf DiagnosticsHelper_TraceWritten
            End If
        End Try

    End Function

    Private Function StatoParameterToStatoReturn(ByVal value As StatoParameter) As StatoReturn
        '
        ' Per debug ritorno la chiamata
        '
        Dim sXmlRichiesta As String
        Using stream As New IO.MemoryStream
            Dim oDataSerializer As New DataContractSerializer(GetType(StatoParameter))
            oDataSerializer.WriteObject(stream, value)

            stream.Position = 0
            sXmlRichiesta = System.Text.Encoding.UTF8.GetString(stream.ToArray)
        End Using

        Dim sXmlRisposta As String = sXmlRichiesta.Replace("StatoParameter", "StatoReturn")

        Using stream As New IO.MemoryStream
            Dim encoding As System.Text.Encoding = System.Text.Encoding.UTF8
            stream.Write(encoding.GetBytes(sXmlRisposta), 0, encoding.GetByteCount(sXmlRisposta))
            stream.Position = 0

            Dim oDataSerializer As New DataContractSerializer(GetType(StatoReturn))
            Return CType(oDataSerializer.ReadObject(stream), StatoReturn)
        End Using

    End Function

#Region "DiagnosticsHelper Events"

    Private Sub DiagnosticsHelper_EntryLogWritten(sender As Object, e As DiagnosticsHelper.EntryLogWrittenEventArgs)
        '
        ' Per evitare log di altri metodi, controllo il ThreadID
        ' Se in futuro si adotterà Async sarà da rivedere
        '
        If Thread.CurrentThread.ManagedThreadId = e.ThreadID Then
            '
            ' Tipo di LOG
            '
            Select Case e.EntryType
                Case EventLogEntryType.Information
                    '
                    ' No in Application Insights
                    '
                    _telemetry.TrackEvent(e.Message)

                Case EventLogEntryType.Warning
                    If e.Ex IsNot Nothing Then
                        _telemetry.TrackException(e.Ex)
                    Else
                        _telemetry.TrackEvent(e.Message)
                    End If

                Case EventLogEntryType.Error
                    If e.Ex IsNot Nothing Then
                        _telemetry.TrackException(e.Ex)
                    Else
                        '
                        ' Se non c'è genero dal messaggio
                        '
                        _telemetry.TrackException(New ApplicationException(e.Message))
                    End If

            End Select
        Else
            '
            ' Altro Thread, ignoro
            '
            DiagnosticsHelper.WriteDiagnostics("BtDataAccess.Stato: Ignorato DiagnosticsHelper_EntryLogWritten, altro Thread!")
        End If

    End Sub

    Private Sub DiagnosticsHelper_TraceWritten(sender As Object, e As DiagnosticsHelper.TraceWrittenEventArgs)
        '
        ' Per evitare log di altri metodi, controllo il ThreadID
        ' Se in futuro si adotterà Async sarà da rivedere
        '
        If Thread.CurrentThread.ManagedThreadId = e.ThreadID Then
            '
            ' Trace su App Ins
            '
            _telemetry.TrackTrace(e.Message)

        Else
            '
            ' Altro Thread, ignoro
            '
            DiagnosticsHelper.WriteDiagnostics("BtDataAccess.Stato: Ignorato DiagnosticsHelper_TraceWritten, altro Thread!")
        End If

    End Sub

#End Region

End Class

