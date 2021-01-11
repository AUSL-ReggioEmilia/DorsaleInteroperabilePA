

Namespace DI.Sac.User

    Partial Public Class ConsensoDettaglio
        Inherits System.Web.UI.Page

        Private Shared ReadOnly _ClassName As String = System.Reflection.MethodBase.GetCurrentMethod().ReflectedType.Name

        Private mbConsensoDettaglioObjectDataSource_CancelSelect As Boolean = False
        Private ReadOnly mbCanReadConsensi As Boolean = True

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
            Try
                '
                ' Verifico se ha i diritti per leggere i consensi (dal portale user si può solo leggere, mai modificare)
                '
                If Not mbCanReadConsensi Then
                    Throw New ApplicationException("L'utente non ha i diritti per accedere alla pagina.")
                End If

                Dim qsIdPaziente As String = Request.Params("idPaziente")

                If Not Page.IsPostBack Then

                    lnkIndietro.NavigateUrl = String.Format(lnkIndietro.NavigateUrl, qsIdPaziente)

                End If

            Catch ex As Exception
                'Si è verificato un errore.
                Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
            End Try
        End Sub

        'Private Sub ConsensoDettaglioObjectDataSource_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles ConsensoDettaglioObjectDataSource.Selecting
        '    Try
        '        e.Cancel = mbConsensoDettaglioObjectDataSource_CancelSelect
        '    Catch ex As Exception
        '        'Si è verificato un errore.
        '        Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
        '    End Try
        'End Sub

        'Protected Sub ConsensoDettaglioObjectDataSource_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles ConsensoDettaglioObjectDataSource.Selected
        '    Try
        '        'If Not e.Exception Is Nothing Then

        '        '    GestioneErrori.WriteException(e.Exception)

        '        '    divErrorMessage.Visible = True
        '        '    LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
        '        '    e.ExceptionHandled = True
        '        'End If
        '    Catch ex As Exception
        '        'Si è verificato un errore.
        '        Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
        '    End Try
        'End Sub

        'Protected Sub ConsensoDettaglioObjectDataSource_Deleted(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles ConsensoDettaglioObjectDataSource.Deleted
        '    Try
        '        'If Not e.Exception Is Nothing Then

        '        '    GestioneErrori.WriteException(e.Exception)
        '        '    divErrorMessage.Visible = True
        '        '    LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Eliminazione)
        '        '    e.ExceptionHandled = True
        '        'End If
        '    Catch ex As Exception
        '        'Si è verificato un errore.
        '        Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
        '    End Try
        'End Sub

        Private Sub HyperLinkStyle(ByRef sender As HyperLink, ByVal enabled As Boolean)
            If enabled Then
                sender.Enabled = True
                sender.Text = sender.Text.Replace("_grey.gif", ".gif")
            Else
                sender.Enabled = False
                sender.Text = sender.Text.Replace(".gif", "_grey.gif")
            End If
        End Sub

        Private Sub HyperLinkStyle(ByRef sender As LinkButton, ByVal enabled As Boolean)
            If enabled Then
                sender.Enabled = True
                sender.Text = sender.Text.Replace("_grey.gif", ".gif")
            Else
                sender.Enabled = False
                sender.Text = sender.Text.Replace(".gif", "_grey.gif")
                sender.OnClientClick = String.Empty
            End If
        End Sub

        ''' <summary>
        ''' Da usare in caso di errore per nascondere le componenti della pagina
        ''' </summary>
        ''' <param name="bVisible"></param>
        ''' <remarks></remarks>
        Private Sub SetDetailVisible(bVisible As Boolean)
            ToolbarTable.Visible = bVisible
            'MainFormView.Visible = bVisible
        End Sub

        ''' <summary>
        ''' Funzione usata nella parte ASPX per visualizzare gli attributi
        ''' </summary>
        ''' <param name="attributi"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Protected Function ShowAttributi(attributi As Object) As String
            Dim sReturn As String = String.Empty

            If attributi IsNot Nothing Then
                Dim attributiType As WcfSacPazienti.AttributiType = CType(attributi, WcfSacPazienti.AttributiType)

                sReturn = Utility.ShowAttributiWcf(attributiType)
            End If

            Return sReturn
        End Function

#Region "ProtectedFunctions"
        Protected Function GetOperatoreCognome(ByVal row As Object) As String
            Dim cognomeOperatore As String = String.Empty


            If row IsNot Nothing Then
                Dim consensoRow As WcfSacPazienti.ConsensoType = CType(row, WcfSacPazienti.ConsensoType)

                If consensoRow IsNot Nothing Then
                    If consensoRow.Operatore IsNot Nothing Then
                        cognomeOperatore = consensoRow.Operatore.Cognome
                    End If
                End If
            End If

            Return cognomeOperatore
        End Function

        Protected Function GetOperatoreNome(ByVal row As Object) As String
            Dim nomeOperatore As String = String.Empty


            If row IsNot Nothing Then
                Dim consensoRow As WcfSacPazienti.ConsensoType = CType(row, WcfSacPazienti.ConsensoType)

                If consensoRow IsNot Nothing Then
                    If consensoRow.Operatore IsNot Nothing Then
                        nomeOperatore = consensoRow.Operatore.Nome
                    End If
                End If
            End If

            Return nomeOperatore
        End Function

        Protected Function GetOperatoreComputer(ByVal row As Object) As String
            Dim computerOperatore As String = String.Empty

            If row IsNot Nothing Then
                Dim consensoRow As WcfSacPazienti.ConsensoType = CType(row, WcfSacPazienti.ConsensoType)

                If consensoRow IsNot Nothing Then
                    If consensoRow.Operatore IsNot Nothing Then
                        computerOperatore = consensoRow.Operatore.Computer
                    End If
                End If
            End If

            Return computerOperatore
        End Function

#End Region
    End Class

End Namespace