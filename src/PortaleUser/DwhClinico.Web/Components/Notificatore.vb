Imports DwhClinico.Data

''' <summary>
''' Classe utilizzata per notificare via email gli utenti.
''' </summary>
Public Class Notificatore

    'PERCORSO FISICO DEI MODELLI XSLT
    Const XSLT_NOTIFICA_MESSAGGIO As String = "~\Xslt\EmailLinkPerAccessoDiretto.xslt"

    ''' <summary>
    ''' Ottieni il percorso fisico dell'xslt.
    ''' </summary>
    ''' <param name="XsltFileName"></param>
    ''' <returns></returns>
    Private Function GetXsltFullPath(XsltFileName As String) As String

        Return HttpContext.Current.Server.MapPath(XsltFileName)

    End Function

    ''' <summary>
    ''' NOTIFICA VIA EMAIL L'EVENTO DI CARICAMENTO DI UN MESSAGGIO
    ''' </summary>	
    Public Sub CaricamentoMessaggio(ByVal sMittente As String, dtNotifica As DataTable, listaDestinatari As String(), ByVal oggettoMail As String)

        Dim oMsg As New EmailMessage

        If dtNotifica Is Nothing Then
            Throw New ArgumentNullException("dtNotifica", "Nessun dato restituito")
        End If

        '
        'Ottiene sempre la prima row
        '
        Dim drNotifica = dtNotifica(0)

        'DEFINISCO IL MITTENTE
        'oMsg.MailFrom = My.Settings.MittenteMail 'DwhClinico@progel.it. in prod "DwhUser@asmn.re.it"
        oMsg.MailFrom = sMittente

        ' XML DA PASSARE ALLA TRASFORMAZIONE XSLT PER CREARE IL CORPO DELLA MAIL
        oMsg.MailXMLData = CreateXMLDataMessaggio(dtNotifica)
        oMsg.MailSubject = oggettoMail
        oMsg.MailXsltFilePath = GetXsltFullPath(XSLT_NOTIFICA_MESSAGGIO)

        '
        'Esegue la trasformazione xslt.
        '
        oMsg.ApplicaTrasformazioneXslt()

        '
        'Invio lo stesso messaggio a tutti i destinatari
        '
        For Each sDestinatario In listaDestinatari
            '
            'Invio solo se sMedicoEmail è valorizzato.
            '
            If Not String.IsNullOrEmpty(sDestinatario) Then
                oMsg.MailTo = sDestinatario.Trim()
                oMsg.Accoda()
            End If
        Next
    End Sub

    ''' <summary>
    ''' Crea un XML con tutti i dati da utilizzare per qualsiasi trasformazione XSLT 
    ''' </summary>	
    Private Function CreateXMLDataMessaggio(dtNotifica As DataTable) As String
        'PRODUCE UN DOCUMENTO DEL TIPO:

        Dim oStream As IO.StringWriter = Nothing
        Dim oXmlWriter As System.Xml.XmlTextWriter = Nothing
        Dim iStep As Integer = 0

        Try
            oStream = New IO.StringWriter
            oXmlWriter = New System.Xml.XmlTextWriter(oStream)

            oXmlWriter.Formatting = System.Xml.Formatting.Indented
            oXmlWriter.WriteStartElement("root")

            iStep = 1
            '
            ' Aggiungo i valori provenienti dal dataset della richiesta
            '
            For Each oCol As DataColumn In dtNotifica.Columns
                Dim sColName As String = oCol.ColumnName.ToLower
                Dim oColValue = dtNotifica(0).Item(oCol.Ordinal)
                If oColValue Is DBNull.Value Then
                    oColValue = String.Empty
                End If
                oXmlWriter.WriteElementString(sColName, oColValue.ToString())
            Next

            '
            ' Chiudo
            '
            iStep = 2
            oXmlWriter.WriteEndElement()
            oXmlWriter.Flush()
            oXmlWriter.Close()

            Return oStream.ToString

        Catch ex As Exception
            Throw New ApplicationException("Errore CreateXMLData Step:" & iStep.ToString, ex)
        Finally
            iStep = 3
            If Not oXmlWriter Is Nothing Then
                oXmlWriter.Close()
            End If
            If Not oStream Is Nothing Then
                oStream.Close()
            End If
        End Try
    End Function
End Class