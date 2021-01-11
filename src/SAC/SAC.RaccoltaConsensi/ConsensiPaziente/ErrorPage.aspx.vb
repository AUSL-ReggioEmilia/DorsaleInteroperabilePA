'
' La pagina legge dalla sessione il tipo di errore e la descrizione dell'errore
'
'
Public Class ErrorPage
    Inherits System.Web.UI.Page

    ''' <summary>
    '''  Imposto l'enum relativo ai codici d'errore
    ''' </summary>
    Public Enum ErrorCode
        Unknown
        AccessDenied
        NoRights
        MissingResource
        Exception
    End Enum

    Private Const ERRORE_CODICE As String = "ERRORPAGE_ERRORE_CODICE"
    Private Const ERRORE_DESCRIZIONE As String = "ERRORPAGE_ERRORE_DESCRIZIONE"

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            Dim sErrorDescription As String = String.Empty
            Dim iErrorCode As ErrorCode = ErrorCode.Unknown
            If Not HttpContext.Current.Session(ERRORE_CODICE) Is Nothing Then iErrorCode = DirectCast(HttpContext.Current.Session(ERRORE_CODICE), ErrorCode)
            If Not HttpContext.Current.Session(ERRORE_DESCRIZIONE) Is Nothing Then sErrorDescription = DirectCast(HttpContext.Current.Session(ERRORE_DESCRIZIONE), String)

            If Not IsPostBack Then
                Select Case iErrorCode
                    Case ErrorCode.Unknown
                        imgErrorImage.ImageUrl = Me.ResolveUrl("~/Images/ErrorUnknown.gif")
                        lblErroreDescrizioneBreve.Text = "ERRORE SCONOSCIUTO"
                    Case ErrorCode.NoRights
                        imgErrorImage.ImageUrl = Me.ResolveUrl("~/Images/ErrorAccessDenied.jpg")
                        lblErroreDescrizioneBreve.Text = "L'UTENTE NON HA I DIRITTI PER ACCEDERE"
                    Case ErrorCode.AccessDenied
                        imgErrorImage.ImageUrl = Me.ResolveUrl("~/Images/ErrorAccessDenied.jpg")
                        lblErroreDescrizioneBreve.Text = "L'UTENTE NON HA I DIRITTI PER ACCEDERE"
                    Case ErrorCode.MissingResource
                        imgErrorImage.ImageUrl = Me.ResolveUrl("~/Images/ErrorMissingResource.gif")
                        lblErroreDescrizioneBreve.Text = "RISORSA MANCANTE"  '"Una risorsa necessaria per la visualizzazione della pagina non esiste"
                    Case ErrorCode.Exception
                        imgErrorImage.ImageUrl = Me.ResolveUrl("~/Images/ErrorUnknown.gif")
                        lblErroreDescrizioneBreve.Text = "ERRORE"
                    Case Else
                        imgErrorImage.ImageUrl = Me.ResolveUrl("~/Images/ErrorUnknown.gif")
                        lblErroreDescrizioneBreve.Text = "ERRORE SCONOSCIUTO"
                End Select
                lblErroreDescrizione.Text = sErrorDescription
            End If
        Catch ex As Exception
            '
            ' Nascondo i controlli perchè l'errore è avvenuto sulla pagina
            '
            imgErrorImage.Visible = False
            lblErroreDescrizioneBreve.Visible = False
            lblErroreDescrizione.Visible = False
            '
            ' Scrivo errore in event log
            '
            GestioneErrori.TrapError(ex)
            lblErrorMessage.Text = "Errore durante il caricamento della pagina."
            alertErrorMessage.Visible = True
        End Try

    End Sub

    Public Shared Sub SetErrorDescription(iErroreCodice As ErrorCode, sErroreDescrizione As String)
        Try
            HttpContext.Current.Session(ERRORE_CODICE) = iErroreCodice
            HttpContext.Current.Session(ERRORE_DESCRIZIONE) = sErroreDescrizione
        Catch ex As Exception
            '
            ' Scrivo errore in event log
            '
            GestioneErrori.TrapError(ex)
        End Try
    End Sub

End Class