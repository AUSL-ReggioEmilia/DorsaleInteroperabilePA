Imports Dwh.DataAccess.Wcf.Types.Prescrizioni

<ServiceContract(Namespace:="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0")> _
Public Interface IPrescrizioni

	<OperationContract(Name:="Aggiungi")> _
	Function Aggiungi(ByVal Prescrizione As PrescrizioneParameter) As PrescrizioneReturn

	<OperationContract(Name:="Rimuovi")> _
	Function Rimuovi(ByVal IdEsterno As String, ByVal DataModificaEsterno As DateTime) As ErroreType

End Interface

