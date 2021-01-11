Imports System
Imports System.Data

Imports System.Data.SqlClient
Imports System.Configuration
Imports System.ComponentModel

Namespace DI.Dispatcher.User.Data

    <DataObjectAttribute(True)> _
    Public NotInheritable Class DataAdapterManager

        ''' <summary>
        ''' Rappresenta la versione minima del DB 
        ''' </summary>
        ''' <remarks></remarks>
        Private Shared ReadOnly ApplicationDBVersion As New Version("1.0")

        Private Sub New()

        End Sub

    End Class

End Namespace