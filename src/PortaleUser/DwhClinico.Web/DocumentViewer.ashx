<%@ WebHandler Language="VB" Class="DocumentViewer" %>

Imports System
Imports System.Web
Imports DwhClinico.Web.Utility
Imports DwhClinico.Data

Public Class DocumentViewer : Implements IHttpHandler
    '
    ' La pagina accetta i seguenti parametri:
    ' 1)IdDocumento e nome tabella del documento
    '
    Private Const TBL_SISTEMI_EROGANTI_DOCUMENTI As String = "SistemiErogantiDocumenti"

   
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Dim sValue As String
        Dim oIDAttachment As Guid
        Dim sDocumentTable As String
        Try
            '
            ' Lettura parametri di pagina: lettura per ID dal database
            '
            sValue = context.Request.QueryString(PAR_ID_DOC)
            If Not sValue Is Nothing AndAlso sValue.Length > 0 Then
                oIDAttachment = New Guid(sValue)
            End If
            sDocumentTable = context.Request.QueryString(PAR_DOC_TABLE)

            If oIDAttachment = Guid.Empty OrElse String.IsNullOrEmpty(sDocumentTable) Then
                Throw New Exception("I parametri 'IdDocumento' e 'DocumentTable' sono obbligatori.")
            End If

            Call ShowDocumentByID(context, oIDAttachment, sDocumentTable)

        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
        
    End Sub
        
    Private Sub ShowDocumentByID(ByVal oContext As HttpContext, ByVal oIdDocumento As Guid, ByVal sTableName As String)
        '
        ' Eseguo una query per ricavare i dati della riga della tabella desiderata
        '
        Dim mbRecordNotFound As Boolean = False
        Try
            Using odata As DwhClinico.Data.Documenti = New DwhClinico.Data.Documenti

                Select Case sTableName.ToUpper
                    Case TBL_SISTEMI_EROGANTI_DOCUMENTI.ToUpper

                        Dim odt As DwhClinico.Data.DocumentiDataSet.FevsGetDocumentoSistemiErogantiDataTable = odata.GetDataSistemiErogantiDocumento(oIdDocumento)
                        If Not odt Is Nothing AndAlso odt.Rows.Count > 0 Then
                            With odt(0)
                                Call ResponseDocument(oContext, .Nome, .Estensione, .Contenuto, .ContentType)
                            End With
                        Else
                            mbRecordNotFound = True
                        End If

                    Case Else
                        '
                        ' Non è stata trovata la tabella
                        '
                        Throw New Exception(String.Format("La tabella '{0}' non è gestita", sTableName))
                End Select
                '
                ' Se non ho trovato il record scrivo nel log
                '
                If mbRecordNotFound Then
                    Throw New Exception(String.Format("Non esiste il documento con ID={0} nella tabella '{1}'.", oIdDocumento.ToString, sTableName))
                End If

            End Using
        Catch ex As Exception
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
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class