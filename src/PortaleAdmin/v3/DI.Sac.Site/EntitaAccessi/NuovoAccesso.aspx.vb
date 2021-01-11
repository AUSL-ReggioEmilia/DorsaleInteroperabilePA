Imports DI.Common
Imports Progel.Identity.ActiveDirectory
Imports System
Imports System.Web.UI.HtmlControls
Imports System.Data
Imports System.Web.UI.WebControls
Imports System.Diagnostics
Imports DI.Sac.Admin.Data.PermessiDataSetTableAdapters
Imports DI.Sac.Admin.Data.PermessiDataSet

Namespace DI.Sac.Admin

    Partial Public Class NuovoAccesso
        Inherits System.Web.UI.Page

        Private Shared ReadOnly _className As String = String.Concat("Gestione.", System.Reflection.MethodBase.GetCurrentMethod().ReflectedType.Name)

        '
        ' Controlli da ricercare nella pagina master
        '
        Private formMaster As HtmlForm

        Private Const CELL_IDs As Byte = 0
        Private Const CELL_SAMACCOUNTNAME As Byte = 2
        Private Const CELL_DISPLAYNAME As Byte = 3
        Private Const CELL_NAME As Byte = 4
        Private Const CELL_DESCRIPTION As Byte = 5
        Private Const CELL_CHECKBOX As Byte = 6

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
            Try
                '
                ' Default Focus/Button
                '
                If Master.TryFindControl(Of HtmlForm)("form1", formMaster) Then
                    formMaster.DefaultFocus = txtNome.ClientID
                    formMaster.DefaultButton = btnRicerca.UniqueID
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

        Protected Sub btnRicerca_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnRicerca.Click
            Try
                Dim oDataset As DataSet = Nothing
                Dim sFilter As String = String.Empty
                Dim sFilterDescription As String = String.Empty
                Dim sFilterName As String = String.Empty
                Dim sFilterUsers As String = String.Empty
                Dim sFilterGroups As String = String.Empty
                Dim sFilterUserGroup As String = String.Empty
                Dim sSearchValue As String = String.Empty
                Dim sPropertyToFind As String = "objectGUID,sAMAccountName,objectCategory,objectClass,displayName,name,description"
                Dim oIdentityUtil As New Util()
                Dim bFindUsers As Boolean = chkUserGroup.Items(0).Selected
                Dim bFindGroups As Boolean = chkUserGroup.Items(1).Selected
                Dim sNome As String = txtNome.Text
                Dim sDescrizione As String = txtDescrizione.Text
                '
                ' ATTENZIONE: Se il campo Descrizione (txtDescrizione.Text) contiene solo degli a "*" , la stringa di filtro che viene composta genera un errore
                '
                If sDescrizione.Replace("*", String.Empty) = String.Empty Then
                    'Allora era composto da soli "*"
                    sDescrizione = String.Empty
                End If

                '
                ' Condizioni di filtro su gruppi e/o utenti o entrambi.
                '
                sFilterUsers = "(&(objectClass=user)(objectCategory=person))"
                sFilterGroups = "(&(objectClass=group)(objectCategory=group))"

                If bFindGroups And bFindUsers Then
                    sFilterUserGroup = "(|" & sFilterGroups & sFilterUsers & ")"
                ElseIf bFindGroups Then
                    sFilterUserGroup = "(" & sFilterGroups & ")"
                ElseIf bFindUsers Then
                    sFilterUserGroup = "(" & sFilterUsers & ")"
                End If
                '
                ' Compongo la stringa di ricerca basata sul nome e sulla descrizione
                '
                sFilterName = "(cn=" & sNome & "*)" & _
                          "(displayName=" & sNome & "*)" & _
                          "(name=" & sNome & "*)" & _
                          "(sn=" & sNome & "*)" & _
                          "(givenName=" & sNome & "*)"

                sFilterName = "(|" & sFilterName & ")"

                If sDescrizione.Length > 0 Then
                    sFilterDescription = "(description=*" & sDescrizione & "*)"
                    sFilter = "(&" & sFilterName & sFilterDescription & ")"
                Else
                    sFilter = sFilterName
                End If
                '
                ' Compongo la stringa completa 
                '
                sFilter = "(&" & sFilterUserGroup & sFilter & ")"
                '
                ' Eseguo la ricerca
                '
                oDataset = oIdentityUtil.FindDirectoryEntries(oIdentityUtil.GetLdapDomainName(""), sPropertyToFind, sFilter)
                '
                ' Visualizzo il pulsante di conferma/annulla
                '
                If oDataset.Tables(0).Rows.Count > 0 Then

                    btnConferma.Visible = True
                    btnAnnulla.Visible = True
                Else
                    btnConferma.Visible = False
                    btnAnnulla.Visible = False
                End If

                gvActiveDirectory.DataSource = oDataset.Tables(0)
                gvActiveDirectory.DataBind()
            Catch ex As Exception
                'ExceptionsManager.TraceException(ex)
                'LabelError.Visible = True
                'LabelError.Text = MessageHelper.GetGenericMessage()
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

        Protected Sub gvActiveDirectory_SelectedIndexChanged(ByVal sender As Object, ByVal e As EventArgs) Handles gvActiveDirectory.SelectedIndexChanged

            Dim currentRow As GridViewRow = gvActiveDirectory.Rows(gvActiveDirectory.SelectedIndex)

            Try
                Dim oObjectGUID As Byte() = Convert.FromBase64String(CType(CType(currentRow.Cells(CELL_IDs).Controls(1), Label).Text, String))
                Dim oGUID = New Guid(oObjectGUID)
                '
                ' Determino se l'entità è un utente o un gruppo
                '
                Dim bEntity As Byte
                Dim oArray As Array = DirectCast(currentRow.Cells(CELL_IDs).Controls(3), Label).Text.Split("CN=")
                If oArray.GetValue(1).ToString().Contains("Group") Then
                    bEntity = CByte(TypeAccessEntity.Group)
                Else
                    bEntity = CByte(TypeAccessEntity.User)
                End If
                '
                ' sAMAccountName
                '
                Dim sSAMAccountName As String = currentRow.Cells(CELL_SAMACCOUNTNAME).Text
                '
                ' displayName --> (Descrizione1)
                '
                Dim sDisplayName As String = currentRow.Cells(CELL_DISPLAYNAME).Text.Replace("&nbsp;", String.Empty)
                '
                ' name  --> (Descrizione2)
                '
                Dim sName As String = currentRow.Cells(CELL_NAME).Text.Replace("&nbsp;", String.Empty)
                '
                ' description  --> (Descrizione3)
                '
                Dim sDescription As String = currentRow.Cells(CELL_DESCRIPTION).Text.Replace("&nbsp;", String.Empty)

                Add(oGUID, sSAMAccountName, sDisplayName, sName, sDescription, bEntity)

                Response.Redirect("EntitaAccessiLista.aspx", False)
            Catch ex As Exception
                'ExceptionsManager.TraceException(ex)
                'LabelError.Visible = True
                'LabelError.Text = MessageHelper.GetGenericMessage()
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

        Protected Sub btnConferma_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnConferma.Click
            Try
                '
                ' Copio gli accessi selezionati
                '
                For Each gridRow As GridViewRow In gvActiveDirectory.Rows

                    Dim chkSelect As CheckBox = DirectCast(gridRow.Cells(CELL_CHECKBOX).Controls(1), CheckBox)
                    If chkSelect.Checked Then

                        Dim oObjectGUID As Byte() = Convert.FromBase64String(DirectCast(gridRow.Cells(CELL_IDs).Controls(1), Label).Text)
                        Dim oGUID = New Guid(oObjectGUID)
                        '
                        ' Determino se l'entità è un utente o un gruppo
                        '
                        Dim bEntity As Byte
                        Dim oArray As Array = DirectCast(gridRow.Cells(CELL_IDs).Controls(3), Label).Text.Split("CN=")
                        If oArray.GetValue(1).ToString().Contains("Group") Then
                            bEntity = CByte(TypeAccessEntity.Group)
                        Else
                            bEntity = CByte(TypeAccessEntity.User)
                        End If
                        '
                        ' sAMAccountName
                        '
                        Dim sSAMAccountName As String = gridRow.Cells(CELL_SAMACCOUNTNAME).Text
                        '
                        ' displayName --> (Descrizione1)
                        '
                        Dim sDisplayName As String = gridRow.Cells(CELL_DISPLAYNAME).Text.Replace("&nbsp;", String.Empty)
                        '
                        ' name  --> (Descrizione2)
                        '
                        Dim sName As String = gridRow.Cells(CELL_NAME).Text.Replace("&nbsp;", String.Empty)
                        '
                        ' description  --> (Descrizione3)
                        '
                        Dim sDescription As String = gridRow.Cells(CELL_DESCRIPTION).Text.Replace("&nbsp;", String.Empty)

                        Add(oGUID, sSAMAccountName, sDisplayName, sName, sDescription, bEntity)
                    End If
                Next

                Response.Redirect("EntitaAccessiLista.aspx", False)
            Catch ex As Exception
                'ExceptionsManager.TraceException(ex)
                'LabelError.Visible = True
                'LabelError.Text = MessageHelper.GetGenericMessage()
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

        Protected Sub btnAnnulla_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnAnnulla.Click
            Try
                Response.Redirect("EntitaAccessiLista.aspx", False)
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    LabelError.Visible = True
                    LabelError.Text = sErrorMessage
                End If
            End Try
        End Sub

        ''' <summary>
        ''' Insert/Update della riga
        ''' </summary>
        ''' <param name="id"></param>
        ''' <param name="samAccountName"></param>
        ''' <param name="displayName"></param>
        ''' <param name="name"></param>
        ''' <param name="description"></param>
        ''' <param name="entity"></param>
        ''' <remarks></remarks>
        Protected Sub Add(ByVal id As Guid, ByVal samAccountName As String, ByVal displayName As String, _
                          ByVal name As String, ByVal description As String, ByVal entity As Byte)

            Using adapter As New EntitaAccessiTableAdapter()

                Dim dominio As String = New Util().GetNetbiosDomainName()
                Dim dataTable As EntitaAccessiDataTable = adapter.GetData()
                Dim row As EntitaAccessiRow = dataTable.FindById(id)

                If row IsNot Nothing Then
                    '
                    ' MODIFICA ETTORE 2014-01-06: Attenzione devo reimpostare il valore del campo Amministratore!
                    '
                    adapter.UpdateRow(id, samAccountName, displayName, name, description, dominio, entity, row.Amministratore)
                Else
                    adapter.Insert(id, samAccountName, displayName, name, description, dominio, entity, False)
                End If
            End Using
        End Sub

    End Class

End Namespace