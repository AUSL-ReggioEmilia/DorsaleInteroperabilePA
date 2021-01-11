<System.ComponentModel.DataObject(True)>
Public Class Email

    Public Sub NotificheEmailInserisce(Mittente As String, Destinatario As String, CopiaConoscenza As String, CopiaConoscenzaNascosta As String, Oggetto As String, Messaggio As String)
        Using ta As New EmailDataSetTableAdapters.NotificheEmailInserisceTableAdapter
            ta.Connection = SqlConnection

            '
            '
            '
            ta.GetData(Mittente, Destinatario, CopiaConoscenza, CopiaConoscenzaNascosta, Oggetto, Messaggio)
        End Using
    End Sub

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select)>
    Public Function DestinatariPreferitiCerca(ByVal Mittente As String) As Data.EmailDataSet.DestinatariPreferitiCercaDataTable
        Using ta As New EmailDataSetTableAdapters.DestinatariPreferitiCercaTableAdapter
            ta.Connection = SqlConnection
            '
            '
            '
            Return ta.GetData(Mittente)
        End Using
    End Function

End Class

