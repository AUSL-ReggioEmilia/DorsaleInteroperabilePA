Imports System.Collections.Generic
Imports System.Web.Routing
Imports System.Web.UI
Imports DI.OrderEntry.Services
Imports DI.OrderEntry.User
Imports DI.PortalUser2.Data

Public Class ucToolbar
    Inherits System.Web.UI.UserControl

#Region "Property"
    Public Property IsAccessoDiretto() As Boolean
        Get
            Return Me.ViewState("IsAccessoDiretto")
        End Get
        Set(ByVal value As Boolean)
            Me.ViewState.Add("IsAccessoDiretto", value)
        End Set
    End Property

    Public Property IdRichiesta() As String
        Get
            Return Me.ViewState("IdRichiesta")
        End Get
        Set(ByVal value As String)
            Me.ViewState.Add("IdRichiesta", value)
        End Set
    End Property

    Public Property IdPaziente() As String
        Get
            Return Me.ViewState("IdPaziente")
        End Get
        Set(ByVal value As String)
            Me.ViewState.Add("IdPaziente", value)
        End Set
    End Property

    Public Property Nosologico() As String
        Get
            Return Me.ViewState("Nosologico")
        End Get
        Set(ByVal value As String)
            Me.ViewState.Add("Nosologico", value)
        End Set
    End Property

    Public Property CurrentStep() As Integer
        Get
            Return Me.ViewState("CurrentStep")
        End Get
        Set(ByVal value As Integer)
            Me.ViewState.Add("CurrentStep", value)
        End Set
    End Property

    Public Property IsEliminabile() As Boolean
        Get
            Return Me.ViewState("IsEliminabile")
        End Get
        Set(ByVal value As Boolean)
            Me.ViewState.Add("IsEliminabile", value)
        End Set
    End Property

#End Region

    Private Sub btnEliminaRichiesta_Click(sender As Object, e As EventArgs) Handles btnEliminaRichiesta.Click
        Try
            EliminaRichiesta(IdRichiesta)

            '
            '2020-07-16 Kyrylo: Traccia Operazioni 
            '
            Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalUser)
            oTracciaOp.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Eliminato Ordine", New Guid(IdPaziente), Nothing, IdRichiesta, "IdRichiesta")


            If Not Me.IsAccessoDiretto Then
                Response.Redirect(Utility.buildUrl("~/Pages/Home.aspx", Me.IsAccessoDiretto))
            Else
                Response.Redirect(Utility.buildUrl("~/Pages/AccessoDirettoMessage.aspx?mode=Deleted", Me.IsAccessoDiretto))
            End If

        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
        End Try
    End Sub

    Private Sub btnAvanti_Click(sender As Object, e As EventArgs) Handles btnAvanti.Click
        Try
            If Me.CurrentStep = 2 Then '2 = ComposizioneOrdine
                DirectCast(Me.Page, Object).Avanti()
            End If
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
        End Try
    End Sub

    Public Function StringJavascriptClenaup(input As String) As String
        Dim output As String

        output = input.Replace(vbCrLf, "<br />")
        output = output.Replace("'", "\'")

        Return output

    End Function

    Private Sub ucToolbar_Load(sender As Object, e As EventArgs) Handles Me.Load
        Try
            If Me.CurrentStep = 2 Then '2 = ComposizioneOrdine
                btnAvanti.CausesValidation = True
                btnAvanti.ValidationGroup = "vldDataPrenotazione"
            ElseIf Me.CurrentStep = 3 Then '3 = DatiAccessori
                btnEliminaRichiesta.Visible = False
            ElseIf Me.CurrentStep = 4 Then '4 = confermaInoltro
                btnAvanti.Visible = False
                btnInoltra.Visible = True
                btnInoltraEStampaOrdine.Visible = True
                btnSalvaOrdineInBozza.Visible = True
            ElseIf Me.CurrentStep = 5 Then '5 = riassuntoOrdine
                realIndietroButton.Visible = False
                btnAvanti.Visible = False
                btnScaricaOrdine.Visible = True
                btnStampaOrdine.Visible = True
                'Abilito o disabilito il tasto "Elimina"
                If Not IsEliminabile Then
                    btnEliminaRichiesta.Enabled = False
                    btnEliminaRichiesta.Attributes.Add("disabled", "true")
                Else
                    btnEliminaRichiesta.Enabled = True
                    btnEliminaRichiesta.Attributes.Remove("disabled")
                End If

            End If

        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
        End Try
    End Sub

    Private Sub realIndietroButton_Click(sender As Object, e As EventArgs) Handles realIndietroButton.Click
        Try
            Dim parametri As String = $"?IdRichiesta={Me.IdRichiesta}&IdPaziente={Me.IdPaziente}"
            If Not String.IsNullOrEmpty(Me.Nosologico) Then
                parametri += $"&Nosologico={Me.Nosologico}"
            End If
            If Me.CurrentStep = 2 Then
                Response.Redirect(Utility.buildUrl($"~/Pages/Home.aspx", Me.IsAccessoDiretto))
            End If
            If Me.CurrentStep = 3 Then
                DirectCast(Me.Page, Object).SalvaDati(Me.IdRichiesta)
                Response.Redirect(Utility.buildUrl($"~/Pages/ComposizioneOrdine.aspx{parametri}", Me.IsAccessoDiretto))
            End If
            If Me.CurrentStep = 4 Then
                ' 2020-01-20 Kyrylo : Se da QueryString è presente il parametro ShowPannelloPaziente allora lo aggiungo all'url della pagina precedente
                If Me.IsAccessoDiretto Then
                    Dim showPannelloPaziente As String = Request.QueryString("ShowPannelloPaziente")
                    If Not String.IsNullOrEmpty(showPannelloPaziente) Then
                        Dim bShowPannelloPaziente As Boolean = True
                        If Boolean.TryParse(showPannelloPaziente, bShowPannelloPaziente) Then
                            parametri += $"&ShowPannelloPaziente={bShowPannelloPaziente}"
                        End If
                    End If
                End If

                If DirectCast(Me.Page, Object).HasDatiAccessori = True Then
                    Response.Redirect(Utility.buildUrl($"~/Pages/DatiAccessori.aspx{parametri}", Me.IsAccessoDiretto))
                Else
                    Response.Redirect(Utility.buildUrl($"~/Pages/ComposizioneOrdine.aspx{parametri}", Me.IsAccessoDiretto))
                End If

            End If
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
        End Try
    End Sub

    Private Sub btnInoltra_Click(sender As Object, e As EventArgs) Handles btnInoltra.Click
        Try
            DirectCast(Me.Page, Object).Inoltra()
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
        End Try
    End Sub

    Private Sub btnInoltraEStampaOrdine_Click(sender As Object, e As EventArgs) Handles btnInoltraEStampaOrdine.Click
        Try
            DirectCast(Me.Page, Object).InoltraEStampa()
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
        End Try
    End Sub

    Private Sub btnScaricaOrdine_Click(sender As Object, e As EventArgs) Handles btnScaricaOrdine.Click
        Try
            Response.Redirect($"~\Reports\ReportPdfDownLoad.aspx?idOrdine={Me.IdRichiesta}")
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
        End Try
    End Sub

    Private Sub btnSalvaOrdineInBozza_Click(sender As Object, e As EventArgs) Handles btnSalvaOrdineInBozza.Click
        Try
            DirectCast(Me.Page, Object).Salva()
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
        End Try
    End Sub

    Private Sub btnStampaOrdine_Click(sender As Object, e As EventArgs) Handles btnStampaOrdine.Click
        Try
            Response.Redirect($"~\Reports\StampaOrdine.aspx?IdRichiesta={Me.IdRichiesta}", False)
            'Response.Redirect($"~\Reports\ReportPdfViewer.aspx?idOrdine={Me.IdRichiesta}")
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
        End Try
    End Sub


    Private Sub EliminaRichiesta(idRichiesta As String)
        Try
            Dim userData = UserDataManager.GetUserData()
            Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                Dim result As CancellaOrdinePerIdGuidResponse = webService.CancellaOrdinePerIdGuid(New CancellaOrdinePerIdGuidRequest(userData.Token, idRichiesta))
                If result.CancellaOrdinePerIdGuidResult.StatoValidazione.Stato <> StatoValidazioneEnum.AA Then
                    Throw New Exception(result.CancellaOrdinePerIdGuidResult.StatoValidazione.Descrizione)
                End If
            End Using
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            Throw
        End Try
    End Sub
End Class