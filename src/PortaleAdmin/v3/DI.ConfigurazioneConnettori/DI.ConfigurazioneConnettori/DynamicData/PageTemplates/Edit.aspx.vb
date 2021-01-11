Imports System.Web.DynamicData
Imports System.Web.Routing
Imports System.Web.UI.WebControls.Expressions

Class Edit
    Inherits Page

    Protected table As MetaTable

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As EventArgs)
        table = DynamicDataRouteHandler.GetRequestMetaTable(Context)
        FormView1.SetMetaTable(table)
        DetailsDataSource.EntityTypeName = table.EntityType.AssemblyQualifiedName
        Title = table.DisplayName
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
        Try

            '
            'CONTROLLO ACCESSO -> PRESENZA ATTRIBUTO RuoloAccesso
            '
            Dim attrRuoloAccesso As RuoloAccesso =
                CType(Attribute.GetCustomAttribute(table.RootEntityType, GetType(RuoloAccesso)), RuoloAccesso)

            If Not RuoloAccessoManager.IsInRole(attrRuoloAccesso) Then

                Throw New AccessViolationException("L'utente non ha accesso alla pagina!")

            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Master.ShowAlert(sErrorMessage)
        End Try
    End Sub

    Protected Sub FormView1_ItemCommand(ByVal sender As Object, ByVal e As FormViewCommandEventArgs)
        If e.CommandName = DataControlCommands.CancelCommandName Then
            Response.Redirect(table.ListActionPath)
        End If
    End Sub

    Protected Sub FormView1_ItemDeleted(sender As Object, e As FormViewDeletedEventArgs) Handles FormView1.ItemDeleted

        If e.Exception Is Nothing OrElse e.ExceptionHandled Then
            Response.Redirect(table.ListActionPath)
        Else
            Dim sErrorMessage As String = GestioneErrori.TrapError(e.Exception)
            Master.ShowAlert(sErrorMessage)
            e.ExceptionHandled = True
        End If
    End Sub

    Protected Sub FormView1_ItemUpdated(sender As Object, e As FormViewUpdatedEventArgs) Handles FormView1.ItemUpdated
        'If e.Exception Is Nothing OrElse e.ExceptionHandled Then
        '    Response.Redirect(table.ListActionPath)
        'End If
    End Sub

    Private Sub FormView1_ItemUpdating(sender As Object, e As FormViewUpdateEventArgs) Handles FormView1.ItemUpdating

        'Attenzione incoerenza nei dati: attualmente ci sono dei problemi in Prestazioni CUP - Prestazioni -> Sistema erogante (campo relativo alla tabella sistemi eroganti e obbligatorio) viene spesso valorizzato a "" ma non esiste nessun sistema con valore ""
        'questo causa expetion in fase di Update
        'TODO: decidere come sistemarlo

        'Modifica 29-05-2020 Leo & Kyry: se c'è l'attributo "DefaultEmptyString" in un field della tabella gli do il default value a "" e non a Nothing
        'questo perchè inserire Nothing in tabelle SQL Not Null causa exceptions

        'Lista delle colonne da impostare a ""
        Dim columnsDefaultEmptyString As List(Of MetaColumn) = table.Columns.Where(Function(x) x.Attributes.Contains(New DefaultEmptyString())).ToList()

        For Each column As MetaColumn In columnsDefaultEmptyString

            'Match delle colonne e dei campi inseriti in base al Display Name
            Dim displayName As String = column.DisplayName

            'Per ogni colonna controllo che sia Nothing, se lo è allora la imposto a ""
            If e.NewValues.Item(displayName) Is Nothing Then
                e.NewValues.Item(displayName) = String.Empty
            End If

            'Anche per l'old value, altrimenti non lo trova
            If e.OldValues.Item(displayName) Is Nothing Then
                e.OldValues.Item(displayName) = String.Empty
            End If

        Next

    End Sub

    Private Sub DetailsDataSource_Updated(sender As Object, e As LinqDataSourceStatusEventArgs) Handles DetailsDataSource.Updated
        If Not Me.Master.ShowAlertIfError(e) Then
            '
            ' Quando salvo, se non si sono verificati errori, svuoto la sessione.
            '
            HttpContext.Current.Session(Utility.CURRENT_ROW) = Nothing
            Response.Redirect(table.ListActionPath)
        End If
    End Sub

End Class
