Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel


<ScaffoldTable(True)>
<MetadataType(GetType(OeConnAnthema_CentriRichiedentiMetadata))>
<DisplayName("OeConnAnthema/Centri Richiedenti")>
<TableName("OeConnAnthema-CentriRichiedenti")>
Partial Public Class OeConnAnthema_CentriRichiedenti
End Class

Public Class OeConnAnthema_CentriRichiedentiMetadata
	'[Nome] [varchar](64) Not NULL,
	'[Descrizione] [varchar](128) NULL,
	'[Codice] [varchar](64) Not NULL,
	'[PuntoPrelievo] [varchar](64) Not NULL,
	'[CodiceLIS] [varchar](64) Not NULL,
	'[AziendaErogante] [varchar](16) Not NULL,
	'[SistemaErogante] [varchar](16) Not NULL,
	'[AziendaRichiedente] [varchar](16) Not NULL,
	'[SistemaRichiedente] [varchar](16) Not NULL,
	'[PCInvioRichiesta] [varchar](64) Not NULL,

	<Display(Order:=4)>
	<FilterUIHint("Search")>
	Public Nome As Object

	<Display(Order:=3)>
	<FilterUIHint("Search")>
	Public Codice As Object

	<Display(Name:="Punto Prelievo")>
	Public PuntoPrelievo As Object

	<Display(Name:="Codice LIS", Order:=5)>
	<FilterUIHint("Search")>
	Public CodiceLIS As Object

	<Display(Name:="Azienda Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=1)>
	Public AziendaErogante As Object

	<Display(Name:="Azienda Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=1)>
	Public CentriRichiedentiAziendeEroganti As Object

	<Display(Name:="Sistema Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=2)>
	Public SistemaErogante As Object

	<Display(Name:="Sistema Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=2)>
	Public CentriRichiedentiSistemiEroganti As Object

	<Display(Name:="Azienda Richiedente")>
	Public AziendaRichiedente As Object

	<Display(Name:="Sistema Richiedente")>
	Public SistemaRichiedente As Object

	<Display(Name:="PC Invio Richiesta")>
	Public PCInvioRichiesta As Object

End Class




<ScaffoldTable(True)>
<MetadataType(GetType(TranscodificaAttributiPrestazioniAnthemaMetaforaMetadata))>
<DisplayName("OeConnAnthema/Transcodifica Attributi Prestazioni Anthema-Metafora")>
<TableName("OeConnAnthema-TranscodificaAttributiPrestazioniAnthemaMetafora")>
Partial Public Class TranscodificaAttributiPrestazioniAnthemaMetafora
End Class

Public Class TranscodificaAttributiPrestazioniAnthemaMetaforaMetadata

	'[StrutturaErogante] [varchar](64) Not NULL,
	'[IdPrestazioneAnthema] [varchar](16) Not NULL,
	'[IdPrestazioneLis] [varchar](16) Not NULL,
	'[Nome] [varchar](64) Not NULL CONSTRAINT [DF_TranscodificaAttributiPrestazioniAnthemaMetafora_Nome]  Default (''),
	'[Codice] [varchar](64) Not NULL CONSTRAINT [DF_TranscodificaAttributiPrestazioniAnthemaMetafora_Codice]  Default (''),
	'[Posizione] [int] Not NULL CONSTRAINT [DF_TranscodificaAttributiPrestazioniAnthemaMetafora_Posizione]  Default ((0)),
	'[Descrizione] [varchar](128) NULL,
	'[TipoDato] [varchar](16) NULL,
	'[TipoContenuto] [tinyint] NULL,  (1 = Multiprelievo; 2 = Materiale; 3 = Sede)

	<Display(Order:=1)>
	Public Codice As Object

    <Display(Name:="Struttura Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=2)>
    Public StrutturaErogante As Object

    <Display(Name:="Struttura Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=2)>
    Public TranscodificaAttributiPrestazioniAnthemaMetaforaStruttureEroganti As Object

    <Display(Name:="Id Prestazione Anthema", Order:=3)>
    <FilterUIHint("Search")>
    Public IdPrestazioneAnthema As Object

    <Display(Name:="Id Prestazione Lis", Order:=4)>
    <FilterUIHint("Search")>
    Public IdPrestazioneLis As Object

    <Display(AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=5)>
    Public Nome As Object

    <Display(Name:="Nome", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=5)>
    Public TranscodificaAttributiPrestazioniAnthemaMetaforaNomi As Object

    <Display(Order:=6)>
    <FilterUIHint("Search")>
    Public Descrizione As Object

    <Display(Name:="Tipo Dato")>
	Public TipoDato As Object

	<Display(Name:="Tipo Contenuto")>
	<UIHint("Integer")>
	<Range(1, 3, ErrorMessage:="Tipo Contenuto, valori possibili: 1=Multiprelievo; 2=Materiale; 3=Sede")>
	Public TipoContenuto As Object

End Class



<ScaffoldTable(True)>
<MetadataType(GetType(TranscodificaAttributiPrestazioniMetaforaAnthemaMetadata))>
<DisplayName("OeConnAnthema/Transcodifica Attributi Prestazioni Metafora-Anthema")>
<TableName("OeConnAnthema-TranscodificaAttributiPrestazioniMetaforaAnthema")>
Partial Public Class TranscodificaAttributiPrestazioniMetaforaAnthema
End Class

Public Class TranscodificaAttributiPrestazioniMetaforaAnthemaMetadata

	'[StrutturaErogante] [varchar](64) Not NULL,
	'[IdPrestazioneAnthema] [varchar](16) Not NULL,
	'[IdPrestazioneLis] [varchar](16) Not NULL,
	'[Nome] [varchar](64) Not NULL CONSTRAINT [DF_TranscodificaAttributiPrestazioniAnthemaMetafora_Nome]  Default (''),
	'[Codice] [varchar](64) Not NULL CONSTRAINT [DF_TranscodificaAttributiPrestazioniAnthemaMetafora_Codice]  Default (''),
	'[Posizione] [int] Not NULL CONSTRAINT [DF_TranscodificaAttributiPrestazioniAnthemaMetafora_Posizione]  Default ((0)),
	'[Descrizione] [varchar](128) NULL,
	'[TipoDato] [varchar](16) NULL,
	'[TipoContenuto] [tinyint] NULL,  (1 = Multiprelievo; 2 = Materiale; 3 = Sede)

	<Display(Order:=1)>
	Public Codice As Object

	<Display(Name:="Struttura Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=2)>
	Public StrutturaErogante As Object

	<Display(Name:="Struttura Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=2)>
    Public TranscodificaAttributiPrestazioniMetaforaAnthemaStrutturaErogante As Object

    <Display(Name:="Id Prestazione Anthema", Order:=3)>
    <FilterUIHint("Search")>
    Public IdPrestazioneAnthema As Object

    <Display(Name:="Id Prestazione Lis", Order:=4)>
    <FilterUIHint("Search")>
    Public IdPrestazioneLis As Object

    <Display(AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=5)>
    Public Nome As Object

    <Display(Name:="Nome", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=5)>
    Public TranscodificaAttributiPrestazioniMetaforaAnthemaNomi As Object

    <Display(Order:=6)>
    <FilterUIHint("Search")>
    Public Descrizione As Object

    <Display(Name:="Tipo Dato")>
    Public TipoDato As Object

    <Display(Name:="Tipo Contenuto")>
	<UIHint("Integer")>
	<Range(1, 3, ErrorMessage:="Tipo Contenuto, valori possibili: 1=Multiprelievo; 2=Materiale; 3=Sede")>
	Public TipoContenuto As Object

End Class


