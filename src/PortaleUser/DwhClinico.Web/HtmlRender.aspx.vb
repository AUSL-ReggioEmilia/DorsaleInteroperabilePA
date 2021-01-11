Imports System
Imports System.Web
Imports DwhClinico.Web.Utility

Partial Class HtmlRender
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim sUrlToRender As String = String.Empty
        Try
            sUrlToRender = Context.Request.QueryString(PAR_URL_TO_RENDER)
            If String.IsNullOrEmpty(sUrlToRender) Then
                Throw New Exception(String.Format("Il parametro '{0}' è obbligatorio!.", PAR_URL_TO_RENDER))
            End If
            '
            ' Response dei byte 
            '
            Dim oByte As Byte() = RefertoRendering(sUrlToRender)
            If Not (oByte Is Nothing OrElse oByte.Length = 0) Then
                Call ResponseDocument(Context, "DettaglioReferto", "pdf", oByte, "application/pdf")
            Else
                MyLogging.WriteError(Nothing, String.Format("Impossibile renderizzare l'HTML dell'Url: '{0}'.", sUrlToRender))
            End If

        Catch ex As Exception
            MyLogging.WriteError(ex, "Si è verificato un errore durante Page_Load()")
        End Try
    End Sub


#Region "Metodi privati"

    ''' <summary>
    ''' Restituisce i byte della pagina renderizzata in PDF
    ''' </summary>
    ''' <param name="sUrlToRender"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function RefertoRendering(ByVal sUrlToRender As String) As Byte()
        Using oWsRendering As New WsRenderingPdf.RenderingPdfSoapClient

            Dim sUser As String = My.Settings.WsRenderingPdf_User
            Dim sPassword As String = My.Settings.WsRenderingPdf_Password
            Utility.SetWCFCredentials(oWsRendering.ChannelFactory.Endpoint.Binding, oWsRendering.ClientCredentials, sUser, sPassword)
            Return PrintUtil.GetBytesRefertoHTML(oWsRendering, sUrlToRender, HttpContext.Current.User.Identity.Name)

        End Using
        Return Nothing
    End Function

    ''' <summary>
    ''' Esegue il response bynary 
    ''' </summary>
    ''' <param name="oContext"></param>
    ''' <param name="sDocumentName"></param>
    ''' <param name="sFileExtension"></param>
    ''' <param name="oByte"></param>
    ''' <param name="sFileContentType"></param>
    ''' <remarks></remarks>
    Private Sub ResponseDocument(ByVal oContext As HttpContext, _
                                 ByVal sDocumentName As String, _
                                 ByVal sFileExtension As String, _
                                 ByRef oByte As Byte(), ByVal sFileContentType As String)
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
            .AddHeader("Content-Disposition", "inline; filename=" & sDocumentName)
            .BinaryWrite(oByte)
        End With
    End Sub

#End Region

End Class
