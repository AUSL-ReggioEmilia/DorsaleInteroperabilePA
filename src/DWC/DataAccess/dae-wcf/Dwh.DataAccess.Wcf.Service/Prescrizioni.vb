Imports DI.Wcf.Instrumentation
Imports Dwh.DataAccess.Wcf.Types.Prescrizioni
Imports Microsoft.ApplicationInsights.Extensibility
Imports System.Text


<ServiceBehavior(Namespace:="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0")>
<ApplicationInsightsBehavior()>
Public Class Prescrizioni
    Implements IPrescrizioni

    Private ReadOnly ErroreMetodoNonImplementato As New ErroreType With {.Codice = ErrorCodes.MetodoNonImplementato.ToString, .Descrizione = "Metodo non implementato"}

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

    Public Function Aggiungi(Par As PrescrizioneParameter) As PrescrizioneReturn Implements IPrescrizioni.Aggiungi
        Dim oPrescrizioneReturn As New PrescrizioneReturn

        Try
            'Controllo parametri
            If Par Is Nothing OrElse Par.Prescrizione Is Nothing Then
                Throw New CustomException("Parametro Prescrizione non fornito", ErrorCodes.ParametroMancante)
            End If

            ' TENTA DI APRIRE LA CONNESSIONE AL DB DWH, SOLLEVA ECCEZIONE SE NON RIESCE PER N VOLTE
            Helper.CheckConnectionString(My.Settings.DWHConnectionString)
            ' TENTA DI APRIRE LA CONNESSIONE AL DB SAC, SOLLEVA ECCEZIONE SE NON RIESCE PER N VOLTE
            Helper.CheckConnectionString(My.Settings.SACConnectionString)

            Dim oPrescBuilder As New PrescrizioneBuilder(Par.Prescrizione)
            '
            ' AGGIUNGE AGLI ATTRIBUTI DELLA PRESCRIZIONE I DETTAGLI ANAGRAFICI DEL PAZIENTE
            '
            oPrescBuilder.AggiungiAttributiPaziente()

            '
            ' LETTURA CAMPI DALL'ALLEGATO XML
            '
            oPrescBuilder.AggiungiDatiDaAllegatoXml()

            '
            ' Tentativi su errori controllati (timeout...)
            '
            For iRetry As Integer = 0 To My.Settings.RetryCount
                Try
                    If iRetry > 0 Then
                        '
                        ' Log dal secondo tentativo in poi
                        '
                        Log.WriteInformation(String.Format("Riprova numero {0} invio messaggio!", iRetry))
                    End If

                    ' GESTIONE DELLA CONCORRENZA MULTITHREAD
                    SyncLock ConcurrentDictionary.GetLockobject(oPrescBuilder.Prescrizione.IdEsterno)
                        '
                        ' SAC : RICERCA / INSERIMENTO DELL'ANAGRAFICA PAZIENTE MEDIANTE STORED PROCEDURE
                        '
                        SacHelper.PazientiOutputCercaAggancioPaziente(oPrescBuilder.Prescrizione, oPrescBuilder.IdPazienteSAC)
                        '
                        ' DWH : CHIAMATA ALLE STORED DI INSERIMENTO SOTTO TRANSAZIONE
                        '
                        DwhHelper.AggiungiOrAggiorna(oPrescBuilder.Prescrizione, oPrescBuilder.IdPazienteSAC)

                    End SyncLock

                    '
                    ' Se processato esce dal loop
                    '
                    Exit For


                Catch ex As CustomException
                    ' LE CustomException INTERROMPONO IL CICLO DI RETRY E PASSANO FUORI
                    Throw ex

                Catch ex As Exception
                    '
                    ' Controlla il tipo di errore
                    '
                    Dim sError As String = ex.Message.ToLower
                    Dim sScope = System.Reflection.MethodInfo.GetCurrentMethod().Name
                    Log.WriteError(ex, "Errore nel metodo " & sScope)

                    If sError.Contains("timeout") Then
                        '
                        ' Timeout
                        '
                        If iRetry = My.Settings.RetryCount Then
                            Throw New CustomException("Errore di timeout in " & sScope, ErrorCodes.Timeout)
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
                            Throw New CustomException("Errore di deadlock in " & sScope, ErrorCodes.Deadlocked)
                        Else
                            '
                            ' Attesa WaitAfterDeadlocked
                            '
                            If My.Settings.WaitAfterDeadlocked > 0 Then
                                Threading.Thread.Sleep(My.Settings.WaitAfterDeadlocked)
                            End If
                        End If

                    ElseIf sError.Contains("was not found or was not accessible") Then
                        '
                        ' Network error
                        '
                        If iRetry = My.Settings.RetryCount Then
                            Throw New CustomException("Errore di rete in " & sScope, ErrorCodes.NetError)
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
                End Try
            Next

            '
            ' SE NON CI SONO ERRORI RESTITUISCO NEL PrescrizioneReturn LA STESSA PRESCRIZIONE CHE MI È ARRIVATA IN INPUT 
            '
            oPrescrizioneReturn.Prescrizione = oPrescBuilder.Prescrizione


        Catch ex As CustomException
            oPrescrizioneReturn.Errore = New ErroreType
            oPrescrizioneReturn.Errore.Codice = ex.ErrorCode
            oPrescrizioneReturn.Errore.Descrizione = ex.Message
            Log.WriteWarning(String.Format("Eccezione Codice: {0}, Messaggio: {1}", ex.ErrorCode, ex.Message))

        Catch ex As Exception
            oPrescrizioneReturn.Errore = New ErroreType
            oPrescrizioneReturn.Errore.Codice = ErrorCodes.ErroreGenerico.ToString
            oPrescrizioneReturn.Errore.Descrizione = ex.Message
            Log.WriteError(ex)

        End Try

        ' RIMUOVO IL LOCKOBJECT DAL DICTIONARY
        If Par IsNot Nothing AndAlso Par.Prescrizione IsNot Nothing AndAlso Par.Prescrizione.IdEsterno IsNot Nothing Then
            ConcurrentDictionary.Remove(Par.Prescrizione.IdEsterno)
        End If

        Return oPrescrizioneReturn

    End Function


    Public Function Rimuovi(ByVal IdEsterno As String, ByVal DataModificaEsterno As DateTime) As ErroreType Implements IPrescrizioni.Rimuovi
        Dim oReturn As New ErroreType With {.Codice = "", .Descrizione = ""}

        Try
            'Controllo parametri
            If String.IsNullOrEmpty(IdEsterno) Then
                Throw New CustomException("Parametro IdEsterno non fornito", ErrorCodes.ParametroMancante)
            End If

            ' TENTA DI APRIRE LA CONNESSIONE AL DB DWH, SOLLEVA ECCEZIONE SE NON RIESCE PER N VOLTE
            Helper.CheckConnectionString(My.Settings.DWHConnectionString)

            '
            ' Tentativi su errori controllati (timeout...)
            '
            For iRetry As Integer = 0 To My.Settings.RetryCount
                Try
                    If iRetry > 0 Then
                        '
                        ' Log dal secondo tentativo in poi
                        '
                        Log.WriteInformation(String.Format("Riprova numero {0} invio messaggio!", iRetry))
                    End If

                    ' GESTIONE DELLA CONCORRENZA MULTITHREAD
                    SyncLock ConcurrentDictionary.GetLockobject(IdEsterno)
                        '
                        ' DWH : CHIAMATA ALLA STORED DI CANCELLAZIONE
                        '
                        DwhHelper.Rimuovi(IdEsterno, DataModificaEsterno)

                    End SyncLock

                    '
                    ' Se processato esce dal loop
                    '
                    Exit For

                Catch ex As CustomException

                    ' LE CustomException INTERROMPONO IL CICLO DI RETRY E PASSANO FUORI
                    Throw ex

                Catch ex As Exception
                    '
                    ' Controlla il tipo di errore
                    '
                    Dim sError As String = ex.Message.ToLower
                    Dim sScope = System.Reflection.MethodInfo.GetCurrentMethod().Name
                    Log.WriteError(ex, "Errore nel metodo " & sScope)

                    If sError.Contains("timeout") Then
                        '
                        ' Timeout
                        '
                        If iRetry = My.Settings.RetryCount Then
                            Throw New CustomException("Errore di timeout in " & sScope, ErrorCodes.Timeout)
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
                            Throw New CustomException("Errore di deadlock in " & sScope, ErrorCodes.Deadlocked)
                        Else
                            '
                            ' Attesa WaitAfterDeadlocked
                            '
                            If My.Settings.WaitAfterDeadlocked > 0 Then
                                Threading.Thread.Sleep(My.Settings.WaitAfterDeadlocked)
                            End If
                        End If

                    ElseIf sError.Contains("was not found or was not accessible") Then
                        '
                        ' Network error
                        '
                        If iRetry = My.Settings.RetryCount Then
                            Throw New CustomException("Errore di rete in " & sScope, ErrorCodes.NetError)
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
                End Try
            Next


        Catch ex As CustomException
            oReturn.Codice = ex.ErrorCode
            oReturn.Descrizione = ex.Message
            Log.WriteWarning(String.Format("Eccezione Codice: {0}, Messaggio: {1}", ex.ErrorCode, ex.Message))

        Catch ex As Exception
            oReturn.Codice = ErrorCodes.ErroreGenerico.ToString
            oReturn.Descrizione = ex.Message
            Log.WriteError(ex)

        End Try

        ' RIMUOVO IL LOCKOBJECT DAL DICTIONARY
        If IdEsterno IsNot Nothing Then
            ConcurrentDictionary.Remove(IdEsterno)
        End If

        Return oReturn

    End Function





End Class
