Imports System
Imports System.Collections
Imports System.Linq
Imports System.Web
Imports DI.PortalUser2

Public Class RoleManagerUtility2

#Region "Public Const"
    '
    ' Queste sono gli attributi restituti nella lista degli accessi dell'utente
    '
    Public Const UO_PAZ_VIEW = "UO@{0}@{1}"                                 'Se ho come accesso il codice dell'unità operativa significa che ho accesso ai Pazienti della unità operativa {0}=codice OU, {1}=codice azienda
    Public Const ATTRIB_REF_VIEW_ALL = "ATTRIB@REF_VIEW_ALL"                'Vedo tutti i referti
    Public Const ATTRIB_REF_VIEW_OSC = "ATTRIB@REF_VIEW_OSC"                'Vedo tutti i referti oscurati
    Public Const ATTRIB_PAZ_VIEW_ALL = "ATTRIB@PAZ_VIEW_ALL"                'Vedo tutti i pazienti
    Public Const ATTRIB_ACC_DIR_ENABLED = "ATTRIB@ACCES_NEC_CLIN"           'Vedo pulsante "accesso diretto per necessità clinica urgente" LA COSTANTE DEVE ESSERE MAIUSCOLA!!!
    Public Const ATTRIB_REFERTI_INFERMIERI_VIEW = "ATTRIB@REF_INF_VIEW"     'Abilita alla visualizzazione del pulsante "RefertiInfermieri" LA COSTANTE DEVE ESSERE MAIUSCOLA!!!
    Public Const ATTRIB_CONSENSO_NEG_CHANGE = "ATTRIB@CONSENSO_NEG_CHANGE"  'Abilita alla modifica di un consenso esplicitamente negato LA COSTANTE DEVE ESSERE MAIUSCOLA!!!
    Public Const ATTRIB_UTE_TEC = "ATTRIB@UTE_TEC"                          'Definisce l'utente come Utente tecnico, tracciamento nascosto
    Public Const ATTRIB_UTE_ACC_TEC = "ATTRIB@UTE_ACC_TEC"                  'Definisce l'utente come Utente con accesso tecnico con tracciamento standard
    Public Const SE_REF_VIEW = "SE@{0}@{1}"                                 'Se ho accesso al sistema significa che ho accesso ai referti per azienda-sistema erogante per {0}=codice SE, {1}=codice azienda

    '
    'USATE NEL SAC
    '
    Public Const ATTRIB_CONSENSI_DELETE_ALL = "ATTRIB@CONSENSI_DELETE_ALL"  'Diritto di eliminare tutti i consensi per il paziente selezionato
    Public Const ATTRIB_UTE_ANONIMIZZATORE = "ATTRIB@UTE_ANONIMIZZATORE"    'Diritto di anonimizzazione
    Public Const ATTRIB_UTE_POS_COLLEGATE = "ATTRIB@UTE_POSIZIONI_COLLEGATE"    'Diritto di creare/leggere 

    '
    ' Opzioni per DI-USER (opzioni cross-applicazioni user)
    '
    Public Const DI_USER_RUOLO_CORRENTE_CODICE = "DI_USER_RUOLO_CORRENTE_CODICE"    'memorizza ultimo ruolo usato dall'utente

    '
    'USATA NEL DWH
    '
    Public Const ATTRIB_ACCESSO_FSE As String = "ATTRIB@ACCESSO_FSE"
    Public Const ATTRIB_OSC_REFERTI = "ATTRIB@OSC_REFERTI"                  'Definisce se gli utenti del ruolo possono cancellare/oscurare un referto
#End Region

#Region "PrivateConst"
    '
    ' Nome per individuare gli oggetti in cache che memorizzano il corrente contesto dell'utente 
    '
    Private Const RM_CURRENT_USER_CONTEXT As String = "RM_CURRENT_USER_CONTEXT"
    Private Const RM_CURRENT_USER_ROLE As String = "RM_CURRENT_USER_ROLE"
    Private msUserName As String
    Private msPortalUserConnectionString As String
    Private msSACConnectionString As String

    Private msSacUser As String
    Private msSacPassword As String
    Private connectionString1 As String
    Private connectionString2 As String
#End Region

    ''' <summary>
    ''' Classe utilizzata per salvare in sessione i dati dell'utente
    ''' </summary>
    ''' <remarks></remarks>
    Private Class RoleManagerUserCurrentData
        Public Property Ruoli As Generic.List(Of RoleManager.Ruolo) = Nothing
        Public Property Sistemi As Generic.List(Of RoleManager.Sistema) = Nothing
        Public Property UnitaOperative As Generic.List(Of RoleManager.UnitaOperativa) = Nothing
        Public Property Accessi As Generic.List(Of String) = Nothing

        Public Sub New(ByVal Ruoli As Generic.List(Of RoleManager.Ruolo), ByVal Sistemi As Generic.List(Of RoleManager.Sistema), ByVal UnitaOperative As Generic.List(Of RoleManager.UnitaOperativa), ByVal Accessi As Generic.List(Of String))
            Me.Ruoli = Ruoli
            Me.Sistemi = Sistemi
            Me.UnitaOperative = UnitaOperative
            Me.Accessi = Accessi
        End Sub
    End Class

    Public Property RuoloCorrente As RoleManager.Ruolo
        Get
            Dim oRuolo As RoleManager.Ruolo = TryCast(ReadCache(RM_CURRENT_USER_ROLE), RoleManager.Ruolo)
            If oRuolo Is Nothing Then
                Return New RoleManager.Ruolo() With {.Codice = "@@NULL", .Descrizione = "@@NULL"}
            Else
                Return oRuolo
            End If
        End Get
        Set(value As RoleManager.Ruolo)
            WriteCache(RM_CURRENT_USER_ROLE, value, 0)
        End Set
    End Property

    Public Sub New(PortalUserConnectionString As String, SACConnectionString As String, ByVal SacUser As String, ByVal SacPassword As String)
        msUserName = HttpContext.Current.User.Identity.Name.ToUpper
        msPortalUserConnectionString = PortalUserConnectionString
        msSACConnectionString = SACConnectionString

        msSacUser = SacUser
        msSacPassword = SacPassword
    End Sub

    'Public Sub New(connectionString1 As String, connectionString2 As String)
    '    Me.connectionString1 = connectionString1
    '    Me.connectionString2 = connectionString2
    'End Sub

    Public Sub InitializeUser()
        '
        ' Questa funzione viene chiamata in un evento del global.asax in cui la Sessione non è ancora disponibile
        '
        Dim t0 As DateTime = Nothing
        Dim oUserCurrentData As RoleManagerUserCurrentData = Nothing
        'Dim oUserCurrentData As WcfSacRoleManager.RuoloDettagliType
        Dim sCodiceRuoloCorrente As String = String.Empty
        Dim oPortalDataAdapterManager = New DI.PortalUser2.Data.PortalDataAdapterManager(msPortalUserConnectionString)
        Try
            t0 = DateTime.Now()
            oUserCurrentData = DirectCast(ReadCache(RM_CURRENT_USER_CONTEXT), RoleManagerUserCurrentData)
            ' 
            ' Leggo dal DiPortalUser il ruolo scritto nella key "DI_USER_RUOLO_CORRENTE_CODICE" -> sCodiceRuoloDiportal
            ' Se diverso da quello memorizzato in oUserCurrentData.RuoloCorrente.Codice si ri-inizializza il contesto utente
            ' Ovviamente quando l'utente cambia ruolo dalla pagina bisogna scrivere nella key OpzioniUtente.DI_USER_RUOLO_CORRENTE_CODICE
            '
            sCodiceRuoloCorrente = oPortalDataAdapterManager.DatiUtenteOttieniValore(msUserName, DI_USER_RUOLO_CORRENTE_CODICE, "")

#If TRACE Then
            'Utility.TraceWriteLine(String.Format("ROLE MANAGER: Codice ruolo scelto dall'utente : {0}", sCodiceRuoloCorrente))
#End If
            '
            ' Se oUserCurrentData è nothing devo ricalcolare tutto 
            ' Se sCodiceRuoloCorrente  è cambiato rispetto quello memorizzato in oUserCurrentData.RuoloCorrente.Codice devo ricalcolare tutto 
            '
            If (oUserCurrentData Is Nothing) OrElse
           ((Not oUserCurrentData Is Nothing) AndAlso (Me.RuoloCorrente.Codice <> sCodiceRuoloCorrente)) Then
#If TRACE Then
                If oUserCurrentData Is Nothing Then
                    'Utility.TraceWriteLine("ROLE MANAGER: Il contesto utente È NOTHING: ricalcolo tutto!")
                ElseIf ((Not String.IsNullOrEmpty(sCodiceRuoloCorrente)) And Me.RuoloCorrente.Codice <> sCodiceRuoloCorrente) Then
                    Utility.TraceWriteLine("ROLE MANAGER: L'utente ha modificato il ruolo: ricalcolo tutto!")
                End If
#End If
                '
                ' Inizializzo il contesto utente
                '
                oUserCurrentData = InitializeUserContext(sCodiceRuoloCorrente)
                If Not oUserCurrentData Is Nothing Then
                    '
                    ' Ri-inizializzo l'Identity utilizzando i dati in sessione
                    '
                    Call InitializeUserPrincipal(oUserCurrentData.Accessi)
                    '
                    ' MODIFICA ETTORE 2015-06-18: Forzo il redirect alla pagina di default (che è visibile a tutti) direttamente dal global.asax
                    ' Altrimenti se utente era in un ruolo che poteva vedere pagina Pazienti.aspx e poi da altro portale si seleziona un ruolo che non può vedere Pazienti.aspx
                    ' il web server richiedeva l'autenticazione.
                    ' Di pagine Default.aspx ce ne è una sola
                    '
                    If Me.RuoloCorrente.Codice <> sCodiceRuoloCorrente Then
                        'SCRIVO SU DB IL RUOLO ASSEGNATO 
                        oPortalDataAdapterManager.DatiUtenteSalvaValore(msUserName, RoleManagerUtility2.DI_USER_RUOLO_CORRENTE_CODICE, Me.RuoloCorrente.Codice)
                    End If


                Else
#If TRACE Then
                    Utility.TraceWriteLine("ROLE MANAGER: ERRORE: Il contesto utente È NOTHING dopo InitializeUserContext()")
#End If
                End If

            ElseIf Not oUserCurrentData Is Nothing Then
#If TRACE Then
                Utility.TraceWriteLine(String.Format("ROLE MANAGER: Ruolo scelto dall'utente: {0}", Me.RuoloCorrente.Descrizione))
#End If
                '
                ' Ri-inizializzo l'Identity utilizzando i dati in sessione
                '
                Call InitializeUserPrincipal(oUserCurrentData.Accessi)
            End If
#If TRACE Then
            Utility.TraceWriteLine(String.Format("ROLE MANAGER: InitializeUser(): durata {0} ms", DateTime.Now.Subtract(t0).TotalMilliseconds))
#End If
        Catch ex As Exception
            Throw New Exception(String.Format("Errore in InitializeUser() per l'utente {0}.", msUserName), ex)
        End Try
    End Sub

    ''' <summary>
    ''' Legge i Ruoli, Unità Operative, Sistemi, Accessi dal role manager + gruppi di AD
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function InitializeUserContext(ByVal sRuoloCodiceScelto As String) As RoleManagerUserCurrentData 'WcfSacRoleManager.RuoloDettagliType '
        '
        ' Inizializzo la lista dei gruppi
        ' e la lista degli accessi comprensiva dei gruppi di ActiveDirectory
        '
        'Dim oUserCurrentData As RoleManagerUserCurrentData = Nothing
        Dim t0 As DateTime = Nothing
        Dim oRoleManagerDa As RoleManager.DataAccess = Nothing
        Dim oListRuoli As Generic.List(Of RoleManager.Ruolo) = Nothing
        Dim oUserDataWcf As WcfSacRoleManager.RuoloDettagliType = Nothing
        Dim oUserData As RoleManagerUserCurrentData = Nothing
        Try
            t0 = DateTime.Now()
            oRoleManagerDa = New RoleManager.DataAccess(msSACConnectionString, msSacUser, msSacPassword)
            '
            ' Per ricavare ultimo Ruolo utilizzato dall'utente
            '
            oListRuoli = oRoleManagerDa.RuoliOttieniPerUtente(msUserName)
            If Not oListRuoli Is Nothing AndAlso oListRuoli.Count > 0 Then
#If TRACE Then
                Utility.TraceWriteLine(String.Format("ROLE MANAGER: InitializeUserContext(): Numero di ruoli: {0}", oListRuoli.Count))
#End If
                Dim oListAccessi As New Generic.List(Of String)
                Dim oListUnitaOperative As New Generic.List(Of RoleManager.UnitaOperativa)
                Dim oListSistemi As New Generic.List(Of RoleManager.Sistema)

                Dim oRuoloCorrente As RoleManager.Ruolo = Nothing
                '
                ' Ricavo il ruolo corrente in base al codice scelto
                '
                If Not String.IsNullOrEmpty(sRuoloCodiceScelto) Then
                    oRuoloCorrente = oListRuoli.Find(Function(e) e.Codice = sRuoloCodiceScelto)
                    If oRuoloCorrente Is Nothing Then
                        oRuoloCorrente = oListRuoli.Item(0)
                    End If
                Else
                    oRuoloCorrente = oListRuoli.Item(0)
                End If
                '
                ' A questo punto oRuoloCorrente è valorizzato
                '
#If TRACE Then
                Utility.TraceWriteLine(String.Format("ROLE MANAGER: InitializeUserContext(): Ruolo corrente {0}-{1}", oRuoloCorrente.Codice, oRuoloCorrente.Descrizione))
#End If

                oUserDataWcf = oRoleManagerDa.ContestoUtenteOttieniPerRuolo(oRuoloCorrente.Codice, msUserName)


                If Not oUserDataWcf Is Nothing Then
                    If Not oUserDataWcf.Accessi Is Nothing Then
                        Utility.TraceWriteLine(String.Format("ROLE MANAGER: InitializeUserContext(): Numero di accessi: {0}", oUserDataWcf.Accessi.Count))

                        'OTTENGO UNA LISTA DI CODICI DEGLI ACCESSI.
                        For index = 0 To oUserDataWcf.Accessi.Count - 1
                            Dim accessoWcf As WcfSacRoleManager.AccessoType = oUserDataWcf.Accessi.Item(index)
                            oListAccessi.Add(accessoWcf.Codice)
                        Next
                    End If

                    If Not oUserDataWcf.UnitaOperative Is Nothing Then
                        Utility.TraceWriteLine(String.Format("ROLE MANAGER: InitializeUserContext(): Numero di Unità Operative: {0}", oUserDataWcf.UnitaOperative.Count))

                        'ciclo tutta la lista ottenuta dal wcf e creo una nuova lista contenente solo i codici.
                        For index = 0 To oUserDataWcf.UnitaOperative.Count - 1
                            Dim unitaOperativaWcf As WcfSacRoleManager.UnitaOperativaType = oUserDataWcf.UnitaOperative.Item(index)
                            Dim unitaOperativa As New RoleManager.UnitaOperativa
                            unitaOperativa.Codice = unitaOperativaWcf.Codice
                            unitaOperativa.CodiceAzienda = unitaOperativaWcf.CodiceAzienda
                            unitaOperativa.Descrizione = unitaOperativaWcf.Descrizione

                            Dim listaRegimi As New List(Of RoleManager.Regime)

                            For Each regimeRow As WcfSacRoleManager.CodiceDescrizioneType In unitaOperativaWcf.Regimi
                                Dim oRegime As New RoleManager.Regime
                                oRegime.Codice = regimeRow.Codice
                                oRegime.Descrizione = regimeRow.Descrizione

                                listaRegimi.Add(oRegime)
                            Next

                            unitaOperativa.Regimi = listaRegimi

                            'CREO LA LISTA DELLE UNITA' OPERATIVE.
                            oListUnitaOperative.Add(unitaOperativa)
                        Next
                    End If

                    If Not oUserDataWcf.Sistemi Is Nothing Then
                        Utility.TraceWriteLine(String.Format("ROLE MANAGER: InitializeUserContext(): Numero di Sistemi: {0}", oUserDataWcf.Sistemi.Count))
                        For index = 0 To oUserDataWcf.Sistemi.Count - 1
                            Dim sistemaWcf As WcfSacRoleManager.SistemaType = oUserDataWcf.Sistemi.Item(index)
                            Dim sistema As New RoleManager.Sistema
                            sistema.Codice = sistemaWcf.Codice
                            sistema.CodiceAzienda = sistemaWcf.CodiceAzienda
                            sistema.Descrizione = sistemaWcf.Descrizione
                            sistema.Erogante = sistemaWcf.Erogante
                            sistema.Richiedente = sistemaWcf.Richiedente

                            'CREO LA LISTA DEI SISTEMI.
                            oListSistemi.Add(sistema)
                        Next
                    End If
                End If


                '
                ' AGGIUNGO ALLA LISTA DEGLI ACCESSI I GRUPPI DI ACTIVE DIRECTORY
                '
                Dim oListWinGroup As Generic.List(Of String) = GetWindowsGroup()
                For Each sWinGroup As String In oListWinGroup
                    If Not oListAccessi.Contains(sWinGroup) Then
                        oListAccessi.Add(sWinGroup)
                    End If
                Next

                ' 
                ' Creo classe da salvare nella Cache/Application
                '
                oUserData = New RoleManagerUserCurrentData(oListRuoli, oListSistemi, oListUnitaOperative, oListAccessi)
                Me.RuoloCorrente = oRuoloCorrente
                '
                ' A questo punto salvo tutto nella CACHE
                '
                Call WriteCache(RM_CURRENT_USER_CONTEXT, oUserData)
            End If
#If TRACE Then
            Utility.TraceWriteLine(String.Format("ROLE MANAGER: InitializeUserContext(): durata {0} ms", DateTime.Now.Subtract(t0).TotalMilliseconds))
#End If
            '
            ' Restituisco
            '
            Return oUserData

        Catch ex As Exception
            Throw New Exception(String.Format("Errore in InitializeUserContext() per l'utente {0}.", msUserName), ex)
        End Try
        Return Nothing
    End Function


    ''' <summary>
    ''' Scrive nell'oggetto CACHE con durata 10 minuti
    ''' </summary>
    ''' <param name="sKey"></param>
    ''' <param name="oValue"></param>
    ''' <remarks></remarks>
    Private Sub WriteCache(ByVal sKey As String, ByVal oValue As Object)
        WriteCache(sKey, oValue, 10)
    End Sub

    Private Sub WriteCache(ByVal sKey As String, ByVal oValue As Object, iMinutiDurata As Integer)
        Dim oHttpContextCurrent = HttpContext.Current
        If iMinutiDurata = 0 Then
            oHttpContextCurrent.Cache.Insert(sKey & "_" & msUserName, oValue, Nothing, Caching.Cache.NoAbsoluteExpiration, New TimeSpan(0, 60, 0))
        Else
            oHttpContextCurrent.Cache.Insert(sKey & "_" & msUserName, oValue, Nothing, DateTime.UtcNow.AddMinutes(iMinutiDurata), Caching.Cache.NoSlidingExpiration, Caching.CacheItemPriority.Normal, Nothing)
        End If
    End Sub

    ''' <summary>
    ''' Legge dall'oggetto CACHE
    ''' </summary>
    ''' <param name="sKey"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function ReadCache(ByVal sKey As String) As Object

        Return HttpContext.Current.Cache(sKey & "_" & msUserName)

    End Function

    ''' <summary>
    ''' Fornisce lista dei gruppi di active directory per l'utente corrente
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function GetWindowsGroup() As Generic.List(Of String)
        Dim principalCurrent As System.Security.Principal.IPrincipal = HttpContext.Current.User
        Dim identityCurrent As System.Security.Principal.IIdentity = principalCurrent.Identity
        '
        ' Ottengo i Principal e Identity specificidi Windows
        '
        Dim principalWinCurrent As System.Security.Principal.WindowsPrincipal = DirectCast(principalCurrent, System.Security.Principal.WindowsPrincipal)
        Dim identityWinCurrent As System.Security.Principal.WindowsIdentity = DirectCast(principalWinCurrent.Identity, System.Security.Principal.WindowsIdentity)
        '
        ' Ruoli .NET correnti
        '
        Dim oListWinGroup As New Generic.List(Of String)
        For Each winGroup As System.Security.Principal.IdentityReference In identityWinCurrent.Groups
            '
            ' Lookup nome del gruppo
            '
            Try
                Dim ntAccountGroup As System.Security.Principal.NTAccount = winGroup.Translate(GetType(System.Security.Principal.NTAccount))
                Dim sRoleName As String = ntAccountGroup.Value
                If Not oListWinGroup.Contains(sRoleName) Then
                    oListWinGroup.Add(sRoleName)
                End If
            Catch ex As Exception
                If ShowError_TraslazioneGruppo(winGroup.Value) Then
                    Dim sErrMsg As String = String.Format("Errore durante traslazione gruppo '{0}' di windows per l'utente '{1}'.", winGroup.Value, principalCurrent.Identity.Name)
#If TRACE Then
                    Utility.TraceWriteLine("ROLE MANAGER: " & sErrMsg)
#End If
                    'Logging.WriteWarning(sErrMsg & vbCrLf & ex.Message)
                End If
            End Try
        Next
        '
        ' Verifico di avere traslato dei gruppi...
        '
        If oListWinGroup.Count = 0 Then
            Dim sErrMsg As String = String.Format("La lista dei gruppi windows è vuota per l'utente '{0}'.", principalCurrent.Identity.Name)
            Throw New Exception(sErrMsg)
        End If

        '
        ' Restituisco la lista dei gruppi di AD
        '
        Return oListWinGroup

    End Function

    Private Function ShowError_TraslazioneGruppo(ByVal winGropValue As String) As Boolean
        Dim bRet As Boolean = True
        '
        ' Verifico l'identificatore del gruppo
        '
        Dim oArray As String() = winGropValue.Split("-")
        If oArray.Length > 2 Then 'Almeno lungo 3
            Select Case oArray(2) 'confronto il terzo elemento
                Case "18", "16", "15"
                    bRet = False 'Non devo visualizzare l'errore
                Case Else
                    bRet = True 'Devo visualizzare l'errore
            End Select
        End If
        '
        ' Restituisco
        '
        Return bRet
    End Function

    ''' <summary>
    ''' Inizializzo il System.Security.Principal.IPrincipal con tutti i ruoli/accessi per l'utente corrente
    ''' </summary>
    ''' <param name="oListAccessi">Lista dei ruoli dell'utente</param>
    ''' <remarks></remarks>
    Private Sub InitializeUserPrincipal(ByVal oListAccessi As Generic.List(Of String))
#If TRACE Then
        Dim t0 As DateTime = DateTime.Now()
#End If
        '
        ' MODIFICA ETTORE 2019-09-26: utilizzo la nuova classe AppGenericPrincipal
        '
        HttpContext.Current.User = AppGenericPrincipal.InitializeWithWindowsUser(oListAccessi.ToArray)
        Threading.Thread.CurrentPrincipal = HttpContext.Current.User

#If TRACE Then
        Utility.TraceWriteLine(String.Format("ROLE MANAGER: InitializeUserPrincipal(): durata {0} ms", DateTime.Now.Subtract(t0).TotalMilliseconds))
#End If
    End Sub

    ''' <summary>
    ''' Restituisce la lista dei ruoli dell'utente
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks>Non ripopola la cache perchè è appena stato fatto nel global.asax</remarks>
    Public Function GetRuoli() As Generic.List(Of RoleManager.Ruolo)
        Dim oRoleManagerUserCurrentData As RoleManagerUserCurrentData = DirectCast(ReadCache(RM_CURRENT_USER_CONTEXT), RoleManagerUserCurrentData)
        If Not oRoleManagerUserCurrentData Is Nothing Then
            Return oRoleManagerUserCurrentData.Ruoli
        End If
        Return Nothing
    End Function

    ''' <summary>
    ''' Restituisce la lista delle unità operative dell'utente
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks>Non ripopola la cache perchè è appena stato fatto nel global.asax</remarks>
    Public Function GetUnitaOperative() As Generic.List(Of RoleManager.UnitaOperativa)
        Dim oRoleManagerUserCurrentData As RoleManagerUserCurrentData = DirectCast(ReadCache(RM_CURRENT_USER_CONTEXT), RoleManagerUserCurrentData)
        If Not oRoleManagerUserCurrentData Is Nothing Then
            Return oRoleManagerUserCurrentData.UnitaOperative
        End If
        Return Nothing
    End Function

    ''' <summary>
    ''' Ottiene la lista dei regimi in base al codice dell'azienda e della unità operativa
    ''' </summary>
    ''' <param name="CodiceAzienda"></param>
    ''' <param name="CodiceUnitaOperativa"></param>
    ''' <returns></returns>
    Public Function GetRegimiByUnitaOperativa(ByVal CodiceAzienda As String, ByVal CodiceUnitaOperativa As String) As Generic.List(Of RoleManager.Regime)
        Dim oReturn As Generic.List(Of RoleManager.Regime) = Nothing

        '
        'Se CodiceAzienda e CodiceUnitaOperativa sono vuoti allora ottengo la lista di tutti i regimi.
        '
        If String.IsNullOrEmpty(CodiceAzienda) OrElse String.IsNullOrEmpty(CodiceUnitaOperativa) Then
            Dim oRoleManagerDa As New RoleManager.DataAccess(msSACConnectionString, msSacUser, msSacPassword)
            oReturn = oRoleManagerDa.RegimiListaOttieni()
        Else
            '
            'Ottengo dalla cache il contesto dell'utente (Sistemi,Ruoli,Unità Operative e accessi)
            '
            Dim oRoleManagerUserCurrentData As RoleManagerUserCurrentData = DirectCast(ReadCache(RM_CURRENT_USER_CONTEXT), RoleManagerUserCurrentData)
            If Not oRoleManagerUserCurrentData Is Nothing Then
                'Ottengo la lista delle unità operative.
                Dim unitaOperative As List(Of RoleManager.UnitaOperativa) = CType(oRoleManagerUserCurrentData.UnitaOperative, List(Of RoleManager.UnitaOperativa))
                'Eseguo una query linq per ottenere la lista dei regimi associata all'unità operativa specifica.
                Dim oListaRegimi = (From o In unitaOperative Where o.Codice.ToUpper = CodiceUnitaOperativa.ToUpper AndAlso o.CodiceAzienda.ToUpper = CodiceAzienda.ToUpper Select o.Regimi).ToList
                If Not oListaRegimi Is Nothing AndAlso oListaRegimi.Count > 0 Then
                    'Nel primo item della lista è presente la lista dei regimi
                    oReturn = CType(oListaRegimi.Item(0), List(Of RoleManager.Regime))
                End If
            End If
        End If
        Return oReturn
    End Function


    ''' <summary>
    ''' Restituisce la lista dei sistemi eroganti visibili dall'utente
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks>Non ripopola la cache perchè è appena stato fatto nel global.asax</remarks>
    Public Function GetSistemi() As List(Of RoleManager.Sistema)
        Dim oRoleManagerUserCurrentData As RoleManagerUserCurrentData = DirectCast(ReadCache(RM_CURRENT_USER_CONTEXT), RoleManagerUserCurrentData)
        If Not oRoleManagerUserCurrentData Is Nothing Then
            Return oRoleManagerUserCurrentData.Sistemi
        End If
        Return Nothing
    End Function
End Class

