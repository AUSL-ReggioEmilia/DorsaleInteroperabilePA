Imports DwhClinico.Web
Imports DwhClinico.Web.Utility

Partial Class Portale_Container
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Try
            '
            ' Carica la barra di navigazione
            '
            Dim oNavBar As AbstractBarraNavigazione
            oNavBar = Me.LoadControl("~/NavigationBar.ascx")
            DivNavBar.Controls.Add(oNavBar)
            '
            ' Apre l'url in un InLine Frame
            '
            Dim sUrlContent As String = Me.Request.QueryString(PAR_URL) & ""
            If sUrlContent.Length = 0 Then
                Throw New Exception("Manca il paramentro 'Url'!")
            End If
            Dim sNavName As String = Me.Request.QueryString(PAR_PAGE_TITLE) & ""

            sUrlContent = Me.ResolveUrl(sUrlContent)
            '
            ' Imposto InLine Frame
            '
            Me.IframeMain.Attributes.Add("src", sUrlContent)
            Me.LinkNoIframeMain.HRef = sUrlContent
            '
            ' Visualizzazione NavBar + titolo della pagina
            '
            If sNavName.Length > 0 Then
                '
                ' Setto barra di navigazione
                '
                oNavBar.SetCurrentItem(sNavName, Me.Request.Url.AbsoluteUri)
                '
                ' Titolo
                '
                LabelTitle.Text = sNavName
            End If
            '
            ' Per Visualizzare i dati della Navigation Bar
            '
            Me.DataBind()

        Catch ex As Exception
            '
            ' Errore
            '
            MyLogging.WriteError(ex, Me.GetType.Name)
            Response.Redirect(Me.ResolveUrl("~/MissingResource.htm"))
        End Try

    End Sub

End Class
