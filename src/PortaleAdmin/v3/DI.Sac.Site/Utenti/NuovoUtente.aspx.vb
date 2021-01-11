
Imports DI.Common
Imports Progel.Identity.ActiveDirectory
Imports System
Imports System.Web.UI.WebControls
Imports System.Web.UI.HtmlControls
Imports System.Data
Imports System.Diagnostics
Imports DI.Sac.Admin.Data.UtentiDataSetTableAdapters
Imports DI.Sac.Admin.Data.UtentiDataSet

Namespace DI.Sac.Admin

    Partial Public Class NuovoUtente
        Inherits System.Web.UI.Page

        Private Shared ReadOnly _ClassName As String = String.Concat("Gestione.", System.Reflection.MethodBase.GetCurrentMethod().ReflectedType.Name)

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

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
            '
            ' Default Focus/Button
            '
            If Master.TryFindControl(Of HtmlForm)("form1", formMaster) Then
                formMaster.DefaultFocus = txtNomeCerca.ClientID
                formMaster.DefaultButton = btnRicerca.UniqueID
            End If

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
                Dim sNome As String = txtNomeCerca.Text
                Dim sDescrizione As String = txtDescrizione.Text
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

                If Not sDescrizione.Length = 0 Then
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
				'            If oDataset.Tables(0).Rows.Count > 0 Then
				'	butConferma.Visible = True
				'	butAnnulla.Visible = True
				'Else
				'	butConferma.Visible = False
				'	butAnnulla.Visible = False
				'End If

				gvActiveDirectory.DataSource = oDataset.Tables(0)
				gvActiveDirectory.DataBind()
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				LabelError.Visible = True
				LabelError.Text = MessageHelper.GetGenericMessage()
			End Try
		End Sub

		Protected Sub btnNuovo_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnNuovo.Click
			trToolbar.Visible = False
			trGridView.Visible = False
			trNuovoUtente.Visible = True
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

				Add(sSAMAccountName, sDescription)

				Redirect()

			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				LabelError.Visible = True
				LabelError.Text = MessageHelper.GetGenericMessage()
			End Try
		End Sub

		Private Function ConvertSortDirectionToSql(sortDirection__1 As SortDirection) As String
			Dim newSortDirection As String = [String].Empty

			Select Case sortDirection__1
				Case SortDirection.Ascending
					newSortDirection = "ASC"
					Exit Select

				Case SortDirection.Descending
					newSortDirection = "DESC"
					Exit Select
			End Select

			Return newSortDirection
		End Function

		Protected Sub gvActiveDirectory_PageIndexChanging(sender As Object, e As GridViewPageEventArgs)

			gvActiveDirectory.PageIndex = e.NewPageIndex
			gvActiveDirectory.DataBind()

		End Sub

		Protected Sub gvActiveDirectory_Sorting(sender As Object, e As GridViewSortEventArgs)

			Dim dataTable As DataTable = TryCast(gvActiveDirectory.DataSource, DataTable)

			If dataTable IsNot Nothing Then
				Dim dataView As New DataView(dataTable)
				dataView.Sort = Convert.ToString(e.SortExpression + " ") & ConvertSortDirectionToSql(e.SortDirection)

				gvActiveDirectory.DataSource = dataView
				gvActiveDirectory.DataBind()
			End If

		End Sub


		Protected Sub butConferma_Click(ByVal sender As Object, ByVal e As EventArgs) Handles butConfermaTop.Click, butConferma.Click

			Dim chkSelect As CheckBox

			Try
				'
				' Copio gli accessi selezionati
				'
				For Each row As GridViewRow In gvActiveDirectory.Rows

					chkSelect = CType(row.Cells(CELL_CHECKBOX).Controls(1), CheckBox)
					If chkSelect.Checked Then
						'
						' objectGUID
						'
						Dim oObjectGUID As Byte() = Convert.FromBase64String(CType(CType(row.Cells(CELL_IDs).Controls(1), Label).Text, String))
						Dim oGUID = New Guid(oObjectGUID)
						'
						' Determino se l'entità è un utente o un gruppo
						'
						Dim bEntity As Byte
						Dim oArray As Array = DirectCast(row.Cells(CELL_IDs).Controls(3), Label).Text.Split("CN=")
						If oArray.GetValue(1).ToString().Contains("Group") Then
							bEntity = CByte(TypeAccessEntity.Group)
						Else
							bEntity = CByte(TypeAccessEntity.User)
						End If
						'
						' sAMAccountName
						'
						Dim sSAMAccountName As String = row.Cells(CELL_SAMACCOUNTNAME).Text
						'
						' displayName --> (Descrizione1)
						'
						Dim sDisplayName As String = row.Cells(CELL_DISPLAYNAME).Text.Replace("&nbsp;", String.Empty)
						'
						' name  --> (Descrizione2)
						'
						Dim sName As String = row.Cells(CELL_NAME).Text.Replace("&nbsp;", String.Empty)
						'
						' description  --> (Descrizione3)
						'
						Dim sDescription As String = row.Cells(CELL_DESCRIPTION).Text.Replace("&nbsp;", String.Empty)

						Add(sSAMAccountName, sDescription)
					End If
				Next

				Redirect()

			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				LabelError.Visible = True
				LabelError.Text = MessageHelper.GetGenericMessage()
			End Try
		End Sub

		Protected Sub butAnnulla_Click(ByVal sender As Object, ByVal e As EventArgs) Handles butAnnullaTop.Click, butAnnulla.Click
			Redirect()
		End Sub

        Protected Sub InsertButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles InsertButton.Click

            Dim disattivato As Byte
            If chkDisattivato.Checked Then disattivato = 1 Else disattivato = 0

            Add(txtUtente.Text, txtDescrizione.Text, txtDipartimentale.Text, txtEmailResponsabile.Text, disattivato)

            Redirect()
        End Sub

        Protected Sub InsertCancelButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles InsertCancelButton.Click
            Redirect()
        End Sub

        Private Sub Redirect()
            Response.Redirect("UtentiLista.aspx", False)
        End Sub

        '
        ' Insert/Update della riga
        '
        Protected Sub Add(ByVal sAMAccountName As String, ByVal description As String)
            Try
                Using adapter As New UtentiTableAdapter()

                    Dim sDominio As String = New Util().GetNetbiosDomainName()
                    Dim sUtente As String = String.Concat(sDominio, "\", sAMAccountName)
                    Dim sDipartimentale As String = Nothing
                    Dim sEmailResponsabile As String = Nothing
                    Dim sDisattivato As Byte = 0
                    Dim dt As UtentiDataTable = adapter.GetData(sUtente)

                    If String.IsNullOrEmpty(description) Then description = Nothing

                    If dt.Rows.Count > 0 Then

                        Dim row As UtentiRow = dt(0)
                        If Not row.IsDipartimentaleNull() Then sDipartimentale = row.Dipartimentale
                        If Not row.IsEmailResponsabileNull() Then sEmailResponsabile = row.EmailResponsabile

                        sDisattivato = row.Disattivato

                        adapter.Update(sUtente, description, sDipartimentale, sEmailResponsabile, sDisattivato)
                    Else
                        adapter.Insert(sUtente, description, Nothing, Nothing, sDisattivato)
                    End If

                End Using

            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Inserimento)
            End Try
        End Sub

        Protected Sub Add(ByVal utente As String, ByVal descrizione As String, ByVal dipartimentale As String, ByVal emailResponsabile As String, ByVal disattivato As Byte)
            Try
                Using adapter As New UtentiTableAdapter()

                    Dim dt As UtentiDataTable = adapter.GetData(utente)

                    If String.IsNullOrEmpty(descrizione) Then descrizione = Nothing
                    If String.IsNullOrEmpty(dipartimentale) Then dipartimentale = Nothing
                    If String.IsNullOrEmpty(emailResponsabile) Then emailResponsabile = Nothing

                    If dt.Rows.Count > 0 Then

                        ' Update
                        Dim oRow As UtentiRow = dt(0)
                        If Not oRow.IsDipartimentaleNull() Then dipartimentale = oRow.Dipartimentale
                        If Not oRow.IsEmailResponsabileNull() Then emailResponsabile = oRow.EmailResponsabile
                        disattivato = oRow.Disattivato

                        adapter.Update(utente, descrizione, dipartimentale, emailResponsabile, disattivato)
                    Else
                        adapter.Insert(utente, descrizione, dipartimentale, emailResponsabile, disattivato)
                    End If
                End Using
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Inserimento)
            End Try
        End Sub

    End Class

End Namespace