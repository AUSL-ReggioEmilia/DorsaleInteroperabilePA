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
Imports System.Collections.Generic
Imports System.ComponentModel
Imports System.Data
Imports System.Data.Linq
Imports System.Data.Linq.Mapping
Imports System.Linq
Imports System.Linq.Expressions
Imports System.Reflection


<Global.System.Data.Linq.Mapping.DatabaseAttribute(Name:="AuslAsmnRe_DwhConnAnthema")>  _
Partial Public Class DwhConnAnthemaDataContext
	Inherits System.Data.Linq.DataContext
	
	Private Shared mappingSource As System.Data.Linq.Mapping.MappingSource = New AttributeMappingSource()
	
  #Region "Extensibility Method Definitions"
  Partial Private Sub OnCreated()
  End Sub
  Partial Private Sub InsertCentriRichiedenti(instance As CentriRichiedenti)
    End Sub
  Partial Private Sub UpdateCentriRichiedenti(instance As CentriRichiedenti)
    End Sub
  Partial Private Sub DeleteCentriRichiedenti(instance As CentriRichiedenti)
    End Sub
  #End Region
	
	Public Sub New()
		MyBase.New(Global.System.Configuration.ConfigurationManager.ConnectionStrings("AuslAsmnRe_DwhConnAnthemaConnectionString").ConnectionString, mappingSource)
		OnCreated
	End Sub
	
	Public Sub New(ByVal connection As String)
		MyBase.New(connection, mappingSource)
		OnCreated
	End Sub
	
	Public Sub New(ByVal connection As System.Data.IDbConnection)
		MyBase.New(connection, mappingSource)
		OnCreated
	End Sub
	
	Public Sub New(ByVal connection As String, ByVal mappingSource As System.Data.Linq.Mapping.MappingSource)
		MyBase.New(connection, mappingSource)
		OnCreated
	End Sub
	
	Public Sub New(ByVal connection As System.Data.IDbConnection, ByVal mappingSource As System.Data.Linq.Mapping.MappingSource)
		MyBase.New(connection, mappingSource)
		OnCreated
	End Sub
	
	Public ReadOnly Property CentriRichiedenti() As System.Data.Linq.Table(Of CentriRichiedenti)
		Get
			Return Me.GetTable(Of CentriRichiedenti)
		End Get
	End Property
End Class

<Global.System.Data.Linq.Mapping.TableAttribute(Name:="dbo.CentriRichiedenti")>  _
Partial Public Class CentriRichiedenti
	Implements System.ComponentModel.INotifyPropertyChanging, System.ComponentModel.INotifyPropertyChanged
	
	Private Shared emptyChangingEventArgs As PropertyChangingEventArgs = New PropertyChangingEventArgs(String.Empty)
	
	Private _Nome As String
	
	Private _Descrizione As String
	
	Private _Codice As String
	
	Private _PuntoPrelievo As String
	
	Private _CodiceLIS As String
	
	Private _AziendaErogante As String
	
	Private _SistemaErogante As String
	
	Private _AziendaRichiedente As String
	
	Private _SistemaRichiedente As String
	
	Private _PCInvioRichiesta As String
	
	Private _RepartoErogante As String
	
	Private _SezioneErogante As String
	
	Private _SpecialitaErogante As String
	
    #Region "Extensibility Method Definitions"
    Partial Private Sub OnLoaded()
    End Sub
    Partial Private Sub OnValidate(action As System.Data.Linq.ChangeAction)
    End Sub
    Partial Private Sub OnCreated()
    End Sub
    Partial Private Sub OnNomeChanging(value As String)
    End Sub
    Partial Private Sub OnNomeChanged()
    End Sub
    Partial Private Sub OnDescrizioneChanging(value As String)
    End Sub
    Partial Private Sub OnDescrizioneChanged()
    End Sub
    Partial Private Sub OnCodiceChanging(value As String)
    End Sub
    Partial Private Sub OnCodiceChanged()
    End Sub
    Partial Private Sub OnPuntoPrelievoChanging(value As String)
    End Sub
    Partial Private Sub OnPuntoPrelievoChanged()
    End Sub
    Partial Private Sub OnCodiceLISChanging(value As String)
    End Sub
    Partial Private Sub OnCodiceLISChanged()
    End Sub
    Partial Private Sub OnAziendaEroganteChanging(value As String)
    End Sub
    Partial Private Sub OnAziendaEroganteChanged()
    End Sub
    Partial Private Sub OnSistemaEroganteChanging(value As String)
    End Sub
    Partial Private Sub OnSistemaEroganteChanged()
    End Sub
    Partial Private Sub OnAziendaRichiedenteChanging(value As String)
    End Sub
    Partial Private Sub OnAziendaRichiedenteChanged()
    End Sub
    Partial Private Sub OnSistemaRichiedenteChanging(value As String)
    End Sub
    Partial Private Sub OnSistemaRichiedenteChanged()
    End Sub
    Partial Private Sub OnPCInvioRichiestaChanging(value As String)
    End Sub
    Partial Private Sub OnPCInvioRichiestaChanged()
    End Sub
    Partial Private Sub OnRepartoEroganteChanging(value As String)
    End Sub
    Partial Private Sub OnRepartoEroganteChanged()
    End Sub
    Partial Private Sub OnSezioneEroganteChanging(value As String)
    End Sub
    Partial Private Sub OnSezioneEroganteChanged()
    End Sub
    Partial Private Sub OnSpecialitaEroganteChanging(value As String)
    End Sub
    Partial Private Sub OnSpecialitaEroganteChanged()
    End Sub
    #End Region
	
	Public Sub New()
		MyBase.New
		OnCreated
	End Sub
	
	<Global.System.Data.Linq.Mapping.ColumnAttribute(Storage:="_Nome", DbType:="VarChar(64) NOT NULL", CanBeNull:=false)>  _
	Public Property Nome() As String
		Get
			Return Me._Nome
		End Get
		Set
			If (String.Equals(Me._Nome, value) = false) Then
				Me.OnNomeChanging(value)
				Me.SendPropertyChanging
				Me._Nome = value
				Me.SendPropertyChanged("Nome")
				Me.OnNomeChanged
			End If
		End Set
	End Property
	
	<Global.System.Data.Linq.Mapping.ColumnAttribute(Storage:="_Descrizione", DbType:="VarChar(128)")>  _
	Public Property Descrizione() As String
		Get
			Return Me._Descrizione
		End Get
		Set
			If (String.Equals(Me._Descrizione, value) = false) Then
				Me.OnDescrizioneChanging(value)
				Me.SendPropertyChanging
				Me._Descrizione = value
				Me.SendPropertyChanged("Descrizione")
				Me.OnDescrizioneChanged
			End If
		End Set
	End Property
	
	<Global.System.Data.Linq.Mapping.ColumnAttribute(Storage:="_Codice", DbType:="VarChar(64) NOT NULL", CanBeNull:=false, IsPrimaryKey:=true)>  _
	Public Property Codice() As String
		Get
			Return Me._Codice
		End Get
		Set
			If (String.Equals(Me._Codice, value) = false) Then
				Me.OnCodiceChanging(value)
				Me.SendPropertyChanging
				Me._Codice = value
				Me.SendPropertyChanged("Codice")
				Me.OnCodiceChanged
			End If
		End Set
	End Property
	
	<Global.System.Data.Linq.Mapping.ColumnAttribute(Storage:="_PuntoPrelievo", DbType:="VarChar(64) NOT NULL", CanBeNull:=false, IsPrimaryKey:=true)>  _
	Public Property PuntoPrelievo() As String
		Get
			Return Me._PuntoPrelievo
		End Get
		Set
			If (String.Equals(Me._PuntoPrelievo, value) = false) Then
				Me.OnPuntoPrelievoChanging(value)
				Me.SendPropertyChanging
				Me._PuntoPrelievo = value
				Me.SendPropertyChanged("PuntoPrelievo")
				Me.OnPuntoPrelievoChanged
			End If
		End Set
	End Property
	
	<Global.System.Data.Linq.Mapping.ColumnAttribute(Storage:="_CodiceLIS", DbType:="VarChar(64) NOT NULL", CanBeNull:=false)>  _
	Public Property CodiceLIS() As String
		Get
			Return Me._CodiceLIS
		End Get
		Set
			If (String.Equals(Me._CodiceLIS, value) = false) Then
				Me.OnCodiceLISChanging(value)
				Me.SendPropertyChanging
				Me._CodiceLIS = value
				Me.SendPropertyChanged("CodiceLIS")
				Me.OnCodiceLISChanged
			End If
		End Set
	End Property
	
	<Global.System.Data.Linq.Mapping.ColumnAttribute(Storage:="_AziendaErogante", DbType:="VarChar(16) NOT NULL", CanBeNull:=false)>  _
	Public Property AziendaErogante() As String
		Get
			Return Me._AziendaErogante
		End Get
		Set
			If (String.Equals(Me._AziendaErogante, value) = false) Then
				Me.OnAziendaEroganteChanging(value)
				Me.SendPropertyChanging
				Me._AziendaErogante = value
				Me.SendPropertyChanged("AziendaErogante")
				Me.OnAziendaEroganteChanged
			End If
		End Set
	End Property
	
	<Global.System.Data.Linq.Mapping.ColumnAttribute(Storage:="_SistemaErogante", DbType:="VarChar(16) NOT NULL", CanBeNull:=false)>  _
	Public Property SistemaErogante() As String
		Get
			Return Me._SistemaErogante
		End Get
		Set
			If (String.Equals(Me._SistemaErogante, value) = false) Then
				Me.OnSistemaEroganteChanging(value)
				Me.SendPropertyChanging
				Me._SistemaErogante = value
				Me.SendPropertyChanged("SistemaErogante")
				Me.OnSistemaEroganteChanged
			End If
		End Set
	End Property
	
	<Global.System.Data.Linq.Mapping.ColumnAttribute(Storage:="_AziendaRichiedente", DbType:="VarChar(16) NOT NULL", CanBeNull:=false)>  _
	Public Property AziendaRichiedente() As String
		Get
			Return Me._AziendaRichiedente
		End Get
		Set
			If (String.Equals(Me._AziendaRichiedente, value) = false) Then
				Me.OnAziendaRichiedenteChanging(value)
				Me.SendPropertyChanging
				Me._AziendaRichiedente = value
				Me.SendPropertyChanged("AziendaRichiedente")
				Me.OnAziendaRichiedenteChanged
			End If
		End Set
	End Property
	
	<Global.System.Data.Linq.Mapping.ColumnAttribute(Storage:="_SistemaRichiedente", DbType:="VarChar(16) NOT NULL", CanBeNull:=false)>  _
	Public Property SistemaRichiedente() As String
		Get
			Return Me._SistemaRichiedente
		End Get
		Set
			If (String.Equals(Me._SistemaRichiedente, value) = false) Then
				Me.OnSistemaRichiedenteChanging(value)
				Me.SendPropertyChanging
				Me._SistemaRichiedente = value
				Me.SendPropertyChanged("SistemaRichiedente")
				Me.OnSistemaRichiedenteChanged
			End If
		End Set
	End Property
	
	<Global.System.Data.Linq.Mapping.ColumnAttribute(Storage:="_PCInvioRichiesta", DbType:="VarChar(64) NOT NULL", CanBeNull:=false)>  _
	Public Property PCInvioRichiesta() As String
		Get
			Return Me._PCInvioRichiesta
		End Get
		Set
			If (String.Equals(Me._PCInvioRichiesta, value) = false) Then
				Me.OnPCInvioRichiestaChanging(value)
				Me.SendPropertyChanging
				Me._PCInvioRichiesta = value
				Me.SendPropertyChanged("PCInvioRichiesta")
				Me.OnPCInvioRichiestaChanged
			End If
		End Set
	End Property
	
	<Global.System.Data.Linq.Mapping.ColumnAttribute(Storage:="_RepartoErogante", DbType:="VarChar(64)")>  _
	Public Property RepartoErogante() As String
		Get
			Return Me._RepartoErogante
		End Get
		Set
			If (String.Equals(Me._RepartoErogante, value) = false) Then
				Me.OnRepartoEroganteChanging(value)
				Me.SendPropertyChanging
				Me._RepartoErogante = value
				Me.SendPropertyChanged("RepartoErogante")
				Me.OnRepartoEroganteChanged
			End If
		End Set
	End Property
	
	<Global.System.Data.Linq.Mapping.ColumnAttribute(Storage:="_SezioneErogante", DbType:="VarChar(16)")>  _
	Public Property SezioneErogante() As String
		Get
			Return Me._SezioneErogante
		End Get
		Set
			If (String.Equals(Me._SezioneErogante, value) = false) Then
				Me.OnSezioneEroganteChanging(value)
				Me.SendPropertyChanging
				Me._SezioneErogante = value
				Me.SendPropertyChanged("SezioneErogante")
				Me.OnSezioneEroganteChanged
			End If
		End Set
	End Property
	
	<Global.System.Data.Linq.Mapping.ColumnAttribute(Storage:="_SpecialitaErogante", DbType:="VarChar(16)")>  _
	Public Property SpecialitaErogante() As String
		Get
			Return Me._SpecialitaErogante
		End Get
		Set
			If (String.Equals(Me._SpecialitaErogante, value) = false) Then
				Me.OnSpecialitaEroganteChanging(value)
				Me.SendPropertyChanging
				Me._SpecialitaErogante = value
				Me.SendPropertyChanged("SpecialitaErogante")
				Me.OnSpecialitaEroganteChanged
			End If
		End Set
	End Property
	
	Public Event PropertyChanging As PropertyChangingEventHandler Implements System.ComponentModel.INotifyPropertyChanging.PropertyChanging
	
	Public Event PropertyChanged As PropertyChangedEventHandler Implements System.ComponentModel.INotifyPropertyChanged.PropertyChanged
	
	Protected Overridable Sub SendPropertyChanging()
		If ((Me.PropertyChangingEvent Is Nothing)  _
					= false) Then
			RaiseEvent PropertyChanging(Me, emptyChangingEventArgs)
		End If
	End Sub
	
	Protected Overridable Sub SendPropertyChanged(ByVal propertyName As [String])
		If ((Me.PropertyChangedEvent Is Nothing)  _
					= false) Then
			RaiseEvent PropertyChanged(Me, New PropertyChangedEventArgs(propertyName))
		End If
	End Sub
End Class