Imports System.Web

''' <summary>
''' GESTIONE DEI FILE CARICATI TRAMITE LA PAGINA PAGES/FILEUPLOAD.ASPX
''' </summary>
Public NotInheritable Class Upload

	Private Sub New()

	End Sub

	Public Const UPLOAD_CONFIRM_URL As String = "upd_confirm_url"
	Public Const UPLOAD_POST_URL As String = "upd_post_url"

	Public Const KEY_UPLOAD_POSTED_FILE As String = "key-upd-posted-file"
	Public Const KEY_UPLOAD_CANCEL_BUTTON As String = "key-upd-cancel-upload"
	Public Const KEY_UPLOAD_OK_UPLOAD As String = "key-upd-ok-upload"
	Public Const KEY_UPLOAD_PAGE_TITLE As String = "key-upd-page-title"
	Public Const KEY_UPLOAD_INFO As String = "key-upd-help"
	Public Const KEY_UPLOAD_MAX_FILE_SIZE_KB As String = "key-upd-max-file-size"
	Public Const KEY_UPLOAD_ALLOWED_EXTENSIONS As String = "key-upd-allowed-ext"
	Public Const KEY_UPLOAD_CONTENT_TYPE_FILTERS As String = "key-upd-content-type-filters"
	Public Const KEY_UPLOAD_RETURN_URL As String = "key-upd-ret-url"

	Public Shared Sub NavigateToUploadPage(ByVal sUploadPageUrl As String,
								ByVal sPageTitle As String,
								ByVal sPageInfo As String,
								ByVal sReturnUrl As String,
								ByVal iMaxSizeKb As Integer,
								ByVal sAllowedExtensions As String,
								ByVal sContentTypeFiltersList As String)

		If HttpContext.Current.Items(KEY_UPLOAD_POSTED_FILE) Is Nothing Then
			If HttpContext.Current.Items(KEY_UPLOAD_CANCEL_BUTTON) Is Nothing Then

				With HttpContext.Current
					.Items.Add(KEY_UPLOAD_PAGE_TITLE, sPageTitle)
					.Items.Add(KEY_UPLOAD_INFO, sPageInfo)
					.Items.Add(KEY_UPLOAD_RETURN_URL, sReturnUrl)
					.Items.Add(KEY_UPLOAD_MAX_FILE_SIZE_KB, iMaxSizeKb)
					.Items.Add(KEY_UPLOAD_ALLOWED_EXTENSIONS, sAllowedExtensions)
					.Items.Add(KEY_UPLOAD_CONTENT_TYPE_FILTERS, sContentTypeFiltersList)
				End With

				HttpContext.Current.Server.Transfer(sUploadPageUrl, True)
			End If
		End If
	End Sub

	Public Shared Function UploadCanceled() As Boolean
		Return HttpContext.Current.Items(KEY_UPLOAD_CANCEL_BUTTON) IsNot Nothing
	End Function

	Public Shared Function UploadSuccessFully() As Boolean
		Return HttpContext.Current.Items(KEY_UPLOAD_POSTED_FILE) IsNot Nothing
	End Function

	Public Shared Function HttpPostedFile() As HttpPostedFile
		Return DirectCast(HttpContext.Current.Items(KEY_UPLOAD_POSTED_FILE), HttpPostedFile)
	End Function

	Public Shared Function HttpPostedFileBytes() As Byte()

		Dim fs = HttpPostedFile.InputStream
		Dim br As New System.IO.BinaryReader(fs)
		Return br.ReadBytes(fs.Length)

	End Function
End Class

