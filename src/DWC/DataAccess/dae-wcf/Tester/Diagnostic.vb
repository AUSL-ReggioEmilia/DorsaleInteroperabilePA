Imports System.Configuration

Public Class Diagnostic

	''' <summary>
	''' Ritorna true se l'eseguibile è stato complilato in Debug mode
	''' </summary>
	Public Shared ReadOnly Property InDebug() As Boolean
		Get
#If DEBUG Then
			Return True
#End If
			Return False
		End Get
	End Property



End Class
