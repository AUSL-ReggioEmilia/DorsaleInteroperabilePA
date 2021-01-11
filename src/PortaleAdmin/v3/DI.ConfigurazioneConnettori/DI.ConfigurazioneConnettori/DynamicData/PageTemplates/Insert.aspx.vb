Class Insert
    Inherits Page

    Protected table As MetaTable

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As EventArgs)
        table = DynamicDataRouteHandler.GetRequestMetaTable(Context)
        '
        ' SE MI È STATO PASSATO UN OGGETTO DA COPIARE, LO MOSTRO 
        '
        If Request.QueryString("Copy") = "1" AndAlso Session(Utility.CURRENT_ROW) IsNot Nothing Then
            FormView1.SetMetaTable(table, Session(Utility.CURRENT_ROW))
        Else
            FormView1.SetMetaTable(table, table.GetColumnValuesFromRoute(Context))
        End If

        DetailsDataSource.EntityTypeName = table.EntityType.AssemblyQualifiedName
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)
        Title = table.DisplayName

        '
        ' Solo la prima volta
        '
        If Not Page.IsPostBack Then

            '
            'CONTROLLO ACCESSO -> PRESENZA ATTRIBUTO RuoloAccesso
            '
            Dim attrRuoloAccesso As RuoloAccesso =
                CType(Attribute.GetCustomAttribute(table.RootEntityType, GetType(RuoloAccesso)), RuoloAccesso)

            If Not RuoloAccessoManager.IsInRole(attrRuoloAccesso) Then

                Throw New AccessViolationException("L'utente non ha accesso alla pagina!")

            End If
        End If

    End Sub

    Protected Sub FormView1_ItemCommand(ByVal sender As Object, ByVal e As FormViewCommandEventArgs)
        If e.CommandName = DataControlCommands.CancelCommandName Then
            Response.Redirect(table.ListActionPath)
            '
            ' Quando annullo l'operazione svuoto la sessione.
            '
            HttpContext.Current.Session(Utility.CURRENT_ROW) = Nothing
        End If


    End Sub

    Private Sub DetailsDataSource_Inserted(sender As Object, e As LinqDataSourceStatusEventArgs) Handles DetailsDataSource.Inserted
        If Not Me.Master.ShowAlertIfError(e) Then
            '
            ' Quando salvo, se non si sono verificati errori, svuoto la sessione.
            '
            HttpContext.Current.Session(Utility.CURRENT_ROW) = Nothing
            Response.Redirect(table.ListActionPath)
        End If
    End Sub

    Private Sub FormView1_ItemInserting(sender As Object, e As FormViewInsertEventArgs) Handles FormView1.ItemInserting

        'Modifica 29-05-2020 Leo & Kyry: se c'è l'attributo "DefaultEmptyString" in un field della tabella gli do il default value a "" e non a Nothing
        'questo perchè inserire Nothing in tabelle SQL Not Null causa exceptions

        'Attributo da controllare
        Dim attr = New DefaultEmptyString()

        'Lista delle colonne da impostare a ""
        Dim columnsDefaultEmptyString As List(Of MetaColumn) = table.Columns.Where(Function(x) x.Attributes.Contains(attr)).ToList()

        For Each column As MetaColumn In columnsDefaultEmptyString

            'Match delle colonne e dei campi inseriti in base al Display Name
            Dim displayName As String = column.DisplayName

            'Per ogni colonna controllo che sia Nothing, se lo è allora la imposto a ""
            If e.Values.Item(displayName) Is Nothing Then
                e.Values.Item(displayName) = String.Empty
            End If

        Next

        'Modifica 08/10/2020 KYRY: Rimuovo tutti gli eventuali spazi all'inizio del testo nelle textbox
        For i = 1 To e.Values.Values.Count - 1
            If e.Values.Item(i) IsNot Nothing AndAlso e.Values.Item(i).GetType.Name = "String" Then
                e.Values.Item(i) = e.Values.Item(i).ToString().TrimStart(" "c)
            End If
        Next
    End Sub
End Class
