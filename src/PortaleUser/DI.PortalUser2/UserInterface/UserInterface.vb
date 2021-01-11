Imports System.Net.NetworkInformation
Imports System.Reflection
Imports System.IO
Imports System

Namespace DI.PortalUser2

	Public Class UserInterface

		Private Const _StyleVisibile = "display:block;"
		Private Const _StyleNascosto = "display:none;"

		Private connectionStringPortalUser As String


        Public Sub New()
        End Sub

        Public Sub New(PortalUserConnectionString As String)
			connectionStringPortalUser = PortalUserConnectionString
		End Sub
#Region "Public"

		''' <summary>
		''' Crea l'header per i portali Bootstrap
		''' </summary>
		''' <param name="BannerTitle"></param>
		''' <param name="PathFolderDocumenti"></param>
		''' <param name="PathFolderImmagini"></param>
		''' <returns></returns>
		Public Function GetBootstrapHeader(ByVal BannerTitle As String, ByVal PathFolderDocumenti As String, ByVal PathFolderImmagini As String) As String
			Dim result As String = String.Empty
			Try
				Dim bootstrapHeader = GetEmbeddedResource("headerBootstrap.htm")
				result = String.Format(bootstrapHeader, PathFolderImmagini, BannerTitle, PathFolderDocumenti)
			Catch ex As Exception
			End Try
			Return result
		End Function

		Public Function GetBootstrapHeader2(ByVal BannerTitle As String) As String
			Dim sMenu As String = String.Empty

			Dim bootstrapHeader = GetEmbeddedResource("headerBootstrap.htm")

			Using ta As New ConfigurazioniDataSetTableAdapters.ConfigurazioniOttieniBySessioneTableAdapter(connectionStringPortalUser)
				Dim dt As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneDataTable = ta.GetData("MenuPortali")

				If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
					Dim subtitle As String = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "Subtitle" Select configurazione.ValoreString).FirstOrDefault
					Dim linkPortale As String = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "LinkPortaleClinico" Select configurazione.ValoreString).FirstOrDefault
					Dim linkMailReferenti As String = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "LinkMailReferenti" Select configurazione.ValoreString).FirstOrDefault

					Dim linkMailReferentiVisibile As Boolean = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "LinkMailReferentiVisibile" Select configurazione.ValoreBoolean).FirstOrDefault
					Dim linkMailReferentiVisibileStyle = String.Empty
					If Not linkMailReferentiVisibile Then
						linkMailReferentiVisibileStyle = _StyleNascosto
					End If

					Dim linkPortaleVisibile As Boolean = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "LinkPortaleClinicoVisibile" Select configurazione.ValoreBoolean).FirstOrDefault
					Dim linkPortaleVisibileStyle = String.Empty
					If Not linkPortaleVisibile Then
						linkPortaleVisibileStyle = _StyleNascosto
					End If

					Dim linkInformativaVisibile As Boolean = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "LinkInformativaVisibile" Select configurazione.ValoreBoolean).FirstOrDefault
					Dim linkInformativaVisibileStyle = String.Empty
					If Not linkInformativaVisibile Then
						linkInformativaVisibileStyle = _StyleNascosto
					End If

					Dim linkMailReferentiTooltip As String = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "LinkMailReferentiTooltip" Select configurazione.ValoreString).FirstOrDefault
					Dim linkPortaleClinicoTooltip As String = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "LinkPortaleClinicoTooltip" Select configurazione.ValoreString).FirstOrDefault
					Dim linkInformativaTooltip As String = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "LinkInformativaTooltip" Select configurazione.ValoreString).FirstOrDefault




					sMenu = String.Format(bootstrapHeader, BannerTitle, subtitle, linkPortale, linkMailReferenti, linkMailReferentiVisibileStyle, linkPortaleVisibileStyle, linkInformativaVisibileStyle, linkMailReferentiTooltip, linkPortaleClinicoTooltip, linkInformativaTooltip, GetURLInformazioni())
				End If
			End Using

			Return sMenu
		End Function

		''' <summary>
		''' Ottiene l'URL della pagina informazioni del portale home ADMIN
		''' </summary>
		''' <returns></returns>
		Public Function GetURLInformazioni() As String

			Using ta As New ConfigurazioniDataSetTableAdapters.ConfigurazioneMenuListaTableAdapter(connectionStringPortalUser)
				Dim dt As ConfigurazioniDataSet.ConfigurazioneMenuListaDataTable = ta.GetData()

				Dim items = dt.ToList()

				Return items.Where(Function(x) x.Titolo = "Informazioni").SingleOrDefault().Url
			End Using

		End Function
#End Region


#Region "Private"

		Public Function GetLocalhostFqdn() As String

			Dim oProperties = IPGlobalProperties.GetIPGlobalProperties()
			Return String.Format("{0}.{1}", oProperties.HostName, oProperties.DomainName)

		End Function


		Private Function GetEmbeddedResource(ResourceName As String) As String
			Dim oAssembly = Assembly.GetExecutingAssembly()
			Dim sRet As String = String.Empty

			Using stream As IO.Stream = oAssembly.GetManifestResourceStream(ResourceName)
				Using reader As New StreamReader(stream)
					sRet = reader.ReadToEnd()
				End Using
			End Using

			Return sRet
		End Function

#End Region

	End Class


End Namespace

