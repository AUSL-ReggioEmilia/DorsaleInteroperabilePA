Imports System.Threading
Imports System.Xml
Imports Microsoft.ApplicationInsights
Imports Microsoft.ApplicationInsights.DataContracts
Imports Microsoft.ApplicationInsights.DependencyCollector
Imports Microsoft.ApplicationInsights.Extensibility
Imports Microsoft.ApplicationInsights.Extensibility.PerfCounterCollector
Imports OE.Core
Imports OE.Core.Schemas.Msg.OrdineReturnTypes
Imports OE.Core.Schemas.Msg.QueueTypes

<ServiceBehavior(Namespace:="http://schemas.progel.it/OE/WCF/DataAccess/Ordine")> _
Public Class Ordine
    Implements IOrdine

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

    Public Function OrdinePerIdRichiestaOrderEntry(idRichiestaOrderEntry As String) As OrdineReturn Implements IOrdine.OrdinePerIdRichiestaOrderEntry

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
            telemetryOperation = _telemetry.StartOperation(Of RequestTelemetry)("Ordine.OrdinePerIdRichiestaOrderEntry")
            '
            ' Valido parametri
            '
            If String.IsNullOrEmpty(idRichiestaOrderEntry) Then
                '
                ' Error
                '
                Throw New ArgumentException("Il parametro è nullo!", "idGuid")
            End If
            '
            ' Prova a connetersi
            '
            Helper.TryConnectToDatabase(_Setting)
            '
            ' Chiama la DLL di data access, che processa lòa richiesta sul DB
            '
            Dim oDataAccess As New OE.DataAccess.OrdineData
            Dim oOrdineReturn As OrdineReturn = Nothing

            DiagnosticsHelper.WriteInformation("Ordine.OrdinePerIdOrderEntry()")
            '
            ' Tentativi su errori controllati (timeout...)
            '
            For nRetry As Integer = 0 To My.Settings.RetryCount
                Try
                    If nRetry > 0 Then
                        '
                        ' Log info
                        '
                        DiagnosticsHelper.WriteInformation(String.Format("Riprova numero {0} accesso a ordine!", nRetry))
                    End If
                    '
                    ' Processa la richiesta
                    ' Passare oSetting non servirebbe più, è un GLOBALONE di CORE, per ora rimane
                    '
                    oOrdineReturn = oDataAccess.OrdinePerIdOrderEntry(idRichiestaOrderEntry, _Setting)
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
                        ' timeout
                        '
                        If nRetry = My.Settings.RetryCount Then
                            Throw New ApplicationException("Timeout: Durante l'accesso ad database!", ex)
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
                        ' deadlocked
                        '
                        If nRetry = My.Settings.RetryCount Then
                            Throw New ApplicationException("Deadlocked: Durante l'accesso ad database!", ex)
                        Else
                            '
                            ' Aspetta
                            '
                            Dim nRetryTime As Integer = My.Settings.WaitAfterDeadlocked
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
                            Throw New ApplicationException("NetError: Durante l'accesso ad database!", ex)
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
                        ' Re-Throw per uscire con errore
                        '
                        Throw
                    End If
                    '
                    ' Warning, RIPROVA
                    '
                    DiagnosticsHelper.WriteWarning(ex, "Errore durante DataAccess Ordine.OrdinePerIdOrderEntry(); riprova!")

                End Try
            Next
            '
            ' Ritorno dato
            '
            Return oOrdineReturn

        Catch ex As FaultException
            '
            ' Scrive log errore
            '
            DiagnosticsHelper.WriteError(ex, "Fault durante Ordine.OrdinePerIdRichiestaOrderEntry()!")
            '
            ' E' già un SoapException
            '
            Throw

        Catch ex As Exception
            '
            ' Controllo tipo di EX, Ignoro ordine non trovato
            '
            If ex.Message <> "Ordine non trovato!" Then
                '
                ' Scrive log errore
                '    
                DiagnosticsHelper.WriteError(ex, "Errore durante l'esecuzione!")
            End If
            '
            ' Ritorna codice errore
            '
            Dim oOrdineReturn As New OrdineReturn
            '
            ' Riepilogo Exception
            '
            Dim sMessage As String = DiagnosticsHelper.FormatException(ex)

            oOrdineReturn.Esito = New CodiceDescrizioneType With {.Codice = "AE", .Descrizione = sMessage}
            Return oOrdineReturn

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

    Private Sub RaiseOrdineFault(ex As Exception)
        Throw New FaultException(Of OrdineFault)(New OrdineFault(ex), ex.Message)
    End Sub


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
            DiagnosticsHelper.WriteDiagnostics("BtDataAccess.Ordine: Ignorato DiagnosticsHelper_EntryLogWritten, altro Thread!")
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
            DiagnosticsHelper.WriteDiagnostics("BtDataAccess.Ordine: Ignorato DiagnosticsHelper_TraceWritten, altro Thread!")
        End If

    End Sub

#End Region

End Class
