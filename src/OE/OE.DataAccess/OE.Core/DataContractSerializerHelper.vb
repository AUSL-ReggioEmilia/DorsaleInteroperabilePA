Imports System.IO
Imports System.Text
Imports System.Runtime.Serialization
Imports OE.Core

Public NotInheritable Class DataContractSerializerHelper
    Private Sub New()
    End Sub

    Public Shared Function GetXML(Of T)(ByVal obj As T) As String
        DiagnosticsHelper.WriteDiagnostics(String.Format("DataContractSerializerHelper.GetXML(Of {0})", GetType(T).Name))

        'TODO: in futuro usare Serialize(Of T)(ByVal obj As T) 
        If obj Is Nothing Then
            Return Nothing
        Else
            Using ms As New MemoryStream()
                Dim xSerializer As DataContractSerializer = New DataContractSerializer(GetType(T))
                xSerializer.WriteObject(ms, obj)

                Dim enc As Encoding = Encoding.UTF8
                Dim sXml As String = enc.GetString(ms.ToArray())

#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
                'Versione 1.2
                sXml = sXml.Replace("http://schemas.progel.it/WCF/OE/WsTypes/1.2", "http://schemas.progel.it/WCF/OE/WsTypes/1.1")
                sXml = sXml.Replace("http://schemas.progel.it/OE/Types/1.2", "http://schemas.progel.it/OE/Types/1.1")
#End If
                Return sXml
            End Using
        End If

    End Function

    Public Shared Function GetXML(Of T)(ByVal obj As T, encoding As Encoding) As String
        DiagnosticsHelper.WriteDiagnostics(String.Format("DataContractSerializerHelper.GetXML(Of {0})", GetType(T).Name))

        If obj Is Nothing Then
            Return Nothing
        Else
            Using ms As New MemoryStream()
                Dim xSerializer As DataContractSerializer = New DataContractSerializer(GetType(T))
                xSerializer.WriteObject(ms, obj)

                Dim sXml As String = encoding.GetString(ms.ToArray())

                Return sXml
            End Using
        End If

    End Function

    Public Shared Function GetXmlElement(Of T)(ByVal obj As T) As Xml.XmlElement
        DiagnosticsHelper.WriteDiagnostics(String.Format("DataContractSerializerHelper.GetXmlElement(Of {0})", GetType(T).Name))

        If obj Is Nothing Then
            Return Nothing
        Else
            Using ms As New MemoryStream()
                Dim xSerializer As DataContractSerializer = New DataContractSerializer(GetType(T))
                xSerializer.WriteObject(ms, obj)

                Dim xdoc As New Xml.XmlDocument()
                xdoc.Load(ms)
                Return xdoc.DocumentElement
            End Using
        End If

    End Function


    Public Shared Function Serialize(Of T)(ByVal obj As T) As String
        DiagnosticsHelper.WriteDiagnostics(String.Format("DataContractSerializerHelper.Serialize(Of {0})", GetType(T).Name))

        If obj Is Nothing Then
            Return Nothing
        Else
            Using ms As New MemoryStream()
                Dim xSerializer As DataContractSerializer = New DataContractSerializer(GetType(T))
                xSerializer.WriteObject(ms, obj)

                Dim enc As Encoding = Encoding.UTF8
                Dim sXml As String = enc.GetString(ms.ToArray())

#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
                'Versione 1.2
                sXml = sXml.Replace("http://schemas.progel.it/WCF/OE/WsTypes/1.2", "http://schemas.progel.it/WCF/OE/WsTypes/1.1")
                sXml = sXml.Replace("http://schemas.progel.it/OE/Types/1.2", "http://schemas.progel.it/OE/Types/1.1")
#End If
                Return sXml
            End Using
        End If

    End Function

    Public Shared Function Deserialize(Of T)(ByVal xmlData As String) As T
        DiagnosticsHelper.WriteDiagnostics(String.Format("DataContractSerializerHelper.Deserialize(Of {0})", GetType(T).Name))

        If String.IsNullOrEmpty(xmlData) Then
            Return Nothing
        Else

#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
            'Versione 1.2
            xmlData = xmlData.Replace("http://schemas.progel.it/WCF/OE/WsTypes/1.1", "http://schemas.progel.it/WCF/OE/WsTypes/1.2")
            xmlData = xmlData.Replace("http://schemas.progel.it/OE/Types/1.1", "http://schemas.progel.it/OE/Types/1.2")
#Else
            'Versione 1.1
            xmlData = xmlData.Replace("http://schemas.progel.it/WCF/OE/WsTypes/1.2", "http://schemas.progel.it/WCF/OE/WsTypes/1.1")
            xmlData = xmlData.Replace("http://schemas.progel.it/OE/Types/1.2", "http://schemas.progel.it/OE/Types/1.1")
#End If

            Using ms As New MemoryStream()
                Dim enc As Encoding = Encoding.UTF8

                ms.Write(enc.GetBytes(xmlData), 0, enc.GetByteCount(xmlData))
                ms.Position = 0

                Dim instance As T

                Dim serializer As DataContractSerializer = New DataContractSerializer(GetType(T))
                instance = CType(serializer.ReadObject(ms), T)

                Return instance
            End Using
        End If

    End Function

    Public Shared Function Deserialize(Of T)(ByVal xmlData As String, encoding As Encoding) As T
        DiagnosticsHelper.WriteDiagnostics(String.Format("DataContractSerializerHelper.Deserialize(Of {0})", GetType(T).Name))

        If String.IsNullOrEmpty(xmlData) Then
            Return Nothing
        Else

#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
            'Versione 1.2
            xmlData = xmlData.Replace("http://schemas.progel.it/WCF/OE/WsTypes/1.1", "http://schemas.progel.it/WCF/OE/WsTypes/1.2")
            xmlData = xmlData.Replace("http://schemas.progel.it/OE/Types/1.1", "http://schemas.progel.it/OE/Types/1.2")
#Else
            'Versione 1.1
            xmlData = xmlData.Replace("http://schemas.progel.it/WCF/OE/WsTypes/1.2", "http://schemas.progel.it/WCF/OE/WsTypes/1.1")
            xmlData = xmlData.Replace("http://schemas.progel.it/OE/Types/1.2", "http://schemas.progel.it/OE/Types/1.1")
#End If
            Using ms As New MemoryStream()

                ms.Write(encoding.GetBytes(xmlData), 0, encoding.GetByteCount(xmlData))
                ms.Position = 0

                Dim instance As T

                Dim serializer As DataContractSerializer = New DataContractSerializer(GetType(T))
                instance = CType(serializer.ReadObject(ms), T)

                Return instance
            End Using
        End If

    End Function

    Public Shared Function Clone(Of T)(ByVal obj As T) As T

        DiagnosticsHelper.WriteDiagnostics(String.Format("DataContractSerializerHelper.Clone(Of {0})", GetType(T).Name))

        If obj Is Nothing Then
            Return Nothing
        Else
            Using ms As New MemoryStream()
                Dim xSerializer As DataContractSerializer = New DataContractSerializer(GetType(T))
                xSerializer.WriteObject(ms, obj)

                ms.Position = 0
                Return CType(xSerializer.ReadObject(ms), T)
            End Using
        End If

    End Function

End Class