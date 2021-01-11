Imports System.Xml
Imports OE.Core.Schemas.Msg.RichiestaParameterTypes
Imports OE.Core.Schemas.Msg.RichiestaReturnTypes
Imports OE.Core.Schemas.Msg.QueueTypes
Imports Microsoft.ApplicationInsights.Extensibility
Imports Microsoft.ApplicationInsights
Imports Microsoft.ApplicationInsights.DataContracts
Imports Microsoft.ApplicationInsights.DependencyCollector
Imports OE.Core
Imports System.Threading
Imports Microsoft.ApplicationInsights.Extensibility.PerfCounterCollector

<ServiceBehavior(Namespace:="http://schemas.progel.it/OE/WCF/DataAccess/Richiesta")>
Public Class Richiesta
    Implements IRichiesta

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

    Public Function ProcessaMessaggio(ByVal value As RichiestaParameter) As RichiestaReturn _
            Implements IRichiesta.ProcessaMessaggio

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
            telemetryOperation = _telemetry.StartOperation(Of RequestTelemetry)("Richiesta.ProcessaMessaggio")
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
            ' e ritorna n messaggi splittati per sistema erogante
            ' Lo split serve per gestire la richiesta multisettore
            '
            Dim oDataAccess As New OE.DataAccess.MessaggioRichiesta
            Dim oRichiestaReturn As RichiestaReturn = Nothing

            DiagnosticsHelper.WriteInformation("Richiesta.ProcessaMessaggio()")
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
                    oRichiestaReturn = oDataAccess.ProcessaMessaggio(value, _Setting)
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
                            Throw New FaultException(Of RichiestaFault)(New RichiestaFault(ex), "Timeout")
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
                            Throw New FaultException(Of RichiestaFault)(New RichiestaFault(ex), "Deadlocked")
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
                            Throw New FaultException(Of RichiestaFault)(New RichiestaFault(ex), "NetError")
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
                        DiagnosticsHelper.WriteError(ex, "Errore durante DataAccess MessaggioRichiesta.ProcessaMessaggi()!")
                        '
                        ' Esce senza fault
                        '
                        Exit For
                    End If
                    '
                    ' Warning, RIPROVA
                    '
                    DiagnosticsHelper.WriteWarning(ex, "Errore durante DataAccess MessaggioRichiesta.ProcessaMessaggio(); riprova!")

                End Try
            Next
            '
            ' Se nothing torna vuoto
            '
            If oRichiestaReturn Is Nothing Then
                oRichiestaReturn = New RichiestaReturn() With {.RichiesteQueue = New RichiesteQueueType}
            End If

            Return oRichiestaReturn

        Catch ex As FaultException
            '
            ' Scrive log errore
            '
            DiagnosticsHelper.WriteError(ex, "Fault durante Richiesta.ProcessaMessaggio()!")
            '
            ' E' già un SoapException
            '
            Throw

        Catch ex As Exception
            '
            ' Scrive log errore
            '
            DiagnosticsHelper.WriteError(ex, "Errore durante Richiesta.ProcessaMessaggio()!")
            '
            ' Fault
            '
            Throw New FaultException(Of RichiestaFault)(New RichiestaFault(ex), "Errore durante l'esecuzione!")

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

    Private Function RichiestaParameterToRichiestaReturn(ByVal value As RichiestaParameter) As RichiestaReturn
        '
        ' Per debug ritorno la chiamata
        '
        Dim sXmlRichiesta As String
        Using stream As New IO.MemoryStream
            Dim oDataSerializer As New DataContractSerializer(GetType(RichiestaParameter))
            oDataSerializer.WriteObject(stream, value)

            stream.Position = 0
            sXmlRichiesta = System.Text.Encoding.UTF8.GetString(stream.ToArray)
        End Using

        Dim sXmlRisposta As String = sXmlRichiesta.Replace("RichiestaParameter", "RichiestaReturn")

        sXmlRisposta = sXmlRisposta.Replace("<RichiestaQueue xmlns:a=""http://schemas.progel.it/BT/OE/QueueTypes/1.1"">", _
                                            "<RichiesteQueue xmlns:a=""http://schemas.progel.it/BT/OE/QueueTypes/1.1""><RichiestaQueue>")

        sXmlRisposta = sXmlRisposta.Replace("</RichiestaQueue>", _
                                            "</RichiestaQueue></RichiesteQueue>")

        Using stream As New IO.MemoryStream
            Dim encoding As System.Text.Encoding = System.Text.Encoding.UTF8
            stream.Write(encoding.GetBytes(sXmlRisposta), 0, encoding.GetByteCount(sXmlRisposta))
            stream.Position = 0

            Dim oDataSerializer As New DataContractSerializer(GetType(RichiestaReturn))
            Return CType(oDataSerializer.ReadObject(stream), RichiestaReturn)
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
            DiagnosticsHelper.WriteDiagnostics("BtDataAccess.Richiesta: Ignorato DiagnosticsHelper_EntryLogWritten, altro Thread!")
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
            DiagnosticsHelper.WriteDiagnostics("BtDataAccess.Richiesta: Ignorato DiagnosticsHelper_TraceWritten, altro Thread!")
        End If

    End Sub

#End Region

End Class

