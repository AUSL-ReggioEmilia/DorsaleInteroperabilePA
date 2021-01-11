Imports System.Xml
Imports OE.Core

<Serializable()>
<CLSCompliant(True)>
Public MustInherit Class MessaggioBase(Of T, U)

    Public Sub New()
    End Sub

    Public MustOverride Function ProcessaMessaggio(ByVal messaggio As T, ByVal settings As ConfigurationSettings) As U
    Public MustOverride Function ProcessaXmlDocument(ByVal messaggio As XmlDocument, ByVal settings As ConfigurationSettings) As XmlDocument

End Class