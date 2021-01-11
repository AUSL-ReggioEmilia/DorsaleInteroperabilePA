Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel


<ScaffoldTable(True)>
<MetadataType(GetType(RichiesteAgendeAbilitateMetadata))>
<DisplayName("OeConnARTEXE/Richieste Agende Abilitate")>
<TableName("OeConnARTEXE-RichiesteAgendeAbilitate")>
<ExcelImport>
Partial Public Class RichiesteAgendeAbilitate

End Class

Public Class RichiesteAgendeAbilitateMetadata

    <FilterUIHint("Search")>
    Public Codice As Object

    <FilterUIHint("Search")>
    Public Descrizione As Object
End Class

