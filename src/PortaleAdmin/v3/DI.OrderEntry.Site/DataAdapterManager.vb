Imports System
Imports System.Data
Imports System.Web.UI
Imports System.Data.SqlClient
Imports System.Configuration
Imports System.ComponentModel
Imports System.Web.SessionState

Imports DI.OrderEntry.Admin.Data.OrdiniTableAdapters
Imports DI.OrderEntry.Admin.Data.Ordini
Imports DI.OrderEntry.Admin.Data.MessaggiTableAdapters
Imports DI.OrderEntry.Admin.Data.Messaggi
Imports DI.OrderEntry.Admin.Data.Utenti
Imports DI.OrderEntry.Admin.Data.EnnupleTableAdapters
Imports DI.OrderEntry.Admin.Data.Ennuple
Imports DI.OrderEntry.Admin.Data.Profili
Imports DI.OrderEntry.Admin.Data.ProfiliTableAdapters
Imports DI.OrderEntry.Admin.Data.DatiAccessoriTableAdapters
Imports DI.OrderEntry.Admin.Data.DatiAccessori
Imports DI.OrderEntry.Admin.Data.UtentiTableAdapters
'Imports DI.OrderEntry.Admin.Data.RuoliTableAdapters
'Imports DI.OrderEntry.Admin.Data.Ruoli

Imports DI.PortalAdmin.Data


Namespace DI.OrderEntry.Admin.Data

    <DataObjectAttribute(True)>
    Public NotInheritable Class DataAdapterManager

        ''' <summary>
        ''' Rappresenta la versione minima del DB 
        ''' </summary>
        ''' <remarks></remarks>
        Private Shared ReadOnly ApplicationDBVersion As New Version("1.0")

        Public Shared ReadOnly PortalAdminDataAdapterManager As PortalDataAdapterManager

        Private Sub New()

        End Sub

        Shared Sub New()
            PortalAdminDataAdapterManager = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
        End Sub

        ''' <summary>
        ''' Restituisce la tabella di lookup UILookupAziende
        ''' </summary>
        ''' <param name="dataTable">L'oggetto da popolare</param>
        ''' <param name="codice">parametro opzionale per restituire un valore a partire dal codice</param>
        ''' <param name="addEmpty">Se true, la tabella conterrà un campo iniziale vuoto</param>
        ''' <remarks></remarks>
        Public Shared Sub Fill(ByVal dataTable As UILookupAziendeDataTable, ByVal codice As String, ByVal addEmpty As Boolean)

            Using adapter As New UILookupAziendeTableAdapter()
                adapter.Fill(dataTable, codice)
            End Using

            If addEmpty Then
                dataTable.AddUILookupAziendeRow(" ", String.Empty)
            End If
        End Sub

        Public Shared Sub Fill(ByVal dataTable As UiLookupDatiAccessoriValoriDefaultDataTable)

            Using adapter As New UiLookupDatiAccessoriValoriDefaultTableAdapter()
                adapter.Fill(dataTable, Nothing)
            End Using
        End Sub

        Public Shared Sub Fill(ByVal dataTable As UiLookupSistemiErogantiDataTable, ByVal codice As String, ByVal addEmpty As Boolean)

            Using adapter As New UiLookupSistemiErogantiTableAdapter()

                adapter.Fill(dataTable, codice)
            End Using

            If addEmpty Then

                dataTable.AddUiLookupSistemiErogantiRow(Guid.Empty, " ", String.Empty)
            End If
        End Sub

        Public Shared Sub Fill(ByVal dataTable As UiLookupStatiCalcolatiOrdineDataTable, ByVal codice As String, ByVal addEmpty As Boolean)

            Using adapter As New UiLookupStatiCalcolatiOrdineTableAdapter()
                adapter.Fill(dataTable, codice)
            End Using

            If addEmpty Then
                dataTable.Rows.InsertAt(dataTable.NewUiLookupStatiCalcolatiOrdineRow, 0)
                'dataTable.AddUiLookupStatiCalcolatiOrdineRow(String.Empty)
            End If
        End Sub

        Public Shared Sub Fill(ByVal dataTable As UiLookupSistemiRichiedentiDataTable, ByVal codice As String, ByVal addEmpty As Boolean)

            Using adapter As New UiLookupSistemiRichiedentiTableAdapter()

                adapter.Fill(dataTable, codice)
            End Using

            If addEmpty Then

                dataTable.AddUiLookupSistemiRichiedentiRow(Guid.Empty, " ", String.Empty)
            End If
        End Sub

        ''' <summary>
        ''' Restituisce la tabella di lookup UILookupStatiOrdineDataTable
        ''' </summary>
        ''' <param name="dataTable">L'oggetto da popolare</param>
        ''' <param name="codice">parametro opzionale per restituire un valore a partire dal codice</param>
        ''' <param name="addEmpty">Se true, la tabella conterrà un campo iniziale vuoto</param>
        ''' <remarks></remarks>
        Public Shared Sub Fill(ByVal dataTable As UILookupStatiOrdineDataTable, ByVal codice As String, ByVal addEmpty As Boolean)

            Using adapter As New UILookupStatiOrdineTableAdapter()

                adapter.Fill(dataTable, codice)
            End Using

            If addEmpty Then

                dataTable.AddUILookupStatiOrdineRow(" ", String.Empty, Byte.MinValue)
            End If
        End Sub

        Public Shared Sub Fill(ByVal dataTable As UiOrdiniErogatiTestateSelectDataTable, ByVal id As Guid)

            Using adapter As New UiOrdiniErogatiTestateSelectTableAdapter()
                adapter.Fill(dataTable, id)
            End Using
        End Sub

        Public Shared Sub Fill(ByVal dataTable As UiOrdiniTestateDatiAggiuntiviListDataTable, ByVal id As Guid)

            Using adapter As New UiOrdiniTestateDatiAggiuntiviListTableAdapter()
                adapter.Fill(dataTable, id)
            End Using
        End Sub

        Public Shared Sub Fill(ByVal dataTable As UiOrdiniRigheRichiesteDatiAggiuntiviListDataTable, ByVal id As Guid)

            Using adapter As New UiOrdiniRigheRichiesteDatiAggiuntiviListTableAdapter()
                adapter.Fill(dataTable, id)
            End Using
        End Sub

        Public Shared Sub Fill(ByVal dataTable As UiOrdiniRigheErogateDatiAggiuntiviListDataTable, ByVal id As Guid)

            Using adapter As New UiOrdiniRigheErogateDatiAggiuntiviListTableAdapter()
                adapter.Fill(dataTable, id)
            End Using
        End Sub

        Public Shared Sub Fill(ByVal dataTable As UiOrdiniErogatiTestateDatiAggiuntiviListDataTable, ByVal id As Guid)

            Using adapter As New UiOrdiniErogatiTestateDatiAggiuntiviListTableAdapter()
                adapter.Fill(dataTable, id)
            End Using
        End Sub

        Public Shared Sub Fill(ByVal dataTable As UiMessaggiRichiesteSelectDataTable, ByVal id As Guid)

            Using adapter As New UiMessaggiRichiesteSelectTableAdapter()
                adapter.Fill(dataTable, id)
            End Using
        End Sub

        Public Shared Sub Fill(ByVal dataTable As UiMessaggiStatiSelectDataTable, ByVal id As Guid)

            Using adapter As New UiMessaggiStatiSelectTableAdapter()
                adapter.Fill(dataTable, id)
            End Using
        End Sub

        Public Shared Sub Fill(ByVal dataTable As UiTrackingSelectDataTable, ByVal id As Guid)

            Using adapter As New UiTrackingSelectTableAdapter()
                adapter.Fill(dataTable, id)
            End Using
        End Sub

        Public Shared Function CopiaEnnupla(idEnnupla As Guid, userName As String) As Integer

            Using adapter As New EnnupleQuery()

                adapter.UiEnnupleCopy(idEnnupla, userName)
            End Using

            Return 0
        End Function

        Public Shared Function EliminaEnnupla(idEnnupla As Guid) As Integer

            Using adapter As New EnnupleQuery()

                adapter.UiEnnupleDelete(idEnnupla)
            End Using

            Return 0
        End Function

        Public Shared Function CopiaEnnuplaAccessi(idEnnupla As Guid, userName As String) As Integer

            Using adapter As New Data.EnnupleAccessiTableAdapters.EnnupleAccessiQuery()

                adapter.UiEnnupleAccessiCopy(idEnnupla, userName)
            End Using

            Return 0
        End Function

        Public Shared Function EliminaEnnuplaAccessi(idEnnupla As Guid) As Integer

            Using adapter As New Data.EnnupleAccessiTableAdapters.EnnupleAccessiQuery()

                adapter.UiEnnupleAccessiDelete(idEnnupla)
            End Using

            Return 0
        End Function

        ''' <summary>
        ''' Restituisce il dettaglio del messaggio di validazione dell'ordine (richiesta)
        ''' </summary>
        ''' <param name="datatable"></param>
        ''' <param name="id"></param>
        ''' <remarks></remarks>
        Public Shared Sub Fill(ByVal dataTable As UiOrdiniMessaggiValidazioneListDataTable, ByVal id As Guid)

            Using adapter As New UiOrdiniMessaggiValidazioneListTableAdapter
                adapter.Fill(dataTable, id)
            End Using

        End Sub

#Region "UtentiGruppi"
        'Public Shared Sub Fill(ByVal dataTable As UiGruppiUtentiListDataTable, descrizione As String)

        '	Using adapter As New UiGruppiUtentiListTableAdapter()
        '		adapter.Fill(dataTable, descrizione)
        '	End Using
        'End Sub

        Public Shared Sub Fill(ByVal dataTable As Data.Ennuple.UiUtentiListDataTable, idGruppo As Guid, descrizione As String)

            Using adapter As New Data.EnnupleTableAdapters.UiUtentiListTableAdapter()
                adapter.Fill(dataTable, idGruppo, descrizione)
            End Using
        End Sub

        Public Shared Sub Fill(ByVal dataTable As UiUtentiSelectDataTable, idUtente As Guid?)

            Using adapter As New UiUtentiSelectTableAdapter()
                adapter.Fill(dataTable, idUtente, Nothing, Nothing, Nothing)
            End Using
        End Sub

        Public Shared Function Update(dataTable As UiGruppiUtentiListDataTable) As Integer

            Using adapter As New UiGruppiUtentiListTableAdapter()
                Return adapter.Update(dataTable)
            End Using
        End Function

        'Public Shared Function Update(dataTable As UiUtentiSelectDataTable) As Integer

        '	Using adapter As New UiUtentiSelectTableAdapter()
        '		Return adapter.Update(dataTable)
        '	End Using
        'End Function

        Public Shared Function DeleteGroup(idGruppo As Guid) As Integer

            Using adapter As New UiGruppiUtentiListTableAdapter()

                adapter.Delete(idGruppo)
            End Using

            Return 0
        End Function

        Public Shared Function DeleteUserFromGroup(idUtente As Guid, idGruppo As Guid) As Integer

            Using adapter As New EnnupleQuery()

                adapter.UiUtentiGruppiUtentiDelete(idUtente, idGruppo)
            End Using

            Return 0
        End Function

        Public Shared Function InsertUsersInGroup(idGruppo As Guid, idUtenti As Guid()) As Integer

            Using adapter As New EnnupleQuery()

                For Each idUtente As Guid In idUtenti
                    Dim oRet = adapter.UiUtentiGruppiUtentiInsert(idUtente, idGruppo)
                Next
            End Using

            Return 0
        End Function

#End Region

#Region "PrestazioniGruppi"

        Public Shared Sub Fill(ByVal dataTable As UiGruppiPrestazioniListDataTable, ByVal descrizione As String, ByVal preferiti As Boolean?, CodiceDescrizionePrestazione As String, IdSistemaErogante As Guid?, note As String)

            Using adapter As New UiGruppiPrestazioniListTableAdapter()
                adapter.Fill(dataTable, descrizione, preferiti, CodiceDescrizionePrestazione, IdSistemaErogante, note)
            End Using
        End Sub

        Public Shared Sub Fill(ByVal dataTable As UiPrestazioniListDataTable, idGruppo As Guid, ByVal codiceDescrizione As String, ByVal idSistemaErogante As Guid?)

            Using adapter As New UiPrestazioniListTableAdapter()
                adapter.Fill(dataTable, idGruppo, codiceDescrizione, idSistemaErogante)
            End Using
        End Sub

        Public Shared Sub Fill(ByVal dataTable As UiPrestazioniSelectDataTable, idPrestazione As Guid?, codiceDescrizione As String, idSistemaErogante As Guid?, attivo As Boolean?)

            Using adapter As New UiPrestazioniSelectTableAdapter()
                adapter.Fill(dataTable, idPrestazione, codiceDescrizione, idSistemaErogante, attivo)
            End Using
        End Sub


        Public Shared Sub Fill(ByVal dataTable As Data.Prestazioni.UiPrestazioniSelectDataTable, idPrestazione As Guid?, codiceDescrizione As String, idSistemaErogante As Guid?, attivo As Boolean?, sistemaAttivo As Boolean?, RichiedibileSOloDaProfilo As Boolean?)
            Using adapter As New Data.PrestazioniTableAdapters.UiPrestazioniSelectTableAdapter()
                adapter.Fill(dataTable, idPrestazione, codiceDescrizione, idSistemaErogante, attivo, sistemaAttivo, RichiedibileSOloDaProfilo)
            End Using
        End Sub

        'Public Shared Sub Fill(ByVal dataTable As Data.Prestazioni.UiPrestazioniSelectDataTable, idPrestazione As Guid?, codiceDescrizione As String, idSistemaErogante As Guid?, tipo As Byte?, attivo As Boolean?)

        '	Using adapter As New Data.PrestazioniTableAdapters.UiPrestazioniSelectTableAdapter()
        '		adapter.FillByTipo(dataTable, idPrestazione, codiceDescrizione, idSistemaErogante, tipo, attivo)
        '	End Using
        'End Sub

        Public Shared Sub Fill(ByVal dataTable As Data.Profili.UiProfiliPrestazioniSelectDataTable, idPrestazione As Guid?, codiceDescrizione As String, idSistemaErogante As Guid?, tipo As Byte?, attivo As Boolean?)

            Using adapter As New Data.ProfiliTableAdapters.UiProfiliPrestazioniSelectTableAdapter()
                adapter.Fill(dataTable, idPrestazione, codiceDescrizione, idSistemaErogante, attivo)
            End Using

        End Sub

        Public Shared Function Update(dataTable As Data.Prestazioni.UiPrestazioniSelectDataTable) As Integer

            Using adapter As New Data.PrestazioniTableAdapters.UiPrestazioniSelectTableAdapter()
                Return adapter.Update(dataTable)
            End Using
        End Function

        Public Shared Function Update(dataTable As UiGruppiPrestazioniListDataTable) As Integer

            Using adapter As New UiGruppiPrestazioniListTableAdapter()
                Return adapter.Update(dataTable)
            End Using
        End Function

        Public Shared Function DeleteGroupPrestazioni(idGruppo As Guid) As Integer

            Using adapter As New UiGruppiPrestazioniListTableAdapter()

                adapter.Delete(idGruppo)
            End Using

            Return 0
        End Function

        Public Shared Function DeletePrestazioneFromGroup(idPrestazione As Guid, idGruppo As Guid) As Integer

            Using adapter As New EnnupleQuery()

                adapter.UiPrestazioniGruppiPrestazioniDelete(idPrestazione, idGruppo)
            End Using

            Return 0
        End Function

        Public Shared Function InsertPrestazioniInGroup(idGruppo As Guid, idPrestazioni As Guid()) As Integer

            Using adapter As New EnnupleQuery()

                For Each idPrestazione As Guid In idPrestazioni
                    adapter.UiPrestazioniGruppiPrestazioniInsert(idPrestazione, idGruppo)
                Next
            End Using

            Return 0
        End Function

        Public Shared Function PrestazioniGruppiPrestazioniCopy(IDGruppoOrigine As Guid, IDGruppoDestinazione As Guid) As Integer

            Using adapter As New EnnupleQuery()
                adapter.UiPrestazioniGruppiPrestazioniCopy(IDGruppoOrigine, IDGruppoDestinazione)
            End Using

            Return 0
        End Function


#End Region

#Region "Profili"

        Public Shared Sub Fill(ByVal dataTable As UiProfiliPrestazioniListDataTable, codiceDescrizione As String, attivo As Boolean?, CodiceDescrizionePrestazione As String, IdSistemaErogante As Guid?, Note As String)

            Using adapter As New UiProfiliPrestazioniListTableAdapter()
                adapter.Fill(dataTable, codiceDescrizione, attivo, CodiceDescrizionePrestazione, IdSistemaErogante, Note)
            End Using
        End Sub

        Public Shared Sub Fill(ByVal dataTable As UiProfiliPrestazioniProfiliListDataTable, idProfilo As Guid, codiceDescrizione As String, idSistemaErogante As Guid?)

            Using adapter As New UiProfiliPrestazioniProfiliListTableAdapter()
                adapter.Fill(dataTable, idProfilo, codiceDescrizione, idSistemaErogante)
            End Using
        End Sub

        Public Shared Function Update(dataTable As UiProfiliPrestazioniListDataTable) As Integer

            Using adapter As New UiProfiliPrestazioniListTableAdapter()
                Return adapter.Update(dataTable)
            End Using
        End Function

        Public Shared Function DeleteProfilePrestazioni(idProfilo As Guid, userName As String) As Integer

            Using adapter As New UiProfiliPrestazioniListTableAdapter()

                adapter.Delete(idProfilo, userName)
            End Using

            Return 0
        End Function

        Public Shared Function DeletePrestazioneFromProfile(idPrestazione As Guid, idProfilo As Guid) As Integer

            Using adapter As New ProfiliQuery()

                adapter.UiProfiliPrestazioniProfiliDelete(idPrestazione, idProfilo)
            End Using

            Return 0
        End Function

        Public Shared Function InsertPrestazioniInProfile(idProfilo As Guid, idPrestazioni As Guid()) As Integer

            Using adapter As New ProfiliQuery()

                For Each idPrestazione As Guid In idPrestazioni
                    adapter.UiProfiliPrestazioniProfiliInsert(idPrestazione, idProfilo)
                Next
            End Using

            Return 0
        End Function


        Public Shared Function PrestazioniProfiloPrestazioniCopy(IDProfiloOrigine As Guid, IDProfiloDestinazione As Guid) As Integer

            Using adapter As New ProfiliQuery
                adapter.UiPrestazioniProfiloPrestazioniCopy(IDProfiloOrigine, IDProfiloDestinazione)
            End Using

            Return 0
        End Function

#End Region



#Region "Ruoli"

        ' 08-10-2014  ESCLUSA DAL PROGETTO

        '		Public Shared Sub Fill(ByVal dataTable As UiRuoliListDataTable, descrizione As String, attivo As Boolean?)

        '			Using adapter As New UiRuoliListTableAdapter()
        '				adapter.Fill(dataTable, descrizione, attivo)
        '			End Using
        '		End Sub

        '		Public Shared Sub Fill(ByVal dataTable As UiUnitaOperativeListDataTable, idRuolo As Integer, codiceAzienda As String, codiceUO As String)

        '			Using adapter As New UiUnitaOperativeListTableAdapter()
        '				adapter.Fill(dataTable, idRuolo, codiceAzienda, codiceUO)
        '			End Using
        '		End Sub

        '		Public Shared Sub Fill(ByVal dataTable As Data.Ruoli.UiUtentiListDataTable, idRuolo As Integer, ByVal nomeUtente As String)

        '			Using adapter As New Data.RuoliTableAdapters.UiUtentiListTableAdapter()
        '				adapter.Fill(dataTable, idRuolo, nomeUtente)
        '			End Using
        '		End Sub

        '		Public Shared Function Update(dataTable As UiRuoliListDataTable) As Integer

        '			Using adapter As New UiRuoliListTableAdapter()
        '				Return adapter.Update(dataTable)
        '			End Using
        '		End Function

        '		Public Shared Function DeleteRuolo(idRuolo As Integer) As Integer

        '			Using adapter As New UiRuoliListTableAdapter()

        '				adapter.Delete(idRuolo)
        '			End Using

        '			Return 0
        '		End Function

        '		Public Shared Function DeleteUOFromRole(codiceAzienda As String, codiceUO As String, idRuolo As Integer) As Integer

        '			Using adapter As New RuoliQuery()

        '				Return adapter.UiRuoliUODelete(codiceAzienda, codiceUO, idRuolo)
        '			End Using
        '		End Function

        '		Public Shared Function InsertUoInRole(idRuolo As Integer, unitaOperative As String()) As Integer

        '			Using adapter As New RuoliQuery()

        '				For Each uo As String In unitaOperative
        '					adapter.UiRuoliUOInsert(uo.Split("-")(0), uo.Substring(uo.IndexOf("-") + 1), idRuolo)
        '				Next
        '			End Using

        '			Return 0
        '		End Function

        '		Public Shared Function DeleteUserFromRole(nomeUtente As String, idRuolo As Integer) As Integer

        '			Using adapter As New RuoliQuery()

        '				Return adapter.UiRuoliUtentiDelete(nomeUtente, idRuolo)
        '			End Using
        '		End Function

        '		Public Shared Function InsertUserInRole(idRuolo As Integer, nomeUtenti As String()) As Integer

        '			Using adapter As New RuoliQuery()

        '				For Each nomeUtente As String In nomeUtenti
        '					adapter.UiRuoliUtentiInsert(nomeUtente, idRuolo)
        '				Next
        '			End Using

        '			Return 0
        '		End Function

#End Region

#Region "DatiAccessori"

        Public Shared Sub Fill(ByVal dataTable As UiPrestazioniDatiAccessoriListDataTable, idPrestazione As Guid)

            Using adapter As New UiPrestazioniDatiAccessoriListTableAdapter()
                adapter.Fill(dataTable, idPrestazione)
            End Using
        End Sub

        Public Shared Sub Fill(ByVal dataTable As UiSistemiDatiAccessoriListDataTable, idSistema As Guid)

            Using adapter As New UiSistemiDatiAccessoriListTableAdapter()
                adapter.Fill(dataTable, idSistema)
            End Using
        End Sub

        Public Shared Function DeleteDatoAccessorioFromPrestazione(codiceDatoAccessorio As String, idPrestazione As Guid) As Integer

            Using adapter As New DatiAccessoriTableAdapter()

                adapter.UiPrestazioniDatiAccessoriDelete(idPrestazione, codiceDatoAccessorio)
            End Using

            Return 0
        End Function

        Public Shared Function InsertDatoAccessorioInPrestazione(idPrestazione As Guid, codici As String()) As Integer

            Using adapter As New DatiAccessoriTableAdapter()

                For Each codice As String In codici
                    adapter.UiPrestazioniDatiAccessoriInsert(idPrestazione, codice)
                Next
            End Using

            Return 0
        End Function

        Public Shared Function DeleteDatoAccessorioFromSistema(codiceDatoAccessorio As String, idSistema As Guid) As Integer

            Using adapter As New DatiAccessoriTableAdapter()

                adapter.UiSistemiDatiAccessoriDelete(idSistema, codiceDatoAccessorio)
            End Using

            Return 0
        End Function

        Public Shared Function InsertDatoAccessorioInSistema(idSistema As Guid, codici As String()) As Integer

            Using adapter As New DatiAccessoriTableAdapter()

                For Each codice As String In codici
                    adapter.UiSistemiDatiAccessoriInsert(idSistema, codice)
                Next
            End Using

            Return 0
        End Function

#End Region

        Public Shared Function CheckDatiAccessoriCodeUnicity(codice As String) As Integer

            Using adapter As New Data.DatiAccessoriTableAdapters.UiDatiAccessoriCheckCodeTableAdapter()

                Dim result = adapter.GetData(codice)

                If result.Count > 0 AndAlso Not result(0).IsColumn1Null() Then
                    Return result(0).Column1
                Else
                    Return -1
                End If
            End Using
        End Function

        Public Shared Function GetDatiAccessoriPreview(codice As String) As Data.DatiAccessori.UiDatiAccessoriPreviewDataTable

            Using adapter As New Data.DatiAccessoriTableAdapters.UiDatiAccessoriPreviewTableAdapter()

                Return adapter.GetData(codice)
            End Using
        End Function
        Public Shared Function GetDatiAccessoriSistemi(codice As String) As Data.DatiAccessori.UiDatiAccessoriSistemiDataTable

            Using adapter As New Data.DatiAccessoriTableAdapters.UiDatiAccessoriSistemiTableAdapter()

                Return adapter.GetData(codice)
            End Using
        End Function

        Public Shared Sub Fill(ByVal dataTable As Data.Sistemi.UiSistemiSelectDataTable, ByVal id As Guid?, codiceDescrizione As String, azienda As String, erogante As Boolean?, richiedente As Boolean?, attivo As Boolean?, cancellazionePostInoltro As Boolean?, cancellazionePostInCarico As Boolean?)

            Using adapter As New Data.SistemiTableAdapters.UiSistemiSelectTableAdapter()
                adapter.Fill(dataTable, id, codiceDescrizione, azienda, erogante, richiedente, attivo, cancellazionePostInoltro, cancellazionePostInCarico)
            End Using
        End Sub

        Public Shared Sub Fill(ByVal dataTable As Data.Sistemi.UiSistemiDatiAccessoriSelectDataTable, ByVal id As Guid?, ByVal codiceDatoAccessorio As String, ByVal idSistema As Guid?)

            Using adapter As New Data.SistemiTableAdapters.UiSistemiDatiAccessoriSelectTableAdapter()
                adapter.Fill(dataTable, id, codiceDatoAccessorio, idSistema)
            End Using
        End Sub

        Public Shared Sub Update(ByVal dataTable As Data.Sistemi.UiSistemiDatiAccessoriSelectDataTable)

            Using adapter As New Data.SistemiTableAdapters.UiSistemiDatiAccessoriSelectTableAdapter()
                adapter.Update(dataTable)
            End Using
        End Sub

        Public Shared Sub Fill(ByVal dataTable As Data.Prestazioni.UiPrestazioniDatiAccessoriSelectDataTable, ByVal id As Guid?, ByVal codiceDatoAccessorio As String, ByVal idPrestazione As Guid?)

            Using adapter As New Data.PrestazioniTableAdapters.UiPrestazioniDatiAccessoriSelectTableAdapter()
                adapter.Fill(dataTable, id, codiceDatoAccessorio, idPrestazione)
            End Using
        End Sub

        Public Shared Sub Update(ByVal dataTable As Data.Prestazioni.UiPrestazioniDatiAccessoriSelectDataTable)

            Using adapter As New Data.PrestazioniTableAdapters.UiPrestazioniDatiAccessoriSelectTableAdapter()
                adapter.Update(dataTable)
            End Using
        End Sub

        Public Shared Function Update(dataTable As Data.Sistemi.UiSistemiSelectDataTable) As Integer

            Using adapter As New Data.SistemiTableAdapters.UiSistemiSelectTableAdapter()
                Return adapter.Update(dataTable)
            End Using
        End Function

        Public Shared Sub Fill(ByVal dataTable As Data.DatiAccessori.UiDatiAccessoriListDataTable, codice As String, etichetta As String, tipo As String, Top As Integer?)

            Using adapter As New Data.DatiAccessoriTableAdapters.UiDatiAccessoriListTableAdapter()
                adapter.Fill(dataTable, codice, etichetta, tipo, Top)
            End Using
        End Sub

        Public Shared Function Update(dataTable As Data.DatiAccessori.UiDatiAccessoriListDataTable) As Integer

            Using adapter As New Data.DatiAccessoriTableAdapters.UiDatiAccessoriListTableAdapter()
                Return adapter.Update(dataTable)
            End Using
        End Function

        'Public Shared Sub Fill(ByVal dataTable As Data.UnitaOperative.UiUnitaOperativeSelectDataTable, ByVal id As Guid?, codiceDescrizione As String, azienda As String, ByVal attivo As Boolean?)

        '	Using adapter As New Data.UnitaOperativeTableAdapters.UiUnitaOperativeSelectTableAdapter()
        '		adapter.Fill(dataTable, id, codiceDescrizione, azienda, attivo)
        '	End Using
        'End Sub

        'Public Shared Function Update(dataTable As Data.UnitaOperative.UiUnitaOperativeSelectDataTable) As Integer
        '	Using adapter As New Data.UnitaOperativeTableAdapters.UiUnitaOperativeSelectTableAdapter()
        '		Return adapter.Update(dataTable)
        '	End Using
        'End Function

        Public Shared Sub Fill(ByVal dataTable As Data.Utenti.UiUtentiSelectDataTable, ByVal id As Guid?, codiceDescrizione As String, ByVal attivo As Boolean?)
            Using adapter As New Data.UtentiTableAdapters.UiUtentiSelectTableAdapter()
                adapter.Fill(dataTable, id, codiceDescrizione, attivo, Nothing)
            End Using
        End Sub


        Public Shared Sub Fill(ByVal dataTable As Data.Utenti.UiUtentiSelectDataTable, ByVal id As Guid?, codiceDescrizione As String, ByVal attivo As Boolean?, Delega As Integer?)
            Using adapter As New Data.UtentiTableAdapters.UiUtentiSelectTableAdapter()
                adapter.Fill(dataTable, id, codiceDescrizione, attivo, Delega)
            End Using
        End Sub


        Public Shared Function Update(dataTable As Data.Utenti.UiUtentiSelectDataTable) As Integer
            Using adapter As New Data.UtentiTableAdapters.UiUtentiSelectTableAdapter()
                Return adapter.Update(dataTable)
            End Using
        End Function

        Public Shared Function UtentiInsertOrUpdate(utente As String, descrizione As String, attivo As Boolean, delega As Integer) As Integer
            Using adapter As New Data.UtentiTableAdapters.QueriesTableAdapter

                Return adapter.UiUtentiInsertOrUpdate(utente, descrizione, attivo, delega)
            End Using
        End Function

        Public Shared Function PrestazioniInsertOrUpdate(codice As String, descrizione As String, idSistemaErogante As Guid, userName As String, attivo As Boolean, codiceSinonimo As String)

            Using adapter As New Data.PrestazioniTableAdapters.QueriesTableAdapter
                Return adapter.UiPrestazioniInsertOrUpdate(codice, descrizione, idSistemaErogante, userName, attivo, codiceSinonimo)
            End Using

        End Function

        Private Const GetSinotticoUltimaOraSpName = "dbo.UiSinottico1"
        Private Const GetSinotticoSistemiUltimaOraSpName = "dbo.UiSinotticoSistemi1"

        'MODIFICA ETTORE 2019-03-25: Nuove SP che leggono dalle tabelle SinotticoUltimoMese e SinotticoUltime24Ore 
        Private Const GetSinottico_Ultime24Ore_SpName = "dbo.UiSinotticoUltime24Ore"
        Private Const GetSinottico_Ultime24Ore_Sistemi_SpName = "dbo.UiSinotticoUltime24OreSistemi" 'per esplodere il sistema erogante nei sistemi richiedenti
        Private Const GetSinottico_UltimiNGiorni_SpName = "dbo.UiSinotticoUltimiNGiorni"  'usata sia per ultimi 7 giorni che ultimo mese
        Private Const GetSinottico_UltimiNGiorni_Sistemi_SpName = "dbo.UiSinotticoUltimiNGiorniSistemi" 'per esplodere il sistema erogante nei sistemi richiedenti


        ''' <summary>
        ''' Restituisce i dati del sinottico
        ''' </summary>
        ''' <param name="dataDa"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function GetSinottico2(dataDa As DateTime) As DataTable
            Dim resultTable = New DataTable()
            Dim spToUse As String = String.Empty
            Dim dNow As DateTime = DateTime.Now
            Dim oDateDiff As TimeSpan = dNow - dataDa

            'TODO: Attenzione alle SP si passa dataDa e dataA=dNow; nelle SP si filtra nell'intervallo  dataA <= Data <= DataDa. In questo modo se la differenza in giorni è 7 in realtà si leggono dati di 8 giorni 

            If oDateDiff.TotalHours < 2 Then
                'ULTIMA ORA
                spToUse = GetSinotticoUltimaOraSpName

                Using adapter As New SqlDataAdapter(spToUse, ConfigurationManager.ConnectionStrings("AuslAsmnRe_OrderEntryConnectionString").ConnectionString)

                    adapter.SelectCommand.CommandType = CommandType.StoredProcedure
                    adapter.SelectCommand.Parameters.Add("@DataDa", SqlDbType.DateTime2).Value = dataDa
                    adapter.SelectCommand.Parameters.Add("@DataA", SqlDbType.DateTime2).Value = dNow
                    adapter.Fill(resultTable)

                End Using

            ElseIf oDateDiff.TotalHours < 25 Then
                'ULTIME 24 ORE - legge tutta la tabella dove ci sono solo le ultime 24 ore
                spToUse = GetSinottico_Ultime24Ore_SpName

                Using adapter As New SqlDataAdapter(spToUse, ConfigurationManager.ConnectionStrings("AuslAsmnRe_OrderEntryConnectionString").ConnectionString)

                    adapter.SelectCommand.CommandType = CommandType.StoredProcedure 'Non ha parametri

                    adapter.Fill(resultTable)

                End Using

            ElseIf oDateDiff.TotalDays < 8 Then
                'ULTIMI 7 GIORNI
                spToUse = GetSinottico_UltimiNGiorni_SpName

                Using adapter As New SqlDataAdapter(spToUse, ConfigurationManager.ConnectionStrings("AuslAsmnRe_OrderEntryConnectionString").ConnectionString)

                    adapter.SelectCommand.CommandType = CommandType.StoredProcedure
                    adapter.SelectCommand.Parameters.Add("@DataDa", SqlDbType.Date).Value = dataDa.AddDays(1) 'se parto da dataDa i giorni sarebbero uno in più
                    adapter.SelectCommand.Parameters.Add("@DataA", SqlDbType.Date).Value = dNow
                    adapter.Fill(resultTable)

                End Using

            ElseIf oDateDiff.TotalDays < 31 Then
                'ULTIMI 30 GIORNI
                spToUse = GetSinottico_UltimiNGiorni_SpName

                Using adapter As New SqlDataAdapter(spToUse, ConfigurationManager.ConnectionStrings("AuslAsmnRe_OrderEntryConnectionString").ConnectionString)

                    adapter.SelectCommand.CommandType = CommandType.StoredProcedure
                    adapter.SelectCommand.Parameters.Add("@DataDa", SqlDbType.Date).Value = dataDa.AddDays(1) 'se parto da dataDa i giorni sarebbero uno in più
                    adapter.SelectCommand.Parameters.Add("@DataA", SqlDbType.Date).Value = dNow
                    adapter.Fill(resultTable)

                End Using

            Else
                Throw New NotImplementedException(String.Format("Intervallo di date non gestito: dataDa={0} dNow={1}", dataDa, dNow))
            End If
            '
            ' Restituisco la data table 
            '
            Return resultTable
        End Function




        Public Shared Function GetSinotticoDettaglio2(sistema As String, dataDa As DateTime) As DataTable

            Dim resultTable = New DataTable()
            Dim spToUse As String = String.Empty
            Dim dNow As DateTime = DateTime.Now
            Dim oDateDiff As TimeSpan = dNow - dataDa

            If oDateDiff.TotalHours < 2 Then
                'ULTIMA ORA
                spToUse = GetSinotticoSistemiUltimaOraSpName

                Using adapter As New SqlDataAdapter(spToUse, ConfigurationManager.ConnectionStrings("AuslAsmnRe_OrderEntryConnectionString").ConnectionString)

                    adapter.SelectCommand.CommandType = CommandType.StoredProcedure
                    adapter.SelectCommand.Parameters.Add("@Tipo", SqlDbType.VarChar, 50).Value = sistema
                    adapter.SelectCommand.Parameters.Add("@DataDa", SqlDbType.DateTime2).Value = dataDa
                    adapter.SelectCommand.Parameters.Add("@DataA", SqlDbType.DateTime2).Value = dNow
                    adapter.Fill(resultTable)

                End Using


            ElseIf oDateDiff.TotalHours < 25 Then
                'ULTIME 24 ORE
                spToUse = GetSinottico_Ultime24Ore_Sistemi_SpName

                Using adapter As New SqlDataAdapter(spToUse, ConfigurationManager.ConnectionStrings("AuslAsmnRe_OrderEntryConnectionString").ConnectionString)

                    adapter.SelectCommand.CommandType = CommandType.StoredProcedure 'Solo il parametro @Tipo
                    adapter.SelectCommand.Parameters.Add("@Tipo", SqlDbType.VarChar, 50).Value = sistema
                    adapter.Fill(resultTable)

                End Using

            ElseIf oDateDiff.TotalDays < 8 Then
                'ULTIMI 7 GIORNI
                spToUse = GetSinottico_UltimiNGiorni_Sistemi_SpName

                Using adapter As New SqlDataAdapter(spToUse, ConfigurationManager.ConnectionStrings("AuslAsmnRe_OrderEntryConnectionString").ConnectionString)

                    adapter.SelectCommand.CommandType = CommandType.StoredProcedure
                    adapter.SelectCommand.Parameters.Add("@Tipo", SqlDbType.VarChar, 50).Value = sistema
                    adapter.SelectCommand.Parameters.Add("@DataDa", SqlDbType.Date).Value = dataDa.AddDays(1) 'se parto da dataDa i giorni sarebbero uno in più
                    adapter.SelectCommand.Parameters.Add("@DataA", SqlDbType.Date).Value = dNow
                    adapter.Fill(resultTable)

                End Using

            ElseIf oDateDiff.TotalDays < 31 Then
                'ULTIMI 30 GIORNI
                spToUse = GetSinottico_UltimiNGiorni_Sistemi_SpName

                Using adapter As New SqlDataAdapter(spToUse, ConfigurationManager.ConnectionStrings("AuslAsmnRe_OrderEntryConnectionString").ConnectionString)

                    adapter.SelectCommand.CommandType = CommandType.StoredProcedure
                    adapter.SelectCommand.Parameters.Add("@Tipo", SqlDbType.VarChar, 50).Value = sistema
                    adapter.SelectCommand.Parameters.Add("@DataDa", SqlDbType.Date).Value = dataDa.AddDays(1) 'se parto da dataDa i giorni sarebbero uno in più
                    adapter.SelectCommand.Parameters.Add("@DataA", SqlDbType.Date).Value = dNow
                    adapter.Fill(resultTable)

                End Using

            Else
                Throw New NotImplementedException(String.Format("Intervallo di date non gestito: dataDa={0} dNow={1}", dataDa, dNow))
            End If
            '
            ' Restituisco la data table 
            '
            Return resultTable

        End Function


        Public Shared Function GetEnnuple() As DataTable

            Using adapter As New UiEnnupleListTableAdapter()

                Return adapter.GetData(Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing)
            End Using
        End Function

    End Class

End Namespace

