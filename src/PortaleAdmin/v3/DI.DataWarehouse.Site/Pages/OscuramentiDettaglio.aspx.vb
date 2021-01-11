Imports System
Imports System.Web.UI.WebControls
Imports System.Web.UI.HtmlControls
Imports System.Web.UI
Imports System.Collections.Generic
Imports System.Drawing
Imports System.Collections.Specialized
Imports System.Data.SqlClient

Public Class OscuramentiDettaglio
    Inherits System.Web.UI.Page

#Region "PROPERTY E VARIABILI DI PAGINA"
    Public Property IdOscuramento() As String
        Get
            Return Me.ViewState("IdOscuramento")
        End Get
        Set(ByVal value As String)
            Me.ViewState.Add("IdOscuramento", value)
        End Set
    End Property

    ''' <summary>
    ''' SALVA NEL VIEW STATE L'OSCURAMENTO CORRENTE.
    ''' </summary>
    ''' <returns></returns>
    Public Property SelectedOscuramento() As OscuramentiDataSet.OscuramentiDataTable
        Get
            Return Me.ViewState("SelectedOscuramento")
        End Get
        Set(ByVal value As OscuramentiDataSet.OscuramentiDataTable)
            Me.ViewState("SelectedOscuramento") = value
        End Set
    End Property

    Private Const BACKPAGE As String = "OscuramentiLista.aspx"
    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
    Private mbErroreSalvataggio As Boolean = False
    Private cColoreTexboxDisabled As Color = ColorTranslator.FromHtml("#E5E5E5")

#End Region

    ''' <summary>
    ''' OTTIENE IL TIPO DI OSCURAMENTO IN BASE ALLA CHECLBOX SELEZIONATA.
    ''' </summary>
    ''' <returns></returns>
    Private Function GetTipoOscuramentoScelto() As Byte
        If opt0.Checked Then Return 0
        If opt1.Checked Then Return 1
        If opt2.Checked Then Return 2
        If opt3.Checked Then Return 3
        If opt4.Checked Then Return 4
        If opt5.Checked Then Return 5
        If opt6.Checked Then Return 6
        If opt7.Checked Then Return 7
        If opt8.Checked Then Return 8
        If opt9.Checked Then Return 9
        If opt10.Checked Then Return 10
        Return 1 'default
    End Function

    Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
        Try
            '
            ' COME ULTIMA COSA CARICO IL RECORD DALLA TAB. OSCURAMENTI
            '
            If Not Page.IsPostBack Then
                If Request.QueryString("Id") = "" Then
                    lblTitolo.Text = "Inserimento Nuovo Oscuramento"
                    chkApplicaDWH.Checked = True
                    chkApplicaSole.Checked = True
                    butElimina.Visible = False
                    'butEliminaTop.Visible = False
                    opt1.Checked = True
                    optTipoOscuramento_CheckedChanged(opt1, Nothing)
                Else
                    Me.IdOscuramento = Request.QueryString("Id")
                    odsDettaglio.Select()
                End If
            End If

            Page.Form.DefaultButton = butSalva.UniqueID
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    ''' <summary>
    ''' CICLA TUTTE LE RIGHE DELLA TABELLA E SELEZIONA LA RIGA CORRETTA IN BASE ALLA CHECKBOX SELEZIONATA
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    Protected Sub optTipoOscuramento_CheckedChanged(sender As Object, e As EventArgs) Handles opt1.CheckedChanged, opt2.CheckedChanged, opt3.CheckedChanged, opt4.CheckedChanged, opt5.CheckedChanged, opt6.CheckedChanged, opt7.CheckedChanged, opt8.CheckedChanged, opt9.CheckedChanged, opt10.CheckedChanged
        Try
            'OTTENTO L'ID DEL RADIO BUTTON SELEZIONATO (es. opt10)
            Dim sIDRiga As String = CType(sender, RadioButton).ID
            'OTTENGO L'ID DELLA RIGA COMPONENDO "RIGA" + IL NUMERO DEL RADIO BUTTON
            sIDRiga = "riga" & sIDRiga.Substring(3) '-> TOLGO I PRIMI 3 CARATTERI DALL'ID DEL RADIO BUTTON ("opt") 

            'Ciclo su tutti i TD della table_dettagli
            Dim list_TD As New ControlFinder(Of HtmlTableCell)
            list_TD.FindChildren(table_dettagli)
            For Each oTD In list_TD
                'seleziono le sole righe con ID="rigaX"
                If oTD.Parent.ID IsNot Nothing AndAlso oTD.Parent.ID.StartsWith("riga") Then
                    'seleziono le celle con i controlli dentro (non quelle con gli option)
                    If oTD.ID Is Nothing Then
                        Dim bEnabled As Boolean = oTD.Parent.ID = sIDRiga
                        oTD.Disabled = Not bEnabled
                        For Each oCtl In oTD.Controls
                            If TypeOf oCtl Is TextBox Then
                                oCtl.BackColor = If(bEnabled, Color.White, cColoreTexboxDisabled)
                                oCtl.Text = ""
                                oCtl.Enabled = bEnabled
                            ElseIf TypeOf oCtl Is DropDownList Then
                                oCtl.SelectedValue = Nothing
                            End If
                        Next
                    Else 'TD con dentro un option
                        If sender Is opt0 Then
                            oTD.Disabled = True
                        End If
                    End If
                End If
            Next

            'CASO SPECIALE TIPO 0 = OSCURAMENTO DI SISTEMA NON MODIFICABILE
            If sender Is opt0 Then
                txtTitolo.Enabled = False
                txtNote.Enabled = False
                butElimina.Enabled = False
                'butEliminaTop.Enabled = False
                butSalva.Enabled = False
                'butSalvaTop.Enabled = False
                chkApplicaDWH.Enabled = False
                chkApplicaSole.Enabled = False
            End If

            If My.Settings.OscPuntuali_RinotificaSole Then
                'PER GLI OSCURMAENTI PUNTUALI MOSTRO IL PULSANTE "AVANTI" PER VISUALIZZARE LA LISTA DEI REFERTI E DEGLI EPISODI DA VISUALIZZARE.
                Select Case GetTipoOscuramentoScelto()
                    Case 1, 3, 4, 5, 9
                        butSalva.Visible = False

                        btnAvanti.Visible = True

                        'visualizzo il wizard 
                        wizard.Visible = True


                        'butSalvaTop.Visible = False
                        'btnAvantiTop.Visible = True
                    Case Else
                        butSalva.Visible = True
                        btnAvanti.Visible = False

                        'nascondo il wizard 
                        wizard.Visible = False

                        'butSalvaTop.Visible = True
                        'btnAvantiTop.Visible = False
                End Select
            Else
                btnAvanti.Visible = False
                ' btnAvantiTop.Visible = False
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Function ValidazioneInputParameters(Par As IOrderedDictionary) As Boolean
        Try
            If CType(Par("ApplicaDWH"), Boolean) = False And CType(Par("ApplicaSole"), Boolean) = False Then
                Utility.ShowErrorLabel(LabelError, "Occorre specificare l'applicabilità dell'oscuramento.")
                Return False
            End If

            Select Case GetTipoOscuramentoScelto()
                Case 0 'non salvabile
                    Return False

                Case 1
                    If Par("AziendaErogante").Length = 0 Or Par("NumeroNosologico").Length = 0 Then
                        Utility.ShowErrorLabel(LabelError, "Occorre specificare Numero Nosologico e Azienda Erogante.")
                        Return False
                    End If

                Case 2
                    If Par("RepartoRichiedenteCodice").Length = 0 Then
                        Utility.ShowErrorLabel(LabelError, "Occorre specificare il Codice Reparto Richiedente.")
                        Return False
                    End If

                Case 3
                    If Par("NumeroReferto").Length = 0 Then
                        Utility.ShowErrorLabel(LabelError, "Occorre specificare il Numero Referto.")
                        Return False
                    End If

                Case 4
                    If Par("NumeroPrenotazione").Length = 0 Then
                        Utility.ShowErrorLabel(LabelError, "Occorre specificare il Numero Prenotazione.")
                        Return False
                    End If

                Case 5
                    If Par("IdOrderEntry").Length = 0 Then
                        Utility.ShowErrorLabel(LabelError, "Occorre specificare l'Id Order Entry.")
                        Return False
                    End If

                Case 6
                    If Par("AziendaErogante").Length = 0 Or Par("SistemaErogante").Length = 0 Or Par("RepartoErogante").Length = 0 Then
                        Utility.ShowErrorLabel(LabelError, "Occorre specificare Azienda, Sistema e Reparto eroganti.")
                        Return False
                    End If

                Case 7
                    If Par("RepartoRichiedenteCodice").Length = 0 Then
                        Utility.ShowErrorLabel(LabelError, "Occorre specificare il Codice Reparto Di Ricovero.")
                        Return False
                    End If
                    If Par("SistemaErogante").Length = 0 Then
                        Utility.ShowErrorLabel(LabelError, "Occorre specificare il Sistema Erogante del Ricovero.")
                        Return False
                    End If

                Case 8
                    If Par("Parola").Length = 0 Then
                        Utility.ShowErrorLabel(LabelError, "Occorre specificare il campo Parola per Referto.")
                        Return False
                    End If

                Case 9
                    If Par("IdEsternoReferto").Length = 0 Then
                        Utility.ShowErrorLabel(LabelError, "Occorre specificare il campo Id Esterno Referto.")
                        Return False
                    End If

                Case 10
                    If Par("Parola").Length = 0 Then
                        Utility.ShowErrorLabel(LabelError, "Occorre specificare il campo Parola per Evento/Ricovero.")
                        Return False
                    End If
            End Select

            Return True

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
            Return False
        End Try
    End Function

    Private Function ValidaOscuramentiPuntuali() As Boolean
        Try

            If chkApplicaDWH.Checked = False And chkApplicaSole.Checked = False Then
                Utility.ShowErrorLabel(LabelError, "Occorre specificare l'applicabilità dell'oscuramento.")
                Return False
            End If

            Select Case GetTipoOscuramentoScelto()
                Case 0 'non salvabile
                    Return False

                Case 1
                    If String.IsNullOrEmpty(txt1NumeroNosologico.Text) Or String.IsNullOrEmpty(ddl1AziendaErogante.SelectedValue) Then
                        Utility.ShowErrorLabel(LabelError, "Occorre specificare Numero Nosologico e Azienda Erogante.")
                        Return False
                    End If

                Case 3
                    If String.IsNullOrEmpty(txt3NumeroReferto.Text) Then
                        Utility.ShowErrorLabel(LabelError, "Occorre specificare il Numero Referto.")
                        Return False
                    End If

                Case 4
                    If String.IsNullOrEmpty(txt4NumeroPrenotazione.Text) Then
                        Utility.ShowErrorLabel(LabelError, "Occorre specificare il Numero Prenotazione.")
                        Return False
                    End If

                Case 5
                    If String.IsNullOrEmpty(txt5IdOrderEntry.Text) Then
                        Utility.ShowErrorLabel(LabelError, "Occorre specificare l'Id Order Entry.")
                        Return False
                    End If

                Case 9
                    If String.IsNullOrEmpty(txt9IdEsterno.Text) Then
                        Utility.ShowErrorLabel(LabelError, "Occorre specificare il campo Id Esterno Referto.")
                        Return False
                    End If
            End Select

            Return True

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
            Return False
        End Try
    End Function

    Protected Sub butSalva_Click(sender As Object, e As EventArgs)
        Try
            'SOLO PER I MASSIVI IMPOSTO SEMPRE LO STATO A "COMPLETATO"
            If String.IsNullOrEmpty(Request.QueryString("Id")) Then
                odsDettaglio.InsertParameters("Stato").DefaultValue = Utility.OscuramentoCompletato
                odsDettaglio.Insert()
            Else
                odsDettaglio.UpdateParameters("Stato").DefaultValue = Utility.OscuramentoCompletato
                odsDettaglio.Update()
            End If


        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Protected Sub butAnnulla_Click(sender As Object, e As EventArgs) Handles butAnnulla.Click ', butAnnullaTop.Click
        Try
            Response.Redirect(BACKPAGE)
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Protected Sub butElimina_Click(sender As Object, e As EventArgs) Handles butElimina.Click ', butEliminaTop.Click
        Try
            odsDettaglio.Delete()
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

#Region "ObjectDataSource"
    Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Selected
        Try
            If Not ObjectDataSource_TrapError(sender, e) Then

                Dim oTable As OscuramentiDataSet.OscuramentiDataTable = e.ReturnValue
                If oTable.Rows.Count <> 1 Then Return

                Dim oRow As OscuramentiDataSet.OscuramentiRow = oTable(0)

                If oRow.IsTipoOscuramentoNull Then
                    oRow.TipoOscuramento = 1
                End If


                lblTitolo.Text = "Dettaglio Oscuramento Codice " & oRow.CodiceOscuramento.ToString

                If oRow.Stato.ToUpper = Utility.OscuramentoInserito.ToUpper Then
                    lblSubTitle.Visible = True
                    lblSubTitle2.Visible = True
                Else
                    lblSubTitle.Visible = False
                    lblSubTitle2.Visible = False
                End If


                txtTitolo.Text = If(oRow.IsTitoloNull, "", oRow.Titolo)
                txtNote.Text = If(oRow.IsNoteNull, "", oRow.Note)
                chkApplicaDWH.Checked = oRow.ApplicaDWH
                chkApplicaSole.Checked = oRow.ApplicaSole

                Select Case oRow.TipoOscuramento
                    Case 0
                        opt0.Checked = True
                        optTipoOscuramento_CheckedChanged(opt0, Nothing)

                    Case 1
                        opt1.Checked = True
                        optTipoOscuramento_CheckedChanged(opt1, Nothing)
                        If Not oRow.IsAziendaEroganteNull Then DropDownList_TrySelectValue(ddl1AziendaErogante, oRow.AziendaErogante)
                        txt1NumeroNosologico.Text = If(oRow.IsNumeroNosologicoNull, "", oRow.NumeroNosologico)

                    Case 2
                        opt2.Checked = True
                        optTipoOscuramento_CheckedChanged(opt2, Nothing)
                        txt2RepartoRichiedenteCodice.Text = If(oRow.IsRepartoRichiedenteCodiceNull, "", oRow.RepartoRichiedenteCodice)
                        If Not oRow.IsSistemaEroganteNull Then DropDownList_TrySelectValue(txt2SistemaErogante, oRow.SistemaErogante)
                        If Not oRow.IsAziendaEroganteNull Then DropDownList_TrySelectValue(txt2AziendaErogante, oRow.AziendaErogante)

                    Case 3
                        opt3.Checked = True
                        optTipoOscuramento_CheckedChanged(opt3, Nothing)
                        txt3NumeroReferto.Text = If(oRow.IsNumeroRefertoNull, "", oRow.NumeroReferto)
                        If Not oRow.IsSistemaEroganteNull Then DropDownList_TrySelectValue(txt3SistemaErogante, oRow.SistemaErogante)
                        If Not oRow.IsAziendaEroganteNull Then DropDownList_TrySelectValue(txt3AziendaErogante, oRow.AziendaErogante)

                    Case 4
                        opt4.Checked = True
                        optTipoOscuramento_CheckedChanged(opt4, Nothing)
                        txt4NumeroPrenotazione.Text = If(oRow.IsNumeroPrenotazioneNull, "", oRow.NumeroPrenotazione)
                        If Not oRow.IsSistemaEroganteNull Then DropDownList_TrySelectValue(txt4SistemaErogante, oRow.SistemaErogante)
                        If Not oRow.IsAziendaEroganteNull Then DropDownList_TrySelectValue(txt4AziendaErogante, oRow.AziendaErogante)

                    Case 5
                        opt5.Checked = True
                        optTipoOscuramento_CheckedChanged(opt5, Nothing)
                        txt5IdOrderEntry.Text = If(oRow.IsIdOrderEntryNull, "", oRow.IdOrderEntry)
                        If Not oRow.IsSistemaEroganteNull Then DropDownList_TrySelectValue(txt5SistemaErogante, oRow.SistemaErogante)
                        If Not oRow.IsAziendaEroganteNull Then DropDownList_TrySelectValue(txt5AziendaErogante, oRow.AziendaErogante)

                    Case 6
                        opt6.Checked = True
                        optTipoOscuramento_CheckedChanged(opt6, Nothing)
                        txt6Repartoerogante.Text = If(oRow.IsRepartoEroganteNull, "", oRow.RepartoErogante)
                        If Not oRow.IsSistemaEroganteNull Then DropDownList_TrySelectValue(txt6SistemaErogante, oRow.SistemaErogante)
                        If Not oRow.IsAziendaEroganteNull Then DropDownList_TrySelectValue(txt6AziendaErogante, oRow.AziendaErogante)

                    Case 7
                        opt7.Checked = True
                        optTipoOscuramento_CheckedChanged(opt7, Nothing)
                        txt7RepartoRichiedenteCodice.Text = If(oRow.IsRepartoRichiedenteCodiceNull, "", oRow.RepartoRichiedenteCodice)
                        If Not oRow.IsSistemaEroganteNull Then DropDownList_TrySelectValue(ddl7SistemaErogante, oRow.SistemaErogante)
                        If Not oRow.IsAziendaEroganteNull Then DropDownList_TrySelectValue(ddl7AziendaErogante, oRow.AziendaErogante)

                    Case 8
                        opt8.Checked = True
                        optTipoOscuramento_CheckedChanged(opt8, Nothing)
                        txt8Parola.Text = If(oRow.IsParolaNull, "", oRow.Parola)

                    Case 9
                        opt9.Checked = True
                        optTipoOscuramento_CheckedChanged(opt9, Nothing)
                        txt9IdEsterno.Text = If(oRow.IsIdEsternoRefertoNull, "", oRow.IdEsternoReferto)


                    Case 10
                        opt10.Checked = True
                        optTipoOscuramento_CheckedChanged(opt10, Nothing)
                        txt10Parola.Text = If(oRow.IsParolaNull, "", oRow.Parola)

                End Select

                Me.SelectedOscuramento = oTable
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub odsDettaglio_PrimaDiSalvare(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceMethodEventArgs) Handles odsDettaglio.Inserting, odsDettaglio.Updating
        'VALORIZZO I PARAMETRI DELL'OBJECTDATASOURCE.
        SetInputParameters(e.InputParameters)
        'VERIFICO SE I FILTRI SONO CORRETTI.
        e.Cancel = Not ValidazioneInputParameters(e.InputParameters)
    End Sub

    Private Sub odsDettaglio_HaSalvato(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Deleted
        If ObjectDataSource_TrapError(sender, e) Then
            mbErroreSalvataggio = True
        Else
            ObjectDataSource_DiscardCache()
            Response.Redirect(BACKPAGE)
        End If
    End Sub

    Private Sub odsDettaglio_Inserted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Inserted
        Try
            If ObjectDataSource_TrapError(sender, e) Then
                mbErroreSalvataggio = True
            Else
                ObjectDataSource_DiscardCache()
                'Me.IdOscuramento = e.OutputParameters("OutputId").ToString

                Response.Redirect(BACKPAGE, False)
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub odsDettaglio_Updated(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Updated
        Try
            If ObjectDataSource_TrapError(sender, e) Then
                mbErroreSalvataggio = True
            Else
                ObjectDataSource_DiscardCache()

                Response.Redirect(BACKPAGE, False)
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub
#End Region

#Region "Funzioni"

    ''' <summary>
    ''' Gestisce gli errori del ObjectDataSource in maniera pulita
    ''' </summary>
    ''' <returns>True se si è verificato un errore</returns>
    Private Function ObjectDataSource_TrapError(ods As ObjectDataSourceView, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) As Boolean
        Try
            If e.Exception IsNot Nothing AndAlso e.Exception.InnerException IsNot Nothing Then
                Utility.ShowErrorLabel(LabelError, GestioneErrori.TrapError(e.Exception.InnerException))
                e.ExceptionHandled = True
                Return True
            Else
                Return False
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
            Return True
        End Try

    End Function

    Private Sub ObjectDataSource_DiscardCache()
        If odsDettaglio.EnableCaching Then
            Cache(msPAGEKEY) = New Object
        End If
    End Sub

    ''' <summary>
    ''' Cerca negli Item Value della DropDownList il valore passato, se lo trova lo seleziona e restituisce True
    ''' </summary>
    Private Function DropDownList_TrySelectValue(DropDown As DropDownList, Value As String)
        Dim lst As ListItem = DropDown.Items.FindByValue(Value)
        If lst Is Nothing Then
            Return False
        Else
            lst.Selected = True
            Return True
        End If
    End Function

    ''' <summary>
    ''' ACCETTA LA LISTA DEI PARAMETRI ACCETTATI DALLE STORED PROCEDURE DI INSERIMENTO E MODIFICA E LI RIEMPIE CON I VALORI CORRETTI.
    ''' </summary>
    ''' <param name="Par"></param>
    ''' <returns></returns>
    Private Function SetInputParameters(Par As IOrderedDictionary) As Boolean
        Try
            Par("TipoOscuramento") = Convert.ToByte(GetTipoOscuramentoScelto())
            Par("Titolo") = txtTitolo.Text
            Par("Note") = txtNote.Text
            Par("Utente") = User.Identity.Name
            Par("ApplicaDWH") = chkApplicaDWH.Checked
            Par("ApplicaSole") = chkApplicaSole.Checked

            Select Case GetTipoOscuramentoScelto()
                Case 1
                    Par("AziendaErogante") = ddl1AziendaErogante.SelectedValue
                    Par("NumeroNosologico") = txt1NumeroNosologico.Text.Trim

                Case 2
                    Par("RepartoRichiedenteCodice") = txt2RepartoRichiedenteCodice.Text.Trim
                    Par("SistemaErogante") = txt2SistemaErogante.SelectedValue
                    Par("AziendaErogante") = txt2AziendaErogante.SelectedValue

                Case 3
                    Par("NumeroReferto") = txt3NumeroReferto.Text.Trim
                    Par("SistemaErogante") = txt3SistemaErogante.SelectedValue
                    Par("AziendaErogante") = txt3AziendaErogante.SelectedValue

                Case 4
                    Par("NumeroPrenotazione") = txt4NumeroPrenotazione.Text.Trim
                    Par("SistemaErogante") = txt4SistemaErogante.SelectedValue
                    Par("AziendaErogante") = txt4AziendaErogante.SelectedValue

                Case 5
                    Par("IdOrderEntry") = txt5IdOrderEntry.Text.Trim
                    Par("SistemaErogante") = txt5SistemaErogante.SelectedValue
                    Par("AziendaErogante") = txt5AziendaErogante.SelectedValue

                Case 6
                    Par("SistemaErogante") = txt6SistemaErogante.SelectedValue
                    Par("AziendaErogante") = txt6AziendaErogante.SelectedValue
                    Par("RepartoErogante") = txt6Repartoerogante.Text.Trim
                    Par("StrutturaEroganteCodice") = txt6StrutturaEroganteCodice.Text.Trim

                Case 7
                    Par("RepartoRichiedenteCodice") = txt7RepartoRichiedenteCodice.Text.Trim
                    Par("SistemaErogante") = ddl7SistemaErogante.SelectedValue
                    Par("AziendaErogante") = ddl7AziendaErogante.SelectedValue

                Case 8
                    Par("Parola") = txt8Parola.Text.Trim

                Case 9
                    Par("IdEsternoReferto") = txt9IdEsterno.Text.Trim

                Case 10
                    Par("Parola") = txt10Parola.Text.Trim

            End Select

            Return True

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
            Return False
        End Try
    End Function

#End Region

#Region "GESTIONE OSCURAMENTI PUNTUALI"
    ''' <summary>
    ''' IL PULSANTE btnAvanti E' VISIBILE SOLO NEL CASO IN CUI SI STA MODIFICANDO O CREANDO UN OSCURAMENTO PUNTUALE.
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    Private Sub btnAvanti_Click(sender As Object, e As EventArgs) Handles btnAvanti.Click ', btnAvantiTop.Click
        Try
            'VALIDO I CAMPI DELL'OSCURAMENTO.
            If ValidaOscuramentiPuntuali() Then
                '
                'VERIFICO SE SONO IN INSERIMENTO O MODIFICA.
                '
                If String.IsNullOrEmpty(Me.IdOscuramento) Then  'SE ME.IdOscuramento = NOTHING ALLORA SONO IN INSERIMENTO.
                    'DEFINISCO UNA VARIABILE IN CUI INSERIRO' L'ID DELL'OSCURAMENTO CHE VERRA' CREATO.
                    Dim outputId As Nullable(Of Guid) = Nothing

                    Using ta As New OscuramentiDataSetTableAdapters.OscuramentiTableAdapter
                        'CREO UN ORDERED DICTIONARY CONTENENTE IL NOME E IL VALORE DEI PARAMETRI DA PASSARE ALLA INSERT.
                        Dim oParametersDictionary As New OrderedDictionary
                        For Each oCurrentParameter As WebControls.Parameter In odsDettaglio.InsertParameters
                            oParametersDictionary.Add(oCurrentParameter.Name, oCurrentParameter.DefaultValue)
                        Next

                        'VALORIZZO I DEFAULT VALUE DEI PARAMETRI DENTRO DICTIONARY.
                        SetInputParameters(oParametersDictionary)

                        'SALVO IL NUOVO OSCURAMENTO E OTTENGO L'ID.
                        outputId = InsertOscuramentoPuntuale(oParametersDictionary, Nothing)
                    End Using

                    'ESEGUO UN REDIRECT ALLA PAGINA DI RINOTIFICA PASSANDO L'ID DEL NUOVO OSCURAMENTO.
                    Response.Redirect(String.Format("~/Pages/OscuramentiRinotifica.aspx?Id={0}", outputId.ToString), False)
                Else 'SONO IN MODIFICA

                    Dim sStato As String = Nothing 'INDICA LO STATO DELL'OSCURAMENTO(INSERITO,COMPLETATO)
                    Dim bFiltriOscuramentoModificati As Boolean = False 'INDICA SE SONO STATI MODIFICATI I FILTRI DELL'OSCURAMENTO
                    Dim idCorrelazioneOscuramentoPrecedente As Nullable(Of Guid) = Nothing 'INDICA L'ID DEL OSCURAMENTO PADRE.

                    If Not Me.SelectedOscuramento Is Nothing Then
                        'OTTENGO L'OSCURAMENTO CORRENTE DAL VIEW STATE.
                        Dim oRow As OscuramentiDataSet.OscuramentiRow = CType(Me.SelectedOscuramento(0), OscuramentiDataSet.OscuramentiRow)

                        'OTTENGO LO STATO.
                        sStato = oRow.Stato

                        'OTTENGO L'ID DI CORRELAZIONE.
                        If Not oRow.IsIdCorrelazioneNull Then
                            idCorrelazioneOscuramentoPrecedente = oRow.IdCorrelazione
                        End If

                        'SE LO STATO E' INSERITO NON MI PREOCCUPO DI VERIFICARE SE SONO STATI MODIFICATI I FILTRI DELL'OSCURAMENTO.
                        If sStato.ToUpper <> Utility.OscuramentoInserito.ToUpper Then
                            'VERIFICO SE SONO STATI MODIFICATI I PARAMETRI DI FILTRO DELL'OSCURAMENTO.
                            bFiltriOscuramentoModificati = IsFiltriOscuramentoModificati(oRow)
                        End If
                    End If

                    If sStato.ToUpper = Utility.OscuramentoInserito.ToUpper Then
                        'SOLO SE LO STATO E' INSERITO SALVO E NAVIGO ALLA PAGINA DI RINOTIFICA.
                        odsDettaglio.UpdateParameters("Stato").DefaultValue = sStato
                        odsDettaglio.Update()

                        Response.Redirect(String.Format("~/Pages/OscuramentiRinotifica.aspx?Id={0}&IdOld={1}", Me.IdOscuramento, idCorrelazioneOscuramentoPrecedente), False)
                    ElseIf Not bFiltriOscuramentoModificati Then
                        'SE SONO QUI SONO STATI MODIFICATI SOLO I DATI DI TESTATA DELL'OSCURAMENTO, PER CUI NON E' NECESSARIO RINOTIFICARE.

                        odsDettaglio.UpdateParameters("Stato").DefaultValue = sStato
                        odsDettaglio.Update()

                        'Registro uno script lato client per indicare all'utente che le modifiche apportate all'oscuramento non necessitano della rinotifica.
                        ' e che quindi verrà reindirizzato alla pagina di lista
                        Dim functionJS As String = "alert('Le modifiche apportate non richiedono la rinotifica dell\'oscuramento.');"
                        functionJS = functionJS & "window.location='" & "../Pages/OscuramentiLista.aspx" & "';"
                        ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide2", functionJS, True)

                    Else
                        'INDICA L'ID RESTITUITO DALL'INSERIMENTO.
                        Dim outputId As Nullable(Of Guid) = Nothing

                        'SE SONO QUI SIGNIFICA CHE STO MODIFICATO UN OSCURAMENTO "COMPLETATO".
                        'INSERISCO UN NUOVO OSCURAMENTO CON STATO INSERITO E IMPOSTO L'ID DI CORRELAZIONE DEL VECCHIO RECORD.
                        Using ta As New OscuramentiDataSetTableAdapters.OscuramentiTableAdapter
                            Dim oParametersDictionary As New OrderedDictionary
                            For Each oCurrentParameter As WebControls.Parameter In odsDettaglio.InsertParameters
                                oParametersDictionary.Add(oCurrentParameter.Name, oCurrentParameter.DefaultValue)
                            Next

                            SetInputParameters(oParametersDictionary)

                            outputId = InsertOscuramentoPuntuale(oParametersDictionary, New Guid(Me.IdOscuramento))
                        End Using

                        Response.Redirect(String.Format("~/Pages/OscuramentiRinotifica.aspx?Id={0}&IdOld={1}", outputId.ToString, Me.IdOscuramento.ToString), False)
                    End If
                End If
            End If
        Catch ex As Threading.ThreadAbortException
            '
            'non faccio niente
            '
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    ''' <summary>
    ''' VERIFICA SE SONO STATI MODIFICATI I FILTRI DELL'OSCURAMENTO.
    ''' </summary>
    ''' <param name="oRow"></param>
    ''' <returns></returns>
    Private Function IsFiltriOscuramentoModificati(ByVal oRow As OscuramentiDataSet.OscuramentiRow) As Boolean
        Dim bFiltriOscuramentoModificati As Boolean = False

        If oRow.TipoOscuramento <> GetTipoOscuramentoScelto() Then
            bFiltriOscuramentoModificati = True
        Else
            Dim AziendaErogante As String = String.Empty
            If Not oRow.IsAziendaEroganteNull Then
                AziendaErogante = oRow.AziendaErogante
            End If

            Dim SistemaErogante As String = String.Empty
            If Not oRow.IsSistemaEroganteNull Then
                SistemaErogante = oRow.SistemaErogante
            End If

            Dim NumeroNosologico As String = String.Empty
            If Not oRow.IsNumeroNosologicoNull Then
                NumeroNosologico = oRow.NumeroNosologico
            End If

            Dim NumeroReferto As String = String.Empty
            If Not oRow.IsNumeroRefertoNull Then
                NumeroReferto = oRow.NumeroReferto
            End If

            Dim NumeroPrenotazione As String = String.Empty
            If Not oRow.IsNumeroPrenotazioneNull Then
                NumeroPrenotazione = oRow.NumeroPrenotazione
            End If

            Dim IdOrderEntry As String = String.Empty
            If Not oRow.IsIdOrderEntryNull Then
                IdOrderEntry = oRow.IdOrderEntry
            End If

            Dim IdEsternoReferto As String = String.Empty
            If Not oRow.IsIdEsternoRefertoNull Then
                IdEsternoReferto = oRow.IdEsternoReferto
            End If

            Select Case GetTipoOscuramentoScelto()
                Case 1 'AZIENDA + NUMERONOSOLOGICO.
                    If ddl1AziendaErogante.SelectedValue <> AziendaErogante OrElse txt1NumeroNosologico.Text <> NumeroNosologico Then
                        bFiltriOscuramentoModificati = True
                    End If
                Case 3 'AZIENDA + SISTEMA + NUMERO REFERTO
                    If txt3AziendaErogante.SelectedValue <> AziendaErogante OrElse txt3SistemaErogante.Text <> SistemaErogante OrElse txt3NumeroReferto.Text <> NumeroReferto Then
                        bFiltriOscuramentoModificati = True
                    End If
                Case 4 'AZIENDA + SISTEMA + NUMERO PRENOTAZIONE
                    If txt4AziendaErogante.SelectedValue <> AziendaErogante OrElse txt4SistemaErogante.Text <> SistemaErogante OrElse txt4NumeroPrenotazione.Text <> NumeroPrenotazione Then
                        bFiltriOscuramentoModificati = True
                    End If
                Case 5 'AZIENDA + SISTEMA + ID ORDER ENTRY
                    If txt5AziendaErogante.SelectedValue <> AziendaErogante OrElse txt5SistemaErogante.Text <> SistemaErogante OrElse txt5IdOrderEntry.Text <> IdOrderEntry Then
                        bFiltriOscuramentoModificati = True
                    End If
                Case 9 'ID ESTERNO REFERTO
                    If txt9IdEsterno.Text <> oRow.IdEsternoReferto Then
                        bFiltriOscuramentoModificati = True
                    End If
            End Select
        End If

        Return bFiltriOscuramentoModificati
    End Function

    ''' <summary>
    ''' ESEGUE L'INSERIMENTO DI UN OSCURAMENTO PUNTUALE QUANDO SI CLICCA IL PULSANTE AVANTI.
    ''' </summary>
    ''' <param name="oParametersDictionary"></param>
    ''' <param name="idOscuramentoModificato"></param>
    ''' <returns></returns>
    Protected Function InsertOscuramentoPuntuale(ByVal oParametersDictionary As OrderedDictionary, ByVal idOscuramentoModificato As Nullable(Of Guid)) As Guid
        Using ta As New OscuramentiDataSetTableAdapters.OscuramentiTableAdapter
            Dim outputId As Nullable(Of Guid) = Nothing

            ta.Insert(oParametersDictionary.Item("Titolo"), oParametersDictionary.Item("Note"), oParametersDictionary.Item("AziendaErogante"),
                                      oParametersDictionary.Item("SistemaErogante"), oParametersDictionary.Item("NumeroNosologico"), oParametersDictionary.Item("RepartoRichiedenteCodice"),
                                      oParametersDictionary.Item("NumeroPrenotazione"), oParametersDictionary.Item("NumeroReferto"), oParametersDictionary.Item("IdOrderEntry"),
                                      oParametersDictionary.Item("RepartoErogante"), oParametersDictionary.Item("StrutturaEroganteCodice"),
                                      oParametersDictionary.Item("TipoOscuramento"), oParametersDictionary.Item("Parola"), oParametersDictionary.Item("IdEsternoReferto"),
                                      oParametersDictionary.Item("Utente"), oParametersDictionary.Item("ApplicaDWH"), oParametersDictionary.Item("ApplicaSole"), "Inserito", idOscuramentoModificato, outputId
                                      )

            Return outputId
        End Using

    End Function

#End Region

End Class

''' <summary>
''' Ricerca ricorsiva di controlli di un determinato tipo
''' </summary>
''' <typeparam name="T">Tipo del controllo da cercare</typeparam>
''' <remarks>implementa IEnumerable</remarks>
Public Class ControlFinder(Of T As Control)
    Implements IEnumerable(Of T)

    Private ReadOnly _foundControls As New List(Of T)()

    Public Sub FindChildren(Parent As Control)
        For Each child In Parent.Controls
            If TypeOf child Is T Then
                _foundControls.Add(child)
            Else
                FindChildren(child)
            End If
        Next
    End Sub

    Public Function GetEnumerator() As System.Collections.Generic.IEnumerator(Of T) Implements System.Collections.Generic.IEnumerable(Of T).GetEnumerator
        Return _foundControls.GetEnumerator
    End Function

    Public Function GetEnumerator1() As System.Collections.IEnumerator Implements System.Collections.IEnumerable.GetEnumerator
        Return _foundControls.GetEnumerator
    End Function
End Class
