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

Namespace Dwh.DataAccess.Wcf.Service
    
    <System.Diagnostics.DebuggerStepThroughAttribute(),  _
     System.CodeDom.Compiler.GeneratedCodeAttribute("System.Runtime.Serialization", "4.0.0.0"),  _
     System.Runtime.Serialization.DataContractAttribute(Name:="PrescrizioneParameter", [Namespace]:="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0"),  _
     System.SerializableAttribute()>  _
    Partial Public Class PrescrizioneParameter
        Inherits Object
        Implements System.Runtime.Serialization.IExtensibleDataObject, System.ComponentModel.INotifyPropertyChanged
        
        <System.NonSerializedAttribute()>  _
        Private extensionDataField As System.Runtime.Serialization.ExtensionDataObject
        
        Private PrescrizioneField As Dwh.DataAccess.Wcf.Service.PrescrizioneType
        
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
        Public Property Prescrizione() As Dwh.DataAccess.Wcf.Service.PrescrizioneType
            Get
                Return Me.PrescrizioneField
            End Get
            Set
                If (Object.ReferenceEquals(Me.PrescrizioneField, value) <> true) Then
                    Me.PrescrizioneField = value
                    Me.RaisePropertyChanged("Prescrizione")
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
     System.Runtime.Serialization.DataContractAttribute(Name:="PrescrizioneType", [Namespace]:="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0"),  _
     System.SerializableAttribute()>  _
    Partial Public Class PrescrizioneType
        Inherits Object
        Implements System.Runtime.Serialization.IExtensibleDataObject, System.ComponentModel.INotifyPropertyChanged
        
        <System.NonSerializedAttribute()>  _
        Private extensionDataField As System.Runtime.Serialization.ExtensionDataObject
        
        Private IdEsternoField As String
        
        Private DataModificaEsternoField As Date
        
        Private StatoCodiceField As Byte
        
        Private TipoPrescrizioneField As String
        
        Private DataPrescrizioneField As Date
        
        Private NumeroPrescrizioneField As String
        
        Private MedicoPrescrittoreCodiceFiscaleField As String
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private QuesitoDiagnosticoField As String
        
        Private PazienteField As Dwh.DataAccess.Wcf.Service.PazienteType
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private AttributiField As Dwh.DataAccess.Wcf.Service.AttributiType
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private AllegatiField As Dwh.DataAccess.Wcf.Service.AllegatiType
        
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
        Public Property IdEsterno() As String
            Get
                Return Me.IdEsternoField
            End Get
            Set
                If (Object.ReferenceEquals(Me.IdEsternoField, value) <> true) Then
                    Me.IdEsternoField = value
                    Me.RaisePropertyChanged("IdEsterno")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(IsRequired:=true, Order:=1)>  _
        Public Property DataModificaEsterno() As Date
            Get
                Return Me.DataModificaEsternoField
            End Get
            Set
                If (Me.DataModificaEsternoField.Equals(value) <> true) Then
                    Me.DataModificaEsternoField = value
                    Me.RaisePropertyChanged("DataModificaEsterno")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(IsRequired:=true, Order:=2)>  _
        Public Property StatoCodice() As Byte
            Get
                Return Me.StatoCodiceField
            End Get
            Set
                If (Me.StatoCodiceField.Equals(value) <> true) Then
                    Me.StatoCodiceField = value
                    Me.RaisePropertyChanged("StatoCodice")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(IsRequired:=true, EmitDefaultValue:=false, Order:=3)>  _
        Public Property TipoPrescrizione() As String
            Get
                Return Me.TipoPrescrizioneField
            End Get
            Set
                If (Object.ReferenceEquals(Me.TipoPrescrizioneField, value) <> true) Then
                    Me.TipoPrescrizioneField = value
                    Me.RaisePropertyChanged("TipoPrescrizione")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(IsRequired:=true, Order:=4)>  _
        Public Property DataPrescrizione() As Date
            Get
                Return Me.DataPrescrizioneField
            End Get
            Set
                If (Me.DataPrescrizioneField.Equals(value) <> true) Then
                    Me.DataPrescrizioneField = value
                    Me.RaisePropertyChanged("DataPrescrizione")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(IsRequired:=true, EmitDefaultValue:=false, Order:=5)>  _
        Public Property NumeroPrescrizione() As String
            Get
                Return Me.NumeroPrescrizioneField
            End Get
            Set
                If (Object.ReferenceEquals(Me.NumeroPrescrizioneField, value) <> true) Then
                    Me.NumeroPrescrizioneField = value
                    Me.RaisePropertyChanged("NumeroPrescrizione")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(IsRequired:=true, EmitDefaultValue:=false, Order:=6)>  _
        Public Property MedicoPrescrittoreCodiceFiscale() As String
            Get
                Return Me.MedicoPrescrittoreCodiceFiscaleField
            End Get
            Set
                If (Object.ReferenceEquals(Me.MedicoPrescrittoreCodiceFiscaleField, value) <> true) Then
                    Me.MedicoPrescrittoreCodiceFiscaleField = value
                    Me.RaisePropertyChanged("MedicoPrescrittoreCodiceFiscale")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue:=false, Order:=7)>  _
        Public Property QuesitoDiagnostico() As String
            Get
                Return Me.QuesitoDiagnosticoField
            End Get
            Set
                If (Object.ReferenceEquals(Me.QuesitoDiagnosticoField, value) <> true) Then
                    Me.QuesitoDiagnosticoField = value
                    Me.RaisePropertyChanged("QuesitoDiagnostico")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(IsRequired:=true, EmitDefaultValue:=false, Order:=8)>  _
        Public Property Paziente() As Dwh.DataAccess.Wcf.Service.PazienteType
            Get
                Return Me.PazienteField
            End Get
            Set
                If (Object.ReferenceEquals(Me.PazienteField, value) <> true) Then
                    Me.PazienteField = value
                    Me.RaisePropertyChanged("Paziente")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue:=false, Order:=9)>  _
        Public Property Attributi() As Dwh.DataAccess.Wcf.Service.AttributiType
            Get
                Return Me.AttributiField
            End Get
            Set
                If (Object.ReferenceEquals(Me.AttributiField, value) <> true) Then
                    Me.AttributiField = value
                    Me.RaisePropertyChanged("Attributi")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue:=false, Order:=10)>  _
        Public Property Allegati() As Dwh.DataAccess.Wcf.Service.AllegatiType
            Get
                Return Me.AllegatiField
            End Get
            Set
                If (Object.ReferenceEquals(Me.AllegatiField, value) <> true) Then
                    Me.AllegatiField = value
                    Me.RaisePropertyChanged("Allegati")
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
     System.Runtime.Serialization.DataContractAttribute(Name:="PazienteType", [Namespace]:="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0"),  _
     System.SerializableAttribute()>  _
    Partial Public Class PazienteType
        Inherits Object
        Implements System.Runtime.Serialization.IExtensibleDataObject, System.ComponentModel.INotifyPropertyChanged
        
        <System.NonSerializedAttribute()>  _
        Private extensionDataField As System.Runtime.Serialization.ExtensionDataObject
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private NomeField As String
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private CognomeField As String
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private CodiceFiscaleField As String
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private DataNascitaField As System.Nullable(Of Date)
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private TesseraSanitariaField As String
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private LuogoNascitaField As Dwh.DataAccess.Wcf.Service.CodiceDescrizioneType
        
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
        Public Property Nome() As String
            Get
                Return Me.NomeField
            End Get
            Set
                If (Object.ReferenceEquals(Me.NomeField, value) <> true) Then
                    Me.NomeField = value
                    Me.RaisePropertyChanged("Nome")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue:=false, Order:=1)>  _
        Public Property Cognome() As String
            Get
                Return Me.CognomeField
            End Get
            Set
                If (Object.ReferenceEquals(Me.CognomeField, value) <> true) Then
                    Me.CognomeField = value
                    Me.RaisePropertyChanged("Cognome")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue:=false, Order:=2)>  _
        Public Property CodiceFiscale() As String
            Get
                Return Me.CodiceFiscaleField
            End Get
            Set
                If (Object.ReferenceEquals(Me.CodiceFiscaleField, value) <> true) Then
                    Me.CodiceFiscaleField = value
                    Me.RaisePropertyChanged("CodiceFiscale")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(Order:=3)>  _
        Public Property DataNascita() As System.Nullable(Of Date)
            Get
                Return Me.DataNascitaField
            End Get
            Set
                If (Me.DataNascitaField.Equals(value) <> true) Then
                    Me.DataNascitaField = value
                    Me.RaisePropertyChanged("DataNascita")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue:=false, Order:=4)>  _
        Public Property TesseraSanitaria() As String
            Get
                Return Me.TesseraSanitariaField
            End Get
            Set
                If (Object.ReferenceEquals(Me.TesseraSanitariaField, value) <> true) Then
                    Me.TesseraSanitariaField = value
                    Me.RaisePropertyChanged("TesseraSanitaria")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue:=false, Order:=5)>  _
        Public Property LuogoNascita() As Dwh.DataAccess.Wcf.Service.CodiceDescrizioneType
            Get
                Return Me.LuogoNascitaField
            End Get
            Set
                If (Object.ReferenceEquals(Me.LuogoNascitaField, value) <> true) Then
                    Me.LuogoNascitaField = value
                    Me.RaisePropertyChanged("LuogoNascita")
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
     System.Runtime.Serialization.CollectionDataContractAttribute(Name:="AttributiType", [Namespace]:="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0", ItemName:="Attributo"),  _
     System.SerializableAttribute()>  _
    Public Class AttributiType
        Inherits System.Collections.Generic.List(Of Dwh.DataAccess.Wcf.Service.AttributoType)
    End Class
    
    <System.Diagnostics.DebuggerStepThroughAttribute(),  _
     System.CodeDom.Compiler.GeneratedCodeAttribute("System.Runtime.Serialization", "4.0.0.0"),  _
     System.Runtime.Serialization.CollectionDataContractAttribute(Name:="AllegatiType", [Namespace]:="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0", ItemName:="Allegato"),  _
     System.SerializableAttribute()>  _
    Public Class AllegatiType
        Inherits System.Collections.Generic.List(Of Dwh.DataAccess.Wcf.Service.AllegatoType)
    End Class
    
    <System.Diagnostics.DebuggerStepThroughAttribute(),  _
     System.CodeDom.Compiler.GeneratedCodeAttribute("System.Runtime.Serialization", "4.0.0.0"),  _
     System.Runtime.Serialization.DataContractAttribute(Name:="CodiceDescrizioneType", [Namespace]:="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0"),  _
     System.SerializableAttribute()>  _
    Partial Public Class CodiceDescrizioneType
        Inherits Object
        Implements System.Runtime.Serialization.IExtensibleDataObject, System.ComponentModel.INotifyPropertyChanged
        
        <System.NonSerializedAttribute()>  _
        Private extensionDataField As System.Runtime.Serialization.ExtensionDataObject
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
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
        
        <System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue:=false)>  _
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
     System.Runtime.Serialization.DataContractAttribute(Name:="AttributoType", [Namespace]:="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0"),  _
     System.SerializableAttribute()>  _
    Partial Public Class AttributoType
        Inherits Object
        Implements System.Runtime.Serialization.IExtensibleDataObject, System.ComponentModel.INotifyPropertyChanged
        
        <System.NonSerializedAttribute()>  _
        Private extensionDataField As System.Runtime.Serialization.ExtensionDataObject
        
        Private NomeField As String
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private ValoreField As String
        
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
        Public Property Nome() As String
            Get
                Return Me.NomeField
            End Get
            Set
                If (Object.ReferenceEquals(Me.NomeField, value) <> true) Then
                    Me.NomeField = value
                    Me.RaisePropertyChanged("Nome")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue:=false)>  _
        Public Property Valore() As String
            Get
                Return Me.ValoreField
            End Get
            Set
                If (Object.ReferenceEquals(Me.ValoreField, value) <> true) Then
                    Me.ValoreField = value
                    Me.RaisePropertyChanged("Valore")
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
     System.Runtime.Serialization.DataContractAttribute(Name:="AllegatoType", [Namespace]:="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0"),  _
     System.SerializableAttribute()>  _
    Partial Public Class AllegatoType
        Inherits Object
        Implements System.Runtime.Serialization.IExtensibleDataObject, System.ComponentModel.INotifyPropertyChanged
        
        <System.NonSerializedAttribute()>  _
        Private extensionDataField As System.Runtime.Serialization.ExtensionDataObject
        
        Private IdEsternoField As String
        
        Private TipoContenutoField As String
        
        Private ContenutoField() As Byte
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private AttributiField As Dwh.DataAccess.Wcf.Service.AttributiType
        
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
        Public Property IdEsterno() As String
            Get
                Return Me.IdEsternoField
            End Get
            Set
                If (Object.ReferenceEquals(Me.IdEsternoField, value) <> true) Then
                    Me.IdEsternoField = value
                    Me.RaisePropertyChanged("IdEsterno")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(IsRequired:=true, EmitDefaultValue:=false)>  _
        Public Property TipoContenuto() As String
            Get
                Return Me.TipoContenutoField
            End Get
            Set
                If (Object.ReferenceEquals(Me.TipoContenutoField, value) <> true) Then
                    Me.TipoContenutoField = value
                    Me.RaisePropertyChanged("TipoContenuto")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(IsRequired:=true, EmitDefaultValue:=false, Order:=2)>  _
        Public Property Contenuto() As Byte()
            Get
                Return Me.ContenutoField
            End Get
            Set
                If (Object.ReferenceEquals(Me.ContenutoField, value) <> true) Then
                    Me.ContenutoField = value
                    Me.RaisePropertyChanged("Contenuto")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue:=false, Order:=3)>  _
        Public Property Attributi() As Dwh.DataAccess.Wcf.Service.AttributiType
            Get
                Return Me.AttributiField
            End Get
            Set
                If (Object.ReferenceEquals(Me.AttributiField, value) <> true) Then
                    Me.AttributiField = value
                    Me.RaisePropertyChanged("Attributi")
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
     System.Runtime.Serialization.DataContractAttribute(Name:="PrescrizioneReturn", [Namespace]:="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0"),  _
     System.SerializableAttribute()>  _
    Partial Public Class PrescrizioneReturn
        Inherits Object
        Implements System.Runtime.Serialization.IExtensibleDataObject, System.ComponentModel.INotifyPropertyChanged
        
        <System.NonSerializedAttribute()>  _
        Private extensionDataField As System.Runtime.Serialization.ExtensionDataObject
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private PrescrizioneField As Dwh.DataAccess.Wcf.Service.PrescrizioneType
        
        <System.Runtime.Serialization.OptionalFieldAttribute()>  _
        Private ErroreField As Dwh.DataAccess.Wcf.Service.ErroreType
        
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
        Public Property Prescrizione() As Dwh.DataAccess.Wcf.Service.PrescrizioneType
            Get
                Return Me.PrescrizioneField
            End Get
            Set
                If (Object.ReferenceEquals(Me.PrescrizioneField, value) <> true) Then
                    Me.PrescrizioneField = value
                    Me.RaisePropertyChanged("Prescrizione")
                End If
            End Set
        End Property
        
        <System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue:=false, Order:=1)>  _
        Public Property Errore() As Dwh.DataAccess.Wcf.Service.ErroreType
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
     System.Runtime.Serialization.DataContractAttribute(Name:="ErroreType", [Namespace]:="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0"),  _
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
    
    <System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0"),  _
     System.ServiceModel.ServiceContractAttribute([Namespace]:="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0", ConfigurationName:="Dwh.DataAccess.Wcf.Service.IPrescrizioni")>  _
    Public Interface IPrescrizioni
        
        <System.ServiceModel.OperationContractAttribute(Action:="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0/IPrescrizioni/Aggiung"& _ 
            "i", ReplyAction:="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0/IPrescrizioni/Aggiung"& _ 
            "iResponse")>  _
        Function Aggiungi(ByVal Prescrizione As Dwh.DataAccess.Wcf.Service.PrescrizioneParameter) As Dwh.DataAccess.Wcf.Service.PrescrizioneReturn
        
        <System.ServiceModel.OperationContractAttribute(Action:="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0/IPrescrizioni/Rimuovi"& _ 
            "", ReplyAction:="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0/IPrescrizioni/Rimuovi"& _ 
            "Response")>  _
        Function Rimuovi(ByVal IdEsterno As String, ByVal DataModificaEsterno As Date) As Dwh.DataAccess.Wcf.Service.ErroreType
    End Interface
    
    <System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")>  _
    Public Interface IPrescrizioniChannel
        Inherits Dwh.DataAccess.Wcf.Service.IPrescrizioni, System.ServiceModel.IClientChannel
    End Interface
    
    <System.Diagnostics.DebuggerStepThroughAttribute(),  _
     System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")>  _
    Partial Public Class PrescrizioniClient
        Inherits System.ServiceModel.ClientBase(Of Dwh.DataAccess.Wcf.Service.IPrescrizioni)
        Implements Dwh.DataAccess.Wcf.Service.IPrescrizioni
        
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
        
        Public Function Aggiungi(ByVal Prescrizione As Dwh.DataAccess.Wcf.Service.PrescrizioneParameter) As Dwh.DataAccess.Wcf.Service.PrescrizioneReturn Implements Dwh.DataAccess.Wcf.Service.IPrescrizioni.Aggiungi
            Return MyBase.Channel.Aggiungi(Prescrizione)
        End Function
        
        Public Function Rimuovi(ByVal IdEsterno As String, ByVal DataModificaEsterno As Date) As Dwh.DataAccess.Wcf.Service.ErroreType Implements Dwh.DataAccess.Wcf.Service.IPrescrizioni.Rimuovi
            Return MyBase.Channel.Rimuovi(IdEsterno, DataModificaEsterno)
        End Function
    End Class
End Namespace
