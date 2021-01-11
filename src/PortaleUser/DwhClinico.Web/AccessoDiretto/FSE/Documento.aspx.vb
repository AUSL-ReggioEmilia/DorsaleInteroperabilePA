Imports DI.PortalUser2
Imports DwhClinico.Data

Public Class Documento
	Inherits System.Web.UI.Page

#Region "Property"

#Region "Token"
	Private ReadOnly Property Token As WcfDwhClinico.TokenType
		'
		' Ottiene il token da passare come parametro agli ObjectDataSource all'interno delle tab.
		' Utilizza la property CodiceRuolo per creare il token
		'
		Get
			Dim TokenViewState As WcfDwhClinico.TokenType = TryCast(Me.ViewState("Token"), WcfDwhClinico.TokenType)
			If TokenViewState Is Nothing Then

				TokenViewState = Tokens.GetToken(Me.CodiceRuolo)

				Me.ViewState("Token") = TokenViewState
			End If
			Return TokenViewState
		End Get
	End Property

	Private ReadOnly Property CodiceRuolo As String
		'
		' Salva nel ViewState il codice ruolo dell'utente
		' Utilizzata per creare il token da passare come parametro all'ObjectDataSource all'interno delle tab.
		'
		Get
			Dim sCodiceRuolo As String = Me.ViewState("CodiceRuolo")
			If String.IsNullOrEmpty(sCodiceRuolo) Then
				'
				' Prendo il ruolo dell'utente
				'
				Dim oRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
				Dim oRuoloCorrente As RoleManager.Ruolo = oRoleManagerUtility.RuoloCorrente
				'
				' Salvo in ViewState
				'
				sCodiceRuolo = oRuoloCorrente.Codice
				Me.ViewState("CodiceRuolo") = sCodiceRuolo
			End If

			Return sCodiceRuolo
		End Get
	End Property

	Private ReadOnly Property DescrizioneRuolo As String
		'
		' Salva nel ViewState la descrizione del ruolo dell'utente
		'
		Get
			Dim sDescrizioneRuolo As String = Me.ViewState("DescrizioneRuolo")
			If String.IsNullOrEmpty(sDescrizioneRuolo) Then
				'
				' Prendo il ruolo dell'utente
				'
				Dim oRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
				Dim oRuoloCorrente As RoleManager.Ruolo = oRoleManagerUtility.RuoloCorrente
				'
				' Salvo in ViewState
				'
				sDescrizioneRuolo = oRuoloCorrente.Descrizione
				Me.ViewState("DescrizioneRuolo") = sDescrizioneRuolo
			End If

			Return sDescrizioneRuolo
		End Get
	End Property
#End Region

	Private Property CodiceDocumento() As String
		Get
			Return Me.ViewState("CodiceDocumento")
		End Get
		Set(ByVal value As String)
			Me.ViewState("CodiceDocumento") = value
		End Set
	End Property

	Private Property CodiceFiscaleMedico() As String
		Get
			Return Me.ViewState("CodiceFiscaleMedico")
		End Get
		Set(ByVal value As String)
			Me.ViewState("CodiceFiscaleMedico") = value
		End Set
	End Property

	Private Property CodiceFiscalePaziente() As String
		Get
			Return Me.ViewState("CodiceFiscalePaziente")
		End Get
		Set(ByVal value As String)
			Me.ViewState("CodiceFiscalePaziente") = value
		End Set
	End Property

	Private Property TipoAccesso() As String
		Get
			Return Me.ViewState("TipoAccesso")
		End Get
		Set(ByVal value As String)
			Me.ViewState("TipoAccesso") = value
		End Set
	End Property

	Private Property IdPaziente() As Guid
		Get
			Return CType(Me.ViewState("IdPaziente"), Guid)
		End Get
		Set(ByVal value As Guid)
			Me.ViewState("IdPaziente") = value
		End Set
	End Property

	Private Property ConsensoPaziente() As String
		Get
			Return Me.ViewState("ConsensoPaziente")
		End Get
		Set(ByVal value As String)
			Me.ViewState("ConsensoPaziente") = value
		End Set
	End Property
	Public Property TipoDocumento() As String
		Get
			Return Me.ViewState("TipoDocumento")
		End Get
		Set(ByVal value As String)
			Me.ViewState("TipoDocumento") = value
		End Set
	End Property

	Public Property NaturaDocumento() As String
		Get
			Return Me.ViewState("NaturaDocumento")
		End Get
		Set(ByVal value As String)
			Me.ViewState("NaturaDocumento") = value
		End Set
	End Property

#End Region

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
		Try
			If Not IsPostBack Then
				'
				'Ottengo i parametri
				'
				Me.CodiceFiscalePaziente = Me.Request.QueryString("CodiceFiscalePaziente")
				Me.CodiceFiscaleMedico = Me.Request.QueryString("CodiceFiscaleMedico")
				Me.TipoAccesso = Me.Request.QueryString("TipoAccesso")
				Me.CodiceDocumento = Me.Request.QueryString("CodiceDocumento")
				Me.IdPaziente = New Guid(Me.Request.QueryString("IdPaziente"))
				Me.TipoDocumento = Me.Request.QueryString("TipoDocumento")
				Me.NaturaDocumento = Me.Request.QueryString("NaturaDocumento")

				'testo se l'Id del paziente è valido.
				If Me.IdPaziente <> Guid.Empty Then
					'creo una nuova custom data source per ottenere i dati del paziente.
					Dim customDataSource As New CustomDataSource.PazienteOttieniPerId()
					Dim dettaglioPaziente As WcfDwhClinico.PazienteType = customDataSource.GetData(Me.Token, Me.IdPaziente)

					'testo se il dettaglio del paziente non è vuoto.
					If dettaglioPaziente IsNot Nothing Then
						If dettaglioPaziente.ConsensoAziendale IsNot Nothing Then
							'ottengo la descrizione del consenso del paziente.
							Me.ConsensoPaziente = dettaglioPaziente.ConsensoAziendale.Descrizione
						End If
					End If
				End If

				'Salvo il Token in sessione per poi leggerlo nel DocumentoViewer
				Session("Token") = Me.Token

				'
				'Valorizzo l'url del iframe e eseguo il bind
				'
				IframeMain.Src = String.Format("~/FSE/DocumentoViewer.aspx?CodiceDocumento={0}&CodiceFiscalePaziente={1}&CodiceFiscaleMedico={2}&TipoAccesso={3}&TipoDocumento={4}&NaturaDocumento={5}", Me.CodiceDocumento, Me.CodiceFiscalePaziente, Me.CodiceFiscaleMedico, Me.TipoAccesso, Me.TipoDocumento, Me.NaturaDocumento)
				IframeMain.DataBind()

				'testo se l'Id del paziente è valido.
				'Traccio l'accesso solo se l'id è valido. In questo modo evito di scrivere un record con IdPaziene = '00000000-0000-0000-0000-000000000000'
				If Me.IdPaziente <> Guid.Empty Then
					'Traccio gli accessi
					TracciaAccessi.TracciaAccessiLista(Me.CodiceRuolo, Me.DescrizioneRuolo, "FSE: Accesso Documento. Codice: " & Me.CodiceDocumento, Me.IdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote, 1, Me.ConsensoPaziente)
				End If
			End If

		Catch ex As ApplicationException
			divErrorMessage.Visible = True
			lblErrorMessage.Text = ex.Message

		Catch ex As Exception
			divErrorMessage.Visible = True
			lblErrorMessage.Text = "Si è verificato un errore durante la ricerca dei dati."
			Logging.WriteError(ex, Me.GetType.Name)
		End Try
	End Sub

	Private Sub BtnIndietro_Click(sender As Object, e As EventArgs) Handles BtnIndietro.Click
		Try
			'
			'torno alla pagina precedente
			'
			Response.Redirect("~/AccessoDiretto/FSE/DocumentiLista.aspx?IdPaziente=" & Me.IdPaziente.ToString, False)
		Catch ex As Exception
			divErrorMessage.Visible = True
			lblErrorMessage.Text = "Si è verificato un errore."
			Logging.WriteError(ex, Me.GetType.Name)
		End Try
	End Sub
End Class