Imports OE.Core
Imports OE.Core.Schemas.Msg
Imports OE.Core.Schemas.Msg.QueueTypes

<Serializable()>
Public NotInheritable Class StatoHelper
    Private Sub New()
    End Sub

    ''' <summary>
    ''' Calcola lo stato di testata. controlla se stato in testata oppure tutte righe erogate prendendo il valore minomo IC-IP-CM-CA
    ''' </summary>
    Public Shared Function GetStatoOrderEntryTestataStato(ByVal obj As QueueTypes.TestataStatoType) As String

        If Not String.IsNullOrEmpty(obj.StatoOrderEntry) Then

            ' C'e in testata ritorno quello
            Return obj.StatoOrderEntry
        Else
            Dim sStato As String = Nothing

            If obj.RigheErogate IsNot Nothing AndAlso obj.RigheErogate.Count > 0 Then

                ' Controlla tutte le righe
                For Each riga As QueueTypes.RigaErogataType In obj.RigheErogate

                    ' Setta come stato il minimo da IC-IP-CM-CA tra tutte le righe
                    If riga.StatoOrderEntry = StatoTestataErogatoOrderEntryEnum.CA.ToString Then

                        If String.IsNullOrEmpty(sStato) Then
                            sStato = StatoTestataErogatoOrderEntryEnum.CA.ToString
                        End If
                    End If

                    If riga.StatoOrderEntry = StatoTestataErogatoOrderEntryEnum.CM.ToString Then

                        If String.IsNullOrEmpty(sStato) Or sStato = StatoTestataErogatoOrderEntryEnum.CA.ToString Then
                            sStato = StatoTestataErogatoOrderEntryEnum.CM.ToString
                        End If

                    ElseIf riga.StatoOrderEntry = StatoTestataErogatoOrderEntryEnum.IP.ToString Then

                        If String.IsNullOrEmpty(sStato) Or sStato = StatoTestataErogatoOrderEntryEnum.CA.ToString _
                                                        Or sStato = StatoTestataErogatoOrderEntryEnum.CM.ToString Then
                            sStato = StatoTestataErogatoOrderEntryEnum.IP.ToString
                        End If

                    ElseIf riga.StatoOrderEntry = StatoTestataErogatoOrderEntryEnum.IC.ToString Then

                        If String.IsNullOrEmpty(sStato) Or sStato = StatoTestataErogatoOrderEntryEnum.CA.ToString _
                                                        Or sStato = StatoTestataErogatoOrderEntryEnum.CM.ToString _
                                                        Or sStato = StatoTestataErogatoOrderEntryEnum.IP.ToString Then
                            sStato = StatoTestataErogatoOrderEntryEnum.IC.ToString
                        End If
                    End If

                Next
            End If

            Return sStato
        End If

    End Function

    Public Shared Function GetStatoOrderEntryTestataStato(StatoTestataOrderEntry As String, _
                                                          ByVal righeErogateRow() As StatoDS.RigaErogataRow) As String

        If Not String.IsNullOrEmpty(StatoTestataOrderEntry) Then

            If Not [Enum].IsDefined(GetType(StatoTestataErogatoOrderEntryEnum), StatoTestataOrderEntry) Then
                Throw New OrderEntryNotFoundException("ENUM StatoTestataErogatoOrderEntryEnum", StatoTestataOrderEntry)
            End If

            Return StatoTestataOrderEntry
        Else
            Dim sStato As String = Nothing

            If righeErogateRow IsNot Nothing AndAlso righeErogateRow.Length > 0 Then
                '
                ' Controlla tutte le righe del DB
                '
                For Each riga As StatoDS.RigaErogataRow In righeErogateRow
                    '
                    ' Setta come stato il minimo da IC-IP-CM-CA tra tutte le righe
                    '
                    If riga.StatoOrderEntry = StatoTestataErogatoOrderEntryEnum.CA.ToString Then

                        If String.IsNullOrEmpty(sStato) Then
                            sStato = StatoTestataErogatoOrderEntryEnum.CA.ToString
                        End If
                    End If

                    If riga.StatoOrderEntry = StatoTestataErogatoOrderEntryEnum.CM.ToString Then

                        If String.IsNullOrEmpty(sStato) Or sStato = StatoTestataErogatoOrderEntryEnum.CA.ToString Then
                            sStato = StatoTestataErogatoOrderEntryEnum.CM.ToString
                        End If

                    ElseIf riga.StatoOrderEntry = StatoTestataErogatoOrderEntryEnum.IP.ToString Then

                        If String.IsNullOrEmpty(sStato) Or sStato = StatoTestataErogatoOrderEntryEnum.CA.ToString _
                                                        Or sStato = StatoTestataErogatoOrderEntryEnum.CM.ToString Then
                            sStato = StatoTestataErogatoOrderEntryEnum.IP.ToString
                        End If

                    ElseIf riga.StatoOrderEntry = StatoTestataErogatoOrderEntryEnum.IC.ToString Then

                        If String.IsNullOrEmpty(sStato) Or sStato = StatoTestataErogatoOrderEntryEnum.CA.ToString _
                                                        Or sStato = StatoTestataErogatoOrderEntryEnum.CM.ToString _
                                                        Or sStato = StatoTestataErogatoOrderEntryEnum.IP.ToString Then
                            sStato = StatoTestataErogatoOrderEntryEnum.IC.ToString
                        End If
                    End If

                Next
            End If

            Return sStato
        End If

    End Function

    ''' <summary>
    ''' Calcola tutti gli stati di testata erogata via tipo stato
    ''' </summary>
    Public Shared Function GetStatiTestataStato(ByVal obj As QueueTypes.StatoQueueType, ByVal testata As StatoDS.TestataRow, richiesta As OrdiniDS.TestataRow,
                                                ByRef statoOrderEntry As String, ByRef sottoStatoOrderEntry As String, ByRef statoRisposta As String) As Boolean
        Dim result As Boolean = False

        Try
            If obj.TipoStato = QueueTypes.TipoStatoType.RR Then
                '
                ' RICHIESTA RISPOSTA
                '
                If testata IsNot Nothing Then
                    Dim testataStatoRisposta As String = Nothing

                    If obj.TipoOperazione = TipoOperazioneType.Incrementale Then
                        '
                        ' Stato OSU letto dal DB perchè potrebbe essere arrivato prima della risposta RR
                        '
                        statoOrderEntry = If(testata.IsStatoOrderEntryNull(), Nothing, testata.StatoOrderEntry)
                        sottoStatoOrderEntry = If(testata.IsSottoStatoOrderEntryNull(), SottoStatiOrderEntry.TestataStato.ARR_10.ToString() _
                                                                                    , testata.SottoStatoOrderEntry)
                        testataStatoRisposta = If(testata.IsStatoRispostaNull(), Nothing, testata.StatoRisposta)
                    Else
                        statoOrderEntry = Nothing
                        sottoStatoOrderEntry = SottoStatiOrderEntry.TestataStato.ARR_10.ToString()
                    End If

                    ' Calcola StatoRisposta in modo incrementale
                    statoRisposta = SetStatoRisposta(obj.Testata.StatoOrderEntry, testataStatoRisposta)
                Else

                    statoOrderEntry = Nothing
                    sottoStatoOrderEntry = Nothing

                    statoRisposta = SetStatoRisposta(obj.Testata.StatoOrderEntry, Nothing)
                End If

            ElseIf obj.TipoStato = QueueTypes.TipoStatoType.OSU Then
                '
                ' ORDER STATUS UPDATE
                '

                ' Se incrementale non controllo le righe
                If obj.TipoOperazione = TipoOperazioneType.Completo Then

                    ' Calcola lo stato erogante testata e se manca tra tutte le righe
                    statoOrderEntry = StatoHelper.GetStatoOrderEntryTestataStato(obj.Testata)
                Else
                    ' C'e in testata ritorno quello
                    statoOrderEntry = obj.Testata.StatoOrderEntry
                End If

                ' Sottostsato ARRIVATO
                sottoStatoOrderEntry = SottoStatiOrderEntry.TestataStato.ARR_10.ToString()

                ' Stato risposata letta dal DB perchè arrivata con il precedente messaggio RR (oppure arriverà)
                If testata IsNot Nothing AndAlso Not testata.IsStatoRispostaNull() Then
                    statoRisposta = testata.StatoRisposta
                End If
            End If

            result = True

        Catch ex As OrderEntryDataVersioneMismatchException
            Throw ex

        Catch ex As Exception
            DiagnosticsHelper.WriteDiagnostics("Errore del metodo StatiOrderEntry.GetStatiTestataStato()")
            DiagnosticsHelper.WriteWarning(ex)
        End Try

        '
        ' Return
        '
        Return result

    End Function

    ''' <summary>
    ''' Calcolo lo StatoRisposta in modo incrementale rispetto al valore gia salvato AA-AE-AR-SE
    ''' </summary>
    Private Shared Function SetStatoRisposta(ByVal msgStatoRisposta As String, testataStatoRisposta As String) As String

        ' Ritorno nothing se tutti i dati vuoti
        If String.IsNullOrEmpty(testataStatoRisposta) AndAlso String.IsNullOrEmpty(msgStatoRisposta) Then Return Nothing

        ' Ritorno StatoRisposta del MESSAGGIO se dati da DB vuoti
        If String.IsNullOrEmpty(testataStatoRisposta) AndAlso Not String.IsNullOrEmpty(msgStatoRisposta) Then
            Return DirectCast([Enum].Parse(GetType(StatiOrderEntry.Risposta), msgStatoRisposta), StatiOrderEntry.Risposta).ToString()
        End If

        ' Calcolo se DB e MESSAGGIO valorizzati
        If Not String.IsNullOrEmpty(testataStatoRisposta) AndAlso Not String.IsNullOrEmpty(msgStatoRisposta) Then

            ' Se lo stato del messaggio o quello salvato contiene un errore NON controllo Stato Risposta già salvato sul DB
            Dim check As Boolean
            If msgStatoRisposta = StatiOrderEntry.Risposta.AE.ToString OrElse
                                    msgStatoRisposta = StatiOrderEntry.Risposta.AR.ToString OrElse
                                    testataStatoRisposta = StatiOrderEntry.Risposta.AE.ToString OrElse
                                    testataStatoRisposta = StatiOrderEntry.Risposta.AR.ToString Then

                check = False
            Else
                check = True
            End If

            ' valuto la priorita fra lo stato risposta salvato e quello del messaggio se è la stessa versione
            If DirectCast([Enum].Parse(GetType(StatiOrderEntry.Risposta), testataStatoRisposta), StatiOrderEntry.Risposta) >=
                DirectCast([Enum].Parse(GetType(StatiOrderEntry.Risposta), msgStatoRisposta), StatiOrderEntry.Risposta) AndAlso check Then

                ' Lo stato sul DB è già più avanti salvo lo stesso letto
                Return DirectCast([Enum].Parse(GetType(StatiOrderEntry.Risposta), testataStatoRisposta), StatiOrderEntry.Risposta).ToString()
            Else

                ' Salvo il nuovo sato da MESSAGGIO
                Return DirectCast([Enum].Parse(GetType(StatiOrderEntry.Risposta), msgStatoRisposta), StatiOrderEntry.Risposta).ToString()
            End If

        End If

        ' Ritorno StatoRisposta da DB se MESSAGGIO vuoto
        If Not String.IsNullOrEmpty(testataStatoRisposta) AndAlso String.IsNullOrEmpty(msgStatoRisposta) Then
            Return DirectCast([Enum].Parse(GetType(StatiOrderEntry.Risposta), testataStatoRisposta), StatiOrderEntry.Risposta).ToString()
        End If

        Return Nothing
    End Function

End Class
