Imports DwhClinico.Data
'
' La pagina legge dalla sessione il tipo di errore e la descrizione dell'errore
'
'
Public Class ErrorPage
    Inherits System.Web.UI.Page

    Private Const ERRORE_CODICE As String = "ERRORPAGE_ERRORE_CODICE"
    Private Const ERRORE_DESCRIZIONE As String = "ERRORPAGE_ERRORE_DESCRIZIONE"

    Public Shared Sub SetErrorDescription(iErroreCodice As Utility.ErrorCode, sErroreDescrizione As String)
        HttpContext.Current.Session(ERRORE_CODICE) = iErroreCodice
        HttpContext.Current.Session(ERRORE_DESCRIZIONE) = sErroreDescrizione
    End Sub


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim sErroreDescrizione As String
        Dim iErroreCodice As Utility.ErrorCode
        Try
            iErroreCodice = DirectCast(HttpContext.Current.Session(ERRORE_CODICE), Utility.ErrorCode)
            sErroreDescrizione = DirectCast(HttpContext.Current.Session(ERRORE_DESCRIZIONE), String)
            If Not IsPostBack Then
                Select Case iErroreCodice
                    Case Utility.ErrorCode.Unknow
                        imgErrorImage.ImageUrl = Me.ResolveUrl("~/Images/ErrorUnknown.gif")
                        lblErroreDescrizioneBreve.Text = "ERRORE SCONOSCIUTO"
                    Case Utility.ErrorCode.NoRights
                        imgErrorImage.ImageUrl = Me.ResolveUrl("~/Images/ErrorAccessDenied.jpg")
                        lblErroreDescrizioneBreve.Text = "L'UTENTE NON HA I DIRITTI PER ACCEDERE"
                    Case Utility.ErrorCode.AccessDenied
                        imgErrorImage.ImageUrl = Me.ResolveUrl("~/Images/ErrorAccessDenied.jpg")
                        lblErroreDescrizioneBreve.Text = "L'UTENTE NON HA I DIRITTI PER ACCEDERE"
                    Case Utility.ErrorCode.MissingResource
                        imgErrorImage.ImageUrl = Me.ResolveUrl("~/Images/ErrorMissingResource.gif")
                        lblErroreDescrizioneBreve.Text = "RISORSA MANCANTE" '"Una risorsa necessaria per la visualizzazione della pagina non esiste"
                    Case Utility.ErrorCode.Exception
                        imgErrorImage.ImageUrl = Me.ResolveUrl("~/Images/ErrorUnknown.gif")
                        lblErroreDescrizioneBreve.Text = "ERRORE"
                    Case Else
                        imgErrorImage.ImageUrl = Me.ResolveUrl("~/Images/ErrorUnknown.gif")
                        lblErroreDescrizioneBreve.Text = "ERRORE SCONOSCIUTO"
                End Select
                lblErroreDescrizione.Text = sErroreDescrizione
            End If
        Catch ex As Exception
            '
            ' Nascondo i controlli perchè l'errore è avvenuto sulla pagina
            '
            imgErrorImage.Visible = False
            lblErroreDescrizioneBreve.Visible = False
            lblErroreDescrizione.Visible = False
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = "Errore durante il caricamento della pagina."
            alertErrorMessage.Visible = True
        End Try
    End Sub

End Class