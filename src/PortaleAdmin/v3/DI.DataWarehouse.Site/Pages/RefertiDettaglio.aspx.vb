Imports System
Imports System.Collections.Generic
Imports System.Data
Imports System.Linq
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin
Imports DI.PortalAdmin.Data

Public Class RefertiDettaglio
    Inherits System.Web.UI.Page

    Private Const KEY_ID_PRESTAZIONE As String = "KEY_ID_PRESTAZIONE"
    Public Property IdPrestazione() As String
        Get
            If ViewState(KEY_ID_PRESTAZIONE) Is Nothing Then
                Return String.Empty
            Else
                Return ViewState(KEY_ID_PRESTAZIONE)
            End If
        End Get
        Set(ByVal value As String)
            ViewState.Add(KEY_ID_PRESTAZIONE, value)
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            '
            'Controllo se IdReferto è un guid valido.
            '
            Dim IdReferto As String = Request.QueryString("IdReferto")
            If String.IsNullOrEmpty(IdReferto) OrElse Not Utility.SQLTypes.IsValidGuid(IdReferto) Then
                LabelError.Visible = True
                LabelError.Text = "il parametro 'Id Referto' non è un guid valido."
            ElseIf Not Page.IsPostBack Then
                '
                '2020-07-07 Kyrylo: Traccia Operazioni
                '
                Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Visualizzato dettaglio referto", idPaziente:=Nothing, Nothing, IdReferto, "IdReferto")
            End If

        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

#Region "Eventi dell'ObjectDataSource"
    Private Sub RefertoAttributiOds_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles RefertoAttributiOds.Selected
        '
        ' Gestione degli errri causati dalla query
        '
        If Not GestioneErrori.ObjectDataSource_TrapError(e, LabelError) Then

            '
            'Il div contenente la tabella degli attributi ha una altezza prefissata ed è scrollabile (per evitare di generare una pagina troppo lunga).
            'Se non ci sono attributi elimino l'altezza in modo da non mostrare comunque uno spazio bianco alto 300px.
            '
            Dim eG = CType(e.ReturnValue, DataTable)
            lblAttributiEmpty.Visible = False
            If eG.Rows.Count <= 0 Then
                lblAttributiEmpty.Visible = True
            End If
        End If
    End Sub

    Private Sub RefertiOds_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles RefertiOds.Selected
        '
        ' Gestione degli errri causati dalla query
        '
        GestioneErrori.ObjectDataSource_TrapError(e, LabelError)
    End Sub

    Private Sub AttributiPrestazioneOds_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles AttributiPrestazioneOds.Selecting
        Try
            If String.IsNullOrEmpty(Me.IdPrestazione) Then
                e.Cancel = True
            End If
            e.InputParameters("IdPrestazione") = Me.IdPrestazione
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub PrestazioniRefertoOds_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles PrestazioniRefertoOds.Selected
        '
        ' Gestione degli errri causati dalla query
        '
        If Not GestioneErrori.ObjectDataSource_TrapError(e, LabelError) Then

            '
            'Il div contenente la tabella degli attributi ha una altezza prefissata ed è scrollabile (per evitare di generare una pagina troppo lunga).
            'Se non ci sono attributi elimino l'altezza in modo da non mostrare comunque uno spazio bianco alto 300px.
            '
            Dim eG = CType(e.ReturnValue, DataTable)
            lblPrestazioniEmpty.Visible = False
            'divPrestazioni.Style.Add("height", "300")
            If eG.Rows.Count <= 0 Then
                lblPrestazioniEmpty.Visible = True
                'divPrestazioni.Style.Remove("height")
            End If
        End If
    End Sub
#End Region

#Region "Funzioni del markup"
    Protected Function FormatCodiceDescrizione(ByVal oDescrizione As Object, ByVal oCodice As Object) As String
        '
        'restituisce una stringa formata dalla descrizione + codice da mostrare nel markup.
        '
        Try
            Dim sResult As String = String.Empty
            Dim descrizione As String = String.Empty
            Dim codice As String = String.Empty

            If Not oDescrizione Is DBNull.Value Then
                descrizione = oDescrizione.ToString
            End If

            If Not oCodice Is DBNull.Value Then
                codice = oCodice.ToString
            End If

            If Not String.IsNullOrEmpty(descrizione) AndAlso Not String.IsNullOrEmpty(codice) Then
                sResult = String.Format("{0} - {1}", descrizione, codice)
            ElseIf Not String.IsNullOrEmpty(descrizione) AndAlso String.IsNullOrEmpty(codice) Then
                sResult = String.Format("{0}", descrizione)
            ElseIf String.IsNullOrEmpty(descrizione) AndAlso Not String.IsNullOrEmpty(codice) Then
                sResult = String.Format("({0})", codice)
            End If

            Return sResult
        Catch ex As Exception
            '
            'Non si dovrebbe mai verificare
            '
            Dim sMessage As String = "Si è verificato un errore durante 'FormatCodiceDescrizione'. "
            Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
            Return String.Empty
        End Try
    End Function

    Private Sub gvPrestazioniReferto_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvPrestazioniReferto.RowCommand
        Try
            If e.CommandName = "ApriAttributi" Then
                '
                'Ottengo l'Id della prestazione
                '
                Me.IdPrestazione = e.CommandArgument.ToString

                '
                'Eseguo il bind della griglia
                '
                gvAttributiPrestazione.DataBind()

                '
                'Aggiungo alla pagina lo script per aprire la modale contenente gli attributi.
                '
                Dim title As String = String.Format("Attributi Prestazione: {0}", Me.IdPrestazione)
                Dim functionJS As String = "openModal('attributiModal','" + title + "',500,500,false)"
                ScriptManager.RegisterStartupScript(Page, Page.GetType, "OpenModal", functionJS, True)
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub AttributiPrestazioneOds_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles AttributiPrestazioneOds.Selected
        '
        ' Gestione degli errri causati dalla query
        '
        GestioneErrori.ObjectDataSource_TrapError(e, LabelError)
    End Sub

    Private Sub gvAllgati_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvAllegati.RowCommand
        Dim oAttributi As Object = e.CommandArgument
        gvAllegatiAttributi.DataSource = ShowAttributi(oAttributi)
        gvAllegatiAttributi.DataBind()


        '
        'Aggiungo alla pagina lo script per aprire la modale contenente gli attributi.
        '
        Dim title As String = String.Format("Attributi Allegato")
        Dim functionJS As String = "openModal('attributiAllegatoModal','" + title + "',500,500,false)"
        ScriptManager.RegisterStartupScript(Page, Page.GetType, "OpenModal", functionJS, True)
    End Sub

    Public Shared Function ShowAttributi(oAttributi As Object) As System.Collections.Specialized.OrderedDictionary
        Dim oRet As System.Collections.Specialized.OrderedDictionary = New System.Collections.Specialized.OrderedDictionary
        If Not oAttributi Is DBNull.Value Then
            Dim sAttributi As String = DirectCast(oAttributi, String)
            Dim oXml As System.Xml.Linq.XDocument = System.Xml.Linq.XDocument.Parse(sAttributi)
            Dim query As System.Collections.Generic.IEnumerable(Of System.Xml.Linq.XElement) = From p In oXml.Root.Elements("Attributo")
            If query.Count > 0 Then
                Dim oSb As New Text.StringBuilder
                For Each oAttributo As System.Xml.Linq.XElement In query
                    Dim sValoreAttributo As String = String.Empty
                    Dim sNomeAttributo As String = oAttributo.@Nome
                    If Not String.IsNullOrEmpty(sNomeAttributo) Then
                        sValoreAttributo = oAttributo.@Valore
                        oRet.Add(sNomeAttributo, sValoreAttributo)
                    End If
                Next
            End If
        End If
        '
        ' Restituisco
        '
        Return oRet
    End Function

    Protected Function GetUrlReferto() As String
        Dim sResult As String = String.Empty
        Try
            'Compongo l'url per visualizzare il dettaglio del referto sull'accesso diretto.
            sResult = String.Format(My.Settings.RefertoUrl, Request.QueryString("IdReferto"))
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
        '
        'restituisco
        '
        Return sResult
    End Function

    Protected Sub NavigaLogSOLE()
        Try
            'navigo alla pagina di LOG degli inivii di SOLE.
            Response.Redirect(String.Format("~/Pages/SOLELogInvii.aspx?idreferto={0}", Request.QueryString("IdReferto")))
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

#End Region



End Class