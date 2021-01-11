Imports System.ComponentModel

Public Class AdminPage
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            divErrorMessage.Visible = False
            If Not Page.IsPostBack Then

            End If
        Catch ex As Exception

        End Try

    End Sub

    Private Sub odsClaims_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsClaims.Selected
        Try
            If e.Exception IsNot Nothing Then
                Dim ex As Exception = e.Exception.InnerException
                If ex Is Nothing Then ex = e.Exception
                'Scrivo solo nell'event log
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    divErrorMessage.Visible = True
                    LabelError.Text = sErrorMessage
                End If
                e.ExceptionHandled = True
            End If
        Catch ex As Exception
            '
            ' Scrivo in event log e memorizzo l'errore
            '
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                '
                ' Rendo visibile il div che contiene il messaggio di errore
                '
                divErrorMessage.Visible = True
                '
                ' Scrivo in event log e visualizzo nella label
                '
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub
End Class

<DataObject(True)>
Public Class ClaimsInfo

    Public Function GetDataTable() As DataView
        Dim objClaims As Object = DirectCast(HttpContext.Current.User, System.Security.Claims.ClaimsPrincipal).Claims

        Dim oDataTable As New DataTable()
        oDataTable.Columns.Add("Claims", GetType(String))

        For Each oClaim As System.Security.Claims.Claim In objClaims
            oDataTable.Rows.Add(oClaim.Value)
        Next
        Dim oDataView As DataView = oDataTable.DefaultView
        oDataView.Sort = "Claims"
        '
        '
        '
        Return oDataView
    End Function


End Class