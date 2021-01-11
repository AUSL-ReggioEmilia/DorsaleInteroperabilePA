Imports System
Imports System.Data
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin
Imports DI.PortalAdmin.Data

Public Class RicoveriDettaglio
    Inherits System.Web.UI.Page

    Private Const KEY_ID_EVENTO As String = "KEY_ID_EVENTO"

    Private msAziendaErogante As String
    Private msNumeroNosologico As String

    Public Property IdEvento() As String
        Get
            If ViewState(KEY_ID_EVENTO) Is Nothing Then
                Return String.Empty
            Else
                Return ViewState(KEY_ID_EVENTO)
            End If
        End Get
        Set(ByVal value As String)
            ViewState.Add(KEY_ID_EVENTO, value)
        End Set
    End Property
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Try
            '
            'Controllo se IdReferto è un guid valido.
            '
            Dim IdRicovero As String = Request.QueryString("IdRicovero")
            If String.IsNullOrEmpty(IdRicovero) OrElse Not Utility.SQLTypes.IsValidGuid(IdRicovero) Then
                LabelError.Visible = True
                LabelError.Text = "il parametro 'Id Ricovero' non è un guid valido."
            End If

            msAziendaErogante = Request.QueryString("AziendaErogante")
            If String.IsNullOrEmpty(msAziendaErogante) Then
                LabelError.Visible = True
                LabelError.Text = "il parametro 'AziendaErogante' è obbligatorio."
            End If

            msNumeroNosologico = Request.QueryString("NumeroNosologico")
            If String.IsNullOrEmpty(msNumeroNosologico) Then
                LabelError.Text = "il parametro 'NumeroNosologico' è obbligatorio."
            ElseIf Not Page.IsPostBack Then
                '
                '2020-07-07 Kyrylo: Traccia Operazioni
                '
                Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Visualizzato dettaglio ricovero", idPaziente:=Nothing, Nothing, msNumeroNosologico, "Numero nosologico")
            End If

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

    Private Sub EventoAttributiOds_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles EventoAttributiOds.Selected
        '
        ' Gestione degli errri causati dalla query
        '
        GestioneErrori.ObjectDataSource_TrapError(e, LabelError)
    End Sub

    Private Sub EventoAttributiOds_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles EventoAttributiOds.Selecting
        Try
            If String.IsNullOrEmpty(IdEvento) Then
                e.Cancel = True
            End If
            e.InputParameters("IdEvento") = IdEvento
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub gvEventiRicovero_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvEventiRicovero.RowCommand
        Try
            If e.CommandName = "ApriAttributi" Then
                IdEvento = e.CommandArgument.ToString
                gvAttributiEventi.DataBind()
                Dim title As String = String.Format("Attributi evento: {0}", IdEvento)
                Dim functionJS As String = "openModal('attributiModal','" + title + "',500,500,false)"
                ScriptManager.RegisterStartupScript(Page, Page.GetType, "OpenModal", functionJS, True)
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub RicoveroAttributiOds_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles RicoveroAttributiOds.Selected
        '
        ' Gestione degli errri causati dalla query
        '
        If Not GestioneErrori.ObjectDataSource_TrapError(e, LabelError) Then

            '
            'Il div contenente la tabella degli attributi ha una altezza prefissata ed è scrollabile (per evitare di generare una pagina troppo lunga).
            'Se non ci sono attributi elimino l'altezza in modo da non mostrare comunque uno spazio bianco alto 300px.
            '
            Dim eG = CType(e.ReturnValue, DataTable)
            lblAttributiEmpty.Visible = False
            If eG.Rows.Count <= 0 Then
                lblAttributiEmpty.Visible = True
            End If
        End If
    End Sub

    Private Sub RicoveroOds_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles RicoveroOds.Selected
        '
        ' Gestione degli errri causati dalla query
        '
        GestioneErrori.ObjectDataSource_TrapError(e, LabelError)
    End Sub

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


    Protected Sub NavigaLogSOLE()
        Try
            'navigo alla pagina di LOG degli inivi di SOLE.
            Response.Redirect(String.Format("~/Pages/EventiSOLELogInvii.aspx?AziendaErogante={0}&NumeroNosologico={1}", msAziendaErogante, msNumeroNosologico))
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

End Class