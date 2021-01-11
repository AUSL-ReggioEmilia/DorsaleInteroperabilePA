Imports Sac.Msg.Wcf
Imports Sac.Msg.Wcf.sac.bt.paziente.schema.dataaccess
Imports Sac.Msg.Wcf.sac.bt.consenso.schema.dataaccess

Module TypeExtension

    ''' <summary>
    ''' Se l'oggetto è Nothing restituisce NullString che ha default "" (NON CAMBIARE QUESTO COMPORTAMENTO POTREBBE CAUSARE ERRORI!!!)
    ''' </summary>
    <System.Runtime.CompilerServices.Extension()>
    Public Function NullSafeToString(Of T)(this As T, Optional NullString As String = "") As String
        If this Is Nothing Then
            Return NullString
        End If
        Return this.ToString()
    End Function


    <System.Runtime.CompilerServices.Extension()>
    Public Function ToMessaggioPaziente(ByVal Messaggio As MessaggioPazienteParameter) As Asmn.Sac.Msg.DataAccess.MessaggioPaziente
        '
        ' I flag MantenimentoPediatra, CapoFamiglia, Indigenza vengono veicolati tramite gli Attributi: li devo ricavare dagli attributi
        '
        Dim oDatiAnamnestici As String = Nothing
        Dim bMantenimentoPediatra As Boolean?
        Dim bCapoFamiglia As Boolean?
        Dim bIndigenza As Boolean?
        Dim sXmlAttributi As String = Nothing
        Dim oEsenzioni As New List(Of Asmn.Sac.Msg.DataAccess.PazienteEsenzione)
        Dim oFusione As Asmn.Sac.Msg.DataAccess.PazienteFusione = Nothing
        '
        ' Estraggo dagli attributi il flag, cosi per ora li scrivo anche in testata (verranno scritti anche negli attributi)
        '
        Dim oAttributo As AttributoType = Nothing

        'Se i dati arrivano da GST il nodo Messaggio.Paziente.Attributi potrebbe essere NOTHING
        If Not Messaggio.Paziente.Attributi Is Nothing Then

            oAttributo = Utility.GetAttributoByNome("MantenimentoPediatra", Messaggio.Paziente.Attributi)
            If Not oAttributo Is Nothing AndAlso Not String.IsNullOrEmpty(oAttributo.Valore) Then bMantenimentoPediatra = CBool(oAttributo.Valore)

            oAttributo = Utility.GetAttributoByNome("CapoFamiglia", Messaggio.Paziente.Attributi)
            If Not oAttributo Is Nothing AndAlso Not String.IsNullOrEmpty(oAttributo.Valore) Then bCapoFamiglia = CBool(oAttributo.Valore)

            oAttributo = Utility.GetAttributoByNome("Indigenza", Messaggio.Paziente.Attributi)
            If Not oAttributo Is Nothing AndAlso Not String.IsNullOrEmpty(oAttributo.Valore) Then bIndigenza = CBool(oAttributo.Valore)
            '
            ' Creo l'XML degli attributi
            '
            sXmlAttributi = ToXml(Messaggio.Paziente.Attributi)
        End If

        '
        ' Paziente
        '
        Dim oPaziente As New Asmn.Sac.Msg.DataAccess.Paziente(Messaggio.Paziente.Id, Messaggio.Paziente.Tessera, Messaggio.Paziente.Cognome, Messaggio.Paziente.Nome, Messaggio.Paziente.DataNascita,
                                                              Messaggio.Paziente.Sesso, Messaggio.Paziente.ComuneNascitaCodice, Messaggio.Paziente.NazionalitaCodice, Messaggio.Paziente.CodiceFiscale,
                                                              oDatiAnamnestici, bMantenimentoPediatra, bCapoFamiglia, bIndigenza,
                                                              Messaggio.Paziente.CodiceTerminazione, Messaggio.Paziente.DescrizioneTerminazione, Messaggio.Paziente.ComuneResCodice, Messaggio.Paziente.SubComuneRes,
                                                              Messaggio.Paziente.IndirizzoRes, Messaggio.Paziente.LocalitaRes, Messaggio.Paziente.CapRes, Messaggio.Paziente.DataDecorrenzaRes, Messaggio.Paziente.ComuneAslResCodice,
                                                              Messaggio.Paziente.CodiceAslRes, Messaggio.Paziente.RegioneResCodice, Messaggio.Paziente.ComuneDomCodice, Messaggio.Paziente.SubComuneDom,
                                                              Messaggio.Paziente.IndirizzoDom, Messaggio.Paziente.LocalitaDom, Messaggio.Paziente.CapDom, Messaggio.Paziente.PosizioneAss, Messaggio.Paziente.RegioneAssCodice,
                                                              Messaggio.Paziente.ComuneAslAssCodice, Messaggio.Paziente.CodiceAslAss, Messaggio.Paziente.DataInizioAss, Messaggio.Paziente.DataScadenzaAss,
                                                              Messaggio.Paziente.DataTerminazioneAss, Messaggio.Paziente.DistrettoAmm, Messaggio.Paziente.DistrettoTer, Messaggio.Paziente.Ambito, Messaggio.Paziente.CodiceMedicoDiBase,
                                                              Messaggio.Paziente.CodiceFiscaleMedicoDiBase, Messaggio.Paziente.CognomeNomeMedicoDiBase, Messaggio.Paziente.DistrettoMedicoDiBase,
                                                              Messaggio.Paziente.DataSceltaMedicoDiBase, Messaggio.Paziente.ComuneRecapitoCodice, Messaggio.Paziente.IndirizzoRecapito, Messaggio.Paziente.LocalitaRecapito,
                                                              Messaggio.Paziente.Telefono1, Messaggio.Paziente.Telefono2, Messaggio.Paziente.Telefono3,
                                                              Messaggio.Paziente.CodiceSTP, Messaggio.Paziente.DataInizioSTP, Messaggio.Paziente.DataFineSTP, Messaggio.Paziente.MotivoAnnulloSTP, sXmlAttributi)

        '
        ' Esenzioni
        '
        If Not Messaggio.Esenzioni Is Nothing AndAlso Messaggio.Esenzioni.Count > 0 Then
            oEsenzioni = New List(Of Asmn.Sac.Msg.DataAccess.PazienteEsenzione)
            For Each oEsenzione As EsenzioneType In Messaggio.Esenzioni
                'L'oggetto esenzione della DLL
                Dim oEsenzioneDll As New Asmn.Sac.Msg.DataAccess.PazienteEsenzione(oEsenzione.CodiceEsenzione, oEsenzione.CodiceDiagnosi, oEsenzione.Patologica,
                                                                                    oEsenzione.DataInizioValidita, oEsenzione.DataFineValidita, oEsenzione.NumeroAutorizzazioneEsenzione, oEsenzione.NoteAggiuntive,
                                                                                    oEsenzione.CodiceTestoEsenzione, oEsenzione.TestoEsenzione, oEsenzione.DecodificaEsenzioneDiagnosi,
                                                                                    oEsenzione.AttributoEsenzioneDiagnosi)
                oEsenzioni.Add(oEsenzioneDll)
            Next
        End If
        '
        ' Fusione (presente se MERGE)
        '
        If Not Messaggio.Fusione Is Nothing Then
            oFusione = New Asmn.Sac.Msg.DataAccess.PazienteFusione(Messaggio.Fusione.Id, Messaggio.Fusione.Tessera, Messaggio.Fusione.Cognome, Messaggio.Fusione.Nome, Messaggio.Fusione.DataNascita,
                                                                   Messaggio.Fusione.Sesso, Messaggio.Fusione.ComuneNascitaCodice, Messaggio.Fusione.NazionalitaCodice, Messaggio.Fusione.CodiceFiscale)
        End If
        '
        ' Costruisco la classe MessaggioPaziente
        '
        Dim oRet As New Asmn.Sac.Msg.DataAccess.MessaggioPaziente(Messaggio.Utente, Messaggio.DataSequenza, oPaziente, oEsenzioni.ToArray, oFusione)
        '
        ' Restituisco la classe MessaggioPaziente
        '
        Return oRet
    End Function


    <System.Runtime.CompilerServices.Extension()>
    Public Function ToMessaggioPazienteReturn(ByVal oRisposta As Asmn.Sac.Msg.DataAccess.RispostaPaziente) As MessaggioPazienteReturn
        If oRisposta Is Nothing Then Return Nothing

        Dim oRet As MessaggioPazienteReturn = Nothing
        If Not oRisposta.Paziente Is Nothing Then
            oRet = New MessaggioPazienteReturn

            oRet.IdMessaggio = oRisposta.IdMessaggio
            oRet.DataSequenza = oRisposta.DataSequenza
            oRet.Azione = oRisposta.Azione

            oRet.Paziente = oRisposta.Paziente.ToDettaglioPazienteReturn
            oRet.Esenzioni = oRisposta.Esenzioni.ToPazienteEsenzioni
            oRet.Sinonimi = oRisposta.Sinonimi.ToPazienteSinonimi
            oRet.Consensi = oRisposta.Consensi.ToPazienteConsensi

            If Not oRisposta.PazienteFuso Is Nothing Then
                oRet.Fusione = oRisposta.PazienteFuso.ToPazienteFusione()
            End If
        End If

        '
        '
        '
        Return oRet
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Private Function ToXml(oAttributi As AttributiType) As String

        If oAttributi Is Nothing Then Return Nothing
        If Not oAttributi.Any Then Return Nothing

        Dim oListNomi As New System.Collections.Generic.List(Of String)

        '
        ' Ordino la lista degli attributi per nome 
        '
        Dim oAttributiOrdinati As List(Of AttributoType) = (From c In oAttributi Order By c.Nome Ascending).ToList

        Dim eRoot = New XElement("Attributi")
        '
        ' Loop sugli attributi ordinati
        '
        Dim iCounterAttributi As Integer = 0
        For Each oAttributo As AttributoType In oAttributiOrdinati
            If String.IsNullOrEmpty(oAttributo.Nome) Or String.IsNullOrEmpty(oAttributo.Valore) Then Continue For
            '
            ' Mi assicuro di non aggiungere due volte lo stesso nome di attributo 
            '
            Dim oAttrNomeToUpper As String = oAttributo.Nome.ToUpper
            If Not oListNomi.Contains(oAttrNomeToUpper) Then
                oListNomi.Add(oAttrNomeToUpper)
                Dim eAttrib As New XElement("Attributo",
                                        New XAttribute("Nome", oAttributo.Nome),
                                        New XAttribute("Valore", oAttributo.Valore))
                eRoot.Add(eAttrib)
                iCounterAttributi = iCounterAttributi + 1
            End If
        Next
        '
        ' Se c'è almeno un attributo con valore <> "" restituisco XML altrimenti NOTHING (su DB diventa NULL)
        '
        If iCounterAttributi > 0 Then
            Return eRoot.ToString
        Else
            Return Nothing
        End If
    End Function


    <System.Runtime.CompilerServices.Extension()>
    Public Function ToDettaglioPazienteReturn(oDettaglioPaziente As Asmn.Sac.Msg.DataAccess.RispostaDettaglioPazienteWCF) As DettaglioPazienteReturn
        If oDettaglioPaziente Is Nothing Then Return Nothing

        Dim oRet As DettaglioPazienteReturn = Nothing
        If Not oDettaglioPaziente.Paziente Is Nothing Then
            oRet = New DettaglioPazienteReturn
            oRet.Paziente = oDettaglioPaziente.Paziente.ToDettaglioPazienteReturn
            oRet.Esenzioni = oDettaglioPaziente.Esenzioni.ToPazienteEsenzioni
            oRet.Sinonimi = oDettaglioPaziente.Sinonimi.ToPazienteSinonimi
            oRet.Consensi = oDettaglioPaziente.Consensi.ToPazienteConsensi
        End If
        '
        '
        '
        Return oRet
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Public Function ToDettaglioPazienteReturn(oDetPaz As Asmn.Sac.Msg.DataAccess.PazienteOut) As PazienteReturn
        Dim oRet As New PazienteReturn

        oRet.IdSac = oDetPaz.IdSac.ToUpper
        oRet.Provenienza = oDetPaz.Provenienza
        oRet.IdProvenienza = oDetPaz.IdProvenienza
        oRet.LivelloAttendibilita = oDetPaz.LivelloAttendibilita
        'Terminazione
        oRet.CodiceTerminazione = oDetPaz.CodiceTerminazione
        oRet.DescrizioneTerminazione = oDetPaz.DescrizioneTerminazione
        ' Generalità 
        oRet.CodiceFiscale = oDetPaz.CodiceFiscale
        oRet.Cognome = oDetPaz.Cognome
        oRet.Nome = oDetPaz.Nome
        oRet.DataNascita = oDetPaz.DataNascita
        oRet.Sesso = oDetPaz.Sesso
        oRet.Tessera = oDetPaz.Tessera
        oRet.ComuneNascitaCodice = oDetPaz.ComuneNascitaCodice
        oRet.ComuneNascitaNome = oDetPaz.ComuneNascitaNome
        oRet.NazionalitaCodice = oDetPaz.NazionalitaCodice
        oRet.NazionalitaNome = oDetPaz.NazionalitaNome
        oRet.DataDecesso = oDetPaz.DataDecesso
        ' Dati di residenza
        oRet.ComuneResCodice = oDetPaz.ComuneResCodice
        oRet.ComuneResNome = oDetPaz.ComuneResNome
        oRet.IndirizzoRes = oDetPaz.IndirizzoRes
        oRet.LocalitaRes = oDetPaz.LocalitaRes
        oRet.CapRes = oDetPaz.CapRes
        oRet.DataDecorrenzaRes = oDetPaz.DataDecorrenzaRes
        ' Dati di domicilio
        oRet.ComuneDomCodice = oDetPaz.ComuneDomCodice
        oRet.ComuneDomNome = oDetPaz.ComuneDomNome
        oRet.IndirizzoDom = oDetPaz.IndirizzoDom
        oRet.LocalitaDom = oDetPaz.LocalitaDom
        oRet.CapDom = oDetPaz.CapDom

        ' Dati di recapito
        oRet.ComuneRecapitoCodice = oDetPaz.ComuneRecapitoCodice
        oRet.ComuneRecapitoNome = oDetPaz.ComuneRecapitoNome
        oRet.IndirizzoRecapito = oDetPaz.IndirizzoRecapito
        oRet.LocalitaRecapito = oDetPaz.LocalitaRecapito
        oRet.Telefono1 = oDetPaz.Telefono1
        oRet.Telefono2 = oDetPaz.Telefono2
        oRet.Telefono3 = oDetPaz.Telefono3

        'Dati di STP
        oRet.CodiceStp = oDetPaz.CodiceStp
        oRet.DataInizioStp = oDetPaz.DataInizioStp
        oRet.DataFineStp = oDetPaz.DataFineStp
        oRet.MotivoAnnulloStp = oDetPaz.MotivoAnnulloStp
        ' Dati Assistito
        oRet.PosizioneAss = oDetPaz.PosizioneAss
        oRet.DataInizioAss = oDetPaz.DataInizioAss
        oRet.DataScadenzaAss = oDetPaz.DataScadenzaAss
        oRet.DataTerminazioneAss = oDetPaz.DataTerminazioneAss
        ' Dati USL Residenza
        oRet.CodiceAslRes = oDetPaz.CodiceAslRes
        oRet.RegioneResCodice = oDetPaz.RegioneResCodice
        oRet.ComuneAslResCodice = oDetPaz.ComuneAslResCodice
        ' Dati USL Assistenza
        oRet.CodiceAslAss = oDetPaz.CodiceAslAss
        oRet.RegioneAssCodice = oDetPaz.RegioneAssCodice
        oRet.ComuneAslAssCodice = oDetPaz.ComuneAslAssCodice
        ' Dati Medico di base
        oRet.CodiceMedicoDiBase = oDetPaz.CodiceMedicoDiBase
        oRet.CodiceFiscaleMedicoDiBase = oDetPaz.CodiceFiscaleMedicoDiBase
        oRet.CognomeNomeMedicoDiBase = oDetPaz.CognomeNomeMedicoDiBase
        oRet.DistrettoMedicoDiBase = oDetPaz.DistrettoMedicoDiBase
        oRet.DataSceltaMedicoDiBase = oDetPaz.DataSceltaMedicoDiBase

        'Questi campi verranno messi negli attributi del messaggio di output QueueOutput ver 2
        oRet.SubComuneRes = oDetPaz.SubComuneRes
        oRet.AslResNome = oDetPaz.AslResNome
        oRet.RegioneResNome = oDetPaz.RegioneResNome
        oRet.SubComuneDom = oDetPaz.SubComuneDom
        oRet.RegioneAssNome = oDetPaz.RegioneAssNome
        oRet.AslAssNome = oDetPaz.AslAssNome
        oRet.DistrettoAmm = oDetPaz.DistrettoAmm
        oRet.DistrettoTer = oDetPaz.DistrettoTer
        oRet.Ambito = oDetPaz.Ambito
        '
        ' Valorizzo gli attributi
        '
        oRet.Attributi = oDetPaz.Attributi.ToAttributi

        '
        '
        '
        Return oRet
    End Function


    <System.Runtime.CompilerServices.Extension()>
    Private Function ToAttributi(ByVal sAttributiXML As String) As AttributiType
        Const NAME_TAG_ATTRIBUTO As String = "Attributo"
        Const NAME_ATTRIBUTO_NOME As String = "Nome"
        Const NAME_ATTRIBUTO_VALORE As String = "Valore"
        '
        ' Se la testata esiste creo l'oggetto
        '
        Dim oAttributi As New AttributiType
        If Not String.IsNullOrEmpty(sAttributiXML) Then
            Dim oXmlAttributi As System.Xml.Linq.XDocument = System.Xml.Linq.XDocument.Parse(sAttributiXML)
            Dim query As System.Collections.Generic.IEnumerable(Of System.Xml.Linq.XElement) = From p In oXmlAttributi.Root.Elements(NAME_TAG_ATTRIBUTO) Order By p.Attribute(NAME_ATTRIBUTO_NOME).Value
            For Each oElement As System.Xml.Linq.XElement In query
                Dim sNome As String = oElement.Attribute(NAME_ATTRIBUTO_NOME).Value
                Dim sValore As String = oElement.Attribute(NAME_ATTRIBUTO_VALORE).Value
                If (Not String.IsNullOrEmpty(sNome)) Then
                    '
                    ' Aggiungo alla lista degli attributi
                    '
                    Dim oAttributo As New AttributoType
                    oAttributo.Nome = sNome
                    oAttributo.Valore = sValore
                    oAttributi.Add(oAttributo)
                End If
            Next
        End If
        '
        ' Restituisco
        '
        Return oAttributi
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Public Function ToPazienteSinonimi(oSinonimi As Asmn.Sac.Msg.DataAccess.PazienteSinonimo()) As SinonimiType
        Dim oRet As New SinonimiType
        If Not oSinonimi Is Nothing AndAlso oSinonimi.Count > 0 Then
            For Each oSinonimo In oSinonimi
                Dim oPazienteSinonimo As New SinonimoType
                ' Mi assicuro che gli Id GUID siano maiuscoli (oSinonimo.Id può essere un guid o una stringa...)
                ' [oSinonimo.Id, oSinonimo.Provenienza] = [guid,SAC]
                ' [oSinonimo.Id, oSinonimo.Provenienza] = [XXXXX,LHA]
                oPazienteSinonimo.Id = oSinonimo.Id.ToUpper
                oPazienteSinonimo.Provenienza = oSinonimo.Provenienza
                oRet.Add(oPazienteSinonimo)
            Next
        End If
        Return oRet
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Public Function ToPazienteEsenzioni(oEsenzioni As Asmn.Sac.Msg.DataAccess.PazienteEsenzioneOut()) As EsenzioniReturn
        Dim oRet As New EsenzioniReturn
        If Not oEsenzioni Is Nothing AndAlso oEsenzioni.Count > 0 Then
            For Each oEsenzione In oEsenzioni
                Dim oPazienteEsenzione As New EsenzioneReturn
                oPazienteEsenzione.CodiceEsenzione = oEsenzione.CodiceEsenzione
                oPazienteEsenzione.CodiceDiagnosi = oEsenzione.CodiceDiagnosi
                oPazienteEsenzione.Patologica = oEsenzione.Patologica
                oPazienteEsenzione.DataInizioValidita = oEsenzione.DataInizioValidita
                oPazienteEsenzione.DataFineValidita = oEsenzione.DataFineValidita
                oPazienteEsenzione.NumeroAutorizzazioneEsenzione = oEsenzione.NumeroAutorizzazioneEsenzione
                oPazienteEsenzione.NoteAggiuntive = oEsenzione.NoteAggiuntive
                oPazienteEsenzione.CodiceTestoEsenzione = oEsenzione.CodiceTestoEsenzione
                oPazienteEsenzione.TestoEsenzione = oEsenzione.TestoEsenzione
                oPazienteEsenzione.DecodificaEsenzioneDiagnosi = oEsenzione.DecodificaEsenzioneDiagnosi
                oPazienteEsenzione.AttributoEsenzioneDiagnosi = oEsenzione.AttributoEsenzioneDiagnosi
                oPazienteEsenzione.Provenienza = oEsenzione.Provenienza
                oPazienteEsenzione.OperatoreId = oEsenzione.OperatoreId
                oPazienteEsenzione.OperatoreCognome = oEsenzione.OperatoreCognome
                oPazienteEsenzione.OperatoreNome = oEsenzione.OperatoreNome
                oPazienteEsenzione.OperatoreComputer = oEsenzione.OperatoreComputer
                '
                ' Aggiungo alla lista
                '
                oRet.Add(oPazienteEsenzione)
            Next
        End If
        Return oRet
    End Function


    <System.Runtime.CompilerServices.Extension()>
    Public Function ToPazienteConsensi(oConsensi As Asmn.Sac.Msg.DataAccess.PazienteConsensoOut()) As ConsensiType
        Dim oRet As New ConsensiType
        If Not oConsensi Is Nothing AndAlso oConsensi.Count > 0 Then
            For Each oConsenso In oConsensi
                Dim oPazienteConsenso As New sac.bt.paziente.schema.dataaccess.ConsensoType
                oPazienteConsenso.Provenienza = oConsenso.Provenienza
                oPazienteConsenso.IdProvenienza = oConsenso.IdProvenienza
                oPazienteConsenso.Tipo = oConsenso.Tipo
                oPazienteConsenso.Stato = oConsenso.Stato
                oPazienteConsenso.DataStato = oConsenso.DataStato
                oPazienteConsenso.OperatoreId = oConsenso.OperatoreId
                oPazienteConsenso.OperatoreCognome = oConsenso.OperatoreCognome
                oPazienteConsenso.OperatoreNome = oConsenso.OperatoreNome
                oPazienteConsenso.OperatoreComputer = oConsenso.OperatoreComputer
                oRet.Add(oPazienteConsenso)
            Next
        End If
        Return oRet
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Public Function ToPazienteFusione(oPazienteFusoOut As Asmn.Sac.Msg.DataAccess.PazienteFusoOut) As FusoType
        Dim oRet As sac.bt.paziente.schema.dataaccess.FusoType = Nothing
        If Not oPazienteFusoOut Is Nothing Then
            oRet = New sac.bt.paziente.schema.dataaccess.FusoType

            oRet.IdSac = oPazienteFusoOut.IdSac
            oRet.Provenienza = oPazienteFusoOut.Provenienza
            oRet.IdProvenienza = oPazienteFusoOut.IdProvenienza
            'GENERALITA'
            oRet.CodiceFiscale = oPazienteFusoOut.CodiceFiscale
            oRet.Cognome = oPazienteFusoOut.Cognome
            oRet.Nome = oPazienteFusoOut.Nome
            oRet.DataNascita = oPazienteFusoOut.DataNascita
            oRet.Sesso = oPazienteFusoOut.Sesso
            oRet.CodiceSanitario = oPazienteFusoOut.CodiceSanitario
            oRet.ComuneNascitaCodice = oPazienteFusoOut.ComuneNascitaCodice
            oRet.ComuneNascitaNome = oPazienteFusoOut.ComuneNascitaNome
            oRet.NazionalitaCodice = oPazienteFusoOut.NazionalitaCodice
            oRet.NazionalitaNome = oPazienteFusoOut.NazionalitaNome
            oRet.DataDecesso = oPazienteFusoOut.DataDecesso
            oRet.Attributi = oPazienteFusoOut.Attributi.ToAttributi()
        End If
        Return oRet
    End Function



    <System.Runtime.CompilerServices.Extension()>
    Public Function ToPazientiReturn(oListaPazienti As Asmn.Sac.Msg.DataAccess.RispostaListaPazientiWcf) As ListaPazientiReturn
        If oListaPazienti Is Nothing Then Return Nothing
        Dim oRet As New ListaPazientiReturn
        Dim oPazienti As New ListaPazientiType
        'Se ho dei pazienti
        If Not oListaPazienti.Paziente Is Nothing AndAlso oListaPazienti.Paziente.Count > 0 Then
            For Each oPaz As Asmn.Sac.Msg.DataAccess.PazienteLista In oListaPazienti.Paziente
                Dim oListaPazienteReturn As ListaPazienteType = oPaz.ToListaPazienteReturn()
                oPazienti.Add(oListaPazienteReturn)
            Next
        End If

        oRet.Pazienti = oPazienti
        '
        '
        '
        Return oRet
    End Function

    <System.Runtime.CompilerServices.Extension()>
    Public Function ToListaPazienteReturn(oPazienteLista As Asmn.Sac.Msg.DataAccess.PazienteLista) As ListaPazienteType
        Dim oRet As New ListaPazienteType
        oRet.IdSac = oPazienteLista.IdSac
        oRet.Provenienza = oPazienteLista.Provenienza
        oRet.IdProvenienza = oPazienteLista.IdProvenienza
        oRet.LivelloAttendibilita = oPazienteLista.LivelloAttendibilita 'da restituire
        'Terminazione
        oRet.CodiceTerminazione = oPazienteLista.CodiceTerminazione
        oRet.DescrizioneTerminazione = oPazienteLista.DescrizioneTerminazione
        ' Generalità 
        oRet.CodiceFiscale = oPazienteLista.CodiceFiscale
        oRet.Cognome = oPazienteLista.Cognome
        oRet.Nome = oPazienteLista.Nome
        oRet.DataNascita = oPazienteLista.DataNascita
        oRet.Sesso = oPazienteLista.Sesso
        oRet.Tessera = oPazienteLista.Tessera
        oRet.ComuneNascitaCodice = oPazienteLista.ComuneNascitaCodice
        oRet.ComuneNascitaNome = oPazienteLista.ComuneNascitaNome
        oRet.NazionalitaCodice = oPazienteLista.NazionalitaCodice
        oRet.NazionalitaNome = oPazienteLista.NazionalitaNome
        oRet.DataDecesso = oPazienteLista.DataDecesso
        ' Dati di residenza
        oRet.ComuneResCodice = oPazienteLista.ComuneResCodice
        oRet.ComuneResNome = oPazienteLista.ComuneResNome
        oRet.IndirizzoRes = oPazienteLista.IndirizzoRes
        oRet.LocalitaRes = oPazienteLista.LocalitaRes
        oRet.CapRes = oPazienteLista.CapRes
        oRet.DataDecorrenzaRes = oPazienteLista.DataDecorrenzaRes
        ' Dati di domicilio
        oRet.ComuneDomCodice = oPazienteLista.ComuneDomCodice
        oRet.ComuneDomNome = oPazienteLista.ComuneDomNome
        oRet.IndirizzoDom = oPazienteLista.IndirizzoDom
        oRet.LocalitaDom = oPazienteLista.LocalitaDom
        oRet.CapDom = oPazienteLista.CapDom
        ' Dati di recapito
        oRet.ComuneRecapitoCodice = oPazienteLista.ComuneRecapitoCodice
        oRet.ComuneRecapitoNome = oPazienteLista.ComuneRecapitoNome
        oRet.IndirizzoRecapito = oPazienteLista.IndirizzoRecapito
        oRet.LocalitaRecapito = oPazienteLista.LocalitaRecapito
        oRet.Telefono1 = oPazienteLista.Telefono1
        oRet.Telefono2 = oPazienteLista.Telefono2
        oRet.Telefono3 = oPazienteLista.Telefono3
        'Dati di STP
        oRet.CodiceSTP = oPazienteLista.CodiceStp
        oRet.DataInizioSTP = oPazienteLista.DataInizioStp
        oRet.DataFineSTP = oPazienteLista.DataFineStp
        oRet.MotivoAnnulloSTP = oPazienteLista.MotivoAnnulloStp
        ' Dati Assistito
        oRet.PosizioneAss = oPazienteLista.PosizioneAss
        oRet.DataInizioAss = oPazienteLista.DataInizioAss
        oRet.DataScadenzaAss = oPazienteLista.DataScadenzaAss
        oRet.DataTerminazioneAss = oPazienteLista.DataTerminazioneAss
        ' Dati USL Residenza
        oRet.CodiceAslRes = oPazienteLista.CodiceAslRes
        oRet.RegioneResCodice = oPazienteLista.RegioneResCodice
        oRet.ComuneAslResCodice = oPazienteLista.ComuneAslResCodice
        ' Dati USL Assistenza
        oRet.CodiceAslAss = oPazienteLista.CodiceAslAss
        oRet.RegioneAssCodice = oPazienteLista.RegioneAssCodice
        oRet.ComuneAslAssCodice = oPazienteLista.ComuneAslAssCodice
        ' Dati Medico di base
        oRet.CodiceMedicoDiBase = oPazienteLista.CodiceMedicoDiBase
        oRet.CodiceFiscaleMedicoDiBase = oPazienteLista.CodiceFiscaleMedicoDiBase
        oRet.CognomeNomeMedicoDiBase = oPazienteLista.CognomeNomeMedicoDiBase
        oRet.DistrettoMedicoDiBase = oPazienteLista.DistrettoMedicoDiBase
        oRet.DataSceltaMedicoDiBase = oPazienteLista.DataSceltaMedicoDiBase

        oRet.SubComuneRes = oPazienteLista.SubComuneRes
        oRet.AslResNome = oPazienteLista.AslResNome
        oRet.RegioneResNome = oPazienteLista.RegioneResNome
        oRet.SubComuneDom = oPazienteLista.SubComuneDom
        oRet.RegioneAssNome = oPazienteLista.RegioneAssNome
        oRet.AslAssNome = oPazienteLista.AslAssNome
        oRet.DistrettoAmm = oPazienteLista.DistrettoAmm
        oRet.DistrettoTer = oPazienteLista.DistrettoTer
        oRet.Ambito = oPazienteLista.Ambito

        '
        ' Costruisco gli attributi
        '
        oRet.Attributi = ToAttributi(oPazienteLista.Attributi)
        '
        ' Costruisco i sinonimi
        '
        oRet.Sinonimi = ToPazienteSinonimi(oPazienteLista.Sinonimi)
        '
        ' Costruisco le esenzioni
        '
        oRet.Esenzioni = ToPazienteEsenzioni(oPazienteLista.Esenzioni)
        '
        ' Costruisco i consensi
        '
        oRet.Consensi = ToPazienteConsensi(oPazienteLista.Consensi)

        '
        '
        '
        Return oRet
    End Function




#Region "Consensi"
    <System.Runtime.CompilerServices.Extension()>
    Public Function ToMessaggioConsenso(ByVal Messaggio As MessaggioConsensoParameter) As Asmn.Sac.Msg.DataAccess.MessaggioConsenso
        '
        '
        '
        Dim oPazienteDataNascita As DateTime = Nothing
        If Messaggio.Consenso.PazienteDataNascita.HasValue Then
            oPazienteDataNascita = Messaggio.Consenso.PazienteDataNascita.Value
        End If
        '
        ' Consenso
        '
        Dim oConsenso As New Asmn.Sac.Msg.DataAccess.Consenso(Messaggio.Consenso.Id, Messaggio.Consenso.Tipo, Messaggio.Consenso.DataStato, Messaggio.Consenso.Stato,
                        Messaggio.Consenso.OperatoreId, Messaggio.Consenso.OperatoreCognome, Messaggio.Consenso.OperatoreNome, Messaggio.Consenso.OperatoreComputer,
                        Messaggio.Consenso.PazienteProvenienza, Messaggio.Consenso.PazienteIdProvenienza,
                        Messaggio.Consenso.PazienteCognome, Messaggio.Consenso.PazienteNome, Messaggio.Consenso.PazienteCodiceFiscale,
                        oPazienteDataNascita, Messaggio.Consenso.PazienteComuneNascitaCodice,
                        Messaggio.Consenso.PazienteNazionalitaCodice, Messaggio.Consenso.PazienteTesseraSanitaria)

        '
        ' Costruisco la classe MessaggioPaziente
        '
        Dim oRet As New Asmn.Sac.Msg.DataAccess.MessaggioConsenso(Messaggio.Utente, Messaggio.DataSequenza, oConsenso)
        '
        ' Restituisco la classe MessaggioConsenso per la DLL
        '
        Return oRet
    End Function


#End Region

End Module



