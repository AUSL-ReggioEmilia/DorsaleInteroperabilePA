﻿Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin
Imports System.Data
Imports OrganigrammaDataSetTableAdapters

Public Class UnitaOperativeLista
    Inherits System.Web.UI.Page

    Private Const lblText As String = "Sono stati mostrati solo i primi 1000 record perchè la ricerca ha prodotto più di 1000 risultati."


    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName


	Private Sub Page_PreRender(sender As Object, e As System.EventArgs) Handles Me.PreRender
		Try
			If Not Page.IsPostBack Then
				FilterHelper.Restore(pannelloFiltri, msPAGEKEY)
			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
		Try
			If Not Page.IsPostBack Then
				'RICARICO IL FILTRO DELLA DROPDOWN CHE VIENE PERSO AL DATABIND
				FilterHelper.Restore(ddlFiltriAzienda, msPAGEKEY)
			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Protected Sub RicercaButton_Click(sender As Object, e As EventArgs) Handles butFiltriRicerca.Click

		Try
			LabelError.Visible = False
			If ValidazioneFiltri() Then
				FilterHelper.SaveInSession(pannelloFiltri, msPAGEKEY)
				Cache.Remove(odsLista.CacheKeyDependency)
				gvLista.PageIndex = 0
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try

	End Sub

    Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
        Try
            If e.Exception Is Nothing Then
                Dim gvTop As Integer = CInt(odsLista.SelectParameters.Item("Top").DefaultValue)
                Dim eG = CType(e.ReturnValue, DataTable)
                If eG.Rows.Count = gvTop Then
                    lblGvLista.Visible = True
                    lblGvLista.Text = lblText
                Else
                    lblGvLista.Visible = False
                End If
            Else
                ObjectDataSource_TrapError(sender, e)
                lblGvLista.Visible = False
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
            lblGvLista.Visible = False
        End Try
    End Sub

    Protected Function ValidazioneFiltri() As Boolean

		'nulla da validare
		Return True

	End Function


#Region "Funzioni"

	''' <summary>
	''' Gestisce gli errori del ObjectDataSource in maniera pulita
	''' </summary>
	''' <returns>True se si è verificato un errore</returns>
	Private Function ObjectDataSource_TrapError(ods As ObjectDataSourceView, e As ObjectDataSourceStatusEventArgs) As Boolean
		Try
			If e.Exception IsNot Nothing AndAlso e.Exception.InnerException IsNot Nothing Then
				Utility.ShowErrorLabel(LabelError, GestioneErrori.TrapError(e.Exception.InnerException))
				e.ExceptionHandled = True
				Return True
			Else
				Return False
			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
			Return True
		End Try

	End Function

#End Region

End Class