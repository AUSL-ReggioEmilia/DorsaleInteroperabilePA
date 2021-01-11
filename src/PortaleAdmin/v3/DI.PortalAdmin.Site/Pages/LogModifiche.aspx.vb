Imports System
Imports System.IO
Imports System.Text
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Xml
Imports DI.Common

Public Class LogModifiche1
    Inherits System.Web.UI.Page
    'ID DELLA PAGINA PER SALVARE I DATI IN SESSIONE.
    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
    'VARIABILE PER SALVARE IN SESSIONE SE HO CLICCATO IL PULSANTE CERCA.
    Dim bCercaClicked As Boolean = False

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            'SOLO LA PRIMA VOLTA.
            If Not Page.IsPostBack Then
                'ESEGUO IL RESTORE DEI FILTRI PRENDENDOLI DALLA SESSIONE.
                FilterHelper.Restore(panelFiltri, msPAGEKEY)
                'RECUPERO IL VALORE DI bCercaClicked DALLA SESSIONE. IN QUESTO MODO QUANDO RITORNO SU QUESTA PAGINA SE bCercaClicked = TRUE ESEGUO LA RICERCA.
                bCercaClicked = Me.Session(String.Format("{0}_btnCercaClicked", msPAGEKEY))
            End If

            '
            ' RENDERING PER BOOTSTRAP
            ' Converte i tag html generati dalla GridView per la paginazione
            ' e li adatta alle necessita dei CSS Bootstrap
            '
            gvListaLogModifiche.PagerStyle.CssClass = "pagination-gridview"
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)
        Catch ex As Exception
            alertError.Visible = True
            alertError.InnerText = GestioneErrori.TrapError(ex)
        End Try
    End Sub

    Private Sub ddlDatabaseNomi_PreRender(sender As Object, e As EventArgs) Handles ddlDatabaseNomi.PreRender
        Try
            'INSERISCO UN ITEM VUOTO NELLA DROP DOWN DEI DATABASE
            If ddlDatabaseNomi.Items.FindByValue("-1") Is Nothing Then
                Dim nullItems As New ListItem("", "-1")
                ddlDatabaseNomi.Items.Insert(0, nullItems)
            End If

            'OTTENGO IL SELECTED VALUE DALLA SESSIONE.
            Dim sValoreSessione = Me.Session(String.Format("{0}_ddlNomeDatabase", msPAGEKEY))
            'SE sValoreSessione NON E' NOTHING E NON E' -1 ALORA IMPOSTO IL SELECTED VALUE DELLA COMBO.
            If Not String.IsNullOrEmpty(sValoreSessione) AndAlso sValoreSessione <> "-1" Then
                ddlDatabaseNomi.SelectedValue = sValoreSessione
            End If
        Catch ex As Exception
            alertError.Visible = True
            alertError.InnerText = GestioneErrori.TrapError(ex)
        End Try
    End Sub

    Private Sub ddlDatabaseNomi_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ddlDatabaseNomi.SelectedIndexChanged
        Try
            bCercaClicked = False

            'SALVO IN SESSIONE IL VALORE SELEZIONATO OGNI VOLTA CHE NE SELEZIONO UNO.
            Me.Session.Add(String.Format("{0}_ddlNomeDatabase", msPAGEKEY), ddlDatabaseNomi.SelectedValue)

            'QUANDO SELEZIONO UN DATABASE RICARICO LA DROP DELLE TABELLE.
            ddlTabelleNomi.DataBind()
        Catch ex As Exception
            alertError.Visible = True
            alertError.InnerText = GestioneErrori.TrapError(ex)
        End Try
    End Sub

    Private Sub gvListaLogModifiche_PreRender(sender As Object, e As EventArgs) Handles gvListaLogModifiche.PreRender
        Try
            '
            'RENDER PER BOOTSTRAP
            'CREA LA TABLE CON THEADER E TBODY SE L'HEADER NON È NOTHING.
            '
            If Not gvListaLogModifiche.HeaderRow Is Nothing Then
                gvListaLogModifiche.UseAccessibleHeader = True
                gvListaLogModifiche.HeaderRow.TableSection = TableRowSection.TableHeader
            End If
        Catch ex As Exception
            alertError.Visible = True
            alertError.InnerText = GestioneErrori.TrapError(ex)
        End Try
    End Sub

    Private Sub odsLogModifiche_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsLogModifiche.Selecting
        Try
            'PASSO I PARAMETRI SOLO SE IL BOTTONE CERCA E' STATO PREMUTO E TUTTI I FILTRI SONO VALIDI.
            If bCercaClicked AndAlso ValidaFiltri() Then
                e.InputParameters("DataModificaDal") = CType(txtDataDal.Text, DateTime)
                'SE DATA AL E' VUOTA ALLORA PASSO NOTHING(LA SP IMPOSTA DI DEFAULT LA DATA CORRENTE)
                If String.IsNullOrEmpty(txtDataAl.Text) Then
                    e.InputParameters("DataModificaAl") = Nothing
                Else
                    e.InputParameters("DataModificaAl") = CType(txtDataAl.Text, DateTime)
                End If
                Dim sDatabaseNome As String = Nothing
                If ddlDatabaseNomi.SelectedValue <> "-1" Then
                    sDatabaseNome = ddlDatabaseNomi.SelectedValue
                End If

                Dim sTabellaNome As String = Nothing
                If Not String.IsNullOrEmpty(ddlTabelleNomi.SelectedValue) AndAlso ddlTabelleNomi.SelectedValue <> "-1" Then
                    sTabellaNome = ddlTabelleNomi.SelectedValue
                End If
                e.InputParameters("DatabaseNome") = sDatabaseNome
                e.InputParameters("TabellaNome") = sTabellaNome
                e.InputParameters("MaxNumRow") = ddlTop.SelectedValue
            Else
                e.Cancel = True
            End If
        Catch ex As Exception
            alertError.Visible = True
            alertError.InnerText = GestioneErrori.TrapError(ex)
        End Try
    End Sub

    Private Sub odsTabelleNomi_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsTabelleNomi.Selecting
        Try
            'RICARICO I NOMI DELLE TABELLE IN BASE AL DATABASE SELEZIONATO.
            e.InputParameters("DatabaseNome") = ddlDatabaseNomi.SelectedValue
        Catch ex As Exception
            alertError.Visible = True
            alertError.InnerText = GestioneErrori.TrapError(ex)
        End Try
    End Sub

    Private Function ValidaFiltri() As Boolean
        Dim bResult As Boolean = True
        Dim sMessage As String = String.Empty
        Try
            'IL PARAMETRO DATA DAL E' OBBLIGATORIO.
            If String.IsNullOrEmpty(txtDataDal.Text) Then
                sMessage = sMessage + "<br>" + "Il filtro 'Data Dal' è obbligatorio."
                bResult = False
                'TESTO SE DATA DAL E' UNA DATA VALIDA.
            ElseIf Not String.IsNullOrEmpty(txtDataDal.Text) AndAlso Not Utility.IsValidDateTime(txtDataDal.Text) Then
                sMessage = sMessage + "<br>" + "Il filtro 'Data Dal' non è una data valida."
                bResult = False
            End If

            ''IL PARAMETRO DATABASE E' OBBLIGATORIO.
            'If ddlDatabaseNomi.SelectedValue = "-1" Then
            '    sMessage = sMessage + "<br>" + "Il filtro 'Database Name' è obbligatorio."
            '    bResult = False
            'Else
            '    'SE HO SELEZIONATO UN DATABASE ALLORA DEVO SELEZIONARE ANCHE UNA TABELLA.
            '    If ddlTabelleNomi.SelectedValue = "-1" Then
            '        sMessage = sMessage + "<br>" + "Selezionare una Tabella."
            '        bResult = False
            '    End If
            'End If

            'IL PARAMETRO DATA AL NON E' OBBLIGATORIO. SE E' VALORIZZATO ALLORA TESTO CHE SIA UNA DATA VALIDA.
            If Not String.IsNullOrEmpty(txtDataAl.Text) AndAlso Not Utility.IsValidDateTime(txtDataAl.Text) Then
                sMessage = sMessage + "<br>" + "Il filtro 'Data Al' non è una data valida."
                bResult = False
            End If

            'SE BRESULT E' FALSE ALLORA MOSTRO L'ALERT CON IL RIEPILOGO DEGLI ERRORI.
            If Not bResult Then
                ShowErrorAlert(sMessage.Remove(0, 4))
            End If
        Catch ex As Exception
            alertError.Visible = True
            alertError.InnerText = GestioneErrori.TrapError(ex)
        End Try
        Return bResult
    End Function

    Private Sub ShowErrorAlert(Text As String)
        Try
            'MOSTRO UN ALERT DI ERRORE CON LA LISTA DEGLI ERRORI DI VALIDAZIONE.
            alertError.Visible = True
            alertError.InnerHtml = Text
        Catch ex As Exception
            alertError.Visible = True
            alertError.InnerText = GestioneErrori.TrapError(ex)
        End Try
    End Sub

    Private Sub btnCerca_Click(sender As Object, e As EventArgs) Handles btnCerca.Click
        Try
            'SALVO IN SESSIONE I FILTRI LATERALI
            FilterHelper.SaveInSession(panelFiltri, msPAGEKEY)

            'SALVO IN SESSIONE IL VALORE DEL SALECTED VALUE DELLA COMBO DELLE TABELLE.
            Me.Session.Add(String.Format("{0}_ddlNomeTabella", msPAGEKEY), ddlTabelleNomi.SelectedValue)
            'SALVO IN SESSIONE QUANDO CLICCO IL PULSANTE CERCA. (PER RIESEGUIRE LA QUERY QUANDO RITORNO SULLA PAGINA)
            Me.Session.Add(String.Format("{0}_btnCercaClicked", msPAGEKEY), True)

            'IMPOSTO CHE HO CLICCATO IL BOTTONE CERCA.
            bCercaClicked = True
            'ESEGUO IL BIND DELLA GRIGLIA.
            gvListaLogModifiche.DataBind()
        Catch ex As Exception
            alertError.Visible = True
            alertError.InnerText = GestioneErrori.TrapError(ex)
        End Try
    End Sub

    Private Sub ddlTabelleNomi_PreRender(sender As Object, e As EventArgs) Handles ddlTabelleNomi.PreRender
        Try
            'SE E' STATO SELEZIONATO UN DATABASE ABILITO LA COMBO DELLE TABELLE E AGGIUNGO UN ITEM VUOTO.
            'SE NON E' STATO ANCORA SELEZIONATO UN DATABASE ALLORA DISABILITO LA COMBO DELLE TABELLE.
            If Not ddlDatabaseNomi.SelectedValue = "-1" Then
                If ddlTabelleNomi.Items.FindByValue("-1") Is Nothing Then
                    Dim nullItem As New ListItem("", "-1")
                    ddlTabelleNomi.Items.Insert(0, nullItem)
                    ddlTabelleNomi.Enabled = True
                End If

                'VALORIZZO IL SELECTED VALUE DELLA COMBO PRENDENDO IL VALORE DALLA SESSIONE.
                Dim sValoreSessione = Me.Session(String.Format("{0}_ddlNomeTabella", msPAGEKEY))
                If Not String.IsNullOrEmpty(sValoreSessione) AndAlso sValoreSessione <> "-1" Then
                    If ddlTabelleNomi.Items.FindByValue(sValoreSessione) IsNot Nothing Then
                        ddlTabelleNomi.SelectedValue = sValoreSessione
                    End If
                End If
            Else
                ddlTabelleNomi.Enabled = False
            End If
        Catch ex As Exception
            alertError.Visible = True
            alertError.InnerText = GestioneErrori.TrapError(ex)
        End Try
    End Sub

    Private Sub gvListaLogModifiche_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvListaLogModifiche.RowCommand
        Try
            'GESTIONE DEI COMMANDI PER VISUALIZZARE E SCARICA L'XML DI DETTAGLIO
            If e.CommandName.ToUpper = "DETTAGLIO" Then
                'ESEGUO UN REDIRECT ALLA PAGINA DOWNLOAD.ASPX PER VISUALIZZARE IL DETTAGLIO DELLA MODIFICA.
                'IL PARAMETRO M INDICA CHE DEVE ESSERE APERO UN POPUP
                Response.Redirect("Download.aspx?M=VIEW&ID=" & e.CommandArgument, "_blank", "menubar=0,toolbar=0,scrollbars=1,resizable=1,top=10,width=800,height=800")
            ElseIf e.CommandName.ToUpper = "SCARICA" Then
                Response.Redirect("Download.aspx?&ID=" & e.CommandArgument)
            End If
        Catch ex As Exception
            alertError.Visible = True
            alertError.InnerText = GestioneErrori.TrapError(ex)
        End Try
    End Sub

    Private Sub gvListaLogModifiche_PageIndexChanging(sender As Object, e As GridViewPageEventArgs) Handles gvListaLogModifiche.PageIndexChanging
        'PERMETTO LA RIESECUZIONE DELLA QUERY.
        'ALTRIMENTI VIENE CANCELLATA LA SELECT E SBIANCATA LA TABELLA.
        bCercaClicked = True
    End Sub
End Class