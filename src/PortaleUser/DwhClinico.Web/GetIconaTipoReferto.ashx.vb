Imports System.Web
Imports System.Web.Services

Public Class GetIconaTipoReferto
    Implements System.Web.IHttpHandler

    Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Dim sIdTipiReferto As String = context.Request.QueryString("IdTipoReferto")
        If Not String.IsNullOrEmpty(sIdTipiReferto) Then
            sIdTipiReferto = sIdTipiReferto.ToUpper
            '
            ' Leggo i possibili tipi di referto (sempre valorizzata)
            '
            Dim dsDizionarioTipiRefertoOttieni As New CustomDataSource.DizionarioTipiRefertoOttieni
            Dim oDizionarioTipiRefertoListaType As WcfDwhClinico.DizionarioTipiRefertoListaType = dsDizionarioTipiRefertoOttieni.GetData()

            Dim oList As List(Of WcfDwhClinico.DizionarioTipoRefertoListaType) = oDizionarioTipiRefertoListaType.Where(Function(e) e.Id = sIdTipiReferto).ToList()
            If Not oList Is Nothing AndAlso oList.Count > 0 Then
                Call ResponseDocument(context, "", "", oList.Item(0).Icona, "image/png")
            End If

        End If

    End Sub

    ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property


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
            ' .AddHeader("Content-Disposition", "inline; filename=" & sFileName)
            .BinaryWrite(oArrayFileContainer)
        End With
    End Sub


End Class