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

Imports System
Imports System.Runtime.Serialization

Namespace WcfSacDizionari
    
    <System.Diagnostics.DebuggerStepThroughAttribute(),  _
     System.CodeDom.Compiler.GeneratedCodeAttribute("System.Runtime.Serialization", "4.0.0.0"),  _
     System.Runtime.Serialization.DataContractAttribute(Name:="TokenType", [Namespace]:="http://schemas.progel.it/WCF/SAC/Types/3.0"),  _
     System.SerializableAttribute()>  _
    Partial Public Class TokenType
        Inherits Object
        Implements System.Runtime.Serialization.IExtensibleDataObject, System.ComponentModel.INotifyPropertyChanged
        
        <System.NonSerializedAttribute()>  _
        Private extensionDataField As System.Runtime.Serialization.ExtensionDataObject
        
        Private IdField As String
        
        Private CodiceRuoloField As String
        
        Private UtenteDelegaField As String
        
        <Global.System.ComponentModel.BrowsableAttribute(false)>  _
        Public Property ExtensionData() As System.Runtime.Serialization.ExtensionDataObject Implements System.Runtime.Serialization.IExtensibleDataObject.ExtensionData
            Get
                Return Me.extensionDataField
            End Get
            Set
                Me.extensionDataField = value
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(IsRequired:=true, EmitDefaultValue:=false)>  _
        Public Property Id() As String
            Get
                Return Me.IdField
            End Get
            Set
                If (Object.ReferenceEquals(Me.IdField, value) <> true) Then
                    Me.IdField = value
                    Me.RaisePropertyChanged("Id")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(IsRequired:=true, EmitDefaultValue:=false, Order:=1)>  _
        Public Property CodiceRuolo() As String
            Get
                Return Me.CodiceRuoloField
            End Get
            Set
                If (Object.ReferenceEquals(Me.CodiceRuoloField, value) <> true) Then
                    Me.CodiceRuoloField = value
                    Me.RaisePropertyChanged("CodiceRuolo")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(IsRequired:=true, EmitDefaultValue:=false, Order:=2)>  _
        Public Property UtenteDelega() As String
            Get
                Return Me.UtenteDelegaField
            End Get
            Set
                If (Object.ReferenceEquals(Me.UtenteDelegaField, value) <> true) Then
                    Me.UtenteDelegaField = value
                    Me.RaisePropertyChanged("UtenteDelega")
                End If
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
     System.CodeDom.Compiler.GeneratedCodeAttribute("System.Runtime.Serialization", "4.0.0.0"),  _
     System.Runtime.Serialization.DataContractAttribute(Name:="EsenzioniReturn", [Namespace]:="http://schemas.progel.it/WCF/SAC/DizionariTypes/3.0"),  _
     System.SerializableAttribute()>  _
    Partial Public Class EsenzioniReturn
        Inherits Object
        Implements System.Runtime.Serialization.IExtensibleDataObject, System.ComponentModel.INotifyPropertyChanged
        
        <System.NonSerializedAttribute()>  _
        Private extensionDataField As System.Runtime.Serialization.ExtensionDataObject
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private EsenzioniField As WcfSacDizionari.EsenzioniListaType
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private ErroreField As WcfSacDizionari.ErroreType
        
        <Global.System.ComponentModel.BrowsableAttribute(false)>  _
        Public Property ExtensionData() As System.Runtime.Serialization.ExtensionDataObject Implements System.Runtime.Serialization.IExtensibleDataObject.ExtensionData
            Get
                Return Me.extensionDataField
            End Get
            Set
                Me.extensionDataField = value
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue:=false)>  _
        Public Property Esenzioni() As WcfSacDizionari.EsenzioniListaType
            Get
                Return Me.EsenzioniField
            End Get
            Set
                If (Object.ReferenceEquals(Me.EsenzioniField, value) <> true) Then
                    Me.EsenzioniField = value
                    Me.RaisePropertyChanged("Esenzioni")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue:=false, Order:=1)>  _
        Public Property Errore() As WcfSacDizionari.ErroreType
            Get
                Return Me.ErroreField
            End Get
            Set
                If (Object.ReferenceEquals(Me.ErroreField, value) <> true) Then
                    Me.ErroreField = value
                    Me.RaisePropertyChanged("Errore")
                End If
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
     System.CodeDom.Compiler.GeneratedCodeAttribute("System.Runtime.Serialization", "4.0.0.0"),  _
     System.Runtime.Serialization.DataContractAttribute(Name:="ErroreType", [Namespace]:="http://schemas.progel.it/WCF/SAC/Types/3.0"),  _
     System.SerializableAttribute()>  _
    Partial Public Class ErroreType
        Inherits Object
        Implements System.Runtime.Serialization.IExtensibleDataObject, System.ComponentModel.INotifyPropertyChanged
        
        <System.NonSerializedAttribute()>  _
        Private extensionDataField As System.Runtime.Serialization.ExtensionDataObject
        
        Private CodiceField As String
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private DescrizioneField As String
        
        <Global.System.ComponentModel.BrowsableAttribute(false)>  _
        Public Property ExtensionData() As System.Runtime.Serialization.ExtensionDataObject Implements System.Runtime.Serialization.IExtensibleDataObject.ExtensionData
            Get
                Return Me.extensionDataField
            End Get
            Set
                Me.extensionDataField = value
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(IsRequired:=true, EmitDefaultValue:=false)>  _
        Public Property Codice() As String
            Get
                Return Me.CodiceField
            End Get
            Set
                If (Object.ReferenceEquals(Me.CodiceField, value) <> true) Then
                    Me.CodiceField = value
                    Me.RaisePropertyChanged("Codice")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue:=false)>  _
        Public Property Descrizione() As String
            Get
                Return Me.DescrizioneField
            End Get
            Set
                If (Object.ReferenceEquals(Me.DescrizioneField, value) <> true) Then
                    Me.DescrizioneField = value
                    Me.RaisePropertyChanged("Descrizione")
                End If
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
     System.CodeDom.Compiler.GeneratedCodeAttribute("System.Runtime.Serialization", "4.0.0.0"),  _
     System.Runtime.Serialization.CollectionDataContractAttribute(Name:="EsenzioniListaType", [Namespace]:="http://schemas.progel.it/WCF/SAC/DizionariTypes/3.0", ItemName:="Esenzione"),  _
     System.SerializableAttribute()>  _
    Public Class EsenzioniListaType
        Inherits System.Collections.Generic.List(Of WcfSacDizionari.EsenzioneListaType)
    End Class
    
    <System.Diagnostics.DebuggerStepThroughAttribute(),  _
     System.CodeDom.Compiler.GeneratedCodeAttribute("System.Runtime.Serialization", "4.0.0.0"),  _
     System.Runtime.Serialization.DataContractAttribute(Name:="EsenzioneListaType", [Namespace]:="http://schemas.progel.it/WCF/SAC/DizionariTypes/3.0"),  _
     System.SerializableAttribute()>  _
    Partial Public Class EsenzioneListaType
        Inherits Object
        Implements System.Runtime.Serialization.IExtensibleDataObject, System.ComponentModel.INotifyPropertyChanged
        
        <System.NonSerializedAttribute()>  _
        Private extensionDataField As System.Runtime.Serialization.ExtensionDataObject
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private CodiceEsenzioneField As String
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private CodiceDiagnosiField As String
        
        Private PatologicaField As Boolean
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private TestoEsenzioneField As String
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private DecodificaEsenzioneDiagnosiField As String
        
        <Global.System.ComponentModel.BrowsableAttribute(false)>  _
        Public Property ExtensionData() As System.Runtime.Serialization.ExtensionDataObject Implements System.Runtime.Serialization.IExtensibleDataObject.ExtensionData
            Get
                Return Me.extensionDataField
            End Get
            Set
                Me.extensionDataField = value
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue:=false)>  _
        Public Property CodiceEsenzione() As String
            Get
                Return Me.CodiceEsenzioneField
            End Get
            Set
                If (Object.ReferenceEquals(Me.CodiceEsenzioneField, value) <> true) Then
                    Me.CodiceEsenzioneField = value
                    Me.RaisePropertyChanged("CodiceEsenzione")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue:=false, Order:=1)>  _
        Public Property CodiceDiagnosi() As String
            Get
                Return Me.CodiceDiagnosiField
            End Get
            Set
                If (Object.ReferenceEquals(Me.CodiceDiagnosiField, value) <> true) Then
                    Me.CodiceDiagnosiField = value
                    Me.RaisePropertyChanged("CodiceDiagnosi")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(IsRequired:=true, Order:=2)>  _
        Public Property Patologica() As Boolean
            Get
                Return Me.PatologicaField
            End Get
            Set
                If (Me.PatologicaField.Equals(value) <> true) Then
                    Me.PatologicaField = value
                    Me.RaisePropertyChanged("Patologica")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue:=false, Order:=3)>  _
        Public Property TestoEsenzione() As String
            Get
                Return Me.TestoEsenzioneField
            End Get
            Set
                If (Object.ReferenceEquals(Me.TestoEsenzioneField, value) <> true) Then
                    Me.TestoEsenzioneField = value
                    Me.RaisePropertyChanged("TestoEsenzione")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue:=false, Order:=4)>  _
        Public Property DecodificaEsenzioneDiagnosi() As String
            Get
                Return Me.DecodificaEsenzioneDiagnosiField
            End Get
            Set
                If (Object.ReferenceEquals(Me.DecodificaEsenzioneDiagnosiField, value) <> true) Then
                    Me.DecodificaEsenzioneDiagnosiField = value
                    Me.RaisePropertyChanged("DecodificaEsenzioneDiagnosi")
                End If
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
    
    <System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0"),  _
     System.ServiceModel.ServiceContractAttribute([Namespace]:="http://schemas.progel.it/WCF/SAC/Service/3.0", ConfigurationName:="WcfSacDizionari.IDizionari")>  _
    Public Interface IDizionari
        
        <System.ServiceModel.OperationContractAttribute(Action:="http://schemas.progel.it/WCF/SAC/Service/3.0/IDizionari/DizionariEsenzioniCerca", ReplyAction:="http://schemas.progel.it/WCF/SAC/Service/3.0/IDizionari/DizionariEsenzioniCercaRe"& _ 
            "sponse")>  _
        Function DizionariEsenzioniCerca(ByVal Token As WcfSacDizionari.TokenType, ByVal MaxRecord As System.Nullable(Of Integer), ByVal Ordinamento As String, ByVal CodiceEsenzione As String, ByVal DescrizioneEsenzione As String) As WcfSacDizionari.EsenzioniReturn
        
        <System.ServiceModel.OperationContractAttribute(Action:="http://schemas.progel.it/WCF/SAC/Service/3.0/IDizionari/DizionariEsenzioniCerca", ReplyAction:="http://schemas.progel.it/WCF/SAC/Service/3.0/IDizionari/DizionariEsenzioniCercaRe"& _ 
            "sponse")>  _
        Function DizionariEsenzioniCercaAsync(ByVal Token As WcfSacDizionari.TokenType, ByVal MaxRecord As System.Nullable(Of Integer), ByVal Ordinamento As String, ByVal CodiceEsenzione As String, ByVal DescrizioneEsenzione As String) As System.Threading.Tasks.Task(Of WcfSacDizionari.EsenzioniReturn)
    End Interface
    
    <System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")>  _
    Public Interface IDizionariChannel
        Inherits WcfSacDizionari.IDizionari, System.ServiceModel.IClientChannel
    End Interface
    
    <System.Diagnostics.DebuggerStepThroughAttribute(),  _
     System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")>  _
    Partial Public Class DizionariClient
        Inherits System.ServiceModel.ClientBase(Of WcfSacDizionari.IDizionari)
        Implements WcfSacDizionari.IDizionari
        
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
        
        Public Function DizionariEsenzioniCerca(ByVal Token As WcfSacDizionari.TokenType, ByVal MaxRecord As System.Nullable(Of Integer), ByVal Ordinamento As String, ByVal CodiceEsenzione As String, ByVal DescrizioneEsenzione As String) As WcfSacDizionari.EsenzioniReturn Implements WcfSacDizionari.IDizionari.DizionariEsenzioniCerca
            Return MyBase.Channel.DizionariEsenzioniCerca(Token, MaxRecord, Ordinamento, CodiceEsenzione, DescrizioneEsenzione)
        End Function
        
        Public Function DizionariEsenzioniCercaAsync(ByVal Token As WcfSacDizionari.TokenType, ByVal MaxRecord As System.Nullable(Of Integer), ByVal Ordinamento As String, ByVal CodiceEsenzione As String, ByVal DescrizioneEsenzione As String) As System.Threading.Tasks.Task(Of WcfSacDizionari.EsenzioniReturn) Implements WcfSacDizionari.IDizionari.DizionariEsenzioniCercaAsync
            Return MyBase.Channel.DizionariEsenzioniCercaAsync(Token, MaxRecord, Ordinamento, CodiceEsenzione, DescrizioneEsenzione)
        End Function
    End Class
End Namespace