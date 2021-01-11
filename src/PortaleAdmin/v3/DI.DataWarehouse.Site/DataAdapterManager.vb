Imports System
Imports System.ComponentModel
Imports System.Data
Imports System.Data.SqlClient
Imports System.Configuration
Imports System.Reflection
'Imports DI.DataWarehouse.Admin.Data.DocumentiDataSetTableAdapters
'Imports DI.DataWarehouse.Admin.Data.DocumentiDataSet
Imports DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters
Imports DI.DataWarehouse.Admin.Data.BackEndDataSet
Imports DI.DataWarehouse.Admin.Data.RefertiStiliDataSetTableAdapters
Imports DI.DataWarehouse.Admin.Data.Sole
Imports DI.DataWarehouse.Admin.Data.SoleTableAdapters
Imports DI.PortalAdmin.Data

Namespace DI.DataWarehouse.Admin.Data

    <DataObjectAttribute(True)> _
    Public NotInheritable Class DataAdapterManager

        Public Shared ReadOnly PortalAdminDataAdapterManager As PortalDataAdapterManager

        Private Sub New()

        End Sub

        Shared Sub New()

            PortalAdminDataAdapterManager = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
        End Sub

		Public Shared Function GetDataSistemiErogantiDocumento(ByVal idDocumento As Guid) As GetDocumentoSistemiErogantiDataTable

			Using adapter As New GetDocumentoSistemiErogantiTableAdapter()
				Return adapter.GetData(idDocumento)
			End Using

		End Function

        <DataObjectMethod(DataObjectMethodType.Select)> _
        Public Shared Function GetDataRefertiStiliLista(ByVal nome As String, ByVal descrizione As String) As RefertiStiliListaDataTable

            Using adapter As New RefertiStiliListaTableAdapter()

                Return adapter.GetData(nome, descrizione)
            End Using
        End Function

        Public Shared Function RefertiStiliFill(ByVal stiliDataSet As RefertiStiliDataSet, ByVal id As Guid) As Integer

            Using adapter As New RefertiStiliTableAdapter()
                Return adapter.Fill(stiliDataSet.RefertiStili, id)
            End Using
        End Function

        Public Shared Function RefertiStiliUpdate(ByVal stiliDataSet As RefertiStiliDataSet) As Integer

            Using adapter As New RefertiStiliTableAdapter()
                Return adapter.Update(stiliDataSet.RefertiStili)
            End Using

        End Function

		''' <summary>
		''' Esegue la ricerca solo se ho impostato il nosologico o il numeroreferto o datadal o dataal
		''' </summary>
		''' <param name="numeroReferto"></param>
		''' <param name="numeroNosologico"></param>
		''' <param name="dataDal"></param>
		''' <param name="dataAl"></param>
		''' <param name="visualizzaNoteCancellate"></param>
		''' <returns></returns>
		''' <remarks></remarks>
		<DataObjectMethod(DataObjectMethodType.Select)> _
        Public Shared Function GetDataRefertiNoteLista(ByVal numeroReferto As String, ByVal numeroNosologico As String, ByVal dataDal As DateTime?, ByVal dataAl As DateTime?, ByVal visualizzaNoteCancellate As Boolean?) As BackEndDataSet.RefertiNoteListaDataTable

            If Not String.IsNullOrEmpty(numeroReferto) OrElse Not String.IsNullOrEmpty(numeroNosologico) OrElse dataDal.HasValue OrElse dataAl.HasValue Then

                Using adapter As New RefertiNoteListaTableAdapter()
                    Return adapter.GetData(numeroReferto, numeroNosologico, dataDal, dataAl, visualizzaNoteCancellate)
                End Using
            Else
                Return Nothing
            End If
        End Function

        <DataObjectMethod(DataObjectMethodType.Select)> _
        Public Shared Function GetRefertiNoteDettaglio(ByVal id As Guid) As RefertiNoteDettaglioDataTable

            Using adapter As New RefertiNoteDettaglioTableAdapter()
                Return adapter.GetData(id)
            End Using
        End Function

        <DataObjectMethod(DataObjectMethodType.Delete)> _
        Public Shared Function RimuoviNoteReferti(ByVal id As Guid) As Integer

            Using adapter As New RefertiNoteDettaglioTableAdapter()
                Return adapter.Delete(id)
            End Using
        End Function

        <DataObjectMethod(DataObjectMethodType.Select)> _
        Public Shared Function SistemiErogantiDocumentiLista(ByVal aziendaErogante As String) As SistemiErogantiDocumentiListaDataTable

            Using adapter As New SistemiErogantiDocumentiListaTableAdapter()
                Return adapter.GetData(aziendaErogante)
            End Using
        End Function

        Public Shared Function SistemiErogantiDocumentiDettaglio(ByVal id As Guid, ByVal dataSet As BackEndDataSet) As Integer

            Using adapter As New SistemiErogantiDocumentiDettaglioTableAdapter()
                Return adapter.Fill(dataSet.SistemiErogantiDocumentiDettaglio, id)
            End Using
        End Function

        Public Shared Function SistemiErogantiDocumentiAggiorna(ByVal dataset As BackEndDataSet) As Integer

            Using adapter As New SistemiErogantiDocumentiDettaglioTableAdapter()
                Return adapter.Update(dataset.SistemiErogantiDocumentiDettaglio)
            End Using
        End Function

        Public Shared Function SistemiErogantiDocumentiRimuovi(ByVal id As Guid) As Integer

            Using adapter As New SistemiErogantiDocumentiDettaglioTableAdapter()
                Return adapter.Delete(id)
            End Using
        End Function

        <DataObjectMethod(DataObjectMethodType.Select)> _
        Public Shared Function SistemiErogantiCombo(ByVal aziendaErogante As String) As SistemiErogantiComboDataTable

            Using adapter As New SistemiErogantiComboTableAdapter()
                Return adapter.GetData(aziendaErogante)
            End Using
        End Function

        <DataObjectMethod(DataObjectMethodType.Select)> _
        Public Shared Function GetTipiRefertiLista(addEmpty As Boolean) As DataView

            Dim result As StampeSottoscrizioniTipoRefertiListaDataTable
            Using adapter As New StampeSottoscrizioniTipoRefertiListaTableAdapter()

                result = adapter.GetData()
            End Using

            If addEmpty Then

                result.AddStampeSottoscrizioniTipoRefertiListaRow(-1, "")

                result.DefaultView.Sort = "Descrizione"
            End If

            Return result.DefaultView
        End Function

        <DataObjectMethod(DataObjectMethodType.Select)> _
        Public Shared Function GetTipiSottoscrizioniLista(addEmpty As Boolean) As DataView

            Dim result As StampeSottoscrizioniTipoSottoscrizioniListaDataTable
            Using adapter As New StampeSottoscrizioniTipoSottoscrizioniListaTableAdapter()

                result = adapter.GetData()
            End Using

            If addEmpty Then

                result.AddStampeSottoscrizioniTipoSottoscrizioniListaRow(-1, "")

                result.DefaultView.Sort = "Descrizione"
            End If

            Return result.DefaultView
        End Function

        <DataObjectMethod(DataObjectMethodType.Select)> _
        Public Shared Function GetStatiSottoscrizioniLista(addEmpty As Boolean) As DataView

            Dim result As StampeSottoscrizioniStatiListaDataTable
            Using adapter As New StampeSottoscrizioniStatiListaTableAdapter()

                result = adapter.GetData()
            End Using

            If addEmpty Then

                result.AddStampeSottoscrizioniStatiListaRow(-1, "")

                result.DefaultView.Sort = "Descrizione"
            End If

            Return result.DefaultView
        End Function

        Public Shared Function ChangeActivationState(id As Guid?) As Integer

            Using adapter As New StampeSottoscrizioniDettaglioTableAdapter()

                Dim row = adapter.GetData(id)(0)

                row.IdStato = If(row.IdStato = 3, 1, 3)

                Return adapter.Update(row)
            End Using
        End Function

        Public Shared Function DeleteSottoscrizione(id As Guid?) As Integer

            Using adapter As New StampeSottoscrizioniDettaglioTableAdapter()

                Dim row = adapter.GetData(id)(0)

                Return adapter.Delete(id, row.Ts)
            End Using
        End Function

        Public Shared Function GetLookupTipiReferti() As StampeSottoscrizioniTipoRefertiListaDataTable

            Using adapter As New StampeSottoscrizioniTipoRefertiListaTableAdapter()

                Return adapter.GetData()
            End Using
        End Function

         Public Shared Function GetLookupTipiAbbonamenti() As StampeSottoscrizioniTipoSottoscrizioniListaDataTable

            Using adapter As New StampeSottoscrizioniTipoSottoscrizioniListaTableAdapter()

                Return adapter.GetData()
            End Using
        End Function

		Public Shared Function GetLookupSistemi(codiceAzienda As String) As StampeSottoscrizioniSistemiErogantiListaDataTable

			Using adapter As New StampeSottoscrizioniSistemiErogantiListaTableAdapter()

				Return adapter.GetData(codiceAzienda)
			End Using
		End Function

		Public Shared Function GetStampeSottoscrizioniDettaglio(id As Guid) As StampeSottoscrizioniDettaglioDataTable

            Using adapter As New StampeSottoscrizioniDettaglioTableAdapter()

                Return adapter.GetData(id)
            End Using
        End Function

        Public Shared Function GetRepartiRichiedentiStampeSottoscrizioni(id As Guid) As StampeSottoscrizioniRepartiRichiedentiListaDataTable

            Using adapter As New StampeSottoscrizioniRepartiRichiedentiListaTableAdapter()

                Return adapter.GetData(id)
            End Using
        End Function

        Public Shared Function RemoveSistemaFromSottoscrizione(idSottoscrizione As Guid, idSistema As Guid) As Integer

			Using adapter As New BackEndDataSetTableAdapters.QueriesTableAdapter()

				Return adapter.StampeSottoscrizioniRepartiRichiedentiRimuovi(idSottoscrizione, idSistema)
			End Using
        End Function

        Public Shared Function AddSistemaToSottoscrizione(idSottoscrizione As Guid, idSistema As Guid) As Integer

			Using adapter As New BackEndDataSetTableAdapters.QueriesTableAdapter()

				Return adapter.StampeSottoscrizioniRepartiRichiedentiAggiungi(idSottoscrizione, idSistema)
			End Using
        End Function

        Public Shared Function SearchReparti(codiceAzienda As String, codiceSistema As String, descrizione As String) As StampeSottoscrizioniRepartiRichiedentiSelezionabiliDataTable

            Using adapter As New StampeSottoscrizioniRepartiRichiedentiSelezionabiliTableAdapter()

                Return adapter.GetData(codiceAzienda, codiceSistema, descrizione)
            End Using
        End Function

        Public Shared Function Update(table As StampeSottoscrizioniDettaglioDataTable) As Integer

            Using adapter As New StampeSottoscrizioniDettaglioTableAdapter()
                Return adapter.Update(table)
            End Using
        End Function

        Public Shared Function GetLookupAziendeEroganti() As AziendeErogantiListaDataTable

            Using adapter As New AziendeErogantiListaTableAdapter()

                Return adapter.GetData()
            End Using
        End Function

        Public Shared Function GetLookupSistemiEroganti(codiceAzienda As String) As SistemiErogantiListaDataTable

            Using adapter As New SistemiErogantiListaTableAdapter()

                Return adapter.GetData(codiceAzienda, "referti")
            End Using
        End Function


    End Class

	''' <summary>
	''' Estensioni
	''' </summary>
	Module Extensions

		''' <summary>
		''' Imposta un timeout a tutti i Select Command contenuti nel TableAdapter
		''' </summary>
		<System.Runtime.CompilerServices.Extension()> _
		Public Sub CommandTimeout(Of T As Global.System.ComponentModel.Component)(TableAdapter As T, CommandTimeout As Integer)
			For Each c In TryCast(GetType(T).GetProperty("CommandCollection", BindingFlags.NonPublic Or BindingFlags.GetProperty Or BindingFlags.Instance).GetValue(TableAdapter, Nothing), SqlCommand())
				c.CommandTimeout = CommandTimeout
			Next
		End Sub

	End Module


End Namespace