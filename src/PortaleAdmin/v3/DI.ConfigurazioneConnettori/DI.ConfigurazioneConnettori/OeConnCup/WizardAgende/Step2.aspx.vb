Imports OeConnCup.WizardAgende

Public Class WizardStep2
    Inherits System.Web.UI.Page

    Protected Shadows ReadOnly Property Master() As SiteMaster
        Get
            Return CType(MyBase.Master, SiteMaster)
        End Get
    End Property

    Protected Property Agenda() As Agenda
        Get
            Return CType(Me.Session(Utility.SESSION_WIZARD_AGENDA), Agenda)
        End Get
        Set(ByVal value As Agenda)
            Me.Session.Add(Utility.SESSION_WIZARD_AGENDA, value)
        End Set
    End Property

    Protected Property PrestazioneSelected() As Prestazione
        Get
            Return CType(Me.ViewState("PrestazioneSelected"), Prestazione)
        End Get
        Set(value As Prestazione)
            Me.ViewState.Add("PrestazioneSelected", value)
        End Set
    End Property

    Protected Property SelectedIndex() As Integer
        Get
            Return CType(Me.ViewState("SelectedIndex"), Integer)
        End Get
        Set(value As Integer)
            Me.ViewState.Add("SelectedIndex", value)
        End Set
    End Property

    Private _listaOrigine As String

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Try

            ' Render per bootstrap
            ' Crea la TABLE con Theader e Tbody
            GridViewPrestazioni.UseAccessibleHeader = True
            '
            ' Converte i tag html generati dalla GridView per la paginazione
            '   e li adatta alle necessita dei CSS Bootstrap
            GridViewPrestazioni.PagerStyle.CssClass = "pagination-gridview"
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)

            ' Solo la prima volta
            If Not Page.IsPostBack Then

                'Agenda = TryCast(Session(Utility.SESSION_WIZARD_AGENDA), Agenda)

                If Agenda Is Nothing Then
                    'Errore
                    Throw New ApplicationException("Non ho trovato in sessione l'istanza Agenda")
                End If

                'Cancello tutte le prestazioni 
                Agenda.Prestazioni.Clear()

                'TOOD: Provare ad ottenre la tabella(OeConnCupDataContext) già esistente senza fare il new
                'Dim db1 = Global_asax.DefaultModel.Tables.Where(Function(a) a.Name = NomeTabella())

                'Creo un nuovo contesto per utilizzare la tabella DiffLHAAgendePrestazioniTranscodificaAttributiPrestazioniCupErogantes
                Dim db As New OeConnCupDataContext

                Dim dtStruttureEroganti = db.ocup_StruttureErogantis()

                'Controllo che esista la struttura erognate, se non esiste la creo!
                If dtStruttureEroganti.Where(Function(a) a.Codice = Agenda.StrutturaErogante).FirstOrDefault Is Nothing Then
                    dtStruttureEroganti.InsertOnSubmit(New ocup_StruttureEroganti With {.Codice = Agenda.StrutturaErogante})
                    db.SubmitChanges()
                End If

                Dim dtsource = db.DiffPrestazioniCups()
                Dim prestazioniList As List(Of DiffPrestazioniCup) = dtsource.Where(Function(a) a.StrutturaErogante = Agenda.StrutturaErogante AndAlso a.CodiceAgendaCup = Agenda.CodiceAgendaCup).ToList()

                'Carico le prestazioni dell'agenda
                If prestazioniList IsNot Nothing AndAlso prestazioniList.Count > 0 Then

                    For Each prestazione As DiffPrestazioniCup In prestazioniList
                        Agenda.Prestazioni.Add(prestazione)
                    Next

                End If

                'Aggiorno la Griglia delle Prestazioni
                GridViewPrestazioni.DataSource = Agenda.Prestazioni
                GridViewPrestazioni.DataBind()
                UpdatePanelPrestazioni.Update()

                '' Render per bootstrap
                '' Crea la TABLE con Theader e Tbody
                'GridViewPrestazioni.HeaderRow.TableSection = TableRowSection.TableHeader

            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Me.Master.ShowAlert(sErrorMessage)
        End Try

    End Sub

    Private Sub BtnAvanti_Click(sender As Object, e As EventArgs) Handles BtnAvanti.Click

        Try
            ' Attualmente aggiornata poichè property di sessione
            Response.Redirect("Step3.aspx", False)

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Me.Master.ShowAlert(sErrorMessage)
        End Try

    End Sub

    Private Sub BtnIndietro_Click(sender As Object, e As EventArgs) Handles BtnIndietro.Click
        '
        ' Torno allo Step 1
        '
        Response.Redirect("Step1.aspx", False)
    End Sub

    Private Sub GridViewPrestazioni_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles GridViewPrestazioni.RowCommand
        If e.CommandName.Equals("Modifica") Then

            Dim idPrestazioneErogante As String = e.CommandArgument.ToString()

            SelectedIndex = Agenda.Prestazioni.FindIndex(Function(x) x.IdPrestazioneErogante = idPrestazioneErogante)
            PrestazioneSelected = Agenda.Prestazioni(SelectedIndex)

            'Ricarico i dati della modal
            ModalBody.DataBind()

            '
            ' Open dialog
            '
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "myModal", "$('#myModal').modal('show');", True)
            UpdatePanelModalForm.Update()

        End If
    End Sub

    Private Sub ButtonUpdate_Click(sender As Object, e As EventArgs) Handles ButtonUpdate.Click

        'Rimuovo la vecchia prestazione 
        Agenda.Prestazioni.RemoveAt(SelectedIndex)

        Dim idPrestazioneErogante As String = TxtIdPrestazioneErogante.Text
        Dim specialitaEsame As String
        Dim idPrestazioneCup As String

        'Ricavo il codice specialità dall'idPrestazioneErogante (primi 2 caratteri)
        specialitaEsame = idPrestazioneErogante.Substring(0, 2)
        'Ricavo il l'idPrestazioneCup dall'idPrestazioneErogante aggiungendo gli zeri in testa se necessario 
        idPrestazioneCup = idPrestazioneErogante.Substring(2)
        If idPrestazioneCup.Length < 5 Then
            Dim fmt As String = "00000" 'formato con 5 digit, se sono meno ci saranno gli zeri in testa per arrivare a 5
            idPrestazioneCup = CType(idPrestazioneCup, Integer).ToString(fmt)
        End If

        PrestazioneSelected.SpecialitaEsameCup = specialitaEsame
        PrestazioneSelected.IdPrestazioneCup = idPrestazioneCup
        PrestazioneSelected.IdPrestazioneErogante = idPrestazioneErogante

        'Ri Aggiungo la prestazione che è stata modificata
        Agenda.Prestazioni.Insert(SelectedIndex, PrestazioneSelected)

        'Aggiorno la Griglia delle Prestazioni
        GridViewPrestazioni.DataSource = Agenda.Prestazioni
        GridViewPrestazioni.DataBind()
        UpdatePanelPrestazioni.Update()

        'Rimuovo il selezionato!
        PrestazioneSelected = New Prestazione

        '
        ' Chiude la Modal
        '
        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "myModal", "$('#myModal').modal('hide');", True)

    End Sub

    Private Sub ButtonCancel_Click(sender As Object, e As EventArgs) Handles ButtonCancel.Click
        '
        ' Chiude la Modal
        '
        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "myModal", "$('#myModal').modal('hide');", True)
    End Sub

    Private Sub FiltriCercaIdPrestazioneCup_Click(sender As Object, e As EventArgs) Handles FiltriCercaIdPrestazioneCup.Click
        Filtra()
    End Sub

    Private Sub FiltriCercaIdPrestazioneErogante_Click(sender As Object, e As EventArgs) Handles FiltriCercaIdPrestazioneErogante.Click
        Filtra()
    End Sub

    Private Sub Filtra()

        Dim idPrestazioneCup As String = ""
        If Not String.IsNullOrEmpty(TxtFiltroIdPrestazioneCup.Text) Then
            idPrestazioneCup = TxtFiltroIdPrestazioneCup.Text
        End If

        Dim idPrestazioneErogante As String = ""
        If Not String.IsNullOrEmpty(TxtFiltroIdPrestazioneErogante.Text) Then
            idPrestazioneErogante = TxtFiltroIdPrestazioneErogante.Text
        End If

        Dim prestazioniFiltrate = Agenda.Prestazioni.Where(Function(x) x.IdPrestazioneCup.StartsWith(idPrestazioneCup) AndAlso x.IdPrestazioneErogante.StartsWith(idPrestazioneErogante)).ToList()
        GridViewPrestazioni.DataSource = prestazioniFiltrate
        GridViewPrestazioni.DataBind()
        UpdatePanelPrestazioni.Update()
        UpdatePanelFiltri.Update()

    End Sub

    Private Sub GridViewPrestazioni_PageIndexChanging(sender As Object, e As GridViewPageEventArgs) Handles GridViewPrestazioni.PageIndexChanging
        ' Cambio pagina della griglia, 
        '
        GridViewPrestazioni.PageIndex = e.NewPageIndex

        'Devo ri applicare la DataSource e i Filtri ogni volta che cambio pagina
        Filtra()
        UpdatePanelPrestazioni.Update()

    End Sub
End Class