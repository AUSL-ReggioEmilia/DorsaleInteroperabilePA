Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin
Imports DI.PortalAdmin.Data

Public Class NoteAnamnesticheDettaglio
    Inherits System.Web.UI.Page

    Public Property IdNotaAnamnestica() As Guid
        Get
            Return Me.ViewState("IdNotaAnamnestica")
        End Get
        Set(ByVal value As Guid)
            Me.ViewState.Add("IdNotaAnamnestica", value)
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            '
            'Verifico se l'id della nota ottenuto dal query string è valorizza e se è un guid valido.
            '
            Dim sIdNota As String = Request.QueryString(Constants.PAR_ID_NOTA_ANAMNESTICA)
            If String.IsNullOrEmpty(sIdNota) OrElse Not Utility.SQLTypes.IsValidGuid(sIdNota) Then
                lblError.Visible = True
                lblError.Text = "Il parametro 'IdNotaAnamnestica' non è un guid valido."
            Else
                Me.IdNotaAnamnestica = New Guid(sIdNota)
            End If

            If Not Page.IsPostBack Then
                '
                '2020-07-07 Kyrylo: Traccia Operazioni
                '
                Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Visualizzata nota anamnestica", idPaziente:=Nothing, Nothing, IdNotaAnamnestica.ToString(), "IdNotaAnamnestica")
            End If

        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub fvNotaAnamnestica_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles fvNotaAnamnestica.ItemCommand
        '
        'Resetto l'attributo src dell'iframe per evitare che venga eseguito il download del contenuto ad ogni postback.
        '
        myIframe.Src = ""
        Try
            If e.CommandName = "ApriContenuto" Then
                '
                'Valorizzo l'attributo src dell'iframe.
                '
                myIframe.Src = String.Format("~/PagesNoteAnamnestiche/DownloadNotaAnamnesticaContenuto.aspx?{0}={1}", Constants.PAR_ID_NOTA_ANAMNESTICA, Me.IdNotaAnamnestica)
                myIframe.DataBind()

            ElseIf e.CommandName = "ApriContenutoHtml" Then
                '
                'Mostro la modale contenente l'HTML del Contenuto.
                '
                Dim title As String = String.Format("Contenuto HTML")
                Dim functionJS As String = "openModal('ContenutoHtmlModal','" + title + "',500,500,false)"
                ScriptManager.RegisterStartupScript(Page, Page.GetType, "OpenModal", functionJS, True)
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

#Region "Object Data Source"
    Private Sub odsNotaAnamnestica_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsNotaAnamnestica.Selected, OdsAttributiNotaAnamnestica.Selected
        '
        ' Gestione degli errri causati dalla query
        '
        GestioneErrori.ObjectDataSource_TrapError(e, lblError)
    End Sub

    Private Sub odsNotaAnamnestica_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsNotaAnamnestica.Selecting, OdsAttributiNotaAnamnestica.Selecting
        '
        'Valorizzo il parametro dell'ObjectDataSouce.
        '
        e.InputParameters("IdNotaAnamnestica") = Me.IdNotaAnamnestica
    End Sub
#End Region


    Protected Function FormatCodiceDescrizione(ByVal oDescrizione As Object, ByVal oCodice As Object) As String
        '
        'restituisce una stringa formata dalla descrizione + codice da mostrare nel markup.
        '
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
            Utility.ShowErrorLabel(lblError, sMessage)
            Return String.Empty
        End Try
    End Function



End Class