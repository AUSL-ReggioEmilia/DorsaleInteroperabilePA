Imports System.ComponentModel

<ScaffoldTable(True)>
<MetadataType(GetType(LhaAgendeMetaData))>
<DisplayName("Connettori/CupConnLHA")>
<TableName("LhaAgende")>
<ExcelImport>
Partial Public Class LhaAgende

End Class

Public Class LhaAgendeMetaData

    <Display(Name:="IdAgenda", Order:=1)>
    Public IDAGENDA As Object

    <Display(Name:="CodiceMnemonico", Order:=2)>
    Public CODICEMNEMONICO As Object

    <Display(Name:="CodiceAziendale", Order:=3)>
    Public CODICEAZIENDALE As Object

    <Display(Name:="Descrizione", Order:=4)>
    Public DESCRIZIONE As Object

    <Display(Name:="IdStrutturaErogante", Order:=5, AutoGenerateField:=False)>
    Public IDSTRUTTURAEROGANTE As Object

    ',[CODICEMNEMONICOSTREROGANTE]
    ',[CODICEAZIENDALESTREROGANTE]
    ',[IDSPECIALITA]
    ',[IDTIPOAGENDA]
    ',[GENERAZIONEFINOAL]
    ',[DATAAPERTURA]
    ',[DATACHIUSURA]
    ',[IDCONTROLLO]
    ',[CONTROLLOFORZABILE]
    ',[IDZONAGEOGRAFICA]
    ',[IDPROGRESSIVOMODIFICA]
    ',[INSERIMENTOUTENTE]
    ',[INSERIMENTODATA]
    ',[INSERIMENTOFONTE]
    ',[MODIFICADATA]
    ',[MODIFICAUTENTE]
    ',[MODIFICAFONTE]

End Class