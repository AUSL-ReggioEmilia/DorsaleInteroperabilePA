Imports DI.PortalUser2
Imports DwhClinico.Data
Imports DwhClinico.Web.Utility

Partial Class AccessoDiretto_ApreAllegato
    Inherits System.Web.UI.Page

#Region "Property"
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
        'USA DI.PORTALUSER -> Tutte le property "CodiceRuolo" utilizzate nell'accesso standard e accesso diretto
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
#End Region

#Region " Web Form Designer Generated Code "

    'This call is required by the Web Form Designer.
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()

    End Sub


    Private Sub Page_Init(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Init
        'CODEGEN: This method call is required by the Web Form Designer
        'Do not modify it using the code editor.
        InitializeComponent()
    End Sub

#End Region

    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        Dim IdEsterno As String = String.Empty
        Dim IdAllegato As String = String.Empty
        Dim sIdReferto As String = String.Empty
        Dim IdReferto As System.Guid
        Try
            IdEsterno = Request.QueryString(PAR_ID_ESTERNO_ALLEGATO)
            IdAllegato = Request.QueryString(PAR_ID_ALLEGATO)
            If String.IsNullOrEmpty(IdEsterno) Then
                If String.IsNullOrEmpty(IdAllegato) Then
                    Throw New ApplicationException(String.Format("I parametri non sono validi. Almeno uno tra i parametri {0} e {1} deve essere valorizzato.", PAR_ID_ESTERNO_ALLEGATO, PAR_ID_ALLEGATO))
                End If
            End If

            sIdReferto = Request.QueryString(PAR_ID_REFERTO)
            If String.IsNullOrEmpty(sIdReferto) Then
                'sIdReferto = SessionHandler.AccessoDirettoIdReferto
                sIdReferto = SessionHandler.IdReferto
                If String.IsNullOrEmpty(sIdReferto) Then
                    Throw New ApplicationException(String.Format("Il parametro '{0}' non è valido", PAR_ID_REFERTO))
                End If
            End If

            '
            ' Verifico che i parametri siano valorizzati
            '
            IdReferto = New Guid(sIdReferto)


            Dim RefertoOttieniPerId As New CustomDataSource.AccessoDirettoRefertoOttieniPerId
            If Not String.IsNullOrEmpty(sIdReferto) Then
                Dim dettaglioReferto As WcfDwhClinico.RefertoType = RefertoOttieniPerId.GetData(Me.Token, IdReferto)
                If Not dettaglioReferto Is Nothing Then
                    If Not dettaglioReferto.Allegati Is Nothing Then
                        Dim allegati As New List(Of WcfDwhClinico.AllegatoType)
                        If Not String.IsNullOrEmpty(IdAllegato) Then
                            allegati = (From c In dettaglioReferto.Allegati Where String.Compare(c.Id, IdAllegato, True) = 0).ToList
                        ElseIf Not String.IsNullOrEmpty(IdEsterno) Then
                            allegati = (From c In dettaglioReferto.Allegati Where String.Compare(c.IdEsterno, IdEsterno, True) = 0).ToList
                        End If
                        Dim allegatoCorrente As WcfDwhClinico.AllegatoType = CType(allegati(0), WcfDwhClinico.AllegatoType)
                        If Not allegatoCorrente Is Nothing AndAlso allegatoCorrente.Contenuto.GetLength(0) > 0 Then
                            '
                            ' Toglie directory dal nome
                            '
                            Dim oFileInfo As System.IO.FileInfo
                            oFileInfo = New System.IO.FileInfo(allegatoCorrente.NomeFile)
                            Dim sFileName As String = oFileInfo.Name()
                            '
                            ' Scrivo il contenuto binario
                            '
                            Response.Expires = 0
                            Response.Clear()
                            Response.BufferOutput = True
                            Response.ContentType = allegatoCorrente.TipoContenuto
                            Response.AddHeader("content-disposition", "inline; filename=" & sFileName)
                            Response.BinaryWrite(allegatoCorrente.Contenuto)
                        End If
                    End If
                End If
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            Call Response.Write(FormatError("Si è verificato un errore durante la visualizzazione dell'allegato!"))
            Logging.WriteError(ex, Me.GetType.Name)
        Finally
        End Try
    End Sub

    Private Function FormatError(ByVal sMsg As String) As String
        Return String.Format("<div style=""color: red; font-weight: bold; font-size: 11px; font-family: verdana, helvetica, arial, sans-serif;"">{0}</div>", sMsg)
    End Function


End Class
