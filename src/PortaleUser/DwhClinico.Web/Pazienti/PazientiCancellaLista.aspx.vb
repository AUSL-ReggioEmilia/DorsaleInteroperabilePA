Imports DwhClinico.Web
Imports DwhClinico.Data
Imports DwhClinico.Web.Utility
'***********************************************************************************************************
' ATTENZIONE: questa pagina un tempo era un entry point, ora non è più utilizzata
' vediamo se dismetterla completamente
'***********************************************************************************************************
Partial Class Pazienti_PazientiCancellaLista
    Inherits System.Web.UI.Page

    Dim msPageName As String = ""
    Private mbCancelSelectOperation As Boolean = False

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Try
            msPageName = Me.GetType.Name
            '
            ' Aggiungo lo script per lo stylesheet
            '
            'PageAddCss(Me)
            '
            ' Solo la prima volta
            '
            If Not IsPostBack Then
                '
                ' Invalido la cache della lista dei pazienti 
                '
                If Not Session(SESS_INVALIDA_CACHE_LISTA_PAZIENTI) Is Nothing Then
                    Session(SESS_INVALIDA_CACHE_LISTA_PAZIENTI) = Nothing
                    Call DataSourceMain_InvalidaCache()
                End If

                If Not VerificaPermessiCancellazionePaziente() Then
                    '
                    ' Accesso negato
                    '
                    Response.Redirect(Me.ResolveUrl("~/AccessDenied.htm"))
                    '
                    ' 2012-11-28 - Commentato per esigenze di monitoring
                    '
                    'Response.End()
                End If
                '
                ' Inizializzazioni della pagina;
                ' visualizzo la modalità d'inserimento della data nel formato corrente
                '
                spanDataNascita.InnerHtml = Utility.FormatDateDescription()

                '
                ' Ripristino parametri di ricerca
                '
                txtCognome.Text = Me.Session(msPageName & PAR_COGNOME) & ""
                txtNome.Text = Me.Session(msPageName & PAR_NOME) & ""
                txtDataNascita.Text = Me.Session(msPageName & PAR_DATA_NASCITA) & ""
                txtLuogoNascita.Text = Me.Session(msPageName & PAR_LUOGO_NASCITA) & ""
                '
                ' Aggiorno la barra di navigazione
                '
                BarraNavigazione.ClearAll()
                BarraNavigazione.SetCurrentItem("Cancellazioni paziente", Me.Request.Url.AbsoluteUri)
            End If

        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            '
            ' Gestione dell'errore
            '
            Logging.WriteError(ex, "Page_Load")
            lblErrorMessage.Text = "Errore durante il caricamento della pagina!"

        End Try

    End Sub

    Protected Sub cmdCerca_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdCerca.Click

        Try
            mbCancelSelectOperation = False
            Dim sValidationMessage As String = ValidateFiltersValue()
            If String.IsNullOrEmpty(sValidationMessage) Then
                '
                ' Invalido la cache
                '
                Call DataSourceMain_InvalidaCache()

                Me.Session(msPageName & PAR_COGNOME) = txtCognome.Text
                Me.Session(msPageName & PAR_NOME) = txtNome.Text
                Me.Session(msPageName & PAR_DATA_NASCITA) = txtDataNascita.Text
                Me.Session(msPageName & PAR_LUOGO_NASCITA) = txtLuogoNascita.Text
                '
                ' Eseguo il bind della griglia con i dati
                ' Me.DataBind()
                '
                GridViewMain.DataBind()
            Else
                lblErrorMessage.Text = sValidationMessage
                mbCancelSelectOperation = True
            End If

        Catch ex As Exception
            '
            ' Gestione dell'errore
            '
            Logging.WriteError(ex, "cmdCerca_Click")
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
        End Try

    End Sub

    Private Sub DataSourceMain_InvalidaCache()
        If DataSourceMain.EnableCaching Then
            Dim sCacheKeyDependency As String = DataSourceMain.CacheKeyDependency
            If Not String.IsNullOrEmpty(sCacheKeyDependency) Then
                HttpContext.Current.Cache(sCacheKeyDependency) = New Object
            End If
        End If
    End Sub


#Region "DataSourceMain"

    Private Sub DataSourceMain_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourceMain.Selected
        Try
            If e.Exception IsNot Nothing Then
                '
                ' Errore
                '
                Logging.WriteError(e.Exception, Me.GetType.Name)
                lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
                e.ExceptionHandled = True
            End If
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
        End Try
    End Sub

    Private Sub DataSourceMain_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DataSourceMain.Selecting
        Try
            If mbCancelSelectOperation = True Then
                e.Cancel = True
            End If
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
        End Try
    End Sub



    ''' <summary>
    ''' Restituisce il messagggio di errore di validazione
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function ValidateFiltersValue() As String
        Dim sRetMsg As String = String.Empty
        Try
            If txtDataNascita.Text.Length > 0 Then
                Dim odate As DateTime '= Date.Parse(txtDataReferto.Text) ' con questa si genera errore
                If Not Date.TryParse(txtDataNascita.Text, odate) Then ' con questa non si genera errore ma si manda messaggio
                    sRetMsg = "Il filtro ""Data nascita"" non è compilato correttamente!"
                End If
            End If

        Catch ex As Exception
            Logging.WriteWarning("Errore durante l'operazione di validazione dei filtri!" & vbCrLf & Utility.FormatException(ex))
        End Try
        '
        '
        '
        Return sRetMsg
    End Function
#End Region
End Class
