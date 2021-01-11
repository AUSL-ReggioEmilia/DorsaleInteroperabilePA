Imports System.Web.UI
Imports System.Collections.Generic
Imports System.Web.UI.WebControls
Imports System.Text
Imports CustomDataSource
Imports DI.PortalUser2.Data
Imports DI.OrderEntry.Services

Namespace DI.OrderEntry.User

    Public Class ListaOrdini
        Inherits Page

        'creo delle variabili di pagina che sono necessarie per il loading della gvPazienti in quanto formano parte della key su cui effettuo la select
        Public Property codice() As String
            Get
                Return Me.ViewState("codice")
            End Get
            Set(ByVal value As String)
                Me.ViewState.Add("codice", value)
            End Set
        End Property
        Public Property codiceAzienda() As String
            Get
                Return Me.ViewState("codiceAzienda")
            End Get
            Set(ByVal value As String)
                Me.ViewState.Add("codiceAzienda", value)
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
        Public Property AziendaErogante() As String
            Get
                Return Me.ViewState("AziendaErogante")
            End Get
            Set(ByVal value As String)
                Me.ViewState.Add("AziendaErogante", value)
            End Set
        End Property
        Public Property isAccessoDiretto() As Boolean
            Get
                Return Me.ViewState("isAccessoDiretto")
            End Get
            Set(ByVal value As Boolean)
                Me.ViewState.Add("isAccessoDiretto", value)
            End Set
        End Property
        Public Property nosologico() As String
            Get
                Return Me.ViewState("nosologico")
            End Get
            Set(ByVal value As String)
                Me.ViewState.Add("nosologico", value)
            End Set
        End Property

        Private executeSelect As Boolean = False
        Private msPAGEKEY As String = Page.GetType().BaseType.FullName
        Private Const errorMessage As String = "Errore nella combinazione di parametri passata nella querystring<br />Le combinazioni accettate sono: Nosologico-Azienda Erogante e IdProvenienza-Provenienza."

        Protected Sub ListaOrdini_PreInit(sender As Object, e As EventArgs) Handles Me.PreInit
            Try
                '
                'ATTENZIONE: Il cambio della master è gestibile solo nel preinit della pagina				'
                '
                If RouteData.Values("AccessoDiretto") IsNot Nothing Then
                    isAccessoDiretto = CType(RouteData.Values("AccessoDiretto"), Boolean)
                    If isAccessoDiretto Then
                        Me.MasterPageFile = "~/SiteAccessoDiretto.master"
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try

        End Sub


        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
            Try
                If Not Page.IsPostBack Then

                    'Cancello la cache per evitare di utilizzare dati vecchi o sbagliati
                    Dim dataSource2 As New PrestazioniErogate
                    dataSource2.ClearCache()


                    Me.nosologico = Request.QueryString("Nosologico")

                    Redirector.SetTarget(Utility.buildUrl(Request.Url.AbsoluteUri, Me.isAccessoDiretto), True)

                    If isAccessoDiretto Then

                        'Nascondo i filtri nel pannello che non mi servono
                        divFiltriAccessoStandard.Visible = False

                        'Combinazioni possibili: 
                        '1) idProvenienza e Provenienza
                        '2) Nosologico e AziendaErogante
                        Dim idProvenienza As String = Request.QueryString("idProvenienza")
                        Dim provenienza As String = Request.QueryString("Provenienza")
                        Me.AziendaErogante = Request.QueryString("AziendaErogante")

                        'Mostro nel divErrorMessage un messaggio se nella query string i parametri non sono forniti nelle rispettive coppie
                        If Not ((Not String.IsNullOrEmpty(idProvenienza) AndAlso Not String.IsNullOrEmpty(provenienza)) OrElse (Not String.IsNullOrEmpty(nosologico) AndAlso Not String.IsNullOrEmpty(AziendaErogante))) Then
                            Throw New ApplicationException(errorMessage)
                        End If


                        'Setto l'url ricavato in precedenza come variabile in sessione
                        SessionHandler.EntryPointAccessoDiretto = Request.Url.AbsoluteUri


                        'Ottengo l'idPaziente in base alla combinazione dei parametri
                        If Not String.IsNullOrEmpty(idProvenienza) AndAlso Not String.IsNullOrEmpty(provenienza) Then
                            Me.IdPaziente = Utility.GetIdPazienteByProvenienza(idProvenienza, provenienza)
                            If Me.IdPaziente Is Nothing OrElse String.IsNullOrEmpty(Me.IdPaziente) Then
                                'genero una nuova eccezione
                                Throw New ApplicationException("Il paziente non è stato trovato")
                            End If
                        End If

                        ddlPeriodo.SelectedValue = 30
                        ddlStato.SelectedValue = 0

                        'Forzo il DataBind della tabella
                        executeSelect = True

                        'Pulisco la cache quando premo "cerca"
                        Dim reparti As New Reparti
                        reparti.ClearCache()

                        gvReparti.DataBind()
                    Else
                        FilterHelper.Restore(filterPanel, msPAGEKEY)
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub CercaButton_Click(sender As Object, e As System.EventArgs) Handles CercaButton.Click
            Try
                'Valido i filtri
                If CheckFilters() Then
                    'Setto la variabile executeSelect a True in modo da eseguire il bind dei dati.
                    'Se è false l'ODS blocca il bind dei dati.
                    executeSelect = True

                    FilterHelper.SaveInSession(filterPanel, msPAGEKEY)

                    'Pulisco la cache quando premo "cerca"
                    Dim reparti As New Reparti
                    reparti.ClearCache()

                    'Rieseguo il bind dei dati.
                    gvReparti.DataBind()

                    '
                    '2020-07-14 Kyrylo: Traccia Operazioni
                    '
                    Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalUser)
                    oTracciaOp.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Ricerca ordini", filterPanel, Nothing)

                End If

            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Protected Function GetDettaglioUrl(ByVal idRichiesta As Object, ByVal idPaziente As Object, stato As String, nosologico As String) As String
            Dim numnosologico As String = If(nosologico Is Nothing, "", "&Nosologico=" & nosologico)
            Dim page As String = If(stato = "Inserito" OrElse stato = "Modificato", "ComposizioneOrdine", "RiassuntoOrdine")
            Return Utility.buildUrl($"{page}.aspx?IdRichiesta={idRichiesta}&IdPaziente={idPaziente}{numnosologico}", Me.isAccessoDiretto)
        End Function

        Protected Function GetDatiAccessoriUrl(idRichiesta As Object) As String
            Dim result As String = String.Empty
            Try
                If idRichiesta IsNot Nothing Then
                    result = Utility.buildUrl($"RiepilogoDatiAccessori.aspx?IdRichiesta={idRichiesta}", Me.isAccessoDiretto)
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return result
        End Function

        Protected Function GetCopiaOrdineUrl(idRichiesta As String, idPaziente As String) As String
            Dim result As String = String.Empty
            Try
                If idRichiesta IsNot Nothing Then
                    result = Utility.buildUrl($"CopiaOrdine.aspx?IdRichiesta={idRichiesta}&IdPaziente={idPaziente}", Me.isAccessoDiretto)
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return result
        End Function

        Protected Function GetSacPazienteUrl(ByVal id As Object) As String
            If id IsNot Nothing Then
                Return My.Settings.PazienteSacUrl & id
            Else
                Return String.Empty
            End If
        End Function

        Public Shared Function GetUrlRefertiDwh(idPaziente As String) As String

            Return String.Format("{0}{1}", My.Settings.DwhUrlReferti, idPaziente)
        End Function

        Public Shared Function GetUrlRefertoOrdineDwh(annoNumero As String) As String

            Return String.Format("{0}{1}", My.Settings.DwhUrlRefertoOrdine, annoNumero)
        End Function

        Private Sub gvReparti_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvReparti.RowDataBound
            Try
                'Nascondo l'ultima cella dell'HEADER della tabella esterna.
                If e.Row.RowType = DataControlRowType.Header Then
                    '
                    ' Nascondo l'ultima colonna della griglia esterna
                    '
                    Dim rigaCorrente As GridViewRow = e.Row
                    Dim cellCurrent As TableCell = rigaCorrente.Cells(rigaCorrente.Cells.Count - 1)
                    cellCurrent.CssClass = "hidden"
                End If

                'Testo se è una row.
                If e.Row.RowType = DataControlRowType.DataRow Then

                    'Ottengo la riga corrente.
                    Dim rigaCorrente As GridViewRow = e.Row
                    Dim reparto As CustomDataSource.Reparto = CType(rigaCorrente.DataItem, CustomDataSource.Reparto)


                    codice = reparto.Codice
                    codiceAzienda = reparto.CodiceAzienda


                    Dim odsPazienti As ObjectDataSource = CType(rigaCorrente.FindControl("odsPazienti"), ObjectDataSource)

                    odsPazienti.SelectParameters.Item("Codice").DefaultValue = reparto.Codice
                    odsPazienti.SelectParameters.Item("CodiceAzienda").DefaultValue = reparto.CodiceAzienda

                    Dim gvPazienti As GridView = CType(rigaCorrente.FindControl("gvPazienti"), GridView)
                    gvPazienti.DataBind()

                    If gvPazienti.Rows.Count > 0 Then

                        '
                        ' Creo il bottone per collassare la riga
                        '
                        Dim sbCellDiv As New StringBuilder
                        sbCellDiv.AppendFormat("<button data-target='.{0}'", reparto.Codice & reparto.CodiceAzienda)
                        sbCellDiv.AppendFormat("        class='btn-link'")
                        sbCellDiv.AppendFormat("        data-toggle='collapse'")
                        sbCellDiv.AppendFormat("        type='button'>")
                        sbCellDiv.AppendFormat(" <div  class='ricercaavanzata-collapsing {0} collapse in' id='id-{1}'>", reparto.Codice & reparto.CodiceAzienda, reparto.Codice & reparto.CodiceAzienda)
                        sbCellDiv.AppendFormat("            <span class='glyphicon glyphicon-minus'></span>")
                        sbCellDiv.AppendFormat("        </div>")
                        sbCellDiv.AppendFormat("        <div  class='ricercaavanzata-collapsing {0} collapse {1}'>", reparto.Codice & reparto.CodiceAzienda, reparto.Codice & reparto.CodiceAzienda)
                        sbCellDiv.AppendFormat("            <span class='glyphicon glyphicon-plus'></span>")
                        sbCellDiv.AppendFormat("        </div>")
                        sbCellDiv.AppendFormat("</button>")

                        rigaCorrente.Cells(0).Text = sbCellDiv.ToString()



                        Dim sbCellDiv2 As New StringBuilder
                        sbCellDiv2.AppendFormat("<button data-target='.{0}'", reparto.Codice & reparto.CodiceAzienda)
                        sbCellDiv2.AppendFormat("        class='btn-link'")
                        sbCellDiv2.AppendFormat("        data-toggle='collapse'")
                        sbCellDiv2.AppendFormat("        type='button'>")
                        sbCellDiv2.AppendFormat(" <div  class='ricercaavanzata-collapsing {0} collapse in' id='id-{1}'>", reparto.Codice & reparto.CodiceAzienda, reparto.Codice & reparto.CodiceAzienda)
                        sbCellDiv2.AppendFormat("             <strong>{0}</strong>", reparto.CodiceAzienda & "-" & reparto.Descrizione)
                        sbCellDiv2.AppendFormat("        </div>")
                        sbCellDiv2.AppendFormat("        <div  class='ricercaavanzata-collapsing {0} collapse {1}'>", reparto.Codice & reparto.CodiceAzienda, reparto.Codice & reparto.CodiceAzienda)
                        sbCellDiv2.AppendFormat("            <strong>{0}</strong>", reparto.CodiceAzienda & "-" & reparto.Descrizione)
                        sbCellDiv2.AppendFormat("        </div>")
                        sbCellDiv2.AppendFormat("</button>")

                        rigaCorrente.Cells(1).Text = sbCellDiv2.ToString()

                        '
                        ' Cerco la tabella della griglia
                        '
                        Dim tblGrid As Table = CType(gvReparti.Controls(0), Table)

                        '
                        ' Recupero la posizione della riga corrente nella tabella
                        '
                        Dim nRowIndex As Integer = tblGrid.Rows.GetRowIndex(rigaCorrente)

                        '
                        ' Crea una nuova riga e la posiziono dopo la riga corrente
                        '
                        Dim gvrSubFooter As New GridViewRow(nRowIndex + 1, 0, DataControlRowType.DataRow, DataControlRowState.Normal)

                        '
                        ' Aggiungo classe Css alla riga per il collassamento della row tramite bootstrap
                        '
                        gvrSubFooter.CssClass = String.Format("collapse {0} in", reparto.Codice & reparto.CodiceAzienda)

                        ' Creo una nuova cella per la riga aggiuntiva
                        ' Con il contenuto dell'ultima cella
                        '
                        Dim cellExpanded As TableCell
                        cellExpanded = rigaCorrente.Cells(rigaCorrente.Cells.Count - 1)
                        cellExpanded.ColumnSpan = gvReparti.Columns.Count - 1


                        '
                        ' Aggiunge due celle alla nuova riga
                        '
                        gvrSubFooter.Cells.Add(New TableCell())
                        gvrSubFooter.Cells.Add(cellExpanded)

                        '
                        ' Aggiunge la nuova riga alla tabella della griglia
                        '
                        tblGrid.Controls.AddAt(nRowIndex + 1, gvrSubFooter)
                        '
                        ' Sostituosce l'ultima colonna con una cella vuota e la nasconde
                        '
                        Dim cellReplace As New TableCell
                        cellReplace.CssClass = "hidden"
                        rigaCorrente.Cells.Add(cellReplace)
                    Else
                        '
                        ' Nasconde l'ultima colonna della riga
                        '
                        Dim cellCurrent As TableCell = rigaCorrente.Cells(rigaCorrente.Cells.Count - 1)
                        cellCurrent.CssClass = "hidden"
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Protected Sub gvPazienti_RowDataBound(sender As Object, e As GridViewRowEventArgs)
            Try
                'Nascondo l'ultima cella dell'HEADER della tabella esterna.
                If e.Row.RowType = DataControlRowType.Header Then
                    '
                    ' Nascondo l'ultima colonna della griglia esterna
                    '
                    Dim rigaCorrente As GridViewRow = e.Row
                    Dim cellCurrent As TableCell = rigaCorrente.Cells(rigaCorrente.Cells.Count - 1)
                    cellCurrent.CssClass = "hidden"
                End If

                'Testo se è una row.
                If e.Row.RowType = DataControlRowType.DataRow Then

                    'Ottengo la riga corrente.
                    Dim rigaCorrente As GridViewRow = e.Row
                    Dim paziente As CustomDataSource.Paziente = CType(rigaCorrente.DataItem, CustomDataSource.Paziente)


                    Dim odsOrdini As ObjectDataSource = CType(rigaCorrente.FindControl("odsOrdini"), ObjectDataSource)
                    odsOrdini.SelectParameters.Item("Codice").DefaultValue = codice
                    odsOrdini.SelectParameters.Item("CodiceAzienda").DefaultValue = codiceAzienda
                    odsOrdini.SelectParameters.Item("IdPaziente").DefaultValue = paziente.Id

                    Dim gvOrdini As GridView = CType(rigaCorrente.FindControl("gvOrdini"), GridView)
                    gvOrdini.DataBind()

                    If gvOrdini.Rows.Count > 0 Then

                        '
                        ' Creo il bottone per collassare la riga
                        '
                        Dim sbCellDiv As New StringBuilder
                        sbCellDiv.AppendFormat("<button data-target='.{0}'", codice & codiceAzienda & paziente.Id)
                        sbCellDiv.AppendFormat("        class='btn-link'")
                        sbCellDiv.AppendFormat("        data-toggle='collapse'")
                        sbCellDiv.AppendFormat("        type='button'>")
                        sbCellDiv.AppendFormat(" <div  class='ricercaavanzata-collapsing {0} collapse ' id='id-{1}'>", codice & codiceAzienda & paziente.Id, codice & codiceAzienda & paziente.Id)
                        sbCellDiv.AppendFormat("            <span class='glyphicon glyphicon-minus'></span>")
                        sbCellDiv.AppendFormat("        </div>")
                        sbCellDiv.AppendFormat("        <div  class='ricercaavanzata-collapsing {0} collapse in {1}'>", codice & codiceAzienda & paziente.Id, codice & codiceAzienda & paziente.Id)
                        sbCellDiv.AppendFormat("            <span class='glyphicon glyphicon-plus'></span>")
                        sbCellDiv.AppendFormat("        </div>")
                        sbCellDiv.AppendFormat("</button>")

                        rigaCorrente.Cells(0).Text = sbCellDiv.ToString()

                        Dim sbCellDiv2 As New StringBuilder

                        'Aggiungo l'icona per il link ai referti su DWH.
                        sbCellDiv2.AppendFormat("<a id='DWHHyperLink' href='{0}' target='_blank'>", GetUrlRefertiDwh(paziente.Id))
                        sbCellDiv2.AppendFormat("<img src ='{0}' alt='visualizza i referti del paziente' title='visualizza i referti del paziente' />", VirtualPathUtility.ToAbsolute("~/Images/dwh.gif"))
                        sbCellDiv2.AppendFormat("</a>")

                        'Aggiungo l'icona per il link al paziente su SAC.
                        sbCellDiv2.AppendFormat("<a id='SacHyperLink' href='{0}' target='_blank'>", GetSacPazienteUrl(paziente.Id))
                        sbCellDiv2.AppendFormat("<img src='{0}' alt='visualizza il dettaglio del paziente' title='visualizza il dettaglio del paziente'/>", VirtualPathUtility.ToAbsolute("~/Images/person.gif"))
                        sbCellDiv2.AppendFormat("</a>")

                        'Aggiungo il link per il collassamento della riga.
                        sbCellDiv2.AppendFormat("<button data-target='.{0}'", codice & codiceAzienda & paziente.Id)
                        sbCellDiv2.AppendFormat("        class='btn-link'")
                        sbCellDiv2.AppendFormat("        data-toggle='collapse'")
                        sbCellDiv2.AppendFormat("        type='button'>")
                        sbCellDiv2.AppendFormat(" <div  class='ricercaavanzata-collapsing {0} collapse ' id='id-{1}'>", codice & codiceAzienda & paziente.Id, codice & codiceAzienda & paziente.Id)
                        sbCellDiv2.AppendFormat("             <strong>{0}</strong>", paziente.DatiAnagraficiPaziente)
                        sbCellDiv2.AppendFormat("        </div>")
                        sbCellDiv2.AppendFormat("        <div class='ricercaavanzata-collapsing {0} collapse in {1}'>", codice & codiceAzienda & paziente.Id, codice & codiceAzienda & paziente.Id)
                        sbCellDiv2.AppendFormat("            <strong>{0}</strong>", paziente.DatiAnagraficiPaziente)
                        sbCellDiv2.AppendFormat("        </div>")
                        sbCellDiv2.AppendFormat("</button>")

                        rigaCorrente.Cells(1).Text = sbCellDiv2.ToString()

                        '
                        ' Cerco la tabella della griglia
                        '
                        Dim gvPazienti As GridView = CType(sender, GridView)
                        Dim tblGrid As Table = CType(gvPazienti.Controls(0), Table)

                        '
                        ' Recupero la posizione della riga corrente nella tabella
                        '
                        Dim nRowIndex As Integer = tblGrid.Rows.GetRowIndex(rigaCorrente)

                        '
                        ' Crea una nuova riga e la posiziono dopo la riga corrente
                        '
                        Dim gvrSubFooter As New GridViewRow(nRowIndex + 1, 0, DataControlRowType.DataRow, DataControlRowState.Normal)

                        '
                        ' Aggiungo classe Css alla riga per il collassamento della row tramite bootstrap
                        '
                        gvrSubFooter.CssClass = String.Format("collapse {0}", codice & codiceAzienda & paziente.Id, codice & codiceAzienda & paziente.Id)

                        ' Creo una nuova cella per la riga aggiuntiva
                        ' Con il contenuto dell'ultima cella
                        '
                        Dim cellExpanded As TableCell
                        cellExpanded = rigaCorrente.Cells(rigaCorrente.Cells.Count - 1)
                        cellExpanded.ColumnSpan = gvPazienti.Columns.Count - 1


                        '
                        ' Aggiunge due celle alla nuova riga
                        '
                        gvrSubFooter.Cells.Add(New TableCell())
                        gvrSubFooter.Cells.Add(cellExpanded)

                        '
                        ' Aggiunge la nuova riga alla tabella della griglia
                        '
                        tblGrid.Controls.AddAt(nRowIndex + 1, gvrSubFooter)
                        '
                        ' Sostituosce l'ultima colonna con una cella vuota e la nasconde
                        '
                        Dim cellReplace As New TableCell
                        cellReplace.CssClass = "hidden"
                        rigaCorrente.Cells.Add(cellReplace)
                    Else
                        '
                        ' Nasconde l'ultima colonna della riga
                        '
                        Dim cellCurrent As TableCell = rigaCorrente.Cells(rigaCorrente.Cells.Count - 1)
                        cellCurrent.CssClass = "hidden"
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        'Verifico che nome e cognome siano validati nel caso in cui il periodo selezionato sia "tutti"
        Private Function CheckFilters() As Boolean
            Dim res As Boolean = True
            Try
                If Not (Me.isAccessoDiretto) Then
                    If (ddlPeriodo.SelectedIndex = 0) Then
                        If (String.IsNullOrEmpty(txtNome.Text) OrElse String.IsNullOrEmpty(txtCognome.Text)) Then
                            lblError.Text = "Occorre inserire Nome e Cognome se il periodo temporale è maggiore di un mese"
                            divErrorMessage.Visible = True
                            res = False
                        End If
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return res
        End Function

        Private Sub odsReparti_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsReparti.Selecting
            Try
                If Not executeSelect Then
                    e.Cancel = True
                    Exit Sub
                End If

                If isAccessoDiretto Then
                    e.InputParameters("Uo") = String.Empty
                    e.InputParameters("stato") = ddlStato.SelectedValue
                    e.InputParameters("nosologico") = Me.nosologico
                    e.InputParameters("cognome") = String.Empty
                    e.InputParameters("nome") = String.Empty
                    e.InputParameters("dataNascita") = String.Empty
                    e.InputParameters("daysToShow") = ddlPeriodo.SelectedValue
                    e.InputParameters("sistemaErogante") = String.Empty
                    e.InputParameters("AziendaErogante") = Me.AziendaErogante
                    e.InputParameters("IdPaziente") = Me.IdPaziente
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub
        '''<summary>
        ''' Funzione per trappare gli errori e mostrare il div d'errore.
        ''' </summary>
        ''' <param name="ex"></param>
        Private Sub gestioneErrori(ex As Exception)

            'Testo di errore generico da visualizzare nel divError della pagina.
            Dim errorMessage As String = "Si è verificato un errore. Contattare l'amministratore del sito"

            'Se ex è una ApplicationException, allora contiene un messaggio di errore personalizzato che viene visualizzato poi
            'nel divError della pagina.
            If TypeOf ex Is ApplicationException Then
                Dim message As String = ex.Message

                If ex.InnerException IsNot Nothing AndAlso Not String.IsNullOrEmpty(ex.InnerException.Message) Then
                    message = ex.InnerException.Message
                End If

                If isAccessoDiretto Then
                    divPage.Visible = False
                    errorMessage = message
                End If
                errorMessage = message
            End If

            'Scrivo l'errore nell'event viewer.
            ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

            'Visualizzo il messaggio di errore nella pagina.
            divErrorMessage.Visible = True
            lblError.Text = errorMessage
        End Sub

        Protected Sub gvOrdini_RowDataBound(sender As Object, e As GridViewRowEventArgs)
            Try
                If e.Row.RowType = DataControlRowType.DataRow Then
                    Dim row = CType(e.Row.DataItem, CustomDataSource.Ordine)

                    If row IsNot Nothing Then
                        Select Case row.StatoOrderEntryDescrizione?.ToUpper
                            Case "INSERITO"
                                e.Row.CssClass += " warning"
                            Case "ERRATO"
                                e.Row.CssClass += " danger"
                            Case "CANCELLATO", "ANNULLATO"
                                e.Row.CssClass += " active"
                            Case "INCARICO", "PROGRAMMATO", "EROGATO", "ACCETTATO"
                                e.Row.CssClass += " success"
                        End Select
                    End If
                End If

            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Protected Function MustIconBeVisible(ordine As Ordine) As Boolean
            Dim res As Boolean = False
            Try
                If Not (String.IsNullOrEmpty(ordine.IdRichiestaRichiedente) OrElse String.IsNullOrEmpty(ordine.SistemaRichiedente)) Then
                    Dim datiAgg As List(Of DatoNomeValoreType) = RiassuntoOrdineMethods.DatiAggiuntiviSistemaErogante(ordine.IdRichiestaRichiedente, ordine.SistemaRichiedente)
                    If datiAgg IsNot Nothing AndAlso datiAgg.Count > 0 Then
                        res = True
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return res
        End Function

        Protected Sub btnOpenModalDatiAccessori_Click(sender As Object, e As EventArgs)
            Try
                Dim LinkButton As LinkButton = CType(sender, LinkButton)
                Dim argument As String = LinkButton.CommandArgument.ToString()
                ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide", $"getDatiAccessoriAsync({argument})", True)
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        '''' <summary>
        '''' Recupero il campo etichetta dall'oggetto DatoAccessorio
        '''' </summary>
        '''' <param name="oDatoAccessorio"></param>
        '''' <returns></returns>
        'Protected Function GetEtichetta(oDatoAccessorio As Object) As String
        '	Dim etichetta As String = String.Empty

        '	Try


        '		Try
        '			Dim datoAccessorio As DatoAccessorioType = CType(oDatoAccessorio, DatoAccessorioType)
        '			etichetta = datoAccessorio.Etichetta
        '		Catch ex As Exception
        '			'
        '			'Vado avanti
        '			'
        '		End Try
        '	Catch ex As Exception

        '	End Try
        '	Return etichetta
        'End Function


        '''' <summary>
        '''' funzione di utility per eliminare la classe bootstrap Form-control-static se il valore del dato accessorio è troppo lungo
        '''' (perchè si presenta un errore grafico causato da un bug bootstrap)
        '''' </summary>
        '''' <param name="oValoreDato"></param>
        '''' <returns></returns>
        'Protected Function GetClassValoreDato(oValoreDato As Object)
        '	Dim sClass As String = "form-control-static"

        '	Try
        '		If oValoreDato IsNot Nothing Then
        '			Dim valoreDato As String = CType(oValoreDato, String)

        '			If valoreDato.Length > 80 Then
        '				sClass = ""
        '			End If
        '		End If
        '	Catch ex As Exception
        '		gestioneErrori(ex)
        '	End Try

        '	Return sClass
        'End Function

        'Protected Function SaveBase64AndGetId(base64 As String) As String
        '	Dim hash As String = String.Empty
        '	Try
        '		hash = base64.GetHashCode().ToString

        '		If HttpContext.Current.Cache(hash) IsNot Nothing Then
        '			Return hash
        '		Else
        '			HttpContext.Current.Cache.Add(hash, base64, Nothing, Caching.Cache.NoAbsoluteExpiration, New TimeSpan(0, 30, 0), Caching.CacheItemPriority.BelowNormal, Nothing)

        '			Return hash
        '		End If
        '	Catch ex As Exception
        '		gestioneErrori(ex)
        '	End Try
        '	Return hash
        'End Function

        'Protected Function GetDatoAccessorioVisibility(oTipoContenuto As Object) As Integer
        '	Dim isVisible As Boolean = False
        '	Try
        '		If oTipoContenuto IsNot Nothing Then
        '			If oTipoContenuto.ToString().ToUpper() = "PDF" Then
        '				isVisible = True
        '			End If
        '		End If
        '	Catch ex As Exception
        '		'NON FACCIO NULLA
        '	End Try
        '	Return isVisible
        'End Function


    End Class


End Namespace