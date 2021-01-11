Imports System.ComponentModel

<ScaffoldTable(True)>
<MetadataType(GetType(TranscodificaCUPMetadata))>
<DisplayName("OeConnVna/Transcodifica CUP")>
<TableName("OeConnVna-TranscodificaCUP")>
<ExcelImport>
Partial Public Class TranscodificaCUP
End Class

<ScaffoldTable(True)>
<MetadataType(GetType(TranscodificaAltriSistemiMetadata))>
<DisplayName("OeConnVna/Trascodifica Altri Sistemi")>
<TableName("OeConnVna-TrascodificaAltriSistemi")>
<ExcelImport>
Partial Public Class TranscodificaAltriSistemi
End Class

<ScaffoldTable(True)>
<MetadataType(GetType(FiltriPrestazioniMetadata))>
<DisplayName("OeConnVna/Filtri Prestazioni")>
<TableName("OeConnVna-FiltriPrestazioni")>
<ExcelImport>
Partial Public Class FiltriPrestazioni
End Class

Public Class FiltriPrestazioniMetadata
    <Display(Name:="Id", Order:=1)>
    Public Id As Object

    <Display(Name:="Azienda", Order:=2)>
    <FilterUIHint("Search")>
    Public Azienda As Object

    <Display(Name:="Sistema", Order:=3)>
    <FilterUIHint("Search")>
    Public Sistema As Object

    <Display(Name:="Prestazione", Order:=4)>
    <FilterUIHint("Search")>
    Public Prestazione As Object

    <Display(Name:="Transcodifica", Order:=5)>
    <FilterUIHint("Search")>
    Public Transcodifica As Object
End Class

Public Class TranscodificaAltriSistemiMetadata
    <Display(Name:="Id", Order:=1)>
    Public Id As Object

    <Display(Name:="Sistema Richiedente Azienda", Order:=2)>
    <FilterUIHint("Search")>
    Public SistemaRichiedenteAzienda As Object

    <Display(Name:="Sistema Richiedente Codice", Order:=3)>
    <FilterUIHint("Search")>
    Public SistemaRichiedenteCodice As Object

    <Display(Name:="Uo Richiedente Azienda", Order:=4)>
    <FilterUIHint("Search")>
    Public UoRichiedenteAzienda As Object

    <Display(Name:="Uo Richiedente Codice", Order:=5)>
    <FilterUIHint("Search")>
    Public UoRichiedenteCodice As Object

    <Display(Name:="Transcodifica", Order:=6)>
    <FilterUIHint("Search")>
    Public Transcodifica As Object
End Class

Public Class TranscodificaCUPMetadata
    <Display(Name:="Id", Order:=1)>
    Public Id As Object

    <Display(Name:="Codice Agenda", Order:=2)>
    <FilterUIHint("Search")>
    Public CodiceAgenda As Object

    <Display(Name:="Transcodifica", Order:=3)>
    <FilterUIHint("Search")>
    Public Transcodifica As Object
End Class


