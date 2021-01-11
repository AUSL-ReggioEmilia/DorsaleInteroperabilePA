Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility

Partial Class Pazienti_PazientiConsenso
    Inherits System.Web.UI.Page
    '
    ' Variabili private della classe
    '
    Private mguidIdPaziente As Guid
    Private mstrPageID As String
    Private mobjPazientiDettaglio As PazienteDettaglio
    Private bDataSourcePazientiAccessiListaExecuteSelect As Boolean = True
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
            mguidIdPaziente = New Guid(Request.QueryString(PAR_ID_PAZIENTE))
            mstrPageID = Request.Url.Segments(Request.Url.Segments.GetUpperBound(0))
            '
            ' Aggiungo lo script per lo stylesheet
            '
            'PageAddCss(Me)

        Catch ex As Exception
            '
            ' Gestione dell'errore
            '
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = Logging.GetMessageError(ex, "") & "<br>" & _
                                "durante la lettura dei parametri dal QueryString."
        End Try
    
        '
        ' Eseguo il bind della griglia con i dati (solo se è un PostBack)
        '
		Call PageDataBind()
        '
        ' Visualizzo/nascondo dati relativi all'ultimo evento
        '
        Call ShowEventiInfo()

        'If Not IsPostBack Then
        '    '
        '    ' Aggiorno la barra di navigazione
        '    '
        '    BarraNavigazione.SetCurrentItem("Consenso", "")
        'End If
        '
        ' Inizializzo la pagina
        '
        Call InitializePage()

    End Sub

    Private Sub InitializePage()
        '
        ' Inizializzo la pagina
        '
        Dim strScript As String = String.Empty
        Dim strUrl As String = String.Empty
        '
        ' Aggiungo lo script lato client
        ' per la conferma alla forzatura del consenso
        '
        strScript = "javascript:return confirm('Confermi la forzatura del consenso ?');"

        cmdForzaConsenso.Attributes.Item("onclick") = strScript
        '------------------------------------------------------------------------------------------
        ' Aggiungo lo script lato client per inserire un nuovo consenso GENERICO
        '------------------------------------------------------------------------------------------
        strUrl = Me.ResolveUrl("~/Pazienti/PazientiConsensoInserisci.aspx") &
                                "?" & PAR_ID_PAZIENTE & "=" & mguidIdPaziente.ToString & "&" & PAR_ID_TIPO_CONSENSO & "=" & CType(SacConsensiDataAccess.TipoConsenso.Generico, Integer)
        strScript = "javascript:document.location.href='" & strUrl & "'"
        cmdRichiediConsenso.Attributes.Item("onclick") = strScript
        '------------------------------------------------------------------------------------------
        ' Aggiungo lo script lato client per modificare un nuovo consenso GENERICO
        '------------------------------------------------------------------------------------------
        strUrl = Me.ResolveUrl("~/Pazienti/PazientiConsensoModifica.aspx") &
                                "?" & PAR_ID_PAZIENTE & "=" & mguidIdPaziente.ToString & "&" & PAR_ID_TIPO_CONSENSO & "=" & CType(SacConsensiDataAccess.TipoConsenso.Generico, Integer)
        strScript = "javascript:document.location.href='" & strUrl & "'"
        cmdModificaConsenso.Attributes.Item("onclick") = strScript
        '------------------------------------------------------------------------------------------
        ' Aggiungo lo script lato client per inserire un nuovo consenso DOSSIER
        '------------------------------------------------------------------------------------------
        strUrl = Me.ResolveUrl("~/Pazienti/PazientiConsensoInserisci.aspx") &
                                "?" & PAR_ID_PAZIENTE & "=" & mguidIdPaziente.ToString & "&" & PAR_ID_TIPO_CONSENSO & "=" & CType(SacConsensiDataAccess.TipoConsenso.Dossier, Integer)
        strScript = "javascript:document.location.href='" & strUrl & "'"
        cmdRichiediConsensoDossier.Attributes.Item("onclick") = strScript
        '------------------------------------------------------------------------------------------
        ' Aggiungo lo script lato client per modificare un nuovo consenso DOSSIER
        '------------------------------------------------------------------------------------------
        strUrl = Me.ResolveUrl("~/Pazienti/PazientiConsensoModifica.aspx") &
                                "?" & PAR_ID_PAZIENTE & "=" & mguidIdPaziente.ToString & "&" & PAR_ID_TIPO_CONSENSO & "=" & CType(SacConsensiDataAccess.TipoConsenso.Dossier, Integer)
        strScript = "javascript:document.location.href='" & strUrl & "'"
        cmdModificaConsensoDossier.Attributes.Item("onclick") = strScript
        '------------------------------------------------------------------------------------------
        ' Aggiungo lo script lato client per inserire un nuovo consenso DOSSIER STORICO
        '------------------------------------------------------------------------------------------
        strUrl = Me.ResolveUrl("~/Pazienti/PazientiConsensoInserisci.aspx") &
                                "?" & PAR_ID_PAZIENTE & "=" & mguidIdPaziente.ToString & "&" & PAR_ID_TIPO_CONSENSO & "=" & CType(SacConsensiDataAccess.TipoConsenso.DossierStorico, Integer)
        strScript = "javascript:document.location.href='" & strUrl & "'"
        cmdRichiediConsensoDossierStorico.Attributes.Item("onclick") = strScript
        '------------------------------------------------------------------------------------------
        ' Aggiungo lo script lato client per modificare un nuovo consenso DOSSIER STORICO
        '------------------------------------------------------------------------------------------
        strUrl = Me.ResolveUrl("~/Pazienti/PazientiConsensoModifica.aspx") &
                                "?" & PAR_ID_PAZIENTE & "=" & mguidIdPaziente.ToString & "&" & PAR_ID_TIPO_CONSENSO & "=" & CType(SacConsensiDataAccess.TipoConsenso.DossierStorico, Integer)
        strScript = "javascript:document.location.href='" & strUrl & "'"
        cmdModificaConsensoDossierStorico.Attributes.Item("onclick") = strScript

        '-------------------------------------------------------------------------------------
        ' Configuro pulsante per visualizzazione della lista dei referti
        ' MODIFICA 2015-04-22: ora il pulsante viene usato si da Medici che da Infermieri: quindi è sempre visibile
        ' trReferti.Visible = True DI DEFAULT, cmdReferti2.Visible = True DI default
        '-------------------------------------------------------------------------------------
        If Utility.CheckPermission(RoleManagerUtility.ATTRIB_REFERTI_INFERMIERI_VIEW) Then
            '
            '  Se infermiere cambio la label accanto al pulsante
            '
            lblReferti.Text = My.Settings.ButtonRefertiInfermieri_Description
        End If


        '-------------------------------------------------------------------------------------
        ' Configuro pulsante per visualizzazione della lista degli Eventi
        '-------------------------------------------------------------------------------------
        Dim sRoleViewer As String = String.Empty
        sRoleViewer = Utility.GetAppSettings(PAR_EVENTI_ROLE_VIEWER, "")
        If sRoleViewer.Length > 0 AndAlso CheckPermission(sRoleViewer) Then
            cmdEventi.Visible = True
            lblEventi.Visible = True
            cmdEventi.Text = Utility.GetAppSettings(PAR_EVENTI_CAPTION, "")
            lblEventi.Text = Utility.GetAppSettings(PAR_EVENTI_DESCRIPTION, "")
        Else
            cmdEventi.Visible = False
            lblEventi.Visible = False
        End If

    End Sub


    Private Sub cmdResetConsensi_Click(sender As Object, e As System.EventArgs) Handles cmdResetConsensi.Click
        Try
            Dim oSacConsensiWs As SacConsensiDataAccess.ConsensiSoap

            ' DOPPIO CONTROLLO SULL'ATTRIBUTO CONSENSI_DELETE_ALL
            If Not HttpContext.Current.User.IsInRole(RoleManagerUtility.ATTRIB_CONSENSI_DELETE_ALL) Then
                Exit Sub
            End If
            '
            ' Istanzio il webservice e imposto le credenziali in base al metodo di autenticazione Integrata(NTLM)/Basic
            '
            oSacConsensiWs = New SacConsensiDataAccess.ConsensiSoapClient
            If oSacConsensiWs Is Nothing Then
                Throw New Exception("Errore: il Web Service SacConsensiDataAccess.ConsensiSoapClient è nothing.")
            End If
            Utility.SetWsConsensiCredential(oSacConsensiWs)
            '
            ' INVOCO ConsensiEliminaPerIdPaziente
            Dim body As New SacConsensiDataAccess.ConsensiEliminaPerIdPazienteRequestBody(mguidIdPaziente.ToString, HttpContext.Current.User.Identity.Name)
            Dim request As New SacConsensiDataAccess.ConsensiEliminaPerIdPazienteRequest(body)
            oSacConsensiWs.ConsensiEliminaPerIdPaziente(request)

            'QUESTO SERVE PER FAR RICARICARE LA PAGINA ED ANCHE PER EVITARE 
            'CHE L'EVENTO CLICK SIA RIESEGUITO PIU' VOLTE SE SI RICARICA LA PAGINA
            Response.Redirect(Page.Request.RawUrl)

        Catch ex As Exception
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'esecuzione del comando di Reset Consensi."
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub PageDataBind()
        Dim oSacPazientiWs As SacPazientiDataAccess.PazientiSoapClient = Nothing
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
                SacDettaglioPaziente.Session() = moSacDettaglioPaziente
            End If
            '
            ' A questo punto la classe moSacDettaglioPaziente è valorizzata e posso eseguire il bind per il div paziente
            '
            divPaziente.DataBind()
            '
            ' Visualizzo/nascondo la parte della data di decesso: sia label che text
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


            '----------------------------------------------------------------------------------------------
            ' Rendo visibile il link ai dati di consenso sul SAC
            ' Se almeno uno è stato acquisito (non imposrta se Accordato o non accordato) visualizzo il link
            '----------------------------------------------------------------------------------------------
            hlShowConsensi.NavigateUrl = Me.ResolveUrl(String.Format("~/Pazienti/PazientiConsensoSac.aspx?IdPaziente={0}", mguidIdPaziente.ToString))
            hlShowConsensi.Visible = False
            If oConsensoGenerico.Stato <> ConsensoStato.NonAcquisito OrElse
              oConsensoDossier.Stato <> ConsensoStato.NonAcquisito OrElse
              oConsensoDossierStorico.Stato <> ConsensoStato.NonAcquisito Then

                hlShowConsensi.Visible = True
            End If


            '----------------------------------------------------------------------------------------------
            ' Altre configurazioni
            '----------------------------------------------------------------------------------------------
            '
            ' Pulsante reset consensi
            '
            Dim bResetConsensi As Boolean = HttpContext.Current.User.IsInRole(RoleManagerUtility.ATTRIB_CONSENSI_DELETE_ALL)
            cmdResetConsensi.Enabled = bResetConsensi
            cmdResetConsensi.Visible = bResetConsensi

            Dim bConsensoPresente As Boolean = moSacDettaglioPaziente.ConsensoPresente()
            '
            ' Il pulsante di forzatura del consenso si deve vedere se DOSSIER STORICO non è stato ACCORDATO AND l'utente può accedere per necessità clinica urgente
            '
            cmdForzaConsenso.Visible = (oConsensoDossierStorico.Stato <> ConsensoStato.Accordato) AndAlso Me.Context.User.IsInRole(RoleManagerUtility.ATTRIB_ACC_DIR_ENABLED)
            '
            ' Disabilito i pulsanti se manca il consenso
            '
            cmdReferti2.Enabled = (bConsensoPresente)
            '
            ' La visualizzazione degli eventi dipende dal consenso? Si come i referti
            '
            cmdEventi.Enabled = (bConsensoPresente)
            '
            ' Imposto il parametro di select per la datasource degli "accessi al paziente"
            '
            Dim bShowListaAccessiPaziente As Boolean = CBool(CInt(Utility.GetAppSettings(PAR_LISTA_ACCESSI_PAZIENTE_VISIBLE, "0")))
            bDataSourcePazientiAccessiListaExecuteSelect = bShowListaAccessiPaziente

            If bShowListaAccessiPaziente Then
                DataSourcePazientiAccessiLista.SelectParameters("IdPaziente").DefaultValue = mguidIdPaziente.ToString()
            End If


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
                    ' Aggiungo e seleziono MOTIVO_ACCESSO_NECESSITA_TECNICA_TEXT (solo se "Utente tecnico")
                    '
                    cmbMotiviAccesso.Items.Add(New ListItem(MOTIVO_ACCESSO_NECESSITA_TECNICA_TEXT, MOTIVO_ACCESSO_NECESSITA_TECNICA_ID))
                    If bUtenteTecnico Then
                        cmbMotiviAccesso.SelectedValue = MOTIVO_ACCESSO_NECESSITA_TECNICA_ID
                    End If
                Else
                    '
                    ' In base alla pagina di provenienza imposto default per il motivo dell'accesso
                    '
                    If Request.UrlReferrer IsNot Nothing Then
                        Dim sPath As String = Request.UrlReferrer.AbsolutePath.ToUpper
                        If sPath.Contains("/PAZIENTI/PAZIENTI.ASPX") Then
                            '
                            ' Non faccio niente: costringo utente ad eseguire una selezione di un motivo presente in tabella
                            '
                        ElseIf sPath.Contains("/DEFAULT.ASPX") Then
                            '
                            ' Aggiungo un item alla combo e lo seleziono
                            '
                            cmbMotiviAccesso.Items.Add(New ListItem(MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_TEXT, MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_ID))
                            cmbMotiviAccesso.SelectedValue = MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_ID
                        Else
                            '
                            ' Se si arriva alla pagina del consenso navigando "all'indietro"...
                            ' Seleziono valore già selezionato in precedenza leggendolo dalla sessione (Se si seleziona un item che non esiste NON viene generato un errore)
                            '
                            Dim oItemMotivoAccesso As ListItem = Utility.MotivoAccesso
                            If Not oItemMotivoAccesso Is Nothing Then
                                If cmbMotiviAccesso.Items.FindByValue(oItemMotivoAccesso.Value) Is Nothing Then
                                    cmbMotiviAccesso.Items.Add(oItemMotivoAccesso)
                                End If
                                cmbMotiviAccesso.SelectedValue = oItemMotivoAccesso.Value
                            End If
                        End If
                    End If
                End If
            End If

        Catch ex As Exception
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante il caricamento della pagina!"
			Logging.WriteError(ex, Me.GetType.Name)
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
                ' Salvo in sessione i dati relativi a MotivoAccesso e Note
                '
                Utility.MotivoAccesso = cmbMotiviAccesso.SelectedItem
                Utility.MotivoAccessoNote = txtMotivoAccessoNote.Text
                '
                ' Abilito i pulsanti a prescindere che l'utente li possa vedere (se l'utente li può vedere è già stato controllato)
                '     
                cmdReferti2.Enabled = True

                cmdEventi.Enabled = True
                '
                ' Setto che ho spinto il pulsante per forzare il consenso
                '
                Call SetSessionForzaturaConsenso(mguidIdPaziente, True)
                '
                ' Traccia accessi
                '
                Utility.TracciaAccessiPaziente("Forzatura del consenso per urgenze", mguidIdPaziente, Utility.MotivoAccesso, Utility.MotivoAccessoNote)
            Else
                ClientScript.RegisterStartupScript(Page.GetType(), "cmdForzaConsenso_Click", JSBuildScript(JSAlertCode(Messaggi.MSG_SELEZIONARE_MOTIVO_ACCESSO)))
            End If

        Catch ex As Exception
            '
            ' Gestione dell'errore
            '
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = Logging.GetMessageError(ex, "") & "<br>" & _
                                "durante l'operazione di aggiornamento dei dati."
        End Try

    End Sub


    Private Function GetButtonJScript(ByVal sKeyPopup As String, ByVal sUrl As String) As String
        Dim sPopup As String
        Dim sJFunction As String

        Try
            sPopup = ConfigurationManager.AppSettings(sKeyPopup) & ""
            If sPopup Is Nothing OrElse sPopup.Length = 0 Then
                sPopup = "1"
            End If
        Catch ex As Exception
            sPopup = "1"
        End Try

        If sPopup = "1" Then
            sJFunction = "ApriApplicazione"
        Else
            sJFunction = "NavigaApplicazione"
        End If

        Return "javascript:" & sJFunction & "('" & sUrl & "');"

    End Function

    Private Sub SetDataDecessoVisible(oSacDettaglioPaziente As SacDettaglioPaziente)
        If oSacDettaglioPaziente.DataDecesso.HasValue Then
            lblDataDecesso.Visible = True
            lblDataDecessoDesc.Visible = True
        Else
            lblDataDecesso.Visible = False
            lblDataDecessoDesc.Visible = False
        End If
    End Sub


    Protected Sub cmdEventi_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdEventi.Click
        Call NavigaAllaPagina("~/Eventi/RicoveriLista.aspx")
    End Sub

    Protected Sub cmdReferti2_Click(sender As Object, e As EventArgs) Handles cmdReferti2.Click
        Call NavigaAllaPagina("~/Referti/RefertiListaPaziente.aspx")
    End Sub

    ''' <summary>
    ''' Navigazione alle pagine dei referti ed eventi. Controlla se è stato selezionato un motivo di accesso
    ''' </summary>
    ''' <param name="sUrl">Url nella forma "~/Folder/Page.aspx"</param>
    ''' <remarks></remarks>
    Private Sub NavigaAllaPagina(sUrl As String)
        Dim strUrl As String
        Try
            If cmbMotiviAccesso.SelectedValue <> MOTIVO_ACCESSO_NOT_SELECTED_ID Then
				Utility.MotivoAccesso = cmbMotiviAccesso.SelectedItem
				Utility.MotivoAccessoNote = txtMotivoAccessoNote.Text
                strUrl = Me.ResolveUrl(sUrl)
                Response.Redirect(strUrl & "?idpaziente=" & mguidIdPaziente.ToString)
            Else
                ClientScript.RegisterStartupScript(Page.GetType(), "NavigaAllaPagina", JSBuildScript(JSAlertCode(Messaggi.MSG_SELEZIONARE_MOTIVO_ACCESSO)))
            End If
        Catch ex As Threading.ThreadAbortException
            ' Non faccio niente: causato dal redirect
        Catch ex As Exception
            ' Gestione dell'errore
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante la pressione del pulsante."
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

	Private Sub ShowEventiInfo()
		Dim sRoleViewer As String
		Try
			'
			' Rendo invisibili tutti i control che visualizzano dati sugli eventi
			'
			divEventi.Visible = False
			'
			' Se L'utente corrente ha i permessi per visualizzare gli eventi...
			'
			sRoleViewer = Utility.GetAppSettings(PAR_EVENTI_ROLE_VIEWER, "")
			If sRoleViewer.Length > 0 AndAlso CheckPermission(sRoleViewer) Then
				'
				' Eseguo query e valorizzo i controlli...
				'
				Using oData As New Ricoveri
					Dim oDt As RicoveriDataSet.FevsRicoveroPazienteInfoDataTable
					'
					' Restituisce se attualmente ricoverato a prescindere dall'AziendaErogante
					'
					oDt = oData.GetRicoveroPazienteInfo(mguidIdPaziente)
					If Not oDt Is Nothing AndAlso oDt.Count > 0 Then
						Dim dr As RicoveriDataSet.FevsRicoveroPazienteInfoRow = oDt(0)
						'
						' Ettore 2015-06-03: ora la SP filtra le prenotazioni e restituisce solo dei ricoveri
						' TODO: sentire Foracchia - non viene fatto nessun controllo di visibilità sull'ultimo ricovero mostrato nelle info
						'
						If dr.Ricoverato Then
							imgRicoverato.ImageUrl = Me.ResolveUrl("~/images/flag_yes.gif")
							lblDataRicovero.Text = ""
							If Not dr.IsDataAccettazioneNull Then
								lblDataRicovero.Text = Format(dr.DataAccettazione, "g")
							End If
							divEventi.Visible = True
						End If
					End If
				End Using
			End If

		Catch ex As Exception
            '
            ' Gestione dell'errore
            '
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante la lettura dei dati relativi agli eventi."
			Logging.WriteError(ex, Me.GetType.Name)
		End Try
	End Sub

    'Protected Sub cmdEsci_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdEsci.Click
    '    Try
    '        Dim sUrl As String = CType(BarraNavigazione.NavBarList(0), ListItem).Value
    '        Call Me.Response.Redirect(Me.ResolveUrl(sUrl))
    '    Catch
    '        Call Me.Response.Redirect(Me.ResolveUrl("~/Default.aspx"))
    '    End Try
    'End Sub

#Region "DataSourcePazientiAccessiLista"

    Protected Sub DataSourcePazientiAccessiLista_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DataSourcePazientiAccessiLista.Selecting
        Try
            If bDataSourcePazientiAccessiListaExecuteSelect = False Then
                e.Cancel = True
            End If
        Catch
        End Try
    End Sub

    'Protected Sub DataSourcePazientiAccessiLista_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourcePazientiAccessiLista.Selected
    '    Const USER_ERR_MSG As String = "Errore durante l'operazione di ricerca degli ultimi accessi al paziente!"
    '    Try
    '        '
    '        ' Inizializzo la label del messaggio per la grid view
    '        '
    '        lblMsgGridViewPazientiAccessiLista.Visible = False
    '        lblMsgGridViewPazientiAccessiLista.Text = ""
    '        tblAccessiPaziente.Visible = True
    '        If e.Exception IsNot Nothing Then
    '            '
    '            ' Errore
    '            '
    '            Logging.WriteError(e.Exception, Me.GetType.Name)
    '            alertErrorMessage.Visible = True
    '            lblErrorMessage.Text = USER_ERR_MSG
    '            tblAccessiPaziente.Visible = False
    '            e.ExceptionHandled = True
    '        ElseIf e.ReturnValue Is Nothing OrElse CType(e.ReturnValue, DataTable).Rows.Count = 0 Then
    '            lblMsgGridViewPazientiAccessiLista.Visible = True
    '            lblMsgGridViewPazientiAccessiLista.Text = "Nessun accesso recente al paziente!"
    '        End If

    '    Catch ex As Exception
    '        '
    '        ' Errore
    '        '
    '        Logging.WriteError(ex, Me.GetType.Name)
    '        lblErrorMessage.Text = USER_ERR_MSG
    '        alertErrorMessage.Visible = True
    '    End Try
    'End Sub


#End Region

End Class
