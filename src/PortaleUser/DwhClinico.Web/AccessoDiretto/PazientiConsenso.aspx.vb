Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
'
' STEP 1)   NON implemento l'acquisizione del consenso da ACCESSO DIRETTO ma adatto le pagine 
'           per testare la presenza del consenso minimo.
'           Al momento rendo invisibili i pulsanti per acquisire il consenso
'
' STEP 2)   Creo nella folder Accesso Diretto le pagine di inserimento/modifica del consenso
'           e imposto la navigazione tramite i pulsanti già presenti nella pagina ASPX 
'
'
Partial Class AccessoDiretto_PazientiConsenso
    Inherits System.Web.UI.Page

    '
    ' Variabili private della classe
    '
    Private mguidIdPaziente As Guid
    Private mUrlToNavigate As String
    '
    '
    '
    'Private mbAutoNav As Boolean = True
    Protected moSacDettaglioPaziente As SacDettaglioPaziente = Nothing 'E' visibile nel'ASPX

#Region "Registrazione script lato client"

    Protected Overrides Sub OnPreRender(ByVal e As System.EventArgs)
        Dim sClientCode As String = Nothing
        If Not ClientScript.IsClientScriptBlockRegistered("PageScript") Then
            sClientCode = JSApriApplicazione() & vbCrLf
            sClientCode = sClientCode & JSNavigaApplicazione()
            '
            ' Registro lo script
            '
            ClientScript.RegisterClientScriptBlock(GetType(Page), "PageScript", JSBuildScript(sClientCode))
        End If

    End Sub

#End Region

    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        Try
            '
            ' Leggo parametri dal QueryString
            '
            Dim sIdPaziente As String = Request.QueryString(PAR_ID_PAZIENTE)
            If String.IsNullOrEmpty(sIdPaziente) Then
                Throw New ApplicationException(String.Format("Il parametro '{0}' è obbligatorio.", PAR_ID_PAZIENTE))
            End If
            mguidIdPaziente = New Guid(sIdPaziente)

            mUrlToNavigate = Request.QueryString(PAR_URL_TO)
            If String.IsNullOrEmpty(mUrlToNavigate) Then
                Throw New ApplicationException(String.Format("Il parametro '{0}' è obbligatorio.", PAR_URL_TO))
            End If
            '
            ' RENDO SEMPRE INVISIBILE IL PULSANTE
            '
            cmdAnnulla.Visible = False
            '
            ' Aggiungo lo script per lo stylesheet
            '
            'PageAddCss(Me)
            If Not IsPostBack Then
                '
                ' Inizializzo la pagina
                '
                Call InitializePage()
            End If
            '
            ' Eseguo il bind della griglia con i dati 
            ' contiene try-catch e controllo postback
            '
            Call PageDataBind()

        Catch ex As Exception
            divDatiPaziente.Visible = False 'questo impedirà il binding
            divMotivoAccesso.Visible = False
            divPulsanti.Visible = False

            '
            ' Gestione dell'errore
            '
            lblErrorMessage.Text = "Errore durante il caricamento della pagina!"
            alertErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub InitializePage()
        Dim strScript As String = String.Empty
        Dim strUrl As String = String.Empty
        '
        ' Aggiungo lo script lato client
        ' per la conferma alla forzatura del consenso
        '
        strScript = "javascript:return confirm('Confermi la forzatura del consenso ?');"
        cmdForzaConsenso.Attributes.Item("onclick") = strScript

        '
        ' ATTENZIONE: mUrlToNavigate essendo un URL deve essere encoded
        '
        Dim sParUrlTo As String = Server.UrlEncode(mUrlToNavigate)

        '------------------------------------------------------------------------------------------
        ' Aggiungo lo script lato client per inserire un nuovo consenso GENERICO
        '------------------------------------------------------------------------------------------
        strUrl = Me.ResolveUrl("~/AccessoDiretto/PazientiConsensoInserisci.aspx") & _
                                "?" & PAR_ID_PAZIENTE & "=" & mguidIdPaziente.ToString & "&" & PAR_ID_TIPO_CONSENSO & "=" & CType(SacConsensiDataAccess.TipoConsenso.Generico, Integer) & "&" & PAR_URL_TO & "=" & sParUrlTo
        strScript = "javascript:document.location.href='" & strUrl & "'"
        cmdRichiediConsenso.Attributes.Item("onclick") = strScript
        '------------------------------------------------------------------------------------------
        ' Aggiungo lo script lato client per modificare un nuovo consenso GENERICO
        '------------------------------------------------------------------------------------------
        strUrl = Me.ResolveUrl("~/AccessoDiretto/PazientiConsensoModifica.aspx") & _
                                "?" & PAR_ID_PAZIENTE & "=" & mguidIdPaziente.ToString & "&" & PAR_ID_TIPO_CONSENSO & "=" & CType(SacConsensiDataAccess.TipoConsenso.Generico, Integer) & "&" & PAR_URL_TO & "=" & sParUrlTo
        strScript = "javascript:document.location.href='" & strUrl & "'"
        cmdModificaConsenso.Attributes.Item("onclick") = strScript
        '------------------------------------------------------------------------------------------
        ' Aggiungo lo script lato client per inserire un nuovo consenso DOSSIER
        '------------------------------------------------------------------------------------------
        strUrl = Me.ResolveUrl("~/AccessoDiretto/PazientiConsensoInserisci.aspx") & _
                                "?" & PAR_ID_PAZIENTE & "=" & mguidIdPaziente.ToString & "&" & PAR_ID_TIPO_CONSENSO & "=" & CType(SacConsensiDataAccess.TipoConsenso.Dossier, Integer) & "&" & PAR_URL_TO & "=" & sParUrlTo
        strScript = "javascript:document.location.href='" & strUrl & "'"
        cmdRichiediConsensoDossier.Attributes.Item("onclick") = strScript
        '------------------------------------------------------------------------------------------
        ' Aggiungo lo script lato client per modificare un nuovo consenso DOSSIER
        '------------------------------------------------------------------------------------------
        strUrl = Me.ResolveUrl("~/AccessoDiretto/PazientiConsensoModifica.aspx") & _
                                "?" & PAR_ID_PAZIENTE & "=" & mguidIdPaziente.ToString & "&" & PAR_ID_TIPO_CONSENSO & "=" & CType(SacConsensiDataAccess.TipoConsenso.Dossier, Integer) & "&" & PAR_URL_TO & "=" & sParUrlTo
        strScript = "javascript:document.location.href='" & strUrl & "'"
        cmdModificaConsensoDossier.Attributes.Item("onclick") = strScript
        '------------------------------------------------------------------------------------------
        ' Aggiungo lo script lato client per inserire un nuovo consenso DOSSIER STORICO
        '------------------------------------------------------------------------------------------
        strUrl = Me.ResolveUrl("~/AccessoDiretto/PazientiConsensoInserisci.aspx") & _
                                "?" & PAR_ID_PAZIENTE & "=" & mguidIdPaziente.ToString & "&" & PAR_ID_TIPO_CONSENSO & "=" & CType(SacConsensiDataAccess.TipoConsenso.DossierStorico, Integer) & "&" & PAR_URL_TO & "=" & sParUrlTo
        strScript = "javascript:document.location.href='" & strUrl & "'"
        cmdRichiediConsensoDossierStorico.Attributes.Item("onclick") = strScript
        '------------------------------------------------------------------------------------------
        ' Aggiungo lo script lato client per modificare un nuovo consenso DOSSIER STORICO
        '------------------------------------------------------------------------------------------
        strUrl = Me.ResolveUrl("~/AccessoDiretto/PazientiConsensoModifica.aspx") & _
                                "?" & PAR_ID_PAZIENTE & "=" & mguidIdPaziente.ToString & "&" & PAR_ID_TIPO_CONSENSO & "=" & CType(SacConsensiDataAccess.TipoConsenso.DossierStorico, Integer) & "&" & PAR_URL_TO & "=" & sParUrlTo
        strScript = "javascript:document.location.href='" & strUrl & "'"
        cmdModificaConsensoDossierStorico.Attributes.Item("onclick") = strScript
        '------------------------------------------------------------------------------------------


    End Sub


    Private Sub PageDataBind()
        Try
            If IsPostBack Then
                '
                ' Leggo i dati dalla sessione
                '
                moSacDettaglioPaziente = SacDettaglioPaziente.Session()
            End If
            '
            ' Se nothing rieseguo la query
            '
            If moSacDettaglioPaziente Is Nothing Then
                Dim oPazienteSac As New PazienteSac
                '
                ' Invoco classe che wrappa il web service pazienti del SAC
                '
                moSacDettaglioPaziente = oPazienteSac.GetData(mguidIdPaziente.ToString)
                If moSacDettaglioPaziente Is Nothing Then
                    Throw New ApplicationException(String.Format("Il paziente con id='{0}' non esiste!", mguidIdPaziente))
                End If
                SacDettaglioPaziente.Session() = moSacDettaglioPaziente
            End If
            '
            ' Ho il consenso per vedere i dati?
            '
            Dim bConsensoPresente As Boolean = moSacDettaglioPaziente.ConsensoPresente()
            '
            ' Autonav=true e ho il consenso OPPURE il consenso è stato forzato navigo ai dati
            '
            'If mbAutoNav Then
            '    If (bConsensoPresente) Then
            '        Call Response.Redirect(Me.ResolveUrl(mUrlToNavigate), False)
            '        Exit Sub
            '    End If
            '    If (Utility.GetSessionForzaturaConsenso(mguidIdPaziente)) Then
            '        Call Response.Redirect(Me.ResolveUrl(mUrlToNavigate), False)
            '        Exit Sub
            '    End If
            'End If
            '***************************************************************************************
            ' Se sono qui NON POSSO accedere ai dati del paziente
            '***************************************************************************************

            '
            ' Decido se visualizzare il pulsante "Esci"
            '
            'If CType(BarraNavigazione.NavBarList(0), ListItem).Value.ToUpper.Contains("PAZIENTICONSENSO.ASPX?") Then
            '    cmdAnnulla.Enabled = False
            'End If
            '
            ' Eseguo il bind con i dati del paziente
            '
            divPaziente.DataBind()
            '
            ' Nascondo/Visualizzo la data decesso
            '
            Call SetDataDecessoVisible(moSacDettaglioPaziente)

            '
            ' Memorizzo se posso modificare un consenso negato
            '
            Dim bCanChangeConsensoNegato As Boolean = Utility.CheckPermission(RoleManagerUtility.ATTRIB_CONSENSO_NEG_CHANGE)

            '----------------------------------------------------------------------------------------------
            ' Visualizzazione dei dati e dei pulsanti relativi alla presenza del consenso GENERICO
            '----------------------------------------------------------------------------------------------
            Dim oConsensoGenerico As Consenso = moSacDettaglioPaziente.GetConsensoGenerico()
            lblDataConsensoValue.Visible = False
            lblDataConsenso.Visible = False
            If oConsensoGenerico.Stato <> ConsensoStato.NonAcquisito Then
                If oConsensoGenerico.DataStato.HasValue Then
                    lblDataConsensoValue.Text = oConsensoGenerico.DataStato.Value.ToShortDateString()
                End If
                lblDataConsensoValue.Visible = True
                lblDataConsenso.Visible = True
            End If
            cmdRichiediConsenso.Visible = (oConsensoGenerico.Stato = ConsensoStato.NonAcquisito)
            cmdModificaConsenso.Visible = (oConsensoGenerico.Stato <> ConsensoStato.NonAcquisito)


            '----------------------------------------------------------------------------------------------
            ' Visualizzazione dei dati e dei pulsanti relativi alla presenza del consenso DOSSIER
            '----------------------------------------------------------------------------------------------
            Dim oConsensoDossier As Consenso = moSacDettaglioPaziente.GetConsensoDossier()
            lblDataConsensoDossierValue.Visible = False
            lblDataConsensoDossier.Visible = False
            If oConsensoDossier.Stato <> ConsensoStato.NonAcquisito Then
                If oConsensoDossier.DataStato.HasValue Then
                    lblDataConsensoDossierValue.Text = oConsensoDossier.DataStato.Value.ToShortDateString()
                End If
                lblDataConsensoDossierValue.Visible = True
                lblDataConsensoDossier.Visible = True
            End If
            cmdRichiediConsensoDossier.Visible = (oConsensoDossier.Stato = ConsensoStato.NonAcquisito)
            cmdModificaConsensoDossier.Visible = (oConsensoDossier.Stato <> ConsensoStato.NonAcquisito)


            '----------------------------------------------------------------------------------------------
            ' Visualizzazione dei dati e dei pulsanti relativi alla presenza del consenso DOSSIER STORICO
            '----------------------------------------------------------------------------------------------
            Dim oConsensoDossierStorico As Consenso = moSacDettaglioPaziente.GetConsensoDossierStorico()
            lblDataConsensoDossierStoricoValue.Visible = False
            lblDataConsensoDossierStorico.Visible = False
            If oConsensoDossier.Stato <> ConsensoStato.NonAcquisito Then
                If oConsensoDossierStorico.DataStato.HasValue Then
                    lblDataConsensoDossierStoricoValue.Text = oConsensoDossierStorico.DataStato.Value.ToShortDateString()
                End If
                lblDataConsensoDossierStoricoValue.Visible = True
                lblDataConsensoDossierStorico.Visible = True
            End If
            cmdRichiediConsensoDossierStorico.Visible = (oConsensoDossierStorico.Stato = ConsensoStato.NonAcquisito)
            cmdModificaConsensoDossierStorico.Visible = (oConsensoDossierStorico.Stato <> ConsensoStato.NonAcquisito)

            '----------------------------------------------------------------------------------------------
            ' Imposto ordine per acquisire i consensi
            '----------------------------------------------------------------------------------------------
            cmdRichiediConsenso.Disabled = False 'sempre abilitati - logica negata!
            cmdModificaConsenso.Disabled = False
            If oConsensoGenerico.Stato <> ConsensoStato.NonAcquisito Then
                cmdModificaConsenso.Disabled = Not bCanChangeConsensoNegato
            End If
            'Posso acquisire il consenso dossier solo se ho GENERICO = ACCORDATO
            cmdRichiediConsensoDossier.Disabled = oConsensoGenerico.Stato <> ConsensoStato.Accordato
            cmdModificaConsensoDossier.Disabled = oConsensoGenerico.Stato <> ConsensoStato.Accordato
            If oConsensoDossier.Stato <> ConsensoStato.NonAcquisito AndAlso oConsensoGenerico.Stato = ConsensoStato.Accordato Then
                cmdModificaConsensoDossier.Disabled = Not bCanChangeConsensoNegato
            End If
            'Posso acquisire il consenso dossierstorico solo se ho DOSSIER = ACCORDATO
            cmdRichiediConsensoDossierStorico.Disabled = oConsensoDossier.Stato <> ConsensoStato.Accordato
            cmdModificaConsensoDossierStorico.Disabled = oConsensoDossier.Stato <> ConsensoStato.Accordato
            If oConsensoDossierStorico.Stato <> ConsensoStato.NonAcquisito AndAlso oConsensoDossier.Stato = ConsensoStato.Accordato Then
                cmdModificaConsensoDossierStorico.Disabled = Not bCanChangeConsensoNegato
            End If


            '
            ' Visualizzo il messaggio per l'utente solo il consesno acquisito è tale da NON poter accedere i dati
            '
            lblMessaggioAssenzaConsenso.Visible = Not bConsensoPresente
            '
            ' Il pulsante di forzatura del consenso si deve vedere se DOSSIER STORICO non è stato ACCORDATO AND l'utente può accedere per necessità clinica urgente
            '
            cmdForzaConsenso.Visible = (oConsensoDossierStorico.Stato <> ConsensoStato.Accordato) AndAlso Me.Context.User.IsInRole(RoleManagerUtility.ATTRIB_ACC_DIR_ENABLED)
            '
            ' Valorizzo il testo per l'utente in caso di consenso/i non sufficienti
            '
            lblMessaggioAssenzaConsenso.Text = "Il paziente non ha fornito il consenso al trattamento dei sui dati clinici."
            '
            ' Valorizzo il testo per l'per l'utilizzo del pulsante "<Accesso forzato>"
            '
            If cmdForzaConsenso.Visible Then
                lblMessaggioUsaAccessoForzato.Text = String.Format("Per necessità clinica è possibile continuare premendo il pulsante '{0}'", cmdForzaConsenso.Text)
            End If
            '
            ' Pulsante per navigare all'oggetto/i richiesto
            '
            cmdAccedi.Enabled = bConsensoPresente


            If Not IsPostBack Then
                '
                ' Carico la combo con i motivi dell'accesso
                '
                Call Utility.LoadComboMotiviAccesso(cmbMotiviAccesso)
                '
                ' Verifico se l'utente ha l'accesso tecnico
                '
                Dim bUtenteTecnico As Boolean = HttpContext.Current.User.IsInRole(RoleManagerUtility.ATTRIB_UTE_TEC)
                Dim bUtenteConAccessoTecnico As Boolean = HttpContext.Current.User.IsInRole(RoleManagerUtility.ATTRIB_UTE_ACC_TEC)
                If bUtenteTecnico OrElse bUtenteConAccessoTecnico Then
                    '
                    ' Aggiungo e seleziono MOTIVO_ACCESSO_NECESSITA_TECNICA_TEXT
                    '
                    cmbMotiviAccesso.Items.Add(New ListItem(MOTIVO_ACCESSO_NECESSITA_TECNICA_TEXT, MOTIVO_ACCESSO_NECESSITA_TECNICA_ID))
                    If bUtenteTecnico Then
                        cmbMotiviAccesso.SelectedValue = MOTIVO_ACCESSO_NECESSITA_TECNICA_ID
                    End If
                Else
                    '
                    ' Nell'Accesso diretto aggiungo sempre MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_TEXT e lo metto come default
                    '
                    cmbMotiviAccesso.Items.Add(New ListItem(MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_TEXT, MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_ID))
                    cmbMotiviAccesso.SelectedValue = MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_ID
                End If
            End If
        Catch ex As ApplicationException
            '
            ' Gestione dell'errore: in questo caso posso mostrare all'utente il messaggio d'errore
            '
            lblErrorMessage.Text = ex.Message
            alertErrorMessage.Visible = True
        Catch ex As Exception
            '
            ' Gestione dell'errore
            '
            lblErrorMessage.Text = Logging.GetMessageError(ex, "") & "<br>" &
                                "durante l'operazione di ricerca dei dati del paziente."
            alertErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        Finally
            If moSacDettaglioPaziente Is Nothing Then
                divDatiPaziente.Visible = False 'questo impedirà il binding
                divMotivoAccesso.Visible = False
                divPulsanti.Visible = False
            End If
        End Try

    End Sub


    Protected Function GetImageStatoConsenso(oConsenso As Consenso) As String
        '
        ' Ritorna l'HTML per disegnare la colonna del Consenso
        '
        Dim strHtml As String = "(nessun Consenso)"
        Select Case oConsenso.Stato
            Case ConsensoStato.Accordato
                strHtml = "<img src='" & Me.ResolveUrl("~/images/flag_yes.gif") & "' alt='Consenso accordato' border=0>" & _
                            "&nbsp;&nbsp;(Consenso accordato)"
            Case ConsensoStato.Negato
                strHtml = "<img src='" & Me.ResolveUrl("~/images/flag_no.gif") & "'  alt='Consenso negato' border=0>" & _
                            "&nbsp;&nbsp;(Consenso negato)"

            Case ConsensoStato.NonAcquisito
                strHtml = "(nessun Consenso)"
        End Select
        Return strHtml
    End Function

    Private Sub cmdForzaConsenso_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdForzaConsenso.Click
        Try
            If cmbMotiviAccesso.SelectedValue <> MOTIVO_ACCESSO_NOT_SELECTED_ID Then
                '
                ' MODIFICA 2015-03-20: Imposto che ho premuto il pulsante per accedere
                '
                Utility.AccessoDiretto_AccessoDaConsenso(mguidIdPaziente) = True
                '
                ' Valorizzo il motivo di accesso
                '
                Utility.MotivoAccesso = cmbMotiviAccesso.SelectedItem
                '
                ' Loggo la forzatura del consenso
                '
				Utility.TracciaAccessiPaziente("Forzatura del consenso per urgenze da accesso diretto", mguidIdPaziente, Utility.MotivoAccesso, Utility.MotivoAccessoNote)
                '
                ' Memorizzo in sessione che ho forzato il consenso
                '
                Call Utility.SetSessionForzaturaConsenso(mguidIdPaziente, True)
                '
                ' Navigo alla pagina richiesta
                '
                Call Me.Response.Redirect(Me.ResolveUrl(mUrlToNavigate), False)
            Else
                ClientScript.RegisterStartupScript(Page.GetType(), "cmdForzaConsenso_Click", JSBuildScript(JSAlertCode(Messaggi.MSG_SELEZIONARE_MOTIVO_ACCESSO)))
            End If

        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            lblErrorMessage.Text = "Si è verificato un errore durante l'accesso forzato ai dati del paziente senza consenso."
            alertErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub SetDataDecessoVisible(oSacDettaglioPaziente As SacDettaglioPaziente)
        If oSacDettaglioPaziente.DataDecesso.HasValue Then
            lblDataDecesso.Visible = True
            lblDataDecessoDesc.Visible = True
        Else
            lblDataDecesso.Visible = False
            lblDataDecessoDesc.Visible = False
        End If
    End Sub

    Protected Sub cmdAnnulla_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdAnnulla.Click
        '
        ' Questa è da modificare per ritornare alla pagina precedente...a seconda dei vari casi
        '
        Try
            'Dim sUrl As String = CType(BarraNavigazione.NavBarList(0), ListItem).Value
            'Call Me.Response.Redirect(Me.ResolveUrl(sUrl), False)
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            lblErrorMessage.Text = String.Format("Si è verificato un errore durante la pressione del pulsante '{0}'", cmdAnnulla.Text)
            alertErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub cmdAccedi_Click(sender As Object, e As System.EventArgs) Handles cmdAccedi.Click
        Try
            If cmbMotiviAccesso.SelectedValue <> MOTIVO_ACCESSO_NOT_SELECTED_ID Then
                '
                ' MODIFICA 2015-03-20: Imposto che ho premuto il pulsante per accedere
                '
                Utility.AccessoDiretto_AccessoDaConsenso(mguidIdPaziente) = True
                '
                ' Valorizzo il motivo di accesso
                '
                Utility.MotivoAccesso = cmbMotiviAccesso.SelectedItem
                Call Me.Response.Redirect(Me.ResolveUrl(mUrlToNavigate), False)
            Else
                ClientScript.RegisterStartupScript(Page.GetType(), "cmdAccedi_Click", JSBuildScript(JSAlertCode(Messaggi.MSG_SELEZIONARE_MOTIVO_ACCESSO)))
            End If
        Catch ex As Exception
            lblErrorMessage.Text = String.Format("Si è verificato un errore durante la pressione del pulsante '{0}'", cmdAccedi.Text)
            alertErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub
End Class
