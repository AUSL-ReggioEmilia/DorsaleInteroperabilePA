Imports System.Xml.Serialization
Imports System.Text
Imports System.Runtime.Serialization


''' <summary>
''' Metodi Shared di serializzazione
''' </summary>
Public Class GenericSerializer

	''' <summary>
	''' Serializza l'oggetto deducendone il tipo
	''' </summary>
	Public Shared Function Serialize(Of T)(ByVal oInstance As T) As String
		Try
			Using memStream As New IO.MemoryStream

				Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
				oSerializer.Serialize(memStream, oInstance)

				Dim oEnc As Encoding = Encoding.UTF8
				Dim sXml As String = oEnc.GetString(memStream.ToArray())

				Return sXml
			End Using

		Catch ex As Exception
			Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)
		End Try
	End Function

	''' <summary>
	''' Serializza l'oggetto imponendo il tipo
	''' </summary>
	Public Shared Function Serialize(ByVal oInstance As Object) As String
		Try
			Using memStream As New IO.MemoryStream

				Dim oSerializer As XmlSerializer = New XmlSerializer(oInstance.GetType)
				oSerializer.Serialize(memStream, oInstance)

				Dim oEnc As Encoding = Encoding.UTF8
				Dim sXml As String = oEnc.GetString(memStream.ToArray())

				Return sXml
			End Using

		Catch ex As Exception
			Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)
		End Try
	End Function

	Public Shared Function Deserialize(Of T)(ByVal XmlData As String) As T
		Try
			Using memStream As New IO.MemoryStream
				Dim oEnc As Encoding = Encoding.UTF8

				memStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
				memStream.Position = 0

				Dim oInstance As T

				Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
				oInstance = CType(oSerializer.Deserialize(memStream), T)

				Return oInstance
			End Using

		Catch ex As Exception

			Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

		End Try

	End Function

End Class


''' <summary>
''' Classe di base per rendere qualsiasi classe che ne deriva serializzabile (solo le proprietà pubbliche)
''' </summary>
Public MustInherit Class BaseSerializer(Of T)

	''' <summary>
	''' Serializza l'oggetto e ne ritorna l'xml
	''' </summary>
	<CLSCompliant(False)> _
	Public Function Serialize() As String
		Try
			Using memStream As New IO.MemoryStream
				Dim oSerializer As XmlSerializer = New XmlSerializer(Me.GetType())
				oSerializer.Serialize(memStream, Me)
				Dim oEnc As Encoding = Encoding.UTF8
				Dim sXml As String = oEnc.GetString(memStream.ToArray())

				Return sXml
			End Using

		Catch ex As Exception
			'
			' Log e eccezione
			'
			Throw New ApplicationException("Errore durante Serialize di; " & Me.GetType().ToString & " - " & ex.Message, ex)

		End Try
	End Function

	''' <summary>
	''' Genera e ritorna una nuova istanza dell'oggetto dello stesso tipo dell'istanza in uso
	''' </summary>
	<CLSCompliant(False)> _
	Public Function Deserialize(ByVal XmlData As String) As T

		Try
			Using memStream As New IO.MemoryStream
				Dim oEnc As Encoding = Encoding.UTF8

				memStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
				memStream.Position = 0

				'no Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
				'no Dim oSerializer = New XmlSerializer(GetType(T))
				Dim oSerializer = New XmlSerializer(Me.GetType())
				Return CType(oSerializer.Deserialize(memStream), T)

			End Using

		Catch ex As Exception
			'
			' Log e eccezione
			'
			Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

		End Try

	End Function


	'
	' METODI SHARED
	'

	''' <summary>
	''' Genera e ritorna una nuova istanza dell'oggetto del tipo specificato
	''' </summary>
	<CLSCompliant(False)> _
	Public Shared Function Deserialize(Type As Type, ByVal XmlData As String) As T

		Try
			Using memStream As New IO.MemoryStream
				Dim oEnc As Encoding = Encoding.UTF8

				memStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
				memStream.Position = 0

				Dim oSerializer = New XmlSerializer(Type)
				Return CType(oSerializer.Deserialize(memStream), T)

			End Using

		Catch ex As Exception
			'
			' Log e eccezione
			'
			Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

		End Try

	End Function

	'<CLSCompliant(False)> _
	'Public Function Deserialize(ByVal InputStream As IO.Stream) As T

	'	Try
	'		Dim oInstance As T

	'		Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
	'		InputStream.Position = 0
	'		oInstance = CType(oSerializer.Deserialize(InputStream), T)

	'		Return oInstance

	'	Catch ex As Exception
	'		'
	'		' Log e eccezione
	'		'
	'		Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

	'	End Try
	'End Function

	'<CLSCompliant(False)> _
	'Public Shared Sub Serialize(ByVal Instance As T, ByVal OutputStream As IO.Stream)
	'	'
	'	' Serializzo
	'	'
	'	Try
	'		Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
	'		oSerializer.Serialize(OutputStream, Instance)
	'		OutputStream.Position = 0

	'	Catch ex As Exception
	'		'
	'		' Log e eccezione
	'		'
	'		Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)

	'	End Try

	'End Sub

	'Public Function GetXml() As String
	'	'
	'	' Serializzo
	'	'
	'	Try
	'		Using memStream As New IO.MemoryStream

	'			Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
	'			oSerializer.Serialize(memStream, Me)

	'			Dim oEnc As Encoding = Encoding.UTF8
	'			Dim sXml As String = oEnc.GetString(memStream.ToArray())

	'			Return sXml
	'		End Using

	'	Catch ex As Exception
	'		'
	'		' Log e eccezione
	'		'
	'		Throw New ApplicationException("Errore durante GetXml()!; " & ex.Message, ex)

	'	End Try

	'End Function

End Class


Public Class GenericDataContractSerializer

    Public Shared Function Serialize(Of T)(ByVal value As T) As String
        Try
            Using stream As New IO.MemoryStream
                Dim oDataSerializer As New DataContractSerializer(GetType(T))
                oDataSerializer.WriteObject(stream, value)

                stream.Position = 0
                Return System.Text.Encoding.UTF8.GetString(stream.ToArray)
            End Using

        Catch ex As Exception
            Return ex.Message
        End Try

    End Function


    Public Shared Function Deserialize(Of T)(ByVal XmlData As String) As T
        Using memStream As New IO.MemoryStream
            Dim oEnc As Encoding = Encoding.UTF8
            Dim oSerializer As New DataContractSerializer(GetType(T))

            memStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
            memStream.Position = 0

            Dim oInstance As T = CType(oSerializer.ReadObject(memStream), T)
            Return oInstance
        End Using
    End Function

End Class