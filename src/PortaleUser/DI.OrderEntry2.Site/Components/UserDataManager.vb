Imports DI.OrderEntry.Services
Imports DI.OrderEntry.User.Data
Imports DI.PortalUser2

Namespace DI.OrderEntry.User

    Public Class UserData

        Private _token As TokenAccessoType

        Public ReadOnly Property Token As TokenAccessoType
            Get
                Return _token
            End Get
        End Property

        Public Sub New(token As TokenAccessoType)
            _token = token
        End Sub
    End Class

    Public Class UserDataManager

        Private Sub New()

        End Sub

        Public Shared Function GetUserData() As UserData

            Dim userData = HttpContext.Current.Session("UserData")

            'tolgo alla data di scadenza n minuti, se la data di scadenza anticipata è minore o uguale alla data/ora di adesso ricreo il token
            If userData Is Nothing OrElse userData.Token Is Nothing OrElse userData.Token.DataScadenza.AddMinutes(-10) <= DateTime.Now Then
                userData = CreateUserData(GetToken())
            End If

            Return userData

        End Function

        Private Shared Function GetToken() As TokenAccessoType

            Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                Return webService.CreaTokenAccessoDelega2(New CreaTokenAccessoDelega2Request(My.User.Name, DI.Common.Utility.GetAziendaRichiedente2(), My.Settings.SistemaRichiedente, Utility.GetUserHostName)).CreaTokenAccessoDelega2Result

            End Using

        End Function

        Private Shared Function CreateUserData(token As TokenAccessoType) As UserData

            Dim userData = New UserData(token)
            HttpContext.Current.Session("UserData") = userData

            Return userData
        End Function

        Public Shared Function GetDettaglioUtente(username As String) As RoleManager.Utente
            Dim oRet As RoleManager.Utente

            If HttpContext.Current.Session("ADUserInfo") Is Nothing Then
                oRet = DataAdapterManager.DataAccess.UtenteOttieniDettaglio(username)
                HttpContext.Current.Session.Add("ADUserInfo", oRet)
            Else
                oRet = DirectCast(HttpContext.Current.Session("ADUserInfo"), RoleManager.Utente)
            End If

            Return oRet

        End Function


        'Public Shared Function GetUserPcRichiedente() As String

        '	Dim sPcRichiedente As String = String.Empty
        '	Dim sIpAddress As String = String.Empty

        '	If HttpContext.Current.Session("PcRichiedente") Is Nothing Then

        '		Dim request As HttpRequest = HttpContext.Current.Request

        '		Try
        '			'IP of the remote client use
        '			sIpAddress = request.UserHostAddress

        '			'DNS name of the remote client use
        '			sPcRichiedente = request.UserHostName()

        '			If String.IsNullOrEmpty(sPcRichiedente) OrElse (sPcRichiedente = sIpAddress) Then
        '				If Not String.IsNullOrEmpty(sIpAddress) Then
        '					sPcRichiedente = Net.Dns.GetHostEntry(sIpAddress).HostName
        '				End If
        '			End If

        '		Catch ex As Exception
        '			If String.IsNullOrEmpty(sPcRichiedente) Then
        '				sPcRichiedente = sIpAddress
        '			End If
        '		End Try

        '		If Not String.IsNullOrEmpty(sPcRichiedente) Then
        '			HttpContext.Current.Session.Add("PcRichiedente", sPcRichiedente)
        '		End If

        '	Else
        '		sPcRichiedente = DirectCast(HttpContext.Current.Session("PcRichiedente"), String)
        '	End If

        '	Return sPcRichiedente

        'End Function

    End Class



End Namespace