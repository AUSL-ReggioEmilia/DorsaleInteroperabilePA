Imports System
Imports System.Data
Imports System.Drawing
Imports System.Collections.Generic
Imports System.IO
Imports System.Text
Imports System.Diagnostics
Imports System.Globalization
Imports System.Data.SqlTypes
'
Namespace DI.Common

    ''' <summary>
    ''' Classe statica di utilità generiche
    ''' </summary>
    ''' <remarks></remarks>
    Public NotInheritable Class Utility

        Private Const _invalidExtensions As String = ".ade, .adp, .app, .asp, .bas, .bat, .cer, .chm, .cmd, .com, .cpl, .crt, .csh, .der, .exe, .fxp, .hlp, .hta, .inf, .ins, .isp, .its, .js, .jse, .ksh, .lnk, .mad, .maf, .mag, .mam, .maq, .mar, .mas, .mat, .mau, .mav, .maw, .msc, .msh, .msh1, .msh2, .msh1xml, .msh2xml, .mshxml, .msi, .msp, .mst, .ops, .pcd, .pif, .plg, .prf, .prg, .pst, .reg, .scf, .scr, .sct, .shb, .shs, .tmp, .url, .vb, .vbe, .vbs, .vsmacros, .vsw, .ws, .wsc, .wsf, .wsh"

        Public Shared ReadOnly DateTimeISO8601Format As String = "yyyy-MM-dd"

        Private Sub New()

        End Sub

        ''' <summary>
        ''' Filtra una DataSource e gestisce lo stato di attivazione
        ''' </summary>
        ''' <param name="dataSource">Un oggetto DataTable sulla cui DefaultView operare il filtro</param>
        ''' <param name="valueToBind">Il valore eventualmente selezionato nel controllo associato, usato nel caso
        ''' in cui a essere selezionato sia un elemento disattivato</param>
        ''' <remarks></remarks>
        Public Shared Sub FilterComboDataSource(ByVal dataSource As DataTable, ByVal valueToBind As Object)

            FilterComboDataSource(dataSource.DefaultView, valueToBind)
        End Sub

        ''' <summary>
        ''' Filtra una DataSource e gestisce lo stato di attivazione
        ''' </summary>
        ''' <param name="dataSource">Un oggetto DataView su cui operare il filtro</param>
        ''' <param name="valueToBind">Il valore eventualmente selezionato nel controllo associato, usato nel caso
        ''' in cui a essere selezionato sia un elemento disattivato</param>
        ''' <remarks></remarks>
        Public Shared Sub FilterComboDataSource(ByVal dataSource As DataView, ByVal valueToBind As Object)

            Dim filterValue As String = String.Empty

            If valueToBind IsNot Nothing AndAlso valueToBind IsNot DBNull.Value Then
                filterValue = " OR ID = " & valueToBind.ToString()
            End If

            Dim filter As String = dataSource.RowFilter

            If filter.Length > 0 Then

                If filter.IndexOf("(ATTIVO = 1 OR ID =") > -1 Then
                    dataSource.RowFilter = filter.Substring(0, filter.LastIndexOf(" OR ID =")) & filterValue & ")"
                    Return
                Else
                    If Not filter.EndsWith("AND") Then
                        filter &= " AND "
                    End If
                End If
            End If

            dataSource.RowFilter = filter & "(ATTIVO = 1" & filterValue & ")"
        End Sub

        ''' <summary>
        ''' La lista delle estensioni proibite
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared ReadOnly Property InvalidExtensions() As String
            Get
                Return _invalidExtensions
            End Get
        End Property

        ''' <summary>
        ''' Verifica se un nome di file è valido per SharePoint
        ''' </summary>
        ''' <param name="fileName">Il nome del file (es.: allegato.txt)</param>
        ''' <returns>True, se il formato del file è valido</returns>
        ''' <remarks>Caratteri non validi per un nome di file
        ''' Per Sharepoint le regole sono queste:
        ''' 1)I caratteri non validi sono i seguenti: ~"#%&amp;*:&lt;&gt;?/\{|}. 
        ''' 2)Il nome non può iniziare o finire con un punto o uno spazio
        ''' 3)Il nome non può includere punti consecutivi.
        ''' 
        '''Inoltre, per evitare altri problemi,
        '''non accetto nemmeno i nomi dei file con ' (per non fare casini con gli href dell'html)</remarks> 
        Public Shared Function IsFileNameValid(ByVal fileName As String) As Boolean

            Dim invalidChars As String = "[~#%&'/*:<>?""/|{}\\]"

            If System.Text.RegularExpressions.Regex.Match(fileName, invalidChars).Success Then
                ' il file contiene caratteri non validi 
                Return False
            End If

            If _invalidExtensions.Contains(Path.GetExtension(fileName)) Then
                ' il file è di un tipo non permesso
                Return False
            End If

            If fileName.StartsWith(".") Then
                ' il nome di file inizia con un punto
                Return False
            End If

            If fileName.EndsWith(".") Then
                ' il nome di file finisce con un punto
                Return False
            End If

            If fileName.Contains("..") Then
                ' il nome di file contiene due punti consecutivi
                Return False
            End If

            If fileName.StartsWith(" ") Then
                ' il nome di file inizia con uno spazio
                Return False
            End If

            If fileName.EndsWith(" ") Then
                ' il nome di file finisce con uno spazio
                Return False
            End If

            Return True
        End Function

        ''' <summary>
        ''' Controlla che una tabella contenga tutte le colonne di un'altra tabella
        ''' </summary>
        ''' <param name="table">La DataTable da controllare</param>
        ''' <param name="schema">La DataTable da usare come paragone</param>
        ''' <returns>True se table contiene almeno tutte le colonne di schema</returns>
        ''' <remarks>Utilizzata per validare gli acceleratori</remarks>
        Public Shared Function CheckDataTableAgainstSchema(ByVal table As DataTable, ByVal schema As DataTable) As Boolean

            For Each column As DataColumn In schema.Columns

                If Not table.Columns.Contains(column.ColumnName) Then
                    Return False
                End If
            Next

            Return True
        End Function

        ''' <summary>
        ''' Scrive il contenuto di un file in un ByteArray
        ''' </summary>
        ''' <param name="filePath">Il path assoluto del file</param>
        ''' <returns>Un array di Byte </returns>
        ''' <remarks></remarks>
        Public Shared Function CopyFileContentToByteArray(ByVal filePath As String) As Byte()

            If String.IsNullOrEmpty(filePath) Then
                Throw New ArgumentNullException("filePath")
            End If

            If Not File.Exists(filePath) Then
                Throw New FileNotFoundException("File non trovato", filePath)
            End If

            Using fileStream As New FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.Read)

                Dim bufferSize As Integer = Convert.ToInt32(fileStream.Length)
                Dim fileContent(bufferSize) As Byte

                fileStream.Read(fileContent, 0, bufferSize)

                Return fileContent
            End Using
        End Function

        ''' <summary>
        ''' Carica un file leggendo il byte array passato
        ''' </summary>
        ''' <param name="byteArray">Il byte array di partenza</param>
        ''' <param name="fileExtension">l'estensione del file da salvare</param>
        ''' <returns>Il path del file temporaneo generato dal byte array</returns>
        ''' <remarks></remarks>
        Public Shared Function CopyByteArrayToTempFile(ByVal byteArray As Byte(), ByVal fileExtension As String) As String

            If String.IsNullOrEmpty(fileExtension) Then
                Throw New ArgumentNullException("fileExtension")
            End If

            If byteArray Is Nothing Then
                Throw New ArgumentNullException("byteArray")
            End If

            Dim resultFilePath As String = GetTempFileName(fileExtension)

            Using fileStream As New FileStream(resultFilePath, FileMode.Create)
                fileStream.Write(byteArray, 0, byteArray.Length)
            End Using

            Return resultFilePath
        End Function

        ''' <summary>
        ''' Restituisce il percorso di un file temporaneo
        ''' </summary>
        ''' <param name="fileExtension">l'estensione del file da creare</param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function GetTempFileName(ByVal fileExtension As String) As String

            Dim tempFilePath As String = Path.Combine(Path.GetTempPath(), Path.GetRandomFileName())

            If Not String.IsNullOrEmpty(fileExtension) Then

                tempFilePath = Path.ChangeExtension(tempFilePath, fileExtension)
            End If

            Return tempFilePath
        End Function

        ''' <summary>
        ''' Crea una cartella di file temporanei 
        ''' </summary>
        ''' <param name="directoryName"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function GetTempDirectory(ByVal directoryName As String) As String

            Dim directoryPath As String = Path.Combine(Path.GetTempPath(), directoryName)

            If Not Directory.Exists(directoryPath) Then
                Directory.CreateDirectory(directoryPath)
            End If

            Return directoryPath
        End Function

        ''' <summary>
        ''' Funzione per il parsing senza eccezioni di una stringa a intero
        ''' </summary>
        ''' <param name="value">Il valore da convertire a intero</param>
        ''' <returns>Restituisce un Nullable(Of Integer) che contiene il valore se il parsing ha successo, null altrimenti</returns>
        ''' <remarks></remarks>
        Public Shared Function ParseNumber(ByVal value As String) As Integer?

            Dim intValue As Integer

            If Integer.TryParse(value, intValue) Then

                Return intValue
            Else
                Return Nothing
            End If
        End Function

        ''' <summary>
		''' Converte da Data a Iso8601
        ''' </summary>
        ''' <param name="iso8601DateTime"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function Iso8601ToDate(ByVal iso8601DateTime As String) As DateTime

            If Not String.IsNullOrEmpty(iso8601DateTime) Then
                Return DateTime.ParseExact(iso8601DateTime, DateTimeISO8601Format, Nothing)
            Else
                Throw New ArgumentException("iso8601DateTime")
            End If
        End Function

        ''' <summary>
        ''' Converte da Iso8601 a Data
        ''' </summary>
        ''' <param name="dateTimeValue"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function DateToIso8601(ByVal dateTimeValue As DateTime) As String

            Return dateTimeValue.ToString(DateTimeISO8601Format)
        End Function

        ''' <summary>
        ''' Prova il parsing di una variabile String in Guid
        ''' </summary>
        ''' <param name="stringToParse">La stringa sulla quale effettuare il TryParse</param>
        ''' <param name="value">Il valore guid oggetto del parsing, Null se non ha successo</param>
        ''' <returns>True se il parsing ha avuto successo, False altrimenti</returns>
        ''' <remarks></remarks>
        Public Shared Function TryParseStringToGuid(ByVal stringToParse As String, ByRef value As Guid?) As Boolean
            Try
                value = New Guid(stringToParse)
                Return True

            Catch ex As FormatException

                value = Nothing
                Return False
            End Try
        End Function

        ''' <summary>
        ''' Restituisce il valore stringa del campo specificato
        ''' </summary>
        ''' <param name="row"></param>
        ''' <param name="fieldName"></param>
        ''' <returns>il valore se presente, nothing altrimenti</returns>
        ''' <remarks></remarks>
        Public Shared Function GetStringValueFromColumn(ByVal row As DataRow, ByVal fieldName As String) As String

            If row Is Nothing Then
                Throw New ArgumentNullException("row")
            End If

            If String.IsNullOrEmpty(fieldName) Then
                Throw New ArgumentException("fieldName")
            End If

            If Not row.Table.Columns.Contains(fieldName) Then
                Throw New ArgumentException("La tabella non contiene il campo specificato", "fieldName")
            End If

            If row(fieldName) Is DBNull.Value OrElse row(fieldName) Is Nothing Then
                Return Nothing
            Else
                Return row(fieldName).ToString()
            End If
        End Function

        ''' <summary>
        ''' Ricava lo schema da una datatable
        ''' </summary>
        ''' <param name="datatable"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function GetXsdSchemaFromDataTable(ByVal datatable As DataTable) As String

            Using writer As New StringWriter()
                datatable.WriteXmlSchema(writer)
                Return writer.ToString()
            End Using
        End Function

        ''' <summary>
        ''' Restituisce la rappresentazione xml di una datatable
        ''' </summary>
        ''' <param name="datatable"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function GetXmlFromDataTable(ByVal datatable As DataTable) As String

            Using writer As New StringWriter()
                datatable.WriteXml(writer)
                Return writer.ToString()
            End Using
        End Function

        ''' <summary>
        ''' Crea una nuova DataTable eseguendo una "distinct" su una DataTable di partenza
        ''' </summary>
        ''' <param name="newTableName">Il nome della tabella da creare</param>
        ''' <param name="sourceTable">L'oggetto DataTable di partenza</param>
        ''' <param name="fieldName">il campo in base al quale eseguire la distinct</param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function CreateDistinctTable(ByVal newTableName As String, ByVal sourceTable As DataTable, ByVal ParamArray fieldName As String()) As DataTable

            Dim view As DataView = New DataView(sourceTable)

            Return view.ToTable(newTableName, True, fieldName)
        End Function

        '''<summary>
        ''' Converte l'esadecimale in un <see cref="Color"/>
        ''' </summary>
        '''<param name="hex"></param>
        ''' <returns></returns>
        Public Shared Function FromHex(hex As String) As Color

            If hex.StartsWith("#") Then
                hex = hex.Substring(1)
            End If

            If hex.Length <> 6 Then
                Throw New ArgumentException("Color not valid", "hex")
            End If

            Return Color.FromArgb(
                Integer.Parse(hex.Substring(0, 2), NumberStyles.HexNumber),
                Integer.Parse(hex.Substring(2, 2), NumberStyles.HexNumber),
                Integer.Parse(hex.Substring(4, 2), NumberStyles.HexNumber))
        End Function

        ''' <summary>
        ''' Restituisce la data di partenza per i filtri in base al periodo selezionato, mappato sulla classe PeriodiFiltri
        ''' </summary>
        ''' <param name="periodo"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function GetDataDaPerFiltro(periodo As String) As DateTime?

            Select Case periodo

                Case PeriodiFiltri.UltimaOra
                    Return DateTime.Now.AddHours(-1)

                Case PeriodiFiltri.Ultime24Ore
                    Return DateTime.Now.AddDays(-1)

                Case PeriodiFiltri.Ultimi7Giorni
                    Return DateTime.Now.AddDays(-7)

                Case PeriodiFiltri.Ultimi30Giorni
                    Return DateTime.Now.AddDays(-30)
            End Select
        End Function

        ''' <summary>
        ''' Restituisce una lista di campi chiave/valore costruita a partire da una <see cref="System.Data.DataTable"></see>
        ''' </summary>
        ''' <param name="table"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function GetListFromDataTable(table As DataTable) As List(Of Dictionary(Of String, String))

            Dim list = New List(Of Dictionary(Of String, String))()

            For Each row In table.Rows

                Dim dictionary = New Dictionary(Of String, String)()
                For Each column As DataColumn In table.Columns

                    dictionary.Add(column.ColumnName, row(column.ColumnName).ToString())
                Next

                list.Add(dictionary)
            Next

            Return list
        End Function

        ''' <summary>
        ''' Converte in Enum in un Dictionary
        ''' </summary>
        ''' <typeparam name="T"></typeparam>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function ConvertEnumToDictionary(Of T)() As IDictionary(Of String, String)

            Dim type = GetType(T)

            If type.BaseType IsNot GetType([Enum]) Then
                Throw New InvalidCastException()
            End If

            Return [Enum].GetValues(type).Cast(Of Object)().ToDictionary(Function(e) CType(e, Integer).ToString(), Function(e) [Enum].GetName(type, e))
        End Function

        ''' <summary>
        ''' Restituisce il nome dell'azienda erogante (ASMN, AUSL) in base al dominio dell'utente. Genera una eccezione se non la trova.
        ''' </summary>
        ''' <returns></returns>
        Public Shared Function GetAziendaRichiedente() As String
            Dim sAzienda As String = Nothing
            Dim sDomain As String = Nothing
            Dim oArray As String() = Split(System.Web.HttpContext.Current.User.Identity.Name, "\"c)
            '
            ' Mi aspetto due elementi nell'array oArray(0)=dominio, oArray(1)=account
            '
            If oArray.Length > 1 Then
                sDomain = oArray(0)
                If String.Compare(sDomain, "OSPEDALE", True) = 0 Then
                    sAzienda = My.Settings.AziendaRichiedente_ASMN
                ElseIf String.Compare(sDomain, "MASTER_USL", True) = 0 Then
                    sAzienda = My.Settings.AziendaRichiedente_AUSL
                ElseIf String.Compare(sDomain, "PROGEL.IT", True) = 0 Then
                    'Per le prove su DAGOBAH
                    sAzienda = My.Settings.AziendaRichiedente_ASMN
                End If
            End If
            If String.IsNullOrEmpty(sAzienda) Then
                Throw New ApplicationException(String.Format("Impossibile ricavare il nome dell'azienda erogante dal dominio dell'utente. Dominio: {0}", sDomain))
            End If
            Return sAzienda
        End Function

        ''' <summary>
        ''' Restituisce il nome dell'azienda erogante in base al dominio dell'utente. Genera una eccezione se non la trova.
        ''' Usa la settings ListDominioAziendaRichiedente "Dominio;AziendaNome"
        ''' </summary>
        ''' <returns></returns>
        Public Shared Function GetAziendaRichiedente2() As String

            Dim sAzienda As String = Nothing
            Dim sDomain As String = Nothing

            ' Mi aspetto due elementi nell'array oArray(0)=dominio, oArray(1)=account
            Dim oArray As String() = Split(System.Web.HttpContext.Current.User.Identity.Name, "\"c)

            Dim listDominioAzienda As Specialized.StringCollection = My.Settings.ListDominioAziendaRichiedente

            If listDominioAzienda IsNot Nothing AndAlso listDominioAzienda.Count > 0 Then

                If oArray.Length > 1 Then
                    sDomain = oArray(0)

                    For Each dominioAzienda As String In listDominioAzienda

                        ' Mi aspetto due elementi nell'array oArrayDominioAzienda(0)=Dominio, oArrayDominioAzienda(1)=Azienda
                        Dim oArrayDominioAzienda As String() = dominioAzienda.Split(";")

                        If Not String.IsNullOrEmpty(oArrayDominioAzienda(0)) AndAlso Not String.IsNullOrEmpty(oArrayDominioAzienda(1)) Then

                            If String.Compare(oArrayDominioAzienda(0), sDomain, True) = 0 Then
                                sAzienda = oArrayDominioAzienda(1).ToUpper()
                            End If

                        End If

                    Next
                End If

            End If

            If String.IsNullOrEmpty(sAzienda) Then
                Throw New ApplicationException(String.Format("Impossibile ricavare il nome dell'azienda erogante dal dominio dell'utente. Dominio: {0}", sDomain))
            End If

            Return sAzienda

        End Function


        ''' <summary>
        ''' Restituisce il nome dell'azienda erogante (ASMN, AUSL) in base all'url.
        ''' </summary>
        ''' <returns></returns>
        Public Shared Function GetAziendaRichiedenteFromUrl(ByVal url As Uri) As String
            Dim sAzienda As String = Nothing
            If url Is Nothing OrElse String.IsNullOrEmpty(url.Host) Then
                Throw New ApplicationException("Impossibile ricavare il nome dell'azienda erogante dall'Host.")
            Else
                Dim sHost As String = url.Host.ToUpper
                If sHost.Contains(My.Settings.AziendaRichiedente_ASMN.ToUpper) Then
                    'SE CONTIENE "ASMN" ALLORA RESTITUISCO ASMN
                    sAzienda = My.Settings.AziendaRichiedente_ASMN
                ElseIf sHost.Contains(My.Settings.AziendaRichiedente_AUSL.ToUpper) Then
                    'SE CONTIENE "AUSL" ALLORA RESTITUISCO AUSL
                    sAzienda = My.Settings.AziendaRichiedente_AUSL
                Else
                    'SI DOVREBBE VERIFICARE SOLO IN SVILUPPO.
                    sAzienda = My.Settings.AziendaRichiedente_ASMN
                End If
            End If

            '
            '
            '
            Return sAzienda
        End Function

        Public Shared Function IsValidGuid(candidate As String)
            Try
                SqlGuid.Parse(candidate)
                Return True
            Catch 'ex As Exception
                Return False
            End Try
        End Function


        Public Shared Function IsValidDateTime(candidate As String)
            Try
                Dim dt As DateTime = DateTime.Parse(candidate)
                'formato SortableDateTime: "2008-03-09T16:05:07" 
                SqlDateTime.Parse(String.Format("{0:s}", dt))
                Return True
            Catch 'ex As Exception
                Return False
            End Try
        End Function

    End Class

    Public NotInheritable Class PeriodiFiltri

        Private Sub New()

        End Sub

        Public Shared ReadOnly UltimaOra As String = "1"
        Public Shared ReadOnly Ultime24Ore = "2"
        Public Shared ReadOnly Ultimi7Giorni = "3"
        Public Shared ReadOnly Ultimi30Giorni = "4"
    End Class


End Namespace