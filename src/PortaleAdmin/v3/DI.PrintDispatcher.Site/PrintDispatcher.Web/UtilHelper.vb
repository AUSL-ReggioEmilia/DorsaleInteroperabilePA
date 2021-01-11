Public NotInheritable Class UtilHelper

    Private Sub New()
    End Sub

    Public Enum RedirectType
        Parent
        Self
    End Enum

    Public Enum TypeError
        CaricamentoDati
        ElaborazionePagina
        Inserimento
        Aggiornamento
        Eliminazione
        EsecuzioneProcedura
        Creazione
        RiinvioStampa
    End Enum

    Public Shared Function SplitUserName(ByVal userName As String) As String
        Try
            Dim value As String() = My.User.Name.Split("\"c)
            If value.Length > 1 Then
                Return value(1)
            End If
            Return My.User.Name
        Catch ex As Exception
            Return My.User.Name
        End Try
    End Function

    Public Shared Function GetErrorMessage(ByVal typeError As TypeError) As String
        Select Case typeError
            Case TypeError.CaricamentoDati
                Return "Errore durante l'operazione di caricamento dati."

            Case TypeError.ElaborazionePagina
                Return "Errore durante l'operazione di elaborazione pagina."

            Case TypeError.EsecuzioneProcedura
                Return "Errore durante l'esecuzione della procedura."

            Case Else
                Return String.Format("Errore durante l'operazione di {0}.", typeError.ToString().ToLower())
        End Select
    End Function

    Public Shared Function GetInnerException(ByRef innerException As Exception, ByRef className As String) As String
        Dim sb As New StringBuilder()
        sb.Append(vbCrLf)
        sb.Append(String.Concat("[Class Name= ", className, "]"))
        If Not innerException Is Nothing Then
            sb.Append(vbCrLf & vbTab)
            Return String.Concat("InnerException: ", innerException.Message)
        End If
        Return sb.ToString()
    End Function

    ''' <summary>
    ''' Definisce le impostazioni dei pulsanti di azione - solo RePrint in base allo stato del job
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Sub AggiornaPulsantiAzione(ByVal ReprintButton As Button, ByVal oRow As DataAccess.JobQueueDataSet.UiJobQueueSelectRow)
        '
        ' In caso di errore posso sempre rimandare in stampa se il record non è nella history
        '
        ' Se non è nella history (poichè non c'è più il pdf)
        ' ed è valorizzata la data di completamento del job di stampa (quindi è stato già mandato in stampa)
        '
        ReprintButton.Enabled = False
        ReprintButton.Visible = True
        If Not oRow.InHistory AndAlso (Not oRow.IsPrintJobDateCompletedNull) Then
            ReprintButton.Visible = True
            ReprintButton.Enabled = True
        End If
    End Sub

    Public Shared Function RePrint(ByVal id As Guid, ByVal Ts As Byte()) As Boolean
        Using ta As New DataAccess.JobQueueDataSetTableAdapters.QueriesTableAdapter()
            ta.UiJobQueueUpdate(id, Ts, True, My.User.Name)
        End Using
        Return True
    End Function

    ''' <summary>
    ''' Per la gestione della ricerca tramite IdOrderEntry
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Property IdOrderEntry() As String
        Get
            Return CType(HttpContext.Current.Session("_IdOrderEntry_"), String)
        End Get
        Set(ByVal value As String)
            HttpContext.Current.Session("_IdOrderEntry_") = value
        End Set
    End Property

End Class

Public NotInheritable Class FilterHelper

    Private Sub New()
    End Sub

    Private Shared ReadOnly _className As String = System.Reflection.MethodBase.GetCurrentMethod().ReflectedType.Name

    ''' <summary>
    ''' Salvo i filtri in una Session
    ''' </summary>
    ''' <param name="parent"></param>
    ''' <remarks></remarks>
    Public Shared Sub SaveInSession(ByRef parent As Control)
        Try
            Dim child As Control

            If parent.Controls.Count > 0 Then
                For Each child In parent.Controls
                    SaveInSession(child)

                    If TypeOf child Is TextBox Then
                        HttpContext.Current.Session(child.ID) = CType(child, TextBox).Text
                    ElseIf TypeOf child Is DropDownList Then
                        HttpContext.Current.Session(child.ID) = CType(child, DropDownList).SelectedValue
                    ElseIf TypeOf child Is CheckBox Then
                        HttpContext.Current.Session(child.ID) = CType(child, CheckBox).Checked
                    ElseIf TypeOf child Is RadioButtonList Then
                        HttpContext.Current.Session(child.ID) = CType(child, RadioButtonList).SelectedValue
                    End If
                Next
            End If
        Catch ex As Exception
            My.Log.WriteException(ex, TraceEventType.Error, UtilHelper.GetInnerException(ex.InnerException, _className))
        End Try
    End Sub

    ''' <summary>
    ''' Clear dei filtri
    ''' </summary>
    ''' <param name="parent"></param>
    ''' <remarks></remarks>
    Public Shared Sub Clear(ByRef parent As Control)
        Try
            Dim child As Control

            If parent.Controls.Count > 0 Then
                For Each child In parent.Controls
                    Clear(child)

                    If TypeOf child Is TextBox Then
                        CType(child, TextBox).Text = String.Empty
                        If HttpContext.Current.Session(child.ID) IsNot Nothing Then HttpContext.Current.Session(child.ID) = Nothing
                    ElseIf TypeOf child Is DropDownList Then
                        CType(child, DropDownList).SelectedIndex = -1
                        If HttpContext.Current.Session(child.ID) IsNot Nothing Then HttpContext.Current.Session(child.ID) = Nothing
                    ElseIf TypeOf child Is CheckBox Then
                        CType(child, CheckBox).Checked = False
                        If HttpContext.Current.Session(child.ID) IsNot Nothing Then HttpContext.Current.Session(child.ID) = Nothing
                    ElseIf TypeOf child Is RadioButtonList Then
                        CType(child, RadioButtonList).SelectedIndex = -1
                        If HttpContext.Current.Session(child.ID) IsNot Nothing Then HttpContext.Current.Session(child.ID) = Nothing
                    End If
                Next
            End If
        Catch ex As Exception
            My.Log.WriteException(ex, TraceEventType.Error, UtilHelper.GetInnerException(ex.InnerException, _className))
        End Try
    End Sub

    ''' <summary>
    ''' Restore dei filtri salvati
    ''' </summary>
    ''' <param name="parent"></param>
    ''' <remarks></remarks>
    Public Shared Sub Restore(ByRef parent As Control)
        Try
            Dim child As Control
            Dim id As String

            If parent.Controls.Count > 0 Then
                For Each child In parent.Controls
                    Restore(child)
                    '
                    ' Id
                    '
                    id = child.ID

                    If TypeOf child Is TextBox Then
                        If Not HttpContext.Current.Session(id) Is Nothing Then
                            CType(child, TextBox).Text = HttpContext.Current.Session(id).ToString()
                        End If

                    ElseIf TypeOf child Is CheckBox Then
                        If Not HttpContext.Current.Session(id) Is Nothing Then
                            CType(child, CheckBox).Checked = CType(HttpContext.Current.Session(id).ToString(), Boolean)
                        End If

                    ElseIf TypeOf child Is DropDownList Then
                        ' Stringa empty viene usata nella dropdown list Storicizzati
                        If Not HttpContext.Current.Session(id) Is Nothing Then
                            CType(child, DropDownList).SelectedIndex = -1
                            CType(child, DropDownList).Items.FindByValue(HttpContext.Current.Session(id).ToString()).Selected = True
                        End If

                    ElseIf TypeOf child Is RadioButtonList Then
                        If Not HttpContext.Current.Session(id) Is Nothing AndAlso
                                Not HttpContext.Current.Session(id).ToString().Equals(String.Empty) Then
                            CType(child, RadioButtonList).SelectedIndex = -1
                            CType(child, RadioButtonList).Items.FindByValue(HttpContext.Current.Session(id).ToString()).Selected = True
                        End If

                    End If
                Next
            End If
        Catch ex As Exception
            My.Log.WriteException(ex, TraceEventType.Error, UtilHelper.GetInnerException(ex.InnerException, _className))
        End Try
    End Sub

    ''' <summary>
    ''' Clear dei valori nei controlli
    ''' </summary>
    ''' <param name="parent"></param>
    ''' <remarks></remarks>
    Public Shared Sub EmptyControlsValue(ByRef parent As Control)
        Try
            Dim child As Control

            If parent.Controls.Count > 0 Then
                For Each child In parent.Controls
                    EmptyControlsValue(child)

                    If TypeOf child Is TextBox Then
                        DirectCast(child, TextBox).Text = String.Empty
                    ElseIf TypeOf child Is DropDownList Then
                        DirectCast(child, DropDownList).SelectedIndex = -1
                    End If
                Next
            End If
        Catch ex As Exception
            My.Log.WriteException(ex, TraceEventType.Error, UtilHelper.GetInnerException(ex.InnerException, _className))
        End Try

    End Sub

End Class