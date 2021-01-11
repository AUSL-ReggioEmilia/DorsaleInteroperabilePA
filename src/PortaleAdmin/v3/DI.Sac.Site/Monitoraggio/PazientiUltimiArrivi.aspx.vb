Imports System.Web.UI.WebControls

Public Class PazientiUltimiArrivi
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub

    Private Sub odsLista_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
        GestioneErrori.ObjectDataSource_TrapError(e, LabelError)
    End Sub
End Class