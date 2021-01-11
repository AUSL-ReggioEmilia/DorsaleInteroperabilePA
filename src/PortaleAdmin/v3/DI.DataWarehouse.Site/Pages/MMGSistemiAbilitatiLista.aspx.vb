Imports System
Imports System.Web.UI.WebControls

Public Class SistemiAbilitati
    Inherits System.Web.UI.Page

    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            Page.Form.DefaultButton = butFiltriRicerca.UniqueID

            If Not Page.IsPostBack Then
                '
                'Ricarico i filtri dalla sessione
                '
                FilterHelper.Restore(pannelloFiltri, msPAGEKEY)
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Protected Sub RicercaButton_Click(sender As Object, e As EventArgs) Handles butFiltriRicerca.Click
        Try
            LabelError.Visible = False

            '
            ' Salvo in sessione i filtri e eseguo il bind dei dati.
            '
            FilterHelper.SaveInSession(pannelloFiltri, msPAGEKEY)
            gvLista.DataBind()

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try

    End Sub


    Private Sub NewButton_Click(sender As Object, e As System.EventArgs) Handles NewButton.Click
        '
        'Eseguo il redirect alla pagina di dettaglio dei SistemiAbilitati
        '
        Response.Redirect(Me.ResolveUrl("MMGSistemiAbilitatiDettaglio.aspx"), False)
    End Sub

    Private Sub odsLista_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
        ObjectDataSource_TrapError(e)
    End Sub

#Region "Funzioni"

    ''' <summary>
    ''' Gestisce gli errori del ObjectDataSource in maniera pulita
    ''' </summary>
    ''' <returns>True se si è verificato un errore</returns>
    Private Function ObjectDataSource_TrapError(e As ObjectDataSourceStatusEventArgs) As Boolean
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


    Private Sub ObjectDataSource_InvalidaCache(ods As ObjectDataSource)
        Dim sCacheKeyDependency As String
        If ods.EnableCaching Then
            sCacheKeyDependency = ods.CacheKeyDependency
            If Not String.IsNullOrEmpty(sCacheKeyDependency) Then
                System.Web.HttpContext.Current.Cache(sCacheKeyDependency) = New Object
            End If
        End If
    End Sub

#End Region

End Class