Imports Sac.Msg.Wcf.sac.bt.paziente.schema.dataaccess

<ServiceContract(Namespace:="http://SAC.BT.Paziente.Schema.DataAccess/v1.0")>
Public Interface IPazienti

    <OperationContract()>
    Function ProcessaMessaggio(ByVal Tipo As MessaggioPazienteTipoEnum,
                                       ByVal Messaggio As MessaggioPazienteParameter) As MessaggioPazienteReturn

    <OperationContract()>
    Function ListaPazientiByGeneralita(ByVal MaxRecord As Integer,
                                       ByVal SortOrder As PazientiSortOrderEnum,
                                       ByVal RestituisciSinonimi As Boolean,
                                       ByVal RestituisciEsenzioni As Boolean,
                                       ByVal RestituisciConsensi As Boolean,
                                       ByVal IdPaziente As String,
                                       ByVal Cognome As String,
                                       ByVal Nome As String,
                                       ByVal DataNascita As DateTime?,
                                       ByVal CodiceFiscale As String,
                                       ByVal Sesso As String) As ListaPazientiReturn

    <OperationContract()>
    Function DettaglioPaziente(ByVal IdPaziente As String) As DettaglioPazienteReturn


End Interface

