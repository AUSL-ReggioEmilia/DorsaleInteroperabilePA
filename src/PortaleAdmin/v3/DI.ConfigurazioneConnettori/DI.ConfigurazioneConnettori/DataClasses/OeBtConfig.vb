Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel


<ScaffoldTable(True)>
<MetadataType(GetType(TipoOperazioneOsuMetadata))>
<DisplayName("OeBtConfig/Tipo Operazione Osu")>
<TableName("OeBtConfig-TipoOperazioneOsu")>
Partial Public Class TipoOperazioneOsu

End Class

Public Class TipoOperazioneOsuMetadata
    <Display(AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=1)>
    Public Azienda As Object

    <Display(Name:="Azienda", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=1)>
    Public TipoOperazioneOsuAziende As Object

    <Display(AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=2)>
    Public Sistema As Object

    <Display(Name:="Sistema", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=2)>
    Public TipoOperazioneOsuSistemi As Object

    <Display(Name:="Tipo Operazione", Order:=3)>
    Public TipoOperazione As Object

End Class

