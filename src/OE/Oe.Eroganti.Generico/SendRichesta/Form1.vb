Imports System.Text
Imports System.Xml.Serialization

Public Class Form1

    Private Sub Form1_Load(sender As Object, e As System.EventArgs) Handles Me.Load

        Dim oData As ServiceReference.RichiestaType
        oData = GetRichiestaInstance()

        Using oStream As IO.MemoryStream = New IO.MemoryStream()
            Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(ServiceReference.RichiestaType))
            oSerializer.Serialize(oStream, oData)

            oStream.Position = 0
            Dim baMessaggio As Byte() = oStream.ToArray()

            Dim sMessage As String = Encoding.UTF8.GetString(baMessaggio)
            TextBoxXml.Text = sMessage
        End Using

    End Sub

    Private Sub ButtonSend_Click(sender As System.Object, e As System.EventArgs) Handles ButtonSend.Click

        Dim oService As New ServiceReference.ServiceClient
        Dim oData As ServiceReference.RichiestaType

        Try
            TextBoxResult.Text = ""

            Dim sMessage As String = TextBoxXml.Text

            Dim oEnc As Encoding = Encoding.UTF8
            Dim baMessage As Byte() = oEnc.GetBytes(sMessage)

            Using oStream As IO.MemoryStream = New IO.MemoryStream(baMessage)
                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(ServiceReference.RichiestaType))
                oData = TryCast(oSerializer.Deserialize(oStream), ServiceReference.RichiestaType)
            End Using

            Try
                Dim dtStart As DateTime = DateTime.Now

                oService.Open()
                oService.ListenData(oData)

                Dim dtStop As DateTime = DateTime.Now
                TextBoxResult.Text = String.Format("AA; Inviato in {0} sec.", dtStop - dtStart)

            Catch ex As Exception
                TextBoxResult.Text = "Error!"

                oService.Close()
                Throw
            End Try

        Catch ex As Exception
            MessageBox.Show(ex.Message)
        End Try
    End Sub

    Private Function GetRichiestaInstance() As ServiceReference.RichiestaType

        Dim obj = New ServiceReference.RichiestaType

        obj.IdRichiestaOrderEntry = "2013/12345@RIS"
        obj.DataVersione = DateTime.Now
        obj.IdRichiestaRichiedente = "123456"
        obj.OperazioneOrderEntry = "SR"

        obj.SistemaErogante = New ServiceReference.SistemaType
        obj.SistemaErogante.Azienda = New ServiceReference.CodiceDescrizioneType With {.Codice = "ASMN"}
        obj.SistemaErogante.Sistema = New ServiceReference.CodiceDescrizioneType With {.Codice = "RIS"}

        obj.SistemaRichiedente = New ServiceReference.SistemaType
        obj.SistemaRichiedente.Azienda = New ServiceReference.CodiceDescrizioneType With {.Codice = "ASMN"}
        obj.SistemaRichiedente.Sistema = New ServiceReference.CodiceDescrizioneType With {.Codice = "GST"}

        obj.UnitaOperativaRichiedente = New ServiceReference.StrutturaType
        obj.UnitaOperativaRichiedente.Azienda = New ServiceReference.CodiceDescrizioneType With {.Codice = "ASMN"}
        obj.UnitaOperativaRichiedente.UnitaOperativa = New ServiceReference.CodiceDescrizioneType With {.Codice = "PS"}

        obj.DataRichiesta = DateTime.Now.AddMinutes(-1)

        obj.DataPrenotazione = DateTime.Now.AddDays(1)

        obj.RigheRichieste = New ServiceReference.RigheRichiesteType

        Dim objRigaRichiesta = New ServiceReference.RigaRichiestaType
        objRigaRichiesta.Prestazione = New ServiceReference.PrestazioneType With {.Codice = "1234", .Descrizione = "UnoDueTreQuattro"}

        obj.RigheRichieste.Add(objRigaRichiesta)

        Return obj

    End Function

End Class

