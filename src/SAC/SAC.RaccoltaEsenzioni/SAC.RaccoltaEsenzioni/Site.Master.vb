Partial Public Class Site
    Inherits MasterPage

    ''' <summary>
    ''' Ottengo la versione dell'assembly
    ''' </summary>
    ''' <returns></returns>
    Protected ReadOnly Property AssemblyVersion() As String
        Get
            Return Utility.GetAssemblyVersion()
        End Get
    End Property


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

    End Sub


    ''' <summary>
    ''' Funzione per la visualizzazione degli errori
    ''' </summary>
    ''' <param name="ErrorMessage"></param>
    Public Sub ShowErrorLabel(ErrorMessage As String)
        DivError.Visible = True

        Utility.ShowErrorLabel(LabelError, ErrorMessage)

        updError.Update()
    End Sub
End Class