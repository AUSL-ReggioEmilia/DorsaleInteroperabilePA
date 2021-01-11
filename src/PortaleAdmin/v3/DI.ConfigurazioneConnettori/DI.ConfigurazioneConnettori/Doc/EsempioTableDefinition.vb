Imports Microsoft.VisualBasic
Imports System.ComponentModel.DataAnnotations

'How to: Customize Data Field Validation in the Data Model
'https://msdn.microsoft.com/en-us/library/cc488527(v=vs.140).aspx

'http://www.hanselman.com/blog/ASPNETWebFormsDynamicDataFieldTemplatesForDbGeographySpatialTypesPlusModelBindersAndFriendlyURLs.aspx

'http://www.codeproject.com/Articles/626455/CurionLib-Dynamic-Data-Entry-Forms

'creazione di Atributi di Validazione
'https://msdn.microsoft.com/en-us/library/cc668224.aspx

<ScaffoldTable(True)> _
<MetadataType(GetType(GerarchieMetadata))> _
Partial Public Class Gerarchie

End Class

Public Class GerarchieMetadata

	'CAMPO NASCOSTO
	<ScaffoldColumn(False)>
	Public Path As Object

	'FORMATO DATA
	<DisplayFormat(DataFormatString:="{0:d}")>
	Public DataCreazione As Object

	'DISPLAY NAME E ORDINAMENTO
	<Display(Name:="PC Invio Richiesta", Order:=8)>
	Public PCInvioRichiesta As Object

	'CONTROLLO EDIT MULTILINE TEXTBOX
	<UIHint("MultilineText")>
	Public Nome As Object

	'CAMPO NON EDITABILE
	<Editable(False)>
	Public PCInvioRichiesta As Object

	'NASCONDO IL FILTRO DI RICERCA NELLA PAGINA LISTA
	<Display(AutoGenerateFilter:=False)>
	Public IncludiPrenotatiCup As Boolean

	'CAMPO OBBLIGATORIO (QUANDO NON LO È GIÀ SU DB)
	<Required(AllowEmptyStrings:=False, ErrorMessage:="Campo Descrizione obbligatorio")>
	Public Descrizione As Object

	'CAMPO INTEGER CON CONTROLLO DI INTERVALLO
	<UIHint("Integer")>
	<Range(10, 50, ErrorMessage:="Inserire in valore compreso fra 10 e 50")>
	Public ScreenSize As Object

	'CAMPO CON DROPDOWN CON VALORI ARBITRARI
	<UIHint("ValuesList", Nothing, "ValueList", "Referto,Evento")>
	Public TipoErogante As Object

	'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
	<Required(AllowEmptyStrings:=True)>
	<DisplayFormat(ConvertEmptyStringToNull:=False)>
	Public TipoErogante As Object

End Class

