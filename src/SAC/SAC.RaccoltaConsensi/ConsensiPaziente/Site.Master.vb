Imports DI.PortalUser2
Imports DI.PortalUser2.Data
Imports DI.PortalUser2.RoleManager

Partial Public Class Site
    Inherits MasterPage

    Public UtenteCorrente As Utente
    Public ErroreCaricamento As Boolean = False

    Protected ReadOnly Property InstrumentationKey As String
        Get
            Return Microsoft.ApplicationInsights.Extensibility.TelemetryConfiguration.Active.InstrumentationKey
        End Get
    End Property

    Private Sub Page_Init(sender As Object, e As System.EventArgs) Handles Me.Init
        Try
            '
            ' CARICO DA DB LE INFORMAZIONI SULL'UTENTE CORRENTE
            '
            UtenteCorrente = GestioneUtente.GetUtenteCorrente

        Catch ex As Exception
            ErroreCaricamento = True
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            ShowErrorLabel(sErrorMessage)
        End Try
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

        If Not IsPostBack Then
            Try

                PageHeader.Visible = Not MySession.IsAccessoDiretto

                FooterPlaceholder.Visible = Not MySession.IsAccessoDiretto

                'Valorizzo la versione del progetto.
                lblVersioneAssembly.Text = Utility.GetAssemblyVersion()

                'Valorizzo il pc.
                lblNomeHost.Text = Utility.GetUserHostName()

                'Nuovo: per ora non lo faccio lascio l'header attuale
                'Dim oUserInterface As UserInterface = New UserInterface(My.Settings.PortalUserConnectionString)
                'HeaderPlaceholder.Text = oUserInterface.GetBootstrapHeader2(PortalsTitles.PortaleConsensi)

                'Popolo le info relative all'utente
                PopolaInfoUtente()

            Catch
                'NON BLOCCO L'ESECUZIONE PER PROBLEMI GRAFICI
            End Try
        End If

    End Sub

    Public Sub ShowErrorLabel(ErrorMessage As String)
        'Utility.ShowErrorLabel(LabelError, ErrorMessage)
        If ErrorMessage.Length > 0 Then
            DivError.Visible = True
            LabelError.Text = ErrorMessage
            LabelError.Visible = True
            LabelError.Style.Add("display", "block")
        End If
    End Sub


    Private Sub PopolaInfoUtente()
        Try
            'Popolo la combo dei ruoli.
            Dim listaRuoli As List(Of Ruolo) = PortalUserSingleton.instance.RoleManagerUtility.GetRuoli()

            'Se l'utente non ha ruoli l'applicazione deve funzionare (non si potrà gestire il consenso generico)
            If (listaRuoli Is Nothing OrElse listaRuoli.Count = 0) Then
                'Nascondo label e comboi dei ruoli
                divRuoli.Visible = False
            Else
                'Popolo la combo dei ruoli
                Call PopolaComboRuoliUtente(listaRuoli)
            End If

            Dim nomeCognomeUtente As String = String.Empty

            'Questo oggetto viene salvato in sessione all'interno del global.asax
            Dim ultimoAccesso As SessioneUtente.UltimoAccesso = CType(Session(Utility.sess_dati_ultimo_accesso), SessioneUtente.UltimoAccesso)
            If (Not ultimoAccesso Is Nothing) Then
                nomeCognomeUtente = $"{ultimoAccesso.Utente?.Nome} {ultimoAccesso.Utente?.Cognome}"
                lblUltimoAccesso.Text = ultimoAccesso.UltimoAccessoDescrizione
            End If

            'valorizzo il nome-cognome dell'utente e il ruolo corrente.
            If (listaRuoli Is Nothing OrElse listaRuoli.Count = 0) Then
                lblInfoUtente.Text = $"{nomeCognomeUtente}"
            Else
                lblInfoUtente.Text = $"{nomeCognomeUtente} - {ddlRuoliUtente.SelectedItem.Text}"
            End If

            'Valorizzo il nome utente e la postazione contenuti nella dropdownlist dei ruoli.
            lblUtente.Text = UtenteCorrente.AccountName
            lblPostazione.Text = Utility.GetUserHostName()

        Catch ex As ApplicationException
            'Nascondo la riga della tabella con la combo dei ruoli.
            divRuoli.Visible = False
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            ShowErrorLabel(sErrorMessage)
            'Utility.NavigateToErrorPage(ErrorPage.ErrorCode.Exception, sErrorMessage, False)

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            ShowErrorLabel(sErrorMessage)
            'Utility.NavigateToErrorPage(ErrorPage.ErrorCode.Exception, sErrorMessage, False)
        End Try
    End Sub

    ''' <summary>
    ''' Metodo per popolare la combo dei ruoli
    ''' </summary>
    Private Sub PopolaComboRuoliUtente(listaRuoli As List(Of Ruolo))
        Try
            'ottengo il ruolo corrente
            Dim ruoloCorrenteCodice As String = PortalUserSingleton.instance.RoleManagerUtility.RuoloCorrente.Codice

            'Cancello gli item della combo
            ddlRuoliUtente.Items.Clear()

            'Popolo la combo con i ruoli dell'utente
            ddlRuoliUtente.DataSource = listaRuoli
            ddlRuoliUtente.DataValueField = "Codice"
            ddlRuoliUtente.DataTextField = "Descrizione"
            ddlRuoliUtente.DataBind()

            'Effettuo il bind della combo
            If Not String.IsNullOrEmpty(ruoloCorrenteCodice) Then
                Dim item As ListItem = ddlRuoliUtente.Items.FindByValue(ruoloCorrenteCodice)
                If Not item Is Nothing Then
                    item.Selected = True
                End If
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            ShowErrorLabel(sErrorMessage)
        End Try
    End Sub

    Private Sub ddlRuoliUtente_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ddlRuoliUtente.SelectedIndexChanged
        Try
            Dim currentUserName As String = UtenteCorrente.AccountName
            Dim ddlRuoliUtente As DropDownList = CType(sender, DropDownList)
            'Salvo nella tabella DatiUtente l'ultimo ruolo scelto dall'utente
            PortalUserSingleton.instance.PortalDataAdapterManager.DatiUtenteSalvaValore(currentUserName, RoleManagerUtility2.DI_USER_RUOLO_CORRENTE_CODICE, ddlRuoliUtente.SelectedItem.Value)

            'Scrivo la data di accesso corrente e il ruolo corrente sarà quella letta alla prossima ripartenza della sessione
            PortalUserSingleton.instance.SessioneUtente.SetUltimoAccesso(currentUserName, PortalsNames.PortaleConsensi, DateTime.Now, ddlRuoliUtente.SelectedItem.Value)

            'Imposto endResponse = false per non generarare ThreadAbortException
            Response.Redirect(Request.RawUrl, False)

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            ShowErrorLabel(sErrorMessage)
        End Try
    End Sub
End Class
