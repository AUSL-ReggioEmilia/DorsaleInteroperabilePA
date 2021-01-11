Imports System
Imports System.Web.UI

Namespace DI.DataWarehouse.Admin

    Partial Class StiliLista
        Inherits Page

        Private mPageId As String = Me.GetType().Name

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            Page.SetFocus(Me.CercaButton)

        End Sub

        Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
            Try
                If Not Page.IsPostBack Then
                    FilterHelper.Restore(Me, mPageId)
                    'rieseguo la ricerca se ho recuperato qualcosa dai filtri precedentemente impostati
                    If NomeTextBox.Text.Length > 0 Or DescrizioneTextBox.Text.Length > 0 Then
                        GridViewMain.DataBind()
                    End If
                End If

            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Protected Sub CercaButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles CercaButton.Click
            Try
                FilterHelper.SaveInSession(Me, mPageId)
                DataSourceMain.DataBind()
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Protected Sub NewButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles NewButton.Click

            Response.Redirect(Me.ResolveUrl("~/Pages/StiliDettaglio.aspx"), False)

        End Sub
        Protected Function GetTipo(ByVal Tipo As Integer) As String
            Dim sReturn As String = String.Empty
            Try
                'MOSTRO LA DESCRIZIONE DEL TIPO.
                Select Case Tipo
                    Case Constants.COMBO_TIPO_INTERNO_WS2_ITEM_VALUE '1
                        sReturn = String.Concat(Constants.COMBO_TIPO_INTERNO_WS2_ITEM_TEXT, String.Format(" ({0})", Tipo))
                    Case Constants.COMBO_TIPO_ESTERNO_ITEM_VALUE '2
                        sReturn = String.Concat(Constants.COMBO_TIPO_ESTERNO_ITEM_TEXT, String.Format(" ({0})", Tipo))
                    Case Constants.COMBO_TIPO_PDF_ITEM_VALUE '3
                        sReturn = String.Concat(Constants.COMBO_TIPO_PDF_ITEM_TEXT, String.Format(" ({0})", Tipo))
                    Case Constants.COMBO_TIPO_INTERNO_WS3_ITEM_VALUE '4
                        sReturn = String.Concat(Constants.COMBO_TIPO_INTERNO_WS3_ITEM_TEXT, String.Format(" ({0})", Tipo))
                    Case Else
                        sReturn = Tipo.ToString
                End Select
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
                sReturn = String.Empty
            End Try

            Return sReturn
        End Function

    End Class
End Namespace