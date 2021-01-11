Imports System
Imports System.Web.UI
Imports System.Data
Imports System.Linq

Imports System.Web.UI.WebControls
Imports System.Data.SqlTypes
Imports System.Web.Services
Imports System.Xml
Imports System.Xml.Xsl
Imports System.IO
Imports System.Text
Imports System.Web
Imports System.Collections.Generic
Imports System.Security.Principal
Imports DI.Common
Imports DI.Dispatcher.User.Data
Imports System.Net
Imports DI.OrderEntry
Imports DI.PortalUser2.Data

Namespace DI.Dispatcher.User

    Public Class StampeLista
        Inherits Page

        Private Const PageSessionIdPrefix As String = "StampeLista_"

        Private Property PageIndex() As Integer
            Get
                Dim sessionItem As Object = Session(PageSessionIdPrefix + "PageIndex")

                If sessionItem Is Nothing Then Return 0 Else Return DirectCast(sessionItem, Integer)
            End Get
            Set(ByVal value As Integer)
                Session(PageSessionIdPrefix + "PageIndex") = value
            End Set
        End Property

        Private Property SortExpression() As String
            Get
                Dim sessionItem As Object = Session(PageSessionIdPrefix + "SortExpression")
                If sessionItem Is Nothing Then Return String.Empty Else Return sessionItem.ToString()
            End Get
            Set(ByVal value As String)
                Session(PageSessionIdPrefix + "SortExpression") = value
            End Set
        End Property

        Private Property SortDirection() As SortDirection
            Get
                Dim sessionItem As Object = Session(PageSessionIdPrefix + "SortDirection")
                If sessionItem Is Nothing Then Return Nothing Else Return DirectCast(sessionItem, SortDirection)
            End Get
            Set(ByVal value As SortDirection)
                Session(PageSessionIdPrefix + "SortDirection") = value
            End Set
        End Property

        Private ObjectDataSourceCancelSelect As Boolean = True

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            If Not Page.IsPostBack Then

                'Dim id As Guid = Guid.Empty

                'If Request("Id") IsNot Nothing AndAlso Utility.TryParseStringToGuid(Request("Id"), id) Then

                '    Dim ordineTestata = DataAdapterManager.GetOrdineTestata(id)

                '    If ordineTestata.Count > 0 Then

                '        Me.FilterDropDownList.SelectedValue = "id"
                '        Me.FilterTextBox.Text = ordineTestata(0).NumeroOrdine
                '    End If
                'End If

                If Me.FilterTextBox.Text.Length = 0 Then

                    Me.FilterDropDownList.SelectedValue = "periferica"
                    'prefiltrato per macchina richiedente
                    Me.FilterTextBox.Text = Utility.GetUserHostName
                End If

                Me.DataDaTextBox.Text = DateTime.Now.AddDays(-7).ToString("d")
                Me.DataATextBox.Text = DateTime.Now.ToString("d")

                RichiesteGridView.Sort(SortExpression, SortDirection)
                RichiesteGridView.PageIndex = PageIndex

                LoadFilters()
            End If
        End Sub

        Private Sub LoadFilters()

            For Each control As Control In filterPanel.Controls

                Dim value As String = If(String.IsNullOrEmpty(control.ID), String.Empty, Session(PageSessionIdPrefix + control.ID))

                If value Is Nothing Then
                    Continue For
                End If

                Dim filterTextBox = TryCast(control, TextBox)

                If filterTextBox IsNot Nothing Then

                    filterTextBox.Text = value
                Else
                    Dim filterComboBox = TryCast(control, DropDownList)

                    If filterComboBox IsNot Nothing Then

                        filterComboBox.SelectedValue = value
                    End If
                End If
            Next
        End Sub

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
                    End If
                End If

                If Session(PageSessionIdPrefix + control.ID) Is Nothing Then

                    Session.Add(PageSessionIdPrefix + control.ID, value)
                Else
                    Session(PageSessionIdPrefix + control.ID) = value
                End If
            Next
        End Sub

        Private Sub RichiesteGridView_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles RichiesteGridView.RowDataBound

            If (e.Row.RowType = DataControlRowType.Header) Then

                Dim cellIndex = -1
                For Each field As DataControlField In RichiesteGridView.Columns

                    e.Row.Cells(RichiesteGridView.Columns.IndexOf(field)).CssClass = "GridHeader"

                    If field.SortExpression = RichiesteGridView.SortExpression AndAlso RichiesteGridView.SortExpression.Length > 0 Then

                        cellIndex = RichiesteGridView.Columns.IndexOf(field)
                    End If
                Next

                If cellIndex > -1 Then

                    e.Row.Cells(cellIndex).CssClass = If(RichiesteGridView.SortDirection = SortDirection.Ascending, "GridHeaderSortAsc", "GridHeaderSortDesc")
                End If
            End If
        End Sub

        Protected Sub RichiesteGridView_Sorted(sender As Object, e As EventArgs) Handles RichiesteGridView.Sorted
            Me.SortExpression = RichiesteGridView.SortExpression
            Me.SortDirection = RichiesteGridView.SortDirection
        End Sub

        Protected Sub RichiesteGridView_PageIndexChanged(sender As Object, e As EventArgs) Handles RichiesteGridView.PageIndexChanged

            Me.PageIndex = RichiesteGridView.PageIndex
        End Sub

        Public Shared Function GetPrintList(tipoFiltro As String, valoreFiltro As String, dataDa As DateTime?, dataA As DateTime?, sortExpression As String) As Object

            If String.IsNullOrEmpty(tipoFiltro) OrElse String.IsNullOrEmpty(valoreFiltro) Then
                Return New List(Of Object)()
            End If

            Using webService As New Ver1SoapClient("PrintDispatcherWebService")

                webService.ClientCredentials.Windows.AllowedImpersonationLevel = TokenImpersonationLevel.Impersonation

                Dim printList As New List(Of StampaEtichette2)()

                Select Case tipoFiltro

                    'IdOrderEntry
                    Case "id"

                        Dim request As New StampeEtichetteByIdOrderEntry2Request(New StampeEtichetteByIdOrderEntry2RequestBody(valoreFiltro))

                        Dim response = webService.StampeEtichetteByIdOrderEntry2(request)

                        printList = response.Body.StampeEtichetteByIdOrderEntry2Result

                    Case "cognome"

                        Dim request As New StampeEtichetteByPaziente2Request(New StampeEtichetteByPaziente2RequestBody(valoreFiltro, Nothing, Nothing, Nothing, Nothing, dataDa, dataA))

                        Dim response = webService.StampeEtichetteByPaziente2(request)

                        printList = response.Body.StampeEtichetteByPaziente2Result

                    Case "cognomeNome"

                        Dim valoreFiltroSplitted = valoreFiltro.Split(" ")
                        Dim cognome = String.Empty
                        Dim nome = String.Empty

                        If (valoreFiltroSplitted.Length > 1) Then

                            cognome = valoreFiltroSplitted(0)
                            nome = valoreFiltroSplitted(1)
                        Else
                            cognome = valoreFiltro
                        End If

                        Dim request As New StampeEtichetteByPaziente2Request(New StampeEtichetteByPaziente2RequestBody(cognome, nome, Nothing, Nothing, Nothing, dataDa, dataA))

                        Dim response = webService.StampeEtichetteByPaziente2(request)

                        printList = response.Body.StampeEtichetteByPaziente2Result

                    Case "periferica"

                        Dim request As New StampeEtichetteByPeriferica2Request(New StampeEtichetteByPeriferica2RequestBody(valoreFiltro, dataDa, dataA))

                        Dim response = webService.StampeEtichetteByPeriferica2(request)

                        printList = response.Body.StampeEtichetteByPeriferica2Result
                End Select

                If printList.Count = 0 Then
                    Return printList
                End If

                '
                ' MODIFICA ETTORE 2015-01-27: a causa della nuova funzionalità "Richieste multisettore"
                ' nella tabella letta da StampeEtichetteByPeriferica2Request() e nella PrintDispatcher.JobQueue l'IdOrderEntry
                ' viene scritto nella forma "YYYY/NNNN@MM" dove MM è un progressivo. Dal punto di vista della stampa continua del PrintDispatcher
                ' questo non crea problemi, ma il web service del'OrderEntry si aspetta un IdOrderEntry la cui parte successiva alla "/" possa essere 
                ' trasformato in un numero.
                ' Elimino quindi negli IdOrderEntry la parte "@MM"
                '
                For Each printItem As StampaEtichette2 In printList
                    Dim IdOrderEntry As String = printItem.IdOrderEntry
                    Dim IndexChiocciola As Integer = 0
                    IndexChiocciola = IdOrderEntry.IndexOf("@")
                    If IndexChiocciola > 0 Then
                        printItem.IdOrderEntry = IdOrderEntry.Substring(0, IndexChiocciola)
                    End If
                Next


                Dim idList = (From print In printList Select print.IdOrderEntry).Distinct()
                Dim oeList As OrdiniListaType

                Try
                    Using webServiceOE As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                        'MODIFICA ETTORE 2016-07-20: prelevo l'azienda in base al dominio dell'utente
                        Dim token = webServiceOE.CreaTokenAccesso(DI.Common.Utility.GetAziendaRichiedente(), My.Settings.SistemaRichiedente)

                        oeList = webServiceOE.CercaOrdiniPerRangeIdRichiesta(token, idList.ToArray())
                    End Using
                Catch ex As Exception
                    GestioneErrori.WriteException(ex)
                    Throw
                End Try

                Dim reverse As Boolean = sortExpression.Contains("DESC")

                If reverse Then
                    sortExpression = sortExpression.Substring(0, sortExpression.IndexOf(" DESC"))
                End If

                If sortExpression.Length = 0 Then
                    sortExpression = "DataInserimento"
                    reverse = True
                End If

                printList.Sort(New SortableComparer(Of StampaEtichette2)(sortExpression, reverse))

                Dim oePrintList = From print In printList
                                  Group Join oe In oeList On oe.IdRichiestaOrderEntry Equals print.IdOrderEntry Into Group
                                  From g In Group.DefaultIfEmpty()
                                  Where (g Is Nothing OrElse g.DescrizioneStato <> StatoDescrizioneEnum.Cancellato)
                                  Select New With {.IdOrderEntry = print.IdOrderEntry,
                                                  .AziendaRichiedente = print.AziendaRichiedente,
                                                  .DataInserimento = print.DataInserimento,
                                                  .IdPrinterManager = print.IdPrinterManager,
                                                  .PazienteCodiceFiscale = print.PazienteCodiceFiscale,
                                                  .PazienteCognome = print.PazienteCognome,
                                                  .PazienteDataNascita = print.PazienteDataNascita,
                                                  .PazienteLuogoNascita = print.PazienteLuogoNascita,
                                                  .PazienteNome = print.PazienteNome,
                                                  .Periferica = print.Periferica,
                                                  .PrintDispatcherJob = print.PrintDispatcherJob,
                                                  .ServerDiStampa = print.ServerDiStampa,
                                                  .SistemaRichiedente = print.SistemaRichiedente,
                                                  .Stampante = print.Stampante,
                                                  .UnitaOperativaCodice = print.UnitaOperativaCodice,
                                                  .UnitaOperativaDesc = print.UnitaOperativaDesc,
                                                  .DataPrenotazione = If(g IsNot Nothing, g.DataPrenotazione, String.Empty),
                                                  .NumeroNosologico = If(g IsNot Nothing, g.NumeroNosologico, String.Empty)
                                                  }

                Return oePrintList.ToList()
            End Using
        End Function

        <WebMethod()>
        Public Shared Function Reprint(id As Guid, usePrintDispatcher As Boolean) As Object

            If id = Guid.Empty Then
                Return -1
            End If

            Try
                Using webService As New Ver1SoapClient("PrintDispatcherWebService")

                    webService.ClientCredentials.Windows.AllowedImpersonationLevel = TokenImpersonationLevel.Impersonation

                    Dim request As New StampeEtichetteRePrint2Request(New StampeEtichetteRePrint2RequestBody(id, HttpContext.Current.User.Identity.Name))

                    Dim response = webService.StampeEtichetteRePrint2(request)

                    Return response.Body.StampeEtichetteRePrint2Result
                End Using
            Catch ex As Exception

                GestioneErrori.WriteException(ex)

                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings(Utility.PORTAL_USER_CONNECTION_STRING).ConnectionString)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.PrintDispatcher)

                Throw
            End Try
        End Function

        <WebMethod()>
        Public Shared Function ReprintLocal(id As Guid, usePrintDispatcher As Boolean) As Object

            If id = Guid.Empty Then
                Return -1
            End If

            Try
                Using webService As New Ver1SoapClient("PrintDispatcherWebService")

                    webService.ClientCredentials.Windows.AllowedImpersonationLevel = TokenImpersonationLevel.Impersonation

                    Dim request As New StampeEtichettePrintOnComputer2Request(New StampeEtichettePrintOnComputer2RequestBody(id, Utility.GetUserHostName, HttpContext.Current.User.Identity.Name))

                    Dim response = webService.StampeEtichettePrintOnComputer2(request)

                    Return response.Body.StampeEtichettePrintOnComputer2Result
                End Using
            Catch ex As Exception

                GestioneErrori.WriteException(ex)

                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings(Utility.PORTAL_USER_CONNECTION_STRING).ConnectionString)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.PrintDispatcher)

                Throw
            End Try
        End Function

        <WebMethod()>
        Public Shared Function SaveBase64AndGetId(id As Guid) As String

            If id = Guid.Empty Then
                Return -1
            End If

            Dim file As Byte()

            Try
                Using webService As New Ver1SoapClient("PrintDispatcherWebService")

                    webService.ClientCredentials.Windows.AllowedImpersonationLevel = TokenImpersonationLevel.Impersonation

                    Dim request As New StampeEtichetteOttieniDocumentoRequest(New StampeEtichetteOttieniDocumentoRequestBody(id))

                    Dim response = webService.StampeEtichetteOttieniDocumento(request)

                    If response.Body.StampeEtichetteOttieniDocumentoResult Is Nothing OrElse response.Body.StampeEtichetteOttieniDocumentoResult.Documento Is Nothing Then
                        Return -1
                    End If

                    file = response.Body.StampeEtichetteOttieniDocumentoResult.Documento
                End Using
            Catch ex As Exception

                GestioneErrori.WriteException(ex)

                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings(Utility.PORTAL_USER_CONNECTION_STRING).ConnectionString)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.PrintDispatcher)

                Throw
            End Try

            If HttpContext.Current.Cache(id.ToString()) IsNot Nothing Then
                Return id.ToString()
            Else
                HttpContext.Current.Cache.Add(id.ToString(), file, Nothing, System.Web.Caching.Cache.NoAbsoluteExpiration, New TimeSpan(0, 30, 0), CacheItemPriority.BelowNormal, Nothing)

                Return id.ToString()
            End If
        End Function

        Private Sub RichiesteGridView_PreRender(sender As Object, e As EventArgs) Handles RichiesteGridView.PreRender
            '
            'Render per Bootstrap
            'Crea la Table con Theader e Tbody se l'header non è nothing.
            '
            If Not RichiesteGridView.HeaderRow Is Nothing Then
                RichiesteGridView.UseAccessibleHeader = True
                RichiesteGridView.HeaderRow.TableSection = TableRowSection.TableHeader
            End If
        End Sub

        Private Sub MainObjectDataSource_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles MainObjectDataSource.Selected
            divErrore.Visible = False
            If e.Exception IsNot Nothing Then
                If e.Exception.InnerException IsNot Nothing Then
                    Dim oEx As Exception = e.Exception.InnerException
                    divErrore.Visible = True
                    If TypeOf oEx Is ApplicationException Then
                        'Se application Exception posso visualizzare il messaggio di errore
                        lblErrore.Text = oEx.Message
                    Else
                        'Se application Exception posso visualizzare il messaggio di errore
                        lblErrore.Text = "Si è verificato un errore durante la ricerca dei dati."
                    End If
                End If
                e.ExceptionHandled = True
            End If
        End Sub

        Private Sub SearchButton_Click(sender As Object, e As EventArgs) Handles SearchButton.Click
            '
            ' Verifico che i filtri siano impostati correttamente.
            '
            ValidazioneFiltri()

            '
            ' Salva i filtri.
            '
            SaveFilters()

            Me.DataBind()
        End Sub

        Private Sub MainObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles MainObjectDataSource.Selecting
            '
            ' Annullo la select in caso di errore
            '
            If ObjectDataSourceCancelSelect Then
                e.Cancel = True
                Exit Sub
            End If
            Dim dataA As DateTime = DateTime.Now
            Dim dataDal As DateTime = Nothing

            e.InputParameters("tipoFiltro") = FilterDropDownList.SelectedValue
            e.InputParameters("valoreFiltro") = FilterTextBox.Text

            If Not String.IsNullOrEmpty(DataATextBox.Text) Then
                '
                ' se DataATextBox non è valorizzata allora prendo la data odierna.
                '
                DateTime.TryParse(DataATextBox.Text, dataA)
            End If
            DateTime.TryParse(DataDaTextBox.Text, dataDal)
            e.InputParameters("dataDa") = dataDal
            e.InputParameters("dataA") = dataA
        End Sub

        Private Sub ValidazioneFiltri()
            Try
                ObjectDataSourceCancelSelect = False

                '
                ' Validazione dei filtri temporali.
                '
                Dim dataMin As Date = "01/01/1900"
                Dim dataMax As Date = "31/12/3000"
                Dim dataDal As Date = Nothing
                Dim dataA As Date = Nothing

                '
                ' Data Dal non deve essere vuota.
                '
                If String.IsNullOrEmpty(DataDaTextBox.Text) Then
                    Throw New ApplicationException(String.Format("Il filtro '{0}' è obbligatorio.", lblDataDal.InnerText))
                End If

                '
                ' Se il contenuto della textbox non è una data allora genero una exception.
                '
                If Not Date.TryParse(DataDaTextBox.Text, dataDal) Then
                    Throw New ApplicationException(String.Format("Il formato del filtro '{0}' non è valido.", lblDataDal.InnerText))
                End If

                '
                ' Il campo "Data A" può essere vuoto. Se è valorizzata la textbox ma il valore non è una data allora genero una exception
                '
                If Not String.IsNullOrEmpty(DataATextBox.Text) AndAlso Not Date.TryParse(DataATextBox.Text, dataA) Then
                    Throw New ApplicationException(String.Format("Il formato del filtro '{0}' non è valido.", lblDataA.InnerText))
                End If

                '
                ' Se dataDal non è compresa tra "01/01/1900" e "31/12/3000" allora genero una exception.
                '
                If dataDal < dataMin OrElse dataDal > dataMax Then
                    Throw New ApplicationException("La date devono essere comprese tra 01/01/1900 e 31/12/3000.")
                End If

                '
                ' Se dataA non è compresa tra "01/01/1900" e "31/12/3000" allora genero una exception.
                '
                If Not String.IsNullOrEmpty(DataATextBox.Text) AndAlso dataA < dataMin OrElse dataA > dataMax Then
                    Throw New ApplicationException("La date devono essere comprese tra 01/01/1900 e 31/12/3000.")
                End If

                '
                ' Se dataDal è maggiore di dataA allora genero una exception.
                '
                If Not String.IsNullOrEmpty(DataATextBox.Text) AndAlso dataDal > dataA Then
                    Throw New ApplicationException(String.Format("Il filtro '{0}' è maggiore del filtro '{1}'.", lblDataDal.InnerText, lblDataA.InnerText))
                End If

            Catch ex As ApplicationException
                '
                ' Annullo la select dell'ObjectDataSource e mostro il messaggio di errore.
                '
                ObjectDataSourceCancelSelect = True
                divErrore.Visible = True
                lblErrore.Text = ex.Message
            Catch ex As Exception
                '
                ' LOG degli errori.
                '
                GestioneErrori.WriteException(ex)
                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings(Utility.PORTAL_USER_CONNECTION_STRING).ConnectionString)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.PrintDispatcher)
            End Try
        End Sub
    End Class
End Namespace