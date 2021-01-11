Imports System
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin
'
' LA PAGINA NON VA PIU' IN INSERIMENTO PERCHE' I SISTEMI VENGONO SINCRONIZZATI DA SAC->DWH TRAMITE UN JOB
'
Public Class SistemiErogantiDettaglio
    Inherits System.Web.UI.Page

    Private Const BACKPAGE As String = "SistemiErogantiLista.aspx"

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Request.QueryString(Constants.Id) Is Nothing Then
            '
            ' PASSO IN MODALITÀ INSERIMENTO (NON USATA i record arrivano dal SAC)
            '
            'FormViewDettaglio.ChangeMode(FormViewMode.Insert)
            'labelTitolo.Text = "Inserimento Sistema Erogante"
        Else
            labelTitolo.Text = "Dettaglio Sistema Erogante"
            FormViewDettaglio.ChangeMode(FormViewMode.Edit)
        End If
    End Sub

    Protected Sub FormViewDettaglio_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles FormViewDettaglio.ItemCommand
        Try
            Select Case e.CommandName.ToUpper
                Case "CANCEL"
                    Response.Redirect(BACKPAGE, False)
            End Select

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    'Private Sub FormViewDettaglio_ItemInserted(sender As Object, e As FormViewInsertedEventArgs) Handles FormViewDettaglio.ItemInserted
    '    e.KeepInInsertMode = True
    'End Sub

    Private Sub FormViewDettaglio_ItemUpdated(sender As Object, e As FormViewUpdatedEventArgs) Handles FormViewDettaglio.ItemUpdated
        e.KeepInEditMode = True
    End Sub

    Private Sub SistemiErogantiOds_HaSalvato(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles SistemiErogantiOds.Updated, SistemiErogantiOds.Deleted, SistemiErogantiOds.Inserted
        If Not GestioneErrori.ObjectDataSource_TrapError(e, LabelError) Then
            Response.Redirect(BACKPAGE, False)
        End If
    End Sub

    Private Sub FormViewDettaglio_ItemUpdating(sender As Object, e As FormViewUpdateEventArgs) Handles FormViewDettaglio.ItemUpdating
        Try
            'MODIFICA ETTORE 2017-03-01: non controllo che almeno uno dei due chekbox sia selezionato
            'Dim fvSistemiEroganti As FormView = CType(sender, FormView)
            'Dim checkTipoReferti As CheckBox = CType(fvSistemiEroganti.FindControl("TipoRefertiCheckBox"), CheckBox)
            'Dim checkTipoRicoveri As CheckBox = CType(fvSistemiEroganti.FindControl("TipoRicoveriCheckBox"), CheckBox)
            'Dim checkTipoNoteAnamnestiche As CheckBox = CType(fvSistemiEroganti.FindControl("TipoNoteAnamnesticheCheckBox"), CheckBox)


            'If checkTipoReferti.Checked = False And checkTipoRicoveri.Checked = False And checkTipoNoteAnamnestiche.Checked = False Then
            '    Throw New ApplicationException("Almeno uno dei campi TipoReferti, TipoRicoveri, TipoNoteAnamnestiche deve essere selezionato.")
            'End If
        Catch ex As ApplicationException
            e.Cancel = True
            LabelError.Text = ex.Message
            LabelError.Visible = True
        Catch ex As Exception
            e.Cancel = True
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    'MODIFICA ETTORE 2017-03-01: non si va in inserimento
    'Private Sub FormViewDettaglio_ItemInserting(sender As Object, e As FormViewInsertEventArgs) Handles FormViewDettaglio.ItemInserting
    '    Try
    '        Dim fvSistemiEroganti As FormView = CType(sender, FormView)
    '        Dim checkTipoReferti As CheckBox = CType(fvSistemiEroganti.FindControl("TipoRefertiCheckBox"), CheckBox)
    '        Dim checkTipoRicoveri As CheckBox = CType(fvSistemiEroganti.FindControl("TipoRicoveriCheckBox"), CheckBox)
    '        Dim checkTipoNoteAnamnestiche As CheckBox = CType(fvSistemiEroganti.FindControl("TipoNoteAnamnesticheCheckBox"), CheckBox)

    '        If checkTipoReferti.Checked = False And checkTipoRicoveri.Checked = False And checkTipoNoteAnamnestiche.Checked = False Then
    '            Throw New ApplicationException("Almeno uno dei campi TipoReferti, TipoRicoveri, TipoNoteAnamnestiche deve essere selezionato.")
    '        End If
    '    Catch ex As ApplicationException
    '        e.Cancel = True
    '        LabelError.Text = ex.Message
    '        LabelError.Visible = True
    '    Catch ex As Exception
    '        e.Cancel = True
    '        Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
    '        Utility.ShowErrorLabel(LabelError, sErrorMessage)
    '    End Try
    'End Sub

End Class