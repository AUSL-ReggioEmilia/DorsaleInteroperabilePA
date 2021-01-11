Imports DwhClinico.Web
Imports DwhClinico.Data
Imports DwhClinico.Web.Utility
'-----------------------------------------------------------------------------------------------------------------------
' Come è usata questa pagina?
'
' Il nome della pagina non compare nel codice quindi non viene mai composto un URL per navigare a questa pagina
' Utilizza la configurazione:
'       <add key="Referti.Link" value="~/Reporting/Reports/GroupListaReferti.aspx?@@FLD@@@IdPaziente=@Id_Paziente"/>
' e sostituisce @Id_Paziente con l'Id del paziente
' e apre URL in un IFrame.
'-----------------------------------------------------------------------------------------------------------------------
Partial Class Referti_RefertiLista
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim oSacDettaglioPaziente As SacDettaglioPaziente = Nothing
        Try
            If Not Me.IsPostBack Then
                '
                ' Leggo il QueryString
                '
                Dim sIdPaziente As String = Request.QueryString(PAR_ID_PAZIENTE) & ""
                If sIdPaziente.Length = 0 Then
                    Throw New Exception("Manca il parametro IdPaziente!")
                End If
                '
                ' Prendo dalla Sessione i dati del paziente e del coonsenso
                '
                Try
                    'oSacDettaglioPaziente = CType(Me.Session(SESS_GLOBAL & PAR_PAZIENTE_DETTAGLIO), SacDettaglioPaziente)
                    oSacDettaglioPaziente = SacDettaglioPaziente.Session()
                Catch ex As Exception
                    oSacDettaglioPaziente = Nothing
                End Try
                If oSacDettaglioPaziente Is Nothing Then
                    '
                    ' Se c'è IdPaziente, consenso non trovato
                    '
                    lblErrorMessage.Text = "Consenso non trovato!"
                    lblErrorMessage.Visible = True
                    Exit Sub
                Else
                    If oSacDettaglioPaziente.IdPaziente.ToString.ToLower <> sIdPaziente.ToLower Then
                        '
                        ' Se NON c'è IdPaziente, consenso non trovato
                        '
                        lblErrorMessage.Text = "Consenso non valido!"
                        lblErrorMessage.Visible = True
                        Exit Sub
                    End If
                End If
                '
                ' Traccia accessi
                '
                Utility.TracciaAccessiLista("Lista referti", oSacDettaglioPaziente.IdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote)
                '
                ' Setto barra di navigazione
                '
                NavBar.SetCurrentItem("Referti lista", Me.Request.Url.AbsoluteUri)
                '
                ' Apre l'url in un InLine Frame
                '
                Dim sUrlContent As String = My.Settings.Referti_Link
                sUrlContent = sUrlContent.Replace(FLD_ID_PAZIENTE, sIdPaziente)

                sUrlContent = Me.ResolveUrl(sUrlContent)

                Me.IframeMain.Attributes.Add("src", sUrlContent)
                Me.LinkNoIframeMain.HRef = sUrlContent
            End If

        Catch ex As Exception
            Logging.WriteError(ex, "Referti_RefertiLista")
            Response.Redirect(Me.ResolveUrl("~/MissingResource.htm"))
        End Try

    End Sub

End Class
