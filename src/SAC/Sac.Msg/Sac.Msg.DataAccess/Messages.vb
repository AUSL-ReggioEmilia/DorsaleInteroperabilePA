Imports System.Reflection
Imports System.Xml.Serialization
Imports System.Text

Public Class GenericSerialize(Of T)

    <CLSCompliant(False)> _
    Public Shared Function Deserialize(ByVal XmlData As String) As T

        Try
            Using memStream As New IO.MemoryStream
                Dim oEnc As Encoding = Encoding.UTF8

                memStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
                memStream.Position = 0

                Dim oInstance As T

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
                oInstance = CType(oSerializer.Deserialize(memStream), T)

                Return oInstance
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

        End Try

    End Function

    <CLSCompliant(False)> _
    Public Shared Function Serialize(ByVal oInstance As T) As String
        '
        ' Serializzo
        '
        Try
            Using memStream As New IO.MemoryStream

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
                oSerializer.Serialize(memStream, oInstance)

                Dim oEnc As Encoding = Encoding.UTF8
                Dim sXml As String = oEnc.GetString(memStream.ToArray())

                Return sXml
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)

        End Try

    End Function

    <CLSCompliant(False)> _
    Public Shared Function Deserialize(ByVal InputStream As IO.Stream) As T

        Try
            Dim oInstance As T

            Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
            InputStream.Position = 0
            oInstance = CType(oSerializer.Deserialize(InputStream), T)

            Return oInstance

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

        End Try
    End Function

    <CLSCompliant(False)> _
    Public Shared Sub Serialize(ByVal Instance As T, ByVal OutputStream As IO.Stream)
        '
        ' Serializzo
        '
        Try
            Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(T))
            oSerializer.Serialize(OutputStream, Instance)
            OutputStream.Position = 0

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)

        End Try

    End Sub

    Public Shared Function StreamToString(ByVal memStream As IO.MemoryStream) As String

        Dim oEnc As Encoding = Encoding.UTF8
        Return oEnc.GetString(memStream.ToArray())

    End Function

    Public Shared Function ReadDataRow(ByVal Sorgente As Data.DataRow, ByVal Destinazione As T) As T

        Dim oType As Type = GetType(T)
        Dim dcRow As Data.DataColumn

        For Each dcRow In Sorgente.Table.Columns
            Dim sName As String = dcRow.ColumnName
            '
            ' Cerco se c'è nella destinazione
            '
            Dim oFieldInfo As FieldInfo = Nothing
            Try
                oFieldInfo = oType.GetField(sName, BindingFlags.NonPublic Or _
                                                    BindingFlags.Instance Or _
                                                    BindingFlags.Public)
            Catch ex As Exception
                oFieldInfo = Nothing
            End Try
            If oFieldInfo IsNot Nothing Then
                '
                ' Leggo la sorgente
                '
                Dim oValue = Sorgente.Item(sName)
                '
                ' Scrivo nella destinazione
                '
                Try
                    If oValue IsNot DBNull.Value Then
                        oFieldInfo.SetValue(Destinazione, oValue, BindingFlags.Instance, Nothing, Nothing)
                    Else
                        oFieldInfo.SetValue(Destinazione, Nothing, BindingFlags.Instance, Nothing, Nothing)
                    End If
                Catch ex As Exception
                    '
                    ' Errore
                    '
                    Throw New ApplicationException("Errore in GenericSerialize(Of T).ReadDataRow() durante SetValue() destinazione! " & ex.Message)
                End Try
            End If
        Next

        Return Destinazione

    End Function

End Class

#Region "Paziente"

<Serializable()> _
Public Class PazienteHL7
    Public Id As String
    Public Provenienza As String
    Public IdProvenienza As String
    Public Tessera As String
    Public Cognome As String
    Public Nome As String
    Public DataNascita As Global.System.Nullable(Of Date)
    Public Sesso As String
    Public CodiceFiscale As String
    Public ComuneNascitaCodice As String
    Public ComuneNascitaNome As String
    Public NazionalitaCodice As String
    Public NazionalitaNome As String
    Public IndirizzoRes As String
    Public LocalitaRes As String
    Public CapRes As String
    Public ComuneResCodice As String
    Public ComuneResNome As String
    Public IndirizzoDom As String
    Public LocalitaDom As String
    Public CapDom As String
    Public ComuneDomCodice As String
    Public ComuneDomNome As String
    Public Telefono1 As String
    Public Telefono2 As String

    ' Predisposizione allo standard quindi attualmente non valorizzati
    Public CognomeMadreNubile As String
    Public NomeMadreNubile As String
    Public StatoCivile As String
    Public Religione As String
    Public GruppoEtnico As String
    Public Cittadinanza As String
    Public DataDecesso As Global.System.Nullable(Of Date)

    Public Sinonimi() As PazienteSinonimo

    Public Sub New()
    End Sub

    Public Sub New(ByVal Id As String, _
                ByVal Provenienza As String, _
                ByVal IdProvenienza As String, _
                ByVal Tessera As String, _
                ByVal Cognome As String, _
                ByVal Nome As String, _
                ByVal DataNascita As Global.System.Nullable(Of Date), _
                ByVal Sesso As String, _
                ByVal CodiceFiscale As String, _
                ByVal ComuneNascitaCodice As String, _
                ByVal ComuneNascitaNome As String, _
                ByVal NazionalitaCodice As String, _
                ByVal NazionalitaNome As String, _
                ByVal IndirizzoRes As String, _
                ByVal LocalitaRes As String, _
                ByVal CapRes As String, _
                ByVal ComuneResCodice As String, _
                ByVal ComuneResNome As String, _
                ByVal IndirizzoDom As String, _
                ByVal LocalitaDom As String, _
                ByVal CapDom As String, _
                ByVal ComuneDomCodice As String, _
                ByVal ComuneDomNome As String, _
                ByVal Telefono1 As String, _
                ByVal Telefono2 As String, _
                ByVal CognomeMadreNubile As String, _
                ByVal NomeMadreNubile As String, _
                ByVal StatoCivile As String, _
                ByVal Religione As String, _
                ByVal GruppoEtnico As String, _
                ByVal Cittadinanza As String, _
                ByVal DataDecesso As Global.System.Nullable(Of Date), _
                ByVal Sinonimi() As PazienteSinonimo)
        '
        ' Modifica Ettore 2013-01-29: mi assicuro che la stringa che rappresenta il GUID del paziente sia formatta in maiuscolo
        '
        If String.IsNullOrEmpty(Id) Then
            Me.Id = Id
        Else
            Me.Id = Id.ToUpper()
        End If
        Me.Provenienza = Provenienza
        Me.IdProvenienza = IdProvenienza
        Me.Tessera = Tessera
        Me.Cognome = Cognome
        Me.Nome = Nome
        Me.DataNascita = DataNascita
        Me.Sesso = Sesso
        Me.CodiceFiscale = CodiceFiscale
        Me.ComuneNascitaCodice = ComuneNascitaCodice
        Me.ComuneNascitaNome = ComuneNascitaNome
        Me.NazionalitaCodice = NazionalitaCodice
        Me.IndirizzoRes = IndirizzoRes
        Me.LocalitaRes = LocalitaRes
        Me.CapRes = CapRes
        Me.NazionalitaNome = NazionalitaNome
        Me.ComuneResCodice = ComuneResCodice
        Me.IndirizzoDom = IndirizzoDom
        Me.LocalitaDom = LocalitaDom
        Me.CapDom = CapDom
        Me.ComuneDomCodice = ComuneDomCodice
        Me.ComuneDomNome = ComuneDomNome
        Me.Telefono1 = Telefono1
        Me.Telefono2 = Telefono2
        Me.CognomeMadreNubile = CognomeMadreNubile
        Me.NomeMadreNubile = NomeMadreNubile
        Me.StatoCivile = StatoCivile
        Me.Religione = Religione
        Me.GruppoEtnico = GruppoEtnico
        Me.Cittadinanza = Cittadinanza
        Me.DataDecesso = DataDecesso
        Me.Sinonimi = Sinonimi
    End Sub

End Class

'2020-05-08 ATTENZIONE: i campi ComuneAslAssCodice e ComuneAslResCodice sono stati erroneamente aggiunti alla classe paziente
'e non vengono popolati dal messaggio LHA
<Serializable()>
Public Class Paziente
    Public Provenienza As String
    Public Id As String
    Public Tessera As String
    Public Cognome As String
    Public Nome As String
    Public DataNascita As Global.System.Nullable(Of Date)
    Public Sesso As String
    Public ComuneNascitaCodice As String
    Public ComuneNascitaNome As String
    Public NazionalitaCodice As String
    Public NazionalitaNome As String
    Public CodiceFiscale As String
    Public DatiAnamnestici As String
    Public MantenimentoPediatra As Global.System.Nullable(Of Boolean)
    Public CapoFamiglia As Global.System.Nullable(Of Boolean)
    Public Indigenza As Global.System.Nullable(Of Boolean)
    Public CodiceTerminazione As String
    Public DescrizioneTerminazione As String
    Public ComuneResCodice As String
    Public ComuneResNome As String
    Public SubComuneRes As String
    Public IndirizzoRes As String
    Public LocalitaRes As String
    Public CapRes As String
    Public DataDecorrenzaRes As Global.System.Nullable(Of Date)
    Public ComuneAslResCodice As String
    Public CodiceAslRes As String
    Public AslResNome As String
    Public RegioneResCodice As String
    Public RegioneResNome As String
    Public ComuneDomCodice As String
    Public ComuneDomNome As String
    Public SubComuneDom As String
    Public IndirizzoDom As String
    Public LocalitaDom As String
    Public CapDom As String
    Public PosizioneAss As Global.System.Nullable(Of Byte)
    Public RegioneAssCodice As String
    Public RegioneAssNome As String
    Public ComuneAslAssCodice As String
    Public CodiceAslAss As String
    Public AslAssNome As String
    Public DataInizioAss As Global.System.Nullable(Of Date)
    Public DataScadenzaAss As Global.System.Nullable(Of Date)
    Public DataTerminazioneAss As Global.System.Nullable(Of Date)
    Public DistrettoAmm As String
    Public DistrettoTer As String
    Public Ambito As String
    Public CodiceMedicoDiBase As Global.System.Nullable(Of Integer)
    Public CodiceFiscaleMedicoDiBase As String
    Public CognomeNomeMedicoDiBase As String
    Public DistrettoMedicoDiBase As String
    Public DataSceltaMedicoDiBase As Global.System.Nullable(Of Date)
    Public ComuneRecapitoCodice As String
    Public ComuneRecapitoNome As String
    Public IndirizzoRecapito As String
    Public LocalitaRecapito As String
    Public Telefono1 As String
    Public Telefono2 As String
    Public Telefono3 As String
    Public CodiceSTP As String
    Public DataInizioSTP As Global.System.Nullable(Of Date)
    Public DataFineSTP As Global.System.Nullable(Of Date)
    Public MotivoAnnulloSTP As String
    'MODIFICA ETTORE WCF 2018-07-26: Per passare la striga XML degli attributi
    Public Attributi As String



    Public Sub New()
    End Sub

    'MODIFICA ETTORE WCF 2018-07-26: Per passare la striga XML degli attributi nel NEW
    Public Sub New(ByVal Id As String,
                    ByVal Tessera As String,
                    ByVal Cognome As String,
                    ByVal Nome As String,
                    ByVal DataNascita As Global.System.Nullable(Of Date),
                    ByVal Sesso As String,
                    ByVal ComuneNascitaCodice As String,
                    ByVal NazionalitaCodice As String,
                    ByVal CodiceFiscale As String,
                    ByVal DatiAnamnestici As String,
                    ByVal MantenimentoPediatra As Global.System.Nullable(Of Boolean),
                    ByVal CapoFamiglia As Global.System.Nullable(Of Boolean),
                    ByVal Indigenza As Global.System.Nullable(Of Boolean),
                    ByVal CodiceTerminazione As String,
                    ByVal DescrizioneTerminazione As String,
                    ByVal ComuneResCodice As String,
                    ByVal SubComuneRes As String,
                    ByVal IndirizzoRes As String,
                    ByVal LocalitaRes As String,
                    ByVal CapRes As String,
                    ByVal DataDecorrenzaRes As Global.System.Nullable(Of Date),
                    ByVal ComuneAslResCodice As String,
                    ByVal CodiceAslRes As String,
                    ByVal RegioneResCodice As String,
                    ByVal ComuneDomCodice As String,
                    ByVal SubComuneDom As String,
                    ByVal IndirizzoDom As String,
                    ByVal LocalitaDom As String,
                    ByVal CapDom As String,
                    ByVal PosizioneAss As Global.System.Nullable(Of Byte),
                    ByVal RegioneAssCodice As String,
                    ByVal ComuneAslAssCodice As String,
                    ByVal CodiceAslAss As String,
                    ByVal DataInizioAss As Global.System.Nullable(Of Date),
                    ByVal DataScadenzaAss As Global.System.Nullable(Of Date),
                    ByVal DataTerminazioneAss As Global.System.Nullable(Of Date),
                    ByVal DistrettoAmm As String,
                    ByVal DistrettoTer As String,
                    ByVal Ambito As String,
                    ByVal CodiceMedicoDiBase As Global.System.Nullable(Of Integer),
                    ByVal CodiceFiscaleMedicoDiBase As String,
                    ByVal CognomeNomeMedicoDiBase As String,
                    ByVal DistrettoMedicoDiBase As String,
                    ByVal DataSceltaMedicoDiBase As Global.System.Nullable(Of Date),
                    ByVal ComuneRecapitoCodice As String,
                    ByVal IndirizzoRecapito As String,
                    ByVal LocalitaRecapito As String,
                    ByVal Telefono1 As String,
                    ByVal Telefono2 As String,
                    ByVal Telefono3 As String,
                    ByVal CodiceSTP As String,
                    ByVal DataInizioSTP As Global.System.Nullable(Of Date),
                    ByVal DataFineSTP As Global.System.Nullable(Of Date),
                    ByVal MotivoAnnulloSTP As String,
                    ByVal Attributi As String)

        Me.Id = Id
        Me.Tessera = Tessera
        Me.Cognome = Cognome
        Me.Nome = Nome
        Me.DataNascita = DataNascita
        Me.Sesso = Sesso
        Me.ComuneNascitaCodice = ComuneNascitaCodice
        Me.NazionalitaCodice = NazionalitaCodice
        Me.CodiceFiscale = CodiceFiscale
        Me.DatiAnamnestici = DatiAnamnestici
        Me.MantenimentoPediatra = MantenimentoPediatra
        Me.CapoFamiglia = CapoFamiglia
        Me.Indigenza = Indigenza
        Me.CodiceTerminazione = CodiceTerminazione
        Me.DescrizioneTerminazione = DescrizioneTerminazione
        Me.ComuneResCodice = ComuneResCodice
        Me.SubComuneRes = SubComuneRes
        Me.IndirizzoRes = IndirizzoRes
        Me.LocalitaRes = LocalitaRes
        Me.CapRes = CapRes
        Me.DataDecorrenzaRes = DataDecorrenzaRes
        Me.ComuneAslResCodice = ComuneAslResCodice
        Me.CodiceAslRes = CodiceAslRes
        Me.RegioneResCodice = RegioneResCodice
        Me.ComuneDomCodice = ComuneDomCodice
        Me.SubComuneDom = SubComuneDom
        Me.IndirizzoDom = IndirizzoDom
        Me.LocalitaDom = LocalitaDom
        Me.CapDom = CapDom
        Me.PosizioneAss = PosizioneAss
        Me.RegioneAssCodice = RegioneAssCodice
        Me.ComuneAslAssCodice = ComuneAslAssCodice
        Me.CodiceAslAss = CodiceAslAss
        Me.DataInizioAss = DataInizioAss
        Me.DataScadenzaAss = DataScadenzaAss
        Me.DataTerminazioneAss = DataTerminazioneAss
        Me.DistrettoAmm = DistrettoAmm
        Me.DistrettoTer = DistrettoTer
        Me.Ambito = Ambito
        Me.CodiceMedicoDiBase = CodiceMedicoDiBase
        Me.CodiceFiscaleMedicoDiBase = CodiceFiscaleMedicoDiBase
        Me.CognomeNomeMedicoDiBase = CognomeNomeMedicoDiBase
        Me.DistrettoMedicoDiBase = DistrettoMedicoDiBase
        Me.DataSceltaMedicoDiBase = DataSceltaMedicoDiBase
        Me.ComuneRecapitoCodice = ComuneRecapitoCodice
        Me.IndirizzoRecapito = IndirizzoRecapito
        Me.LocalitaRecapito = LocalitaRecapito
        Me.Telefono1 = Telefono1
        Me.Telefono2 = Telefono2
        Me.Telefono3 = Telefono3
        Me.CodiceSTP = CodiceSTP
        Me.DataInizioSTP = DataInizioSTP
        Me.DataFineSTP = DataFineSTP
        Me.MotivoAnnulloSTP = MotivoAnnulloSTP
        'MODIFICA ETTORE WCF 2018-07-26: Per passare la striga XML degli attributi nel NEW
        Me.Attributi = Attributi
    End Sub
End Class

<Serializable()> _
Public Class PazienteEsenzione
    Public CodiceEsenzione As String
    Public CodiceDiagnosi As String
    Public Patologica As Boolean
    Public DataInizioValidita As Global.System.Nullable(Of Date)
    Public DataFineValidita As Global.System.Nullable(Of Date)
    Public NumeroAutorizzazioneEsenzione As String
    Public NoteAggiuntive As String
    Public CodiceTestoEsenzione As String
    Public TestoEsenzione As String
    Public DecodificaEsenzioneDiagnosi As String
    Public AttributoEsenzioneDiagnosi As String

    Public Sub New()
    End Sub

    Public Sub New(ByVal CodiceEsenzione As String, _
                    ByVal CodiceDiagnosi As String, _
                    ByVal Patologica As Boolean, _
                    ByVal DataInizioValidita As Global.System.Nullable(Of Date), _
                    ByVal DataFineValidita As Global.System.Nullable(Of Date), _
                    ByVal NumeroAutorizzazioneEsenzione As String, _
                    ByVal NoteAggiuntive As String, _
                    ByVal CodiceTestoEsenzione As String, _
                    ByVal TestoEsenzione As String, _
                    ByVal DecodificaEsenzioneDiagnosi As String, _
                    ByVal AttributoEsenzioneDiagnosi As String)

        Me.CodiceEsenzione = CodiceEsenzione
        Me.CodiceDiagnosi = CodiceDiagnosi
        Me.Patologica = Patologica
        Me.DataInizioValidita = DataInizioValidita
        Me.DataFineValidita = DataFineValidita
        Me.NumeroAutorizzazioneEsenzione = NumeroAutorizzazioneEsenzione
        Me.NoteAggiuntive = NoteAggiuntive
        Me.CodiceTestoEsenzione = CodiceTestoEsenzione
        Me.TestoEsenzione = TestoEsenzione
        Me.DecodificaEsenzioneDiagnosi = DecodificaEsenzioneDiagnosi
        Me.AttributoEsenzioneDiagnosi = AttributoEsenzioneDiagnosi

    End Sub
End Class

<Serializable()> _
Public Class PazienteSinonimo
    Implements IEquatable(Of PazienteSinonimo)

    Public Provenienza As String
    Public Id As String

    Public Sub New()
    End Sub

    Public Sub New(ByVal Provenienza As String, _
                    ByVal Id As String)

        Me.Provenienza = Provenienza
        Me.Id = Id
    End Sub

    Public Overloads Function Equals(other As PazienteSinonimo) As Boolean Implements System.IEquatable(Of PazienteSinonimo).Equals
        If Me.Provenienza = other.Provenienza AndAlso Me.Id = other.Id Then
            Return True
        Else
            Return False
        End If
    End Function

End Class

<Serializable()> _
Public Class PazienteFusione
    Public Id As String
    Public Cognome As String
    Public Tessera As String
    Public Nome As String
    Public DataNascita As Global.System.Nullable(Of Date)
    Public Sesso As String
    Public ComuneNascitaCodice As String
    Public NazionalitaCodice As String
    Public CodiceFiscale As String

    Public Sub New()
    End Sub

    Public Sub New(ByVal Id As String, _
                    ByVal Tessera As String, _
                    ByVal Cognome As String, _
                    ByVal Nome As String, _
                    ByVal DataNascita As Global.System.Nullable(Of Date), _
                    ByVal Sesso As String, _
                    ByVal ComuneNascitaCodice As String, _
                    ByVal NazionalitaCodice As String, _
                    ByVal CodiceFiscale As String)

        Me.Id = Id
        Me.Tessera = Tessera
        Me.Cognome = Cognome
        Me.Nome = Nome
        Me.DataNascita = DataNascita
        Me.Sesso = Sesso
        Me.ComuneNascitaCodice = ComuneNascitaCodice
        Me.NazionalitaCodice = NazionalitaCodice
        Me.CodiceFiscale = CodiceFiscale

    End Sub
End Class

<Serializable()> _
<Xml.Serialization.XmlRoot("MessaggioPaziente")> _
Public Class MessaggioPaziente
    Public Utente As String
    Public DataSequenza As Date
    Public Paziente As Paziente

    <XmlElementAttribute("Esenzioni")> _
    Public Esenzioni() As PazienteEsenzione

    <XmlElementAttribute("Fusione")> _
    Public Fusione As PazienteFusione

    Public Sub New()
    End Sub

    Public Sub New(ByVal Utente As String, _
                ByVal DataSequenza As Date, _
                ByVal Paziente As Paziente)

        Me.Utente = Utente
        Me.DataSequenza = DataSequenza

        Me.Paziente = Paziente
    End Sub

    Public Sub New(ByVal Utente As String, _
                    ByVal DataSequenza As Date, _
                    ByVal Paziente As Paziente, _
                    ByVal Esenzioni() As PazienteEsenzione)

        Me.Utente = Utente
        Me.DataSequenza = DataSequenza

        Me.Paziente = Paziente
        Me.Esenzioni = Esenzioni
    End Sub

    Public Sub New(ByVal Utente As String, _
                ByVal DataSequenza As Date, _
                ByVal Paziente As Paziente, _
                ByVal Fusione As PazienteFusione)

        Me.Utente = Utente
        Me.DataSequenza = DataSequenza

        Me.Paziente = Paziente
        Me.Fusione = Fusione
    End Sub

    Public Sub New(ByVal Utente As String, _
                ByVal DataSequenza As Date, _
                ByVal Paziente As Paziente, _
                ByVal Esenzioni() As PazienteEsenzione, _
                ByVal Fusione As PazienteFusione)

        Me.Utente = Utente
        Me.DataSequenza = DataSequenza

        Me.Paziente = Paziente
        Me.Esenzioni = Esenzioni
        Me.Fusione = Fusione
    End Sub

    Public Shared Function Deserialize(ByVal XmlData As String) As MessaggioPaziente

        Try
            Using memStream As New IO.MemoryStream
                Dim oEnc As Encoding = Encoding.UTF8

                memStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
                memStream.Position = 0

                Dim oInstance As MessaggioPaziente

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(MessaggioPaziente))
                oInstance = CType(oSerializer.Deserialize(memStream), MessaggioPaziente)

                Return oInstance
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

        End Try

    End Function

    Public Shared Function Serialize(ByVal oInstance As MessaggioPaziente) As String
        '
        ' Serializzo
        '
        Try
            Using memStream As New IO.MemoryStream

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(MessaggioPaziente))
                oSerializer.Serialize(memStream, oInstance)

                Dim oEnc As Encoding = Encoding.UTF8
                Dim sXml As String = oEnc.GetString(memStream.ToArray())

                Return sXml
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)

        End Try

    End Function

End Class


'Risposta Paziente da usare con WCF
<Serializable()>
<Xml.Serialization.XmlRoot("RispostaPaziente")>
Public Class RispostaPaziente

    Public IdMessaggio As String
    Public DataSequenza As DateTime
    Public Azione As Integer '0=Inserimento, 1=Modifica, 2=Cancellazione, 3=Fusione (I valori del messaggio QueueOutput ver 2)

    Public Paziente As PazienteOut

    <XmlElementAttribute("Esenzioni")>
    Public Esenzioni() As PazienteEsenzioneOut

    <XmlElementAttribute("Sinonimi")>
    Public Sinonimi() As PazienteSinonimo

    <XmlElementAttribute("Consensi")>
    Public Consensi() As PazienteConsensoOut

    <XmlElementAttribute("PazienteFuso")>
    Public PazienteFuso As PazienteFusoOut

    Public Sub New()
    End Sub

    Public Sub New(ByVal IdMessaggio As String,
                   ByVal DataSequenza As DateTime,
                   ByVal Azione As Integer,
                   ByVal Paziente As PazienteOut,
                   ByVal Esenzioni() As PazienteEsenzioneOut,
                   ByVal Sinonimi() As PazienteSinonimo,
                   ByVal Consensi() As PazienteConsensoOut,
                   ByVal PazienteFuso As PazienteFusoOut
                   )
        If String.IsNullOrEmpty(IdMessaggio) Then
            Me.IdMessaggio = IdMessaggio
        Else
            Me.IdMessaggio = IdMessaggio.ToUpper()
        End If
        Me.DataSequenza = DataSequenza
        Me.Azione = Azione
        Me.Paziente = Paziente
        Me.Esenzioni = Esenzioni
        Me.Sinonimi = Sinonimi
        Me.Consensi = Consensi
        Me.PazienteFuso = PazienteFuso
    End Sub

    Public Shared Function Deserialize(ByVal XmlData As String) As RispostaPaziente

        Try
            Using memStream As New IO.MemoryStream
                Dim oEnc As Encoding = Encoding.UTF8

                memStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
                memStream.Position = 0

                Dim oInstance As RispostaPaziente

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RispostaPaziente))
                oInstance = CType(oSerializer.Deserialize(memStream), RispostaPaziente)

                Return oInstance
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

        End Try

    End Function

    Public Shared Function Serialize(ByVal oInstance As RispostaPaziente) As String
        '
        ' Serializzo
        '
        Try
            Using memStream As New IO.MemoryStream

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RispostaPaziente))
                oSerializer.Serialize(memStream, oInstance)

                Dim oEnc As Encoding = Encoding.UTF8
                Dim sXml As String = oEnc.GetString(memStream.ToArray())

                Return sXml
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)

        End Try

    End Function

End Class


<Serializable()>
Public Class RispostaDettaglioPaziente

    Public Id As String
    Public Paziente As Paziente

    <XmlElementAttribute("Esenzioni")>
    Public Esenzioni() As PazienteEsenzione

    <XmlElementAttribute("Sinonimi")>
    Public Sinonimi() As PazienteSinonimo

    Public Sub New()
    End Sub

    Public Sub New(ByVal Id As String,
                   ByVal Paziente As Paziente)
        '
        ' Modifica Ettore 2013-01-29: mi assicuro una stringa rappresentante un guid sia sempre formattata in maiuscolo
        ' Se Id è "" oppure nothing lo valorizzo con "" o nothing, altrimenti ne faccio il ToUpper()
        '
        If String.IsNullOrEmpty(Id) Then
            Me.Id = Id
        Else
            Me.Id = Id.ToUpper()
        End If
        Me.Paziente = Paziente
    End Sub

    Public Sub New(ByVal Id As String,
                   ByVal Paziente As Paziente,
                   ByVal Esenzioni() As PazienteEsenzione,
                   ByVal Sinonimi() As PazienteSinonimo)
        '
        ' Modifica Ettore 2013-01-29: mi assicuro una stringa rappresentante un guid sia sempre formattata in maiuscolo
        ' Se Id è "" oppure nothing lo valorizzo con "" o nothing, altrimenti ne faccio il ToUpper()
        '
        If String.IsNullOrEmpty(Id) Then
            Me.Id = Id
        Else
            Me.Id = Id.ToUpper()
        End If
        Me.Paziente = Paziente
        Me.Esenzioni = Esenzioni
        Me.Sinonimi = Sinonimi
    End Sub

    Public Shared Function Deserialize(ByVal XmlData As String) As RispostaDettaglioPaziente

        Try
            Using memStream As New IO.MemoryStream
                Dim oEnc As Encoding = Encoding.UTF8

                memStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
                memStream.Position = 0

                Dim oInstance As RispostaDettaglioPaziente

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RispostaDettaglioPaziente))
                oInstance = CType(oSerializer.Deserialize(memStream), RispostaDettaglioPaziente)

                Return oInstance
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

        End Try

    End Function

    Public Shared Function Serialize(ByVal oInstance As RispostaDettaglioPaziente) As String
        '
        ' Serializzo
        '
        Try
            Using memStream As New IO.MemoryStream

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RispostaDettaglioPaziente))
                oSerializer.Serialize(memStream, oInstance)

                Dim oEnc As Encoding = Encoding.UTF8
                Dim sXml As String = oEnc.GetString(memStream.ToArray())

                Return sXml
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)

        End Try

    End Function

End Class


<Serializable()> _
Public Class RispostaListaPazienti

    <XmlElementAttribute("Paziente")> _
    Public Pazienti() As PazienteHL7

    Public Sub New()
    End Sub

    Public Sub New(ByVal Pazienti() As PazienteHL7)
        Me.Pazienti = Pazienti
    End Sub

    Public Shared Function Deserialize(ByVal XmlData As String) As RispostaListaPazienti

        Try
            Using memStream As New IO.MemoryStream
                Dim oEnc As Encoding = Encoding.UTF8

                memStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
                memStream.Position = 0

                Dim oInstance As RispostaListaPazienti

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RispostaListaPazienti))
                oInstance = CType(oSerializer.Deserialize(memStream), RispostaListaPazienti)

                Return oInstance
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

        End Try

    End Function

    Public Shared Function Serialize(ByVal oInstance As RispostaListaPazienti) As String
        '
        ' Serializzo
        '
        Try
            Using memStream As New IO.MemoryStream

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RispostaListaPazienti))
                oSerializer.Serialize(memStream, oInstance)

                Dim oEnc As Encoding = Encoding.UTF8
                Dim sXml As String = oEnc.GetString(memStream.ToArray())

                Return sXml
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)

        End Try

    End Function

End Class

#End Region

#Region "Consenso"

<Serializable()> _
Public Class Consenso
    Public Id As String
    Public Tipo As String
    Public DataStato As Date
    Public Stato As Boolean
    Public OperatoreId As String
    Public OperatoreCognome As String
    Public OperatoreNome As String
    Public OperatoreComputer As String
    Public PazienteProvenienza As String
    Public PazienteIdProvenienza As String
    Public PazienteCognome As String
    Public PazienteNome As String
    Public PazienteCodiceFiscale As String
    Public PazienteDataNascita As Global.System.Nullable(Of Date)
    Public PazienteComuneNascitaCodice As String
    Public PazienteNazionalitaCodice As String
    Public PazienteTesseraSanitaria As String

    Public Sub New()
    End Sub

    'MODIFICA ETTORE 2018-08-06: aggiunto al New() il campo Id
    Public Sub New(ByVal Id As String,
                  ByVal Tipo As String,
                   ByVal DataStato As DateTime,
                   ByVal Stato As Boolean,
                   ByVal OperatoreId As String,
                   ByVal OperatoreCognome As String,
                   ByVal OperatoreNome As String,
                   ByVal OperatoreComputer As String,
                   ByVal PazienteProvenienza As String,
                   ByVal PazienteIdProvenienza As String,
                   ByVal PazienteCognome As String,
                   ByVal PazienteNome As String,
                   ByVal PazienteCodiceFiscale As String,
                   ByVal PazienteDataNascita As DateTime,
                   ByVal PazienteComuneNascitaCodice As String,
                   ByVal PazienteNazionalitaCodice As String,
                   ByVal PazienteTesseraSanitaria As String)
        Me.Id = Id
        Me.Tipo = Tipo
        Me.DataStato = DataStato
        Me.Stato = Stato
        Me.OperatoreId = OperatoreId
        Me.OperatoreCognome = OperatoreCognome
        Me.OperatoreNome = OperatoreNome
        Me.OperatoreComputer = OperatoreComputer
        Me.PazienteProvenienza = PazienteProvenienza
        Me.PazienteIdProvenienza = PazienteIdProvenienza
        Me.PazienteCognome = PazienteCognome
        Me.PazienteNome = PazienteNome
        Me.PazienteCodiceFiscale = PazienteCodiceFiscale
        Me.PazienteDataNascita = PazienteDataNascita
        Me.PazienteComuneNascitaCodice = PazienteComuneNascitaCodice
        Me.PazienteNazionalitaCodice = PazienteNazionalitaCodice
        Me.PazienteTesseraSanitaria = PazienteTesseraSanitaria
    End Sub

End Class




<Serializable()> _
<Xml.Serialization.XmlRoot("MessaggioConsenso")> _
Public Class MessaggioConsenso
    Public Utente As String
    Public Consenso As Consenso
    Public DataSequenza As Date

    Public Sub New()
    End Sub

    Public Sub New(ByVal Utente As String, _
                    ByVal DataSequenza As Date, _
                    ByVal Consenso As Consenso)

        Me.Utente = Utente
        Me.DataSequenza = DataSequenza

        Me.Consenso = Consenso
    End Sub

    Public Shared Function Deserialize(ByVal XmlData As String) As MessaggioConsenso

        Try
            Using memStream As New IO.MemoryStream
                Dim oEnc As Encoding = Encoding.UTF8

                memStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
                memStream.Position = 0

                Dim oInstance As MessaggioConsenso

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(MessaggioConsenso))
                oInstance = CType(oSerializer.Deserialize(memStream), MessaggioConsenso)

                Return oInstance
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

        End Try

    End Function

    Public Shared Function Serialize(ByVal oInstance As MessaggioConsenso) As String
        '
        ' Serializzo
        '
        Try
            Using memStream As New IO.MemoryStream

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(MessaggioConsenso))
                oSerializer.Serialize(memStream, oInstance)

                Dim oEnc As Encoding = Encoding.UTF8
                Dim sXml As String = oEnc.GetString(memStream.ToArray())

                Return sXml
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)

        End Try

    End Function

End Class

<Serializable()> _
<Xml.Serialization.XmlRoot("RispostaConsenso")> _
Public Class RispostaConsenso
    Public Id As String

    Public IdProvenienza As String

    Public Consenso As Consenso

    <XmlElementAttribute("IngressoAck")> _
    Public IngressoAck As IngressoAck

    <XmlElementAttribute("NotificheAck")> _
    Public NotificheAck() As NotificaAck

    Public Sub New()
    End Sub

    Public Sub New(ByVal Id As String, _
                   ByVal IdProvenienza As String, _
                   ByVal Consenso As Consenso, _
                   ByVal IngressoAck As IngressoAck, _
                   ByVal NotificheAck() As NotificaAck)

        Me.Id = Id
        Me.IdProvenienza = IdProvenienza
        Me.Consenso = Consenso
        Me.IngressoAck = IngressoAck
        Me.NotificheAck = NotificheAck
    End Sub

    Public Shared Function Deserialize(ByVal XmlData As String) As RispostaConsenso

        Try
            Using memStream As New IO.MemoryStream
                Dim oEnc As Encoding = Encoding.UTF8

                memStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
                memStream.Position = 0

                Dim oInstance As RispostaConsenso

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RispostaConsenso))
                oInstance = CType(oSerializer.Deserialize(memStream), RispostaConsenso)

                Return oInstance
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

        End Try

    End Function

    Public Shared Function Serialize(ByVal oInstance As RispostaConsenso) As String
        '
        ' Serializzo
        '
        Try
            Using memStream As New IO.MemoryStream

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RispostaConsenso))
                oSerializer.Serialize(memStream, oInstance)

                Dim oEnc As Encoding = Encoding.UTF8
                Dim sXml As String = oEnc.GetString(memStream.ToArray())

                Return sXml
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)

        End Try

    End Function

End Class

<Serializable()> _
Public Class RispostaDettaglioConsenso

    Public Id As String
    Public Consenso As Consenso

    Public Sub New()
    End Sub

    Public Sub New(ByVal Id As String)

        Me.Id = Id
        Me.Consenso = Consenso
    End Sub

    Public Sub New(ByVal Id As String, _
               ByVal Consenso As Consenso)

        Me.Id = Id
        Me.Consenso = Consenso
    End Sub

    Public Shared Function Deserialize(ByVal XmlData As String) As RispostaDettaglioConsenso

        Try
            Using memStream As New IO.MemoryStream
                Dim oEnc As Encoding = Encoding.UTF8

                memStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
                memStream.Position = 0

                Dim oInstance As RispostaDettaglioConsenso

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RispostaDettaglioConsenso))
                oInstance = CType(oSerializer.Deserialize(memStream), RispostaDettaglioConsenso)

                Return oInstance
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

        End Try

    End Function

    Public Shared Function Serialize(ByVal oInstance As RispostaDettaglioConsenso) As String
        '
        ' Serializzo
        '
        Try
            Using memStream As New IO.MemoryStream

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RispostaDettaglioConsenso))
                oSerializer.Serialize(memStream, oInstance)

                Dim oEnc As Encoding = Encoding.UTF8
                Dim sXml As String = oEnc.GetString(memStream.ToArray())

                Return sXml
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)

        End Try

    End Function

End Class

#End Region

#Region "Ack"

<Serializable()> _
Public Class IngressoAck
    Public Utente As String
    Public Ack As Boolean
    Public Url As String
    Public Account As String
    Public Password As String

    Public Sub New()
    End Sub

    Public Sub New(ByVal utenteValue As String, _
                   ByVal ackValue As Boolean, _
                   ByVal urlValue As String, _
                   ByVal accountValue As String, _
                   ByVal passwordValue As String)

        Me.Utente = utenteValue
        Me.Ack = ackValue
        Me.Url = urlValue
        Me.Account = accountValue
        Me.Password = passwordValue
    End Sub

End Class

<Serializable()> _
Public Class NotificaAck
    Public Utente As String
    Public Ack As Boolean
    Public Url As String
    Public Account As String
    Public Password As String

    Public Sub New()
    End Sub

    Public Sub New(ByVal utenteValue As String, _
                   ByVal ackValue As Boolean, _
                   ByVal urlValue As String, _
                   ByVal accountValue As String, _
                   ByVal passwordValue As String)

        Me.Utente = utenteValue
        Me.Ack = ackValue
        Me.Url = urlValue
        Me.Account = accountValue
        Me.Password = passwordValue
    End Sub

End Class

<Serializable()> _
Public Class RispostaUtentiAck

    <XmlElementAttribute("Ingresso")> _
    Public Ingresso As IngressoAck

    <XmlElementAttribute("Notifiche")> _
    Public Notifiche() As NotificaAck

    Public Sub New()
    End Sub

    Public Sub New(ByVal ingressoValue As IngressoAck, _
                   ByVal notificheValue() As NotificaAck)

        Me.Ingresso = ingressoValue
        Me.Notifiche = notificheValue
    End Sub

    Public Shared Function Deserialize(ByVal XmlData As String) As RispostaUtentiAck

        Try
            Using memStream As New IO.MemoryStream
                Dim oEnc As Encoding = Encoding.UTF8

                memStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
                memStream.Position = 0

                Dim oInstance As RispostaUtentiAck

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RispostaUtentiAck))
                oInstance = CType(oSerializer.Deserialize(memStream), RispostaUtentiAck)

                Return oInstance
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

        End Try

    End Function

    Public Shared Function Serialize(ByVal oInstance As RispostaUtentiAck) As String
        '
        ' Serializzo
        '
        Try
            Using memStream As New IO.MemoryStream

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RispostaUtentiAck))
                oSerializer.Serialize(memStream, oInstance)

                Dim oEnc As Encoding = Encoding.UTF8
                Dim sXml As String = oEnc.GetString(memStream.ToArray())

                Return sXml
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)

        End Try

    End Function

End Class

#End Region



'MODIFICA ETTORE WCF 2018-07-27 - Classe Paziente per costruire le risposte da utilizzare con la WCF
<Serializable()>
Public Class PazienteOut
    Public IdSac As String
    Public Provenienza As String
    Public IdProvenienza As String
    Public LivelloAttendibilita As Integer

    'Terminazione
    Public CodiceTerminazione As String
    Public DescrizioneTerminazione As String

    'Generalità
    Public CodiceFiscale As String
    Public Cognome As String
    Public Nome As String
    Public DataNascita As DateTime?
    Public Sesso As String
    Public Tessera As String
    Public ComuneNascitaCodice As String
    Public ComuneNascitaNome As String
    Public NazionalitaCodice As String
    Public NazionalitaNome As String
    Public DataDecesso As DateTime?

    'Dati di residenza
    Public ComuneResCodice As String
    Public ComuneResNome As String
    Public IndirizzoRes As String
    Public LocalitaRes As String
    Public CapRes As String
    Public DataDecorrenzaRes As DateTime?

    'Dati di domicilio
    Public ComuneDomCodice As String
    Public ComuneDomNome As String
    Public IndirizzoDom As String
    Public LocalitaDom As String
    Public CapDom As String


    'Dati di recapito
    Public ComuneRecapitoCodice As String
    Public ComuneRecapitoNome As String
    Public IndirizzoRecapito As String
    Public LocalitaRecapito As String
    Public Telefono1 As String
    Public Telefono2 As String
    Public Telefono3 As String


    'Dati di STP
    Public CodiceStp As String
    Public DataInizioStp As DateTime?
    Public DataFineStp As DateTime?
    Public MotivoAnnulloStp As String

    'Dati Assistito
    Public PosizioneAss As Byte?
    Public DataInizioAss As DateTime?
    Public DataScadenzaAss As DateTime?
    Public DataTerminazioneAss As DateTime?

    'Dati USL Residenza
    Public CodiceAslRes As String
    Public RegioneResCodice As String
    Public ComuneAslResCodice As String

    'Dati USL Assistenza
    Public CodiceAslAss As String
    Public RegioneAssCodice As String
    Public ComuneAslAssCodice As String

    'Dati Medico di base
    Public CodiceMedicoDiBase As String
    Public CodiceFiscaleMedicoDiBase As String
    Public CognomeNomeMedicoDiBase As String
    Public DistrettoMedicoDiBase As String
    Public DataSceltaMedicoDiBase As DateTime?

    'Questi al momento nel messaggio di out ver 2 finiscono negli attributi
    Public SubComuneRes As String
    Public AslResNome As String
    Public RegioneResNome As String
    Public SubComuneDom As String
    Public RegioneAssNome As String
    Public AslAssNome As String
    Public DistrettoAmm As String
    Public DistrettoTer As String
    Public Ambito As String

    ''MODIFICA ETTORE WCF 2018-07-26: Per passare la striga XML degli attributi
    Public Attributi As String

    Public Sub New()
    End Sub

    Public Sub New(ByVal IdSac As String, ByVal Provenienza As String, ByVal IdProvenienza As String, ByVal LivelloAttendibilita As Integer,
        ByVal CodiceTerminazione As String, ByVal DescrizioneTerminazione As String,
        ByVal CodiceFiscale As String, ByVal Cognome As String, ByVal Nome As String, ByVal DataNascita As DateTime?, ByVal Sesso As String, ByVal Tessera As String,
        ByVal ComuneNascitaCodice As String, ByVal ComuneNascitaNome As String, ByVal NazionalitaCodice As String, ByVal NazionalitaNome As String, ByVal DataDecesso As DateTime?,
        ByVal ComuneResCodice As String, ByVal ComuneResNome As String, ByVal IndirizzoRes As String, ByVal LocalitaRes As String, ByVal CapRes As String, ByVal DataDecorrenzaRes As DateTime?,
        ByVal ComuneDomCodice As String, ByVal ComuneDomNome As String, ByVal IndirizzoDom As String, ByVal LocalitaDom As String, ByVal CapDom As String,
        ByVal ComuneRecapitoCodice As String, ByVal ComuneRecapitoNome As String, ByVal IndirizzoRecapito As String, ByVal LocalitaRecapito As String,
        ByVal Telefono1 As String, ByVal Telefono2 As String, ByVal Telefono3 As String,
        ByVal CodiceStp As String, ByVal DataInizioStp As DateTime?, ByVal DataFineStp As DateTime?, ByVal MotivoAnnulloStp As String,
        ByVal PosizioneAss As Byte?, ByVal DataInizioAss As DateTime?, ByVal DataScadenzaAss As DateTime?, ByVal DataTerminazioneAss As DateTime?,
        ByVal CodiceAslRes As String, ByVal RegioneResCodice As String, ByVal ComuneAslResCodice As String,
        ByVal CodiceAslAss As String, ByVal RegioneAssCodice As String, ByVal ComuneAslAssCodice As String,
        ByVal CodiceMedicoDiBase As String, ByVal CodiceFiscaleMedicoDiBase As String, ByVal CognomeNomeMedicoDiBase As String, ByVal DistrettoMedicoDiBase As String, ByVal DataSceltaMedicoDiBase As DateTime?,
        ByVal SubComuneRes As String,
        ByVal AslResNome As String,
        ByVal RegioneResNome As String,
        ByVal SubComuneDom As String,
        ByVal RegioneAssNome As String,
        ByVal AslAssNome As String,
        ByVal DistrettoAmm As String,
        ByVal DistrettoTer As String,
        ByVal Ambito As String,
        ByVal Attributi As String)

        Me.IdSac = IdSac
        Me.Provenienza = Provenienza
        Me.IdProvenienza = IdProvenienza
        Me.LivelloAttendibilita = LivelloAttendibilita

        'Terminazione
        Me.CodiceTerminazione = CodiceTerminazione
        Me.DescrizioneTerminazione = DescrizioneTerminazione

        'Generalità
        Me.CodiceFiscale = CodiceFiscale
        Me.Cognome = Cognome
        Me.Nome = Nome
        Me.DataNascita = DataNascita
        Me.Sesso = Sesso
        Me.Tessera = Tessera
        Me.ComuneNascitaCodice = ComuneNascitaCodice
        Me.ComuneNascitaNome = ComuneNascitaNome
        Me.NazionalitaCodice = NazionalitaCodice
        Me.NazionalitaNome = NazionalitaNome
        Me.DataDecesso = DataDecesso

        'Dati di residenza
        Me.ComuneResCodice = ComuneResCodice
        Me.ComuneResNome = ComuneResNome
        Me.IndirizzoRes = IndirizzoRes
        Me.LocalitaRes = LocalitaRes
        Me.CapRes = CapRes
        Me.DataDecorrenzaRes = DataDecorrenzaRes

        'Dati di domicilio
        Me.ComuneDomCodice = ComuneDomCodice
        Me.ComuneDomNome = ComuneDomNome
        Me.IndirizzoDom = IndirizzoDom
        Me.LocalitaDom = LocalitaDom
        Me.CapDom = CapDom


        'Dati di recapito
        Me.ComuneRecapitoCodice = ComuneRecapitoCodice
        Me.ComuneRecapitoNome = ComuneRecapitoNome
        Me.IndirizzoRecapito = IndirizzoRecapito
        Me.LocalitaRecapito = LocalitaRecapito

        Me.Telefono1 = Telefono1
        Me.Telefono2 = Telefono2
        Me.Telefono3 = Telefono3


        'Dati di STP
        Me.CodiceStp = CodiceStp
        Me.DataInizioStp = DataInizioStp
        Me.DataFineStp = DataFineStp
        Me.MotivoAnnulloStp = MotivoAnnulloStp

        'Dati Assistito
        Me.PosizioneAss = PosizioneAss
        Me.DataInizioAss = DataInizioAss
        Me.DataScadenzaAss = DataScadenzaAss
        Me.DataTerminazioneAss = DataTerminazioneAss

        'Dati USL Residenza
        Me.CodiceAslRes = CodiceAslRes
        Me.RegioneResCodice = RegioneResCodice
        Me.ComuneAslResCodice = ComuneAslResCodice

        'Dati USL Assistenza
        Me.CodiceAslAss = CodiceAslAss
        Me.RegioneAssCodice = RegioneAssCodice
        Me.ComuneAslAssCodice = ComuneAslAssCodice

        'Dati Medico di base
        Me.CodiceMedicoDiBase = CodiceMedicoDiBase
        Me.CodiceFiscaleMedicoDiBase = CodiceFiscaleMedicoDiBase
        Me.CognomeNomeMedicoDiBase = CognomeNomeMedicoDiBase
        Me.DistrettoMedicoDiBase = DistrettoMedicoDiBase
        Me.DataSceltaMedicoDiBase = DataSceltaMedicoDiBase

        'Questi finiscono negli attributi del messaggio QueueOutput ver 2
        Me.SubComuneRes = SubComuneRes
        Me.AslResNome = AslResNome
        Me.RegioneResNome = RegioneResNome
        Me.SubComuneDom = SubComuneDom
        Me.RegioneAssNome = RegioneAssNome
        Me.AslAssNome = AslAssNome
        Me.DistrettoAmm = DistrettoAmm
        Me.DistrettoTer = DistrettoTer
        Me.Ambito = Ambito

        ''MODIFICA ETTORE WCF 2018-07-26: Per passare la striga XML degli attributi
        Me.Attributi = Attributi

    End Sub


End Class


'MODIFICA ETTORE WCF 2018-07-27 - Classe PazienteConsensoOut per costruire le risposte da utilizzare con la WCF
<Serializable()>
Public Class PazienteConsensoOut
    Public Provenienza As String
    Public IdProvenienza As String
    Public Tipo As String
    Public Stato As Boolean
    Public DataStato As DateTime
    Public OperatoreId As String
    Public OperatoreCognome As String
    Public OperatoreNome As String
    Public OperatoreComputer As String

    Public Sub New()
    End Sub

    Public Sub New(ByVal Provenienza As String, ByVal IdProvenienza As String, ByVal Tipo As String, ByVal Stato As Boolean, ByVal DataStato As DateTime,
                   ByVal OperatoreId As String, ByVal OperatoreCognome As String, ByVal OperatoreNome As String, ByVal OperatoreComputer As String)

        Me.Provenienza = Provenienza
        Me.IdProvenienza = IdProvenienza
        Me.Tipo = Tipo
        Me.Stato = Stato
        Me.DataStato = DataStato
        Me.OperatoreId = OperatoreId
        Me.OperatoreCognome = OperatoreCognome
        Me.OperatoreNome = OperatoreNome
        Me.OperatoreComputer = OperatoreComputer
    End Sub

End Class


'MODIFICA ETTORE WCF 2018-07-27 - Classe PazienteEsenzioneOut per costruire le risposte da utilizzare con la WCF
<Serializable()>
Public Class PazienteEsenzioneOut
    Public CodiceEsenzione As String
    Public CodiceDiagnosi As String
    Public Patologica As Boolean
    Public DataInizioValidita As Global.System.Nullable(Of Date)
    Public DataFineValidita As Global.System.Nullable(Of Date)
    Public NumeroAutorizzazioneEsenzione As String
    Public NoteAggiuntive As String
    Public CodiceTestoEsenzione As String
    Public TestoEsenzione As String
    Public DecodificaEsenzioneDiagnosi As String
    Public AttributoEsenzioneDiagnosi As String
    Public Provenienza As String
    Public OperatoreId As String
    Public OperatoreCognome As String
    Public OperatoreNome As String
    Public OperatoreComputer As String

    Public Sub New()
    End Sub

    Public Sub New(ByVal CodiceEsenzione As String,
                    ByVal CodiceDiagnosi As String,
                    ByVal Patologica As Boolean,
                    ByVal DataInizioValidita As Global.System.Nullable(Of Date),
                    ByVal DataFineValidita As Global.System.Nullable(Of Date),
                    ByVal NumeroAutorizzazioneEsenzione As String,
                    ByVal NoteAggiuntive As String,
                    ByVal CodiceTestoEsenzione As String,
                    ByVal TestoEsenzione As String,
                    ByVal DecodificaEsenzioneDiagnosi As String,
                    ByVal AttributoEsenzioneDiagnosi As String,
                    ByVal Provenienza As String,
                    ByVal OperatoreId As String,
                    ByVal OperatoreCognome As String,
                    ByVal OperatoreNome As String,
                    ByVal OperatoreComputer As String)
        Me.CodiceEsenzione = CodiceEsenzione
        Me.CodiceDiagnosi = CodiceDiagnosi
        Me.Patologica = Patologica
        Me.DataInizioValidita = DataInizioValidita
        Me.DataFineValidita = DataFineValidita
        Me.NumeroAutorizzazioneEsenzione = NumeroAutorizzazioneEsenzione
        Me.NoteAggiuntive = NoteAggiuntive
        Me.CodiceTestoEsenzione = CodiceTestoEsenzione
        Me.TestoEsenzione = TestoEsenzione
        Me.DecodificaEsenzioneDiagnosi = DecodificaEsenzioneDiagnosi
        Me.AttributoEsenzioneDiagnosi = AttributoEsenzioneDiagnosi
        Me.Provenienza = Provenienza
        Me.OperatoreId = OperatoreId
        Me.OperatoreCognome = OperatoreCognome
        Me.OperatoreNome = OperatoreNome
        Me.OperatoreComputer = OperatoreComputer
    End Sub

End Class


'MODIFICA ETTORE WCF 2019-09-05 - Classe PazienteFusoOut per costruire le risposte da utilizzare con la WCF
<Serializable()>
Public Class PazienteFusoOut
    Public IdSac As String
    Public Provenienza As String
    Public IdProvenienza As String

    Public CodiceFiscale As String
    Public Cognome As String
    Public Nome As String
    Public DataNascita As Nullable(Of DateTime)
    Public Sesso As String
    Public CodiceSanitario As String
    Public ComuneNascitaCodice As String
    Public ComuneNascitaNome As String
    Public NazionalitaCodice As String
    Public NazionalitaNome As String
    Public DataDecesso As Nullable(Of DateTime) 'Calcolato su Terminazione.Codice = 4 e DataTerminazione
    Public Attributi As String   'questo lo devo comporre come "Attributi del paziente letti da DB" + "campi dettaglio paziente diversi dai campi di testata sotto il nodo PazienteFusoOut"

    Public Sub New()
    End Sub

    Public Sub New(ByVal IdSac As String, ByVal Provenienza As String, ByVal IdProvenienza As String, ByVal CodiceFiscale As String, ByVal Cognome As String, ByVal Nome As String,
        ByVal DataNascita As Nullable(Of DateTime), ByVal Sesso As String, ByVal CodiceSanitario As String, ByVal ComuneNascitaCodice As String, ByVal ComuneNascitaNome As String,
        ByVal NazionalitaCodice As String, ByVal NazionalitaNome As String, ByVal DataDecesso As Nullable(Of DateTime), ByVal Attributi As String)

        Me.IdSac = IdSac
        Me.Provenienza = Provenienza
        Me.IdProvenienza = IdProvenienza
        Me.CodiceFiscale = CodiceFiscale
        Me.Cognome = Cognome
        Me.Nome = Nome
        Me.DataNascita = DataNascita
        Me.Sesso = Sesso
        Me.CodiceSanitario = CodiceSanitario
        Me.ComuneNascitaCodice = ComuneNascitaCodice
        Me.ComuneNascitaNome = ComuneNascitaNome
        Me.NazionalitaCodice = NazionalitaCodice
        Me.NazionalitaNome = NazionalitaNome
        Me.DataDecesso = DataDecesso
        Me.Attributi = Attributi
    End Sub

End Class




<Serializable()>
Public Class RispostaDettaglioPazienteWCF

    Public Paziente As PazienteOut

    <XmlElementAttribute("Esenzioni")>
    Public Esenzioni() As PazienteEsenzioneOut

    <XmlElementAttribute("Sinonimi")>
    Public Sinonimi() As PazienteSinonimo

    <XmlElementAttribute("Consensi")>
    Public Consensi() As PazienteConsensoOut

    Public Sub New()
    End Sub

    Public Sub New(ByVal Paziente As PazienteOut,
                   ByVal Esenzioni() As PazienteEsenzioneOut,
                   ByVal Sinonimi() As PazienteSinonimo,
                   ByVal Consensi() As PazienteConsensoOut)
        Me.Paziente = Paziente
        Me.Esenzioni = Esenzioni
        Me.Sinonimi = Sinonimi
        Me.Consensi = Consensi
    End Sub

    Public Shared Function Deserialize(ByVal XmlData As String) As RispostaDettaglioPaziente

        Try
            Using memStream As New IO.MemoryStream
                Dim oEnc As Encoding = Encoding.UTF8

                memStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
                memStream.Position = 0

                Dim oInstance As RispostaDettaglioPaziente

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RispostaDettaglioPaziente))
                oInstance = CType(oSerializer.Deserialize(memStream), RispostaDettaglioPaziente)

                Return oInstance
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

        End Try

    End Function

    Public Shared Function Serialize(ByVal oInstance As RispostaDettaglioPaziente) As String
        '
        ' Serializzo
        '
        Try
            Using memStream As New IO.MemoryStream

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RispostaDettaglioPaziente))
                oSerializer.Serialize(memStream, oInstance)

                Dim oEnc As Encoding = Encoding.UTF8
                Dim sXml As String = oEnc.GetString(memStream.ToArray())

                Return sXml
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)

        End Try

    End Function

End Class



'DA USARE PER WCF
<Serializable()>
Public Class PazienteLista
    Public IdSac As String
    Public Provenienza As String
    Public IdProvenienza As String
    Public LivelloAttendibilita As Integer

    'Terminazione
    Public CodiceTerminazione As String
    Public DescrizioneTerminazione As String

    'Generalità
    Public CodiceFiscale As String
    Public Cognome As String
    Public Nome As String
    Public DataNascita As DateTime?
    Public Sesso As String
    Public Tessera As String
    Public ComuneNascitaCodice As String
    Public ComuneNascitaNome As String
    Public NazionalitaCodice As String
    Public NazionalitaNome As String
    Public DataDecesso As DateTime?

    'Dati di residenza
    Public ComuneResCodice As String
    Public ComuneResNome As String
    Public IndirizzoRes As String
    Public LocalitaRes As String
    Public CapRes As String
    Public DataDecorrenzaRes As DateTime?

    'Dati di domicilio
    Public ComuneDomCodice As String
    Public ComuneDomNome As String
    Public IndirizzoDom As String
    Public LocalitaDom As String
    Public CapDom As String

    'Dati di recapito
    Public ComuneRecapitoCodice As String
    Public ComuneRecapitoNome As String
    Public IndirizzoRecapito As String
    Public LocalitaRecapito As String
    Public Telefono1 As String
    Public Telefono2 As String
    Public Telefono3 As String

    'Dati di STP
    Public CodiceStp As String
    Public DataInizioStp As DateTime?
    Public DataFineStp As DateTime?
    Public MotivoAnnulloStp As String

    'Dati Assistito
    Public PosizioneAss As Byte?
    Public DataInizioAss As DateTime?
    Public DataScadenzaAss As DateTime?
    Public DataTerminazioneAss As DateTime?

    'Dati USL Residenza
    Public CodiceAslRes As String
    Public RegioneResCodice As String
    Public ComuneAslResCodice As String

    'Dati USL Assistenza
    Public CodiceAslAss As String
    Public RegioneAssCodice As String
    Public ComuneAslAssCodice As String

    'Dati Medico di base
    Public CodiceMedicoDiBase As String
    Public CodiceFiscaleMedicoDiBase As String
    Public CognomeNomeMedicoDiBase As String
    Public DistrettoMedicoDiBase As String
    Public DataSceltaMedicoDiBase As DateTime?


    Public SubComuneRes As String
    Public AslResNome As String
    Public RegioneResNome As String
    Public SubComuneDom As String
    Public RegioneAssNome As String
    Public AslAssNome As String
    Public DistrettoAmm As String
    Public DistrettoTer As String
    Public Ambito As String


    'Per restituire la striga XML degli attributi
    Public Attributi As String

    Public Sinonimi() As PazienteSinonimo

    Public Esenzioni() As PazienteEsenzioneOut

    Public Consensi() As PazienteConsensoOut

    Public Sub New()
    End Sub

    Public Sub New(ByVal IdSac As String, ByVal Provenienza As String, ByVal IdProvenienza As String, ByVal LivelloAttendibilita As Integer,
       ByVal CodiceTerminazione As String, ByVal DescrizioneTerminazione As String,
       ByVal CodiceFiscale As String, ByVal Cognome As String, ByVal Nome As String, ByVal DataNascita As DateTime?, ByVal Sesso As String, ByVal Tessera As String,
       ByVal ComuneNascitaCodice As String, ByVal ComuneNascitaNome As String, ByVal NazionalitaCodice As String, ByVal NazionalitaNome As String, ByVal DataDecesso As DateTime?,
       ByVal ComuneResCodice As String, ByVal ComuneResNome As String, ByVal IndirizzoRes As String, ByVal LocalitaRes As String, ByVal CapRes As String, ByVal DataDecorrenzaRes As DateTime?,
       ByVal ComuneDomCodice As String, ByVal ComuneDomNome As String, ByVal IndirizzoDom As String, ByVal LocalitaDom As String, ByVal CapDom As String,
       ByVal ComuneRecapitoCodice As String, ByVal ComuneRecapitoNome As String, ByVal IndirizzoRecapito As String, ByVal LocalitaRecapito As String,
       ByVal Telefono1 As String, ByVal Telefono2 As String, ByVal Telefono3 As String,
       ByVal CodiceStp As String, ByVal DataInizioStp As DateTime?, ByVal DataFineStp As DateTime?, ByVal MotivoAnnulloStp As String,
       ByVal PosizioneAss As Byte?, ByVal DataInizioAss As DateTime?, ByVal DataScadenzaAss As DateTime?, ByVal DataTerminazioneAss As DateTime?,
       ByVal CodiceAslRes As String, ByVal RegioneResCodice As String, ByVal ComuneAslResCodice As String,
       ByVal CodiceAslAss As String, ByVal RegioneAssCodice As String, ByVal ComuneAslAssCodice As String,
       ByVal CodiceMedicoDiBase As String, ByVal CodiceFiscaleMedicoDiBase As String, ByVal CognomeNomeMedicoDiBase As String, ByVal DistrettoMedicoDiBase As String, ByVal DataSceltaMedicoDiBase As DateTime?,
        ByVal SubComuneRes As String,
        ByVal AslResNome As String,
        ByVal RegioneResNome As String,
        ByVal SubComuneDom As String,
        ByVal RegioneAssNome As String,
        ByVal AslAssNome As String,
        ByVal DistrettoAmm As String,
        ByVal DistrettoTer As String,
        ByVal Ambito As String,
       ByVal Attributi As String,
       ByVal Sinonimi() As PazienteSinonimo,
       ByVal Esenzioni() As PazienteEsenzioneOut,
       ByVal Consensi() As PazienteConsensoOut)

        Me.IdSac = IdSac
        Me.Provenienza = Provenienza
        Me.IdProvenienza = IdProvenienza
        Me.LivelloAttendibilita = LivelloAttendibilita

        'Terminazione
        Me.CodiceTerminazione = CodiceTerminazione
        Me.DescrizioneTerminazione = DescrizioneTerminazione

        'Generalità
        Me.CodiceFiscale = CodiceFiscale
        Me.Cognome = Cognome
        Me.Nome = Nome
        Me.DataNascita = DataNascita
        Me.Sesso = Sesso
        Me.Tessera = Tessera
        Me.ComuneNascitaCodice = ComuneNascitaCodice
        Me.ComuneNascitaNome = ComuneNascitaNome
        Me.NazionalitaCodice = NazionalitaCodice
        Me.NazionalitaNome = NazionalitaNome
        Me.DataDecesso = DataDecesso ' La sp usata per leggere il dettaglio non restituisce "DataDecesso" ma la può restituire

        'Dati di residenza
        Me.ComuneResCodice = ComuneResCodice
        Me.ComuneResNome = ComuneResNome
        Me.IndirizzoRes = IndirizzoRes
        Me.LocalitaRes = LocalitaRes
        Me.CapRes = CapRes
        Me.DataDecorrenzaRes = DataDecorrenzaRes

        'Dati di domicilio
        Me.ComuneDomCodice = ComuneDomCodice
        Me.ComuneDomNome = ComuneDomNome
        Me.IndirizzoDom = IndirizzoDom
        Me.LocalitaDom = LocalitaDom
        Me.CapDom = CapDom

        'Dati di recapito
        Me.ComuneRecapitoCodice = ComuneRecapitoCodice
        Me.ComuneRecapitoNome = ComuneRecapitoNome
        Me.IndirizzoRecapito = IndirizzoRecapito
        Me.LocalitaRecapito = LocalitaRecapito
        Me.Telefono1 = Telefono1
        Me.Telefono2 = Telefono2
        Me.Telefono3 = Telefono3

        'Dati di STP
        Me.CodiceStp = CodiceStp
        Me.DataInizioStp = DataInizioStp
        Me.DataFineStp = DataFineStp
        Me.MotivoAnnulloStp = MotivoAnnulloStp

        'Dati Assistito
        Me.PosizioneAss = PosizioneAss
        Me.DataInizioAss = DataInizioAss
        Me.DataScadenzaAss = DataScadenzaAss
        Me.DataTerminazioneAss = DataTerminazioneAss

        'Dati USL Residenza
        Me.CodiceAslRes = CodiceAslRes
        Me.RegioneResCodice = RegioneResCodice
        Me.ComuneAslResCodice = ComuneAslResCodice

        'Dati USL Assistenza
        Me.CodiceAslAss = CodiceAslAss
        Me.RegioneAssCodice = RegioneAssCodice
        Me.ComuneAslAssCodice = ComuneAslAssCodice

        'Dati Medico di base
        Me.CodiceMedicoDiBase = CodiceMedicoDiBase
        Me.CodiceFiscaleMedicoDiBase = CodiceFiscaleMedicoDiBase
        Me.CognomeNomeMedicoDiBase = CognomeNomeMedicoDiBase
        Me.DistrettoMedicoDiBase = DistrettoMedicoDiBase
        Me.DataSceltaMedicoDiBase = DataSceltaMedicoDiBase


        Me.SubComuneRes = SubComuneRes
        Me.AslResNome = AslResNome
        Me.RegioneResNome = RegioneResNome
        Me.SubComuneDom = SubComuneDom
        Me.RegioneAssNome = RegioneAssNome
        Me.AslAssNome = AslAssNome
        Me.DistrettoAmm = DistrettoAmm
        Me.DistrettoTer = DistrettoTer
        Me.Ambito = Ambito

        'Per passare la striga XML degli attributi
        Me.Attributi = Attributi
        '
        ' I figli
        '
        Me.Sinonimi = Sinonimi
        Me.Esenzioni = Esenzioni
        Me.Consensi = Consensi
    End Sub

    Public Shared Function Deserialize(ByVal XmlData As String) As RispostaListaPazienti

        Try
            Using memStream As New IO.MemoryStream
                Dim oEnc As Encoding = Encoding.UTF8

                memStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
                memStream.Position = 0

                Dim oInstance As RispostaListaPazienti

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RispostaListaPazienti))
                oInstance = CType(oSerializer.Deserialize(memStream), RispostaListaPazienti)

                Return oInstance
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

        End Try

    End Function

    Public Shared Function Serialize(ByVal oInstance As RispostaListaPazienti) As String
        '
        ' Serializzo
        '
        Try
            Using memStream As New IO.MemoryStream

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RispostaListaPazienti))
                oSerializer.Serialize(memStream, oInstance)

                Dim oEnc As Encoding = Encoding.UTF8
                Dim sXml As String = oEnc.GetString(memStream.ToArray())

                Return sXml
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)

        End Try

    End Function

End Class



<Serializable()>
Public Class RispostaListaPazientiWcf

    <XmlElementAttribute("Paziente")>
    Public Paziente() As PazienteLista

    Public Sub New()
    End Sub

    Public Sub New(Paziente() As PazienteLista)
        Me.Paziente = Paziente
    End Sub


    Public Shared Function Deserialize(ByVal XmlData As String) As RispostaListaPazienti

        Try
            Using memStream As New IO.MemoryStream
                Dim oEnc As Encoding = Encoding.UTF8

                memStream.Write(oEnc.GetBytes(XmlData), 0, oEnc.GetByteCount(XmlData))
                memStream.Position = 0

                Dim oInstance As RispostaListaPazienti

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RispostaListaPazienti))
                oInstance = CType(oSerializer.Deserialize(memStream), RispostaListaPazienti)

                Return oInstance
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Deserialize()!; " & ex.Message, ex)

        End Try

    End Function

    Public Shared Function Serialize(ByVal oInstance As RispostaListaPazienti) As String
        '
        ' Serializzo
        '
        Try
            Using memStream As New IO.MemoryStream

                Dim oSerializer As XmlSerializer = New XmlSerializer(GetType(RispostaListaPazienti))
                oSerializer.Serialize(memStream, oInstance)

                Dim oEnc As Encoding = Encoding.UTF8
                Dim sXml As String = oEnc.GetString(memStream.ToArray())

                Return sXml
            End Using

        Catch ex As Exception
            '
            ' Log e eccezione
            '
            Throw New ApplicationException("Errore durante Serialize()!; " & ex.Message, ex)

        End Try

    End Function

End Class



<Serializable()>
Public Class Attributo
    Public Nome As String
    Public Valore As String

    Public Sub New()
    End Sub

    Public Sub New(ByVal Nome As String, ByVal Valore As String)
        Me.Nome = Nome
        Me.Valore = Valore
    End Sub

End Class
