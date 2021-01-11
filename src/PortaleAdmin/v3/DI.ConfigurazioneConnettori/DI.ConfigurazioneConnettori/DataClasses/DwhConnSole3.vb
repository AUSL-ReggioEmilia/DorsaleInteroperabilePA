Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel

Partial Public Class DwhConnSole3DataContext
End Class


<ScaffoldTable(True)>
<MetadataType(GetType(PresidiErogantiMetadata))>
<DisplayName("DwhConnSole3/Presidi Eroganti")>
<TableName("DwhConnSole3-PresidiEroganti")>
Partial Public Class PresidiEroganti

End Class

Public Class PresidiErogantiMetadata
    '[TipoErogante]
    '[AziendaErogante]
    '[SistemaErogante]
    '[RepartoErogante]
    '[AziendaErogantePrefissoEsterno]
    '[PresidioEroganteCodice]
    '[PresidioEroganteDescr]
    '[PresidioEroganteSubCodice]
    '[AziendaEroganteDescr]
    '[RepartoEroganteDescr]
    '[AziendaEroganteCodice]
    '[RegioneEroganteCodice]
    '[UnitaOperativaCodice]
    '[UnitaOperativaDescr]
    '[UnitaOperativaSubCodice]
    '[FseAbilitato]

    <Display(Name:="Azienda Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=1)>
    Public AziendaErogante As Object

    <Display(Name:="Azienda Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=1)>
    Public PresidiErogantiAziendeEroganti As Object

    <Display(Name:="Sistema Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=2)>
    Public SistemaErogante As Object

    <Display(Name:="Sistema Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=2)>
    Public PresidiErogantiSistemiEroganti As Object

    '<UIHint("ValuesList", Nothing, "ValueList", "Referto,Evento")>
    <Display(Name:="Tipo Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=3)>
    Public TipoErogante As Object

    <Display(Name:="Tipo Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=3)>
    Public PresidiErogantiTipiEroganti As Object

    <Display(Name:="Reparto Erogante", Order:=4)>
    <FilterUIHint("Search")>
    <Required(AllowEmptyStrings:=True)>
    <DisplayFormat(ConvertEmptyStringToNull:=False)>
    Public RepartoErogante As Object

    <Display(Name:="Azienda Erogante Prefisso Esterno", Order:=5)>
    <FilterUIHint("Search")>
    Public AziendaErogantePrefissoEsterno As Object

    <Display(Name:="Presidio Erogante Codice")>
    Public PresidioEroganteCodice As Object

    <Display(Name:="Presidio Erogante Descrizione")>
    Public PresidioEroganteDescr As Object

    <Display(Name:="Presidio Erogante Sub Codice")>
    Public PresidioEroganteSubCodice As Object

    <Display(Name:="Azienda Erogante Descrizione")>
    Public AziendaEroganteDescr As Object

    <Display(Name:="Reparto Erogante Descrizione")>
    Public RepartoEroganteDescr As Object

    <Display(Name:="Azienda Erogante Codice")>
    Public AziendaEroganteCodice As Object

    <Display(Name:="Regione Erogante Codice")>
    Public RegioneEroganteCodice As Object

    <Display(Name:="Unità Operativa Codice")>
    Public UnitaOperativaCodice As Object

    <Display(Name:="Unità Operativa Descrizione")>
    Public UnitaOperativaDescr As Object

    <Display(Name:="Unità Operativa Sub Codice")>
    Public UnitaOperativaSubCodice As Object

    <Display(Name:="Fse Abilitato", AutoGenerateFilter:=False)>
    Public FseAbilitato As Object


End Class


<ScaffoldTable(True)>
<MetadataType(GetType(RepartiRichiedentiMetadata))>
<DisplayName("DwhConnSole3/Reparti Richiedenti")>
<TableName("DwhConnSole3-RepartiRichiedenti")>
Partial Public Class RepartiRichiedenti

End Class


Public Class RepartiRichiedentiMetadata
    '[TipoErogante]
    '[AziendaErogante]
    '[SistemaErogante]
    '[RepartoRichiedenteCodice]
    '[RepartoRichiedenteTipo]
    '[IstitutoCodice]
    '[PercorsoCarceri]
    '[PercorsoSert]

    <Display(Name:="Tipo Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=1)>
    Public TipoErogante As Object

    <Display(Name:="Tipo Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=1)>
    Public RepartiRichiedentiTipiEroganti As Object

    <Display(Name:="Azienda Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=1)>
    Public AziendaErogante As Object

    <Display(Name:="Azienda Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=1)>
    Public RepartiRichiedentiAziendeEroganti As Object

    <Display(Name:="Sistema Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=2)>
    Public SistemaErogante As Object

    <Display(Name:="Sistema Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=2)>
    Public RepartiRichiedentiSistemiEroganti As Object

    '<UIHint("ValuesList", Nothing, "ValueList", "Referto,Evento")>
    <Display(Name:=" Reparto Codice", AutoGenerateFilter:=True, AutoGenerateField:=True, Order:=3)>
    <FilterUIHint("Search")>
    Public RepartoRichiedenteCodice As Object

    <Display(Name:="Reparto Tipo", AutoGenerateFilter:=True, AutoGenerateField:=True, Order:=4)>
    <FilterUIHint("Search")>
    Public RepartoRichiedenteTipo As Object

    <Display(Name:="Istituto Codice", AutoGenerateFilter:=True, AutoGenerateField:=True, Order:=4)>
    <FilterUIHint("Search")>
    Public IstitutoCodice As Object

    <Display(Name:="Percorso Carceri", AutoGenerateFilter:=True, AutoGenerateField:=True, Order:=4)>
    <FilterUIHint("Boolean")>
    Public PercorsoCarceri As Object

    <Display(Name:="Percorso Sert", AutoGenerateFilter:=True, AutoGenerateField:=True, Order:=4)>
    <FilterUIHint("Boolean")>
    Public PercorsoSert As Object

End Class


