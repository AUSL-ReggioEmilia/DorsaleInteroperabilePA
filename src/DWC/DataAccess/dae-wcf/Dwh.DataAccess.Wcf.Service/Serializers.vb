Imports System.Xml.Serialization
Imports System.Text

''' <summary>
''' Usa System.Xml.Serialization.XmlSerializer
''' </summary>
Public Class GenericXmlSerializer

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

	Public Shared Function Deserialize(Of T)(ByVal XmlData As String) As T
		Try
			Using memStream As New IO.MemoryStream

				Dim oEnc As Encoding = Encoding.Default
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
''' Usa System.Runtime.Serialization.DataContractSerializer
''' </summary>
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

End Class


''' <summary>
''' Classe di base per rendere qualsiasi classe che ne deriva serializzabile
''' </summary>
Public MustInherit Class BaseSerializer(Of T)

	<CLSCompliant(False)> _
	Public Shared Function Deserialize(ByVal XmlData As String) As T

		Try
			Using memStream As New IO.MemoryStream
				Dim oEnc As Encoding = Encoding.Default

				memStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
				memStream.Position = 0

				Dim oInstance As T

				Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
				oInstance = CType(oSerializer.Deserialize(memStream), T)

				Return oInstance
			End Using

		Catch ex As Exception
			'
			' Log e eccezione
			'
			Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

		End Try

	End Function

	<CLSCompliant(False)> _
	Public Shared Function Serialize(ByVal oInstance As T) As String
		'
		' Serializzo
		'
		Try
			Using memStream As New IO.MemoryStream

				Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
				oSerializer.Serialize(memStream, oInstance)

				Dim oEnc As Encoding = Encoding.Default
				Dim sXml As String = oEnc.GetString(memStream.ToArray())

				Return sXml
			End Using

		Catch ex As Exception
			'
			' Log e eccezione
			'
			Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)

		End Try

	End Function

	<CLSCompliant(False)> _
	Public Shared Function Deserialize(ByVal InputStream As IO.Stream) As T

		Try
			Dim oInstance As T

			Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
			InputStream.Position = 0
			oInstance = CType(oSerializer.Deserialize(InputStream), T)

			Return oInstance

		Catch ex As Exception
			'
			' Log e eccezione
			'
			Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

		End Try
	End Function

	<CLSCompliant(False)> _
	Public Shared Sub Serialize(ByVal Instance As T, ByVal OutputStream As IO.Stream)
		'
		' Serializzo
		'
		Try
			Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
			oSerializer.Serialize(OutputStream, Instance)
			OutputStream.Position = 0

		Catch ex As Exception
			'
			' Log e eccezione
			'
			Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)

		End Try

	End Sub

	Public Function GetXml() As String
		'
		' Serializzo
		'
		Try
			Using memStream As New IO.MemoryStream

				Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
				oSerializer.Serialize(memStream, Me)

				Dim oEnc As Encoding = Encoding.Default
				Dim sXml As String = oEnc.GetString(memStream.ToArray())

				Return sXml
			End Using

		Catch ex As Exception
			'
			' Log e eccezione
			'
			Throw New ApplicationException("Errore durante GetXml()!; " & ex.Message, ex)

		End Try

	End Function

End Class


