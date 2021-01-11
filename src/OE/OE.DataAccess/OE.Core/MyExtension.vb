Imports Msg = OE.Core.Schemas.Msg

#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
'Versione 1.2
Imports Wcf = OE.Core.Schemas.Wcf12
#Else
'Versione 1.0 e 1.1
Imports Wcf = OE.Core.Schemas.Wcf
#End If

Module TypeExtension

    ''' <summary>
    ''' Ritorna un oggetto di tipo DatiAccessoriType da una DatiAccessoriDataTable
    ''' </summary>
    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToDatiAccessoriType(dt As DatiAccessoriDS.DatiAccessoriDataTable) As Wcf.WsTypes.DatiAccessoriType

        Dim result As Wcf.WsTypes.DatiAccessoriType = Nothing

        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            'Creo oggetto di ritorno
            result = New Wcf.WsTypes.DatiAccessoriType

            'Carico le righe
            For Each row In dt
                result.Add(row.ToDatoAccessorioType)
            Next
        End If

        Return result

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToDatoAccessorioType(row As DatiAccessoriDS.DatiAccessoriRow) As Wcf.WsTypes.DatoAccessorioType

        Return New Wcf.WsTypes.DatoAccessorioType() With {
                    .Codice = row.Codice,
                    .Descrizione = If(row.IsDescrizioneNull(), Nothing, row.Descrizione),
                    .Etichetta = row.Etichetta,
                    .Tipo = DirectCast([Enum].Parse(GetType(Wcf.WsTypes.TipoDatoAccessorioEnum), row.Tipo), Wcf.WsTypes.TipoDatoAccessorioEnum),
                    .Obbligatorio = row.Obbligatorio,
                    .Ripetibile = row.Ripetibile,
                    .Valori = If(row.IsValoriNull(), Nothing, row.Valori),
                    .Ordinamento = If(row.IsOrdinamentoNull(), Nothing, row.Ordinamento),
                    .Gruppo = If(row.IsGruppoNull(), Nothing, row.Gruppo),
                    .ValidazioneRegex = If(row.IsValidazioneRegexNull(), Nothing, row.ValidazioneRegex),
                    .ValidazioneMessaggio = If(row.IsValidazioneMessaggioNull(), Nothing, row.ValidazioneMessaggio),
                    .internal_NomeDatoAggiuntivo = If(row.IsNomeDatoAggiuntivoNull, Nothing, row.NomeDatoAggiuntivo),
                    .internal_DiSistema = If(row.IsSistemaNull, False, row.Sistema),
                    .internal_ConcatenaNomeUguale = row.ConcatenaNomeUguale,
                    .internal_IdPrestazione = row.IDPrestazione,
                    .internal_ValoriDinamiciAbilita = row.ValoriDinamiciAbilita,
                    .internal_ValoriDinamiciParametri = If(row.IsValoriDinamiciParametriNull, Nothing, row.ValoriDinamiciParametri)
                    }

    End Function


    ''' <summary>
    ''' Ritorna un oggetto di tipo ToPrestazioneErogabiliType da una PrestazioniRow
    ''' </summary>
    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToPrestazioneErogabiliType(row As PrestazioniDS.PrestazioniProfiliRow, profiloPrestazioni As Wcf.WsTypes.PrestazioniErogabiliType, _
                                                                                datiAccessori As Wcf.WsTypes.DatiAccessoriType) As Wcf.WsTypes.PrestazioneErogabileType

        Dim result As Wcf.WsTypes.PrestazioneErogabileType = Nothing

        If row IsNot Nothing Then

            'Creo oggetto di ritorno
            result = New Wcf.WsTypes.PrestazioneErogabileType() With {
                            .Id = row.ID.ToString().ToUpper(),
                            .Codice = row.Codice,
                            .Descrizione = If(row.IsDescrizioneNull(), Nothing, row.Descrizione),
                            .Prestazioni = profiloPrestazioni,
                            .DatiAccessori = datiAccessori,
                            .Attributi = New Wcf.WsTypes.PrestazioneAttributiType()
                        }

            'Setto il sistema e tipo
            If row.Tipo <> Wcf.WsTypes.TipoPrestazioneErogabileEnum.Prestazione Then
                'Se profilo decodifico tipo e il sistema è vuoto
                result.Tipo = DirectCast([Enum].Parse(GetType(Wcf.WsTypes.TipoPrestazioneErogabileEnum), row.Tipo.ToString()),  _
                    Wcf.WsTypes.TipoPrestazioneErogabileEnum)

                result.SistemaErogante = New Wcf.BaseTypes.SistemaType() With {
                                .Azienda = New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = ""},
                                .Sistema = New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = ""}
                                }

            Else
                'E' una prestazione
                result.Tipo = Wcf.WsTypes.TipoPrestazioneErogabileEnum.Prestazione

                result.SistemaErogante = New Wcf.BaseTypes.SistemaType() With {
                                .Azienda = New Wcf.BaseTypes.CodiceDescrizioneType() With {
                                            .Codice = row.CodiceAzienda,
                                            .Descrizione = If(row.IsDescrizioneAziendaNull(), Nothing, row.DescrizioneAzienda)},
                                .Sistema = New Wcf.BaseTypes.CodiceDescrizioneType() With {
                                            .Codice = row.CodiceSistema,
                                            .Descrizione = If(row.IsDescrizioneSistemaNull(), Nothing, row.DescrizioneSistema)}
                                }
            End If
        End If

        Return result

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToPrestazioneErogabiliType(row As PrestazioniDS.PrestazioneRow, profiloPrestazioni As Wcf.WsTypes.PrestazioniErogabiliType, _
                                                                                datiAccessori As Wcf.WsTypes.DatiAccessoriType) As Wcf.WsTypes.PrestazioneErogabileType

        Dim result As Wcf.WsTypes.PrestazioneErogabileType = Nothing

        If row IsNot Nothing Then

            'Creo oggetto di ritorno
            result = New Wcf.WsTypes.PrestazioneErogabileType() With {
                        .Id = row.ID.ToString().ToUpper(),
                        .Codice = row.Codice,
                        .Descrizione = If(row.IsDescrizioneNull(), Nothing, row.Descrizione),
                        .Prestazioni = profiloPrestazioni,
                        .DatiAccessori = datiAccessori,
                        .Attributi = New Wcf.WsTypes.PrestazioneAttributiType()
                    }

            'Setto il sistema e tipo
            If row.Tipo <> Wcf.WsTypes.TipoPrestazioneErogabileEnum.Prestazione Then
                'Se profilo decodifico tipo e il sistema è vuoto
                result.Tipo = DirectCast([Enum].Parse(GetType(Wcf.WsTypes.TipoPrestazioneErogabileEnum), row.Tipo.ToString()),  _
                    Wcf.WsTypes.TipoPrestazioneErogabileEnum)

                result.SistemaErogante = New Wcf.BaseTypes.SistemaType() With {
                                .Azienda = New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = ""},
                                .Sistema = New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = ""}
                                }

            Else
                'E' una prestazione
                result.Tipo = Wcf.WsTypes.TipoPrestazioneErogabileEnum.Prestazione

                result.SistemaErogante = New Wcf.BaseTypes.SistemaType() With {
                            .Azienda = New Wcf.BaseTypes.CodiceDescrizioneType() With {
                                .Codice = row.CodiceAziendaSistemaErogante,
                                .Descrizione = If(row.IsDescrizioneAziendaSistemaEroganteNull(), Nothing, row.DescrizioneAziendaSistemaErogante)},
                            .Sistema = New Wcf.BaseTypes.CodiceDescrizioneType() With {
                                .Codice = row.CodiceSistemaErogante,
                                .Descrizione = If(row.IsDescrizioneSistemaEroganteNull(), Nothing, row.DescrizioneSistemaErogante)}}
            End If


        End If

        Return result

    End Function


    ''' <summary>
    ''' Ritorna un oggetto di tipo PrestazioneListaType da una PrestazioniRow
    ''' </summary>
    ''' 
    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToPrestazioniListaType(dt As PrestazioniDS.PrestazioniDataTable) As Wcf.WsTypes.PrestazioniListaType

        Dim result As Wcf.WsTypes.PrestazioniListaType = Nothing

        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            'Creo oggetto di ritorno
            result = New Wcf.WsTypes.PrestazioniListaType

            'Carico le righe
            For Each row As PrestazioniDS.PrestazioniRow In dt
                result.Add(row.ToPrestazioneListaType)
            Next
        End If

        Return result

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToPrestazioniListaType(dt As TemplateDS.ProfiliDataTable) As Wcf.WsTypes.PrestazioniListaType

        Dim result As Wcf.WsTypes.PrestazioniListaType = Nothing

        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            'Creo oggetto di ritorno
            result = New Wcf.WsTypes.PrestazioniListaType

            'Carico le righe
            For Each row As TemplateDS.ProfiliRow In dt
                result.Add(row.ToPrestazioneListaType)
            Next
        End If

        Return result

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToPrestazioneListaType(row As PrestazioniDS.PrestazioneRow) As Wcf.WsTypes.PrestazioneListaType

        Dim result As Wcf.WsTypes.PrestazioneListaType = Nothing

        If row IsNot Nothing Then
            'Creo oggetto di ritorno
            result = New Wcf.WsTypes.PrestazioneListaType() With {
                        .Id = row.ID.ToString().ToUpper(),
                        .Codice = row.Codice,
                        .Descrizione = If(row.IsDescrizioneNull(), Nothing, row.Descrizione)
                        }

            'Setto il sistema e tipo
            If row.Tipo <> Wcf.WsTypes.TipoPrestazioneErogabileEnum.Prestazione Then
                'Se profilo decodifico tipo e il sistema è vuoto
                result.Tipo = DirectCast([Enum].Parse(GetType(Wcf.WsTypes.TipoPrestazioneErogabileEnum), row.Tipo.ToString()),  _
                    Wcf.WsTypes.TipoPrestazioneErogabileEnum)

                result.SistemaErogante = New Wcf.BaseTypes.SistemaType() With {
                                .Azienda = New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = ""},
                                .Sistema = New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = ""}
                                }

            Else
                'E' una prestazione
                result.Tipo = Wcf.WsTypes.TipoPrestazioneErogabileEnum.Prestazione

                result.SistemaErogante = New Wcf.BaseTypes.SistemaType() With {
                            .Azienda = New Wcf.BaseTypes.CodiceDescrizioneType() With {
                                .Codice = row.CodiceAziendaSistemaErogante,
                                .Descrizione = If(row.IsDescrizioneAziendaSistemaEroganteNull(), Nothing, row.DescrizioneAziendaSistemaErogante)},
                            .Sistema = New Wcf.BaseTypes.CodiceDescrizioneType() With {
                                .Codice = row.CodiceSistemaErogante,
                                .Descrizione = If(row.IsDescrizioneSistemaEroganteNull(), Nothing, row.DescrizioneSistemaErogante)}}
            End If

        End If

        Return result

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToPrestazioneListaType(row As PrestazioniDS.PrestazioniRow) As Wcf.WsTypes.PrestazioneListaType

        Dim result As Wcf.WsTypes.PrestazioneListaType = Nothing

        If row IsNot Nothing Then

            'Creo oggetto di ritorno
            result = New Wcf.WsTypes.PrestazioneListaType() With {
                        .Id = row.ID.ToString.ToUpper,
                        .Codice = row.Codice,
                        .Descrizione = If(row.IsDescrizioneNull(), Nothing, row.Descrizione)
                    }

            'Setto il sistema e tipo
            If row.Tipo <> Wcf.WsTypes.TipoPrestazioneErogabileEnum.Prestazione Then
                'Se profilo decodifico tipo e il sistema è vuoto
                result.Tipo = DirectCast([Enum].Parse(GetType(Wcf.WsTypes.TipoPrestazioneErogabileEnum), row.Tipo.ToString()),  _
                    Wcf.WsTypes.TipoPrestazioneErogabileEnum)

                result.SistemaErogante = New Wcf.BaseTypes.SistemaType() With {
                                .Azienda = New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = ""},
                                .Sistema = New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = ""}
                                }

            Else
                'E' una prestazione
                result.Tipo = Wcf.WsTypes.TipoPrestazioneErogabileEnum.Prestazione

                result.SistemaErogante = New Wcf.BaseTypes.SistemaType() With {
                                .Azienda = New Wcf.BaseTypes.CodiceDescrizioneType() With {
                                            .Codice = row.CodiceAzienda,
                                            .Descrizione = If(row.IsDescrizioneAziendaNull(), Nothing, row.DescrizioneAzienda)},
                                .Sistema = New Wcf.BaseTypes.CodiceDescrizioneType() With {
                                            .Codice = row.CodiceSistema,
                                            .Descrizione = If(row.IsDescrizioneSistemaNull(), Nothing, row.DescrizioneSistema)}
                                }
            End If

        End If

        Return result

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToPrestazioneListaType(row As TemplateDS.ProfiliRow) As Wcf.WsTypes.PrestazioneListaType

        Dim result As Wcf.WsTypes.PrestazioneListaType = Nothing

        If row IsNot Nothing Then

            'Creo oggetto di ritorno
            result = New Wcf.WsTypes.PrestazioneListaType() With {
                        .Id = row.ID.ToString.ToUpper,
                        .Codice = row.Codice,
                        .Descrizione = If(row.IsDescrizioneNull(), Nothing, row.Descrizione)
                    }

            'Setto il sistema e tipo
            If row.Tipo <> Wcf.WsTypes.TipoPrestazioneErogabileEnum.Prestazione Then
                'Se profilo decodifico tipo e il sistema è vuoto
                result.Tipo = DirectCast([Enum].Parse(GetType(Wcf.WsTypes.TipoPrestazioneErogabileEnum), row.Tipo.ToString()),  _
                    Wcf.WsTypes.TipoPrestazioneErogabileEnum)

                result.SistemaErogante = New Wcf.BaseTypes.SistemaType() With {
                                .Azienda = New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = ""},
                                .Sistema = New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = ""}
                                }

            Else
                'E' una prestazione
                result.Tipo = Wcf.WsTypes.TipoPrestazioneErogabileEnum.Prestazione

                result.SistemaErogante = New Wcf.BaseTypes.SistemaType() With {
                                .Azienda = New Wcf.BaseTypes.CodiceDescrizioneType() With {
                                            .Codice = row.CodiceAzienda,
                                            .Descrizione = If(row.IsDescrizioneAziendaNull(), Nothing, row.DescrizioneAzienda)},
                                .Sistema = New Wcf.BaseTypes.CodiceDescrizioneType() With {
                                            .Codice = row.CodiceSistema,
                                            .Descrizione = If(row.IsDescrizioneSistemaNull(), Nothing, row.DescrizioneSistema)}
                                }
            End If

        End If

        Return result

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToPrestazioniListaType(rows As List(Of PrestazioniDS.PrestazioneRow)) As Wcf.WsTypes.PrestazioniListaType

        Dim result As Wcf.WsTypes.PrestazioniListaType = Nothing

        If rows IsNot Nothing AndAlso rows.Count > 0 Then
            'Creo oggetto di ritorno
            result = New Wcf.WsTypes.PrestazioniListaType

            'Carico le righe
            For Each row As PrestazioniDS.PrestazioneRow In rows
                result.Add(row.ToPrestazioneListaType)
            Next
        End If

        Return result

    End Function


    ''' <summary>
    ''' Ritorna un oggetto di tipo ToGruppiPrestazioniListaType da una GruppiPrestazioniListaDataTable
    ''' </summary>
    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToGruppiPrestazioniListaType(dt As PrestazioniDS.GruppiPrestazioniListaDataTable) As Wcf.WsTypes.GruppiPrestazioniListaType

        Dim result As Wcf.WsTypes.GruppiPrestazioniListaType = Nothing

        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            'Creo oggetto di ritorno
            result = New Wcf.WsTypes.GruppiPrestazioniListaType

            'Carico le righe
            For Each row As PrestazioniDS.GruppiPrestazioniListaRow In dt
                result.Add(row.ToGruppoPrestazioniListaType)
            Next
        End If

        Return result

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToGruppoPrestazioniListaType(row As PrestazioniDS.GruppiPrestazioniListaRow) As Wcf.WsTypes.GruppoPrestazioniListaType

        Dim result As Wcf.WsTypes.GruppoPrestazioniListaType = Nothing

        If row IsNot Nothing Then
            'Creo oggetto di ritorno
            result = New Wcf.WsTypes.GruppoPrestazioniListaType() With {
                                .Id = row.ID.ToString.ToUpper,
                                .Descrizione = row.Descrizione,
                                .NumeroPrestazioni = row.NumeroPrestazioni,
                                .SistemiEroganti = If(row.IsSistemiNull, Nothing, row.Sistemi)
                                }
        End If

        Return result

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToGruppoPrestazioniType(row As PrestazioniDS.GruppiPrestazioniListaRow) As Wcf.WsTypes.GruppoPrestazioniType

        Dim result As Wcf.WsTypes.GruppoPrestazioniType = Nothing

        If row IsNot Nothing Then
            'Creo oggetto di ritorno
            result = New Wcf.WsTypes.GruppoPrestazioniType() With {
                                .Id = row.ID.ToString.ToUpper,
                                .Descrizione = row.Descrizione
                                }

            '.Prestazioni = Prestazioni
        End If

        Return result

    End Function


    ''' <summary>
    ''' Ritorna un oggetto di tipo ProfiliUtenteListaType da una TemplateDS.ProfiliUtenteDataTable
    ''' </summary>
    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToProfiliUtenteListaType(dt As TemplateDS.ProfiliUtenteDataTable) As Wcf.WsTypes.ProfiliUtenteListaType

        Dim result As Wcf.WsTypes.ProfiliUtenteListaType = Nothing

        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            'Creo oggetto di ritorno
            result = New Wcf.WsTypes.ProfiliUtenteListaType

            'Carico le righe
            For Each row As TemplateDS.ProfiliUtenteRow In dt
                result.Add(row.ToProfiloUtenteListaType)
            Next
        End If

        Return result

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToProfiloUtenteListaType(row As TemplateDS.ProfiliUtenteRow) As Wcf.WsTypes.ProfiloUtenteListaType

        Dim result As Wcf.WsTypes.ProfiloUtenteListaType = Nothing

        If row IsNot Nothing Then
            'Creo oggetto di ritorno

            result = New Wcf.WsTypes.ProfiloUtenteListaType() With {.Id = row.ID.ToString().ToUpper(),
                                                           .Codice = row.Codice,
                                                           .Descrizione = If(row.IsDescrizioneNull(), Nothing, row.Descrizione),
                                                           .NumeroPrestazioni = If(row.IsNumeroPrestazioniNull(), 0, row.NumeroPrestazioni),
                                                           .SistemiEroganti = If(row.IsSistemiErogantiNull(), Nothing, row.SistemiEroganti)
                                                          }
        End If

        Return result

    End Function


    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToProfiloUtenteType(row As TemplateDS.ProfiloUtenteRow, prestazioniProfilo As Wcf.WsTypes.ProfiloUtentePrestazioniType) As Wcf.WsTypes.ProfiloUtenteType

        Dim result As Wcf.WsTypes.ProfiloUtenteType = Nothing

        If row IsNot Nothing Then
            'Creo oggetto di ritorno
            result = New Wcf.WsTypes.ProfiloUtenteType() With {
                                .Id = row.ID.ToString().ToUpper(),
                                .Codice = row.Codice,
                                .Descrizione = If(row.IsDescrizioneNull(), Nothing, row.Descrizione),
                                .Prestazioni = prestazioniProfilo
                                }
        End If

        Return result

    End Function


    ''' <summary>
    ''' Ritorna un oggetto di tipo ProfiliUtenteListaType da una TemplateDS.ProfiliUtenteDataTable
    ''' </summary>
    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToProfiloUtentePrestazioniType(dt As TemplateDS.PrestazioniProfiliDataTable) As Wcf.WsTypes.ProfiloUtentePrestazioniType

        Dim result As Wcf.WsTypes.ProfiloUtentePrestazioniType = Nothing

        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            'Creo oggetto di ritorno
            result = New Wcf.WsTypes.ProfiloUtentePrestazioniType

            'Carico le righe
            For Each row As TemplateDS.PrestazioniProfiliRow In dt
                result.Add(row.ToProfiloUtenteListaType)
            Next
        End If

        Return result

    End Function

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToProfiloUtenteListaType(row As TemplateDS.PrestazioniProfiliRow) As Wcf.WsTypes.ProfiloUtentePrestazioneType

        Dim result As Wcf.WsTypes.ProfiloUtentePrestazioneType = Nothing

        If row IsNot Nothing Then
            'Creo oggetto di ritorno
            result = New Wcf.WsTypes.ProfiloUtentePrestazioneType() With {
                                .Id = row.ID.ToString().ToUpper(),
                                .Codice = row.Codice,
                                .Descrizione = If(row.IsDescrizioneNull(), Nothing, row.Descrizione),
                                .SistemaErogante = New Wcf.BaseTypes.SistemaType() With {
                                .Azienda = New Wcf.BaseTypes.CodiceDescrizioneType() With {
                                        .Codice = row.CodiceAziendaSistemaErogante,
                                        .Descrizione = If(row.IsDescrizioneAziendaSistemaEroganteNull(), Nothing, row.DescrizioneAziendaSistemaErogante)},
                                .Sistema = New Wcf.BaseTypes.CodiceDescrizioneType() With {
                                        .Codice = row.CodiceSistemaErogante,
                                        .Descrizione = If(row.IsDescrizioneSistemaEroganteNull(), Nothing, row.DescrizioneSistemaErogante)}},
                                .Tipo = DirectCast([Enum].Parse(GetType(Wcf.WsTypes.TipoPrestazioneErogabileEnum), row.Tipo.ToString()),  _
                                                                Wcf.WsTypes.TipoPrestazioneErogabileEnum)
                                                                                }

        End If

        Return result

    End Function


    ''' <summary>
    ''' Ritorna il valore del dato accessorio per Codice
    ''' </summary>
    <System.Runtime.CompilerServices.Extension()>
    Friend Function GetValoreByCodice(datiAccessoriValori As Wcf.WsTypes.DatiAccessoriValoriType, codice As String) As String

        ' Cerco il valore per Codice
        Dim datoAccessorio = datiAccessoriValori.FindByCodice(codice)
        If datoAccessorio IsNot Nothing Then
            Return datoAccessorio.ValoreDato
        Else
            Return Nothing
        End If

    End Function

    ''' <summary>
    ''' Ritorna il dato accessorio per Codice
    ''' </summary>
    <System.Runtime.CompilerServices.Extension()>
    Friend Function FindByCodice(datiAccessoriValori As Wcf.WsTypes.DatiAccessoriValoriType, codice As String) As Wcf.WsTypes.DatoAccessorioValoreType

        ' Cerco i datoaccessorio del Codice
        Return datiAccessoriValori.Find(Function(e) e.Codice.ToUpper = codice.ToUpper)

    End Function

End Module
