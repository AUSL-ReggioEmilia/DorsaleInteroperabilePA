Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls

Public Class TranscodificaRegimiDettaglio
    Inherits System.Web.UI.Page

    Private Property SistemaErogante() As String
        Get
            Return DirectCast(ViewState("ViewState-SistemaErogante"), String)
        End Get
        Set(ByVal value As String)
            ViewState("ViewState-SistemaErogante") = value
        End Set
    End Property

    '
    ' mbParentRedirect viene usata nel FormView.ItemCommand per definire in base al pulsante premuto se dopo le operazioni
    ' di insert/update si deve navigare alla pagina di lista
    '
    Private Property ParentRedirect() As Boolean
        Get
            Return DirectCast(ViewState("ViewState-ParentRedirect"), Boolean)
        End Get
        Set(ByVal value As Boolean)
            ViewState("ViewState-ParentRedirect") = value
        End Set
    End Property

    Private Const PAGE_LIST As String = "~/Transcodifiche/TranscodificaRegimiLista.aspx"
    Private Const PAGE_DETAIL As String = "~/Transcodifiche/TranscodificaRegimiDettaglio.aspx"

    Private mbMainDataSourceCancelSelecting As Boolean = False
    '
    ' Il guid che identifica il record della transcodifica
    '
    Private mId As Guid
    Private msDatiCorrentiMsg As String = String.Empty


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim sId As String = String.Empty
        Try
            '
            ' Leggo l'Id del record da modificare
            '
            sId = Request.QueryString("Id")
            '
            '
            '
            If Not Page.IsPostBack Then
                '
                ' Set FormViewMode
                '
                If Not String.IsNullOrEmpty(sId) Then
                    fvDettaglio.DefaultMode = FormViewMode.Edit
                Else
                    fvDettaglio.DefaultMode = FormViewMode.Insert
                End If
                '
                '
                '
                If Not String.IsNullOrEmpty(sId) Then
                    mId = New Guid(sId)
                End If
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub odsMain_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsMain.Selecting
        Try
            e.Cancel = mbMainDataSourceCancelSelecting
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub odsMain_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsMain.Selected
        Try
            If Not e.Exception Is Nothing Then
                Dim sMessage As String = Utility.TrapError(e.Exception.InnerException, True)
                Utility.ShowErrorLabel(lblError, sMessage)
                e.ExceptionHandled = True
            Else
                '
                ' Memorizzo il valore da selezionare per la ddlAziendeEroganti
                '
                Dim odt As TranscodificheDataSet.TranscodificaRegimiOttieniDataTable = CType(e.ReturnValue, TranscodificheDataSet.TranscodificaRegimiOttieniDataTable)
                If Not odt Is Nothing AndAlso odt.Rows.Count > 0 Then
                    'Memorizzo il valore del SistemaErogante (drop down list in cascata che dipende dalla combo dell'AziendaErogante)
                    SistemaErogante = odt(0).SistemaErogante
                Else
                    Throw New Exception(String.Format("La query non ha restituito record per Id={0}", mId))
                End If

            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub odsMain_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles odsMain.Inserting
        Try
            Dim oddlAziendeEroganti As DropDownList = CType(fvDettaglio.FindControl("ddlAziendeEroganti"), DropDownList)
            Dim oddlSistemiEroganti As DropDownList = CType(fvDettaglio.FindControl("ddlSistemiEroganti"), DropDownList)
            e.InputParameters("AziendaErogante") = oddlAziendeEroganti.SelectedValue
            'Per questo campo è OBBLIGATORIO PASSARLO perchè per gestire combo in cascata nel markup non cè il bind con SelectedValue
            e.InputParameters("SistemaErogante") = oddlSistemiEroganti.SelectedValue
            'Per gli altri campi non è necessario perchè il binding è bidirezionale

            '
            ' Valorizzo stribga contenente descrizione dei dati valorizzati dall'utente
            '
            msDatiCorrentiMsg = GetDatiCorrentiMsg()

        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub odsMain_Inserted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsMain.Inserted
        Try
            If Not e.Exception Is Nothing Then
                Dim sMessage As String = Utility.TrapError(e.Exception.InnerException, True)
                '
                ' Concateno il messaggio di errore con i dati correnti impostati dall'utente
                '
                sMessage = String.Concat(sMessage, msDatiCorrentiMsg)
                Utility.ShowErrorLabel(lblError, sMessage)
                e.ExceptionHandled = True
            Else
                '
                ' Torno alla pagina di lista
                '
                If ParentRedirect Then
                    mbMainDataSourceCancelSelecting = True
                    Call GoToParent()
                End If

            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub odsMain_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles odsMain.Updating
        Try
            Dim oddlAziendeEroganti As DropDownList = CType(fvDettaglio.FindControl("ddlAziendeEroganti"), DropDownList)
            Dim oddlSistemiEroganti As DropDownList = CType(fvDettaglio.FindControl("ddlSistemiEroganti"), DropDownList)
            e.InputParameters("AziendaErogante") = oddlAziendeEroganti.SelectedValue
            'Per questo campo è OBBLIGATORIO PASSARLO perchè per gestire combo in cascata nel markup non cè il bind con SelectedValue
            e.InputParameters("SistemaErogante") = oddlSistemiEroganti.SelectedValue
            'Per gli altri campi non è necessario perchè il binding è bidirezionale

            '
            ' Valorizzo stribga contenente descrizione dei dati valorizzati dall'utente
            '
            msDatiCorrentiMsg = GetDatiCorrentiMsg()

        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub odsMain_Updated(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsMain.Updated
        Try
            If Not e.Exception Is Nothing Then
                mbMainDataSourceCancelSelecting = False
                Dim sMessage As String = Utility.TrapError(e.Exception.InnerException, True)
                '
                ' Concateno il messaggio di errore con i dati correnti impostati dall'utente
                '
                sMessage = String.Concat(sMessage, msDatiCorrentiMsg)
                Utility.ShowErrorLabel(lblError, sMessage)
                e.ExceptionHandled = True
            Else
                '
                ' Torno alla pagina di lista
                '
                If ParentRedirect Then
                    mbMainDataSourceCancelSelecting = True
                    Call GoToParent()
                End If
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub odsMain_Deleted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsMain.Deleted
        Try
            If Not e.Exception Is Nothing Then
                Dim sMessage As String = Utility.TrapError(e.Exception.InnerException, True)
                Utility.ShowErrorLabel(lblError, sMessage)
                e.ExceptionHandled = True
            Else
                '
                ' Navigo subito alla pagna di lista
                '
                mbMainDataSourceCancelSelecting = True
                Call GoToParent()
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub


    Protected Sub ddlAziendeEroganti_SelectedIndexChanged(sender As Object, e As EventArgs)
        Try
            Dim oddlSistemiEroganti As DropDownList = CType(fvDettaglio.FindControl("ddlSistemiEroganti"), DropDownList)
            '
            ' Valorizzo il SistemaErogante corrente con "" cosi in seguito a modifica dell'azienda erogante
            ' nella ddl dei sistemi eroganti si visualizza ""
            '
            SistemaErogante = String.Empty
            '
            ' Questa non serve se tolgo da ASPX la proprietà "AppendDataItem" della combo
            ' oddlSistemiEroganti.Items.Clear()
            '
            ' Ricarico ddl dei sistemi eroganti
            '
            oddlSistemiEroganti.DataBind()

        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub odsSistemiEroganti_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsSistemiEroganti.Selecting
        Try
            Dim oddlAziendeEroganti As DropDownList = CType(fvDettaglio.FindControl("ddlAziendeEroganti"), DropDownList)
            e.InputParameters("AziendaErogante") = oddlAziendeEroganti.SelectedValue
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub odsSistemiEroganti_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsSistemiEroganti.Selected
        Try
            If Not e.Exception Is Nothing Then
                Dim sMessage As String = Utility.TrapError(e.Exception, True)
                Utility.ShowErrorLabel(lblError, sMessage)
                e.ExceptionHandled = True
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Protected Sub ddlSistemiEroganti_PreRender(sender As Object, e As EventArgs)
        Try
            Dim oddlSistemiEroganti As DropDownList = CType(fvDettaglio.FindControl("ddlSistemiEroganti"), DropDownList)
            If oddlSistemiEroganti.Items.FindByValue("") Is Nothing Then
                'Se manca lo aggiungo
                oddlSistemiEroganti.Items.Insert(0, New ListItem(String.Empty, String.Empty))
            End If
            If Not oddlSistemiEroganti.Items.FindByValue(SistemaErogante) Is Nothing Then
                'Se è presente lo seleziono
                oddlSistemiEroganti.SelectedValue = SistemaErogante
            End If

        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub


    Private Sub fvDettaglio_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles fvDettaglio.ItemCommand
        Try
            Select Case e.CommandName
                Case DataControlCommands.InsertCommandName
                    If e.CommandArgument.ToString().Equals("ParentRedirect") Then
                        ParentRedirect = True
                        mbMainDataSourceCancelSelecting = True
                    Else
                        ParentRedirect = False
                    End If
                Case DataControlCommands.UpdateCommandName
                    If e.CommandArgument.ToString().Equals("ParentRedirect") Then
                        ParentRedirect = True
                        mbMainDataSourceCancelSelecting = True
                    Else
                        ParentRedirect = False
                    End If
                Case DataControlCommands.DeleteCommandName
                    '
                    ' Eseguo redirect alla pagina parent
                    '
                    mbMainDataSourceCancelSelecting = True
                    ParentRedirect = True

                Case DataControlCommands.CancelCommandName
                    '
                    ' Eseguo redirect alla pagina parent
                    '
                    mbMainDataSourceCancelSelecting = True
                    '
                    ' Navigo subito alla pagina di lista
                    '
                    Call GoToParent()
            End Select
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub


    Private Sub GoToParent()
        Response.Redirect(PAGE_LIST, False)
    End Sub


    Private Function GetDatiCorrentiMsg() As String

        Dim oddlAziendeEroganti As DropDownList = CType(fvDettaglio.FindControl("ddlAziendeEroganti"), DropDownList)
        Dim oddlSistemiEroganti As DropDownList = CType(fvDettaglio.FindControl("ddlSistemiEroganti"), DropDownList)
        Dim otxtCodiceEsterno As TextBox = CType(fvDettaglio.FindControl("txtCodiceEsterno"), TextBox)
        Dim otxtCodice As TextBox = CType(fvDettaglio.FindControl("txtCodice"), TextBox)
        Dim otxtDescrizione As TextBox = CType(fvDettaglio.FindControl("txtDescrizione"), TextBox)

        Dim sAziendaErogante As String = String.Empty
        Dim sSistemaErogante As String = String.Empty

        If Not oddlAziendeEroganti.SelectedItem Is Nothing Then
            sAziendaErogante = oddlAziendeEroganti.SelectedItem.Text
        End If
        If Not oddlSistemiEroganti.SelectedItem Is Nothing Then
            sSistemaErogante = oddlSistemiEroganti.SelectedItem.Text
        End If
        '
        ' Restituisco
        '
        Return String.Concat("</br>", "Valori:", "</br>", "AziendaErogante: ", sAziendaErogante, "</br>",
                             "SistemaErogante: ", sSistemaErogante, "</br>",
                             "CodiceEsterno: ", otxtCodiceEsterno.Text, "</br>",
                             "Codice: ", otxtCodice.Text, "</br>",
                             "Descrizione: ", otxtDescrizione.Text)

    End Function


End Class