Imports DI.Dispatcher.User

'-----------------------------------------------------------------------------------------------------------
' Utilizzata per redirezionare la navigazione all'ultima pagina visitata dall'utente
' Bisogna configurare nel database "DiUserPortal", tabella "ConfigurazioneMenu" il record
' relativo all'applicazione web. 
' Esempi:
'       /<NomeWebApp>/PortalRedirect.aspx
'       /<NomeWebApp>/PortalRedirect.aspx?URL=/<NomeWebApp>/<paginadesiderata.aspx>
' Se il parametro URL     È CONFIGURATO e la sessione è scaduta l'utente verrà ridirezionato all'url specificato
' Se il parametro URL NON È CONFIGURATO e la sessione è scaduta l'utente verrà ridirezionato a "~/", cioè la pagina di default configurata su IIS
'-----------------------------------------------------------------------------------------------------------
Public Class PortalRedirect
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            Call GoToUrlCorrente("~/")
        Catch ex As Exception
            GestioneErrori.WriteException(ex)
            '
            ' In caso di errore redirigo a pagina di default
            '
            Response.Redirect("~/", False)
        End Try
    End Sub

    ''' <summary>
    ''' Naviga all'ultima pagina visitata; se url nothing naviga al default
    ''' </summary>
    ''' <param name="sDefaultUrl">url di default</param>
    ''' <remarks></remarks>
    Private Sub GoToUrlCorrente(ByVal sDefaultUrl As String)
        '
        ' Prelevo url memorizzato in sessione
        '
        Dim sUrl As String = Utility.GetUrlCorrente()
        If String.IsNullOrEmpty(sUrl) Then
            '
            ' Leggo il parametro URL eventualmente per impostare dall'esterno una pagina diversa dalla default
            ' (impostato nella configurazione del menu orizzontale in DiPortalUser)
            '
            sUrl = HttpContext.Current.Request.QueryString("URL")
            If String.IsNullOrEmpty(sUrl) Then
                '
                ' Redirigo al default: ovviamente deve essere configurata in IIS una pagina di default
                '
                sUrl = sDefaultUrl
            End If
        End If
        '
        ' Redirezione all'url desiderato
        '
        Response.Redirect(sUrl, False)
    End Sub

End Class