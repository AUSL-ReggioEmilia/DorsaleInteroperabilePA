Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Data
Imports DI.OrderEntry.Admin.Data
Imports DI.OrderEntry.Admin.Data.DatiAccessori
Imports System.Web.Services
Imports System.Web
Imports DI.PortalAdmin.Data
Imports System.Configuration
Imports System.Linq
Imports System.Collections.Generic
Imports System.Text

Namespace DI.OrderEntry.Admin

    Public Class DatiAccessori
        Inherits Page

        Private Const PageSessionIdPrefix As String = "DatiAccessori_"

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

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
            If Not Page.IsPostBack Then
                DatiAccessoriListView.Sort(SortExpression, SortDirection)
            Else
                SaveFilters()
            End If
            LoadFilters()
        End Sub

        Protected Sub CercaButton_Click(sender As Object, e As EventArgs) Handles CercaButton.Click

            DatiAccessoriListView.DataBind()

        End Sub

        Protected Sub DatiAccessoriObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles DatiAccessoriObjectDataSource.Selecting

            If Not Page.IsPostBack AndAlso Not Me.FilterLoaded Then
                e.Cancel = True
            End If
        End Sub

        Protected Sub DatiAccessoriListView_Sorted(sender As Object, e As EventArgs) Handles DatiAccessoriListView.Sorted
            Me.SortExpression = DatiAccessoriListView.SortExpression
            Me.SortDirection = DatiAccessoriListView.SortDirection
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

        <WebMethod()>
        Public Shared Function SaveFilter(controlId As String, value As String) As String

            If HttpContext.Current.Session(PageSessionIdPrefix + controlId) Is Nothing Then
                HttpContext.Current.Session.Add(PageSessionIdPrefix + controlId, value)
            Else
                HttpContext.Current.Session(PageSessionIdPrefix + controlId) = value
            End If

            Return "ok"
        End Function

        Private Sub SaveFilters()

            For Each control As Control In filterPanel.Controls

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


        <WebMethod()>
        Public Shared Function GetDatiSistemaDiDefault() As Object
            Try
                Dim datoTable = New UiLookupDatiAccessoriValoriDefaultDataTable()

                DataAdapterManager.Fill(datoTable)

                If datoTable.Count = 0 Then
                    Return Nothing
                Else
                    Return (From dato In datoTable
                            Select New With {.Codice = dato.Codice, .Descrizione = dato.Descrizione}).ToArray()
                End If
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Throw
            End Try
        End Function

        <WebMethod()>
        Public Shared Function GetDato(codice As String) As Object
            Try
                codice = Utils.JavascriptUnEscape(codice)
                Dim datoTable = New UiDatiAccessoriListDataTable()
                'RECUPERO LA RIGA DI DATIACCESSORI PER CODICE (CHIAVE)
                DataAdapterManager.Fill(datoTable, codice, Nothing, Nothing, 1000)

                If datoTable.Count = 0 Then
                    Return Nothing
                Else
                    Dim row = (From dato In datoTable
                               Where String.Equals(dato.Codice, codice, StringComparison.InvariantCultureIgnoreCase)
                               Select dato).First()

                    Return New With {.Codice = row.Codice, .Descrizione = row.Descrizione, .Etichetta = row.Etichetta, .Tipo = row.Tipo,
                                     .Obbligatorio = row.Obbligatorio, .Ripetibile = row.Ripetibile, .Valori = row.Valori,
                                     .Ordinamento = row.Ordinamento, .Gruppo = row.Gruppo, .ValidazioneRegEx = row.ValidazioneRegex,
                                     .ValidazioneMessaggio = row.ValidazioneMessaggio, .Sistema = row.Sistema, .ValoreDefault = row.ValoreDefault,
                                     .NomeDatoAggiuntivo = row.NomeDatoAggiuntivo, .Concatena = row.ConcatenaNomeUguale}
                End If
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Throw
            End Try
        End Function

        <WebMethod()>
        Public Shared Function UpdateDato(insert As Boolean, codice As String, descrizione As String, etichetta As String, tipo As String,
                                          obbligatorio As Boolean, ripetibile As Boolean, valori As String, ordinamento As Integer?,
                                          gruppo As String, validazioneRegEx As String, validazioneMessaggio As String, sistema As Boolean,
                                          valoreDefault As String, nomeDatoAggiuntivo As String, concatena As Boolean) As String
            Try
                Dim datoTable As New UiDatiAccessoriListDataTable()
                Dim row = datoTable.AddUiDatiAccessoriListRow(Utils.JavascriptUnEscape(codice),
                                                              Utils.JavascriptUnEscape(descrizione),
                                                              DateTime.Now, DateTime.Now, My.User.Name,
                                                              Utils.JavascriptUnEscape(etichetta),
                                                              tipo, obbligatorio, ripetibile,
                                                              Utils.JavascriptUnEscape(valori),
                                                              ordinamento,
                                                              Utils.JavascriptUnEscape(gruppo),
                                                              Utils.JavascriptUnEscape(validazioneRegEx),
                                                              Utils.JavascriptUnEscape(validazioneMessaggio),
                                                              sistema,
                                                              Utils.JavascriptUnEscape(valoreDefault),
                                                              Utils.JavascriptUnEscape(nomeDatoAggiuntivo),
                                                              concatena)
                If Not insert Then
                    row.AcceptChanges()
                    row.SetModified()
                End If
                DataAdapterManager.Update(datoTable)

                Return codice

            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Throw
            End Try
        End Function

        <WebMethod()>
        Public Shared Function CheckCodeUnicity(codice As String) As String

            Return DataAdapterManager.CheckDatiAccessoriCodeUnicity(codice) > 0

        End Function

        <WebMethod()>
        Public Shared Function GetDatiAccessoriPreview(codice As String) As Object

            Return (From e In DataAdapterManager.GetDatiAccessoriPreview(codice)
                    Select New With {.Descrizione = e.Descrizione, .Tipo = e.Tipo}).ToArray()
        End Function

        <WebMethod()>
        Public Shared Function GetDatiAccessoriSistemi(codice As String) As Object

            Return (From e In DataAdapterManager.GetDatiAccessoriSistemi(codice)
                    Select New With {.Descrizione = e.Descrizione, .Codice = e.Codice, .IdSistema = e.IDSistema}).ToArray()
        End Function

        Private Sub ImportButton_Click(sender As Object, e As EventArgs) Handles ImportButton.Click
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

                    Dim datiAccessoriDataTable = New UiDatiAccessoriListDataTable()

                    '
                    'Trasformo il file CSV in una datatable.
                    '
                    Dim CsvTable As DataTable = CSVHelper.CsvToDataTable(data)

                    '
                    'Il CSV deve avere almeno le seguenti colonne:
                    ' 1) codice
                    '
                    If (CsvTable.Columns.Contains("codice")) Then

                        Dim iCont As Integer = 2 'Parte da 2 perchè nella prima riga ci sono le intestazioni

                        '
                        'Ciclo tutte le row della datatable.
                        '
                        For Each row In CsvTable.Rows
                            '
                            'Ottengo il codice del dato accessorio.
                            '
                            Dim codiceDatoAccessorio As String = row("codice").ToString.ToLowerInvariant
                            Try
                                '
                                'Se queste colonne non sono valorizzate restituisco un errore.
                                '
                                If String.IsNullOrEmpty(codiceDatoAccessorio) Then
                                    Throw New Exception("Le colonna codice è obbligatoria.")
                                End If

                                '
                                'Cerco sulla tabella il profilo con codice = codiceDatoAccessorio.
                                '
                                DataAdapterManager.Fill(datiAccessoriDataTable, codiceDatoAccessorio, Nothing, Nothing, 1000)
                                Dim resultDatiAccessori = From datoAccessorio In datiAccessoriDataTable
                                                          Where datoAccessorio.Codice.ToLowerInvariant = codiceDatoAccessorio
                                                          Select datoAccessorio.Codice


                                Dim descrizioneDatoAccessorio As String = row("descrizione").ToString.ToLowerInvariant
                                Dim etichettaDatoAccessorio As String = row("etichetta").ToString.ToLowerInvariant
                                Dim tipoDatoAccessorio As String = row("tipo")
                                Dim datoAccessorioObbligatorio As Boolean = row("obbligatorio").ToString.ToLowerInvariant
                                Dim datoAccessorioRipetibile As Boolean = row("ripetibile").ToString.ToLowerInvariant
                                Dim valoriDatoAccessorio As String = row("valori")
                                Dim ordinamentoDatoAccessorio As Integer = row("ordinamento")
                                Dim gruppoDatoAccessorio As String = row("gruppo")
                                Dim regexValidazioneDatoAccessorio As String = row("regexvalidazione")
                                Dim messaggioValidazioneDatoAccessorio As String = row("messaggiovalidazione")
                                Dim datoAccessorioDiSistema As Boolean = row("disistema").ToString.ToLowerInvariant
                                Dim valoreDefaultDatoAccessorio As String = row("valoredefault").ToString.ToLowerInvariant
                                Dim sinonimoDatoAccessorio As String = row("sinonimo").ToString.ToLowerInvariant
                                Dim concatenaSeUgualeDatoAccessorio As Boolean = row("concatenaseuguale").ToString.ToLowerInvariant

                                '
                                'Se resultDatiAccessori è vuoto allora non esiste il profilo indicato quindi lo creo.
                                '
                                If resultDatiAccessori Is Nothing OrElse resultDatiAccessori.Count = 0 Then
                                    '
                                    'Se sono qui il profilo NON esiste quindi lo creo.
                                    '
                                    UpdateDato(1, codiceDatoAccessorio, descrizioneDatoAccessorio, etichettaDatoAccessorio, tipoDatoAccessorio, datoAccessorioObbligatorio, datoAccessorioRipetibile,
                                               valoriDatoAccessorio, ordinamentoDatoAccessorio, gruppoDatoAccessorio, regexValidazioneDatoAccessorio, messaggioValidazioneDatoAccessorio, datoAccessorioDiSistema, valoreDefaultDatoAccessorio, sinonimoDatoAccessorio, concatenaSeUgualeDatoAccessorio)
                                Else
                                    '
                                    'Se sono qui il profilo esiste quindi lo modifico.
                                    '
                                    UpdateDato(0, codiceDatoAccessorio, descrizioneDatoAccessorio, etichettaDatoAccessorio, tipoDatoAccessorio, datoAccessorioObbligatorio, datoAccessorioRipetibile,
                                               valoriDatoAccessorio, ordinamentoDatoAccessorio, gruppoDatoAccessorio, regexValidazioneDatoAccessorio, messaggioValidazioneDatoAccessorio, datoAccessorioDiSistema, valoreDefaultDatoAccessorio, sinonimoDatoAccessorio, concatenaSeUgualeDatoAccessorio)
                                End If

                            Catch ex As Exception
                                ExceptionsManager.TraceException(ex)
                                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                                errorString.Append("Si è verificato un errore durante l'importazione del file csv. CodiceDatoAccessorio = " & codiceDatoAccessorio)
                            End Try

                            iCont += 1
                        Next

                    Else
                        errorString.Append("Errore durante l'importazione: Il file deve avere le seguenti colonne: Codice")
                    End If

                Catch ex As Exception
                    ExceptionsManager.TraceException(ex)
                    Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                    portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                    errorString.Append("Errore durante l'importazione: Il file deve avere le seguenti colonne: Codice.")
                    ErrorLabel.Visible = True
                End Try
            Else
                errorString.Append("Errore durante l'importazione da file csv, controllare il formato del file.")
            End If

            If errorString.ToString.Length > 0 Then
                ErrorLabel.Text = errorString.ToString
                ErrorLabel.Visible = True
            End If

            DatiAccessoriListView.DataBind()
        End Sub


        Private Sub btnEsportaCsvEsempio_Click(sender As Object, e As EventArgs) Handles btnEsportaCsvEsempio.Click
            Try
                '
                'Ottengo i profili.
                '
                Dim dt As UiDatiAccessoriListDataTable
                Using ta As New DatiAccessoriTableAdapters.UiDatiAccessoriListTableAdapter
                    dt = ta.GetData(CodiceFiltroTextBox.Text, If(String.IsNullOrEmpty(EtichettaFiltroTextBox.Text), Nothing, EtichettaFiltroTextBox.Text), If(String.IsNullOrEmpty(TipoFiltroDropDownList.SelectedValue), Nothing, TipoFiltroDropDownList.SelectedValue), 1000)
                End Using

                '
                'Verifico che la datatable sia valorizzata.
                '
                If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
                    Dim csvFile As String = String.Empty

                    '
                    'Colonne che compongono il CSV
                    '
                    Dim listaColonne As New List(Of String)
                    listaColonne.Add("Codice")
                    listaColonne.Add("Descrizione")
                    listaColonne.Add("Etichetta")
                    listaColonne.Add("Tipo")
                    listaColonne.Add("Obbligatorio")
                    listaColonne.Add("Ripetibile")
                    listaColonne.Add("Valori")
                    listaColonne.Add("Ordinamento")
                    listaColonne.Add("Gruppo")
                    listaColonne.Add("RegexValidazione")
                    listaColonne.Add("MessaggioValidazione")
                    listaColonne.Add("DiSistema")
                    listaColonne.Add("ValoreDefault")
                    listaColonne.Add("Sinonimo")
                    listaColonne.Add("ConcatenaSeUguale")

                    '
                    'Aggiungo le colonne al csv.
                    '
                    For Each item In listaColonne
                        csvFile += item.Replace(",", ";") + ","c
                    Next

                    'Rimuovo l'ultima virgola dalla stringa.
                    csvFile = csvFile.Substring(0, csvFile.Count - 1)
                    csvFile += Environment.NewLine

                    For Each datoAccessorio As UiDatiAccessoriListRow In dt.Rows
                        '
                        'Ottengo il codice della prestazione.
                        '
                        Dim sCodicePrestazione As String = datoAccessorio.Codice
                        Dim sDescrizioneDatoAccessorio As String = datoAccessorio.Descrizione
                        Dim sEtichettaDatoAccessorio As String = datoAccessorio.Etichetta
                        Dim sTipoDatoAccessorio As String = datoAccessorio.Tipo
                        Dim bObbligatorioDatoAccessorio As Boolean = datoAccessorio.Obbligatorio
                        Dim bRipetibileDatoAccessorio As Boolean = datoAccessorio.Ripetibile
                        Dim sValoriDatoAccessorio As String = datoAccessorio.Valori
                        Dim iOrdinamentoDatoAccessorio As Integer = datoAccessorio.Ordinamento
                        Dim sGruppoDatoAccessorio As String = datoAccessorio.Gruppo
                        Dim sRegexValidazioneDatoAccessorio As String = datoAccessorio.ValidazioneRegex
                        Dim sMessaggioValidazioneDatoAccessorio As String = datoAccessorio.ValidazioneMessaggio
                        Dim bDatoAccessorioDiSistema As Boolean = datoAccessorio.Sistema
                        Dim sValoreDefaultDatoAccessorio As String = datoAccessorio.ValoreDefault
                        Dim sSinonimoDatoAccessorio As String = datoAccessorio.NomeDatoAggiuntivo
                        Dim bConcatenaSeugUgualeDatoAccessorio As Boolean = datoAccessorio.ConcatenaNomeUguale

                        '
                        'Valorizzo i campi CodiceProfilo, CodicePrestazione,CodiceAzienda e CodiceSistema del csv.
                        '
                        csvFile += sCodicePrestazione.Replace(",", ";") & "[CAMPO OBBLIGATORIO]" + ","c
                        csvFile += sDescrizioneDatoAccessorio.Replace(",", ";") + ","c
                        csvFile += sEtichettaDatoAccessorio.Replace(",", ";") + ","c
                        csvFile += sTipoDatoAccessorio.Replace(",", ";") & "[Possibili Valori: ComboBox;DateBox;DateTimeBox;FloatBox;ListBox;ListMultiBox;NumberBox;TextBox;TimeBox]" + ","c
                        csvFile += If(bObbligatorioDatoAccessorio = True, 1, 0).ToString.Replace(",", ";") & "[1 o 0]" + ","c
                        csvFile += If(bRipetibileDatoAccessorio = True, 1, 0).ToString.Replace(",", ";") & "[1 o 0]" + ","c
                        csvFile += sValoriDatoAccessorio.Replace(",", ";") + ","c
                        csvFile += iOrdinamentoDatoAccessorio.ToString.Replace(",", ";") + ","c
                        csvFile += sGruppoDatoAccessorio.Replace(",", ";") + ","c
                        csvFile += sRegexValidazioneDatoAccessorio.Replace(",", ";") + ","c
                        csvFile += sMessaggioValidazioneDatoAccessorio.Replace(",", ";") + ","c
                        csvFile += If(bDatoAccessorioDiSistema = True, 1, 0).ToString.Replace(",", ";") & "[1 o 0]" + ","c
                        csvFile += sValoreDefaultDatoAccessorio.Replace(",", ";") + ","c
                        csvFile += sSinonimoDatoAccessorio.Replace(",", ";") + ","c
                        csvFile += If(bConcatenaSeugUgualeDatoAccessorio = True, 1, 0).ToString.Replace(",", ";") & "[1 o 0]"

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

    End Class

End Namespace