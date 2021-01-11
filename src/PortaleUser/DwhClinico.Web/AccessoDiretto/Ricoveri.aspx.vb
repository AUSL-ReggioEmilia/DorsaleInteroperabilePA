Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
Imports System.Security

Partial Class AccessoDiretto_Ricoveri
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            '
            ' Solo la prima volta
            '
            If Not IsPostBack Then
                'Mostro o nascondo l'header della masterpage in base a quanto indicato nella querystring o precedentemente in sessione
                Utility.CheckShowHeaderParam(Request)
                '
                ' Ottengo i parametri dal QueryString
                '
                Dim oQueryString As Specialized.NameValueCollection = Me.Request.QueryString
                Dim sIdPaziente As String = oQueryString(PAR_ID_PAZIENTE)
                Dim sIdPazienteEsterno As String = oQueryString(PAR_ID_ESTERNO) ' Affinchè una ricerca dell'IdPaziente per IdEsterno restituisca qualcosa bisogna che IdEsterno="SAC_<IdPazienteAttivo>"
                Dim sNomeAnagrafica As String = oQueryString(PAR_NOME_ANAGRAFICA)
                Dim sIdAnagrafica As String = oQueryString(PAR_ID_ANAGRAFICA)
                '
                ' Parametri aggiuntivi
                '
                Dim sNumeroNosologico As String = oQueryString(PAR_NUMERO_NOSOLOGICO)
                Dim sRepartoErogante As String = oQueryString(PAR_REPARTO_EROGANTE)
                Dim sRepartoRicoveroCodice As String = oQueryString(PAR_REPARTO_RICOVERO)
                Dim sDallaData As String = oQueryString(PAR_DALLA_DATA) 'sempre DD/MM/YYYY
                Dim dDallaData As Date = Nothing

                If Not String.IsNullOrEmpty(sDallaData) Then
                    If Not Date.TryParse(sDallaData, dDallaData) Then
                        Throw New ApplicationException(String.Format("Il parametro {0} non è formattato correttamente.", PAR_DALLA_DATA))
                    End If
                End If
                If Not String.IsNullOrEmpty(sIdPaziente) Then
                    Dim sUrl As String = Me.ResolveUrl("~/AccessoDiretto/Referti.aspx")
                    sUrl = String.Format("{0}?{1}={2}&{3}={4}&{5}={6}&{7}={8}", sUrl, PAR_ID_PAZIENTE, sIdPaziente, PAR_NUMERO_NOSOLOGICO, sNumeroNosologico, PAR_REPARTO_EROGANTE, sRepartoErogante, PAR_REPARTO_RICOVERO, sRepartoRicoveroCodice, PAR_DALLA_DATA, sDallaData)
                    Response.Redirect(sUrl, True)
                ElseIf Not String.IsNullOrEmpty(sIdPazienteEsterno) Then
                    '
                    ' Vedi mail di Foracchia: non serve più (lascio per segnalare che la ricerca non è valida)
                    '
                    Throw New ApplicationException(String.Format("La ricerca per {0} non è valida.", PAR_ID_ESTERNO))
                ElseIf Not String.IsNullOrEmpty(sNomeAnagrafica) AndAlso Not String.IsNullOrEmpty(sIdAnagrafica) Then
                    Dim sUrl As String = Me.ResolveUrl("~/AccessoDiretto/Referti.aspx")
                    sUrl = String.Format("{0}?{1}={2}&{3}={4}&{5}={6}&{7}={8}&{9}={10}", sUrl, PAR_NOME_ANAGRAFICA, sNomeAnagrafica, PAR_ID_ANAGRAFICA, sIdAnagrafica, PAR_NUMERO_NOSOLOGICO, sNumeroNosologico, PAR_REPARTO_EROGANTE, sRepartoErogante, PAR_REPARTO_RICOVERO, sRepartoRicoveroCodice, PAR_DALLA_DATA, sDallaData)
                    Response.Redirect(sUrl, True)
                Else
                    Throw New ApplicationException("La combinazione dei parametri non è valida.")
                End If
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            divErrorMessage.Visible = False
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante il caricamento della pagina!"
            divErrorMessage.Visible = False
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub
End Class

