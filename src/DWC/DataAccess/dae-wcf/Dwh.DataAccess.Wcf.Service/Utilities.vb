Module Utilities


	''' <summary>
	''' Se l'oggetto è Nothing restituisce NullString
	''' </summary>
	<System.Runtime.CompilerServices.Extension()>
	Public Function NullSafeToString(Of T)(this As T, Optional NullString As String = "") As String
		If this Is Nothing Then
			Return NullString
		End If
		Return this.ToString()
	End Function


	''' <summary>
	''' Ritorna DefaultValue se Value è NULL, altrimenti Value
	''' </summary>
	Public Function IsNull(Of T)(ByVal Value As T, ByVal DefaultValue As T) As T
		If Value Is Nothing OrElse Convert.IsDBNull(Value) Then
			Return DefaultValue
		Else
			Return Value
		End If
	End Function


	''' <summary>
	''' Concatena i Values distinti presenti nella lista, usando il separatore passato
	''' </summary>
	<Runtime.CompilerServices.Extension>
	Public Function ConcatDistinctValues(input As IEnumerable(Of Xml.Linq.XElement), Separator As String) As String
		If Not input.Any Then Return ""
		'Dim sArr As New HashSet(Of String)
		'For Each item In input
		'	'HashSet per definizione non ammette duplicati e non da errore
		'	sArr.Add(item.Value)
		'Next
		'Return String.Join(Separator, sArr.ToArray)

		Return String.Join(Separator, (input.[Select](Function(x) x.Value).Distinct).ToArray)

	End Function


End Module
