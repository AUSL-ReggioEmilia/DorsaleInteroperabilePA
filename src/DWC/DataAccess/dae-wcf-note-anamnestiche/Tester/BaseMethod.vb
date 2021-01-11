
Public MustInherit Class BaseMethod
	Inherits BaseSerializer(Of BaseMethod)

	''' <summary>
	''' Endpoint da passare al costruttore del proxy che punta al webservice
	''' </summary>
	Friend Property Endpoint() As String

	''' <summary>
	''' Inizializza le proprietà e predispone il metodo all'esecuzione
	''' </summary>
	Public MustOverride Sub Setup()

	''' <summary>
	''' Esegue la chiamata al metodo del webservice e ritorna l'oggetto restituito 
	''' </summary>
	Public MustOverride Function Execute() As Object

End Class
