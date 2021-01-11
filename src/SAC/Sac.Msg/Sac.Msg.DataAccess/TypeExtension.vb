Imports System.Linq
Imports System.Xml.Linq

Module TypeExtension

    <System.Runtime.CompilerServices.Extension()>
    Public Function ToXml(oAttributi As System.Collections.Generic.List(Of Attributo)) As String

        If oAttributi Is Nothing Then Return Nothing
        If Not oAttributi.Any Then Return Nothing

        Dim oListNomi As New System.Collections.Generic.List(Of String)

        '
        ' Ordino la lista degli attributi per nome 
        '
        Dim oAttributiOrdinati As List(Of Attributo) = (From c In oAttributi Order By c.Nome Ascending).ToList

        Dim eRoot = New XElement("Attributi")
        '
        ' Loop sugli attributi ordinati
        '
        Dim iCounterAttributi As Integer = 0
        For Each oAttributo As Attributo In oAttributiOrdinati
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
    Public Function ToListAttributi(ByVal sAttributiXML As String) As System.Collections.Generic.List(Of Attributo)
        Const NAME_TAG_ATTRIBUTO As String = "Attributo"
        Const NAME_ATTRIBUTO_NOME As String = "Nome"
        Const NAME_ATTRIBUTO_VALORE As String = "Valore"
        '
        ' Se la testata esiste creo l'oggetto
        '
        Dim oAttributi As New System.Collections.Generic.List(Of Attributo)
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
                    Dim oAttributo As New Attributo(sNome, sValore)
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
    Public Function ToPazienteOutput(ByVal dr As PazientiDataSet.PazienteDettaglioRow) As PazienteOut

        Dim sIdSac As String = dr.Id.ToString.ToUpper()
        Dim sProvenienza As String = dr.Provenienza
        Dim sIdProvenienza As String = dr.IdProvenienza
        Dim iLivelloAttendibilita As Integer = dr.LivelloAttendibilita

        'Terminazione
        Dim sCodiceTerminazione As String = Nothing
        If Not dr.IsCodiceTerminazioneNull() Then sCodiceTerminazione = dr.CodiceTerminazione

        Dim sDescrizioneTerminazione As String = Nothing
        If Not dr.IsDescrizioneTerminazioneNull() Then sDescrizioneTerminazione = dr.DescrizioneTerminazione

        'Generalità
        Dim sCodiceFiscale As String = Nothing
        If Not dr.IsCodiceFiscaleNull() Then sCodiceFiscale = dr.CodiceFiscale

        Dim sCognome As String = Nothing
        If Not dr.IsCognomeNull() Then sCognome = dr.Cognome

        Dim sNome As String = Nothing
        If Not dr.IsNomeNull() Then sNome = dr.Nome

        Dim oDataNascita As DateTime? = Nothing
        If Not dr.IsDataNascitaNull() Then oDataNascita = dr.DataNascita

        Dim sSesso As String = Nothing
        If Not dr.IsSessoNull() Then sSesso = dr.Sesso

        Dim sTessera As String = Nothing ' La sp usata per leggere il dettaglio restituisce "Tessera"
        If Not dr.IsTesseraNull Then sTessera = dr.Tessera

        Dim sComuneNascitaCodice As String = Nothing
        If Not dr.IsComuneNascitaCodiceNull Then sComuneNascitaCodice = dr.ComuneNascitaCodice

        Dim sComuneNascitaNome As String = Nothing
        If Not dr.IsComuneNascitaNomeNull Then sComuneNascitaNome = dr.ComuneNascitaNome

        Dim sNazionalitaCodice As String = Nothing
        If Not dr.IsNazionalitaCodiceNull Then sNazionalitaCodice = dr.NazionalitaCodice

        Dim sNazionalitaNome As String = Nothing
        If Not dr.IsNazionalitaNomeNull Then sNazionalitaNome = dr.NazionalitaNome

        Dim oDataDecesso As DateTime? = Nothing
        If Not dr.IsDataDecessoNull Then oDataDecesso = dr.DataDecesso

        'Dati di residenza
        Dim sComuneResCodice As String = Nothing
        If Not dr.IsComuneResCodiceNull Then sComuneResCodice = dr.ComuneResCodice

        Dim sComuneResNome As String = Nothing
        If Not dr.IsComuneResNomeNull Then sComuneResNome = dr.ComuneResNome

        Dim sIndirizzoRes As String = Nothing
        If Not dr.IsIndirizzoResNull Then sIndirizzoRes = dr.IndirizzoRes

        Dim sLocalitaRes As String = Nothing
        If Not dr.IsLocalitaResNull Then sLocalitaRes = dr.LocalitaRes

        Dim sCapRes As String = Nothing
        If Not dr.IsCapResNull Then sCapRes = dr.CapRes

        Dim oDataDecorrenzaRes As DateTime?
        If Not dr.IsDataDecorrenzaResNull Then oDataDecorrenzaRes = dr.DataDecorrenzaRes

        'Dati di domicilio
        Dim sComuneDomCodice As String = Nothing
        If Not dr.IsComuneDomCodiceNull Then sComuneDomCodice = dr.ComuneDomCodice

        Dim sComuneDomNome As String = Nothing
        If Not dr.IsComuneDomNomeNull Then sComuneDomNome = dr.ComuneDomNome

        Dim sIndirizzoDom As String = Nothing
        If Not dr.IsIndirizzoDomNull Then sIndirizzoDom = dr.IndirizzoDom

        Dim sLocalitaDom As String = Nothing
        If Not dr.IsLocalitaDomNull Then sLocalitaDom = dr.LocalitaDom

        Dim sCapDom As String = Nothing
        If Not dr.IsCapDomNull Then sCapDom = dr.CapDom


        'Dati di recapito
        Dim sComuneRecapitoCodice As String = Nothing
        If Not dr.IsComuneRecapitoCodiceNull Then sComuneRecapitoCodice = dr.ComuneRecapitoCodice

        Dim sComuneRecapitoNome As String = Nothing
        If Not dr.IsComuneRecapitoNomeNull Then sComuneRecapitoNome = dr.ComuneRecapitoNome

        Dim sIndirizzoRecapito As String = Nothing
        If Not dr.IsIndirizzoRecapitoNull Then sIndirizzoRecapito = dr.IndirizzoRecapito

        Dim sLocalitaRecapito As String = Nothing
        If Not dr.IsLocalitaRecapitoNull Then sLocalitaRecapito = dr.LocalitaRecapito


        Dim sTelefono1 As String = Nothing
        If Not dr.IsTelefono1Null Then sTelefono1 = dr.Telefono1

        Dim sTelefono2 As String = Nothing
        If Not dr.IsTelefono2Null Then sTelefono2 = dr.Telefono2

        Dim sTelefono3 As String = Nothing
        If Not dr.IsTelefono3Null Then sTelefono3 = dr.Telefono3


        'Dati di STP
        Dim sCodiceStp As String = Nothing
        If Not dr.IsCodiceSTPNull Then sCodiceStp = dr.CodiceSTP

        Dim oDataInizioStp As DateTime?
        If Not dr.IsDataInizioSTPNull Then oDataInizioStp = dr.DataInizioSTP

        Dim oDataFineStp As DateTime?
        If Not dr.IsDataFineSTPNull Then oDataFineStp = dr.DataFineSTP

        Dim sMotivoAnnulloStp As String = Nothing
        If Not dr.IsMotivoAnnulloSTPNull Then sMotivoAnnulloStp = dr.MotivoAnnulloSTP

        'Dati Assistito
        Dim iPosizioneAss As Byte? = Nothing
        If Not dr.IsPosizioneAssNull Then iPosizioneAss = dr.PosizioneAss

        Dim oDataInizioAss As DateTime?
        If Not dr.IsDataInizioAssNull Then oDataInizioAss = dr.DataInizioAss

        Dim oDataScadenzaAss As DateTime?
        If Not dr.IsDataScadenzaAssNull Then oDataScadenzaAss = dr.DataScadenzaAss

        Dim oDataTerminazioneAss As DateTime?
        If Not dr.IsDataTerminazioneAssNull Then oDataTerminazioneAss = dr.DataTerminazioneAss

        'Dati USL Residenza
        Dim sCodiceAslRes As String = Nothing
        If Not dr.IsCodiceAslResNull Then sCodiceAslRes = dr.CodiceAslRes

        Dim sRegioneResCodice As String = Nothing
        If Not dr.IsRegioneResCodiceNull Then sRegioneResCodice = dr.RegioneResCodice

        Dim sComuneAslResCodice As String = Nothing
        If Not dr.IsComuneAslResCodiceNull Then sComuneAslResCodice = dr.ComuneAslResCodice


        'Dati USL Assistenza
        Dim sCodiceAslAss As String = Nothing
        If Not dr.IsCodiceAslAssNull Then sCodiceAslAss = dr.CodiceAslAss

        Dim sRegioneAssCodice As String = Nothing
        If Not dr.IsRegioneAssCodiceNull Then sRegioneAssCodice = dr.RegioneAssCodice

        Dim sComuneAslAssCodice As String = Nothing
        If Not dr.IsComuneAslAssCodiceNull Then sComuneAslAssCodice = dr.ComuneAslAssCodice

        'Dati Medico di base
        Dim sCodiceMedicoDiBase As String = Nothing
        If Not dr.IsCodiceMedicoDiBaseNull Then sCodiceMedicoDiBase = dr.CodiceMedicoDiBase.ToString

        Dim sCodiceFiscaleMedicoDiBase As String = Nothing
        If Not dr.IsCodiceFiscaleMedicoDiBaseNull Then sCodiceFiscaleMedicoDiBase = dr.CodiceFiscaleMedicoDiBase

        Dim sCognomeNomeMedicoDiBase As String = Nothing
        If Not dr.IsCognomeNomeMedicoDiBaseNull Then sCognomeNomeMedicoDiBase = dr.CognomeNomeMedicoDiBase

        Dim sDistrettoMedicoDiBase As String = Nothing
        If Not dr.IsDistrettoMedicoDiBaseNull Then sDistrettoMedicoDiBase = dr.DistrettoMedicoDiBase

        Dim oDataSceltaMedicoDiBase As DateTime?
        If Not dr.IsDataSceltaMedicoDiBaseNull Then oDataSceltaMedicoDiBase = dr.DataSceltaMedicoDiBase

        'Questi finiscono negli attributi del messaggio QueueOutput ver 2
        Dim sSubComuneRes As String = Nothing
        If Not dr.IsSubComuneResNull Then sSubComuneRes = dr.SubComuneRes

        Dim sAslResNome As String = Nothing
        If Not dr.IsAslResNomeNull Then sAslResNome = dr.AslResNome

        Dim sRegioneResNome As String = Nothing
        If Not dr.IsRegioneResNomeNull Then sRegioneResNome = dr.RegioneResNome

        Dim sSubComuneDom As String = Nothing
        If Not dr.IsSubComuneDomNull Then sSubComuneDom = dr.SubComuneDom

        Dim sRegioneAssNome As String = Nothing
        If Not dr.IsRegioneAssNomeNull Then sRegioneAssNome = dr.RegioneAssNome

        Dim sAslAssNome As String = Nothing
        If Not dr.IsAslAssNomeNull Then sAslAssNome = dr.AslAssNome

        Dim sDistrettoAmm As String = Nothing
        If Not dr.IsDistrettoAmmNull Then sDistrettoAmm = dr.DistrettoAmm

        Dim sDistrettoTer As String = Nothing
        If Not dr.IsDistrettoTerNull Then sDistrettoTer = dr.DistrettoTer

        Dim sAmbito As String = Nothing
        If Not dr.IsAmbitoNull Then sAmbito = dr.Ambito

        'Attributi del paziente
        Dim sAttributi As String = Nothing
        If Not dr.IsAttributiNull Then sAttributi = dr.Attributi

        '
        ' Creo il paziente
        '
        Dim oPaziente As New PazienteOut(sIdSac, sProvenienza, sIdProvenienza, iLivelloAttendibilita,
                            sCodiceTerminazione, sDescrizioneTerminazione,
                            sCodiceFiscale, sCognome, sNome, oDataNascita, sSesso, sTessera,
                            sComuneNascitaCodice, sComuneNascitaNome, sNazionalitaCodice, sNazionalitaNome, oDataDecesso,
                            sComuneResCodice, sComuneResNome, sIndirizzoRes, sLocalitaRes, sCapRes, oDataDecorrenzaRes,
                            sComuneDomCodice, sComuneDomNome, sIndirizzoDom, sLocalitaDom, sCapDom,
                            sComuneRecapitoCodice, sComuneRecapitoNome, sIndirizzoRecapito, sLocalitaRecapito,
                            sTelefono1, sTelefono2, sTelefono3,
                            sCodiceStp, oDataInizioStp, oDataFineStp, sMotivoAnnulloStp,
                            iPosizioneAss, oDataInizioAss, oDataScadenzaAss, oDataTerminazioneAss,
                            sCodiceAslRes, sRegioneResCodice, sComuneAslResCodice,
                            sCodiceAslAss, sRegioneAssCodice, sComuneAslAssCodice,
                            sCodiceMedicoDiBase, sCodiceFiscaleMedicoDiBase, sCognomeNomeMedicoDiBase, sDistrettoMedicoDiBase, oDataSceltaMedicoDiBase,
                            sSubComuneRes,
                            sAslResNome,
                            sRegioneResNome,
                            sSubComuneDom,
                            sRegioneAssNome,
                            sAslAssNome,
                            sDistrettoAmm,
                            sDistrettoTer,
                            sAmbito,
                            sAttributi)
        Return oPaziente
    End Function


    <System.Runtime.CompilerServices.Extension()>
    Public Function ToPazienteFusoOut(ByVal oDt As PazientiDataSet.PazienteDettaglioDataTable) As PazienteFusoOut

        Dim oRow As PazientiDataSet.PazienteDettaglioRow = oDt(0)

        Dim sIdSac As String = String.Empty
        sIdSac = oRow.Id.ToString.ToUpper

        Dim sProvenienza As String = String.Empty
        sProvenienza = oRow.Provenienza

        Dim sIdProvenienza As String = String.Empty
        sIdProvenienza = oRow.IdProvenienza

        Dim sCodiceFiscale As String = String.Empty
        If Not oRow.IsCodiceFiscaleNull Then sCodiceFiscale = oRow.CodiceFiscale

        Dim sCognome As String = String.Empty
        If Not oRow.IsCognomeNull Then sCognome = oRow.Cognome

        Dim sNome As String = String.Empty
        If Not oRow.IsNomeNull Then sNome = oRow.Nome

        Dim dDataNascita As Nullable(Of DateTime) = Nothing
        If Not oRow.IsDataNascitaNull Then dDataNascita = oRow.DataNascita

        Dim sSesso As String = String.Empty
        If Not oRow.IsSessoNull Then sSesso = oRow.Sesso

        Dim sCodiceSanitario As String = String.Empty
        If Not oRow.IsTesseraNull Then sCodiceSanitario = oRow.Tessera

        Dim sComuneNascitaCodice As String = String.Empty
        If Not oRow.IsComuneNascitaCodiceNull Then sComuneNascitaCodice = oRow.ComuneNascitaCodice

        Dim sComuneNascitaNome As String = String.Empty
        If Not oRow.IsComuneNascitaNomeNull Then sComuneNascitaNome = oRow.ComuneNascitaNome

        Dim sNazionalitaCodice As String = String.Empty
        If Not oRow.IsNazionalitaCodiceNull Then sNazionalitaCodice = oRow.NazionalitaCodice

        Dim sNazionalitaNome As String = String.Empty
        If Not oRow.IsNazionalitaNomeNull Then sNazionalitaNome = oRow.NazionalitaNome

        Dim dDataDecesso As Nullable(Of DateTime) = Nothing
        If Not oRow.IsDataDecessoNull Then dDataDecesso = oRow.DataDecesso

        Dim sAttributi As String = String.Empty
        If Not oRow.IsAttributiNull Then sAttributi = oRow.Attributi

        ''
        '' Determino gli attributi del nodo Fusione: Fusione.Attributi = Paziente.Attributi letti da DB + Campi testata della PazienteDettaglioDataTable che non sono già mappati nel nodo Fusione
        ''
        ''
        '' Creo la lista degli attributi del nodo fusione
        ''
        'Dim oListAttributi As New System.Collections.Generic.List(Of Attributo)
        ''
        '' Aggiungo prima gli "attributi paziente" letti da database
        ''
        'If Not oRow.IsAttributiNull Then
        '    oListAttributi = oRow.Attributi.ToAttributi
        'End If
        ''
        '' Creo una lista di esclusione con i nomi dei campi che non devo aggiungere agli attributi (perchè già presenti in testata)
        ''
        'Dim oListExclude As New System.Collections.Generic.List(Of String)
        'oListExclude.Add("ID")
        'oListExclude.Add("PROVENIENZA")
        'oListExclude.Add("IDPROVENIENZA")
        'oListExclude.Add("CODICEFISCALE")
        'oListExclude.Add("COGNOME")
        'oListExclude.Add("NOME")
        'oListExclude.Add("DATANASCITA")
        'oListExclude.Add("SESSO")
        'oListExclude.Add("TESSERA")
        'oListExclude.Add("COMUNENASCITACODICE")
        'oListExclude.Add("COMUNENASCITANOME")
        'oListExclude.Add("NAZIONALITACODICE")
        'oListExclude.Add("NAZIONALITANOME")
        'oListExclude.Add("ATTRIBUTI")
        ''
        '' Aggiungo i campi di testata alla lista di attributi
        ''
        'oListAttributi = BuildListaAttributi(oListAttributi, oDt, oListExclude)
        ''
        '' La converto in XML (stringa). La funzione elimina eventuali doppi
        ''
        'sAttributi = oListAttributi.ToXml

        Dim oFuso As New PazienteFusoOut(sIdSac, sProvenienza, sIdProvenienza, sCodiceFiscale, sCognome, sNome, dDataNascita, sSesso, sCodiceSanitario,
                                        sComuneNascitaCodice, sComuneNascitaNome, sNazionalitaCodice, sNazionalitaNome, dDataDecesso, sAttributi)

        '
        ' Restituisco
        '
        Return oFuso
    End Function


End Module
