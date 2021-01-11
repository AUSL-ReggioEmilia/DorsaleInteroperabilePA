Imports System.IO
Imports Tester.Dwh.DataAccess.NoteAnamnestiche.Wcf.Service
'
'
'  CLASSI PER TESTARE I SINGOLI METODI ESPOSTI DAL WCF 
'  1 CLASSE = 1 METODO
'
'

Namespace Methods

    Public Class NotaAnamnestica_Aggiungi
        Inherits BaseMethod

        Public NotaAnamnestica As NotaAnamnesticaParameter

        Public Overrides Function ToString() As String
            Return "NotaAnamnestica Processa"
        End Function

        Overrides Sub Setup()
            If NotaAnamnestica Is Nothing Then
                NotaAnamnestica = New NotaAnamnesticaParameter()
                NotaAnamnestica.DataModificaEsterno = DateTime.UtcNow
                NotaAnamnestica.NotaAnamnestica = NotaAnamnestica_Modello()

            Else
                NotaAnamnestica.NotaAnamnestica.IdEsterno = Guid.NewGuid().ToString
                NotaAnamnestica.DataModificaEsterno = DateTime.UtcNow
            End If
        End Sub

        Overrides Function Execute() As Object
            Using ws As New NoteAnamnesticheClient(MyBase.Endpoint)
                ServiceHelper.SetWCFCredentials(ws.ChannelFactory.Endpoint.Binding, ws.ClientCredentials, My.Settings.USERNAME, My.Settings.PASSWORD)
                Return ws.Processa(NotaAnamnestica)
            End Using
        End Function

        ''' <summary>
        ''' Prescrizione preconfezionata d'esempio
        ''' </summary>
        Private Shared Function NotaAnamnestica_Modello() As NotaAnamnesticaType
            Dim oNotaAnamnestica As New NotaAnamnesticaType

            oNotaAnamnestica.IdEsterno = "83b1f8d0-4aee-4ae5-9e1e-69d07436ac1b" 'Guid.NewGuid().ToString
            oNotaAnamnestica.StatoCodice = 1
            oNotaAnamnestica.AziendaErogante = "ASMN"
            oNotaAnamnestica.SistemaErogante = "PS"
            oNotaAnamnestica.DataNota = Date.Now()
            oNotaAnamnestica.DataFineValidita = New Date(2020, 1, 1)
            oNotaAnamnestica.TipoCodice = "1"
            oNotaAnamnestica.TipoDescrizione = "TipoDescrizione 1"
            oNotaAnamnestica.TipoContenuto = "text/rtf" '"text/html"
            oNotaAnamnestica.Contenuto = File.ReadAllBytes("Resources\Document.rtf")

            'oNotaAnamnestica.TipoContenuto = "text/html"
            'oNotaAnamnestica.Contenuto = File.ReadAllBytes(Resources\Contenuto.html")

            'oNotaAnamnestica.Contenuto = File.ReadAllBytes("Resources\Contenuto.txt")

            oNotaAnamnestica.Paziente = New PazienteType
            With oNotaAnamnestica.Paziente
                .Nome = "Giorgio"
                .Cognome = "Campani"
                .CodiceFiscale = "CMPGRG58H25A586Z"
                .DataNascita = New Date(1958, 6, 25)  'DateTime.Parse("1958/06/25")
                .TesseraSanitaria = "T5T6RFG1234"
                .ComuneNascitaCodice = "035003"
                .ComuneNascitaDescrizione = "Baiso"
                .NomeAnagrafica = "SAC"
                .CodiceAnagrafica = "6D268E1B-DF15-4199-BC0B-206D97319DF4"
            End With

            oNotaAnamnestica.Attributi = New AttributiType
            oNotaAnamnestica.Attributi.Add(New AttributoType() With {.Nome = "ATTR01", .Valore = "01"})
            oNotaAnamnestica.Attributi.Add(New AttributoType() With {.Nome = "ATTR02", .Valore = "02"})
            oNotaAnamnestica.Attributi.Add(New AttributoType() With {.Nome = "ATTR03", .Valore = "03"})

            Return oNotaAnamnestica

        End Function

    End Class
End Namespace