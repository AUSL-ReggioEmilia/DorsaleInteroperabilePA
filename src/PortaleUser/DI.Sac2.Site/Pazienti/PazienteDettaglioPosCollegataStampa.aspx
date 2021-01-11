<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="PazienteDettaglioPosCollegataStampa.aspx.vb" Inherits=".PazienteDettaglioPosCollegataStampa" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Stampa modulo posizione collegata</title>
    <!--  USO UNO STILE LOCALE PER LA PAGINA DI STAMPA -->
    <style type="text/css">
        body
        {
            font-size: 9pt;
            margin: 0px;
            color: Black;
            background-color: white;
            font-family: Verdana, Arial, Helvetica;
            border: 0px;
        }
        table
        {
            font-size: 9pt;
            font-family: Verdana, Arial, Helvetica;
        }
        
        .DetailPanel
        {
            border-width: 1px;
            border-style: solid;
            border-color: Black;
            margin-top: 10px;
            display: block;
            text-align: left;
            padding: 8px;
        }
        
        .Title
        {
            display: block;
            padding-top: 3px;
            padding-bottom: 3px;
            color: black;
            font-weight: bold;
            font-size: 10pt;
        }
        
        .ModuloStampaAvviso
        {
            display: block;
            padding-bottom: 10px;
        }
        
        .TabButton
        {
	        width: 100px;
        }
        
        .Error
        {
	        color: red;
	        font-weight: bold;
	        font-size: 11px;
	        font-family: Verdana, Arial, Helvetica;
        }

    </style>
    <style type="text/css" media="print">
        .HideOnPrint
        {
            display: none;
        }
    </style>
    <script type="text/javascript">
        function Stampa() {
            // Effettuo la stampa
            window.print();
            // Chiudo la finestra
            window.close();
            return false;
        };
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
        Visible="False"></asp:Label>
    <div align="center" style="width: 100%;">
        <div id="MainDiv" runat="server" style="width: 16.5cm;">
            <div>
                <asp:Image ID="imgToolbar1" runat="server" ImageUrl="/Images/LogoAzienda.jpg" width="404" Height="74"/>
            </div>
            <div class="DetailPanel">
                <asp:Label ID="lblProceduraTop" runat="server" Text="PROCEDURA DI CREAZIONE POSIZIONE COLLEGATA - ..."
                    CssClass="Title"></asp:Label>
                <asp:Label ID="lblTitolo" runat="server" Text="DATI DELLA POSIZIONE ANAGRAFICA ORIGINALE:"
                    CssClass="Title"></asp:Label>
                <asp:FormView ID="PazienteDettaglioFormView" runat="server" DataKeyNames="Id" DataSourceID="DettaglioPazienteObjectDataSource"
                    EmptyDataText="Dettaglio paziente non disponibile!" EnableModelValidation="True"
                    Width="100%">
                    <ItemTemplate>
                        <table cellpadding="0" cellspacing="0" border="0">
                            <tr>
                                <td valign="top" width="100px">
                                    Cognome:
                                </td>
                                <td valign="top">
                                    <asp:Label ID="lblCognome" runat="server" Text='<%# Bind("Cognome") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    Nome:
                                </td>
                                <td valign="top">
                                    <asp:Label ID="lblNome" runat="server" Text='<%# Bind("Nome") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    Sesso:
                                </td>
                                <td valign="top">
                                    <asp:Label ID="lblSesso" runat="server" Text='<%# Bind("Sesso") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    Data nascita:
                                </td>
                                <td valign="top">
                                    <asp:Label ID="lblDataNascita" runat="server" Text='<%# Bind("DataNascita", "{0:d}") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    Luogo nascita:
                                </td>
                                <td valign="top">
                                    <asp:Label ID="lblComuneNascita" runat="server" Text='<%# Bind("ComuneNascitaDescrizione") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    Codice fiscale:
                                </td>
                                <td valign="top">
                                    <asp:Label ID="lblCodiceFiscale" runat="server" Text='<%# Bind("CodiceFiscale") %>' />
                                </td>
                            </tr>
                        </table>
                    </ItemTemplate>
                </asp:FormView>
            </div>
            <div style="display: block;padding-bottom: 100px;">
            </div>
            <div>
                <asp:Image ID="imgToolbar2" runat="server" ImageUrl="/Images/LogoAzienda.jpg" width="400" Height="74"/>
            </div>
            <div class="DetailPanel">
               <asp:Label ID="lblTitolo2" runat="server" Text="DATI DELLA POSIZIONE ANAGRAFICA COLLEGATA:"
                    CssClass="Title"></asp:Label>
                <asp:FormView ID="PosizioneCollegataDettaglioFormView" runat="server" DataKeyNames="IdPosizioneCollegata"
                    DataSourceID="DettaglioPosizioneCollegataObjectDataSource" EmptyDataText="Dettaglio della posizione collegata non disponibile!"
                    EnableModelValidation="True" Width="100%">
                    <ItemTemplate>
                        <table cellpadding="0" cellspacing="0" border="0">
                            <tr>
                                <td valign="top" width="100px">
                                    Cognome:
                                </td>
                                <td valign="top">
                                    <asp:Label ID="lblCognome" runat="server" Text='<%# Bind("PosizioneCollegataCognome") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    Nome:
                                </td>
                                <td valign="top">
                                    <asp:Label ID="lblNome" runat="server" Text='<%# Bind("PosizioneCollegataNome") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    Sesso:
                                </td>
                                <td valign="top">
                                    <asp:Label ID="lblSesso" runat="server" Text='<%# Bind("PosizioneCollegataSesso") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    Data nascita:
                                </td>
                                <td valign="top">
                                    <asp:Label ID="lblDataNascita" runat="server" Text='<%# Bind("PosizioneCollegataDataNascita", "{0:d}") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    Luogo nascita:
                                </td>
                                <td valign="top">
                                    <asp:Label ID="lblComuneNascita" runat="server" Text='<%# Bind("PosizioneCollegataComuneNascitaDescrizione") %>' />
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    Codice fiscale:
                                </td>
                                <td valign="top">
                                    <asp:Label ID="lblCodiceFiscale" runat="server" Text='<%# Bind("PosizioneCollegataCodiceFiscale") %>' />
                                </td>
                            </tr>
                        </table>
                    </ItemTemplate>
                </asp:FormView>
                <asp:Label ID="lblProceduraBottom" runat="server" Text="PROCEDURA DI CREAZIONE POSIZIONE COLLEGATA - ..."
                    CssClass="Title" ></asp:Label>
            </div>
            <div align="center" style="width: 100%; display: block; padding-top: 50px;">
                <asp:Button ID="IdStampa" runat="server" Text="Stampa" OnClientClick="Stampa();"
                    CssClass="TabButton HideOnPrint" />
            </div>
            <div style="display: block;padding-bottom: 15px;">
        </div>
        <asp:ObjectDataSource ID="DettaglioPazienteObjectDataSource" runat="server" SelectMethod="GetData"
            TypeName="PazientiPosizioniCollegateDataSetTableAdapters.PazientiPosizioniCollegatePazienteSelectTableAdapter">
            <SelectParameters>
                <asp:QueryStringParameter Name="Id" QueryStringField="id" DbType="Guid" />
            </SelectParameters>
        </asp:ObjectDataSource>
        <asp:ObjectDataSource ID="DettaglioPosizioneCollegataObjectDataSource" runat="server"
            SelectMethod="GetData" TypeName="PazientiPosizioniCollegateDataSetTableAdapters.PazientiPosizioniCollegateSelectByIdSacPosizioneCollegataTableAdapter">
            <SelectParameters>
                <asp:QueryStringParameter Name="IdSacPosizioneCollegata" QueryStringField="IdSacPosizioneCollegata"
                    DbType="String" />
            </SelectParameters>
        </asp:ObjectDataSource>
    </div>
    </form>
</body>
</html>
