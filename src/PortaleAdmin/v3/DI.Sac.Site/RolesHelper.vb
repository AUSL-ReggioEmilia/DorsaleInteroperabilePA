Imports System.Collections.Generic
Imports System.Data
Imports System.Web
Imports System
Imports System.Diagnostics
Imports DI.Sac.Admin.Data.PermessiDataSetTableAdapters
Imports DI.Sac.Admin.Data.PermessiDataSet
Imports System.Reflection
Imports System.Collections
Imports Microsoft.VisualBasic.Constants

Namespace DI.Sac.Admin

    ''' <summary>
    ''' Enumerazione dei ruoli possibili da associare all'utente corrente
    ''' </summary>
    ''' <remarks></remarks>
    Public Enum TypeRoles

        ROLE_AMMINISTRATORE

        ROLE_PAZIENTI_CREATE
        ROLE_PAZIENTI_READ
        ROLE_PAZIENTI_WRITE
        ROLE_PAZIENTI_DELETE
        ROLE_PAZIENTI_FULLCONTROL
        ROLE_PAZIENTI_CREATE_ANONIMIZZAZIONE 'ha senso solo per servizio pazienti
        ROLE_PAZIENTI_READ_ANONIMIZZAZIONE 'ha senso solo per servizio pazienti
        'MODIFICA ETTORE 2018-02-22: Creazione posizioni collegate
        ROLE_PAZIENTI_CREATE_POS_COLLEGATA 'ha senso solo per servizio pazienti
        ROLE_PAZIENTI_READ_POS_COLLEGATA 'ha senso solo per servizio pazienti


        ROLE_CONSENSI_CREATE
        ROLE_CONSENSI_READ
        ROLE_CONSENSI_WRITE
        ROLE_CONSENSI_DELETE
        ROLE_CONSENSI_FULLCONTROL

        ROLE_STRUTTUREPERSONALEMEDICO_CREATE
        ROLE_STRUTTUREPERSONALEMEDICO_READ
        ROLE_STRUTTUREPERSONALEMEDICO_WRITE
        ROLE_STRUTTUREPERSONALEMEDICO_DELETE
        ROLE_STRUTTUREPERSONALEMEDICO_FULLCONTROL

        ROLE_PRONTUARIOFARMACEUTICO_CREATE
        ROLE_PRONTUARIOFARMACEUTICO_READ
        ROLE_PRONTUARIOFARMACEUTICO_WRITE
        ROLE_PRONTUARIOFARMACEUTICO_DELETE
        ROLE_PRONTUARIOFARMACEUTICO_FULLCONTROL

        ROLE_CODIFICHESANITARIE_CREATE
        ROLE_CODIFICHESANITARIE_READ
        ROLE_CODIFICHESANITARIE_WRITE
        ROLE_CODIFICHESANITARIE_DELETE
        ROLE_CODIFICHESANITARIE_FULLCONTROL

        ROLE_TRANSCODIFICHE_CREATE
        ROLE_TRANSCODIFICHE_READ
        ROLE_TRANSCODIFICHE_WRITE
        ROLE_TRANSCODIFICHE_DELETE
        ROLE_TRANSCODIFICHE_FULLCONTROL

        ROLE_REGISTROIDDIPARTIMENTALI_CREATE
        ROLE_REGISTROIDDIPARTIMENTALI_READ
        ROLE_REGISTROIDDIPARTIMENTALI_WRITE
        ROLE_REGISTROIDDIPARTIMENTALI_DELETE
        ROLE_REGISTROIDDIPARTIMENTALI_FULLCONTROL
    End Enum

    ''' <summary>
    ''' Enumerazione dei serivizi applicativi disponibili
    ''' </summary>
    ''' <remarks></remarks>
    Public Enum TypeServices

        Pazienti = 1
        Consensi = 2
        StrutturePersonaleMedico = 3
        ProntuarioFarmaceutico = 4
        CodificheSanitarie = 5
        Transcodifiche = 6
        RegistroIdDipartimentali = 7
    End Enum

    Public NotInheritable Class RolesHelper

        Private Sub New()
        End Sub

        Private Shared _result As List(Of String) 
        Private Shared ReadOnly _className As String = MethodBase.GetCurrentMethod().ReflectedType.Name
        Private Const ROLE_CACHE_PREFIX As String = "Roles_"

        ''' <summary>
        ''' Ritorna i ruoli dell'utente corrente
        ''' </summary>
        ''' <param name="identityName">il nome dell'identity corrente</param>
        ''' <returns>String()</returns>
        ''' <remarks></remarks>
        Public Shared Function GetAllRoles(ByVal identityName As String, ByVal isInSiteAdmins As Boolean) As List(Of String)

            Dim entitaAccessiDataTable As EntitaAccessiDataTable = Nothing
            Dim entitaAccessiServiziDataTable As EntitaAccessiServiziDataTable = Nothing

            _result = New List(Of String)()

            Try
                ' Se l'utente corrente fa parte del ruolo SiteAdmins, gli assegno il ruolo amministrativo
                If isInSiteAdmins Then _result.Add(TypeRoles.ROLE_AMMINISTRATORE.ToString())

                Dim splittedUserName As String() = identityName.Split("\"c)
                Dim userName As String = splittedUserName(1)
                Dim domain As String = splittedUserName(0)

                Using adapter As New EntitaAccessiTableAdapter()
                    entitaAccessiDataTable = adapter.GetData()
                End Using

                ' Creo una vista dove ritorno una riga con i dati dell'utente corrente, se esiste!
                Using utenteDataView As New DataView(entitaAccessiDataTable, String.Concat(entitaAccessiDataTable.NomeColumn.Caption, "='", userName, "' AND ", entitaAccessiDataTable.DominioColumn.Caption, "='", domain, "'"), String.Empty, DataViewRowState.CurrentRows)

                    If utenteDataView.Count > 0 Then

                        Dim utenteRow As EntitaAccessiRow = DirectCast(utenteDataView(0).Row, EntitaAccessiRow)

                        ' Controllo se l'utente corrente è amministratore
                        If utenteRow.Amministratore AndAlso Not _result.Contains(TypeRoles.ROLE_AMMINISTRATORE.ToString()) Then _result.Add(TypeRoles.ROLE_AMMINISTRATORE.ToString())

                        ' Get dei permessi utente, creo il DataTable di tipo EntitaAccessiServiziDataTable
                        Using adapter As New EntitaAccessiServiziTableAdapter()
                            entitaAccessiServiziDataTable = adapter.GetData(utenteRow.Id)
                        End Using

                        For Each row As EntitaAccessiServiziRow In entitaAccessiServiziDataTable

                            AddRole(row)
                        Next
                    End If
                End Using

                ' Creo una vista dove ritorno i gruppi, se esistono!                
                Using gruppiDataView As New DataView(entitaAccessiDataTable, String.Concat(entitaAccessiDataTable.TipoColumn.Caption, "=1"), String.Empty, DataViewRowState.CurrentRows)

                    For i As Integer = 0 To gruppiDataView.Count - 1

                        Dim gruppoRow As EntitaAccessiRow = DirectCast(gruppiDataView(i).Row, EntitaAccessiRow)

                        ' Controllo se l'utente corrente fa parte del gruppo
                        Dim sGruppo As String = gruppoRow.Dominio & "\" & gruppoRow.Nome
                        If HttpContext.Current.User.IsInRole(sGruppo) Then
                            '
                            ' MODIFICA ETTORE 1014-01-17: Questa operazione mi permette di definire come amministratori tutti gli utenti di un gruppo
                            ' Se utente appartiene al gruppo e il gruppo è marcato come amministratore aggiungo il ruolo amministratore
                            '
                            If gruppoRow.Amministratore AndAlso Not _result.Contains(TypeRoles.ROLE_AMMINISTRATORE.ToString()) Then _result.Add(TypeRoles.ROLE_AMMINISTRATORE.ToString())

                            ' Get dei permessi di gruppo, creo il DataTable di tipo EntitaAccessiServiziDataTable
                            Using adapter As New EntitaAccessiServiziTableAdapter()
                                entitaAccessiServiziDataTable = adapter.GetData(gruppoRow.Id)
                            End Using

                            For Each row As EntitaAccessiServiziRow In entitaAccessiServiziDataTable

                                AddRole(row)
                            Next
                        End If
                    Next
                End Using
            Catch ex As Exception

                ExceptionsManager.TraceException(ex)
            End Try

            Return _result
        End Function

        Private Shared Sub AddRole(ByRef row As EntitaAccessiServiziRow)

            Select Case row.IdServizio

                Case CType(TypeServices.Pazienti, Byte)

                    Call AddStandardRole(row, TypeRoles.ROLE_PAZIENTI_CREATE, _
                                        TypeRoles.ROLE_PAZIENTI_READ, _
                                        TypeRoles.ROLE_PAZIENTI_WRITE, _
                                        TypeRoles.ROLE_PAZIENTI_DELETE, _
                                        TypeRoles.ROLE_PAZIENTI_FULLCONTROL)
                    'Hanno senso solo per servizio Pazienti
                    If row.ControlloCompleto Then
                        If Not _result.Contains(TypeRoles.ROLE_PAZIENTI_CREATE_ANONIMIZZAZIONE.ToString()) Then _result.Add(TypeRoles.ROLE_PAZIENTI_CREATE_ANONIMIZZAZIONE.ToString())
                        If Not _result.Contains(TypeRoles.ROLE_PAZIENTI_READ_ANONIMIZZAZIONE.ToString()) Then _result.Add(TypeRoles.ROLE_PAZIENTI_READ_ANONIMIZZAZIONE.ToString())
                        If Not _result.Contains(TypeRoles.ROLE_PAZIENTI_CREATE_POS_COLLEGATA.ToString()) Then _result.Add(TypeRoles.ROLE_PAZIENTI_CREATE_POS_COLLEGATA.ToString())
                        If Not _result.Contains(TypeRoles.ROLE_PAZIENTI_READ_POS_COLLEGATA.ToString()) Then _result.Add(TypeRoles.ROLE_PAZIENTI_READ_POS_COLLEGATA.ToString())

                    Else
                        If row.CreazioneAnonimizzazione Then
                            If Not _result.Contains(TypeRoles.ROLE_PAZIENTI_CREATE_ANONIMIZZAZIONE.ToString()) Then _result.Add(TypeRoles.ROLE_PAZIENTI_CREATE_ANONIMIZZAZIONE.ToString())
                        End If
                        If row.LetturaAnonimizzazione Then
                            If Not _result.Contains(TypeRoles.ROLE_PAZIENTI_READ_ANONIMIZZAZIONE.ToString()) Then _result.Add(TypeRoles.ROLE_PAZIENTI_READ_ANONIMIZZAZIONE.ToString())
                        End If
                        If row.CreazionePosizioneCollegata Then
                            If Not _result.Contains(TypeRoles.ROLE_PAZIENTI_CREATE_POS_COLLEGATA.ToString()) Then _result.Add(TypeRoles.ROLE_PAZIENTI_CREATE_POS_COLLEGATA.ToString())
                        End If
                        If row.LetturaPosizioneCollegata Then
                            If Not _result.Contains(TypeRoles.ROLE_PAZIENTI_READ_POS_COLLEGATA.ToString()) Then _result.Add(TypeRoles.ROLE_PAZIENTI_READ_POS_COLLEGATA.ToString())
                        End If

                    End If

                Case CType(TypeServices.Consensi, Byte)
                    Call AddStandardRole(row, TypeRoles.ROLE_CONSENSI_CREATE, _
                                        TypeRoles.ROLE_CONSENSI_READ, _
                                        TypeRoles.ROLE_CONSENSI_WRITE, _
                                        TypeRoles.ROLE_CONSENSI_DELETE, _
                                        TypeRoles.ROLE_CONSENSI_FULLCONTROL)

                Case CType(TypeServices.StrutturePersonaleMedico, Byte)
                    Call AddStandardRole(row, TypeRoles.ROLE_STRUTTUREPERSONALEMEDICO_CREATE, _
                                        TypeRoles.ROLE_STRUTTUREPERSONALEMEDICO_READ, _
                                        TypeRoles.ROLE_STRUTTUREPERSONALEMEDICO_WRITE, _
                                        TypeRoles.ROLE_STRUTTUREPERSONALEMEDICO_DELETE, _
                                        TypeRoles.ROLE_STRUTTUREPERSONALEMEDICO_FULLCONTROL)

                Case CType(TypeServices.ProntuarioFarmaceutico, Byte)
                    Call AddStandardRole(row, TypeRoles.ROLE_PRONTUARIOFARMACEUTICO_CREATE, _
                                        TypeRoles.ROLE_PRONTUARIOFARMACEUTICO_READ, _
                                        TypeRoles.ROLE_PRONTUARIOFARMACEUTICO_WRITE, _
                                        TypeRoles.ROLE_PRONTUARIOFARMACEUTICO_DELETE, _
                                        TypeRoles.ROLE_PRONTUARIOFARMACEUTICO_FULLCONTROL)

                Case CType(TypeServices.CodificheSanitarie, Byte)
                    Call AddStandardRole(row, TypeRoles.ROLE_CODIFICHESANITARIE_CREATE, _
                                        TypeRoles.ROLE_CODIFICHESANITARIE_READ, _
                                        TypeRoles.ROLE_CODIFICHESANITARIE_WRITE, _
                                        TypeRoles.ROLE_CODIFICHESANITARIE_DELETE, _
                                        TypeRoles.ROLE_CODIFICHESANITARIE_FULLCONTROL)

                Case CType(TypeServices.Transcodifiche, Byte)
                    Call AddStandardRole(row, TypeRoles.ROLE_TRANSCODIFICHE_CREATE, _
                                        TypeRoles.ROLE_TRANSCODIFICHE_READ, _
                                        TypeRoles.ROLE_TRANSCODIFICHE_WRITE, _
                                        TypeRoles.ROLE_TRANSCODIFICHE_DELETE, _
                                        TypeRoles.ROLE_TRANSCODIFICHE_FULLCONTROL)

                Case CType(TypeServices.RegistroIdDipartimentali, Byte)
                    Call AddStandardRole(row, TypeRoles.ROLE_REGISTROIDDIPARTIMENTALI_CREATE, _
                                        TypeRoles.ROLE_REGISTROIDDIPARTIMENTALI_READ, _
                                        TypeRoles.ROLE_REGISTROIDDIPARTIMENTALI_WRITE, _
                                        TypeRoles.ROLE_REGISTROIDDIPARTIMENTALI_DELETE, _
                                        TypeRoles.ROLE_REGISTROIDDIPARTIMENTALI_FULLCONTROL)

            End Select
        End Sub


        ''' <summary>
        ''' Aggiunge i ruoli standard alla lista locale _result
        ''' </summary>
        ''' <param name="row"></param>
        ''' <param name="RoleCreate"></param>
        ''' <param name="RoleRead"></param>
        ''' <param name="RoleWrite"></param>
        ''' <param name="RoleDelete"></param>
        ''' <param name="RoleFullControll"></param>
        ''' <remarks></remarks>
        Private Shared Sub AddStandardRole(row As EntitaAccessiServiziRow, RoleCreate As TypeRoles, RoleRead As TypeRoles, RoleWrite As TypeRoles, RoleDelete As TypeRoles, RoleFullControll As TypeRoles)
            If row.ControlloCompleto Then
                If Not _result.Contains(RoleCreate.ToString()) Then _result.Add(RoleCreate.ToString())
                If Not _result.Contains(RoleRead.ToString()) Then _result.Add(RoleRead.ToString())
                If Not _result.Contains(RoleWrite.ToString()) Then _result.Add(RoleWrite.ToString())
                If Not _result.Contains(RoleDelete.ToString()) Then _result.Add(RoleDelete.ToString())
                If Not _result.Contains(RoleFullControll.ToString()) Then _result.Add(RoleFullControll.ToString())
            Else
                If row.Creazione Then
                    If Not _result.Contains(RoleCreate.ToString()) Then _result.Add(RoleCreate.ToString())
                End If

                If row.Lettura Then
                    If Not _result.Contains(RoleRead.ToString()) Then _result.Add(RoleRead.ToString())
                End If

                If row.Scrittura Then
                    If Not _result.Contains(RoleWrite.ToString()) Then _result.Add(RoleWrite.ToString())
                End If

                If row.Eliminazione Then
                    If Not _result.Contains(RoleDelete.ToString()) Then _result.Add(RoleDelete.ToString())
                End If
            End If
        End Sub

        ''' <summary>
        ''' Cancella la cache dei ruoli dell'utente
        ''' </summary>
        ''' <param name="nome"></param>
        ''' <param name="dominio"></param>
        ''' <param name="tipo"></param>
        ''' <remarks></remarks>
        Public Shared Sub ResetRolesCache(ByVal nome As String, ByVal dominio As String, ByVal tipo As Byte)
            '
            ' Costruisco sempre le key della cache con stringhe maiuscole
            '
            dominio = dominio.ToUpper()
            nome = nome.ToUpper()
            If tipo = 1 Then
                '
                ' Di tipo Group, ciclo e rimuovo tutti gli oggetti cache utenti                
                '
                Dim cacheEnumerator As IDictionaryEnumerator = System.Web.HttpContext.Current.Cache.GetEnumerator()
                While cacheEnumerator.MoveNext()
                    Dim sKey As String = cacheEnumerator.Key.ToString()
                    If sKey.Contains(String.Concat(ROLE_CACHE_PREFIX, dominio)) Then
                        System.Web.HttpContext.Current.Cache.Remove(sKey)
                        '
                        ' Trace
                        '
                        Dim sUser As String = sKey.Replace(ROLE_CACHE_PREFIX, "")
                        Utility.TraceWriteLine(String.Format("Rimozione ruoli associati a '{0}'", sUser))
                    End If
                End While
            Else
                '
                ' Di tipo User
                '
                Dim sUser As String = String.Concat(dominio, "\", nome)
                Dim skey As String = String.Concat(ROLE_CACHE_PREFIX, sUser)
                System.Web.HttpContext.Current.Cache.Remove(skey)
                '
                ' Trace 
                '
                Utility.TraceWriteLine(String.Format("Rimozione ruoli associati a '{0}'", sUser))
            End If
        End Sub

        ''' <summary>
        ''' Scrive nella cache la lista di ruoli dell'utente
        ''' </summary>
        ''' <param name="username"></param>
        ''' <param name="roles"></param>
        ''' <remarks></remarks>
        Public Shared Sub WriteRolesList(username As String, roles As List(Of String))
            HttpContext.Current.Cache.Add(ROLE_CACHE_PREFIX & username.ToUpper(), roles, Nothing, DateTime.Now.AddMinutes(30), Caching.Cache.NoSlidingExpiration, Caching.CacheItemPriority.Normal, Nothing)
            Utility.TraceWriteLine(String.Format("Impostazione ruoli associati a '{0}'", username))
        End Sub

        ''' <summary>
        ''' Legge dalla cache la lista di ruoli dell'utente
        ''' </summary>
        ''' <param name="username"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function ReadRolesList(username As String) As List(Of String)
            Dim cachedRoles As Object = HttpContext.Current.Cache(ROLE_CACHE_PREFIX & username.ToUpper())
            If cachedRoles Is Nothing Then
                Return Nothing
            Else
                Return DirectCast(cachedRoles, List(Of String))
            End If
        End Function


#Region "Debug"

        ''' <summary>
        ''' Per visualizzare(ad esempio in DebugView.exe) la lista dei ruoli associati all'utente
        ''' </summary>
        ''' <param name="username"></param>
        ''' <remarks></remarks>
        Public Shared Sub TraceUserRoles(username As String)
            Utility.TraceWriteLine(String.Format("Elenco  ruoli dell'utente '{0}':", username))
            If HttpContext.Current.User.IsInRole(My.Settings.SiteAdmins) Then
                Utility.TraceWriteLine(String.Format("      My.Settings.SiteAdmins={0}", My.Settings.SiteAdmins))
            End If
            Dim roles As List(Of String) = ReadRolesList(username)
            For Each sRole As String In roles
                Utility.TraceWriteLine(String.Format("      {0}", sRole))
            Next
        End Sub

#End Region

    End Class

End Namespace