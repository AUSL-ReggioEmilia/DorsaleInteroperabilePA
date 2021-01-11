Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel
Imports System.Data.Linq

<ScaffoldTable(True)>
<MetadataType(GetType(CentriRichiedentiMetadata))>
<DisplayName("DwhConnAnthema/Centri Richiedenti")>
<TableName("DwhConnAnthema-CentriRichiedenti")>
Partial Public Class CentriRichiedenti
End Class

Public Class CentriRichiedentiMetadata
	'[Nome]
	'[Descrizione]
	'[Codice]
	'[PuntoPrelievo]
	'[CodiceLIS]
	'[AziendaErogante]
	'[SistemaErogante]
	'[AziendaRichiedente]
	'[SistemaRichiedente]
	'[PCInvioRichiesta]
	'[RepartoErogante]
	'[SezioneErogante]
	'[SpecialitaErogante]

	<Display(Order:=1)>
	Public Codice As Object

	<Display(Name:="Punto Prelievo", Order:=2)>
	Public PuntoPrelievo As Object

	<Display(Order:=3)>
	Public Nome As Object

	<Display(Order:=4)>
	Public Descrizione As Object

	<Display(Name:="Azienda Richiedente", Order:=5)>
	Public AziendaRichiedente As Object

	<Display(Name:="Sistema Richiedente", Order:=6)>
	Public SistemaRichiedente As Object

	<Display(Name:="Codice LIS", Order:=7)>
	Public CodiceLIS As Object

	<Display(Name:="PC Invio Richiesta", Order:=8)>
	Public PCInvioRichiesta As Object

	<Display(Name:="Azienda Erogante")>
	Public AziendaErogante As Object

	<Display(Name:="Sistema Erogante")>
	Public SistemaErogante As Object

	<Display(Name:="Reparto Erogante")>
	Public RepartoErogante As Object

	<Display(Name:="Sezione Erogante")>
	Public SezioneErogante As Object

	<Display(Name:="Specialità Erogante")>
	Public SpecialitaErogante As Object


End Class
