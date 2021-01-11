Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel

Partial Public Class DwhConnFileRefertoInputDataContext
End Class

<ScaffoldTable(True)>
<MetadataType(GetType(fri_SistemiErogantiMetadata))>
<DisplayName("DwhConnFileRefertoInput/Sistemi Eroganti")>
<TableName("DwhConnFileRefertoInput-SistemiEroganti")>
Partial Public Class fri_SistemiEroganti
End Class


Public Class fri_SistemiErogantiMetadata
    '[Azienda]
    '[Sistema]
    '[PrefissoIdEsterno]
    '[StiveVisualizzazione]

    <Display(AutoGenerateFilter:=False, AutoGenerateField:=True)>
    Public Azienda As Object

    '<FilterUIHint("MultiForeignKey")>
    <Display(Name:="Azienda", AutoGenerateFilter:=True, AutoGenerateField:=False)>
    Public SistemiEroganti_Aziende As Object

    <Display(AutoGenerateFilter:=False, AutoGenerateField:=True)>
    Public Sistema As Object

    <Display(Name:="Sistema", AutoGenerateFilter:=True, AutoGenerateField:=False)>
    Public SistemiEroganti_Sistemi As Object

    <Display(Name:="Stile Visualizzazione")>
    Public StiveVisualizzazione As Object

    <Display(Name:="Prefisso Id Esterno")>
    Public PrefissoIdEsterno As Object

    <Display(Name:="Ordine Invio")>
    Public OrdineInvio As Object

    <Display(Name:="Max Size MB")>
    Public MaxSizeMB As Object

End Class
