Imports Dwh.DataAccess.Wcf.Types.NoteAnamnestiche
Imports System.Xml
Imports System.Xml.Linq
Imports System.Xml.XPath

''' <summary>
''' ARRICCHISCE GLI ATTRIBUTI DELLA NOTA ANAMNESTICA 
''' </summary>
Public Class NotaAnamnesticaBuilder

    Public Property NotaAnamnestica As Types.NoteAnamnestiche.NotaAnamnesticaType
    Public Property IdPazienteSAC As Guid


    Public Sub New(oNotaAnamnestica As Types.NoteAnamnestiche.NotaAnamnesticaType)
        Me.NotaAnamnestica = oNotaAnamnestica
    End Sub


    Private Structure AttributiNomi

        'NOME DEGLI ATTRIBUTI LEGATI AL PAZIENTE.
        Public Const Cognome = "Cognome"
        Public Const Nome = "Nome"
        Public Const Sesso = "Sesso"
        Public Const CodiceFiscale = "CodiceFiscale"
        Public Const DataNascita = "DataNascita"
        Public Const ComuneNascita = "ComuneNascita"
        Public Const ComuneNascitaCodice = "ComuneNascitaCodice"
        Public Const CodiceSanitario = "CodiceSanitario"
        'MODIFICA ETTORE 2018-06-14: aggiunto i nomi di questi attributi della nota anamnestica
        Public Const CodiceAnagraficaCentrale = "CodiceAnagraficaCentrale"
        Public Const NomeAnagraficaCentrale = "NomeAnagraficaCentrale"

    End Structure


    ''' <summary>
    ''' AGGIUNGE AGLI ATTRIBUTI DELLA NOTA ANAMNESTICA I DETTAGLI ANAGRAFICI DEL PAZIENTE
    ''' </summary>
    Public Sub AggiungiAttributiPaziente()
        Try
            If NotaAnamnestica.Paziente Is Nothing Then Exit Sub
            Dim oPaz = NotaAnamnestica.Paziente

            AggiungiAttributo(AttributiNomi.Nome, oPaz.Nome)
            AggiungiAttributo(AttributiNomi.Cognome, oPaz.Cognome)
            AggiungiAttributo(AttributiNomi.CodiceFiscale, oPaz.CodiceFiscale)
            AggiungiAttributo(AttributiNomi.DataNascita, oPaz.DataNascita)
            AggiungiAttributo(AttributiNomi.ComuneNascita, oPaz.ComuneNascitaDescrizione)
            AggiungiAttributo(AttributiNomi.ComuneNascitaCodice, oPaz.ComuneNascitaCodice)
            AggiungiAttributo(AttributiNomi.CodiceSanitario, oPaz.TesseraSanitaria)
            'MODIFICA ETTORE 2018-06-14: aggiunto questi attributi agli attributi della nota anamnestica
            AggiungiAttributo(AttributiNomi.CodiceAnagraficaCentrale, oPaz.CodiceAnagrafica)
            AggiungiAttributo(AttributiNomi.NomeAnagraficaCentrale, oPaz.NomeAnagrafica)

        Catch ex As Exception
            Throw New CustomException(String.Format("NotaAnamnestica.IdEsterno: {0}, Messaggio: {1}", NotaAnamnestica.IdEsterno, ex.Message), ErrorCodes.ErroreAttributiAnagrafici)
        End Try
    End Sub

    ''' <summary>
    ''' AGGIUNGE UN ATTRIBUTO ALLA NOTAANAMNESTICA
    ''' </summary>
    Private Sub AggiungiAttributo(Nome As String, Valore As Object)

        ' VALORI NULLI NON CONSENTITI
        If Valore Is Nothing Then Return

        Dim oAttr As New AttributoType
        oAttr.Nome = Nome

        If TypeOf Valore Is DateTime Then
            Dim dtTemp As DateTime = DirectCast(Valore, DateTime)
            '{0:s} = SortableDateTi­mePattern (culture independent):	yyyy-MM-ddTHH:mm:ss
            oAttr.Valore = String.Format("{0:s}", dtTemp)
        Else
            oAttr.Valore = Valore.ToString
        End If

        NotaAnamnestica.Attributi.Add(oAttr)

    End Sub

    ''' <summary>
    ''' Aggiunge il prefisso dell'azienda erogante all'IdEsterno se non è già presente
    ''' </summary>
    Public Sub AutoPrefixIdEsterno()
        Dim sIdEsterno As String = NotaAnamnestica.IdEsterno
        Dim sAziendaEroganteUpper As String = NotaAnamnestica.AziendaErogante.ToUpper
        Dim sIdEsternoUpper As String = sIdEsterno.ToUpper
        If Not sIdEsternoUpper.StartsWith(String.Concat(sAziendaEroganteUpper, "_")) Then
            'Prefisso l'idEsterno con l'azienda erogante: modifica direttamente il valore nella classe
            NotaAnamnestica.IdEsterno = String.Concat(sAziendaEroganteUpper, "_", NotaAnamnestica.IdEsterno)
        End If
    End Sub
End Class
