Imports System.IO
Imports System.Text
Imports System.Runtime.Serialization

Imports OE.Core
Imports Msg = OE.Core.Schemas.Msg

#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
'Versione 1.2
Imports Wcf = OE.Core.Schemas.Wcf12
#Else
'Versione 1.0 e 1.1
Imports Wcf = OE.Core.Schemas.Wcf
#End If

<Assembly: System.Runtime.Serialization.ContractNamespaceAttribute("http://schemas.progel.it/OE/RichiestaFault/1.1", ClrNamespace:="RichiestaFault")> 
Public Class RichiestaFault
    Implements IFault

    Public Sub New()
    End Sub

    Public Sub New(ByVal procedure As String, ByVal ex As Exception, token As Wcf.WsTypes.TokenAccessoType, ordine As Wcf.WsTypes.OrdineType)

        Me.Procedura = procedure
        Me.Errore = ex.Message
        Me.Sistema = "Wcf"

        If token IsNot Nothing Then

            Me.Utente = token.Utente

            If ordine IsNot Nothing Then

                Me.DataOperazione = ordine.Data

                ' Valorizzo a String.Empty per evitare errori di serializzazione
                If ordine.SistemaRichiedente.Azienda.Codice Is Nothing Then ordine.SistemaRichiedente.Azienda.Codice = String.Empty
                If ordine.SistemaRichiedente.Sistema.Codice Is Nothing Then ordine.SistemaRichiedente.Sistema.Codice = String.Empty

                Me.SistemaRichiedente = New Msg.QueueTypes.SistemaType() With {
                    .Azienda = New Msg.QueueTypes.CodiceDescrizioneType() With {.Codice = ordine.SistemaRichiedente.Azienda.Codice},
                    .Sistema = New Msg.QueueTypes.CodiceDescrizioneType() With {.Codice = ordine.SistemaRichiedente.Sistema.Codice}
                }

                Me.IdRichiestaRichiedente = ordine.IdRichiestaRichiedente
                Me.DataRichiesta = ordine.DataRichiesta
            End If
        End If
    End Sub

    Public Sub New(ByVal procedure As String, ByVal ex As Exception, ByVal messaggio As Msg.RichiestaParameterTypes.RichiestaParameter)

        Me.Procedura = procedure
        Me.Errore = ex.Message
        Me.Sistema = "Msg"

        If messaggio IsNot Nothing AndAlso messaggio.RichiestaQueue IsNot Nothing Then

            Me.Utente = messaggio.RichiestaQueue.Utente
            Me.DataOperazione = messaggio.RichiestaQueue.DataOperazione
            Me.UnitaOperativaRichiedente = messaggio.RichiestaQueue.Testata.UnitaOperativaRichiedente
            Me.SistemaRichiedente = messaggio.RichiestaQueue.Testata.SistemaRichiedente
            Me.IdRichiestaRichiedente = messaggio.RichiestaQueue.Testata.IdRichiestaRichiedente
            Me.DataRichiesta = messaggio.RichiestaQueue.Testata.DataRichiesta
        End If
    End Sub

    <DataMemberAttribute(IsRequired:=False, EmitDefaultValue:=False)>
    Public Sistema As String

    <DataMemberAttribute(IsRequired:=False, EmitDefaultValue:=False)>
    Public Utente As String

    <DataMemberAttribute(IsRequired:=False, EmitDefaultValue:=False)>
    Public DataOperazione As Nullable(Of DateTime)

    <DataMemberAttribute(IsRequired:=False, EmitDefaultValue:=False)>
    Public UnitaOperativaRichiedente As Msg.QueueTypes.StrutturaType

    <DataMemberAttribute(IsRequired:=False, EmitDefaultValue:=False)>
    Public SistemaRichiedente As Msg.QueueTypes.SistemaType

    <DataMemberAttribute(IsRequired:=False, EmitDefaultValue:=False)>
    Public IdRichiestaRichiedente As String

    <DataMemberAttribute(IsRequired:=False, EmitDefaultValue:=False)>
    Public DataRichiesta As DateTime

    <DataMemberAttribute(IsRequired:=False, EmitDefaultValue:=False)>
    Public Procedura As String

    <DataMemberAttribute(IsRequired:=False, EmitDefaultValue:=False)>
    Public Errore As String

End Class