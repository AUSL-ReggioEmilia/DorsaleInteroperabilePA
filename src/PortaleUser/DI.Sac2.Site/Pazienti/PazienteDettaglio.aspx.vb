Imports DI.Sac.User.Data.PazientiUiDataSetTableAdapters
Imports DI.Sac.User.Data.ConsensiUiDataSetTableAdapters
Imports DI.Sac.User.Data.ConsensiUiDataSet
Imports DI.Sac.User.Data.PazientiUiDataSet
Imports DI.Sac.User.Data.IstatDataSetTableAdapters
Imports DI.Sac.User.Data.IstatDataSet
Imports DI.Common
Imports PazientiAnonimizzazioniDataSetTableAdapters
Imports PazientiAnonimizzazioniDataSet
Imports PazientiPosizioniCollegateDataSetTableAdapters
Imports PazientiPosizioniCollegateDataSet
Imports DI.PortalUser2.Data

Namespace DI.Sac.User

    Partial Public Class PazienteDettaglio
        Inherits System.Web.UI.Page


#Region "SessionKey"
        'Costante per salvare in sessione la tab corrente.
        Private Const KEY_CURRENT_TAB As String = "KEY_CURRENT_TAB"
        Private Const KEY_ANONIMIZZAZIONI_LISTA As String = "ANONIMIZZAZIONI_LISTA"
        Private Const KEY_POSIZIONI_COLLEGATE_LISTA As String = "POSIZIONI_COLLEGATE_LISTA"
#End Region




        'Private Shared ReadOnly _ClassName As String = System.Reflection.MethodBase.GetCurrentMethod().ReflectedType.Name
        Private mbCanCreateAnonimizzazione As Boolean = False
        Private mbCanCreatePosCollegata As Boolean = False
        Private mIdPaziente As Guid


        '
        ' Controlli da ricercare nel FormView
        '
        'Private mPazienteDettaglioMultiView As MultiView
        Private mPazienteDettaglioView As View
        Private mActiveTabButton As Button
        'Private moddlTerminazioni As DropDownList

        'Private mConsensiGrid As GridView
        'Private mConsensiNestedGrid As GridView
        'Private mVisualizzaConsensiRadioButtonList As RadioButtonList

        'Private mEsenzioniGrid As GridView
        'Private mVisualizzaEsenzioniRadioButtonList As RadioButtonList

        'Private mAnonimizzazioniGrid As GridView

        ' Permessi utente    
        Private ReadOnly mbCanReadConsensi As Boolean = True

        Private mbPazienteDettaglioObjectDataSource_CancelSelect As Boolean = False
        Private mbPazientiSinonimiObjectDataSource_CancelSelect As Boolean = False

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
            Dim bAnagraficaAnonima As Boolean = False
            Dim bAnagraficaCollegata As Boolean = False
            Dim bAnagraficaVera As Boolean = False
            Dim IdSacOriginaleAnonimizzazione As Guid = Nothing
            Dim IdSacOriginalePosCollegata As Guid = Nothing
            Dim sIdPaziente As String = String.Empty
            Try

                sIdPaziente = Request.Params("id")
                If Not String.IsNullOrEmpty(sIdPaziente) Then
                    mIdPaziente = New Guid(sIdPaziente)
                Else
                    Throw New ApplicationException("Il parametro Id è obbligatorio.")
                End If

                If Not Page.IsPostBack Then
                    '------------------------------------------------------
                    ' MODIFICA ETTORE 2016-02-10: Per anonimizzazioni
                    ' MODIFICA ETTORE 2018-02-26: Per posizioni collegate
                    '------------------------------------------------------
                    '
                    ' Rimuovo la cache cosi posso rileggere i nuovi dati
                    '
                    If mIdPaziente <> Nothing Then
                        Utility.MyCache.Remove(KEY_ANONIMIZZAZIONI_LISTA & mIdPaziente.ToString().ToUpper())
                        Utility.MyCache.Remove(KEY_POSIZIONI_COLLEGATE_LISTA & mIdPaziente.ToString().ToUpper())
                    End If
                    AnonimizzazioneLink.NavigateUrl = String.Format(AnonimizzazioneLink.NavigateUrl, sIdPaziente)
                    PosizioneCollegataLink.NavigateUrl = String.Format(PosizioneCollegataLink.NavigateUrl, sIdPaziente)
                    '
                    ' Verifico se il record è un record di ANONIMIZZAZIONE
                    ' Se IdSacOriginaleAnonimizzazione  rimane NOTHING allora mIdPaziente non è un record di anonimizzazione e se ho idiritti posso abilitare il link "Anonimizzazione"
                    '
                    IdSacOriginaleAnonimizzazione = GetIdSacOriginaleAnagraficaAnonimizzata(mIdPaziente)
                    bAnagraficaAnonima = CBool(IdSacOriginaleAnonimizzazione <> Nothing)
                    '
                    ' POSIZIONI COLLEGATE
                    ' Verifico se il record corrente è un record di un aposizione collegate
                    ' Se IdSacOriginalePosCollegata rimane NOTHING allora mIdPaziente non è un record di una posizione collegata e se ho i diritti posso abilitare il link "Posizioni collegate"
                    '
                    IdSacOriginalePosCollegata = GetIdSacOriginaleAnagraficaCollegata(mIdPaziente)
                    bAnagraficaCollegata = CBool(IdSacOriginalePosCollegata <> Nothing)
                    '
                    ' Verifico se l'ha i diritti di anonimizzazione
                    '
                    mbCanCreateAnonimizzazione = Utility.IsUserAnonimizzatore()
                    '
                    ' Verifico se l'ha i diritti di creare "posizioni collegate"
                    '
                    mbCanCreatePosCollegata = Utility.IsUserPosizioniCollegate()

                    bAnagraficaVera = Not bAnagraficaAnonima And Not bAnagraficaCollegata
                    '
                    ' Posso "anonimizzare" o creare "posizioni collegate" solo se il record corrente non è già una posizione anonimizzata o collegata
                    '
                    SetHyperLinkStyle(AnonimizzazioneLink, mbCanCreateAnonimizzazione AndAlso (bAnagraficaVera))
                    SetHyperLinkStyle(PosizioneCollegataLink, mbCanCreatePosCollegata AndAlso (bAnagraficaVera))
                    '------------------------------------------------------


                    '
                    ' Rendo invisibili eventuali TAB se non ho i diritti di READ
                    '
                    Me.btnActiveViewConsensi.Visible = mbCanReadConsensi
                    Me.btnActiveViewAnonimizzazioni.Visible = mbCanCreateAnonimizzazione
                    Me.btnActiveViewPosizioniCollegate.Visible = mbCanCreateAnonimizzazione
                    '
                    '
                    '
                    SetBackgroundButton(DirectCast(tabContainer, Control), "btnActiveViewAnagrafeStati")

                    If mbCanCreateAnonimizzazione Then
                        Call LoadAnonimizzazioni(bAnagraficaAnonima, IdSacOriginaleAnonimizzazione)
                    End If

                    If mbCanCreatePosCollegata Then
                        Call LoadPosizioniCollegate(bAnagraficaCollegata, IdSacOriginalePosCollegata)
                    End If

                    '
                    ' Visualizzo eventualmente la precedente Tab
                    '
                    Call SetPreviusActiveView()

                    '
                    '2020-07-13 Kyrylo: Traccia Operazioni
                    '
                    Dim oTracciaOp As New TracciaOperazioniManager(Utility.ConnectionStringPortalUser)
                    oTracciaOp.TracciaOperazione(PortalsNames.Sac, Page.AppRelativeVirtualPath, "Visualizzato dettaglio paziente", mIdPaziente)

                End If
            Catch ex As Exception
                'ottengo il nome della procedura per avere maggiori info su application insights
                Dim sCurrentMethodName = System.Reflection.MethodBase.GetCurrentMethod().Name
                'Scrivo solo nell'event log
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    divErrorMessage.Visible = True
                    LabelError.Text = sErrorMessage
                End If
                'Rendo invisibile tutto
                Call SetDetailVisible(False)
                mbPazienteDettaglioObjectDataSource_CancelSelect = True
                mbPazientiSinonimiObjectDataSource_CancelSelect = True
            End Try
        End Sub

        ''' <summary>
        ''' Serve a rivisualizzare la tab precedente
        ''' </summary>
        ''' <remarks></remarks>
        Private Sub SetPreviusActiveView()
            'eseguo il clear delle classi css delle tabs in modo da eliminare le classi css boostrap.
            tabAnagrafeStati.Attributes.Clear()
            tabResidenzaDomicilio.Attributes.Clear()
            tabAssistitoMedicoBase.Attributes.Clear()
            tabDefaultView.Attributes.Clear()
            tabEsenzioni.Attributes.Clear()
            tabConsensi.Attributes.Clear()
            tabAnonimizzazioni.Attributes.Clear()
            tabPosizioniCollegate.Attributes.Clear()

            'Prendo il valore dalla sessione: se c'è imposto la tab altrimenti seleziono quella di default(Anagrafe)
            If HttpContext.Current.Session(KEY_CURRENT_TAB) IsNot Nothing Then
                Dim btnTab As LinkButton = CType(tabContainer.FindControl(HttpContext.Current.Session(KEY_CURRENT_TAB)), LinkButton)
                TryCast(btnTab.Parent, HtmlGenericControl).Attributes.Add("class", "active")
                Dim activeViewFromSession As View = CType(PazienteDettaglioMultiView.FindControl(btnTab.CommandArgument), View)
                PazienteDettaglioMultiView.SetActiveView(activeViewFromSession)
            Else
                'Se in sessione non c'è nulla allora è la prima volta che accedo alla pagina quindi imposto la tab "Anagrafe" come quella di default.
                TryCast(btnActiveViewAnagrafeStati.Parent, HtmlGenericControl).Attributes.Add("class", "active")
                PazienteDettaglioMultiView.SetActiveView(AnagrafeStati)
            End If
        End Sub

        ''' <summary>
        ''' Funzione che visualizza la tab cliccata
        ''' </summary>
        ''' <param name="sender"></param>
        ''' <param name="e"></param>
        ''' <remarks></remarks>
        Protected Sub Button_Command(ByVal sender As Object, ByVal e As CommandEventArgs)
            'Ottengo il bottone corrente.
            Dim btn As LinkButton = DirectCast(sender, LinkButton)

            'Cancello le classi boostrap dalle tabs.
            tabAnagrafeStati.Attributes.Clear()
            tabResidenzaDomicilio.Attributes.Clear()
            tabAssistitoMedicoBase.Attributes.Clear()
            tabDefaultView.Attributes.Clear()
            tabEsenzioni.Attributes.Clear()
            tabConsensi.Attributes.Clear()
            tabAnonimizzazioni.Attributes.Clear()
            tabPosizioniCollegate.Attributes.Clear()

            'Imposto la tab corretta.
            If PazienteDettaglioMultiView.TryFindControl(Of View)(e.CommandArgument.ToString(), mPazienteDettaglioView) Then
                PazienteDettaglioMultiView.SetActiveView(mPazienteDettaglioView)

                'Salvo in sessione la tab corrente
                HttpContext.Current.Session.Remove(KEY_CURRENT_TAB)
                HttpContext.Current.Session.Add(KEY_CURRENT_TAB, btn.ID)
            Else
                divErrorMessage.Visible = True
                LabelError.Text = MessageHelper.GetGenericMessage()
            End If

            'Aggiungo le classi css per "attivare" la tab.
            SetBackgroundButton(DirectCast(tabContainer, Control), String.Empty)
            Dim tab As HtmlGenericControl = TryCast(btn.Parent, HtmlGenericControl)
            tab.Attributes.Add("class", "active")
        End Sub


        ''' <summary>
        ''' Determina il background di default dei bottoni
        ''' </summary>
        ''' <param name="container"></param>
        ''' <param name="activeControl"></param>
        ''' <remarks></remarks>
        Private Sub SetBackgroundButton(ByRef container As Control, ByVal activeControl As String)

            For Each child As Control In container.Controls

                SetBackgroundButton(child, activeControl)

                If TypeOf child Is Button Then
                    DirectCast(child, Button).CssClass = "DefaultView"
                End If
            Next

            If container.TryFindControl(Of Button)(activeControl, mActiveTabButton) Then
                mActiveTabButton.CssClass = "ActiveView"
            End If
        End Sub

        'Private Sub HyperLinkStyle(ByRef sender As HyperLink, ByVal enabled As Boolean)
        '    If enabled Then
        '        sender.Enabled = True
        '        sender.Text = sender.Text.Replace("_grey.gif", ".gif")
        '    Else
        '        sender.Enabled = False
        '        sender.Text = sender.Text.Replace(".gif", "_grey.gif")
        '    End If
        'End Sub

        'Private Sub HyperLinkStyle(ByRef sender As LinkButton, ByVal enabled As Boolean)
        '    If enabled Then
        '        sender.Enabled = True
        '        sender.Text = sender.Text.Replace("_grey.gif", ".gif")
        '    Else
        '        sender.Enabled = False
        '        sender.Text = sender.Text.Replace(".gif", "_grey.gif")
        '        sender.OnClientClick = String.Empty
        '    End If
        'End Sub


        ''' <summary>
        ''' Da usare in caso di errore per nascondere le componenti della pagina
        ''' </summary>
        ''' <param name="bVisible"></param>
        ''' <remarks></remarks>
        Private Sub SetDetailVisible(bVisible As Boolean)
            ToolbarTable.Visible = bVisible
            NomePazienteFormView.Visible = bVisible
            tabContainer.Visible = bVisible
        End Sub

        ''' <summary>
        ''' Funzione per abilitare/disabilitare hiperlink (utile per toolbar)
        ''' </summary>
        ''' <param name="sender"></param>
        ''' <param name="enabled"></param>
        ''' <remarks></remarks>
        Private Sub SetHyperLinkStyle(sender As HyperLink, ByVal enabled As Boolean)

            Dim extension = If(sender.Text.Contains("gif"), "gif", "png")

            If Not enabled Then
                sender.Attributes.Add("disabled", "disabled")
                sender.CssClass = sender.CssClass + " disabled"
            End If
        End Sub

#Region "Anonimizzazioni"

        Private Function GetIdSacOriginaleAnagraficaAnonimizzata(ByVal IdPazienteCorrente As Guid) As Guid
            Dim oIdSacOriginale As Guid = Nothing
            Using adapter As New PazientiAnonimizzazioniSelectByIdSacAnonimoTableAdapter
                Dim oTable As PazientiAnonimizzazioniSelectByIdSacAnonimoDataTable
                oTable = adapter.GetData(mIdPaziente)
                If Not oTable Is Nothing AndAlso oTable.Rows.Count > 0 Then
                    oIdSacOriginale = oTable(0).IdSacOriginale
                End If
            End Using
            Return oIdSacOriginale
        End Function

        Protected Sub LoadAnonimizzazioni(bAnagraficaAnonima As Boolean, IdSacOriginale As Guid)
            Dim oPosizioneOriginaleLink As HyperLink = Nothing
            If Not bAnagraficaAnonima Then
                '
                ' Rendo VISIBILE la gridview
                '
                gvAnonimizzazioni.Visible = True
                '
                ' Carico i dati
                '
                gvAnonimizzazioni.DataSource = GetPazientiAnonimizzazioniLista(mIdPaziente)
                gvAnonimizzazioni.DataBind()
                '
                ' Rendo INVISIBLE il lik alla posizione corrente
                '
                PosizioneOriginaleLink.Visible = False
            Else
                '
                ' Rendo INVISIBILE la gridview
                '
                gvAnonimizzazioni.Visible = False
                '
                ' Rendo VISIBLE il link alla posizione corrente e valorizzo URL
                '
                PosizioneOriginaleLink.NavigateUrl = String.Format("~/Pazienti/PazienteDettaglio.aspx?Id={0}", IdSacOriginale)
                PosizioneOriginaleLink.Visible = True
            End If
        End Sub

        Private Function GetPazientiAnonimizzazioniLista(IdPAziente As Guid) As PazientiAnonimizzazioniListaByIdSacOriginaleDataTable
            Dim sKey As String = KEY_ANONIMIZZAZIONI_LISTA & IdPAziente.ToString().ToUpper()
            Dim dataSource As PazientiAnonimizzazioniListaByIdSacOriginaleDataTable = Nothing
            dataSource = Utility.MyCache.Read(sKey)
            If dataSource Is Nothing Then
                dataSource = New PazientiAnonimizzazioniListaByIdSacOriginaleDataTable()
                Using adapter = New PazientiAnonimizzazioniListaByIdSacOriginaleTableAdapter()
                    adapter.Fill(dataSource, IdPAziente)
                End Using
                Utility.MyCache.Write(sKey, dataSource, 60)
            End If
            Return dataSource
        End Function

        ''' <summary>
        ''' gvAnonimizzazioni: gestione del PageIndexChanging
        ''' </summary>
        ''' <param name="sender"></param>
        ''' <param name="e"></param>
        ''' <remarks></remarks>
        Protected Sub gvAnonimizzazioni_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
            Try
                Dim oGridView As GridView = DirectCast(sender, GridView)
                If Not oGridView Is Nothing Then
                    oGridView.PageIndex = e.NewPageIndex
                    oGridView.DataSource = GetPazientiAnonimizzazioniLista(mIdPaziente)
                    oGridView.DataBind()
                End If
            Catch ex As Exception
                'Scrivo solo nell'event log
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    divErrorMessage.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

#End Region

#Region "Posizioni collegate"
        Private Function GetIdSacOriginaleAnagraficaCollegata(ByVal IdPazienteCorrente As Guid) As Guid
            Dim oIdSacOriginale As Guid = Nothing
            Using adapter As New PazientiPosizioniCollegateSelectByIdSacPosizioneCollegataTableAdapter
                Dim oTable As PazientiPosizioniCollegateSelectByIdSacPosizioneCollegataDataTable
                oTable = adapter.GetData(mIdPaziente)
                If Not oTable Is Nothing AndAlso oTable.Rows.Count > 0 Then
                    oIdSacOriginale = oTable(0).IdSacOriginale
                End If
            End Using
            Return oIdSacOriginale
        End Function

        Protected Sub LoadPosizioniCollegate(bAnagraficaCollegata As Boolean, IdSacOriginale As Guid)
            Dim oPosizioneOriginaleLink As HyperLink = Nothing
            If Not bAnagraficaCollegata Then
                '
                ' Rendo VISIBILE la gridview
                '
                gvPosizioniCollegate.Visible = True
                '
                ' Carico i dati
                '
                gvPosizioniCollegate.DataSource = GetPazientiPosizioniCollegateLista(mIdPaziente)
                gvPosizioniCollegate.DataBind()
                '
                ' Rendo INVISIBLE il lik alla posizione corrente
                '
                PosizioneOriginalePosizioneCollegataLink.Visible = False
            Else
                '
                ' Rendo INVISIBILE la gridview
                '
                gvPosizioniCollegate.Visible = False
                '
                ' Rendo VISIBLE il link alla posizione corrente e valorizzo URL
                '
                PosizioneOriginalePosizioneCollegataLink.NavigateUrl = String.Format("~/Pazienti/PazienteDettaglio.aspx?Id={0}", IdSacOriginale)
                PosizioneOriginalePosizioneCollegataLink.Visible = True
            End If
        End Sub


        Private Function GetPazientiPosizioniCollegateLista(IdPAziente As Guid) As PazientiPosizioniCollegateListaByIdSacOriginaleDataTable
            Dim sKey As String = KEY_POSIZIONI_COLLEGATE_LISTA & IdPAziente.ToString().ToUpper()
            Dim dataSource As PazientiPosizioniCollegateListaByIdSacOriginaleDataTable = Nothing
            dataSource = Utility.MyCache.Read(sKey)
            If dataSource Is Nothing Then
                dataSource = New PazientiPosizioniCollegateListaByIdSacOriginaleDataTable()
                Using adapter = New PazientiPosizioniCollegateListaByIdSacOriginaleTableAdapter()
                    adapter.Fill(dataSource, IdPAziente)
                End Using
                Utility.MyCache.Write(sKey, dataSource, 60)
            End If
            Return dataSource
        End Function

        ''' <summary>
        ''' gvAnonimizzazioni: gestione del PageIndexChanging
        ''' </summary>
        ''' <param name="sender"></param>
        ''' <param name="e"></param>
        ''' <remarks></remarks>
        Protected Sub gvPosizioniCollegate_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
            Try
                Dim oGridView As GridView = DirectCast(sender, GridView)
                If Not oGridView Is Nothing Then
                    oGridView.PageIndex = e.NewPageIndex
                    oGridView.DataSource = GetPazientiPosizioniCollegateLista(mIdPaziente)
                    oGridView.DataBind()
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

#End Region

#Region "Esenzioni"
        ''' <summary>
        ''' RowCommand della griglia, per la gestione dei link al dettaglio.
        ''' </summary>
        ''' <param name="sender"></param>
        ''' <param name="e"></param>
        Protected Sub gvEsenzioni_RowCommand(sender As Object, e As GridViewCommandEventArgs)
            Try
                If e.CommandName.ToUpper = "DETTAGLIO" Then
                    Dim idEsenzione As String = e.CommandArgument
                    Response.Redirect(String.Format("../Esenzioni/EsenzioneDettaglio.aspx?idPaziente={0}&idEsenzione={1}", mIdPaziente, idEsenzione))
                End If
            Catch ex As Exception

                'Si è verificato un errore.
                Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
            End Try
        End Sub

        ''' <summary>
        ''' PreRender della griglia, crea i Bootstrap header per la tabella
        ''' </summary>
        ''' <param name="sender"></param>
        ''' <param name="e"></param>
        Protected Sub gvEsenzioni_PreRender(sender As Object, e As EventArgs)
            Try
                CreateBootstrapGridViewHeader(sender)
            Catch ex As Exception
                'Si è verificato un errore.
                Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
            End Try
        End Sub

        ''' <summary>
        ''' Restituisce il testo dell'esenzione contenuta dentro il campo TestoEsenzione.
        ''' </summary>
        ''' <param name="row"></param>
        ''' <returns></returns>
        Protected Function GetTestoEsenzione(ByVal row As Object) As String
            Dim testoEsenzione As String = String.Empty

            Try
                If row IsNot Nothing Then
                    Dim esenzione As WcfSacPazienti.EsenzioneType = CType(row, WcfSacPazienti.EsenzioneType)

                    If esenzione IsNot Nothing Then
                        If esenzione.TestoEsenzione IsNot Nothing Then
                            testoEsenzione = esenzione.TestoEsenzione.Descrizione
                        End If
                    End If
                End If
            Catch ex As Exception
                '
                'Non faccio nulla e vado avanti
                '
            End Try

            Return testoEsenzione
        End Function

        Private Sub odsEsenzioni_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsEsenzioni.Selected
            Try
                'testo se si è verificato un errore.
                If e.Exception IsNot Nothing Then
                    e.ExceptionHandled = True
                    'ottengo il messaggio di errore.
                    Throw e.Exception
                End If
            Catch ex As Exception
                'Si è verificato un errore.
                '
                'ATTENZIONE:
                'Chiamo il metodo CustomDataSourceException.TrapError(ex) al posto di GestioneErrori.TrapError perchè questa objectdatasource chiama una CustomDataSource
                ' che ottiene i dati da un WCF.
                'iN questo modo trappo anche gli errori generati dal WCF.
                Master.ShowErrorLabel(CustomDataSourceException.TrapError(ex))
            End Try
        End Sub

#End Region

#Region "Consensi"
        ''' <summary>
        ''' RowCommand della griglia, gestione del link di dettaglio.
        ''' </summary>
        ''' <param name="sender"></param>
        ''' <param name="e"></param>
        Protected Sub gvConsensi_RowCommand(sender As Object, e As GridViewCommandEventArgs)
            Try
                If e.CommandName.ToUpper = "DETTAGLIO" Then
                    Dim idEsenzione As String = e.CommandArgument
                    Response.Redirect(String.Format("../Consensi/ConsensoDettaglio.aspx?IdPaziente={0}&IdConsenso={1}", mIdPaziente, idEsenzione))
                End If
            Catch ex As Exception

                'Si è verificato un errore.
                Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
            End Try
        End Sub

        ''' <summary>
        ''' PreRender della griglia, Crea i Bootstrap header per la tabella.
        ''' </summary>
        ''' <param name="sender"></param>
        ''' <param name="e"></param>
        Protected Sub gvConsensi_PreRender(sender As Object, e As EventArgs)
            CreateBootstrapGridViewHeader(sender)
        End Sub

        Private Sub odsConsensi_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsConsensi.Selected
            Try
                'testo se si è verificato un errore.
                If e.Exception IsNot Nothing Then
                    e.ExceptionHandled = True
                    'ottengo il messaggio di errore.
                    Throw e.Exception
                End If
            Catch ex As Exception
                'Si è verificato un errore.
                '
                'ATTENZIONE:
                'Chiamo il metodo CustomDataSourceException.TrapError(ex) al posto di GestioneErrori.TrapError perchè questa objectdatasource chiama una CustomDataSource
                ' che ottiene i dati da un WCF.
                'iN questo modo trappo anche gli errori generati dal WCF.
                Master.ShowErrorLabel(CustomDataSourceException.TrapError(ex))
            End Try
        End Sub
#End Region

#Region "Sinonimi"
        Protected Sub gvSinonimi_PreRender(sender As Object, e As EventArgs)
            CreateBootstrapGridViewHeader(sender)
        End Sub

        Private Sub odsSinonimi_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsSinonimi.Selected
            Try
                'testo se si è verificato un errore.
                If e.Exception IsNot Nothing Then
                    e.ExceptionHandled = True
                    'ottengo il messaggio di errore.
                    Throw e.Exception
                End If
            Catch ex As Exception
                'Si è verificato un errore.
                '
                'ATTENZIONE:
                'Chiamo il metodo CustomDataSourceException.TrapError(ex) al posto di GestioneErrori.TrapError perchè questa objectdatasource chiama una CustomDataSource
                ' che ottiene i dati da un WCF.
                'iN questo modo trappo anche gli errori generati dal WCF.
                Master.ShowErrorLabel(CustomDataSourceException.TrapError(ex))
            End Try
        End Sub
#End Region
        Private Sub odsPaziente_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsPaziente.Selected
            Try
                'testo se si è verificato un errore.
                If e.Exception IsNot Nothing Then
                    e.ExceptionHandled = True
                    'ottengo il messaggio di errore.
                    Throw e.Exception
                End If
            Catch ex As Exception
                'Si è verificato un errore.
                '
                'ATTENZIONE:
                'Chiamo il metodo CustomDataSourceException.TrapError(ex) al posto di GestioneErrori.TrapError perchè questa objectdatasource chiama una CustomDataSource
                ' che ottiene i dati da un WCF.
                'iN questo modo trappo anche gli errori generati dal WCF.
                Master.ShowErrorLabel(CustomDataSourceException.TrapError(ex))
            End Try
        End Sub

        Private Sub gvAnonimizzazioni_PreRender(sender As Object, e As EventArgs) Handles gvAnonimizzazioni.PreRender
            Try
                CreateBootstrapGridViewHeader(sender)
            Catch ex As Exception
                'Si è verificato un errore.
                Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
            End Try
        End Sub

        Private Sub gvPosizioniCollegate_PreRender(sender As Object, e As EventArgs) Handles gvPosizioniCollegate.PreRender
            Try
                CreateBootstrapGridViewHeader(sender)
            Catch ex As Exception
                'Si è verificato un errore.
                Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
            End Try
        End Sub

        Private Sub odsEsenzioni_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsEsenzioni.Selecting
            Try
                'Determino se devo restituire solo le esenzioni attive oppure tutte.
                Dim onlyAttive As Boolean? = Nothing
                If rblVisualizzaEsenzioni.SelectedValue = "1" Then
                    onlyAttive = True
                End If

                e.InputParameters("Attive") = onlyAttive
            Catch ex As Exception
                'Si è verificato un errore.
                Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
            End Try
        End Sub

        Private Sub rblVisualizzaEsenzioni_SelectedIndexChanged(sender As Object, e As EventArgs) Handles rblVisualizzaEsenzioni.SelectedIndexChanged
            Try
                gvEsenzioni.DataBind()
            Catch ex As Exception
                'Si è verificato un errore.
                Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
            End Try
        End Sub

        ''' <summary>
        ''' Crea i Bootstrap header per la tabella.
        ''' </summary>
        ''' <param name="sender"></param>
        Private Sub CreateBootstrapGridViewHeader(sender As Object)
            Try
                'Bootstrap SetUp per le gridView
                HelperGridView.SetUpGridView(sender, Me.Page)

            Catch ex As Exception
                'Si è verificato un errore.
                Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
            End Try
        End Sub
    End Class
End Namespace