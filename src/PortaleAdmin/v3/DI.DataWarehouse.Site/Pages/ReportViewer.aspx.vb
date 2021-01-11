Imports System
Imports System.Web.UI
Imports System.Configuration
Imports DI.DataWarehouse.Admin.Data
Imports DI.PortalAdmin.Data

Namespace DI.DataWarehouse.Admin

    Public Class ReportViewer
        Inherits Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
            Dim urlContent As String = String.Empty

            Try

				Dim repository = Request("repository") 'di, dwh, url
                Dim reportName = Request("reportName")

				If reportName Is Nothing Then
					Return
				End If

				Dim url As String

				Select Case repository
					Case "di" 'reporting admin
						url = String.Format(My.Settings.ReportingUrl, reportName)
					Case "dwh" 'reporting user
						url = String.Format(My.Settings.ReportingDwhUrl, reportName)
					Case Else
						url = reportName
				End Select

				Try
					If url.StartsWith("http") Then
						urlContent = Me.ResolveUrl(url)
					Else 'percorso relativo all'app dwh
                        urlContent = Me.ResolveUrl("~/" & url)
                    End If

                Catch ex As Exception
                    Throw New ApplicationException(String.Format("Si è verificato un errore durante la risoluzione dell'url ""{0}"". Contattare l'amministratore.", url))
                End Try


                Me.IframeMain.Attributes.Add("src", urlContent)
                DataAdapterManager.PortalAdminDataAdapterManager.TracciaAccessi(User.Identity.Name, PortalsNames.DwhClinico, "Report visualizzato: " & reportName)

            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

    End Class

End Namespace