Imports System
Imports System.Collections.Generic
Imports System.Linq
Imports System.Web.UI.WebControls

Public Class Legenda
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub

    Private Sub gvIcone_PreRender(sender As Object, e As EventArgs) Handles gvIcone.PreRender
        '
        'RENDER PER BOOTSTRAP
        'CREA LA TABLE CON THEADER E TBODY SE L'HEADER NON È NOTHING.
        '
        If Not gvIcone.HeaderRow Is Nothing Then
            gvIcone.UseAccessibleHeader = True
            gvIcone.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
    End Sub
End Class