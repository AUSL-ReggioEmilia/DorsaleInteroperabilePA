Imports System
Imports System.IO
Imports System.Web.UI
Imports System.Web

Namespace DI.DataWarehouse.Admin

    Partial Class FileUpload
        Inherits Page

        ' I parametri vengono passati tramite l'oggetto Context() usando Server.Transfer nella pagina chiamante
        ' Analogamente i dati di upload vengono passati alla pagina chiamante con un Server.Transfer eseguito da questa pagina        
        Const VS_URL_REFERRER As String = "file_upload_url_referrer"
        Const VS_POST_URL As String = "vs-post-url"
        Const VS_CONFIRM_URL As String = "vs-confirm-url"

        Private Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles MyBase.Load

            Dim title As String = CType(Context.Items(Upload.KEY_UPLOAD_PAGE_TITLE), String)
            If title IsNot Nothing Then
                TitleLabel.Text = title
            End If

            Dim info As String = CType(Context.Items(Upload.KEY_UPLOAD_INFO), String)
            If info IsNot Nothing Then
                InfoLabel.Text = info
            End If

            If Not IsPostBack Then

                ' Memorizza la parametrizzazione per averla disponibile anche nei postback
                ViewState(Upload.KEY_UPLOAD_MAX_FILE_SIZE_KB) = Context.Items(Upload.KEY_UPLOAD_MAX_FILE_SIZE_KB)
                ViewState(Upload.KEY_UPLOAD_ALLOWED_EXTENSIONS) = Context.Items(Upload.KEY_UPLOAD_ALLOWED_EXTENSIONS)
                ViewState(Upload.KEY_UPLOAD_CONTENT_TYPE_FILTERS) = Context.Items(Upload.KEY_UPLOAD_CONTENT_TYPE_FILTERS)

                ' Memorizzo l'indirizzo di ritorno
                If ViewState(VS_URL_REFERRER) Is Nothing Then

                    Dim contextItem As Object = Context.Items(Upload.KEY_UPLOAD_RETURN_URL)

                    If contextItem Is Nothing AndAlso Context.Request.UrlReferrer IsNot Nothing Then
                        ViewState(VS_URL_REFERRER) = Context.Request.UrlReferrer.PathAndQuery
                    Else
                        ViewState(VS_URL_REFERRER) = CType(contextItem, String)
                    End If
                End If
            End If
        End Sub

        Private Sub OkButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles OkButton.Click

            Dim errorMessage As String
            Dim httpPostedfile As HttpPostedFile = InputFile.PostedFile

            If httpPostedfile.ContentLength > 0 Then
                errorMessage = ValidateUpload(httpPostedfile)
            Else
                errorMessage = "Impossibile caricare il file!<BR>La dimensione del file è 0 Byte.<BR>Verificare il percorso del file."
            End If

			If errorMessage.Length = 0 Then

				' Salva nel Context il File e ritorno alla pagina in cui è stato eseguito il server transfer
				Context.Items.Add(Upload.KEY_UPLOAD_POSTED_FILE, httpPostedfile)
				Context.Items.Add(Upload.KEY_UPLOAD_CANCEL_BUTTON, Nothing)
				Server.Transfer(CType(ViewState(VS_URL_REFERRER), String), False)
			Else
				ErrorMessageLabel.Text = errorMessage
                ErrorMessageLabel.Visible = True
            End If
        End Sub

        ''' <summary>
        ''' Ritorna al chiamante segnalando che l'utente ha premuto "ANNULLA"
        ''' </summary>
        ''' <param name="sender"></param>
        ''' <param name="e"></param>
        ''' <remarks></remarks>
        Private Sub CancelButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles CancelButton.Click

            Context.Items.Add(Upload.KEY_UPLOAD_POSTED_FILE, Nothing)
            Context.Items.Add(Upload.KEY_UPLOAD_CANCEL_BUTTON, 1)
            Server.Transfer(CType(ViewState(VS_URL_REFERRER), String), False)
        End Sub

        ''' <summary>
        ''' Effettua i controlli sul file caricato
        ''' </summary>
        ''' <param name="httpPostedFile"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Private Function ValidateUpload(ByVal httpPostedFile As HttpPostedFile) As String

            Dim errorMessage As String = String.Empty
            Dim maxSizeKb As Integer
            Dim allowedExtensions As String
            Dim contentTypeFilter As String
            Dim formatError As Boolean

            Dim contextItem As Object = ViewState(Upload.KEY_UPLOAD_MAX_FILE_SIZE_KB)

            If contextItem IsNot Nothing Then
                maxSizeKb = CType(contextItem, Integer)
            End If

            allowedExtensions = CType(ViewState(Upload.KEY_UPLOAD_ALLOWED_EXTENSIONS), String)
            contentTypeFilter = CType(ViewState(Upload.KEY_UPLOAD_CONTENT_TYPE_FILTERS), String)

            ' Controlla la dimensione
            ' Se iMaxSizeKb = 0 la dimensione non viene controllata!
            If maxSizeKb > 0 Then

                Dim iMaxSizeByte As Integer = maxSizeKb * 1024

                If httpPostedFile.ContentLength > iMaxSizeByte Then
					errorMessage &= String.Format("La dimensione del file supera il limite massimo di {0}KB", maxSizeKb) & "<br />"
				End If
            End If

            formatError = (allowedExtensions.Length > 0 AndAlso allowedExtensions.IndexOf(Path.GetExtension(httpPostedFile.FileName)) = -1) OrElse (contentTypeFilter.Length > 0 AndAlso Not httpPostedFile.ContentType Like contentTypeFilter)

            If formatError Then
				errorMessage &= "Il file ha un'estensione non consentita!<br />"
			End If

            Return errorMessage
        End Function

#Region "Funzioni usate nell'HTML"

        Protected Function GetPostUrl() As String
            Return CType(ViewState(VS_POST_URL), String)
        End Function

        Protected Function GetConfirmationUrl() As String
            Return CType(ViewState(VS_CONFIRM_URL), String)
        End Function

#End Region

    End Class

End Namespace