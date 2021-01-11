Imports DwhClinico.Data

''' <summary>
''' Classe che comprende tutte le funzioni usate per il tracciamento degli accessi dell'utente ai dati del paziente.
''' </summary>
Public Class TracciaAccessi

#Region "Public Sub"
    ''' <summary>
    ''' Funzione di tracciamento degli accessi al dettaglio di una nota anamnestica.
    ''' </summary>
    ''' <param name="CodiceRuolo"></param>
    ''' <param name="DescrizioneRuolo"></param>
    ''' <param name="Operazione"></param>
    ''' <param name="IdPaziente"></param>
    ''' <param name="IdNotaAnamnestica"></param>
    ''' <param name="ItemMotivoAccesso"></param>
    ''' <param name="Note"></param>
    ''' <param name="NumeroRecord"></param>
    ''' <param name="ConsensoPaziente"></param>
    Public Shared Sub TracciaAccessiNotaAnamnestica(ByVal CodiceRuolo As String, ByVal DescrizioneRuolo As String, ByVal Operazione As String, ByVal IdPaziente As Nullable(Of Guid), ByVal IdNotaAnamnestica As Nullable(Of Guid), ItemMotivoAccesso As ListItem, Note As String, NumeroRecord As Integer, ConsensoPaziente As String)
        Call TracciaAccessi(CodiceRuolo, DescrizioneRuolo, Operazione, IdPaziente, Nothing, Nothing, Nothing, ItemMotivoAccesso, Note, NumeroRecord, ConsensoPaziente, IdNotaAnamnestica)
    End Sub

    ''' <summary>
    ''' Funzione di tracciamento degli accessi al paziente.
    ''' </summary>
    ''' <param name="sCodiceRuolo"></param>
    ''' <param name="sDescrizioneRuolo"></param>
    ''' <param name="sOperazione"></param>
    ''' <param name="oIdPaziente"></param>
    ''' <param name="oItemMotivoAccesso"></param>
    ''' <param name="Note"></param>
    ''' <param name="NumeroRecord"></param>
    ''' <param name="ConsensoPaziente"></param>
    Public Shared Sub TracciaAccessiPaziente(ByVal sCodiceRuolo As String, ByVal sDescrizioneRuolo As String, ByVal sOperazione As String, ByVal oIdPaziente As Nullable(Of Guid), oItemMotivoAccesso As ListItem, Note As String, NumeroRecord As Nullable(Of Integer), ConsensoPaziente As String)
        Call TracciaAccessi(sCodiceRuolo, sDescrizioneRuolo, sOperazione, oIdPaziente, Nothing, Nothing, Nothing, oItemMotivoAccesso, Note, NumeroRecord, ConsensoPaziente, Nothing)
    End Sub

    ''' <summary>
    ''' Funzione di tracciamento degli accessi al ricovero.
    ''' </summary>
    ''' <param name="CodiceRuolo"></param>
    ''' <param name="DescrizioneRuolo"></param>
    ''' <param name="Operazione"></param>
    ''' <param name="IdPaziente"></param>
    ''' <param name="IdRicovero"></param>
    ''' <param name="ItemMotivoAccesso"></param>
    ''' <param name="Note"></param>
    ''' <param name="NumeroRecord"></param>
    ''' <param name="ConsensoPaziente"></param>
    Public Shared Sub TracciaAccessiRicovero(ByVal CodiceRuolo As String, ByVal DescrizioneRuolo As String, ByVal Operazione As String, ByVal IdPaziente As Nullable(Of Guid), ByVal IdRicovero As Nullable(Of Guid), ItemMotivoAccesso As ListItem, Note As String, NumeroRecord As Integer, ConsensoPaziente As String)
        Call TracciaAccessi(CodiceRuolo, DescrizioneRuolo, Operazione, IdPaziente, Nothing, IdRicovero, Nothing, ItemMotivoAccesso, Note, NumeroRecord, ConsensoPaziente, Nothing)
    End Sub


    ''' <summary>
    ''' Funzione di tracciamento degli accessi sulle liste dei referti,ricoveri, note anamnestiche e prescrizioni.
    ''' </summary>
    ''' <param name="CodiceRuolo"></param>
    ''' <param name="DescrizioneRuolo"></param>
    ''' <param name="Operazione"></param>
    ''' <param name="IdPaziente"></param>
    ''' <param name="ItemMotivoAccesso"></param>
    ''' <param name="Note"></param>
    ''' <param name="NumeroRecord"></param>
    ''' <param name="ConsensoPaziente"></param>
    Public Shared Sub TracciaAccessiLista(ByVal CodiceRuolo As String, ByVal DescrizioneRuolo As String, ByVal Operazione As String, ByVal IdPaziente As Nullable(Of Guid), ItemMotivoAccesso As ListItem, Note As String, NumeroRecord As Integer, ConsensoPaziente As String)
        Call TracciaAccessi(CodiceRuolo, DescrizioneRuolo, Operazione, IdPaziente, Nothing, Nothing, Nothing, ItemMotivoAccesso, Note, NumeroRecord, ConsensoPaziente, Nothing)
    End Sub

    ''' <summary>
    ''' Funzione di tracciamento degli accessi al referto.
    ''' </summary>
    ''' <param name="CodiceRuolo"></param>
    ''' <param name="DescrizioneRuolo"></param>
    ''' <param name="Operazione"></param>
    ''' <param name="IdPaziente"></param>
    ''' <param name="IdReferto"></param>
    ''' <param name="ItemMotivoAccesso"></param>
    ''' <param name="Note"></param>
    ''' <param name="NumeroRecord"></param>
    ''' <param name="ConsensoPaziente"></param>
    Public Shared Sub TracciaAccessiReferto(ByVal CodiceRuolo As String, ByVal DescrizioneRuolo As String, ByVal Operazione As String, ByVal IdPaziente As Nullable(Of Guid), ByVal IdReferto As Nullable(Of Guid), ItemMotivoAccesso As ListItem, Note As String, NumeroRecord As Nullable(Of Integer), ConsensoPaziente As String)
        Call TracciaAccessi(CodiceRuolo, DescrizioneRuolo, Operazione, IdPaziente, IdReferto, Nothing, Nothing, ItemMotivoAccesso, Note, NumeroRecord, ConsensoPaziente, Nothing)
    End Sub
#End Region

#Region "Private Sub"
    ''' <summary>
    ''' Funzione che si occupa di chiamare la datatable per inserire l'accesso della tabella dbo.TracciaAccessi
    ''' </summary>
    ''' <param name="sCodiceRuolo"></param>
    ''' <param name="sDescrizioneRuolo"></param>
    ''' <param name="sOperazione"></param>
    ''' <param name="oIdPazienti"></param>
    ''' <param name="oIdReferti"></param>
    ''' <param name="oIdRicoveri"></param>
    ''' <param name="oIdEventi"></param>
    ''' <param name="oItemMotivoAccesso"></param>
    ''' <param name="Note"></param>
    ''' <param name="NumeroRecord"></param>
    ''' <param name="ConsensoPaziente"></param>
    ''' <param name="IdNotaAnamnestica"></param>
    Private Shared Sub TracciaAccessi(ByVal sCodiceRuolo As String, ByVal sDescrizioneRuolo As String, ByVal sOperazione As String, ByVal oIdPazienti As Nullable(Of Guid),
                                          ByVal oIdReferti As Nullable(Of Guid), ByVal oIdRicoveri As Nullable(Of Guid), ByVal oIdEventi As Nullable(Of Guid), oItemMotivoAccesso As ListItem, ByVal Note As String _
                                          , ByVal NumeroRecord As Nullable(Of Integer), ByVal ConsensoPaziente As String, ByVal IdNotaAnamnestica As Nullable(Of Guid))
        Try
            Using oUtenti As Utenti = New Utenti
                Dim sMotivoAccesso As String = Nothing
                '
                ' Questa la devo eseguire per ottenere anche il nome del PC, oltre che Dominio e Account per chiamare Utility.GetDettaglioUtente()
                '
                Dim oCurrentUser As CurrentUser = Utility.GetCurrentUser()

                Dim oDettaglioUtente As Utility.DettaglioUtente = Utility.GetDettaglioUtente(oCurrentUser.DomainName, oCurrentUser.UserName)
                Dim IdUtente As Nullable(Of Guid) = oDettaglioUtente.IdUtente
                '
                ' Devo leggere il valore del ruolo corrente tramite funzione oRoleManagerUtility.GetRuoloCorrente() che legge dall'oggetto "contesto utente" inizializzato 
                ' all'interno del Global.ASAX. Così anche nel caso di accesso diretto al referto riesco a scrivere Ruolo e Descrizione nella tabella TracciaAccessi
                '
                Dim sRuoloUtenteCodice As String = sCodiceRuolo
                Dim sRuoloUtenteDescrizione As String = sDescrizioneRuolo

                If Not oItemMotivoAccesso Is Nothing Then
                    sMotivoAccesso = oItemMotivoAccesso.Text
                End If

                '
                ' Inizializzo Cognome e Nome dell'utente loggato
                '
                Dim sCognomeUtente As String = oDettaglioUtente.Cognome
                Dim sNomeUtente As String = oDettaglioUtente.Nome
                '
                ' Se l'utente deve essere tracciato come "Utente tecnico"...
                '
                If HttpContext.Current.User.IsInRole(RoleManagerUtility2.ATTRIB_UTE_TEC) Then
                    sCognomeUtente = "Utente Tecnico"
                    sNomeUtente = ""
                End If

                oUtenti.AggiungiTracciaAccessi(IdUtente, oCurrentUser.DomainName, oCurrentUser.UserName,
                    sCognomeUtente, sNomeUtente,
                    oCurrentUser.HostName, oCurrentUser.HostAddress,
                    sOperazione, oIdPazienti, oIdReferti, oIdRicoveri, oIdEventi,
                    sRuoloUtenteCodice, sRuoloUtenteDescrizione, sMotivoAccesso, Note, NumeroRecord, ConsensoPaziente, IdNotaAnamnestica)
            End Using
        Catch ex As Exception
            Logging.WriteError(ex, String.Format("Errore durante TracciaAccessi() per l'utente {0}", HttpContext.Current.User.Identity.Name))
        End Try
    End Sub

#End Region

End Class
