Namespace DI.Sac.User

    Partial Public Class EsenzioneDettaglio
        Inherits System.Web.UI.Page

        ''' <summary>
        ''' Property contente l'id del paziente.
        ''' Salva nel ViewState della pagina l'id del paziente.
        ''' </summary>
        ''' <returns></returns>
        Public Property IdPaziente() As Guid
            Get
                Return CType(ViewState("IdPaziente"), Guid)
            End Get
            Set(ByVal value As Guid)
                ViewState("IdPaziente") = value
            End Set
        End Property

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
            Try
                '
                ' Parametri di QueryString
                '
                Me.IdPaziente = New Guid(Request.QueryString("idPaziente"))

                If Not Page.IsPostBack Then
                    '
                    ' Set della proprietà NavigateUrl del collegamento di indietro
                    '
                    lnkIndietro.NavigateUrl = String.Format(lnkIndietro.NavigateUrl, IdPaziente.ToString)
                End If
            Catch ex As Exception

                'Si è verificato un errore.
                Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
            End Try

        End Sub

        Protected Sub odsDettaglioEsenzione_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettaglioEsenzione.Selected
            Try
                'testo se si è verificato un errore.
                If e.Exception IsNot Nothing Then
                    e.ExceptionHandled = True
                    'ottengo il messaggio di errore.
                    Throw e.Exception
                End If
            Catch ex As Exception
                'Si è verificato un errore.
                '
                'ATTENZIONE:
                'Chiamo il metodo CustomDataSourceException.TrapError(ex) al posto di GestioneErrori.TrapError perchè questa objectdatasource chiama una CustomDataSource
                ' che ottiene i dati da un WCF.
                'iN questo modo trappo anche gli errori generati dal WCF.
                Master.ShowErrorLabel(CustomDataSourceException.TrapError(ex))
            End Try
        End Sub


#Region "ProtectedFunctions"
        ''' <summary>
        ''' Ottiene la descrizione dell'esenzione dal nodo TestoEsenzione del WcfSac
        ''' </summary>
        ''' <param name="row"></param>
        ''' <returns></returns>
        Protected Function GetEsenzioneTestoDescrizione(ByVal row As Object) As String
            Dim descrizioneEsenzione As String = String.Empty

            If row IsNot Nothing Then
                Dim esenzioneRow As WcfSacPazienti.EsenzioneType = CType(row, WcfSacPazienti.EsenzioneType)

                If esenzioneRow IsNot Nothing Then
                    If esenzioneRow.TestoEsenzione IsNot Nothing Then
                        descrizioneEsenzione = esenzioneRow.TestoEsenzione.Descrizione
                    End If
                End If

            End If

            Return descrizioneEsenzione
        End Function

        ''' <summary>
        ''' Ottiene il codice dell'esenzione dal nodo TestoEsenzione del WcfSac
        ''' </summary>
        ''' <param name="row"></param>
        ''' <returns></returns>
        Protected Function GetEsenzioneTestoCodice(ByVal row As Object) As String
            Dim codiceEsenzione As String = String.Empty

            If row IsNot Nothing Then
                Dim esenzioneRow As WcfSacPazienti.EsenzioneType = CType(row, WcfSacPazienti.EsenzioneType)

                If esenzioneRow IsNot Nothing Then
                    If esenzioneRow.TestoEsenzione IsNot Nothing Then
                        codiceEsenzione = esenzioneRow.TestoEsenzione.Codice
                    End If
                End If

            End If

            Return codiceEsenzione
        End Function
#End Region

    End Class

End Namespace