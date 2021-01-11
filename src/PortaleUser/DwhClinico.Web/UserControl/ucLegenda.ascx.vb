Public Class ucLegenda
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        '
        'Mostro o nascondo le icone relative alle note anamnestiche in base alla setting "ShowNoteAnamnesticheTab"
        '
        dlPresenzaNote.Visible = My.Settings.ShowNoteAnamnesticheTab
        dlStatiNote.Visible = My.Settings.ShowNoteAnamnesticheTab
    End Sub
End Class