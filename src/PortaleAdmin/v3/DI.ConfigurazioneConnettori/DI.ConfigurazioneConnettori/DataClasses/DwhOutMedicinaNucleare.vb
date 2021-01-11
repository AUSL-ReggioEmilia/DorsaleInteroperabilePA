Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel

<ScaffoldTable(True)>
<MetadataType(GetType(PazientiDaMonitorareMetadata))>
<DisplayName("DwhOutMedicinaNucleare/Pazienti Da Monitorare")>
<TableName("DwhOutMedicinaNucleare-PazientiDaMonitorare")>
Partial Public Class PazientiDaMonitorare
End Class

Public Class PazientiDaMonitorareMetadata
	'[Id] [uniqueidentifier] Not NULL CONSTRAINT [DF_PazientiDaMonitorare_Id]  Default (newid()),
	'[Cognome] [varchar](100) Not NULL,
	'[Nome] [varchar](100) Not NULL,
	'[DataNascita] [datetime] Not NULL,
	'[DataInizioMonitoraggio] [datetime] NULL,
	'[DataFineMonitoraggio] [datetime] NULL,

	<ScaffoldColumn(False)>
	Public Id As Object

    <FilterUIHint("Search")>
    Public Cognome As Object

    <FilterUIHint("Search")>
    Public Nome As Object

	<DisplayFormat(DataFormatString:="{0:d}", ApplyFormatInEditMode:=True)>
	<Display(Name:="Data di Nascita")>
	<FilterUIHint("DateFilter")>
	Public DataNascita As Object

	<Display(Name:="Data Inizio Monitoraggio")>
	<DisplayFormat(DataFormatString:="{0:g}", ApplyFormatInEditMode:=True)>
	Public DataInizioMonitoraggio As Object

	<Display(Name:="Data Fine Monitoraggio")>
	<DisplayFormat(DataFormatString:="{0:g}", ApplyFormatInEditMode:=True)>
	Public DataFineMonitoraggio As Object


End Class



<ScaffoldTable(True)>
<MetadataType(GetType(PrestazioniDaMonitorareMetadata))>
<DisplayName("DwhOutMedicinaNucleare/Prestazioni Da Monitorare")>
<TableName("DwhOutMedicinaNucleare-PrestazioniDaMonitorare")>
Partial Public Class PrestazioniDaMonitorare
End Class

Public Class PrestazioniDaMonitorareMetadata
    '[Codice] [varchar](12) Not NULL
    '[Descrizione] [varchar](150) Not NULL,

    <FilterUIHint("Search")>
    Public Codice As Object

    <FilterUIHint("Search")>
    Public Descrizione As Object
End Class
