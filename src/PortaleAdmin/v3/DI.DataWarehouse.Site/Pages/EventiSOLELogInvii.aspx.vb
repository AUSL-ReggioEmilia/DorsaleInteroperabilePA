Imports System
Imports System.Data
Imports System.Linq
Imports System.Web
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin.Data

Public Class RicoveriSOLElogInvii
    Inherits System.Web.UI.Page

    Private mPageId As String = Me.GetType().Name
    Const BACKPAGE = "RicoveriLista.aspx"

    Const DONE_CANCELLAZIONE As String = "done1"
    Const DONE_RINOTIFICA As String = "done2"

#Region "Property"
    '
    ' SALVO NEL VIEW STATE L'AZIENDA EROGANTE E IL NUMERO NOSOLOGICO
    '
    Private Property AziendaErogante As String
        Get
            Return ViewState("AziendaErogante")
        End Get
        Set(value As String)
            ViewState("AziendaErogante") = value
        End Set
    End Property

    Private Property NumeroNosologico As String
        Get
            Return ViewState("NumeroNosologico")
        End Get
        Set(value As String)
            ViewState("NumeroNosologico") = value
        End Set
    End Property

    Private Property EventiSoleDataTable As Sole.LogInviiSoleListaPerAziendaNosologicoDataTable
        Get
            Dim sUserName As String = HttpContext.Current.User.Identity.Name.ToUpper
            Dim sKey As String = String.Concat(sUserName, "_LogInviiSoleListaPerAziendaNosologicoDataTable")
            Return CType(HttpContext.Current.Session(sKey), Sole.LogInviiSoleListaPerAziendaNosologicoDataTable)
        End Get
        Set(value As Sole.LogInviiSoleListaPerAziendaNosologicoDataTable)
            Dim sUserName As String = System.Web.HttpContext.Current.User.Identity.Name.ToUpper
            Dim sKey As String = String.Concat(sUserName, "_LogInviiSoleListaPerAziendaNosologicoDataTable")
            HttpContext.Current.Session(sKey) = value
        End Set
    End Property

#End Region


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            '
            'Ottengo AziendaErogante e NumeroNosologico dal QueryString
            '
            Dim sAziendaErogante As String = Request.QueryString("AziendaErogante")
            Dim sNumeroNosologico As String = Request.QueryString("NumeroNosologico")

            '
            'AziendaErogante e NumeroNosologico devono essere valorizzati
            '
            If String.IsNullOrEmpty(sAziendaErogante) OrElse String.IsNullOrEmpty(sNumeroNosologico) Then
                Utility.ShowErrorLabel(LabelError, "Il parametri non sono valorizzati correttamente.")
            Else
                '
                'Salvo nel ViewState i parametri
                '
                AziendaErogante = sAziendaErogante
                NumeroNosologico = sNumeroNosologico


                '
                'Valorizzo il titolo della pagina
                '
                lblTitolo.Text = String.Format("Lista notifiche SOLE del Ricovero {0} - {1}", sAziendaErogante, sNumeroNosologico)
            End If

            'dopo la pressione del pulsante Invio, disabilito il pulsante stesso
            If Request.QueryString(DONE_CANCELLAZIONE) = "1" Then
                DeleteButton.Enabled = False
            End If
            If Request.QueryString(DONE_RINOTIFICA) = "1" Then
                RiprocessaButton.Enabled = False
            End If

        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub GoBack()
        Try
            Response.Redirect(BACKPAGE, False)
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub ObjectDataSource_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsRicoveri.Selected
        Try
            If Not GestioneErrori.ObjectDataSource_TrapError(e, LabelError) Then
                Dim dT As Sole.LogInviiSoleListaPerAziendaNosologicoDataTable = CType(e.ReturnValue, Sole.LogInviiSoleListaPerAziendaNosologicoDataTable)
                If dT Is Nothing OrElse dT.Rows.Count = 0 Then
                    'Disabilito i pulsanti se non c'è nulla nella lista
                    DeleteButton.Enabled = False
                    RiprocessaButton.Enabled = False
                    txtDallaDataQueue.Enabled = False
                Else
                    '
                    ' Memorizzo in sessione la data table: creo ua copia della data table e la metto in sessione
                    '
                    Dim oNewDt As New Sole.LogInviiSoleListaPerAziendaNosologicoDataTable
                    dT.CopyToDataTable(oNewDt, LoadOption.OverwriteChanges)
                    EventiSoleDataTable = oNewDt
                End If
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub DeleteButton_Click(sender As Object, e As System.EventArgs) Handles DeleteButton.Click
        Try
            Dim iRetValue As Integer = -1

            Using taNotifica As New SoleTableAdapters.EventiNotificaCancellazioneTableAdapter
                Dim dtNotifica As New Sole.EventiNotificaCancellazioneDataTable
                taNotifica.Fill(dtNotifica, Me.AziendaErogante, Me.NumeroNosologico)
                Dim oRet = taNotifica.Adapter.SelectCommand.Parameters("@RETURN_VALUE").Value
                If TypeOf oRet Is Integer Then
                    iRetValue = oRet
                End If
            End Using

            If iRetValue <> 0 Then
                Utility.ShowErrorLabel(LabelError, String.Format("La procedura di cancellazione ha restituito il codice d'errore {0}. Contattare un amministratore.", iRetValue))
                DeleteButton.Enabled = False
                gvMain.DataBind()
            Else
                'ricarico la pagina aggiungendo done=1, questo evita il doppio postback se l'utente preme F5
                Dim sUrl As String = Me.ModifyQueryStringParameter(DONE_CANCELLAZIONE, "1")
                Dim functionJS As String = "alert('La notifica di cancellazione del ricovero è stata eseguita.');"
                functionJS = functionJS & "window.location='" & sUrl & "';"
                ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide2", functionJS, True)

            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub


    Private Class ErroreProcessamento
        Public IdEvento As Guid
        Public CodiceErrore As Integer
    End Class
    Private Sub RiprocessaButton_Click(sender As Object, e As System.EventArgs) Handles RiprocessaButton.Click
        Dim dDallaData As DateTime
        Dim listRetValue As New System.Collections.Generic.Dictionary(Of Integer, ErroreProcessamento)
        Try
            'TODO: rimuovere l'adapter BevsRicoveroNotificaEventiSole e relativa stored procedure
            'Using taNotifica As New RicoveriDataSetTableAdapters.QueriesTableAdapter
            '    taNotifica.BevsRicoveroNotificaEventiSole(Me.AziendaErogante, Me.NumeroNosologico)
            'End Using

            '
            ' Riprocesso tutti gli eventi a partire dalla dataqueue impostata in txtDallaDataQueue
            '
            If String.IsNullOrEmpty(txtDallaDataQueue.Text) Then
                'messaggio di errore
                Throw New ApplicationException("Il campo 'Dalla Data' è obblicatorio.")
            Else
                'Verifico che sia una data
                If Not Date.TryParse(txtDallaDataQueue.Text, dDallaData) Then
                    Throw New ApplicationException("Il campo 'Dalla Data' non è una data valida.")
                End If
            End If
            If EventiSoleDataTable Is Nothing OrElse EventiSoleDataTable.Rows.Count = 0 Then
                Throw New ApplicationException("La sessione è scaduta. Ricaricare la pagina.")
            End If
            '
            ' Se sono qui dDallaData è stato valorizzato
            ' La property EventiSoleDataTable contiene in sessione la lista degli eventi visualizzati nella grid
            ' Ricavo gli eventi da riprocessare tramite query linkq e li riprocesso nello stesso ordine
            '
            If Not EventiSoleDataTable Is Nothing AndAlso EventiSoleDataTable.Rows.Count > 0 Then
                Dim oCollection As Collections.Generic.IEnumerable(Of Sole.LogInviiSoleListaPerAziendaNosologicoRow) = (From c In EventiSoleDataTable Where c.DataQueue >= dDallaData Order By c.DataQueue Ascending).ToList
                Dim iCounter As Integer = 0
                For Each oItem As Sole.LogInviiSoleListaPerAziendaNosologicoRow In oCollection
                    iCounter = iCounter + 1
                    Using ta As New SoleTableAdapters.EventiRiprocessaPerIdEventoTableAdapter
                        Dim dt As New Sole.EventiRiprocessaPerIdEventoDataTable
                        ta.FillByIdEvento(dt, oItem.IdEvento, "DWH-ADMIN: riprocessa evento")
                        Dim oRet As Object = ta.Adapter.SelectCommand.Parameters("@RETURN_VALUE").Value
                        If TypeOf oRet Is Integer Then
                            Dim iCodiceErrore As Integer = CType(oRet, Integer)
                            If iCodiceErrore <> 0 Then
                                Dim oErr As New ErroreProcessamento
                                oErr.IdEvento = oItem.IdEvento
                                oErr.CodiceErrore = CType(oRet, Integer)
                                listRetValue.Add(iCounter, oErr)
                            End If
                        End If
                    End Using
                Next
            End If
            '
            ' Cerco in listRetValue se ci sono dei valori restituiti <> da zero
            ' Cerco il primo codice di errore
            '
            Dim iPrimoCodiceErrore As Integer = 0
            Dim iCountErrori As Integer = 0
            Dim sErrMsg1 As String = String.Empty
            For Each iKey As Integer In listRetValue.Keys
                Dim oErr As ErroreProcessamento = listRetValue(iKey)
                If oErr.CodiceErrore <> 0 Then
                    sErrMsg1 = String.Concat(sErrMsg1, String.Format("IdEvento:{0} - CodiceErrore:{1}", oErr.IdEvento, oErr.CodiceErrore), Environment.NewLine)
                    iCountErrori = iCountErrori + 1
                End If
            Next

            ' 
            ' Verifico presenza di errori
            '
            If Not String.IsNullOrEmpty(sErrMsg1) Then
                '
                ' Rimpiazzo il NewLine con <br/> visto che visualizzo il messaggio di errore in una label
                '
                sErrMsg1 = sErrMsg1.Replace(Environment.NewLine, "<br/>")
                Dim sErrMsg As String = String.Format("La procedura peer alcuni eventi ha restituito un codice di erroe.<br/>")
                sErrMsg = String.Concat(sErrMsg, sErrMsg1) 'non aggiungo ulteriore "<br/>"
                sErrMsg = String.Concat(sErrMsg, "Uno o più eventi potrebbero non essere più presente sul DWH oppure non essere presenti nella coda.<br/>")
                sErrMsg = String.Concat(sErrMsg, "Contattare un amministratore.")
                Utility.ShowErrorLabel(LabelError, sErrMsg)
                RiprocessaButton.Enabled = False
                gvMain.DataBind()
            Else
                '
                ' Mostro ALERT e ricarico la pagina
                ' Ricarico la pagina aggiungendo DONE_RINOTIFICA=1, questo evita il doppio postback se l'utente preme F5
                '
                Dim sUrl As String = Me.ModifyQueryStringParameter(DONE_RINOTIFICA, "1")
                Dim functionJS As String = "alert('Il riprocessamento degli eventi è stato eseguito.');"
                functionJS = functionJS & "window.location='" & sUrl & "';"
                ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide2", functionJS, True)
            End If

        Catch ex As ApplicationException
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)

        Catch ex As Exception
            RiprocessaButton.Enabled = False
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)

        End Try
    End Sub

End Class