Imports DI.Common
Imports System.Web.UI.WebControls
Imports System
Imports System.Diagnostics
Imports DI.Sac.Admin.Data.PazientiDataSetTableAdapters
Imports DI.Sac.Admin.Data.PazientiDataSet
Imports DI.Sac.Admin.Data.PazientiAnonimizzazioniDataSetTableAdapters
Imports DI.Sac.Admin.Data.PazientiAnonimizzazioniDataSet
Imports DI.Sac.Admin.Data.PazientiPosizioniCollegateDataSetTableAdapters
Imports DI.Sac.Admin.Data.PazientiPosizioniCollegateDataSet
Imports System.Reflection
Imports System.Web.UI
Imports DI.Common.Controls
Imports System.Linq
Imports DI.Sac.Admin.Data.Lha
Imports DI.Sac.Admin.Data.LhaTableAdapters
Imports DI.PortalAdmin.Data

Namespace DI.Sac.Admin

    Partial Public Class PazienteDettaglio
        Inherits System.Web.UI.Page

        Private Shared ReadOnly _className As String = String.Concat("Gestione.", MethodBase.GetCurrentMethod().ReflectedType.Name)

        Private Const KEY_ANONIMIZZAZIONI_LISTA As String = "ANONIM_LISTA"
        Private Const KEY_POSIZIONI_COLLEGATE_LISTA As String = "POSIZIONI_COLLEGATE_LISTA"

        Private Const DDL_TERMINAZIONI_CODICE_DECESSO As String = "4"

        Private mIdPaziente As Guid
        Private mIdPazienteFuso As Guid

        ' Controlli da ricercare nel FormView        
        Private mPazienteDettaglioMultiView As MultiView
        Private mPazienteDettaglioView As View
        Private mActiveTabButton As Button

        Private mConsensiGrid As GridView
        Private mConsensiNestedGrid As GridView
        Private mVisualizzaConsensiRadioButtonList As RadioButtonList

        Private mEsenzioniGrid As GridView
        Private mVisualizzaEsenzioniRadioButtonList As RadioButtonList

        Private mAnonimizzazioniGrid As GridView
        Private mPosizioniCollegateGrid As GridView

        Private mComuneAslResCascadingDropDownList As CascadingDropDownList
        Private mComuneAslAssCascadingDropDownList As CascadingDropDownList

        Private moddlTerminazioni As DropDownList
        Private motxtDataDecesso As TextBox
        Private motxtDataTerminazioneAss As TextBox

        ' Permessi utente    
        Private ReadOnly mbCanCreatePazienti As Boolean = User.IsInRole(TypeRoles.ROLE_PAZIENTI_CREATE.ToString())
        Private ReadOnly mbCanWritePazienti As Boolean = User.IsInRole(TypeRoles.ROLE_PAZIENTI_WRITE.ToString())
        Private ReadOnly mbCanDeletePazienti As Boolean = User.IsInRole(TypeRoles.ROLE_PAZIENTI_DELETE.ToString())
        'Private ReadOnly mbCanReadPazienti As Boolean = User.IsInRole(TypeRoles.ROLE_PAZIENTI_READ.ToString())
        Private ReadOnly mbCanReadConsensi As Boolean = User.IsInRole(TypeRoles.ROLE_CONSENSI_READ.ToString())
        'Private ReadOnly mbCanWriteConsensi As Boolean = User.IsInRole(TypeRoles.ROLE_CONSENSI_WRITE.ToString())
        Private ReadOnly mbCanCreateAnonimizzazione As Boolean = User.IsInRole(TypeRoles.ROLE_PAZIENTI_CREATE_ANONIMIZZAZIONE.ToString())
        Private ReadOnly mbCanReadAnonimizzazione As Boolean = User.IsInRole(TypeRoles.ROLE_PAZIENTI_READ_ANONIMIZZAZIONE.ToString())
        'MODIFICA ETTORE 2018-02-22: posizioni collegate
        Private ReadOnly mbCanCreatePosCollegata As Boolean = User.IsInRole(TypeRoles.ROLE_PAZIENTI_CREATE_POS_COLLEGATA.ToString())
        Private ReadOnly mbCanReadPosCollegata As Boolean = User.IsInRole(TypeRoles.ROLE_PAZIENTI_READ_POS_COLLEGATA.ToString())


        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
            Dim bAnagraficaAnonima As Boolean = False
            Dim bAnagraficaCollegata As Boolean = False
            Dim bAnagraficaVera As Boolean = False
            Dim IdSacOriginaleAnonimizzazione As Guid = Nothing
            Dim IdSacOriginalePosCollegata As Guid = Nothing
            Dim sIdPaziente As String = String.Empty
            Try

                sIdPaziente = Request.Params("id")

                Dim mode = Request.Params("mode")
                '
                ' Ricalcolo sempre l'IdPaziente
                '
                If Not String.IsNullOrEmpty(sIdPaziente) Then
                    mIdPaziente = New Guid(sIdPaziente)
                End If

                If Not Page.IsPostBack Then
                    '
                    ' Rimuovo la cache cosi posso rileggere i nuovi dati
                    '
                    If mIdPaziente <> Nothing Then
                        Utility.MyCache.Remove(KEY_ANONIMIZZAZIONI_LISTA & mIdPaziente.ToString().ToUpper())
                        Utility.MyCache.Remove(KEY_POSIZIONI_COLLEGATE_LISTA & mIdPaziente.ToString().ToUpper())
                    End If


                    MergeLink.NavigateUrl = String.Format(MergeLink.NavigateUrl, sIdPaziente)
                    MergeDettaglioLink.NavigateUrl = String.Format(MergeDettaglioLink.NavigateUrl, sIdPaziente)
                    ModificaLink.NavigateUrl = String.Format(ModificaLink.NavigateUrl, sIdPaziente)
                    VisualizzaLogLink.NavigateUrl = String.Format(VisualizzaLogLink.NavigateUrl, sIdPaziente)
                    CopiaSuAppuntiLink.NavigateUrl = String.Format(CopiaSuAppuntiLink.NavigateUrl, sIdPaziente)
                    AnonimizzazioneLink.NavigateUrl = String.Format(AnonimizzazioneLink.NavigateUrl, sIdPaziente)
                    PosizioneCollegataLink.NavigateUrl = String.Format(PosizioneCollegataLink.NavigateUrl, sIdPaziente)
                    '
                    ' Rendo disabilitati eventuali pulsanti della toolbar in base ai diritti
                    '
                    SetHyperLinkStyle(ModificaLink, mbCanWritePazienti)
                    SetHyperLinkStyle(EliminaLink, mbCanDeletePazienti)

                    '
                    ' Rendo invisibili eventuali TAB se non ho i diritti di READ
                    '
                    Me.btnActiveViewConsensi.Visible = mbCanReadConsensi


                    'If String.IsNullOrEmpty(msIdPaziente) Then
                    If mIdPaziente = Nothing Then

                        PazienteDettaglioFormView.DefaultMode = FormViewMode.ReadOnly

                        SetHyperLinkStyle(ModificaLink, False)
                        SetHyperLinkStyle(MergeLink, False)
                        SetHyperLinkStyle(MergeDettaglioLink, False)
                        SetHyperLinkStyle(RinotificaPazienteAttivoButton, False)
                        SetHyperLinkStyle(RinotificaFusioneButton, False)
                        SetHyperLinkStyle(EliminaLink, False)
                        SetHyperLinkStyle(RipristinaLink, False)
                        SetHyperLinkStyle(VisualizzaLogLink, False)
                        SetHyperLinkStyle(AnonimizzazioneLink, False)
                        SetHyperLinkStyle(PosizioneCollegataLink, False)

                    Else
                        '_IdPaziente = New Guid(_id)
                        AggiornaTabellaUltimiPazientiVisitati(mIdPaziente)

                        Try
                            ' Recupero riga corrente                        
                            Dim pazientiTable As PazientiGestioneDataTable
                            Dim pazientiRow As PazientiGestioneRow
                            Using adapter As New PazientiGestioneTableAdapter()

                                pazientiTable = adapter.GetData(mIdPaziente)
                                If Not pazientiTable Is Nothing AndAlso pazientiTable.Rows.Count > 0 Then
                                    pazientiRow = pazientiTable(0)
                                    ' Salvo nel ViewState il paziente
                                    PazienteCorrente = pazientiTable
                                Else
                                    Throw New ApplicationException("L'anagrafica selezionata non esiste!")
                                End If

                            End Using
                            '
                            ' Verifico se il record è un record di ANONIMIZZAZIONE
                            '
                            Using adapter As New PazientiAnonimizzazioniSelectByIdSacAnonimoTableAdapter
                                Dim oTable As PazientiAnonimizzazioniSelectByIdSacAnonimoDataTable
                                oTable = adapter.GetData(mIdPaziente)
                                If Not oTable Is Nothing AndAlso oTable.Rows.Count > 0 Then
                                    bAnagraficaAnonima = True
                                    IdSacOriginaleAnonimizzazione = oTable(0).IdSacOriginale
                                End If
                            End Using
                            'TODO: verificare se il guid corrente è una anagrafica di una posizione collegata
                            Using adapter As New PazientiPosizioniCollegateSelectByIdSacPosizioneCollegataTableAdapter
                                Dim oTable As PazientiPosizioniCollegateSelectByIdSacPosizioneCollegataDataTable
                                oTable = adapter.GetData(mIdPaziente)
                                If Not oTable Is Nothing AndAlso oTable.Rows.Count > 0 Then
                                    bAnagraficaCollegata = True
                                    IdSacOriginalePosCollegata = oTable(0).IdSacOriginale
                                End If
                            End Using

                            bAnagraficaVera = Not bAnagraficaAnonima And Not bAnagraficaCollegata

                            SetHyperLinkStyle(SincronizzaLink, GetIdLha().HasValue)

                            If pazientiRow.Disattivato = 0 Then

                                ' Paziente attivo; disabilito il dettaglio del merge(se non fa parte di una gerarchia di fusione) ed il ripristino                            
                                SetHyperLinkStyle(MergeDettaglioLink, False)
                                SetHyperLinkStyle(RipristinaLink, False)
                                SetHyperLinkStyle(AnonimizzazioneLink, mbCanCreateAnonimizzazione And (bAnagraficaVera))
                                SetHyperLinkStyle(PosizioneCollegataLink, mbCanCreatePosCollegata And (bAnagraficaVera))

                                SetHyperLinkStyle(RinotificaPazienteAttivoButton, True)
                                SetHyperLinkStyle(RinotificaFusioneButton, False)

                                ' Stabilisco se fa parte di una gerarchia di fusione                            
                                Using adapter = New PazientiMergeTableAdapter()

                                    Dim pazientiMerge As PazientiMergeDataTable = adapter.GetData(mIdPaziente)

                                    If pazientiMerge.Rows.Count > 0 Then

                                        ' Fa parte quindi abilito il pulsante                                    
                                        SetHyperLinkStyle(MergeDettaglioLink, True)
                                    End If
                                End Using

                            ElseIf pazientiRow.Disattivato = 1 Then

                                ' Paziente cancellato; disabilito il merge, il dettaglio del merge e la cancellazione                            
                                SetHyperLinkStyle(MergeLink, False)
                                SetHyperLinkStyle(MergeDettaglioLink, False)
                                SetHyperLinkStyle(EliminaLink, False)
                                SetHyperLinkStyle(RipristinaLink, True)
                                SetHyperLinkStyle(AnonimizzazioneLink, False)
                                SetHyperLinkStyle(PosizioneCollegataLink, False)
                                SetHyperLinkStyle(RinotificaPazienteAttivoButton, False)
                                SetHyperLinkStyle(RinotificaFusioneButton, False)

                            ElseIf pazientiRow.Disattivato = 2 Then

                                ' Paziente fuso; disabilito il merge ed il ripristino                            
                                SetHyperLinkStyle(MergeLink, False)
                                SetHyperLinkStyle(EliminaLink, False)
                                SetHyperLinkStyle(RipristinaLink, False)
                                SetHyperLinkStyle(AnonimizzazioneLink, False)
                                SetHyperLinkStyle(PosizioneCollegataLink, False)
                                SetHyperLinkStyle(RinotificaPazienteAttivoButton, False)
                                SetHyperLinkStyle(RinotificaFusioneButton, True)

                            End If
                        Catch ex As Exception
                            'ExceptionsManager.TraceException(ex)
                            Throw
                        End Try
                    End If

                    If mode IsNot Nothing Then
                        mode = mode.ToLower
                        'Inizializzo in readonly
                        PazienteDettaglioFormView.DefaultMode = FormViewMode.ReadOnly
                        If mode = "insert" And mbCanCreatePazienti Then
                            PazienteDettaglioFormView.DefaultMode = FormViewMode.Insert

                            SetHyperLinkStyle(ModificaLink, False)
                            SetHyperLinkStyle(CopiaSuAppuntiLink, False)
                            SetHyperLinkStyle(VisualizzaLogLink, False)
                            SetHyperLinkStyle(SincronizzaLink, False)
                            SetHyperLinkStyle(AnonimizzazioneLink, False)
                            SetHyperLinkStyle(PosizioneCollegataLink, False)
                            SetHyperLinkStyle(MergeLink, False)

                        ElseIf mode = "edit" And mbCanWritePazienti Then

                            'Livello attendibilità                                
                            Dim attendibilita As Boolean
                            Using adapter As New FunctionTableAdapter()
                                attendibilita = adapter.GetModificaPazienteByLivelloAttendibilita(mIdPaziente)
                            End Using

                            If attendibilita Then
                                PazienteDettaglioFormView.DefaultMode = FormViewMode.Edit
                            Else
                                PazienteDettaglioFormView.DefaultMode = FormViewMode.ReadOnly
                                LabelError.Visible = True
                                LabelError.Text = "Il livello di attendibilità non permette la modifica dell'oggetto!"
                            End If

                            SetHyperLinkStyle(ModificaLink, False)
                            SetHyperLinkStyle(AnonimizzazioneLink, False)
                            SetHyperLinkStyle(PosizioneCollegataLink, False)
                            SetHyperLinkStyle(MergeLink, False)


                        End If

                    End If

                    Select Case PazienteDettaglioFormView.DefaultMode
                        Case FormViewMode.ReadOnly
                            'In questa modalità l'Id del paziente deve essere presente
                            If mIdPaziente = Nothing Then 'If String.IsNullOrEmpty(sIdPaziente) Then
                                Throw New ApplicationException("L'id del paziente non è valorizzato.")
                            End If

                            'Se posso creare/modificare i pazienti posso eseguire fusioni
                            SetHyperLinkStyle(MergeLink, mbCanCreatePazienti OrElse mbCanWritePazienti)

                            ' Load delle esenzioni                            
                            Try
                                LoadEsenzioni(Nothing, Nothing)
                            Catch ex As Exception
                                ExceptionsManager.TraceException(ex)
                                LabelError.Visible = True
                                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
                            End Try

                            ' Load dei consensi                            
                            Try
                                LoadConsensi(Nothing, Nothing)
                            Catch ex As Exception
                                ExceptionsManager.TraceException(ex)
                                LabelError.Visible = True
                                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
                            End Try

                            ' Se UrlReferrer è "~/Consensi/ConsensoDettaglio.aspx" mi riposiziono nel tab consensi                            
                            If Request.UrlReferrer IsNot Nothing AndAlso Request.UrlReferrer.OriginalString.Contains("ConsensoDettaglio.aspx") Then

                                ' Cerco il controllo multiview                            
                                If PazienteDettaglioFormView.TryFindControl(Of MultiView)("PazienteDettaglioMultiView", mPazienteDettaglioMultiView) Then

                                    ' Cerco il controllo view                                    
                                    If mPazienteDettaglioMultiView.TryFindControl(Of View)("Consensi", mPazienteDettaglioView) Then
                                        mPazienteDettaglioMultiView.SetActiveView(mPazienteDettaglioView)
                                    End If
                                End If

                                ' Setto il colore di background del button                                
                                SetBackgroundButton(TabContainer, "btnActiveViewConsensi")
                            End If

                            Me.btnActiveViewAnonimizzazioni.Visible = False
                            If mbCanReadAnonimizzazione Then
                                Call LoadAnonimizzazioni(bAnagraficaAnonima, IdSacOriginaleAnonimizzazione)
                                Me.btnActiveViewAnonimizzazioni.Visible = True
                            End If


                            Me.btnActiveViewPosizioniCollegate.Visible = False
                            If mbCanReadPosCollegata Then
                                Call LoadPosizioniCollegate(bAnagraficaCollegata, IdSacOriginalePosCollegata)
                                Me.btnActiveViewPosizioniCollegate.Visible = True
                            End If

                            '
                            '2020-07-01 Kyrylo: Traccia Operazioni
                            '
                            Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                            oTracciaOp.TracciaOperazione(PortalsNames.Sac, Page.AppRelativeVirtualPath, "Visualizzato dettaglio paziente", New Guid(sIdPaziente))

                        Case Else

                            Me.btnActiveViewEsenzioni.Visible = False
                            Me.btnActiveViewConsensi.Visible = False
                            Me.btnActiveViewAnonimizzazioni.Visible = False
                    End Select

                End If 'End IsPostBack

            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
                'Rendo invisibile tutto
                Call SetDetailVisible(False)
            End Try
        End Sub

        Protected Sub EliminaLink_Click(ByVal sender As Object, ByVal e As EventArgs) Handles EliminaLink.Click
            Try
                Dim paziente As PazientiGestioneRow = PazienteCorrente(0)

                Using query = New PazientiGestioneTableAdapter()
                    query.Update(paziente.Id, 1, DateTime.Now, paziente.Occultato, User.Identity.Name)
                End Using

                ' Invalido la Cache                
                Cache("PazientiGestioneLista") = DateTime.Now()

                '
                '2020-07-02 Kyrylo: Traccia Operazioni
                '
                Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                oTracciaOp.TracciaOperazione(PortalsNames.Sac, Page.AppRelativeVirtualPath, "Eliminata anagrafica", mIdPaziente)

                Response.Redirect("PazientiLista.aspx", False)

            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Eliminazione)
            End Try
        End Sub

        Protected Sub RipristinaLink_Click(ByVal sender As Object, ByVal e As EventArgs) Handles RipristinaLink.Click
            Try
                ' Ripristino dall'eliminazione il paziente                
                Dim paziente As PazientiGestioneRow = PazienteCorrente(0)
                Dim dataDisattivazione As Nullable(Of DateTime) = Nothing

                Using adapter = New PazientiGestioneTableAdapter()
                    adapter.Update(paziente.Id, 0, dataDisattivazione, paziente.Occultato, User.Identity.Name)
                End Using

                Cache("PazientiGestioneLista") = DateTime.Now()
                Response.Redirect("PazientiLista.aspx", False)

            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Aggiornamento)
            End Try
        End Sub

        Private Property PazienteCorrente() As PazientiGestioneDataTable
            Get
                Dim paziente As Object = ViewState("PazienteCorrente")
                If paziente Is Nothing Then Return Nothing Else Return DirectCast(paziente, PazientiGestioneDataTable)
            End Get
            Set(ByVal Value As PazientiGestioneDataTable)
                ViewState("PazienteCorrente") = Value
            End Set
        End Property

        Protected Sub Button_Command(ByVal sender As Object, ByVal e As CommandEventArgs)
            '
            ' Determino quale button è stato cliccato e setto 
            ' la proprietà ActiveViewIndex del controllo MultiView
            '
            Try
                If PazienteDettaglioFormView.TryFindControl(Of MultiView)("PazienteDettaglioMultiView", mPazienteDettaglioMultiView) Then

                    If mPazienteDettaglioMultiView.TryFindControl(Of View)(e.CommandArgument.ToString(), mPazienteDettaglioView) Then
                        mPazienteDettaglioMultiView.SetActiveView(mPazienteDettaglioView)
                    Else
                        'Questo errore si genera quando non è stata impostato correttamente il nome della View
                        LabelError.Visible = True
                        LabelError.Text = MessageHelper.GetGenericMessage()
                    End If

                    ' Setto il colore di background del button                
                    SetBackgroundButton(TabContainer, String.Empty)
                    DirectCast(sender, Button).CssClass = "ActiveView"
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub



        Protected Sub PazienteDettaglioObjectDataSource_Selected(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles PazienteDettaglioObjectDataSource.Selected
            Try
                If e.Exception IsNot Nothing Then
                    ExceptionsManager.TraceException(e.Exception)
                    LabelError.Visible = True
                    LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
                    e.ExceptionHandled = True
                Else
                    ' Salvo nel ViewState i valori degli attributi Id e Ts utilizzati come parametri nella SP di update                
                    Dim dt As PazientiDettaglioDataTable = DirectCast(e.ReturnValue, PazientiDettaglioDataTable)
                    If dt.Rows.Count > 0 Then
                        Dim row As PazientiDettaglioRow = dt(0)
                        ViewState.Add("Id", row.Id)
                        ViewState.Add("Ts", row.Ts)
                        '
                        ' MODIFICA ETTORE 2014-02-04: faccio l'uppercase del sesso se non è nullo 
                        '
                        If row.IsSessoNull Then
                            row.Sesso = ""
                        Else
                            row.Sesso = row.Sesso.ToUpper()
                        End If

                        '
                        ' Memorizzo CodiceTerminazione, DescrizioneTerminazione da usare per caricare eventualemnte la combo ddlTerminazioni
                        '
                        If row.IsCodiceTerminazioneNull Then row.CodiceTerminazione = ""
                        If row.IsDescrizioneTerminazioneNull Then row.DescrizioneTerminazione = ""
                        ViewState("CodiceTerminazione") = row.CodiceTerminazione
                        ViewState("DescrizioneTerminazione") = row.DescrizioneTerminazione

                        '
                        ' NON CONSENTO LA FUSIONE SU PAZIENTI PROVENIENTI DA LHA
                        '
                        If row.Provenienza.ToUpper = "LHA" Then SetHyperLinkStyle(MergeLink, False)

                    End If
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

        Protected Sub PazienteDettaglioObjectDataSource_Inserting(ByVal sender As Object, ByVal e As ObjectDataSourceMethodEventArgs) Handles PazienteDettaglioObjectDataSource.Inserting
            Try
                e.InputParameters("Utente") = Context.User.Identity.Name

                '---------------------------------------------------------------------------------------------------------------------------------------------------------
                ' Gestione manuale dei campi CodiceTerminazione, DescrizioneTerminazione, DataTerminazioneAss (Valorizzo i parametri e gestisco il nothing/null)
                '---------------------------------------------------------------------------------------------------------------------------------------------------------
                motxtDataTerminazioneAss = MyFindControl(PazienteDettaglioFormView, "PazienteDettaglioMultiView", "AssistitoMedicoBase", "txtDataTerminazioneAss")
                moddlTerminazioni = MyFindControl(PazienteDettaglioFormView, "PazienteDettaglioMultiView", "AssistitoMedicoBase", "ddlTerminazioni")
                If (motxtDataTerminazioneAss.Text <> "") Then
                    'Verifico che sia stato selezionato un item dalla combo ddlTerminazioni 
                    If moddlTerminazioni.SelectedValue = "" Then
                        Throw New ApplicationException("Se data terminazione è valorizzata, la descrizione della terminazione è obbligatoria.")
                    End If
                End If
                e.InputParameters("CodiceTerminazione") = If(moddlTerminazioni.SelectedItem.Value = "", Nothing, moddlTerminazioni.SelectedItem.Value)
                e.InputParameters("DescrizioneTerminazione") = If(moddlTerminazioni.SelectedItem.Text = "", Nothing, moddlTerminazioni.SelectedItem.Text)
                Dim dDataTerminzioneAss As DateTime?
                If motxtDataTerminazioneAss.Text <> "" Then
                    dDataTerminzioneAss = CType(motxtDataTerminazioneAss.Text, DateTime)
                End If
                e.InputParameters("DataTerminazioneAss") = dDataTerminzioneAss
                '---------------------------------------------------------------------------------------------------------------------------------------------------------

            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
                e.Cancel = True
            End Try
        End Sub

        Protected Sub PazienteDettaglioObjectDataSource_Inserted(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles PazienteDettaglioObjectDataSource.Inserted
            Try
                If e.Exception IsNot Nothing Then
                    ExceptionsManager.TraceException(e.Exception)
                    LabelError.Visible = True
                    LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Inserimento)
                    e.ExceptionHandled = True
                Else
                    Cache("PazientiLista") = DateTime.Now()
                    Response.Redirect("PazientiLista.aspx", False)
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

        Protected Sub PazienteDettaglioObjectDataSource_Updating(ByVal sender As Object, ByVal e As ObjectDataSourceMethodEventArgs) Handles PazienteDettaglioObjectDataSource.Updating
            Try

                e.InputParameters("Id") = ViewState("Id")
                e.InputParameters("Ts") = ViewState("Ts")
                e.InputParameters("Utente") = Context.User.Identity.Name

                '---------------------------------------------------------------------------------------------------------------------------------------------------------
                ' Gestione manuale dei campi CodiceTerminazione, DescrizioneTerminazione, DataTerminazioneAss (Valorizzo i parametri e gestisco il nothing/null)
                '---------------------------------------------------------------------------------------------------------------------------------------------------------
                motxtDataTerminazioneAss = MyFindControl(PazienteDettaglioFormView, "PazienteDettaglioMultiView", "AssistitoMedicoBase", "txtDataTerminazioneAss")
                moddlTerminazioni = MyFindControl(PazienteDettaglioFormView, "PazienteDettaglioMultiView", "AssistitoMedicoBase", "ddlTerminazioni")
                If (motxtDataTerminazioneAss.Text <> "") Then
                    'Verifico che sia stato selezionato un item dalla combo ddlTerminazioni 
                    If moddlTerminazioni.SelectedValue = "" Then
                        Throw New ApplicationException("Se data terminazione è valorizzata, la descrizione della terminazione è obbligatoria.")
                    End If
                End If
                e.InputParameters("CodiceTerminazione") = If(moddlTerminazioni.SelectedItem.Value = "", Nothing, moddlTerminazioni.SelectedItem.Value)
                e.InputParameters("DescrizioneTerminazione") = If(moddlTerminazioni.SelectedItem.Text = "", Nothing, moddlTerminazioni.SelectedItem.Text)
                Dim dDataTerminzioneAss As DateTime?
                If motxtDataTerminazioneAss.Text <> "" Then
                    dDataTerminzioneAss = CType(motxtDataTerminazioneAss.Text, DateTime)
                End If
                e.InputParameters("DataTerminazioneAss") = dDataTerminzioneAss
                '---------------------------------------------------------------------------------------------------------------------------------------------------------

                Dim regioneResCodice As String = Nothing
                If PazienteDettaglioFormView.TryFindControl(Of MultiView)("PazienteDettaglioMultiView", mPazienteDettaglioMultiView) Then

                    If mPazienteDettaglioMultiView.FindControl("pddlComuneAslRes") IsNot Nothing Then
                        mComuneAslResCascadingDropDownList = DirectCast(mPazienteDettaglioMultiView.FindControl("pddlComuneAslRes"), CascadingDropDownList)
                        regioneResCodice = GetCodiceAslRegione(mComuneAslResCascadingDropDownList.ChildDownBindValue, mComuneAslResCascadingDropDownList.ChildTopBindValue)
                    End If
                End If

                If Not String.IsNullOrEmpty(regioneResCodice) Then
                    e.InputParameters("RegioneResCodice") = regioneResCodice
                End If

                Dim regioneAssCodice As String = Nothing
                If PazienteDettaglioFormView.TryFindControl(Of MultiView)("PazienteDettaglioMultiView", mPazienteDettaglioMultiView) Then

                    If mPazienteDettaglioMultiView.FindControl("pddlComuneAslAss") IsNot Nothing Then
                        mComuneAslAssCascadingDropDownList = DirectCast(mPazienteDettaglioMultiView.FindControl("pddlComuneAslAss"), CascadingDropDownList)
                        regioneAssCodice = GetCodiceAslRegione(mComuneAslAssCascadingDropDownList.ChildDownBindValue, mComuneAslAssCascadingDropDownList.ChildTopBindValue)
                    End If
                End If

                If Not String.IsNullOrEmpty(regioneAssCodice) Then
                    e.InputParameters("RegioneAssCodice") = regioneAssCodice
                End If

            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
                e.Cancel = True
            End Try

        End Sub

        Private Function GetCodiceAslRegione(ByVal codice As String, ByVal codiceComune As String) As String

            Using adapter As New IstatAslTableAdapter()

                Dim dt As IstatAslDataTable = adapter.GetData(codice, codiceComune)

                If dt.Rows.Count > 0 Then
                    Return dt(0).CodiceAslRegione
                End If
            End Using

            Return Nothing
        End Function

        Protected Sub PazienteDettaglioObjectDataSource_Updated(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles PazienteDettaglioObjectDataSource.Updated
            Try
                If e.Exception IsNot Nothing Then
                    ExceptionsManager.TraceException(e.Exception)
                    LabelError.Visible = True
                    LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Aggiornamento)
                    e.ExceptionHandled = True
                Else

                    Cache("PazientiLista") = DateTime.Now()
                    Response.Redirect("PazientiLista.aspx", False)
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

        Private Sub PazienteDettaglioFormView_DataBound(sender As Object, e As System.EventArgs) Handles PazienteDettaglioFormView.DataBound
            '
            ' Ricavo i dati per la combo relativo al record corrente
            ' Se manca alla drop down lo aggiungo per sicurezza (in quanto dati provenienti da LHA, e manca integrità referenziale sul campo CodiceTerminazione)
            '
            Dim sCodiceTerminazione As String = DirectCast(ViewState("CodiceTerminazione"), String)
            Dim sDescrizioneTerminazione As String = DirectCast(ViewState("DescrizioneTerminazione"), String)
            '
            ' Carico dati per combo ddlTerminazioni
            '
            Call LoadComboTerminazioni(sCodiceTerminazione, sDescrizioneTerminazione)
            '
            ' Usando i dati del record corrente seleziono il valore della dropdown list
            ' Il valore da selezionare ora esiste per forza!
            '
            moddlTerminazioni.SelectedValue = sCodiceTerminazione

        End Sub

        'dropdown presente nell'EditTemplate del PazienteDettaglioFormView / AnagrafeStati
        Protected Sub ddlSesso_DataBinding(sender As Object, e As EventArgs)
            '
            ' Aggiungo alla dropdown Sesso un eventuale codice non presente in lista 
            '
            Try
                Dim paziente As PazientiGestioneRow = PazienteCorrente(0)
                Dim ddlSesso As DropDownList = sender
                If ddlSesso.Items.FindByValue(paziente.Sesso) Is Nothing Then
                    ddlSesso.Items.Add(New ListItem(paziente.Sesso, paziente.Sesso))
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub


        Protected Sub PazienteDettaglioFormView_ItemCommand(ByVal sender As Object, ByVal e As FormViewCommandEventArgs) Handles PazienteDettaglioFormView.ItemCommand
            Try
                If e.CommandName = DataControlCommands.CancelCommandName Then
                    'Response.Redirect(Request.Url.OriginalString.Replace("&edit=true", String.Empty), False)
                    Response.Redirect("PazientiLista.aspx", False)
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If

            End Try
        End Sub

#Region "Consensi"

        Protected Sub LoadConsensi(ByVal sender As Object, ByVal e As EventArgs)

            If mbCanReadConsensi Then

                If PazienteDettaglioFormView.TryFindControl(Of GridView)("gvConsensi", mConsensiGrid) Then
                    '
                    ' Visualizzo le colonne nascoste dalla visualizzazione All
                    '
                    For Each c As DataControlField In mConsensiGrid.Columns
                        c.Visible = True
                    Next

                    Dim dataSource As New ConsensiListaDataTable()
                    Using adapter = New ConsensiListaTableAdapter()
                        adapter.Fill(dataSource, mIdPaziente)
                    End Using
                    mConsensiGrid.DataSource = dataSource
                    mConsensiGrid.DataBind()
                End If
            Else
                'LabelError.Visible = True
                'LabelError.Text = "Non si dispone dei diritti necessari per visualizzare i consensi!"
            End If
        End Sub

        Protected Function GetDataConsensiAll(ByVal idPaziente As Guid, ByVal idTipoConsenso As Byte) As ConsensiListaDataTable

            Dim dt As New ConsensiListaDataTable()

            Using adapter = New ConsensiListaTableAdapter()
                adapter.FillAll(dt, idPaziente, idTipoConsenso)
            End Using

            Return dt
        End Function

        Protected Sub gvConsensi_RowDataBound(ByVal sender As Object, ByVal e As GridViewRowEventArgs)
            Try
                If e.Row.RowType = DataControlRowType.DataRow Then
                    '
                    ' Cerco il controllo radiobutton di visualizzazione dei consensi
                    '
                    If PazienteDettaglioFormView.TryFindControl(Of RadioButtonList)("rblVisualizzaConsensi", mVisualizzaConsensiRadioButtonList) Then

                        If mVisualizzaConsensiRadioButtonList.SelectedValue.Equals("All") Then

                            '
                            ' Nascondo alcune colonne della gridview principale
                            '
                            If PazienteDettaglioFormView.TryFindControl(Of GridView)("gvConsensi", mConsensiGrid) Then

                                mConsensiGrid.Columns(2).Visible = False
                                mConsensiGrid.Columns(3).Visible = False
                                mConsensiGrid.Columns(4).Visible = False
                                mConsensiGrid.Columns(5).Visible = False
                                mConsensiGrid.Columns(6).Visible = False
                                mConsensiGrid.Columns(8).Visible = False 'la colonna degli attributi

                                DirectCast(e.Row.Cells(0).Controls(0), HyperLink).NavigateUrl = String.Empty
                                DirectCast(e.Row.Cells(0).Controls(0), HyperLink).Style.Add("color", "#000000")
                                '
                                ' Visualizzo la gridview nested
                                '
                                Dim idTipo As String = DirectCast(e.Row.Cells(7).Controls(1), Label).Text

                                mConsensiNestedGrid = DirectCast(e.Row.Cells(1).Controls(1), GridView)
                                mConsensiNestedGrid.Attributes.Add("IdPaziente", mIdPaziente.ToString)
                                mConsensiNestedGrid.Attributes.Add("IdTipoConsenso", idTipo)
                                mConsensiNestedGrid.DataSource = GetDataConsensiAll(mIdPaziente, CType(idTipo, Byte))
                                mConsensiNestedGrid.DataBind()
                            End If
                        End If
                    End If
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try


        End Sub

        Protected Sub gvConsensiNested_PageIndexChanging(ByVal sender As Object, ByVal e As GridViewPageEventArgs)
            Try
                Dim gvConsensiNested As GridView = DirectCast(sender, GridView)

                gvConsensiNested.DataSource = GetDataConsensiAll(New Guid(gvConsensiNested.Attributes("IdPaziente")), CType(gvConsensiNested.Attributes("IdTipoConsenso"), Byte))
                gvConsensiNested.PageIndex = e.NewPageIndex
                gvConsensiNested.DataBind()

            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
            End Try
        End Sub

#End Region

#Region " Esenzioni "

        Protected Sub LoadEsenzioni(ByVal sender As Object, ByVal e As System.EventArgs)

            ' Cerco il controllo radiobutton di visualizzazione dei consensi            
            Dim dataFineValidita As Nullable(Of DateTime) = Nothing

            If PazienteDettaglioFormView.TryFindControl(Of RadioButtonList)("rblVisualizzaEsenzioni", mVisualizzaEsenzioniRadioButtonList) Then

                If Not mVisualizzaEsenzioniRadioButtonList.SelectedValue.Equals("All") Then

                    dataFineValidita = DateTime.Now
                End If
            End If

            If PazienteDettaglioFormView.TryFindControl(Of GridView)("gvEsenzioni", mEsenzioniGrid) Then

                Dim dataSource As New EsenzioniListaDataTable()
                Using adapter = New EsenzioniListaTableAdapter()
                    adapter.FillByIdPaziente(dataSource, mIdPaziente, dataFineValidita)
                End Using

                mEsenzioniGrid.DataSource = dataSource
                mEsenzioniGrid.DataBind()
            Else
                LabelError.Visible = True
                LabelError.Text = "Non si dispone dei diritti necessari per visualizzare le esenzioni!"
            End If
        End Sub

#End Region

#Region " Anonimizzazioni "

        Protected Sub LoadAnonimizzazioni(bAnagraficaAnonima As Boolean, IdSacOriginale As Guid)
            Dim oPosizioneOriginaleLink As HyperLink = Nothing
            If PazienteDettaglioFormView.TryFindControl(Of GridView)("gvAnonimizzazioni", mAnonimizzazioniGrid) Then
                If Not bAnagraficaAnonima Then
                    '
                    ' Rendo VISIBILE la gridview
                    '
                    mAnonimizzazioniGrid.Visible = True
                    '
                    ' Carico i dati
                    '
                    mAnonimizzazioniGrid.DataSource = GetPazientiAnonimizzazioniLista(mIdPaziente)
                    mAnonimizzazioniGrid.DataBind()
                    '
                    ' Rendo INVISIBLE il lik alla posizione corrente
                    '
                    If PazienteDettaglioFormView.TryFindControl(Of HyperLink)("PosizioneOriginaleLink", oPosizioneOriginaleLink) Then
                        oPosizioneOriginaleLink.Visible = False
                    End If
                Else
                    '
                    ' Rendo INVISIBILE la gridview
                    '
                    mAnonimizzazioniGrid.Visible = False
                    '
                    ' Rendo VISIBLE il link alla posizione corrente e valorizzo URL
                    '
                    If PazienteDettaglioFormView.TryFindControl(Of HyperLink)("PosizioneOriginaleLink", oPosizioneOriginaleLink) Then
                        oPosizioneOriginaleLink.NavigateUrl = String.Format("~/Pazienti/PazienteDettaglio.aspx?Id={0}", IdSacOriginale)
                        oPosizioneOriginaleLink.Visible = True
                    End If
                End If
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
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

#End Region

#Region " Posizioni Collegate "

        Protected Sub LoadPosizioniCollegate(bAnagraficaCollegata As Boolean, IdSacOriginale As Guid)
            Dim oPosizioneOriginaleLink As HyperLink = Nothing
            If PazienteDettaglioFormView.TryFindControl(Of GridView)("gvPosizioniCollegate", mPosizioniCollegateGrid) Then
                If Not bAnagraficaCollegata Then
                    '
                    ' Rendo VISIBILE la gridview
                    '
                    mPosizioniCollegateGrid.Visible = True
                    '
                    ' Carico i dati
                    '
                    mPosizioniCollegateGrid.DataSource = GetPazientiPosizioniCollegateLista(mIdPaziente)
                    mPosizioniCollegateGrid.DataBind()
                    '
                    ' Rendo INVISIBLE il lik alla posizione corrente
                    '
                    If PazienteDettaglioFormView.TryFindControl(Of HyperLink)("PosizioneOriginalePosizioneCollegataLink", oPosizioneOriginaleLink) Then
                        oPosizioneOriginaleLink.Visible = False
                    End If
                Else
                    '
                    ' Rendo INVISIBILE la gridview
                    '
                    mPosizioniCollegateGrid.Visible = False
                    '
                    ' Rendo VISIBLE il link alla posizione corrente e valorizzo URL
                    '
                    If PazienteDettaglioFormView.TryFindControl(Of HyperLink)("PosizioneOriginalePosizioneCollegataLink", oPosizioneOriginaleLink) Then
                        oPosizioneOriginaleLink.NavigateUrl = String.Format("~/Pazienti/PazienteDettaglio.aspx?Id={0}", IdSacOriginale)
                        oPosizioneOriginaleLink.Visible = True
                    End If
                End If
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

        Private Sub SetBackgroundButton(ByRef container As Control, ByVal activeControl As String)

            ' Setto il background di default dei buttons
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

        Private Sub SetHyperLinkStyle(sender As HyperLink, ByVal enabled As Boolean)

            Dim extension = If(sender.Text.Contains("gif"), "gif", "png")

            If enabled Then
                sender.Enabled = True
                sender.Text = sender.Text.Replace("_grey." & extension, "." & extension)
                sender.Style.Remove("color")
            Else
                sender.Enabled = False
                sender.Style.Add("color", "gray")
                If Not sender.Text.Contains("_grey." & extension) Then
                    sender.Text = sender.Text.Replace("." & extension, "_grey." & extension)
                End If
            End If
        End Sub

        Private Sub SetHyperLinkStyle(sender As LinkButton, ByVal enabled As Boolean)

            Dim extension = If(sender.Text.Contains("gif"), "gif", "png")

            If enabled Then
                sender.Enabled = True
                sender.Text = sender.Text.Replace("_grey." & extension, "." & extension)
                sender.Style.Remove("color")
            Else
                sender.Enabled = False
                sender.Style.Add("color", "gray")
                sender.OnClientClick = String.Empty
                If Not sender.Text.Contains("_grey." & extension) Then
                    sender.Text = sender.Text.Replace("." & extension, "_grey." & extension)
                End If
            End If
        End Sub

        ''' <summary>
        ''' Aggiorna la tabella degli ultimi pazienti visitati
        ''' </summary>
        ''' <param name="id"></param>
        ''' <remarks></remarks>
        Private Sub AggiornaTabellaUltimiPazientiVisitati(id As Guid)

            Dim ultimiPazientiTable As PazientiGestioneListaDataTable

            If Session("UltimiPazientiVisitati") Is Nothing Then

                ultimiPazientiTable = New PazientiGestioneListaDataTable()

                Session("UltimiPazientiVisitati") = ultimiPazientiTable
            Else
                ultimiPazientiTable = DirectCast(Session("UltimiPazientiVisitati"), PazientiGestioneListaDataTable)
            End If

            Dim foundRows = ultimiPazientiTable.Select("Id = '" & id.ToString() & "'")

            If foundRows.Count > 0 Then

                ultimiPazientiTable.Rows.Remove(foundRows(0))
            End If

            If ultimiPazientiTable.Count = 5 Then
                ultimiPazientiTable.Rows.RemoveAt(0)
            End If

            Using adapter As New PazientiGestioneListaTableAdapter()

                ultimiPazientiTable.Merge(adapter.GetData(Nothing, Nothing, Nothing, Nothing, id, Nothing, Nothing, Nothing, Nothing))
            End Using
        End Sub

        Private Function GetIdLha() As Decimal?

            If PazienteCorrente(0).Provenienza = "LHA" Then

                Dim idLha As Decimal

                If Decimal.TryParse(PazienteCorrente(0).IdProvenienza, idLha) Then
                    Return idLha
                End If
            End If

            Return Nothing
        End Function

        Protected Sub SincronizzaLink_Click(sender As Object, e As EventArgs) Handles SincronizzaLink.Click
            Try
                Using adapter As New PazientiDropTableUiListTableAdapter()

                    Dim value As Decimal? = GetIdLha()

                    If value.HasValue() Then
                        adapter.Insert(value)
                    End If
                End Using

            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try

        End Sub

        ''' <summary>
        ''' Da usare in caso di errore per nascondere le componenti della pagina
        ''' </summary>
        ''' <param name="bVisible"></param>
        ''' <remarks></remarks>
        Private Sub SetDetailVisible(bVisible As Boolean)
            ToolbarTable.Visible = bVisible
            NomePazienteFormView.Visible = bVisible
            TabContainer.Visible = bVisible
            TabSeparator.Visible = bVisible
            PazienteDettaglioFormView.Visible = bVisible
        End Sub

        ''' <summary>
        ''' Visualizza la data di decesso nell'ItemTemplate
        ''' </summary>
        ''' <param name="oCodiceTerminazione"></param>
        ''' <param name="oDataTerminazione"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Protected Function GetDataDecesso(oCodiceTerminazione As Object, oDataTerminazione As Object) As String
            Try
                Return Utility.GetDataDecesso(oCodiceTerminazione, oDataTerminazione)
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
            Return Nothing
        End Function


        ''' <summary>
        ''' Funzione generica per la ricerca di un controllo nella pagina di dettaglio
        ''' </summary>
        ''' <param name="oFormView"></param>
        ''' <param name="sIdMultiView"></param>
        ''' <param name="sIdView"></param>
        ''' <param name="sIdControl"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Private Function MyFindControl(oFormView As FormView, sIdMultiView As String, sIdView As String, sIdControl As String) As Control
            Dim oControl As Control = Nothing
            Dim oMultiView As MultiView = Nothing
            If oFormView.TryFindControl(Of MultiView)(sIdMultiView, oMultiView) Then
                Dim oView As View = Nothing
                ' Cerco il controllo view                                    
                If oMultiView.TryFindControl(Of View)(sIdView, oView) Then
                    'Cerco il controllo
                    oView.TryFindControl(Of Control)(sIdControl, oControl)
                End If
            End If
            '
            '
            '
            Return oControl
        End Function

        ''' <summary>
        ''' Carico gli item della combo delle terminazioni
        ''' </summary>
        ''' <param name="sCodiceTerminazione"></param>
        ''' <param name="sDescrizioneTerminazione"></param>
        ''' <remarks></remarks>
        Private Sub LoadComboTerminazioni(sCodiceTerminazione As String, sDescrizioneTerminazione As String)
            Try
                Using oTaTerminazioni As New DI.Sac.Admin.Data.PazientiDataSetTableAdapters.ComboTerminazioniTableAdapter
                    Dim odtTerminazioni As DI.Sac.Admin.Data.PazientiDataSet.ComboTerminazioniDataTable = oTaTerminazioni.GetData()
                    moddlTerminazioni = MyFindControl(PazienteDettaglioFormView, "PazienteDettaglioMultiView", "AssistitoMedicoBase", "ddlTerminazioni")
                    If Not moddlTerminazioni Is Nothing Then
                        moddlTerminazioni.Items.Clear()
                        moddlTerminazioni.DataSource = odtTerminazioni
                        moddlTerminazioni.DataBind()
                        '
                        ' Aggiungo sempre "", "" per gestione dei NULL - FONDAMENTALE
                        '
                        If moddlTerminazioni.Items.FindByValue("") Is Nothing Then
                            Dim oItem As New ListItem("", "")
                            moddlTerminazioni.Items.Insert(0, oItem) 'Lo aggiungo all'inizio
                        End If
                        '
                        ' Aggiungo i valori sul record paziente se  mancano - FONDAMENTALE
                        '
                        If moddlTerminazioni.Items.FindByValue(sCodiceTerminazione) Is Nothing Then
                            Dim oItem As New ListItem(sDescrizioneTerminazione, sCodiceTerminazione)
                            moddlTerminazioni.Items.Add(oItem) 'Lo aggiungo alla fine
                        End If
                    Else
                        Throw New ApplicationException("Impossibile caricare la lista delle terminazioni!")
                    End If
                End Using
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

        Private Sub btnActiveViewAnagrafeStati_Click(sender As Object, e As System.EventArgs) Handles btnActiveViewAnagrafeStati.Click
            Try
                If PazienteDettaglioFormView.DefaultMode <> FormViewMode.ReadOnly Then
                    '
                    ' Allineamento della txtDataDecesso quando siamo in modalita Update/Insert
                    '
                    moddlTerminazioni = MyFindControl(PazienteDettaglioFormView, "PazienteDettaglioMultiView", "AssistitoMedicoBase", "ddlTerminazioni")
                    If Not moddlTerminazioni Is Nothing Then
                        If moddlTerminazioni.SelectedValue = DDL_TERMINAZIONI_CODICE_DECESSO Then
                            motxtDataDecesso = MyFindControl(PazienteDettaglioFormView, "PazienteDettaglioMultiView", "AssistitoMedicoBase", "txtDataDecesso")
                            motxtDataTerminazioneAss = MyFindControl(PazienteDettaglioFormView, "PazienteDettaglioMultiView", "AssistitoMedicoBase", "txtDataterminazioneAss")
                            If Not motxtDataTerminazioneAss Is Nothing AndAlso Not motxtDataDecesso Is Nothing Then
                                motxtDataDecesso.Text = motxtDataTerminazioneAss.Text
                            End If
                        End If
                    End If
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub


        Protected Sub RinotificaFusioneButton_Click(sender As Object, e As EventArgs) Handles RinotificaFusioneButton.Click

            Try
                Dim IdPazientePadre As Guid
                Dim Utente As String = User.Identity.Name
                Dim IdPazienteFuso As Guid = mIdPaziente

                ' Recupero l'IDPaziente dell'anagrafica padre                            
                Using adapter = New PazientiMergeTableAdapter()

                    Dim pazientiMerge As PazientiMergeDataTable = adapter.GetDataRootById(mIdPaziente)

                    If pazientiMerge.Rows.Count = 0 Then
                        LabelError.Visible = True
                        LabelError.Text = "Anagrafica root non trovata. Contattare un amministratore."
                        Exit Sub
                    End If
                    IdPazientePadre = pazientiMerge(0).IdPaziente

                End Using

                Dim iRet As Integer? = -1
                Using adapter = New FunctionTableAdapter()
                    iRet = adapter.PazientiUiRinotificaFusione(IdPazientePadre, IdPazienteFuso, Utente)
                End Using

                If iRet = 0 Then
                    ClientScript.RegisterStartupScript(Me.GetType(), "Popup", "alert('Operazione avvenuta con successo','Rinotifica Fusione');", True)
                Else
                    LabelError.Visible = True
                    LabelError.Text = "Si è verificato un errore. Contattare un amministratore"
                End If

            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

        Private Sub RinotificaPazienteAttivoButton_Click(sender As Object, e As EventArgs) Handles RinotificaPazienteAttivoButton.Click
            Try
                Dim Utente As String = User.Identity.Name
                Dim IdPazienteAttivo As Guid = mIdPaziente

                Dim iRet As Integer? = -1
                Using adapter = New FunctionTableAdapter()
                    iRet = adapter.PazientiUiRinotificaPazienteAttivo(IdPazienteAttivo, Utente)
                End Using

                If iRet = 0 Then
                    ClientScript.RegisterStartupScript(Me.GetType(), "Popup", "alert('Operazione avvenuta con successo','Rinotifica paziente');", True)
                Else
                    LabelError.Visible = True
                    LabelError.Text = "Si è verificato un errore. Contattare un amministratore"
                End If

                '
                '2020-07-02 Kyrylo: Traccia Operazioni
                '
                Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                oTracciaOp.TracciaOperazione(PortalsNames.Sac, Page.AppRelativeVirtualPath, "Rinotifica anagrafica", mIdPaziente)

            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try

        End Sub


        ''' <summary>
        ''' Funzione usata nella parte ASPX per visualizzare gli attributi
        ''' </summary>
        ''' <param name="oAttributi"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Protected Function ShowAttributi(oAttributi As Object) As String
            Return Utility.ShowAttributi(oAttributi)
        End Function

        ''' <summary>
        ''' Funzione usata nella parte ASPX per visualizzare solo i dati dell'autorizzatore al consenso del minore
        ''' </summary>
        ''' <param name="oAttributi"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Protected Function ShowAttributiAutorizzatoreMinore(oAttributi As Object) As String
            Return Utility.ShowAttributiAutorizzatoreMinore(oAttributi)
        End Function

        Private Sub PazienteDettaglioFormView_ItemUpdating(sender As Object, e As FormViewUpdateEventArgs) Handles PazienteDettaglioFormView.ItemUpdating

            '
            '2020-07-02 Kyrylo: Traccia Operazioni
            '
            Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
            oTracciaOp.TracciaOperazione(PortalsNames.Sac, Page.AppRelativeVirtualPath, "Effettuata modifica anagrafica", e.OldValues, e.NewValues, mIdPaziente)

        End Sub
    End Class

End Namespace