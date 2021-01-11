Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin.Data

Namespace DI.DataWarehouse.Admin

	Partial Class SOLELogInvii
		Inherits Page

		Private mPageId As String = Me.GetType().Name
        Const BACKPAGE = "RefertiLista.aspx"

        Const DONE_CANCELLAZIONE As String = "done1"
        Const DONE_RINOTIFICA As String = "done2"

        Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
            Try
                'controllo dei parametri				
                'IdReferto è obbligatorio
                If Not Utility.SQLTypes.IsValidGuid(Request.QueryString(Constants.IdReferto)) Then
                    GoBack()
                End If

                'dopo la pressione del pulsante Invio, disabilito il pulsante stesso
                If Request.QueryString(DONE_CANCELLAZIONE) = "1" Then
                    DeleteButton.Enabled = False
                End If
                If Request.QueryString(DONE_RINOTIFICA) = "1" Then
                    RiprocessaButton.Enabled = False
                End If

                lblTitolo.Text = Page.Title

            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub

		Private Sub GoBack()
			Try
				Response.Redirect(BACKPAGE, False)
			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub

        Private Sub ObjectDataSource_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DataSourceMain.Selected
            Try
                If Not GestioneErrori.ObjectDataSource_TrapError(e, LabelError) Then
                    Dim dT As System.Data.DataTable = CType(e.ReturnValue, System.Data.DataTable)
                    If dT Is Nothing OrElse dT.Rows.Count = 0 Then
                        'Disabilito i pulsanti se non c'è nulla nella lista
                        DeleteButton.Enabled = False
                        RiprocessaButton.Enabled = False
                    End If
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub

        Private Sub DeleteButton_Click(sender As Object, e As System.EventArgs) Handles DeleteButton.Click
			Try
				Dim gIDReferto As New Guid(Request.QueryString(Constants.IdReferto))
				Dim iRetValue As Integer = -1

				Using taNotifica As New SoleTableAdapters.NotificaCancellazioneTableAdapter
					Dim dtNotifica As New Sole.NotificaCancellazioneDataTable
					taNotifica.Fill(dtNotifica, gIDReferto)
					Dim oRet = taNotifica.Adapter.SelectCommand.Parameters("@RETURN_VALUE").Value
					If TypeOf oRet Is Integer Then
						iRetValue = oRet
					End If
				End Using

				If iRetValue <> 0 Then
					Utility.ShowErrorLabel(LabelError, String.Format("La procedura di cancellazione ha restituito il codice d'errore {0}. Contattare un amministratore.", iRetValue))
					DeleteButton.Enabled = False
					GridViewMain.DataBind()
				Else
                    'ricarico la pagina aggiungendo DONE_CANCELLAZIONE=1, questo evita il doppio postback se l'utente preme F5
                    Dim sUrl As String = Me.ModifyQueryStringParameter(DONE_CANCELLAZIONE, "1")
                    Dim functionJS As String = "alert('La notifica di cancellazione del referto è stata eseguita.');"
                    functionJS = functionJS & "window.location='" & sUrl & "';"
                    ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide2", functionJS, True)

                End If

            Catch ex As Exception
				Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
				Utility.ShowErrorLabel(LabelError, sErrorMessage)
			End Try
		End Sub

        Private Sub RiprocessaButton_Click(sender As Object, e As System.EventArgs) Handles RiprocessaButton.Click
            Dim iRetValue As Integer = 0
            Try
                Dim gIDReferto As New Guid(Request.QueryString(Constants.IdReferto))

                Using ta As New SoleTableAdapters.RefertiRiprocessaPerIdRefertoTableAdapter
                    Dim dt As New Sole.RefertiRiprocessaPerIdRefertoDataTable
                    ta.FillByIdReferto(dt, gIDReferto, "DWH-ADMIN: riprocessa referto")
                    Dim oRet = ta.Adapter.SelectCommand.Parameters("@RETURN_VALUE").Value
                    If TypeOf oRet Is Integer Then
                        iRetValue = oRet
                    End If
                End Using

                If iRetValue <> 0 Then
                    Dim sErrMsg As String = String.Format("La procedura ha restituito il codice d'errore {0}.<br/>Il referto potrebbe non essere più presente sul DWH oppure non essere presente nella coda.<br/> Contattare un amministratore.", iRetValue)
                    Utility.ShowErrorLabel(LabelError, sErrMsg)
                    RiprocessaButton.Enabled = False
                    GridViewMain.DataBind()
                Else
                    '
                    ' Mostro ALERT e ricarico la pagina
                    ' Ricarico la pagina aggiungendo DONE_RINOTIFICA=1, questo evita il doppio postback se l'utente preme F5
                    '
                    Dim sUrl As String = Me.ModifyQueryStringParameter(DONE_RINOTIFICA, "1")
                    Dim functionJS As String = "alert('Il referto è stato riprocessato.');"
                    functionJS = functionJS & "window.location='" & sUrl & "';"
                    ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide2", functionJS, True)
                End If


            Catch ex As Exception
                RiprocessaButton.Enabled = False
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub


#Region "Funzioni"

#End Region

    End Class

End Namespace