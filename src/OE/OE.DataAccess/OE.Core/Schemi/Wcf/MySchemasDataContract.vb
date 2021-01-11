Imports System.Runtime.Serialization


#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
'Versione 1.2
Namespace Schemas.Wcf12.BaseTypes
#Else
'Versione 1.0 e 1.1
Namespace Schemas.Wcf.BaseTypes
#End If

    <System.CodeDom.Compiler.GeneratedCodeAttribute("System.Runtime.Serialization", "4.0.0.0"), _
     System.Runtime.Serialization.DataContractAttribute(Name:="TipoAccessoEnum", [Namespace]:="http://schemas.progel.it/OE/Types/1.1")> _
    Public Enum TipoAccessoEnum As Integer

        ''' <summary>
        ''' Lettura
        ''' </summary>
        <System.Runtime.Serialization.EnumMemberAttribute()> _
        R

        ''' <summary>
        ''' Inserimento/Modifica
        ''' </summary>
        <System.Runtime.Serialization.EnumMemberAttribute()> _
        I

        ''' <summary>
        ''' Inoltro/Cancellazione
        ''' </summary>
        <System.Runtime.Serialization.EnumMemberAttribute()> _
        S
    End Enum


    Public Class SistemaType
        Implements IEquatable(Of SistemaType)

        Public Overloads Function Equals(
            ByVal other As SistemaType
            ) As Boolean Implements IEquatable(Of SistemaType).Equals

            ' Check whether the compared object is null.
            If other Is Nothing Then Return False

            ' Check whether the compared object references the same data.
            If Me Is other Then Return True

            ' Check whether properties are equal.
            Return Me.Azienda.Codice.Equals(other.Azienda.Codice) AndAlso Me.Sistema.Codice.Equals(other.Sistema.Codice)
        End Function

        Public Overrides Function GetHashCode() As Integer

            Dim hashAziendaCodice = Me.Azienda.Codice.GetHashCode
            Dim hashSistemaCodice = Me.Sistema.Codice.GetHashCode

            ' Calculate the hash code for the product.
            Return hashAziendaCodice Xor hashSistemaCodice
        End Function
    End Class

    Public Class StrutturaType
        Implements IEquatable(Of StrutturaType)

        Public Overloads Function Equals(
            ByVal other As StrutturaType
            ) As Boolean Implements IEquatable(Of StrutturaType).Equals

            ' Check whether the compared object is null.
            If other Is Nothing Then Return False

            ' Check whether the compared object references the same data.
            If Me Is other Then Return True

            ' Check whether properties are equal.
            Return Me.Azienda.Codice.Equals(other.Azienda.Codice) AndAlso Me.UnitaOperativa.Codice.Equals(other.UnitaOperativa.Codice)
        End Function

        Public Overrides Function GetHashCode() As Integer

            Dim hashAziendaCodice = Me.Azienda.Codice.GetHashCode
            Dim hashUnitaOperativaCodice = Me.UnitaOperativa.Codice.GetHashCode

            ' Calculate the hash code for the product.
            Return hashAziendaCodice Xor hashUnitaOperativaCodice
        End Function

        Public Function Clone() As StrutturaType
            '
            ' Crea una nuova istanza della classe
            '
            Dim newStruttura As New StrutturaType
            newStruttura.Azienda = New CodiceDescrizioneType With {.Codice = Me.Azienda.Codice, _
                                                                   .Descrizione = Me.Azienda.Descrizione}
            newStruttura.UnitaOperativa = New CodiceDescrizioneType With {.Codice = Me.UnitaOperativa.Codice, _
                                                                          .Descrizione = Me.UnitaOperativa.Descrizione}

            Return newStruttura

        End Function

        Public Function CopyFrom(ByRef source As StrutturaType) As StrutturaType
            '
            ' Copia l'istanza della classe
            '
            Me.Azienda.Codice = source.Azienda.Codice
            Me.Azienda.Descrizione = source.Azienda.Descrizione

            Me.UnitaOperativa.Codice = source.UnitaOperativa.Codice
            Me.UnitaOperativa.Descrizione = source.UnitaOperativa.Descrizione

            Return Me
        End Function

    End Class

End Namespace

#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
'Versione 1.2
Namespace Schemas.Wcf12.WsTypes
#Else
'Versione 1.0 e 1.1
Namespace Schemas.Wcf.WsTypes
#End If

    Partial Public Class DatoAccessorioType
        '
        ' Estendo lo schema per dei dati interni non pubblicati del WS
        '
        Public internal_DiSistema As Boolean
        Public internal_NomeDatoAggiuntivo As String
        Public internal_ConcatenaNomeUguale As Boolean
        Public internal_IdPrestazione As Guid

        Public internal_ValoriDinamiciAbilita As Boolean
        Public internal_ValoriDinamiciParametri As String

    End Class

    Partial Public Class DatoAccessorioValoreType
        '
        ' Estendo lo schema per dei dati interni non pubblicati del WS
        '
        Public internal_Ordinamento As Integer
    End Class

    Partial Public Class DatoNomeValoreType
        '
        ' Estendo lo schema per dei dati interni non pubblicati del WS
        '
        Public internal_Xml As XElement
    End Class

End Namespace
