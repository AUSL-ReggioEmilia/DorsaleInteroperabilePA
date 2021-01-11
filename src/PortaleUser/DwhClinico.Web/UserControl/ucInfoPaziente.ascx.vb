Public Class ucInfoPaziente
    Inherits System.Web.UI.UserControl

    ''' <summary>
    ''' LE PROPERTY VENGONO VALORIZZATE DALLA PAGINA IN CUI LO USER CONTROL VIENE IMPLEMENTATO
    ''' Questo user control si occupa solo di renderizzare i dati che gli vengono passati
    ''' </summary>
#Region "Property"
    Public WriteOnly Property Nome() As String
        Set(ByVal value As String)
            lblNome.Text = value
        End Set
    End Property

    Public WriteOnly Property Cognome() As String
        Set(ByVal value As String)
            lblCognome.Text = value
        End Set
    End Property

    Public WriteOnly Property CodiceFiscale() As String
        Set(ByVal value As String)
            lblCodiceFiscale.Text = value
        End Set
    End Property

    Public WriteOnly Property LuogoNascita() As String
        Set(ByVal value As String)
            lblLuogoNascita.Text = value
        End Set
    End Property

    Public WriteOnly Property DataNascita() As Date?
        Set(ByVal dataNascita As Date?)
            lblDataNascita.Text = String.Empty
            If dataNascita.HasValue Then
                lblDataNascita.Text = String.Format("{0:d}", dataNascita.Value)
            End If
        End Set
    End Property
#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
    End Sub

End Class