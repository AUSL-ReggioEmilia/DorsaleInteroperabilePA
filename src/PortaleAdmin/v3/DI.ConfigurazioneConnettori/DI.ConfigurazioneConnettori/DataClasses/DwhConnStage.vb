Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel


<ScaffoldTable(True)>
<MetadataType(GetType(AdtSpecchioTranscodificheCodiciRepartoMetadata))>
<DisplayName("DwhConnStage/Adt Specchio Transcodifiche Codici Reparto")>
<TableName("DwhConnStage-AdtSpecchioTranscodificheCodiciReparto")>
<ExcelImport>
Partial Public Class AdtSpecchioTranscodificheCodiciReparto
End Class

Public Class AdtSpecchioTranscodificheCodiciRepartoMetadata
    <Display(AutoGenerateFilter:=False, AutoGenerateField:=True, Name:="Azienda Provenienza", Order:=1)>
    Public AziendaProvenienza As Object

    <Display(AutoGenerateFilter:=True, AutoGenerateField:=False, Name:="Azienda Provenienza", Order:=1)>
    Public AdtSpecchioTranscodificheCodiciRepartoAziendeProvenienza As Object

    <Display(Name:="Codice Reparto Provenienza", Order:=2)>
    <FilterUIHint("Search")>
    Public CodiceRepartoProvenienza As Object

    <Display(AutoGenerateFilter:=False, AutoGenerateField:=True, Name:="Azienda Destinazione", Order:=3)>
    Public AziendaDestinazione As Object

    <Display(AutoGenerateFilter:=True, AutoGenerateField:=False, Name:="Azienda Destinazione", Order:=3)>
    Public AdtSpecchioTranscodificheCodiciRepartoAziendeDestinazione As Object

    <Display(Name:="Codice Reparto Destinazione", Order:=4)>
    <FilterUIHint("Search")>
    Public CodiceRepartoDestinazione As Object


End Class
