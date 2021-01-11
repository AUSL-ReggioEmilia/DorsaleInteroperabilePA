Imports DwhClinico.Data
Imports DwhClinico.Web.Utility

Public Class PatientSummary
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim oIdPaziente As System.Guid
        Dim oDataManager As DataManager = Nothing
        Try
            Try
                '
                ' Leggo parametri dal QueryString
                '
                oIdPaziente = New Guid(Request.QueryString(PAR_ID_PAZIENTE))

            Catch ex As Exception
                '
                ' Gestione dell'errore
                '
                Throw New Exception("Il parametro '" & PAR_ID_ALLEGATO & "' del QueryString non valido!")
            End Try
            '
            ' Leggo i dati del PDF
            '
            Dim oBytePdf As Byte() = PatientSummaryUtil.PatientSummaryPdf(oIdPaziente)
            If Not oBytePdf Is Nothing AndAlso oBytePdf.Length > 0 Then
                '
                ' Visualizzo il PDF
                '
                '
                ' Scrivo il contenuto binario
                '
                Response.Expires = 0
                Response.Clear()
                Response.BufferOutput = True
                Response.ContentType = "application/pdf"
                Response.AddHeader("content-disposition", "inline; filename=" & "Patient Summary")
                Response.BinaryWrite(oBytePdf)
                '
                ' ATTENZIONE:
                ' - Senza .Flush() E senza catch della Threading.ThreadAbortException si verifica apertura PDF in nuova finestra
                ' - Con .Flush() O con catch della Threading.ThreadAbortException si verifica apertura PDF embedded nella finestra corrente
                '
                ' 2012-11-28 - Commentato per esigenze di monitoring
                '
                'Response.Flush()
                'Response.End()
            Else
                Call Response.Write(FormatError("Impossibile visualizzare il Patient Summary: il dato non esiste!"))
            End If

        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            Call Response.Write(FormatError("Si è verificato un errore durante la visualizzazione del Patient Summary!"))
            Logging.WriteError(ex, Me.GetType.Name)
        Finally
            '
            ' Rilascio
            '
            If Not oDataManager Is Nothing Then
                oDataManager.Dispose()
            End If
        End Try

    End Sub

    Private Function FormatError(ByVal sMsg As String) As String
        Return String.Format("<div style=""color: red; font-weight: bold; font-size: 11px; font-family: verdana, helvetica, arial, sans-serif;"">{0}</div>", sMsg)
    End Function
End Class