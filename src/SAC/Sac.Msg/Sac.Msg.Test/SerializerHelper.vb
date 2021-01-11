Imports System.IO
Imports System.Text
Imports System.Xml.Serialization

Public NotInheritable Class SerializerHelper(Of T)
    Private Sub New()
    End Sub

    Public Shared Function GetXML(ByVal obj As T) As String

        Using ms As New MemoryStream()
            Dim xSerializer As XmlSerializer = New XmlSerializer(GetType(T))
            xSerializer.Serialize(ms, obj)

            Dim enc As Encoding = Encoding.UTF8
            Dim sXml As String = enc.GetString(ms.ToArray())

            Return sXml
        End Using

    End Function

    Public Shared Function Serialize(ByVal obj As T) As String

        Using ms As New MemoryStream()
            Dim xSerializer As XmlSerializer = New XmlSerializer(GetType(T))
            xSerializer.Serialize(ms, obj)

            Dim enc As Encoding = Encoding.UTF8
            Dim sXml As String = enc.GetString(ms.ToArray())

            Return sXml
        End Using

    End Function

    Public Shared Function Deserialize(ByVal xmlData As String) As T

        Using ms As New MemoryStream()
            Dim enc As Encoding = Encoding.UTF8

            ms.Write(enc.GetBytes(xmlData), 0, enc.GetByteCount(xmlData))
            ms.Position = 0

            Dim instance As T

            Dim serializer As XmlSerializer = New XmlSerializer(GetType(T))
            instance = CType(serializer.Deserialize(ms), T)

            Return instance
        End Using

    End Function

End Class