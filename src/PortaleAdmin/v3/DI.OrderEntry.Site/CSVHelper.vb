Imports System.Data
Imports System
Imports System.Text
Imports System.Globalization

Public Class CSVHelper
	Public Const Size10MB As Integer = 1024 * 1024 * 10
	Public Const FieldSeparator As Char = ","c
	Public Const RowSeparator As String = Microsoft.VisualBasic.vbCrLf

	Private Shared ReadOnly sRowSep As String() = {RowSeparator}
	Private Shared ReadOnly cFieldSep As Char() = {FieldSeparator}
	Private Shared ReadOnly sUTF8Preamble As String = Encoding.UTF8.GetString(Encoding.UTF8.GetPreamble())


	''' <summary>
	''' Converte un file CSV in una datatable, si aspetta di trovare le intestazioni di colonna nella prima riga
	''' </summary>
	Public Shared Function CsvToDataTable(ByRef ByteArray As Byte()) As DataTable

		Dim dtOut As New DataTable
		dtOut.CaseSensitive = False
		Dim sBuffer = Encoding.UTF8.GetString(ByteArray)
		'rimuovo un eventuale BOM
		If sBuffer.StartsWith(sUTF8Preamble) Then sBuffer = sBuffer.Remove(0, sUTF8Preamble.Length)

		Dim sRowsArray = sBuffer.Split(sRowSep, StringSplitOptions.RemoveEmptyEntries)
		sBuffer = Nothing

		Dim sFieldsArray As String()
        For iRow As Integer = 0 To sRowsArray.GetUpperBound(0)
            Dim sRowString = sRowsArray(iRow)
            If sRowString.EndsWith(",") Then
                sRowString = sRowString.Substring(0, sRowString.Length - 1)
            End If
            'sFieldsArray = sRowsArray(iRow).Split(cFieldSep, StringSplitOptions.RemoveEmptyEntries)
            sFieldsArray = sRowString.Split(cFieldSep)
            If iRow = 0 Then
				For Each sColName As String In sFieldsArray
                dtOut.Columns.Add(sColName)
            Next
            Else
            dtOut.Rows.Add(sFieldsArray)
            End If
        Next

        Return dtOut

	End Function

	Public Shared Function IsValidUTF8(ByteArray As Byte()) As Boolean

		Dim bom As Byte() = Encoding.UTF8.GetPreamble()
		For c As Integer = 0 To bom.Length - 1
			If ByteArray.Length < c + 1 OrElse Not ByteArray(c) = bom(c) Then
				Return False
			End If
		Next
		Return True

	End Function

	''' <summary>
	''' Controlla se la prima riga del file contiene tutte le stringhe nell'array TestValues (anche in ordine sparso)
	''' </summary>
	''' <param name="csvFile"></param>
	''' <param name="TestValues"></param>
	Public Shared Function FirstLineContainsValues(csvFile As Byte(), TestValues As Collections.IEnumerable) As String
		Dim sRet As String = ""

		Dim sLine = ReadFirstLine(csvFile)
		If sLine = "" Then Return "Intestazione mancante."

		Dim sLineValues = sLine.Split(cFieldSep, StringSplitOptions.RemoveEmptyEntries)

		For Each sVal In TestValues
			If StringArrayInvariantCultureIndexOf(sLineValues, sVal) = -1 Then
				sRet = sRet & "'" & sVal & "' mancante, "
			End If
		Next

		Return sRet
	End Function

	''' <summary>
	''' Cerca Value nell'array passato, se lo trova restituisce l'indice della sua posizione, altrimenti -1
	''' InvariantCulture - IgnoreCase
	''' </summary>
	Private Shared Function StringArrayInvariantCultureIndexOf(stringArray As String(), Value As String) As Integer
		Dim cInvariantCulture As New CultureInfo(CultureInfo.InvariantCulture.LCID)

		For i As Integer = stringArray.GetLowerBound(0) To stringArray.GetUpperBound(0)
			If String.Compare(stringArray(i), Value, True, cInvariantCulture) = 0 Then
				Return i
			End If
		Next

		Return -1
	End Function

	Public Shared Function ReadFirstLine(bArray As Byte()) As String

		Const CR As Byte = 13
		Dim pos = Array.IndexOf(bArray, CR)
		If pos = -1 Then Return String.Empty
		Dim PreambleLength = Encoding.UTF8.GetPreamble().Length
		Return Encoding.UTF8.GetString(bArray, PreambleLength, pos - PreambleLength)

	End Function

End Class
