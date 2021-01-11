Imports System.Web.UI
Imports System.Web.Services
Imports DI.PortalUser2.Data
Imports DI.OrderEntry.User.Data
Imports System.Linq

Namespace DI.OrderEntry.User

    Public Class PazientePerNosologicoMethods
        Inherits Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

        End Sub

        <WebMethod()>
        Public Shared Function GetIdPaziente(nosologico As String, azienda As String) As String

            If String.IsNullOrEmpty(nosologico) Then
                Return Nothing
            End If

            If String.IsNullOrEmpty(azienda) Then
                Return Nothing
            End If

            nosologico = nosologico.Trim()

            Dim oEpisodio As New WcfDwhClinico.EpisodioType

            Try
                ''2015-05-07:  SU INDICAZIONE DI CORRADO VIENE UTILIZZATO IL PRIMO CODICE AZIENDA
                '  CHE TROVO NELLE UNITA' OPERATIVE LEGATE AL RUOLO CORRENTE
                '  SI DA PER SCONTATO CHE IL RUOLO DEBBA ESSERE MONO AZIENDA
                Dim unitaOperative = DataAdapterManager.GetLookupUOPerRuolo()
                If unitaOperative.Count = 0 Then
                    '
                    'l'utente non ha i permessi sulle UO
                    '
                    Throw New Exception("Nessuna unità operativa configurata per il ruolo corrente.")

                End If

                'Dim azienda = unitaOperative(0).CodiceAzienda

                oEpisodio = DettaglioPaziente.GetDatiRicoveroByNosologicoAzienda(nosologico, azienda)


                If oEpisodio Is Nothing Then

                    Return "NoRicovero"
                Else


                    If oEpisodio.DataConclusione.HasValue AndAlso oEpisodio.DataConclusione.Value.AddDays(My.Settings.IntervalloChiusuraRicovero) <= DateTime.Now Then
                        Return "RicoveroChiuso"
                    End If

                    'prendo l'ultimo evento in ordine cronologico che ha valorizzato il reparto codice
                    Dim RepartoCodice = String.Empty

                    '
                    ' Se il paziente è dimesso allora lo prendo da StrutturaConclusione altrimenti lo prendo da StrutturaUltimoEvento.
                    '
                    If oEpisodio.StrutturaConclusione IsNot Nothing Then
                        RepartoCodice = oEpisodio.StrutturaConclusione.Codice
                    ElseIf oEpisodio.StrutturaUltimoEvento IsNot Nothing Then
                        RepartoCodice = oEpisodio.StrutturaUltimoEvento.Codice
                    Else
                        Return "RepartoNonValorizzato"
                    End If


                    'controllo autorizzazioni sul reparto per il ruolo corrente
                    'Dim found = (From unita In unitaOperative
                    '             Where String.Equals(unita.CodiceUO, azienda & "-" & RepartoCodice, StringComparison.CurrentCultureIgnoreCase)).ToArray().Count > 0
                    Dim found = (From unita In unitaOperative
                                 Where String.Equals(unita.CodiceUO, azienda & "-" & RepartoCodice, StringComparison.CurrentCultureIgnoreCase))

                    If found.ToArray.Count > 0 Then
                        Return oEpisodio.IdPaziente & "§" & RepartoCodice
                    Else
                        Return "NoReparto"
                    End If
                End If

            Catch ex As CustomException(Of WcfDwhClinico.ErroreType)
                '
                ' Eseguito solo se l'errore è restituito dalla chiamata al metodo del ws.
                '
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Throw
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Throw
            End Try
        End Function


        Public Shared Function GetNumNosologicoDWH(ByVal rsValue As String,
                                        ByRef rstrRetValue1 As String,
                                        ByRef rstrRetValue2 As String) As Boolean
            '
            ' Ritorna il numero nosologico da utilizzare nel DWH Clinico
            '
            ' Es.: 	 I05045646	--->   1005045646
            '
            Dim strNosologico As String = String.Empty
            Dim boolFound As Boolean = False

            Try
                '
                ' Default
                '
                rstrRetValue1 = Nothing
                rstrRetValue2 = Nothing

                If Not IsNothing(rsValue) AndAlso rsValue.Length > 0 Then

                    If Left(rsValue.ToUpper, 1) = "P" Then
                        '
                        ' P ----> 13
                        '
                        rstrRetValue1 = "13" + Right(rsValue, rsValue.Length - 1)
                        boolFound = True
                    ElseIf (Left(rsValue.ToUpper, 1) = "I") Then
                        '
                        ' I  ----> può essere 10 o 12
                        '
                        rstrRetValue1 = "10" + Right(rsValue, rsValue.Length - 1)
                        rstrRetValue2 = "12" + Right(rsValue, rsValue.Length - 1)

                        boolFound = True
                    ElseIf Left(rsValue.ToUpper, 1) = "D" Then
                        '
                        ' D ----> 11
                        '
                        rstrRetValue1 = "11" + Right(rsValue, rsValue.Length - 1)

                        boolFound = True
                    ElseIf Left(rsValue.ToUpper, 2) = "LA" Then
                        '
                        ' LA ----> 16
                        '
                        rstrRetValue1 = "16" + Right(rsValue, rsValue.Length - 2)

                        boolFound = True
                    ElseIf Left(rsValue.ToUpper, 1) = "E" Then
                        '
                        ' E ----> 18
                        '
                        rstrRetValue1 = "18" + Right(rsValue, rsValue.Length - 1)

                        boolFound = True
                    End If

                    Return boolFound

                End If

            Catch ex As Exception
                '
                ' Errore
                '
                Return False
            End Try

            Return boolFound

        End Function

        Public Shared Function GetNumNosologicoDWH(ByVal originalNosologico As String) As String
            '
            ' Ritorna il numero nosologico da utilizzare nel DWH Clinico
            '
            ' Es.: 1005045646 ---> I05045646
            '
            Dim nosologico As String = originalNosologico

            Try

                If Not String.IsNullOrEmpty(nosologico) Then

                    Dim intitialNosologico As String = nosologico.Substring(0, 2)

                    Select Case intitialNosologico

                        Case "13"
                            '
                            ' P ----> 13
                            '
                            nosologico = "P" + Right(nosologico, nosologico.Length - 2)

                        Case "10", "12"
                            '
                            ' I  ----> può essere 10 o 12
                            '
                            nosologico = "I" + Right(nosologico, nosologico.Length - 2)

                        Case "11"
                            '
                            ' D ----> 11
                            '
                            nosologico = "D" + Right(nosologico, nosologico.Length - 2)

                        Case "16"
                            '
                            ' LA ----> 16
                            '
                            nosologico = "LA" + Right(nosologico, nosologico.Length - 2)

                        Case "18"
                            '
                            ' E ----> 18
                            '
                            nosologico = "E" + Right(nosologico, nosologico.Length - 2)

                    End Select

                End If

            Catch ex As Exception
                '
                ' Errore
                '
                Return originalNosologico
            End Try

            Return nosologico

        End Function

    End Class

End Namespace