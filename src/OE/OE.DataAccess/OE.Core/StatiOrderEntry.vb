<Serializable()>
Public NotInheritable Class StatiOrderEntry
    Private Sub New()
    End Sub

    ''' <summary>
    ''' Stato order entry della risposta (ACK)
    ''' </summary>
    Public Enum Risposta As Byte
        ''' <summary>
        ''' Richiesta accettata dall'erogante
        ''' </summary>
        AA = 1

        ''' <summary>
        ''' Richiesta errata dall'erogante
        ''' </summary>
        AE = 2

        ''' <summary>
        ''' Richiesta rifiutata dall'erogante
        ''' </summary>
        AR = 3

        ''' <summary>
        ''' Richiesta accettata con stato esteso (etichette) dall'erogante
        ''' </summary>
        SE = 4

        Unknown = Byte.MaxValue
    End Enum

End Class

Public NotInheritable Class SottoStatiOrderEntry
    Private Sub New()
    End Sub

    ''' <summary>
    ''' Sotto-Stato order della richiesta
    ''' </summary>
    Public Enum TestataRichiesta As Byte
        ''' <summary>
        ''' In inserimento
        ''' </summary>
        INS_00 = 1

        ''' <summary>
        ''' Inserito
        ''' </summary>
        INS_10 = 2

        ''' <summary>
        ''' In inoltro
        ''' </summary>
        INO_00 = 3

        ''' <summary>
        ''' Inoltrato
        ''' </summary>
        INO_10 = 4

        ''' <summary>
        ''' Inoltro errato
        ''' </summary>
        INO_20 = 5

        ''' <summary>
        ''' Inoltro fallito
        ''' </summary>
        INO_21 = 6

        Unknown = Byte.MaxValue
    End Enum

    ''' <summary>
    ''' Sotto-Stato order entry dello stato
    ''' </summary>
    Public Enum TestataStato As Byte
        ''' <summary>
        ''' In arrivo
        ''' </summary>
        ARR_00 = 1

        ''' <summary>
        ''' Arrivato
        ''' </summary>
        ARR_10 = 2

        ''' <summary>
        ''' In aggiornamento
        ''' </summary>
        UPD_00 = 3

        ''' <summary>
        ''' Aggiornato
        ''' </summary>
        UPD_10 = 4

        Unknown = Byte.MaxValue
    End Enum

End Class
