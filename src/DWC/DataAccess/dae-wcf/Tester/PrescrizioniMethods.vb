Imports Tester.Dwh.DataAccess.Wcf.Service
'
'
'  CLASSI PER TESTARE I SINGOLI METODI ESPOSTI DAL WCF 
'  1 CLASSE = 1 METODO
'
'

Namespace Methods

    Public Class Prescrizione_Specialistica_Dema_Aggiungi
        Inherits BaseMethod

        Public Prescrizione As PrescrizioneParameter

        Public Overrides Function ToString() As String
            Return "Specialistica Dema"
        End Function

        Overrides Sub Setup()
            If Prescrizione Is Nothing Then
                Prescrizione = New PrescrizioneParameter()
                Prescrizione.Prescrizione = Prescrizione_Modello()

            Else
                Prescrizione.Prescrizione.IdEsterno = Guid.NewGuid().ToString
                Prescrizione.Prescrizione.NumeroPrescrizione = Format(DateTime.Now, "yyyyMMddhhmmss")
                Prescrizione.Prescrizione.DataModificaEsterno = DateTime.Now
                Prescrizione.Prescrizione.DataPrescrizione = DateTime.Now
                'Dim i As Integer = 1
                'Integer.TryParse(Prescrizione.Prescrizione.NumeroPrescrizione, i)
                'i += 1
                'Prescrizione.Prescrizione.NumeroPrescrizione = i.ToString
            End If
        End Sub

        Overrides Function Execute() As Object
            Using ws As New PrescrizioniClient(MyBase.Endpoint)
                ServiceHelper.SetWCFCredentials(ws.ChannelFactory.Endpoint.Binding, ws.ClientCredentials, My.Settings.USERNAME, My.Settings.PASSWORD)
                Return ws.Aggiungi(Prescrizione)
            End Using
        End Function

        ''' <summary>
        ''' Prescrizione preconfezionata d'esempio
        ''' </summary>
        Private Shared Function Prescrizione_Modello() As PrescrizioneType
            Dim oPres As New PrescrizioneType

            oPres.IdEsterno = Guid.NewGuid().ToString
            oPres.DataModificaEsterno = DateTime.UtcNow
            oPres.StatoCodice = 1
            oPres.TipoPrescrizione = "specialistica"
            oPres.DataPrescrizione = DateTime.UtcNow
            oPres.NumeroPrescrizione = "1"
            oPres.MedicoPrescrittoreCodiceFiscale = "GPPNMP34P12A944K"
            oPres.QuesitoDiagnostico = "DA SCARTARE"

            oPres.Paziente = New PazienteType With
             {.Nome = "nome01",
              .Cognome = "cognome01",
              .CodiceFiscale = "codfisc",
               .DataNascita = DateTime.Parse("2000/01/01"),
             .TesseraSanitaria = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
             }
            ', .LuogoNascita = New CodiceDescrizioneType With {.Codice = "037006", .Descrizione = "Bologna"}

            'oPres.Attributi = New AttributiType
            'oPres.Attributi.Add(New AttributoType() With {.Nome = "ATTR01", .Valore = "01"})
            'oPres.Attributi.Add(New AttributoType() With {.Nome = "ATTR02", .Valore = "02"})
            'oPres.Attributi.Add(New AttributoType() With {.Nome = "ATTR03", .Valore = "03"})

            oPres.Allegati = New AllegatiType
            Dim oAllegato As New AllegatoType()
            oAllegato.IdEsterno = Guid.NewGuid().ToString
            oAllegato.Contenuto = System.IO.File.ReadAllBytes("Resources\Specialistica DEMA.xml")
            oAllegato.TipoContenuto = "text/xml"
            oAllegato.Attributi = New AttributiType
            oAllegato.Attributi.Add(New AttributoType() With {.Nome = "ALLATTR01", .Valore = "valore attributo allegato 01"})
            oAllegato.Attributi.Add(New AttributoType() With {.Nome = "ALLATTR02", .Valore = "valore attributo allegato 02"})
            oAllegato.Attributi.Add(New AttributoType() With {.Nome = "ALLATTR03", .Valore = "valore attributo allegato 03"})

            oPres.Allegati.Add(oAllegato)

            Return oPres

        End Function

    End Class


    Public Class Prescrizione_Specialistica_NON_DEMA_Aggiungi
        Inherits BaseMethod

        Public Prescrizione As PrescrizioneParameter

        Public Overrides Function ToString() As String
            Return "Specialistica NON Dema"
        End Function

        Overrides Sub Setup()
            If Prescrizione Is Nothing Then
                Prescrizione = New PrescrizioneParameter()
                Prescrizione.Prescrizione = Prescrizione_Modello()

            Else
                Prescrizione.Prescrizione.IdEsterno = Guid.NewGuid().ToString
                Prescrizione.Prescrizione.NumeroPrescrizione = Format(DateTime.Now, "yyyyMMddhhmmss")
                Prescrizione.Prescrizione.DataModificaEsterno = DateTime.Now
                Prescrizione.Prescrizione.DataPrescrizione = DateTime.Now
                'Dim i As Integer = 1
                'Integer.TryParse(Prescrizione.Prescrizione.NumeroPrescrizione, i)
                'i += 1
                'Prescrizione.Prescrizione.NumeroPrescrizione = i.ToString
            End If
        End Sub

        Overrides Function Execute() As Object
            Using ws As New PrescrizioniClient(MyBase.Endpoint)
                ServiceHelper.SetWCFCredentials(ws.ChannelFactory.Endpoint.Binding, ws.ClientCredentials, My.Settings.USERNAME, My.Settings.PASSWORD)
                Return ws.Aggiungi(Prescrizione)
            End Using
        End Function

        ''' <summary>
        ''' Prescrizione preconfezionata d'esempio
        ''' </summary>
        Private Shared Function Prescrizione_Modello() As PrescrizioneType
            Dim oPres As New PrescrizioneType

            oPres.IdEsterno = Guid.NewGuid().ToString
            oPres.DataModificaEsterno = DateTime.UtcNow
            oPres.StatoCodice = 1
            oPres.TipoPrescrizione = "specialistica"
            oPres.DataPrescrizione = DateTime.UtcNow
            oPres.NumeroPrescrizione = "1"
            oPres.MedicoPrescrittoreCodiceFiscale = "GPPNMP34P12A944K"
            oPres.QuesitoDiagnostico = "DA SCARTARE"

            oPres.Paziente = New PazienteType With
             {.Nome = "nome01",
              .Cognome = "cognome01",
              .CodiceFiscale = "codfisc",
               .DataNascita = DateTime.Parse("2000/01/01"),
             .TesseraSanitaria = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
             }

            oPres.Allegati = New AllegatiType
            Dim oAllegato As New AllegatoType()
            oAllegato.IdEsterno = Guid.NewGuid().ToString
            oAllegato.Contenuto = System.IO.File.ReadAllBytes("Resources\Specialistica NON DEMA.xml")
            oAllegato.TipoContenuto = "text/xml"

            oPres.Allegati.Add(oAllegato)

            Return oPres

        End Function

    End Class


    Public Class Prescrizione_Farmaceutica_DEMA_Aggiungi
        Inherits BaseMethod

        Public Prescrizione As PrescrizioneParameter

        Public Overrides Function ToString() As String
            Return "Farmaceutica DEMA"
        End Function

        Overrides Sub Setup()
            If Prescrizione Is Nothing Then
                Prescrizione = New PrescrizioneParameter()
                Prescrizione.Prescrizione = Prescrizione_Modello()

            Else
                Prescrizione.Prescrizione.IdEsterno = Guid.NewGuid().ToString
                Prescrizione.Prescrizione.NumeroPrescrizione = Format(DateTime.Now, "yyyyMMddhhmmss")
                Prescrizione.Prescrizione.DataModificaEsterno = DateTime.Now
                Prescrizione.Prescrizione.DataPrescrizione = DateTime.Now
            End If
        End Sub

        Overrides Function Execute() As Object
            Using ws As New PrescrizioniClient(MyBase.Endpoint)
                ServiceHelper.SetWCFCredentials(ws.ChannelFactory.Endpoint.Binding, ws.ClientCredentials, My.Settings.USERNAME, My.Settings.PASSWORD)
                Return ws.Aggiungi(Prescrizione)
            End Using
        End Function

        ''' <summary>
        ''' Prescrizione preconfezionata d'esempio
        ''' </summary>
        Private Shared Function Prescrizione_Modello() As PrescrizioneType
            Dim oPres As New PrescrizioneType

            oPres.IdEsterno = Guid.NewGuid().ToString
            oPres.DataModificaEsterno = DateTime.UtcNow
            oPres.StatoCodice = 1
            oPres.TipoPrescrizione = "farmaceutica"
            oPres.DataPrescrizione = DateTime.UtcNow
            oPres.NumeroPrescrizione = "1"
            oPres.MedicoPrescrittoreCodiceFiscale = "GPPNMP34P12A944K"
            oPres.QuesitoDiagnostico = "DA SCARTARE"

            oPres.Paziente = New PazienteType With
             {.Nome = "nome01",
              .Cognome = "cognome01",
              .CodiceFiscale = "codfisc",
               .DataNascita = DateTime.Parse("2000/01/01"),
             .TesseraSanitaria = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
             }
            ', .LuogoNascita = New CodiceDescrizioneType With {.Codice = "037006", .Descrizione = "Bologna"}

            'oPres.Attributi = New AttributiType
            'oPres.Attributi.Add(New AttributoType() With {.Nome = "ATTR01", .Valore = "01"})
            'oPres.Attributi.Add(New AttributoType() With {.Nome = "ATTR02", .Valore = "02"})
            'oPres.Attributi.Add(New AttributoType() With {.Nome = "ATTR03", .Valore = "03"})

            oPres.Allegati = New AllegatiType
            Dim oAllegato As New AllegatoType()
            oAllegato.IdEsterno = Guid.NewGuid().ToString
            oAllegato.Contenuto = System.IO.File.ReadAllBytes("Resources\Farmaceutica DEMA.xml")
            oAllegato.TipoContenuto = "text/xml"
            'oAllegato.Attributi = New AttributiType
            'oAllegato.Attributi.Add(New AttributoType() With {.Nome = "ALLATTR01", .Valore = "valore attributo allegato 01"})
            'oAllegato.Attributi.Add(New AttributoType() With {.Nome = "ALLATTR02", .Valore = "valore attributo allegato 02"})
            'oAllegato.Attributi.Add(New AttributoType() With {.Nome = "ALLATTR03", .Valore = "valore attributo allegato 03"})

            oPres.Allegati.Add(oAllegato)

            Return oPres

        End Function

    End Class


    Public Class Prescrizione_Farmaceutica_NON_DEMA_Aggiungi
        Inherits BaseMethod

        Public Prescrizione As PrescrizioneParameter

        Public Overrides Function ToString() As String
            Return "Farmaceutica NON DEMA"
        End Function

        Overrides Sub Setup()
            If Prescrizione Is Nothing Then
                Prescrizione = New PrescrizioneParameter()
                Prescrizione.Prescrizione = Prescrizione_Modello()

            Else
                Prescrizione.Prescrizione.IdEsterno = Guid.NewGuid().ToString
                Prescrizione.Prescrizione.NumeroPrescrizione = Format(DateTime.Now, "yyyyMMddhhmmss")
                Prescrizione.Prescrizione.DataModificaEsterno = DateTime.Now
                Prescrizione.Prescrizione.DataPrescrizione = DateTime.Now
            End If
        End Sub

        Overrides Function Execute() As Object
            Using ws As New PrescrizioniClient(MyBase.Endpoint)
                ServiceHelper.SetWCFCredentials(ws.ChannelFactory.Endpoint.Binding, ws.ClientCredentials, My.Settings.USERNAME, My.Settings.PASSWORD)
                Return ws.Aggiungi(Prescrizione)
            End Using
        End Function

        ''' <summary>
        ''' Prescrizione preconfezionata d'esempio
        ''' </summary>
        Private Shared Function Prescrizione_Modello() As PrescrizioneType
            Dim oPres As New PrescrizioneType

            oPres.IdEsterno = Guid.NewGuid().ToString
            oPres.DataModificaEsterno = DateTime.UtcNow
            oPres.StatoCodice = 1
            oPres.TipoPrescrizione = "farmaceutica"
            oPres.DataPrescrizione = DateTime.UtcNow
            oPres.NumeroPrescrizione = "1"
            oPres.MedicoPrescrittoreCodiceFiscale = "GPPNMP34P12A944K"
            oPres.QuesitoDiagnostico = "DA SCARTARE"

            oPres.Paziente = New PazienteType With
             {.Nome = "nome01",
              .Cognome = "cognome01",
              .CodiceFiscale = "codfisc",
               .DataNascita = DateTime.Parse("2000/01/01"),
             .TesseraSanitaria = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
             }
            ', .LuogoNascita = New CodiceDescrizioneType With {.Codice = "037006", .Descrizione = "Bologna"}

            'oPres.Attributi = New AttributiType
            'oPres.Attributi.Add(New AttributoType() With {.Nome = "ATTR01", .Valore = "01"})
            'oPres.Attributi.Add(New AttributoType() With {.Nome = "ATTR02", .Valore = "02"})
            'oPres.Attributi.Add(New AttributoType() With {.Nome = "ATTR03", .Valore = "03"})

            oPres.Allegati = New AllegatiType
            Dim oAllegato As New AllegatoType()
            oAllegato.IdEsterno = Guid.NewGuid().ToString
            oAllegato.Contenuto = System.IO.File.ReadAllBytes("Resources\Farmaceutica NON DEMA.xml")
            oAllegato.TipoContenuto = "text/xml"
            'oAllegato.Attributi = New AttributiType
            'oAllegato.Attributi.Add(New AttributoType() With {.Nome = "ALLATTR01", .Valore = "valore attributo allegato 01"})
            'oAllegato.Attributi.Add(New AttributoType() With {.Nome = "ALLATTR02", .Valore = "valore attributo allegato 02"})
            'oAllegato.Attributi.Add(New AttributoType() With {.Nome = "ALLATTR03", .Valore = "valore attributo allegato 03"})

            oPres.Allegati.Add(oAllegato)

            Return oPres

        End Function

    End Class


    Public Class Prescrizione4_Aggiungi
		Inherits BaseMethod

		Public Prescrizione As PrescrizioneParameter

		Public Overrides Function ToString() As String
			Return "Prescrizione4 Farma Aggiungi"
		End Function

		Overrides Sub Setup()
			If Prescrizione Is Nothing Then
				Prescrizione = New PrescrizioneParameter()
				Prescrizione.Prescrizione = Prescrizione_Modello()

			Else
				Prescrizione.Prescrizione.IdEsterno = Guid.NewGuid().ToString
				Prescrizione.Prescrizione.NumeroPrescrizione = Format(DateTime.Now, "yyyyMMddhhmmss")
				Prescrizione.Prescrizione.DataModificaEsterno = DateTime.Now
				Prescrizione.Prescrizione.DataPrescrizione = DateTime.Now
			End If
		End Sub

		Overrides Function Execute() As Object
			Using ws As New PrescrizioniClient(MyBase.Endpoint)
				ServiceHelper.SetWCFCredentials(ws.ChannelFactory.Endpoint.Binding, ws.ClientCredentials, My.Settings.USERNAME, My.Settings.PASSWORD)
				Return ws.Aggiungi(Prescrizione)
			End Using
		End Function

		''' <summary>
		''' Prescrizione preconfezionata d'esempio
		''' </summary>
		Private Shared Function Prescrizione_Modello() As PrescrizioneType
			Dim oPres As New PrescrizioneType

			oPres.IdEsterno = Guid.NewGuid().ToString
			oPres.DataModificaEsterno = DateTime.UtcNow
			oPres.StatoCodice = 1
			oPres.TipoPrescrizione = "farmaceutica"
			oPres.DataPrescrizione = DateTime.UtcNow
			oPres.NumeroPrescrizione = "1"
			oPres.MedicoPrescrittoreCodiceFiscale = "GPPNMP34P12A944K"
			oPres.QuesitoDiagnostico = "DA SCARTARE"

			oPres.Paziente = New PazienteType With
			 {.Nome = "nome01",
			  .Cognome = "cognome01",
			  .CodiceFiscale = "codfisc",
			   .DataNascita = DateTime.Parse("2000/01/01"),
			 .TesseraSanitaria = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
			 }
			', .LuogoNascita = New CodiceDescrizioneType With {.Codice = "037006", .Descrizione = "Bologna"}

			'oPres.Attributi = New AttributiType
			'oPres.Attributi.Add(New AttributoType() With {.Nome = "ATTR01", .Valore = "01"})
			'oPres.Attributi.Add(New AttributoType() With {.Nome = "ATTR02", .Valore = "02"})
			'oPres.Attributi.Add(New AttributoType() With {.Nome = "ATTR03", .Valore = "03"})

			oPres.Allegati = New AllegatiType
			Dim oAllegato As New AllegatoType()
			oAllegato.IdEsterno = Guid.NewGuid().ToString
			oAllegato.Contenuto = System.IO.File.ReadAllBytes("Resources\esempio4.xml")
			oAllegato.TipoContenuto = "text/xml"
			'oAllegato.Attributi = New AttributiType
			'oAllegato.Attributi.Add(New AttributoType() With {.Nome = "ALLATTR01", .Valore = "valore attributo allegato 01"})
			'oAllegato.Attributi.Add(New AttributoType() With {.Nome = "ALLATTR02", .Valore = "valore attributo allegato 02"})
			'oAllegato.Attributi.Add(New AttributoType() With {.Nome = "ALLATTR03", .Valore = "valore attributo allegato 03"})

			oPres.Allegati.Add(oAllegato)

			Return oPres

		End Function

	End Class


	Public Class Prescrizione5_Aggiungi
		Inherits BaseMethod

		Public Prescrizione As PrescrizioneParameter

		Public Overrides Function ToString() As String
			Return "Prescrizione5 Farma Aggiungi"
		End Function

		Overrides Sub Setup()
			If Prescrizione Is Nothing Then
				Prescrizione = New PrescrizioneParameter()
				Prescrizione.Prescrizione = Prescrizione_Modello()

			Else
				Prescrizione.Prescrizione.IdEsterno = Guid.NewGuid().ToString
				Prescrizione.Prescrizione.NumeroPrescrizione = Format(DateTime.Now, "yyyyMMddhhmmss")
				Prescrizione.Prescrizione.DataModificaEsterno = DateTime.Now
				Prescrizione.Prescrizione.DataPrescrizione = DateTime.Now
			End If
		End Sub

		Overrides Function Execute() As Object
			Using ws As New PrescrizioniClient(MyBase.Endpoint)
				ServiceHelper.SetWCFCredentials(ws.ChannelFactory.Endpoint.Binding, ws.ClientCredentials, My.Settings.USERNAME, My.Settings.PASSWORD)
				Return ws.Aggiungi(Prescrizione)
			End Using
		End Function

		''' <summary>
		''' Prescrizione preconfezionata d'esempio
		''' </summary>
		Private Shared Function Prescrizione_Modello() As PrescrizioneType
			Dim oPres As New PrescrizioneType

			oPres.IdEsterno = Guid.NewGuid().ToString
			oPres.DataModificaEsterno = DateTime.UtcNow
			oPres.StatoCodice = 1
			oPres.TipoPrescrizione = "farmaceutica"
			oPres.DataPrescrizione = DateTime.UtcNow
			oPres.NumeroPrescrizione = "1"
			oPres.MedicoPrescrittoreCodiceFiscale = "GPPNMP34P12A944K"
			oPres.QuesitoDiagnostico = "DA SCARTARE"

			oPres.Paziente = New PazienteType With
			 {.Nome = "nome01",
			  .Cognome = "cognome01",
			  .CodiceFiscale = "codfisc",
			   .DataNascita = DateTime.Parse("2000/01/01"),
			 .TesseraSanitaria = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
			 }
			', .LuogoNascita = New CodiceDescrizioneType With {.Codice = "037006", .Descrizione = "Bologna"}

			'oPres.Attributi = New AttributiType
			'oPres.Attributi.Add(New AttributoType() With {.Nome = "ATTR01", .Valore = "01"})
			'oPres.Attributi.Add(New AttributoType() With {.Nome = "ATTR02", .Valore = "02"})
			'oPres.Attributi.Add(New AttributoType() With {.Nome = "ATTR03", .Valore = "03"})

			oPres.Allegati = New AllegatiType
			Dim oAllegato As New AllegatoType()
			oAllegato.IdEsterno = Guid.NewGuid().ToString
			oAllegato.Contenuto = System.IO.File.ReadAllBytes("Resources\esempio5.xml")
			oAllegato.TipoContenuto = "text/xml"
			'oAllegato.Attributi = New AttributiType
			'oAllegato.Attributi.Add(New AttributoType() With {.Nome = "ALLATTR01", .Valore = "valore attributo allegato 01"})
			'oAllegato.Attributi.Add(New AttributoType() With {.Nome = "ALLATTR02", .Valore = "valore attributo allegato 02"})
			'oAllegato.Attributi.Add(New AttributoType() With {.Nome = "ALLATTR03", .Valore = "valore attributo allegato 03"})

			oPres.Allegati.Add(oAllegato)

			Return oPres

		End Function

	End Class


	Public Class Prescrizione6_Aggiungi
		Inherits BaseMethod

		Public Prescrizione As PrescrizioneParameter

		Public Overrides Function ToString() As String
			Return "Prescrizione6 Spec con Priorità Aggiungi"
		End Function

		Overrides Sub Setup()
			If Prescrizione Is Nothing Then
				Prescrizione = New PrescrizioneParameter()
				Prescrizione.Prescrizione = Prescrizione_Modello()

			Else
				Prescrizione.Prescrizione.IdEsterno = Guid.NewGuid().ToString
				Prescrizione.Prescrizione.NumeroPrescrizione = Format(DateTime.Now, "yyyyMMddhhmmss")
				Prescrizione.Prescrizione.DataModificaEsterno = DateTime.Now
				Prescrizione.Prescrizione.DataPrescrizione = DateTime.Now

			End If
		End Sub

		Overrides Function Execute() As Object
			Using ws As New PrescrizioniClient(MyBase.Endpoint)
				ServiceHelper.SetWCFCredentials(ws.ChannelFactory.Endpoint.Binding, ws.ClientCredentials, My.Settings.USERNAME, My.Settings.PASSWORD)
				Return ws.Aggiungi(Prescrizione)
			End Using
		End Function

		''' <summary>
		''' Prescrizione preconfezionata d'esempio
		''' </summary>
		Private Shared Function Prescrizione_Modello() As PrescrizioneType
			Dim oPres As New PrescrizioneType

			oPres.IdEsterno = Guid.NewGuid().ToString
			oPres.DataModificaEsterno = DateTime.UtcNow
			oPres.StatoCodice = 1
			oPres.TipoPrescrizione = "farmaceutica" '"specialistica" "farmaceutica"
			oPres.DataPrescrizione = DateTime.UtcNow
			oPres.NumeroPrescrizione = "1"
			oPres.MedicoPrescrittoreCodiceFiscale = "GPPNMP34P12A944K"
			oPres.QuesitoDiagnostico = "DA SCARTARE"

			oPres.Paziente = New PazienteType With
			 {.Nome = "nome01",
			  .Cognome = "cognome01",
			  .CodiceFiscale = "codfisc",
			   .DataNascita = DateTime.Parse("2000/01/01"),
			 .TesseraSanitaria = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
			 }

			oPres.Allegati = New AllegatiType
			Dim oAllegato As New AllegatoType()
			oAllegato.IdEsterno = Guid.NewGuid().ToString
			oAllegato.Contenuto = System.IO.File.ReadAllBytes("Resources\esempio6.xml")
			oAllegato.TipoContenuto = "text/xml"

			oPres.Allegati.Add(oAllegato)

			Return oPres

		End Function

	End Class


	Public Class Prescrizione_Rimuovi
		Inherits BaseMethod

		Public IdEsterno As String
		Public DataModificaEsterno As DateTime

		Public Overrides Function ToString() As String
			Return "Prescrizione Rimuovi"
		End Function

		Overrides Sub Setup()

			If IdEsterno Is Nothing Then
				IdEsterno = " "
				DataModificaEsterno = DateTime.Now.Date
			End If

		End Sub

		Overrides Function Execute() As Object
			Using ws As New PrescrizioniClient(MyBase.Endpoint)
				ServiceHelper.SetWCFCredentials(ws.ChannelFactory.Endpoint.Binding, ws.ClientCredentials, My.Settings.USERNAME, My.Settings.PASSWORD)
				Return ws.Rimuovi(IdEsterno, DataModificaEsterno)
			End Using
		End Function
	End Class

End Namespace