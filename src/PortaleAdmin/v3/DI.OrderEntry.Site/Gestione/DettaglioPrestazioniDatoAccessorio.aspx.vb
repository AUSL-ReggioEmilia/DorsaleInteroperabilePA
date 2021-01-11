Imports System
Imports System.Collections.Generic
Imports System.Configuration
Imports System.Linq
Imports System.Web
Imports System.Web.Services
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.OrderEntry.Admin
Imports DI.OrderEntry.Admin.Data
Imports DI.PortalAdmin.Data

Public Class DettaglioPrestazioniDatoAccessorio
    Inherits System.Web.UI.Page


#Region "Property"

    Public Property idDatoAccessorio As String
        Get
            Return Me.ViewState("--idDatoAccessorio--")
        End Get
        Set(value As String)
            Me.ViewState("--idDatoAccessorio--") = value
        End Set
    End Property

    Public Property listaIdPrestazioni As List(Of String)
        Get
            Return HttpContext.Current.Session.Item("--listaIdPrestazioni--")
        End Get
        Set(value As List(Of String))
            HttpContext.Current.Session.Add("--listaIdPrestazioni--", value)
        End Set
    End Property

#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            If Not Page.IsPostBack Then
                '
                ' Ottengo dal QueryString l'ID del Dato Accessorio
                '
                idDatoAccessorio = Me.Request.QueryString("id")

                If String.IsNullOrEmpty(idDatoAccessorio) Then
                    Throw New ApplicationException("L'id del Dato Accessorio è obbligatorio.")
                End If
            End If
        Catch ex As ApplicationException
            Utils.ShowErrorLabel(LabelError, ex.Message)
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Utils.ShowErrorLabel(LabelError, ex.Message)
        End Try
    End Sub


#Region "GridView gvPrestazioni"

    Private Sub gvPrestazioni_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvPrestazioni.RowDataBound
        Try
            Dim gvRow As GridViewRow = CType(e.Row, GridViewRow)
            If gvRow.RowType = DataControlRowType.DataRow Then
                '
                ' Ottengo la checkbox della riga
                '
                Dim checkSistema As CheckBox = CType(gvRow.Cells(0).Controls(1), CheckBox)

                '
                ' Se la lista contiuene già l'id del Sistema allora nascondo la Checkbox:
                ' in questo modo non posso reinserire più volte lo stesso Sistema in un Dato Accessorio
                '
                If Not listaIdPrestazioni Is Nothing AndAlso listaIdPrestazioni.Contains(gvPrestazioni.DataKeys.Item(gvRow.RowIndex).Value.ToString) Then
                    checkSistema.Visible = False
                Else
                    checkSistema.Visible = True
                End If
            End If
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Utils.ShowErrorLabel(LabelError, ex.Message)
        End Try
    End Sub

#End Region

#Region "AddButton & RemoveButton"

    Private Sub addButton_Click(sender As Object, e As ImageClickEventArgs) Handles addButton.Click
        Try
            Dim idPrestazione As String
            Dim listaIdPrestazioniDaInserire As New List(Of String)
            '
            ' Controllo ogni riga della tabella dei sistemi:
            ' Se la checkbox "check" è checked allora ottendo l'id del Sistema e lo inserisco nella tabella dei sistemi legati al Dato Accessorio
            '
            For Each gvRow As GridViewRow In gvPrestazioni.Rows
                If gvRow.RowType = DataControlRowType.DataRow Then
                    Dim check As CheckBox = CType(gvRow.FindControl("chkPrestazioniLista"), CheckBox)
                    If Not check Is Nothing AndAlso check.Checked Then
                        idPrestazione = gvPrestazioni.DataKeys.Item(gvRow.RowIndex).Value.ToString
                        If Not listaIdPrestazioni.Contains(idPrestazione) Then
                            listaIdPrestazioniDaInserire.Add(idPrestazione)
                        End If
                    End If
                End If
            Next

            '
            ' In questo modo rieseguo il bind dei dati solo se la è stato selezionata almeno una prestazione
            '
            If Not listaIdPrestazioniDaInserire Is Nothing AndAlso listaIdPrestazioniDaInserire.Count > 0 Then
                For Each idP As String In listaIdPrestazioniDaInserire
                    InsertDatiAccessoriInPrestazione(idP, idDatoAccessorio)
                Next

                '
                ' Rieseguo il bind delle griglie per aggiornare i dati
                '
                gvPrestazioniDatoAccessorio.DataBind()
                gvPrestazioni.DataBind()
            End If

        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Utils.ShowErrorLabel(LabelError, ex.Message)
        End Try
    End Sub

    Private Sub removeButton_Click(sender As Object, e As ImageClickEventArgs) Handles removeButton.Click
        Try
            Dim idPrestazione As String
            Dim listaIdPrestazioni As New List(Of String)

            '
            ' Controllo ogni riga della tabella dei sistemi:
            ' Se la checkbox "check" è checked allora ottendo l'id del Sistema e lo rimuovo dalla tabella dei sistemi legati al Dato Accessorio
            '
            For Each gvRow As GridViewRow In gvPrestazioniDatoAccessorio.Rows
                If gvRow.RowType = DataControlRowType.DataRow Then
                    Dim check As CheckBox = CType(gvRow.FindControl("chkPrestazioniDatoAccessorio"), CheckBox)
                    If Not check Is Nothing AndAlso check.Checked Then
                        idPrestazione = gvPrestazioniDatoAccessorio.DataKeys.Item(gvRow.RowIndex).Value.ToString
                        listaIdPrestazioni.Add(idPrestazione)

                    End If
                End If
            Next

            '
            ' In questo modo rieseguo il bind dei dati solo se la è stato selezionata almeno una prestazione
            '
            If Not listaIdPrestazioni Is Nothing AndAlso listaIdPrestazioni.Count > 0 Then
                For Each idP As String In listaIdPrestazioni
                    DeleteDatiAccessoriDaPrestazione(idP, idDatoAccessorio)
                Next

                '
                ' Rieseguo il bind delle griglie per aggiornare i dati
                '
                gvPrestazioniDatoAccessorio.DataBind()
                gvPrestazioni.DataBind()
            End If
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Utils.ShowErrorLabel(LabelError, ex.Message)
        End Try
    End Sub

#End Region

#Region "Web Method"

    <WebMethod()>
    Public Shared Function DeleteDatiAccessoriDaPrestazione(idPrestazione As String, codiciDatiAccessori As String) As String
        Try
            For Each codice In codiciDatiAccessori.Split(";"c)
                DataAdapterManager.DeleteDatoAccessorioFromPrestazione(codice, New Guid(idPrestazione))
            Next
            Return "ok"
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            Return Nothing
        End Try
    End Function

    <WebMethod()>
    Public Shared Function InsertDatiAccessoriInPrestazione(idPrestazione As String, codiciDatiAccessori As String) As String
        Try
            Dim codici = From codice In codiciDatiAccessori.Split(";"c)
                         Select codice
            DataAdapterManager.InsertDatoAccessorioInPrestazione(New Guid(idPrestazione), codici.ToArray())
            Return "ok"
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            Return Nothing
        End Try
    End Function

#End Region

#Region "Metodi CheckBox"

    Protected Sub chekAllPrestazioni(sender As Object, e As EventArgs)
        Try
            '
            ' Quando premo sulla checkbox contenuto nell'header seleziono tutte le checkbox contenute nel body della tabella
            '
            Dim headerCheck As CheckBox = CType(sender, CheckBox)
            For Each row As GridViewRow In gvPrestazioni.Rows
                If row.RowType = DataControlRowType.DataRow Then
                    Dim check As CheckBox = CType(row.FindControl("chkPrestazioniLista"), CheckBox)
                    check.Checked = headerCheck.Checked
                End If
            Next
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Utils.ShowErrorLabel(LabelError, ex.Message)
        End Try
    End Sub

    Protected Sub chekAllPrestazioniDatoAccessorio(sender As Object, e As EventArgs)
        Try
            '
            ' Quando premo sulla checkbox contenuto nell'header seleziono tutte le checkbox contenute nel body della tabella
            '
            Dim headerCheck As CheckBox = CType(sender, CheckBox)
            For Each row As GridViewRow In gvPrestazioniDatoAccessorio.Rows
                If row.RowType = DataControlRowType.DataRow Then
                    Dim check As CheckBox = CType(row.FindControl("chkPrestazioniDatoAccessorio"), CheckBox)
                    check.Checked = headerCheck.Checked
                End If
            Next
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Utils.ShowErrorLabel(LabelError, ex.Message)
        End Try
    End Sub

#End Region

#Region "ObjectDataSource odsPrestazioniDatoAccessorio"

    Private Sub odsPrestazioniDatoAccessorio_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsPrestazioniDatoAccessorio.Selected
        Try
            Dim ds As DI.OrderEntry.Admin.Data.DatiAccessori.UiDatiAccessoriPrestazioniDataTable = CType(e.ReturnValue, DI.OrderEntry.Admin.Data.DatiAccessori.UiDatiAccessoriPrestazioniDataTable)
            '
            ' Creo una lista contenente tutti gli Id dei Sistemi collegati al Dato Accessorio
            ' Questa lista (listaIdSistemi) viene usata per evitare di reinserire più volte un Sistema in un Dato Accessorio
            '
            Dim listaId As New List(Of String)
            For Each row As Data.DataRow In ds.Rows
                listaId.Add(row.Item(1).ToString())
            Next
            listaIdPrestazioni = listaId
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Utils.ShowErrorLabel(LabelError, ex.Message)
        End Try
    End Sub



#End Region

End Class