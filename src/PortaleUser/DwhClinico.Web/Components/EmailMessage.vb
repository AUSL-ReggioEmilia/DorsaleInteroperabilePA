Imports System.Xml
Imports System.IO
Imports System.Xml.XPath
Imports System.Xml.Xsl

''' <summary>
''' Classe di supporto per la generazione di messaggi email.
''' Questa classe non invia direttamente le email, bensì si limita a fornire un meccanismo per scrivere 
''' nella tabella EmailsNotify, dalla quale vengono lette periodicamente le informazioni dal servizio 
''' Progel.EmailSender che effettua l'invio vero e proprio. 
''' </summary>
Public Class EmailMessage

    ''' <summary>
    ''' Indirizzo del mittente dell'email
    ''' </summary>
    Public Property MailFrom As String

    ''' <summary>
    ''' Indirizzo destinatario dell'email: è possibile specificare più indirizzi destinatari separandoli da ';'.
    ''' </summary>
    Public Property MailTo As String

    ''' <summary>
    ''' Indirizzo/i per copia carbone; è possibile specificare più indirizzi separati da ';'.
    ''' </summary>
    Public Property MailCC As String

    ''' <summary>
    ''' Indirizzo/i per blind carbon copy; è possibile specificare più indirizzi separati da ';'.
    ''' </summary>
    Public Property MailBCC As String

    ''' <summary>
    ''' Oggetto del messaggio.
    ''' </summary>
    Public Property MailSubject As String

    ''' <summary>
    ''' Dati XML da trasformare tramite file XSLT.
    ''' </summary>
    Public Property MailXMLData As String

    ''' <summary>
    ''' Path al file XSLT per la trasformazione dell'XML.
    ''' </summary>
    Public Property MailXsltFilePath As String

    ''' <summary>
    ''' Corpo del messaggio in html.
    ''' </summary>
    Public Property MailHTMLBody As String


    ''' <summary>
    ''' Accoda il messaggio in tabella EmailsNotify, viene usato come corpo MailHTMLBody
    ''' </summary>
    ''' <returns>L'ID del record inserito</returns>
    Public Sub Accoda()
        Dim oEmail As New Data.Email
        oEmail.NotificheEmailInserisce(MailFrom, MailTo, MailCC, MailBCC, MailSubject, MailHTMLBody)
    End Sub

    ''' <summary>
    ''' Esegue la trasformazione del contenuto di MailXMLBody mediante il file XSLT specificato in MailXsltFilePath.
    '''  Il risultato HTML della trasformazione viene posto in MailHTMLBody
    ''' </summary>
    Public Sub ApplicaTrasformazioneXslt()
        If String.IsNullOrEmpty(MailXMLData) Then
            Throw New ArgumentNullException("Parametro mancante", "MailXMLData")
        End If
        If String.IsNullOrEmpty(MailXsltFilePath) Then
            Throw New ArgumentNullException("Parametro mancante", "MailXsltFilePath")
        End If

        '
        ' Carico il doc XML
        '
        Dim oStringReader As New StringReader(MailXMLData)
        Dim oDocXml As New XPathDocument(oStringReader)
        '
        ' Flusso di output HTML
        '
        Dim oStringWriter As New StringWriter
        Dim oTextWriter As New XmlTextWriter(oStringWriter)
        '
        ' Trasformo XML + XSLT in HTML
        '
        Dim oXslt As New XslCompiledTransform
        oXslt.Load(MailXsltFilePath)
        oXslt.Transform(oDocXml, Nothing, oTextWriter, Nothing)
        oTextWriter.Flush()
        '
        ' Salvo il risultato
        '
        MailHTMLBody = oStringWriter.ToString

        ' Pulizia
        oStringReader.Close()
        oTextWriter.Close()
        oStringWriter.Close()

    End Sub

End Class

