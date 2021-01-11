Imports System
Imports System.Web.UI.WebControls
Imports DI.OrderEntry.Admin

Public Class DettaglioAssociazioneSistemiDatoAccessorio
    Inherits System.Web.UI.Page

#Region "Property"
    Public Property RowID As String
        Get
            Return Me.ViewState("--RowID--")
        End Get
        Set(value As String)
            Me.ViewState("--RowID--") = value
        End Set
    End Property
    Public Property idDatoAccessorio As String
        Get
            Return Me.ViewState("--idDatoAccessorio--")
        End Get
        Set(value As String)
            Me.ViewState("--idDatoAccessorio--") = value
        End Set
    End Property
    Public Property idSistema As String
        Get
            Return Me.ViewState("--idSistema--")
        End Get
        Set(value As String)
            Me.ViewState("--idSistema--") = value
        End Set
    End Property
#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            If Not Page.IsPostBack Then
                '
                ' Ottengo dal QueryString i parametri e controllo se sono valorizzati.
                '
                RowID = Me.Request.QueryString("id")
                If String.IsNullOrEmpty(RowID) Then
                    Throw New ApplicationException("Il parametro 'Id' è obbligatorio.")
                End If

                idDatoAccessorio = Me.Request.QueryString("idDatoAccessorio")
                If String.IsNullOrEmpty(idDatoAccessorio) Then
                    Throw New ApplicationException("Il parametro 'idDatoAccessorio' è obbligatorio.'")
                End If

                idSistema = Me.Request.QueryString("idSistema")
                If String.IsNullOrEmpty(idDatoAccessorio) Then
                    Throw New ApplicationException("Il parametro 'idDatoAccessorio' è obbligatorio.'")
                End If
            End If
        Catch ex As ApplicationException
            Utils.ShowErrorLabel(LabelError, ex.Message)
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Utils.ShowErrorLabel(LabelError, ex.Message)
        End Try
    End Sub

    Protected Sub chkEreditaCheckedChanged(sender As Object, e As EventArgs)
        changeChkState()
    End Sub

    Private Sub form_PreRender(sender As Object, e As EventArgs) Handles fvSistemiDatiAccessori.PreRender
        If Not Page.IsPostBack Then
            changeChkState()
            'changeTxbValoreDefaultState()
        End If
    End Sub

    Private Sub changeTxbValoreDefaultState()
        Try
            Dim txtValoreDefault As TextBox = CType(fvSistemiDatiAccessori.FindControl("ValoreDefaultTextBox"), TextBox)
            Dim sistemaCheckbox As CheckBox = CType(fvSistemiDatiAccessori.FindControl("SistemaCheckBox"), CheckBox)
            Dim validator As RequiredFieldValidator = CType(fvSistemiDatiAccessori.FindControl("txtValidator"), RequiredFieldValidator)

            If txtValoreDefault IsNot Nothing AndAlso sistemaCheckbox IsNot Nothing Then
                If sistemaCheckbox.Checked Then
                    txtValoreDefault.Enabled = True
                    validator.Enabled = True
                Else
                    txtValoreDefault.Enabled = False
                    validator.Enabled = False
                End If
            End If
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Utils.ShowErrorLabel(LabelError, ex.Message)
        End Try
    End Sub

    Protected Sub chkSistemaCheckedChanged(sender As Object, e As EventArgs)
        changeTxbValoreDefaultState()
    End Sub

    Private Sub changeChkState()
        Try
            Dim ereditaCheckbox As CheckBox = CType(fvSistemiDatiAccessori.FindControl("EreditaCheckBox"), CheckBox)
            Dim sistemaChk As CheckBox = CType(fvSistemiDatiAccessori.FindControl("SistemaCheckBox"), CheckBox)
            Dim valoreDefaultTxb As TextBox = CType(fvSistemiDatiAccessori.FindControl("ValoreDefaultTextBox"), TextBox)
            Dim validator As RequiredFieldValidator = CType(fvSistemiDatiAccessori.FindControl("txtValidator"), RequiredFieldValidator)


            '
            ' Se ereditaCheckbox.checked = true allora abilito la checkbox "sistemaChk" e la textbox "txtValoreDefault"
            '
            If ereditaCheckbox IsNot Nothing AndAlso sistemaChk IsNot Nothing Then
                If Not ereditaCheckbox.Checked Then
                    If sistemaChk.Checked Then
                        valoreDefaultTxb.Enabled = True
                        validator.Enabled = True
                    Else
                        valoreDefaultTxb.Enabled = False
                        validator.Enabled = False
                    End If
                    sistemaChk.Enabled = True
                Else
                    valoreDefaultTxb.Enabled = False
                    sistemaChk.Enabled = False
                    validator.Enabled = False
                End If
            End If

        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Utils.ShowErrorLabel(LabelError, ex.Message)
        End Try
    End Sub

    Private Sub odsSistemiDatiAccessori_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles odsSistemiDatiAccessori.Updating
        Try
            LabelError.Visible = False

            Dim Eredita As Boolean = CType(e.InputParameters.Item("Eredita"), Boolean)
            Dim Sistemi As Boolean = CType(e.InputParameters.Item("Sistema"), Boolean)
            Dim ValoreDefault As String = CType(e.InputParameters.Item("ValoreDefault"), String)

            '
            ' Se la checkbox Eredita è false e Sistemi è true allora ValoreDefault deve essere valorizzata.
            '
            If Eredita = False Then
                If Sistemi Then
                    If String.IsNullOrEmpty(ValoreDefault) Then
                        e.Cancel = True
                        LabelError.Visible = True
                        LabelError.Text = "Il campo 'Valore di default' è obbligatorio."
                    End If
                End If
            End If

            e.InputParameters("Id") = New Guid(RowID)
            e.InputParameters("CodiceDatoAccessorio") = idDatoAccessorio
            e.InputParameters("IdSistema") = New Guid(idSistema)
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Utils.ShowErrorLabel(LabelError, ex.Message)
        End Try
    End Sub

    Private Sub odsSistemiDatiAccessori_Updated(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsSistemiDatiAccessori.Updated
        Try
            '
            ' Registro lo script lato client per chiudere la modale. Lo faccio solo se il dato è stato aggiornato e non ci sono stati errori.
            '
            Dim scriptText As String
            scriptText = "window.parent.commonModalDialogClose(0);"
            ClientScript.RegisterClientScriptBlock(Me.GetType(),
            "CloseModal", scriptText, True)

        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
            Utils.ShowErrorLabel(LabelError, ex.Message)
        End Try
    End Sub
End Class