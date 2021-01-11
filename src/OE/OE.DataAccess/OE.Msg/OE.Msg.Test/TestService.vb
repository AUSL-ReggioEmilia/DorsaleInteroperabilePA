Imports System.Runtime.Serialization

Imports OE.Core.Schemas.Msg.QueueTypes
Imports OE.Core.Schemas.Msg.RichiestaParameterTypes
Imports OE.Core.Schemas.Msg.RichiestaReturnTypes
Imports OE.Core.Schemas.Msg.StatoParameterTypes
Imports OE.Core.Schemas.Msg.StatoReturnTypes
Imports OE.Core.Schemas.Msg.OrdineReturnTypes
Imports OE.Core

Public Class TestService

    Dim _Settings As OE.Core.ConfigurationSettings

    Private Sub TestService_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        '
        ' Instanza del globalone su OE.Core.ConfigurationHelper
        '
        _Settings = OE.Core.ConfigurationHelper.ConfigurationSettings

        _Settings.ConnectionString = "Data Source=ALDERAAN;Initial Catalog=AuslAsmnRe_OrderEntry;User ID=OE_BT_DA;Password=User4deV;Persist Security Info=True"
        _Settings.TransactionIsolationLevel = IsolationLevel.ReadCommitted
        _Settings.Ttl = 30

        _Settings.LogSource = Application.ProductName
        _Settings.LogInformation = False
        _Settings.LogWarning = False
        _Settings.LogError = False
        _Settings.LogTrace = True

        _Settings.AutoSyncPrestazioni = True
        _Settings.AutoSyncUnitaOperative = True
        _Settings.AutoSyncSistemiRichiedenti = True
        _Settings.AutoSyncSistemiEroganti = True

        _Settings.TranscodificaAttiva = True
        '
        ' globalone Opzioni
        '
        SyncLock _Settings.Options

            _Settings.Options.Clear()
            _Settings.Options.Add("IgnoraRegimeVuoto", "False")

        End SyncLock
        '
        ' Default UI
        '
        ComboBoxDesRic.SelectedItem = "SR"
        ComboBoxDesStato.SelectedItem = "RR AA"

    End Sub


    Private Sub ButtonRichiesta_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ButtonRichiesta.Click

        Try
            Dim oService As New OE.DataAccess.MessaggioRichiesta

            TextBoxOutput.Text = "-->Start: " & DateTime.Now
            TextBoxOutput.Refresh()
            '
            ' Test metodo tipizzato
            '
            Dim oParam As RichiestaParameter
            Dim oReturn As RichiestaReturn

            Using stream As New IO.MemoryStream
                Dim encoding As System.Text.Encoding = System.Text.Encoding.UTF8
                stream.Write(encoding.GetBytes(TextBoxInput.Text), 0, encoding.GetByteCount(TextBoxInput.Text))
                stream.Position = 0

                Dim oDataSerializer As New DataContractSerializer(GetType(RichiestaParameter))
                oParam = CType(oDataSerializer.ReadObject(stream), RichiestaParameter)
            End Using

            oParam.RichiestaQueue.Testata.DataRichiesta = DateTime.Now()

            If String.IsNullOrEmpty(TextBoxIdRichiestaRichiedente.Text) Then
                oParam.RichiestaQueue.Testata.IdRichiestaRichiedente = "test-" + DateTime.UtcNow.ToString("hhmmssfff")
            Else
                oParam.RichiestaQueue.Testata.IdRichiestaRichiedente = TextBoxIdRichiestaRichiedente.Text
            End If

            oReturn = oService.ProcessaMessaggio(oParam, _Settings)

            Using stream As New IO.MemoryStream
                Dim oDataSerializer As New DataContractSerializer(GetType(RichiestaReturn))
                oDataSerializer.WriteObject(stream, oReturn)
                stream.Position = 0
                '
                ' Output
                '
                TextBoxOutput.Text = TextBoxOutput.Text & vbCrLf & "-->Stop: " & DateTime.Now
                TextBoxOutput.Text = TextBoxOutput.Text & vbCrLf & _
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
            Dim oService As New OE.DataAccess.MessaggioStato

            TextBoxOutput.Text = "-->Start: " & DateTime.Now
            TextBoxOutput.Refresh()
            '
            ' Test metodo tipizzato
            '
            Dim oParam As Schemas.Msg.StatoParameterTypes.StatoParameter
            Dim oReturn As Schemas.Msg.StatoReturnTypes.StatoReturn

            oParam = New Schemas.Msg.StatoParameterTypes.StatoParameter

            Using stream As New IO.MemoryStream
                Dim encoding As System.Text.Encoding = System.Text.Encoding.UTF8
                stream.Write(encoding.GetBytes(TextBoxInput.Text), 0, encoding.GetByteCount(TextBoxInput.Text))
                stream.Position = 0

                Dim oDataSerializer As New DataContractSerializer(GetType(StatoParameter))
                oParam = CType(oDataSerializer.ReadObject(stream), StatoParameter)
            End Using

            If Not String.IsNullOrEmpty(TextBoxIdOrderEntry.Text) Then
                oParam.StatoQueue.Testata.IdRichiestaOrderEntry = TextBoxIdOrderEntry.Text
            End If

            oReturn = oService.ProcessaMessaggio(oParam, _Settings)

            Using stream As New IO.MemoryStream
                Dim oDataSerializer As New DataContractSerializer(GetType(StatoReturn))
                oDataSerializer.WriteObject(stream, oReturn)
                stream.Position = 0
                '
                ' Output
                '
                TextBoxOutput.Text = TextBoxOutput.Text & vbCrLf & "-->Stop: " & DateTime.Now
                TextBoxOutput.Text = TextBoxOutput.Text & vbCrLf & _
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
            Dim oService As New OE.DataAccess.OrdineData
            Dim sIdOrderEntry As String = Nothing

            TextBoxOutput.Text = "-->Start: " & DateTime.Now
            TextBoxOutput.Refresh()
            '
            ' Test metodo tipizzato
            '
            Dim oReturn As OrdineReturn

            If Not String.IsNullOrEmpty(TextBoxIdOrderEntry.Text) Then
                sIdOrderEntry = TextBoxIdOrderEntry.Text
            End If

            oReturn = oService.OrdinePerIdOrderEntry(sIdOrderEntry, _Settings)

            Using stream As New IO.MemoryStream
                Dim oDataSerializer As New DataContractSerializer(GetType(OrdineReturn))
                oDataSerializer.WriteObject(stream, oReturn)
                stream.Position = 0
                '
                ' Output
                '
                TextBoxOutput.Text = TextBoxOutput.Text & vbCrLf & "-->Stop: " & DateTime.Now
                TextBoxOutput.Text = TextBoxOutput.Text & vbCrLf & _
                                        System.Text.Encoding.UTF8.GetString(stream.ToArray)
            End Using

        Catch ex As Exception
            '
            ' Error
            '
            MessageBox.Show(ex.Message)
        End Try

    End Sub



    Private Sub ButtonDesRic_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ButtonDesRic.Click

        ' Leggo la Combo con OPERAZIONE
        Dim sOperazione As String = ComboBoxDesRic.SelectedItem

        ' Creo la RICHIESTA
        Dim oRichiesta As New RichiestaParameter
        oRichiesta.RichiestaQueue = New RichiestaQueueType
        oRichiesta.RichiestaQueue.Testata = New TestataRichiestaType

        oRichiesta.RichiestaQueue.Testata.RigheRichieste = New RigheRichiesteType

        'Nuova righe richieste
        Dim NewRigaRichiesta0 = New RigaRichiestaType

        NewRigaRichiesta0.IdRigaRichiedente = "1"
        NewRigaRichiesta0.SistemaErogante = New SistemaType With {.Azienda = New CodiceDescrizioneType With {.Codice = "ASMN"},
                                                                  .Sistema = New CodiceDescrizioneType With {.Codice = "CV"}
                                                                }
        NewRigaRichiesta0.Prestazione = New PrestazioneType With {.Codice = "222", .Descrizione = "DueDueDue"}
        oRichiesta.RichiestaQueue.Testata.RigheRichieste.Add(NewRigaRichiesta0)

        'Nuova righe richieste
        Dim NewRigaRichiesta1 = New RigaRichiestaType

        NewRigaRichiesta1.IdRigaRichiedente = "2"
        NewRigaRichiesta1.SistemaErogante = New SistemaType With {.Azienda = New CodiceDescrizioneType With {.Codice = "ASMN"},
                                                                  .Sistema = New CodiceDescrizioneType With {.Codice = "CV"}
                                                                }

        NewRigaRichiesta1.Prestazione = New PrestazioneType With {.Codice = "333", .Descrizione = "TreTreTre"}
        oRichiesta.RichiestaQueue.Testata.RigheRichieste.Add(NewRigaRichiesta1)

        ' Se CA setto tutte le righe CA
        If sOperazione = "CA" Then
            For Each Riga As RigaRichiestaType In oRichiesta.RichiestaQueue.Testata.RigheRichieste
                Riga.OperazioneOrderEntry = "CA"
            Next
        End If

        'Dati aggiuntivi
        oRichiesta.RichiestaQueue.Testata.DatiAggiuntivi = New DatiAggiuntiviType
        oRichiesta.RichiestaQueue.Testata.DatiAggiuntivi.Add(New DatoNomeValoreType)

        oRichiesta.RichiestaQueue.Testata.DatiAggiuntivi(0).Nome = "0"
        oRichiesta.RichiestaQueue.Testata.DatiAggiuntivi(0).TipoDato = "string"
        oRichiesta.RichiestaQueue.Testata.DatiAggiuntivi(0).ValoreDato = "0"

        'Consensi
        oRichiesta.RichiestaQueue.Testata.Consensi = New ConsensiType
        oRichiesta.RichiestaQueue.Testata.Consensi.Add(New ConsensoType)
        oRichiesta.RichiestaQueue.Testata.Consensi(0).Data = DateTime.Now
        oRichiesta.RichiestaQueue.Testata.Consensi(0).Tipo = "Generico"
        oRichiesta.RichiestaQueue.Testata.Consensi(0).Valore = True

        'Paziente
        oRichiesta.RichiestaQueue.Testata.Paziente = New PazienteType
        oRichiesta.RichiestaQueue.Testata.Paziente.AnagraficaCodice = "1233445"
        oRichiesta.RichiestaQueue.Testata.Paziente.AnagraficaNome = "GST_ASMN"
        oRichiesta.RichiestaQueue.Testata.Paziente.CodiceFiscale = "1234567890123"
        oRichiesta.RichiestaQueue.Testata.Paziente.DataNascita = #1/1/1964#

        'Dati intestazione
        oRichiesta.RichiestaQueue.Utente = "MSG"
        oRichiesta.RichiestaQueue.DataOperazione = DateTime.Now

        oRichiesta.RichiestaQueue.Testata.Data = DateTime.Now
        oRichiesta.RichiestaQueue.Testata.NumeroNosologico = "12345678"
        oRichiesta.RichiestaQueue.Testata.DataRichiesta = DateTime.Now

        If Not String.IsNullOrEmpty(TextBoxDataPrenotazione.Text) Then
            oRichiesta.RichiestaQueue.Testata.DataPrenotazione = DateTime.Parse(TextBoxDataPrenotazione.Text)
        End If

        oRichiesta.RichiestaQueue.Testata.IdRichiestaRichiedente = "test-" + DateTime.UtcNow.ToString("hhmmssfff")

        oRichiesta.RichiestaQueue.Testata.SistemaRichiedente = New SistemaType
        oRichiesta.RichiestaQueue.Testata.SistemaRichiedente.Azienda = New CodiceDescrizioneType With {.Codice = "ASMN"}
        oRichiesta.RichiestaQueue.Testata.SistemaRichiedente.Sistema = New CodiceDescrizioneType With {.Codice = "GST"}

        oRichiesta.RichiestaQueue.Testata.UnitaOperativaRichiedente = New StrutturaType
        oRichiesta.RichiestaQueue.Testata.UnitaOperativaRichiedente.Azienda = New CodiceDescrizioneType With {.Codice = "ASMN"}
        oRichiesta.RichiestaQueue.Testata.UnitaOperativaRichiedente.UnitaOperativa = New CodiceDescrizioneType With {.Codice = "PS"}

        'Operazione dalla COMBO
        oRichiesta.RichiestaQueue.Testata.OperazioneOrderEntry = sOperazione
        oRichiesta.RichiestaQueue.Testata.Data = DateTime.Now

        oRichiesta.RichiestaQueue.Testata.Regime = New CodiceDescrizioneType
        oRichiesta.RichiestaQueue.Testata.Regime.Codice = RegimeEnum.SCR.ToString

        Using stream As New IO.MemoryStream
            Dim oDataSerializer As New DataContractSerializer(GetType(RichiestaParameter))
            oDataSerializer.WriteObject(stream, oRichiesta)

            stream.Position = 0
            TextBoxInput.Text = System.Text.Encoding.UTF8.GetString(stream.ToArray)
        End Using


    End Sub

    Private Sub ButtonDesStato_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ButtonDesStato.Click

        ' Leggo la Combo con OPERAZIONE
        Dim sStato As String = ComboBoxDesStato.SelectedItem
        Dim asStato As String() = sStato.Split(" ")

        Dim sTipoStato As String = asStato(0)
        Dim sStatoOrderEntry As String = asStato(1)

        'Creo STATO, RR oppure OSU
        Dim oStato As New StatoParameter
        oStato.StatoQueue = New StatoQueueType

        If CheckBoxIncrementale.Checked Then
            oStato.StatoQueue.TipoOperazione = TipoOperazioneType.Incrementale
        Else
            oStato.StatoQueue.TipoOperazione = TipoOperazioneType.Completo
        End If

        oStato.StatoQueue.Utente = "MSG"
        oStato.StatoQueue.DataOperazione = DateTime.Now

        If sTipoStato = "RR" Then
            oStato.StatoQueue.TipoStato = TipoStatoType.RR
        ElseIf sTipoStato = "OSU" Then
            oStato.StatoQueue.TipoStato = TipoStatoType.OSU
        Else
            oStato.StatoQueue.TipoStato = TipoStatoType.OSU
        End If

        oStato.StatoQueue.Testata = New TestataStatoType

        oStato.StatoQueue.Testata.DatiAggiuntivi = New DatiAggiuntiviType
        oStato.StatoQueue.Testata.DatiAggiuntivi.Add(New DatoNomeValoreType)

        oStato.StatoQueue.Testata.DatiAggiuntivi(0).Nome = "0"
        oStato.StatoQueue.Testata.DatiAggiuntivi(0).TipoDato = "string"
        oStato.StatoQueue.Testata.DatiAggiuntivi(0).ValoreDato = "0"

        oStato.StatoQueue.Testata.Consensi = New ConsensiType
        oStato.StatoQueue.Testata.Consensi.Add(New ConsensoType)
        oStato.StatoQueue.Testata.Consensi(0).Tipo = "Generico"
        oStato.StatoQueue.Testata.Consensi(0).Valore = True
        oStato.StatoQueue.Testata.Consensi(0).Data = DateTime.Now

        If Not String.IsNullOrEmpty(TextBoxDataPrenotazione.Text) Then
            oStato.StatoQueue.Testata.DataPrenotazione = DateTime.Parse(TextBoxDataPrenotazione.Text)
        End If

        oStato.StatoQueue.Testata.Data = DateTime.Now
        oStato.StatoQueue.Testata.IdRichiestaRichiedente = "12345678"

        oStato.StatoQueue.Testata.IdRichiestaOrderEntry = "12345678"
        oStato.StatoQueue.Testata.StatoOrderEntry = sStatoOrderEntry

        oStato.StatoQueue.Testata.StatoErogante = New CodiceDescrizioneType With {.Codice = "RP"}

        oStato.StatoQueue.Testata.SistemaRichiedente = New SistemaType
        oStato.StatoQueue.Testata.SistemaRichiedente.Azienda = New CodiceDescrizioneType With {.Codice = "ASMN"}
        oStato.StatoQueue.Testata.SistemaRichiedente.Sistema = New CodiceDescrizioneType With {.Codice = "GST"}

        oStato.StatoQueue.Testata.SistemaErogante = New SistemaType
        oStato.StatoQueue.Testata.SistemaErogante.Azienda = New CodiceDescrizioneType With {.Codice = "ASMN"}
        oStato.StatoQueue.Testata.SistemaErogante.Sistema = New CodiceDescrizioneType With {.Codice = "CV"}

        If sTipoStato <> "RR" Then
            oStato.StatoQueue.Testata.RigheErogate = New RigheErogateType

            oStato.StatoQueue.Testata.RigheErogate.Add(New RigaErogataType)

            oStato.StatoQueue.Testata.RigheErogate(0).IdRigaRichiedente = "1234"
            oStato.StatoQueue.Testata.RigheErogate(0).StatoOrderEntry = sStatoOrderEntry
            oStato.StatoQueue.Testata.RigheErogate(0).StatoErogante = New CodiceDescrizioneType With {.Codice = "CR"}
            oStato.StatoQueue.Testata.RigheErogate(0).Prestazione = New PrestazioneType With {.Codice = "222", .Descrizione = "DueDueDue"}

            If CheckBoxDataPianificata.Checked AndAlso Not String.IsNullOrEmpty(TextBoxDataPrenotazione.Text) Then
                oStato.StatoQueue.Testata.RigheErogate(0).DatiAggiuntivi = New DatiAggiuntiviType

                oStato.StatoQueue.Testata.RigheErogate(0).DatiAggiuntivi.Add(New DatoNomeValoreType)
                oStato.StatoQueue.Testata.RigheErogate(0).DatiAggiuntivi(0).Id = DatiAggiuntivi.ID_DATA_PIANIFICATA
                oStato.StatoQueue.Testata.RigheErogate(0).DatiAggiuntivi(0).Nome = "CORE_DataPianificata"
                oStato.StatoQueue.Testata.RigheErogate(0).DatiAggiuntivi(0).TipoDato = "xs:dateTime"
                oStato.StatoQueue.Testata.RigheErogate(0).DatiAggiuntivi(0).ValoreDato = DateTime.Parse(TextBoxDataPrenotazione.Text).AddHours(10)
            End If

            If Not CheckBoxIncrementale.Checked Then
                ' Se non incrementale aggiungo la seconda
                oStato.StatoQueue.Testata.RigheErogate.Add(New RigaErogataType)

                oStato.StatoQueue.Testata.RigheErogate(1).IdRigaRichiedente = "5678"
                oStato.StatoQueue.Testata.RigheErogate(1).StatoOrderEntry = "CA"
                oStato.StatoQueue.Testata.RigheErogate(1).StatoErogante = New CodiceDescrizioneType With {.Codice = "CA"}
                oStato.StatoQueue.Testata.RigheErogate(1).Prestazione = New PrestazioneType With {.Codice = "444", .Descrizione = "QuattroQuattroQuattro"}
            End If
        End If

        Using stream As New IO.MemoryStream
            Dim oDataSerializer As New DataContractSerializer(GetType(StatoParameter))
            oDataSerializer.WriteObject(stream, oStato)

            stream.Position = 0
            TextBoxInput.Text = System.Text.Encoding.UTF8.GetString(stream.ToArray)
        End Using


    End Sub


End Class
