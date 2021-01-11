Module Extension
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
    ''' Stringa con prima lettera maiuscola
    ''' </summary>
    <System.Runtime.CompilerServices.Extension()>
    Public Function Capitalize(input As String) As String
        ' Check for empty string.
        If String.IsNullOrEmpty(input) Then
            Return String.Empty
        End If
        ' Return char and concat substring.
        Return Char.ToUpper(input(0)) + input.Substring(1)
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

End Module
