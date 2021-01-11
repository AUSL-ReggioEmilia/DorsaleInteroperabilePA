Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel


<ScaffoldTable(True)>
<MetadataType(GetType(FiltriRepartiRichiedentiMetadata))>
<DisplayName("DwhOutDSA/Filtri Reparti Richiedenti")>
<TableName("DwhOutDSA-FiltriRepartiRichiedenti")>
Partial Public Class FiltriRepartiRichiedenti

End Class

Public Class FiltriRepartiRichiedentiMetadata
    '[CodiceReparto]
    '[Tipologia]

    <Display(Name:="Codice Reparto")>
    <FilterUIHint("Search")>
    Public CodiceReparto As Object

    <Display(AutoGenerateFilter:=False, AutoGenerateField:=True)>
    Public Tipologia As Object

    <Display(Name:="Tipologia", AutoGenerateFilter:=True, AutoGenerateField:=False)>
    Public FiltriRepartiRichiedentiTipologie As Object

End Class

