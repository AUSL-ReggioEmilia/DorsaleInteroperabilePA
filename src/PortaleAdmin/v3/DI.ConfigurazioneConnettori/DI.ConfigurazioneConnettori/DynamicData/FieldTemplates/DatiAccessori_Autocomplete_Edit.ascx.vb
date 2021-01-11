Imports System.ComponentModel.DataAnnotations
Imports System.Web.DynamicData
Imports System.Web
Imports System.Web.Services
Imports Newtonsoft

Class DatiAccessori_Autocomplete_EditField
    Inherits FieldTemplateUserControl

    Public Overrides ReadOnly Property DataControl As Control
        Get
            Return TextBox1
        End Get
    End Property

    ''' <summary>
    ''' property usata lato client per generare l'autocomplete sulla textbox
    ''' </summary>
    ''' <returns></returns>
    Protected ReadOnly Property listaValoriDefault() As String
        Get
            Dim jsonSerializer As New Script.Serialization.JavaScriptSerializer()
            Return jsonSerializer.Serialize(GetDefaultDatiAccessori())
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)
        If (Column.MaxLength < 20) Then
            TextBox1.Columns = Column.MaxLength
        End If
        TextBox1.ToolTip = Column.Description
    End Sub

    Protected Overrides Sub OnDataBinding(ByVal e As EventArgs)
        MyBase.OnDataBinding(e)
        If (Column.MaxLength > 0) Then
            TextBox1.MaxLength = Math.Max(FieldValueEditString.Length, Column.MaxLength)
        End If
    End Sub

    Protected Overrides Sub ExtractValues(ByVal dictionary As IOrderedDictionary)
        dictionary(Column.Name) = ConvertEditedValue(TextBox1.Text)
    End Sub

    ''' <summary>
    ''' Ottiene la lista dei possibili default
    ''' </summary>
    ''' <returns></returns>
    Protected Shared Function GetDefaultDatiAccessori() As Object
        Try
            Dim returnValue As Object = Nothing

            Dim dt As DataSet_DatiAccessori.DatiAccessoriDefaultCercaDataTable = Nothing

            Using ta As New DataSet_DatiAccessoriTableAdapters.DatiAccessoriDefaultCercaTableAdapter()
                dt = ta.GetData()
            End Using

            If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
                returnValue = (From dato As DataSet_DatiAccessori.DatiAccessoriDefaultCercaRow In dt Select dato.Codice).ToArray()
            End If

            Return returnValue
        Catch ex As Exception
            Throw
        End Try
    End Function

End Class
