Imports System
Imports System.Web.UI
Imports DI.DataWarehouse.Admin.Data
Imports DI.DataWarehouse.Admin.Data.BackEndDataSet
Imports System.Web.UI.WebControls
Imports System.Data
Imports DI.PortalAdmin.Data

Namespace DI.DataWarehouse.Admin

    Partial Class RefertiRiassociazioneDettaglio
        Inherits Page

        Const BACKPAGE = "RefertiRiassociazioneLista.aspx"
        Const SACPAZIENTIPAGE = "RefertiRiassociazioneSACPazientiLista.aspx"

        Private Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles MyBase.Load
            Try
                'controllo dei parametri
                'IdReferto è obbligatorio
                If Not Utility.SQLTypes.IsValidGuid(Request.QueryString(Constants.IdReferto)) Then
                    GoBack()
                End If

                'IdPaziente è opzionale, ma se c'è deve essere un guid valido
                If Not String.IsNullOrEmpty(Request.QueryString(Constants.IdPaziente)) AndAlso Not Utility.SQLTypes.IsValidGuid(Request.QueryString(Constants.IdPaziente)) Then
                    GoBack()
                End If

                butAssocia.Enabled = False

                If Not Page.IsPostBack Then
                    '
                    '2020-07-07 Kyrylo: Traccia Operazioni
                    '
                    Dim idReferto As String = Request.QueryString(Constants.IdReferto)
                    Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                    oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Visualizzato dettaglio referto", idPaziente:=Nothing, Nothing, idReferto, "idReferto")
                End If

            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Private Sub GoBack()
            Try
                Response.Redirect(BACKPAGE, True)
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Private Sub odsDettagliReferto_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettagliReferto.Selected
            ObjectDataSource_TrapError(sender, e)
        End Sub

        Private Sub odsDettagliSAC_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles odsDettagliSAC.Selecting
            Try
                '
                ' NON CARICO DAL SAC I DATI DEL PAZIENTE NULLO
                '
                If String.IsNullOrEmpty(Request.QueryString(Constants.IdPaziente)) OrElse
                 Request.QueryString(Constants.IdPaziente).ToString = Constants.SAC_IdPazienteNullo Then
                    e.Cancel = True
                End If
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Private Sub odsDettagliSAC_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettagliSAC.Selected
            Try
                If Not ObjectDataSource_TrapError(sender, e) Then
                    Dim dt As DataTable = e.ReturnValue
                    If dt.Rows.Count = 1 Then
                        butAssocia.Enabled = True
                        'lblWarning.Visible = FormViewDettagliReferto.DataKey(0).ToString <> Request.QueryString(Constants.IdPaziente).ToString
                    End If
                End If
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Private Sub odsDettagliReferto_Updated(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettagliReferto.Updated
            Try
                If Not ObjectDataSource_TrapError(sender, e) Then
                    Response.Redirect(Request.Url.AbsolutePath & "?" & Constants.IdReferto & "=" & Request.QueryString(Constants.IdReferto))
                End If
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Protected Sub butCerca_Click(sender As Object, e As EventArgs) Handles butCerca.Click
            Try
                Response.Redirect(SACPAZIENTIPAGE & "?" & Constants.IdReferto & "=" & Request.QueryString(Constants.IdReferto))
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Protected Sub butAnnulla_Click(sender As Object, e As EventArgs) Handles butAnnulla.Click
            GoBack()
        End Sub

        Protected Sub butAssocia_Click(sender As Object, e As EventArgs) Handles butAssocia.Click
            Try
                '
                ' I DUE PARAMETRI PER L'UPDATE LI PRENDE DAL QUERYSTRING
                odsDettagliReferto.Update()
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Protected Function GetDettaglioRefertoTestataUrl(ByVal idReferto As Object) As String

            If idReferto IsNot DBNull.Value Then
                Return String.Format(My.Settings.RefertoDettaglioTestataUrl, idReferto)
            Else
                Return String.Empty
            End If
        End Function


#Region "Funzioni"

        ''' <summary>
        ''' Gestisce gli errori del ObjectDataSource in maniera pulita
        ''' </summary>
        ''' <returns>True se si è verificato un errore</returns>
        Private Function ObjectDataSource_TrapError(ods As ObjectDataSourceView, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) As Boolean
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