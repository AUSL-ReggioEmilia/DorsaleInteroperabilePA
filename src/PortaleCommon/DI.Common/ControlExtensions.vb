Imports System.Web.UI
Imports System.Runtime.CompilerServices
'
Namespace DI.Common

    Public Module ControlExtensions

        <Extension()> _
        Public Function TryFindControl(Of T As Control)(ByVal control As Control, ByVal id As String, ByRef returnWebControl As T) As Boolean
            Dim _control As T = TryCast(control.FindControl(id), T)

            If _control Is Nothing Then
                returnWebControl = Nothing
                Return False
            Else
                returnWebControl = _control
                _control = Nothing
                Return True
            End If

        End Function

    End Module

End Namespace