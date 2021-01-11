Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel
Imports System.Data.Linq

<ScaffoldTable(True)>
<MetadataType(GetType(SistemiAbilitatiMetadata))>
<DisplayName("DwhClinicoMMG/Sistemi Abilitati")>
<TableName("DwhClinicoMMG-SistemiAbilitati")>
<ExcelImport>
Partial Public Class SistemiAbilitati
End Class


Public Class SistemiAbilitatiMetadata
    ' [Id]
    ' [SistemaErogante]
    ' [SpecialitaErogante]

    <Display(Order:=1)>
    Public Id As Object

    <Display(Name:="Sistema Erogante", Order:=2, AutoGenerateField:=True, AutoGenerateFilter:=True)>
    <FilterUIHint("Search")>
    Public SistemaErogante As Object

    <Display(Name:="Specialità Erogante", Order:=3, AutoGenerateField:=True, AutoGenerateFilter:=True)>
    <FilterUIHint("Search")>
    Public SpecialitaErogante As Object
End Class
