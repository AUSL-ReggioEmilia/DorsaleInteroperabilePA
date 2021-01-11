Module Utilities
    '
    ' Le azioni supportate dalla DAE
    '
    Public Const AZIONE_INSERIMENTO As Integer = 0
    Public Const AZIONE_AGGIORNAMENTO As Integer = 1
    Public Const AZIONE_CANCELLAZIONE As Integer = 2 'al momento non implementata

    Public Const ERRORE_APERTURA_CONNESSIONE As String = "Errore apertura connessione"

#Region "Extension"

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

    ''' <summary>
    ''' Legge il valore di un nodo xml e se non lo trova restituisce NullString
    ''' </summary>
    ''' <param name="oXElement">Il risultato della query xpath</param>
    ''' <param name="NullString">Il valore di default</param>
    ''' <returns></returns>
    <Runtime.CompilerServices.Extension>
    Public Function GetStringValue(ByVal oXElement As Xml.Linq.XElement, Optional NullString As String = Nothing) As String
        '
        ' Nel caso l'XElement non esista perchè il tal nodo manca (perchè non valorizzato) nell'XML di defaul restituisce NOTHING
        '
        Dim sRet As String = NullString
        If Not oXElement Is Nothing Then
            sRet = oXElement.Value
        End If
        '
        ' Restituisco
        '
        Return sRet
    End Function

#End Region


#Region "Funzioni Aspose"
    ''' <summary>
    ''' Valorizza il ContenutoHtml e il ContenutoText della nota anamnestica.
    ''' </summary>
    ''' <param name="Contenuto"></param>
    ''' <param name="MimeType"></param>
    ''' <param name="ContenutoHtml"></param>
    ''' <param name="ContenutoText"></param>
    Public Sub ConvertContenutoToHtmlText(ByVal Contenuto As Byte(), ByVal MimeType As String, ByRef ContenutoHtml As String, ByRef ContenutoText As String)
        MimeType = MimeType.ToUpper
        ContenutoHtml = Nothing
        ContenutoText = Nothing

        If MimeType = "TEXT/PLAIN" Then
            ContenutoText = System.Text.Encoding.UTF8.GetString(Contenuto)

            'TRASFORMO LA STRINGA IN HTML METTENDOLO DENTRO UN <P>
            ContenutoHtml = String.Format("<p>{0}</p>", System.Text.Encoding.UTF8.GetString(Contenuto))
        ElseIf MimeType = "TEXT/HTML" Then
            '
            'ATTENZIONE:
            'PER FUNZIONARE IL CONTENUTO PASSATO DEVE AVERE TUTTI I TAG DI UNA PAGINA HTML (<html>,<body>)
            '

            'CREO IL DOCUMENTO ASPOSE
            Dim doc As Aspose.Words.Document = AsposeDocCreate(Contenuto)

            'CONVERTO IN STRINGA L'HTML GENERATO DA DOC
            ContenutoText = System.Text.Encoding.UTF8.GetString(AsposeDocConvertToByteArray(doc, Aspose.Words.SaveFormat.Text))

            ContenutoHtml = System.Text.Encoding.UTF8.GetString(Contenuto)
        Else
            'CREO IL DOCUMENTO ASPOSE
            Dim doc As Aspose.Words.Document = AsposeDocCreate(Contenuto)

            'CONVERTO IN STRINGA L'HTML GENERATO DA DOC
            ContenutoText = System.Text.Encoding.UTF8.GetString(AsposeDocConvertToByteArray(doc, Aspose.Words.SaveFormat.Text))

            ContenutoHtml = System.Text.Encoding.UTF8.GetString(AsposeDocConvertToByteArray(doc, Aspose.Words.SaveFormat.Html))
        End If

    End Sub

    Private Function AsposeDocCreate(ByVal baArrayIn As Byte()) As Aspose.Words.Document
        Dim doc As Aspose.Words.Document = Nothing
        Using msFileOut As New IO.MemoryStream
            Using msFileIn As New IO.MemoryStream(baArrayIn)
                Dim license As New Aspose.Words.License()
                license.SetLicense("Aspose.Words.lic")
                doc = New Aspose.Words.Document(msFileIn)
            End Using
            '
            ' Restituisco
            '
            Return doc
        End Using
    End Function

    Private Function AsposeDocConvertToByteArray(ByVal oDoc As Aspose.Words.Document, format As Aspose.Words.SaveFormat) As Byte()
        Using msFileOut As New IO.MemoryStream

            Select Case format
                Case Aspose.Words.SaveFormat.Rtf
                    Dim oRtfSaveOptions As New Aspose.Words.Saving.RtfSaveOptions()
                    oRtfSaveOptions.SaveFormat = Aspose.Words.SaveFormat.Rtf

                    oDoc.Save(msFileOut, oRtfSaveOptions)

                Case Aspose.Words.SaveFormat.Text
                    Dim oTxtSaveOptions As New Aspose.Words.Saving.TxtSaveOptions()
                    oTxtSaveOptions.SaveFormat = Aspose.Words.SaveFormat.Text
                    oTxtSaveOptions.Encoding = New System.Text.UTF8Encoding(False) 'Serve per non fare emettere il BOM

                    oDoc.Save(msFileOut, oTxtSaveOptions)

                Case Aspose.Words.SaveFormat.Html
                    'QUESTO FORMATO NON E' ATTUALMENTE SUPPORTATO COME FORMATO DI OUTPUT
                    Dim oHtmlSaveOptions As New Aspose.Words.Saving.HtmlSaveOptions()
                    oHtmlSaveOptions.SaveFormat = Aspose.Words.SaveFormat.Html
                    oHtmlSaveOptions.Encoding = New System.Text.UTF8Encoding(False) 'Serve per non fare emettere il BOM

                    oDoc.Save(msFileOut, oHtmlSaveOptions)

                Case Else
                    Throw New Exception("AsposeDocConvertToByteArray(): Formato non supportato!")
            End Select
            '
            ' Restituisco
            '
            Return msFileOut.ToArray
        End Using
    End Function
#End Region


#Region "Funzioni per la descrizione dell'oggetto NotaAnamnestica"

    <Runtime.CompilerServices.Extension>
    Public Function Descrizione(oNotaAnamnesticaType As Types.NoteAnamnestiche.NotaAnamnesticaType) As String
        Dim sRet As String = String.Empty
        If Not oNotaAnamnesticaType Is Nothing Then
            sRet = String.Format("NotaAnamnestica: AziendaErogante={0}, SistemaErogante={1} IdEsterno={2}.",
                                 oNotaAnamnesticaType.AziendaErogante.NullSafeToString("NULL"),
                                 oNotaAnamnesticaType.SistemaErogante.NullSafeToString("NULL"),
                                 oNotaAnamnesticaType.IdEsterno.NullSafeToString("NULL"))
            If Not oNotaAnamnesticaType.Paziente Is Nothing Then
                sRet = String.Concat(sRet, vbCrLf, String.Format("Paziente: CodiceAnagrafica={0}, NomeAnagrafica={1}, Cognome={2}, Nome={3} CodiceFiscale={4}.",
                                                                 oNotaAnamnesticaType.Paziente.CodiceAnagrafica.NullSafeToString("NULL"),
                                                                 oNotaAnamnesticaType.Paziente.NomeAnagrafica.NullSafeToString("NULL"),
                                                                 oNotaAnamnesticaType.Paziente.Cognome.NullSafeToString("NULL"),
                                                                 oNotaAnamnesticaType.Paziente.Nome.NullSafeToString("NULL"),
                                                                 oNotaAnamnesticaType.Paziente.CodiceFiscale.NullSafeToString("NULL")))
            End If
        End If
        Return sRet
    End Function

#End Region

End Module
