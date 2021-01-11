Public Class _Default
    Inherits Page

    Private btnClicked As Boolean = False

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            'solo la prima volta
            'carico i filtri ottenendo i valori dalla sessione
            LoadFilterFromSession()

            'Se almeno una textbox è valorizzata allora eseguo la query
            If Not String.IsNullOrEmpty(txtCognome.Text) OrElse Not String.IsNullOrEmpty(txtNome.Text) OrElse Not String.IsNullOrEmpty(txtAnnoNascita.Text) _
                OrElse Not String.IsNullOrEmpty(txtCodfisc.Text) Then
                btnClicked = True
            End If

        End If
    End Sub

    Private Sub odsPazienti_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsPazienti.Selecting
        Try
            If btnClicked Then
                'se sono qui è stato premuto il pulsante "Cerca",quindi eseguo la ricerca.
                e.InputParameters("Token") = Nothing 'IMPORTANTE: il Token non è obbligatorio.In questo caso non è necessario passarlo.
                e.InputParameters("Cognome") = txtCognome.Text
                e.InputParameters("Nome") = txtNome.Text

                'ottengo l'anno di nascita.
                Dim annoNascita As Integer? = Nothing
                If Not String.IsNullOrEmpty(txtAnnoNascita.Text) Then
                    'casto a Integer il contenuto della textbox txtAnnoNascita.
                    annoNascita = CType(txtAnnoNascita.Text, Integer)
                End If

                e.InputParameters("AnnoNascita") = annoNascita
                e.InputParameters("CodiceFiscale") = txtCodfisc.Text
            Else
                'se sono qui non è stato cliccato il pulsante "Cerca", quindi cancello la select.
                e.Cancel = True
            End If

        Catch ex As Exception
            'Si è verificato un errore.
            Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
        End Try
    End Sub

    Private Sub butFiltriRicerca_Click(sender As Object, e As EventArgs) Handles butFiltriRicerca.Click
        Try
            If validaFiltri() Then
                'salvo i filtri in sessone
                SaveFilterInSession()

                'setto a true la variabile.
                btnClicked = True

                'eseguo il bind dei dati.
                odsPazienti.DataBind()
            End If
        Catch ex As Exception
            'Si è verificato un errore.
            Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
        End Try
    End Sub

    Private Function validaFiltri() As Boolean
        Dim ret As Boolean = True

        Try
            'il cognome è obbligatorio.
            '(bisogna inserire almeno due lettere del cognome)
            If String.IsNullOrEmpty(txtCognome.Text) OrElse txtCognome.Text.Length < 2 Then
                Throw New ApplicationException("Specificare almeno due lettere del cognome.")
            End If
        Catch ex As ApplicationException
            ret = False
            'Si è verificato un errore applicativo.
            Master.ShowErrorLabel(ex.Message)
        Catch ex As Exception
            ret = False
            'Si è verificato un errore.
            Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
        End Try

        Return ret
    End Function

    Private Sub GridViewMain_PreRender(sender As Object, e As EventArgs) Handles gvMain.PreRender
        Try
            'Bootstrap SetUp per le gridView
            HelperGridView.SetUpGridView(gvMain, Me.Page)

        Catch ex As Exception
            'Si è verificato un errore.
            Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
        End Try
    End Sub

    Private Sub odsPazienti_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsPazienti.Selected
        Try
            'testo se si è verificato un errore.
            If e.Exception IsNot Nothing Then
                e.ExceptionHandled = True
                'ottengo il messaggio di errore.
                Throw e.Exception
            End If

            'Non si è verificato nessun errore.
            Dim result As WcfSacPazienti.PazientiListaType = CType(e.ReturnValue, WcfSacPazienti.PazientiListaType)
            If result Is Nothing OrElse result.Count = 0 Then
                divEmptyRow.Visible = True
                gvMain.Visible = False
            End If
        Catch ex As Exception
            'Si è verificato un errore.
            '
            'ATTENZIONE:
            'Chiamo il metodo CustomDataSourceException.TrapError(ex) al posto di GestioneErrori.TrapError perchè questa objectdatasource chiama una CustomDataSource
            ' che ottiene i dati da un WCF.
            'iN questo modo trappo anche gli errori generati dal WCF.
            Master.ShowErrorLabel(CustomDataSourceException.TrapError(ex))
        End Try
    End Sub

#Region "Filtri"
    ''' <summary>
    ''' Carica i filtri ottenendo i valori dalla sessione
    ''' </summary>
    Private Sub LoadFilterFromSession()
        Try
            txtCognome.Text = Me.Session(String.Format("{0}_{1}", Me.GetType.Name, txtCognome.ID))
            txtNome.Text = Me.Session(String.Format("{0}_{1}", Me.GetType.Name, txtNome.ID))
            txtAnnoNascita.Text = Me.Session(String.Format("{0}_{1}", Me.GetType.Name, txtAnnoNascita.ID))
            txtCodfisc.Text = Me.Session(String.Format("{0}_{1}", Me.GetType.Name, txtCodfisc.ID))
        Catch ex As Exception
            'Si è verificato un errore.
            Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
        End Try
    End Sub

    ''' <summary>
    ''' Salva i valori dei filtri in sessione
    ''' </summary>
    Private Sub SaveFilterInSession()
        Try
            Me.Session.Add(String.Format("{0}_{1}", Me.GetType.Name, txtCognome.ID), txtCognome.Text)
            Me.Session.Add(String.Format("{0}_{1}", Me.GetType.Name, txtNome.ID), txtNome.Text)
            Me.Session.Add(String.Format("{0}_{1}", Me.GetType.Name, txtAnnoNascita.ID), txtAnnoNascita.Text)
            Me.Session.Add(String.Format("{0}_{1}", Me.GetType.Name, txtCodfisc.ID), txtCodfisc.Text)
        Catch ex As Exception
            'Si è verificato un errore.
            Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
        End Try
    End Sub
#End Region
End Class