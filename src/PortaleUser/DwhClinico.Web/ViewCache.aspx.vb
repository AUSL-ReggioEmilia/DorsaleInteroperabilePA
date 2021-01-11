Imports DwhClinico.Web.moRoleManagerUtility
Imports DwhClinico.Web.Utility

Public Class ViewCache
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim sOut As String = String.Empty
        Try
            If Not IsPostBack Then
				'
				' Aggiungo lo script per lo stylesheet
				'
				' PageAddCss(Me)
				'
				'
				'
				Dim sUserName As String = HttpContext.Current.User.Identity.Name.ToUpper()
                For Each oDictionaryEntry As System.Collections.DictionaryEntry In HttpContext.Current.Cache
                    If oDictionaryEntry.Key.ToString.StartsWith("RM_CURRENT_") Then
                        sOut = sOut & oDictionaryEntry.Key.ToString
                        sOut = sOut & "<br/>"

                    End If
                Next
                MainDiv.InnerHtml = sOut
            End If
        Catch ex As Exception
            lblErrore.Visible = True
            lblErrore.Text = ex.Message
        End Try
    End Sub

    Protected Sub cmdCancellaCache_Click(sender As Object, e As EventArgs) Handles cmdCancellaCache.Click
        Try
            For Each oDictionaryEntry As System.Collections.DictionaryEntry In HttpContext.Current.Cache
                If oDictionaryEntry.Key.ToString.StartsWith("RM_CURRENT_") Then
                    HttpContext.Current.Cache.Remove(oDictionaryEntry.Key)
                End If
            Next

        Catch ex As Exception
            lblErrore.Visible = True
            lblErrore.Text = ex.Message
        End Try
    End Sub
End Class