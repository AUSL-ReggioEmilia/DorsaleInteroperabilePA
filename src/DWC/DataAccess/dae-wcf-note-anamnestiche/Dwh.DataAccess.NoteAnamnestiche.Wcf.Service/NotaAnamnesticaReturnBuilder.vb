'------------------------------------------------------------------------------
' Classe utilizzata per la costruzione dell'oggetto di ritorno della DAE
'------------------------------------------------------------------------------
' Accetta come parametri la nota anamnestica in input e l'XML restituito dalla 
' SP ExtNoteAnamnesticheAggiungi e restituisce l'oggetto NotaAnamnesticaReturnType
'------------------------------------------------------------------------------
Imports System.Xml
Imports System.Xml.Linq
Imports System.Xml.XPath

Public Class NotaAnamnesticaReturnBuilder
    Private IdEsterno As String
    Private Xml As String = String.Empty
    Private Azione As Integer = AZIONE_INSERIMENTO
    Private DataSequenza As Date

    Public Sub New(ByVal IdEsterno As String, ByVal DataSequenza As DateTime, ByVal Azione As Integer, ByVal Xml As String)
        Me.IdEsterno = IdEsterno
        Me.DataSequenza = DataSequenza
        Me.Azione = Azione
        Me.Xml = Xml
    End Sub

    Public Function BuildNotaAnamnesticaReturnType() As Types.NoteAnamnestiche.NotaAnamnesticaReturnType
        '
        ' Controllo se i dati sono presenti
        '
        If String.IsNullOrEmpty(Xml) Then
            Dim sErrMsg As String = String.Format("BuildNotaAnamnesticaReturnType: Parametro XML vuoto. IdEsterno={0}", IdEsterno)
            Throw New CustomException(sErrMsg, ErrorCodes.ErroreBuildingOutput)
        End If
        '
        ' Inizializzo il tipo da restituire
        '
        Dim oRet As New Types.NoteAnamnestiche.NotaAnamnesticaReturnType
        '
        '
        '
        Dim xmlRoot As XElement = XElement.Parse(Xml)
        '-----------------------------------------------------------------------------------------------------------------------
        ' ATTENZIONE: Per come è costruito l'XML non è necessario il namespace manager
        '   Dim namespaceManager As XmlNamespaceManager = New XmlNamespaceManager(New NameTable())
        '   namespaceManager.AddNamespace("ns0", "http://schemas.progel.it/SQL/Dwh/QueueNotaAnamnesticaOutput/1.0")
        '   Dim oXElement As XElement = xmlRoot.XPathSelectElement("ns0", namespaceManager)
        '-----------------------------------------------------------------------------------------------------------------------
        '
        ' Variabile temporanea per memorizzare il risultato stringa delle query xpath
        '
        Dim sValue As String
        '
        ' ATTENZIONE: L'extension GetStringValue() restituisce nothing se non trova il nodo
        '
        oRet.Id = xmlRoot.XPathSelectElement("Id").GetStringValue().ToUpper 'Id è OBBLIGATORIO quindi sempre valorizzato
        '
        ' DataSequenza  (date): lo prendo dal parametro del New()
        '
        oRet.DataSequenza = DataSequenza
        '
        ' Azione (Integer) 
        '
        oRet.Azione = Azione  'la prendo dal parametro  del New()
        '
        '
        '
        oRet.IdPaziente = xmlRoot.XPathSelectElement("IdPaziente").GetStringValue().ToUpper 'IdPaziente è OBBLIGATORIO quindi sempre valorizzato
        oRet.CodiceAnagraficaCentrale = xmlRoot.XPathSelectElement("CodiceAnagraficaCentrale").GetStringValue()
        oRet.NomeAnagraficaCentrale = xmlRoot.XPathSelectElement("NomeAnagraficaCentrale").GetStringValue()
        oRet.IdEsterno = xmlRoot.XPathSelectElement("IdEsterno").GetStringValue()
        '
        ' DataInserimento (datetime)
        '
        sValue = xmlRoot.XPathSelectElement("DataInserimento").GetStringValue()
        If Not String.IsNullOrEmpty(sValue) Then oRet.DataInserimento = CType(sValue, Date)
        '
        ' DataModifica (datetime)
        '
        sValue = xmlRoot.XPathSelectElement("DataModifica").GetStringValue()
        If Not String.IsNullOrEmpty(sValue) Then oRet.DataModifica = CType(sValue, Date)
        '
        ' StatoCodice (byte)
        '
        sValue = xmlRoot.XPathSelectElement("StatoCodice").GetStringValue()
        If Not String.IsNullOrEmpty(sValue) Then oRet.StatoCodice = CType(sValue, Byte)
        oRet.StatoDescrizione = xmlRoot.XPathSelectElement("StatoDescrizione").GetStringValue()
        '
        '
        '
        oRet.AziendaErogante = xmlRoot.XPathSelectElement("AziendaErogante").GetStringValue()
        oRet.SistemaErogante = xmlRoot.XPathSelectElement("SistemaErogante").GetStringValue()
        '
        ' DataNota (datetime)
        '
        sValue = xmlRoot.XPathSelectElement("DataNota").GetStringValue()
        If Not String.IsNullOrEmpty(sValue) Then oRet.DataNota = CType(sValue, Date)
        '
        ' DataFineValidita (datetime)
        '
        sValue = xmlRoot.XPathSelectElement("DataFineValidita").GetStringValue()
        If Not String.IsNullOrEmpty(sValue) Then oRet.DataFineValidita = CType(sValue, Date)
        '
        '
        '
        oRet.TipoCodice = xmlRoot.XPathSelectElement("TipoCodice").GetStringValue()
        oRet.TipoDescrizione = xmlRoot.XPathSelectElement("TipoDescrizione").GetStringValue()
        '
        ' Contenuto (byte()) : da Base64 a byte()
        '
        sValue = xmlRoot.XPathSelectElement("Contenuto").GetStringValue()
        If Not String.IsNullOrEmpty(sValue) Then oRet.Contenuto = System.Convert.FromBase64String(sValue)

        oRet.TipoContenuto = xmlRoot.XPathSelectElement("TipoContenuto").GetStringValue()
        oRet.ContenutoHtml = xmlRoot.XPathSelectElement("ContenutoHtml").GetStringValue()
        oRet.ContenutoText = xmlRoot.XPathSelectElement("ContenutoText").GetStringValue()
        '
        ' OGGETTO Attributi: Uso quelli popolati nella NotaAnamnestica
        ' Funziona perchè l'oggetto Attributi usato nell'oggetto di input è lo stesso di quello usato nell'oggetto di output
        ' oRet.Attributi = NotaAnamnesticaType.Attributi
        '
        oRet.Attributi = BuildAttributiType(xmlRoot)
        '
        ' Oggetto "Note" (tutte le note di un paziente): 
        '
        Dim oColNote As System.Collections.Generic.IEnumerable(Of System.Xml.Linq.XElement) = xmlRoot.XPathSelectElements("Note/Nota")
        If Not oColNote Is Nothing AndAlso oColNote.Count > 0 Then
            Dim oNoteType As New Types.NoteAnamnestiche.NoteType
            For Each oNota As XElement In oColNote
                Dim oNotaType As New Types.NoteAnamnestiche.NotaType
                '
                ' DataNota (DateTime)
                '
                sValue = oNota.XPathSelectElement("DataNota").GetStringValue()
                If Not String.IsNullOrEmpty(sValue) Then oNotaType.DataNota = CType(sValue, Date)
                '
                ' DataFineValidita (DateTime)
                '
                sValue = oNota.XPathSelectElement("DataFineValidita").GetStringValue()
                If Not String.IsNullOrEmpty(sValue) Then oNotaType.DataFineValidita = CType(sValue, Date)
                '
                ' Tutti campi stringa
                '
                oNotaType.AziendaErogante = oNota.XPathSelectElement("AziendaErogante").GetStringValue()
                oNotaType.SistemaErogante = oNota.XPathSelectElement("SistemaErogante").GetStringValue()
                oNotaType.TipoDescrizione = oNota.XPathSelectElement("TipoDescrizione").GetStringValue()
                oNotaType.ContenutoText = oNota.XPathSelectElement("ContenutoText").GetStringValue()
                '
                ' Aggiungo all'oggetto NoteType la nota corrente
                '
                oNoteType.Add(oNotaType)
            Next
            '
            ' Associo la lista delle note all'oggetto da restituire 
            '
            oRet.Note = oNoteType
        End If
        '
        ' Costruisco l'oggetto Paziente
        '
        Dim oXmlAnagrafica As XElement = xmlRoot.XPathSelectElement("Paziente/Anagrafica")
        oRet.Paziente = BuildPazienteReturnType(oXmlAnagrafica)
        '
        ' Restituisco
        '
        Return oRet
    End Function

    Private Function BuildPazienteReturnType(ByVal xmlAnagrafica As XElement) As Types.NoteAnamnestiche.PazienteReturnType
        'Questo è il nodo da Valorizzare
        Dim oAnag As New Types.NoteAnamnestiche.AnagraficaType
        '
        ' Variabile temporanea usata per memorizzare il risultato della XQuery
        '
        Dim sValue As String
        '
        '
        '
        oAnag.Id = xmlAnagrafica.XPathSelectElement("Id").GetStringValue().ToUpper() 'Id è OBBLIGATORIO quindi sempre valorizzato
        '
        ' DataModifica (datetime)
        '
        sValue = xmlAnagrafica.XPathSelectElement("DataModifica").GetStringValue() 'DataModifica è OBBLIGATORIO quindi sempre valorizzato
        If Not String.IsNullOrEmpty(sValue) Then oAnag.DataModifica = CType(sValue, Date)

        oAnag.AziendaErogante = xmlAnagrafica.XPathSelectElement("AziendaErogante").GetStringValue()
        oAnag.SistemaErogante = xmlAnagrafica.XPathSelectElement("SistemaErogante").GetStringValue()
        oAnag.RepartoErogante = xmlAnagrafica.XPathSelectElement("RepartoErogante").GetStringValue()
        oAnag.Cognome = xmlAnagrafica.XPathSelectElement("Cognome").GetStringValue()
        oAnag.Nome = xmlAnagrafica.XPathSelectElement("Nome").GetStringValue()
        oAnag.CodiceFiscale = xmlAnagrafica.XPathSelectElement("CodiceFiscale").GetStringValue()
        oAnag.CodiceSanitario = xmlAnagrafica.XPathSelectElement("CodiceSanitario").GetStringValue()
        '
        ' DataNascita (datetime)
        '
        sValue = xmlAnagrafica.XPathSelectElement("DataNascita").GetStringValue()
        If Not String.IsNullOrEmpty(sValue) Then oAnag.DataNascita = CType(sValue, Date)
        '
        '
        '
        oAnag.LuogoNascita = xmlAnagrafica.XPathSelectElement("LuogoNascita").GetStringValue()
        oAnag.Sesso = xmlAnagrafica.XPathSelectElement("Sesso").GetStringValue()
        oAnag.ComuneNascitaCodice = xmlAnagrafica.XPathSelectElement("ComuneNascitaCodice").GetStringValue()
        oAnag.NazionalitaCodice = xmlAnagrafica.XPathSelectElement("NazionalitaCodice").GetStringValue()
        oAnag.NazionalitaNome = xmlAnagrafica.XPathSelectElement("NazionalitaNome").GetStringValue()
        '
        '
        '
        oAnag.ResidenzaComuneCodice = xmlAnagrafica.XPathSelectElement("ResidenzaComuneCodice").GetStringValue()
        oAnag.ResidenzaComuneNome = xmlAnagrafica.XPathSelectElement("ResidenzaComuneNome").GetStringValue()
        oAnag.ResidenzaIndirizzo = xmlAnagrafica.XPathSelectElement("ResidenzaIndirizzo").GetStringValue()
        oAnag.ResidenzaLocalita = xmlAnagrafica.XPathSelectElement("ResidenzaLocalita").GetStringValue()
        oAnag.ResidenzaCAP = xmlAnagrafica.XPathSelectElement("ResidenzaCAP").GetStringValue()
        '
        ' ResidenzaDataDecorrenza (datetime)
        '
        sValue = xmlAnagrafica.XPathSelectElement("ResidenzaDataDecorrenza").GetStringValue()
        If Not String.IsNullOrEmpty(sValue) Then oAnag.ResidenzaDataDecorrenza = CType(sValue, Date)
        '
        '
        '
        oAnag.DomicilioComuneCodice = xmlAnagrafica.XPathSelectElement("DomicilioComuneCodice").GetStringValue()
        oAnag.DomicilioComuneNome = xmlAnagrafica.XPathSelectElement("DomicilioComuneNome").GetStringValue()
        oAnag.DomicilioIndirizzo = xmlAnagrafica.XPathSelectElement("DomicilioIndirizzo").GetStringValue()
        oAnag.DomicilioLocalita = xmlAnagrafica.XPathSelectElement("DomicilioLocalita").GetStringValue()
        oAnag.DomicilioCAP = xmlAnagrafica.XPathSelectElement("DomicilioCAP").GetStringValue()
        '
        ' DomicilioDataDecorrenza (datetime)
        '
        sValue = xmlAnagrafica.XPathSelectElement("DomicilioDataDecorrenza").GetStringValue()
        If Not String.IsNullOrEmpty(sValue) Then oAnag.DomicilioDataDecorrenza = CType(sValue, Date)
        ''
        ''
        ''
        oAnag.UslResidenzaCodice = xmlAnagrafica.XPathSelectElement("UslResidenzaCodice").GetStringValue()
        oAnag.UslResidenzaPosizioneAssistito = xmlAnagrafica.XPathSelectElement("UslResidenzaPosizioneAssistito").GetStringValue()
        oAnag.UslResidenzaRegioneCodice = xmlAnagrafica.XPathSelectElement("UslResidenzaRegioneCodice").GetStringValue()
        oAnag.UslResidenzaComuneCodice = xmlAnagrafica.XPathSelectElement("UslResidenzaComuneCodice").GetStringValue()
        '
        '
        '
        oAnag.UslAssistenzaCodice = xmlAnagrafica.XPathSelectElement("UslAssistenzaCodice").GetStringValue()
        oAnag.UslAssistenzaPosizioneAssistito = xmlAnagrafica.XPathSelectElement("UslAssistenzaPosizioneAssistito").GetStringValue()
        oAnag.UslAssistenzaRegioneCodice = xmlAnagrafica.XPathSelectElement("UslAssistenzaRegioneCodice").GetStringValue()
        oAnag.UslAssistenzaComuneCodice = xmlAnagrafica.XPathSelectElement("UslAssistenzaComuneCodice").GetStringValue()
        '
        '
        '
        oAnag.MedicoDiBaseCodiceFiscale = xmlAnagrafica.XPathSelectElement("MedicoDiBaseCodiceFiscale").GetStringValue()
        oAnag.MedicoDiBaseCognomeNome = xmlAnagrafica.XPathSelectElement("MedicoDiBaseCognomeNome").GetStringValue()
        oAnag.MedicoDiBaseDistretto = xmlAnagrafica.XPathSelectElement("MedicoDiBaseDistretto").GetStringValue()
        '
        ' Costruisco gli attributi
        '
        Dim oCollXElemAttributo As System.Collections.Generic.IEnumerable(Of System.Xml.Linq.XElement) = xmlAnagrafica.XPathSelectElements("Attributi/Attributo")
        If Not oCollXElemAttributo Is Nothing AndAlso oCollXElemAttributo.Count > 0 Then
            Dim oAttributi As New Types.NoteAnamnestiche.AttributiType
            For Each oXElemAttributo As System.Xml.Linq.XElement In oCollXElemAttributo
                Dim oXAttribute As XAttribute
                Dim oAttributo As New Types.NoteAnamnestiche.AttributoType
                '
                ' Leggo l'attributo Nome
                '
                oXAttribute = oXElemAttributo.Attribute("Nome")
                If Not oXAttribute Is Nothing Then oAttributo.Nome = oXAttribute.Value
                '
                ' Leggo l'attributo Cognome
                '
                oXAttribute = oXElemAttributo.Attribute("Valore")
                If Not oXAttribute Is Nothing Then oAttributo.Valore = oXAttribute.Value
                '
                ' Aggiungo alla lista degli attributi
                '
                oAttributi.Add(oAttributo)
            Next
            oAnag.Attributi = oAttributi
        End If
        '
        ' Creo nuovo oggetto da restituire
        '
        Dim oPazienteReturnType As New Types.NoteAnamnestiche.PazienteReturnType
        oPazienteReturnType.Anagrafica = oAnag
        Return oPazienteReturnType
    End Function

    Private Function BuildAttributiType(ByVal oXmlRoot As XElement) As Types.NoteAnamnestiche.AttributiType
        'Dim oXmlAttributi As XElement = xmlRoot.XPathSelectElement("Attributi")
        Dim oAttributiReturnType As New Types.NoteAnamnestiche.AttributiType
        '
        ' Costruisco gli attributi
        '
        Dim oCollXElemAttributo As System.Collections.Generic.IEnumerable(Of System.Xml.Linq.XElement) = oXmlRoot.XPathSelectElements("Attributi/Attributo")
        If Not oCollXElemAttributo Is Nothing AndAlso oCollXElemAttributo.Count > 0 Then
            Dim oAttributi As New Types.NoteAnamnestiche.AttributiType
            For Each oXElemAttributo As System.Xml.Linq.XElement In oCollXElemAttributo
                Dim oXAttribute As XAttribute
                Dim oAttributo As New Types.NoteAnamnestiche.AttributoType
                '
                ' Leggo l'attributo Nome
                '
                oXAttribute = oXElemAttributo.Attribute("Nome")
                If Not oXAttribute Is Nothing Then oAttributo.Nome = oXAttribute.Value
                '
                ' Leggo l'attributo Valore
                '
                oXAttribute = oXElemAttributo.Attribute("Valore")
                If Not oXAttribute Is Nothing Then oAttributo.Valore = oXAttribute.Value
                '
                ' Aggiungo alla lista degli attributi
                '
                oAttributi.Add(oAttributo)
            Next
            oAttributiReturnType = oAttributi
        End If
        '
        ' Restituisco
        '
        Return oAttributiReturnType

    End Function

End Class
