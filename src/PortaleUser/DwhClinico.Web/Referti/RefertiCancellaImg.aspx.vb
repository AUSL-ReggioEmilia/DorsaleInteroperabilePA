Imports DwhClinico.Data
Imports DwhClinico.Web

Partial Class Referti_RefertiCancellaImg
    Inherits System.Web.UI.Page
    '
    'TODO: VIENE USATA QUESTA PAGINA??? ...da dove viene chiamata questa pagina devo passare il parametro Sistema_Erogante
    '
    Private Const CACHE_KEY_REFERTI_CANCELLA_IMAGE As String = "{0}_{1}_{2}_{3}_referti_cancella_image"

    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

        Dim sAziendaErogante As String
        Dim sSistemaErogante As String
        Dim sRepartoErogante As String
        Dim oBitmap As System.Drawing.Bitmap
        '
        ' Legge i parametri
        '
        sAziendaErogante = Request.QueryString("azienda_erogante") & ""
        sSistemaErogante = Request.QueryString("sistema_erogante") & ""
        sRepartoErogante = Request.QueryString("reparto_erogante") & ""

        oBitmap = GetImage(sAziendaErogante, sSistemaErogante, sRepartoErogante)

        Response.Expires = 0
        Response.Clear()
        Response.BufferOutput = True
        Response.ContentType = "image/gif"
        Response.AddHeader("content-disposition", "inline")
        oBitmap.Save(Response.OutputStream, System.Drawing.Imaging.ImageFormat.Gif)
        '
        ' 2012-11-28 - Commentato per esigenze di monitoring
        '
        'Response.End()
    End Sub

    Private Function GetImage(ByVal sAziendaErogante As String, ByVal sSistemaErogante As String, ByVal sRepartoErogante As String) As System.Drawing.Bitmap
        '
        ' Restituisce l'immagine verificando i permessi dell'utente.
        ' L'immagine viene messa in cache (legata all'utente, all'azienda erogante e al reparto erogante) per un breve intervallo di tempo,
        ' ciò evita che vengano effettuati i controlli ogni volta durante la costruzione della lista dei referti.
        '
        Dim sImagesVirtual As String
        Dim sFileName As String
        Dim sFilePath As String
        Dim oBuffer As Object
        Dim oBitmap As System.Drawing.Bitmap
        Dim sUserName As String
        Dim sCacheKey As String

        With HttpContext.Current
            If .User.Identity.IsAuthenticated Then
                sUserName = HttpContext.Current.User.Identity.Name
            Else
                '
                ' Anonimo
                '
                sUserName = "ASPNET"
            End If

            sCacheKey = String.Format(CACHE_KEY_REFERTI_CANCELLA_IMAGE, sUserName, sAziendaErogante, sSistemaErogante, sRepartoErogante)
            oBuffer = .Cache.Get(sCacheKey)

            If oBuffer Is Nothing Then
                If Utility.VerificaPermessiCancellazioneReferto(sAziendaErogante, sSistemaErogante, sRepartoErogante) Then
                    sFileName = "RefertiCancella.gif"
                Else
                    sFileName = "PixelTrasparente.gif"
                End If

                sImagesVirtual = ResolveUrl("~/images/")
                sFilePath = Server.MapPath(sImagesVirtual & sFileName)
                oBitmap = New System.Drawing.Bitmap(sFilePath)

                .Cache.Insert(sCacheKey, oBitmap, Nothing, DateTime.Now.AddSeconds(30), TimeSpan.Zero)
            Else
                oBitmap = CType(oBuffer, System.Drawing.Bitmap)
            End If
        End With

        Return oBitmap

    End Function

End Class
