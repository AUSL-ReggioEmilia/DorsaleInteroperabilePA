Imports System.Data.Linq

Module Extensions

	''' <summary>
	''' Metodo Substring che non dà errore se si tentano di recuperare più caratteri di quelli disponibili nella stringa
	''' </summary>
	<System.Runtime.CompilerServices.Extension()>
	Public Function SafeSubstring(value As String, startIndex As Integer, length As Integer) As String
		Return New String((If(value, String.Empty)).Skip(startIndex).Take(length).ToArray())
	End Function

	''' <summary>
	''' VERIFICA SE L'OGGETTO PASSATO È GIÀ PRESENTE NELLA TABELLA
	''' </summary>
	<System.Runtime.CompilerServices.Extension()>
	Public Function Contains(table As ITable, PredicateEntity As Object) As Boolean

		Dim qry = From r In table Where r Is PredicateEntity
		Return qry.Count > 0

	End Function

	''' <summary>
	''' 
	''' </summary>
	<System.Runtime.CompilerServices.Extension()>
	Public Function FindFirst(table As ITable, PredicateEntity As Object) As Object

		Dim qry = From r In table Where r Is PredicateEntity Select r
		Dim o = qry.FirstOrDefault

		Return o

	End Function

End Module
