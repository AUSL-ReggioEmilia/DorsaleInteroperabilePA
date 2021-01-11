Imports OeConnCup.WizardAgende

Public Class WizardStep3
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

    Private _listaOrigine As String

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            If Not Page.IsPostBack Then

                'Pulisco la sessione! (Tolgo le prestazioni fallite, potrebbero esserci delle vecchie prestazioni fallite altrimenti)
                Session.Remove(Utility.SESSION_WIZARD_AGENDA_PRESTAZIONI_FALLITE)

                If Agenda Is Nothing Then
                    'Errore
                    Throw New ApplicationException("Non ho trovato in sessione l'istanza Agenda")
                End If

                'TOOD: Provare ad ottenre la tabella(OeConnCupDataContext) già esistente senza fare il new
                'Dim db1 = Global_asax.DefaultModel.Tables.Where(Function(a) a.Name = NomeTabella())

                'Aggiorno la pagina
                Page.DataBind()
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Me.Master.ShowAlert(sErrorMessage)
        End Try
    End Sub

    Private Sub BtnConferma_Click(sender As Object, e As EventArgs) Handles BtnConferma.Click

        Try

            Dim prestazioniFallite As List(Of Prestazione) = New List(Of Prestazione)

            'Inserisco l'agenda (se è da creare) e le prestazioni associate
            Dim db As New OeConnCupDataContext

            If Not Agenda.IsAlreadyExisting Then

                Dim dtsAgende = db.TranscodificaAgendaCupStrutturaErogante()
                dtsAgende.InsertOnSubmit(Agenda)
                db.SubmitChanges()

            End If

            Dim dtsPrestazioni = db.TranscodificaAttributiPrestazioniCupErogante()

            For Each prestazione As Prestazione In Agenda.Prestazioni
                Try
                    dtsPrestazioni.InsertOnSubmit(prestazione)
                    'Devo fare il commit di una alla volta per vedere se va in errore e catturare la prestazione fallita
                    db.SubmitChanges()
                Catch ex As Exception
                    'Vado avanti ma segno quale prestazione è fallita
                    prestazioniFallite.Add(prestazione)
                End Try
            Next

            'Salvo in sessione le prestazioni fallite solo se ce ne sono!
            If (prestazioniFallite.Count > 0) Then
                Session.Add(Utility.SESSION_WIZARD_AGENDA_PRESTAZIONI_FALLITE, prestazioniFallite)
            End If

            'Passo allo step 4
            Response.Redirect("Step4.aspx", False)

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Me.Master.ShowAlert(sErrorMessage)
            'Se va in errore l'inserimento dell'agenda probabilmente non esiste la StrutturaErogante!!! (StrutturaErogante = CodiceSistemaErogante)
        End Try

    End Sub


End Class