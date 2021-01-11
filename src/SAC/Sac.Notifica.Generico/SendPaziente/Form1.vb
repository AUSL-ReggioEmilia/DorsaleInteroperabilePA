Imports System.Text
Imports System.Xml.Serialization

Public Class Form1

    Private Sub Form1_Load(sender As Object, e As System.EventArgs) Handles Me.Load

        Dim oData As ServiceReference.SoapPazienteType
        oData = GetRichiestaInstance()

        Using oStream As IO.MemoryStream = New IO.MemoryStream()
            Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(ServiceReference.SoapPazienteType))
            oSerializer.Serialize(oStream, oData)

            oStream.Position = 0
            Dim baMessaggio As Byte() = oStream.ToArray()

            Dim sMessage As String = Encoding.UTF8.GetString(baMessaggio)
            TextBoxXml.Text = sMessage
        End Using

    End Sub

    Private Sub ButtonSend_Click(sender As System.Object, e As System.EventArgs) Handles ButtonSend.Click

        Dim oService As New ServiceReference.ServiceClient
        Dim oData As ServiceReference.SoapPazienteType

        Try
            TextBoxResult.Text = ""

            Dim sMessage As String = TextBoxXml.Text

            Dim oEnc As Encoding = Encoding.UTF8
            Dim baMessage As Byte() = oEnc.GetBytes(sMessage)

            Using oStream As IO.MemoryStream = New IO.MemoryStream(baMessage)
                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(ServiceReference.SoapPazienteType))
                oData = TryCast(oSerializer.Deserialize(oStream), ServiceReference.SoapPazienteType)
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

    Private Function GetRichiestaInstance() As ServiceReference.SoapPazienteType

        Dim obj = New ServiceReference.SoapPazienteType

        obj.Azione = 0
        obj.IdMessaggio = "12345"
        obj.DataSequenza = DateTime.UtcNow

        obj.Paziente = New ServiceReference.PazienteType
        obj.Paziente.IdSac = Guid.NewGuid.ToString

        obj.Paziente.IdProvenienza = "1234"
        obj.Paziente.Provenienza = "TEST"

        obj.Paziente.LivelloAttendibilita = 55

        obj.Paziente.Generalita = New ServiceReference.GeneralitaType
        obj.Paziente.Generalita.CodiceFiscale = "0000000000000"
        obj.Paziente.Generalita.Nome = "Pippo"
        obj.Paziente.Generalita.Cognome = "Capuozzo"
        obj.Paziente.Generalita.DataDecesso = New DateTime(1964, 10, 15)

        obj.Paziente.Recapito = New ServiceReference.RecapitoType
        obj.Paziente.Recapito.Email = "pippo.capuozzo@progel.it"

        Return obj

    End Function

End Class


