﻿Imports System.Diagnostics
Imports System
Imports System.Web.UI.WebControls

Namespace DI.Sac.Admin

    Partial Public Class UtentiLista
        Inherits System.Web.UI.Page

        Private Shared ReadOnly _ClassName As String = String.Concat("Gestione.", System.Reflection.MethodBase.GetCurrentMethod().ReflectedType.Name)

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
			' BEGIN
        End Sub

        Protected Sub MainObjectDataSource_Selected(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles MainObjectDataSource.Selected

            If e.Exception IsNot Nothing Then
                ExceptionsManager.TraceException(e.Exception)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
                e.ExceptionHandled = True
            End If
        End Sub

    End Class

End Namespace