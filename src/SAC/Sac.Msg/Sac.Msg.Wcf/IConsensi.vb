Imports Sac.Msg.Wcf.sac.bt.consenso.schema.dataaccess

<ServiceContract(Namespace:="http://SAC.BT.Consenso.Schema.DataAccess/v1.0")>
Public Interface IConsensi
    <OperationContract()>
    Function ProcessaMessaggio(ByVal Tipo As MessaggioConsensoTipoEnum,
                                      ByVal Messaggio As MessaggioConsensoParameter) As MessaggioConsensoReturn


End Interface
