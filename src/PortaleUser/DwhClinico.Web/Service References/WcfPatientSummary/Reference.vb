﻿'------------------------------------------------------------------------------
' <auto-generated>
'     This code was generated by a tool.
'     Runtime Version:4.0.30319.42000
'
'     Changes to this file may cause incorrect behavior and will be lost if
'     the code is regenerated.
' </auto-generated>
'------------------------------------------------------------------------------

Option Strict On
Option Explicit On


Namespace WcfPatientSummary
    
    <System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0"),  _
     System.ServiceModel.ServiceContractAttribute(Name:="SOLE.Wcf.BtDataAccess.PatientSummary", [Namespace]:="http://Sole.DwhClinico.PatientSummary", ConfigurationName:="WcfPatientSummary.SOLEWcfBtDataAccessPatientSummary")>  _
    Public Interface SOLEWcfBtDataAccessPatientSummary
        
        'CODEGEN: Generating message contract since the operation OttieniPaS is neither RPC nor document wrapped.
        <System.ServiceModel.OperationContractAttribute(Action:="OttieniPaS", ReplyAction:="*"),  _
         System.ServiceModel.XmlSerializerFormatAttribute(SupportFaults:=true)>  _
        Function OttieniPaS(ByVal request As WcfPatientSummary.OttieniPaSRequest) As WcfPatientSummary.OttieniPaSResponse
        
        <System.ServiceModel.OperationContractAttribute(AsyncPattern:=true, Action:="OttieniPaS", ReplyAction:="*")>  _
        Function BeginOttieniPaS(ByVal request As WcfPatientSummary.OttieniPaSRequest, ByVal callback As System.AsyncCallback, ByVal asyncState As Object) As System.IAsyncResult
        
        Function EndOttieniPaS(ByVal result As System.IAsyncResult) As WcfPatientSummary.OttieniPaSResponse
    End Interface
    
    '''<remarks/>
    <System.CodeDom.Compiler.GeneratedCodeAttribute("System.Xml", "4.6.1064.2"),  _
     System.SerializableAttribute(),  _
     System.Diagnostics.DebuggerStepThroughAttribute(),  _
     System.ComponentModel.DesignerCategoryAttribute("code"),  _
     System.Xml.Serialization.XmlTypeAttribute(AnonymousType:=true, [Namespace]:="http://Sole.DwhClinico.PatientSummary.RequestData")>  _
    Partial Public Class Richiesta
        Inherits Object
        Implements System.ComponentModel.INotifyPropertyChanged
        
        Private pazienteField As RichiestaPaziente
        
        Private richiedenteField As RichiestaRichiedente
        
        Private datiRestituitiField As RichiestaDatiRestituiti
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=0)>  _
        Public Property Paziente() As RichiestaPaziente
            Get
                Return Me.pazienteField
            End Get
            Set
                Me.pazienteField = value
                Me.RaisePropertyChanged("Paziente")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=1)>  _
        Public Property Richiedente() As RichiestaRichiedente
            Get
                Return Me.richiedenteField
            End Get
            Set
                Me.richiedenteField = value
                Me.RaisePropertyChanged("Richiedente")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=2)>  _
        Public Property DatiRestituiti() As RichiestaDatiRestituiti
            Get
                Return Me.datiRestituitiField
            End Get
            Set
                Me.datiRestituitiField = value
                Me.RaisePropertyChanged("DatiRestituiti")
            End Set
        End Property
        
        Public Event PropertyChanged As System.ComponentModel.PropertyChangedEventHandler Implements System.ComponentModel.INotifyPropertyChanged.PropertyChanged
        
        Protected Sub RaisePropertyChanged(ByVal propertyName As String)
            Dim propertyChanged As System.ComponentModel.PropertyChangedEventHandler = Me.PropertyChangedEvent
            If (Not (propertyChanged) Is Nothing) Then
                propertyChanged(Me, New System.ComponentModel.PropertyChangedEventArgs(propertyName))
            End If
        End Sub
    End Class
    
    '''<remarks/>
    <System.CodeDom.Compiler.GeneratedCodeAttribute("System.Xml", "4.6.1064.2"),  _
     System.SerializableAttribute(),  _
     System.Diagnostics.DebuggerStepThroughAttribute(),  _
     System.ComponentModel.DesignerCategoryAttribute("code"),  _
     System.Xml.Serialization.XmlTypeAttribute(AnonymousType:=true, [Namespace]:="http://Sole.DwhClinico.PatientSummary.RequestData")>  _
    Partial Public Class RichiestaPaziente
        Inherits Object
        Implements System.ComponentModel.INotifyPropertyChanged
        
        Private nomeField As String
        
        Private cognomeField As String
        
        Private dataNascitaField As System.Nullable(Of Date)
        
        Private dataNascitaFieldSpecified As Boolean
        
        Private codiceFiscaleField As String
        
        Private codicePasSField As String
        
        Private codiceFiscaleMedicoField As String
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=0)>  _
        Public Property Nome() As String
            Get
                Return Me.nomeField
            End Get
            Set
                Me.nomeField = value
                Me.RaisePropertyChanged("Nome")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=1)>  _
        Public Property Cognome() As String
            Get
                Return Me.cognomeField
            End Get
            Set
                Me.cognomeField = value
                Me.RaisePropertyChanged("Cognome")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, IsNullable:=true, Order:=2)>  _
        Public Property DataNascita() As System.Nullable(Of Date)
            Get
                Return Me.dataNascitaField
            End Get
            Set
                Me.dataNascitaField = value
                Me.RaisePropertyChanged("DataNascita")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlIgnoreAttribute()>  _
        Public Property DataNascitaSpecified() As Boolean
            Get
                Return Me.dataNascitaFieldSpecified
            End Get
            Set
                Me.dataNascitaFieldSpecified = value
                Me.RaisePropertyChanged("DataNascitaSpecified")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=3)>  _
        Public Property CodiceFiscale() As String
            Get
                Return Me.codiceFiscaleField
            End Get
            Set
                Me.codiceFiscaleField = value
                Me.RaisePropertyChanged("CodiceFiscale")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=4)>  _
        Public Property CodicePasS() As String
            Get
                Return Me.codicePasSField
            End Get
            Set
                Me.codicePasSField = value
                Me.RaisePropertyChanged("CodicePasS")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=5)>  _
        Public Property CodiceFiscaleMedico() As String
            Get
                Return Me.codiceFiscaleMedicoField
            End Get
            Set
                Me.codiceFiscaleMedicoField = value
                Me.RaisePropertyChanged("CodiceFiscaleMedico")
            End Set
        End Property
        
        Public Event PropertyChanged As System.ComponentModel.PropertyChangedEventHandler Implements System.ComponentModel.INotifyPropertyChanged.PropertyChanged
        
        Protected Sub RaisePropertyChanged(ByVal propertyName As String)
            Dim propertyChanged As System.ComponentModel.PropertyChangedEventHandler = Me.PropertyChangedEvent
            If (Not (propertyChanged) Is Nothing) Then
                propertyChanged(Me, New System.ComponentModel.PropertyChangedEventArgs(propertyName))
            End If
        End Sub
    End Class
    
    '''<remarks/>
    <System.CodeDom.Compiler.GeneratedCodeAttribute("System.Xml", "4.6.1064.2"),  _
     System.SerializableAttribute(),  _
     System.Diagnostics.DebuggerStepThroughAttribute(),  _
     System.ComponentModel.DesignerCategoryAttribute("code"),  _
     System.Xml.Serialization.XmlTypeAttribute(AnonymousType:=true, [Namespace]:="http://Sole.DwhClinico.PatientSummary.RequestData")>  _
    Partial Public Class RichiestaRichiedente
        Inherits Object
        Implements System.ComponentModel.INotifyPropertyChanged
        
        Private codiceFiscaleField As String
        
        Private ruoloField As String
        
        Private nomeField As String
        
        Private cognomeField As String
        
        Private contestoApplicativoField As String
        
        Private presaInCaricoField As String
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=0)>  _
        Public Property CodiceFiscale() As String
            Get
                Return Me.codiceFiscaleField
            End Get
            Set
                Me.codiceFiscaleField = value
                Me.RaisePropertyChanged("CodiceFiscale")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=1)>  _
        Public Property Ruolo() As String
            Get
                Return Me.ruoloField
            End Get
            Set
                Me.ruoloField = value
                Me.RaisePropertyChanged("Ruolo")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=2)>  _
        Public Property Nome() As String
            Get
                Return Me.nomeField
            End Get
            Set
                Me.nomeField = value
                Me.RaisePropertyChanged("Nome")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=3)>  _
        Public Property Cognome() As String
            Get
                Return Me.cognomeField
            End Get
            Set
                Me.cognomeField = value
                Me.RaisePropertyChanged("Cognome")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=4)>  _
        Public Property ContestoApplicativo() As String
            Get
                Return Me.contestoApplicativoField
            End Get
            Set
                Me.contestoApplicativoField = value
                Me.RaisePropertyChanged("ContestoApplicativo")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=5)>  _
        Public Property PresaInCarico() As String
            Get
                Return Me.presaInCaricoField
            End Get
            Set
                Me.presaInCaricoField = value
                Me.RaisePropertyChanged("PresaInCarico")
            End Set
        End Property
        
        Public Event PropertyChanged As System.ComponentModel.PropertyChangedEventHandler Implements System.ComponentModel.INotifyPropertyChanged.PropertyChanged
        
        Protected Sub RaisePropertyChanged(ByVal propertyName As String)
            Dim propertyChanged As System.ComponentModel.PropertyChangedEventHandler = Me.PropertyChangedEvent
            If (Not (propertyChanged) Is Nothing) Then
                propertyChanged(Me, New System.ComponentModel.PropertyChangedEventArgs(propertyName))
            End If
        End Sub
    End Class
    
    '''<remarks/>
    <System.CodeDom.Compiler.GeneratedCodeAttribute("System.Xml", "4.6.1064.2"),  _
     System.SerializableAttribute(),  _
     System.Diagnostics.DebuggerStepThroughAttribute(),  _
     System.ComponentModel.DesignerCategoryAttribute("code"),  _
     System.Xml.Serialization.XmlTypeAttribute(AnonymousType:=true, [Namespace]:="http://Sole.DwhClinico.PatientSummary.RequestData")>  _
    Partial Public Class RichiestaDatiRestituiti
        Inherits Object
        Implements System.ComponentModel.INotifyPropertyChanged
        
        Private maxRecordsField As Integer
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=0)>  _
        Public Property MaxRecords() As Integer
            Get
                Return Me.maxRecordsField
            End Get
            Set
                Me.maxRecordsField = value
                Me.RaisePropertyChanged("MaxRecords")
            End Set
        End Property
        
        Public Event PropertyChanged As System.ComponentModel.PropertyChangedEventHandler Implements System.ComponentModel.INotifyPropertyChanged.PropertyChanged
        
        Protected Sub RaisePropertyChanged(ByVal propertyName As String)
            Dim propertyChanged As System.ComponentModel.PropertyChangedEventHandler = Me.PropertyChangedEvent
            If (Not (propertyChanged) Is Nothing) Then
                propertyChanged(Me, New System.ComponentModel.PropertyChangedEventArgs(propertyName))
            End If
        End Sub
    End Class
    
    '''<remarks/>
    <System.CodeDom.Compiler.GeneratedCodeAttribute("System.Xml", "4.6.1064.2"),  _
     System.SerializableAttribute(),  _
     System.Diagnostics.DebuggerStepThroughAttribute(),  _
     System.ComponentModel.DesignerCategoryAttribute("code"),  _
     System.Xml.Serialization.XmlTypeAttribute(AnonymousType:=true, [Namespace]:="http://Sole.DwhClinico.PatientSummary.Risposta")>  _
    Partial Public Class Risposta
        Inherits Object
        Implements System.ComponentModel.INotifyPropertyChanged
        
        Private inErroreField As Boolean
        
        Private esitoField As RispostaEsito
        
        Private datiField As RispostaDati
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=0)>  _
        Public Property InErrore() As Boolean
            Get
                Return Me.inErroreField
            End Get
            Set
                Me.inErroreField = value
                Me.RaisePropertyChanged("InErrore")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=1)>  _
        Public Property Esito() As RispostaEsito
            Get
                Return Me.esitoField
            End Get
            Set
                Me.esitoField = value
                Me.RaisePropertyChanged("Esito")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=2)>  _
        Public Property Dati() As RispostaDati
            Get
                Return Me.datiField
            End Get
            Set
                Me.datiField = value
                Me.RaisePropertyChanged("Dati")
            End Set
        End Property
        
        Public Event PropertyChanged As System.ComponentModel.PropertyChangedEventHandler Implements System.ComponentModel.INotifyPropertyChanged.PropertyChanged
        
        Protected Sub RaisePropertyChanged(ByVal propertyName As String)
            Dim propertyChanged As System.ComponentModel.PropertyChangedEventHandler = Me.PropertyChangedEvent
            If (Not (propertyChanged) Is Nothing) Then
                propertyChanged(Me, New System.ComponentModel.PropertyChangedEventArgs(propertyName))
            End If
        End Sub
    End Class
    
    '''<remarks/>
    <System.CodeDom.Compiler.GeneratedCodeAttribute("System.Xml", "4.6.1064.2"),  _
     System.SerializableAttribute(),  _
     System.Diagnostics.DebuggerStepThroughAttribute(),  _
     System.ComponentModel.DesignerCategoryAttribute("code"),  _
     System.Xml.Serialization.XmlTypeAttribute(AnonymousType:=true, [Namespace]:="http://Sole.DwhClinico.PatientSummary.Risposta")>  _
    Partial Public Class RispostaEsito
        Inherits Object
        Implements System.ComponentModel.INotifyPropertyChanged
        
        Private codiceField As String
        
        Private descrizioneField As String
        
        Private codiceErroreHL7Field As String
        
        Private descrizioneErroreHL7Field As String
        
        Private codiceErroreApplicazioneField As String
        
        Private descrizioneErroreApplicazioneField As String
        
        Private codiceSeveritaField As String
        
        Private descrizioneSeveritaField As String
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=0)>  _
        Public Property Codice() As String
            Get
                Return Me.codiceField
            End Get
            Set
                Me.codiceField = value
                Me.RaisePropertyChanged("Codice")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=1)>  _
        Public Property Descrizione() As String
            Get
                Return Me.descrizioneField
            End Get
            Set
                Me.descrizioneField = value
                Me.RaisePropertyChanged("Descrizione")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=2)>  _
        Public Property CodiceErroreHL7() As String
            Get
                Return Me.codiceErroreHL7Field
            End Get
            Set
                Me.codiceErroreHL7Field = value
                Me.RaisePropertyChanged("CodiceErroreHL7")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=3)>  _
        Public Property DescrizioneErroreHL7() As String
            Get
                Return Me.descrizioneErroreHL7Field
            End Get
            Set
                Me.descrizioneErroreHL7Field = value
                Me.RaisePropertyChanged("DescrizioneErroreHL7")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=4)>  _
        Public Property CodiceErroreApplicazione() As String
            Get
                Return Me.codiceErroreApplicazioneField
            End Get
            Set
                Me.codiceErroreApplicazioneField = value
                Me.RaisePropertyChanged("CodiceErroreApplicazione")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=5)>  _
        Public Property DescrizioneErroreApplicazione() As String
            Get
                Return Me.descrizioneErroreApplicazioneField
            End Get
            Set
                Me.descrizioneErroreApplicazioneField = value
                Me.RaisePropertyChanged("DescrizioneErroreApplicazione")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=6)>  _
        Public Property CodiceSeverita() As String
            Get
                Return Me.codiceSeveritaField
            End Get
            Set
                Me.codiceSeveritaField = value
                Me.RaisePropertyChanged("CodiceSeverita")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=7)>  _
        Public Property DescrizioneSeverita() As String
            Get
                Return Me.descrizioneSeveritaField
            End Get
            Set
                Me.descrizioneSeveritaField = value
                Me.RaisePropertyChanged("DescrizioneSeverita")
            End Set
        End Property
        
        Public Event PropertyChanged As System.ComponentModel.PropertyChangedEventHandler Implements System.ComponentModel.INotifyPropertyChanged.PropertyChanged
        
        Protected Sub RaisePropertyChanged(ByVal propertyName As String)
            Dim propertyChanged As System.ComponentModel.PropertyChangedEventHandler = Me.PropertyChangedEvent
            If (Not (propertyChanged) Is Nothing) Then
                propertyChanged(Me, New System.ComponentModel.PropertyChangedEventArgs(propertyName))
            End If
        End Sub
    End Class
    
    '''<remarks/>
    <System.CodeDom.Compiler.GeneratedCodeAttribute("System.Xml", "4.6.1064.2"),  _
     System.SerializableAttribute(),  _
     System.Diagnostics.DebuggerStepThroughAttribute(),  _
     System.ComponentModel.DesignerCategoryAttribute("code"),  _
     System.Xml.Serialization.XmlTypeAttribute(AnonymousType:=true, [Namespace]:="http://Sole.DwhClinico.PatientSummary.Risposta")>  _
    Partial Public Class RispostaDati
        Inherits Object
        Implements System.ComponentModel.INotifyPropertyChanged
        
        Private cDAField() As Byte
        
        Private pDFField() As Byte
        
        Private codiceStatoField As String
        
        Private descrizioneStatoField As String
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, DataType:="base64Binary", Order:=0)>  _
        Public Property CDA() As Byte()
            Get
                Return Me.cDAField
            End Get
            Set
                Me.cDAField = value
                Me.RaisePropertyChanged("CDA")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, DataType:="base64Binary", Order:=1)>  _
        Public Property PDF() As Byte()
            Get
                Return Me.pDFField
            End Get
            Set
                Me.pDFField = value
                Me.RaisePropertyChanged("PDF")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=2)>  _
        Public Property CodiceStato() As String
            Get
                Return Me.codiceStatoField
            End Get
            Set
                Me.codiceStatoField = value
                Me.RaisePropertyChanged("CodiceStato")
            End Set
        End Property
        
        '''<remarks/>
        <System.Xml.Serialization.XmlElementAttribute(Form:=System.Xml.Schema.XmlSchemaForm.Unqualified, Order:=3)>  _
        Public Property DescrizioneStato() As String
            Get
                Return Me.descrizioneStatoField
            End Get
            Set
                Me.descrizioneStatoField = value
                Me.RaisePropertyChanged("DescrizioneStato")
            End Set
        End Property
        
        Public Event PropertyChanged As System.ComponentModel.PropertyChangedEventHandler Implements System.ComponentModel.INotifyPropertyChanged.PropertyChanged
        
        Protected Sub RaisePropertyChanged(ByVal propertyName As String)
            Dim propertyChanged As System.ComponentModel.PropertyChangedEventHandler = Me.PropertyChangedEvent
            If (Not (propertyChanged) Is Nothing) Then
                propertyChanged(Me, New System.ComponentModel.PropertyChangedEventArgs(propertyName))
            End If
        End Sub
    End Class
    
    <System.Diagnostics.DebuggerStepThroughAttribute(),  _
     System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0"),  _
     System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced),  _
     System.ServiceModel.MessageContractAttribute(IsWrapped:=false)>  _
    Partial Public Class OttieniPaSRequest
        
        <System.ServiceModel.MessageBodyMemberAttribute([Namespace]:="http://Sole.DwhClinico.PatientSummary.RequestData", Order:=0)>  _
        Public Richiesta As WcfPatientSummary.Richiesta
        
        Public Sub New()
            MyBase.New
        End Sub
        
        Public Sub New(ByVal Richiesta As WcfPatientSummary.Richiesta)
            MyBase.New
            Me.Richiesta = Richiesta
        End Sub
    End Class
    
    <System.Diagnostics.DebuggerStepThroughAttribute(),  _
     System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0"),  _
     System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced),  _
     System.ServiceModel.MessageContractAttribute(IsWrapped:=false)>  _
    Partial Public Class OttieniPaSResponse
        
        <System.ServiceModel.MessageBodyMemberAttribute([Namespace]:="http://Sole.DwhClinico.PatientSummary.Risposta", Order:=0)>  _
        Public Risposta As WcfPatientSummary.Risposta
        
        Public Sub New()
            MyBase.New
        End Sub
        
        Public Sub New(ByVal Risposta As WcfPatientSummary.Risposta)
            MyBase.New
            Me.Risposta = Risposta
        End Sub
    End Class
    
    <System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")>  _
    Public Interface SOLEWcfBtDataAccessPatientSummaryChannel
        Inherits WcfPatientSummary.SOLEWcfBtDataAccessPatientSummary, System.ServiceModel.IClientChannel
    End Interface
    
    <System.Diagnostics.DebuggerStepThroughAttribute(),  _
     System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")>  _
    Partial Public Class OttieniPaSCompletedEventArgs
        Inherits System.ComponentModel.AsyncCompletedEventArgs
        
        Private results() As Object
        
        Public Sub New(ByVal results() As Object, ByVal exception As System.Exception, ByVal cancelled As Boolean, ByVal userState As Object)
            MyBase.New(exception, cancelled, userState)
            Me.results = results
        End Sub
        
        Public ReadOnly Property Result() As WcfPatientSummary.Risposta
            Get
                MyBase.RaiseExceptionIfNecessary
                Return CType(Me.results(0),WcfPatientSummary.Risposta)
            End Get
        End Property
    End Class
    
    <System.Diagnostics.DebuggerStepThroughAttribute(),  _
     System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")>  _
    Partial Public Class SOLEWcfBtDataAccessPatientSummaryClient
        Inherits System.ServiceModel.ClientBase(Of WcfPatientSummary.SOLEWcfBtDataAccessPatientSummary)
        Implements WcfPatientSummary.SOLEWcfBtDataAccessPatientSummary
        
        Private onBeginOttieniPaSDelegate As BeginOperationDelegate
        
        Private onEndOttieniPaSDelegate As EndOperationDelegate
        
        Private onOttieniPaSCompletedDelegate As System.Threading.SendOrPostCallback
        
        Public Sub New()
            MyBase.New
        End Sub
        
        Public Sub New(ByVal endpointConfigurationName As String)
            MyBase.New(endpointConfigurationName)
        End Sub
        
        Public Sub New(ByVal endpointConfigurationName As String, ByVal remoteAddress As String)
            MyBase.New(endpointConfigurationName, remoteAddress)
        End Sub
        
        Public Sub New(ByVal endpointConfigurationName As String, ByVal remoteAddress As System.ServiceModel.EndpointAddress)
            MyBase.New(endpointConfigurationName, remoteAddress)
        End Sub
        
        Public Sub New(ByVal binding As System.ServiceModel.Channels.Binding, ByVal remoteAddress As System.ServiceModel.EndpointAddress)
            MyBase.New(binding, remoteAddress)
        End Sub
        
        Public Event OttieniPaSCompleted As System.EventHandler(Of OttieniPaSCompletedEventArgs)
        
        <System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)>  _
        Function WcfPatientSummary_SOLEWcfBtDataAccessPatientSummary_OttieniPaS(ByVal request As WcfPatientSummary.OttieniPaSRequest) As WcfPatientSummary.OttieniPaSResponse Implements WcfPatientSummary.SOLEWcfBtDataAccessPatientSummary.OttieniPaS
            Return MyBase.Channel.OttieniPaS(request)
        End Function
        
        Public Function OttieniPaS(ByVal Richiesta As WcfPatientSummary.Richiesta) As WcfPatientSummary.Risposta
            Dim inValue As WcfPatientSummary.OttieniPaSRequest = New WcfPatientSummary.OttieniPaSRequest()
            inValue.Richiesta = Richiesta
            Dim retVal As WcfPatientSummary.OttieniPaSResponse = CType(Me,WcfPatientSummary.SOLEWcfBtDataAccessPatientSummary).OttieniPaS(inValue)
            Return retVal.Risposta
        End Function
        
        <System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)>  _
        Function WcfPatientSummary_SOLEWcfBtDataAccessPatientSummary_BeginOttieniPaS(ByVal request As WcfPatientSummary.OttieniPaSRequest, ByVal callback As System.AsyncCallback, ByVal asyncState As Object) As System.IAsyncResult Implements WcfPatientSummary.SOLEWcfBtDataAccessPatientSummary.BeginOttieniPaS
            Return MyBase.Channel.BeginOttieniPaS(request, callback, asyncState)
        End Function
        
        <System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)>  _
        Public Function BeginOttieniPaS(ByVal Richiesta As WcfPatientSummary.Richiesta, ByVal callback As System.AsyncCallback, ByVal asyncState As Object) As System.IAsyncResult
            Dim inValue As WcfPatientSummary.OttieniPaSRequest = New WcfPatientSummary.OttieniPaSRequest()
            inValue.Richiesta = Richiesta
            Return CType(Me,WcfPatientSummary.SOLEWcfBtDataAccessPatientSummary).BeginOttieniPaS(inValue, callback, asyncState)
        End Function
        
        <System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)>  _
        Function WcfPatientSummary_SOLEWcfBtDataAccessPatientSummary_EndOttieniPaS(ByVal result As System.IAsyncResult) As WcfPatientSummary.OttieniPaSResponse Implements WcfPatientSummary.SOLEWcfBtDataAccessPatientSummary.EndOttieniPaS
            Return MyBase.Channel.EndOttieniPaS(result)
        End Function
        
        <System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)>  _
        Public Function EndOttieniPaS(ByVal result As System.IAsyncResult) As WcfPatientSummary.Risposta
            Dim retVal As WcfPatientSummary.OttieniPaSResponse = CType(Me,WcfPatientSummary.SOLEWcfBtDataAccessPatientSummary).EndOttieniPaS(result)
            Return retVal.Risposta
        End Function
        
        Private Function OnBeginOttieniPaS(ByVal inValues() As Object, ByVal callback As System.AsyncCallback, ByVal asyncState As Object) As System.IAsyncResult
            Dim Richiesta As WcfPatientSummary.Richiesta = CType(inValues(0),WcfPatientSummary.Richiesta)
            Return Me.BeginOttieniPaS(Richiesta, callback, asyncState)
        End Function
        
        Private Function OnEndOttieniPaS(ByVal result As System.IAsyncResult) As Object()
            Dim retVal As WcfPatientSummary.Risposta = Me.EndOttieniPaS(result)
            Return New Object() {retVal}
        End Function
        
        Private Sub OnOttieniPaSCompleted(ByVal state As Object)
            If (Not (Me.OttieniPaSCompletedEvent) Is Nothing) Then
                Dim e As InvokeAsyncCompletedEventArgs = CType(state,InvokeAsyncCompletedEventArgs)
                RaiseEvent OttieniPaSCompleted(Me, New OttieniPaSCompletedEventArgs(e.Results, e.Error, e.Cancelled, e.UserState))
            End If
        End Sub
        
        Public Overloads Sub OttieniPaSAsync(ByVal Richiesta As WcfPatientSummary.Richiesta)
            Me.OttieniPaSAsync(Richiesta, Nothing)
        End Sub
        
        Public Overloads Sub OttieniPaSAsync(ByVal Richiesta As WcfPatientSummary.Richiesta, ByVal userState As Object)
            If (Me.onBeginOttieniPaSDelegate Is Nothing) Then
                Me.onBeginOttieniPaSDelegate = AddressOf Me.OnBeginOttieniPaS
            End If
            If (Me.onEndOttieniPaSDelegate Is Nothing) Then
                Me.onEndOttieniPaSDelegate = AddressOf Me.OnEndOttieniPaS
            End If
            If (Me.onOttieniPaSCompletedDelegate Is Nothing) Then
                Me.onOttieniPaSCompletedDelegate = AddressOf Me.OnOttieniPaSCompleted
            End If
            MyBase.InvokeAsync(Me.onBeginOttieniPaSDelegate, New Object() {Richiesta}, Me.onEndOttieniPaSDelegate, Me.onOttieniPaSCompletedDelegate, userState)
        End Sub
    End Class
End Namespace
