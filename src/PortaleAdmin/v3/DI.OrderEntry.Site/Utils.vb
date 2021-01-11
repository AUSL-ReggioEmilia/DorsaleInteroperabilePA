Imports System
Imports System.Web

Public Class Utils


#Region "Gestione Errori"
    ''' <summary>
    ''' Mostra il Testo passato nella Label e la rende visibile
    ''' </summary>
    ''' <param name="Label">Label da mostrare</param>
    ''' <param name="Text">Testo da visualizzare</param>
    ''' <remarks></remarks>
    Public Shared Sub ShowErrorLabel(Label As UI.WebControls.Label, Text As String)

        Label.Text = Text
        Label.Visible = Text.Length > 0

    End Sub

#End Region

#Region "Conversioni"

    ''' <summary>
    ''' Ritorna Nothing se Value è NULL o stringa vuota, altrimenti Value
    ''' </summary>
    Public Shared Function StringEmptyDBNullToNothing(Value As Object) As String
        If Value Is DBNull.Value OrElse String.IsNullOrEmpty(Value) Then
            Return Nothing
        Else
            Return Value
        End If
    End Function

    ''' <summary>
    ''' Ritorna DefaultValue se Value è NULL, altrimenti Value
    ''' </summary>
    Public Shared Function IsNull(Of T)(ByVal Value As T, ByVal DefaultValue As T) As T
        If Value Is Nothing OrElse Convert.IsDBNull(Value) Then
            Return DefaultValue
        Else
            Return Value
        End If
    End Function

    ''' <summary>
    ''' Ritorna Nothing se Value è Null, altrimenti Value convertito nel tipo scelto
    ''' Utilizzo: GetNullable(Of String)(Value)
    ''' </summary>
    Public Shared Function GetNullable(Of T)(Value As Object) As T
        If Convert.IsDBNull(Value) Then
            Return Nothing
        Else
            Return CType(Value, T)
        End If
    End Function

    ''' <summary>
    ''' Operazione opposta di quella svolta dalle funzioni escape(escapeHtmlEntities(dato)) in javascript
    ''' </summary>
    Public Shared Function JavascriptUnEscape(str As String) As String
        Return HttpUtility.HtmlDecode(HttpUtility.UrlDecode(str))
    End Function


#End Region

#Region "Framework"

    ''' <summary>
    ''' Restituisce la versione del framework attualmente in uso dall'applicazione
    ''' </summary>
    ''' <returns></returns>
    Public Shared Function FrameworkVersion() As String
        Try
            Return Diagnostics.FileVersionInfo.GetVersionInfo(GetType(Integer).Assembly.Location).ProductVersion
        Catch
            Return "Impossibile recuperare la versione del framework."
        End Try
    End Function
#End Region

End Class
