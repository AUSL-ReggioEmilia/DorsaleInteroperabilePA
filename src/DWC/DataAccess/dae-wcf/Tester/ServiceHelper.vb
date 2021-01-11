Imports System.Security.Principal
Imports System.ServiceModel
Imports System.Net

Public Class ServiceHelper

	Public Shared Function GetIdentityName() As String

		If ServiceSecurityContext.Current Is Nothing Then

			' Nessun ServiceSecurityContext, uso WindowsIdentity
			Dim userName As String = WindowsIdentity.GetCurrent.Name

			If String.IsNullOrEmpty(userName) Then
				Dim sMessage As String = "Impossibile creare il contesto di sicurezza per l'utente corrente. Contattare l'amministratore di sistema."
				Throw New ApplicationException(sMessage)
			End If

			Return userName
		Else
			' Cerco nel contesto di WCF
			Return ServiceSecurityContext.Current.WindowsIdentity.Name
		End If

	End Function

	Public Shared Function GetClientPcName() As String

		If OperationContext.Current Is Nothing Then

			' Nessun OperationContext, uso il nome del server
			Dim computerName As String = My.Computer.Name

			If String.IsNullOrEmpty(computerName) Then
				Dim sMessage As String = "Impossibile ottenere OperationContext. Contattare l'amministratore di sistema."
				Throw New ApplicationException(sMessage)
			End If

			Return computerName
		Else
			' Cerco nel contesto di WCF
			Dim messagePropertyRemoteEndpoint As Channels.RemoteEndpointMessageProperty
			Dim sRemoteEndpoint = Channels.RemoteEndpointMessageProperty.Name

			messagePropertyRemoteEndpoint = TryCast(OperationContext.Current.IncomingMessageProperties(sRemoteEndpoint), Channels.RemoteEndpointMessageProperty)
			If messagePropertyRemoteEndpoint IsNot Nothing Then

				'Se localhost torna il server
				Dim sIpAddress As String = messagePropertyRemoteEndpoint.Address

				Dim computerName As String = Net.Dns.GetHostEntry(sIpAddress).HostName
				If String.IsNullOrEmpty(computerName) Then
					Return sIpAddress
				Else
					Return computerName
				End If
			Else
				Return Nothing
			End If
		End If

	End Function


	''' <summary>
	''' Reimposta le credenziali di autenticazione al webservice
	''' </summary>
	''' <param name="oEndPointBinding">passare: oWs.ChannelFactory.Endpoint.Binding</param>
	''' <param name="oCredentials">passare: oWs.ClientCredentials</param>
	''' <param name="sUser">Nome Utente</param>
	''' <param name="sPassword">Password</param>
	Public Shared Sub SetWCFCredentials(oEndPointBinding As ServiceModel.Channels.Binding, oCredentials As ServiceModel.Description.ClientCredentials, sUser As String, sPassword As String)
		Dim sErrorMsg As String = String.Empty
		Dim oBasicHttpBinding As BasicHttpBinding = TryCast(oEndPointBinding, BasicHttpBinding)
		If oBasicHttpBinding IsNot Nothing Then
			Dim oCredType = oBasicHttpBinding.Security.Transport.ClientCredentialType
			If oCredType = HttpClientCredentialType.Basic Then
				' Autenticazione BASIC
				oCredentials.UserName.UserName = sUser
				oCredentials.UserName.Password = sPassword
				oBasicHttpBinding.UseDefaultWebProxy = False
				Exit Sub
			ElseIf oCredType = HttpClientCredentialType.Windows Then
				' Autenticazione WINDOWS
				' Se non ho fornito user e password lascio fare al sistema.
				If Not String.IsNullOrEmpty(sUser) AndAlso Not String.IsNullOrEmpty(sPassword) Then
					oCredentials.Windows.ClientCredential = GetNetworkCredential(sUser, sPassword)
				End If
				Exit Sub
			Else
				sErrorMsg = String.Format("Il tipo di credenziali 'HttpClientCredentialType.{0}' non è gestito!", oCredType.ToString)
				sErrorMsg = sErrorMsg & vbCrLf & _
				   "I tipi di credenziali gestiti sono: 'HttpClientCredentialType.Basic', 'HttpClientCredentialType.Windows'."
				Throw New ApplicationException(sErrorMsg)
			End If
		End If
		Dim oWSHttpBinding As WSHttpBinding = TryCast(oEndPointBinding, WSHttpBinding)
		If oWSHttpBinding IsNot Nothing Then
			Dim oCredType = oWSHttpBinding.Security.Transport.ClientCredentialType
			If oCredType = HttpClientCredentialType.Basic Then
				' Autenticazione BASIC
				oCredentials.UserName.UserName = sUser
				oCredentials.UserName.Password = sPassword
				oWSHttpBinding.UseDefaultWebProxy = False
				Exit Sub
			ElseIf oCredType = HttpClientCredentialType.Windows Then
				' Autenticazione WINDOWS
				' Se non ho fornito user e password lascio fare al sistema.
				If Not String.IsNullOrEmpty(sUser) AndAlso Not String.IsNullOrEmpty(sPassword) Then
					oCredentials.Windows.ClientCredential = GetNetworkCredential(sUser, sPassword)
				End If
				Exit Sub
			Else
				sErrorMsg = String.Format("Il tipo di credenziali 'HttpClientCredentialType.{0}' non è gestito!", oCredType.ToString)
				sErrorMsg = sErrorMsg & vbCrLf & _
				   "I tipi di credenziali gestiti sono: 'HttpClientCredentialType.Basic', 'HttpClientCredentialType.Windows'."
				Throw New ApplicationException(sErrorMsg)
			End If
		End If
		'
		' Se sono qui il tipo di binding non è gestito
		'
		'sErrorMsg = String.Format("Il tipo di binding '{0}' non è gestito!", oEndPointBinding.ToString)
		'sErrorMsg = sErrorMsg & vbCrLf & _
		'  "Utilizzare il tipo di binding 'BasicHttpBinding'/'WsHttpBinding'."
		'Throw New ApplicationException(sErrorMsg)
	End Sub

	Private Shared Function GetNetworkCredential(ByVal sUser As String, ByVal sPassword As String) As NetworkCredential

		Dim credentials As NetworkCredential

		If sUser.Length > 0 Then
			'Basic autentication                
			Dim domain As String = String.Empty
			Dim account As String() = sUser.Replace("\", "/").Split("/"c)

			If account.Length > 1 Then
				domain = account(0)
				sUser = account(1)
			End If

			credentials = New NetworkCredential(sUser, sPassword, domain)
		Else
			'Integrated autentication                
			credentials = CType(CredentialCache.DefaultCredentials(), NetworkCredential)
		End If

		Return credentials
	End Function

End Class
