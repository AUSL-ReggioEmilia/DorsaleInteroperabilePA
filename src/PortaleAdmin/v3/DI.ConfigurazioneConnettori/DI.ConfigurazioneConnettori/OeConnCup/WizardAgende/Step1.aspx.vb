Imports OeConnCup.WizardAgende

Public Class WizardStep1
    Inherits System.Web.UI.Page

    Protected Shadows ReadOnly Property Master() As SiteMaster
        Get
            Return CType(MyBase.Master, SiteMaster)
        End Get
    End Property

    Protected Property Agenda() As Agenda
        Get
            Return CType(Me.ViewState("Agenda"), Agenda)
        End Get
        Set(ByVal value As Agenda)
            Me.ViewState.Add("Agenda", value)
        End Set
    End Property

    Public Property CodiceAgendaCup() As String
        Get
            Return CType(Me.ViewState("CodiceAgendaCup"), String)
        End Get
        Set(ByVal value As String)
            Me.ViewState.Add("CodiceAgendaCup", value)
        End Set
    End Property

    Private Const _separator As String = " @ "

    Protected Property ListaOrigine() As String
        Get
            Return CType(Me.Session("ListaOrigine"), String)
        End Get
        Set(ByVal value As String)
            Me.Session.Add("ListaOrigine", value)
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Try

            If Not Page.IsPostBack Then

                'TOOD: Provare ad ottenre la tabella(OeConnCupDataContext) già esistente senza fare il new
                'Dim db1 = Global_asax.DefaultModel.
                Dim db As New OeConnCupDataContext

                'Ottengo i codici Sistemi per popolare la DropDownList
                Dim dtsourceSistemi = db.ocup_SistemiErogantis()
                Dim enumSistemi As List(Of ocup_SistemiEroganti) = dtsourceSistemi.ToList()
                Dim sListSistemiEroganti As List(Of String) = New List(Of String)

                For Each sistema As ocup_SistemiEroganti In enumSistemi
                    sListSistemiEroganti.Add($"{sistema.CodiceSistema}{_separator}{sistema.CodiceAzienda}")
                Next

                DdlSistemaErogante.DataSource = sListSistemiEroganti

                'Leggo da queryString la lista di origine e la scrivo in sessione
                Me.ListaOrigine = Request.QueryString("ListaOrigine")

                'Leggo da queryString il CodiceAgendaCup
                Me.CodiceAgendaCup = Request.QueryString("CodiceAgendaCup")

                If Not String.IsNullOrEmpty(Me.CodiceAgendaCup) Then

                    'Pulisco la sessione!
                    Session.Remove(Utility.SESSION_WIZARD_AGENDA)


                    'Ottengo l'agenda, se non la trovo la creo poi(Se arrivo da Agende Esistenti con Prestazioni da Configurare allora esiste già)
                    Dim dtAgendeCup = db.TranscodificaAgendaCupStrutturaErogante()
                    Dim agendaEsistente As TranscodificaAgendaCupStrutturaErogante = dtAgendeCup.Where(Function(a) a.CodiceAgendaCup = Me.CodiceAgendaCup).FirstOrDefault

                    'Se non esiste l'agenda ne creo una da inserire nello step3
                    If agendaEsistente Is Nothing Then

                        'Creo l'agenda da inserire nello step 3 
                        Dim dtsourceAgende = db.DiffAgendeCups()
                        Dim agendaSelezionata As DiffAgendeCup = dtsourceAgende.Where(Function(a) a.CodiceAgendaCup = Me.CodiceAgendaCup).FirstOrDefault

                        If agendaSelezionata Is Nothing Then
                            Throw New ApplicationException("Non è stata trovata nessun'agenda")
                        End If

                        Agenda = agendaSelezionata
                        Agenda.IsAlreadyExisting = False

                    Else
                        'Se esiste l'agenda prendo quella esistente
                        Agenda = agendaEsistente
                        Agenda.IsAlreadyExisting = True

                        'Imposto nella DdlSistemaErogante i valori precedentemente selezionati
                        DdlSistemaErogante.SelectedValue = $"{Agenda.CodiceSistemaErogante}{_separator}{Agenda.CodiceAziendaErogante}"
                        DdlSistemaErogante.Enabled = False
                        TxtTranscodificaCodiceAgendaCup.Enabled = False


                    End If

                Else

                    'Se non trovo l'agenda nel query string guardo in sessione (caso indietro da pagina: step2 o step3)
                    Agenda = CType(Session(Utility.SESSION_WIZARD_AGENDA), Agenda)

                    If Agenda Is Nothing Then
                        Throw New ApplicationException("Non è stata trovata nessun'agenda")
                    End If

                    'Imposto nella DdlSistemaErogante i valori precedentemente selezionati
                    DdlSistemaErogante.SelectedValue = $"{Agenda.CodiceSistemaErogante}{_separator}{Agenda.CodiceAziendaErogante}"

                    'Se l'agenda esiste già allora devo mettere in read only
                    If Agenda.IsAlreadyExisting Then
                        DdlSistemaErogante.Enabled = False
                        TxtTranscodificaCodiceAgendaCup.Enabled = False
                    End If

                    'Tolgo le prestazioni all'agenda poichè Struttura Erogante potrebbe cambiare
                    Agenda.Prestazioni.Clear()

                End If

                'Aggiorno la pagina
                Page.DataBind()

            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Me.Master.ShowAlert(sErrorMessage)
        End Try

    End Sub

    Private Sub BtnAvanti_Click(sender As Object, e As EventArgs) Handles BtnAvanti.Click

        Try

            'Imposto l'agenda inserita dall'utente solo se non era già esistente
            If Not Agenda.IsAlreadyExisting Then

                'Aggiorno "Agenda" con i campi inseiriti dall'utente
                Agenda.TranscodificaCodiceAgendaCup = TxtTranscodificaCodiceAgendaCup.Text

                Dim selectedSistema As String = DdlSistemaErogante.SelectedValue
                Dim index As Integer = selectedSistema.IndexOf(_separator)

                Agenda.CodiceSistemaErogante = selectedSistema.Substring(0, index)
                Agenda.CodiceAziendaErogante = selectedSistema.Substring(index + _separator.Length)

                'Campi calcolati
                Agenda.StrutturaErogante = Agenda.CodiceSistemaErogante
                Agenda.DescrizioneStrutturaErogante = Agenda.CodiceSistemaErogante

            End If

            Session.Add(Utility.SESSION_WIZARD_AGENDA, Agenda)

            Response.Redirect("Step2.aspx", False)

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Me.Master.ShowAlert(sErrorMessage)
        End Try

    End Sub

    Private Sub DdlSistemaErogante_DataBound(sender As Object, e As EventArgs) Handles DdlSistemaErogante.DataBound
        'Imposto l'item di default "[Non impostato]"
        DdlSistemaErogante.Items.Insert(0, New ListItem("[Non impostato]", String.Empty))
    End Sub

End Class