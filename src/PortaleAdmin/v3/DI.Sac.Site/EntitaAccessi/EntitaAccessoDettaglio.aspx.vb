
Imports System.Web.UI.WebControls
Imports System
Imports System.Diagnostics
Imports System.Collections
Imports DI.Sac.Admin.Data.PermessiDataSetTableAdapters
Imports DI.Sac.Admin.Data.PermessiDataSet
Imports System.Reflection
Imports System.Web.UI

Namespace DI.Sac.Admin

    Partial Public Class EntitaAccessoDettaglio
        Inherits Page

        Private Shared ReadOnly _className As String = String.Concat("Gestione.", MethodBase.GetCurrentMethod().ReflectedType.Name)

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
            Dim Id As Guid = Nothing
            Try
                Id = New Guid(Request.Params("id"))
                If Not Page.IsPostBack Then
                    'Prelevo i dati di dettaglio dell'utente o gruppo per il quale la pagina deve impostare gli accessi/autorizzazioni e li visualizzo 
                    Using oEntitaAccessiDettaglioAdapter = New EntitaAccessiDettaglioTableAdapter
                        Dim oEntitaAccessidettaglioDataTable As EntitaAccessiDettaglioDataTable = oEntitaAccessiDettaglioAdapter.GetData(Id)
                        If Not oEntitaAccessidettaglioDataTable Is Nothing AndAlso oEntitaAccessidettaglioDataTable.Rows.Count > 0 Then
                            Dim oRow As EntitaAccessiDettaglioRow = oEntitaAccessidettaglioDataTable(0)
                            lblDettaglioUtente.Text = String.Format("Accessi {0}  ""{1}\{2}""", oRow.DescrizioneTipo.ToLower, oRow.Dominio, oRow.Nome)
                        End If
                    End Using

                    ' Salvo in sessione il DataSource                             
                    Using adapter = New EntitaAccessiServiziTableAdapter()
                        Me.DataSource = adapter.GetData(Id)
                    End Using

                    gvEntitaAccessiServizi.DataSource = DataSource
                    gvEntitaAccessiServizi.DataBind()
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

        Protected Sub btnConferma_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnConferma.Click
            Try
                Dim entitaAccessiServiziRow As EntitaAccessiServiziRow
                Dim nome As String = String.Empty
                Dim dominio As String = String.Empty
                Dim tipo As Byte
                '
                ' Verifico se la property DataSource è nothing (legge/scrive in Session)
                '
                If DataSource Is Nothing Then
                    LabelError.Visible = True
                    LabelError.Text = "La sessione è scaduta. Ricaricare la pagina."
                    Exit Sub
                End If
                '
                ' Memorizzo la Datasource
                '
                Dim oDataSource As EntitaAccessiServiziDataTable = DirectCast(DataSource, EntitaAccessiServiziDataTable)
                '
                ' Ciclo le righe della GridView
                '
                For Each row As GridViewRow In gvEntitaAccessiServizi.Rows
                    '
                    ' Id di riga, più dati di riga
                    '
                    Dim id As Integer = DirectCast(row.Cells(0).Controls(1), Label).Text
                    Dim boolCreazione As Boolean = DirectCast(row.Cells(2).Controls(1), CheckBox).Checked
                    Dim boolLettura As Boolean = DirectCast(row.Cells(3).Controls(1), CheckBox).Checked
                    Dim boolScrittura As Boolean = DirectCast(row.Cells(4).Controls(1), CheckBox).Checked
                    Dim boolEliminazione As Boolean = DirectCast(row.Cells(5).Controls(1), CheckBox).Checked
                    'Permessi per Anonimizzazione
                    Dim boolCreazioneAnonimizzazione As Boolean = DirectCast(row.Cells(6).Controls(1), CheckBox).Checked
                    Dim boolLetturaAnonimizzazione As Boolean = DirectCast(row.Cells(7).Controls(1), CheckBox).Checked
                    'MODIFICA ETTORE 2018-02-22: Permessi per Posizioni Collegate - ATTENZIONE all'indice delle celle...
                    Dim boolCreazionePosCollegata As Boolean = DirectCast(row.Cells(8).Controls(1), CheckBox).Checked
                    Dim boolLetturaPosCollegata As Boolean = DirectCast(row.Cells(9).Controls(1), CheckBox).Checked
                    'Controllo completo
                    Dim boolControlloCompleto As Boolean = DirectCast(row.Cells(10).Controls(1), CheckBox).Checked

                    entitaAccessiServiziRow = oDataSource.FindById(id)
                    nome = entitaAccessiServiziRow.Nome
                    dominio = entitaAccessiServiziRow.Dominio
                    tipo = entitaAccessiServiziRow.Tipo
 
                    entitaAccessiServiziRow.Creazione = boolCreazione
                    entitaAccessiServiziRow.Lettura = boolLettura
                    entitaAccessiServiziRow.Scrittura = boolScrittura
                    entitaAccessiServiziRow.Eliminazione = boolEliminazione
                    entitaAccessiServiziRow.CreazioneAnonimizzazione = boolCreazioneAnonimizzazione
                    entitaAccessiServiziRow.LetturaAnonimizzazione = boolLetturaAnonimizzazione
                    'MODIFICA ETTORE 2018-02-22: Permessi per Posizioni Collegate
                    entitaAccessiServiziRow.CreazionePosizioneCollegata = boolCreazionePosCollegata
                    entitaAccessiServiziRow.LetturaPosizioneCollegata = boolLetturaPosCollegata
                    entitaAccessiServiziRow.ControlloCompleto = boolControlloCompleto


                Next

                Using adapter As New EntitaAccessiServiziTableAdapter()
                    adapter.Update(oDataSource)
                End Using

                RolesHelper.ResetRolesCache(nome, dominio, tipo)

                Response.Redirect("EntitaAccessiLista.aspx", False)
            Catch ex As Exception
                'ExceptionsManager.TraceException(ex)
                'LabelError.Visible = True
                'LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Aggiornamento)
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

        Protected Sub btnAnnulla_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnAnnulla.Click
            Response.Redirect("EntitaAccessiLista.aspx", False)
        End Sub

        Private Property DataSource() As EntitaAccessiServiziDataTable
            Get
                Dim o As Object = Session("gvEntitaAccessiServizi")
                If o Is Nothing Then Return Nothing Else Return DirectCast(o, EntitaAccessiServiziDataTable)
            End Get
            Set(ByVal Value As EntitaAccessiServiziDataTable)
                Session("gvEntitaAccessiServizi") = Value
            End Set
        End Property

        Protected Function AbilitaCheckAnonimizzazione(IdServizio As Object) As Boolean
            Dim bRet As Boolean = True
            If Not IdServizio Is DBNull.Value Then
                If CInt(IdServizio) <> TypeServices.Pazienti Then
                    bRet = False
                End If
            End If
            Return bRet
        End Function

        Protected Function AbilitaCheckPosCollegata(IdServizio As Object) As Boolean
            Dim bRet As Boolean = True
            If Not IdServizio Is DBNull.Value Then
                If CInt(IdServizio) <> TypeServices.Pazienti Then
                    bRet = False
                End If
            End If
            Return bRet
        End Function


    End Class

End Namespace