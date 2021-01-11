Imports System.Xml
Imports System.Text
Imports System.Collections.Specialized
Imports System.Diagnostics
Imports System.Globalization
Imports Microsoft.Win32
Imports System.Threading


Namespace My
    '
    ' Estensione di My per gli oggetti a istanza singola
    '
    <Global.Microsoft.VisualBasic.HideModuleName()> _
    Friend Module Singleton
        Private _instance As New ThreadSafeObjectProvider(Of RegConfig)

        ReadOnly Property Config() As RegConfig
            Get
                Return _instance.GetInstance
            End Get
        End Property

    End Module

End Namespace

Public Class RegConfig
    Public LogSource As String
    Public LogInformation As Boolean
    Public LogWarning As Boolean
    Public LogError As Boolean

    Public ConnectionString As String
    Public ConnectionStringSac As String
    Public DatabaseIsolationLevel As String
    Public ApplicationSyncLevel As String
    Public ApplicationSyncTimeout As Integer
    '
    ' Gestione connection timeout 
    '
    Public ConnectionErrorNumRetry As Integer
    Public ConnectionErrorDelayRetry As Integer 'in secondi
    '
    ' Gestione command timeout 
    '
    Public CommandTimeoutNumRetry As Integer
    Public CommandTimeoutDelayRetry As Integer 'in secondi
    '
    ' Gestione deadlock
    '
    Public DeadLockNumRetry As Integer
    Public DeadLockDelayRetry As Integer 'in secondi
    '
    ' Gestione transcodifica Unita Operative
    '
    Public TranscodificaUoReferti As Boolean
    '
    ' MODIFICA ETTORE 2018-02-20: Gestione massima dimensione di tutti gli allegati
    '
    Public MaxTotalSizeAllegatiRefertoMb As Integer

    Private Const RegKeyDal As String = "SOFTWARE\Progel\DwhClinico\DataAccessEsterno\2.0"

    Public Sub New()

        Dim oRegKey As RegistryKey = Registry.LocalMachine
        Dim oDalKey As RegistryKey = Nothing

        Try
            '
            ' Apre in lettura
            '
            oDalKey = oRegKey.OpenSubKey(RegKeyDal, False)
            If oDalKey Is Nothing Then
                '
                ' Creo con dei default
                '
                Me.LogSource = "DwhClinico DataAccess Esterno"
                Me.LogInformation = False
                Me.LogWarning = False
                Me.LogError = True

                Me.ConnectionString = "data source=(local);initial catalog=DwhClinico;integrated security=SSPI;user id=;persist security info=False"
                Me.ConnectionStringSac = "data source=(local);initial catalog=SAC;Password=User4deV;Persist Security Info=True;User ID=SAC_DWC"

                Me.DatabaseIsolationLevel = ""
                Me.ApplicationSyncLevel = ""
                Me.ApplicationSyncTimeout = 60000
                '
                ' Modifica Ettore 2012-07-30
                '
                Me.ConnectionErrorNumRetry = 20
                Me.ConnectionErrorDelayRetry = 30  'secondi
                Me.CommandTimeoutNumRetry = 60
                Me.CommandTimeoutDelayRetry = 10  'secondi
                '
                ' Modifica Ettore 2015-02-20
                '
                Me.DeadLockNumRetry = 10
                Me.DeadLockDelayRetry = 5  'secondi
                '
                ' Modifica Ettore 2014-09-15: Gestione transcodifiche
                '
                Me.TranscodificaUoReferti = True
                '
                ' MODIFICA ETTORE 2018-02-20: Gestione massima dimensione di tutti gli allegati
                '
                Me.MaxTotalSizeAllegatiRefertoMb = 5

                Me.Save()
            End If

            Me.LogSource = CType(oDalKey.GetValue("LogSource", "DwhClinico DataAccess Esterno"), String)
            Me.LogInformation = CType(oDalKey.GetValue("LogInformation", 0), Boolean)
            Me.LogWarning = CType(oDalKey.GetValue("LogWarning", 0), Boolean)
            Me.LogError = CType(oDalKey.GetValue("LogError", 1), Boolean)

            Me.ConnectionString = CType(oDalKey.GetValue("ConnectionString", ""), String)
            Me.ConnectionStringSac = CType(oDalKey.GetValue("ConnectionStringSac", ""), String)
            Me.DatabaseIsolationLevel = CType(oDalKey.GetValue("DatabaseIsolationLevel", ""), String)
            Me.ApplicationSyncLevel = CType(oDalKey.GetValue("ApplicationSyncLevel", ""), String)
            Me.ApplicationSyncTimeout = CType(oDalKey.GetValue("ApplicationSyncTimeout", 60000), Integer)
            '
            ' Modifica Ettore 2012-07-30
            '
            Me.ConnectionErrorNumRetry = CType(oDalKey.GetValue("ConnectionErrorNumRetry", 20), Integer)
            Me.ConnectionErrorDelayRetry = CType(oDalKey.GetValue("ConnectionErrorDelayRetry", 30), Integer)  'secondi
            Me.CommandTimeoutNumRetry = CType(oDalKey.GetValue("CommandTimeoutNumRetry", 60), Integer)
            Me.CommandTimeoutDelayRetry = CType(oDalKey.GetValue("CommandTimeoutDelayRetry", 10), Integer)  'secondi
            '
            ' Modifica Ettore 2014-09-15
            '
            Me.DeadLockNumRetry = CType(oDalKey.GetValue("DeadLockNumRetry", 10), Integer)
            Me.DeadLockDelayRetry = CType(oDalKey.GetValue("DeadLockDelayRetry", 5), Integer)  'secondi
            '
            ' Modifica Ettore 2014-09-15: gestione transcodifiche
            '
            Me.TranscodificaUoReferti = CType(oDalKey.GetValue("TranscodificaUoReferti", 1), Boolean)
            '
            ' MODIFICA ETTORE 2018-02-20: Gestione massima dimensione di tutti gli allegati
            '
            Me.MaxTotalSizeAllegatiRefertoMb = CType(oDalKey.GetValue("MaxTotalSizeAllegatiRefertoMb", 5), Integer)  'MegaByte

        Catch ex As Exception
            '
            ' Errore
            '
            LogEvent.WriteError(ex, "Configurazione non trovata!")

        Finally
            '
            ' Rilascia
            '
            If Not oDalKey Is Nothing Then
                oDalKey.Close()
            End If
            If Not oRegKey Is Nothing Then
                oRegKey.Close()
            End If
        End Try

    End Sub

    Public Sub Save()

        Dim oRegKey As RegistryKey = Registry.LocalMachine
        Dim oDalKey As RegistryKey = Nothing

        Try
            '
            ' Apre in scrittura
            '
            oDalKey = oRegKey.OpenSubKey(RegKeyDal, True)
            If oDalKey Is Nothing Then
                oDalKey = oRegKey.CreateSubKey(RegKeyDal)
            End If

            oDalKey.SetValue("LogSource", Me.LogSource)
            oDalKey.SetValue("LogInformation", Me.LogInformation)
            oDalKey.SetValue("LogWarning", Me.LogWarning)
            oDalKey.SetValue("LogError", Me.LogError)

            oDalKey.SetValue("ConnectionString", Me.ConnectionString)
            oDalKey.SetValue("ConnectionStringSac", Me.ConnectionStringSac)
            oDalKey.SetValue("DatabaseIsolationLevel", Me.DatabaseIsolationLevel)
            oDalKey.SetValue("ApplicationSyncLevel", Me.ApplicationSyncLevel)
            oDalKey.SetValue("ApplicationSyncTimeout", Me.ApplicationSyncTimeout)
            '
            ' Modifica Ettore 2012-07-30
            '
            oDalKey.SetValue("ConnectionErrorNumRetry", Me.ConnectionErrorNumRetry)
            oDalKey.SetValue("ConnectionErrorDelayRetry", Me.ConnectionErrorDelayRetry)
            oDalKey.SetValue("CommandTimeoutNumRetry", Me.CommandTimeoutNumRetry)
            oDalKey.SetValue("CommandTimeoutDelayRetry", Me.CommandTimeoutDelayRetry)
            '
            ' Modifica Ettore 2015-02-20
            '
            oDalKey.SetValue("DeadLockNumRetry", Me.DeadLockNumRetry)
            oDalKey.SetValue("DeadLockDelayRetry", Me.DeadLockDelayRetry)
            '
            ' Modifica Ettore 2014-09-15: getione transcodifiche
            '
            oDalKey.SetValue("TranscodificaUoReferti", Me.TranscodificaUoReferti)
            '
            ' MODIFICA ETTORE 2018-02-20: Gestione massima dimensione di tutti gli allegati
            '
            oDalKey.SetValue("MaxTotalSizeAllegatiRefertoMb", Me.MaxTotalSizeAllegatiRefertoMb)   'MegaByte

            oDalKey.Flush()
            '
            ' Crea log Source
            '
            If Me.LogSource.Length > 0 AndAlso Not Diagnostics.EventLog.SourceExists(Me.LogSource) Then
                Diagnostics.EventLog.CreateEventSource(Me.LogSource, "Application")
            End If

        Catch ex As Exception
            '
            ' Errore
            '
            LogEvent.WriteError(ex, "Durante scrittura della configurazione!")

        Finally
            '
            ' Rilascia
            '
            If Not oDalKey Is Nothing Then
                oDalKey.Close()
            End If
            If Not oRegKey Is Nothing Then
                oRegKey.Close()
            End If
        End Try

    End Sub

End Class

Friend Class LogEvent

    Public Shared Sub WriteInformation(ByVal sMessage As String)

        Try
            Dim sSource As String = My.Config.LogSource
            Dim bEnabled As Boolean = My.Config.LogInformation
            '
            ' Controllo se abilitato
            '
            If bEnabled Then
                EventLog.WriteEntry(sSource, sMessage, EventLogEntryType.Information)
            End If

        Catch ex As Exception
        End Try

    End Sub

    Public Shared Sub WriteWarning(ByVal sMessage As String)

        Try
            Dim sSource As String = My.Config.LogSource
            Dim bEnabled As Boolean = My.Config.LogWarning
            '
            ' Controllo se abilitato
            '
            If bEnabled Then
                EventLog.WriteEntry(sSource, sMessage, EventLogEntryType.Warning)
            End If

        Catch ex As Exception
        End Try

    End Sub

    Public Shared Sub WriteError(ByVal Exception As Exception, Optional ByVal sMessage As String = "")

        Try
            Dim sSource As String = My.Config.LogSource
            Dim bEnabled As Boolean = My.Config.LogError
            '
            ' Controllo se abilitato
            '
            If bEnabled Then
                If sMessage.Length > 0 Then
                    sMessage &= vbCrLf & vbCrLf
                End If
                '
                ' Documento eccezione
                '
                If Not Exception Is Nothing Then
                    sMessage &= "Exception info ***************" & vbCrLf
                    sMessage &= "Source = " & Exception.Source & vbCrLf & vbCrLf
                    sMessage &= Exception.StackTrace & vbCrLf & vbCrLf
                    sMessage &= Exception.Message & vbCrLf & vbCrLf
                    '
                    ' Ed inner ex
                    '
                    If Not Exception.InnerException Is Nothing Then
                        sMessage &= "InnerException ***************" & vbCrLf
                        sMessage &= "Source = " & Exception.InnerException.Source & vbCrLf & vbCrLf
                        sMessage &= Exception.InnerException.StackTrace & vbCrLf & vbCrLf
                        sMessage &= Exception.InnerException.Message
                    End If
                End If


                EventLog.WriteEntry(sSource, sMessage, EventLogEntryType.Error)
            End If

        Catch ex As Exception
        End Try

    End Sub

End Class

Friend Class XmlUtil

    Public Shared Function FormatDatetime(ByVal DataOra As Date) As String
        '
        ' Ritorna DbNull se data minima
        '
        Try
            If DataOra = #1/1/1753# Then
                Return ""
            Else
                Return DataOra.ToString("s")
            End If

        Catch ex As Exception
            Return ""
        End Try

    End Function

    Public Shared Function ParseDatetime(ByVal DataOraString As String) As Date
        '
        ' Ritorna data minima se vuoto
        '
        Try
            If Not DataOraString Is Nothing AndAlso DataOraString.Length > 0 Then
                Dim culture As CultureInfo = New CultureInfo("en-US", True)
                Return Date.Parse(DataOraString, culture)
            Else
                Return #1/1/1753#
            End If

        Catch ex As Exception
            Return #1/1/1753#
        End Try

    End Function

#Region "Old function"

    'Public Shared Function CreateXmlAttributi(ByVal Attributi() As ConnectorV2.Attributo) As String
    '    '
    '    ' Vecchia versione: da non usare
    '    '
    '    Dim oXmlDoc As XmlDocument = New XmlDocument
    '    '
    '    ' Crea root
    '    '
    '    Dim oXmlRoot As XmlNode = oXmlDoc.CreateNode(XmlNodeType.Element, "Root", "")
    '    oXmlDoc.AppendChild(oXmlRoot)
    '    '
    '    ' Loop su tutti i nodi
    '    '
    '    If Not Attributi Is Nothing Then
    '        For Each Attributo As ConnectorV2.Attributo In Attributi
    '            '
    '            ' Leggo nome e valore
    '            '
    '            Dim sAttribNome As String = Attributo.Nome & ""
    '            Dim sAttribValore As String = Attributo.Valore & ""

    '            If sAttribNome.Length > 0 And sAttribValore.Length > 0 Then
    '                '
    '                ' Creo attributi e appendo
    '                '
    '                Dim oXmlNode As XmlNode = oXmlDoc.CreateNode(XmlNodeType.Element, "Attributo", "")

    '                Dim oXmlAttrib As XmlAttribute
    '                oXmlAttrib = oXmlDoc.CreateAttribute("Nome")
    '                oXmlAttrib.Value = sAttribNome
    '                oXmlNode.Attributes.Append(oXmlAttrib)

    '                oXmlAttrib = oXmlDoc.CreateAttribute("Valore")
    '                oXmlAttrib.Value = sAttribValore
    '                oXmlNode.Attributes.Append(oXmlAttrib)
    '                '
    '                ' E appendo
    '                '
    '                oXmlDoc.DocumentElement.AppendChild(oXmlNode)
    '            End If
    '        Next
    '    End If
    '    '
    '    ' Converto in ISO
    '    '
    '    Dim oEncIso As Encoding = Encoding.GetEncoding("iso-8859-1")
    '    Dim memBuffer As System.IO.MemoryStream = Nothing
    '    Dim txtwrIso As System.Xml.XmlTextWriter = Nothing
    '    Dim sXmlIso As String = ""

    '    Try
    '        memBuffer = New System.IO.MemoryStream
    '        txtwrIso = New System.Xml.XmlTextWriter(memBuffer, oEncIso)

    '        oXmlDoc.Save(txtwrIso)
    '        sXmlIso = oEncIso.GetString(memBuffer.ToArray())
    '    Catch ex As Exception
    '    Finally
    '        '
    '        ' Rilascia
    '        '
    '        If Not txtwrIso Is Nothing Then
    '            txtwrIso.Close()
    '        End If
    '        If Not memBuffer Is Nothing Then
    '            memBuffer.Close()
    '        End If
    '    End Try
    '    '
    '    ' String con attributi in formato XML
    '    '
    '    Return sXmlIso

    'End Function

    'Public Shared Function AddXmlAttributi(ByVal StringXml As String, ByVal Attributi() As ConnectorV2.Attributo) As String

    '    Dim sXPath As String = "/Root/Attributo[@Nome='{0}']"
    '    Dim oXmlDoc As XmlDocument

    '    oXmlDoc = New XmlDocument
    '    oXmlDoc.LoadXml(StringXml)
    '    '
    '    ' Loop su tutti i nodi
    '    '
    '    If Not Attributi Is Nothing Then
    '        For Each Attributo As ConnectorV2.Attributo In Attributi
    '            '
    '            ' Leggo nome e valore
    '            '
    '            Dim sAttribNome As String = Attributo.Nome & ""
    '            Dim sAttribValore As String = Attributo.Valore & ""

    '            If sAttribNome.Length > 0 Then
    '                '
    '                ' Cerco l'elemento
    '                '
    '                Dim oXmlNode As XmlNode
    '                oXmlNode = oXmlDoc.SelectSingleNode(String.Format(sXPath, sAttribNome))
    '                If oXmlNode Is Nothing Then
    '                    '
    '                    ' Creo attributi e appendo
    '                    '
    '                    oXmlNode = oXmlDoc.CreateNode(XmlNodeType.Element, "Attributo", "")

    '                    Dim oXmlAttrib As XmlAttribute
    '                    oXmlAttrib = oXmlDoc.CreateAttribute("Nome")
    '                    oXmlAttrib.Value = sAttribNome
    '                    oXmlNode.Attributes.Append(oXmlAttrib)

    '                    oXmlAttrib = oXmlDoc.CreateAttribute("Valore")
    '                    oXmlAttrib.Value = sAttribValore
    '                    oXmlNode.Attributes.Append(oXmlAttrib)
    '                    '
    '                    ' Lo appendo
    '                    '
    '                    oXmlDoc.DocumentElement.AppendChild(oXmlNode)
    '                Else
    '                    '
    '                    ' Lo modifico
    '                    '
    '                    oXmlNode.Attributes("Valore").Value = sAttribValore
    '                End If
    '            End If
    '        Next
    '    End If
    '    '
    '    ' String con attributi in formato XML
    '    '
    '    Return oXmlDoc.OuterXml

    'End Function

#End Region

    Public Shared Function CreateXdocAttributi(ByVal Attributi() As ConnectorV2.Attributo) As XmlDocument

        Dim oXmlDoc As XmlDocument = New XmlDocument
        '
        ' Crea root
        '
        Dim oXmlRoot As XmlNode = oXmlDoc.CreateNode(XmlNodeType.Element, "Root", "")
        oXmlDoc.AppendChild(oXmlRoot)
        '
        ' Loop su tutti i nodi
        '
        If Not Attributi Is Nothing Then
            For Each Attributo As ConnectorV2.Attributo In Attributi
                '
                ' Leggo nome e valore
                '
                Dim sAttribNome As String = Attributo.Nome & ""
                Dim sAttribValore As String = Attributo.Valore & ""

                If sAttribNome.Length > 0 And sAttribValore.Length > 0 Then
                    '
                    ' Creo attributi e appendo
                    '
                    Dim oXmlNode As XmlNode = oXmlDoc.CreateNode(XmlNodeType.Element, "Attributo", "")

                    Dim oXmlAttrib As XmlAttribute
                    oXmlAttrib = oXmlDoc.CreateAttribute("Nome")
                    oXmlAttrib.Value = sAttribNome
                    oXmlNode.Attributes.Append(oXmlAttrib)

                    oXmlAttrib = oXmlDoc.CreateAttribute("Valore")
                    oXmlAttrib.Value = sAttribValore
                    oXmlNode.Attributes.Append(oXmlAttrib)
                    '
                    ' E appendo
                    '
                    oXmlDoc.DocumentElement.AppendChild(oXmlNode)
                End If
            Next
        End If

        Return oXmlDoc

    End Function

    Public Shared Function AddXdocAttributi(ByVal oXmlDoc As XmlDocument, ByVal Attributi() As ConnectorV2.Attributo) As XmlDocument

        Dim sXPath As String = "/Root/Attributo[@Nome='{0}']"
        '
        ' Loop su tutti i nodi
        '
        If Not Attributi Is Nothing Then
            For Each Attributo As ConnectorV2.Attributo In Attributi
                '
                ' Leggo nome e valore
                '
                Dim sAttribNome As String = Attributo.Nome & ""
                Dim sAttribValore As String = Attributo.Valore & ""

                If sAttribNome.Length > 0 Then
                    '
                    ' Cerco l'elemento
                    '
                    Dim oXmlNode As XmlNode
                    oXmlNode = oXmlDoc.SelectSingleNode(String.Format(sXPath, sAttribNome))
                    If oXmlNode Is Nothing Then
                        '
                        ' Creo attributi e appendo
                        '
                        oXmlNode = oXmlDoc.CreateNode(XmlNodeType.Element, "Attributo", "")

                        Dim oXmlAttrib As XmlAttribute
                        oXmlAttrib = oXmlDoc.CreateAttribute("Nome")
                        oXmlAttrib.Value = sAttribNome
                        oXmlNode.Attributes.Append(oXmlAttrib)

                        oXmlAttrib = oXmlDoc.CreateAttribute("Valore")
                        oXmlAttrib.Value = sAttribValore
                        oXmlNode.Attributes.Append(oXmlAttrib)
                        '
                        ' Lo appendo
                        '
                        oXmlDoc.DocumentElement.AppendChild(oXmlNode)
                    Else
                        '
                        ' Lo modifico
                        '
                        oXmlNode.Attributes("Valore").Value = sAttribValore
                    End If
                End If
            Next
        End If

        Return oXmlDoc

    End Function


    Public Shared Function FindXdocAttributo(ByVal oXmlDoc As XmlDocument, ByVal sNomeAttributo As String) As XmlNode
        Dim sXPath As String = "/Root/Attributo[@Nome='{0}']"
        Return oXmlDoc.SelectSingleNode(String.Format(sXPath, sNomeAttributo))
    End Function



    'Public Shared Function GetXmlTextWriterAttributi(ByVal oXmlDoc As XmlDocument) As String
    '    '
    '    ' Converto in ISO ?????Non funziona non usare?????
    '    '
    '    Dim oEncIso As Encoding = Encoding.GetEncoding("iso-8859-1")
    '    Dim memBuffer As System.IO.MemoryStream = Nothing
    '    Dim txtwrIso As System.Xml.XmlTextWriter = Nothing
    '    Dim sXmlIso As String = ""

    '    Try
    '        memBuffer = New System.IO.MemoryStream
    '        txtwrIso = New System.Xml.XmlTextWriter(memBuffer, oEncIso)

    '        oXmlDoc.Save(txtwrIso)
    '        sXmlIso = oEncIso.GetString(memBuffer.ToArray())
    '    Catch ex As Exception
    '    Finally
    '        '
    '        ' Rilascia
    '        '
    '        If Not txtwrIso Is Nothing Then
    '            txtwrIso.Close()
    '        End If
    '        If Not memBuffer Is Nothing Then
    '            memBuffer.Close()
    '        End If
    '    End Try
    '    '
    '    ' String con attributi in formato XML
    '    '
    '    Return sXmlIso

    'End Function

    Public Shared Function GetXmlWriterAttributi(ByVal oXmlDoc As XmlDocument) As String
        '
        ' Converto in ISO
        '
        Dim oSettings As New System.Xml.XmlWriterSettings
        oSettings.Encoding = Encoding.GetEncoding("ISO-8859-1")

        Dim memBuffer As System.IO.MemoryStream = Nothing
        Dim oXmlWriter As System.Xml.XmlWriter = Nothing

        Dim sXmlIso As String = ""

        Try
            memBuffer = New System.IO.MemoryStream
            oXmlWriter = System.Xml.XmlWriter.Create(memBuffer, oSettings)
            oXmlDoc.Save(oXmlWriter)
            sXmlIso = oSettings.Encoding.GetString(memBuffer.ToArray())
        Catch ex As Exception
        Finally
            '
            ' Rilascia
            '
            If Not oXmlWriter Is Nothing Then
                oXmlWriter.Close()
            End If
            If Not memBuffer Is Nothing Then
                memBuffer.Close()
            End If
        End Try
        '
        ' String con attributi in formato XML
        '
        Return sXmlIso

    End Function


End Class

Friend Class SqlUtil

    Public Shared Function ParseDatetime(ByVal DataOra As Date) As Object
        '
        ' Ritorna DbNull se data minima
        '
        Try
            If DataOra = #1/1/1753# Then
                Return DBNull.Value
            Else
                Return DataOra
            End If

        Catch ex As Exception
            Return DBNull.Value
        End Try

    End Function

    Public Shared Function StringNothingToDbNull(ByVal Value As String) As Object
        '
        ' Ritorna DbNull se data minima
        '
        Try
            If Value Is Nothing Then
                Return DBNull.Value
            Else
                Return Value
            End If

        Catch ex As Exception
            Return DBNull.Value
        End Try

    End Function

    Public Shared Function StringEmptyToDbNull(ByVal Value As String) As Object
        '
        ' Ritorna DbNull se data minima
        '
        Try
            If Value Is Nothing OrElse Value.Trim.Length = 0 Then
                Return DBNull.Value
            Else
                Return Value
            End If

        Catch ex As Exception
            Return DBNull.Value
        End Try

    End Function


End Class

Friend Class ConfigUtil

    Public Enum SyncLevel
        Tipo
        Sistema
        IdEsterno
    End Enum

    Public Shared Function GetIsolationLevel() As Data.IsolationLevel
        '
        ' Ritorna il livello di tranzazione da usare
        '
        Try
            Select Case My.Config.DatabaseIsolationLevel
                Case "Chaos"
                    Return IsolationLevel.Chaos

                Case "ReadCommitted"
                    Return IsolationLevel.ReadCommitted

                Case "ReadUncommitted"
                    Return IsolationLevel.ReadUncommitted

                Case "RepeatableRead"
                    Return IsolationLevel.RepeatableRead

                Case "Serializable"
                    Return IsolationLevel.Serializable

                Case Else
                    Return IsolationLevel.ReadCommitted

            End Select

        Catch ex As Exception
            Return IsolationLevel.ReadCommitted
        End Try

    End Function

    Public Shared Function GetSyncLevel() As SyncLevel
        '
        ' Ritorna il livello di tranzazione da usare
        '
        Try
            Select Case My.Config.ApplicationSyncLevel
                Case "Tipo"
                    Return SyncLevel.Tipo

                Case "Sistema"
                    Return SyncLevel.Sistema

                Case "IdEsterno"
                    Return SyncLevel.IdEsterno

                Case Else
                    Return SyncLevel.IdEsterno

            End Select

        Catch ex As Exception
            Return SyncLevel.IdEsterno
        End Try

    End Function

    Public Shared Function GetMutex(ByVal SyncName As String) As Mutex

        Dim bMutAcquire As Boolean = False
        Dim mutSync As Mutex = Nothing
        '
        ' Crea un mutex 
        '
        Try
            mutSync = New Mutex(False, SyncName)
            If mutSync Is Nothing Then
                Throw New ApplicationException()
            End If

        Catch ex As Exception
            '
            ' Rilascio mutex
            '
            If Not mutSync Is Nothing Then
                mutSync.Close()
            End If
            '
            ' Esco
            '
            Throw New System.Exception(String.Format("Errore di creazione del Mutex('{0}')!", SyncName))
        End Try
        '
        ' Attivo il sincronismo
        '
        Try
            bMutAcquire = mutSync.WaitOne(My.Config.ApplicationSyncTimeout, False)
            If bMutAcquire Then
                '
                ' Ritorno il Mutex se acquisito
                '
                Return mutSync
            Else
                Throw New ApplicationException()
            End If

        Catch ex As Exception
            '
            ' Rilascio mutex
            '
            If Not mutSync Is Nothing Then
                If bMutAcquire Then
                    mutSync.ReleaseMutex()
                End If

                mutSync.Close()
            End If
            '
            ' Esco
            '
            Throw New System.Exception(String.Format("Timout di sincronizzazione Mutex('{0}')!", SyncName))
        End Try

    End Function

End Class



#Region "Eccezioni custom per Gestione Timeout"
'
' Modifica Ettore 2012-07-30
'
Friend Enum DataAccessExceptionErrorCodeEnum
    ConnectionError = 10
    CommandTimeout = 20
    DatiMancanti = 30
End Enum

Friend Class DataAccessException
    Inherits Exception
    Public ErrorCode As DataAccessExceptionErrorCodeEnum

    Public Sub New()
    End Sub
    Public Sub New(ByVal Message As String, ByVal ErrorCode As DataAccessExceptionErrorCodeEnum)
        MyBase.New(Message)
        Me.ErrorCode = ErrorCode
    End Sub
End Class

Friend Class ConnectionException
    Inherits DataAccessException
    Public Sub New()
        MyBase.New("Connection Exception", DataAccessExceptionErrorCodeEnum.ConnectionError)
    End Sub
    Public Sub New(ByVal Message As String)
        MyBase.New("Connection Exception" & vbCrLf & Message, DataAccessExceptionErrorCodeEnum.ConnectionError)
    End Sub
End Class

Friend Class CommandTimeoutException
    Inherits DataAccessException
    Public Sub New()
        MyBase.New("Command Timeout Exception", DataAccessExceptionErrorCodeEnum.CommandTimeout)
    End Sub
    Public Sub New(ByVal Message As String)
        MyBase.New("Command Timeout Exception" & vbCrLf & Message, DataAccessExceptionErrorCodeEnum.CommandTimeout)
    End Sub
End Class


Friend Class DatiMancantiException
    Inherits DataAccessException
    Public Sub New()
        MyBase.New("Dati Mancanti Exception", DataAccessExceptionErrorCodeEnum.DatiMancanti)
    End Sub
    Public Sub New(ByVal Message As String)
        MyBase.New("Dati Mancanti Exception" & vbCrLf & Message, DataAccessExceptionErrorCodeEnum.DatiMancanti)
    End Sub
End Class

#End Region

