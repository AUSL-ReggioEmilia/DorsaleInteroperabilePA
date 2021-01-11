Imports System
Imports System.Web.UI.WebControls
Imports OrganigrammaDataSetTableAdapters

Public Class SistemaRuoloListaaspx
    Inherits System.Web.UI.Page

    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
    Private Const BACKPAGE As String = "SistemiDettaglio.aspx"
    Private Const KEY_DESCRUOLO As String = "DescSistema"

    Private Property IdSistema() As String
        Get
            Return ViewState("IdSistema")
        End Get
        Set(ByVal value As String)
            ViewState("IdSistema") = value
        End Set
    End Property

    Private Property mbModalitàInserimento() As Boolean
        Get
            Return ViewState("mbModalitàInserimento")
        End Get
        Set(ByVal value As Boolean)
            ViewState("mbModalitàInserimento") = value
        End Set
    End Property

    Private Sub Page_PreInit(sender As Object, e As System.EventArgs) Handles Me.PreInit
        '
        ' NEL PREINIT PULISCO LA CACHE DEL OBJECTDATASOURCE
        '
        If Not Page.IsPostBack Then
            '
            ' ALL'AVVIO LA PAGINA VIENE MOSTRATA IN MODALITA' LISTA
            '
            mbModalitàInserimento = False
            Cache.Remove("CacheSistemaRuoli")
        End If

    End Sub

    Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
        Try
            'msIDSistema = Request.QueryString("IdSistema")

            If Not Page.IsPostBack Then
                IdSistema = Request.QueryString("IdSistema")


                Using ta As New SistemiTableAdapter()
                    Using dt As OrganigrammaDataSet.SistemiDataTable = ta.GetDataById(New Guid(IdSistema))
                        If dt.Rows.Count = 1 Then
                            Dim dr As OrganigrammaDataSet.SistemiRow = dt.Rows(0)
                            ViewState.Add(KEY_DESCRUOLO, dr.Codice & " - " & dr.Descrizione)
                        Else
                            Utility.ShowErrorLabel(LabelError, "Sistema " & IdSistema & " non trovato!")
                        End If
                    End Using
                End Using
            End If

            If mbModalitàInserimento Then
                lblTitolo.Text = "Associazione dei Ruoli al Sistema: " & ViewState(KEY_DESCRUOLO)
            Else
                lblTitolo.Text = "Ruoli associati al Sistema: " & ViewState(KEY_DESCRUOLO)
            End If

            'mostro / nascondo i pulsanti
            butConfermaTop.Visible = mbModalitàInserimento
            butEliminaTop.Visible = Not mbModalitàInserimento
            butAggiungiTop.Visible = Not mbModalitàInserimento
            butConferma.Visible = mbModalitàInserimento
            butElimina.Visible = Not mbModalitàInserimento
            butAggiungi.Visible = Not mbModalitàInserimento
            'mostro la colonna 'imposta ruoli' solo in modalità lista
            'gvLista.Columns(1).Visible = Not mbModalitàInserimento

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub


    Protected Sub RicercaButton_Click(sender As Object, e As EventArgs) Handles butFiltriRicerca.Click

        Try
            LabelError.Visible = False
            If ValidazioneFiltri() Then
                'FilterHelper.SaveInSession(pannelloFiltri, msPAGEKEY)
                Cache.Remove(odsRuoli.CacheKeyDependency)
                gvLista.PageIndex = 0
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try

    End Sub

    Private Sub odsLista_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsRuoli.Selected
        ObjectDataSource_TrapError(sender, e)
    End Sub

    Private Sub odsLista_Deleted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsRuoli.Deleted
        ObjectDataSource_TrapError(sender, e)
    End Sub

    Private Sub odsLista_Inserted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsRuoli.Inserted
        ObjectDataSource_TrapError(sender, e)
    End Sub

    Private Sub odsLista_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsRuoli.Selecting
        Try

            If mbModalitàInserimento Then
                '@IdRuolo=NULL fa caricare la lista completa dei sistemi
                e.InputParameters("IdSistema") = Nothing
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Protected Function ValidazioneFiltri() As Boolean

        'nulla da validare
        Return True

    End Function

    Protected Sub butAnnulla_Click(sender As Object, e As EventArgs) Handles butAnnulla.Click, butAnnullaTop.Click

        If mbModalitàInserimento Then
            '
            ' PASSO ALLA MODALITA' LISTA
            '
            mbModalitàInserimento = False
            Cache.Remove(odsRuoli.CacheKeyDependency)
            txtFiltriCodice.Text = ""
            txtFiltriDescrizione.Text = ""
            gvLista.DataBind()
        Else
            ' BACK
            Response.Redirect(Me.ResolveUrl(String.Format("{0}?Id={1}", BACKPAGE, IdSistema)))
        End If
    End Sub

    Protected Sub butElimina_Click(sender As Object, e As EventArgs) Handles butElimina.Click, butEliminaTop.Click
        Try
            For Each row As GridViewRow In gvLista.Rows
                Dim chkItem As CheckBox = row.FindControl("CheckBox")
                If chkItem.Checked Then
                    odsRuoli.DeleteParameters("Id").DefaultValue = gvLista.DataKeys(row.RowIndex).Values("ID").ToString
                    odsRuoli.Delete()
                End If
            Next
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Protected Sub butAggiungi_Click(sender As Object, e As EventArgs) Handles butAggiungi.Click, butAggiungiTop.Click

        '
        ' PASSO ALLA MODALITA' INSERIMENTO
        '
        mbModalitàInserimento = True
        Cache.Remove(odsRuoli.CacheKeyDependency)
        txtFiltriCodice.Text = ""
        txtFiltriDescrizione.Text = ""
        gvLista.DataBind()

    End Sub

    Protected Sub butConferma_Click(sender As Object, e As EventArgs) Handles butConferma.Click, butConfermaTop.Click
        Dim iNumChecked As Integer = 0
        Try
            For Each row As GridViewRow In gvLista.Rows
                Dim chkItem As CheckBox = row.FindControl("CheckBox")
                If chkItem.Checked Then
                    odsRuoli.InsertParameters("UtenteInserimento").DefaultValue = User.Identity.Name
                    odsRuoli.InsertParameters("IdRuolo").DefaultValue = gvLista.DataKeys(row.RowIndex).Values("IDRuolo").ToString
                    odsRuoli.InsertParameters("IdSistema").DefaultValue = Request.QueryString("IdSistema")
                    odsRuoli.Insert()
                    iNumChecked += 1
                End If
            Next

            If iNumChecked > 0 Then
                '
                ' PASSO ALLA MODALITA' LISTA
                '
                butAnnulla_Click(Nothing, Nothing)

            Else
                Utility.ShowErrorLabel(LabelError, "Selezionare i Sistemi da aggiungere al Ruolo.")
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Protected Sub chkboxSelectAll_CheckedChanged(ByVal sender As Object, ByVal e As EventArgs)
        Try
            Dim ChkBoxHeader As CheckBox = CType(gvLista.HeaderRow.FindControl("chkboxSelectAll"), CheckBox)
            For Each row As GridViewRow In gvLista.Rows
                CType(row.FindControl("CheckBox"), CheckBox).Checked = ChkBoxHeader.Checked
            Next
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
End Class