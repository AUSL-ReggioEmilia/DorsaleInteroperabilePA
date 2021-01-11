Imports System.Xml.Serialization
Imports System.Text

Public MustInherit Class SerializeResult(Of T)

    <CLSCompliant(False)>
    Public Shared Function Deserialize(ByVal XmlData As String) As T

        Try
            Using memStream As New IO.MemoryStream
                Dim oEnc As Encoding = Encoding.Default

                memStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
                memStream.Position = 0

                Dim oInstance As T

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
                oInstance = CType(oSerializer.Deserialize(memStream), T)

                Return oInstance
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

        End Try

    End Function

    <CLSCompliant(False)>
    Public Shared Function Serialize(ByVal oInstance As T) As String
        '
        ' Serializzo
        '
        Try
            Using memStream As New IO.MemoryStream

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
                oSerializer.Serialize(memStream, oInstance)

                Dim oEnc As Encoding = Encoding.Default
                Dim sXml As String = oEnc.GetString(memStream.ToArray())

                Return sXml
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)

        End Try

    End Function

    <CLSCompliant(False)>
    Public Shared Function Deserialize(ByVal InputStream As IO.Stream) As T

        Try
            Dim oInstance As T

            Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
            InputStream.Position = 0
            oInstance = CType(oSerializer.Deserialize(InputStream), T)

            Return oInstance

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

        End Try
    End Function

    <CLSCompliant(False)>
    Public Shared Sub Serialize(ByVal Instance As T, ByVal OutputStream As IO.Stream)
        '
        ' Serializzo
        '
        Try
            Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
            oSerializer.Serialize(OutputStream, Instance)
            OutputStream.Position = 0

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)

        End Try

    End Sub

    Public Function GetXml() As String
        '
        ' Serializzo
        '
        Try
            Using memStream As New IO.MemoryStream

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
                oSerializer.Serialize(memStream, Me)

                Dim oEnc As Encoding = Encoding.Default
                Dim sXml As String = oEnc.GetString(memStream.ToArray())

                Return sXml
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante GetXml()!; " & ex.Message, ex)

        End Try

    End Function

End Class


<System.Diagnostics.DebuggerStepThroughAttribute(),
 System.Xml.Serialization.XmlTypeAttribute(AnonymousType:=True, [Namespace]:="http://dwhClinico.org/dataResult/2"),
 System.Xml.Serialization.XmlRootAttribute([Namespace]:="http://dwhClinico.org/dataResult/2", IsNullable:=False)>
Public Class RefertoResult
    Inherits SerializeResult(Of RefertoResult)

    <System.Xml.Serialization.XmlElementAttribute("Referto")>
    Public Referto As RefertiDataSetReferto

End Class

'''<remarks/>
<System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "4.0.30319.1"),
 System.SerializableAttribute(),
 System.Diagnostics.DebuggerStepThroughAttribute(),
 System.ComponentModel.DesignerCategoryAttribute("code"),
 System.Xml.Serialization.XmlTypeAttribute(AnonymousType:=True, [Namespace]:="http://dwhClinico.org/dataResult/2")>
Partial Public Class RefertiDataSetReferto

    Private idField As String

    Private idPazienteField As String

    Private dataInserimentoField As Date

    Private dataModificaField As Date

    Private aziendaEroganteField As String

    Private sistemaEroganteField As String

    Private repartoEroganteField As String

    Private dataRefertoField As Date

    Private numeroRefertoField As String

    Private numeroNosologicoField As String

    Private numeroPrenotazioneField As String

    Private cognomeField As String

    Private nomeField As String

    Private sessoField As String

    Private codiceFiscaleField As String

    Private dataNascitaField As Date

    Private dataNascitaFieldSpecified As Boolean

    Private comuneNascitaField As String

    Private provinciaNascitaField As String

    Private comuneResidenzaField As String

    Private codiceSAUBField As String

    Private codiceSanitarioField As String

    Private repartoRichiedenteCodiceField As String

    Private repartoRichiedenteDescrField As String

    Private statoRichiestaCodiceField As String

    Private statoRichiestaDescrField As String

    Private tipoRichiestaCodiceField As String

    Private tipoRichiestaDescrField As String

    Private prioritaCodiceField As String

    Private prioritaDescrField As String

    Private refertoField As String

    Private medicoRefertanteCodiceField As String

    Private medicoRefertanteDescrField As String

    Private ruoloVisualizzazioneRepartoRichiedenteField As String

    Private ruoloVisualizzazioneSistemaEroganteField As String

    Private ruoliVisualizzazioneField As String

    Private dataEventoField As Date

    Private firmatoField As Boolean

    Private prestazioniField() As RefertiDataSetRefertoPrestazioni

    Private allegatiField() As RefertiDataSetRefertoAllegati

    Private refertoAttributiField() As RefertiDataSetRefertoRefertoAttributi

    '''<remarks/>
    Public Property Id() As String
        Get
            Return Me.idField
        End Get
        Set(value As String)
            Me.idField = value
        End Set
    End Property

    '''<remarks/>
    Public Property IdPaziente() As String
        Get
            Return Me.idPazienteField
        End Get
        Set(value As String)
            Me.idPazienteField = value
        End Set
    End Property

    '''<remarks/>
    Public Property DataInserimento() As Date
        Get
            Return Me.dataInserimentoField
        End Get
        Set(value As Date)
            Me.dataInserimentoField = value
        End Set
    End Property

    '''<remarks/>
    Public Property DataModifica() As Date
        Get
            Return Me.dataModificaField
        End Get
        Set(value As Date)
            Me.dataModificaField = value
        End Set
    End Property

    '''<remarks/>
    Public Property AziendaErogante() As String
        Get
            Return Me.aziendaEroganteField
        End Get
        Set(value As String)
            Me.aziendaEroganteField = value
        End Set
    End Property

    '''<remarks/>
    Public Property SistemaErogante() As String
        Get
            Return Me.sistemaEroganteField
        End Get
        Set(value As String)
            Me.sistemaEroganteField = value
        End Set
    End Property

    '''<remarks/>
    Public Property RepartoErogante() As String
        Get
            Return Me.repartoEroganteField
        End Get
        Set(value As String)
            Me.repartoEroganteField = value
        End Set
    End Property

    '''<remarks/>
    Public Property DataReferto() As Date
        Get
            Return Me.dataRefertoField
        End Get
        Set(value As Date)
            Me.dataRefertoField = value
        End Set
    End Property

    '''<remarks/>
    Public Property NumeroReferto() As String
        Get
            Return Me.numeroRefertoField
        End Get
        Set(value As String)
            Me.numeroRefertoField = value
        End Set
    End Property

    '''<remarks/>
    Public Property NumeroNosologico() As String
        Get
            Return Me.numeroNosologicoField
        End Get
        Set(value As String)
            Me.numeroNosologicoField = value
        End Set
    End Property

    '''<remarks/>
    Public Property NumeroPrenotazione() As String
        Get
            Return Me.numeroPrenotazioneField
        End Get
        Set(value As String)
            Me.numeroPrenotazioneField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Cognome() As String
        Get
            Return Me.cognomeField
        End Get
        Set(value As String)
            Me.cognomeField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Nome() As String
        Get
            Return Me.nomeField
        End Get
        Set(value As String)
            Me.nomeField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Sesso() As String
        Get
            Return Me.sessoField
        End Get
        Set(value As String)
            Me.sessoField = value
        End Set
    End Property

    '''<remarks/>
    Public Property CodiceFiscale() As String
        Get
            Return Me.codiceFiscaleField
        End Get
        Set(value As String)
            Me.codiceFiscaleField = value
        End Set
    End Property

    '''<remarks/>
    Public Property DataNascita() As Date
        Get
            Return Me.dataNascitaField
        End Get
        Set(value As Date)
            Me.dataNascitaField = value
        End Set
    End Property

    '''<remarks/>
    <System.Xml.Serialization.XmlIgnoreAttribute()>
    Public Property DataNascitaSpecified() As Boolean
        Get
            Return Me.dataNascitaFieldSpecified
        End Get
        Set(value As Boolean)
            Me.dataNascitaFieldSpecified = value
        End Set
    End Property

    '''<remarks/>
    Public Property ComuneNascita() As String
        Get
            Return Me.comuneNascitaField
        End Get
        Set(value As String)
            Me.comuneNascitaField = value
        End Set
    End Property

    '''<remarks/>
    Public Property ProvinciaNascita() As String
        Get
            Return Me.provinciaNascitaField
        End Get
        Set(value As String)
            Me.provinciaNascitaField = value
        End Set
    End Property

    '''<remarks/>
    Public Property ComuneResidenza() As String
        Get
            Return Me.comuneResidenzaField
        End Get
        Set(value As String)
            Me.comuneResidenzaField = value
        End Set
    End Property

    '''<remarks/>
    Public Property CodiceSAUB() As String
        Get
            Return Me.codiceSAUBField
        End Get
        Set(value As String)
            Me.codiceSAUBField = value
        End Set
    End Property

    '''<remarks/>
    Public Property CodiceSanitario() As String
        Get
            Return Me.codiceSanitarioField
        End Get
        Set(value As String)
            Me.codiceSanitarioField = value
        End Set
    End Property

    '''<remarks/>
    Public Property RepartoRichiedenteCodice() As String
        Get
            Return Me.repartoRichiedenteCodiceField
        End Get
        Set(value As String)
            Me.repartoRichiedenteCodiceField = value
        End Set
    End Property

    '''<remarks/>
    Public Property RepartoRichiedenteDescr() As String
        Get
            Return Me.repartoRichiedenteDescrField
        End Get
        Set(value As String)
            Me.repartoRichiedenteDescrField = value
        End Set
    End Property

    '''<remarks/>
    Public Property StatoRichiestaCodice() As String
        Get
            Return Me.statoRichiestaCodiceField
        End Get
        Set(value As String)
            Me.statoRichiestaCodiceField = value
        End Set
    End Property

    '''<remarks/>
    Public Property StatoRichiestaDescr() As String
        Get
            Return Me.statoRichiestaDescrField
        End Get
        Set(value As String)
            Me.statoRichiestaDescrField = value
        End Set
    End Property

    '''<remarks/>
    Public Property TipoRichiestaCodice() As String
        Get
            Return Me.tipoRichiestaCodiceField
        End Get
        Set(value As String)
            Me.tipoRichiestaCodiceField = value
        End Set
    End Property

    '''<remarks/>
    Public Property TipoRichiestaDescr() As String
        Get
            Return Me.tipoRichiestaDescrField
        End Get
        Set(value As String)
            Me.tipoRichiestaDescrField = value
        End Set
    End Property

    '''<remarks/>
    Public Property PrioritaCodice() As String
        Get
            Return Me.prioritaCodiceField
        End Get
        Set(value As String)
            Me.prioritaCodiceField = value
        End Set
    End Property

    '''<remarks/>
    Public Property PrioritaDescr() As String
        Get
            Return Me.prioritaDescrField
        End Get
        Set(value As String)
            Me.prioritaDescrField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Referto() As String
        Get
            Return Me.refertoField
        End Get
        Set(value As String)
            Me.refertoField = value
        End Set
    End Property

    '''<remarks/>
    Public Property MedicoRefertanteCodice() As String
        Get
            Return Me.medicoRefertanteCodiceField
        End Get
        Set(value As String)
            Me.medicoRefertanteCodiceField = value
        End Set
    End Property

    '''<remarks/>
    Public Property MedicoRefertanteDescr() As String
        Get
            Return Me.medicoRefertanteDescrField
        End Get
        Set(value As String)
            Me.medicoRefertanteDescrField = value
        End Set
    End Property

    '
    ' Da serializzare per compatibilità
    '
    '''<remarks/>
    Public Property RuoloVisualizzazioneRepartoRichiedente() As String
        Get
            Return Me.ruoloVisualizzazioneRepartoRichiedenteField
        End Get
        Set(value As String)
            Me.ruoloVisualizzazioneRepartoRichiedenteField = value
        End Set
    End Property

    '
    ' Da serializzare per compatibilità
    '
    '''<remarks/>
    Public Property RuoloVisualizzazioneSistemaErogante() As String
        Get
            Return Me.ruoloVisualizzazioneSistemaEroganteField
        End Get
        Set(value As String)
            Me.ruoloVisualizzazioneSistemaEroganteField = value
        End Set
    End Property


    '
    ' MODIFICA ETTORE: non serializzo in output il campo RuoliVisualizzazione
    '
    '''<remarks/>
    <System.Xml.Serialization.XmlIgnoreAttribute()>
    Public Property RuoliVisualizzazione() As String
        Get
            Return Me.ruoliVisualizzazioneField
        End Get
        Set(value As String)
            Me.ruoliVisualizzazioneField = value
        End Set
    End Property

    '''<remarks/>
    Public Property DataEvento() As Date
        Get
            Return Me.dataEventoField
        End Get
        Set(value As Date)
            Me.dataEventoField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Firmato() As Boolean
        Get
            Return Me.firmatoField
        End Get
        Set(value As Boolean)
            Me.firmatoField = value
        End Set
    End Property

    '''<remarks/>
    <System.Xml.Serialization.XmlElementAttribute("Prestazioni")>
    Public Property Prestazioni() As RefertiDataSetRefertoPrestazioni()
        Get
            Return Me.prestazioniField
        End Get
        Set(value As RefertiDataSetRefertoPrestazioni())
            Me.prestazioniField = value
        End Set
    End Property

    '''<remarks/>
    <System.Xml.Serialization.XmlElementAttribute("Allegati")>
    Public Property Allegati() As RefertiDataSetRefertoAllegati()
        Get
            Return Me.allegatiField
        End Get
        Set(value As RefertiDataSetRefertoAllegati())
            Me.allegatiField = value
        End Set
    End Property

    '''<remarks/>
    <System.Xml.Serialization.XmlElementAttribute("RefertoAttributi")>
    Public Property RefertoAttributi() As RefertiDataSetRefertoRefertoAttributi()
        Get
            Return Me.refertoAttributiField
        End Get
        Set(value As RefertiDataSetRefertoRefertoAttributi())
            Me.refertoAttributiField = value
        End Set
    End Property
End Class

'''<remarks/>
<System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "4.0.30319.1"),
 System.SerializableAttribute(),
 System.Diagnostics.DebuggerStepThroughAttribute(),
 System.ComponentModel.DesignerCategoryAttribute("code"),
 System.Xml.Serialization.XmlTypeAttribute(AnonymousType:=True, [Namespace]:="http://dwhClinico.org/dataResult/2")>
Partial Public Class RefertiDataSetRefertoPrestazioni

    Private idField As String

    Private idRefertiBaseField As String

    Private dataErogazioneField As Date

    Private dataErogazioneFieldSpecified As Boolean

    Private sezionePosizioneField As Integer

    Private sezionePosizioneFieldSpecified As Boolean

    Private sezioneCodiceField As String

    Private sezioneDescrizioneField As String

    Private prestazionePosizioneField As Integer

    Private prestazionePosizioneFieldSpecified As Boolean

    Private prestazioneCodiceField As String

    Private prestazioneDescrizioneField As String

    Private runningNumberField As Integer

    Private runningNumberFieldSpecified As Boolean

    Private gravitaCodiceField As String

    Private gravitaDescrizioneField As String

    Private risultatoField As String

    Private valoriRiferimentoField As String

    Private commentiField As String

    Private prestazioniAttributiField() As RefertiDataSetRefertoPrestazioniPrestazioniAttributi

    '''<remarks/>
    Public Property Id() As String
        Get
            Return Me.idField
        End Get
        Set(value As String)
            Me.idField = value
        End Set
    End Property

    '''<remarks/>
    Public Property IdRefertiBase() As String
        Get
            Return Me.idRefertiBaseField
        End Get
        Set(value As String)
            Me.idRefertiBaseField = value
        End Set
    End Property

    '''<remarks/>
    Public Property DataErogazione() As Date
        Get
            Return Me.dataErogazioneField
        End Get
        Set(value As Date)
            Me.dataErogazioneField = value
        End Set
    End Property

    '''<remarks/>
    <System.Xml.Serialization.XmlIgnoreAttribute()>
    Public Property DataErogazioneSpecified() As Boolean
        Get
            Return Me.dataErogazioneFieldSpecified
        End Get
        Set(value As Boolean)
            Me.dataErogazioneFieldSpecified = value
        End Set
    End Property

    '''<remarks/>
    Public Property SezionePosizione() As Integer
        Get
            Return Me.sezionePosizioneField
        End Get
        Set(value As Integer)
            Me.sezionePosizioneField = value
        End Set
    End Property

    '''<remarks/>
    <System.Xml.Serialization.XmlIgnoreAttribute()>
    Public Property SezionePosizioneSpecified() As Boolean
        Get
            Return Me.sezionePosizioneFieldSpecified
        End Get
        Set(value As Boolean)
            Me.sezionePosizioneFieldSpecified = value
        End Set
    End Property

    '''<remarks/>
    Public Property SezioneCodice() As String
        Get
            Return Me.sezioneCodiceField
        End Get
        Set(value As String)
            Me.sezioneCodiceField = value
        End Set
    End Property

    '''<remarks/>
    Public Property SezioneDescrizione() As String
        Get
            Return Me.sezioneDescrizioneField
        End Get
        Set(value As String)
            Me.sezioneDescrizioneField = value
        End Set
    End Property

    '''<remarks/>
    Public Property PrestazionePosizione() As Integer
        Get
            Return Me.prestazionePosizioneField
        End Get
        Set(value As Integer)
            Me.prestazionePosizioneField = value
        End Set
    End Property

    '''<remarks/>
    <System.Xml.Serialization.XmlIgnoreAttribute()>
    Public Property PrestazionePosizioneSpecified() As Boolean
        Get
            Return Me.prestazionePosizioneFieldSpecified
        End Get
        Set(value As Boolean)
            Me.prestazionePosizioneFieldSpecified = value
        End Set
    End Property

    '''<remarks/>
    Public Property PrestazioneCodice() As String
        Get
            Return Me.prestazioneCodiceField
        End Get
        Set(value As String)
            Me.prestazioneCodiceField = value
        End Set
    End Property

    '''<remarks/>
    Public Property PrestazioneDescrizione() As String
        Get
            Return Me.prestazioneDescrizioneField
        End Get
        Set(value As String)
            Me.prestazioneDescrizioneField = value
        End Set
    End Property

    '''<remarks/>
    Public Property RunningNumber() As Integer
        Get
            Return Me.runningNumberField
        End Get
        Set(value As Integer)
            Me.runningNumberField = value
        End Set
    End Property

    '''<remarks/>
    <System.Xml.Serialization.XmlIgnoreAttribute()>
    Public Property RunningNumberSpecified() As Boolean
        Get
            Return Me.runningNumberFieldSpecified
        End Get
        Set(value As Boolean)
            Me.runningNumberFieldSpecified = value
        End Set
    End Property

    '''<remarks/>
    Public Property GravitaCodice() As String
        Get
            Return Me.gravitaCodiceField
        End Get
        Set(value As String)
            Me.gravitaCodiceField = value
        End Set
    End Property

    '''<remarks/>
    Public Property GravitaDescrizione() As String
        Get
            Return Me.gravitaDescrizioneField
        End Get
        Set(value As String)
            Me.gravitaDescrizioneField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Risultato() As String
        Get
            Return Me.risultatoField
        End Get
        Set(value As String)
            Me.risultatoField = value
        End Set
    End Property

    '''<remarks/>
    Public Property ValoriRiferimento() As String
        Get
            Return Me.valoriRiferimentoField
        End Get
        Set(value As String)
            Me.valoriRiferimentoField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Commenti() As String
        Get
            Return Me.commentiField
        End Get
        Set(value As String)
            Me.commentiField = value
        End Set
    End Property

    '''<remarks/>
    <System.Xml.Serialization.XmlElementAttribute("PrestazioniAttributi")>
    Public Property PrestazioniAttributi() As RefertiDataSetRefertoPrestazioniPrestazioniAttributi()
        Get
            Return Me.prestazioniAttributiField
        End Get
        Set(value As RefertiDataSetRefertoPrestazioniPrestazioniAttributi())
            Me.prestazioniAttributiField = value
        End Set
    End Property
End Class

'''<remarks/>
<System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "4.0.30319.1"),
 System.SerializableAttribute(),
 System.Diagnostics.DebuggerStepThroughAttribute(),
 System.ComponentModel.DesignerCategoryAttribute("code"),
 System.Xml.Serialization.XmlTypeAttribute(AnonymousType:=True, [Namespace]:="http://dwhClinico.org/dataResult/2")>
Partial Public Class RefertiDataSetRefertoPrestazioniPrestazioniAttributi

    Private idPrestazioniBaseField As String

    Private nomeField As String

    Private valoreField As Object

    '''<remarks/>
    Public Property IdPrestazioniBase() As String
        Get
            Return Me.idPrestazioniBaseField
        End Get
        Set(value As String)
            Me.idPrestazioniBaseField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Nome() As String
        Get
            Return Me.nomeField
        End Get
        Set(value As String)
            Me.nomeField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Valore() As Object
        Get
            Return Me.valoreField
        End Get
        Set(value As Object)
            Me.valoreField = value
        End Set
    End Property
End Class

'''<remarks/>
<System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "4.0.30319.1"),
 System.SerializableAttribute(),
 System.Diagnostics.DebuggerStepThroughAttribute(),
 System.ComponentModel.DesignerCategoryAttribute("code"),
 System.Xml.Serialization.XmlTypeAttribute(AnonymousType:=True, [Namespace]:="http://dwhClinico.org/dataResult/2")>
Partial Public Class RefertiDataSetRefertoAllegati

    Private idField As String

    Private idRefertiBaseField As String

    Private dataFileField As Date

    Private dataFileFieldSpecified As Boolean

    Private mimeTypeField As String

    Private mimeDataField() As Byte

    Private nomeFileField As String

    Private descrizioneField As String

    Private posizioneField As Integer

    Private posizioneFieldSpecified As Boolean

    Private statoCodiceField As String

    Private statoDescrizioneField As String

    Private allegatiAttributiField() As RefertiDataSetRefertoAllegatiAllegatiAttributi

    '''<remarks/>
    Public Property Id() As String
        Get
            Return Me.idField
        End Get
        Set(value As String)
            Me.idField = value
        End Set
    End Property

    '''<remarks/>
    Public Property IdRefertiBase() As String
        Get
            Return Me.idRefertiBaseField
        End Get
        Set(value As String)
            Me.idRefertiBaseField = value
        End Set
    End Property

    '''<remarks/>
    Public Property DataFile() As Date
        Get
            Return Me.dataFileField
        End Get
        Set(value As Date)
            Me.dataFileField = value
        End Set
    End Property

    '''<remarks/>
    <System.Xml.Serialization.XmlIgnoreAttribute()>
    Public Property DataFileSpecified() As Boolean
        Get
            Return Me.dataFileFieldSpecified
        End Get
        Set(value As Boolean)
            Me.dataFileFieldSpecified = value
        End Set
    End Property

    '''<remarks/>
    Public Property MimeType() As String
        Get
            Return Me.mimeTypeField
        End Get
        Set(value As String)
            Me.mimeTypeField = value
        End Set
    End Property

    '''<remarks/>
    <System.Xml.Serialization.XmlElementAttribute(DataType:="base64Binary")>
    Public Property MimeData() As Byte()
        Get
            Return Me.mimeDataField
        End Get
        Set(value As Byte())
            Me.mimeDataField = value
        End Set
    End Property

    '''<remarks/>
    Public Property NomeFile() As String
        Get
            Return Me.nomeFileField
        End Get
        Set(value As String)
            Me.nomeFileField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Descrizione() As String
        Get
            Return Me.descrizioneField
        End Get
        Set(value As String)
            Me.descrizioneField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Posizione() As Integer
        Get
            Return Me.posizioneField
        End Get
        Set(value As Integer)
            Me.posizioneField = value
        End Set
    End Property

    '''<remarks/>
    <System.Xml.Serialization.XmlIgnoreAttribute()>
    Public Property PosizioneSpecified() As Boolean
        Get
            Return Me.posizioneFieldSpecified
        End Get
        Set(value As Boolean)
            Me.posizioneFieldSpecified = value
        End Set
    End Property

    '''<remarks/>
    Public Property StatoCodice() As String
        Get
            Return Me.statoCodiceField
        End Get
        Set(value As String)
            Me.statoCodiceField = value
        End Set
    End Property

    '''<remarks/>
    Public Property StatoDescrizione() As String
        Get
            Return Me.statoDescrizioneField
        End Get
        Set(value As String)
            Me.statoDescrizioneField = value
        End Set
    End Property

    '''<remarks/>
    <System.Xml.Serialization.XmlElementAttribute("AllegatiAttributi")>
    Public Property AllegatiAttributi() As RefertiDataSetRefertoAllegatiAllegatiAttributi()
        Get
            Return Me.allegatiAttributiField
        End Get
        Set(value As RefertiDataSetRefertoAllegatiAllegatiAttributi())
            Me.allegatiAttributiField = value
        End Set
    End Property
End Class

'''<remarks/>
<System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "4.0.30319.1"),
 System.SerializableAttribute(),
 System.Diagnostics.DebuggerStepThroughAttribute(),
 System.ComponentModel.DesignerCategoryAttribute("code"),
 System.Xml.Serialization.XmlTypeAttribute(AnonymousType:=True, [Namespace]:="http://dwhClinico.org/dataResult/2")>
Partial Public Class RefertiDataSetRefertoAllegatiAllegatiAttributi

    Private idAllegatiBaseField As String

    Private nomeField As String

    Private valoreField As Object

    '''<remarks/>
    Public Property IdAllegatiBase() As String
        Get
            Return Me.idAllegatiBaseField
        End Get
        Set(value As String)
            Me.idAllegatiBaseField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Nome() As String
        Get
            Return Me.nomeField
        End Get
        Set(value As String)
            Me.nomeField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Valore() As Object
        Get
            Return Me.valoreField
        End Get
        Set(value As Object)
            Me.valoreField = value
        End Set
    End Property
End Class

'''<remarks/>
<System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "4.0.30319.1"),
 System.SerializableAttribute(),
 System.Diagnostics.DebuggerStepThroughAttribute(),
 System.ComponentModel.DesignerCategoryAttribute("code"),
 System.Xml.Serialization.XmlTypeAttribute(AnonymousType:=True, [Namespace]:="http://dwhClinico.org/dataResult/2")>
Partial Public Class RefertiDataSetRefertoRefertoAttributi

    Private idRefertiBaseField As String

    Private nomeField As String

    Private valoreField As Object

    '''<remarks/>
    Public Property IdRefertiBase() As String
        Get
            Return Me.idRefertiBaseField
        End Get
        Set(value As String)
            Me.idRefertiBaseField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Nome() As String
        Get
            Return Me.nomeField
        End Get
        Set(value As String)
            Me.nomeField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Valore() As Object
        Get
            Return Me.valoreField
        End Get
        Set(value As Object)
            Me.valoreField = value
        End Set
    End Property
End Class


'---------------------------------------------------------------
' Parte paziente
'---------------------------------------------------------------
<System.Diagnostics.DebuggerStepThroughAttribute(),
 System.Xml.Serialization.XmlTypeAttribute(AnonymousType:=True, [Namespace]:="http://dwhClinico.org/dataResult/2"),
 System.Xml.Serialization.XmlRootAttribute([Namespace]:="http://dwhClinico.org/dataResult/2", IsNullable:=False)>
Public Class PazienteResult
    Inherits SerializeResult(Of PazienteResult)

    <System.Xml.Serialization.XmlElementAttribute("Paziente")>
    Public Paziente As PazientiDataSetPaziente

End Class


'''<remarks/>
<System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "4.0.30319.1"),
 System.SerializableAttribute(),
 System.Diagnostics.DebuggerStepThroughAttribute(),
 System.ComponentModel.DesignerCategoryAttribute("code"),
 System.Xml.Serialization.XmlTypeAttribute(AnonymousType:=True, [Namespace]:="http://dwhClinico.org/dataResult/2")>
Partial Public Class PazientiDataSetPaziente

    Private idField As String

    Private aziendaEroganteField As String

    Private sistemaEroganteField As String

    Private repartoEroganteField As String

    Private codiceSanitarioField As String

    Private nomeField As String

    Private cognomeField As String

    Private dataNascitaField As Date

    Private dataNascitaFieldSpecified As Boolean

    Private luogoNascitaField As String

    Private codiceFiscaleField As String

    Private sessoField As String

    Private consensoField As Byte

    Private consensoFieldSpecified As Boolean

    Private datiAnamnesticiField As String

    Private dataDecessoField As Date

    Private dataDecessoFieldSpecified As Boolean

    '''<remarks/>
    Public Property Id() As String
        Get
            Return Me.idField
        End Get
        Set(value As String)
            Me.idField = value
        End Set
    End Property

    '''<remarks/>
    Public Property AziendaErogante() As String
        Get
            Return Me.aziendaEroganteField
        End Get
        Set(value As String)
            Me.aziendaEroganteField = value
        End Set
    End Property

    '''<remarks/>
    Public Property SistemaErogante() As String
        Get
            Return Me.sistemaEroganteField
        End Get
        Set(value As String)
            Me.sistemaEroganteField = value
        End Set
    End Property

    '''<remarks/>
    Public Property RepartoErogante() As String
        Get
            Return Me.repartoEroganteField
        End Get
        Set(value As String)
            Me.repartoEroganteField = value
        End Set
    End Property

    '''<remarks/>
    Public Property CodiceSanitario() As String
        Get
            Return Me.codiceSanitarioField
        End Get
        Set(value As String)
            Me.codiceSanitarioField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Nome() As String
        Get
            Return Me.nomeField
        End Get
        Set(value As String)
            Me.nomeField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Cognome() As String
        Get
            Return Me.cognomeField
        End Get
        Set(value As String)
            Me.cognomeField = value
        End Set
    End Property

    '''<remarks/>
    Public Property DataNascita() As Date
        Get
            Return Me.dataNascitaField
        End Get
        Set(value As Date)
            Me.dataNascitaField = value
        End Set
    End Property

    '''<remarks/>
    <System.Xml.Serialization.XmlIgnoreAttribute()>
    Public Property DataNascitaSpecified() As Boolean
        Get
            Return Me.dataNascitaFieldSpecified
        End Get
        Set(value As Boolean)
            Me.dataNascitaFieldSpecified = value
        End Set
    End Property

    '''<remarks/>
    Public Property LuogoNascita() As String
        Get
            Return Me.luogoNascitaField
        End Get
        Set(value As String)
            Me.luogoNascitaField = value
        End Set
    End Property

    '''<remarks/>
    Public Property CodiceFiscale() As String
        Get
            Return Me.codiceFiscaleField
        End Get
        Set(value As String)
            Me.codiceFiscaleField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Sesso() As String
        Get
            Return Me.sessoField
        End Get
        Set(value As String)
            Me.sessoField = value
        End Set
    End Property

    '''<remarks/>
    Public Property Consenso() As Byte
        Get
            Return Me.consensoField
        End Get
        Set(value As Byte)
            Me.consensoField = value
        End Set
    End Property

    '''<remarks/>
    <System.Xml.Serialization.XmlIgnoreAttribute()>
    Public Property ConsensoSpecified() As Boolean
        Get
            Return Me.consensoFieldSpecified
        End Get
        Set(value As Boolean)
            Me.consensoFieldSpecified = value
        End Set
    End Property

    '''<remarks/>
    Public Property DatiAnamnestici() As String
        Get
            Return Me.datiAnamnesticiField
        End Get
        Set(value As String)
            Me.datiAnamnesticiField = value
        End Set
    End Property

    '''<remarks/>
    Public Property DataDecesso() As Date
        Get
            Return Me.dataDecessoField
        End Get
        Set(value As Date)
            Me.dataDecessoField = value
        End Set
    End Property

    '''<remarks/>
    <System.Xml.Serialization.XmlIgnoreAttribute()>
    Public Property DataDecessoSpecified() As Boolean
        Get
            Return Me.dataDecessoFieldSpecified
        End Get
        Set(value As Boolean)
            Me.dataDecessoFieldSpecified = value
        End Set
    End Property
End Class









