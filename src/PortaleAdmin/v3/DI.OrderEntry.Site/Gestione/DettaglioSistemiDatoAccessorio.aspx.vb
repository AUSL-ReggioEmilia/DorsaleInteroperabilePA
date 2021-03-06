﻿Imports System
Imports System.Collections.Generic
Imports System.Configuration
Imports System.Linq
Imports System.Web
Imports System.Web.Services
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.OrderEntry.Admin
Imports DI.OrderEntry.Admin.Data
Imports DI.OrderEntry.Admin.Data.DatiAccessoriTableAdapters
Imports DI.PortalAdmin.Data

Public Class DettaglioSistemiDatoAccessorio
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

    Public Property listaIdSistemi As List(Of String)
        Get
            Return HttpContext.Current.Session.Item("--listaIdSistemi--")
        End Get
        Set(value As List(Of String))
            HttpContext.Current.Session.Add("--listaIdSistemi--", value)
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

#Region "ObjectDataSource odsSistemi"

    Private Sub odsSistemi_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsSistemi.Selecting
        Try
            e.InputParameters("CodiceDescrizione") = codiceDescrizioneTxb.Text
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Utils.ShowErrorLabel(LabelError, ex.Message)
        End Try
    End Sub

    Private Sub odsSistemiDatoAccessorio_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsSistemiDatoAccessorio.Selected
        Try
            Dim ds As DI.OrderEntry.Admin.Data.DatiAccessori.UiDatiAccessoriSistemiDataTable = CType(e.ReturnValue, DI.OrderEntry.Admin.Data.DatiAccessori.UiDatiAccessoriSistemiDataTable)
            '
            ' Creo una lista contenente tutti gli Id dei Sistemi collegati al Dato Accessorio
            ' Questa lista (listaIdSistemi) viene usata per evitare di reinserire più volte un Sistema in un Dato Accessorio
            '
            Dim listaId As New List(Of String)
            For Each row As Data.DataRow In ds.Rows
                listaId.Add(row.Item(8).ToString())
            Next
            listaIdSistemi = listaId
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Utils.ShowErrorLabel(LabelError, ex.Message)
        End Try
    End Sub

#End Region

    Private Sub cercaBtn_Click(sender As Object, e As EventArgs) Handles cercaBtn.Click
        gvSistemi.DataBind()
    End Sub

#Region "Metodi CheckBox"
    Protected Sub chekAllSistemiDatoAccessorio(sender As Object, e As EventArgs)
        Try
            '
            ' Quando premo sulla checkbox contenuto nell'header seleziono tutte le checkbox contenute nel body della tabella
            '
            Dim headerCheck As CheckBox = CType(sender, CheckBox)
            For Each row As GridViewRow In gvSistemiDatoAccessorio.Rows
                If row.RowType = DataControlRowType.DataRow Then
                    Dim check As CheckBox = CType(row.FindControl("chkSistemiDatoAccessorio"), CheckBox)
                    check.Checked = headerCheck.Checked
                End If
            Next
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Utils.ShowErrorLabel(LabelError, ex.Message)
        End Try
    End Sub

    Protected Sub chekAllSistemi(sender As Object, e As EventArgs)
        Try
            '
            ' Quando premo sulla checkbox contenuto nell'header seleziono tutte le checkbox contenute nel body della tabella
            '
            Dim headerCheck As CheckBox = CType(sender, CheckBox)
            For Each row As GridViewRow In gvSistemi.Rows
                If row.RowType = DataControlRowType.DataRow Then
                    Dim check As CheckBox = CType(row.FindControl("chkSistemiLista"), CheckBox)
                    check.Checked = headerCheck.Checked
                End If
            Next
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Utils.ShowErrorLabel(LabelError, ex.Message)
        End Try
    End Sub
#End Region

    Private Sub addButton_Click(sender As Object, e As ImageClickEventArgs) Handles addButton.Click
        Try
            Dim idSistema As String
            Dim listaIdSistemiDaInserire As New List(Of String)

            '
            ' Controllo ogni riga della tabella dei sistemi:
            ' Se la checkbox "check" è checked allora ottendo l'id del Sistema e lo inserisco nella tabella dei sistemi legati al Dato Accessorio
            '
            For Each gvRow As GridViewRow In gvSistemi.Rows
                If gvRow.RowType = DataControlRowType.DataRow Then
                    Dim check As CheckBox = CType(gvRow.FindControl("chkSistemiLista"), CheckBox)
                    If Not check Is Nothing AndAlso check.Checked Then
                        idSistema = gvSistemi.DataKeys.Item(gvRow.RowIndex).Value.ToString

                        '
                        ' Se l'Id è già presente nella lisa dei Sistemi collegati al DatoAccessorio non lo inserisco nella lista dei sistemi da aggiungere
                        '
                        If Not listaIdSistemi.Contains(idSistema) Then
                            listaIdSistemiDaInserire.Add(idSistema)
                        End If
                    End If
                End If
            Next

            '
            ' In questo modo rieseguo il bind dei dati solo se la è stato selezionata almeno una prestazione
            '
            If Not listaIdSistemiDaInserire Is Nothing AndAlso listaIdSistemiDaInserire.Count > 0 Then
                For Each idS As String In listaIdSistemiDaInserire
                    InsertDatiAccessoriInSistema(idS, idDatoAccessorio)
                Next

                '
                ' Rieseguo il bind delle griglie per aggiornare i dati
                '
                gvSistemiDatoAccessorio.DataBind()
                gvSistemi.DataBind()
            End If
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Utils.ShowErrorLabel(LabelError, ex.Message)
        End Try
    End Sub

    Private Sub removeButton_Click(sender As Object, e As ImageClickEventArgs) Handles removeButton.Click
        Try
            Dim idSistema As String
            Dim listaIdSistemi As New List(Of String)


            '
            ' Controllo ogni riga della tabella dei sistemi:
            ' Se la checkbox "check" è checked allora ottendo l'id del Sistema e lo rimuovo dalla tabella dei sistemi legati al Dato Accessorio
            '
            For Each gvRow As GridViewRow In gvSistemiDatoAccessorio.Rows
                If gvRow.RowType = DataControlRowType.DataRow Then
                    Dim check As CheckBox = CType(gvRow.FindControl("chkSistemiDatoAccessorio"), CheckBox)
                    If Not check Is Nothing AndAlso check.Checked Then
                        idSistema = gvSistemiDatoAccessorio.DataKeys.Item(gvRow.RowIndex).Value.ToString
                        listaIdSistemi.Add(idSistema)
                    End If
                End If
            Next


            '
            ' In questo modo rieseguo il bind dei dati solo se la è stato selezionata almeno una prestazione
            '
            If Not listaIdSistemi Is Nothing AndAlso listaIdSistemi.Count > 0 Then
                For Each idS As String In listaIdSistemi
                    DeleteDatiAccessoriDaSistema(idS, idDatoAccessorio)
                Next

                '
                ' Rieseguo il bind delle griglie per aggiornare i dati
                '
                gvSistemiDatoAccessorio.DataBind()
                gvSistemi.DataBind()
            End If
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Utils.ShowErrorLabel(LabelError, ex.Message)
        End Try
    End Sub



    Private Sub gvSistemi_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvSistemi.RowDataBound
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
                If Not listaIdSistemi Is Nothing AndAlso listaIdSistemi.Contains(gvSistemi.DataKeys.Item(gvRow.RowIndex).Value.ToString) Then
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


#Region "WebMethod"
    <WebMethod()>
    Public Shared Function InsertDatiAccessoriInSistema(idSistema As String, codiciDatiAccessori As String) As String
        Try
            Dim codici = From codice In codiciDatiAccessori.Split(";"c)
                         Select codice
            DataAdapterManager.InsertDatoAccessorioInSistema(New Guid(idSistema), codici.ToArray())
            Return "ok"
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            Throw
        End Try
    End Function

    <WebMethod()>
    Public Shared Function DeleteDatiAccessoriDaSistema(idSistema As String, codiciDatiAccessori As String) As String
        Try
            For Each codice In codiciDatiAccessori.Split(";"c)
                DataAdapterManager.DeleteDatoAccessorioFromSistema(codice, New Guid(idSistema))
            Next
            Return "ok"
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            Throw
        End Try
    End Function

#End Region

End Class