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


<Global.System.Data.Linq.Mapping.DatabaseAttribute(Name:="AuslAsmnRe_DwhClinicoMMG")>  _
Partial Public Class DwhClinicoMMGDataContext
	Inherits System.Data.Linq.DataContext
	
	Private Shared mappingSource As System.Data.Linq.Mapping.MappingSource = New AttributeMappingSource()
	
  #Region "Extensibility Method Definitions"
  Partial Private Sub OnCreated()
  End Sub
  Partial Private Sub InsertSistemiAbilitati(instance As SistemiAbilitati)
    End Sub
  Partial Private Sub UpdateSistemiAbilitati(instance As SistemiAbilitati)
    End Sub
  Partial Private Sub DeleteSistemiAbilitati(instance As SistemiAbilitati)
    End Sub
  #End Region
	
	Public Sub New()
		MyBase.New(Global.System.Configuration.ConfigurationManager.ConnectionStrings("AuslAsmnRe_DwhClinicoMMGConnectionString").ConnectionString, mappingSource)
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
	
	Public ReadOnly Property SistemiAbilitati() As System.Data.Linq.Table(Of SistemiAbilitati)
		Get
			Return Me.GetTable(Of SistemiAbilitati)
		End Get
	End Property
End Class

<Global.System.Data.Linq.Mapping.TableAttribute(Name:="dbo.SistemiAbilitati")>  _
Partial Public Class SistemiAbilitati
	Implements System.ComponentModel.INotifyPropertyChanging, System.ComponentModel.INotifyPropertyChanged
	
	Private Shared emptyChangingEventArgs As PropertyChangingEventArgs = New PropertyChangingEventArgs(String.Empty)
	
	Private _Id As System.Guid
	
	Private _SistemaErogante As String
	
	Private _SpecialitaErogante As String
	
    #Region "Extensibility Method Definitions"
    Partial Private Sub OnLoaded()
    End Sub
    Partial Private Sub OnValidate(action As System.Data.Linq.ChangeAction)
    End Sub
    Partial Private Sub OnCreated()
    End Sub
    Partial Private Sub OnIdChanging(value As System.Guid)
    End Sub
    Partial Private Sub OnIdChanged()
    End Sub
    Partial Private Sub OnSistemaEroganteChanging(value As String)
    End Sub
    Partial Private Sub OnSistemaEroganteChanged()
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
	
	<Global.System.Data.Linq.Mapping.ColumnAttribute(Storage:="_Id", AutoSync:=AutoSync.OnInsert, DbType:="UniqueIdentifier NOT NULL", IsPrimaryKey:=true, IsDbGenerated:=true)>  _
	Public Property Id() As System.Guid
		Get
			Return Me._Id
		End Get
		Set
			If ((Me._Id = value)  _
						= false) Then
				Me.OnIdChanging(value)
				Me.SendPropertyChanging
				Me._Id = value
				Me.SendPropertyChanged("Id")
				Me.OnIdChanged
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
	
	<Global.System.Data.Linq.Mapping.ColumnAttribute(Storage:="_SpecialitaErogante", DbType:="VarChar(64)")>  _
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
