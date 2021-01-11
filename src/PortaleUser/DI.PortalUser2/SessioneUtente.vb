Imports System

Namespace DI.PortalUser2

    Public Class SessioneUtente
        Private mPortal As Data.PortalDataAdapterManager
        Private mSACConnectionString As String

        Private mSacUser As String
        Private mSacPassword As String


        Private Const Key_UltimoAccesso As String = "_ULTIMO_ACCESSO_DATA"
        Private Const Key_Ruolo As String = "_ULTIMO_ACCESSO_RUOLO"

        Public Sub New(SACConnectionString As String, DiUserPortalConnectionString As String, ByVal SacUser As String, ByVal SacPassword As String)
            mPortal = New Data.PortalDataAdapterManager(DiUserPortalConnectionString)
            mSACConnectionString = SACConnectionString
            mSacUser = SacUser
            mSacPassword = SacPassword
        End Sub

        ''' <summary>
        ''' Restituisce le informazioni di ultimo accesso al portale passato
        ''' </summary>
        ''' <returns>In mancanza di dati restituisce Data=DateTime.MinValue e Ruolo="" </returns>
        Public Function GetUltimoAccesso(Utente As String, Portale As String) As UltimoAccesso
            Dim oUltimoAccesso As New UltimoAccesso

            oUltimoAccesso.Data = mPortal.DatiUtenteOttieniValore(Utente, Portale & Key_UltimoAccesso, DateTime.MinValue)
            oUltimoAccesso.Ruolo.Codice = mPortal.DatiUtenteOttieniValore(Utente, Portale & Key_Ruolo, "")

            Dim oRoleManagerDataAccess As New RoleManager.DataAccess(mSacUser, mSacPassword)
            '
            ' Verifico che il valore dell'ultimo codice ruolo sia presente
            '
            If Not String.IsNullOrEmpty(oUltimoAccesso.Ruolo.Codice) Then
                Dim dtRuolo As WcfSacRoleManager.RuoloDettagliType = Nothing
                dtRuolo = oRoleManagerDataAccess.ContestoUtenteOttieniPerRuolo(oUltimoAccesso.Ruolo.Codice, Utente)
                'TESTO SE IL RUOLO NON È VUOTO.
                If dtRuolo IsNot Nothing AndAlso dtRuolo.Ruolo IsNot Nothing Then
                    'OTTENGO LA DESCRIZIONE DEL RUOLO.
                    oUltimoAccesso.Ruolo.Descrizione = dtRuolo.Ruolo.Descrizione
                End If
            End If
            '
            ' Ricavo i dati dell'utente
            '
            Dim dtUtente As RoleManager.Utente = Nothing
            dtUtente = oRoleManagerDataAccess.UtenteOttieniDettaglio(Utente)
            '
            ' TESTO SE L'UTENTE NON È VUOTO.
            '
            If dtUtente IsNot Nothing AndAlso dtUtente.Utente IsNot Nothing Then
                'VALORIZZO L'OGGETTO DA RESTITUIRE.
                oUltimoAccesso.Utente.Attivo = dtUtente.Attivo
                oUltimoAccesso.Utente.Utente = dtUtente.Utente
                oUltimoAccesso.Utente.Descrizione = dtUtente.Descrizione
                oUltimoAccesso.Utente.Cognome = dtUtente.Cognome
                oUltimoAccesso.Utente.Nome = dtUtente.Nome
                oUltimoAccesso.Utente.CodiceFiscale = dtUtente.CodiceFiscale
                oUltimoAccesso.Utente.Matricola = dtUtente.Matricola
                oUltimoAccesso.Utente.Email = dtUtente.Email
            End If

            'RESTITUISCO L'OGGETTO.
            Return oUltimoAccesso
        End Function

        ''' <summary>
        ''' Salva data e ruolo dell'ultimo accesso
        ''' </summary>		
        Public Sub SetUltimoAccesso(Utente As String, Portale As String, Data As DateTime, RuoloCodice As String)

            mPortal.DatiUtenteSalvaValore(Utente, Portale & Key_UltimoAccesso, Data)
            mPortal.DatiUtenteSalvaValore(Utente, Portale & Key_Ruolo, RuoloCodice)

        End Sub


#Region "Sottoclassi"


        Public Class UltimoAccesso

            Public Property Data As DateTime = DateTime.MinValue
            Public Property Ruolo As New Ruolo
            Public Property Utente As New Utente

            Public ReadOnly Property UltimoAccessoDescrizione As String
                Get
                    If Data > DateTime.MinValue AndAlso Not String.IsNullOrEmpty(Ruolo.Descrizione) Then
                        Return String.Format("il {0} alle {1} con il ruolo {2}", Data.ToShortDateString(), Data.ToShortTimeString(), Ruolo.Descrizione)
                    Else
                        Return ""
                    End If
                End Get
            End Property

            Public Sub New()

            End Sub

        End Class

        Public Class Ruolo
            Public Property Codice As String = String.Empty
            Public Property Descrizione As String = String.Empty
        End Class

        Public Class Utente
            Public Property Utente As String = String.Empty
            Public Property Descrizione As String = String.Empty
            Public Property Cognome As String = String.Empty
            Public Property Nome As String = String.Empty
            Public Property CodiceFiscale As String = String.Empty
            Public Property Matricola As String = String.Empty
            Public Property Email As String = String.Empty
            Public Property Attivo As Boolean = False
        End Class
#End Region


    End Class

End Namespace
