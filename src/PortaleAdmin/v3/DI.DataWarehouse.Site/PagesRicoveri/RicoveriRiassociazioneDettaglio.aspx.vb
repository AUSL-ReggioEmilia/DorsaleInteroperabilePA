Imports System
Imports System.Data
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin
Imports DI.PortalAdmin.Data

Public Class RicoveriRiassociazioneDettaglio
    Inherits System.Web.UI.Page

    Const BACKPAGE = "~/PagesRicoveri/RicoveriRiassociazioneLista.aspx"
    Const SACPAZIENTIPAGE = "~/PagesRicoveri/RicoveriRiassociazioneSACPazientiLista.aspx"

    Private msAziendaErogante As String
    Private msNumeroNosologico As String


    Public Property IdRicovero() As Guid?
        Get
            If ViewState("IdRicovero") Is Nothing Then
                Return Nothing
            Else
                Return ViewState("IdRicovero")
            End If
        End Get
        Set(ByVal value As Guid?)
            ViewState.Add("IdRicovero", value)
        End Set
    End Property

    Public Property IdPaziente() As Guid?
        Get
            If ViewState("IdPaziente") Is Nothing Then
                Return Nothing
            Else
                Return ViewState("IdPaziente")
            End If
        End Get
        Set(ByVal value As Guid?)
            ViewState.Add("IdPaziente", value)
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Try
            '
            'Controllo se IdRicovero è un guid valido.
            '
            Dim idRicovero As String = Request.QueryString("IdRicovero")
            If String.IsNullOrEmpty(idRicovero) OrElse Not Utility.SQLTypes.IsValidGuid(idRicovero) Then
                LabelError.Visible = True
                LabelError.Text = "il parametro 'Id Ricovero' non è un guid valido."
            Else
                Me.IdRicovero = New Guid(idRicovero)
            End If

            msAziendaErogante = Request.QueryString("AziendaErogante")
            If String.IsNullOrEmpty(msAziendaErogante) Then
                LabelError.Visible = True
                LabelError.Text = "il parametro 'AziendaErogante' è obbligatorio."
            End If

            msNumeroNosologico = Request.QueryString("NumeroNosologico")
            If String.IsNullOrEmpty(msNumeroNosologico) Then
                LabelError.Text = "il parametro 'NumeroNosologico' è obbligatorio."
            End If

            'IdPaziente è opzionale, ma se c'è deve essere un guid valido.
            If Not String.IsNullOrEmpty(Request.QueryString(Constants.IdPaziente)) Then
                If Not Utility.SQLTypes.IsValidGuid(Request.QueryString(Constants.IdPaziente)) Then
                    LabelError.Text = "Il parametro 'IdPaziente' non è un GUID valido."
                Else
                    Me.IdPaziente = New Guid(Request.QueryString(Constants.IdPaziente))
                End If
            End If

            If Not Page.IsPostBack Then
                '
                '2020-07-03 Kyrylo: Traccia Operazioni
                '
                Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Visualizzato dettaglio ricovero", idPaziente:=Nothing, Nothing, msNumeroNosologico, "Numero nosologico")
            End If

            'Disabilito il pulsante per la riassociazione.
            butAssocia.Enabled = False
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub EventiRicoveroOds_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles EventiRicoveroOds.Selected
        '
        ' Gestione degli errri causati dalla query
        '
        GestioneErrori.ObjectDataSource_TrapError(e, LabelError)
    End Sub

    Private Sub RicoveroOds_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles RicoveroOds.Selected
        '
        ' Gestione degli errri causati dalla query
        '
        GestioneErrori.ObjectDataSource_TrapError(e, LabelError)
    End Sub

    Protected Sub butCerca_Click(sender As Object, e As EventArgs) Handles butCerca.Click
        Try
            Response.Redirect(String.Format("{0}?IdRicovero={1}&AziendaErogante={2}&NumeroNosologico={3}", SACPAZIENTIPAGE, Request.QueryString("IdRicovero"), Request.QueryString("AziendaErogante"), Request.QueryString("NumeroNosologico")))
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    ''' <summary>
    ''' Formatta il codice e la descrizione passate separandoli con un "-"
    ''' </summary>
    ''' <param name="oDescrizione"></param>
    ''' <param name="oCodice"></param>
    ''' <returns></returns>
    Protected Function FormatCodiceDescrizione(ByVal oDescrizione As Object, ByVal oCodice As Object) As String
        Try
            Dim sResult As String = String.Empty
            Dim descrizione As String = String.Empty
            Dim codice As String = String.Empty

            If Not oDescrizione Is DBNull.Value Then
                descrizione = oDescrizione.ToString
            End If

            If Not oCodice Is DBNull.Value Then
                codice = oCodice.ToString
            End If

            If Not String.IsNullOrEmpty(descrizione) AndAlso Not String.IsNullOrEmpty(codice) Then
                sResult = String.Format("{0} - {1}", descrizione, codice)
            ElseIf Not String.IsNullOrEmpty(descrizione) AndAlso String.IsNullOrEmpty(codice) Then
                sResult = String.Format("{0}", descrizione)
            ElseIf String.IsNullOrEmpty(descrizione) AndAlso Not String.IsNullOrEmpty(codice) Then
                sResult = String.Format("({0})", codice)
            End If

            Return sResult
        Catch ex As Exception
            '
            'Non si dovrebbe mai verificare
            '
            Dim sMessage As String = "Si è verificato un errore durante 'FormatCodiceDescrizione'. "
            Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
            Return String.Empty
        End Try
    End Function

    Private Sub odsDettagliSAC_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsDettagliSAC.Selecting
        Try
            'Se l'id Paziente è vuoto allora cancello la query.
            If String.IsNullOrEmpty(Request.QueryString(Constants.IdPaziente)) Then
                e.Cancel = True
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub


    Private Sub butAssocia_Click(sender As Object, e As EventArgs) Handles butAssocia.Click
        Try

            'Si occupa di riassociare e di rinotificare il ricovero
            Using ta As New RicoveriDataSetTableAdapters.QueriesTableAdapter
                ta.BeRicoveriRiassociazioneAggiorna(Me.IdRicovero.Value, Me.IdPaziente.Value)
            End Using

            fvRicovero.DataBind()
            gvEventiRicovero.DataBind()

        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub odsDettagliSAC_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDettagliSAC.Selected
        Try
            '
            ' Gestione degli errri causati dalla query
            '
            If Not GestioneErrori.ObjectDataSource_TrapError(e, LabelError) Then
                Dim dt As DataTable = e.ReturnValue
                If dt.Rows.Count = 1 Then
                    butAssocia.Enabled = True
                End If
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub
End Class