Imports System
Imports System.Web.UI.WebControls
Imports System.Data
Imports System.Collections.Generic
Imports System.Collections

Public Class OscuramentiLista
    Inherits System.Web.UI.Page

#Region "VARIABILI DI PAGINA"
    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

    'LISTA DEI TIPI DI OSCURAMENTI DI SISTEMA
    Private OSC_DISISTEMA As Byte() = {0}

    'LISTA DEI TIPI DI OSCURAMENTI MASSIVI
    Private OSC_MASSIVI As Byte() = {2, 6, 7, 8, 10}

    'LISTA DEI TIPI DI OSCURAMENTI PUNTUALI
    Private OSC_PUNTUALI As Byte() = {1, 3, 4, 5, 9}

    'Private ReadOnly TIPIOSC_BYPASSABILI As String = "0,2, 6, 7, 8, 10"
    Private ReadOnly TIPIOSC_BYPASSABILI As Byte() = {0, 2, 6, 7, 8, 10}
#End Region

    Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        Try
            Page.Form.DefaultButton = butFiltriRicerca.UniqueID

            If Not Page.IsPostBack Then
                FilterHelper.Restore(pannelloFiltri, msPAGEKEY)
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
        Try
            If Not Page.IsPostBack Then

                FilterHelper.Restore(ddlFiltriAzienda, msPAGEKEY)
                ' SE AVEVO IMPOSTATO UN FILTRO NELLA DROPDOWN FORZO UN DATABIND 
                ' CHE ALTRIMENTI NON SCATTEREBBE IN AUTOMATICO
                If ddlFiltriAzienda.SelectedValue.Length > 0 Then
                    gvLista.DataBind()
                End If
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Protected Sub RicercaButton_Click(sender As Object, e As EventArgs) Handles butFiltriRicerca.Click
        Try
            LabelError.Visible = False

            FilterHelper.SaveInSession(pannelloFiltri, msPAGEKEY)
            'Cache.Remove(odsLista.CacheKeyDependency)
            gvLista.PageIndex = 0

            gvLista.DataBind()

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try

    End Sub

    Private Function StringFormat(format As String, [default] As String, ParamArray values() As Object) As String
        For Each value In values
            If value Is Nothing OrElse value Is DBNull.Value Then Return [default]
        Next

        Return String.Format(format, values)
    End Function

    Private Sub NewButton_Click(sender As Object, e As System.EventArgs) Handles NewButton.Click
        Response.Redirect(Me.ResolveUrl("OscuramentiDettaglio.aspx"), False)
    End Sub

    Private Sub odsLista_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
        Try
            'Gestione del top 1000 della griglia.
            'Se il count dei record mostrati è 1000 allora mostro una label di avveritmento.
            If e.Exception Is Nothing Then
                'Ottengo il parametro "Top" dell'Ods (settato di default a 1000).
                Dim gvTop As Integer = CInt(odsLista.SelectParameters.Item("Top").DefaultValue)
                'Ottengo la DataTable.
                Dim eG = CType(e.ReturnValue, DataTable)
                'Se il count delle row è uguale a gvTop(1000) allora mostro la label.
                If eG.Rows.Count = gvTop Then
                    lblGvLista.Visible = True

                    'Label mostrata solo nel caso in cui vengono mostrati 1000 record nella griglia.
                    Dim lblText As String = String.Format("Sono stati mostrati solo i primi {0} record perchè la ricerca ha prodotto più di {0} risultati.", gvTop)
                    lblGvLista.Text = lblText
                Else
                    'Nascondo la label.
                    lblGvLista.Visible = False
                End If
            Else
                'Trappo gli errori.
                ObjectDataSource_TrapError(sender, e)
                lblGvLista.Visible = False
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

#Region "Funzioni"

    ''' <summary>
    ''' Gestisce gli errori del ObjectDataSource in maniera pulita
    ''' </summary>
    ''' <returns>True se si è verificato un errore</returns>
    Private Function ObjectDataSource_TrapError(ods As ObjectDataSourceView, e As ObjectDataSourceStatusEventArgs) As Boolean
        Try
            If e.Exception IsNot Nothing AndAlso e.Exception.InnerException IsNot Nothing Then
                Utility.ShowErrorLabel(LabelError, GestioneErrori.TrapError(e.Exception.InnerException))
                e.ExceptionHandled = True
                Return True
            Else
                Return False
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
            Return True
        End Try

    End Function

#End Region

#Region "FUNZIONI MARKUP"

    ''' <summary>
    ''' OTTIENE LA DESCRIZIONE DEL TIPO DI OSCURAMENTO (MASSIVO/PUNTUALE/DISISTEMA)
    ''' </summary>
    ''' <param name="TipoOscuramento"></param>
    ''' <returns></returns>
    Protected Function GetCategoriaOscuramento(TipoOscuramento) As String
        If Array.IndexOf(OSC_DISISTEMA, TipoOscuramento) <> -1 Then
            Return "Di Sistema"
        ElseIf Array.IndexOf(OSC_MASSIVI, TipoOscuramento) <> -1 Then
            Return "Massivo"
        ElseIf Array.IndexOf(OSC_PUNTUALI, TipoOscuramento) <> -1 Then
            Return "Puntuale"
        Else
            Return "TipoOscuramento" & TipoOscuramento.ToString & " non riconosciuto."
        End If

    End Function

    ''' <summary>
    ''' OTTIENE LA LISTA DEI RUOLI CHE POSSONO BYPASSARE L'OSCURAMENTO.
    ''' </summary>
    ''' <param name="TipoOscuramento"></param>
    ''' <param name="Ruoli"></param>
    ''' <returns></returns>
    Protected Function GetTestoRuoli(TipoOscuramento, Ruoli) As String

        'solo i tipi oscuramento di sistema e massivi sono bypassabili
        If IsOscuramentoBypassabile(TipoOscuramento) Then
            Return Ruoli
        Else
            Return "(Non Bypassabile)"
        End If

    End Function

    ''' <summary>
    ''' RESTITUISCE SE L'OSCURAMENTO E' BYPASSABILE
    ''' </summary>
    ''' <param name="TipoOscuramento"></param>
    ''' <returns></returns>
    Protected Function IsOscuramentoBypassabile(TipoOscuramento) As String

        'solo i tipi oscuramento di sistema e massivi sono bypassabili
        'If TIPIOSC_BYPASSABILI.Contains(TipoOscuramento.ToString) Then
        '    Return True
        'Else
        '    Return False
        'End If

        If Array.IndexOf(TIPIOSC_BYPASSABILI, TipoOscuramento) <> -1 Then
            Return True
        Else
            Return False
        End If


    End Function

    ''' <summary>
    ''' OTTIENE LA DESCRIZIONE DELL'OSCURAMENTO
    ''' </summary>
    ''' <param name="RowView"></param>
    ''' <returns></returns>
    Protected Function GetDescrizioneRow(RowView As System.Data.DataRowView) As String

        Dim oRow As DataRow = RowView.Row
        Dim BR As String = "<br />"

        Select Case CType(oRow("TipoOscuramento"), Byte)

            Case 0 ' Oscuramento di sistema
                Return ""

            Case 1 ' azienda erogante & nosologico
                Return StringFormat("Azienda Erogante: {0}", "", oRow("AziendaErogante")) & StringFormat(BR & "Numero Nosologico: {0}", "", oRow("NumeroNosologico"))

            Case 2 ' reparto richiedente (& sistema) (& azienda)
                Return StringFormat("Reparto Richiedente: {0}", "", oRow("RepartoRichiedenteCodice")) & StringFormat("{0}Sistema Erogante: {1}", "", BR, oRow("SistemaErogante")) &
                 StringFormat("{0}Azienda Erogante: {1}", "", BR, oRow("AziendaErogante"))

            Case 3 ' Numero Referto (& sistema) (& azienda)
                Return StringFormat("Numero Referto: {0}", "", oRow("NumeroReferto")) & StringFormat("{0}Sistema Erogante: {1}", "", BR, oRow("SistemaErogante")) &
                 StringFormat("{0}Azienda Erogante: {1}", "", BR, oRow("AziendaErogante"))

            Case 4 ' Numero Prenotazione (& sistema) (& azienda)
                Return StringFormat("Numero Prenotazione: {0}", "", oRow("NumeroPrenotazione")) & StringFormat("{0}Sistema Erogante: {1}", "", BR, oRow("SistemaErogante")) &
                 StringFormat("{0}Azienda Erogante: {1}", "", BR, oRow("AziendaErogante"))

            Case 5 ' id order entry (& sistema) (& azienda)
                Return StringFormat("Id Order Entry: {0}", "", oRow("IdOrderEntry")) & StringFormat("{0}Sistema Erogante: {1}", "", BR, oRow("SistemaErogante")) &
                 StringFormat("{0}Azienda Erogante: {1}", "", BR, oRow("AziendaErogante"))

            Case 6 ' azienda & sistema & reparto (& struttura) eroganti
                Return StringFormat("Sistema Erogante: {0}", "", oRow("SistemaErogante")) & StringFormat("{0}Azienda Erogante: {1}", "", BR, oRow("AziendaErogante")) &
                 StringFormat(BR & "Reparto Erogante: {0}", "", oRow("RepartoErogante")) & StringFormat(BR & "Struttura Erogante Codice: {0}", "", oRow("StrutturaEroganteCodice"))

            Case 7 ' Codice Rep. Ricovero & ADT & Azienda
                Return StringFormat("Reparto Di Ricovero: {0}", "", oRow("RepartoRichiedenteCodice")) & StringFormat("{0}Sistema Erogante: {1}", "", BR, oRow("SistemaErogante")) &
                 StringFormat("{0}Azienda Erogante: {1}", "", BR, oRow("AziendaErogante"))

            Case 8 ' Parola per Referti
                Return StringFormat("Parola per Referti: {0}", "", oRow("Parola"))

            Case 9 ' IdEsternoReferto
                Return StringFormat("IdEsterno: {0}", "", oRow("IdEsternoReferto"))

            Case 10 ' Parola per Evento/Ricovero
                Return StringFormat("Parola per Eventi/Ricoveri: {0}", "", oRow("Parola"))

            Case Else
                Return "TipoOscuramento " & oRow("TipoOscuramento").ToString & " non riconosciuto"
        End Select

    End Function

    ''' <summary>
    ''' Restituisce lo stato dell'oscuramento (Non completato/completato)
    ''' </summary>
    ''' <param name="oRowView"></param>
    ''' <returns></returns>
    Protected Function GetStatoOscuramento(ByVal oRowView As DataRowView)
        Dim sReturn As String = String.Empty

        'Testo se l'oggetto è vuoto
        If oRowView IsNot Nothing AndAlso oRowView.Row IsNot Nothing Then
            'Ottengo la row
            Dim oRow As DataRow = oRowView.Row

            'Se lo stato è "inserito" nella griglia mostro "NON COMPLETATO" in modo che sia più chiaro all'utente lo stato di 
            '   avanzamento della creazione dell'ordine
            If oRow("Stato").ToString().ToUpper = "INSERITO" Then
                sReturn = "NON COMPLETATO"
            Else
                sReturn = oRow("Stato")
            End If
        End If

        Return sReturn
    End Function

#End Region

    Private Sub gvLista_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvLista.RowDataBound
        Try
            If e.Row.RowType = DataControlRowType.DataRow Then
                Dim rw As DataRowView = e.Row.DataItem
                Dim oRow As OscuramentiDataSet.OscuramentiListaRow = rw.Row
                'SE OROW.STATO <> NOTHING ED È MODIFICATO O INSERITO ALLORA MOSTRO IL REFERTO COME INATTIVO.
                If Not String.IsNullOrEmpty(oRow.Stato) AndAlso Not Array.IndexOf(Utility.OscuramentiStatiInattivi, oRow.Stato) = -1 Then
                    e.Row.CssClass = "oscuramento-inattivo"
                End If
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub odsLista_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsLista.Selecting
        Try
            'PASSO IL FILTRO STATO
            Dim sStato As String = Nothing
            If Not String.IsNullOrEmpty(ddlStato.SelectedValue) Then
                sStato = ddlStato.SelectedValue
            End If
            e.InputParameters("Stato") = sStato
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub gvLista_PreRender(sender As Object, e As EventArgs) Handles gvLista.PreRender
        Try
            '4 -> COLONNA STATO
            gvLista.Columns(4).Visible = My.Settings.OscPuntuali_RinotificaSole
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub OscuramentiLista_PreRender(sender As Object, e As EventArgs) Handles Me.PreRender
        Try
            tdStato.Visible = My.Settings.OscPuntuali_RinotificaSole
            trStato.Visible = My.Settings.OscPuntuali_RinotificaSole
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

End Class