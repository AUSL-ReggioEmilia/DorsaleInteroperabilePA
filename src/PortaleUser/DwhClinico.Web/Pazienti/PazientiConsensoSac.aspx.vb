Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
'
' Visualizza la storia dei dati di consenso del paziente memorizzati sul SAC
'
Partial Class Pazienti_PazientiConsensoSac
    Inherits System.Web.UI.Page
    '
    ' Variabili private della classe
    '
    Private mguidIdPaziente As Guid
    Private mbCancelSelectOperation As Boolean = False
    Protected moSacDettaglioPaziente As SacDettaglioPaziente = Nothing 'E' visibile nel'ASPX

    Private Property IdPazienteSAC() As String
        Get
            Return DirectCast(ViewState("IdPazienteSAC"), String)
        End Get
        Set(ByVal value As String)
            ViewState("IdPazienteSAC") = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        '
        ' Aggiungo lo script per lo stylesheet
        '
        'PageAddCss(Me)
        Try
            '
            ' Leggo sempre parametri dal QueryString
            '
            mguidIdPaziente = New Guid(Request.QueryString(PAR_ID_PAZIENTE))
            If Not IsPostBack Then
                divPaziente.Visible = True
                '
                ' Aggiorno la barra di navigazione
                '
                'BarraNavigazione.SetCurrentItem("Dati Consenso", "")

                '
                ' Leggo i dati del paziente
                ' 
                moSacDettaglioPaziente = SacDettaglioPaziente.Session()
                If moSacDettaglioPaziente Is Nothing Then
                    Dim oPazienteSac As New PazienteSac
                    moSacDettaglioPaziente = oPazienteSac.GetData(mguidIdPaziente.ToString)
                    SacDettaglioPaziente.Session() = moSacDettaglioPaziente
                End If
                If moSacDettaglioPaziente Is Nothing Then
                    '
                    ' Allora il paziente non è stato trovato
                    ' Blocco esecuzione della select dell'object data source
                    '
                    mbCancelSelectOperation = True
                    lblErrorMessage.Text = "Impossibile visualizzare i consensi per il paziente selezionato!"
                    alertErrorMessage.Visible = True
                    divPaziente.Visible = False
                    IdPazienteSAC = Nothing
                    Exit Sub
                End If
                '
                ' Bind dei dati paziente
                '
                divPaziente.DataBind()

                IdPazienteSAC = moSacDettaglioPaziente.IdPaziente.ToString
                '
                ' Invalido la cache
                '
                HttpContext.Current.Cache("CKD_ConsensiSACDataSource") = New Object
                '
                ' Passo il valore del parametro all'object data source
                '
                ConsensiSACDataSource.SelectParameters("sIdPazienteSAC").DefaultValue = IdPazienteSAC
            Else
                '
                ' Non faccio niente, l'IdPaziente è già stato memorizzato nella property IdPazienteSAC
                ' I dati del paziente sono già stati scritti nei controlli all'interno di divPaziente
                '
            End If

            '
            'RENDERING PER BOOTSTRAP
            'Converte i tag html generati dalla GridView per la paginazione
            ' e li adatta alle necessita dei CSS Bootstrap
            '
            GridViewConsensiSAC.PagerStyle.CssClass = "pagination-gridview"
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)

        Catch ex As Exception
            lblErrorMessage.Text = "Errore durante il caricamento della pagina."
            alertErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Protected Function GetColConsenso(ByVal oStato As Object) As String
        '
        ' Ritorna l'HTML per disegnare la colonna del Consenso
        '
        Dim strHtml As String
        Dim bStato As Integer = CType(oStato, Boolean)

        If bStato Then
            strHtml = "<img src='" & Me.ResolveUrl("~/images/flag_yes.gif") & "' alt='Consenso accordato' border=0>"
        Else
            strHtml = "<img src='" & Me.ResolveUrl("~/images/flag_no.gif'") & "' alt='Consenso negato' border=0>"
        End If

        Return strHtml

    End Function

    Protected Sub cmdAnnulla_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdAnnulla.Click
        Dim sUrl As String
        Try
            sUrl = String.Format("~/Pazienti/PazientiConsenso.aspx?{0}={1}", PAR_ID_PAZIENTE, mguidIdPaziente.ToString)
            Response.Redirect(sUrl)
        Catch ex As Threading.ThreadAbortException
            'Non faccio niente
        Catch ex As Exception
            lblErrorMessage.Text = "Errore durante esecuzione pulsante 'Annulla'."
            alertErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Protected Sub ConsensiSACDataSource_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles ConsensiSACDataSource.Selected
        Try
            If e.Exception IsNot Nothing Then
                '
                ' Errore
                '
                Logging.WriteError(e.Exception, Me.GetType.Name)
                If Utility.IsTimeOutError(e.Exception) Then
                    Dim sMsgErr As String = "<br />Il sistema è impegnato, le chiediamo di riprovare.<br />"
                    lblNoRecordFound.Text = sMsgErr
                Else
                    lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
                    alertErrorMessage.Visible = True
                End If

                e.ExceptionHandled = True
            ElseIf e.ReturnValue Is Nothing Then
                lblNoRecordFound.Text = "Non ci sono consensi per il paziente!"
                alertErrorMessage.Visible = True
            End If

        Catch ex As Exception
            lblErrorMessage.Text = "Errore durante l'operazione di selezione dei dati!"
            alertErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Protected Sub ConsensiSACDataSource_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles ConsensiSACDataSource.Selecting
        Try
            If mbCancelSelectOperation = True Then
                e.Cancel = True
            End If
        Catch ex As Exception
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            alertErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Protected Function LabelDataDecessoVisible(ByVal oDataDecesso As Object) As Boolean
        ' oDataDecesso viene restituita dalla classe PazienteSac
        'Se non valorizzata è NOTHING
        Return (Not oDataDecesso Is Nothing)
    End Function

    Private Sub GridViewConsensiSAC_PreRender(sender As Object, e As EventArgs) Handles GridViewConsensiSAC.PreRender
        '
        'Render per Bootstrap
        'Crea la Table con Theader e Tbody se l'header non è nothing.
        '
        If Not GridViewConsensiSAC.HeaderRow Is Nothing Then
            GridViewConsensiSAC.UseAccessibleHeader = True
            GridViewConsensiSAC.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
    End Sub
End Class
