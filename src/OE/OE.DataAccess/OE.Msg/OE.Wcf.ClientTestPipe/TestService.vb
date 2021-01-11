Imports System.Runtime.Serialization

Public Class TestService

    Private Sub TestService_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        '
        ' Leggo URI dai servizi
        '
        Try

#If DEBUG Then
            TextBoxUriRichiesta.Text = "net.pipe://localhost/OeDataAccess/Richiesta"
            'TextBoxUriRichiesta.Text = "http://localhost/OeDataAccess/Richiesta"
#Else
            TextBoxUriRichiesta.Text = "net.pipe://localhost/OeDataAccess/OE.Wcf.BtDataAccess.Richiesta.svc"
#End If

        Catch ex As Exception
            TextBoxUriRichiesta.Text = ex.Message
        End Try

        Try

#If DEBUG Then
            TextBoxUriStato.Text = "net.pipe://localhost/OeDataAccess/Stato"
            'TextBoxUriStato.Text = "http://localhost/OeDataAccess/Stato"
#Else
            TextBoxUriStato.Text = "net.pipe://localhost/OeDataAccess/OE.Wcf.BtDataAccess.Stato.svc"
#End If

        Catch ex As Exception
            TextBoxUriStato.Text = ex.Message
        End Try

        Try

#If DEBUG Then
            TextBoxUriOrdine.Text = "net.pipe://localhost/OeDataAccess/Ordine"
            'TextBoxUriOrdine.Text = "http://localhost/OeDataAccess/Ordine"
#Else
            TextBoxUriOrdine.Text = "net.pipe://localhost/OeDataAccess/OE.Wcf.BtDataAccess.Ordine.svc"
#End If

        Catch ex As Exception
            TextBoxUriOrdine.Text = ex.Message
        End Try

    End Sub


    Private Sub ButtonRichiesta_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ButtonRichiesta.Click

        Try
            Dim sUrl As String = TextBoxUriRichiesta.Text
            Dim sEndpoint As String

            If sUrl.StartsWith("http") Then
                sEndpoint = "httpRichiesta"
            Else
                sEndpoint = "pipeRichiesta"
            End If

            Dim oService As New ServiceRichiesta.RichiestaClient(sEndpoint)

            If sUrl.Length > 0 Then
                oService.Endpoint.Address = New ServiceModel.EndpointAddress(sUrl)
            End If

            TextBoxOutput.Text = "-->Endpoint.Address:" & oService.Endpoint.Address.ToString
            TextBoxOutput.Text = TextBoxOutput.Text & vbCrLf & "-->Start: " & DateTime.Now
            TextBoxOutput.Refresh()
            '
            ' Test metodo tipizzato
            '
            Dim oParam As ServiceRichiesta.RichiestaParameter
            Dim oReturn As ServiceRichiesta.RichiestaReturn

            Using stream As New IO.MemoryStream
                Dim encoding As System.Text.Encoding = System.Text.Encoding.UTF8
                stream.Write(encoding.GetBytes(TextBoxInput.Text), 0, encoding.GetByteCount(TextBoxInput.Text))
                stream.Position = 0

                Dim oDataSerializer As New DataContractSerializer(GetType(ServiceRichiesta.RichiestaParameter))
                oParam = CType(oDataSerializer.ReadObject(stream), ServiceRichiesta.RichiestaParameter)
            End Using
            '
            ' Valorizzo DATI
            '
            If Not String.IsNullOrEmpty(TextBoxIdOrderEntry.Text) Then
                oParam.RichiestaQueue.Testata.IdRichiestaOrderEntry = TextBoxIdOrderEntry.Text
            End If

            If Not String.IsNullOrEmpty(TextBoxIdRichiesta.Text) Then
                oParam.RichiestaQueue.Testata.IdRichiestaRichiedente = TextBoxIdRichiesta.Text
            End If
            '
            ' Eseguo METODO
            '
            oReturn = oService.ProcessaMessaggio(oParam)
            '
            ' RISULTATO
            '
            Using stream As New IO.MemoryStream
                Dim oDataSerializer As New DataContractSerializer(GetType(ServiceRichiesta.RichiestaReturn))
                oDataSerializer.WriteObject(stream, oReturn)
                stream.Position = 0
                '
                ' Output
                '
                TextBoxOutput.Text = TextBoxOutput.Text & vbCrLf & "-->Stop: " & DateTime.Now
                TextBoxOutput.Text = TextBoxOutput.Text & vbCrLf &
                                        System.Text.Encoding.UTF8.GetString(stream.ToArray)
            End Using

            If oReturn.RichiesteQueue.Count > 0 Then
                TextBoxIdOrderEntry.Text = oReturn.RichiesteQueue(0).Testata.IdRichiestaOrderEntry
            Else
                TextBoxIdOrderEntry.Text = "RichiesteQueue.Count=0"
            End If

        Catch ex As Exception
            '
            ' Error
            '
            MessageBox.Show(ex.Message)
        End Try

    End Sub

    Private Sub ButtonStato_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ButtonStato.Click

        Try
            Dim sUrl As String = TextBoxUriStato.Text
            Dim sEndpoint As String

            If sUrl.StartsWith("http") Then
                sEndpoint = "httpStato"
            Else
                sEndpoint = "pipeStato"
            End If

            Dim oService As New ServiceStato.StatoClient(sEndpoint)

            If sUrl.Length > 0 Then
                oService.Endpoint.Address = New ServiceModel.EndpointAddress(sUrl)
            End If

            TextBoxOutput.Text = "-->Endpoint.Address:" & oService.Endpoint.Address.ToString
            TextBoxOutput.Text = TextBoxOutput.Text & vbCrLf & "-->Start: " & DateTime.Now
            TextBoxOutput.Refresh()
            '
            ' Test metodo tipizzato
            '
            Dim oParam As ServiceStato.StatoParameter
            Dim oReturn As ServiceStato.StatoReturn

            oParam = New ServiceStato.StatoParameter

            Using stream As New IO.MemoryStream
                Dim encoding As System.Text.Encoding = System.Text.Encoding.UTF8
                stream.Write(encoding.GetBytes(TextBoxInput.Text), 0, encoding.GetByteCount(TextBoxInput.Text))
                stream.Position = 0

                Dim oDataSerializer As New DataContractSerializer(GetType(ServiceStato.StatoParameter))
                oParam = CType(oDataSerializer.ReadObject(stream), ServiceStato.StatoParameter)
            End Using
            '
            ' Valorizzo DATI
            '
            If Not String.IsNullOrEmpty(TextBoxIdOrderEntry.Text) Then
                oParam.StatoQueue.Testata.IdRichiestaOrderEntry = TextBoxIdOrderEntry.Text
            End If

            If Not String.IsNullOrEmpty(TextBoxIdRichiesta.Text) Then
                oParam.StatoQueue.Testata.IdRichiestaRichiedente = TextBoxIdRichiesta.Text
            End If
            '
            ' Eseguo METODO
            '
            oReturn = oService.ProcessaMessaggio(oParam)
            '
            ' RISULTATO
            '
            Using stream As New IO.MemoryStream
                Dim oDataSerializer As New DataContractSerializer(GetType(ServiceStato.StatoReturn))
                oDataSerializer.WriteObject(stream, oReturn)
                stream.Position = 0
                '
                ' Output
                '
                TextBoxOutput.Text = TextBoxOutput.Text & vbCrLf & "-->Stop: " & DateTime.Now
                TextBoxOutput.Text = TextBoxOutput.Text & vbCrLf &
                                        System.Text.Encoding.UTF8.GetString(stream.ToArray)
            End Using

        Catch ex As Exception
            '
            ' Error
            '
            MessageBox.Show(ex.Message)
        End Try

    End Sub

    Private Sub ButtonOrdine_Click(sender As System.Object, e As System.EventArgs) Handles ButtonOrdine.Click

        Try
            Dim sUrl As String = TextBoxUriOrdine.Text
            Dim sEndpoint As String

            If sUrl.StartsWith("http") Then
                sEndpoint = "httpOrdine"
            Else
                sEndpoint = "pipeOrdine"
            End If

            Dim oService As New ServiceOrdine.OrdineClient(sEndpoint)

            If sUrl.Length > 0 Then
                oService.Endpoint.Address = New ServiceModel.EndpointAddress(sUrl)
            End If

            TextBoxOutput.Text = "-->Endpoint.Address:" & oService.Endpoint.Address.ToString
            TextBoxOutput.Text = TextBoxOutput.Text & vbCrLf & "-->Start: " & DateTime.Now
            TextBoxOutput.Refresh()

            Dim sIdOrderEntry As String = TextBoxIdOrderEntry.Text
            '
            ' Test metodo tipizzato
            '
            Dim oReturn As ServiceOrdine.OrdineReturn
            oReturn = oService.OrdinePerIdOrderEntry(sIdOrderEntry)

            Using stream As New IO.MemoryStream
                Dim oDataSerializer As New DataContractSerializer(GetType(ServiceOrdine.OrdineReturn))
                oDataSerializer.WriteObject(stream, oReturn)
                stream.Position = 0
                '
                ' Output
                '
                TextBoxOutput.Text = TextBoxOutput.Text & vbCrLf & "-->Stop: " & DateTime.Now
                TextBoxOutput.Text = TextBoxOutput.Text & vbCrLf &
                                        System.Text.Encoding.UTF8.GetString(stream.ToArray)
            End Using

        Catch ex As Exception
            '
            ' Error
            '
            MessageBox.Show(ex.Message)
        End Try

    End Sub


    Private Sub ButtonDesRic_Click(sender As Object, e As EventArgs) Handles ButtonDesRic2.Click, ButtonDesRic.Click
        '
        ' Bottone 1 o 2
        '
        Dim sName As String = DirectCast(sender, Button).Text
        '
        ' Creo richiesta
        '
        Dim oRichiesta As New ServiceRichiesta.RichiestaParameter
        oRichiesta.RichiestaQueue = New ServiceRichiesta.RichiestaQueueType

        oRichiesta.RichiestaQueue.Utente = "MSG"
        oRichiesta.RichiestaQueue.DataOperazione = DateTime.Now
        '
        ' TESTATA
        '
        oRichiesta.RichiestaQueue.Testata = New ServiceRichiesta.TestataRichiestaType

        oRichiesta.RichiestaQueue.Testata.DatiAggiuntivi = New ServiceRichiesta.DatiAggiuntiviType

        oRichiesta.RichiestaQueue.Testata.DatiAggiuntivi.Add(New ServiceRichiesta.DatoNomeValoreType)
        oRichiesta.RichiestaQueue.Testata.DatiAggiuntivi(0).Nome = "abcd"
        oRichiesta.RichiestaQueue.Testata.DatiAggiuntivi(0).TipoDato = "string"
        oRichiesta.RichiestaQueue.Testata.DatiAggiuntivi(0).ValoreDato = "0"
        '
        ' Consensi
        '
        oRichiesta.RichiestaQueue.Testata.Consensi = New ServiceRichiesta.ConsensiType
        oRichiesta.RichiestaQueue.Testata.Consensi.Add(New ServiceRichiesta.ConsensoType)
        oRichiesta.RichiestaQueue.Testata.Consensi(0).Tipo = "ConsensoBase"
        oRichiesta.RichiestaQueue.Testata.Consensi(0).Valore = True
        '
        ' Paziente
        '
        oRichiesta.RichiestaQueue.Testata.Paziente = New ServiceRichiesta.PazienteType

        oRichiesta.RichiestaQueue.Testata.Paziente.IdSac = "C52EEF32-24B4-4179-B9B5-30EA6196AF4A"
        oRichiesta.RichiestaQueue.Testata.Paziente.AnagraficaCodice = "1233445"
        oRichiesta.RichiestaQueue.Testata.Paziente.AnagraficaNome = "GST_ASMN"
        oRichiesta.RichiestaQueue.Testata.Paziente.CodiceFiscale = "PRVMLD50A01H223G"
        oRichiesta.RichiestaQueue.Testata.Paziente.DataNascita = #1/1/1964#
        '
        ' Richiesta
        '
        oRichiesta.RichiestaQueue.Testata.Data = DateTime.Now
        oRichiesta.RichiestaQueue.Testata.NumeroNosologico = "12345678"
        oRichiesta.RichiestaQueue.Testata.DataRichiesta = DateTime.Now

        oRichiesta.RichiestaQueue.Testata.IdRichiestaRichiedente = "test-" + DateTime.UtcNow.ToString("hhmmssfff")
        TextBoxIdRichiesta.Text = oRichiesta.RichiestaQueue.Testata.IdRichiestaRichiedente

        oRichiesta.RichiestaQueue.Testata.SistemaRichiedente = New ServiceRichiesta.SistemaType
        oRichiesta.RichiestaQueue.Testata.SistemaRichiedente.Azienda = New ServiceRichiesta.CodiceDescrizioneType With {.Codice = "ASMN"}
        oRichiesta.RichiestaQueue.Testata.SistemaRichiedente.Sistema = New ServiceRichiesta.CodiceDescrizioneType With {.Codice = "GST"}

        oRichiesta.RichiestaQueue.Testata.UnitaOperativaRichiedente = New ServiceRichiesta.StrutturaType
        oRichiesta.RichiestaQueue.Testata.UnitaOperativaRichiedente.Azienda = New ServiceRichiesta.CodiceDescrizioneType With {.Codice = "ASMN"}
        oRichiesta.RichiestaQueue.Testata.UnitaOperativaRichiedente.UnitaOperativa = New ServiceRichiesta.CodiceDescrizioneType With {.Codice = "PS"}

        oRichiesta.RichiestaQueue.Testata.OperazioneOrderEntry = "SR"
        oRichiesta.RichiestaQueue.Testata.Data = DateTime.Now

        oRichiesta.RichiestaQueue.Testata.Regime = New ServiceRichiesta.CodiceDescrizioneType With {.Codice = "AMB"}
        '
        ' Righe richieste
        '
        oRichiesta.RichiestaQueue.Testata.RigheRichieste = New ServiceRichiesta.RigheRichiesteType

        Dim RigaRichiesta0 As New ServiceRichiesta.RigaRichiestaType
        RigaRichiesta0.IdRigaRichiedente = "1234"

        RigaRichiesta0.SistemaErogante = New ServiceRichiesta.SistemaType
        RigaRichiesta0.SistemaErogante.Azienda = New ServiceRichiesta.CodiceDescrizioneType With {.Codice = "ASMN"}
        RigaRichiesta0.SistemaErogante.Sistema = New ServiceRichiesta.CodiceDescrizioneType With {.Codice = "LIS-CNM"}

        RigaRichiesta0.Prestazione = New ServiceRichiesta.PrestazioneType With {.Codice = "222", .Descrizione = "DueDueDue"}
        oRichiesta.RichiestaQueue.Testata.RigheRichieste.Add(RigaRichiesta0)

        If sName = "Ric2" Then

            Dim RigaRichiesta1 As New ServiceRichiesta.RigaRichiestaType
            RigaRichiesta1.IdRigaRichiedente = "5678"

            RigaRichiesta1.SistemaErogante = New ServiceRichiesta.SistemaType
            RigaRichiesta1.SistemaErogante.Azienda = New ServiceRichiesta.CodiceDescrizioneType With {.Codice = "ASMN"}
            RigaRichiesta1.SistemaErogante.Sistema = New ServiceRichiesta.CodiceDescrizioneType With {.Codice = "LIS-REGGIO"}

            RigaRichiesta1.Prestazione = New ServiceRichiesta.PrestazioneType With {.Codice = "333", .Descrizione = "treTreTre"}
            oRichiesta.RichiestaQueue.Testata.RigheRichieste.Add(RigaRichiesta1)
        End If

        '
        ' Converto in XML
        '
        Using stream As New IO.MemoryStream
            Dim oDataSerializer As New DataContractSerializer(GetType(ServiceRichiesta.RichiestaParameter))
            oDataSerializer.WriteObject(stream, oRichiesta)

            stream.Position = 0
            TextBoxInput.Text = System.Text.Encoding.UTF8.GetString(stream.ToArray)
        End Using

    End Sub

    Private Sub ButtonDesStato_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ButtonDesStato.Click

        Dim oStato As New ServiceStato.StatoParameter
        oStato.StatoQueue = New ServiceStato.StatoQueueType

        oStato.StatoQueue.TipoOperazione = ServiceStato.TipoOperazioneType.Completo

        oStato.StatoQueue.Testata = New ServiceStato.TestataStatoType

        oStato.StatoQueue.Testata.RigheErogate = New ServiceStato.RigheErogateType
        oStato.StatoQueue.Testata.RigheErogate.Add(New ServiceStato.RigaErogataType)

        oStato.StatoQueue.Testata.Consensi = New ServiceStato.ConsensiType
        oStato.StatoQueue.Testata.Consensi.Add(New ServiceStato.ConsensoType)
        oStato.StatoQueue.Testata.Consensi(0).Tipo = "Generico"
        oStato.StatoQueue.Testata.Consensi(0).Valore = True
        oStato.StatoQueue.Testata.Consensi(0).Data = DateTime.Now

        oStato.StatoQueue.Utente = "MSG"
        oStato.StatoQueue.DataOperazione = DateTime.Now
        oStato.StatoQueue.TipoStato = ServiceStato.TipoStatoType.OSU

        oStato.StatoQueue.Testata.Data = DateTime.Now
        oStato.StatoQueue.Testata.IdRichiestaRichiedente = TextBoxIdRichiesta.Text

        oStato.StatoQueue.Testata.IdRichiestaOrderEntry = TextBoxIdOrderEntry.Text
        oStato.StatoQueue.Testata.StatoOrderEntry = "IC"

        oStato.StatoQueue.Testata.StatoErogante = New ServiceStato.CodiceDescrizioneType With {.Codice = "RP"}

        oStato.StatoQueue.Testata.SistemaRichiedente = New ServiceStato.SistemaType
        oStato.StatoQueue.Testata.SistemaRichiedente.Azienda = New ServiceStato.CodiceDescrizioneType With {.Codice = "ASMN"}
        oStato.StatoQueue.Testata.SistemaRichiedente.Sistema = New ServiceStato.CodiceDescrizioneType With {.Codice = "GST"}

        oStato.StatoQueue.Testata.SistemaErogante = New ServiceStato.SistemaType
        oStato.StatoQueue.Testata.SistemaErogante.Azienda = New ServiceStato.CodiceDescrizioneType With {.Codice = "ASMN"}
        oStato.StatoQueue.Testata.SistemaErogante.Sistema = New ServiceStato.CodiceDescrizioneType With {.Codice = "LIS-CNM"}

        oStato.StatoQueue.Testata.RigheErogate(0).IdRigaRichiedente = "1234"
        oStato.StatoQueue.Testata.RigheErogate(0).StatoOrderEntry = "CM"
        oStato.StatoQueue.Testata.RigheErogate(0).StatoErogante = New ServiceStato.CodiceDescrizioneType With {.Codice = "CR"}
        oStato.StatoQueue.Testata.RigheErogate(0).Prestazione = New ServiceStato.PrestazioneType With {.Codice = "222", .Descrizione = "DueDueDue"}

        oStato.StatoQueue.Testata.RigheErogate(0).DatiAggiuntivi = New ServiceStato.DatiAggiuntiviType
        oStato.StatoQueue.Testata.RigheErogate(0).DatiAggiuntivi.Add(New ServiceStato.DatoNomeValoreType)

        oStato.StatoQueue.Testata.RigheErogate(0).DatiAggiuntivi(0).Id = "00000001-0000-0000-0000-111111111111"
        oStato.StatoQueue.Testata.RigheErogate(0).DatiAggiuntivi(0).Nome = "CORE_DataPianificata"
        oStato.StatoQueue.Testata.RigheErogate(0).DatiAggiuntivi(0).TipoDato = "xs:dateTime"
        oStato.StatoQueue.Testata.RigheErogate(0).DatiAggiuntivi(0).ValoreDato = DateTime.Now.AddHours(24).ToString("s")

        Using stream As New IO.MemoryStream
            Dim oDataSerializer As New DataContractSerializer(GetType(ServiceStato.StatoParameter))
            oDataSerializer.WriteObject(stream, oStato)

            stream.Position = 0
            TextBoxInput.Text = System.Text.Encoding.UTF8.GetString(stream.ToArray)
        End Using

    End Sub

    Private Sub ButtonDesStatoAA_Click(sender As Object, e As EventArgs) Handles ButtonDesStatoAA.Click

        Dim oStato As New ServiceStato.StatoParameter
        oStato.StatoQueue = New ServiceStato.StatoQueueType

        oStato.StatoQueue.TipoOperazione = ServiceStato.TipoOperazioneType.Completo

        oStato.StatoQueue.Utente = "MSG"
        oStato.StatoQueue.DataOperazione = DateTime.Now
        oStato.StatoQueue.TipoStato = ServiceStato.TipoStatoType.RR

        oStato.StatoQueue.Testata = New ServiceStato.TestataStatoType

        oStato.StatoQueue.Testata.Data = DateTime.Now
        oStato.StatoQueue.Testata.IdRichiestaRichiedente = TextBoxIdRichiesta.Text

        oStato.StatoQueue.Testata.IdRichiestaOrderEntry = TextBoxIdOrderEntry.Text
        oStato.StatoQueue.Testata.StatoOrderEntry = "AA"

        oStato.StatoQueue.Testata.StatoErogante = New ServiceStato.CodiceDescrizioneType With {.Codice = "AA"}

        oStato.StatoQueue.Testata.SistemaRichiedente = New ServiceStato.SistemaType
        oStato.StatoQueue.Testata.SistemaRichiedente.Azienda = New ServiceStato.CodiceDescrizioneType With {.Codice = "ASMN"}
        oStato.StatoQueue.Testata.SistemaRichiedente.Sistema = New ServiceStato.CodiceDescrizioneType With {.Codice = "GST"}

        oStato.StatoQueue.Testata.SistemaErogante = New ServiceStato.SistemaType
        oStato.StatoQueue.Testata.SistemaErogante.Azienda = New ServiceStato.CodiceDescrizioneType With {.Codice = "ASMN"}
        oStato.StatoQueue.Testata.SistemaErogante.Sistema = New ServiceStato.CodiceDescrizioneType With {.Codice = "LIS-CNM"}

        Using stream As New IO.MemoryStream
            Dim oDataSerializer As New DataContractSerializer(GetType(ServiceStato.StatoParameter))
            oDataSerializer.WriteObject(stream, oStato)

            stream.Position = 0
            TextBoxInput.Text = System.Text.Encoding.UTF8.GetString(stream.ToArray)
        End Using

    End Sub

    Private Sub ButtonDesStatoSE_Click(sender As Object, e As EventArgs) Handles ButtonDesStatoSE.Click

        Dim oStato As New ServiceStato.StatoParameter
        oStato.StatoQueue = New ServiceStato.StatoQueueType

        oStato.StatoQueue.TipoOperazione = ServiceStato.TipoOperazioneType.Incrementale

        oStato.StatoQueue.Utente = "MSG"
        oStato.StatoQueue.DataOperazione = DateTime.Now
        oStato.StatoQueue.TipoStato = ServiceStato.TipoStatoType.RR

        oStato.StatoQueue.Testata = New ServiceStato.TestataStatoType

        oStato.StatoQueue.Testata.Data = DateTime.Now
        oStato.StatoQueue.Testata.IdRichiestaRichiedente = TextBoxIdRichiesta.Text

        oStato.StatoQueue.Testata.IdRichiestaOrderEntry = TextBoxIdOrderEntry.Text
        oStato.StatoQueue.Testata.StatoOrderEntry = "SE"

        oStato.StatoQueue.Testata.StatoErogante = New ServiceStato.CodiceDescrizioneType With {.Codice = "SE"}

        oStato.StatoQueue.Testata.SistemaRichiedente = New ServiceStato.SistemaType
        oStato.StatoQueue.Testata.SistemaRichiedente.Azienda = New ServiceStato.CodiceDescrizioneType With {.Codice = "ASMN"}
        oStato.StatoQueue.Testata.SistemaRichiedente.Sistema = New ServiceStato.CodiceDescrizioneType With {.Codice = "GST"}

        oStato.StatoQueue.Testata.SistemaErogante = New ServiceStato.SistemaType
        oStato.StatoQueue.Testata.SistemaErogante.Azienda = New ServiceStato.CodiceDescrizioneType With {.Codice = "ASMN"}
        oStato.StatoQueue.Testata.SistemaErogante.Sistema = New ServiceStato.CodiceDescrizioneType With {.Codice = "LIS-CNM"}

        oStato.StatoQueue.Testata.DatiPersistenti = New ServiceStato.DatiPersistentiType
        oStato.StatoQueue.Testata.DatiPersistenti.Add(New ServiceStato.DatoNomeValoreType)

        oStato.StatoQueue.Testata.DatiPersistenti(0).Nome = "File finto"
        oStato.StatoQueue.Testata.DatiPersistenti(0).TipoContenuto = "PDF"
        oStato.StatoQueue.Testata.DatiPersistenti(0).TipoDato = "xs:base64"
        oStato.StatoQueue.Testata.DatiPersistenti(0).ValoreDato = "ad4fde4fd3fa6d3f5f30"

        Using stream As New IO.MemoryStream
            Dim oDataSerializer As New DataContractSerializer(GetType(ServiceStato.StatoParameter))
            oDataSerializer.WriteObject(stream, oStato)

            stream.Position = 0
            TextBoxInput.Text = System.Text.Encoding.UTF8.GetString(stream.ToArray)
        End Using

    End Sub

    Private Sub ButtonDesStatoInc_Click(sender As Object, e As EventArgs) Handles ButtonDesStatoInc.Click

        Dim oStato As New ServiceStato.StatoParameter
        oStato.StatoQueue = New ServiceStato.StatoQueueType

        oStato.StatoQueue.TipoOperazione = ServiceStato.TipoOperazioneType.Incrementale

        oStato.StatoQueue.Testata = New ServiceStato.TestataStatoType

        oStato.StatoQueue.Testata.RigheErogate = New ServiceStato.RigheErogateType
        oStato.StatoQueue.Testata.RigheErogate.Add(New ServiceStato.RigaErogataType)

        oStato.StatoQueue.Testata.Consensi = New ServiceStato.ConsensiType
        oStato.StatoQueue.Testata.Consensi.Add(New ServiceStato.ConsensoType)
        oStato.StatoQueue.Testata.Consensi(0).Tipo = "Generico"
        oStato.StatoQueue.Testata.Consensi(0).Valore = True
        oStato.StatoQueue.Testata.Consensi(0).Data = DateTime.Now

        oStato.StatoQueue.Utente = "MSG"
        oStato.StatoQueue.DataOperazione = DateTime.Now
        oStato.StatoQueue.TipoStato = ServiceStato.TipoStatoType.OSU

        oStato.StatoQueue.Testata.Data = DateTime.Now
        oStato.StatoQueue.Testata.IdRichiestaRichiedente = TextBoxIdRichiesta.Text

        oStato.StatoQueue.Testata.IdRichiestaOrderEntry = TextBoxIdOrderEntry.Text
        oStato.StatoQueue.Testata.StatoOrderEntry = "IC"

        oStato.StatoQueue.Testata.StatoErogante = New ServiceStato.CodiceDescrizioneType With {.Codice = "RP"}

        oStato.StatoQueue.Testata.SistemaRichiedente = New ServiceStato.SistemaType
        oStato.StatoQueue.Testata.SistemaRichiedente.Azienda = New ServiceStato.CodiceDescrizioneType With {.Codice = "ASMN"}
        oStato.StatoQueue.Testata.SistemaRichiedente.Sistema = New ServiceStato.CodiceDescrizioneType With {.Codice = "GST"}

        oStato.StatoQueue.Testata.SistemaErogante = New ServiceStato.SistemaType
        oStato.StatoQueue.Testata.SistemaErogante.Azienda = New ServiceStato.CodiceDescrizioneType With {.Codice = "ASMN"}
        oStato.StatoQueue.Testata.SistemaErogante.Sistema = New ServiceStato.CodiceDescrizioneType With {.Codice = "LIS-CNM"}

        oStato.StatoQueue.Testata.RigheErogate(0).IdRigaRichiedente = "1234"
        oStato.StatoQueue.Testata.RigheErogate(0).StatoOrderEntry = "CM"
        oStato.StatoQueue.Testata.RigheErogate(0).StatoErogante = New ServiceStato.CodiceDescrizioneType With {.Codice = "CR"}
        oStato.StatoQueue.Testata.RigheErogate(0).Prestazione = New ServiceStato.PrestazioneType With {.Codice = "222", .Descrizione = "DueDueDue"}

        oStato.StatoQueue.Testata.RigheErogate(0).DatiAggiuntivi = New ServiceStato.DatiAggiuntiviType
        oStato.StatoQueue.Testata.RigheErogate(0).DatiAggiuntivi.Add(New ServiceStato.DatoNomeValoreType)

        oStato.StatoQueue.Testata.RigheErogate(0).DatiAggiuntivi(0).Id = "00000001-0000-0000-0000-111111111111"
        oStato.StatoQueue.Testata.RigheErogate(0).DatiAggiuntivi(0).Nome = "CORE_DataPianificata"
        oStato.StatoQueue.Testata.RigheErogate(0).DatiAggiuntivi(0).TipoDato = "xs:dateTime"
        oStato.StatoQueue.Testata.RigheErogate(0).DatiAggiuntivi(0).ValoreDato = DateTime.Now.AddHours(24).ToString("s")

        Using stream As New IO.MemoryStream
            Dim oDataSerializer As New DataContractSerializer(GetType(ServiceStato.StatoParameter))
            oDataSerializer.WriteObject(stream, oStato)

            stream.Position = 0
            TextBoxInput.Text = System.Text.Encoding.UTF8.GetString(stream.ToArray)
        End Using
    End Sub

End Class
