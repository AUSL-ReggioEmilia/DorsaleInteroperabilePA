Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Data
Imports DI.OrderEntry.Admin.Data.Profili
Imports DI.OrderEntry.Admin.Data.ProfiliTableAdapters
Imports DI.OrderEntry.Admin.Data
Imports DI.Common
Imports System.Web.Services
Imports System.Collections.Generic
Imports System.Web
Imports DI.PortalAdmin.Data
Imports System.Configuration
Imports System.Linq
Imports System.Data.DataTableExtensions
Imports System.IO
Imports System.Text

Namespace DI.OrderEntry.Admin

    Public Class Profili
        Inherits Page

        Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

#Region "Property di Pagina"
        Private Const PageSessionIdPrefix As String = "Profili_"

        Private Property FilterLoaded() As Boolean
            Get
                Dim o As Object = Session(PageSessionIdPrefix + "FilterLoaded")
                If o Is Nothing Then Return String.Empty Else Return o.ToString()
            End Get
            Set(ByVal value As Boolean)
                Session(PageSessionIdPrefix + "FilterLoaded") = value
            End Set
        End Property

        Private Property SortExpression() As String
            Get
                Dim o As Object = Session(PageSessionIdPrefix + "SortExpression")
                If o Is Nothing Then Return String.Empty Else Return o.ToString()
            End Get
            Set(ByVal value As String)
                Session(PageSessionIdPrefix + "SortExpression") = value
            End Set
        End Property

        Private Property SortDirection() As SortDirection
            Get
                Dim o As Object = Session(PageSessionIdPrefix + "SortDirection")
                If o Is Nothing Then Return Nothing Else Return DirectCast(o, SortDirection)
            End Get
            Set(ByVal value As SortDirection)
                Session(PageSessionIdPrefix + "SortDirection") = value
            End Set
        End Property
#End Region

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            If Not Page.IsPostBack Then
                FilterHelper.Restore(filterPanel, msPAGEKEY)
                Me.GridViewProfili.Sort(SortExpression, SortDirection)
            Else
                SaveFilters()
            End If

            LoadFilters()
        End Sub

        ''' <summary>
        ''' Pulsante Cerca
        ''' </summary>
        Public Sub CaricaProfili()
            ErrorLabel.Text = ""
            ErrorLabel.Visible = False
            Me.ObjectDataSourceProfili.DataBind()
            Me.GridViewProfili.DataBind()
        End Sub

        Private Sub SaveFilters()

            For Each control As Control In Me.filterPanel.Controls

                Dim value As String = String.Empty

                Dim filterTextBox = TryCast(control, TextBox)

                If filterTextBox IsNot Nothing Then

                    value = filterTextBox.Text
                Else
                    Dim filterComboBox = TryCast(control, DropDownList)

                    If filterComboBox IsNot Nothing Then

                        value = filterComboBox.SelectedValue
                    Else
                        Dim filterCheckBox = TryCast(control, CheckBox)

                        If filterCheckBox IsNot Nothing Then

                            value = filterCheckBox.Checked.ToString()
                        End If
                    End If
                End If

                If Session(PageSessionIdPrefix + control.ID) Is Nothing Then

                    Session.Add(PageSessionIdPrefix + control.ID, value)
                Else
                    Session(PageSessionIdPrefix + control.ID) = value
                End If
            Next
        End Sub

        Private Sub LoadFilters()

            Me.FilterLoaded = False

            For Each control As Control In filterPanel.Controls

                Dim value As String = If(String.IsNullOrEmpty(control.ID), String.Empty, Session(PageSessionIdPrefix + control.ID))

                If value Is Nothing Then
                    Continue For
                End If

                Dim filterTextBox = TryCast(control, TextBox)

                If filterTextBox IsNot Nothing Then

                    filterTextBox.Text = value

                    Me.FilterLoaded = True
                Else
                    Dim filterComboBox = TryCast(control, DropDownList)

                    If filterComboBox IsNot Nothing Then

                        filterComboBox.SelectedValue = value

                        Me.FilterLoaded = True
                    Else
                        Dim filterCheckBox = TryCast(control, CheckBox)

                        If filterCheckBox IsNot Nothing Then

                            filterCheckBox.Checked = Boolean.Parse(value)

                            Me.FilterLoaded = True
                        End If
                    End If
                End If
            Next
        End Sub

        Protected Sub GridViewProfili_Sorted(sender As Object, e As EventArgs) Handles GridViewProfili.Sorted

            Me.SortExpression = GridViewProfili.SortExpression
            Me.SortDirection = GridViewProfili.SortDirection
        End Sub

        Protected Sub GridViewProfili_ItemCommand(sender As Object, e As GridViewCommandEventArgs) Handles GridViewProfili.RowCommand

            If e.CommandName = "Elimina" Then

                Try
                    Dim idProfilo = New Guid(e.CommandArgument.ToString())
                    DeleteProfilo(idProfilo.ToString)
                    Response.Redirect(Request.RawUrl)

                Catch ex As Exception
                    ExceptionsManager.TraceException(ex)
                    Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                    portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                End Try
            End If

        End Sub

        <WebMethod()>
        Public Shared Function GetLookupSistemiEroganti() As Dictionary(Of String, String)
            Try
                Dim sistemiLookup = New Data.Ennuple.UiLookupSistemiErogantiDataTable()

                DataAdapterManager.Fill(sistemiLookup, Nothing, False)

                Return (From sistema In sistemiLookup
                        Select New With {.Id = sistema.Id, .Descrizione = sistema.Descrizione}).ToDictionary(Of String, String)(Function(kv) CType(kv.Id, Guid).ToString(), Function(kv) kv.Descrizione)
            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Throw
            End Try
        End Function

        <WebMethod()>
        Public Shared Function GetFilter(controlId As String) As String

            Dim parameterValue As String = If(HttpContext.Current.Session(PageSessionIdPrefix + controlId) Is Nothing, Nothing, HttpContext.Current.Session(PageSessionIdPrefix + controlId))

            Return parameterValue

        End Function

        Public Shared Function GetTipoProfiloImage(tipo As String) As String

            Dim imageUrl As String = String.Empty

            If (tipo = 1) Then
                'tooltip = 'Profilo non scomponibile';
                imageUrl = "../Images/lock.png"
            Else
                'tooltip = 'Profilo scomponibile';
                imageUrl = "../Images/unlock.png"
            End If

            Return imageUrl

        End Function

        Public Shared Function GetTipoProfiloTooltip(tipo As String) As String

            Dim tooltip As String = String.Empty

            If (tipo = 1) Then
                tooltip = "Profilo non scomponibile"
            Else
                tooltip = "Profilo scomponibile"
            End If

            Return tooltip

        End Function

        <WebMethod()>
        Public Shared Function GetPrestazioni(idProfilo As String, descrizioneFiltroPrestazioneProfilo As String, idSistemiErogantiFiltroPrestazioneProfilo As String) As Dictionary(Of String, Object)

            Try

                If Not String.IsNullOrEmpty(descrizioneFiltroPrestazioneProfilo) Then
                    descrizioneFiltroPrestazioneProfilo = Utils.JavascriptUnEscape(descrizioneFiltroPrestazioneProfilo)
                End If

                Dim idSE As Guid? = Nothing

                If Not String.IsNullOrEmpty(idSistemiErogantiFiltroPrestazioneProfilo) Then
                    idSE = New Guid(idSistemiErogantiFiltroPrestazioneProfilo)
                End If

                Dim prestazioniDataTable = New UiProfiliPrestazioniProfiliListDataTable()
                Dim list = New Dictionary(Of String, Object)()

                DataAdapterManager.Fill(prestazioniDataTable, New Guid(idProfilo), descrizioneFiltroPrestazioneProfilo, idSE)

                For Each row As UiProfiliPrestazioniProfiliListRow In prestazioniDataTable

                    Dim Prestazione = New With {.Id = row.ID, .Codice = row.Codice, .Descrizione = row.Descrizione, .SistemaErogante = row.SistemaErogante}
                    list.Add(row.ID.ToString(), Prestazione)
                Next

                Return If(list.Count = 0, Nothing, list)

            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Throw
            End Try

        End Function

        <WebMethod()>
        Public Shared Function GetListaPrestazioni(descrizione As String, idSistemaErogante As String) As Object()
            Try
                If Not String.IsNullOrEmpty(descrizione) Then
                    descrizione = Utils.JavascriptUnEscape(descrizione)
                End If

                Dim idSE As Guid? = Nothing

                If Not String.IsNullOrEmpty(idSistemaErogante) Then
                    idSE = New Guid(idSistemaErogante)
                End If

                Dim prestazioneTable = New Data.Profili.UiProfiliPrestazioniSelectDataTable

                DataAdapterManager.Fill(prestazioneTable, Nothing, descrizione, idSE, Nothing, True)

                If prestazioneTable.Count = 0 Then
                    Return Nothing
                Else
                    Dim result = From row In prestazioneTable
                                 Select New With {.Id = row.ID, .Codice = row.Codice, .Descrizione = row.Descrizione, .SistemaErogante = row.SistemaErogante}

                    Return result.ToArray()
                End If
            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Throw
            End Try
        End Function

        <WebMethod()>
        Public Shared Function UpdateProfilo(idProfilo As String, codice As String, descrizione As String, tipo As Integer, attivo As Boolean?, CopiaDaProfiloId As String, note As String) As String
            Try
                If String.IsNullOrEmpty(idProfilo) Then

                    Dim profiloTable As New UiProfiliPrestazioniListDataTable()
                    profiloTable.AddUiProfiliPrestazioniListRow(Guid.NewGuid(), Utils.JavascriptUnEscape(codice), Utils.JavascriptUnEscape(descrizione), tipo, My.User.Name, attivo, Utils.JavascriptUnEscape(note))
                    DataAdapterManager.Update(profiloTable)

                    Dim gIDNuovoProfilo As Guid = profiloTable(0).ID
                    'copio le stesse prestazioni anche sul nuovo gruppo
                    If Not String.IsNullOrEmpty(CopiaDaProfiloId) Then
                        Dim gIDGruppoOrigine As Guid = New Guid(CopiaDaProfiloId)
                        DataAdapterManager.PrestazioniProfiloPrestazioniCopy(gIDGruppoOrigine, gIDNuovoProfilo)
                    End If

                    Return gIDNuovoProfilo.ToString()

                Else
                    Dim profiloTable As New UiProfiliPrestazioniListDataTable()

                    Dim row = profiloTable.AddUiProfiliPrestazioniListRow(New Guid(idProfilo), Utils.JavascriptUnEscape(codice), Utils.JavascriptUnEscape(descrizione), tipo, My.User.Name, attivo, Utils.JavascriptUnEscape(note))
                    profiloTable.AcceptChanges()
                    row.SetModified()

                    DataAdapterManager.Update(profiloTable)

                    Return idProfilo
                End If
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Throw
            End Try
        End Function

        <WebMethod()>
        Public Shared Function DeleteProfilo(idProfilo As String) As String
            Try
                DataAdapterManager.DeleteProfilePrestazioni(New Guid(idProfilo), My.User.Name)

                Return "ok"
            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Return "error"
            End Try
        End Function

        <WebMethod()>
        Public Shared Function DeletePrestazioneDaProfilo(idProfilo As String, idPrestazioni As String) As String
            Try
                For Each idPrestazione In idPrestazioni.Split(";"c)
                    DataAdapterManager.DeletePrestazioneFromProfile(New Guid(idPrestazione.ToString()), New Guid(idProfilo))
                Next

                Return "ok"
            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Throw
            End Try
        End Function

        ''' <summary>
        ''' 
        ''' </summary>
        ''' <param name="idProfilo"></param>
        ''' <param name="idPrestazioni">Elenco di idPrestazione concatenati da ";"</param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        <WebMethod()>
        Public Shared Function InsertPrestazioniInProfilo(idProfilo As String, idPrestazioni As String) As String
            Try
                Dim idPrestazioniGuid = From idPrestazione In idPrestazioni.Split(";"c)
                                        Select New Guid(idPrestazione)

                DataAdapterManager.InsertPrestazioniInProfile(New Guid(idProfilo), idPrestazioniGuid.ToArray())

                Return "ok"
            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Throw
            End Try
        End Function

        Private Sub ObjectDataSourceProfili_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles ObjectDataSourceProfili.Selected
            '
            'Gestisco gli errori dell'ObjectDataSource.
            '
            GestioneErrori.ObjectDataSource_TrapError(e, ErrorLabel)
        End Sub

#Region "GestioneCSV"
        Private Sub btnEsportaCsvEsempio_Click(sender As Object, e As EventArgs) Handles btnEsportaCsvEsempio.Click
            Try
                '
                'Ottengo i profili.
                '
                Dim dt As UiProfiliPrestazioniListDataTable
                Using ta As New ProfiliTableAdapters.UiProfiliPrestazioniListTableAdapter
                    dt = ta.GetData(Nothing, Nothing, Nothing, Nothing, Nothing)
                End Using

                '
                'Verifico che la datatable sia valorizzata.
                '
                If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
                    Dim CodiceProfilo As String = String.Empty

                    Dim oPrestazioni As Dictionary(Of String, Object) = Nothing

                    '
                    'Ciclo tutti i profili finchè non ne trovo uno con delle prestazioni.
                    'Eseguo un for in modo da generare un csv di esempio usando un profilo REALE con delle PRESTAZIONI.
                    For Each row As UiProfiliPrestazioniListRow In dt.Rows

                        '
                        'Ottengo le prestazoni del profilo. 
                        'ATTENZIONE: ciclo tutti i profili fino a quando non ne trovo uno con delle prestazioni.
                        '
                        oPrestazioni = GetPrestazioni(row.ID.ToString, Nothing, Nothing)
                        If Not oPrestazioni Is Nothing AndAlso oPrestazioni.Count > 0 Then
                            '
                            'Salvo il codice del profilo solo quando ne ho trovato uno con delle prestazioni.
                            '
                            CodiceProfilo = row.Codice

                            '
                            'Esco dal for.
                            '
                            Exit For
                        End If
                    Next

                    Dim csvFile As String = String.Empty

                    '
                    'Colonne che compongono il CSV
                    '
                    Dim listaColonne As New List(Of String)
                    listaColonne.Add("CodiceProfilo")
                    listaColonne.Add("CodicePrestazione")
                    listaColonne.Add("CodiceSistema")
                    listaColonne.Add("CodiceAzienda")
                    listaColonne.Add("DescrizioneProfilo")
                    listaColonne.Add("ProfiloAttivo")
                    listaColonne.Add("TipoProfilo")
                    listaColonne.Add("NoteProfilo")

                    '
                    'Aggiungo le colonne al csv.
                    '
                    For Each item In listaColonne
                        csvFile += item.Replace(",", ";") + ","c
                    Next

                    'Rimuovo l'ultima virgola dalla stringa.
                    csvFile = csvFile.Substring(0, csvFile.Count - 1)
                    csvFile += Environment.NewLine

                    For Each prestazioni In oPrestazioni
                        '
                        'Ottengo il codice della prestazione.
                        '
                        Dim sCodicePrestazione As String = prestazioni.Value.Codice

                        '
                        'Il campo SistemaErogante è composto da AZIENDA - CODICE SISTEMA.
                        '
                        Dim sAziendaSistema As String = prestazioni.Value.SistemaErogante

                        '
                        'Ottengo l'azienda erogante splittando la stringa AziendaSistema  
                        '
                        Dim sCodiceAziendaErogante As String = sAziendaSistema.Split("-").First

                        '
                        'Ottengo il sistema erogante eliminando dalla stringa iniziale l'azienda.
                        '
                        Dim sCodiceSistemaErogante As String = sAziendaSistema.Replace(sCodiceAziendaErogante + "-", "")

                        '
                        'Valorizzo i campi CodiceProfilo, CodicePrestazione,CodiceAzienda e CodiceSistema del csv.
                        '
                        csvFile += CodiceProfilo.Replace(",", ";") + ","c
                        csvFile += sCodicePrestazione.Replace(",", ";") + ","c
                        csvFile += sCodiceSistemaErogante.Replace(",", ";") + ","c
                        csvFile += sCodiceAziendaErogante.Replace(",", ";") + ","c

                        '
                        'VALORIZZO I CAMPI OBBLIGATORI SOLO PER I NUOVI PROFILI CON UNA STRINGA DESCRITTIVA:
                        '
                        csvFile += "DESCRIZIONE: OBBLIGATORIA SOLO PER NUOVO PROFILO" + ","c
                        csvFile += "ATTIVO (1 o 0): OBBLIGATORIO SOLO PER NUOVO PROFILO" + ","c
                        csvFile += "TIPO (1 o 2): OBBLIGATORIO SOLO PER NUOVO PROFILO"
                        csvFile += "NOTE: NON OBBLIGATORIE"

                        '
                        'Aggiungo una linea al csv
                        '
                        csvFile += Environment.NewLine
                    Next

                    '
                    'NECESSARIO PER SALVARE IL CSV IN UTF-8.
                    '
                    Dim utf8 As Encoding = Encoding.UTF8
                    csvFile = csvFile.TrimStart(Encoding.UTF8.GetString(Encoding.UTF8.GetPreamble()))
                    csvFile = Encoding.UTF8.GetString(Encoding.UTF8.GetPreamble()) + csvFile
                    Dim oBytesUtf8 As Byte() = utf8.GetBytes(csvFile)


                    '
                    'Eseguo il download del csv.
                    '
                    Response.Clear()
                    Response.Buffer = True
                    Response.AddHeader("content-disposition", "attachment;filename=SqlExport.csv")
                    Response.Charset = ""
                    Response.ContentType = "application/text"
                    Response.Output.Write(utf8.GetString(oBytesUtf8))
                    Response.Flush()
                    Response.End()
                End If
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try
        End Sub

        Protected Sub ImportButton_Click(sender As Object, e As EventArgs) Handles ImportButton.Click
            Me.ErrorLabel.Visible = False
            Dim errorString As New Text.StringBuilder

            '
            'Verifico se è stato importato un file.
            '
            If CsvFileUpload.HasFile Then
                Try
                    '
                    'Se il file è maggiore di 10MB genero un errore.
                    '
                    If CsvFileUpload.PostedFile.ContentLength > CSVHelper.Size10MB Then
                        ErrorLabel.Text = "Errore durante l'importazione: Il file deve avere una dimensione minore di 10 Mb."
                        ErrorLabel.Visible = True
                        Return
                    End If

                    '
                    'Ottengo i Byte() dal file caricato.
                    '
                    Dim data As Byte() = CsvFileUpload.FileBytes

                    '
                    'Se non è in UTF8 genenero un errore.
                    '
                    If Not CSVHelper.IsValidUTF8(data) Then
                        ErrorLabel.Text = "Errore durante l'importazione: Il file deve avere codifica UTF-8."
                        ErrorLabel.Visible = True
                        Return
                    End If

                    Dim sistemiTable As New Sistemi.UiSistemiSelectDataTable()
                    Dim prestazioneTable = New UiProfiliPrestazioniSelectDataTable()
                    Dim profiliTable = New UiProfiliPrestazioniListDataTable()

                    '
                    'Trasformo il file CSV in una datatable.
                    '
                    Dim CsvTable As DataTable = CSVHelper.CsvToDataTable(data)

                    '
                    'Il CSV deve avere almeno le seguenti colonne:
                    ' 1) codiceprofilo
                    ' 2) codiceprestazione
                    ' 3) codicesistema
                    ' 4) codiceazienda
                    '
                    If (CsvTable.Columns.Contains("codiceprofilo") AndAlso CsvTable.Columns.Contains("codiceprestazione") AndAlso
                        CsvTable.Columns.Contains("codicesistema") AndAlso CsvTable.Columns.Contains("codiceazienda")) Then

                        Dim iCont As Integer = 2 'Parte da 2 perchè nella prima riga ci sono le intestazioni

                        '
                        'Ciclo tutte le row della datatable.
                        '
                        For Each row In CsvTable.Rows
                            Try
                                '
                                'Ottengo il codice del profilo.
                                '
                                Dim codiceProfilo As String = row("codiceprofilo").ToString.ToLowerInvariant

                                '
                                'Cerco sulla tabella il profilo con codice = codiceProfilo.
                                '
                                DataAdapterManager.Fill(profiliTable, codiceProfilo, Nothing, Nothing, Nothing, Nothing)
                                Dim resultProfili = From profilo In profiliTable
                                                    Where profilo.Codice.ToLowerInvariant = codiceProfilo
                                                    Select profilo.ID

                                '
                                'Se resultProfili è vuoto allora non esiste il profilo indicato quindi lo creo.
                                '
                                If resultProfili Is Nothing OrElse resultProfili.Count = 0 Then
                                    Dim descrizioneProfilo As String = row("descrizioneprofilo").ToString.ToLowerInvariant
                                    Dim attivoProfilo As Boolean = row("profiloattivo").ToString.ToLowerInvariant
                                    Dim tipoProfilo As Integer = row("tipoprofilo").ToString.ToLowerInvariant
                                    Dim noteProfilo As String = row("noteprofilo").ToString.ToLowerInvariant

                                    '
                                    'Se queste colonne non sono valorizzate restituisco un errore.
                                    '
                                    If String.IsNullOrEmpty(descrizioneProfilo) OrElse String.IsNullOrEmpty(attivoProfilo) OrElse String.IsNullOrEmpty(tipoProfilo) Then
                                        Throw New Exception("Le colonne DescrizioneProfilo, ProfiloAttivo e TipoProfilo sono obbligatorie per i profili non esistenti.")
                                    End If

                                    '
                                    'Se sono qui il profilo NON esiste quindi lo creo.
                                    '
                                    UpdateProfilo(Nothing, codiceProfilo, descrizioneProfilo, tipoProfilo, attivoProfilo, Nothing, noteProfilo)
                                End If

                                '
                                'Ottengo le altre colonne.
                                '
                                Dim codicePrestazione As String = row("codiceprestazione").ToString.ToLowerInvariant
                                Dim codiceSistema As String = row("codicesistema").ToString.ToLowerInvariant
                                Dim codiceAzienda As String = row("codiceazienda").ToString.ToLowerInvariant

                                '
                                'Verifico che il sistema esista.
                                '
                                DataAdapterManager.Fill(sistemiTable, Nothing, codiceSistema, codiceAzienda, Nothing, Nothing, Nothing, Nothing, Nothing)
                                Dim resultSistema = From sistema In sistemiTable
                                                    Where sistema.Azienda.ToLowerInvariant = codiceAzienda AndAlso sistema.Codice.ToLowerInvariant = codiceSistema
                                                    Select sistema.ID

                                If resultSistema Is Nothing OrElse resultSistema.Count <> 1 Then
                                    errorString.Append("Non è stato possibile caricare la riga " & iCont.ToString & "; Sistema non trovato: Codice= " & codiceSistema & "; Azienda= " & codiceAzienda)
                                    errorString.Append("<br/>")
                                    Continue For
                                End If

                                '
                                'Verifico che la prestazione esista.
                                '
                                DataAdapterManager.Fill(prestazioneTable, Nothing, codicePrestazione, resultSistema.FirstOrDefault, Nothing, Nothing)
                                Dim resultPrestazioni = From prestazione In prestazioneTable
                                                        Where prestazione.Codice.ToLowerInvariant = codicePrestazione AndAlso prestazione.IDSistemaErogante = resultSistema.First
                                                        Select prestazione.ID

                                If resultPrestazioni Is Nothing OrElse resultPrestazioni.Count <> 1 Then
                                    errorString.Append("Non è stato possibile caricare la riga " & iCont.ToString & "; Prestazione non trovata: Codice= " & codicePrestazione)
                                    errorString.Append("<br/>")
                                    Continue For
                                End If


                                '
                                'Ottengo l'id del profilo a cui associare la prestazione.
                                '
                                DataAdapterManager.Fill(profiliTable, codiceProfilo, Nothing, Nothing, Nothing, Nothing)
                                Dim resultProfili2 = From profilo In profiliTable
                                                     Where profilo.Codice.ToLowerInvariant = codiceProfilo
                                                     Select profilo.ID

                                If resultProfili2 Is Nothing OrElse resultProfili2.Count <> 1 Then
                                    errorString.Append("Non è stato possibile caricare la riga " & iCont.ToString & "; Profilo non trovato: Codice= " & codiceProfilo)
                                    errorString.Append("<br/>")
                                End If

                                '
                                'Associo la prestazione al profilo indicato.
                                '
                                Using adapter As New ProfiliQuery()
                                    adapter.UiProfiliPrestazioniProfiliInsert(resultPrestazioni.FirstOrDefault, resultProfili2.FirstOrDefault)
                                End Using

                            Catch ex As Exception
                                ExceptionsManager.TraceException(ex)
                                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                            End Try

                            iCont += 1
                        Next

                    Else
                        errorString.Append("Errore durante l'importazione: Il file deve avere le seguenti colonne: CodiceProfilo, CodicePrestazione, CodiceSistema, CodiceAzienda.")
                    End If

                Catch ex As Exception
                    ExceptionsManager.TraceException(ex)
                    Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                    portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                    errorString.Append("Errore durante l'importazione: Il file deve avere le seguenti colonne: CodiceProfilo, CodicePrestazione, CodiceSistema, CodiceAzienda.")
                    ErrorLabel.Visible = True
                End Try
            Else
                errorString.Append("Errore durante l'importazione da file csv, controllare il formato del file.")
            End If

            If errorString.ToString.Length > 0 Then
                ErrorLabel.Text = errorString.ToString
                ErrorLabel.Visible = True
            End If
        End Sub

        Private Sub CercaButton_Click(sender As Object, e As EventArgs) Handles CercaButton.Click
            Try
                GridViewProfili.DataBind()
                FilterHelper.SaveInSession(filterPanel, msPAGEKEY)
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try
        End Sub
#End Region
    End Class

End Namespace