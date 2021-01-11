Imports System.Xml.Linq
Imports System.Xml.XPath
Imports System.Data
Imports Dwh.DataAccess.Wcf.Service.DWHDataSetTableAdapters
Imports Dwh.DataAccess.Wcf.Types.NoteAnamnestiche

Public Class DwhHelper
    ''' <summary>
    ''' Salva o Aggiorna su DB l'intera nota anamnestica comprensiva di allegati
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Function AggiungiOrAggiorna(ByVal Azione As Integer, ByVal DataModificaEsterno As DateTime, NotaAnamnestica As NotaAnamnesticaType, IdPazienteSAC As Guid) As NotaAnamnesticaReturn
        Dim iAzioneDAE As Integer = AZIONE_INSERIMENTO
        '
        ' Definisco la variabile che decide se compilare il dato di ritorno del metodo 
        '
        Dim bRetNotificaByOrch As Boolean = False
        '
        ' Serializzazione degli attributi della nota anamnestica
        '
        Dim msXmlAttributi As String = Nothing
        If NotaAnamnestica.Attributi IsNot Nothing AndAlso NotaAnamnestica.Attributi.Count > 0 Then
            msXmlAttributi = GenericDataContractSerializer.Serialize(NotaAnamnestica.Attributi)
        End If

        Dim oConn As New SqlClient.SqlConnection(My.Settings.DWHConnectionString)
        Dim oTrans As SqlClient.SqlTransaction = Nothing

        ' Try catch per gestire la TRANSAZIONE , tutte le eccezioni passano fuori
        Try
            Dim sContenutoHtml As String = Nothing
            Dim sContenutoText As String = Nothing
            '
            ' Calcolo sContenutoHtml e sContenutText
            '
            Utilities.ConvertContenutoToHtmlText(NotaAnamnestica.Contenuto, NotaAnamnestica.TipoContenuto, sContenutoHtml, sContenutoText)
            '
            ' Apertura connessione e transazione
            '
            Try
                oConn.Open()
            Catch ex As Exception
                Throw New Exception(String.Concat("DAE NoteAnamnestiche: ", ERRORE_APERTURA_CONNESSIONE, vbCrLf, "Database DwhClinico", vbCrLf, ex.Message))
            End Try

            oTrans = oConn.BeginTransaction
            '
            ' Inserimento/update della nota anamnestica e restituizione dell'XML che rappresenta la nota anamnestica
            '
            Dim oInfoOperazione As InfoOperazioneReturnType = ExecAggiungiOrAggiorna(oConn, oTrans, NotaAnamnestica.IdEsterno, IdPazienteSAC, DataModificaEsterno,
                                                                             sContenutoHtml, sContenutoText, msXmlAttributi, NotaAnamnestica)

            Dim sTraceMsg As String = String.Format("DWH.ExtNoteAnamnesticheAggiungi: IDNotaAnamnestica={0}, DataPartizione={1}, Azione={2}",
                                               oInfoOperazione.IdNotaAnamnestica.NullSafeToString("NULL"),
                                               oInfoOperazione.DataPartizione.NullSafeToString("NULL"),
                                               oInfoOperazione.AzioneDAE.NullSafeToString("NULL"))
            sTraceMsg = String.Concat(sTraceMsg, vbCrLf, NotaAnamnestica.Descrizione)
            Log.TraceWrite(sTraceMsg, TraceLevel.Info.ToString, TraceLevel.Info.ToString)

            If String.IsNullOrEmpty(oInfoOperazione.AzioneDAE) Then
                'NESSUNA AZIONE: ESCO SENZA SEGNALARE ERRORE
                'ACCADE QUANDO SI STA TENTANDO DI AGGIORNARE UN RECORD PIU' RECENTE
                'IN QUESTO CASO L'INSERIMENTO NELLA TABELLA DI NOTIFICA NON VIENE FATTO (nè in CodaXXXOutput nè in CodaXXXOutputInviati) 
                'bRetNotificaByOrch RIMANE FALSE E L'ORCHESTRAZIONE NON ESEGUE NESSUNA NOTIFICA
            Else
                '
                ' Se sono qui oInfoOperazione.AzioneDAE vale "INSERT" o "UPDATE"
                '
                oInfoOperazione.AzioneDAE = oInfoOperazione.AzioneDAE.ToUpper

                If oInfoOperazione.AzioneDAE = "INSERT" OrElse oInfoOperazione.AzioneDAE = "UPDATE" Then
                    '
                    ' Leggo tabella di configurazione per capire se è l'orchestrazione che deve eseguire la notifica di OUTPUT
                    '
                    bRetNotificaByOrch = GetNotificaByOrchestrazione(oConn, oTrans, NotaAnamnestica.AziendaErogante, NotaAnamnestica.SistemaErogante)
                    '
                    ' Invoco la SP di notifica se idPaziente <> Guid.Empty
                    '
                    If IdPazienteSAC.CompareTo(Guid.Empty) <> 0 Then
                        ' Valori possibili: 0=Inserimento, 1=Modifica, 2=Cancellazione (non implementato)
                        If oInfoOperazione.AzioneDAE = "INSERT" Then
                            iAzioneDAE = AZIONE_INSERIMENTO
                        ElseIf oInfoOperazione.AzioneDAE = "UPDATE" Then
                            iAzioneDAE = AZIONE_AGGIORNAMENTO
                        End If
                        '
                        ' Eseguo la notifica nella tabella di coda
                        '
                        Call ExecNotificaCodaOutput(oConn, oTrans,
                                                     NotaAnamnestica.IdEsterno, oInfoOperazione.IdNotaAnamnestica, NotaAnamnestica.AziendaErogante, NotaAnamnestica.SistemaErogante,
                                                     iAzioneDAE, oInfoOperazione.NotaAnamnesticaXml, bRetNotificaByOrch)
                    End If
                End If
            End If
            '
            ' COMMIT della transazione
            '
            oTrans.Commit()
            '
            ' Eseguo la SP di creazione dell'anteprima fuori dalla transazione (come fatto per i referti ed eventi).
            '
            Call ExecAggiornamentoAnteprima(IdPazienteSAC)
            '
            ' Se sono qui non si sono verificati errori
            ' Se la notifica la deve eseguire l'orchestrazione (bRetNotificaByOrch = True) costruisco l'oggetto di ritorno oNotaAnamnesticaReturnType
            ' fuori dalla transazione
            '
            Dim oNotaAnamnesticaReturn As New NotaAnamnesticaReturn
            If bRetNotificaByOrch Then
                '
                ' Costruisco l'oggetto NotaAnamnesticaReturnType dell'oggetto NotaAnamnesticaReturn
                '
                Dim oNotaAnamnesticaReturnBuilder As New NotaAnamnesticaReturnBuilder(NotaAnamnestica.IdEsterno, DataModificaEsterno, iAzioneDAE, oInfoOperazione.NotaAnamnesticaXml)
                oNotaAnamnesticaReturn.NotaAnamnestica = oNotaAnamnesticaReturnBuilder.BuildNotaAnamnesticaReturnType
#If DEBUG Then
                '
                ' Converto in XML l'oggetto da restituire per fare delle verifiche in fase di sviluppo
                '
                Dim sXmlNotaAnamnesticaReturn As String = GenericDataContractSerializer.Serialize(oNotaAnamnesticaReturn)
                Dim i As Integer = 0
#End If

            Else
                oNotaAnamnesticaReturn.NotaAnamnestica = Nothing
            End If

            '
            ' Restituico l'oggetto che verrà passato all'orchestrazione
            '
            Return oNotaAnamnesticaReturn

        Catch
            ' In caso di errore eseguo il ROLLBACK
            If oTrans IsNot Nothing Then oTrans.Rollback()
            ' Le eccezioni sono gestite esternamente
            Throw
        Finally
            If oConn IsNot Nothing AndAlso oConn.State = ConnectionState.Open Then
                oConn.Close()
            End If
        End Try

    End Function


    ''' <summary>
    ''' Esegue la rimozione della nota anamnestica
    ''' </summary>
    ''' <param name="NotaAnamnestica"></param>
    ''' <param name="DataModificaEsterno"></param>
    ''' <returns></returns>
    Public Shared Function Rimuovi(ByVal NotaAnamnestica As NotaAnamnesticaType, DataModificaEsterno As DateTime) As NotaAnamnesticaReturn
        Dim iAzioneDAE As Integer = AZIONE_CANCELLAZIONE
        Dim sXmlNotaAnamnestica As String = String.Empty
        '
        ' Definisco la variabile che decide se compilare il dato di ritorno del metodo 
        '
        Dim bRetNotificaByOrch As Boolean = False

        Dim oConn As New SqlClient.SqlConnection(My.Settings.DWHConnectionString)
        Dim oTrans As SqlClient.SqlTransaction = Nothing

        ' Try catch per gestire la TRANSAZIONE , tutte le eccezioni passano fuori
        Try
            '
            ' Apertura connessione e transazione
            '
            Try
                oConn.Open()
            Catch ex As Exception
                Throw New Exception(String.Concat("DAE NoteAnamnestiche: ", ERRORE_APERTURA_CONNESSIONE, vbCrLf, "Database DwhClinico", vbCrLf, ex.Message))
            End Try

            oTrans = oConn.BeginTransaction


            Dim oIdNotaAnamnestica As Guid = Nothing
            Dim dDataPartizione As Date = Nothing
            Dim dDataModificaEsternoCorrente As Date = Nothing
            '
            ' Verifico l'esistenza del record
            '
            Dim odtNoteAnamnesticheEsiste As DwhDataSet.NoteAnamnesticheEsisteDataTable = Nothing
            Using ta As New NoteAnamnesticheEsisteTableAdapter(oConn, oTrans)
                odtNoteAnamnesticheEsiste = ta.GetData(NotaAnamnestica.IdEsterno)
                If Not odtNoteAnamnesticheEsiste Is Nothing And odtNoteAnamnesticheEsiste.Rows.Count > 0 Then
                    Dim oRow As DwhDataSet.NoteAnamnesticheEsisteRow = odtNoteAnamnesticheEsiste(0)
                    oIdNotaAnamnestica = oRow.IdNotaAnamnestica
                    dDataPartizione = oRow.DataPartizione
                    'La DataModificaEsterno è NULLABILE, ma è sempre valorizzata!!!
                    dDataModificaEsternoCorrente = oRow.DataModificaEsterno
                End If
            End Using

            '
            ' Se il record esiste ed è precedente al messaggio di cancellazione
            '
            If oIdNotaAnamnestica <> Nothing Then
                If dDataModificaEsternoCorrente <= DataModificaEsterno Then
                    '
                    ' Se la DataModificaEsterno del record su db è antecedente o uguale a quella passata dal chiamante
                    ' significa che posso cancellare in quanto il record è lo stesso o o più vecchio;
                    ' Altrimenti su db c'è una versione più recente di quella del chiamante e non la devo cancellare.
                    '
                    sXmlNotaAnamnestica = ExecRimuovi(oConn, oTrans, oIdNotaAnamnestica, dDataPartizione)

                    '
                    ' Se sono qui è avvenuta la cancellazione
                    '
                    Dim sTraceMsg As String = String.Format("DWH.ExtNoteAnamnesticheRimuovi: IdNotaAnamnestica={0}, DataPartizione={1}, Azione={2}",
                                               oIdNotaAnamnestica.NullSafeToString("NULL"),
                                               dDataPartizione.NullSafeToString("NULL"),
                                               iAzioneDAE.NullSafeToString("NULL"))
                    sTraceMsg = String.Concat(sTraceMsg, vbCrLf, NotaAnamnestica.Descrizione)
                    Log.TraceWrite(sTraceMsg, TraceLevel.Info.ToString, TraceLevel.Info.ToString)

                    '
                    ' Leggo tabella di configurazione per capire se è l'orchestrazione che deve eseguire la notifica di OUTPUT
                    '
                    bRetNotificaByOrch = GetNotificaByOrchestrazione(oConn, oTrans, NotaAnamnestica.AziendaErogante, NotaAnamnestica.SistemaErogante)
                    '
                    ' Invoco la SP di notifica: in base al valore di bRetNotificaByOrch inserirà in CodaNoteAnamnesticheOuptut o CodaNoteAnamnesticheOutputInviati
                    ' Eseguo la notifica nella tabella di coda
                    '
                    Call ExecNotificaCodaOutput(oConn, oTrans,
                                                     NotaAnamnestica.IdEsterno, oIdNotaAnamnestica, NotaAnamnestica.AziendaErogante, NotaAnamnestica.SistemaErogante,
                                                     iAzioneDAE, sXmlNotaAnamnestica, bRetNotificaByOrch)

                Else
                    Log.WriteWarning(String.Format("DWH.ExtNoteAnamnesticheEsiste: la nota anamnestica nel database ha DataModificaEsterno più recente: IdEsterno={0}, DataModificaEsterno del record ={1} DataModificaEsterno del messaggio:{2}", NotaAnamnestica.IdEsterno, dDataModificaEsternoCorrente, DataModificaEsterno))
                End If
            Else
                Log.WriteWarning(String.Format("DWH.ExtNoteAnamnesticheEsiste: la nota anamnestica non esiste: IdEsterno={0}", NotaAnamnestica.IdEsterno))
            End If
            '
            ' COMMIT della transazione
            '
            oTrans.Commit()
            '
            ' Se sono qui non si sono verificati errori
            ' Se la notifica la deve eseguire l'orchestrazione (bRetNotificaByOrch = True) costruisco l'oggetto di ritorno oNotaAnamnesticaReturnType
            ' fuori dalla transazione
            '
            Dim oNotaAnamnesticaReturn As New NotaAnamnesticaReturn
            If bRetNotificaByOrch Then
                '
                ' Costruisco l'oggetto NotaAnamnesticaReturnType dell'oggetto NotaAnamnesticaReturn
                '
                Dim oNotaAnamnesticaReturnBuilder As New NotaAnamnesticaReturnBuilder(NotaAnamnestica.IdEsterno, DataModificaEsterno, iAzioneDAE, sXmlNotaAnamnestica)
                oNotaAnamnesticaReturn.NotaAnamnestica = oNotaAnamnesticaReturnBuilder.BuildNotaAnamnesticaReturnType
#If DEBUG Then
                '
                ' Converto in XML l'oggetto da restituire per fare delle verifiche in fase di sviluppo
                '
                Dim sXmlNotaAnamnesticaReturn As String = GenericDataContractSerializer.Serialize(oNotaAnamnesticaReturn)
                Dim i As Integer = 0
#End If
            Else
                oNotaAnamnesticaReturn.NotaAnamnestica = Nothing
            End If

            '
            ' Aggiornamento anteprima: ricavo l'IdPaziente da sXmlNotaAnamnestica (in sXmlNotaAnamnestica c'è sempre l'IdPazienteAttivo)
            '
            If Not String.IsNullOrEmpty(sXmlNotaAnamnestica) Then
                Dim IdPazienteSAC As Guid = DwhHelper.GetIdPaziente(sXmlNotaAnamnestica)
                Call ExecAggiornamentoAnteprima(IdPazienteSAC)
            End If
            '
            ' Restituico l'oggetto che verrà passato all'orchestrazione
            '
            Return oNotaAnamnesticaReturn

        Catch
            ' In caso di errore eseguo il ROLLBACK
            If oTrans IsNot Nothing Then oTrans.Rollback()
            ' Le eccezioni sono gestite esternamente
            Throw
        Finally
            If oConn IsNot Nothing AndAlso oConn.State = ConnectionState.Open Then
                oConn.Close()
            End If
        End Try
    End Function


#Region "Funzioni private per esecuzione degli adapter"

    Private Class InfoOperazioneReturnType
        Public AzioneDAE As String
        Public DataPartizione As Date
        Public IdNotaAnamnestica As Guid
        Public NotaAnamnesticaXml As String
    End Class
    Private Shared Function ExecAggiungiOrAggiorna(ByVal oConn As SqlClient.SqlConnection, ByVal oTrans As SqlClient.SqlTransaction,
                                                   ByVal IdEsternoNotaAnamnestica As String, ByVal IdPazienteSac As Nullable(Of Guid), ByVal DataModificaEsterno As Nullable(Of Date),
                                                   ByVal sContenutoHtml As String, ByVal sContenutoText As String, ByVal msXmlAttributi As String,
                                                   ByVal NotaAnamnestica As NotaAnamnesticaType) As InfoOperazioneReturnType
        '-------------------------------------------------------------------------------
        ' PARAMETRI DELLA SP ExtNoteAnamnesticheAggiungi
        '-------------------------------------------------------------------------------
        ' @IdEsternoNotaAnamnestica			varchar (64)
        ', @IdPaziente						uniqueidentifier
        ', @DataModificaEsterno				datetime                -- = DataSequenza
        ', @StatoCodice						tinyint
        ', @AziendaErogante					varchar(16)
        ', @SistemaErogante					varchar(16)
        ', @DataNota						datetime
        ', @DataFineValidita                datetime
        ', @TipoCodice						varchar(16)
        ', @TipoDescrizione					varchar(256)
        ', @TipoContenuto					varchar(64)
        ', @Contenuto						varbinary(MAX)
        ', @ContenutoHTML					varchar(MAX)
        ', @ContenutoText					varchar(MAX)
        ', @Attributi						xml = NULL
        '-------------------------------------------------------------------------------
        Dim oRet As New InfoOperazioneReturnType
        Dim odtNoteAnamnesticheAggiungi As DwhDataSet.NoteAnamnesticheAggiungiDataTable = Nothing
        Using ta As New NoteAnamnesticheAggiungiTableAdapter(oConn, oTrans)
            odtNoteAnamnesticheAggiungi = ta.GetData(
                            NotaAnamnestica.IdEsterno, IdPazienteSac, DataModificaEsterno, NotaAnamnestica.StatoCodice,
                            NotaAnamnestica.AziendaErogante, NotaAnamnestica.SistemaErogante, NotaAnamnestica.DataNota, NotaAnamnestica.DataFineValidita,
                            NotaAnamnestica.TipoCodice, NotaAnamnestica.TipoDescrizione,
                            NotaAnamnestica.TipoContenuto, NotaAnamnestica.Contenuto,
                            sContenutoHtml, sContenutoText,
                            msXmlAttributi)
        End Using
        '
        ' Restituisco i parametri restituiti dall'esecuzione della stored procedure
        '
        If Not odtNoteAnamnesticheAggiungi Is Nothing AndAlso odtNoteAnamnesticheAggiungi.Count > 0 Then
            Dim oRow As DwhDataSet.NoteAnamnesticheAggiungiRow = odtNoteAnamnesticheAggiungi(0)
            'Se la SP non esegue nulla allora oRow.Azione è NULL
            If Not oRow.IsAzioneNull Then
                oRet.AzioneDAE = oRow.Azione
            End If
            oRet.DataPartizione = oRow.DataPartizione
            oRet.IdNotaAnamnestica = oRow.IdNotaAnamnestica
            oRet.NotaAnamnesticaXml = oRow.NotaAnamnesticaXML
        Else
            'Un errore custom non fa eseguire il retry
            Dim sErrMsg As String = String.Concat("La SP NoteAnamnesticheAggiungi non ha restituito nessun record.", vbCrLf, NotaAnamnestica.Descrizione)
            Throw New CustomException(sErrMsg, ErrorCodes.ErroreGenerico)
        End If
        '
        '
        '
        Return oRet
    End Function

    '
    ' Restituisce l'XML della nota anamnestica cancellata
    '
    Private Shared Function ExecRimuovi(ByVal oConn As SqlClient.SqlConnection, ByVal oTrans As SqlClient.SqlTransaction,
                                          ByVal oIdNotaAnamnestica As Guid, ByVal dDataPartizione As Date) As String
        '-------------------------------------------------------------------------------
        ' PARAMETRI DELLA SP ExtNoteAnamnesticheRimuovi
        '-------------------------------------------------------------------------------
        ' @IdNotaAnamnestica		uniqueidentifier
        ' , @DataPartizione		smalldatetime
        '-------------------------------------------------------------------------------
        Dim oNotaAnamnesticaXml As Object = String.Empty
        Dim sRetXml As String = String.Empty
        '
        ' Eseguo la rimozione (solo se ho trovato la nota anamnestica e dDataModificaEsternoCorrente.Value <= DataModificaEsterno) 
        '
        Dim odtNoteAnamnesticheRimuovi As DwhDataSet.NoteAnamnesticheRimuoviDataTable = Nothing
        Using ta As New NoteAnamnesticheRimuoviTableAdapter(oConn, oTrans)
            odtNoteAnamnesticheRimuovi = ta.GetData(oIdNotaAnamnestica, dDataPartizione, oNotaAnamnesticaXml)
            If Not odtNoteAnamnesticheRimuovi Is Nothing AndAlso odtNoteAnamnesticheRimuovi.Rows.Count > 0 Then
                If odtNoteAnamnesticheRimuovi(0).DELETED_COUNT > 0 Then
                    '
                    ' Memorizzo l'XML del record cancellato
                    '
                    sRetXml = CType(oNotaAnamnesticaXml, String)
                End If
            End If
        End Using
        '
        '
        '
        Return sRetXml
    End Function

    ''' <summary>
    ''' Restituisce true se la notifica la deve fare l'orchestrazione
    ''' </summary>
    ''' <param name="oConn"></param>
    ''' <param name="oTrans"></param>
    ''' <param name="AziendaErogante"></param>
    ''' <param name="SistemaErogante"></param>
    ''' <returns></returns>
    Private Shared Function GetNotificaByOrchestrazione(ByVal oConn As SqlClient.SqlConnection, ByVal oTrans As SqlClient.SqlTransaction, ByVal AziendaErogante As String, ByVal SistemaErogante As String) As Boolean
        Dim oRet As Boolean = False
        Using ta As New DwhDataSetTableAdapters.NoteAnamnesticheNotificaByOrchestrazioneTableAdapter(oConn, oTrans)
            Dim odt As DwhDataSet.NoteAnamnesticheNotificaByOrchestrazioneDataTable = ta.GetData(AziendaErogante, SistemaErogante, Nothing)
            If Not odt Is Nothing AndAlso odt.Count > 0 Then
                Dim oRow As DwhDataSet.NoteAnamnesticheNotificaByOrchestrazioneRow = odt(0)
                If Not oRow.IsNotificaByOrchNull Then
                    oRet = oRow.NotificaByOrch
                End If
            End If
        End Using
        '
        ' Restituisco
        '
        Return oRet
    End Function

    Private Shared Sub ExecNotificaCodaOutput(ByVal oConn As SqlClient.SqlConnection, ByVal oTrans As SqlClient.SqlTransaction, ByVal IdEsterno As String, ByVal IdNotaAnamnestica As Guid, ByVal AziendaErogante As String, ByVal SistemaErogante As String, AzioneDAE As Integer, ByVal NotaAnamnesticaXml As String, ByVal NotificaByOrch As Boolean)
        Using taNotifica As New NoteAnamnesticheNotificaTableAdapter(oConn, oTrans)
            Dim iTipoNotifica As Integer = 0
            If NotificaByOrch Then
                iTipoNotifica = 0 'Viene inserita la notifica in CodaNoteAnamnesticheOutputInviati
            Else
                iTipoNotifica = 1 'Viene inserita la notifica in CodaNoteAnamnesticheOutput
            End If
            '
            ' Il parametro "Notifica" della SP indica se si deve inserire in CodaNoteAnamnesticheOutput: 
            ' Se Notifica = False    (La SP inserisce in CodaNoteAnamnesticheOutputInviati a scopo di log)
            ' Se Notifica = True     (La SP inserisce in CodaNoteAnamnesticheOutput)
            '
            taNotifica.GetData(IdEsterno, IdNotaAnamnestica, AziendaErogante, SistemaErogante, AzioneDAE, NotaAnamnesticaXml, iTipoNotifica)
        End Using
    End Sub

    Private Shared Sub ExecAggiornamentoAnteprima(ByVal IdPazienteSAC As Guid)
        Using taAnteprima As New DwhDataSetTableAdapters.QueriesTableAdapter
            taAnteprima.ExtNoteAnamnesticheCalcolaAnteprimaPaziente(IdPazienteSAC)
        End Using
    End Sub
#End Region


    Public Shared Function GetIdPaziente(ByVal Xml As String) As Guid
        Dim oIdPaziente As Guid = Nothing

        Dim xmlRoot As XElement = XElement.Parse(Xml)
        oIdPaziente = New Guid(xmlRoot.XPathSelectElement("IdPaziente").GetStringValue()) 'IdPaziente è OBBLIGATORIO quindi sempre valorizzato
        '
        ' Restituisco
        '
        Return oIdPaziente
    End Function

End Class
