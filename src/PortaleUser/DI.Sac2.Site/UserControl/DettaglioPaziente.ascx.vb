Public Class DettaglioPaziente
    Inherits System.Web.UI.UserControl

    Public Property IdPaziente As Guid
        Get
            Return ViewState("IdPaziente")
        End Get
        Set(value As Guid)
            ViewState("IdPaziente") = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub

    Private Sub odsPaziente_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsPaziente.Selecting
        If IdPaziente = Guid.Empty Then
            e.Cancel = True
        End If

        '
        ' Questi parametri vengono passati dalla pagina in cui lo UserControl viene implementata
        '
        e.InputParameters("Token") = Nothing
        e.InputParameters("Id") = IdPaziente
    End Sub

    Private Sub odsPaziente_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsPaziente.Selected
        Try
            'testo se si è verificato un errore.
            If e.Exception IsNot Nothing Then
                e.ExceptionHandled = True
                'ottengo il messaggio di errore.
                Throw e.Exception
            End If
        Catch ex As Exception
            lblErrore.Text = CustomDataSourceException.TrapError(ex)
            divErrore.Visible = True
        End Try
    End Sub



#Region "ProtectedFunctions"
    Protected Function GetCognomePaziente(row As Object) As String
        Dim cognome As String = String.Empty

        If row IsNot Nothing Then
            Dim rowPaziente As WcfSacPazienti.PazienteType = CType(row, WcfSacPazienti.PazienteType)

            If rowPaziente IsNot Nothing Then
                If rowPaziente.Generalita IsNot Nothing Then
                    cognome = rowPaziente.Generalita.Cognome
                End If
            End If
        End If

        Return cognome
    End Function

    Protected Function GetNomePaziente(row As Object) As String
        Dim nome As String = String.Empty

        If row IsNot Nothing Then
            Dim rowPaziente As WcfSacPazienti.PazienteType = CType(row, WcfSacPazienti.PazienteType)

            If rowPaziente IsNot Nothing Then
                If rowPaziente.Generalita IsNot Nothing Then
                    nome = rowPaziente.Generalita.Nome
                End If
            End If
        End If

        Return nome
    End Function

    Protected Function GetCodiceFiscalePaziente(row As Object) As String
        Dim codiceFiscale As String = String.Empty

        If row IsNot Nothing Then
            Dim rowPaziente As WcfSacPazienti.PazienteType = CType(row, WcfSacPazienti.PazienteType)

            If rowPaziente IsNot Nothing Then
                If rowPaziente.Generalita IsNot Nothing Then
                    codiceFiscale = rowPaziente.Generalita.CodiceFiscale
                End If
            End If
        End If

        Return codiceFiscale
    End Function

    Protected Function GetSessoPaziente(row As Object) As String
        Dim sesso As String = String.Empty

        If row IsNot Nothing Then
            Dim rowPaziente As WcfSacPazienti.PazienteType = CType(row, WcfSacPazienti.PazienteType)

            If rowPaziente IsNot Nothing Then
                If rowPaziente.Generalita IsNot Nothing Then
                    sesso = rowPaziente.Generalita.Sesso
                End If
            End If
        End If

        Return sesso
    End Function

    Protected Function GetDataNascitaPaziente(row As Object) As String
        Dim dataNascita As String = String.Empty

        If row IsNot Nothing Then
            Dim rowPaziente As WcfSacPazienti.PazienteType = CType(row, WcfSacPazienti.PazienteType)

            If rowPaziente IsNot Nothing Then
                If rowPaziente.Generalita IsNot Nothing Then
                    dataNascita = String.Format("{0:d}", rowPaziente.Generalita.DataNascita)
                End If
            End If
        End If

        Return dataNascita
    End Function


    Protected Function GeComuneNascitaPaziente(row As Object) As String
        Dim comuneNascita As String = String.Empty

        If row IsNot Nothing Then
            Dim rowPaziente As WcfSacPazienti.PazienteType = CType(row, WcfSacPazienti.PazienteType)

            If rowPaziente IsNot Nothing Then
                If rowPaziente.Generalita IsNot Nothing Then
                    comuneNascita = rowPaziente.Generalita.ComuneNascitaNome
                End If
            End If
        End If

        Return comuneNascita
    End Function



#End Region
End Class