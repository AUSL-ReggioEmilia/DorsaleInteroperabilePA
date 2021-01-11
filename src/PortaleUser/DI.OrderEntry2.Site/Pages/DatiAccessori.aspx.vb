Imports System.Web.UI
Imports DI.PortalUser2.Data
Imports DI.OrderEntry.Services
Imports System.Linq
Imports System.Collections.Generic
Imports System.Web.UI.WebControls

Namespace DI.OrderEntry.User

    Public Class DatiAccessori
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

        Public Property Nosologico() As String
            Get
                Return Me.ViewState("Nosologico")
            End Get
            Set(ByVal value As String)
                Me.ViewState.Add("Nosologico", value)
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

        Public Property ListaGruppi() As List(Of String)
            Get
                Return Me.ViewState("ListaGruppi")
            End Get
            Set(ByVal value As List(Of String))
                Me.ViewState.Add("ListaGruppi", value)
            End Set
        End Property
        Dim isAccessoDiretto As Boolean = False


        Public Property ExecuteSelect() As Boolean
            Get
                Return Me.ViewState("ExecuteSelect")
            End Get
            Set(ByVal value As Boolean)
                Me.ViewState.Add("ExecuteSelect", value)
            End Set
        End Property

#End Region

#Region "RegularExpression"
        Const regexFloat = "((\b[0-9]+)?\,)?[0-9]+\b"
        Const regexNumber = "[-+]?\b\d+\b"
        Const regexDateITA = "(0?[1-9]|[12][0-9]|3[01])[/-](0?[1-9]|1[0-2])[/-](1[89][0-9]{2}|[23][0-9]{3})"
        Const regexTime = "([0-9]|[01][0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?"
        Const regexDateTime = regexDateITA & "\s" & regexTime
#End Region

        Private Sub DatiAccessori_PreInit(sender As Object, e As EventArgs) Handles Me.PreInit
            Try
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
        Private Sub DatiAccessori_Load(sender As Object, e As EventArgs) Handles Me.Load
            Try
                If Not Page.IsPostBack Then
                    'Carico le properties contenenti i parametri di query string.
                    Me.IdRichiesta = Request.QueryString("IdRichiesta")
                    Me.Nosologico = Request.QueryString("Nosologico")
                    Me.IdPaziente = Request.QueryString("IdPaziente")

                    'Carico le property della testata del paziente.
                    ucDettaglioPaziente2.Nosologico = Me.Nosologico
                    ucDettaglioPaziente2.IdPaziente = Me.IdPaziente
                    ucDettaglioPaziente2.ExecuteQuery = True
                    ucDettaglioPaziente2.DataBind()

                    '2020-01-21 Kyrylo: Se si è in accesso diretto controllo la presenza del parametro ShowPannelloPaziente e visualizzo o meno il pannello paziente
                    If Me.isAccessoDiretto Then
                        Dim showPannelloPaziente As String = Request.QueryString("ShowPannelloPaziente")

                        If Not String.IsNullOrEmpty(showPannelloPaziente) Then
                            Dim bShowPannelloPaziente As Boolean = True
                            If Boolean.TryParse(showPannelloPaziente, bShowPannelloPaziente) Then
                                ucDettaglioPaziente2.Visible = bShowPannelloPaziente
                            End If
                        End If
                    End If

                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

#Region "Utilities"

        ''' <summary>
        ''' Ottiene il distinct dei nomi dei gruppi di dati accessori.
        ''' </summary>
        ''' <param name="idRichiesta"></param>
        ''' <returns></returns>
        Public Function GetNomiGruppi(idRichiesta As String) As List(Of String)
            Dim listaGruppi As New List(Of String)

            Try
                Dim dataset As New CustomDataSource.DatiAccessori
                Dim domande As List(Of DatoAccessorioListaType) = dataset.GetDataByIdRichiesta(idRichiesta)

                listaGruppi = (From da In domande Where (da.DatoAccessorio.Gruppo IsNot Nothing) Order By da.DatoAccessorio.Gruppo Select da.DatoAccessorio.Gruppo).ToList()

                If listaGruppi IsNot Nothing AndAlso listaGruppi.Count > 0 Then
                    listaGruppi = listaGruppi.Distinct().ToList()
                End If

            Catch ex As Threading.ThreadAbortException
                'in caso di redirect alla pagina di copnferma inoltro
                Return Nothing
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return listaGruppi
        End Function

        ''' <summary>
        ''' Ottiene la lista dei Dati Accessori in base al nome del gruppo.
        ''' </summary>
        ''' <param name="idRichiesta"></param>
        ''' <param name="NomeGruppo"></param>
        ''' <returns></returns>
        Public Function GetDatiAccessoriByNomeGruppo(idRichiesta As String, NomeGruppo As String) As List(Of DatoAccessorioListaType)
            Dim listaGruppi As New List(Of DatoAccessorioListaType)

            Try
                Dim dataset As New CustomDataSource.DatiAccessori
                Dim domande As List(Of DatoAccessorioListaType) = dataset.GetDataByIdRichiesta(idRichiesta)

                If NomeGruppo Is Nothing OrElse String.IsNullOrEmpty(NomeGruppo) Then
                    listaGruppi = (From da In domande Where (da.DatoAccessorio.Gruppo Is Nothing OrElse String.IsNullOrEmpty(da.DatoAccessorio.Gruppo)) Order By da.DatoAccessorio.Ordinamento Ascending Select da).ToList()
                Else
                    listaGruppi = (From da In domande Where (da.DatoAccessorio.Gruppo IsNot Nothing AndAlso da.DatoAccessorio.Gruppo.ToUpper = NomeGruppo.ToUpper) Order By da.DatoAccessorio.Ordinamento Ascending Select da).ToList()
                End If

            Catch ex As Threading.ThreadAbortException
                'in caso di redirect alla pagina di copnferma inoltro
                Return Nothing
            Catch ex As Exception
                gestioneErrori(ex)
            End Try

            Return listaGruppi

        End Function

        ''' <summary>
        ''' Ottiene il tooltip per la label di ogni dato accessorio.
        ''' </summary>
        ''' <param name="dato"></param>
        ''' <returns></returns>
        Protected Function GetTooltipPrestazioni(dato As DatoAccessorioListaType) As String
            Dim tooltip As String = String.Empty

            Try

                'Controlla se il dato è di testata o di prestazione
                If dato.DatoAccessorioRichiesta Then

                    Dim eroganti As String() = (From prestazione In dato.Prestazioni
                                                Select $"{prestazione.SistemaErogante.Azienda.Codice}-{prestazione.SistemaErogante.Sistema.Codice}").Distinct().ToArray()

                    tooltip = "Eroganti che richiedono questo dato: " & String.Join(" ", eroganti)
                Else
                    Dim prestazioni = (From prestazione In dato.Prestazioni
                                       Select $"({prestazione.SistemaErogante.Azienda.Codice}-{prestazione.SistemaErogante.Sistema.Codice}) {If(String.IsNullOrEmpty(prestazione.Descrizione), prestazione.Codice, $"{prestazione.Codice} - {prestazione.Descrizione}")}").ToArray()

                    tooltip = "Prestazioni che richiedono questo dato: " & String.Join(" ", tooltip)
                End If

            Catch ex As Exception
                gestioneErrori(ex)
            End Try

            Return tooltip
        End Function

        ''' <summary>
        ''' Restituisce la regular expression corretta in base al dato accessorio
        ''' </summary>
        ''' <param name="control"></param>
        ''' <param name="regularExpression"></param>
        ''' <param name="message"></param>
        ''' <returns></returns>
        Protected Function GetRegularExpressionValidator(control As WebControl, regularExpression As String, message As String) As RegularExpressionValidator
            Try
                If String.IsNullOrEmpty(message) Then
                    message = "Formato non corretto"
                End If

                Return New RegularExpressionValidator() With
                   {
                   .ID = "REValidator_" & control.ID,
                   .ControlToValidate = control.ID,
                   .Display = ValidatorDisplay.Dynamic,
                   .SetFocusOnError = True,
                   .CssClass = "erroreValidazione",
                   .ValidationExpression = regularExpression,
                   .ErrorMessage = message
                   }
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return New RegularExpressionValidator()
        End Function
#End Region

#Region "AggiungiDatoAccessorio"
        ''' <summary>
        ''' Aggiunge alla pagina il dato accessorio
        ''' </summary>
        ''' <param name="DatoAccessorio"></param>
        ''' <param name="Valore"></param>
        ''' <returns></returns>
        Protected Function AggiungiDatoAccessorio(DatoAccessorio As DatoAccessorioType, Valore As String) As Control
            Dim control As New Control
            Try
                Select Case DatoAccessorio.Tipo
                    Case TipoDatoAccessorioEnum.TextBox, TipoDatoAccessorioEnum.DateBox, TipoDatoAccessorioEnum.DateTimeBox, TipoDatoAccessorioEnum.TimeBox, TipoDatoAccessorioEnum.FloatBox, TipoDatoAccessorioEnum.NumberBox
                        control = AggiungiDatoAccessorioTextBox(DatoAccessorio, Valore)

                    Case TipoDatoAccessorioEnum.ComboBox
                        control = AggiungiDatoAccessorioComboBox(DatoAccessorio, Valore)

                    Case TipoDatoAccessorioEnum.ListBox
                        control = AggiungiDatoAccessorioListBox(DatoAccessorio, Valore)

                    Case TipoDatoAccessorioEnum.ListMultiBox
                        control = AggiungiDatoAccessorioListMultiBox(DatoAccessorio, Valore)

                    Case TipoDatoAccessorioEnum.Titolo
                        control = AggiungiDatoAccessorioTitolo(DatoAccessorio)
                End Select
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return control
        End Function

        Protected Function AggiungiDatoAccessorioTextBox(DatoAccessorio As DatoAccessorioType, Valore As String) As WebControl
            Dim newTextBox = New TextBox()
            Try
                'Creo una nuova textbpx
                newTextBox.ID = DatoAccessorio.Codice
                newTextBox.ClientIDMode = ClientIDMode.Static

                'Testo se è ripetibile
                If DatoAccessorio.Ripetibile Then

                    'Utilizzo data-tipo per la validazione lato client dei controlli ripetibili
                    If (DatoAccessorio.Tipo = TipoDatoAccessorioEnum.FloatBox OrElse DatoAccessorio.Tipo = TipoDatoAccessorioEnum.NumberBox) Then
                        newTextBox.Attributes.Add("data-tipo", DatoAccessorio.Tipo)
                    End If

                    'Return AggiungiDomandaRipetibileTextBox(DatoAccessorio, Valore)
                    newTextBox.ID = $"ctl{DatoAccessorio.Codice}"
                    newTextBox.ClientIDMode = ClientIDMode.Static
                    newTextBox.EnableViewState = False
                    newTextBox.CssClass = "form-control form-control-ripetibile"
                    newTextBox.Style.Add(HtmlTextWriterStyle.Display, "none")
                    newTextBox.Attributes.Add("data-codice", DatoAccessorio.Codice)
                Else
                    'Setto il valore
                    If Valore IsNot Nothing Then
                        newTextBox.Text = Valore
                    End If
                    newTextBox.CssClass = "form-control"
                End If

                'Aggiungo gli attributi corretti in base al tipo di dato accessorio
                Select Case DatoAccessorio.Tipo
                    Case TipoDatoAccessorioEnum.DateBox
                        newTextBox.CssClass += " DateInput"
                        newTextBox.Attributes.Add("placeholder", "gg/mm/aaaa")
                        newTextBox.MaxLength = 10
                    Case TipoDatoAccessorioEnum.TimeBox
                        newTextBox.CssClass += " TimeInput"
                        newTextBox.Attributes.Add("placeholder", "hh:mm:ss")
                        newTextBox.MaxLength = 8
                    Case TipoDatoAccessorioEnum.DateTimeBox
                        newTextBox.CssClass += " DateTimeInput"
                        newTextBox.Attributes.Add("placeholder", "gg/mm/aaaa hh:mm")
                        newTextBox.MaxLength = 16
                    Case Else
                        newTextBox.Attributes.Add("placeholder", DatoAccessorio.Etichetta)
                End Select
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return newTextBox
        End Function

        Protected Function AggiungiDatoAccessorioComboBox(DatoAccessorio As DatoAccessorioType, Valore As String) As WebControl
            Dim newComboBox As New DropDownList()
            Try
                Dim dataSource As New Dictionary(Of String, String)()

                If Not String.IsNullOrEmpty(DatoAccessorio.Valori) Then
                    Dim split = DatoAccessorio.Valori.Split(New String() {"§;"}, StringSplitOptions.None)

                    For Each keyValue In split
                        If Not String.IsNullOrEmpty(keyValue) Then

                            Dim splitKeyValue = keyValue.Split(New String() {"#;"}, StringSplitOptions.None)

                            If splitKeyValue.Length = 1 Then
                                dataSource.Add(splitKeyValue(0), splitKeyValue(0))
                            Else
                                dataSource.Add(splitKeyValue(0), splitKeyValue(1))
                            End If
                        End If
                    Next
                End If

                newComboBox.ID = DatoAccessorio.Codice
                newComboBox.DataSource = dataSource
                newComboBox.AppendDataBoundItems = True
                newComboBox.DataTextField = "Value"
                newComboBox.DataValueField = "Key"

                Dim emptyItem As ListItem = New ListItem With {.Text = String.Empty, .Value = String.Empty}
                newComboBox.Items.Add(emptyItem)
                newComboBox.DataBind()

                If DatoAccessorio.Ripetibile Then
                    newComboBox.ID = $"ctl{DatoAccessorio.Codice}"
                    newComboBox.ClientIDMode = ClientIDMode.Static
                    newComboBox.EnableViewState = False
                    newComboBox.Style.Add(HtmlTextWriterStyle.Display, "none")
                    newComboBox.Attributes.Add("data-codice", DatoAccessorio.Codice)
                    newComboBox.CssClass = "form-control form-control-ripetibile"
                Else
                    If Valore IsNot Nothing Then
                        newComboBox.SelectedValue = Valore
                    End If
                    newComboBox.CssClass = "form-control"
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return newComboBox
        End Function

        Protected Function AggiungiDatoAccessorioTitolo(DatoAccessorio As DatoAccessorioType) As WebControl
            Dim newLabel = New Label
            Try
                newLabel.ID = DatoAccessorio.Codice
                newLabel.CssClass = "form-control-static"
                newLabel.Text = DatoAccessorio.Descrizione
                newLabel.AssociatedControlID = DatoAccessorio.Codice
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return newLabel
        End Function

        Protected Function AggiungiDatoAccessorioListBox(DatoAccessorio As DatoAccessorioType, Valore As String) As WebControl
            Dim newListBox = New RadioButtonList()
            Try
                Dim dataSource As New Dictionary(Of String, String)()

                If Not String.IsNullOrEmpty(DatoAccessorio.Valori) Then
                    Dim split = DatoAccessorio.Valori.Split(New String() {"§;"}, StringSplitOptions.None)
                    For Each keyValue In split
                        Dim splitKeyValue = keyValue.Split(New String() {"#;"}, StringSplitOptions.None)
                        If splitKeyValue.Length = 1 Then
                            dataSource.Add(splitKeyValue(0), splitKeyValue(0))
                        Else
                            dataSource.Add(splitKeyValue(0), splitKeyValue(1))
                        End If
                    Next
                End If
                newListBox.ID = DatoAccessorio.Codice
                newListBox.DataSource = dataSource
                newListBox.DataTextField = "Value"
                newListBox.DataValueField = "Key"
                newListBox.DataBind()

                If Valore IsNot Nothing Then
                    newListBox.SelectedValue = Valore
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return newListBox
        End Function

        Protected Function AggiungiDatoAccessorioListMultiBox(DatoAccessorio As DatoAccessorioType, Valore As String) As WebControl
            Dim panel As New Panel()
            Try
                Dim newListBox = New CheckBoxList()
                newListBox.ID = DatoAccessorio.Codice & "_checklist"

                If Not String.IsNullOrEmpty(DatoAccessorio.Valori) Then

                    Dim split = DatoAccessorio.Valori.Split(New String() {"§;"}, StringSplitOptions.None)

                    For Each keyValue In split

                        If Not String.IsNullOrEmpty(keyValue) Then

                            Dim splitKeyValue = keyValue.Split(New String() {"#;"}, StringSplitOptions.None)

                            If splitKeyValue.Length = 1 Then
                                Dim itemEtichetta As String = splitKeyValue(0)
                                Dim itemValore As String = splitKeyValue(0)
                                Dim item As New ListItem(itemEtichetta, itemValore)
                                item.Attributes.Add("KeyValue", itemValore)
                                newListBox.Items.Add(item)
                            Else
                                Dim itemEtichetta As String = splitKeyValue(1)
                                Dim itemValore As String = splitKeyValue(0)
                                Dim item As New ListItem(itemEtichetta, itemValore)
                                item.Attributes.Add("KeyValue", itemValore)
                                newListBox.Items.Add(item)
                            End If

                        End If
                    Next
                End If

                Dim newTextbox = New TextBox() With
               {
               .ID = DatoAccessorio.Codice,
               .Text = Valore
               }

                If Not String.IsNullOrEmpty(Valore) Then

                    For Each singoloValore As String In Valore.Split(New String() {"§;"}, StringSplitOptions.None)

                        Dim currentCheckBox As ListItem = newListBox.Items.FindByValue(singoloValore)
                        If (currentCheckBox IsNot Nothing) Then

                            currentCheckBox.Selected = True
                        End If
                    Next
                End If

                newTextbox.Style.Add(HtmlTextWriterStyle.Display, "none")
                newTextbox.Attributes.Add("clientId", DatoAccessorio.Codice)
                newListBox.Attributes.Add("clientId", DatoAccessorio.Codice & "_checklist")

                newListBox.CssClass = newListBox.CssClass & " " & "checkboxlist-custom-whitespace"

                panel.Controls.Add(newListBox)
                panel.Controls.Add(newTextbox)

                ClientScript.RegisterStartupScript(GetType(Page), DatoAccessorio.Codice, "CopyValueFromCheckBoxList('" & DatoAccessorio.Codice & "');", True)
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return panel
        End Function
#End Region

        Protected Sub dtDatiAccessori_ItemDataBound(sender As Object, e As DataListItemEventArgs)
            Try
                'Ottengo il pannello
                Dim pannello As Panel = e.Item.FindControl("RispostaPanel")

                'Ottengo il dato accessorio
                Dim datoAccessorio As DatoAccessorioListaType = e.Item.DataItem

                'Ottengo il valore del dato accessorio
                Dim valore = Utility.GetFormattedValueFromDataType(datoAccessorio.ValoreDato, datoAccessorio.DatoAccessorio.Tipo)

                'Ottengo il control del dato accessorio
                Dim controlloDatoAccessorio As WebControl = AggiungiDatoAccessorio(datoAccessorio.DatoAccessorio, valore)

                If controlloDatoAccessorio IsNot Nothing Then
                    If datoAccessorio.DatoAccessorio.Tipo = TipoDatoAccessorioEnum.ListBox OrElse datoAccessorio.DatoAccessorio.Tipo = TipoDatoAccessorioEnum.ListMultiBox Then
                        '
                        ' Per gli altri tipi di controllo è necessario creare una struttura formata da un div contenente una label contenente il newControl.
                        ' Se il newControl è un RadioButtonList allora bisogna inserire nel div la classe css "radio" altrimenti bisogna inseire la classe "checkbox".
                        '
                        'Dim div As New HtmlControls.HtmlGenericControl("div")
                        'Dim label As New HtmlControls.HtmlGenericControl("label")
                        '                  If TypeOf controlloDatoAccessorio Is RadioButtonList Then
                        '	div.Attributes.Add("class", "radio")
                        'Else
                        '	div.Attributes.Add("class", "checkbox")
                        'End If

                        '                  Label.Controls.Add(controlloDatoAccessorio)
                        'div.Controls.Add(label)
                        pannello.Controls.Add(controlloDatoAccessorio)
                    Else
                        If datoAccessorio.DatoAccessorio.Ripetibile Then
                            '
                            ' Se newControl è una TextBox o una DropDownList allora è sufficiente aggiungere la classe css form-control
                            '
                            Dim hf As New HiddenField With {.ID = $"hdf{datoAccessorio.DatoAccessorio.Codice}", .Value = valore, .ClientIDMode = ClientIDMode.Static}
                            pannello.Controls.Add(hf)
                        End If

                        pannello.Controls.Add(controlloDatoAccessorio)
                    End If

                    Dim validator As RegularExpressionValidator = Nothing

                    ' REGEX INCLUSA NEL DATO ACCESSORIO
                    If Not String.IsNullOrEmpty(datoAccessorio.DatoAccessorio.ValidazioneRegex) Then
                        If datoAccessorio.DatoAccessorio.Tipo <> TipoDatoAccessorioEnum.TimeBox AndAlso datoAccessorio.DatoAccessorio.Tipo <> TipoDatoAccessorioEnum.DateTimeBox Then
                            validator = GetRegularExpressionValidator(controlloDatoAccessorio, datoAccessorio.DatoAccessorio.ValidazioneRegex, datoAccessorio.DatoAccessorio.ValidazioneMessaggio)
                        End If
                    Else
                        Dim regex As String = String.Empty

                        'REGEX DI DEFAULT PER ALCUNI TIPI DI DATO
                        Select Case datoAccessorio.DatoAccessorio.Tipo
                            Case TipoDatoAccessorioEnum.FloatBox
                                regex = regexFloat
                            Case TipoDatoAccessorioEnum.NumberBox
                                regex = regexNumber
                        End Select

                        If Not String.IsNullOrEmpty(regex) Then
                            validator = GetRegularExpressionValidator(controlloDatoAccessorio, regex, datoAccessorio.DatoAccessorio.ValidazioneMessaggio)
                            validator.CssClass = "label label-danger"
                        End If
                    End If

                    If validator IsNot Nothing Then
                        pannello.Controls.Add(validator)
                    End If

                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub dtGruppi_ItemDataBound(sender As Object, e As DataListItemEventArgs) Handles dtGruppi.ItemDataBound
            Try
                If e.Item IsNot Nothing AndAlso e.Item.DataItem IsNot Nothing Then
                    'ottengo il nome del gruppo
                    Dim nomeGruppo As String = e.Item.DataItem.ToString

                    'Ottengo la datalist innestata
                    Dim dtl As DataList = CType(e.Item.FindControl("dtDatiAccessori"), DataList)
                    'Ottengo l'ods della datalist innestata
                    Dim ods As ObjectDataSource = CType(e.Item.FindControl("odsDatiAccessori2"), ObjectDataSource)
                    'Valorizzo l'input parameter dell'ods e carico i dati
                    ods.SelectParameters("NomeGruppo").DefaultValue = nomeGruppo
                    dtl.DataBind()
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub dtGruppi_ItemCommand(source As Object, e As DataListCommandEventArgs) Handles dtGruppi.ItemCommand
            Try
                If String.Equals(e.CommandName, "avanti") Then

                    'Cancello la cache
                    Dim dataSource As New CustomDataSource.Prestazioni
                    dataSource.ClearCache()

                    '
                    'Salvo i dati accessori
                    '
                    Dim dicDatiAccessori As New Dictionary(Of String, String)

                    Dim datalist1 As DataList = CType(source, DataList)

                    For Each item As Control In datalist1.Controls
                        Dim datalist2 As DataList = item.FindControl("dtDatiAccessori")
                        If datalist2 IsNot Nothing Then
                            For Each control2 As Control In datalist2.Controls
                                Dim panelRisposta As Panel = CType(control2.FindControl("RispostaPanel"), Panel)
                                If panelRisposta IsNot Nothing AndAlso panelRisposta.Controls.Count > 1 Then
                                    Dim codiceDatoAccessorio = panelRisposta.Attributes("data-codice")
                                    Dim value As String = String.Empty
                                    For Each controllo In panelRisposta.Controls
                                        If TypeOf controllo Is HiddenField Then
                                            'Campo ripetibile.
                                            Dim hdf As HiddenField = CType(controllo, HiddenField)
                                            value = hdf.Value
                                            Exit For
                                        ElseIf TypeOf controllo Is TextBox Then
                                            Dim txt As TextBox = CType(controllo, TextBox)
                                            value = txt.Text
                                            Exit For

                                        ElseIf TypeOf controllo Is CheckBoxList Then
                                            Dim cbl As CheckBoxList = CType(controllo, CheckBoxList)
                                            'Modifica Leo 2019-11-06 Uso funzione di concatenazione stringhe
                                            value = Utility.StringConcatenate(cbl.Items, "§;")
                                            Exit For
                                        ElseIf TypeOf controllo Is RadioButtonList Then
                                            Dim rbl As RadioButtonList = CType(controllo, RadioButtonList)
                                            value = rbl.SelectedValue
                                            Exit For
                                        ElseIf TypeOf controllo Is DropDownList Then
                                            Dim ddl As DropDownList = CType(controllo, DropDownList)
                                            value = ddl.SelectedValue
                                            Exit For

                                        ElseIf TypeOf controllo Is Panel Then
                                            Dim pan As Panel = CType(controllo, Panel)


                                            For Each c In pan.Controls
                                                If TypeOf c Is CheckBoxList Then
                                                    Dim cbl As CheckBoxList = CType(c, CheckBoxList)
                                                    'Modifica Leo 2019-11-06 Uso funzione di concatenazione stringhe
                                                    value = Utility.StringConcatenate(cbl.Items, "§;")
                                                End If
                                            Next

                                            Exit For
                                        End If
                                    Next

                                    dicDatiAccessori.Add(codiceDatoAccessorio, value)
                                End If
                            Next
                        End If
                    Next

                    SalvaDati(dicDatiAccessori)

                ElseIf String.Equals(e.CommandName, "indietro") Then
                    ExecuteSelect = False
                    '
                    'Navigo alla pagina di composizione dell'ordine
                    '
                    Dim url = Utility.buildUrl($"~/Pages/ComposizioneOrdine.aspx?IdPaziente={Me.IdPaziente}&IdRichiesta={Me.IdRichiesta}", Me.isAccessoDiretto)

                    If Not String.IsNullOrEmpty(Me.Nosologico) Then
                        url += $"&Nosologico={Me.Nosologico}"
                    End If

                    ' 2020-01-20 Kyrylo : Se da QueryString è presente il parametro ShowPannelloPaziente allora lo aggiungo all'url delle pagine successive
                    If Me.isAccessoDiretto Then
                        Dim showPannelloPaziente As String = Request.QueryString("ShowPannelloPaziente")
                        If Not String.IsNullOrEmpty(showPannelloPaziente) Then
                            Dim bShowPannelloPaziente As Boolean = True
                            If Boolean.TryParse(showPannelloPaziente, bShowPannelloPaziente) Then
                                url += $"&ShowPannelloPaziente={bShowPannelloPaziente}"
                            End If
                        End If
                    End If

                    Response.Redirect(url, False)
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Public Sub SalvaDati(dicDatiAccessori As Dictionary(Of String, String))
            Try
                'Ottengo i dati dell'utente
                Dim userData = UserDataManager.GetUserData()

                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                    Dim response As OttieniDatiAccessoriPerIdGuidResponse = webService.OttieniDatiAccessoriPerIdGuid(New OttieniDatiAccessoriPerIdGuidRequest(userData.Token, IdRichiesta))
                    Dim datiAccessori As DatiAccessoriListaType = response.OttieniDatiAccessoriPerIdGuidResult
                    Dim risposte = New DatiAccessoriValoriType()

                    For Each datoAccessorio As DatoAccessorioListaType In datiAccessori
                        If datoAccessorio.DatoAccessorio.Ripetibile Then
                            Dim valore As String = String.Empty
                            Dim items = (From i In dicDatiAccessori Where i.Key = datoAccessorio.DatoAccessorio.Codice Select i.Value)
                            If items IsNot Nothing Then
                                valore = items(0)
                            End If

                            Dim values As String() = valore.Split(New String() {"§;"}, StringSplitOptions.None)
                            For Each value In values
                                Dim risposta = New DatoAccessorioValoreType() With {.Codice = datoAccessorio.DatoAccessorio.Codice, .ValoreDato = Utility.GetStringFormatFromDataType(value, datoAccessorio.DatoAccessorio.Tipo)}
                                risposte.Add(risposta)
                            Next
                        ElseIf datoAccessorio.DatoAccessorio.Tipo = TipoDatoAccessorioEnum.Titolo Then
                            Dim risposta = New DatoAccessorioValoreType() With {.Codice = datoAccessorio.DatoAccessorio.Codice, .ValoreDato = datoAccessorio.DatoAccessorio.Descrizione}
                            risposte.Add(risposta)
                        Else
                            Dim valore As String = String.Empty
                            Dim items = (From i In dicDatiAccessori Where i.Key = datoAccessorio.DatoAccessorio.Codice Select i.Value)
                            If items IsNot Nothing Then
                                valore = items(0)
                            End If

                            Dim risposta = New DatoAccessorioValoreType() With {.Codice = datoAccessorio.DatoAccessorio.Codice, .ValoreDato = Utility.GetStringFormatFromDataType(valore, datoAccessorio.DatoAccessorio.Tipo)}
                            risposte.Add(risposta)
                        End If
                    Next

                    webService.AggiornaOrdineDatiAccessoriValoriPerIdGuig(New AggiornaOrdineDatiAccessoriValoriPerIdGuigRequest(userData.Token, IdRichiesta, risposte))


                End Using

                'Dim url = $"~/Pages/ConfermaInoltro.aspx?IdPaziente={Me.IdPaziente}&IdRichiesta={Me.IdRichiesta}"

                'If Not String.IsNullOrEmpty(Me.Nosologico) Then
                '	url += $"&Nosologico={Me.Nosologico}"
                'End If

                Dim sErrori = GetMessaggiValidazione(Me.IdRichiesta)

                If Not sErrori Is Nothing AndAlso sErrori.Count > 0 Then
                    Dim sMessaggio As String = String.Join("<br />", sErrori.ToArray)
                    'divErrorMessage.Visible = True
                    '               lblError.Text = sMessaggio

                    lblErroriCompilazione.Text = sMessaggio
                    Dim functionJS As String = "$('#modalErroriCompilazione').modal('show');"
                    ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide", functionJS, True)

                Else
                    'HttpContext.Current.Response.Redirect(url, False)

                    RedirectToConfermaInoltro()
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub odsGruppi_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsGruppi.Selected
            Try
                If e.Exception Is Nothing Then
                    If e.ReturnValue Is Nothing OrElse CType(e.ReturnValue, List(Of String)).Count = 0 Then
                        ''Costruisco l'URL
                        'Dim sUrl As String = $"~/Pages/ConfermaInoltro.aspx?IdPaziente={Me.IdPaziente}&IdRichiesta={Me.IdRichiesta}"
                        'If Not String.IsNullOrEmpty(Me.Nosologico) Then
                        '    sUrl += $"&Nosologico={Me.Nosologico}"
                        'End If

                        ''Navigo alla pagina di conferma inoltro.
                        'HttpContext.Current.Response.Redirect(sUrl, False)

                        RedirectToConfermaInoltro()
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub RedirectToConfermaInoltro()
            Try
                'Costruisco l'URL
                Dim sUrl As String = Utility.buildUrl($"~/Pages/ConfermaInoltro.aspx?IdPaziente={Me.IdPaziente}&IdRichiesta={Me.IdRichiesta}", Me.isAccessoDiretto)
                If Not String.IsNullOrEmpty(Me.Nosologico) Then
                    sUrl += $"&Nosologico={Me.Nosologico}"
                End If

                ' 2020-01-20 Kyrylo : Se da QueryString è presente il parametro ShowPannelloPaziente allora lo aggiungo all'url della pagina successiva
                If Me.isAccessoDiretto Then
                    Dim showPannelloPaziente As String = Request.QueryString("ShowPannelloPaziente")
                    If Not String.IsNullOrEmpty(showPannelloPaziente) Then
                        Dim bShowPannelloPaziente As Boolean = True
                        If Boolean.TryParse(showPannelloPaziente, bShowPannelloPaziente) Then
                            sUrl += $"&ShowPannelloPaziente={bShowPannelloPaziente}"
                        End If
                    End If
                End If

                'Navigo alla pagina di conferma inoltro.
                HttpContext.Current.Response.Redirect(sUrl, False)
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Public Sub btnModalAvanti_Click(sender As Object, e As EventArgs) Handles btnModalAvanti.Click
            Try
                RedirectToConfermaInoltro()
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

#Region "Utilities"
        ''' <summary>
        ''' Estrae dall'ordine gli eventuali messaggi di errore di validazione
        ''' </summary>
        Private Function GetMessaggiValidazione(IdRichiesta As String) As List(Of String)
            Dim oRet As New List(Of String)

            Try
                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                    Dim userData = UserDataManager.GetUserData()
                    Dim request = New OttieniOrdinePerIdGuidRequest(userData.Token, IdRichiesta)
                    Dim response = webService.OttieniOrdinePerIdGuid(request)
                    Dim result = response.OttieniOrdinePerIdGuidResult

                    If result Is Nothing OrElse result.Ordine.RigheRichieste Is Nothing OrElse result.Ordine.RigheRichieste.Count = 0 Then
                        Return oRet
                    End If

                    If Not String.IsNullOrEmpty(result.StatoValidazione.Descrizione) Then
                        oRet.Add(result.StatoValidazione.Descrizione)
                    End If

                    For i As Integer = 0 To result.StatoValidazione.Righe.Count - 1

                        Dim descPrestazione = result.Ordine.RigheRichieste(i).Prestazione.Descrizione
                        Dim descValidazione = result.StatoValidazione.Righe(i).Descrizione
                        If Not String.IsNullOrEmpty(descValidazione) Then
                            oRet.Add(descPrestazione)
                            oRet.Add(descValidazione)
                        End If
                    Next

                End Using

            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return oRet
        End Function
#End Region

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

        Private Sub timer_Tick(sender As Object, e As EventArgs) Handles timer.Tick
            Try
                timer.Enabled = False
                ExecuteSelect = True
                dtGruppi.DataBind()
                updDatiAccessori.Update()
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub odsGruppi_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsGruppi.Selecting
            Try
                e.Cancel = Not ExecuteSelect
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

    End Class

End Namespace