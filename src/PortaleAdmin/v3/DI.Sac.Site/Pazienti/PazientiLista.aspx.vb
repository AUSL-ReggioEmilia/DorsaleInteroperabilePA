Imports System.Web.UI
Imports System
Imports System.Web.UI.HtmlControls
Imports System.Diagnostics
Imports System.Web.UI.WebControls
Imports DI.Common
Imports System.Reflection
Imports System.Drawing
Imports DI.Sac.Admin.Data.PazientiDataSet
Imports DI.PortalAdmin.Data

Namespace DI.Sac.Admin

    Partial Public Class PazientiLista
        Inherits Page

        Private Shared ReadOnly _className As String = String.Concat("Gestione.", MethodBase.GetCurrentMethod().ReflectedType.Name)

        ' Controlli da ricercare nella pagina master        
        Private formMaster As HtmlForm

        Private ReadOnly _canCreatePazienti As Boolean = User.IsInRole(TypeRoles.ROLE_PAZIENTI_CREATE.ToString())

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
            Try
                If Not Page.IsPostBack Then
                    ' ABilito la possibilità di creare un nuovo paziente in base ai diritti dell'utente corrente
                    NuovoPazienteLink.Enabled = _canCreatePazienti

                    ' Crea una variabile per gestire la cache del ObjectDatasource                
                    If Cache("PazientiGestioneLista") Is Nothing Then Cache("PazientiGestioneLista") = DateTime.Now()

                    LoadGridViewPagingAndSorting()
                    '
                    ' Prima di sistemare i filtri devo assicurarmi che eventuali dropdown list siano caricate
                    '
                    ProvenienzaDropDownList.DataBind()
                    '
                    ' Risetto i filtri con i valori in sessione
                    '
                    FilterHelper.Restore(pannelloFiltri, _className)
                    '
                    '
                    '
                    CaricaUltimiPazientiVisitati()
                End If

                ' Default Focus/Button            
                If Master.TryFindControl(Of HtmlForm)("form1", formMaster) Then
                    formMaster.DefaultFocus = CognomeTextBox.ClientID
                    formMaster.DefaultButton = RicercaButton.UniqueID
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
                MainTable.Visible = False
            End Try
        End Sub

        Protected Sub btnRicerca_Click(ByVal sender As Object, ByVal e As EventArgs) Handles RicercaButton.Click
            Try
                If IsSearchValid() Then

                    'FilterHelper.SaveInSession(pannelloFiltri, _className)
                    LabelError.Visible = False

                    '
                    '2020-07-01 Kyrylo: Traccia Operazioni
                    '
                    Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                    oTracciaOp.TracciaOperazione(PortalsNames.Sac, Page.AppRelativeVirtualPath, "Ricerca pazienti", pannelloFiltri, Nothing)


                Else
                    LabelError.Text = "Valorizzare almeno uno dei seguenti filtri: Cognome, Codice fiscale, Anno di nascita, IdSac, Provenienza e IdProvenienza"
                    LabelError.Visible = True
                    '    FilterHelper.Clear(pannelloFiltri)
                End If

                Cache.Remove(PazientiListaObjectDataSource.CacheKeyDependency)
                PazientiGridView.DataBind()

            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

        Protected Sub PazientiListaObjectDataSource_Selecting(ByVal sender As Object, ByVal e As ObjectDataSourceSelectingEventArgs) Handles PazientiListaObjectDataSource.Selecting
            Try
                ' Non eseguo la ricerca se non è stato specificato un criterio di ricerca            
                If Not IsSearchValid() Then
                    e.Cancel = True
                    If IsPostBack Then
                        LabelError.Text = "Valorizzare almeno uno dei seguenti filtri: Cognome, Codice fiscale, Anno di nascita, IdSac, Provenienza e IdProvenienza"
                        LabelError.Visible = True
                    End If
                    Return
                End If
                LabelError.Visible = False
                If Me.ProvenienzaDropDownList.SelectedValue.Length = 0 Then
                    e.InputParameters("Provenienza") = Nothing
                End If
                If OccultatoRadioButtonList.SelectedValue.Length = 0 Then
                    e.InputParameters("Occultato") = Nothing
                Else
                    e.InputParameters("Occultato") = CType(OccultatoRadioButtonList.SelectedValue, Boolean)
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

        Protected Sub PazientiListaObjectDataSource_Selected(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles PazientiListaObjectDataSource.Selected
            Try
                If e.Exception IsNot Nothing Then
                    ExceptionsManager.TraceException(e.Exception)
                    LabelError.Visible = True
                    LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
                    e.ExceptionHandled = True
                Else
                    FilterHelper.SaveInSession(pannelloFiltri, _className)
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

        Protected Function IsSearchValid() As Boolean

            Return CognomeTextBox.Text.Length > 0 OrElse
                   CodiceFiscaleTextBox.Text.Length > 0 OrElse
                   IdSacTextBox.Text.Length > 0 OrElse
                   AnnoNascitaTextBox.Text.Length > 0 OrElse
                   (ProvenienzaDropDownList.SelectedValue.Length > 0 AndAlso IdEsternoTextBox.Text.Length > 0)

        End Function

#Region "Config DataGrid"

        Protected Sub LoadGridViewPagingAndSorting()
            PazientiGridView.Sort(SortExpression, SortDirection)
            PazientiGridView.PageIndex = PageIndex
        End Sub

        Protected Sub gvPazienti_PageIndexChanged(ByVal sender As Object, ByVal e As EventArgs) Handles PazientiGridView.PageIndexChanged
            Try
                PageIndex = PazientiGridView.PageIndex
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

        Protected Sub gvPazienti_Sorted(ByVal sender As Object, ByVal e As EventArgs) Handles PazientiGridView.Sorted
            Try
                SortExpression = PazientiGridView.SortExpression
                SortDirection = PazientiGridView.SortDirection
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

        Private Property PageIndex() As Integer
            Get
                Dim index As Object = ViewState("gvPazientiPageIndex")
                If index Is Nothing Then Return 0 Else Return DirectCast(index, Integer)
            End Get
            Set(ByVal value As Integer)
                ViewState("gvPazientiPageIndex") = value
            End Set
        End Property

        Private Property SortExpression() As String
            Get
                Dim expression As Object = ViewState("gvPazientiSortExpression")
                If expression Is Nothing Then Return String.Empty Else Return expression.ToString()
            End Get
            Set(ByVal value As String)
                ViewState("gvPazientiSortExpression") = value
            End Set
        End Property

        Private Property SortDirection() As SortDirection
            Get
                Dim direction As Object = ViewState("gvPazientiSortDirection")
                If direction Is Nothing Then Return Nothing Else Return DirectCast(direction, SortDirection)
            End Get
            Set(ByVal value As SortDirection)
                ViewState("gvPazientiSortDirection") = value
            End Set
        End Property
#End Region

        Protected Sub PazientiGridView_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles PazientiGridView.RowDataBound
            If e.Row.RowType = DataControlRowType.DataRow Then
                Dim stato = DirectCast(e.Row.DataItem("Disattivato"), Byte)
                Select Case stato
                    Case 0 'Attivo
                        e.Row.BackColor = Color.FromArgb(192, 240, 192) '#C0F0C0
                    Case 1 'Fuso
                        e.Row.BackColor = Color.FromArgb(252, 192, 192) '#FCC2C2
                    Case Else 'Cancellato
                        e.Row.BackColor = Color.FromArgb(204, 225, 232) '#CCE1E8
                End Select
            End If
        End Sub

        ''' <summary>
        ''' Carica la griglia degli ultimi 5 pazienti visitati
        ''' </summary>
        ''' <remarks></remarks>
        Private Sub CaricaUltimiPazientiVisitati()
            Dim ultimiPazientiTable As PazientiGestioneListaDataTable
            If Session("UltimiPazientiVisitati") Is Nothing Then
                ultimiPazientiTable = New PazientiGestioneListaDataTable()
                Session("UltimiPazientiVisitati") = ultimiPazientiTable
            Else
                ultimiPazientiTable = DirectCast(Session("UltimiPazientiVisitati"), PazientiGestioneListaDataTable)
            End If
            Me.UltimiPazientiVisitatiGridView.DataSource = ultimiPazientiTable
            Me.UltimiPazientiVisitatiGridView.DataBind()
            Me.UltimiPazientiVisitatiLabel.Visible = ultimiPazientiTable.Count > 0
        End Sub

        Protected Shared Function GetCaricaFuseFunction(id As Guid) As String
            Return String.Format("CaricaFuse(this,'{0}'); return false;", id)
        End Function

        Protected Shared Function GetChiudiFuseFunction(id As Guid) As String
            Return String.Format("ChiudiFuse(this,'{0}'); return false;", id)
        End Function

    End Class

End Namespace