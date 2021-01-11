Imports DwhClinico.Data
'**********************************************************************************************************************************************************************
' Facendo delle prove ho notato che:
'   1)  se si passa dei dati qualsiasi per i campi del richiedente ma codice fiscale corretto il patient summary viene restituito
'   2)  se si passa "" nel codice fiscale del paziente viene generato un timeout
'   3)  se si passa "0000000000000000", codice fiscale che non esiste, la risposta contiene PDF CDA vuoti
'       Bisognerebbe quindi evitare di rifare troppo spesso la chiamata per un paziente che non ha il PatientSummary
'   4)  se si passa un codice fiscale di un paziente che non esiste la risposta contiene PDF CDA vuoti (bisognerebbe evitare quindi di fare sempre la chiamata)
'   5)  Nel SAC esistono pazienti con codice fiscale "0000000000000000": per tali codici non eseguo l'invocazione al web service
'
'**********************************************************************************************************************************************************************
Public Class PatientSummaryUtil

    ''' <summary>
    ''' La funzione da invocare tramite AJAX
    ''' </summary>
    ''' <param name="RichiedenteCodiceFiscale"></param>
    ''' <param name="RichiedenteCognome"></param>
    ''' <param name="RichiedenteNome"></param>
    ''' <param name="PazienteCodiceFiscale"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetPatientSummary(ByVal RichiedenteCodiceFiscale As String, ByVal RichiedenteCognome As String, ByVal RichiedenteNome As String, ByVal PazienteCodiceFiscale As String) As WcfPatientSummary.Risposta
        Using oPatSumProxy As New WcfPatientSummary.SOLEWcfBtDataAccessPatientSummaryClient
            If oPatSumProxy Is Nothing Then
                Throw New Exception("Errore: il Web Service " & oPatSumProxy.GetType.Namespace & "." & oPatSumProxy.GetType.Namespace & " è nothing.")
            End If
            Net.ServicePointManager.ServerCertificateValidationCallback = DirectCast(System.Delegate.Combine(Net.ServicePointManager.ServerCertificateValidationCallback, New Net.Security.RemoteCertificateValidationCallback(AddressOf RemoteCertificateValidate)), Net.Security.RemoteCertificateValidationCallback)
            '
            ' Imposto le credenziali
            '
            Dim sUser As String = My.Settings.WsPatientSummaryUser
            Dim sPassword As String = My.Settings.WsPatientSummaryPassword
            Call Utility.SetWCFCredentials(oPatSumProxy.ChannelFactory.Endpoint.Binding, oPatSumProxy.ClientCredentials, sUser, sPassword)
            '
            ' Popolo i dati della richiesta
            '
            Dim PaS_Req As WcfPatientSummary.Richiesta = CreaRichiesta(RichiedenteCodiceFiscale, RichiedenteCognome, RichiedenteNome, "MS", PazienteCodiceFiscale)
            '
            ' Invocazione
            '
            Return oPatSumProxy.OttieniPaS(PaS_Req)
        End Using
        Return Nothing
    End Function

    ''' <summary>
    ''' Questa chiama la SP per vedere se il patient summary è valido (potrei mettere in sessione la DataTable)
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetStato(IdPaziente As Guid) As PazientiDataset.FevsPazientiPatientSummaryStatoDataTable
        'QUERY SU  DB
        Using oData As New Pazienti
            Using dt As PazientiDataset.FevsPazientiPatientSummaryStatoDataTable = oData.GetPatientSummaryStato(IdPaziente)
                If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
                    Return dt
                End If
            End Using
        End Using
        Return Nothing
    End Function

    ''' <summary>
    ''' Salvataggio del patient summary
    ''' </summary>
    ''' <remarks>Se errore scrive nell'event viever</remarks>
    Public Shared Sub Aggiorna(ByVal IdPaziente As Guid, Pdf As Byte(), Errore As String)
        'QUERY SU DB
        Try
            Using oData As New Pazienti
                oData.PatientSummaryAggiorna(IdPaziente, Pdf, Errore)
            End Using
        Catch ex As Exception
            Logging.WriteError(ex, String.Format("Durante il salvataggio del Patient Summary del paziente {0}", IdPaziente))
        End Try
    End Sub

    ''' <summary>
    ''' Compone la stringa con l'errore presente nella risposta del web service
    ''' </summary>
    ''' <param name="oRisposta"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetErrore(oRisposta As WcfPatientSummary.Risposta) As String
        Dim sErrMsg As String = String.Empty
        If (Not oRisposta Is Nothing) AndAlso (Not oRisposta.Esito Is Nothing) Then
            Dim SEP As String = vbCrLf
            sErrMsg = sErrMsg & "Errore Esito:" & SEP
            sErrMsg = sErrMsg & String.Format("Codice={0}, Descrizione={1}", oRisposta.Esito.Codice, oRisposta.Esito.Descrizione) & SEP
            sErrMsg = sErrMsg & String.Format("CodiceErroreApplicazione={0}, DescrizioneErroreApplicazione={1}", oRisposta.Esito.CodiceErroreApplicazione, oRisposta.Esito.DescrizioneErroreApplicazione) & SEP
            sErrMsg = sErrMsg & String.Format("CodiceErroreHL7={0}, DescrizioneErroreHL7={1}", oRisposta.Esito.CodiceErroreHL7, oRisposta.Esito.DescrizioneErroreHL7) & SEP
            sErrMsg = sErrMsg & String.Format("CodiceSeverita={0}, DescrizioneSeverita={1}", oRisposta.Esito.CodiceSeverita, oRisposta.Esito.DescrizioneSeverita) & SEP
        End If
        Return sErrMsg
    End Function

    ''' <summary>
    ''' Funzione CallBack per forzare in modo custom la validazione di un certificato SSL (DA USARE SOLO IN SVILUPPO IN ATTESA DI SISTEMARE IL CERTIFICATO SU ENDOR)
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="cert"></param>
    ''' <param name="chain"></param>
    ''' <param name="sslPolicyErrors"></param>
    ''' <returns></returns>
    ''' <remarks>La uso forzare a TRUE la validazione</remarks>
    Private Shared Function RemoteCertificateValidate(ByVal sender As Object, ByVal cert As System.Security.Cryptography.X509Certificates.X509Certificate, ByVal chain As System.Security.Cryptography.X509Certificates.X509Chain, ByVal sslPolicyErrors As Net.Security.SslPolicyErrors) As Boolean
        'La uso forzare a TRUE la validazione del certificato SSL perchè in SVILUPPO non funziona
        Return True
    End Function

    ''' <summary>
    ''' Funzione per leggere il PDF per visualizzarlo
    ''' </summary>
    ''' <param name="IdPaziente"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function PatientSummaryPdf(ByVal IdPaziente As Guid) As Byte()
        'QUERY SU DB
        Dim oBytePdf As Byte() = Nothing
        Try
            Using oData As New Pazienti
                Dim odt As Data.PazientiDataset.FevsPazientiPatientSummaryOttieniDataTable = oData.PatientSummaryOttieni(IdPaziente)
                If Not odt Is Nothing AndAlso odt.Rows.Count > 0 Then
                    oBytePdf = odt(0).PatientSummaryPdf
                End If
            End Using
        Catch ex As Exception
            Logging.WriteError(ex, String.Format("Durante PatientSummaryPdf() del paziente {0}", IdPaziente))
        End Try
        '
        ' Restituisco
        '
        Return oBytePdf
    End Function


    ''' <summary>
    ''' Funzione che compone i dati della richiesta
    ''' </summary>
    ''' <param name="RichiedenteCodiceFiscale"></param>
    ''' <param name="RichiedenteCognome"></param>
    ''' <param name="RichiedenteNome"></param>
    ''' <param name="RichiedenteRuolo"></param>
    ''' <param name="PazienteCodiceFiscale"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Shared Function CreaRichiesta(ByVal RichiedenteCodiceFiscale As String, ByVal RichiedenteCognome As String, ByVal RichiedenteNome As String, ByVal RichiedenteRuolo As String, ByVal PazienteCodiceFiscale As String) As WcfPatientSummary.Richiesta
        Dim oReqPaz As New WcfPatientSummary.RichiestaPaziente
        Dim oReqRich As New WcfPatientSummary.RichiestaRichiedente
        Dim oReqDatiRet As New WcfPatientSummary.RichiestaDatiRestituiti
        '
        ' Costante a 1 record:
        '
        oReqDatiRet.MaxRecords = 1
        '
        ' Valorizzo i dati del medico
        '
        oReqRich.CodiceFiscale = RichiedenteCodiceFiscale
        oReqRich.Ruolo = RichiedenteRuolo
        oReqRich.Nome = RichiedenteNome
        oReqRich.Cognome = RichiedenteCognome
        '
        ' Valorizzo i dati del paziente
        '
        oReqPaz.CodiceFiscale = PazienteCodiceFiscale
        '
        ' Creo l'oggetto da passare al metodo di ricerca
        '
        Dim oReq As WcfPatientSummary.Richiesta = New WcfPatientSummary.Richiesta
        oReq.Paziente = oReqPaz
        oReq.Richiedente = oReqRich
        oReq.DatiRestituiti = oReqDatiRet
        '
        ' Restituisco
        '
        Return oReq
    End Function


End Class
