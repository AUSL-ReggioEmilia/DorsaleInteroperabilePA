Imports System.Threading
Imports System.Xml
Imports OE.Core
Imports OE.Core.Schemas.Msg
Imports OE.Core.Schemas.Msg.QueueTypes

<Serializable()>
<CLSCompliant(True)>
Public Class MessaggioRichiesta
    Inherits MessaggioBase(Of RichiestaParameterTypes.RichiestaParameter, RichiestaReturnTypes.RichiestaReturn)

    Public Sub New()
    End Sub

    Public Overrides Function ProcessaMessaggio(ByVal messaggio As RichiestaParameterTypes.RichiestaParameter,
                                                ByVal settings As ConfigurationSettings) As RichiestaReturnTypes.RichiestaReturn
        Dim IdTicket As Guid
        Dim idTestata As Guid
        Dim idTracking As Nullable(Of Guid)
        Dim taRichiesta As RichiestaAdapter = Nothing

        ' B E G I N
        Try
            '######################################################
            ' Prima cosa da fare Initialize(settings)
            '######################################################
            '
            ' Init Custom settings
            ConfigurationHelper.Initialize(settings)

            ' Trace
            DiagnosticsHelper.WriteDiagnostics("Richiesta.ProcessaMessaggio()")
            DiagnosticsHelper.WriteDiagnostics("--InitAdapters")

            taRichiesta = New RichiestaAdapter(ConfigurationHelper.ConnectionString)
            taRichiesta.BeginTransaction(ConfigurationHelper.TransactionIsolationLevel)

            ' Validazione del messaggio
            Validate(messaggio)

            ' Trace message
            DiagnosticsHelper.WriteDiagnostics(DataContractSerializerHelper.GetXML(messaggio))

            ' Get del ticket di autenticazione
            Using ta As New TicketAdapter(ConfigurationHelper.ConnectionString)
                IdTicket = ta.GetTicketId(messaggio.RichiestaQueue.Utente, ConfigurationHelper.Ttl)
            End Using

            ' Consolido attributo Data (data di versione)
            If messaggio.RichiestaQueue.Testata.Data Is Nothing Then messaggio.RichiestaQueue.Testata.Data = DateTime.Now

            'Transcodifico le UO Richiedente->Core
            SacHelper.TranscodificaUnitaOperativaIngresso(messaggio.RichiestaQueue)

            ' Tracking
            Using taMessaggio = New MessaggioAdapter(taRichiesta.Connection.ConnectionString)
                idTracking = taMessaggio.MessaggioOrdineInsert(IdTicket, messaggio, MessaggioAdapter.Stato.Inserito, Nothing, Nothing, Nothing, Nothing)

                ' Elaboro l'ordine
                idTestata = taRichiesta.Elabora(IdTicket, messaggio.RichiestaQueue.Testata)

                ' Commit
                taRichiesta.Commit()

                'Ricalcola anteprima e salva in testata
                ' Ci potrebbero essere delle descrizioni di prestazioni diverse sul DB
                taRichiesta.RicalcolaAnteprima(IdTicket, idTestata)

                ' Tracking
                taMessaggio.MessaggioOrdineUpdate(IdTicket, idTracking, MessaggioAdapter.Stato.Processato, idTestata)
            End Using

            ' Aggiorno il sotto-stato della richiesta
            taRichiesta.MsgOrdiniTestateStatusUpdate(IdTicket, idTestata, SottoStatiOrderEntry.TestataRichiesta.INO_00.ToString())

            ' Risposta (split)
            Dim response As RichiestaReturnTypes.RichiestaReturn = SplitOut(messaggio.RichiestaQueue)

            'Se ci sono delle righe processo la risposta
            If response IsNot Nothing AndAlso response.RichiesteQueue IsNot Nothing AndAlso
                                              response.RichiesteQueue.Count > 0 Then


                ' Elaboro la/e testata/e dell'ordine erogato
                ' Se c'è piu di un erogante, all'IdOrderEntry sara aggiunto l'indice di split usando @ come separatore
                ElaboraTestateErogate(IdTicket, response, idTestata)

                DiagnosticsHelper.WriteDiagnostics(String.Concat("Richiesta processata con successo.", vbCrLf, vbCrLf,
                                                                 DataContractSerializerHelper.GetXML(response)))

                'Rimuovo dalla collection gli item che hanno l'operazione O.E. di testata diverso da IN, SR, CA
                response.RichiesteQueue.RemoveAll(Function(e) IsRichiesteInoltrabile(e) = False)

                'Transcodifico le UO Core->Erogante
                SacHelper.TranscodificaUnitaOperativaUscita(response.RichiesteQueue)
            Else
                DiagnosticsHelper.WriteDiagnostics(String.Concat("Richiesta (senza righe) processata con successo.", vbCrLf, vbCrLf,
                                                                 DataContractSerializerHelper.GetXML(response)))
            End If

            ' Return
            Return response

        Catch ex As Exception
            '
            ' Rollback
            '
            If taRichiesta IsNot Nothing Then
                taRichiesta.Rollback()
            End If
            '
            ' Aggiorno lo stato del messaggio originale (NO Throw ERROR)
            '
            Try
                Using taMessaggio = New MessaggioAdapter(ConfigurationHelper.ConnectionString)

                    If idTracking Is Nothing Then
                        '
                        ' TODO: Valutare di inserire direttamente un messaggio di ERRORE
                        '
                        idTracking = taMessaggio.MessaggioOrdineInsert(IdTicket, messaggio, MessaggioAdapter.Stato.Inserito, Nothing, Nothing, Nothing, Nothing)
                    End If
                    '
                    ' Fault sul DB
                    '
                    Dim fault As New RichiestaFault("Richiesta.ProcessaMessaggio()", ex, messaggio)
                    taMessaggio.MessaggioOrdineUpdate(IdTicket, idTracking, MessaggioAdapter.Stato.Errore, Nothing, fault)
                End Using
            Catch
                DiagnosticsHelper.WriteError(ex)
            End Try

            ' RE-Throw
            '
            Throw

        Finally

            ' Rilascio tutte le risorse
            If taRichiesta IsNot Nothing Then
                taRichiesta.Dispose()
            End If
        End Try

    End Function

    Public Overrides Function ProcessaXmlDocument(ByVal messaggio As System.Xml.XmlDocument,
                                                  ByVal settings As ConfigurationSettings) As System.Xml.XmlDocument

        DiagnosticsHelper.WriteDiagnostics("Richiesta.ProcessaXmlDocument()")

        Dim richiestaParameter As RichiestaParameterTypes.RichiestaParameter = Nothing
        Dim richiestaReturn As RichiestaReturnTypes.RichiestaReturn = Nothing
        '
        ' B E G I N
        '
        Try
            '
            ' Deserializzo il messaggio
            '
            richiestaParameter = DataContractSerializerHelper.Deserialize(Of RichiestaParameterTypes.RichiestaParameter)(messaggio.OuterXml)

            If richiestaParameter Is Nothing OrElse richiestaParameter.RichiestaQueue Is Nothing Then
                Throw New OrderEntryInvalidRequestException(My.User.Name, "Errore durante la deserializzazione della richiesta.")
            Else
                richiestaReturn = ProcessaMessaggio(richiestaParameter, settings)
            End If

            '
            ' Risposta
            '
            Dim response As New XmlDocument()
            response.LoadXml(DataContractSerializerHelper.GetXML(richiestaReturn))
            Return response

        Catch ex As Exception
            '
            ' Throw dell'eccezione
            '
            Throw ex
        End Try
    End Function


    Private Function Validate(ByVal messaggio As RichiestaParameterTypes.RichiestaParameter) As Boolean
        DiagnosticsHelper.WriteDiagnostics("Richiesta.Validate()")

        If messaggio.RichiestaQueue Is Nothing Then
            Throw New OrderEntryArgumentNullException("Richiesta")
        End If

        If String.IsNullOrEmpty(messaggio.RichiestaQueue.Utente) Then
            Throw New OrderEntryArgumentNullException("Richiesta.Utente")
        End If

        If messaggio.RichiestaQueue.Testata Is Nothing Then
            Throw New OrderEntryArgumentNullException("Richiesta.Testata")
        End If

        If messaggio.RichiestaQueue.Testata.SistemaRichiedente Is Nothing Then
            Throw New OrderEntryArgumentNullException("Richiesta.Testata.SistemaRichiedente")
        End If

        If String.IsNullOrEmpty(messaggio.RichiestaQueue.Testata.IdRichiestaRichiedente) Then
            Throw New OrderEntryArgumentNullException("Richiesta.Testata.IdRichiestaRichiedente")
        End If

        If String.IsNullOrEmpty(messaggio.RichiestaQueue.Testata.OperazioneOrderEntry) Then
            Throw New OrderEntryArgumentNullException("Richiesta.Testata.OperazioneOrderEntry")
        Else
            If Not [Enum].IsDefined(GetType(OE.Core.Schemas.Msg.QueueTypes.OperazioneTestataRichiestaOrderEntryEnum), messaggio.RichiestaQueue.Testata.OperazioneOrderEntry) Then
                Throw New OrderEntryNotFoundException("ENUM OperazioneTestataRichiestaOrderEntryEnum", messaggio.RichiestaQueue.Testata.OperazioneOrderEntry)
            End If
        End If

        If messaggio.RichiestaQueue.Testata.RigheRichieste Is Nothing Then
            Throw New OrderEntryArgumentNullException("Richiesta.Testata.RigheRichieste")
        End If

        For Each riga As QueueTypes.RigaRichiestaType In messaggio.RichiestaQueue.Testata.RigheRichieste

            If Not String.IsNullOrEmpty(riga.OperazioneOrderEntry) Then
                If Not [Enum].IsDefined(GetType(OE.Core.Schemas.Msg.QueueTypes.OperazioneRigaRichiestaOrderEntryEnum), riga.OperazioneOrderEntry) Then
                    Throw New OrderEntryNotFoundException("ENUM OperazioneRigaRichiestaOrderEntryEnum", riga.OperazioneOrderEntry)
                End If
            End If

            If riga.SistemaErogante Is Nothing Then
                Throw New OrderEntryArgumentNullException(String.Format("Richiesta.Testata.RigheRichieste.Riga({0}).SistemaErogante", riga.IdRigaRichiedente))
            End If

            If riga.Prestazione Is Nothing Then
                Throw New OrderEntryArgumentNullException(String.Format("Richiesta.Testata.RigheRichieste.Riga({0}).Prestazione", riga.IdRigaRichiedente))
            End If

            If String.IsNullOrEmpty(riga.Prestazione.Codice) Then
                Throw New OrderEntryArgumentNullException(String.Format("Richiesta.Testata.RigheRichieste.Riga({0}).Prestazione.Codice", riga.IdRigaRichiedente))
            End If
        Next

        Return True

    End Function

    Private Function SplitOut(obj As QueueTypes.RichiestaQueueType) As RichiestaReturnTypes.RichiestaReturn
        '
        ' Split della risposta quando le prestazioni sono erogate da sistemi differenti
        '
        DiagnosticsHelper.WriteDiagnostics("Richiesta.SplitOut()")

        Dim response As New RichiestaReturnTypes.RichiestaReturn()
        Dim richiesteQueue As New RichiestaReturnTypes.RichiesteQueueType()

        Dim utente = obj.Utente

        ' Distinct per sistemi eroganti
        Dim sistemi = (From c In obj.Testata.RigheRichieste
                       Select c.SistemaErogante.Sistema.Codice).Distinct().ToList()

        For Each sistema In sistemi

            Dim sCodiceSistemaErogante As String = sistema

            ' Serializzo la testata del messaggio originale
            Dim original = DataContractSerializerHelper.Serialize(Of QueueTypes.TestataRichiestaType)(obj.Testata)

            ' Clono la testata
            Dim testata As QueueTypes.TestataRichiestaType = DataContractSerializerHelper.Deserialize(Of QueueTypes.TestataRichiestaType)(original)

            ' Rimuovo dalla testata clonata le righe richieste col sistema erogante diverso da quello corrente
            testata.RigheRichieste.RemoveAll(Function(e) String.Compare(e.SistemaErogante.Sistema.Codice, sCodiceSistemaErogante, True) <> 0)

            ' Creo la richiesta da aggiungere alla collection di risposta
            Dim richiesta As New QueueTypes.RichiestaQueueType() With {.Utente = utente, .Testata = testata}

            ' Add della richiesta alla collection
            richiesteQueue.Add(richiesta)
        Next

        response.RichiesteQueue = richiesteQueue

        Return response
    End Function

    Private Sub ElaboraTestateErogate(ticket As Guid, ByRef response As RichiestaReturnTypes.RichiestaReturn, testataID As Guid)
        '
        ' Elaboro la/e testata/e dell'erogato
        '
        ' Modificata il 2018-06-12: Calcolo IdSplit, il primo sarà sempre NULL, il secondo sarà 2 e così via.
        '                           Durante aggiornamento verifica se precedentemente era già stato
        '                               assegnato un ID al SE e lo riusa per mantenere coerenza
        '                               
        '
        DiagnosticsHelper.WriteDiagnostics("Richiesta.ElaboraTestateErogate()")

        Dim statoAdapter As StatoAdapter = Nothing
        Dim idSplit As Byte? = Nothing

        Try
            '
            ' Se ci sono richieste da inviare le processo
            '
            If response.RichiesteQueue IsNot Nothing AndAlso response.RichiesteQueue.Count > 0 Then
                '
                ' Creo adattatore DB
                '
                statoAdapter = New StatoAdapter(ConfigurationHelper.ConnectionString)
                statoAdapter.BeginTransaction(ConfigurationHelper.TransactionIsolationLevel)
                '
                ' Legge IdSplit già assegnati se una modifica
                '
                Dim IdRichiestaOrderEntry As String = response.RichiesteQueue(0).Testata.IdRichiestaOrderEntry
                Dim dicSistemaEroganteIdSplit As Dictionary(Of Guid, Byte?) = statoAdapter.LeggeSistemaEroganteIdSplit(IdRichiestaOrderEntry)
                '
                ' Uso per ottenere dati sistemi
                '
                Using organigrammaAdapter = New OrganigrammaAdapter(ConfigurationHelper.ConnectionString)
                    '
                    ' Cerco dati del sistema richiedente, uso il primo messaggio
                    '
                    Dim codiceAziendaSistemaRichiedente = response.RichiesteQueue(0).Testata.SistemaRichiedente.Azienda.Codice
                    Dim codiceSistemaRichiedente = response.RichiesteQueue(0).Testata.SistemaRichiedente.Sistema.Codice

                    Dim sistemaRichiedente As OrganigrammaDS.SistemaRow = organigrammaAdapter.GetSistemaByCodice(codiceSistemaRichiedente, codiceAziendaSistemaRichiedente)
                    '
                    ' Loop su tutti i messaggi da inviae, uno per Sistema erogante
                    '
                    For Each item In response.RichiesteQueue
                        '
                        ' Cerco dati del sistema erogante, uso la prima Riga Richiesta
                        '
                        Dim codiceAziendaSistemaErogante = item.Testata.RigheRichieste(0).SistemaErogante.Azienda.Codice
                        Dim codiceSistemaErogante = item.Testata.RigheRichieste(0).SistemaErogante.Sistema.Codice

                        Dim sistemaErogante As OrganigrammaDS.SistemaRow = organigrammaAdapter.GetSistemaByCodice(codiceSistemaErogante, codiceAziendaSistemaErogante)
                        '
                        ' #######################################################
                        ' Cerco se IdSplit già assegnato
                        '  Se è una modifica gli IdSplit sono già assegnati e vanno rispettati
                        '
                        If dicSistemaEroganteIdSplit IsNot Nothing AndAlso dicSistemaEroganteIdSplit.Count > 0 Then

                            If Not dicSistemaEroganteIdSplit.TryGetValue(sistemaErogante.ID, idSplit) Then
                                '
                                ' Non trovato precedente del sistema erogante
                                '  Prendo in MAX più 1 dei precedenti
                                '
                                idSplit = dicSistemaEroganteIdSplit.Values.Max
                                If idSplit.HasValue Then
                                    idSplit = CType(idSplit + 1, Byte?)
                                Else
                                    '
                                    ' Salto il 1, per equipararlo al vuoto
                                    '
                                    idSplit = 2
                                End If
                                '
                                ' Salvo per il prossimo max
                                '
                                dicSistemaEroganteIdSplit.Add(sistemaErogante.ID, idSplit)
                            End If
                        End If
                        '
                        ' #######################################################
                        ' Compongo l'IdRichiestaOrderEntry da inviare con IdSplit appropriato
                        '
                        If idSplit.HasValue Then
                            item.Testata.IdRichiestaOrderEntry = String.Concat(item.Testata.IdRichiestaOrderEntry, "@", idSplit)
                        End If
                        '
                        ' Elaboro la testata erogata
                        '
                        statoAdapter.PreparaTestata(ticket, testataID, sistemaRichiedente.ID, item.Testata.IdRichiestaRichiedente,
                                                    sistemaErogante.ID, idSplit)

                        ' #######################################################
                        '  Se è una primo inoltro gli IdSplit non sono già assegnati
                        '   Gestito dopo PreparaTestata perchè il primo sara un NULL
                        '
                        If dicSistemaEroganteIdSplit Is Nothing OrElse dicSistemaEroganteIdSplit.Count = 0 Then

                            If idSplit.HasValue Then
                                idSplit = CType(idSplit + 1, Byte?)
                            Else
                                '
                                ' Salto il 1, per equipararlo al vuoto
                                '
                                idSplit = 2
                            End If
                        End If
                    Next
                End Using

                ' Commit
                statoAdapter.Commit()
            End If

        Catch ex As Exception

            ' Rollback
            If statoAdapter IsNot Nothing Then
                statoAdapter.Rollback()
            End If

            ' Fault
            DiagnosticsHelper.WriteError(ex)
        Finally

            ' Rilascio tutte le risorse
            If statoAdapter IsNot Nothing Then statoAdapter.Dispose()
        End Try

    End Sub

    Private Function IsRichiesteInoltrabile(item As RichiestaQueueType) As Boolean
        '
        ' Controlla se la richiesta ha l'operazione OE di testata IN, SR, CA
        '
        If item.Testata.OperazioneOrderEntry = OperazioneTestataRichiestaOrderEntryEnum.IN.ToString OrElse
                  item.Testata.OperazioneOrderEntry = OperazioneTestataRichiestaOrderEntryEnum.SR.ToString OrElse
                  item.Testata.OperazioneOrderEntry = OperazioneTestataRichiestaOrderEntryEnum.CA.ToString Then
            Return True
        Else
            Return False
        End If

    End Function

End Class