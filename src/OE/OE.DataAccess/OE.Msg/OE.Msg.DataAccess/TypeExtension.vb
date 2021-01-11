Imports System.Runtime.InteropServices
Imports System.Reflection
Imports System.Data.Linq
Imports OE.Core
Imports OE.Core.Schemas.Msg
Imports System.Text

Module TypeExtension

#Region "SistemaType"

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToSistemaType(sistemaRow As OrganigrammaDS.SistemaRow) As QueueTypes.SistemaType

        Dim sistema As New QueueTypes.SistemaType() With {
                         .Azienda = New QueueTypes.CodiceDescrizioneType() With
                                    {.Codice = sistemaRow.CodiceAzienda,
                                     .Descrizione = If(sistemaRow.IsDescrizioneAziendaNull, Nothing, sistemaRow.DescrizioneAzienda)},
                         .Sistema = New QueueTypes.CodiceDescrizioneType() With
                                    {.Codice = sistemaRow.Codice,
                                     .Descrizione = If(sistemaRow.IsDescrizioneNull, Nothing, sistemaRow.Descrizione)}
                                                  }
        Return sistema

    End Function

#End Region

#Region "TestataRichiestaType"

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToTestataRichiestaType(testata As OrdiniDS.TestataRow, dataAggiuntivi As QueueTypes.DatiAggiuntiviType,
                                           datiPersistenti As QueueTypes.DatiPersistentiType) As QueueTypes.TestataRichiestaType
        '
        ' L'operatore IF(,,) non ritorna i tipi NULLABLE
        Dim dtDataPrenotazione As DateTime? = Nothing
        If Not testata.IsDataPrenotazioneNull() Then
            dtDataPrenotazione = testata.DataPrenotazione
        End If

        Dim dtDataVersione As DateTime? = Nothing
        If Not testata.IsDataNull() Then
            dtDataVersione = testata.Data
        End If

        ' Creo Sistema e unita operativa richiedente
        Dim SistemaRichiedente = New QueueTypes.SistemaType() With {
                                        .Azienda = New QueueTypes.CodiceDescrizioneType() With {.Codice = testata.CodiceAziendaSistemaRichiedente,
                                                                                     .Descrizione = If(testata.IsDescrizioneAziendaSistemaRichiedenteNull(), Nothing, testata.DescrizioneAziendaSistemaRichiedente)},
                                        .Sistema = New QueueTypes.CodiceDescrizioneType() With {.Codice = testata.CodiceSistemaRichiedente,
                                                                                     .Descrizione = If(testata.IsDescrizioneSistemaRichiedenteNull(), Nothing, testata.DescrizioneSistemaRichiedente)}
                                    }
        Dim UnitaOperativaRichiedente = New QueueTypes.StrutturaType() With {
                                        .Azienda = New QueueTypes.CodiceDescrizioneType() With {.Codice = testata.CodiceAziendaUnitaOperativaRichiedente,
                                                                                        .Descrizione = If(testata.IsDescrizioneAziendaUnitaOperativaRichiedenteNull(), Nothing, testata.DescrizioneAziendaUnitaOperativaRichiedente)},
                                        .UnitaOperativa = New QueueTypes.CodiceDescrizioneType() With {.Codice = testata.CodiceUnitaOperativaRichiedente,
                                                                                            .Descrizione = If(testata.IsDescrizioneUnitaOperativaRichiedenteNull(), Nothing, testata.DescrizioneUnitaOperativaRichiedente)}
                                    }

        ' Crea ordineType
        Return New QueueTypes.TestataRichiestaType() With {
            .IdRichiestaOrderEntry = String.Concat(testata.Anno, "/", testata.Numero),
            .IdRichiestaRichiedente = testata.IDRichiestaRichiedente,
            .SistemaRichiedente = SistemaRichiedente,
            .UnitaOperativaRichiedente = UnitaOperativaRichiedente,
            .NumeroNosologico = If(testata.IsNumeroNosologicoNull(), Nothing, testata.NumeroNosologico),
            .Regime = If(testata.IsRegimeNull(), Nothing, CreateRegimeTypeFromXml(testata.Regime)),
            .DataRichiesta = testata.DataRichiesta,
            .OperazioneOrderEntry = testata.StatoOrderEntry,
            .DataPrenotazione = dtDataPrenotazione,
            .OperazioneRichiedente = If(testata.IsStatoRichiedenteNull(), Nothing, CreateOperazioneRichiestaOrderEntryEnumFromXml(testata.StatoRichiedente)),
            .Data = dtDataVersione,
            .Operatore = If(testata.IsOperatoreNull(), Nothing, CreateOperatoreTypeFromXml(testata.Operatore)),
            .Priorita = If(testata.IsPrioritaNull(), Nothing, CreatePrioritaTypeFromXml(testata.Priorita)),
            .TipoEpisodio = If(testata.IsTipoEpisodioNull(), Nothing, CreateCodiceDescrizioneTypeFromXml(testata.TipoEpisodio)),
            .Paziente = If(testata.IsPazienteNull(), Nothing, CreatePazienteTypeFromXml(testata.Paziente, testata.ID)),
            .Note = If(testata.IsNoteNull(), Nothing, testata.Note),
            .Consensi = If(testata.IsConsensiNull(), Nothing, CreateConsensiTypeFromXml(testata.Consensi)),
            .DatiAggiuntivi = dataAggiuntivi,
            .DatiPersistenti = datiPersistenti,
        .RigheRichieste = Nothing
        }

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToTestataDatiAggiuntiviType(rows As List(Of OrdiniDS.TestataDatoAggiuntivoRow)) As QueueTypes.DatiAggiuntiviType

        If rows Is Nothing Then Return Nothing

        Dim result As New QueueTypes.DatiAggiuntiviType

        'Solo i dati non persistenti
        For Each d In rows.FindAll(Function(e) e.IsPersistenteNull = True OrElse e.Persistente = False)

            Dim valore As String = String.Empty
            If Not d.IsValoreDatoNull Then
                valore = d.ValoreDato.ToString

            ElseIf Not d.IsValoreDatoVarcharNull Then
                valore = d.ValoreDatoVarchar

            ElseIf Not d.IsValoreDatoXmlNull Then
                valore = d.ValoreDatoXml
            End If

            result.Add(New QueueTypes.DatoNomeValoreType() With {.Id = If(d.IsIDDatoAggiuntivoNull, Nothing, d.IDDatoAggiuntivo),
                                                                     .Nome = d.Nome,
                                                                     .TipoDato = d.TipoDato,
                                                                     .TipoContenuto = If(d.IsTipoContenutoNull, Nothing, d.TipoContenuto),
                                                                     .ValoreDato = valore
                                                                    })
        Next

        Return result

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToTestataDatiPersistentiType(rows As List(Of OrdiniDS.TestataDatoAggiuntivoRow)) As QueueTypes.DatiPersistentiType

        If rows Is Nothing Then Return Nothing

        Dim result As New QueueTypes.DatiPersistentiType

        'Solo i dati non persistenti
        For Each d In rows.FindAll(Function(e) e.IsPersistenteNull = False AndAlso e.Persistente = True)

            Dim valore As String = String.Empty
            If Not d.IsValoreDatoNull Then
                valore = d.ValoreDato.ToString

            ElseIf Not d.IsValoreDatoVarcharNull Then
                valore = d.ValoreDatoVarchar

            ElseIf Not d.IsValoreDatoXmlNull Then
                valore = d.ValoreDatoXml
            End If

            result.Add(New QueueTypes.DatoNomeValoreType() With {.Id = If(d.IsIDDatoAggiuntivoNull, Nothing, d.IDDatoAggiuntivo),
                                                                      .Nome = d.Nome,
                                                                      .TipoDato = d.TipoDato,
                                                                      .TipoContenuto = If(d.IsTipoContenutoNull, Nothing, d.TipoContenuto),
                                                                      .ValoreDato = valore
                                                                     })
        Next

        Return result

    End Function

#End Region

#Region "RigaRichiestaType"

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToRigaRichiestaType(row As OrdiniDS.RigaRichiestaRow, datiAggiuntivi As QueueTypes.DatiAggiuntiviType) As QueueTypes.RigaRichiestaType

        Dim Sistema As QueueTypes.SistemaType

        'Creo Sistema erogante
        If row.IDSistemaErogante = Guid.Empty Then
            'Sistema Nillabile
            Sistema = New QueueTypes.SistemaType() With {
                .Azienda = New QueueTypes.CodiceDescrizioneType() With {.Codice = ""},
                .Sistema = New QueueTypes.CodiceDescrizioneType() With {.Codice = ""}}
        Else
            Sistema = New QueueTypes.SistemaType() With {
                .Azienda = New QueueTypes.CodiceDescrizioneType() With {.Codice = row.CodiceAziendaSistemaErogante,
                                                             .Descrizione = If(row.IsDescrizioneAziendaSistemaEroganteNull(), Nothing, row.DescrizioneAziendaSistemaErogante)},
                .Sistema = New QueueTypes.CodiceDescrizioneType() With {.Codice = row.CodiceSistemaErogante,
                                                             .Descrizione = If(row.IsDescrizioneSistemaEroganteNull(), Nothing, row.DescrizioneSistemaErogante)}}
        End If

        'Creo prestazione
        Dim Prestazione = New QueueTypes.PrestazioneType() With {.Codice = row.CodicePrestazione,
                                                      .Descrizione = If(row.IsDescrizionePrestazioneNull(), Nothing, row.DescrizionePrestazione)}

        Return New QueueTypes.RigaRichiestaType() With {
            .IdRigaOrderEntry = If(row.IsIDRigaOrderEntryNull(), Nothing, row.IDRigaOrderEntry),
            .OperazioneOrderEntry = If(row.IsStatoOrderEntryNull(), Nothing, row.StatoOrderEntry),
            .IdRigaRichiedente = If(row.IsIDRigaRichiedenteNull(), Nothing, row.IDRigaRichiedente),
            .IdRigaErogante = If(row.IsIDRigaEroganteNull(), Nothing, row.IDRigaErogante),
            .OperazioneRichiedente = If(row.IsStatoRichiedenteNull(), Nothing, CreateOperazioneRigaRichiestaOrderEntryEnumFromXml(row.StatoRichiedente)),
            .SistemaErogante = Sistema,
            .IdRichiestaErogante = If(row.IsIDRichiestaEroganteNull(), Nothing, row.IDRichiestaErogante),
            .Prestazione = Prestazione,
            .Consensi = If(row.IsConsensiNull(), Nothing, CreateConsensiTypeFromXml(row.Consensi)),
        .DatiAggiuntivi = datiAggiuntivi
        }

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToRigaRichiestaDatiAggiuntiviType(rows As List(Of OrdiniDS.RigaRichiestaDatoAggiuntivoRow)) As QueueTypes.DatiAggiuntiviType

        If rows Is Nothing Then Return Nothing

        Dim result As New QueueTypes.DatiAggiuntiviType

        For Each d In rows

            Dim valore As String = String.Empty
            If Not d.IsValoreDatoNull Then
                valore = d.ValoreDato.ToString

            ElseIf Not d.IsValoreDatoVarcharNull Then
                valore = d.ValoreDatoVarchar

            ElseIf Not d.IsValoreDatoXmlNull Then
                valore = d.ValoreDatoXml
            End If

            result.Add(New QueueTypes.DatoNomeValoreType() With {.Id = If(d.IsIDDatoAggiuntivoNull, Nothing, d.IDDatoAggiuntivo),
                                                                      .Nome = d.Nome,
                                                                      .TipoDato = d.TipoDato,
                                                                      .TipoContenuto = If(d.IsTipoContenutoNull, Nothing, d.TipoContenuto),
                                                                      .ValoreDato = valore
                                                                     })
        Next

        Return result

    End Function


    <System.Runtime.CompilerServices.Extension()>
    Friend Function GetMaxIdRigaOrderEntry(righeRichieste As List(Of OrdiniDS.RigaRichiestaRow)) As Integer
        '
        ' Calcola il massimo progressivo delle righe
        '
        Dim idRigaCounter As Integer = 0

        If righeRichieste IsNot Nothing AndAlso righeRichieste.Any Then

            ' Calcolo il maggior IdRigaOrderEntry
            '
            Dim listId = righeRichieste.Where(Function(e) Not e.IsIDRigaOrderEntryNull).Select(Function(e) e.IDRigaOrderEntry)
            For Each sId In listId

                Dim i As Integer = 0
                If Integer.TryParse(sId, i) Then

                    If i > idRigaCounter Then
                        idRigaCounter = i
                    End If
                End If
            Next
        End If

        Return idRigaCounter

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function GeneraUnicoIdRigaRichiedente(righeRichieste As QueueTypes.RigheRichiesteType, rigaRichiesta As QueueTypes.RigaRichiestaType) As String
        '
        ' Se vuoto calcola IdRigaRichiedente usando il sistema erogante ed il codice della prestazione
        ' Se dupplicato aggiunge un contatore
        '
        If String.IsNullOrEmpty(rigaRichiesta.IdRigaRichiedente) Then
            rigaRichiesta.IdRigaRichiedente = String.Format("{0}@{1}.{2}", rigaRichiesta.Prestazione.Codice,
                                                                            rigaRichiesta.SistemaErogante.Sistema.Codice,
                                                                            rigaRichiesta.SistemaErogante.Azienda.Codice)
            'Controllo che Id non esista
            ' La lista 'righeRichieste' non deve essere vuota e DEVE contenere la 'rigaRichiesta'
            '
            If righeRichieste IsNot Nothing AndAlso righeRichieste.Any AndAlso righeRichieste.Contains(rigaRichiesta) Then

                ' Cerco i doppi escludendo la riga da calcolare
                '
                Dim sFindIdRiga As String = String.Concat(rigaRichiesta.IdRigaRichiedente, "*")
                Dim RigheDoppie = righeRichieste.FindAll(Function(e) e.IdRigaRichiedente IsNot Nothing AndAlso
                                                             e.IdRigaRichiedente Like sFindIdRiga AndAlso Not e.Equals(rigaRichiesta))

                ' Se doppio aggiungo un codice calcolato su un hash dei DatiAggiuntivi
                '
                If RigheDoppie IsNot Nothing AndAlso RigheDoppie.Any Then

                    Dim iCode As Integer = rigaRichiesta.DatiAggiuntivi.CalcolaHashCode
                    If iCode = 0 Then
                        iCode = righeRichieste.IndexOf(rigaRichiesta)
                    End If

                    rigaRichiesta.IdRigaRichiedente = $"{rigaRichiesta.IdRigaRichiedente}${iCode}"
                End If
            End If
        End If

        Return rigaRichiesta.IdRigaRichiedente

    End Function

#End Region

#Region "DatiAggiuntiviType"

    <System.Runtime.CompilerServices.Extension()>
    Friend Function CalcolaHashCode(datiAggiuntivi As QueueTypes.DatiAggiuntiviType) As Integer

        If datiAggiuntivi IsNot Nothing AndAlso datiAggiuntivi.Any Then
            '
            ' Genero un codice pseudo unico per i dati aggiuntivi
            '
            Dim sbBuffer As New StringBuilder()

            For Each dato In datiAggiuntivi
                Dim iIndex As Integer = datiAggiuntivi.IndexOf(dato)

                sbBuffer.Append($"Id({iIndex}):{dato.Id};")
                sbBuffer.Append($"Nome({iIndex}):{dato.Nome};")
                sbBuffer.Append($"ValoreDato({iIndex}):{dato.ValoreDato};")
            Next

            Return sbBuffer.ToString().GetHashCode
        Else
            Return 0
        End If

    End Function

#End Region


#Region "TestataStatoType"


    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToTestataStatoType(testata As StatoDS.TestataRow, dataAggiuntivi As QueueTypes.DatiAggiuntiviType, _
                                           datiPersistenti As QueueTypes.DatiPersistentiType) As QueueTypes.TestataStatoType
        '
        ' L'operatore IF(,,) non ritorna i tipi NULLABLE
        Dim dtDataPrenotazione As DateTime? = Nothing
        If Not testata.IsDataPrenotazioneNull() Then
            dtDataPrenotazione = testata.DataPrenotazione
        End If

        Dim dtDataVersione As DateTime? = Nothing
        If Not testata.IsDataNull() Then
            dtDataVersione = testata.Data
        End If

        ' Creo Sistema richiedente
        Dim SistemaRichiedente As QueueTypes.SistemaType = Nothing

        If Not testata.IsCodiceAziendaSistemaRichiedenteNull AndAlso Not testata.IsCodiceSistemaRichiedenteNull Then
            SistemaRichiedente = New QueueTypes.SistemaType() With {
                                            .Azienda = New QueueTypes.CodiceDescrizioneType() With {.Codice = testata.CodiceAziendaSistemaRichiedente,
                                                                                         .Descrizione = If(testata.IsDescrizioneAziendaSistemaRichiedenteNull(), Nothing, testata.DescrizioneAziendaSistemaRichiedente)},
                                            .Sistema = New QueueTypes.CodiceDescrizioneType() With {.Codice = testata.CodiceSistemaRichiedente,
                                                                                         .Descrizione = If(testata.IsDescrizioneSistemaRichiedenteNull(), Nothing, testata.DescrizioneSistemaRichiedente)}
                                        }
        End If

        ' Creo Sistema Erogante
        Dim SistemaErogante = New QueueTypes.SistemaType() With {
                                        .Azienda = New QueueTypes.CodiceDescrizioneType() With {.Codice = testata.CodiceAziendaSistemaErogante,
                                                                                     .Descrizione = If(testata.IsDescrizioneAziendaSistemaEroganteNull(), Nothing, testata.DescrizioneAziendaSistemaErogante)},
                                        .Sistema = New QueueTypes.CodiceDescrizioneType() With {.Codice = testata.CodiceSistemaErogante,
                                                                                     .Descrizione = If(testata.IsDescrizioneSistemaEroganteNull(), Nothing, testata.DescrizioneSistemaErogante)}
                                    }

        Dim sIdRichiestaOrderEntry As String
        sIdRichiestaOrderEntry = String.Concat(If(testata.IsAnnoNull, Nothing, testata.Anno), "/", If(testata.IsNumeroNull, Nothing, testata.Numero))

        '
        ' Stato erogante non è interessante in output
        ' Lo sostituisco con lo stato calcolato dell'erogante
        '
        Dim StatoErogante As QueueTypes.CodiceDescrizioneType = New QueueTypes.CodiceDescrizioneType() With
            {
            .Codice = If(testata.IsStatoCalcolatoEroganteCodiceNull(), Nothing, testata.StatoCalcolatoEroganteCodice),
            .Descrizione = If(testata.IsStatoCalcolatoEroganteDescrizioneNull(), Nothing, testata.StatoCalcolatoEroganteDescrizione)
            }
        '
        ' Stato calcolato della intera RICHIESTA nei dati aggiuntivi se non NULL
        '
        Dim sStatoCalcolatoCodice = If(testata.IsStatoCalcolatoCodiceNull(), Nothing, testata.StatoCalcolatoCodice)
        If Not String.IsNullOrEmpty(sStatoCalcolatoCodice) Then

            If dataAggiuntivi Is Nothing Then
                dataAggiuntivi = New QueueTypes.DatiAggiuntiviType
            End If

            Dim datoAggStatoCalcolatoCodice As New QueueTypes.DatoNomeValoreType With
            {
            .Id = DatiAggiuntivi.ID_STATO_CALCOLATO_CODICE,
            .Nome = "StatoCalcolatoCodice",
            .TipoDato = "xs:string",
            .ValoreDato = sStatoCalcolatoCodice
            }
            dataAggiuntivi.Add(datoAggStatoCalcolatoCodice)

            Dim datoAggStatoCalcolatoDescrizione As New QueueTypes.DatoNomeValoreType With
            {
            .Id = DatiAggiuntivi.ID_STATO_CALCOLATO_DESCRIZIONE,
            .Nome = "StatoCalcolatoDescrizione",
            .TipoDato = "xs:string",
            .ValoreDato = If(testata.IsStatoCalcolatoDescrizioneNull(), Nothing, testata.StatoCalcolatoDescrizione)
            }
            dataAggiuntivi.Add(datoAggStatoCalcolatoDescrizione)
        End If

        ' Crea ordineType
        Return New QueueTypes.TestataStatoType() With {
            .IdRichiestaOrderEntry = sIdRichiestaOrderEntry,
            .StatoOrderEntry = If(testata.IsStatoOrderEntryNull, Nothing, testata.StatoOrderEntry),
            .IdRichiestaRichiedente = If(testata.IsIDRichiestaRichiedenteNull, Nothing, testata.IDRichiestaRichiedente),
            .SistemaRichiedente = SistemaRichiedente,
            .IdRichiestaErogante = If(testata.IsIDRichiestaEroganteNull, Nothing, testata.IDRichiestaErogante),
            .SistemaErogante = SistemaErogante,
            .StatoErogante = StatoErogante,
            .Data = dtDataVersione,
            .DataPrenotazione = dtDataPrenotazione,
            .Operatore = If(testata.IsOperatoreNull(), Nothing, CreateOperatoreTypeFromXml(testata.Operatore)),
            .Paziente = If(testata.IsPazienteNull(), Nothing, CreatePazienteTypeFromXml(testata.Paziente, testata.ID)),
            .Note = If(testata.IsNoteNull(), Nothing, testata.Note),
            .Consensi = If(testata.IsConsensiNull(), Nothing, CreateConsensiTypeFromXml(testata.Consensi)),
            .DatiAggiuntivi = dataAggiuntivi,
            .DatiPersistenti = datiPersistenti,
            .RigheErogate = Nothing
            }

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToTestataDatiAggiuntiviType(rows As List(Of StatoDS.TestataDatoAggiuntivoRow)) As QueueTypes.DatiAggiuntiviType

        If rows Is Nothing Then Return Nothing

        Dim result As New QueueTypes.DatiAggiuntiviType

        'Solo i dati non persistenti
        For Each d In rows.FindAll(Function(e) e.IsPersistenteNull = True OrElse e.Persistente = False)

            Dim valore As String = String.Empty
            If Not d.IsValoreDatoNull Then
                valore = d.ValoreDato.ToString

            ElseIf Not d.IsValoreDatoVarcharNull Then
                valore = d.ValoreDatoVarchar

            ElseIf Not d.IsValoreDatoXmlNull Then
                valore = d.ValoreDatoXml
            End If

            result.Add(New QueueTypes.DatoNomeValoreType() With {.Id = If(d.IsIDDatoAggiuntivoNull, Nothing, d.IDDatoAggiuntivo),
                                                                     .Nome = d.Nome,
                                                                     .TipoDato = d.TipoDato,
                                                                     .TipoContenuto = If(d.IsTipoContenutoNull, Nothing, d.TipoContenuto),
                                                                     .ValoreDato = valore
                                                                    })
        Next

        Return result

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToTestataDatiPersistentiType(rows As List(Of StatoDS.TestataDatoAggiuntivoRow)) As QueueTypes.DatiPersistentiType

        If rows Is Nothing Then Return Nothing

        Dim result As New QueueTypes.DatiPersistentiType

        'Solo i dati non persistenti
        For Each d In rows.FindAll(Function(e) e.IsPersistenteNull = False AndAlso e.Persistente = True)

            Dim valore As String = String.Empty
            If Not d.IsValoreDatoNull Then
                valore = d.ValoreDato.ToString

            ElseIf Not d.IsValoreDatoVarcharNull Then
                valore = d.ValoreDatoVarchar

            ElseIf Not d.IsValoreDatoXmlNull Then
                valore = d.ValoreDatoXml
            End If

            result.Add(New QueueTypes.DatoNomeValoreType() With {.Id = If(d.IsIDDatoAggiuntivoNull, Nothing, d.IDDatoAggiuntivo),
                                                                      .Nome = d.Nome,
                                                                      .TipoDato = d.TipoDato,
                                                                      .TipoContenuto = If(d.IsTipoContenutoNull, Nothing, d.TipoContenuto),
                                                                      .ValoreDato = valore
                                                                     })
        Next

        Return result

    End Function

#End Region

#Region "RigaErogataType"

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToRigaErogataType(row As StatoDS.RigaErogataRow, datiAggiuntivi As QueueTypes.DatiAggiuntiviType) As QueueTypes.RigaErogataType

        'Creo prestazione
        Dim Prestazione = New QueueTypes.PrestazioneType() With {.Codice = row.CodicePrestazione,
                                                      .Descrizione = If(row.IsDescrizionePrestazioneNull(), Nothing, row.DescrizionePrestazione)}

        Return New QueueTypes.RigaErogataType() With {
            .IdRigaOrderEntry = Nothing,
            .StatoOrderEntry = row.StatoOrderEntry,
            .IdRigaRichiedente = If(row.IsIDRigaRichiedenteNull(), Nothing, row.IDRigaRichiedente),
            .IdRigaErogante = If(row.IsIDRigaEroganteNull(), Nothing, row.IDRigaErogante),
            .StatoErogante = CreateOperazioneRigaRichiestaOrderEntryEnumFromXml(row.StatoErogante),
            .Data = If(row.IsDataNull, Nothing, row.Data),
            .Operatore = If(row.IsOperatoreNull(), Nothing, CreateOperatoreTypeFromXml(row.Operatore)),
            .Prestazione = Prestazione,
            .Consensi = If(row.IsConsensiNull(), Nothing, CreateConsensiTypeFromXml(row.Consensi)),
            .DatiAggiuntivi = datiAggiuntivi
            }

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToRigaErogataDatiAggiuntiviType(rows As List(Of StatoDS.RigaErogataDatoAggiuntivoRow)) As QueueTypes.DatiAggiuntiviType

        If rows Is Nothing Then Return Nothing

        Dim result As New QueueTypes.DatiAggiuntiviType

        For Each d In rows

            Dim valore As String = String.Empty
            If Not d.IsValoreDatoNull Then
                valore = d.ValoreDato.ToString

            ElseIf Not d.IsValoreDatoVarcharNull Then
                valore = d.ValoreDatoVarchar

            ElseIf Not d.IsValoreDatoXmlNull Then
                valore = d.ValoreDatoXml
            End If

            result.Add(New QueueTypes.DatoNomeValoreType() With {.Id = If(d.IsIDDatoAggiuntivoNull, Nothing, d.IDDatoAggiuntivo),
                                                                      .Nome = d.Nome,
                                                                      .TipoDato = d.TipoDato,
                                                                      .TipoContenuto = If(d.IsTipoContenutoNull, Nothing, d.TipoContenuto),
                                                                      .ValoreDato = valore
                                                                     })
        Next

        Return result

    End Function

#End Region

#Region "ConsensiType"

    Friend Function CreateConsensiTypeFromXml(ByRef xml As String) As QueueTypes.ConsensiType

        Dim result As QueueTypes.ConsensiType = Nothing

        Try
            ' Cast namespace
            If xml.Contains("http://schemas.progel.it/BT/OE/QueueTypes/1.1") Then
                result = DataContractSerializerHelper.Deserialize(Of QueueTypes.ConsensiType)(xml)

            ElseIf xml.Contains("http://schemas.progel.it/OE/Types/1.1") Then
                Dim typeWcf As Schemas.Wcf.BaseTypes.ConsensiType = Nothing

                typeWcf = DataContractSerializerHelper.Deserialize(Of Schemas.Wcf.BaseTypes.ConsensiType)(xml)
                result = typeWcf.ToConsensiType
            End If

        Catch ex As Exception
        End Try

        Return result

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToConsensiType(ByRef obj As Schemas.Wcf.BaseTypes.ConsensiType) As QueueTypes.ConsensiType
        '
        ' Converte tipo WCF in MSG
        '
        If obj Is Nothing Then Return Nothing

        Dim result As New QueueTypes.ConsensiType()

        For Each c In obj
            result.Add(New QueueTypes.ConsensoType() With {.Tipo = c.Tipo,
                                                               .Valore = c.Valore,
                                                               .Data = c.Data,
                                                               .Operatore = c.Operatore.ToOperatoreType()
                                                              })
        Next
        Return result

    End Function

#End Region

#Region "CodiceDescrizioneType"

    Friend Function CreateCodiceDescrizioneTypeFromXml(ByRef xml As String) As QueueTypes.CodiceDescrizioneType

        Dim result As QueueTypes.CodiceDescrizioneType = Nothing

        Try
            ' Cast namespace
            If xml.Contains("http://schemas.progel.it/BT/OE/QueueTypes/1.1") Then

                result = DataContractSerializerHelper.Deserialize(Of QueueTypes.CodiceDescrizioneType)(xml)

            ElseIf xml.Contains("http://schemas.progel.it/OE/Types/1.1") Then

                Dim typeWcf As Schemas.Wcf.BaseTypes.CodiceDescrizioneType = Nothing
                typeWcf = DataContractSerializerHelper.Deserialize(Of Schemas.Wcf.BaseTypes.CodiceDescrizioneType)(xml)

                result = typeWcf.ToCodiceDescrizioneType
            End If

        Catch ex As Exception
        End Try

        Return result

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToCodiceDescrizioneType(ByRef obj As Schemas.Wcf.BaseTypes.CodiceDescrizioneType) As QueueTypes.CodiceDescrizioneType
        '
        ' Converte tipo WCF in MSG
        '
        If obj Is Nothing Then Return Nothing

        Dim result As New QueueTypes.CodiceDescrizioneType()
        result.Codice = obj.Codice
        result.Descrizione = obj.Descrizione
        Return result

    End Function

#End Region

#Region "PazienteType"

    Friend Function CreatePazienteTypeFromXml(ByRef xml As String, idOrdine As Guid) As QueueTypes.PazienteType

        Dim result As QueueTypes.PazienteType = Nothing

        Try
            ' Cast namespace
            If xml.Contains("http://schemas.progel.it/BT/OE/QueueTypes/1.1") Then

                result = DataContractSerializerHelper.Deserialize(Of QueueTypes.PazienteType)(xml)

            ElseIf xml.Contains("http://schemas.progel.it/OE/Types/1.1") Then

                Dim typeWcf As Schemas.Wcf.BaseTypes.PazienteType = Nothing
                typeWcf = DataContractSerializerHelper.Deserialize(Of Schemas.Wcf.BaseTypes.PazienteType)(xml)

                result = typeWcf.ToPazienteType
            End If

        Catch ex As Exception
        End Try

        Return result
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToPazienteType(ByRef obj As Schemas.Wcf.BaseTypes.PazienteType) As QueueTypes.PazienteType
        '
        ' Converte PazienteType da WCF a MSG
        '
        If obj Is Nothing Then Return Nothing

        Dim result As New QueueTypes.PazienteType()

        result.IdRichiedente = obj.IdRichiedente
        result.IdSac = obj.IdSac
        result.AnagraficaCodice = obj.AnagraficaCodice
        result.AnagraficaNome = obj.AnagraficaNome
        result.CodiceFiscale = obj.CodiceFiscale
        result.Cognome = obj.Cognome
        result.Nome = obj.Nome
        result.DataNascita = obj.DataNascita
        result.ComuneNascita = obj.ComuneNascita
        result.CodiceIstatComuneNascita = obj.CodiceIstatComuneNascita
        result.Sesso = obj.Sesso
        result.IndirizzoResidenza = obj.IndirizzoResidenza
        result.ComuneResidenza = obj.ComuneResidenza
        result.CodiceIstatComuneResidenza = obj.CodiceIstatComuneResidenza
        result.CapResidenza = obj.CapResidenza
        result.Nazionalita = obj.Nazionalita
        result.CodiceIstatNazionalita = obj.CodiceIstatNazionalita
        result.Cittadinanza = obj.Cittadinanza
        result.CodiceIstatCittadinanza = obj.CodiceIstatCittadinanza
        result.DataModifica = obj.DataModifica
        result.TesseraSanitaria = Nothing
        result.CodiceUsl = Nothing

        Return result
    End Function

#End Region

#Region "OperatoreType"

    Friend Function CreateOperatoreTypeFromXml(ByRef xml As String) As QueueTypes.OperatoreType

        Dim result As QueueTypes.OperatoreType = Nothing

        Try
            ' Cast namespace
            If xml.Contains("http://schemas.progel.it/BT/OE/QueueTypes/1.1") Then
                result = DataContractSerializerHelper.Deserialize(Of QueueTypes.OperatoreType)(xml)

            ElseIf xml.Contains("http://schemas.progel.it/OE/Types/1.1") Then

                Dim typeWcf As Schemas.Wcf.BaseTypes.OperatoreType = Nothing
                typeWcf = DataContractSerializerHelper.Deserialize(Of Schemas.Wcf.BaseTypes.OperatoreType)(xml)

                result = typeWcf.ToOperatoreType
            End If

        Catch ex As Exception
        End Try

        Return result
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToOperatoreType(ByRef obj As Schemas.Wcf.BaseTypes.OperatoreType) As QueueTypes.OperatoreType
        '
        ' Converte tipo WCF in MSG
        '
        If obj Is Nothing Then Return Nothing

        Dim result As New QueueTypes.OperatoreType()

        result.ID = obj.ID
        result.Cognome = obj.Cognome
        result.Nome = obj.Nome
        result.CodiceFiscale = obj.CodiceFiscale
        Return result

    End Function

#End Region

#Region "RegimeType"

    Friend Function CreateRegimeTypeFromXml(ByRef xml As String) As QueueTypes.CodiceDescrizioneType

        Dim result As QueueTypes.CodiceDescrizioneType = Nothing

        Try
            ' Cast namespace
            If xml.Contains("http://schemas.progel.it/BT/OE/QueueTypes/1.1") Then
                result = DataContractSerializerHelper.Deserialize(Of QueueTypes.CodiceDescrizioneType)(xml)

            ElseIf xml.Contains("http://schemas.progel.it/OE/Types/1.1") Then

                Dim typeWcf As Schemas.Wcf.BaseTypes.RegimeType = Nothing
                typeWcf = DataContractSerializerHelper.Deserialize(Of Schemas.Wcf.BaseTypes.RegimeType)(xml)

                result = typeWcf.ToCodiceDescrizioneType
            End If

        Catch ex As Exception
        End Try

        Return result
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToCodiceDescrizioneType(ByRef obj As Schemas.Wcf.BaseTypes.RegimeType) As QueueTypes.CodiceDescrizioneType
        '
        ' Converte tipo WCF in MSG
        '
        If obj Is Nothing Then Return Nothing

        Dim result As New QueueTypes.CodiceDescrizioneType()

        result.Codice = obj.Codice.ToString
        result.Descrizione = obj.Descrizione
        Return result

    End Function

#End Region

#Region "RegimeType"

    Friend Function CreatePrioritaTypeFromXml(ByRef xml As String) As QueueTypes.CodiceDescrizioneType

        Dim result As QueueTypes.CodiceDescrizioneType = Nothing

        Try
            ' Cast namespace
            If xml.Contains("http://schemas.progel.it/BT/OE/QueueTypes/1.1") Then
                result = DataContractSerializerHelper.Deserialize(Of QueueTypes.CodiceDescrizioneType)(xml)

            ElseIf xml.Contains("http://schemas.progel.it/OE/Types/1.1") Then

                Dim typeWcf As Schemas.Wcf.BaseTypes.PrioritaType = Nothing
                typeWcf = DataContractSerializerHelper.Deserialize(Of Schemas.Wcf.BaseTypes.PrioritaType)(xml)

                result = typeWcf.ToCodiceDescrizioneType
            End If

        Catch ex As Exception
        End Try

        Return result
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToCodiceDescrizioneType(ByRef obj As Schemas.Wcf.BaseTypes.PrioritaType) As QueueTypes.CodiceDescrizioneType
        '
        ' Converte tipo WCF in MSG
        '
        If obj Is Nothing Then Return Nothing

        Dim result As New QueueTypes.CodiceDescrizioneType()

        result.Codice = obj.Codice.ToString
        result.Descrizione = obj.Descrizione
        Return result

    End Function

#End Region


#Region "OperazioneRichiestaOrderEntryEnum"

    Friend Function CreateOperazioneRichiestaOrderEntryEnumFromXml(ByRef xml As String) As QueueTypes.CodiceDescrizioneType

        Dim result As QueueTypes.CodiceDescrizioneType = Nothing

        Try
            ' Cast namespace
            If xml.Contains("http://schemas.progel.it/BT/OE/QueueTypes/1.1") Then
                result = DataContractSerializerHelper.Deserialize(Of QueueTypes.CodiceDescrizioneType)(xml)

            ElseIf xml.Contains("http://schemas.progel.it/OE/Types/1.1") Then

                Dim typeWcf As Schemas.Wcf.BaseTypes.OperazioneRichiestaOrderEntryEnum = Nothing
                typeWcf = DataContractSerializerHelper.Deserialize(Of Schemas.Wcf.BaseTypes.OperazioneRichiestaOrderEntryEnum)(xml)

                result = typeWcf.ToCodiceDescrizioneType
            End If

        Catch ex As Exception
        End Try

        Return result
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToCodiceDescrizioneType(ByRef obj As Schemas.Wcf.BaseTypes.OperazioneRichiestaOrderEntryEnum) As QueueTypes.CodiceDescrizioneType
        '
        ' Converte tipo WCF in MSG
        '
        Dim result As New QueueTypes.CodiceDescrizioneType()

        result.Codice = obj.ToString
        Return result

    End Function

#End Region

#Region "OperazioneRigaRichiestaOrderEntryEnum"

    Friend Function CreateOperazioneRigaRichiestaOrderEntryEnumFromXml(ByRef xml As String) As QueueTypes.CodiceDescrizioneType

        Dim result As QueueTypes.CodiceDescrizioneType = Nothing

        Try
            ' Cast namespace
            If xml.Contains("http://schemas.progel.it/BT/OE/QueueTypes/1.1") Then
                result = DataContractSerializerHelper.Deserialize(Of QueueTypes.CodiceDescrizioneType)(xml)

            ElseIf xml.Contains("http://schemas.progel.it/OE/Types/1.1") Then

                Dim typeWcf As Schemas.Wcf.BaseTypes.OperazioneRigaRichiestaOrderEntryEnum = Nothing
                typeWcf = DataContractSerializerHelper.Deserialize(Of Schemas.Wcf.BaseTypes.OperazioneRigaRichiestaOrderEntryEnum)(xml)

                result = typeWcf.ToCodiceDescrizioneType
            End If

        Catch ex As Exception
        End Try

        Return result
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToCodiceDescrizioneType(ByRef obj As Schemas.Wcf.BaseTypes.OperazioneRigaRichiestaOrderEntryEnum) As QueueTypes.CodiceDescrizioneType
        '
        ' Converte tipo WCF in MSG
        '
        Dim result As New QueueTypes.CodiceDescrizioneType()

        result.Codice = obj.ToString
        Return result

    End Function

#End Region


#Region "StatoEroganteOrderEntryEnum"

    Friend Function CreateStatoTestataErogatoFromXml(ByRef xml As String) As QueueTypes.CodiceDescrizioneType

        Dim result As QueueTypes.CodiceDescrizioneType = Nothing

        Try
            ' Cast namespace
            If xml.Contains("http://schemas.progel.it/BT/OE/QueueTypes/1.1") Then
                result = DataContractSerializerHelper.Deserialize(Of QueueTypes.CodiceDescrizioneType)(xml)

            ElseIf xml.Contains("http://schemas.progel.it/OE/Types/1.1") Then

                Dim typeWcf As Schemas.Wcf.BaseTypes.StatoTestataErogatoOrderEntryEnum = Nothing
                typeWcf = DataContractSerializerHelper.Deserialize(Of Schemas.Wcf.BaseTypes.StatoTestataErogatoOrderEntryEnum)(xml)

                result = typeWcf.ToCodiceDescrizioneType
            End If

        Catch ex As Exception
        End Try

        Return result
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToCodiceDescrizioneType(ByRef obj As Schemas.Wcf.BaseTypes.StatoTestataErogatoOrderEntryEnum) As QueueTypes.CodiceDescrizioneType
        '
        ' Converte tipo WCF in MSG
        '
        Dim result As New QueueTypes.CodiceDescrizioneType()

        result.Codice = obj.ToString
        Return result

    End Function

#End Region

#Region "StatoRigaErogataOrderEntryEnum"

    Friend Function CreateStatoRigaErogataFromXml(ByRef xml As String) As QueueTypes.CodiceDescrizioneType

        Dim result As QueueTypes.CodiceDescrizioneType = Nothing

        Try
            ' Cast namespace
            If xml.Contains("http://schemas.progel.it/BT/OE/QueueTypes/1.1") Then
                result = DataContractSerializerHelper.Deserialize(Of QueueTypes.CodiceDescrizioneType)(xml)

            ElseIf xml.Contains("http://schemas.progel.it/OE/Types/1.1") Then

                Dim typeWcf As Schemas.Wcf.BaseTypes.StatoRigaErogataOrderEntryEnum = Nothing
                typeWcf = DataContractSerializerHelper.Deserialize(Of Schemas.Wcf.BaseTypes.StatoRigaErogataOrderEntryEnum)(xml)

                result = typeWcf.ToCodiceDescrizioneType
            End If

        Catch ex As Exception
        End Try

        Return result
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToCodiceDescrizioneType(ByRef obj As Schemas.Wcf.BaseTypes.StatoRigaErogataOrderEntryEnum) As QueueTypes.CodiceDescrizioneType
        '
        ' Converte tipo WCF in MSG
        '
        Dim result As New QueueTypes.CodiceDescrizioneType()

        result.Codice = obj.ToString
        Return result

    End Function

#End Region

#Region "PazienteType"
    <System.Runtime.CompilerServices.Extension()>
    Friend Function GetInstance(ByVal obj As QueueTypes.PazienteType) As QueueTypes.PazienteType

        If obj Is Nothing Then
            obj = New QueueTypes.PazienteType()
        End If
        Return obj

    End Function

#End Region

#Region "PazienteType"

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ParseGuid(ByVal input As String, Optional VarNameForError As String = Nothing) As Guid?

        If Not String.IsNullOrEmpty(input) Then

            Try
                Return New Guid(input)
            Catch
                Dim sMessagge As String = "{0} deve contenere un valore Guid a 32 cifre con 4 trattini (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)!"
                If Not String.IsNullOrEmpty(VarNameForError) Then
                    sMessagge = String.Format(sMessagge, VarNameForError)
                Else
                    sMessagge = String.Format(sMessagge, "L'elemento")
                End If
                Throw New Exception(sMessagge)
            End Try
        End If

    End Function
#End Region




#Region "XElement"

    <System.Runtime.CompilerServices.Extension()>
    Public Sub FillInstance(Of T)(obj As T, node As XElement)

        For Each p As PropertyInfo In obj.GetType().GetProperties()

            If p.CanRead AndAlso node.Element(p.Name) IsNot Nothing Then
                '
                ' Copia tipizzata
                '
                If p.PropertyType Is GetType(String) Then
                    p.SetValue(obj, node.Element(p.Name).TryParseString(), Nothing)

                ElseIf p.PropertyType Is GetType(Boolean) Then
                    p.SetValue(obj, node.Element(p.Name).ParseBoolean(), Nothing)

                ElseIf p.PropertyType Is GetType(Nullable(Of Boolean)) Then
                    p.SetValue(obj, node.Element(p.Name).TryParseBoolean(), Nothing)

                ElseIf p.PropertyType Is GetType(DateTime) Then
                    p.SetValue(obj, node.Element(p.Name).ParseDateTime(), Nothing)

                ElseIf p.PropertyType Is GetType(Nullable(Of DateTime)) Then
                    p.SetValue(obj, node.Element(p.Name).TryParseDateTime(), Nothing)

                ElseIf p.PropertyType Is GetType(Integer) Then
                    p.SetValue(obj, node.Element(p.Name).ParseInteger(), Nothing)

                ElseIf p.PropertyType Is GetType(Nullable(Of Integer)) Then
                    p.SetValue(obj, node.Element(p.Name).TryParseInteger(), Nothing)

                ElseIf p.PropertyType Is GetType(Guid) Then
                    p.SetValue(obj, node.Element(p.Name).ParseGuid(), Nothing)

                ElseIf p.PropertyType Is GetType(Nullable(Of Guid)) Then
                    p.SetValue(obj, node.Element(p.Name).TryParseGuid(), Nothing)

                ElseIf p.PropertyType Is GetType(Long) Then
                    p.SetValue(obj, node.Element(p.Name).ParseLong(), Nothing)

                ElseIf p.PropertyType Is GetType(Nullable(Of Long)) Then
                    p.SetValue(obj, node.Element(p.Name).TryParseLong(), Nothing)

                ElseIf p.PropertyType Is GetType(Short) Then
                    p.SetValue(obj, node.Element(p.Name).ParseShort(), Nothing)

                ElseIf p.PropertyType Is GetType(Nullable(Of Short)) Then
                    p.SetValue(obj, node.Element(p.Name).TryParseShort(), Nothing)

                ElseIf p.PropertyType Is GetType(Single) Then
                    p.SetValue(obj, node.Element(p.Name).ParseSingle(), Nothing)

                ElseIf p.PropertyType Is GetType(Nullable(Of Single)) Then
                    p.SetValue(obj, node.Element(p.Name).TryParseSingle(), Nothing)

                ElseIf p.PropertyType Is GetType(Double) Then
                    p.SetValue(obj, node.Element(p.Name).ParseDouble(), Nothing)

                ElseIf p.PropertyType Is GetType(Nullable(Of Double)) Then
                    p.SetValue(obj, node.Element(p.Name).TryParseDouble(), Nothing)

                ElseIf p.PropertyType Is GetType(Byte) Then
                    p.SetValue(obj, node.Element(p.Name).ParseByte(), Nothing)

                ElseIf p.PropertyType Is GetType(Nullable(Of Byte)) Then
                    p.SetValue(obj, node.Element(p.Name).TryParseByte(), Nothing)

                ElseIf p.PropertyType Is GetType(XElement) Then
                    p.SetValue(obj, node.Element(p.Name), Nothing)

                Else
                    p.SetValue(obj, node.Element(p.Name).Value, Nothing)
                End If

            End If
        Next

    End Sub

    <System.Runtime.CompilerServices.Extension()>
    Friend Function TryParseString(ByVal input As XElement) As String
        If input IsNot Nothing AndAlso Not String.IsNullOrEmpty(input.Value) Then
            Return input.Value.ToString()
        Else
            Return Nothing
        End If
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function TryParseGuid(ByVal input As XElement) As Nullable(Of Guid)
        If input IsNot Nothing AndAlso Not String.IsNullOrEmpty(input.Value) Then
            Return New Guid(input.Value)
        Else
            Return Nothing
        End If
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ParseGuid(ByVal input As XElement) As Guid
        Return New Guid(input.Value)
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function TryParseDateTime(ByVal input As XElement) As Nullable(Of DateTime)
        If input IsNot Nothing AndAlso Not String.IsNullOrEmpty(input.Value) Then
            Return CType(input.Value, DateTime)
        Else
            Return Nothing
        End If
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ParseDateTime(ByVal input As XElement) As DateTime
        Return CType(input.Value, DateTime)
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function TryParseInteger(ByVal input As XElement) As Nullable(Of Integer)
        If input IsNot Nothing AndAlso Not String.IsNullOrEmpty(input.Value) Then
            Return CType(input.Value, Integer)
        Else
            Return Nothing
        End If
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ParseInteger(ByVal input As XElement) As Integer
        Return CType(input.Value, Integer)
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function TryParseLong(ByVal input As XElement) As Nullable(Of Long)
        If input IsNot Nothing AndAlso Not String.IsNullOrEmpty(input.Value) Then
            Return CType(input.Value, Long)
        Else
            Return Nothing
        End If
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ParseLong(ByVal input As XElement) As Long
        Return CType(input.Value, Long)
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function TryParseShort(ByVal input As XElement) As Nullable(Of Short)
        If input IsNot Nothing AndAlso Not String.IsNullOrEmpty(input.Value) Then
            Return CType(input.Value, Short)
        Else
            Return Nothing
        End If
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ParseShort(ByVal input As XElement) As Short
        Return CType(input.Value, Short)
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function TryParseSingle(ByVal input As XElement) As Nullable(Of Single)
        If input IsNot Nothing AndAlso Not String.IsNullOrEmpty(input.Value) Then
            Return CType(input.Value, Single)
        Else
            Return Nothing
        End If
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ParseSingle(ByVal input As XElement) As Single
        Return CType(input.Value, Single)
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function TryParseDouble(ByVal input As XElement) As Nullable(Of Double)
        If input IsNot Nothing AndAlso Not String.IsNullOrEmpty(input.Value) Then
            Return CType(input.Value, Double)
        Else
            Return Nothing
        End If
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ParseDouble(ByVal input As XElement) As Double
        Return CType(input.Value, Double)
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function TryParseByte(ByVal input As XElement) As Nullable(Of Byte)
        If input IsNot Nothing AndAlso Not String.IsNullOrEmpty(input.Value) Then
            Return CType(input.Value, Byte)
        Else
            Return Nothing
        End If
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ParseByte(ByVal input As XElement) As Byte
        Return CType(input.Value, Byte)
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function TryParseBoolean(ByVal input As XElement) As Nullable(Of Boolean)
        If input IsNot Nothing AndAlso Not String.IsNullOrEmpty(input.Value) Then
            Return CType(input.Value, Boolean)
        Else
            Return Nothing
        End If
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ParseBoolean(ByVal input As XElement) As Boolean
        Return CType(input.Value, Boolean)
    End Function

#End Region

End Module