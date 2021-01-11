Imports System.Text
Imports System.Xml.Serialization

<ServiceBehavior(Namespace:="http://schemas.progel.it/WCF/OE/StatoRichiedenteGenerico/1.0")> _
Public Class Service
    Implements IService

    Public Sub ListenData(value As RichiedenteGenericoTypes.StatoType) Implements IService.ListenData

        Try
            If value IsNot Nothing Then
                '
                ' Ci sono dei dati, li salvo
                '
                Dim sFileName As String = String.Format("{0}_{1}.xml", My.Application.Info.Title, Guid.NewGuid)
                Dim sFolderName As String = My.Settings.FolderOutput
                '
                ' Serializzo oggetto
                '
                Dim sMessaggio As String = Nothing

                Using oStream As IO.MemoryStream = New IO.MemoryStream
                    Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RichiedenteGenericoTypes.StatoType))
                    oSerializer.Serialize(oStream, value)

                    If String.IsNullOrEmpty(sFolderName) Then
                        '
                        ' Nessun folder, scrivo nel trace
                        '
                        Dim oEnc As Encoding = Encoding.UTF8
                        sMessaggio = oEnc.GetString(oStream.ToArray)

                        Trace.WriteLine(My.Application.Info.Title, DateTime.Now.ToString("s"))
                        Trace.WriteLine(sMessaggio)
                    Else
                        '
                        ' Compongo il percorso
                        '
                        sFileName = IO.Path.Combine(sFolderName, sFileName)
                        '
                        ' Scrivo il file
                        '
                        My.Computer.FileSystem.WriteAllBytes(sFileName, oStream.ToArray, False)
                    End If
                End Using
                '
                ' Return OK
                '
            Else
                Trace.WriteLine("ListenData method receive null value!", DateTime.Now.ToString("s"))
                '
                ' Return Errore
                '
                Throw New FaultException("ListenData method receive null value!")
            End If

        Catch ex As Exception
            Trace.WriteLine("Errore durante ListenData! " & ex.Message, DateTime.Now.ToString("s"))
            '
            ' Return Errore
            '
            Throw New FaultException("Errore durante ListenData! " & ex.Message)
        End Try
    End Sub

End Class
