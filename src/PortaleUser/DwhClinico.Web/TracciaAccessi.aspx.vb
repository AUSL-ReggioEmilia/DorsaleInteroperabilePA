#Region "Descrizione"
'
' Questa pagina non ha nessun layouyt e si occupa esclusivamente di tenere
' traccia nel DB degli accessi a determinati Link
'
#End Region

Imports DwhClinico.Data
Imports DwhClinico.Web.Utility

Namespace DwhClinico.Web

    Partial Class TracciaAccessi
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
        '
        ' Variabili private della classe
        '
        Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
            Dim oIdReferti As Guid = Guid.Empty
            '
            ' Leggo il QueryString
            '
            Dim strIdPaziente As String = Request.QueryString(PAR_ID_PAZIENTE) & ""
            Dim strCodeUrl As String = Request.QueryString(PAR_CODE_URL) & ""
            Dim strNavBar As String = Request.QueryString(PAR_NAVBAR) & ""
            Dim strUrl As String = Request.QueryString(PAR_URL) & ""
            Try
                Dim strOperazione As String
                '
                ' Apro referto o drill-down dentro le prestazioni del referto  
                '
                strOperazione = strUrl
                '
                ' Accodo i parametri
                '
                Dim strKey As String
                Dim strQuery As String = ""
                Dim loop1, loop2 As Integer
                Dim arr1(), arr2() As String
                Dim coll As Collections.Specialized.NameValueCollection

                coll = Request.QueryString
                arr1 = coll.AllKeys

                For loop1 = 0 To arr1.GetUpperBound(0)
                    '
                    ' Legge la key
                    '
                    strKey = arr1(loop1)
                    If strKey.ToUpper <> PAR_URL.ToUpper And strKey.ToUpper <> PAR_NAVBAR.ToUpper Then
                        '
                        ' Legge i valori
                        '
                        arr2 = coll.GetValues(loop1)
                        For loop2 = 0 To arr2.GetUpperBound(0)
                            strQuery &= strKey & "=" & arr2(loop2) & "&"
                        Next loop2
                    End If
                Next loop1
                If strQuery.Length > 0 Then
                    strUrl &= "?" & strQuery.TrimEnd("&"c)
                End If
                '
                ' Apro url nella pagina di Dettaglio referto
                '
                Dim sIdReferto As String = Request.QueryString(PAR_ID_REFERTO) & ""
                '
                ' Controllo se in modatità Accesso Diretto
                '
                Dim bAccessoDiretto As Boolean = False
                If Not Me.Session(SESS_ACCESSO_DIRETTO) Is Nothing Then
                    bAccessoDiretto = CType(Me.Session(SESS_ACCESSO_DIRETTO), Boolean)
                End If
                If bAccessoDiretto = True Then
                    '
                    ' Il parametro EntryPoint viene utilizzato nella pagina Referto.aspx
                    ' dell 'AccessoDiretto nel caso in cui il dettaglio referto (costruito tramite Visualizzazioni) presenti dei link 
                    '
                    strUrl = String.Format("~/AccessoDiretto/Referto.aspx?{0}={1}&{2}={3}&{4}={5}",
                                            PAR_URL,
                                            Me.Server.UrlEncode(strUrl),
                                            PAR_ID_REFERTO,
                                            sIdReferto,
                                            PAR_ENTRY_POINT,
                                            "0")

                Else
                    strUrl = String.Format("~/Referti/RefertiDettaglio.aspx?{0}={1}&{2}={3}",
                                            PAR_URL,
                                            Me.Server.UrlEncode(strUrl),
                                            PAR_ID_REFERTO,
                                            sIdReferto)
                End If

                strUrl = Me.ResolveUrl(strUrl)
                '
                ' IRefertio per traccia accessi
                '
                If sIdReferto.Length > 0 Then
                    oIdReferti = New Guid(sIdReferto)
                End If
                '
                ' Traccia accessi
                ' Lo traccio dentro RefertiDettaglio.aspx
                '

            Catch ex As Exception
                '
                ' Errore
                '
                lblErrorMessage.Text = ex.Message
                lblErrorMessage.Visible = True
                Exit Sub

            End Try

            If Not IsNothing(strUrl) AndAlso strUrl.Length > 0 Then
                '
                ' Redireziono all'URL passato
                '
                Response.Redirect(strUrl)
            Else
                '
                ' Url non trovato
                '
                lblErrorMessage.Text = "Url non trovato!"
                lblErrorMessage.Visible = True
                Exit Sub
            End If

        End Sub

    End Class

End Namespace
