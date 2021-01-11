Imports System
Imports System.Data
Imports System.Web.UI.WebControls

Public Class RuoliCopiaDaSistema
    Inherits System.Web.UI.Page

    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

    '
    'Conservo new view state l'url per tornare alla pagina precedente.
    '
    Private Property BackUrl() As String
        Get
            Return CType(ViewState("_BACKURL_"), String)
        End Get
        Set(ByVal value As String)
            ViewState.Add("_BACKURL_", value)
        End Set
    End Property

    Public Property idSistemaProvenienza() As String
        Get
            Return ViewState("_VIEWSTATEPROVENIENZA_")
        End Get
        Set(ByVal value As String)
            ViewState.Add("_VIEWSTATEPROVENIENZA_", value)
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            If Not Page.IsPostBack Then

                '
                'Salvo il back url per tornare alla pagina precedente.
                '
                BackUrl = Request.UrlReferrer.AbsoluteUri

                '
                'Controllo che l'id passato nell'url sia un guid valido.
                '
                If Utility.IsValidGuid(Request.QueryString("Id")) Then
                    Me.idSistemaProvenienza = Request.QueryString("Id")
                    LabelError.Text = ""
                Else
                    LabelError.Text = "I parametri non sono valorizzati correttamente."
                End If

                '
                'Ricarico il pannello dei filtri prendendolo dalla sessione.
                '
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

    Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
        GestioneErrori.ObjectDataSource_TrapError(e, LabelError)
    End Sub

    Protected Sub butAnnulla_Click(sender As Object, e As EventArgs) Handles butAnnulla.Click, butAnnullaTop.Click
        Try
            '
            'Torno alla pagina di dettaglio del referto.
            '
            Response.Redirect(BackUrl, False)
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub butAggiungiTop_Click(sender As Object, e As EventArgs) Handles butAggiungiTop.Click, butAggiungi.Click
        Try
            '
            'Ciclo ogni riga della gridview gvLista
            '
            For Each row As GridViewRow In gvLista.Rows
                '
                'Ottengo la checkbox.
                '
                Dim chkItem As CheckBox = row.FindControl("gvCheckList")

                '
                'Controllo se la checkbox è checked.
                '
                If Not chkItem Is Nothing AndAlso chkItem.Checked Then
                    Dim RuoliDelSistema As OrganigrammaDataSet.RuoliCercaPerSistemaDataTable

                    '
                    'Se la checkbox è checked allora ottengo l'id del sistema di cui vogliamo copiare i ruoli.
                    '
                    Dim idSistema As String = gvLista.DataKeys(row.RowIndex).Values("Id").ToString

                    '
                    'Ottengo la lista dei ruoli associati a IdSistema.
                    '
                    Using ta As New OrganigrammaDataSetTableAdapters.RuoliCercaPerSistemaTableAdapter
                        RuoliDelSistema = ta.GetData(New Guid(idSistema), Nothing, Nothing, Nothing)
                    End Using

                    '
                    'Se la lista dei ruoli non è vuota allora ciclo ogni ruolo nella lista, ne ottengo l'id.
                    '
                    If Not RuoliDelSistema Is Nothing AndAlso RuoliDelSistema.Rows.Count > 0 Then
                        For Each riga As OrganigrammaDataSet.RuoliCercaPerSistemaRow In RuoliDelSistema.Rows
                            Dim idRuolo As Guid = riga.IDRuolo

                            '
                            'Associo il ruolo all'sistema
                            '
                            Using ta As New OrganigrammaDataSetTableAdapters.RuoliCercaPerSistemaTableAdapter
                                ta.Insert(User.Identity.Name, idRuolo, New Guid(Me.idSistemaProvenienza))
                            End Using
                        Next
                    End If

                    '
                    'Si può selezionare solo un item alla volta, quindi non ciclo tutta la griglia se è già stato fatto l'insert.
                    '
                    Exit For
                End If
            Next
            GoBack()
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub


    Private Sub GoBack()
        Try
            Response.Redirect(Me.BackUrl, False)
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub butFiltriRicerca_Click(sender As Object, e As EventArgs) Handles butFiltriRicerca.Click
        hdnCheckedCount.Value = 0
        FilterHelper.SaveInSession(pannelloFiltri, msPAGEKEY)
        Cache.Remove(odsLista.CacheKeyDependency)
    End Sub
End Class