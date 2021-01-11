Public Class Stampe

#Region "Configurazioni d stampa"
    Public Function StampeConfigurazioniDettaglio(ByVal UserAccount As String, ByVal ClientName As String) As StampeDataset.FevsStampeConfigurazioniStampaDettaglioDataTable
        Using ta As New StampeDatasetTableAdapters.FevsStampeConfigurazioniStampaDettaglioTableAdapter
            ta.Connection = SqlConnection
            Return ta.GetData(UserAccount, ClientName)
        End Using
    End Function

    Public Function StampeConfigurazioniAggiorna(ByVal UserAccount As String, ByVal ClientName As String, ByVal TipoConfigurazione As Integer, ByVal ServerDiStampa As String, ByVal Stampante As String) As Integer
        Using ta As New StampeDatasetTableAdapters.FevsStampeConfigurazioniStampaDettaglioTableAdapter
            ta.Connection = SqlConnection
            Return ta.UpdateConfigurazione(UserAccount, ClientName, TipoConfigurazione, ServerDiStampa, Stampante)
        End Using
    End Function

    Public Function StampeConfigurazioniAggiornaTestStampante(ByVal UserAccount As String, ByVal ClientName As String, ByVal TipoConfigurazione As Integer, ByVal ServerDiStampa As String, ByVal Stampante As String, ByVal ErroreTest As String) As Integer
        Using ta As New StampeDatasetTableAdapters.FevsStampeConfigurazioniStampaDettaglioTableAdapter
            ta.Connection = SqlConnection
            Return ta.UpdateTestStampante(UserAccount, ClientName, TipoConfigurazione, ServerDiStampa, Stampante, ErroreTest)
        End Using
    End Function
#End Region

End Class
