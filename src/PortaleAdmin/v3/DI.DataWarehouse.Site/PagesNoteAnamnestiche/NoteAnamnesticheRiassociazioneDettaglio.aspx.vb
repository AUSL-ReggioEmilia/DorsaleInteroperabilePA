Imports System
Imports System.Data
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin
Imports DI.PortalAdmin.Data

Public Class NoteAnamnesticheRiassociazioneDettaglio
    Inherits System.Web.UI.Page

#Region "Property"
    Public Property IdNotaAnamnestica() As Guid
        Get
            Return Me.ViewState("IdNotaAnamnestica")
        End Get
        Set(ByVal value As Guid)
            Me.ViewState.Add("IdNotaAnamnestica", value)
        End Set
    End Property

    Public Property IdPaziente() As Nullable(Of Guid)
        Get
            Return Me.ViewState("IdPaziente")
        End Get
        Set(ByVal value As Nullable(Of Guid))
            Me.ViewState.Add("IdPaziente", value)
        End Set
    End Property
#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            '
            'Verifico se l'id della nota ottenuto dal query string è valorizza e se è un guid valido.
            '
            Dim sIdNota As String = Request.QueryString(Constants.PAR_ID_NOTA_ANAMNESTICA)
            If String.IsNullOrEmpty(sIdNota) OrElse Not Utility.SQLTypes.IsValidGuid(sIdNota) Then
                lblError.Visible = True
                lblError.Text = "Il parametro 'Id Nota Anamnestica' non è un guid valido."
            Else
                Me.IdNotaAnamnestica = New Guid(sIdNota)
            End If

            '
            'Recupero l'id del paziente: valorizzato nella pagina RefertiRiassociazioneSACPazientiLista.aspx
            '
            Dim sIdPaziente As String = Request.QueryString(Constants.IdPaziente)
            If Utility.SQLTypes.IsValidGuid(sIdPaziente) Then
                '
                'Se è un guid valido lo salvo nel view state.
                '
                Me.IdPaziente = New Guid(sIdPaziente)
            Else
                '
                'Se non è un guid valido allora lo imposto con Nothing.
                '
                Me.IdPaziente = Nothing
            End If

            If Not Page.IsPostBack Then
                '
                '2020-07-07 Kyrylo: Traccia Operazioni
                '
                Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Visualizzazione nota anamnestica", idPaziente:=Nothing, Nothing, IdNotaAnamnestica.ToString(), "IdNotaAnamnestica")
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
                'Valorizzo l'attributo src dell'iframe (permette il download della nota anamnestica)
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
    Private Sub odsNotaAnamnestica_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsNotaAnamnestica.Selected
        '
        ' Gestione degli errri causati dalla query
        '
        GestioneErrori.ObjectDataSource_TrapError(e, lblError)
    End Sub

    Private Sub odsNotaAnamnestica_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsNotaAnamnestica.Selecting
        '
        'Valorizzo il parametro dell'ObjectDataSouce.
        '
        e.InputParameters("IdNotaAnamnestica") = Me.IdNotaAnamnestica
    End Sub

    Private Sub odsDettagliSAC_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles odsDettagliSAC.Selecting
        Try
            '
            'Non carico dal sac i dati del paziente nullo
            '
            If Me.IdPaziente Is Nothing OrElse Me.IdPaziente.ToString = Constants.SAC_IdPazienteNullo Then
                e.Cancel = True
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub odsDettagliSAC_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettagliSAC.Selected
        Try
            If Not GestioneErrori.ObjectDataSource_TrapError(e, lblError) Then
                '
                'Se non si sono verificati errori ed è stato trovato un paziente allora abilito il pulsante "Associa".
                '
                Dim dt As DataTable = e.ReturnValue
                If dt.Rows.Count = 1 Then
                    btnAssocia.Enabled = True
                End If
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub odsNotaAnamnestica_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles odsNotaAnamnestica.Updating
        Try
            e.InputParameters(Constants.PAR_ID_NOTA_ANAMNESTICA) = Me.IdNotaAnamnestica
            e.InputParameters("IdPaziente") = Me.IdPaziente
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub odsNotaAnamnestica_Updated(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsNotaAnamnestica.Updated
        '
        ' Gestione degli errri causati dalla query
        '
        If Not GestioneErrori.ObjectDataSource_TrapError(e, lblError) Then
            '
            'Se la modifica è avvenuta correttamente torno alla pagina di lista.
            '
            GoBack()
        End If
    End Sub
#End Region

#Region "Eventi_Bottoni"
    Protected Sub btnAnnulla_Click(sender As Object, e As EventArgs) Handles btnAnnulla.Click
        GoBack()
    End Sub

    ''' <summary>
    ''' Funzione che torna alla pagina di lista.
    ''' </summary>
    Private Sub GoBack()
        Try
            Response.Redirect("~/PagesNoteAnamnestiche/NoteAnamnesticheRiassociazioneLista.aspx", True)
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub btnCerca_Click(sender As Object, e As EventArgs) Handles btnCerca.Click
        Try
            '
            'Navigo alla pagina di ricerca dei pazienti.
            '
            Response.Redirect(String.Format("~/PagesNoteAnamnestiche/NoteAnamnesticheRiassociazionePazientiLista.aspx?{0}={1}", Constants.PAR_ID_NOTA_ANAMNESTICA, Me.IdNotaAnamnestica))
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub btnAssocia_Click(sender As Object, e As EventArgs) Handles btnAssocia.Click
        Try
            odsNotaAnamnestica.Update()
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

#End Region

End Class