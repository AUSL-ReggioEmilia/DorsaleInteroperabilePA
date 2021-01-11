Imports DwhClinico.Data
Public Class RefertoDettaglioEsterno
    Inherits System.Web.UI.UserControl


    Public Property UrlContent As String
        '
        'Property che salva nel view state l'url a visualizzazioni.
        '
        Get
            Return CType(Me.ViewState("UrlContent"), String)
        End Get
        Set(value As String)
            Me.ViewState("UrlContent") = value
        End Set
    End Property

    Public Property CancelSelect As Boolean
        '
        'Salva nel view state se non deve essere eseguito il codice.
        '
        Get
            Return CType(Me.ViewState("CancelSelect"), Boolean)
        End Get
        Set(value As Boolean)
            Me.ViewState("CancelSelect") = value
        End Set
    End Property


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            If Not CancelSelect Then
                divErrorMessage.Visible = False
                lblErrorMessage.Text = String.Empty

                '
                'Testo se la variabile UrlContent è valorizzata. Se non è valorizzata allora eseguo il trhow di una eccezione.
                '
                If String.IsNullOrEmpty(Me.UrlContent) Then
                    Throw New Exception("L'url dell'iframe non può essere vuoto.")
                End If

                '
                'Se sono qui allora la variabile UrlContent è valorizzata correttamente.
                '
                Me.IframeMain.Attributes.Add("src", Me.UrlContent)
                Me.LinkNoIframeMain.HRef = Me.UrlContent
            End If
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            'loggo l'errore
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub
End Class