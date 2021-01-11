
Imports System.Diagnostics
Imports System
Imports System.Web.UI.WebControls
Imports System.Reflection

Namespace DI.Sac.Admin

    Partial Public Class ProvenienzeLista
        Inherits System.Web.UI.Page

        Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

        Private Shared ReadOnly _ClassName As String = String.Concat("Gestione.", MethodBase.GetCurrentMethod().ReflectedType.Name)

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
            Try
                If Not Page.IsPostBack Then
                    FilterHelper.Restore(pannelloFiltri, msPAGEKEY)
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub

        Private Sub RicercaButton_Click(sender As Object, e As EventArgs) Handles butFiltriRicerca.Click
            Try
                LabelError.Visible = False
                If ValidazioneFiltri() Then
                    FilterHelper.SaveInSession(pannelloFiltri, msPAGEKEY)
                    Cache.Remove(MainObjectDataSource.CacheKeyDependency)
                    gvMain.PageIndex = 0
                End If

            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub

        Protected Sub MainObjectDataSource_Selected(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles MainObjectDataSource.Selected
            ObjectDataSource_TrapError(sender, e)
        End Sub

        Private Function ValidazioneFiltri() As Boolean

            'nulla da validare
            Return True

        End Function

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


End Namespace