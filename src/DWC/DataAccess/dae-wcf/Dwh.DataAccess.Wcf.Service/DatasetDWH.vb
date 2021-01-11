Imports System.Data

Partial Class DWHDataSet
End Class

Namespace DWHDataSetTableAdapters
	'
	' ESTENDO LE CLASSI TABLEADAPTER PER AGGIUNGERE IL PASSAGGIO DI CONNECTION E TRANSACTION DALL'ESTERNO
	'

	Partial Public Class PrescrizioniAggiungiTableAdapter
		Public ReadOnly Property ReturnValue As Integer
			Get
				Debug.Assert(Me.CommandCollection.Count = 1, "IL NUMERO DI SQLCOMMAND NELL'ADAPTER DEVE ESSERE=1")
				Return CInt(Me.CommandCollection(0).Parameters("@RETURN_VALUE").Value)
			End Get
		End Property

		''' <summary>
		''' Assegnazione a tutti i SqlCommand di un'unica connessione e opzionalmente una transazione
		''' </summary>
		Public Sub New(Conn As SqlClient.SqlConnection, Optional Trans As SqlClient.SqlTransaction = Nothing)
			MyBase.New()

			For Each QueryCommand In Me.CommandCollection
				QueryCommand.Connection = Conn
				If Trans IsNot Nothing Then
					QueryCommand.Transaction = Trans
				End If
			Next
		End Sub
	End Class


	Partial Public Class PrescrizioniRimuoviTableAdapter
		Public ReadOnly Property ReturnValue As Integer
			Get
				Debug.Assert(Me.CommandCollection.Count = 1, "IL NUMERO DI SQLCOMMAND NELL'ADAPTER DEVE ESSERE=1")
				Return CInt(Me.CommandCollection(0).Parameters("@RETURN_VALUE").Value)
			End Get
		End Property

		''' <summary>
		''' Assegnazione a tutti i SqlCommand di un'unica connessione e opzionalmente una transazione
		''' </summary>
		Public Sub New(Conn As SqlClient.SqlConnection, Optional Trans As SqlClient.SqlTransaction = Nothing)
			MyBase.New()

			For Each QueryCommand In Me.CommandCollection
				QueryCommand.Connection = Conn
				If Trans IsNot Nothing Then
					QueryCommand.Transaction = Trans
				End If
			Next
		End Sub
	End Class

	Partial Public Class PrescrizioniAllegatiAggiungiTableAdapter
		Public ReadOnly Property ReturnValue As Integer
			Get
				Debug.Assert(Me.CommandCollection.Count = 1, "IL NUMERO DI SQLCOMMAND NELL'ADAPTER DEVE ESSERE=1")
				Return CInt(Me.CommandCollection(0).Parameters("@RETURN_VALUE").Value)
			End Get
		End Property

		''' <summary>
		''' Assegnazione a tutti i SqlCommand di un'unica connessione e opzionalmente una transazione
		''' </summary>
		Public Sub New(Conn As SqlClient.SqlConnection, Optional Trans As SqlClient.SqlTransaction = Nothing)
			MyBase.New()

			For Each QueryCommand In Me.CommandCollection
				QueryCommand.Connection = Conn
				If Trans IsNot Nothing Then
					QueryCommand.Transaction = Trans
				End If
			Next
		End Sub
	End Class


	Partial Public Class PrescrizioniAllegatiRimuoviTableAdapter
		Public ReadOnly Property ReturnValue As Integer
			Get
				Debug.Assert(Me.CommandCollection.Count = 1, "IL NUMERO DI SQLCOMMAND NELL'ADAPTER DEVE ESSERE=1")
				Return CInt(Me.CommandCollection(0).Parameters("@RETURN_VALUE").Value)
			End Get
		End Property

		''' <summary>
		''' Assegnazione a tutti i SqlCommand di un'unica connessione e opzionalmente una transazione
		''' </summary>
		Public Sub New(Conn As SqlClient.SqlConnection, Optional Trans As SqlClient.SqlTransaction = Nothing)
			MyBase.New()

			For Each QueryCommand In Me.CommandCollection
				QueryCommand.Connection = Conn
				If Trans IsNot Nothing Then
					QueryCommand.Transaction = Trans
				End If
			Next
		End Sub
	End Class


	Partial Public Class PrescrizioniEsisteTableAdapter
		Public ReadOnly Property ReturnValue As Integer
			Get
				Debug.Assert(Me.CommandCollection.Count = 1, "IL NUMERO DI SQLCOMMAND NELL'ADAPTER DEVE ESSERE=1")
				Return CInt(Me.CommandCollection(0).Parameters("@RETURN_VALUE").Value)
			End Get
		End Property

		''' <summary>
		''' Assegnazione a tutti i SqlCommand di un'unica connessione e opzionalmente una transazione
		''' </summary>
		Public Sub New(Conn As SqlClient.SqlConnection, Optional Trans As SqlClient.SqlTransaction = Nothing)
			MyBase.New()

			For Each QueryCommand In Me.CommandCollection
				QueryCommand.Connection = Conn
				If Trans IsNot Nothing Then
					QueryCommand.Transaction = Trans
				End If
			Next
		End Sub
	End Class


	Partial Public Class PrescrizioniNotificaTableAdapter
		Public ReadOnly Property ReturnValue As Integer
			Get
				Debug.Assert(Me.CommandCollection.Count = 1, "IL NUMERO DI SQLCOMMAND NELL'ADAPTER DEVE ESSERE=1")
				Return CInt(Me.CommandCollection(0).Parameters("@RETURN_VALUE").Value)
			End Get
		End Property

		''' <summary>
		''' Assegnazione a tutti i SqlCommand di un'unica connessione e opzionalmente una transazione
		''' </summary>
		Public Sub New(Conn As SqlClient.SqlConnection, Optional Trans As SqlClient.SqlTransaction = Nothing)
			MyBase.New()

			For Each QueryCommand In Me.CommandCollection
				QueryCommand.Connection = Conn
				If Trans IsNot Nothing Then
					QueryCommand.Transaction = Trans
				End If
			Next
		End Sub
	End Class

End Namespace

