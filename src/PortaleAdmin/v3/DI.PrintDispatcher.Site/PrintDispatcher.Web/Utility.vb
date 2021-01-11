Imports Microsoft.ApplicationInsights

Public Class Utility

    Public Shared Function MergePdfDocuments(ByVal oDocuments As System.Collections.Generic.List(Of Byte())) As Byte()
        Dim iNumDoc As Integer = oDocuments.Count
        Dim aInputStreams(iNumDoc - 1) As System.IO.Stream
        Dim aOutputstream As System.IO.Stream = Nothing
        Try
            '
            ' MODIFICA ETTORE 2018-03-21: se c'è un solo documento lo restituisco senza fare merge
            '
            If iNumDoc = 1 Then
                Return oDocuments(0)
            End If
            '
            ' Imposto la licenza
            '
            ExpertPdf.PdfCreator.LicensingManager.LicenseKey = "EjkgMiMrMiMyJjwiMiEjPCMgPCsrKys="
            '
            ' Popolo l'array di IO.Streams con i dati da fondere
            '
            For i As Integer = 0 To iNumDoc - 1
                aInputStreams(i) = New System.IO.MemoryStream(oDocuments(i))
            Next
            '
            ' Creo lo stream di output (deve essere uno stream di tipo file)
            '
            aOutputstream = New System.IO.MemoryStream()
            '
            ' Invoco ePdfCreator...esegue il merge degli stream di input e popola lo stream file di output
            '
            ExpertPdf.PdfCreator.MergePdf.Merge(aInputStreams, aOutputstream)
            '
            ' ByteArray da restituire
            '
            Dim OutputBuffer(CInt(aOutputstream.Length) - 1) As Byte
            '
            ' Setto puntatore all'inizio dello stream
            '
            aOutputstream.Position = 0
            '
            ' Read the entire stream
            '
            aOutputstream.Read(OutputBuffer, 0, CInt(aOutputstream.Length))
            '
            ' Salvo su disco il file stream
            '
            aOutputstream.Close()
            '
            ' Leggo i byte del documento salvato su disco
            '
            Return OutputBuffer
        Catch ex As Exception
            Dim sMsg As String = "Errore durante MergingPdfDocuments()"
            ' Eseguo il throw
            Throw New Exception(sMsg, ex.InnerException)
        Finally
            '
            ' Eseguo il dispose delle risorse
            '
            For i As Integer = 0 To iNumDoc - 1
                If Not aInputStreams(i) Is Nothing Then
                    aInputStreams(i).Dispose()
                End If
            Next
            If Not aOutputstream Is Nothing Then
                aOutputstream.Dispose()
            End If
        End Try
        '
        ' Restituisco
        '
        Return Nothing
    End Function

    Public Shared Sub GestisciErroriApplicationInsights(ex As Exception, ByVal NomeProcedura As String)
        '
        'Gestisco l'errore su Application insights
        '
        Dim dicProp As New Dictionary(Of String, String)
        '
        'Aggiungo alla descrizione dell'errore su azure anche il nome del portale in cui si è generato.
        '
        dicProp.Add("NomePortale", CustomInitializer.Telemetry.MyTelemetryInitializer.RoleName)
        '
        'Traccio l'errrore.
        '
        Dim ai = New TelemetryClient()
        ai.TrackException(ex, dicProp)
    End Sub

End Class