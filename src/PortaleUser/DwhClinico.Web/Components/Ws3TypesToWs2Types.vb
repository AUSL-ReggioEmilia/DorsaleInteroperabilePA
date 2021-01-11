Module Ws3TypesToWs2Types

#Region "Conversione RefertoType (WS3) a RefertoResult (WS2)"

    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToRefertoResult(ByVal Referto As WcfDwhClinico.RefertoType) As RefertoResult
        Dim oRefertoResult As New RefertoResult
        '
        ' Se il referto è presente
        '
        If Not Referto Is Nothing AndAlso Not String.IsNullOrEmpty(Referto.Id) Then
            Dim oRefertoResult_Referto As New RefertiDataSetReferto
            '
            ' Memorizzo il nodo paziente
            '
            Dim oNodoPaziente As WcfDwhClinico.PazienteGeneralitaType = Referto.Paziente
            '
            ' Valorizzazione della testata
            '
            oRefertoResult_Referto.Id = Referto.Id
            oRefertoResult_Referto.DataInserimento = Referto.DataInserimento
            oRefertoResult_Referto.DataModifica = Referto.DataModifica
            oRefertoResult_Referto.AziendaErogante = Referto.AziendaErogante
            oRefertoResult_Referto.SistemaErogante = Referto.SistemaErogante
            oRefertoResult_Referto.RepartoErogante = If(Referto.RepartoErogante Is Nothing, Nothing, Referto.RepartoErogante.Descrizione)
            oRefertoResult_Referto.DataReferto = Referto.DataReferto
            oRefertoResult_Referto.NumeroReferto = Referto.NumeroReferto
            oRefertoResult_Referto.NumeroNosologico = Referto.NumeroNosologico
            oRefertoResult_Referto.NumeroPrenotazione = Referto.NumeroPrenotazione
            '
            ' Dati del paziente
            '
            oRefertoResult_Referto.IdPaziente = Referto.IdPaziente
            If Not oNodoPaziente Is Nothing Then
                oRefertoResult_Referto.Cognome = oNodoPaziente.Cognome
                oRefertoResult_Referto.Nome = oNodoPaziente.Nome
                oRefertoResult_Referto.Sesso = oNodoPaziente.Sesso
                oRefertoResult_Referto.CodiceFiscale = oNodoPaziente.CodiceFiscale
                '
                ' Posso usare questo statement perchè oRefertoResult_Referto.DataNascita è Date (non nullabile)
                '
                oRefertoResult_Referto.DataNascita = If(Not oNodoPaziente.DataNascita.HasValue, Nothing, oNodoPaziente.DataNascita.Value)
                oRefertoResult_Referto.DataNascitaSpecified = If(Not oNodoPaziente.DataNascita.HasValue, False, True)

                oRefertoResult_Referto.ComuneNascita = oNodoPaziente.ComuneNascita
                oRefertoResult_Referto.ProvinciaNascita = Nothing
                oRefertoResult_Referto.ComuneResidenza = Nothing
                oRefertoResult_Referto.CodiceSAUB = Nothing
                oRefertoResult_Referto.CodiceSanitario = oNodoPaziente.CodiceSanitario
            End If
            oRefertoResult_Referto.RepartoRichiedenteCodice = If(Referto.RepartoRichiedente Is Nothing, Nothing, Referto.RepartoRichiedente.Codice)
            oRefertoResult_Referto.RepartoRichiedenteDescr = If(Referto.RepartoRichiedente Is Nothing, Nothing, Referto.RepartoRichiedente.Descrizione)
            oRefertoResult_Referto.StatoRichiestaCodice = If(Referto.StatoRichiesta Is Nothing, Nothing, Referto.StatoRichiesta.Codice)
            oRefertoResult_Referto.StatoRichiestaDescr = If(Referto.StatoRichiesta Is Nothing, Nothing, Referto.StatoRichiesta.Descrizione)
            oRefertoResult_Referto.TipoRichiestaCodice = If(Referto.TipoRichiesta Is Nothing, Nothing, Referto.TipoRichiesta.Codice)
            oRefertoResult_Referto.TipoRichiestaDescr = If(Referto.TipoRichiesta Is Nothing, Nothing, Referto.TipoRichiesta.Descrizione)
            oRefertoResult_Referto.PrioritaCodice = If(Referto.Priorita Is Nothing, Nothing, Referto.Priorita.Codice)
            oRefertoResult_Referto.PrioritaDescr = If(Referto.Priorita Is Nothing, Nothing, Referto.Priorita.Descrizione)
            oRefertoResult_Referto.Referto = Referto.TestoReferto
            oRefertoResult_Referto.MedicoRefertanteCodice = If(Referto.MedicoRefertante Is Nothing, Nothing, Referto.MedicoRefertante.Codice)
            oRefertoResult_Referto.MedicoRefertanteDescr = If(Referto.MedicoRefertante Is Nothing, Nothing, Referto.MedicoRefertante.Descrizione)
            oRefertoResult_Referto.DataEvento = Referto.DataEvento
            oRefertoResult_Referto.Firmato = Referto.Firmato
            'Questi non vengono utilizzati: rimangono nothing
            oRefertoResult_Referto.RuoliVisualizzazione = Nothing
            oRefertoResult_Referto.RuoloVisualizzazioneRepartoRichiedente = Nothing
            oRefertoResult_Referto.RuoloVisualizzazioneSistemaErogante = Nothing
            '
            ' Associo la testata
            '
            oRefertoResult.Referto = oRefertoResult_Referto
            '
            ' Copio gli attributi del referto
            '
            If Not Referto.Attributi Is Nothing AndAlso Referto.Attributi.Count > 0 Then
                oRefertoResult.Referto.RefertoAttributi = Referto.Attributi.ToRefertoResult_RefertoAttributi(Referto.Id)
            End If
            '
            ' Copio le prestazioni
            '
            If Not Referto.Prestazioni Is Nothing AndAlso Referto.Prestazioni.Count > 0 Then
                oRefertoResult.Referto.Prestazioni = Referto.Prestazioni.ToRefertoResult_Prestazioni(Referto.Id)
            End If
            '
            ' Copio gli allegati
            '
            If Not Referto.Allegati Is Nothing AndAlso Referto.Allegati.Count > 0 Then
                oRefertoResult.Referto.Allegati = Referto.Allegati.ToRefertoResult_Allegati(Referto.Id)
            End If

        End If
        '
        ' Restituisco
        '
        Return oRefertoResult
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Private Function ToRefertoResult_Prestazioni(ByVal Prestazioni As WcfDwhClinico.PrestazioniType, ByVal IdReferto As String) As RefertiDataSetRefertoPrestazioni()
        If Not Prestazioni Is Nothing AndAlso Prestazioni.Count > 0 Then
            Dim oListPrestazioni As New List(Of RefertiDataSetRefertoPrestazioni)
            For Each oPrestazione As WcfDwhClinico.PrestazioneType In Prestazioni
                Dim oRefertoResult_RefertoPrestazione As New RefertiDataSetRefertoPrestazioni
                oRefertoResult_RefertoPrestazione.Id = oPrestazione.Id
                oRefertoResult_RefertoPrestazione.IdRefertiBase = IdReferto
                '
                ' Posso usare questo statement perchè oRefertoResult_RefertoPrestazione.DataErogazione è Date (non nullabile)
                '
                oRefertoResult_RefertoPrestazione.DataErogazione = If(Not oPrestazione.DataErogazione.HasValue, Nothing, oPrestazione.DataErogazione.Value)
                oRefertoResult_RefertoPrestazione.DataErogazioneSpecified = If(Not oPrestazione.DataErogazione.HasValue, False, True)

                oRefertoResult_RefertoPrestazione.SezionePosizione = If(Not oPrestazione.SezionePosizione.HasValue, Nothing, oPrestazione.SezionePosizione.Value)
                oRefertoResult_RefertoPrestazione.SezionePosizioneSpecified = If(Not oPrestazione.SezionePosizione.HasValue, False, True)

                oRefertoResult_RefertoPrestazione.SezioneCodice = If(oPrestazione.Sezione Is Nothing, Nothing, oPrestazione.Sezione.Codice)
                oRefertoResult_RefertoPrestazione.SezioneDescrizione = If(oPrestazione.Sezione Is Nothing, Nothing, oPrestazione.Sezione.Descrizione)

                oRefertoResult_RefertoPrestazione.PrestazionePosizione = If(Not oPrestazione.PrestazionePosizione.HasValue, Nothing, oPrestazione.PrestazionePosizione.Value)
                oRefertoResult_RefertoPrestazione.PrestazionePosizioneSpecified = If(Not oPrestazione.PrestazionePosizione.HasValue, False, True)

                oRefertoResult_RefertoPrestazione.PrestazioneCodice = If(oPrestazione.Prestazione Is Nothing, Nothing, oPrestazione.Prestazione.Codice)
                oRefertoResult_RefertoPrestazione.PrestazioneDescrizione = If(oPrestazione.Prestazione Is Nothing, Nothing, oPrestazione.Prestazione.Descrizione)

                oRefertoResult_RefertoPrestazione.RunningNumber = Nothing
                oRefertoResult_RefertoPrestazione.RunningNumberSpecified = False

                oRefertoResult_RefertoPrestazione.GravitaCodice = If(oPrestazione.Gravita Is Nothing, Nothing, oPrestazione.Gravita.Codice)
                oRefertoResult_RefertoPrestazione.GravitaDescrizione = If(oPrestazione.Gravita Is Nothing, Nothing, oPrestazione.Gravita.Descrizione)
                oRefertoResult_RefertoPrestazione.Risultato = oPrestazione.Risultato
                oRefertoResult_RefertoPrestazione.ValoriRiferimento = oPrestazione.ValoriRiferimento
                oRefertoResult_RefertoPrestazione.Commenti = oPrestazione.Commenti
                '
                ' Aggiungo gli attributi della prestazione
                '
                If Not oPrestazione.Attributi Is Nothing AndAlso oPrestazione.Attributi.Count > 0 Then
                    oRefertoResult_RefertoPrestazione.PrestazioniAttributi = oPrestazione.Attributi.ToRefertoResult_PrestazioniAttributi(oPrestazione.Id)
                End If
                '
                ' Aggiungo le prestazioni
                '
                oListPrestazioni.Add(oRefertoResult_RefertoPrestazione)
            Next
            '
            ' Restituisco
            '
            Return oListPrestazioni.ToArray
        Else
            Return Nothing
        End If
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Private Function ToRefertoResult_Allegati(ByVal Allegati As WcfDwhClinico.AllegatiType, ByVal IdReferto As String) As RefertiDataSetRefertoAllegati()
        If Not Allegati Is Nothing AndAlso Allegati.Count > 0 Then
            Dim oListAllegati As New List(Of RefertiDataSetRefertoAllegati)
            For Each oAllegato As WcfDwhClinico.AllegatoType In Allegati
                Dim oRefertoResult_RefertoAllegato As New RefertiDataSetRefertoAllegati
                oRefertoResult_RefertoAllegato.Id = oAllegato.Id
                oRefertoResult_RefertoAllegato.IdRefertiBase = IdReferto
                '
                ' Posso usare questo statement perchè oRefertoResult_RefertoAllegato.DataFile  è Date (non nullabile)
                '
                oRefertoResult_RefertoAllegato.DataFile = If(Not oAllegato.DataFile.HasValue, Nothing, oAllegato.DataFile.Value)
                oRefertoResult_RefertoAllegato.DataFileSpecified = If(Not oAllegato.DataFile.HasValue, False, True)

                oRefertoResult_RefertoAllegato.MimeType = oAllegato.TipoContenuto
                oRefertoResult_RefertoAllegato.MimeData = If(oAllegato.Contenuto Is Nothing, Nothing, oAllegato.Contenuto)
                oRefertoResult_RefertoAllegato.NomeFile = oAllegato.NomeFile
                oRefertoResult_RefertoAllegato.Descrizione = oAllegato.Descrizione

                oRefertoResult_RefertoAllegato.Posizione = If(Not oAllegato.Posizione.HasValue, Nothing, oAllegato.Posizione.Value)
                oRefertoResult_RefertoAllegato.PosizioneSpecified = If(Not oAllegato.Posizione.HasValue, False, True)

                oRefertoResult_RefertoAllegato.StatoCodice = Nothing
                oRefertoResult_RefertoAllegato.StatoDescrizione = Nothing
                '
                ' Aggiungo gli attributi dell'allegato
                '
                If Not oAllegato.Attributi Is Nothing AndAlso oAllegato.Attributi.Count > 0 Then
                    oRefertoResult_RefertoAllegato.AllegatiAttributi = oAllegato.Attributi.ToRefertoResult_AllegatiAttributi(oAllegato.Id)
                End If
                '
                ' Aggiungo le prestazioni
                '
                oListAllegati.Add(oRefertoResult_RefertoAllegato)
            Next
            '
            ' Restituisco
            '
            Return oListAllegati.ToArray
        Else
            Return Nothing
        End If
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Private Function ToRefertoResult_RefertoAttributi(ByVal Attributi As WcfDwhClinico.AttributiType, ByVal IdReferto As String) As RefertiDataSetRefertoRefertoAttributi()
        If Not Attributi Is Nothing AndAlso Attributi.Count > 0 Then
            Dim oListAttributi As New List(Of RefertiDataSetRefertoRefertoAttributi)
            For Each oAttributo As WcfDwhClinico.AttributoType In Attributi
                Dim oRefertoResult_RefertoAttributo As New RefertiDataSetRefertoRefertoAttributi
                oRefertoResult_RefertoAttributo.IdRefertiBase = IdReferto
                oRefertoResult_RefertoAttributo.Nome = oAttributo.Nome
                oRefertoResult_RefertoAttributo.Valore = oAttributo.Valore
                oListAttributi.Add(oRefertoResult_RefertoAttributo)
            Next
            Return oListAttributi.ToArray
        Else
            Return Nothing
        End If
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Private Function ToRefertoResult_PrestazioniAttributi(ByVal Attributi As WcfDwhClinico.AttributiType, ByVal IdPrestazione As String) As RefertiDataSetRefertoPrestazioniPrestazioniAttributi()
        If Not Attributi Is Nothing AndAlso Attributi.Count > 0 Then
            Dim oListAttributi As New List(Of RefertiDataSetRefertoPrestazioniPrestazioniAttributi)
#If DEBUG Then
            Debug.WriteLine(String.Format("IdPrestazione={0}", IdPrestazione))
            Dim i As Integer = 1
#End If
            For Each oAttributo As WcfDwhClinico.AttributoType In Attributi
                Dim oRefertoResult_PrestazioneAttributo As New RefertiDataSetRefertoPrestazioniPrestazioniAttributi
                oRefertoResult_PrestazioneAttributo.IdPrestazioniBase = IdPrestazione
                oRefertoResult_PrestazioneAttributo.Nome = oAttributo.Nome
                oRefertoResult_PrestazioneAttributo.Valore = oAttributo.Valore
#If DEBUG Then
                Debug.WriteLine(vbTab & String.Format("Attributo {0}) - Nome={1}, Valore={2}", i, oRefertoResult_PrestazioneAttributo.Nome, oRefertoResult_PrestazioneAttributo.Valore))
                i = i + 1
#End If
                oListAttributi.Add(oRefertoResult_PrestazioneAttributo)
            Next
            Return oListAttributi.ToArray
        Else
            Return Nothing
        End If
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Private Function ToRefertoResult_AllegatiAttributi(ByVal Attributi As WcfDwhClinico.AttributiType, ByVal IdAllegato As String) As RefertiDataSetRefertoAllegatiAllegatiAttributi()
        If Not Attributi Is Nothing AndAlso Attributi.Count > 0 Then
            Dim oListAttributi As New List(Of RefertiDataSetRefertoAllegatiAllegatiAttributi)

            For Each oAttributo As WcfDwhClinico.AttributoType In Attributi
                Dim oRefertoResult_AllegatoAttributo As New RefertiDataSetRefertoAllegatiAllegatiAttributi
                oRefertoResult_AllegatoAttributo.IdAllegatiBase = IdAllegato
                oRefertoResult_AllegatoAttributo.Nome = oAttributo.Nome
                oRefertoResult_AllegatoAttributo.Valore = oAttributo.Valore
                oListAttributi.Add(oRefertoResult_AllegatoAttributo)
            Next
            Return oListAttributi.ToArray
        Else
            Return Nothing
        End If
    End Function

#End Region

#Region "Conversione PazienteType (WS3) to PazienteResult (WS2)"

    '<System.Runtime.CompilerServices.Extension()>
    'Friend Function ToPazienteResult(ByVal Paziente As WcfDwhClinico.PazienteType) As PazienteResult
    '    Dim oPazienteResult As New PazienteResult
    '    If Not Paziente Is Nothing Then
    '        Dim oPazienteResult_Paziente As New PazientiDataSetPaziente

    '        oPazienteResult_Paziente.AziendaErogante = Paziente.CodiceAnagraficaErogante
    '        oPazienteResult_Paziente.AziendaErogante = Paziente.NomeAnagraficaErogante
    '        oPazienteResult_Paziente.SistemaErogante = "???"
    '        oPazienteResult_Paziente.RepartoErogante = String.Empty
    '        oPazienteResult_Paziente.Cognome = Paziente.Cognome
    '        oPazienteResult_Paziente.Nome = Paziente.Nome
    '        oPazienteResult_Paziente.CodiceFiscale = Paziente.CodiceFiscale
    '        oPazienteResult_Paziente.CodiceSanitario = Paziente.CodiceSanitario
    '        oPazienteResult_Paziente.Sesso = Paziente.Sesso
    '        '
    '        '
    '        '
    '        If Paziente.DataNascita.HasValue Then
    '            oPazienteResult_Paziente.DataNascita = Paziente.DataNascita
    '            oPazienteResult_Paziente.DataNascitaSpecified = True
    '        End If
    '        '
    '        '
    '        '
    '        If Not Paziente.ComuneNascita Is Nothing Then
    '            oPazienteResult_Paziente.LuogoNascita = Paziente.ComuneNascita.Descrizione
    '        End If
    '        '
    '        '
    '        '
    '        If Paziente.DataDecesso.HasValue Then
    '            oPazienteResult_Paziente.DataDecesso = Paziente.DataDecesso
    '            oPazienteResult_Paziente.DataDecessoSpecified = True
    '        End If
    '    End If
    '    '
    '    ' Restituisco
    '    '
    '    Return oPazienteResult
    'End Function


    <System.Runtime.CompilerServices.Extension()>
    Friend Function ToPazienteResult(ByVal Paziente As WcfDwhClinico.PazienteGeneralitaType) As PazienteResult
        Dim oPazienteResult As New PazienteResult
        If Not Paziente Is Nothing Then
            Dim oPazienteResult_Paziente As New PazientiDataSetPaziente

            oPazienteResult_Paziente.AziendaErogante = String.Empty
            oPazienteResult_Paziente.AziendaErogante = String.Empty
            oPazienteResult_Paziente.SistemaErogante = String.Empty
            oPazienteResult_Paziente.RepartoErogante = String.Empty
            oPazienteResult_Paziente.Cognome = Paziente.Cognome
            oPazienteResult_Paziente.Nome = Paziente.Nome
            oPazienteResult_Paziente.CodiceFiscale = Paziente.CodiceFiscale
            oPazienteResult_Paziente.CodiceSanitario = Paziente.CodiceSanitario
            oPazienteResult_Paziente.Sesso = Paziente.Sesso
            '
            '
            '
            If Paziente.DataNascita.HasValue Then
                oPazienteResult_Paziente.DataNascita = Paziente.DataNascita
                oPazienteResult_Paziente.DataNascitaSpecified = True
            End If
            '
            '
            '
            oPazienteResult_Paziente.LuogoNascita = String.Empty
            oPazienteResult_Paziente.DataDecesso = Nothing
            oPazienteResult_Paziente.DataDecessoSpecified = False

            '
            ' Associo i dati del paziente
            '
            oPazienteResult.Paziente = oPazienteResult_Paziente
        End If
        '
        ' Restituisco
        '
        Return oPazienteResult
    End Function



#End Region

End Module