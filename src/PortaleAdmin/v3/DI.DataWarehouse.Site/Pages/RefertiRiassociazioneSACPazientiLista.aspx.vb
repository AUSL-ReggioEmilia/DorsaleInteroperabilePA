Imports System.Web.UI
Imports System
Imports System.Web.UI.HtmlControls
Imports System.Diagnostics
Imports System.Web.UI.WebControls
'Imports DI.Common
''Imports System.Reflection
Imports System.Drawing
Imports System.Web
Imports DI.DataWarehouse.Admin
Imports DI.PortalAdmin.Data

Namespace DI.Sac.Admin

    Partial Public Class RefertiRiassociazioneSACPazientiLista
        Inherits Page

        ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
        Const BACKPAGE = "RefertiRiassociazioneDettaglio.aspx?IdReferto={0}&IdPaziente={1}"
        Private mbObjectDataSource_CancelSelect As Boolean = True

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
            Try
                'controllo dei parametri				
                'IdReferto è obbligatorio
                If Not Utility.SQLTypes.IsValidGuid(Request.QueryString(Constants.IdReferto)) Then
                    GoBack()
                End If

                If Not Page.IsPostBack Then
                    Cache.Remove(PazientiListaObjectDataSource.CacheKeyDependency)
                    '
                    ' Modifico url per il menu orizzontale
                    If Not SiteMap.CurrentNode Is Nothing Then
                        Utility.SetSiteMapNodeQueryString(SiteMap.CurrentNode.ParentNode, String.Format("IdReferto={0}", Request.QueryString(Constants.IdReferto)))
                    End If
                End If
                Form.DefaultButton = RicercaButton.UniqueID

            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub

        Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
            Try
                If Not Page.IsPostBack Then
                    FilterHelper.Restore(pannelloFiltri, msPAGEKEY)
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub

        Protected Sub butRicerca_Click(ByVal sender As Object, ByVal e As EventArgs) Handles RicercaButton.Click
            Try
                If IsSearchValid() Then

                    LabelError.Visible = False
                    mbObjectDataSource_CancelSelect = False
                    Cache(PazientiListaObjectDataSource.CacheKeyDependency) = New Date

                    If PazientiGridView.SortExpression = "" Then
                        PazientiGridView.Sort("Cognome,Nome", SortDirection.Ascending)
                    End If


                    '
                    '2020-07-03 Kyrylo: Traccia Operazioni
                    '
                    Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                    oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Ricerca paziente", pannelloFiltri, Nothing)
                End If

            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub

        Protected Sub PazientiListaObjectDataSource_Selecting(ByVal sender As Object, ByVal e As ObjectDataSourceSelectingEventArgs) Handles PazientiListaObjectDataSource.Selecting
            Try
                If mbObjectDataSource_CancelSelect OrElse Not IsSearchValid() Then
                    e.Cancel = True
                Else
                    e.InputParameters("IdPaziente") = Utility.StringEmptyDBNullToNothing(IdSacTextBox.Text)
                End If

                PazientiGridView.EmptyDataText = If(e.Cancel, "Impostare i filtri e premere Cerca.", "Nessun risultato!")

            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub

        Protected Sub PazientiListaObjectDataSource_Selected(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles PazientiListaObjectDataSource.Selected
            If Not ObjectDataSource_TrapError(sender, e) Then
                'se la ricerca non ha prodotto errore salvo i filtri in session
                FilterHelper.SaveInSession(pannelloFiltri, msPAGEKEY)
            End If
        End Sub


        Protected Function IsSearchValid() As Boolean
            Dim bRet As Boolean

            If IdSacTextBox.Text.Length > 0 AndAlso Not Utility.SQLTypes.IsValidGuid(IdSacTextBox.Text) Then
                Utility.ShowErrorLabel(LabelError, "il Campo 'Id Paziente SAC' contiene un codice non valido.")
                Return False
            End If

            bRet = CognomeTextBox.Text.Length > 0 OrElse
              CodiceFiscaleTextBox.Text.Length > 0 OrElse
             IdSacTextBox.Text.Length > 0 OrElse
             AnnoNascitaTextBox.Text.Length > 0 OrElse
             (ProvenienzaTexttBox.Text.Length > 0 AndAlso IdProvenienzaTextBox.Text.Length > 0)

            If Not bRet Then
                Utility.ShowErrorLabel(LabelError, "Valorizzare almeno uno dei seguenti filtri: Cognome, Codice fiscale, Anno di nascita, Id Paziente SAC, Provenienza e IdProvenienza")
            End If

            Return bRet
        End Function

        Private Sub butAnnulla_Click(sender As Object, e As System.EventArgs) Handles butAnnulla.Click
            GoBack()
        End Sub

        Private Sub GoBack(Optional sIDPaziente As String = "")
            Try
                Dim sIDReferto As String = Request.QueryString(Constants.IdReferto)
                Response.Redirect(String.Format(BACKPAGE, sIDReferto, sIDPaziente))
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Protected Sub linkSeleziona_Click(ByVal sender As Object, ByVal e As EventArgs)
            Try
                Dim sIDPazienteScelto As String = sender.CommandArgument
                GoBack(sIDPazienteScelto)
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub

        Protected Sub PazientiGridView_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles PazientiGridView.RowDataBound
            If e.Row.RowType = DataControlRowType.DataRow Then
                Dim stato = DirectCast(e.Row.DataItem("Disattivato"), Byte)
                Select Case stato
                    Case 0 'Attivo
                        e.Row.BackColor = Color.FromArgb(192, 240, 192) '#C0F0C0
                    Case 1 'Fuso
                        e.Row.BackColor = Color.FromArgb(252, 192, 192) '#FCC2C2
                    Case Else 'Cancellato
                        e.Row.BackColor = Color.FromArgb(204, 225, 232) '#CCE1E8
                End Select
            End If
        End Sub



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