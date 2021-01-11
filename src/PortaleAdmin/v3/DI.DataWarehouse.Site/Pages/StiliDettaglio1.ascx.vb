Imports System
Imports DI.DataWarehouse.Admin.Data
Imports System.Web.UI.WebControls
Imports System.Diagnostics
Imports System.Web.UI
Imports System.ComponentModel
Imports System.Globalization

Namespace DI.DataWarehouse.Admin

    Partial Class StiliDettaglio1
        Inherits UserControl



#Region " Web Form Designer Generated Code "

        <DebuggerStepThrough()>
        Private Sub InitializeComponent()

            _stiliDettaglioDataSet = New RefertiStiliDataSet()
            _stiliDettaglioDataSet.BeginInit()

            _stiliDettaglioDataSet.DataSetName = "StiliDettaglioDataset"
            _stiliDettaglioDataSet.Locale = New CultureInfo("it-IT")
            _stiliDettaglioDataSet.EndInit()
        End Sub

        Protected WithEvents _stiliDettaglioDataSet As RefertiStiliDataSet
        Protected WithEvents RequiredFieldValidator1 As RequiredFieldValidator
        Protected WithEvents RequiredFieldValidator2 As RequiredFieldValidator
        Protected WithEvents Requiredfieldvalidator3 As RequiredFieldValidator
        Protected WithEvents RangeValidator1 As RangeValidator


        Private Sub Page_Init(ByVal sender As Object, ByVal e As EventArgs) Handles MyBase.Init

            InitializeComponent()
        End Sub

#End Region

        Public Property Dataset() As RefertiStiliDataSet
            Get
                Return _stiliDettaglioDataSet
            End Get
            Set(ByVal Value As RefertiStiliDataSet)
                _stiliDettaglioDataSet = Value
            End Set
        End Property

        Public Sub PageDataBind()
            '
            ' Eseguo (1 volta) il databind dello user control
            '
            Dim doDatabind As Boolean
            '
            ' Controllo nel ViewState se ho già eseguito il bind
            '
            Try
                doDatabind = CBool(ViewState(Constants.DoDataBind))
            Catch ex As Exception
            End Try

            If Not doDatabind Then

                Me.DataBind()
            End If
        End Sub

        Public Sub Commit()
            '
            'La selezione dell'item della combo è stato fatto qui perchè il metodo commit viene eseguito per primo.
            'Il selected item non poteva essere caricato direttamente dal markup come per gli altri campi.
            '
            If Not Page.IsPostBack Then
                Call LoadTipiCombo()
                '
                'Se il valore di Tipo nel dataset è vuoto allora seleziono il default (2 - Esterno)
                '
                Dim selectedTipo As Object = Utility.StringEmptyDBNullToNothing(DataBinder.Eval(_stiliDettaglioDataSet, "Tables[RefertiStili].DefaultView.[0].Tipo"))
                If Not selectedTipo Is Nothing Then
                    cmbTipo.SelectedValue = CType(selectedTipo, String)
                Else
                    cmbTipo.SelectedValue = Constants.COMBO_TIPO_ESTERNO_ITEM_VALUE.ToString
                End If
            End If

            Dim row As RefertiStiliDataSet.RefertiStiliRow = _stiliDettaglioDataSet.RefertiStili(0)
            row.Nome = NomeTextBox.Text
            row.Descrizione = DescrizioneTextBox.Text
            row.PaginaWeb = PaginaWebTextBox.Text
            row.Parametri = ParametriTextBox.Text
            row.Note = NoteTextBox.Text
            row.Abilitato = chkAbilitato.Checked
            row.Tipo = cmbTipo.SelectedValue
            row.XsltTestata = XsltTestataTextBox.Text
            row.XsltRighe = XsltRigheTextBox.Text

            'NUOVI CAMPI
            row.XsltAllegatoXml = XsltAllegatoXmlTextBox.Text
            row.NomeFileAllegatoXml = NomeFileAllegatoXmlTextBox.Text
            row.ShowAllegatoRTF = chkShowAllegatoRTF.Checked
            row.ShowLinkDocumentoPdf = chkShowLinkDocumentoPdf.Checked

        End Sub



        Private Sub LoadTipiCombo()
            '
            ' Carico la combo dei tipi di visualizzazioni cmbTipo
            '
            Dim oListItem As New ListItem(Constants.COMBO_TIPO_INTERNO_WS2_ITEM_TEXT, Constants.COMBO_TIPO_INTERNO_WS2_ITEM_VALUE.ToString)
            cmbTipo.Items.Add(oListItem)

            oListItem = New ListItem(Constants.COMBO_TIPO_ESTERNO_ITEM_TEXT, Constants.COMBO_TIPO_ESTERNO_ITEM_VALUE.ToString)
            cmbTipo.Items.Add(oListItem)

            oListItem = New ListItem(Constants.COMBO_TIPO_PDF_ITEM_TEXT, Constants.COMBO_TIPO_PDF_ITEM_VALUE.ToString)
            cmbTipo.Items.Add(oListItem)

            oListItem = New ListItem(Constants.COMBO_TIPO_INTERNO_WS3_ITEM_TEXT, Constants.COMBO_TIPO_INTERNO_WS3_ITEM_VALUE.ToString)
            cmbTipo.Items.Add(oListItem)
        End Sub

    End Class

End Namespace
