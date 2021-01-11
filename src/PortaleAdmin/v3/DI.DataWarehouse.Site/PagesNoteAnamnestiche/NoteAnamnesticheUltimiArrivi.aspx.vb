Imports System.Web.UI.WebControls

Public Class NoteAnamnesticheUltimiArrivi
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub

    Private Sub odsListaNoteAnamnestiche_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsListaNoteAnamnestiche.Selected
        GestioneErrori.ObjectDataSource_TrapError(e, LabelError)
    End Sub

    Private Sub odsListaNoteAnamnestiche_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsListaNoteAnamnestiche.Selecting
        'PARAMETRO IN QUERY STRING DA USARE PER TESTARE LA PROCEDURA, NON VIENE MAI PASSATO IN URL
        Dim iNumeroOre As Integer
        If Integer.TryParse(Context.Request.QueryString("NumeroOre"), iNumeroOre) Then
            e.InputParameters("NumeroOre") = iNumeroOre
        End If
    End Sub
End Class