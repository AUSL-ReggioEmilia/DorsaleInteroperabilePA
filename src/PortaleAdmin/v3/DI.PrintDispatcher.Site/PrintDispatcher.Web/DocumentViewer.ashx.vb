Public Class DocumentViewer
    Implements System.Web.IHttpHandler

    Private _IdJob As Guid
    Private _Xps As Boolean

    Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Try
            '
            ' leggo il guid del job di stampa
            '
            _IdJob = New Guid(context.Request.Params("IdJob"))
            '
            ' Visualizzo il documento
            '
            Call ShowDocument(context, _IdJob)
        Catch ex As Exception
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante ProcessRequest(): durante la visualizzazione del documento.")
        End Try
    End Sub

    Private Sub ShowDocument(ByVal oContext As HttpContext, ByVal oIdJob As Guid)
        '
        ' Gestisce solo dei PDF
        '
        Try
            Using oTa As New DataAccess.JobQueueDataSetTableAdapters.UiJobQueueDocumentSelect2TableAdapter
                Dim oDt As DataAccess.JobQueueDataSet.UiJobQueueDocumentSelect2DataTable = oTa.GetData(_IdJob)
                If Not oDt Is Nothing Then
                    If oDt.Rows.Count > 0 Then
                        Dim oListDocuments As New System.Collections.Generic.List(Of Byte())
                        For Each oRow As DataAccess.JobQueueDataSet.UiJobQueueDocumentSelect2Row In oDt
                            If String.Compare(oRow.Extension, "pdf", True) <> 0 Then
                                Throw New Exception("Vi sono documenti con estensione diversa da PDF!")
                            End If
                            oListDocuments.Add(oRow.Document)
                        Next
                        '
                        ' Eseguo il merge di tutti i documenti delle etichette
                        '
                        Dim oAllBytes As Byte() = Nothing
                        oAllBytes = Utility.MergePdfDocuments(oListDocuments)

                        Call ResponseDocument(oContext, "", "pdf", oAllBytes, "application/pdf")

                    End If
                End If
            End Using
        Catch ex As Exception
            oContext.Response.Write("Si è verificato un errore durante la visualizzazione del documento")
            Throw ex
        End Try
    End Sub

    Private Sub ResponseDocument(ByVal oContext As HttpContext, ByVal sDocumentName As String, ByVal sFileExtension As String, ByRef oArrayFileContainer As Byte(), ByVal sFileContentType As String)
        Dim sFileName As String
        If sFileExtension.Length > 0 Then
            sFileName = sDocumentName & "." & sFileExtension
        Else
            sFileName = sDocumentName
        End If
        With oContext.Response
            .Expires = 0
            .Buffer = True
            .Clear()
            .ContentType = sFileContentType
            .AddHeader("Content-Disposition", "inline; filename=" & sFileName)
            .BinaryWrite(oArrayFileContainer)
        End With
    End Sub

    ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class