Imports System.IO
Imports System.Text
Imports System.Runtime.Serialization

Imports OE.Core
Imports Msg = OE.Core.Schemas.Msg

<Assembly: System.Runtime.Serialization.ContractNamespaceAttribute("http://schemas.progel.it/OE/StatoFault/1.1", ClrNamespace:="StatoFault")> 
Public Class StatoFault
    Implements IFault

    Public Sub New()
    End Sub

    Public Sub New(ByVal procedure As String, ByVal ex As Exception, ByVal messaggio As Msg.StatoParameterTypes.StatoParameter)
        Me.Procedura = procedure
        Me.Errore = ex.Message

        If messaggio IsNot Nothing AndAlso messaggio.StatoQueue IsNot Nothing Then
            Me.Utente = messaggio.StatoQueue.Utente
            Me.DataOperazione = messaggio.StatoQueue.DataOperazione
            Me.SistemaErogante = messaggio.StatoQueue.Testata.SistemaErogante
        End If

        Me.Source = ex.Source
        Me.StackTrace = ex.StackTrace
    End Sub

    <DataMemberAttribute(IsRequired:=False, EmitDefaultValue:=False)>
    Public Utente As String

    <DataMemberAttribute(IsRequired:=False, EmitDefaultValue:=False)>
    Public DataOperazione As Nullable(Of DateTime)

    <DataMemberAttribute(IsRequired:=False, EmitDefaultValue:=False)>
    Public SistemaErogante As Msg.QueueTypes.SistemaType

    <DataMemberAttribute(IsRequired:=False, EmitDefaultValue:=False)>
    Public Procedura As String

    <DataMemberAttribute(IsRequired:=False, EmitDefaultValue:=False)>
    Public Errore As String

    <DataMemberAttribute(IsRequired:=False, EmitDefaultValue:=False)>
    Public Source As String

    <DataMemberAttribute(IsRequired:=False, EmitDefaultValue:=False)>
    Public StackTrace As String

End Class