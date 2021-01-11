Imports System
Imports System.Web

Namespace DI.DataWarehouse.Admin

    Public NotInheritable Class Constants

        Private Sub New()

        End Sub

        Public Const DataSet As String = "dataset"
        Public Const CurrentPageIndex As String = "CurrentPageIndex"
        Public Const SortField As String = "SortField"
        Public Const SortDirection As String = "SortDirection"
        Public Const IdPaziente As String = "IdPaziente"
        Public Const IdReferto As String = "IdReferto"
        Public Const IdEvento As String = "IdEvento"
        Public Const IdRicovero As String = "IdRicovero"
        Public Const IdAllegato As String = "IdAllegato"
        Public Const IdEsterno As String = "IdEsterno"
        Public Const Nome As String = "Nome"
        Public Const Cognome As String = "Cognome"
        Public Const CodiceSanitario As String = "CodiceSanitario"
        Public Const CodiceFiscale As String = "CodiceFiscale"
        Public Const DataNascita As String = "DataNascita"
        Public Const LuogoNascita As String = "LuogoNascita"
        Public Const RicercaSomiglianza As String = "RicercaSomiglianza"

        Public Const DallaData As String = "DallaData"
        Public Const SistemaErogante As String = "SistemaErogante"
        Public Const RepartoErogante As String = "RepartoErogante"
        Public Const RepartoRichiedente As String = "RepartoRichiedente"
        Public Const RepartoRicovero As String = "RepartoRicovero" 'ha il medesimo significato di REPARTORICHIEDENTE
        Public Const NomeAnagrafica As String = "NomeAnagrafica"
        Public Const IdAnagrafica As String = "IdAnagrafica"
        Public Const NumeroNosologico As String = "NumeroNosologico"
        Public Const NumeroPrenotazione As String = "NumeroPrenotazione"
        Public Const AziendaErogante As String = "AziendaErogante"

        Public Const Url As String = "Url"
        Public Const Id As String = "Id"
        Public Const DoDataBind As String = "dodatabind"
        Public Const UrlReturn As String = "urlreturn"
        Public Const UrlReferrer As String = "UrlReferrer"

        Public Const PageTitle As String = "PageTitle"
        Public Const IdDocument As String = "IdDoc"
        Public Const DocumentTableName As String = "DocTable"

        Public Const PageId As String = "pageid"

        Public Const SAC_IdPazienteNullo As String = "00000000-0000-0000-0000-000000000000"

        'NOTE ANAMNESTICHE
        Public Const PAR_ID_NOTA_ANAMNESTICA As String = "IdNotaAnamnestica"


        '
        ' I tipi di visualizzazioni di dettaglio
        '
        Public Const COMBO_TIPO_INTERNO_WS2_ITEM_VALUE As Integer = 1
        Public Const COMBO_TIPO_INTERNO_WS2_ITEM_TEXT As String = "Interno (WS2)"

        Public Const COMBO_TIPO_ESTERNO_ITEM_VALUE As Integer = 2
        Public Const COMBO_TIPO_ESTERNO_ITEM_TEXT As String = "Esterno"

        Public Const COMBO_TIPO_PDF_ITEM_VALUE As Integer = 3
        Public Const COMBO_TIPO_PDF_ITEM_TEXT As String = "Pdf"

        Public Const COMBO_TIPO_INTERNO_WS3_ITEM_VALUE As Integer = 4
        Public Const COMBO_TIPO_INTERNO_WS3_ITEM_TEXT As String = "Interno (WS3)"


        Public Shared Function JSBuildScript(ByVal clientCode As String) As String

            Dim script As String = Environment.NewLine & _
                    "<script language=""javascript"" type=""text/javascript"">" & Environment.NewLine & _
                    "<!--" & Environment.NewLine & _
                    "{0}" & Environment.NewLine & _
                    "// -->" & Environment.NewLine & _
                    "</script>"

            clientCode = clientCode.Trim().TrimStart("<!--".ToCharArray).TrimEnd("// -->".ToCharArray)

            Return String.Format(script, clientCode)
        End Function

        Public Shared Function JSOpenWindowFunction() As String

            Return "function OpenWindow(sURL, sWindowName, sOptions, bReplace, iWidth, iHeight)" & Environment.NewLine & _
                      "{" & Environment.NewLine & _
                      "var w = 640, h = 480;" & Environment.NewLine & _
                      "var newwindow;" & Environment.NewLine & _
                      "if (document.all || document.layers)" & Environment.NewLine & _
                          "{" & Environment.NewLine & _
                          "w = screen.availWidth;" & Environment.NewLine & _
                          "h = screen.availHeight;" & Environment.NewLine & _
                          "}" & Environment.NewLine & _
                      "var iLeft = (w-iWidth)/2;" & Environment.NewLine & _
                      "var iTop = (h-iHeight)/2;" & Environment.NewLine & _
                      "var Options = sOptions + ',left=' + iLeft + ',top=' + iTop + ',width=' + iWidth + ',height=' + iHeight;" & Environment.NewLine & _
                      "newwindow = window.open(sURL,sWindowName,Options, bReplace);" & Environment.NewLine & _
                      "newwindow.opener = self;" & Environment.NewLine & _
                      "newwindow.focus();" & Environment.NewLine & _
                      "}" & Environment.NewLine
        End Function

        Public Shared Function JSOpenWindowCode(ByVal sURL As String, _
                                                   ByVal sWindowName As String, _
                                                   ByVal bResizable As Boolean, _
                                                   ByVal bLocation As Boolean, ByVal bMenuBar As Boolean, _
                                                   ByVal bToolbar As Boolean, ByVal bScrolbars As Boolean, _
                                                   ByVal bStatus As Boolean, ByVal bTitlebar As Boolean, _
                                                   ByVal bReplace As Boolean, _
                                                   ByVal iHeight As Integer, ByVal iWidth As Integer) As String
            Dim iTop As Integer = 0
            Dim iLeft As Integer = 0
            Dim sOptions As String = String.Empty
            Dim sLocation As String = "no"
            Dim sMenuBar As String = "no"
            Dim sResizable As String = "no"
            Dim sToolbar As String = "no"
            Dim sScrolbars As String = "no"
            Dim sStatus As String = "no"
            Dim sTitleBar As String = "no"
            Dim sReplace As String = "false"

            If bResizable Then sResizable = "yes"
            If bToolbar Then sToolbar = "yes"
            If bScrolbars Then sScrolbars = "yes"
            If bStatus Then sStatus = "yes"
            If bTitlebar Then sTitleBar = "yes"
            If bReplace Then sReplace = "true"
            If bLocation Then sLocation = "yes"
            If bMenuBar Then sMenuBar = "yes"

            If String.IsNullOrEmpty(sWindowName) Then sWindowName = "_blank"

            sOptions &= "location=" & sLocation & ",menubar=" & sMenuBar
            sOptions &= ",resizable=" & sResizable & ",toolbar=" & sToolbar & ",scrollbars=" & sScrolbars
            sOptions &= ",status=" & sStatus & ",titlebar=" & sTitleBar

            Return "OpenWindow('" & sURL & "','" & sWindowName & "','" & sOptions & "'," & sReplace & "," & iWidth & "," & iHeight & ");"
        End Function

        Public Shared Function JSOpenWindowCode(ByVal url As String, ByVal bResizable As Boolean, _
                                                 ByVal bLocation As Boolean, ByVal bMenuBar As Boolean, _
                                                 ByVal bToolbar As Boolean, ByVal bScrolbars As Boolean, _
                                                 ByVal bStatus As Boolean, ByVal bTitlebar As Boolean, _
                                                 ByVal bReplace As Boolean, _
                                                 ByVal iHeight As Integer, ByVal iWidth As Integer) As String

            Return JSOpenWindowCode(url, "", bResizable, bLocation, bMenuBar, bToolbar, bScrolbars, bStatus, bTitlebar, bReplace, iHeight, iWidth)
        End Function
    End Class


End Namespace