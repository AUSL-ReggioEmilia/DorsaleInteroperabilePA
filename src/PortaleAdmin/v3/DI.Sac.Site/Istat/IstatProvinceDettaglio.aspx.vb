Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin

Public Class IstatProvinceDettaglio
    Inherits System.Web.UI.Page

    Private Const BACKPAGE As String = "~/Istat/IstatProvinceLista.aspx"
    Private Const FILTERKEY As String = "IstatProvinceDettaglio"
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

    Private Sub FormViewDettaglio_PreRender(sender As Object, e As System.EventArgs) Handles FormViewDettaglio.PreRender
        Try
            If mbErroreSalvataggio Then
                FilterHelper.Restore(FormViewDettaglio, FILTERKEY)
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub

    Protected Sub FormViewDettaglio_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles FormViewDettaglio.ItemCommand
        If e.CommandName.ToUpper = "CANCEL" Then
            Response.Redirect(BACKPAGE)
        End If
    End Sub


    Private Sub FormViewDettaglio_ItemUpdated(sender As Object, e As System.Web.UI.WebControls.FormViewUpdatedEventArgs) Handles FormViewDettaglio.ItemUpdated
        e.KeepInEditMode = True
    End Sub

    Private Sub FormViewDettaglio_ItemInserted(sender As Object, e As System.Web.UI.WebControls.FormViewInsertedEventArgs) Handles FormViewDettaglio.ItemInserted
        e.KeepInInsertMode = True
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

#End Region


#Region "ObjectDataSource"

    Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsIstatProvinceDettaglio.Selected, odsRegioni.Selected
        ObjectDataSource_TrapError(sender, e)
    End Sub

    Private Sub odsIstatProvinceDettaglio_Inserted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsIstatProvinceDettaglio.Inserted
        If ObjectDataSource_TrapError(sender, e) Then
            mbErroreSalvataggio = True
        Else
            Cache("CacheIstatProvince") = New Object
            Response.Redirect(BACKPAGE)
        End If
    End Sub

    Private Sub odsIstatProvinceDettaglio_Updated(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsIstatProvinceDettaglio.Updated
        If ObjectDataSource_TrapError(sender, e) Then
            mbErroreSalvataggio = True
        Else
            Cache("CacheIstatProvince") = New Object
            Response.Redirect(BACKPAGE)
        End If
    End Sub

    Private Sub odsIstatProvinceDettaglio_Deleted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsIstatProvinceDettaglio.Deleted
        If ObjectDataSource_TrapError(sender, e) Then
            mbErroreSalvataggio = True
        Else
            Cache("CacheIstatProvince") = New Object
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