<%@ WebHandler Language="VB" Class="DI.DataWarehouse.Admin.DocumentViewer" %>

Imports System
Imports System.Web
Imports DI.DataWarehouse.Admin.Data
Imports DI.DataWarehouse.Admin.Data.DocumentiDataSet
Imports DI.DataWarehouse.Admin.Data.BackEndDataSet

Namespace DI.DataWarehouse.Admin

	Public Class DocumentViewer : Implements IHttpHandler
        
		' La pagina accetta i seguenti parametri:
		' 1)IdDocumento e nome tabella del documento        
		Private Const SistemiErogantiDocumenti As String = "SistemiErogantiDocumenti"

		Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
                       
			Dim idAttachment As Guid
			Dim documentTable As String

			Dim value As String = context.Request.QueryString(Constants.IdDocument)
            
			If Not String.IsNullOrEmpty(value) Then
				idAttachment = New Guid(value)
			End If
            
			documentTable = context.Request.QueryString(Constants.DocumentTableName)

			ShowDocumentById(context, idAttachment, documentTable)
		End Sub
        
		Private Sub ShowDocumentById(ByVal context As HttpContext, ByVal idDocumento As Guid, ByVal tableName As String)
         
			Select Case tableName
                
				Case SistemiErogantiDocumenti

					Dim table As GetDocumentoSistemiErogantiDataTable = DataAdapterManager.GetDataSistemiErogantiDocumento(idDocumento)
					If table IsNot Nothing AndAlso table.Rows.Count > 0 Then
						ResponseDocument(context, table(0).Nome, table(0).Estensione, table(0).Contenuto, table(0).ContentType)
					End If
			End Select
		End Sub

		Private Sub ResponseDocument(ByVal context As HttpContext, ByVal documentName As String, ByVal fileExtension As String, ByRef fileContent As Byte(), ByVal fileContentType As String)
            
			Dim fileName As String
			If fileExtension.Length > 0 Then
				fileName = documentName & "." & fileExtension
			Else
				fileName = documentName
			End If
            
			With context.Response
				.Expires = 0
				.Buffer = True
				.Clear()
				.ContentType = fileContentType
				.AddHeader("Content-Disposition", "inline; filename=" & fileName)
				.BinaryWrite(fileContent)
			End With
		End Sub
 
		Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
			Get
				Return False
			End Get
		End Property

	End Class
    
End Namespace