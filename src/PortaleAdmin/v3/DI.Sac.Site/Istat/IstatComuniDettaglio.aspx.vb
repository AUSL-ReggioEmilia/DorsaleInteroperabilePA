Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin

Public Class IstatComuniDettaglio
    Inherits System.Web.UI.Page

    Private Const BACKPAGE As String = "~/Istat/IstatComuniLista.aspx"
    Private Const FILTERKEY As String = "IstatComuniDettaglio"
    Private mbErroreSalvataggio As Boolean = False


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            If Not Page.IsPostBack Then
                If Request.QueryString("Codice") = "" Then
                    FormViewDettaglio.ChangeMode(FormViewMode.Insert)
                    lblTitolo.Text = "Inserimento Codice Istat"
                Else
                    FormViewDettaglio.ChangeMode(FormViewMode.Edit)
                    lblTitolo.Text = "Dettaglio Codice Istat"
                End If

            Else

            End If
        Catch ex As Exception

            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub


#Region "FormViewDettaglio"

    Protected Sub FormViewDettaglio_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles FormViewDettaglio.ItemCommand
        If e.CommandName.ToUpper = "CANCEL" Then
            Response.Redirect(BACKPAGE)
        End If
    End Sub

    Private Sub FormViewDettaglio_ItemInserted(sender As Object, e As System.Web.UI.WebControls.FormViewInsertedEventArgs) Handles FormViewDettaglio.ItemInserted
        e.KeepInInsertMode = True
    End Sub

    Private Sub FormViewDettaglio_PreRender(sender As Object, e As System.EventArgs) Handles FormViewDettaglio.PreRender
        Try
            If mbErroreSalvataggio Then
                FilterHelper.Restore(FormViewDettaglio, FILTERKEY)
            Else
                If (sender.CurrentMode = FormViewMode.Insert) Then
                    'precarico le date di default
                    sender.FindControl("txtDTInizio").Text = "01/01/1800"
                    sender.FindControl("txtDTFine").Text = "31/12/3000"
                End If

            End If

            'fatto ogni volta per togliere l'elemento {nazione} se si tratta di un comune
            Dim ddlTipo As DropDownList = FormViewDettaglio.FindControl("ddlTipo")
            Dim ddlProvince As DropDownList = FormViewDettaglio.FindControl("ddlProvince")
            If ddlTipo.SelectedValue = "True" Then 'nazione
                ddlProvince.Items.FindByValue("-10").Enabled = True ' mostra {nazione}
                ddlProvince.SelectedValue = "-10" '={nazione}
                ddlProvince.Enabled = False
            Else 'comune
                ddlProvince.Items.FindByValue("-10").Enabled = False 'nasconde {nazione}
                ddlProvince.Enabled = True
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub


    Protected Sub butSalva_Click(sender As Object, e As EventArgs)
        Try
            'salvo i valori attuali nel viewstate perchè se c'è un errore 
            ' di salvataggio li devo rileggere           
            FilterHelper.SaveInSession(FormViewDettaglio, FILTERKEY)
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub


    Protected Sub ddlTipo_SelectedIndexChanged(sender As Object, e As EventArgs)
        If Page.IsPostBack Then 'fatto al postback = solo su click utente
            Try
                Dim ddlTipo As DropDownList = FormViewDettaglio.FindControl("ddlTipo")
                Dim ddlProvince As DropDownList = FormViewDettaglio.FindControl("ddlProvince")
                If ddlTipo.SelectedValue = "True" Then 'nazione
                    ddlProvince.Items.FindByValue("-10").Enabled = True
                    ddlProvince.SelectedValue = "-10" '={nazione}
                    ddlProvince.Enabled = False
                Else 'comune
                    ddlProvince.Items.FindByValue("-10").Enabled = False
                    ddlProvince.SelectedValue = "-1" '={codice sconosciuto}
                    ddlProvince.Enabled = True
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End If

    End Sub

#End Region


#Region "ObjectDataSource"


    Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDettaglioIstatComune.Selected, odsProvince.Selected
        ObjectDataSource_TrapError(sender, e)
    End Sub

    Private Sub odsDettaglioIstatComune_Inserted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettaglioIstatComune.Inserted
        If ObjectDataSource_TrapError(sender, e) Then
            mbErroreSalvataggio = True
        Else
            Cache("CacheIstatComuni") = New Object
            Response.Redirect(BACKPAGE)
        End If
    End Sub

    Private Sub odsDettaglioIstatComune_Updated(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettaglioIstatComune.Updated
        If ObjectDataSource_TrapError(sender, e) Then
            mbErroreSalvataggio = True
        Else
            Cache("CacheIstatComuni") = New Object
            Response.Redirect(BACKPAGE)
        End If
    End Sub

    Private Sub odsDettaglioIstatComune_Deleted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettaglioIstatComune.Deleted
        If ObjectDataSource_TrapError(sender, e) Then
            mbErroreSalvataggio = True
        Else
            Cache("CacheIstatComuni") = New Object
            Response.Redirect(BACKPAGE)
        End If
    End Sub
#End Region


#Region "Funzioni"

    ''' <summary>
    ''' Gestisce gli errori del ObjectDataSource in maniera pulita
    ''' </summary>
    ''' <returns>True se si è verificato un errore</returns>
    Private Function ObjectDataSource_TrapError(ods As ObjectDataSourceView, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) As Boolean
        Try
            If e.Exception IsNot Nothing AndAlso e.Exception.InnerException IsNot Nothing Then
                LabelError.Text = GestioneErrori.TrapError(e.Exception.InnerException)
                LabelError.Visible = True
                e.ExceptionHandled = True
                Return True
            Else
                Return False
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
            Return True
        End Try

    End Function


#End Region


End Class