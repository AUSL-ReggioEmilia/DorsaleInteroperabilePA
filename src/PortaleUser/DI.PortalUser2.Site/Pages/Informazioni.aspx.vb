Public Class Informazioni
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Not Page.IsPostBack Then

            Dim dtInformazioni As InfoDispositivoMedicoDataSet.InfoDispositivoMedicoListaDataTable
            Using ta As New InfoDispositivoMedicoDataSetTableAdapters.InfoDispositivoMedicoListaTableAdapter
                dtInformazioni = ta.GetData()

            End Using

            Dim righeDispositivo = (From x As InfoDispositivoMedicoDataSet.InfoDispositivoMedicoListaRow In dtInformazioni.Rows Where x.Sessione.ToUpper() = "DISPOSITIVO" Select x).ToList()
            GvDispositivo.DataSource = righeDispositivo
            GvDispositivo.DataBind()

        End If

    End Sub


    'Private Sub dlListaChiavi_ItemDataBound(sender As Object, e As DataListItemEventArgs) Handles dlListaChiavi.ItemDataBound
    '    Try
    '        If e.Item IsNot Nothing AndAlso e.Item.DataItem IsNot Nothing Then
    '            'ottengo il nome del gruppo
    '            Dim nomeChiave As String = e.Item.DataItem.ToString

    '            'Ottengo la datalist innestata
    '            Dim dtl As GridView = CType(e.Item.FindControl("dtConfigurazioni"), GridView)
    '            'Ottengo l'ods della datalist innestata
    '            Dim ods As ObjectDataSource = CType(e.Item.FindControl("odsInfoDispositivoMedico"), ObjectDataSource)
    '            'Valorizzo l'input parameter dell'ods e carico i dati
    '            ods.SelectParameters("Chiave").DefaultValue = nomeChiave
    '            dtl.DataBind()
    '        End If
    '    Catch ex As Exception

    '    End Try
    'End Sub

    ''' <summary>
    ''' Ottiene il distinct dei nomi delle chiavi.
    ''' </summary>
    ''' <returns></returns>
    'Public Function GetChiavi() As List(Of String)
    '    Dim listaChiavi As New List(Of String)

    '    Try
    '        Using ta As New InfoDispositivoMedicoDataSetTableAdapters.InfoDispositivoMedicoListaTableAdapter
    '            Dim dtInformazioni As InfoDispositivoMedicoDataSet.InfoDispositivoMedicoListaDataTable = ta.GetData()

    '            If dtInformazioni IsNot Nothing AndAlso dtInformazioni.Count > 0 Then
    '                listaChiavi = (From info As InfoDispositivoMedicoDataSet.InfoDispositivoMedicoListaRow In dtInformazioni.Rows Select info.Sessione).ToList()
    '                listaChiavi = listaChiavi.Distinct().ToList()
    '            End If
    '        End Using

    '    Catch ex As Exception
    '        GestioneErrori(ex)
    '    End Try

    '    Return listaChiavi
    'End Function

    ''' <summary>
    ''' Ottiene il distinct dei nomi delle chiavi.
    ''' </summary>
    ''' <returns></returns>
    'Public Function GetDataByChiave(Chiave As String) As List(Of InfoDispositivoMedicoDataSet.InfoDispositivoMedicoListaRow)
    '    Dim listaConfigurazioni As New List(Of InfoDispositivoMedicoDataSet.InfoDispositivoMedicoListaRow)

    '    Try
    '        Using ta As New InfoDispositivoMedicoDataSetTableAdapters.InfoDispositivoMedicoListaTableAdapter
    '            Dim dtInformazioni As InfoDispositivoMedicoDataSet.InfoDispositivoMedicoListaDataTable = ta.GetData()

    '            If dtInformazioni IsNot Nothing AndAlso dtInformazioni.Count > 0 Then
    '                listaConfigurazioni = (From info As InfoDispositivoMedicoDataSet.InfoDispositivoMedicoListaRow In dtInformazioni.Rows Where info.Sessione.ToUpper() = Chiave.ToUpper() Select info).ToList()
    '            End If
    '        End Using

    '    Catch ex As Exception
    '        'GestioneErrori(ex)
    '    End Try

    '    Return listaConfigurazioni
    'End Function

End Class