Imports OeConnCup.WizardAgende

Public Class Step4
    Inherits System.Web.UI.Page

    Protected Property Agenda As Agenda
    Protected Property PrestazioniFallite As List(Of Prestazione)

    Protected Property ListaOrigine() As String
        Get
            Return CType(Me.Session("ListaOrigine"), String)
        End Get
        Set(ByVal value As String)
            Me.Session.Add("ListaOrigine", value)
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'Leggo l'agenda dalla sessione
        Agenda = CType(Me.Session(Utility.SESSION_WIZARD_AGENDA), Agenda)

        'Solo se l'agenda ha delle prestazioni!
        If Agenda.Prestazioni.Count > 0 Then

            PrestazioniFallite = CType(Session(Utility.SESSION_WIZARD_AGENDA_PRESTAZIONI_FALLITE), List(Of Prestazione))

            'Prestazioni inserite correttamente
            Dim nPrestazioniSuccess As Integer

            If PrestazioniFallite IsNot Nothing AndAlso PrestazioniFallite.Count > 0 Then

                LblPrestazioniFallite.Text = $"Numero di prestazioni associate fallite {PrestazioniFallite.Count} "
                DivFallite.Visible = True
                PopulateGridPrestazioniFallite()

                'se ci sono delle prestazioni fallite: nPrestazioniSuccess => Prestazioni totali - fallite
                nPrestazioniSuccess = Agenda.Prestazioni.Count - PrestazioniFallite.Count
            Else
                'altrimenti => nPrestazioniSuccess = Prestazioni totali
                nPrestazioniSuccess = Agenda.Prestazioni.Count
            End If

            If nPrestazioniSuccess > 0 Then
                LblPrestazioniCompletate.Text = $"Numero di prestazioni associate correttamente: {nPrestazioniSuccess} "
                DivSuccessi.Visible = True
            End If

        End If

        Page.DataBind()

    End Sub

    Private Sub PopulateGridPrestazioniFallite()

        'Aggiorno la Griglia delle Prestazioni
        GridViewPrestazioniFallite.DataSource = PrestazioniFallite
        GridViewPrestazioniFallite.DataBind()
        UpdatePanelPrestazioniFallite.Update()

    End Sub

    Private Sub GridViewPrestazioniFallite_PageIndexChanging(sender As Object, e As GridViewPageEventArgs) Handles GridViewPrestazioniFallite.PageIndexChanging
        ' Cambio pagina della griglia, 
        '
        GridViewPrestazioniFallite.PageIndex = e.NewPageIndex

        'Devo ri applicare la DataSource e i Filtri ogni volta che cambio pagina
        PopulateGridPrestazioniFallite()

    End Sub

    Private Sub BtnOk_Click(sender As Object, e As EventArgs) Handles BtnOk.Click

        'Pulisco la sessione!
        Session.Remove(Utility.SESSION_WIZARD_AGENDA)
        Session.Remove(Utility.SESSION_WIZARD_AGENDA_PRESTAZIONI_FALLITE)

        'Torno alla lista (usanto la variabile in sessione popolata nello step 1)
        Response.Redirect($"~/{Me.ListaOrigine}/List.aspx", False)

    End Sub

End Class