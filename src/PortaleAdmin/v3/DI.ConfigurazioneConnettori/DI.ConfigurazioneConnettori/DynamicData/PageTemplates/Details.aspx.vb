Imports System.Web.DynamicData
Imports System.Web.Routing
Imports System.Web.UI.WebControls.Expressions

Class Details
    Inherits Page

    Protected table As MetaTable

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As EventArgs)
        table = DynamicDataRouteHandler.GetRequestMetaTable(Context)
        FormView1.SetMetaTable(table)
        DetailsDataSource.EntityTypeName = table.EntityType.AssemblyQualifiedName
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)
        Try
            Title = table.DisplayName

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


    Protected Sub FormView1_ItemDeleted(ByVal sender As Object, ByVal e As FormViewDeletedEventArgs)
        If e.Exception Is Nothing OrElse e.ExceptionHandled Then
            Response.Redirect(table.ListActionPath)
        End If
    End Sub

End Class
