Imports DI.PortalUser2
Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
Public Class MatricePrestazioniBySezioneCodice
    Inherits System.Web.UI.Page

    '**********************************************************************
    'ATTENZIONE:
    'VIENE RICHIAMATA ALL'INTERNO DI VISUALIZZAZIONI ("MetaforaCda_01_00")
    ''**********************************************************************

#Region "Property"
    Public Property IdPaziente As Guid
        'SALVO L'ID DEL PAZIENTE NEL VIEWSTATE PER AVERLO PER TUTTA LA DURATA DELLA PAGINA
        Get
            Return Me.ViewState("IdPaziente")
        End Get
        Set(value As Guid)
            Me.ViewState("IdPaziente") = value
        End Set
    End Property

    Public Property SezioneCodice As String
        'SALVO IL CODICE DELLA SEZIONE DELLA MATRICE.
        Get
            Return Me.ViewState("SezioneCodice")
        End Get
        Set(value As String)
            Me.ViewState("SezioneCodice") = value
        End Set
    End Property

    Private ReadOnly Property Token As WcfDwhClinico.TokenType
        ' OTTIENE IL TOKEN DA PASSARE COME PARAMETRO AGLI OBJECTDATASOURCE ALL'INTERNO DELLE TAB.
        ' UTILIZZA LA PROPERTY CODICERUOLO PER CREARE IL TOKEN
        Get
            Dim TokenViewState As WcfDwhClinico.TokenType = TryCast(Me.ViewState("Token"), WcfDwhClinico.TokenType)
            If TokenViewState Is Nothing Then

                TokenViewState = Tokens.GetToken(Me.CodiceRuolo)

                Me.ViewState("Token") = TokenViewState
            End If
            Return TokenViewState
        End Get
    End Property

    Private ReadOnly Property CodiceRuolo As String
        '
        ' Salva nel ViewState il codice ruolo dell'utente
        ' Utilizzata per creare il token da passare come parametro all'ObjectDataSource all'interno delle tab.
        '
        Get
            Dim sCodiceRuolo As String = Me.ViewState("CodiceRuolo")
            If String.IsNullOrEmpty(sCodiceRuolo) Then
                'PRENDO IL RUOLO DELL'UTENTE
                Dim oRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
                Dim oRuoloCorrente As RoleManager.Ruolo = oRoleManagerUtility.RuoloCorrente

                'SALVO IN VIEWSTATE
                sCodiceRuolo = oRuoloCorrente.Codice
                Me.ViewState("CodiceRuolo") = sCodiceRuolo
            End If

            Return sCodiceRuolo
        End Get
    End Property

    Private ReadOnly Property DescrizioneRuolo As String
        'SALVA NEL VIEWSTATE LA DESCRIZIONE DEL RUOLO DELL'UTENTE
        Get
            Dim sDescrizioneRuolo As String = Me.ViewState("DescrizioneRuolo")
            If String.IsNullOrEmpty(sDescrizioneRuolo) Then
                ' PRENDO IL RUOLO DELL'UTENTE
                Dim oRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
                Dim oRuoloCorrente As RoleManager.Ruolo = oRoleManagerUtility.RuoloCorrente
                ' SALVO IN VIEWSTATE
                sDescrizioneRuolo = oRuoloCorrente.Descrizione
                Me.ViewState("DescrizioneRuolo") = sDescrizioneRuolo
            End If

            Return sDescrizioneRuolo
        End Get
    End Property
#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim sIdPaziente As String = String.Empty
        Dim sSezioneCodice As String = String.Empty
        Try
            'UTILIZZO LA VARIABILE DI SESSIONE IsSessioneAttiva PER VERIFICARE SE LA SESSIONE È SCADUTA.
            If SessionHandler.ValidaSessioneAccessoStandard Is Nothing OrElse SessionHandler.ValidaSessioneAccessoStandard = False Then
                RedirectToHome()
            End If

            'OTTENGO I PARAMETRI DA QUERY STRING
            sIdPaziente = Me.Request.QueryString("IdPaziente")
            sSezioneCodice = Me.Request.QueryString("SezioneCodice")

            'IL PARAMETRO ID PAZIENTE È OBBLIGATORIO.
            If String.IsNullOrEmpty(sSezioneCodice) Then
                Throw New ApplicationException("Il parametro SezioneCodice è obbligatorio.")
            End If

            'IL PARAMETRO SEZIONE CODICE È OBBLIGATORIO.
            If String.IsNullOrEmpty(sIdPaziente) Then
                Throw New ApplicationException("Il parametro IdPaziente è obbligatorio.")
            End If

            If Not Page.IsPostBack Then
                'SALVO NEL VIEW STATE I PARAMETRI.
                Me.IdPaziente = New Guid(sIdPaziente)
                Me.SezioneCodice = sSezioneCodice

                'VALORIZZO L'URL ALLA PAGINA DI GESTIONE DEL CONSENSO. QUESTO URL CAMBIA TRA ACCESSOSTANDARD E ACCESSODIRETTO.
                ucTestataPaziente.UrlDettaglioConsensi = String.Format("~/Pazienti/GestioneConsensi.aspx?IdPaziente={0}", sIdPaziente)

                ' PASSO ALLA TESTATA DEL PAZIENTE IL TOKEN E L'ID DEL PAZIENTE PER FARE IL BIND DEI DATI.
                ucTestataPaziente.IdPaziente = Me.IdPaziente
                ucTestataPaziente.Token = Me.Token
                ucTestataPaziente.CodiceRuolo = Me.CodiceRuolo
                ucTestataPaziente.DescrizioneRuolo = Me.DescrizioneRuolo

                ' MOSTRO LA PARTE RELATIVA ALLA GESTIONE DEL CONSENSO NELLA TESTA DEL PAZIENTE.
                ucTestataPaziente.MostraSoloDatiAnagrafici = True

                'VALORIZZO I FILTRI CON I DATI PRESI DALLA SESSIONE.
                CaricaFiltri()

                'ESEGUO IL BIND DELL'XSLT DOPO AVER CARICATO I FILTRI LATERALI.
                DataSourcePrestazioniMatrice.Select()
            End If

            'RESETTO LA VISIBILITÀ DEL DIV D'ERRORE.
            divErrorMessage.Visible = False

            'RESETTO LA VISIBILITÀ DEL DIV USATO QUANDO LA GRIGLIA È VUOTA.
            divMessage.Visible = False
        Catch ex As Threading.ThreadAbortException
            '
            ' NON FACCIO NIENTE
            '
        Catch ex As ApplicationException
            ' CANCELLO ANCHE LE SELECT DELLO USERCONTROL PER LA TESTATA DEL PAZIENTE
            ucTestataPaziente.mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            ' CANCELLO ANCHE LE SELECT DELLO USERCONTROL PER LA TESTATA DEL PAZIENTE
            ucTestataPaziente.mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante il caricamento della pagina!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub RedirectToHome()
        Response.Redirect("~/Default.aspx", False)
    End Sub

#Region "DataSourcePrestazioniMatrice"
    Protected Sub DataSourcePrestazioniMatrice_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourcePrestazioniMatrice.Selected
        Try
            divErrorMessage.Visible = False
            divMessage.Visible = False

            'Ottengo il messaggio di errore.
            Dim messaggioErrore = HelperDataSourceException.GetObjectDataSourceExceptionMessage(e.Exception)

            'Testo se il messaggio di errore è vuoto. Se è valorizzato allora mostro il div d'errore.
            If Not String.IsNullOrEmpty(messaggioErrore) Then
                divErrorMessage.Visible = True
                lblErrorMessage.Text = messaggioErrore
                e.ExceptionHandled = True
            Else
                Dim result As WcfDwhClinico.MatricePrestazioniListaType = CType(e.ReturnValue, WcfDwhClinico.MatricePrestazioniListaType)
                If Not result Is Nothing AndAlso result.Count > 0 Then
                    '
                    ' Trasformo la lista delle matrici in un xml 
                    '
                    Dim oDt As WcfDwhClinico.MatricePrestazioniListaType = CType(e.ReturnValue, WcfDwhClinico.MatricePrestazioniListaType)
                    Dim strXml As String = String.Empty
                    Dim xmlSerializer As New System.Xml.Serialization.XmlSerializer(oDt.GetType)
                    Using memoryStream As New IO.MemoryStream
                        xmlSerializer.Serialize(memoryStream, oDt)
                        memoryStream.Position = 0
                        strXml = New IO.StreamReader(memoryStream).ReadToEnd
                    End Using
                    XmlRisultatoMatrice.DocumentContent = strXml
                    XmlRisultatoMatrice.DataBind()
                    'btnCollapseMatrice.Visible = True
                Else
                    Dim sMsgNoRecord As String = "La ricerca non ha prodotto risultati. Modificare eventualmente i parametri di filtro."
                    divMessage.Visible = True
                    divMessage.InnerText = sMsgNoRecord
                    'btnCollapseMatrice.Visible = False
                End If
            End If

        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati Prestazioni a Matrice!"
        End Try
    End Sub

    Protected Sub DataSourcePrestazioniMatrice_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DataSourcePrestazioniMatrice.Selecting
        Try
            If Not ValidaFiltri() Then
                e.Cancel = True
                Exit Sub
            End If

            e.InputParameters("ByPassaConsenso") = Utility.GetSessionForzaturaConsenso(Me.IdPaziente)
            e.InputParameters("IdPaziente") = Me.IdPaziente
            e.InputParameters("PrestazioneCodice") = Nothing
            e.InputParameters("SezioneCodice") = Me.SezioneCodice
            e.InputParameters("Token") = Me.Token()
            e.InputParameters("DallaData") = CDate(txtDataDal.Text)

            If Not String.IsNullOrEmpty(txtAllaData.Text) Then
                e.InputParameters("AllaData") = CDate(txtAllaData.Text)
            Else
                e.InputParameters("AllaData") = Date.Now
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati Prestazioni a Matrice!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub
#End Region

#Region "GestioneFiltriLaterali"
    Private Function ValidaFiltri() As Boolean
        Dim bReturn As Boolean = True
        Try
            Dim dDataDal As Date
            Dim dDataAl As Date = Nothing

            'CONTROLLO CHE TXTDATADAL NON SIA VUOTA E CHE SIA UNA DATA VALIDA.
            If String.IsNullOrEmpty(txtDataDal.Text) Then
                Throw New ApplicationException("Il parametro 'Dalla Data' è obbligatorio.")
            ElseIf Not Date.TryParse(txtDataDal.Text, dDataDal) Then
                Throw New ApplicationException("Il parametro 'Dalla Data' non è una data valida.")
            End If

            'CONTROLLO CHE DATA AL SIA UNA DATA VALIDA.
            If Not String.IsNullOrEmpty(txtAllaData.Text) AndAlso Not Date.TryParse(txtAllaData.Text, dDataAl) Then
                Throw New ApplicationException("Il parametro 'Alla Data' non è una data valida.")
            End If

            If Not String.IsNullOrEmpty(txtAllaData.Text) Then
                'VERIFICO CHE DATA AL SIA MAGGIORE DI DATA DAL.
                If Not dDataAl > dDataDal Then
                    Throw New ApplicationException("Il parametro 'Dalla Data' deve essere minore di 'Alla Data'.")
                End If
            Else
                'VERIFICO CHE DATA DAL SIA MAGGIORE DI OGGI
                If Not dDataDal < Date.Now Then
                    Throw New ApplicationException("Il parametro 'Dalla Data' deve essere minore della data odierna.")
                End If
            End If

        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            '
            'NON TRACCIO L'ERRORE.
            '
            bReturn = False
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di validazione dei filtri laterali."
            Logging.WriteError(ex, Me.GetType.Name)
            bReturn = False
        End Try
        Return bReturn
    End Function

    'Private Sub SalvaFiltri()
    '    Try
    '        Me.Session(mstrPageID & txtDataDal.ID & Me.IdPaziente.ToString) = txtDataDal.Text
    '        Me.Session(mstrPageID & txtAllaData.ID & Me.IdPaziente.ToString) = txtAllaData.Text
    '    Catch ex As Exception
    '        divErrorMessage.Visible = True
    '        lblErrorMessage.Text = "Errore durante l'operazione di salvataggio dei filtri laterali."
    '        Logging.WriteError(ex, Me.GetType.Name)
    '    End Try
    'End Sub

    Private Sub CaricaFiltri()
        Try
            'ATTENZIONE:
            'USO IL VALORE DEI FILTRI DELLA PAGINA REFERTI_LISTA_PAZIENTE
            Dim RefertiListaId As String = "RefertiListaPaziente"

            'OTTENGO DALLA SESSIONE IL VALORE DEL PARAMETRO "DALLA DATA".
            txtDataDal.Text = CType(Me.Session(RefertiListaId & txtDataDal.ID & Me.IdPaziente.ToString), String)
            'SE "DALLA DATA" NON È VALORIZZATO ALLORA METTO UNA DATA DI DEFAULT ( DATA ODIERNA - 1 ANNO).
            If String.IsNullOrEmpty(txtDataDal.Text) Then
                txtDataDal.Text = Date.Now.AddYears(-1).ToString("dd/MM/yyyy")
            End If

            'OTTENGO DALLA SESSIONE IL VALORE DEL PARAMETRO "ALLA DATA".
            txtAllaData.Text = CType(Me.Session(RefertiListaId & txtAllaData.ID & Me.IdPaziente.ToString), String)
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di caricamento dei filtri laterali."
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub
#End Region

    Private Sub cmdCerca_Click(sender As Object, e As EventArgs) Handles cmdCerca.Click
        Try
            'INVALIDO LA CACHE QUANDO PREMO SU CERCA.
            Dim dt As New CustomDataSource.MatricePrestazioniLabCercaPerSezioneCodice
            dt.ClearCache(Me.IdPaziente, Me.SezioneCodice)

            'SALVO I FILTRI IN SESSIONE.
            'SalvaFiltri()

            'ESEGUO LA SELECT DELL'OBJECT DATA SOURCE.
            DataSourcePrestazioniMatrice.Select()
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati Prestazioni a Matrice!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub cmdEsci_Click(sender As Object, e As EventArgs) Handles cmdEsci.Click
        Try
            'ESEGUO UN REDIRECT ALLA PAGINA DI LISTA DEI REFERTI.
            Response.Redirect(String.Format("~/Referti/RefertiDettaglio.aspx?IdReferto={0}", SessionHandler.IdReferto), False)
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante la navigazione alla pagina di lista dei referti."
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub
End Class