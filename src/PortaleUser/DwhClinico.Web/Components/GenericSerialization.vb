Imports System.Reflection
Imports System.Xml.Serialization

#Region "GenericSerialize"
'
' Funzioni di serializzazione per la visualizzazione del dettaglio dei referti
'
Public Class GenericSerialize(Of T)
    '
    ' Attenzione: In questa classe ho cambiato l'Encodicng da Default a UTF8
    '
    <CLSCompliant(False)>
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

    <CLSCompliant(False)>
    Public Shared Function Serialize(ByVal oInstance As T) As String
        '
        ' Serializzo
        '
        Try
            Using memStream As New IO.MemoryStream

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
                oSerializer.Serialize(memStream, oInstance)

                Dim oEnc As Encoding = Encoding.UTF8
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

    <CLSCompliant(False)>
    Public Shared Function Deserialize(ByVal XmlData As String) As T

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
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

        End Try

    End Function

    <CLSCompliant(False)>
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

    'Public Shared Function StreamToString(ByVal memStream As IO.MemoryStream) As String

    '    Dim oEnc As Encoding = Encoding.UTF8
    '    Return oEnc.GetString(memStream.ToArray())

    'End Function

    'Public Shared Function ReadDataRow(ByVal Sorgente As Data.DataRow, ByVal Destinazione As T) As T

    '    Dim oType As Type = GetType(T)
    '    Dim dcRow As Data.DataColumn

    '    For Each dcRow In Sorgente.Table.Columns
    '        Dim sName As String = dcRow.ColumnName
    '        '
    '        ' Cerco se c'è nella destinazione
    '        '
    '        Dim oFieldInfo As FieldInfo = Nothing
    '        Try
    '            oFieldInfo = oType.GetField(sName, BindingFlags.NonPublic Or
    '                                                BindingFlags.Instance Or
    '                                                BindingFlags.Public)
    '        Catch ex As Exception
    '            oFieldInfo = Nothing
    '        End Try
    '        If oFieldInfo IsNot Nothing Then
    '            '
    '            ' Leggo la sorgente
    '            '
    '            Dim oValue As Object = Sorgente.Item(sName)
    '            '
    '            ' Scrivo nella destinazione
    '            '
    '            Try
    '                If oValue IsNot DBNull.Value Then
    '                    oFieldInfo.SetValue(Destinazione, oValue, BindingFlags.Instance, Nothing, Nothing)
    '                Else
    '                    oFieldInfo.SetValue(Destinazione, Nothing, BindingFlags.Instance, Nothing, Nothing)
    '                End If
    '            Catch ex As Exception
    '                '
    '                ' Errore
    '                '
    '                Throw New ApplicationException("Errore in GenericSerialize(Of T).ReadDataRow() durante SetValue() destinazione! " & ex.Message)
    '            End Try
    '        End If
    '    Next

    '    Return Destinazione

    'End Function

End Class

#End Region

#Region "GenericDataContractSerializer per WCF"
Public Class GenericDataContractSerializer
    ''' <summary>
    ''' Usa System.Runtime.Serialization.DataContractSerializer
    ''' </summary>
    Public Shared Function Serialize(Of T)(ByVal value As T) As String
        Try
            Using stream As New IO.MemoryStream
                Dim oDataSerializer As New System.Runtime.Serialization.DataContractSerializer(GetType(T))
                oDataSerializer.WriteObject(stream, value)

                stream.Position = 0
                Return System.Text.Encoding.UTF8.GetString(stream.ToArray)
            End Using

        Catch ex As Exception
            Return ex.Message
        End Try

    End Function

End Class

#End Region


#Region "Classe di supporto per le visualizzazioni del dettaglio referto"
'
' Classe di supporto per la serializzazione di tutti i dati referto/paziente
'
Public Class Root
    Public SezioneReferto As RefertoResult
    Public SezionePaziente As PazienteResult
    Public Sub New()
    End Sub

    Public Sub New(ByVal SezioneReferto As RefertoResult, SezionePaziente As PazienteResult)
        Me.SezioneReferto = SezioneReferto
        Me.SezionePaziente = SezionePaziente
    End Sub
End Class

#End Region



