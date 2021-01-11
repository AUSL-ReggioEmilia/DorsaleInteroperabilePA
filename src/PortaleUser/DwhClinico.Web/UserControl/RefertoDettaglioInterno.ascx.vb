Public Class RefertoDettaglioInterno
    Inherits System.Web.UI.UserControl

    ''' <summary>
    ''' Serve ad abilitare/disabilitare l'esecuzione del codice di visualizzaione dello user control
    ''' </summary>
    ''' <returns></returns>
    Public Property CancelSelect As Boolean
        '
        'Salva nel view state se non deve essere eseguito il codice.
        '
        Get
            Return CType(Me.ViewState("CancelSelect"), Boolean)
        End Get
        Set(value As Boolean)
            Me.ViewState("CancelSelect") = value
        End Set
    End Property

    Public Property TipoVisualizzazione As Utility.DettaglioReferto_TipoVisualizzaione
        Get
            Return CType(Me.ViewState("TipoVisualizzazione"), Utility.DettaglioReferto_TipoVisualizzaione)
        End Get
        Set(value As Utility.DettaglioReferto_TipoVisualizzaione)
            Me.ViewState("TipoVisualizzazione") = value
        End Set
    End Property

    ''' <summary>
    ''' Contiene l'xslt di testata
    ''' </summary>
    ''' <returns></returns>
    Public Property XsltTestata As String
        Get
            Return CType(Me.ViewState("XsltTestata"), String)
        End Get
        Set(value As String)
            Me.ViewState("XsltTestata") = value
        End Set
    End Property

    ''' <summary>
    ''' Contiene l'xslt di dettaglio/righe
    ''' </summary>
    ''' <returns></returns>
    Public Property XsltDettaglio As String
        Get
            Return CType(Me.ViewState("XsltDettaglio"), String)
        End Get
        Set(value As String)
            Me.ViewState("XsltDettaglio") = value
        End Set
    End Property

    ''' <summary>
    ''' Contiene l'xslt da usare con l'allegato XML
    ''' </summary>
    ''' <returns></returns>
    Public Property XsltAllegatoXml As String
        Get
            Return CType(Me.ViewState("XsltAllegatoXml"), String)
        End Get
        Set(value As String)
            Me.ViewState("XsltAllegatoXml") = value
        End Set
    End Property

    Public Property NomeFileAllegatoXml As String
        Get
            Return CType(Me.ViewState("NomeFileAllegatoXml"), String)
        End Get
        Set(value As String)
            Me.ViewState("NomeFileAllegatoXml") = value
        End Set
    End Property


    ''' <summary>
    ''' Indica se visualizzare il link all'allegato PDF PRINCIPALE
    ''' </summary>
    ''' <returns></returns>
    Public Property ShowLinkDocumentoPdf As String
        Get
            Return CType(Me.ViewState("ShowLinkDocumentoPdf"), String)
        End Get
        Set(value As String)
            Me.ViewState("ShowLinkDocumentoPdf") = value
        End Set
    End Property

    ''' <summary>
    ''' Indica se visualizzare anche i dati dell'allegato RTF
    ''' </summary>
    ''' <returns></returns>
    Public Property ShowAllegatoRTF As Boolean
        Get
            Return CType(Me.ViewState("ShowAllegatoRTF"), Boolean)
        End Get
        Set(value As Boolean)
            Me.ViewState("ShowAllegatoRTF") = value
        End Set
    End Property

    ''' <summary>
    ''' La classe che rappresenta il dettaglio del referto WS3/WCF
    ''' </summary>
    ''' <returns></returns>
    Public Property DettaglioReferto As WcfDwhClinico.RefertoType
        '
        'Salva nel view state l'Id del referto
        '
        Get
            Return CType(Me.ViewState("DettaglioReferto"), WcfDwhClinico.RefertoType)
        End Get
        Set(value As WcfDwhClinico.RefertoType)
            Me.ViewState("DettaglioReferto") = value
        End Set
    End Property

    Public Property UrlContent As String
        '
        'Property che salva nel view state l'url a visualizzazioni.
        '
        Get
            Return CType(Me.ViewState("UrlContent"), String)
        End Get
        Set(value As String)
            Me.ViewState("UrlContent") = value
        End Set
    End Property

    Public Property IsAccessoDiretto As Boolean
        '
        'Salva nel view state se siamo nell'accesso diretto.
        '
        Get
            Return CType(Me.ViewState("IsAccessoDiretto"), Boolean)
        End Get
        Set(value As Boolean)
            Me.ViewState("IsAccessoDiretto") = value
        End Set
    End Property


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim sXml As String = String.Empty
        Try

            If Not Me.CancelSelect Then

                If Not (TipoVisualizzazione = Utility.DettaglioReferto_TipoVisualizzaione.InternaWs2 OrElse TipoVisualizzazione = Utility.DettaglioReferto_TipoVisualizzaione.InternaWs3) Then
                    Dim sErrMsg As String = String.Format("Il tipo di visualizzazizone deve essere {0}, {1}.", Utility.DettaglioReferto_TipoVisualizzaione.InternaWs2.ToString, Utility.DettaglioReferto_TipoVisualizzaione.InternaWs3.ToString)
                    Throw New Exception(sErrMsg)
                End If

                If DettaglioReferto Is Nothing Then
                    Throw New Exception("Il dettaglio del referto è nothing.")
                End If
                '
                ' Nascondo tutto
                '
                divContainerIframe.Visible = False
                divContainerTrasformation.Visible = False
                '
                ' Se UrlContent è valorizzato significa che è stato cliccato il link di un allegato sul dettaglio del dettaglio del referto (allegato di di qualsiasi tipo)
                '
                If Not String.IsNullOrEmpty(UrlContent) Then
                    '
                    ' Popolo quindi l'iframe
                    '
                    divContainerIframe.Visible = True
                    IframeMain.Attributes.Add("src", Me.UrlContent)
                    LinkNoIframeMain.HRef = Me.UrlContent
                    'FONDAMENTALE
                    Exit Sub
                End If

                '
                ' Se sono qui allora UrlContent è vuoto: allora devo visualizzare il dettaglio del referto, quindi eseguo le varie trasformazioni
                '
                divContainerTrasformation.Visible = True
                '
                ' Se non valorizzato UrlContent significa che devo mostrare il dettaglio ed eseguire le trasformazioni
                '
                If TipoVisualizzazione = Utility.DettaglioReferto_TipoVisualizzaione.InternaWs2 Then
                    '
                    ' XSLT scritto per versione WS2 dell'XML
                    ' Converto DettaglioReferto nella versione WS2
                    ' 
                    Dim oRefertoWs2 As RefertoResult = DettaglioReferto.ToRefertoResult()
                    Dim oPazienteWs2 As PazienteResult = Nothing
                    '
                    ' TODO: verificare: la SezionePaziente sembra essere usato in sole due visualizzazioni ("SezionePaziente" in progetto "Visualizzazioni")
                    '   RefertoRadioterapia_Testata.xslt: per visualizzare il codice sanitario che ora è deprecato
                    '   Anatomia3.xslt: per visualizzare i dati anagrafici del paziente. Perchè nel referto non ci sono? Ho guardato anche in vecchi referti 
                    '   ASMN@SINFO RepartoErogante=AnatomiaPatologica e i dati del paziente negli attributi ci sono..
                    ' 
                    ' Invece di invocare il metodo WS3.PazientePerId() e trasformarlo nella versione WS2 PazienteResult, trasformo l'oggetto GeneralitaType contenuto nel dettaglio del referto WS3
                    '
                    If Not DettaglioReferto.Paziente Is Nothing Then
                        oPazienteWs2 = DettaglioReferto.Paziente.ToPazienteResult()
                    End If
                    ' Creo la classe di supporto RefertoResultWS2
                    Dim oAll As New Root(oRefertoWs2, oPazienteWs2)
                    ' Ricavo l'XML del dettaglio referto (serializzazione della classe)
                    sXml = GenericSerialize(Of Root).Serialize(oAll)

                ElseIf TipoVisualizzazione = Utility.DettaglioReferto_TipoVisualizzaione.InternaWs3 Then
                    '
                    ' XSLT scritto per versione WS3 dell'XML
                    ' Creo la classe di supporto RefertoResultWS3, come fatto pe WS2? Forse non ce ne è bisogno perchè i dati anagrafici del paziente sono presenti nel dettaglio del referto
                    ' 
                    ' Ricavo l'XML del dettaglio referto
                    ' Uso GenericDataContractSerializer perchè è un WCF
                    '
                    sXml = GenericDataContractSerializer.Serialize(DettaglioReferto)

                End If
                '
                ' Eseguo trasformazione di testata
                '
                divTestata.Visible = False
                If Not String.IsNullOrEmpty(XsltTestata) Then
                    divTestata.InnerHtml = Utility.ExecXsltTransformation(XsltTestata, Nothing, sXml)
                    divTestata.Visible = True
                End If
                '
                ' Creo un link al documento PDF
                '
                lnkDocumentoPdf.Visible = False
                If ShowLinkDocumentoPdf Then
                    ' Cerco il PDF Principale e se lo trovo creo il link
                    Dim sIdAllegatoPdf As String = Utility.GetIdAllegatoPdfPrincipale(DettaglioReferto.Allegati)
                    If String.IsNullOrEmpty(sIdAllegatoPdf) Then
                        sIdAllegatoPdf = Utility.GetIdAllegatoPdf(DettaglioReferto.Allegati)
                    End If
                    'Call Utility.BuildLinkAllegato(lnkDocumentoPdf, sIdAllegatoPdf, "_blank")
                    Call Utility.BuildLinkAllegato(lnkDocumentoPdf, sIdAllegatoPdf)
                End If
                '
                ' Eseguo trasformazione di dettaglio
                '
                divDettaglio.Visible = False
                If Not String.IsNullOrEmpty(XsltDettaglio) Then
                    divDettaglio.InnerHtml = Utility.ExecXsltTransformation(XsltDettaglio, Nothing, sXml)
                    divDettaglio.Visible = True
                End If

                '
                ' Verificare SEMPRE se il campo Referto è RTF: in tal caso lo leggo e lo converto in HTML e lo visualizzo
                ' Un documento RTF inizia con "{\rtf"
                ' 
                divRefertoFromRTFMain.Visible = False
                Dim bIsRefertoRTF As Boolean = Utility.IsTextRtf(DettaglioReferto.TestoReferto)
                If bIsRefertoRTF Then
                    ' Leggo l'attributo Referto, lo converto in HTML e lo visualizzo.
                    lbldivRefertoFromRTF_Titolo.Text = "Referto:"
                    divRefertoFromRTF.InnerHtml = Utility.GetHtmlFromRtf(DettaglioReferto.TestoReferto)
                    divRefertoFromRTFMain.Visible = True
                End If

                '
                ' Eseguo trasformazione usando XSL per l'allegato XML
                '
                divFromAllegatoXml.Visible = False
                If Not String.IsNullOrEmpty(XsltAllegatoXml) Then
                    If Not String.IsNullOrEmpty(NomeFileAllegatoXml) Then
                        Dim oByteXml As Byte() = Utility.GetByteAllegatoXml_2(DettaglioReferto.Allegati, NomeFileAllegatoXml)
                        If Not oByteXml Is Nothing Then
                            Dim sXMLDebug As String = Nothing
#If DEBUG Then
                            sXMLDebug = System.Text.Encoding.UTF8.GetString(oByteXml)
#End If
                            ' Eseguo la trasformazione a partire dai byte dell'allegato XML
                            Dim sHtml As String = Utility.ExecXsltTransformation(XsltAllegatoXml, Nothing, oByteXml)
                            '
                            ' Solo per il CDA di METAFORA aggiungo i link alle prestazioni
                            '
                            If NomeFileAllegatoXml.ToUpper.Contains("CDA") Then
                                sHtml = Utility.METAFORA_BuildLinkMatricePrestazioni(sHtml, sXml, DettaglioReferto.IdPaziente, IsAccessoDiretto)
                            End If
                            '
                            ' Visualizzo
                            '
                            divFromAllegatoXml.InnerHtml = sHtml
                            divFromAllegatoXml.Visible = True
                        End If
                    End If

                    'PRIMA VERSIONE
                    '' Cerco l'allegato XML: prima provo allegato XML CDA di METAFORA poi un generico XML
                    'Dim oByteXml As Byte() = Utility.GetByteXmlCda(DettaglioReferto.Allegati)
                    'If oByteXml Is Nothing Then
                    '    oByteXml = Utility.GetByteAllegatoXml(DettaglioReferto.Allegati)
                    'End If
                    'If Not oByteXml Is Nothing Then
                    '    ' Eseguo la trasformazione a partire dai byte dell'allegato XML
                    '    divFromAllegatoXml.InnerHtml = Utility.ExecXsltTransformation(XsltAllegatoXml, Nothing, oByteXml)
                    '    divFromAllegatoXml.Visible = True
                    'End If
                End If

                '
                ' Se devo MOSTRARE il contenuto dell'allegato RTF 
                '
                divRefertoFromAllegatoRTFMain.Visible = False
                If ShowAllegatoRTF Then
                    ' Cerco l'allegato RTF
                    Dim oByteRTF As Byte() = Utility.GetByteAllegatoRTF(DettaglioReferto.Allegati)
                    ' Lo converto in HTML con ASPOSE.WORD e lo visualizzo
                    If Not oByteRTF Is Nothing Then
                        Dim oAspose As New AsposeUtil
                        Dim oDoc As Aspose.Words.Document = oAspose.DocumentCreate(oByteRTF)
                        oAspose.ExportImageAsBase64 = True ' Questo fa si che NON sia necessaria definire una folder in cui ASPOSE scrive le immagini
                        Dim bArrayHtml As Byte() = oAspose.DocumentConvertToByteArray(oDoc, Aspose.Words.SaveFormat.Html)
                        divRefertoFromAllegatoRTF.InnerHtml = System.Text.Encoding.UTF8.GetString(bArrayHtml)
                        lbldivRefertoFromAllegatoRTF_Titolo.Text = "Dettaglio Referto:"
                        divRefertoFromAllegatoRTFMain.Visible = True
                    Else
                        ' Visualizzo i dati presenti nell'attributo TESTO
                        Dim sTesto As String = Utility.GetAttributoValue("TESTO", DettaglioReferto.Attributi)
                        If Not String.IsNullOrEmpty(sTesto) Then
                            divRefertoFromAllegatoRTF.InnerHtml = sTesto
                            lbldivRefertoFromAllegatoRTF_Titolo.Text = "Dettaglio Referto:"
                            divRefertoFromAllegatoRTFMain.Visible = True
                        End If
                    End If
                End If
            End If
        Catch ex As Exception
            Throw
        End Try
    End Sub

End Class