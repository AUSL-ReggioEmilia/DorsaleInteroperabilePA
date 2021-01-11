Public Class UserInterface

#Region "Referti"
    ''' <summary>
    ''' Restituisce l'icona di stato dell'invio di un referto a SOLE.
    ''' </summary>
    ''' <param name="oRow"></param>
    ''' <returns></returns>
    Public Overloads Shared Function GetIconaStatoInvioSOLE(oRow As WcfDwhClinico.RefertoListaType) As String
        Dim sReturn As String = String.Empty

        '
        'Testo se la row è nothing.
        '
        If Not oRow Is Nothing Then
            '
            'Se l'esito di invio è valorizzato allora creo l'icona da restituire.
            '
            If Not String.IsNullOrEmpty(oRow.SoleEsitoInvio) Then
                '
                'Ottengo la data di invio del referto.
                '
                Dim sDataInvio As String = String.Empty
                Dim dDataInvio As Date
                If Date.TryParse(oRow.SoleDataInvio, dDataInvio) Then
                    '
                    'Se la data restituita non è vuota allora formatto la data.
                    '
                    sDataInvio = dDataInvio.ToString("dd/MM/yyyy HH:mm")
                End If

                'If oRow.SoleDataInvio.HasValue Then
                '    '
                '    'Se la data restituita non è vuota allora formatto la data.
                '    '
                '    sDataInvio = oRow.SoleDataInvio.Value.ToString("dd/MM/yyyy HH:mm")
                'End If

                sReturn = CreaIconaStatoInvioSole(oRow.SoleEsitoInvio, sDataInvio)
            End If
        End If
        Return sReturn
    End Function

    ''' <summary>
    ''' Restituisce testo + icona di stato dell'invio di un referto a SOLE.
    ''' </summary>
    ''' <param name="oRow"></param>
    ''' <returns></returns>
    Public Overloads Shared Function GetIconaStatoInvioSOLE(oRow As WcfDwhClinico.RefertoType) As String
        Dim sReturn As String = String.Empty

        '
        'Testo se la row è nothing.
        '
        If Not oRow Is Nothing Then
            '
            'Se l'esito di invio è valorizzato allora creo l'icona da restituire.
            '
            If oRow.Attributi IsNot Nothing Then
                Dim sSoleEsitoInvio As String = String.Empty
                Dim sDataEsitoSole As String = String.Empty

                '
                'Ottengo l'attributo Sole-EsitoInvio
                '
                Dim oListEsito = (From i In oRow.Attributi Where i.Nome = "Sole-EsitoInvio" Select i.Valore).ToList

                '
                'Solo se la lista non è vuota.
                '
                If Not oListEsito.Count = 0 Then
                    '
                    'Prendo il primo elemento della lista.
                    '
                    sSoleEsitoInvio = oListEsito.First

                    '
                    'Ottengo l'attributo Sole-DataInvio
                    '
                    Dim oListData = (From i In oRow.Attributi Where i.Nome = "Sole-DataInvio" Select i.Valore).ToList

                    '
                    'Se la lista non è vuota prendo il primo elemento.
                    '
                    If Not oListData.Count = 0 Then
                        sDataEsitoSole = oListData.First
                    End If

                    '
                    'Se la data restituita dalla query linq non è vuota allora formatto la data.
                    '
                    If Not String.IsNullOrEmpty(sDataEsitoSole) Then
                        Dim dDataInvio As Date
                        If Date.TryParse(sDataEsitoSole, dDataInvio) Then
                            '
                            'Se la data restituita non è vuota allora formatto la data.
                            '
                            sDataEsitoSole = dDataInvio.ToString("dd/MM/yyyy HH:mm")
                            'sDataEsitoSole = String.Concat(dDataInvio.Day.ToString.PadLeft(2, "0"), "/", dDataInvio.Month.ToString.PadLeft(2, "0"), "/", dDataInvio.Year.ToString, " ", dDataInvio.Hour.ToString.PadLeft(2, "0"), ":", dDataInvio.Minute.ToString.PadLeft(2, "0"))
                        End If
                    End If

                    '
                    ' Leggo la descrizione dell'esito
                    '
                    Dim sDescrizione As String = GetDescrizioneEsitoInvioSole(sSoleEsitoInvio, sDataEsitoSole)
                    '
                    'Creo l'icona + tooltip.
                    '
                    Dim sHtmlIcona As String = CreaIconaStatoInvioSole(sSoleEsitoInvio, sDataEsitoSole)

                    sReturn = String.Format("<div class=""col-sm-2"">{0}</div> <div class=""col-sm-10""><strong>{1}</strong></div>", sHtmlIcona, sDescrizione)
                End If
            End If
        End If

        Return sReturn
    End Function

    ''' <summary>
    ''' Crea l'icona di stato d'invio a SOLE.
    ''' </summary>
    ''' <param name="sSoleEsitoInvio"></param>
    ''' <param name="sDataEsitoSole"></param>
    ''' <returns></returns>
    Private Shared Function CreaIconaStatoInvioSole(ByVal sSoleEsitoInvio As String, ByVal sDataEsitoSole As String) As String
        '
        'Definisco la stringa da restituire
        '
        Dim sReturn As String = String.Empty
        '
        'Restituisco l'icona solo se l'esito è valorizzato e se è AA o AE o AR.
        '
        If Not String.IsNullOrEmpty(sSoleEsitoInvio) Then
            '
            'Definisco l'icona da restituire.
            'Cambio la classe css e il title in base al tipo di esito(AA,AR,AE)
            '
            Const HTML_ICONA As String = "<span class='glyphicons glyphicons-sun glyphicons-sun-soleEsito{0}' title='{1}'></span>"
            '
            'AA= Inviato, AE= In Errore, AR = Rigettato.
            '
            Dim sTooltip As String = GetDescrizioneEsitoInvioSole(sSoleEsitoInvio, sDataEsitoSole)
            sReturn = String.Format(HTML_ICONA, sSoleEsitoInvio.ToUpper, sTooltip)
        End If
        '
        ' Restituisco
        '
        Return sReturn
    End Function

    Private Shared Function GetDescrizioneEsitoInvioSole(ByVal sSoleEsitoInvio As String, ByVal sDataEsitoSole As String) As String
        'sDataEsitoSole già coinvertita in formato italiano
        Dim sDescrizione As String = String.Empty
        '
        'AA= Inviato, AE= In Errore, AR = Rigettato.
        '
        If sSoleEsitoInvio.ToUpper = "AA" Then
            If String.IsNullOrEmpty(sDataEsitoSole) Then
                sDescrizione = "Referto inviato."
            Else
                sDescrizione = String.Format("Referto inviato a SOLE il {0}", sDataEsitoSole)
            End If
        ElseIf sSoleEsitoInvio.ToUpper = "AE" Then
            If String.IsNullOrEmpty(sDataEsitoSole) Then
                sDescrizione = "SOLE: Invio errato."
            Else
                sDescrizione = String.Format("Invio errato a SOLE il {0}", sDataEsitoSole)
            End If
        ElseIf sSoleEsitoInvio.ToUpper = "AR" Then
            If String.IsNullOrEmpty(sDataEsitoSole) Then
                sDescrizione = "SOLE: Referto rigettato."
            Else
                sDescrizione = String.Format("Referto rigettato da SOLE il {0}", sDataEsitoSole)
            End If
        End If
        '
        ' Restituisco
        '
        Return sDescrizione
    End Function


    ''' <summary>
    ''' Restituisce la descrizione di un referto (TipoRefertoDescrizione + RepartoErogante + SpecialitàErogante)
    ''' </summary>
    ''' <param name="oRow"></param>
    ''' <param name="page"></param>
    ''' <returns></returns>
    Public Shared Function GetStringaDescrittiva(oRow As WcfDwhClinico.RefertoListaType, page As Page) As String
        Dim sStringaDescrittiva As String = String.Empty
        Dim sTipoReferto As String = String.Empty
        Dim sRepartoErogante As String = String.Empty
        Dim sSpecialitaErogante As String = String.Empty
        Dim sResult As String = String.Empty

        '
        ' Costruisco ogni pezzo della stringa finale in modo da evitare che vengano inseriti dei </br> se la stringa è vuota
        '
        If Not String.IsNullOrEmpty(oRow.TipoRefertoDescrizione) Then
            sTipoReferto = String.Format("{0}</br>", oRow.TipoRefertoDescrizione)
        End If
        If Not String.IsNullOrEmpty(oRow.RepartoErogante) Then
            sRepartoErogante = String.Format("{0}</br>", oRow.RepartoErogante)
        End If
        If Not String.IsNullOrEmpty(oRow.SpecialitaErogante) Then
            sSpecialitaErogante = String.Format("{0}</br>", StrConv(oRow.SpecialitaErogante, vbProperCase))
        End If
        sResult = String.Concat(sTipoReferto, sRepartoErogante, sSpecialitaErogante)
        If Not String.IsNullOrEmpty(sResult) Then
            Dim iLenght As Integer = sResult.Length
            If iLenght > 5 Then
                sResult = Left(sResult, iLenght - 5)
            End If
        End If
        Return sResult
    End Function
#End Region

#Region "NoteAnamnestiche"

    ''' <summary>
    ''' Restituisce l'icona di Stato della nota anamnestica (In base a NotaAnamnesticaListaType)
    ''' </summary>
    ''' <param name="oRow"></param>
    ''' <returns></returns>
    Public Overloads Shared Function GetIconaStatoNotaAnamnestica(oRow As WcfDwhClinico.NotaAnamnesticaListaType) As String
        Dim sReturn As String = String.Empty

        '
        'Controllo se oRow è nothing.
        '
        If Not oRow Is Nothing Then
            sReturn = CreaIconaStatoNotaAnamnestica(oRow.StatoCodice)
        End If

        Return sReturn
    End Function

    ''' <summary>
    ''' Restituisce l'icona di Stato della nota anamnestica (In base a NotaAnamnesticaType)
    ''' </summary>
    ''' <param name="oRow"></param>
    ''' <returns></returns>
    Public Overloads Shared Function GetIconaStatoNotaAnamnestica(oRow As WcfDwhClinico.NotaAnamnesticaType) As String
        Dim sReturn As String = String.Empty
        '
        'Controllo se oRow è nothing.
        '
        If Not oRow Is Nothing Then
            '
            'Controllo se oRow.Stato è nothing.
            '
            If Not oRow.Stato Is Nothing Then
                Dim sStatoCodice As String = oRow.Stato.Codice
                If Not String.IsNullOrEmpty(sStatoCodice) Then
                    sReturn = CreaIconaStatoNotaAnamnestica(sStatoCodice)
                End If
            End If
        End If
        Return sReturn
    End Function

    ''' <summary>
    ''' Crea l'icona di stato della nota anamnestica
    ''' </summary>
    ''' <param name="sStato"></param>
    ''' <returns></returns>
    Private Shared Function CreaIconaStatoNotaAnamnestica(ByVal sStato As String) As String
        Dim sReturn As String = String.Empty

        If Not String.IsNullOrEmpty(sStato) Then


            '
            'Dichiaro lo span per l'icona.
            '
            Dim sIcona As String = "<span class='{0}' title='{1}'></span>"

            '
            'Se lo stato non è nothing o string.empty vado avanti.
            '
            If Not String.IsNullOrEmpty(sStato) Then
                '
                'Valorizzo la classe css dell'icona in base allo stato (0=InCorso,1=completato)
                '
                If sStato = 1 Then
                    '
                    '1 = Completato
                    '
                    sReturn = String.Format(sIcona, "glyphicons glyphicons-check iconaNotaAnamnestica-completata", "Completata")
                ElseIf sStato = 0 Then
                    '
                    '0 = InCorso 
                    '
                    sReturn = String.Format(sIcona, "glyphicons glyphicons-stopwatch iconaNotaAnamnestica-inCorso", "In Corso")
                End If
            End If
        End If

        Return sReturn
    End Function

#End Region

#Region "Episodi"
    ''' <summary>
    ''' Restituisce l'icona del tipo di episodio nel markup delle pagine di ricerca del paziente 
    ''' </summary>
    ''' <param name="oRow"></param>
    ''' <returns></returns>
    ''' 
    Public Shared Function GetImgTipoEpisodioRicovero(oRow As WcfDwhClinico.PazienteListaType) As String
        '
        ' Mostro l'icona del tipo di episodio se e solo se l'episodio è aperto.
        ' Per stabilire se l'episodio è aperto uso oRow.EpisodioStatoDescrizione
        ' MODIFICA ETTORE 2017-04-04: la visualizzazione dei dati dipende dal consenso, dalla data del consenso
        ' e dalle date dell'ultimo referto e della data di accettazione dell'ultimo ricovero
        '
        Dim sRetHtml As String = String.Empty
        Dim bIconaVisibile As Boolean = False
        Dim iConsenso As ConsensoMinimoAccordato = ConsensoMinimoAccordato.Nessuno
        Try
            If Not oRow Is Nothing AndAlso Not oRow.EpisodioTipoCodice Is Nothing Then
                If (Not String.IsNullOrEmpty(oRow.EpisodioStatoDescrizione)) AndAlso HelperRicoveri.IsEpisodioAperto(oRow.EpisodioStatoDescrizione) Then
                    Dim sTipoEpisodioRicovero As String = oRow.EpisodioTipoCodice.ToUpper
                    If Not String.IsNullOrEmpty(sTipoEpisodioRicovero) Then
                        If Not String.IsNullOrEmpty(oRow.ConsensoAziendaleCodice) Then
                            iConsenso = CType(oRow.ConsensoAziendaleCodice, ConsensoMinimoAccordato)
                        End If

                        Dim dDataConsenso As Nullable(Of Date) = oRow.ConsensoAziendaleData
                        Dim dDataAccettazione As Nullable(Of Date) = oRow.EpisodioDataApertura
                        '
                        ' In base al consenso determino se l'icona è visibile
                        '
                        bIconaVisibile = GetVisibilitaOggettoByDataConsenso(iConsenso, dDataConsenso, dDataAccettazione)
                        '
                        ' Se l'icona è visibile
                        '
                        If bIconaVisibile Then
                            sRetHtml = HelperRicoveri.GetHtmlImgTipoEpisodioRicovero(sTipoEpisodioRicovero)
                        End If
                    End If
                End If
            End If
        Catch
        End Try
        '
        ' Restituisco
        '
        Return sRetHtml
    End Function

    Public Shared Function GetRicovero(oRow As WcfDwhClinico.PazienteListaType) As String
        '
        ' Utilizzata per popolare la colonna "Episodio Attuale" nelle pagine di lista pazienti
        ' MODIFICA ETTORE 2017-04-04: la visualizzazione dei dati dipende dal consenso, dalla data del consenso
        ' e dalle date dell'ultimo referto e della data di accettazione dell'ultimo ricovero
        '
        Dim iConsenso As ConsensoMinimoAccordato = ConsensoMinimoAccordato.Nessuno
        Dim sResult As String = String.Empty
        Dim sDataEpisodio As String = String.Empty
        Dim bDatiVisibili As Boolean = False
        Try
            If Not oRow Is Nothing Then
                If Not String.IsNullOrEmpty(oRow.ConsensoAziendaleCodice) Then
                    iConsenso = CType(oRow.ConsensoAziendaleCodice, ConsensoMinimoAccordato)
                End If
                Dim dDataConsenso As Nullable(Of Date) = oRow.ConsensoAziendaleData
                Dim dDataAccettazione As Nullable(Of Date) = oRow.EpisodioDataApertura
                '
                ' In base al consenso determino se il dato è visibile
                '
                bDatiVisibili = GetVisibilitaOggettoByDataConsenso(iConsenso, dDataConsenso, dDataAccettazione)
                '
                '
                '
                If bDatiVisibili Then
                    If oRow.EpisodioDataApertura.HasValue Then
                        sDataEpisodio = String.Format("{0:d}", oRow.EpisodioDataApertura.Value)
                    End If
                    If Not String.IsNullOrEmpty(oRow.EpisodioNumeroNosologico) Then
                        'Allora ho l'episodio (ricovero o prenotazione)
                        If (Not String.IsNullOrEmpty(oRow.EpisodioStatoDescrizione)) AndAlso HelperRicoveri.IsEpisodioAperto(oRow.EpisodioStatoDescrizione) Then
                            If String.Compare(oRow.EpisodioCategoria, "Ricovero", True) = 0 Then
                                'MODIFICA ETTORE 2018-11-06: visualizzazione dell'azienda erogante sottoposta a configurazione
                                If My.Settings.AziendaErogante_Visible Then
                                    sResult = String.Format("Nosologico:&nbsp;{0}-{1} </br> Ricoverato nel reparto {2} dal {3}", oRow.EpisodioAziendaErogante, oRow.EpisodioNumeroNosologico.NullSafeToString(), oRow.EpisodioStrutturaUltimoEventoDescrizione.NullSafeToString(), sDataEpisodio)
                                Else
                                    sResult = String.Format("Nosologico:&nbsp;{0} </br> Ricoverato nel reparto {1} dal {2}", oRow.EpisodioNumeroNosologico.NullSafeToString(), oRow.EpisodioStrutturaUltimoEventoDescrizione.NullSafeToString(), sDataEpisodio)
                                End If

                            ElseIf String.Compare(oRow.EpisodioCategoria, "Prenotazione", True) = 0 Then
                                'MODIFICA ETTORE 2017-10-02: visualizzo nella lo stato della Prenotazione/"Lista di attesa"
                                Dim sStatoCodice As String = oRow.EpisodioStatoCodice
                                Dim sStatoDesc As String = " "
                                If sStatoCodice = "23" Then sStatoDesc = " (Sospesa) "
                                'MODIFICA ETTORE 2018-11-06: visualizzazione dell'azienda erogante sottoposta a configurazione
                                If My.Settings.AziendaErogante_Visible Then
                                    sResult = String.Format("Nosologico:&nbsp;{0}-{1} </br> In lista d'attesa{2}nel reparto {3} dal {4}", oRow.EpisodioAziendaErogante, oRow.EpisodioNumeroNosologico.NullSafeToString(), sStatoDesc, oRow.EpisodioStrutturaAperturaDescrizione.NullSafeToString(), sDataEpisodio)
                                Else
                                    sResult = String.Format("Nosologico:&nbsp;{0} </br> In lista d'attesa{1}nel reparto {2} dal {3}", oRow.EpisodioNumeroNosologico.NullSafeToString(), sStatoDesc, oRow.EpisodioStrutturaAperturaDescrizione.NullSafeToString(), sDataEpisodio)
                                End If

                            End If
                        End If
                    End If
                End If
            End If
        Catch ex As Exception
            sResult = String.Empty
        End Try
        '
        ' Restituisco
        '
        Return sResult
    End Function

    Public Shared Function GetStatoEpisodio(oRow As WcfDwhClinico.EpisodioListaType) As String
        Dim strHtml As String = String.Empty
        Try
            If (Not String.IsNullOrEmpty(oRow.StatoDescrizione)) AndAlso HelperRicoveri.IsEpisodioAperto(oRow.StatoDescrizione) Then

                If String.Compare(oRow.Categoria, "Ricovero", True) = 0 Then
                    If oRow.DataUltimoEvento.HasValue Then
                        strHtml = String.Format("APERTO </br> (In {0} dal {1:g})", oRow.StrutturaUltimoEventoDescrizione.NullSafeToString, oRow.DataUltimoEvento)
                    Else
                        strHtml = String.Format("APERTO </br> (In {0})", oRow.StrutturaUltimoEventoDescrizione.NullSafeToString)
                    End If
                ElseIf String.Compare(oRow.Categoria, "Prenotazione", True) = 0 Then
                    Dim sStatoDesc As String = " "
                    Dim sStatoCodice As String = oRow.StatoCodice
                    If sStatoCodice = "23" Then sStatoDesc = " (Sospesa) "
                    If oRow.DataApertura.HasValue Then
                        strHtml = String.Format("PRENOTATA </br> (In lista d'attesa{0}in {1} dal {2:g})", sStatoDesc, oRow.StrutturaAperturaDescrizione.NullSafeToString, oRow.DataApertura)
                    Else
                        strHtml = String.Format("PRENOTATA </br> (In lista d'attesa{0}in {1})", sStatoDesc, oRow.StrutturaAperturaDescrizione.NullSafeToString)
                    End If
                End If
            Else
                Dim dataConclusione As Date?
                If oRow.DataConclusione.HasValue Then
                    dataConclusione = oRow.DataConclusione.Value
                End If

                If String.Compare(oRow.Categoria, "Ricovero", True) = 0 Then

                    If dataConclusione.HasValue Then
                        strHtml = String.Format("CHIUSO </br> (Dimesso da {0} il {1:g})", oRow.StrutturaConclusioneDescrizione.NullSafeToString, dataConclusione)
                    Else
                        strHtml = String.Format("CHIUSO </br> (Dimesso da {0})", oRow.StrutturaConclusioneDescrizione.NullSafeToString)
                    End If

                ElseIf String.Compare(oRow.Categoria, "Prenotazione", True) = 0 Then

                    If dataConclusione.HasValue Then
                        '
                        ' E' corretto usare dataConclusione?
                        '
                        strHtml = String.Format("CHIUSA PRENOTAZIONE </br> (Lista d'attesa in {0} dal {1:g})", oRow.StrutturaAperturaDescrizione.NullSafeToString, dataConclusione)
                    Else
                        strHtml = String.Format("CHIUSA PRENOTAZIONE</br> (Lista d'attesa in {0})", oRow.StrutturaAperturaDescrizione.NullSafeToString)
                    End If

                End If
            End If
        Catch ex As Exception
            strHtml = String.Empty
        End Try

        Return strHtml
    End Function
#End Region

#Region "Prescrizioni"
    Public Shared Function GetPrescrizioniFarmaciPrestazioni(ByVal oRow As WcfDwhClinico.PrescrizioneListaType) As String
        Dim sHtml As String = String.Empty
        Dim sTipoPrescrizione As String = oRow.TipoPrescrizione
        Dim sElenco As String = String.Empty
        '
        ' In base al tipo della prescrizione
        '
        If String.Compare(sTipoPrescrizione, Utility.TIPO_PRESCRIZIONE_SPECIALISTICA, True) = 0 Then
            sElenco = oRow.Prestazioni
        ElseIf String.Compare(sTipoPrescrizione, Utility.TIPO_PRESCRIZIONE_FARMACEUTICA, True) = 0 Then
            sElenco = oRow.Farmaci
        End If
        '
        ' Se ha degli Esami o Farmaci
        '
        If Not String.IsNullOrEmpty(sElenco) Then
            'Bisogna sapere con certezza quale è il separatore per splittare
            'Dim sArray As String() = Split(sElenco, "; ")
            'sHtml = Join(sArray, "<br/>")
            sHtml = sElenco
        End If
        '
        '
        '
        Return sHtml
    End Function

    Public Shared Function GetPrescrizioneDataPrescrizione(ByVal oRow As WcfDwhClinico.PrescrizioneListaType) As String
        Dim sHtml As String = String.Empty
        If oRow.DataPrescrizione <> Nothing Then
            sHtml = String.Format("{0:d}", oRow.DataPrescrizione)
        End If
        Return sHtml
    End Function

    Public Shared Function GetPrescrizioneMedicoPrescrittoreDesc(ByVal oRow As WcfDwhClinico.PrescrizioneListaType) As String
        Dim sHtml As String = String.Format("{0} {1} </br> ({2})", oRow.MedicoPrescrittoreNome.NullSafeToString, oRow.MedicoPrescrittoreCognome.NullSafeToString, oRow.MedicoPrescrittoreCodiceFiscale.NullSafeToString)
        Return sHtml
    End Function

    Public Shared Function GetPrescrizioneEsenzioneCodici(ByVal oRow As WcfDwhClinico.PrescrizioneListaType) As String
        Dim sHtml As String = oRow.EsenzioneCodici
        Return sHtml
    End Function

    Public Shared Function GetPrescrizioneNumero(ByVal oRow As WcfDwhClinico.PrescrizioneListaType) As String
        Dim sHtml As String = oRow.NumeroPrescrizione
        Return sHtml
    End Function

    Public Shared Function GetPrescrizioniPrioritaCodice(ByVal oRow As WcfDwhClinico.PrescrizioneListaType) As String
        Dim sHtml As String = String.Empty
        If Not String.IsNullOrEmpty(oRow.PrioritaCodice) Then
            sHtml = oRow.PrioritaCodice
        End If
        Return sHtml
    End Function

    Public Shared Function GetPrescrizioniQuesitoDiagnosticoPropostaTerapeutica(ByVal oRow As WcfDwhClinico.PrescrizioneListaType) As String
        Dim sHtml As String = String.Empty
        If Not String.IsNullOrEmpty(oRow.QuesitoDiagnostico) Then
            sHtml = oRow.QuesitoDiagnostico
        End If
        If Not String.IsNullOrEmpty(oRow.PropostaTerapeutica) Then
            '
            ' Se sHtml è valorizzato allora aggiungo un a capo
            '
            If Not String.IsNullOrEmpty(sHtml) Then
                sHtml = String.Concat(sHtml, "<br/>")
            End If
            sHtml = String.Concat(sHtml, oRow.PropostaTerapeutica)
        End If
        Return sHtml
    End Function
#End Region

#Region "Lista Pazienti"
    ''' <summary>
    ''' Da usare nella lista dei pazienti ricoverati dove la visualizzazione del nome e cognome dipende dal consesno associato al paziente
    ''' </summary>
    ''' <param name="oRow"></param>
    ''' <returns></returns>
    Public Shared Function GetColumnPazienteRicoverato(oRow As WcfDwhClinico.PazienteListaType) As String
        Dim sOutput As String = String.Empty
        If Not oRow Is Nothing Then
            Dim iConsenso As ConsensoMinimoAccordato = ConsensoMinimoAccordato.Nessuno
            If Not String.IsNullOrEmpty(oRow.ConsensoAziendaleCodice) Then
                iConsenso = CType(oRow.ConsensoAziendaleCodice, ConsensoMinimoAccordato)
            End If
            Select Case iConsenso
                Case ConsensoMinimoAccordato.Nessuno
                    sOutput = Utility.GetInizialiPaziente(oRow.Cognome.ToUpper, oRow.Nome.ToUpper)

                Case ConsensoMinimoAccordato.Dossier, ConsensoMinimoAccordato.DossierStorico
                    '
                    ' In questo caso visualizzo cognome e nome completi e se presente il sesso
                    '
                    sOutput = GetColumnPaziente(oRow)
                Case Else
                    sOutput = Utility.GetInizialiPaziente(oRow.Cognome.ToUpper, oRow.Nome.ToUpper)
            End Select
        End If
        '
        '
        '
        Return sOutput
    End Function

    Public Shared Function GetInformazioniAnagrafiche(oRow As WcfDwhClinico.PazienteListaType) As String
        Dim sReturn As String = String.Empty
        Dim sDataNascita As String = String.Empty
        Dim sNato As String = "Nata"
        If Not oRow Is Nothing Then
            If String.IsNullOrEmpty(oRow.Sesso) OrElse oRow.Sesso.ToUpper = "M" Then sNato = "Nato"
            If oRow.DataNascita.HasValue Then
                sDataNascita = String.Format("{0:d}", oRow.DataNascita)
            End If
            sReturn = String.Format("{0} il {1} a {2} </br> CF: {3}", sNato, sDataNascita, oRow.ComuneNascitaDescrizione, oRow.CodiceFiscale)
        End If
        Return sReturn
    End Function

    Public Shared Function GetAnteprima(oRow As WcfDwhClinico.PazienteListaType) As String
        '
        ' MODIFICA ETTORE 2017-04-04: la visualizzazione dei dati dipende dal consenso, dalla data del consenso
        ' e dalle date dell'ultimo referto e della data di accettazione dell'ultimo ricovero
        ' Questi dati vengono dal WS3 e quindi bisogna testare il nothing e non il DbNull
        '
        Dim sAnteprima As String = String.Empty
        Dim iConsenso As ConsensoMinimoAccordato = ConsensoMinimoAccordato.Nessuno
        Dim dDataConsenso As Nullable(Of Date) = Nothing
        Dim dDataUltimoReferto As Nullable(Of Date) = Nothing
        Dim dDataAccettazione As Nullable(Of Date) = Nothing
        Dim dDataUltimaNotaAnamnestica As Nullable(Of Date) = Nothing
        Dim sAnteprimaReferti As String = String.Empty
        Dim sAnteprimaRicoveri As String = String.Empty
        Dim sAnteprimaNoteAnamnestiche As String = String.Empty
        Dim bAnteprimaRefertiVisibile As Boolean = False
        Dim bAnteprimaRicoveriVisibile As Boolean = False
        Dim bAnteprimaNoteAnamnesticheVisible As Boolean = False
        Try
            If Not oRow Is Nothing Then
                '
                ' Metto un default al consenso
                '
                If Not String.IsNullOrEmpty(oRow.ConsensoAziendaleCodice) Then
                    iConsenso = CType(oRow.ConsensoAziendaleCodice, ConsensoMinimoAccordato)
                End If
                '
                ' Memorizzo Data del consenso, data ultimo referto e data accettaione ultimo ricovero
                '
                dDataConsenso = oRow.ConsensoAziendaleData
                dDataUltimoReferto = oRow.UltimoRefertoData
                dDataAccettazione = oRow.EpisodioDataApertura
                dDataUltimaNotaAnamnestica = oRow.UltimaNotaAnamnesticaData
                '
                ' In base al consenso determino quali parti dell'anteprima sono visibili
                '
                bAnteprimaRefertiVisibile = GetVisibilitaOggettoByDataConsenso(iConsenso, dDataConsenso, dDataUltimoReferto)
                bAnteprimaRicoveriVisibile = GetVisibilitaOggettoByDataConsenso(iConsenso, dDataConsenso, dDataAccettazione)
                bAnteprimaNoteAnamnesticheVisible = GetVisibilitaOggettoByDataConsenso(iConsenso, dDataConsenso, dDataUltimaNotaAnamnestica)
                '
                ' Se anteprima referti è visibile
                '
                If bAnteprimaRefertiVisibile Then
                    sAnteprimaReferti = UserInterface.BuildAnteprimaReferti(oRow.NumeroReferti, oRow.UltimoRefertoSistemaErogante, dDataUltimoReferto)
                End If
                '
                ' Se anteprima ricoveri è visibile
                '
                If bAnteprimaRicoveriVisibile Then
                    'MODIFICA ETTORE 2018-11-06: visualizzazione dell'azienda erogante sottoposta a configurazione
                    If My.Settings.AziendaErogante_Visible Then
                        sAnteprimaRicoveri = UserInterface.BuildAnteprimaRicoveri(oRow.EpisodioAziendaErogante, oRow.EpisodioDataApertura, oRow.EpisodioDataConclusione, oRow.EpisodioStrutturaUltimoEventoDescrizione, oRow.EpisodioStrutturaConclusioneDescrizione)
                    Else
                        sAnteprimaRicoveri = UserInterface.BuildAnteprimaRicoveri(String.Empty, oRow.EpisodioDataApertura, oRow.EpisodioDataConclusione, oRow.EpisodioStrutturaUltimoEventoDescrizione, oRow.EpisodioStrutturaConclusioneDescrizione)
                    End If
                End If
                '
                ' Se anteprima Note anamnestiche è visibile
                '
                If bAnteprimaNoteAnamnesticheVisible Then
                    sAnteprimaNoteAnamnestiche = BuildAnteprimaNoteAnamnestiche(oRow.NumeroNoteAnamnestiche, oRow.UltimaNotaAnamnesticaData, oRow.UltimaNotaAnamnesticaSistemaErogante)
                End If


            End If
            '
            ' Unisco le due anteprime
            '
            sAnteprima = sAnteprimaReferti
            If Not String.IsNullOrEmpty(sAnteprima) Then sAnteprima = sAnteprima & "</br>"
            sAnteprima = sAnteprima & sAnteprimaRicoveri
            If Not String.IsNullOrEmpty(sAnteprima) Then sAnteprima = sAnteprima & "</br>"
            sAnteprima = sAnteprima & sAnteprimaNoteAnamnestiche
            '
            ' Rimuovo ultimo "</br>"
            '
            sAnteprima = sAnteprima.TrimEnd("</br>".ToCharArray)
        Catch
            '
            ' In caso di errore restituisco stringa vuota
            '
            sAnteprima = String.Empty
        End Try
        '
        ' Restituisco
        '
        Return sAnteprima
    End Function

    Public Shared Function GetVisibilitaOggettoByDataConsenso(ByVal iConsenso As ConsensoMinimoAccordato, ByVal dDataConsenso As Nullable(Of Date), ByVal dDataOggetto As Nullable(Of Date)) As Boolean
        '
        ' dDataOggetto può essere la data dell'ultimo referto se oggetto è l'icona presenza referti
        ' dDataOggetto può essere la data di accettazione dell'ultimo ricovero se oggetto è l'icona presenza ricoveri
        '
        Dim bRet As Boolean = False
        Try
            Select Case iConsenso
                Case ConsensoMinimoAccordato.Nessuno, ConsensoMinimoAccordato.Generico
                    bRet = False
                Case ConsensoMinimoAccordato.Dossier
                    bRet = False
                    If dDataOggetto.HasValue AndAlso dDataConsenso.HasValue AndAlso dDataOggetto.Value >= dDataConsenso.Value Then
                        bRet = True
                    End If
                Case ConsensoMinimoAccordato.DossierStorico
                    bRet = True
            End Select
        Catch
        End Try
        '
        ' Restituisco
        '
        Return bRet
    End Function

    Private Shared Function BuildAnteprimaReferti(ByVal iNumeroreferti As Integer, ByVal sUltimoRefertoSistemaErogante As String, ByVal dDataUltimoReferto As Nullable(Of Date)) As String
        Dim sAnteprima As String = String.Empty
        Dim numeroReferti As Integer = 0
        Try
            If iNumeroreferti <> Nothing Then numeroReferti = iNumeroreferti
            sAnteprima = String.Format("Numero referti: {0}", numeroReferti)
            If Not String.IsNullOrEmpty(sUltimoRefertoSistemaErogante) Then
                sAnteprima = String.Format("{0} </br>Ultimo referto: {1}", sAnteprima, sUltimoRefertoSistemaErogante)
            End If
            If dDataUltimoReferto.HasValue Then
                sAnteprima = String.Format("{0} ({1})", sAnteprima, dDataUltimoReferto.Value)
            End If
        Catch
        End Try
        '
        ' Restituisco
        '
        Return sAnteprima
    End Function

    Private Shared Function BuildAnteprimaRicoveri(ByVal sEpisodioAziendaErogante As String, ByVal dDataApertura As Nullable(Of Date), ByVal dDataConclusione As Nullable(Of Date), ByVal sEpisodioStrutturaUltimoEventoDescrizione As String, ByVal sEpisodioStrutturaConclusioneDescrizione As String) As String
        Dim sAnteprima As String = String.Empty
        Dim strutturaReparto As String = Nothing
        Try
            If dDataApertura.HasValue Then
                sAnteprima = String.Format("{0} Ultimo accesso:{1} ", sAnteprima, dDataApertura.Value)
                If dDataConclusione.HasValue Then
                    sAnteprima = String.Format("{0} - {1}", sAnteprima, dDataConclusione.Value)
                    strutturaReparto = If(String.IsNullOrEmpty(sEpisodioStrutturaConclusioneDescrizione), Nothing, sEpisodioStrutturaConclusioneDescrizione)
                Else
                    strutturaReparto = If(String.IsNullOrEmpty(sEpisodioStrutturaUltimoEventoDescrizione), Nothing, sEpisodioStrutturaUltimoEventoDescrizione)
                End If
                If Not String.IsNullOrEmpty(strutturaReparto) Then
                    sAnteprima = String.Format("{0} </br>{1}", sAnteprima, strutturaReparto)
                End If
                If Not String.IsNullOrEmpty(sEpisodioAziendaErogante) Then
                    sAnteprima = String.Format("{0} ({1})", sAnteprima, sEpisodioAziendaErogante)
                End If
            End If
        Catch
        End Try
        '
        ' Restituisco
        '
        Return sAnteprima
    End Function


    Private Shared Function BuildAnteprimaNoteAnamnestiche(ByVal iNumeroNoteAnamnestiche As Integer, ByVal dUltimaNotaAnamnesticaData As Nullable(Of Date), ByVal sUltimaNotaAnamnesticaSistemaErogante As String) As String
        Dim sAnteprima As String = String.Empty
        Try
            Try
                If My.Settings.ShowNoteAnamnesticheTab Then
                    sAnteprima = String.Format("Numero note anamnestiche: {0}", iNumeroNoteAnamnestiche)
                    If iNumeroNoteAnamnestiche <> Nothing AndAlso iNumeroNoteAnamnestiche > 0 Then
                        If Not String.IsNullOrEmpty(sUltimaNotaAnamnesticaSistemaErogante) Then
                            sAnteprima = String.Concat(sAnteprima, String.Format("</br>Ultima nota anamnestica: {0}", sUltimaNotaAnamnesticaSistemaErogante))
                        End If
                        If dUltimaNotaAnamnesticaData.HasValue Then
                            sAnteprima = String.Concat(sAnteprima, String.Format(" ({0})", dUltimaNotaAnamnesticaData.Value))
                        End If
                    End If
                End If
            Catch
            End Try
            '
            ' Restituisco
            '
            Return sAnteprima
        Catch
        End Try
        '
        ' Restituisco
        '
        Return sAnteprima
    End Function

    Public Shared Function GetDomicilio(oRow As WcfDwhClinico.PazienteListaType) As String
        Dim sResult As String = String.Empty
        If Not oRow Is Nothing Then
            If String.IsNullOrEmpty(oRow.ComuneDomicilioCAP) Then
                sResult = String.Format("{0} {1}", oRow.IndirizzoDomicilio.NullSafeToString, oRow.ComuneDomicilioDescrizione.NullSafeToString)
            Else
                sResult = String.Format("{0} {1} ({2})", oRow.IndirizzoDomicilio.NullSafeToString, oRow.ComuneDomicilioDescrizione.NullSafeToString, oRow.ComuneDomicilioCAP.NullSafeToString)
            End If
        End If
        Return sResult
    End Function

    Public Overloads Shared Function GetImgConsenso(oRow As WcfDwhClinico.PazienteListaType, page As Page) As String
        'Dim sUrl As String = String.Empty
        Dim strHtml As String = String.Empty
        Dim sConsensoCodice As String = "0"
        If Not oRow Is Nothing Then
            If Not String.IsNullOrEmpty(oRow.ConsensoAziendaleCodice) Then
                sConsensoCodice = oRow.ConsensoAziendaleCodice
            End If
            'sUrl = page.ResolveUrl(String.Format("~/Images/Consenso_{0}.gif", sConsensoCodice))
            Select Case sConsensoCodice
                Case "0"
                    strHtml = ""
                Case "1"
                    strHtml = "<span class='glyphicon glyphicon-ok custom-icon-gray-color' title='Consenso Generico'></span>"
                Case "2"
                    strHtml = "<span class='glyphicon glyphicon-ok custom-icon-orange-color' title='Consenso Dossier'></span>"
                Case "3"
                    strHtml = "<span class='glyphicon glyphicon-ok custom-icon-green-color' title='Consenso Dossier Storico'></span>"
                Case Else
                    strHtml = GetHtmlImgBlank(page)
            End Select
        End If
        Return strHtml
    End Function

    Public Shared Function GetColumnPaziente(oRow As WcfDwhClinico.PazienteListaType) As String
        Dim sOutput As String = String.Empty
        If Not oRow Is Nothing Then
            If Not String.IsNullOrEmpty(oRow.Sesso) Then
                sOutput = String.Format("{0}, {1} ({2})", oRow.Cognome.ToUpper, oRow.Nome.ToUpper, oRow.Sesso)
            Else
                sOutput = String.Format("{0}, {1}", oRow.Cognome.ToUpper, oRow.Nome.ToUpper)
            End If
        End If
        Return sOutput
    End Function


    ''' <summary>
    ''' Restituisce l'icona di presenza delle Note Anmanestiche (in base al parametro di tipo PazienteListaType)
    ''' </summary>
    ''' <param name="oRow"></param>
    ''' <param name="Page"></param>
    ''' <returns></returns>
    Public Overloads Shared Function GetImgPresenzaNoteAnamnestiche(ByVal oRow As WcfDwhClinico.PazienteListaType, Page As Page)
        '
        ' COPIATA DALLA FUNZIONE GetImgPresenzaReferti
        ' La visualizzazione dei dati dipende dal consenso, dalla data del consenso
        ' e dalle date dell'ultimo referto e della data di accettazione dell'ultimo ricovero
        '
        Dim sRetHtml As String = String.Empty
        '
        'Eseguo solo se la setting ShowNoteAnamnesticheTab è true.
        '
        If My.Settings.ShowNoteAnamnesticheTab Then
            Try
                Dim iConsenso As ConsensoMinimoAccordato = ConsensoMinimoAccordato.Nessuno
                Dim dDataConsenso As Nullable(Of Date) = Nothing
                Dim dDataUltimaNota As Nullable(Of Date) = Nothing
                Dim bIconaVisibile As Boolean = False

                If Not oRow Is Nothing Then
                    '
                    ' Valorizzo il consenso
                    '
                    If Not String.IsNullOrEmpty(oRow.ConsensoAziendaleCodice) Then
                        iConsenso = CType(oRow.ConsensoAziendaleCodice, ConsensoMinimoAccordato)
                    End If

                    '
                    ' Memorizzo la data del consenso aziendale
                    '
                    dDataConsenso = oRow.ConsensoAziendaleData
                    dDataUltimaNota = oRow.UltimaNotaAnamnesticaData

                    '
                    ' In base al consenso determino se l'icona deve essere visualizzata.
                    '
                    bIconaVisibile = GetVisibilitaOggettoByDataConsenso(iConsenso, dDataConsenso, dDataUltimaNota)

                    '
                    ' Se l'icona è visibile
                    '
                    If bIconaVisibile Then
                        '
                        ' Nell'accesso diretto si va ai referti senza il consenso...quindi nell'AccessoDiretto
                        ' non faccio test sul consenso come invece faccio nella lista pazienti "normale"
                        '
                        If Now.AddDays(-1) <= dDataUltimaNota Then
                            sRetHtml = "<span class='glyphicons glyphicons-notes-2 custom-icon-red-color custom-icon-font-size-15px' title='Paziente con Note Anamnestiche nel giorno corrente'></span>"
                        ElseIf Now.AddDays(-7) <= dDataUltimaNota Then
                            sRetHtml = "<span class='glyphicons glyphicons-notes-2 custom-icon-blue-color custom-icon-font-size-15px' title='Paziente con Note Anamnestiche negli ultimi 7gg'></span>"
                        ElseIf Now.AddDays(-30) <= dDataUltimaNota Then
                            sRetHtml = "<span class='glyphicons glyphicons-notes-2 custom-icon-yellow-color custom-icon-font-size-15px' title='Paziente con Note Anamnestiche negli ultimi 30gg'></span>"
                        End If
                    End If
                End If
            Catch ex As Exception
                '
                'Vado avanti senza trappare nessun errore.
                '
            End Try
        End If

        Return sRetHtml
    End Function

    ''' <summary>
    ''' Restituisce l'icona di presenza delle Note Anmanestiche (in base al parametro di tipo PazienteType)
    ''' </summary>
    ''' <param name="oRow"></param>
    ''' <param name="Page"></param>
    ''' <returns></returns>
    Public Overloads Shared Function GetImgPresenzaNoteAnamnestiche(ByVal oRow As WcfDwhClinico.PazienteType, Page As Page)
        '
        ' COPIATA DALLA FUNZIONE GetImgPresenzaReferti
        ' La visualizzazione dei dati dipende dal consenso, dalla data del consenso
        ' e dalle date dell'ultimo referto e della data di accettazione dell'ultimo ricovero
        '
        Dim sRetHtml As String = String.Empty

        '
        'Eseguo solo se la setting ShowNoteAnamnesticheTab è true.
        '
        If My.Settings.ShowNoteAnamnesticheTab Then
            Try
                Dim dDataConsenso As Nullable(Of Date) = Nothing
                Dim dDataUltimaNota As Nullable(Of Date) = Nothing
                Dim bIconaVisibile As Boolean = False
                If oRow IsNot Nothing AndAlso oRow.UltimaNotaAnamnesticaData.HasValue Then
                    If oRow.ConsensoAziendale IsNot Nothing AndAlso Not String.IsNullOrEmpty(oRow.ConsensoAziendale.Codice) Then
                        '
                        ' Memorizzo la data del consenso aziendale.
                        '
                        dDataConsenso = oRow.ConsensoAziendale.Data
                        dDataUltimaNota = oRow.UltimaNotaAnamnesticaData

                        '
                        ' Verifico se bisogna visualizzare le icone.
                        '
                        bIconaVisibile = UserInterface.GetVisibilitaOggettoByDataConsenso(oRow.ConsensoAziendale.Codice, dDataConsenso, dDataUltimaNota)

                        '
                        ' Se l'icona è visibile.
                        '
                        If bIconaVisibile Then

                            Dim sTooltip As String = String.Format("{0} {1:d}", oRow.UltimaNotaAnamnesticaSistemaErogante, dDataUltimaNota)

                            '
                            ' Nell'accesso diretto si va ai referti senza il consenso...quindi nell'AccessoDiretto
                            ' non faccio test sul consenso come invece faccio nella lista pazienti "normale"
                            '
                            If Now.AddDays(-1) <= dDataUltimaNota Then
                                sRetHtml = String.Format("<span class='glyphicons glyphicons-notes-2 custom-icon-red-color custom-icon-font-size-15px' data-toggle='tooltip' data-placement='top' title='{0}'></span>", sTooltip)
                            ElseIf Now.AddDays(-7) <= dDataUltimaNota Then
                                sRetHtml = String.Format("<span class='glyphicons glyphicons-notes-2 custom-icon-blue-color custom-icon-font-size-15px' data-toggle='tooltip' data-placement='top' title='{0}'></span>", sTooltip)
                            ElseIf Now.AddDays(-30) <= dDataUltimaNota Then
                                sRetHtml = String.Format("<span class='glyphicons glyphicons-notes-2 custom-icon-yellow-color custom-icon-font-size-15px' data-toggle='tooltip' data-placement='top' title='{0}'></span>", sTooltip)
                            End If
                        End If
                    End If
                End If
            Catch ex As Exception
                '
                'Vado avanti senza trappare nessun errore.
                '
            End Try
        End If

        Return sRetHtml
    End Function

    ''' <summary>
    ''' Restituisce l'icona di presenza di warning nel referto
    ''' </summary>
    ''' <param name="oRow"></param>
    ''' <returns></returns>
    ''' 
    Public Overloads Shared Function GetImgPresenzaWarning(oRow As WcfDwhClinico.RefertoListaType, page As Page) As String

        Dim sRetHtml As String = String.Empty

        If Not String.IsNullOrEmpty(oRow.Avvertenze) Then
            sRetHtml = $"<img runat='server' src='{page.ResolveUrl("~/Images/Testo.gif")}' width='11px'>"
        End If
        '
        ' Restituisco
        '
        Return sRetHtml
    End Function

#Region "GetImgPresenzaReferti"
    ''' <summary>
    ''' Restituisce l'icona di presenza dei referti nel markup delle pagine di ricerca del paziente
    ''' </summary>
    ''' <param name="oRow"></param>
    ''' <returns></returns>
    ''' 
    Public Overloads Shared Function GetImgPresenzaReferti(oRow As WcfDwhClinico.PazienteListaType, page As Page) As String
        '
        ' L'interfaccia visualizza la presenza di referti anche se si tratta di un referto che l'utente
        ' non può vedere perchè oscurato o perchè il ruolo non può vedere referti di determinati sistemi
        ' MODIFICA ETTORE 2017-04-04: la visualizzazione dei dati dipende dal consenso, dalla data del consenso
        ' e dalle date dell'ultimo referto e della data di accettazione dell'ultimo ricovero
        '
        Dim sRetHtml As String = String.Empty
        Dim iConsenso As ConsensoMinimoAccordato = ConsensoMinimoAccordato.Nessuno
        Dim dDataConsenso As Nullable(Of Date) = Nothing
        Dim dDataUltimoReferto As Nullable(Of Date) = Nothing
        Dim bIconaVisibile As Boolean = False
        Try
            If Not oRow Is Nothing Then
                '
                ' Metto un default al consenso se manca
                '
                If Not String.IsNullOrEmpty(oRow.ConsensoAziendaleCodice) Then
                    iConsenso = CType(oRow.ConsensoAziendaleCodice, ConsensoMinimoAccordato)
                End If
                '
                ' Memorizzo la data del consenso aziendale
                '
                dDataConsenso = oRow.ConsensoAziendaleData
                dDataUltimoReferto = oRow.UltimoRefertoData
                '
                ' In base al consenso determino se l'icona è visibile
                '
                bIconaVisibile = GetVisibilitaOggettoByDataConsenso(iConsenso, dDataConsenso, dDataUltimoReferto)
                '
                ' Se l'icona è visibile
                '
                If bIconaVisibile Then
                    '
                    ' Nell'accesso diretto si va ai referti senza il consenso...quindi nell'AccessoDiretto
                    ' non faccio test sul consenso come invece faccio nella lista pazienti "normale"
                    '
                    If Now.AddDays(-1) <= dDataUltimoReferto Then
                        sRetHtml = "<img runat='server' src='" & page.ResolveUrl("~/Images/PresenzaReferti1.gif") & "' title='Pazienti con referti nel giorno corrente' border=0>"
                    ElseIf Now.AddDays(-7) <= dDataUltimoReferto Then
                        sRetHtml = "<img runat='server' src='" & page.ResolveUrl("~/Images/PresenzaReferti7.gif") & "' title='Pazienti con referti negli ultimi 7gg' border=0>"
                    ElseIf Now.AddDays(-30) <= dDataUltimoReferto Then
                        sRetHtml = "<img runat='server' src='" & page.ResolveUrl("~/Images/PresenzaReferti30.gif") & "' title='Pazienti con referti negli ultimi 30gg' border=0>"
                    End If
                End If
            End If
        Catch
        End Try
        '
        ' Restituisco
        '
        Return sRetHtml
    End Function

    Overloads Shared Function GetImgPresenzaReferti(refertiRow As WcfDwhClinico.RefertoListaType, page As Page) As String
        '
        ' Viene usata nella lista dei referti quindi non viene controllato il consenso
        ' Restituisce l'icona relativa all'ultima data di modifica del referto nella pagina dei referti
        '
        ' ATTENZIONE: questa funzione si basa sulla DataModifica del referto e non sulla data dell'ultimo referto
        '             come la GetImgPresenzaReferti(oRow As WcfDwhClinico.PazienteListaType, page As Page) da usare nelle pagine di lista pazienti
        '
        Dim strHtml As String = String.Empty
        If Not refertiRow Is Nothing Then
            If Now.AddDays(-1) <= refertiRow.DataModifica Then
                strHtml = "<img runat='server' src='" & page.ResolveUrl("~/Images/PresenzaReferti1.gif") & "' title='Referto modificato nel giorno corrente'>"
            ElseIf Now.AddDays(-7) <= refertiRow.DataModifica Then
                strHtml = "<img runat='server' src='" & page.ResolveUrl("~/Images/PresenzaReferti7.gif") & "' title='Referto modificato negli ultimi 7gg'>"
            ElseIf Now.AddDays(-30) <= refertiRow.DataModifica Then
                strHtml = "<img runat='server' src='" & page.ResolveUrl("~/Images/PresenzaReferti30.gif") & "' title='Referto modificato negli ultimi 30gg'>"
            End If
        End If
        Return strHtml
    End Function
#End Region

#End Region

    Public Shared Function GetMenuItem(oMenu As Menu, NomeItem As String) As MenuItem
        Dim oMenuItem As MenuItem = Nothing
        If Not oMenu Is Nothing Then
            For Each item As MenuItem In oMenu.Items
                If String.Compare(item.Value, NomeItem, True) = 0 Then
                    oMenuItem = item
                End If
            Next
        End If
        Return oMenuItem
    End Function

    Public Shared Function GetHtmlImgBlank(ByVal oPage As System.Web.UI.Page) As String
        Return "<img src='" & oPage.ResolveUrl("~/images/blank.gif") & "' border=0>"
    End Function

#Region "Consensi"

    Public Shared Function GetColConsenso(ByVal oStato As Object) As String
        '
        ' Ritorna l'HTML per disegnare la colonna del Consenso
        '
        Dim strHtml As String
        Dim bStato As Integer = CType(oStato, Boolean)
        If bStato Then
            strHtml = "<span class='glyphicon glyphicon-ok custom-icon-green-color'></span>"
        Else
            strHtml = "<span class='glyphicon glyphicon-remove custom-icon-red-color'></span>"
        End If
        Return strHtml
    End Function

    Public Shared Function GetColTipoConsenso(ByVal oTipo As Object) As String
        Dim tipoConsenso As String = CType(oTipo, String)
        Dim strHtml As String
        If String.Compare(tipoConsenso, "Generico", True) = 0 Then
            strHtml = "Base"
        ElseIf String.Compare(tipoConsenso, "DossierStorico", True) = 0 Then
            strHtml = "Dossier Storico"
        Else
            strHtml = tipoConsenso
        End If
        Return strHtml
    End Function


    Private Shared Function VisibilitaConcessioneConsenso_OLD(rigaConsenso As SacConsensiDataAccess.Consensi, ultimoconsenso As String) As Boolean
        Dim result As Boolean = False
        If Not rigaConsenso Is Nothing Then
            If Not rigaConsenso.Stato Then
                If Not String.IsNullOrEmpty(ultimoconsenso) Then
                    If String.Compare(ultimoconsenso, "Generico", True) = 0 Then
                        If String.Compare(rigaConsenso.Tipo, "Dossier", True) = 0 Then
                            result = True
                        End If
                    ElseIf String.Compare(ultimoconsenso, "Dossier", True) = 0 Then
                        If String.Compare(rigaConsenso.Tipo, "DossierStorico", True) = 0 Then
                            result = True
                        End If
                    End If
                Else
                    If String.Compare(rigaConsenso.Tipo, "Generico", True) = 0 Then
                        result = True
                    End If
                End If
            End If
        End If
        Return result
    End Function

    Private Shared Function VisibilitaConcessioneConsenso_NEW(rigaConsenso As SacConsensiDataAccess.Consensi, ultimoconsenso As String) As Boolean
        '
        ' La possibilità di concedere il consenso dipende da "ultimoconsenso" perchè nellam pagina di gestione dei consensi
        ' quando ho entrambi i consensi acquisiti POSITIVI si ha 
        '   PULSANTE  CONSENSO    STATO
        '   NEGA      DOSSIER     POSITIVO
        '   NEGA      DOSSIERSTORICO POSITIVO
        ' e nego il consenso di ordine minore (DOSSIER) devo ottenere 
        '   PULSANTE  CONSENSO      STATO
        '   CONCEDI DOSSIER         POSITIVO
        '           DOSSIERSTORICO  POSITIVO
        '
        Dim result As Boolean = False
        If Not rigaConsenso Is Nothing Then
            If Not rigaConsenso.Stato Then
                If Not String.IsNullOrEmpty(ultimoconsenso) Then
                    If String.Compare(ultimoconsenso, "Generico", True) = 0 Then
                        If String.Compare(rigaConsenso.Tipo, "Dossier", True) = 0 Then
                            result = True
                        End If
                    ElseIf String.Compare(ultimoconsenso, "Dossier", True) = 0 Then
                        If String.Compare(rigaConsenso.Tipo, "DossierStorico", True) = 0 Then
                            result = True
                        End If
                    End If
                Else
                    'MODIFICA ETTORE 2019-03-07: Ora il primo consenso ad essere concesso è il DOSSIER e quindi è il primo che deve mostrare il pulsante "Concedi"
                    '                               nel caso si sia acquisito per primo un DOSSIER NEGATO
                    If String.Compare(rigaConsenso.Tipo, "Dossier", True) = 0 Then
                        result = True
                    End If
                End If
            End If
        End If
        Return result

    End Function

    Public Shared Function VisibilitaConcessioneConsenso(rigaConsenso As SacConsensiDataAccess.Consensi, ultimoconsenso As String) As Boolean
        If My.Settings.NuovaGestioneConsensi = False Then
            Return VisibilitaConcessioneConsenso_OLD(rigaConsenso, ultimoconsenso)
        Else
            Return VisibilitaConcessioneConsenso_NEW(rigaConsenso, ultimoconsenso)
        End If
    End Function


    Private Shared Function VisibilitaNegazioneConsenso_OLD(rigaConsenso As SacConsensiDataAccess.Consensi) As Boolean
        Dim result As Boolean = False
        If Not rigaConsenso Is Nothing Then
            If Utility.CheckPermission(RoleManagerUtility2.ATTRIB_CONSENSO_NEG_CHANGE) Then
                If String.Compare(rigaConsenso.Tipo, "Generico", True) = 0 OrElse String.Compare(rigaConsenso.Tipo, "Dossier", True) = 0 OrElse String.Compare(rigaConsenso.Tipo, "DossierStorico", True) = 0 Then
                    If rigaConsenso.Stato Then
                        result = True
                    End If
                End If
            End If
        End If
        Return result
    End Function

    Private Shared Function VisibilitaNegazioneConsenso_NEW(rigaConsenso As SacConsensiDataAccess.Consensi) As Boolean
        Dim result As Boolean = False
        If Not rigaConsenso Is Nothing Then
            If Utility.CheckPermission(RoleManagerUtility2.ATTRIB_CONSENSO_NEG_CHANGE) Then
                If String.Compare(rigaConsenso.Tipo, "Dossier", True) = 0 OrElse String.Compare(rigaConsenso.Tipo, "DossierStorico", True) = 0 Then
                    If rigaConsenso.Stato Then
                        result = True
                    End If
                End If
            End If
        End If
        Return result
    End Function

    Public Shared Function VisibilitaNegazioneConsenso(rigaConsenso As SacConsensiDataAccess.Consensi) As Boolean
        If My.Settings.NuovaGestioneConsensi = False Then
            Return VisibilitaNegazioneConsenso_OLD(rigaConsenso)
        Else
            Return VisibilitaNegazioneConsenso_NEW(rigaConsenso)
        End If
    End Function



#End Region
End Class
