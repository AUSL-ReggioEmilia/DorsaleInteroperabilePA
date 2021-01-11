Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel
Namespace OeConnAsmnGST


    <ScaffoldTable(True)>
    <MetadataType(GetType(TranscodificaAttributiPrestazioniGstELCOMetadata))>
    <DisplayName("OeConnAsmnGst/Transcodifica Attributi Prestazioni Gst ELCO")>
    <TableName("OeConnAsmnGst-TranscodificaAttributiPrestazioniGstELCO")>
    <ExcelImport>
    Partial Public Class TranscodificaAttributiPrestazioniGstELCO
    End Class

    <ScaffoldTable(True)>
    <MetadataType(GetType(TranscodificaAttributiPrestazioniGstMetaforaMetadata))>
    <DisplayName("OeConnAsmnGst/Transcodifica Attributi Prestazioni Gst Metafora")>
    <TableName("OeConnAsmnGst-TranscodificaAttributiPrestazioniGstMetafora")>
    <ExcelImport>
    Partial Public Class TranscodificaAttributiPrestazioniGstMetafora
    End Class

    <TableName("OeConnAsmnGst-TranscodificaAttributiPrestazioniGstELCOSistemiEroganti")>
    Public Class TranscodificaAttributiPrestazioniGstELCOSistemiEroganti

    End Class
    <TableName("OeConnAsmnGst-TranscodificaAttributiPrestazioniGstELCONomi")>
    Public Class TranscodificaAttributiPrestazioniGstELCONomi

    End Class

    <TableName("OeConnAsmnGst-TranscodificaAttributiPrestazioniGstELCOAziendeEroganti")>
    Public Class TranscodificaAttributiPrestazioniGstELCOAziendeEroganti

    End Class

    <TableName("OeConnAsmnGst-TranscodificaAttributiPrestazioniGstMetaforaStruttureEroganti")>
    Public Class TranscodificaAttributiPrestazioniGstMetaforaStruttureEroganti

    End Class

    <TableName("OeConnAsmnGst-TranscodificaAttributiPrestazioniGstMetaforaNomi")>
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

        <Display(Name:="Sistema Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=1)>
        Public TranscodificaAttributiPrestazioniGstELCOSistemiEroganti As Object

        <Display(Name:="Id Prestazione Gst", Order:=2)>
        <FilterUIHint("Search")>
        Public IdPrestazioneGst As Object

        <Display(Name:="Id Prestazione Ris", Order:=3)>
        <FilterUIHint("Search")>
        Public IdPrestazioneRis As Object

        <Display(Order:=5, AutoGenerateFilter:=False, AutoGenerateField:=True)>
        <Required(AllowEmptyStrings:=True)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
        <DisplayFormat(ConvertEmptyStringToNull:=False)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
        Public Nome As Object

        <Display(Name:="Nome", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=5)>
        Public TranscodificaAttributiPrestazioniGstELCONomi As Object

        <Display(Order:=4)>
        <FilterUIHint("Search")>
        <Required(AllowEmptyStrings:=True)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
        <DisplayFormat(ConvertEmptyStringToNull:=False)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
        Public Codice As Object

        <Display(Order:=6)>
        <FilterUIHint("Search")>
        Public Descrizione As Object

        <Display(Name:="Tipo Dato")>
        Public TipoDato As Object

        <UIHint("Integer")>
        <Range(1, 3, ErrorMessage:="Tipo Contenuto, valori possibili: 1=Multiprelievo; 2=Materiale; 3=Sede")>
        <Display(Name:="Tipo Contenuto")>
        Public TipoContenuto As Object

        <Display(Name:="Azienda Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=7)>
        Public AziendaErogante As Object

        <Display(Name:="Azienda Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=7)>
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

        <Display(Name:="Struttura Erogante", Order:=1, AutoGenerateFilter:=False, AutoGenerateField:=True)>
        Public StrutturaErogante As Object

        <Display(Name:="Struttura Erogante", Order:=1, AutoGenerateFilter:=True, AutoGenerateField:=False)>
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

        <Display(Order:=5, AutoGenerateFilter:=False, AutoGenerateField:=True)>
        <Required(AllowEmptyStrings:=True)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
        <DisplayFormat(ConvertEmptyStringToNull:=False)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
        Public Nome As Object

        <Display(Name:="Nome", Order:=5, AutoGenerateFilter:=True, AutoGenerateField:=False)>
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
