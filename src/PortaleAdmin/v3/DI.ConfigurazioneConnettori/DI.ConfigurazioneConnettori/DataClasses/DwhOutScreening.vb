Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel


<ScaffoldTable(True)>
<MetadataType(GetType(FiltriMammografiaMetadata))>
<DisplayName("DwhOutScreening/Filtri Mammografia")>
<TableName("DwhOutScreening-FiltriMammografia")>
Partial Public Class FiltriMammografia

End Class

Public Class FiltriMammografiaMetadata
	'[AziendaErogante]
	'[SistemaErogante]
	'[PrestazioneCodice]

	<Display(Name:="Azienda Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=1)>
	Public AziendaErogante As Object

	<Display(Name:="Azienda Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=1)>
    Public FiltriMammografiaAziendeEroganti As Object

	<Display(Name:="Sistema Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=2)>
	Public SistemaErogante As Object

	<Display(Name:="Sistema Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=2)>
    Public FiltriMammografiaSistemiEroganti As Object

    <Display(Name:="Codice Prestazione", Order:=3)>
    <FilterUIHint("Search")>
    Public PrestazioneCodice As Object
End Class

