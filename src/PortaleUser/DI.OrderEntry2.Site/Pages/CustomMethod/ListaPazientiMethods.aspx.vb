Imports System
Imports System.Web
Imports System.Web.UI
Imports System.Web.Services
Imports DI.OrderEntry.SacServices
Imports System.Linq
Imports System.Net
Imports System.Collections.Generic
Imports DI.OrderEntry.User.Data
Imports DI.PortalUser2
Imports DI.PortalUser2.Data
Imports System.ComponentModel

Namespace DI.OrderEntry.User

    Public Class ListaPazientiMethods
        Inherits Page

#Region "Public Property"

        Public Shared MAX_NUM_RECORD As Integer = 50

        Public Shared ReadOnly Property Token As WcfDwhClinico.TokenType
            '
            ' Ottiene il token da passare come parametro agli ObjectDataSource all'interno delle tab.
            ' Utilizza la property CodiceRuolo per creare il token
            '
            Get
                Dim TokenViewState As WcfDwhClinico.TokenType = Tokens.GetToken(CodiceRuolo)

                Return TokenViewState
            End Get
        End Property

        Public Shared ReadOnly Property CodiceRuolo As String
            '
            ' Salva nel ViewState il codice ruolo dell'utente
            ' Utilizzata per creare il token da passare come parametro all'ObjectDataSource all'interno delle tab.
            '
            Get
                Dim sCodiceRuolo As String = String.Empty
                '
                ' Prendo il ruolo dell'utente
                '
                Dim oRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
                Dim oRuoloCorrente As RoleManager.Ruolo = oRoleManagerUtility.RuoloCorrente
                '
                ' Salvo in ViewState
                '
                sCodiceRuolo = oRuoloCorrente.Codice

                Return sCodiceRuolo
            End Get
        End Property

        Public Shared ReadOnly Property DescrizioneRuolo As String
            '
            ' Salva nel ViewState la descrizione del ruolo dell'utente
            '
            Get
                Dim sDescrizioneRuolo As String = String.Empty
                '
                ' Prendo il ruolo dell'utente
                '
                Dim oRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
                Dim oRuoloCorrente As RoleManager.Ruolo = oRoleManagerUtility.RuoloCorrente
                '
                ' Salvo in ViewState
                '
                sDescrizioneRuolo = oRuoloCorrente.Descrizione

                Return sDescrizioneRuolo
            End Get
        End Property

#End Region

        Private Const _pageSessionIdPrefix As String = "ListaPazienti_"

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

        End Sub

        '<WebMethod()>
        '<DataObjectMethod(DataObjectMethodType.Select)>
        'Public Shared Function GetLookupTipiRicoveri(AziendaUnitaOperativa As String) As List(Of RoleManager.Regime)

        '    Dim CodiceAzienda As String = AziendaUnitaOperativa.Split("-")(0)
        '    Dim CodiceUnitaOperativa As String = AziendaUnitaOperativa.Substring(AziendaUnitaOperativa.IndexOf("-") + 1)
        '    If CodiceAzienda = "*" Then CodiceAzienda = Nothing
        '    If CodiceUnitaOperativa = "*" Then CodiceUnitaOperativa = Nothing
        '    Return DataAdapterManager.GetRegimiDiRicoveroPerUO(CodiceAzienda, CodiceUnitaOperativa)

        'End Function

        '<WebMethod()>
        'Public Shared Function GetPazientiSac(cognome As String, nome As String, dataNascita As String, luogoNascita As String, codiceFiscale As String) As Object
        '    Try
        '        Using webService As New PazientiSoapClient("PazientiSoap")

        '            If String.IsNullOrEmpty(dataNascita) Then
        '                dataNascita = Nothing
        '            Else
        '                Dim dataDiNascita As DateTime
        '                If DateTime.TryParse(dataNascita, dataDiNascita) Then
        '                    dataNascita = dataDiNascita.ToString("yyyy-MM-dd")
        '                Else
        '                    dataNascita = Nothing
        '                End If
        '            End If

        '            Dim request = New DI.OrderEntry.SacServices.PazientiCercaRequest(cognome & "*", nome & "*", dataNascita, luogoNascita & "*", codiceFiscale, "", 500)
        '            Dim response = webService.PazientiCerca(request)
        '            Dim pazienti As PazientiCercaResponsePazientiCerca() = response.PazientiCercaResult
        '            Dim returnValue = Nothing

        '            '
        '            '2017-03-31 - SimoneB
        '            'Testo se la lista dei pazienti non è vuota. 
        '            'Se la lista è vuota viene restituito nothing e il codice javascript scrive nella pagina "Nessun Risultato".
        '            '
        '            If Not pazienti Is Nothing AndAlso pazienti.Length > 0 Then
        '                returnValue = From result In pazienti.Take(110)
        '                              Order By result.Cognome, result.Nome
        '                              Select New With {
        '                                   .Id = result.Id,
        '                                   .Cognome = result.Cognome,
        '                                   .Nome = result.Nome,
        '                                   .Data_di_nascita = result.DataNascita.ToString("d"),
        '                                   .Comune_di_nascita = result.ComuneNascitaNome,
        '                                   .Sesso = result.Sesso,
        '                                   .Codice_fiscale = result.CodiceFiscale
        '                                  }
        '            End If


        '            Return returnValue
        '        End Using

        '    Catch ex As WebException

        '        Select Case ex.Status

        '            Case WebExceptionStatus.Timeout

        '                Return "timeout"
        '        End Select

        '        ExceptionsManager.TraceException(ex)
        '        Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
        '        portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

        '        Throw
        '    Catch ex As Exception

        '        ExceptionsManager.TraceException(ex)
        '        Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
        '        portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

        '        Throw
        '    End Try
        'End Function

        '''' <summary>
        '''' Ottiene la lista dei pazienti ricoverati
        '''' </summary>
        '''' <param name="cognome"></param>
        '''' <param name="nome"></param>
        '''' <param name="uo"></param>
        '''' <param name="tipoRicovero"></param>
        '''' <param name="idStatoEpisodio"></param>
        '''' <returns></returns>
        '<WebMethod()>
        'Public Shared Function GetPazientiDwh(cognome As String, nome As String, uo As String, tipoRicovero As String, idStatoEpisodio As Integer) As Object
        '    Try

        '        Dim dataDimissioneDal As DateTime = DateTime.Now.AddDays(Int32.Parse(My.Settings.IntervalloChiusuraRicovero) * -1)
        '        Dim RepartiRicovero As New WcfDwhClinico.RepartiParam
        '        Dim aziendacodice = uo.Split("-")(0)
        '        Dim repartocodice = uo.Substring(uo.IndexOf("-") + 1)

        '        Dim pazientiRicoverati As New WcfDwhClinico.PazientiListaType
        '        Dim DataConclusione As Nullable(Of Date) = Nothing
        '        Dim consenso As Nullable(Of Boolean) = Nothing

        '        If SessionHandler.UnitàOperativeAssenti Then
        '            Return Nothing
        '        End If

        '        If aziendacodice = "*" And repartocodice = "*" Then
        '            '
        '            ' Se non è stato selezionato un reparto allora ottengo tutta la lista dei reparti
        '            '
        '            Dim listaUOPerRuolo = DI.OrderEntry.User.Data.DataAdapterManager.GetLookupUOPerRuolo()
        '            For Each reparto In listaUOPerRuolo
        '                repartocodice = reparto.CodiceUO.Substring(reparto.CodiceUO.IndexOf("-") + 1)
        '                RepartiRicovero.Add(New WcfDwhClinico.RepartoParam With {.AziendaCodice = reparto.CodiceAzienda, .RepartoCodice = repartocodice})
        '            Next
        '        Else
        '            '
        '            ' Se è stato selezionato un reparto allora ottengo solo quel reparto.
        '            '
        '            RepartiRicovero.Add(New WcfDwhClinico.RepartoParam With {.AziendaCodice = aziendacodice, .RepartoCodice = repartocodice})
        '        End If

        '        Using oWcf As New WcfDwhClinico.ServiceClient
        '            Call Utility.SetWcfDwhClinicoCredential(oWcf)

        '            '
        '            ' Ottengo un enum contenente l'id dello Stato dell'episodio, necessario per la chiamata al metodo del ws.
        '            '
        '            Dim EnumStato As WcfDwhClinico.StatoRicoveroEnum = CType(idStatoEpisodio, WcfDwhClinico.StatoRicoveroEnum)

        '            ' 0 -> Dimesso
        '            ' 1 -> In Corso
        '            ' 2 -> Dimissione oppure in corso
        '            ' 3 -> prenotazione
        '            If EnumStato = 0 Then
        '                DataConclusione = dataDimissioneDal
        '            End If

        '            '==========================================================================================================================
        '            'IMPORTANTE
        '            'Se le setting "My.Settings.ByPassOscuramenti_Utente" e "My.Settings.ByPassOscuramenti_Ruolo" sono valorizzate TokenByPassOscuramenti 
        '            ' è valorizzato e bypassa gli oscuramenti
        '            'Se GetTokenPerByPassOscuramenti restituisce nothing creo il token nel metodo standard
        '            '==========================================================================================================================
        '            Dim oToken As WcfDwhClinico.TokenType = Tokens.GetTokenPerByPassOscuramenti()
        '            If oToken Is Nothing Then
        '                oToken = Token
        '            End If

        '            '
        '            ' Chiamata al metodo che restituisce i dati
        '            '
        '            Dim oPazientiReturn As WcfDwhClinico.PazientiReturn = oWcf.PazientiRicoveratiCercaPerReparti(oToken, MAX_NUM_RECORD, Nothing, RepartiRicovero, EnumStato, tipoRicovero, Nothing, Nothing, DataConclusione, Nothing, cognome, nome, Nothing, Nothing, Nothing, Nothing, Nothing)

        '            '
        '            ' oPazientiReturn contiene anche l'errore nel caso se ne verifichi uno, quindi va gestito.
        '            '
        '            If oPazientiReturn IsNot Nothing Then
        '                If oPazientiReturn.Errore IsNot Nothing Then
        '                    '
        '                    ' Se il nodo Errore è valorizzato allora faccio il throw di una CustomException di ErroreType per loggare l'errore.
        '                    '
        '                    Throw New CustomException(Of WcfDwhClinico.ErroreType)(oPazientiReturn.Errore.Descrizione, oPazientiReturn.Errore)
        '                Else
        '                    pazientiRicoverati = oPazientiReturn.Pazienti
        '                End If
        '            End If
        '        End Using

        '        '
        '        ' se la lista è vuota allora restituisco nothing
        '        '
        '        If pazientiRicoverati Is Nothing OrElse pazientiRicoverati.Count = 0 Then
        '            Return Nothing
        '        End If

        '        '
        '        'Viene mostrato un messaggio se le righe sono > 100
        '        '
        '        Dim returnValue = From result In pazientiRicoverati.Take(101)
        '                          Order By result.Cognome, result.Nome
        '                          Select New With {
        '             .Id = result.Id,
        '             .Paziente = String.Format("{0}, {1} ({2})", result.Cognome, result.Nome, result.Sesso),
        '             .Informazioni_anagrafiche = String.Format("nat{0} il {1:d} a {2}<br />CF: {3}", If(result.Sesso = "F", "a", "o"), result.DataNascita, result.ComuneNascitaDescrizione, result.CodiceFiscale),
        '             .Ricovero = String.Format("Nosologico: {0}<br />{1} {2} dal {3:d}", result.EpisodioNumeroNosologico, If(idStatoEpisodio = 3, "Prenotato nel reparto", "Ricoverato nel reparto"), result.EpisodioStrutturaUltimoEventoDescrizione, result.EpisodioDataApertura),
        '             .Nosologico = result.EpisodioNumeroNosologico,
        '             .AziendaUO = String.Format("{0}-{1}", result.EpisodioAziendaErogante, If(String.IsNullOrEmpty(result.EpisodioStrutturaUltimoEventoCodice), result.EpisodioStrutturaConclusioneCodice, result.EpisodioStrutturaUltimoEventoCodice)),
        '             .Consenso = If(Not String.IsNullOrEmpty(result.ConsensoAziendaleCodice), CType(result.ConsensoAziendaleCodice, Boolean), Nothing),
        '             .Domicilio = ""
        '              }

        '        Return returnValue
        '    Catch ex As CustomException(Of WcfDwhClinico.ErroreType)
        '        '
        '        ' Eseguito solo se l'errore è restituito dalla chiamata al metodo del ws.
        '        '
        '        ExceptionsManager.TraceException(ex)
        '        Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
        '        portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

        '        '
        '        ' eseguo il throw in modo che possa essere catturato dal codcie lato client
        '        '
        '        Throw
        '    Catch ex As Exception
        '        ExceptionsManager.TraceException(ex)
        '        Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
        '        portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
        '        If ex.Message.IndexOf("timeout", StringComparison.InvariantCultureIgnoreCase) > -1 Then
        '            Throw New Exception("Timeout del server, specificare ulteriori parametri di ricerca.")
        '        End If

        '        Throw
        '    End Try
        'End Function

        '<WebMethod()>
        'Public Shared Function SaveLastSelectedComboValue(key As String, value As String) As String

        '    Select Case key

        '        Case "uo" 'unità operativa: la salvo su DB
        '            DatiUtente.SalvaValore(DatiUtente.Chiavi.OE_USER_REP_RIC_CODICE, value)

        '        Case Else 'altro: salvo nella session
        '            HttpContext.Current.Session(_pageSessionIdPrefix & "_" & key) = value
        '    End Select

        '    Return "ok"
        'End Function
    End Class

End Namespace