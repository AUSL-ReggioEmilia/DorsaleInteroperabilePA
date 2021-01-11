Imports DwhClinico.Data
Imports DwhClinico.Web.Utility
Imports System.Xml
Imports System.Net

Namespace DwhClinico.Web

    Partial Class ApreReferto
        Inherits System.Web.UI.Page

#Region " Web Form Designer Generated Code "

        'This call is required by the Web Form Designer.
        <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        End Sub


        Private Sub Page_Init(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Init
            'CODEGEN: This method call is required by the Web Form Designer
            'Do not modify it using the code editor.
            InitializeComponent()
        End Sub

#End Region

        Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
            Try
                Dim guidIdReferto As Guid
                Try
                    '
                    ' Leggo parametri dal QueryString
                    '
                    guidIdReferto = New Guid(Request.QueryString(PAR_ID_REFERTO))
                Catch ex As Exception
                    '
                    ' Gestione dell'errore
                    '
                    lblErrorMessage.Text = "Errore nel parametro IdReferto!"
                    Logging.GetMessageError(ex, "ApreReferto.Page_Load")
                    Exit Sub
                End Try
                '
                ' Determino l'URL del dettaglio del referto
                '
                Dim strUrl As String = Utility.GetUrlDettaglioReferto(guidIdReferto)
                strUrl = String.Format("{0}&Tipo=BOOTSTRAP", strUrl)

                '
                ' Navigo al dettaglio del referto
                '
                Response.Redirect(strUrl)

            Catch ex As Threading.ThreadAbortException
                '
                ' Non faccio niente
                '
            Catch ex As Exception
                '
                ' Gestione dell'errore
                '
                lblErrorMessage.Text = "Errore contattare l'amministratore!"
                Logging.GetMessageError(ex, "ApreReferto.Page_Load")

            End Try

        End Sub
    End Class

End Namespace
