Imports System.Threading
Imports System.Xml
Imports OE.Core
Imports OE.Core.Schemas.Msg

<Serializable()>
<CLSCompliant(True)>
Public Class MessaggioStato
    Inherits MessaggioBase(Of StatoParameterTypes.StatoParameter, StatoReturnTypes.StatoReturn)

    Public Sub New()
    End Sub

    Public Overrides Function ProcessaMessaggio(ByVal messaggio As StatoParameterTypes.StatoParameter,
                                                ByVal settings As ConfigurationSettings) As StatoReturnTypes.StatoReturn
        Dim idTicket As Guid
        Dim idMessaggioOriginale As Nullable(Of Guid)
        Dim idOrdineErogatoTestata As Nullable(Of Guid)
        Dim taStato As StatoAdapter = Nothing

        Dim bSendOSU As Boolean = True

        ' B E G I N
        Try
            '######################################################
            ' Prima cosa da fare Initialize(settings)
            '######################################################

            ' Init Custom settings
            ConfigurationHelper.Initialize(settings)

            ' Trace
            DiagnosticsHelper.WriteDiagnostics("Stato.ProcessaMessaggio()")
            DiagnosticsHelper.WriteDiagnostics("-- InitAdapters")

            taStato = New StatoAdapter(ConfigurationHelper.ConnectionString)
            taStato.BeginTransaction(ConfigurationHelper.TransactionIsolationLevel)

            ' Validazione del messaggio
            Validate(messaggio)

            '
            ' SANDRO 2018-11-12
            ' Se messaggio RR forzo il TipoOperazione in Incrementale oppure Completo
            '   in funzione di StatoOrderEntry (SE o AA)
            ' 
            ' TODO: Per ora no, (AUSL MOW) (ASMN RIS-REGGIO) (ASMN LIS-REGGIO) (AUSL VILLAVERDE) (ASMN ARTEXE)
            '                   inseriscono AA di tipo INCREMENTALE (a occhio non mi sembra corretto)
            '
            'If messaggio.StatoQueue.TipoStato = QueueTypes.TipoStatoType.RR Then
            '    If messaggio.StatoQueue.Testata.StatoOrderEntry = QueueTypes.StatoTestataErogatoOrderEntryEnum.SE.ToString() Then
            '        '
            '        ' SE sempre INCREMENTALE
            '        '
            '        messaggio.StatoQueue.TipoOperazione = QueueTypes.TipoOperazioneType.Incrementale
            '    Else
            '        messaggio.StatoQueue.TipoOperazione = QueueTypes.TipoOperazioneType.Completo
            '    End If
            'End If

            ' Trace
            DiagnosticsHelper.WriteDiagnostics(DataContractSerializerHelper.GetXML(messaggio))

            ' Get del ticket di autenticazione
            Using taTicket = New TicketAdapter(ConfigurationHelper.ConnectionString)
                idTicket = taTicket.GetTicketId(messaggio.StatoQueue.Utente, ConfigurationHelper.Ttl)
            End Using

            ' Persisto il messaggio originale
            Using _messaggioAdapter = New MessaggioAdapter(ConfigurationHelper.ConnectionString)

                'Calcolo Stato per il traking
                Dim sStatoOrderEntry As String = StatoHelper.GetStatoOrderEntryTestataStato(messaggio.StatoQueue.Testata)

                'Traking messaggi
                idMessaggioOriginale = _messaggioAdapter.MessaggioStatoInsert(idTicket, messaggio, MessaggioAdapter.Stato.Inserito,
                                                                              sStatoOrderEntry, messaggio.StatoQueue.TipoStato.ToString)

                ' Elaboro lo stato
                idOrdineErogatoTestata = taStato.Elabora(idTicket, messaggio.StatoQueue, bSendOSU)

                ' Commit
                taStato.Commit()

                'Traking messaggi completato
                Dim sDescrizione As String = If(bSendOSU, Nothing, "Messaggio OSU da non inviate!")
                _messaggioAdapter.MessaggioStatoUpdate(idTicket, idMessaggioOriginale, MessaggioAdapter.Stato.Processato, idOrdineErogatoTestata, Nothing, sDescrizione)
            End Using

            '-------------------------------------------------------
            ' Creo Risposta
            Dim response As StatoReturnTypes.StatoReturn = Nothing

            'Controlla se inviare la risposta. taStato.Elabora(,,bSendOSU)
            If bSendOSU Then

                ' Invio OSU
                If idOrdineErogatoTestata.HasValue Then

                    ' Copio StatoQueue senza testata che la rileggo dal DB
                    response = New StatoReturnTypes.StatoReturn()
                    response.StatoQueue = New QueueTypes.StatoQueueType

                    response.StatoQueue.TipoOperazione = QueueTypes.TipoOperazioneType.Completo
                    response.StatoQueue.TipoStato = QueueTypes.TipoStatoType.OSU
                    response.StatoQueue.Utente = messaggio.StatoQueue.Utente
                    response.StatoQueue.DataOperazione = messaggio.StatoQueue.DataOperazione

                    'Leggo testata dello Stato dal DB
                    response.StatoQueue.Testata = taStato.LeggeTestataStato(idOrdineErogatoTestata.Value)

                    If messaggio.StatoQueue.TipoStato = QueueTypes.TipoStatoType.RR Then

                        ' Stato calcolato durante ELABORA, non da DB
                        response.StatoQueue.Testata.StatoOrderEntry = messaggio.StatoQueue.Testata.StatoOrderEntry
                    End If

                End If
            End If

            DiagnosticsHelper.WriteDiagnostics(String.Concat("Stato processato con successo.", vbCrLf, vbCrLf,
                                                     DataContractSerializerHelper.GetXML(response)))

            Return response

        Catch ex As Exception
            '
            ' Rollback
            '
            If taStato IsNot Nothing Then
                taStato.Rollback()
            End If
            '
            ' Aggiorno lo stato del messaggio originale (NO Throw ERROR)
            '
            Try
                Using _messaggioAdapter = New MessaggioAdapter(ConfigurationHelper.ConnectionString)

                    If idMessaggioOriginale Is Nothing Then
                        '
                        'Traking aggiungo se non già fatto
                        '
                        idMessaggioOriginale = _messaggioAdapter.MessaggioStatoInsert(idTicket, messaggio, MessaggioAdapter.Stato.Inserito, Nothing, Nothing)
                    End If
                    '
                    ' Fault sul DB
                    '
                    Dim fault As New StatoFault("Stato.ProcessaMessaggio()", ex, messaggio)
                    _messaggioAdapter.MessaggioStatoUpdate(idTicket, idMessaggioOriginale, MessaggioAdapter.Stato.Errore, Nothing, fault, Nothing)
                End Using
            Catch
                DiagnosticsHelper.WriteError(ex)
            End Try
            '
            ' RE-Throw
            '
            Throw

        Finally

            ' Rilascio tutte le risorse
            If taStato IsNot Nothing Then
                taStato.Dispose()
            End If

        End Try
    End Function

    Public Overrides Function ProcessaXmlDocument(ByVal messaggio As System.Xml.XmlDocument,
                                                  ByVal settings As ConfigurationSettings) As System.Xml.XmlDocument

        DiagnosticsHelper.WriteDiagnostics("Stato.ProcessaXmlDocument()")

        Dim statoParameter As StatoParameterTypes.StatoParameter = Nothing
        Dim statoReturn As StatoReturnTypes.StatoReturn = Nothing
        '
        ' B E G I N
        '
        Try
            '
            ' Deserializzo il messaggio
            '
            statoParameter = DataContractSerializerHelper.Deserialize(Of StatoParameterTypes.StatoParameter)(messaggio.OuterXml)

            If statoParameter Is Nothing OrElse statoParameter.StatoQueue Is Nothing Then
                Throw New OrderEntryInvalidRequestException(My.User.Name, "Errore durante la deserializzazione dello stato.")
            Else
                statoReturn = ProcessaMessaggio(statoParameter, settings)
            End If
            '
            ' Risposta
            '
            Dim response As New XmlDocument()
            response.LoadXml(DataContractSerializerHelper.GetXML(statoReturn))
            Return response

        Catch ex As Exception
            '
            ' Throw dell'eccezione
            '
            Throw ex
        End Try
    End Function


    Private Function Validate(ByVal messaggio As StatoParameterTypes.StatoParameter) As Boolean
        DiagnosticsHelper.WriteDiagnostics("Stato.Validate()")

        If messaggio.StatoQueue Is Nothing Then
            Throw New OrderEntryArgumentNullException("Stato")
        End If

        If String.IsNullOrEmpty(messaggio.StatoQueue.Utente) Then
            Throw New OrderEntryArgumentNullException("Stato.Utente")
        End If

        If Not [Enum].IsDefined(GetType(OE.Core.Schemas.Msg.QueueTypes.TipoOperazioneType), messaggio.StatoQueue.TipoOperazione) Then
            Throw New OrderEntryNotFoundException("ENUM StatoTestataErogatoOrderEntryEnum", messaggio.StatoQueue.TipoOperazione.ToString)
        End If

        If Not [Enum].IsDefined(GetType(OE.Core.Schemas.Msg.QueueTypes.TipoStatoType), messaggio.StatoQueue.TipoStato) Then
            Throw New OrderEntryNotFoundException("ENUM StatoTestataErogatoOrderEntryEnum", messaggio.StatoQueue.TipoStato.ToString)
        End If

        If messaggio.StatoQueue.Testata Is Nothing Then
            Throw New OrderEntryArgumentNullException("Stato.Testata")
        End If

        Dim testata As OE.Core.Schemas.Msg.QueueTypes.TestataStatoType = messaggio.StatoQueue.Testata

        If Not String.IsNullOrEmpty(testata.StatoOrderEntry) Then
            If Not [Enum].IsDefined(GetType(OE.Core.Schemas.Msg.QueueTypes.StatoTestataErogatoOrderEntryEnum), testata.StatoOrderEntry) Then
                Throw New OrderEntryNotFoundException("ENUM StatoTestataErogatoOrderEntryEnum", testata.StatoOrderEntry)
            End If
        End If

        If messaggio.StatoQueue.Testata.RigheErogate IsNot Nothing Then
            For Each riga As QueueTypes.RigaErogataType In messaggio.StatoQueue.Testata.RigheErogate

                If Not String.IsNullOrEmpty(riga.StatoOrderEntry) Then
                    If Not [Enum].IsDefined(GetType(OE.Core.Schemas.Msg.QueueTypes.StatoRigaErogataOrderEntryEnum), riga.StatoOrderEntry) Then
                        Throw New OrderEntryNotFoundException("ENUM StatoTestataErogatoOrderEntryEnum", riga.StatoOrderEntry)
                    End If
                End If

                If riga.Prestazione Is Nothing Then
                    Throw New OrderEntryArgumentNullException(String.Format("Stato.Testata.RigheErogate.Riga({0}).Prestazione", riga.IdRigaRichiedente))
                End If

                If String.IsNullOrEmpty(riga.Prestazione.Codice) Then
                    Throw New OrderEntryArgumentNullException(String.Format("Stato.Testata.RigheErogate.Riga({0}).Prestazione.Codice", riga.IdRigaRichiedente))
                End If
            Next
        End If
        '
        ' Return
        '
        Return True

    End Function

End Class