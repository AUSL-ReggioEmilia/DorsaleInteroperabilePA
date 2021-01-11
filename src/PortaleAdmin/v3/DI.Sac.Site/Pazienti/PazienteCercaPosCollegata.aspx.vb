Imports DI.Common
Imports DI.Sac.Admin
Imports System.Web.UI.HtmlControls
Imports System.Web.UI.WebControls
Imports System
Imports System.Diagnostics
Imports DI.Sac.Admin.Data.PazientiDataSetTableAdapters
Imports DI.Sac.Admin.Data.PazientiDataSet
Imports System.Reflection
Imports System.Web.UI
Imports System.Web
Imports DI.PortalAdmin.Data
'
' Per accedere a questa pagina l'utente deve avere il ruolo ROLE_PAZIENTI_READ_POS_COLLEGATA
' La pagina verifica se l'utente ha i permessi per cercare una posizione collegata
' Al primo ingresso la pagina mostra solo il pannello dei filtri
'
Public Class PazienteCercaPosCollegata
    Inherits System.Web.UI.Page

    '
    ' Controlli da ricercare nella pagina master
    '
    Private formMaster As HtmlForm

    Private Const FORMVIEW_MESSAGE_DATI_NON_TROVATI As String = "Dati non disponibili!"

    Private Shared ReadOnly _className As String = MethodBase.GetCurrentMethod().ReflectedType.Name

    Private mbObjectDataOurce_CancelSelect As Boolean = False
    Private ReadOnly mbCanReadPosCollegata As Boolean = User.IsInRole(TypeRoles.ROLE_PAZIENTI_READ_POS_COLLEGATA.ToString())


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            If Not IsPostBack Then
                'La prima volta non eseguo la select se codice manca
                mbObjectDataOurce_CancelSelect = True
                'La prima volta non mostro messaggio
                MainFormView.EmptyDataText = String.Empty
                '
                ' Verifico i diritti utente
                '
                If Not mbCanReadPosCollegata Then
                    MainTable.Visible = False
                    LabelError.Visible = True
                    LabelError.Text = "L'utente non ha i diritti per accedere alla pagina."
                    Exit Sub
                End If
                '
                ' Riscrivo il valore presente in sessione
                '
                FilterHelper.Restore(pannelloFiltri, _className)
                '
                ' Default Focus/Button            
                '
                If Master.TryFindControl(Of HtmlForm)("form1", formMaster) Then
                    formMaster.DefaultFocus = txtFiltroPosCollegata.ClientID
                    formMaster.DefaultButton = btnRicercaButton.UniqueID
                End If
            Else
                MainFormView.EmptyDataText = FORMVIEW_MESSAGE_DATI_NON_TROVATI
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
            ' In caso di errore NON FA eseguire la select all'object data source
            mbObjectDataOurce_CancelSelect = True
        End Try

    End Sub

    Protected Sub btnRicercaButton_Click(sender As Object, e As EventArgs) Handles btnRicercaButton.Click
        Try
            '
            ' Leggo il valore del filtro impostato dall'utente
            '
            Dim sIdPosizioneCollegata As String = txtFiltroPosCollegata.Text
            '
            ' Verifico che sia stato impostato il il codice di anonimizzazione
            '
            If String.IsNullOrEmpty(sIdPosizioneCollegata) Then
                LabelError.Visible = True
                LabelError.Text = "Impostare il codice della posizione collegata."
                mbObjectDataOurce_CancelSelect = True
                Exit Sub
            End If
            '
            ' Salvo in sessione 
            '
            FilterHelper.SaveInSession(pannelloFiltri, _className)
            '
            ' Imposto ilfiltro per la select
            '
            MainObjectDataSource.SelectParameters("IdPosizioneCollegata").DefaultValue = sIdPosizioneCollegata
            '
            ' Cancello cache
            ' HttpContext.Current.Cache("CKD_MainObjectDataSource_Pos_Collegate") = New Object
            '
            '
            ' Viene chiamato il Bind in automatica
            '


            '
            '2020-07-02 Kyrylo: Traccia Operazioni
            '
            Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
            oTracciaOp.TracciaOperazione(PortalsNames.Sac, Page.AppRelativeVirtualPath, "Ricerca posizione anonimizzazione", pannelloFiltri, Nothing)

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
            ' In caso di errore NON FA eseguire la select all'object data source
            mbObjectDataOurce_CancelSelect = True
        End Try
    End Sub

#Region "Object data source"

    Private Sub MainObjectDataSource_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles MainObjectDataSource.Selected
        Try
            If e.Exception IsNot Nothing Then
                Dim ex As Exception = e.Exception.InnerException
                If ex Is Nothing Then ex = e.Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
                e.ExceptionHandled = True
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub

    Private Sub MainObjectDataSource_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles MainObjectDataSource.Selecting
        Try
            e.Cancel = mbObjectDataOurce_CancelSelect
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub

#End Region

End Class