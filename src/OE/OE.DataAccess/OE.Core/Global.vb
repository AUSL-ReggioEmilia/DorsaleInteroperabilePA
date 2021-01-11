Imports System.Runtime.Caching
Imports System.Threading
Imports Msg = OE.Core.Schemas.Msg

#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
'Versione 1.2
Imports Wcf = OE.Core.Schemas.Wcf12
#Else
'Versione 1.0 e 1.1
Imports Wcf = OE.Core.Schemas.Wcf
#End If

Public Class DatiAggiuntivi
    Public Const ID_DATA_PIANIFICATA As String = "00000001-0000-0000-0000-111111111111"
    Public Const ID_STATO_CALCOLATO_CODICE As String = "00000002-0000-0000-0000-111111111111"
    Public Const ID_STATO_CALCOLATO_DESCRIZIONE As String = "00000003-0000-0000-0000-111111111111"

    Public Const NOME_CODICE_PROFILO As String = "CodiceProfilo"
End Class


Namespace My

    Public Class ListAziendeRows
        Inherits System.Collections.Generic.List(Of OrganigrammaDS.AziendaRow)
        Private _rwlock As ReaderWriterLockSlim = New ReaderWriterLockSlim

        Public Sub TryAdd(rowValue As OrganigrammaDS.AziendaRow)
            '
            ' Sincronizza per scrittura
            '
            Try
                _rwlock.EnterWriteLock()
                '
                ' Modifica valore in lista
                '
                Me.RemoveAll(Function(e) e.Codice = rowValue.Codice)
                Me.Add(rowValue)

            Catch ex As Exception
                '
                ' Nothing
                '
            Finally
                _rwlock.ExitWriteLock()
            End Try

        End Sub

        Public Function TryFindByCodice(codiceValue As String) As OrganigrammaDS.AziendaRow
            '
            ' Sincronizza per lettura
            '
            Try
                _rwlock.EnterReadLock()
                '
                ' Cerca valore
                '
                Dim ret As OrganigrammaDS.AziendaRow
                ret = Me.Find(Function(e) e.Codice = codiceValue)
                '
                ' Trace log
                '
                If ret Is Nothing Then
                    DiagnosticsHelper.WriteDiagnostics($"Cache: -- Azienda {codiceValue} non trovato, Count={Me.Count}")
                Else
                    DiagnosticsHelper.WriteDiagnostics($"Cache: || Azienda {codiceValue} trovato, Count={Me.Count}")
                End If
                '
                ' Exit value
                '
                Return ret

            Catch ex As Exception
                Return Nothing

            Finally
                _rwlock.ExitReadLock()
            End Try

        End Function
    End Class

    Public Class ListSistemiRows
        Inherits System.Collections.Generic.List(Of OrganigrammaDS.SistemaRow)
        Private _rwlock As ReaderWriterLockSlim = New ReaderWriterLockSlim

        Public Sub TryAdd(rowValue As OrganigrammaDS.SistemaRow)
            '
            ' Sincronizza per scrittura
            '
            Try
                _rwlock.EnterWriteLock()
                '
                ' Modifica valore in lista
                '
                Me.RemoveAll(Function(e) e.Codice = rowValue.Codice AndAlso e.CodiceAzienda = rowValue.CodiceAzienda)
                Me.Add(rowValue)

            Catch ex As Exception
                '
                ' Nothing
                '
            Finally
                _rwlock.ExitWriteLock()
            End Try

        End Sub

        Public Function TryFindByCodice(codiceValue As String, CodiceAziendaValue As String) As OrganigrammaDS.SistemaRow
            '
            ' Sincronizza per lettura
            '
            Try
                _rwlock.EnterReadLock()

                Dim ret As OrganigrammaDS.SistemaRow
                ret = Me.Find(Function(e) e.Codice = codiceValue AndAlso e.CodiceAzienda = CodiceAziendaValue)
                '
                ' Trace log
                '
                If ret Is Nothing Then
                    DiagnosticsHelper.WriteDiagnostics($"Cache: -- Sistema {codiceValue}@{CodiceAziendaValue} non trovato, Count={Me.Count}")
                Else
                    DiagnosticsHelper.WriteDiagnostics($"Cache: || Sistema {codiceValue}@{CodiceAziendaValue} trovato, Count={Me.Count}")
                End If
                '
                ' Exit value
                '
                Return ret

            Catch ex As Exception
                Return Nothing

            Finally
                _rwlock.ExitReadLock()
            End Try

        End Function
    End Class

    Public Class ListUnitaOperativeRows
        Inherits System.Collections.Generic.List(Of OrganigrammaDS.UnitaOperativaRow)
        Private _rwlock As ReaderWriterLockSlim = New ReaderWriterLockSlim

        Public Sub TryAdd(rowValue As OrganigrammaDS.UnitaOperativaRow)
            '
            ' Sincronizza per scrittura
            '
            Try
                _rwlock.EnterWriteLock()
                '
                ' Modifica valore in lista
                '
                Me.RemoveAll(Function(e) e.Codice = rowValue.Codice AndAlso e.CodiceAzienda = rowValue.CodiceAzienda)
                Me.Add(rowValue)

            Catch ex As Exception
                '
                ' Nothing
                '
            Finally
                _rwlock.ExitWriteLock()
            End Try

        End Sub

        Public Function TryFindByCodice(codiceValue As String, CodiceAziendaValue As String) As OrganigrammaDS.UnitaOperativaRow
            '
            ' Sincronizza per lettura
            '
            Try
                _rwlock.EnterReadLock()
                '
                ' Cerca valore
                '
                Dim ret As OrganigrammaDS.UnitaOperativaRow
                ret = Me.Find(Function(e) e.Codice = codiceValue AndAlso e.CodiceAzienda = CodiceAziendaValue)
                '
                ' Trace log
                '
                If ret Is Nothing Then
                    DiagnosticsHelper.WriteDiagnostics($"Cache: -- UnitaOperative {codiceValue}@{CodiceAziendaValue} non trovato, Count={Me.Count}")
                Else
                    DiagnosticsHelper.WriteDiagnostics($"Cache: || UnitaOperative {codiceValue}@{CodiceAziendaValue} trovato, Count={Me.Count}")
                End If

                Return ret

            Catch ex As Exception
                Return Nothing

            Finally
                _rwlock.ExitReadLock()
            End Try

        End Function
    End Class


    <Global.Microsoft.VisualBasic.HideModuleName()>
    Friend Module Singleton

        Private ReadOnly _ConfigurationSettings As ConfigurationSettings = New ConfigurationSettings

        ReadOnly Property OrderEntryConfig() As ConfigurationSettings
            Get
                Return _ConfigurationSettings
            End Get
        End Property

        ReadOnly Property CacheAziende() As ListAziendeRows
            Get
                Const CacheKey As String = "ListAziendeRows"
                Dim listChached As ListAziendeRows

                SyncLock (CacheKey)
                    '
                    ' Cerco nella cache
                    '
                    Dim cache As ObjectCache = MemoryCache.Default
                    If cache.Contains(CacheKey) Then
                        '
                        ' Trovato
                        '
                        listChached = DirectCast(cache.Get(CacheKey), ListAziendeRows)
                    Else
                        '
                        ' Crea lista in cache
                        '
                        listChached = New ListAziendeRows
                        cache.Add(CacheKey, listChached, MemoryCache.InfiniteAbsoluteExpiration)
                    End If
                End SyncLock

                Return listChached
            End Get
        End Property

        ReadOnly Property CacheSistemi() As ListSistemiRows
            Get
                Const CacheKey As String = "ListSistemiRows"
                Dim listChached As ListSistemiRows

                SyncLock (CacheKey)
                    '
                    ' Cerco nella cache
                    '
                    Dim cache As ObjectCache = MemoryCache.Default
                    If cache.Contains(CacheKey) Then
                        '
                        ' Trovato
                        '
                        listChached = DirectCast(cache.Get(CacheKey), ListSistemiRows)
                    Else
                        '
                        ' Crea lista in cache
                        '
                        listChached = New ListSistemiRows
                        cache.Add(CacheKey, listChached, MemoryCache.InfiniteAbsoluteExpiration)
                    End If
                End SyncLock

                Return listChached
            End Get
        End Property

        ReadOnly Property CacheUnitaOperative() As ListUnitaOperativeRows
            Get
                Const CacheKey As String = "ListUnitaOperativeRows"
                Dim listChached As ListUnitaOperativeRows

                SyncLock (CacheKey)
                    '
                    ' Cerco nella cache
                    '
                    Dim cache As ObjectCache = MemoryCache.Default
                    If cache.Contains(CacheKey) Then
                        '
                        ' Trovato
                        '
                        listChached = DirectCast(cache.Get(CacheKey), ListUnitaOperativeRows)
                    Else
                        '
                        ' Crea lista in cache
                        '
                        listChached = New ListUnitaOperativeRows
                        cache.Add(CacheKey, listChached, MemoryCache.InfiniteAbsoluteExpiration)
                    End If
                End SyncLock

                Return listChached
            End Get
        End Property

    End Module
End Namespace