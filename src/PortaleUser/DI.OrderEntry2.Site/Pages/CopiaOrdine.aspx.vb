Imports System.Web.UI
Imports CustomDataSource
Imports DI.OrderEntry.Services
Imports System.Web.UI.WebControls
Imports DI.PortalUser2.Data
Imports System.Text
Imports System.Collections.Generic
Imports System.Linq
Imports System.ComponentModel

Namespace DI.OrderEntry.User
    Public Class CopiaOrdine
        Inherits Page

#Region "Properties"
        Public Property IdRichiesta() As String
            Get
                Return Me.ViewState("IdRichiesta")
            End Get
            Set(ByVal value As String)
                Me.ViewState.Add("IdRichiesta", value)
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

        Public Property OrderEntryDetail() As OrdineType
            Get
                Return Me.ViewState("OrderEntryDetail")
            End Get
            Set(ByVal value As OrdineType)
                Me.ViewState.Add("OrderEntryDetail", value)
            End Set
        End Property
#End Region

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
            Try
                If Not Page.IsPostBack Then
                    Me.IdRichiesta = Request.QueryString("IdRichiesta")
                    Me.IdPaziente = Request.QueryString("IdPaziente")

                    'Valorizzo le informazioni della testata paziente.
                    DettaglioPaziente.IdPaziente = Me.IdPaziente

                    'Controllo che il parametro IdRichiesta venga passato nella querystring
                    If (IdRichiesta Is Nothing) Then
                        InizializzaCampiTestataOrdine()
                        Throw New ApplicationException("Il parametro IdRichiesta non è presente nella querystring o è in un formato non leggibile")
                    End If

                    Dim userData = UserDataManager.GetUserData()

                    Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                        Dim request = New OttieniOrdinePerIdGuidRequest(userData.Token, Me.IdRichiesta)
                        Dim resp = webService.OttieniOrdinePerIdGuid(request)
                        Dim Richiesta As StatoType = resp.OttieniOrdinePerIdGuidResult

                        'Se non è valorizzato entro in questo if e visualizzo un messaggio di errore
                        If (Richiesta Is Nothing) Then
                            Throw New ApplicationException("L'ordine è inesistente o non contiene prestazioni.")
                            InizializzaCampiTestataOrdine()
                        End If
                        Me.OrderEntryDetail = Richiesta.Ordine

                        DettaglioPaziente.Nosologico = OrderEntryDetail.NumeroNosologico

                        timerTestataOrdine.Enabled = True
                        timerPaziente.Enabled = True
                    End Using

                    '
                    '2020-07-15 Kyrylo: Traccia Operazioni
                    '
                    Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalUser)
                    oTracciaOp.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Copiato ordine", New Guid(IdPaziente), Nothing, IdRichiesta, "IdRichiesta")


                End If

                If Me.OrderEntryDetail IsNot Nothing Then
                    gvEroganti.DataBind()
                End If

            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        'Sbianco i campi della testata dell'ordine.
        Private Sub InizializzaCampiTestataOrdine()
            lblIdRichiesta.InnerText = "-"
            lblUo.InnerText = "-"
            lblRegime.InnerText = "-"
            lblPriorita.InnerText = "-"
            lblDataPrenotazione.InnerText = "-"
            DatiAccessoriIcon.Visible = False
        End Sub

        Private Sub odsDatiAccessoriTestata_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDatiAccessoriTestata.Selected
            Try
                If (Not (CType(e.ReturnValue, DatiAggiuntiviType).Count = 0) AndAlso (Not (e.ReturnValue) Is Nothing)) Then
                    DatiAccessoriIcon.Visible = True
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub CaricaTestataRichiesta()
            Try
                If OrderEntryDetail IsNot Nothing Then

                    Dim data As DateTime? = Nothing

                    If OrderEntryDetail.DataPrenotazione.HasValue AndAlso OrderEntryDetail.DataPrenotazione <> DateTime.MinValue Then
                        data = OrderEntryDetail.DataPrenotazione.Value
                    End If

                    'Imposto i valori della testata dell'ordine.
                    lblIdRichiesta.InnerText = OrderEntryDetail.IdRichiestaOrderEntry
                    lblUo.InnerText = $"{OrderEntryDetail.UnitaOperativaRichiedente.Azienda.Codice}-{OrderEntryDetail.UnitaOperativaRichiedente.UnitaOperativa.Descrizione}"
                    lblRegime.InnerText = OrderEntryDetail.Regime.Descrizione
                    lblPriorita.InnerText = OrderEntryDetail.Priorita.Descrizione
                    lblDataPrenotazione.InnerText = If(Not OrderEntryDetail.DataPrenotazione.HasValue OrElse OrderEntryDetail.DataPrenotazione = DateTime.MinValue, "-", OrderEntryDetail.DataPrenotazione.Value.ToString("dd/MM/yy HH:mm"))

                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub timerPaziente_Tick(sender As Object, e As EventArgs) Handles timerPaziente.Tick
            Try
                timerPaziente.Enabled = False

                DettaglioPaziente.ExecuteQuery = True

                If DettaglioPaziente.ExecuteQuery Then
                    DettaglioPaziente.DataBind()
                End If

            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub timerTestataOrdine_Tick(sender As Object, e As EventArgs) Handles timerTestataOrdine.Tick
            Try
                timerTestataOrdine.Enabled = False
                CaricaTestataRichiesta()

            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub btnCopiaOrdine_Click(sender As Object, e As EventArgs) Handles btnCopiaOrdine.Click

            Dim userData = UserDataManager.GetUserData()

            Dim ts = DateTime.UtcNow.ToString("yyyyMMddHHmmssfff")
            Dim timestamp = ts.Substring(0, If(ts.Length <= 18, ts.Length, 18))
            Dim generatedIdRichiestaRichiedente = timestamp

            Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                Dim request = New CopiaOrdinePerIdGuidRequest(userData.Token, Me.IdRichiesta, Me.IdPaziente, generatedIdRichiestaRichiedente, Me.OrderEntryDetail.NumeroNosologico, Me.OrderEntryDetail.UnitaOperativaRichiedente.Azienda.Codice, Me.OrderEntryDetail.UnitaOperativaRichiedente.UnitaOperativa.Codice, True)
                Dim resp = webService.CopiaOrdinePerIdGuid(request)
                Dim copiedOrder As OrdineType = resp.CopiaOrdinePerIdGuidResult.Ordine

                Dim numnosologico As String = If(copiedOrder.NumeroNosologico Is Nothing, "", "&Nosologico=" & copiedOrder.NumeroNosologico)

                Response.Redirect(Utility.buildUrl($"~/Pages/ComposizioneOrdine.aspx?IdRichiesta={copiedOrder.IdGuidOrderEntry}&IdPaziente={copiedOrder.Paziente.IdSac}{numnosologico}", False), False)
            End Using

        End Sub

        Private Sub btnIndietro_Click(sender As Object, e As EventArgs) Handles btnIndietro.Click
            Response.Redirect(Utility.buildUrl($"~/Pages/ListaOrdini.aspx", False))
        End Sub

        Private Sub gvEroganti_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvEroganti.RowDataBound
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

                If e.Row.RowType = DataControlRowType.DataRow Then

                    'Ottengo la riga corrente.
                    Dim rigaCorrente As GridViewRow = e.Row
                    Dim erogante = rigaCorrente.DataItem

                    Dim gvPrestazioni As GridView = CType(rigaCorrente.FindControl("gvPrestazioni"), GridView)
                    Dim odsPrestazioni As ObjectDataSource = CType(rigaCorrente.FindControl("odsPrestazioni"), ObjectDataSource)
                    odsPrestazioni.SelectParameters.Item("Sistema").DefaultValue = erogante
                    gvPrestazioni.DataBind()

                    If gvPrestazioni.Rows.Count > 0 Then

                        '
                        ' Creo il bottone per collassare la riga
                        '
                        Dim sbCellDiv As New StringBuilder
                        sbCellDiv.AppendFormat("<button data-target='.{0}'", erogante)
                        sbCellDiv.AppendFormat("        class='btn-link btn-xs'")
                        sbCellDiv.AppendFormat("        data-toggle='collapse'")
                        sbCellDiv.AppendFormat("        type='button'>")
                        sbCellDiv.AppendFormat(" <div class='{0} collapse ' id='id-{1}'>", erogante, erogante)
                        sbCellDiv.AppendFormat("            <span class='glyphicon glyphicon-plus'></span>")
                        sbCellDiv.AppendFormat("        </div>")
                        sbCellDiv.AppendFormat("        <div class='{0} collapse in {1}'>", erogante, erogante)
                        sbCellDiv.AppendFormat("            <span class='glyphicon glyphicon-minus'></span>")
                        sbCellDiv.AppendFormat("        </div>")
                        sbCellDiv.AppendFormat("</button>")

                        rigaCorrente.Cells(0).Text = sbCellDiv.ToString()

                        Dim sbCellDiv2 As New StringBuilder
                        sbCellDiv2.AppendFormat("<button data-target='.{0}'", erogante)
                        sbCellDiv2.AppendFormat("        class='btn-link btn-xs'")
                        sbCellDiv2.AppendFormat("        data-toggle='collapse'")
                        sbCellDiv2.AppendFormat("        type='button'>")
                        sbCellDiv2.AppendFormat(" <div class='{0} collapse ' id='id-{1}'>", erogante, erogante)
                        sbCellDiv2.AppendFormat("             <strong>{0}</strong>", erogante)
                        sbCellDiv2.AppendFormat("        </div>")
                        sbCellDiv2.AppendFormat("        <div class='{0} collapse in {1}'>", erogante, erogante)
                        sbCellDiv2.AppendFormat("            <strong>{0}</strong>", erogante)
                        sbCellDiv2.AppendFormat("        </div>")
                        sbCellDiv2.AppendFormat("</button>")

                        rigaCorrente.Cells(1).Text = sbCellDiv2.ToString()

                        '
                        ' Cerco la tabella della griglia
                        '
                        Dim gvEroganti As GridView = CType(sender, GridView)
                        Dim tblGrid As Table = CType(gvEroganti.Controls(0), Table)

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
                        gvrSubFooter.CssClass = String.Format("collapse {0}", erogante)

                        ' Creo una nuova cella per la riga aggiuntiva
                        ' Con il contenuto dell'ultima cella
                        '
                        Dim cellExpanded As TableCell
                        cellExpanded = rigaCorrente.Cells(rigaCorrente.Cells.Count - 1)
                        cellExpanded.ColumnSpan = gvPrestazioni.Columns.Count - 1

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

        Protected Sub gvPrestazioni_RowCommand(sender As Object, e As GridViewCommandEventArgs)
            Try
                If String.Equals(e.CommandName, "ApriDatiAccessori") Then

                    Dim idPrestazione As String = e.CommandArgument

                    'Imposto il parametro su cui l'odsProfilo deve effettuare la query di selezione
                    odsModalDatiAccessori.SelectParameters("idPrestazione").DefaultValue = idPrestazione

                    'Faccio il DataBind della listView associata ai dati accessori delle singole prestazioni
                    lwDatiAccessori.DataBind()

                    'Ottengo la row
                    Dim gvr As GridViewRow = CType(CType(e.CommandSource, LinkButton).NamingContainer, GridViewRow)

                    'Ottengo l'index della row
                    Dim RowIndex As Integer = gvr.RowIndex

                    Dim gridview As GridView = CType(sender, GridView)

                    'Ottengo la descrizione della prestazione relativa alla row selezionata
                    Dim descrizioneprestazione As String = gridview.DataKeys(RowIndex)("Descrizione")

                    lblDatiAccessoriRichiestaTitle.InnerText = $"Dati accessori prestazione ""{descrizioneprestazione}"""

                    'Apro la modale contestuale
                    ClientScript.RegisterStartupScript(Me.GetType(), "DatiAccessoriPrestazione", "$('#modalDatiAccessori').modal('show');", True)

                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        'Recupero il campo etichetta dall'oggetto DatoAccessorio
        Protected Function GetEtichetta(oDatoAccessorio As Object) As String
            Dim etichetta As String = String.Empty
            Try
                Dim datoAccessorio As DatoAccessorioType = CType(oDatoAccessorio, DatoAccessorioType)
                etichetta = datoAccessorio.Etichetta
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return etichetta
        End Function

        'Controllo se la prestazione contiene dei dati accessori.
        Function HasPrestazioneDatiAccessori(IdPrestazione As String) As Boolean
            Dim res As Boolean = False
            Try
                Dim dataSource As New CustomDataSource.DatiAggiuntivi

                res = If(dataSource.GetDataByPrestazione(IdRichiesta, IdPrestazione) Is Nothing, False, True)
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return res
        End Function

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
                errorMessage = ex.Message
            End If

            'Scrivo l'errore nell'event viewer.
            ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

            'Visualizzo il messaggio di errore nella pagina.
            divErrorMessage.Visible = True
            lblError.Text = errorMessage
        End Sub

    End Class
End Namespace