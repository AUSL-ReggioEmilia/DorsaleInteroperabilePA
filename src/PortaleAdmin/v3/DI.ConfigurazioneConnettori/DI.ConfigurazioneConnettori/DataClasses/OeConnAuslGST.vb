Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel
Namespace OeConnAuslGST

    <ScaffoldTable(True)>
    <MetadataType(GetType(TranscodificaAttributiPrestazioniGstMetaforaMetadata))>
    <DisplayName("OeConnAuslGst/Transcodifica Attributi Prestazioni Gst Metafora")>
    <TableName("OeConnAuslGst-TranscodificaAttributiPrestazioniGstMetafora")>
    <ExcelImport>
    Partial Public Class TranscodificaAttributiPrestazioniGstMetafora
    End Class

    <ScaffoldTable(True)>
    <MetadataType(GetType(TranscodificaAttributiPrestazioniGstELCOMetadata))>
    <DisplayName("OeConnAuslGst/Transcodifica Attributi Prestazioni Gst ELCO")>
    <TableName("OeConnAuslGst-TranscodificaAttributiPrestazioniGstELCO")>
    <ExcelImport>
    Partial Public Class TranscodificaAttributiPrestazioniGstELCO
    End Class

    <TableName("OeConnAuslGst-TranscodificaAttributiPrestazioniGstELCOSistemiEroganti")>
    Public Class TranscodificaAttributiPrestazioniGstELCOSistemiEroganti

    End Class

    <TableName("OeConnAuslGst-TranscodificaAttributiPrestazioniGstELCONomi")>
    Public Class TranscodificaAttributiPrestazioniGstELCONomi

    End Class

    <TableName("OeConnAuslGst-TranscodificaAttributiPrestazioniGstELCOAziendeEroganti")>
    Public Class TranscodificaAttributiPrestazioniGstELCOAziendeEroganti

    End Class

    <TableName("OeConnAuslGst-TranscodificaAttributiPrestazioniGstMetaforaStruttureEroganti")>
    Public Class TranscodificaAttributiPrestazioniGstMetaforaStruttureEroganti

    End Class

    <TableName("OeConnAuslGst-TranscodificaAttributiPrestazioniGstMetaforaNomi")>
    Public Class TranscodificaAttributiPrestazioniGstMetaforaNomi

    End Class


    Public Class TranscodificaAttributiPrestazioniGstELCOMetadata
        '[SistemaErogante] [varchar](64) Not NULL,
        '[IdPrestazioneGst] [varchar](16) Not NULL,
        '[IdPrestazioneRis] [varchar](16) Not NULL,
        '[Nome] [varchar](64) Not NULL CONSTRAINT [DF_TranscodificaAttributiPrestazioniGstELCO_Nome]  Default (''),
        '[Codice] [varchar](64) Not NULL CONSTRAINT [DF_TranscodificaAttributiPrestazioniGstELCO_Codice]  Default (''),
        '[Posizione] [int] Not NULL CONSTRAINT [DF_TranscodificaAttributiPrestazioniGstELCO_Posizione]  Default ((0)),
        '[Descrizione] [varchar](128) NULL,
        '[TipoDato] [varchar](16) NULL,
        '[TipoContenuto] [tinyint] NULL,
        '[AziendaErogante] [varchar](64) NULL,


        <Display(Name:="Sistema Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=1)>
        Public SistemaErogante As Object

        <Display(Name:="Sistema Erogante", Order:=1, AutoGenerateFilter:=True, AutoGenerateField:=False)>
        Public TranscodificaAttributiPrestazioniGstELCOSistemiEroganti As Object

        <Display(Name:="Id Prestazione Gst", Order:=2)>
        <FilterUIHint("Search")>
        Public IdPrestazioneGst As Object

        <Display(Name:="Id Prestazione Ris", Order:=3)>
        <FilterUIHint("Search")>
        Public IdPrestazioneRis As Object

        <Display(Order:=4)>
        <FilterUIHint("Search")>
        <Required(AllowEmptyStrings:=True)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
        <DisplayFormat(ConvertEmptyStringToNull:=False)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
        Public Codice As Object

        <Display(AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=5)>
        <Required(AllowEmptyStrings:=True)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
        <DisplayFormat(ConvertEmptyStringToNull:=False)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
        Public Nome As Object

        <Display(Name:="Nome", Order:=5, AutoGenerateFilter:=True, AutoGenerateField:=False)>
        Public TranscodificaAttributiPrestazioniGstELCONomi As Object

        <Display(Order:=6)>
        <FilterUIHint("Search")>
        Public Descrizione As Object

        <Display(Name:="Tipo Dato")>
        Public TipoDato As Object

        <UIHint("Integer")>
        <Range(1, 3, ErrorMessage:="Tipo Contenuto, valori possibili: 1=Multiprelievo; 2=Materiale; 3=Sede")>
        <Display(Name:="Tipo Contenuto")>
        Public TipoContenuto As Object

        <Display(Name:="Azienda Erogante", Order:=7, AutoGenerateFilter:=False, AutoGenerateField:=True)>
        Public AziendaErogante As Object

        <Display(Name:="Azienda Erogante", Order:=7, AutoGenerateFilter:=True, AutoGenerateField:=False)>
        Public TranscodificaAttributiPrestazioniGstELCOAziendeEroganti As Object

    End Class

    Public Class TranscodificaAttributiPrestazioniGstMetaforaMetadata
        '[StrutturaErogante] [varchar](64) Not NULL,
        '[IdPrestazioneGst] [varchar](16) Not NULL,
        '[IdPrestazioneLis] [varchar](16) Not NULL,
        '[Nome] [varchar](64) Not NULL CONSTRAINT [DF_TranscodificaAttributiPrestazioniGstMetafora_Nome]  Default (''),
        '[Codice] [varchar](64) Not NULL CONSTRAINT [DF_TranscodificaAttributiPrestazioniGstMetafora_Codice]  Default (''),
        '[Posizione] [int] Not NULL CONSTRAINT [DF_TranscodificaAttributiPrestazioniGstMetafora_Posizione]  Default ((0)),
        '[Descrizione] [varchar](128) NULL,
        '[TipoDato] [varchar](16) NULL,
        '[TipoContenuto] [tinyint] NULL,

        <Display(Name:="Struttura Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=1)>
        Public StrutturaErogante As Object

        <Display(Name:="Struttura Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=1)>
        Public TranscodificaAttributiPrestazioniGstMetaforaStruttureEroganti As Object

        <Display(Name:="Id Prestazione Gst", Order:=2)>
        <FilterUIHint("Search")>
        Public IdPrestazioneGst As Object

        <Display(Name:="Id Prestazione Lis", Order:=3)>
        <FilterUIHint("Search")>
        Public IdPrestazioneLis As Object

        <Display(Order:=4)>
        <FilterUIHint("Search")>
        <Required(AllowEmptyStrings:=True)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
        <DisplayFormat(ConvertEmptyStringToNull:=False)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
        Public Codice As Object

        <Display(Name:="Nome", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=5)>
        <Required(AllowEmptyStrings:=True)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
        <DisplayFormat(ConvertEmptyStringToNull:=False)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
        Public Nome As Object

        <Display(Name:="Nome", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=5)>
        Public TranscodificaAttributiPrestazioniGstMetaforaNomi As Object

        <Display(Order:=6)>
        <FilterUIHint("Search")>
        Public Descrizione As Object

        <Display(Name:="Tipo Dato")>
        Public TipoDato As Object

        <UIHint("Integer")>
        <Range(1, 3, ErrorMessage:="Tipo Contenuto, valori possibili: 1=Multiprelievo; 2=Materiale; 3=Sede")>
        <Display(Name:="Tipo Contenuto")>
        Public TipoContenuto As Object

    End Class

End Namespace

