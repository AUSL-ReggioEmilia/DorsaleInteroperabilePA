Imports DI.PortalUser2
Imports DwhClinico.Data
Public Class GestioneFascicoloSanitario
    Inherits System.Web.UI.Page

#Region "Property"
    Dim mbCancelSelect As Boolean = True

    Public Property IdPaziente As Guid
        '
        ' Salvo l'Id del paziente nel ViewState per averlo per tutta la durata della pagina
        '
        Get
            Return Me.ViewState("IdPaziente")
        End Get
        Set(value As Guid)
            Me.ViewState("IdPaziente") = value
        End Set
    End Property

    Public Property CodiceFiscaleMedico() As String
        Get
            Return Me.ViewState("CodiceFiscaleMedico")
        End Get
        Set(ByVal value As String)
            Me.ViewState("CodiceFiscaleMedico") = value
        End Set
    End Property

    Public Property CodiceFiscalePaziente() As String
        Get
            Return Me.ViewState("CodiceFiscalePaziente")
        End Get
        Set(ByVal value As String)
            Me.ViewState("CodiceFiscalePaziente") = value
        End Set
    End Property

    Private ReadOnly Property Token As WcfDwhClinico.TokenType
        '
        ' Ottiene il token da passare come parametro agli ObjectDataSource all'interno delle tab.
        ' Utilizza la property CodiceRuolo per creare il token
        '
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
                '
                ' Prendo il ruolo dell'utente
                '
                Dim oRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
                Dim oRuoloCorrente As RoleManager.Ruolo = oRoleManagerUtility.RuoloCorrente
                '
                ' Salvo in ViewState
                '
                sCodiceRuolo = oRuoloCorrente.Codice
                Me.ViewState("CodiceRuolo") = sCodiceRuolo
            End If

            Return sCodiceRuolo
        End Get
    End Property

    Private ReadOnly Property DescrizioneRuolo As String
        '
        ' Salva nel ViewState la descrizione del ruolo dell'utente
        '
        Get
            Dim sDescrizioneRuolo As String = Me.ViewState("DescrizioneRuolo")
            If String.IsNullOrEmpty(sDescrizioneRuolo) Then
                '
                ' Prendo il ruolo dell'utente
                '
                Dim oRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
                Dim oRuoloCorrente As RoleManager.Ruolo = oRoleManagerUtility.RuoloCorrente
                '
                ' Salvo in ViewState
                '
                sDescrizioneRuolo = oRuoloCorrente.Descrizione
                Me.ViewState("DescrizioneRuolo") = sDescrizioneRuolo
            End If

            Return sDescrizioneRuolo
        End Get
    End Property

#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            Dim sIdPaziente As String = Me.Request.QueryString("IdPaziente")

            'UTILIZZO LA VARIABILE DI SESSIONE IsSessioneAttiva PER VERIFICARE SE LA SESSIONE È SCADUTA.
            If SessionHandler.ValidaSessioneAccessoStandard Is Nothing OrElse SessionHandler.ValidaSessioneAccessoStandard = False Then
                ucTestataPaziente.mbValidationCancelSelect = True
                Call RedirectToHome()
                Exit Sub
            End If

            'VISUALIZZO LA TESTATA DEL PAZIENTE.
            ucTestataPaziente.Visible = True

            '
            'nascondo il div d'errore.
            '
            divErrorMessage.Visible = False
            lblErrorMessage.Text = String.Empty

            If Not IsPostBack Then
                '
                'Ottengo l'id del paziente dal Query String
                'Se non è un guid valido allora mostro un messaggio di errore.
                '

                If Not Guid.TryParse(sIdPaziente, Me.IdPaziente) Then
                    ucTestataPaziente.Visible = False
                    Throw New ApplicationException("Il parametro Id Paziente non è valorizzato correttamente")
                Else
                    'SOLO SE L'ID E' UN GUID VALIDO

                    '
                    ' Valorizzo l'url alla pagina di gestione del consenso. Questo url cambia tra AccessoStandard e AccessoDiretto.
                    '
                    ucTestataPaziente.UrlDettaglioConsensi = String.Format("~/Pazienti/GestioneConsensi.aspx?IdPaziente={0}", sIdPaziente)

                    '
                    ' Passo alla testata del paziente il token e l'id del paziente per fare il bind dei dati.
                    '
                    ucTestataPaziente.IdPaziente = Me.IdPaziente
                    ucTestataPaziente.Token = Me.Token
                    ucTestataPaziente.CodiceRuolo = Me.CodiceRuolo
                    ucTestataPaziente.DescrizioneRuolo = Me.DescrizioneRuolo

                    '
                    ' Mostro la parte relativa alla gestione del consenso nella testa del paziente.
                    '
                    ucTestataPaziente.MostraSoloDatiAnagrafici = True

                    Me.CodiceFiscalePaziente = ucTestataPaziente.CodiceFiscale

                    '
                    'Ottengo il codice fiscale dell'utente
                    '
                    Dim oCurrentUser As CurrentUser = Utility.GetCurrentUser()
                    Dim oDettaglioUtente As Utility.DettaglioUtente = Utility.GetDettaglioUtente(oCurrentUser.DomainName, oCurrentUser.UserName)
                    If oDettaglioUtente IsNot Nothing Then
                        If String.IsNullOrEmpty(oDettaglioUtente.CodiceFiscale) Then
                            Me.CodiceFiscaleMedico = Utility.CODICE_FISCALE_NULLO
                        Else
                            Me.CodiceFiscaleMedico = oDettaglioUtente.CodiceFiscale
                        End If
                    End If
                End If
                '
                ' Forzo il caricamento della combo dei "Tipi di accesso" (contesto applicativo), cosi posso andare a settare il valore in sessione
                '
                CmbTipoAccesso.DataBind()
                '
                'Ricarico i filtri
                '
                LoadFilterValues()
            End If

            'SETTO IL DEFAULT BOTTON.
            Me.Form.DefaultButton = btnCerca.UniqueID

            'IMPOSTO IL PAGER STYLE DELLA GRIGLIA.
            GvLista.PagerStyle.CssClass = "pagination-gridview"
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)

        Catch ex As ApplicationException
            '
            ' Cancello anche le select dello UserControl per la testata del paziente
            '
            ucTestataPaziente.mbValidationCancelSelect = True
            ucTestataPaziente.Visible = False
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message

        Catch ex As Exception
            '
            ' Cancello anche le select dello UserControl per la testata del paziente
            '
            ucTestataPaziente.mbValidationCancelSelect = True
            ucTestataPaziente.Visible = False
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante il caricamento della pagina!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub BtnAnnulla_Click(sender As Object, e As EventArgs) Handles btnAnnulla.Click
        Try
            Response.Redirect("~/Referti/RefertiListaPaziente.aspx?idpaziente=" & Me.IdPaziente.ToString, False)
        Catch ex As Exception
            '
            ' Cancello anche le select dello UserControl per la testata del paziente
            '
            ucTestataPaziente.mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Si è verificato un errore."
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub BtnCerca_Click(sender As Object, e As EventArgs) Handles btnCerca.Click
        Try
            If ValidateFiltersValue() Then
                '
                'Salvo in sessione i filtri
                '
                SaveFilterValues()

                mbCancelSelect = False

                '
                'Svuoto la cache prima di rieseguire il bind
                '
                Dim dsDocumenti As New FseDataSource.FseDocumentiCerca()
                dsDocumenti.ClearCache()

                '
                'il controllo dei filtri viene eseguito all'interno del selecting dell'ObjectDataSource
                '
                GvLista.DataBind()
            End If

        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message

        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati."
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub RedirectToHome()
        Response.Redirect(Me.ResolveUrl("~/Default.aspx"), True)
    End Sub

#Region "GestioneGvLista"
    Private Sub OdsMain_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles OdsMain.Selecting
        Try
            '
            'Eseguo il selecting solo se ho cliccato su cerca
            '
            If mbCancelSelect Then
                '
                'Cancello la query solo se i dati non sono presenti in cache
                '
                Dim dsDocumenti As New FseDataSource.FseDocumentiCerca()
                Dim oDocumenti As Object = dsDocumenti.CacheData

                If oDocumenti Is Nothing Then
                    e.Cancel = True
                    Exit Sub
                End If
            End If

            '
            'Se i filtri non sono validi non eseguo la query
            '
            If Not ValidateFiltersValue() Then
                e.Cancel = True
                Exit Sub
            End If

            '
            'Se sono qui i filtri sono già validi
            '
            Dim dDataAl As DateTime = Now.Date
            If Not String.IsNullOrEmpty(txtAllaData.Text) Then
                dDataAl = CType(txtAllaData.Text, DateTime)
            End If
            '
            ' Aggiungo 1 giorno
            '
            dDataAl = dDataAl.AddDays(1)

            '
            'Imposto gli input parameter per gli ObjectDataSource
            '
            e.InputParameters("Token") = Me.Token
            e.InputParameters("TipoAccesso") = CmbTipoAccesso.SelectedValue
            e.InputParameters("DataDal") = CType(txtDataDal.Text, DateTime)
            e.InputParameters("DataAl") = dDataAl
            e.InputParameters("CodiceFiscalePaziente") = Me.CodiceFiscalePaziente
            e.InputParameters("CodiceFiscaleMedico") = Me.CodiceFiscaleMedico

            '
            'Valorizzo il parametro NumMaxRecord ottenendo il valore dalle setting.
            '
            Dim iTop As Integer = My.Settings.FseDocumentiListaTop
            e.InputParameters("NumMaxRecord") = iTop

        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati."
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub OdsMain_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles OdsMain.Selected
        Const MESSAGE_NORECORD As String = "Non è stato trovato nessun documento. Modificare eventualmente i parametri di filtro"
        Try
            '
            ' GESTIONE ERRORE
            '
            divMessage.Visible = False
            Dim messaggioErrore As String = String.Empty

            If e.Exception IsNot Nothing Then
                If e.Exception.InnerException IsNot Nothing Then

                    If TypeOf e.Exception.InnerException Is WsDwhException Then
                        Dim wsDwhException As WsDwhException = DirectCast(e.Exception.InnerException, WsDwhException)

                        If wsDwhException IsNot Nothing AndAlso wsDwhException.ExtraData IsNot Nothing Then
                            ' compongo errore da scrivere nel log
                            Logging.WriteError(Nothing, wsDwhException.GetEventLogMessage())

                            'Ottengo il messaggio d'errore per l'utente
                            messaggioErrore = wsDwhException.Descrizione
                        End If
                    Else
                        Logging.WriteError(e.Exception.InnerException, Me.GetType.Name)
                    End If
                Else
                    Logging.WriteError(e.Exception, Me.GetType.Name)
                End If
                '
                ' FONDAMENTALE: altrimenti l'eccezione viene ancora passata al chiamante
                '
                e.ExceptionHandled = True
                divErrorMessage.Visible = True
                lblErrorMessage.Text = $"Errore durante la ricerca dei dati. {messaggioErrore}"
            Else
                '
                'CONTROLLO CHE I DATI RESTITUITI NON SIANO VUOTI
                '
                If e.ReturnValue IsNot Nothing Then
                    Dim documentoLista As WcfDwhClinico.DocumentiListaType = CType(e.ReturnValue, WcfDwhClinico.DocumentiListaType)

                    'ottengo il count della lista
                    Dim rowCount As Integer = 0
                    If documentoLista IsNot Nothing Then
                        rowCount = documentoLista.Count
                    End If

                    'Se non ci sono record mostro un messaggio.
                    If rowCount = 0 Then
                        Throw New ApplicationException(MESSAGE_NORECORD)
                    Else
                        'ottengo il numero massimo di record che devono essere visualizzati in lista.
                        Dim maxNumRecord As Integer = My.Settings.FseDocumentiListaTop
                        'se rowCount e maxNumRecord sono uguali allora mostro un messaggio.
                        If rowCount = maxNumRecord Then
                            divMessage.Visible = True
                            divMessage.InnerText = Utility.MSG_MAX_NUM_RECORD
                        Else
                            divMessage.Visible = False
                        End If
                    End If
                Else
                    Throw New ApplicationException(MESSAGE_NORECORD)
                End If
            End If

        Catch ex As ApplicationException
            divMessage.Visible = True
            divMessage.InnerText = ex.Message

        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati."
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub GvLista_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles GvLista.RowCommand
        Try
            If e.CommandName = "1" Then
                '
                ' e.CommandArgument è formattato come "CodiceDocumento;Tipologia;TipoDocumento(sNaturaDocumento)"
                '
                Dim sParametri As String = e.CommandArgument
                Dim oArray As String() = Split(sParametri, ";")
                Dim sCodiceDocumento As String = oArray(0)
                Dim sTipoDocumento As String = oArray(1)
                Dim sNaturaDocumento As String = oArray(2)

                Dim sUrl As String = String.Format("~/FSE/Documento.aspx?CodiceDocumento={0}&CodiceFiscalePaziente={1}&CodiceFiscaleMedico={2}&TipoAccesso={3}&IdPaziente={4}&TipoDocumento={5}&NaturaDocumento={6}", sCodiceDocumento, Me.CodiceFiscalePaziente, Me.CodiceFiscaleMedico, CmbTipoAccesso.SelectedValue, Me.IdPaziente.ToString, sTipoDocumento, sNaturaDocumento)
                '
                ' MODIFICA ETTORE 2017-06-08: aggiunto parametro "endresponse = False" per evitare "Thread Abort Exception"
                '
                Response.Redirect(sUrl, False)
            End If
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di apertura del dettaglio."
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub


#End Region

#Region "GestioneFiltriLaterali"
    Private Sub SaveFilterValues()
        '
        'Salvo in sessione i filtri laterali
        '
        Try
            Dim sIdPaziente As String = Me.IdPaziente.ToString.ToUpper
            Me.Session(Me.GetType.Name & txtDataDal.ID & sIdPaziente) = txtDataDal.Text
            Me.Session(Me.GetType.Name & txtAllaData.ID & sIdPaziente) = txtAllaData.Text
            Me.Session(Me.GetType.Name & CmbTipoAccesso.ID & sIdPaziente) = CmbTipoAccesso.SelectedValue
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Si è verificato un errore."
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub LoadFilterValues()
        Try
            '
            'Ricarico i filtri laterali
            '
            Dim sIdPaziente As String = Me.IdPaziente.ToString.ToUpper

            '
            'Se il parametro in sessione è String.empty allora setto il parametro DataDal alla data corrente - 1 anno.
            '
            Dim sDataDal As String = CType(Me.Session(Me.GetType.Name & txtDataDal.ID & sIdPaziente), String)
            If String.IsNullOrEmpty(sDataDal) Then
                txtDataDal.Text = Now.AddYears(-1).ToString("dd/MM/yyyy")
            Else
                txtDataDal.Text = Me.Session(Me.GetType.Name & txtDataDal.ID & sIdPaziente)
            End If

            txtAllaData.Text = Me.Session(Me.GetType.Name & txtAllaData.ID & sIdPaziente)
            CmbTipoAccesso.SelectedValue = Me.Session(Me.GetType.Name & CmbTipoAccesso.ID & sIdPaziente)
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Si è verificato un errore."
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Function ValidateFiltersValue() As Boolean
        '
        'Valida i filtri laterali
        '
        Dim sErrore As String = String.Empty

        Try
            Dim bValidation As Boolean = True
            Dim odate As DateTime
            '
            ' Controllo sempre il dato presente nel filtro
            '
            If txtDataDal.Text.Length > 0 Then
                If Not Date.TryParse(txtDataDal.Text, odate) Then
                    bValidation = False
                    sErrore &= sErrore & String.Format("Il parametro '{0}' non è formattato correttamente. {1}", lblDallaData.Text.TrimEnd(":"), vbCrLf)
                End If
            End If

            '
            ' Controllo se la DataAl è minore di DataDal
            '
            If txtAllaData.Text.Length > 0 Then
                If Not Date.TryParse(txtAllaData.Text, odate) Then
                    bValidation = False
                    sErrore &= sErrore & String.Format("Il parametro '{0}' non è formattato correttamente. {1}", lblAllaData.Text.TrimEnd(":"), vbCrLf)
                ElseIf CDate(txtAllaData.Text) < CDate(txtDataDal.Text) Then
                    bValidation = False
                    sErrore &= sErrore & String.Format("Il parametro '{0}' deve essere maggiore o uguale al parametro '{1}'. {2}", lblAllaData.Text.TrimEnd(":"), lblDallaData.Text.TrimEnd(":"), vbCrLf)
                End If
            End If

            If CmbTipoAccesso.SelectedValue = String.Empty Then
                bValidation = False
                sErrore &= sErrore & String.Format("Selezionare un valore per il parametro '{0}'. {1} ", LblTipoAccesso.Text.TrimEnd(":"), vbCrLf)
            End If

            If String.IsNullOrEmpty(Me.CodiceFiscalePaziente) Then
                bValidation = False
                sErrore &= sErrore & String.Format("Il codice fiscale del paziente è obbligatorio.", vbCrLf)
            End If


            If bValidation = False Then
                Throw New ApplicationException(sErrore)
            End If

            Return bValidation

        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            sErrore = sErrore.TrimEnd(vbCrLf)
            sErrore = sErrore.Replace(vbCrLf, "<br />")
            lblErrorMessage.Text = sErrore
            Logging.WriteError(ex, Me.GetType.Name)
            Return False

        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di validazione dei filtri!"
            Logging.WriteError(ex, Me.GetType.Name)
            Return False
        End Try
    End Function
#End Region


    ReadOnly moTipiDocumento As New FseDataSource.FseDizionariOttieni
    Protected Function LookUpTipologiaDocumento(ByVal oTipologia As Object, ByVal oDocumentDescription As Object) As String

        Dim sDescrizione As String = String.Empty
        Dim sTipologia As String = CType(oTipologia, String)

        Try
            '
            ' Se la descrizione è nulla la ottengo dal WS
            '
            If Not String.IsNullOrEmpty(oDocumentDescription) Then
                sDescrizione = oDocumentDescription
            Else
                Dim tipiDocumento As WcfDwhClinico.TipiAccessoListaType = moTipiDocumento.GetData(Token)
                Dim tipoDocumento As WcfDwhClinico.CodiceDescrizioneType = tipiDocumento.Where(Function(x) x.Codice = sTipologia)

                If tipoDocumento IsNot Nothing Then
                    sDescrizione = tipoDocumento.Descrizione
                End If
            End If

            '
            ' Restituisco
            '
            Return $"{sDescrizione} ({sTipologia})"

        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            Return ""
        End Try

    End Function

    Protected Function GetAnteprima(ByVal oDatiAggiuntivi As Object, ByVal oTipoDocumento As Object, ByVal oDescrizioneDocumento As Object)

        Dim sTipoDocumento As String = CType(oTipoDocumento, String)
        Dim sDescrizioneDocumento As String = CType(oDescrizioneDocumento, String)
        Dim datiAggiuntivi As WcfDwhClinico.DocumentoListaType.DatiAggiuntiviType = IIf(oDatiAggiuntivi Is Nothing, Nothing, CType(oDatiAggiuntivi, WcfDwhClinico.DocumentoListaType.DatiAggiuntiviType))
        Dim sRet As String = ""

        ' Numero di caratteri utili
        Dim trim = 200

        If sTipoDocumento = "DS" OrElse sTipoDocumento = "" Then

            If datiAggiuntivi IsNot Nothing Then

                ' Aggiungo tutti gli attributi (separandoli da ;) alla stringa di ritorno
                For Each attributo As WcfDwhClinico.AttributoType In datiAggiuntivi.DatiAggiuntivi
                    sRet &= $"{attributo.Nome}: {attributo.Valore};"
                Next

                ' Conto i separatori (Cartatteri non facenti parte dei dati utili)
                Dim wasteChars = sRet.Count(Function(c As Char) c = ";")
                ' Numero di caratteri utili + non utili
                trim += wasteChars

                ' Se è maggiore del numero di caretteri utili allora tronco ed aggiungo i puntiti sospensivi
                If sRet.Length > trim Then
                    sRet = sRet.Substring(0, trim)
                    sRet &= "..."
                End If

                ' Ora sostiuisco il carattere separatore con un "a capo"
                sRet = sRet.Replace(";", "<br />")
            End If

        ElseIf sTipoDocumento = "DC" Then

            sRet = sDescrizioneDocumento
            ' Se è maggiore del numero di caretteri utili allora tronco ed aggiungo i puntiti sospensivi
            If sRet.Length > trim Then
                sRet = sRet.Substring(0, trim)
                sRet &= "..."
            End If

        End If

        Return sRet

    End Function

    Protected Function GetTooltipAnteprima(ByVal oDatiAggiuntivi As Object, ByVal oTipoDocumento As Object, ByVal oDescrizioneDocumento As Object)

        Dim sTipoDocumento As String = CType(oTipoDocumento, String)
        Dim sDescrizioneDocumento As String = CType(oDescrizioneDocumento, String)
        Dim datiAggiuntivi As WcfDwhClinico.DocumentoListaType.DatiAggiuntiviType = IIf(oDatiAggiuntivi Is Nothing, Nothing, CType(oDatiAggiuntivi, WcfDwhClinico.DocumentoListaType.DatiAggiuntiviType))
        Dim sRet As String = ""

        If sTipoDocumento = "DS" OrElse sTipoDocumento = "" Then

            If datiAggiuntivi IsNot Nothing Then

                For Each dato As WcfDwhClinico.AttributoType In datiAggiuntivi.DatiAggiuntivi
                    sRet &= $"{dato.Nome}: {dato.Valore}{vbCrLf}"
                Next

                ' Rimuovo l'ultimo "a capo"
                sRet = sRet.Remove(sRet.LastIndexOf(vbCrLf))

            End If
        ElseIf sTipoDocumento = "DC" Then
            sRet = sDescrizioneDocumento
        End If

        Return sRet

    End Function

    Private Sub GvLista_PreRender(sender As Object, e As EventArgs) Handles GvLista.PreRender
        '
        'RENDER PER BOOTSTRAP
        'CREA LA TABLE CON THEADER E TBODY SE L'HEADER NON È NOTHING.
        '
        If Not GvLista.HeaderRow Is Nothing Then
            GvLista.UseAccessibleHeader = True
            GvLista.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
    End Sub

    Protected Function GetAziendaErogante(ByVal oAziendaCodice As Object, ByVal oAuthorDescription As Object, ByVal oAziendaDescrizione As Object) As String

        Dim sAziendaCodice As String = CType(oAziendaCodice, String)
        Dim sAziendaDescrizione As String
        Try
            If Not String.IsNullOrEmpty(oAuthorDescription) Then
                sAziendaDescrizione = oAuthorDescription
            Else
                sAziendaDescrizione = CType(oAziendaDescrizione, String)
            End If

            '
            ' Restituisco
            '
            Return $"{sAziendaDescrizione} ({sAziendaCodice})"

        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            Return ""
        End Try

    End Function

    Protected Function GetOrigine(ByVal tipoDocumento As Object) As String

        Select Case tipoDocumento
            Case "", "DS"
                Return "Documento SOLE"

            Case "DC"
                Return "Documento Cittadino"

            Case Else
                Return ""
        End Select

    End Function

    Private Sub OdsTipiAccesso_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles OdsTipiAccesso.Selecting
        'Imosto il Token per la chiamata al WS per i dati con cui popolare la DropDown
        e.InputParameters("Token") = Me.Token
    End Sub
End Class