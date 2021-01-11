<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="PazienteDettaglioAnonimizzazioniStampa.aspx.vb"
    Inherits=".PazienteDettaglioAnonimizzazioniStampa" %>
<!DOCTYPE html>
<!--<html xmlns="http://www.w3.org/1999/xhtml">-->
<html>
<head id="Head1" runat="server">
   <meta http-equiv="X-UA-Compatible" content="IE=edge">
   <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Stampa modulo anonimizzazione</title>
    <!--  USO UNO STILE LOCALE PER LA PAGINA DI STAMPA -->
    <style type="text/css">
        body {
            font-size: 9pt;
            margin: 0px;
            color: Black;
            background-color: white;
            font-family: Verdana, Arial, Helvetica;
            border: 0px;
        }

        table {
            font-size: 9pt;
            font-family: Verdana, Arial, Helvetica;
        }

        /* per la grid delle esenzioni*/
        .GridRowStyle td {
            border: 1px solid lightgray;
        }

        .GridHeaderStyle th {
            border: 1px solid lightgray;
        }

        .DetailPanel {
            border-width: 1px;
            border-style: solid;
            border-color: Black;
            margin-top: 10px;
            display: block;
            text-align: left;
            padding: 8px;
        }

        .Title {
            display: block;
            padding-top: 3px;
            padding-bottom: 3px;
            color: black;
            font-weight: bold;
            font-size: 10pt;
        }

        .Title2 {
            display: block;
            padding-top: 3px;
            padding-bottom: 3px;
            color: black;
            font-weight: bold;
            font-size: 7pt;
        }


        .ModuloStampaAvviso {
            display: block;
            padding-bottom: 10px;
        }

        .TabButton {
            width: 100px;
        }

        .Error {
            color: red;
            font-weight: bold;
            font-size: 11px;
            font-family: Verdana, Arial, Helvetica;
        }
    </style>
    <style type="text/css" media="print">
        .HideOnPrint {
            display: none;
        }
    </style>

    <script src="../Scripts/jquery-1.11.2.min.js"></script>

    <script type="text/javascript">
        function Stampa() {
            //var altezzaform = $("#<%= form1.ClientID %>").height(); //in pixel

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
                    <asp:Image ID="imgToolbar1" runat="server" ImageUrl="/Images/LogoAzienda.jpg" Width="404" Height="74" />
                </div>
                <div class="DetailPanel">
                    <asp:Label ID="lblProceduraTop" runat="server" Text="PROCEDURA DI ANONIMIZZAZIONE - ..."
                        CssClass="Title"></asp:Label>
                    <asp:Label ID="lblTitolo" runat="server" Text="DATI DELLA POSIZIONE ANAGRAFICA ORIGINALE:"
                        CssClass="Title"></asp:Label>
                    <asp:FormView ID="PazienteDettaglioFormView" runat="server" DataKeyNames="Id" DataSourceID="DettaglioPazienteObjectDataSource"
                        EmptyDataText="Dettaglio paziente non disponibile!" EnableModelValidation="True"
                        Width="100%">
                        <ItemTemplate>
                            <table cellpadding="0" cellspacing="0" border="0">
                                <tr>
                                    <td valign="top" width="100px">Cognome:
                                    </td>
                                    <td valign="top">
                                        <asp:Label ID="lblCognome" runat="server" Text='<%# Bind("Cognome") %>' />
                                    </td>
                                </tr>
                                <tr>
                                    <td valign="top">Nome:
                                    </td>
                                    <td valign="top">
                                        <asp:Label ID="lblNome" runat="server" Text='<%# Bind("Nome") %>' />
                                    </td>
                                </tr>
                                <tr>
                                    <td valign="top">Sesso:
                                    </td>
                                    <td valign="top">
                                        <asp:Label ID="lblSesso" runat="server" Text='<%# Bind("Sesso") %>' />
                                    </td>
                                </tr>
                                <tr>
                                    <td valign="top">Data nascita:
                                    </td>
                                    <td valign="top">
                                        <asp:Label ID="lblDataNascita" runat="server" Text='<%# Bind("DataNascita", "{0:d}") %>' />
                                    </td>
                                </tr>
                                <tr>
                                    <td valign="top">Luogo nascita:
                                    </td>
                                    <td valign="top">
                                        <asp:Label ID="lblComuneNascita" runat="server" Text='<%# Bind("ComuneNascitaDescrizione") %>' />
                                    </td>
                                </tr>
                                <tr>
                                    <td valign="top">Codice fiscale:
                                    </td>
                                    <td valign="top">
                                        <asp:Label ID="lblCodiceFiscale" runat="server" Text='<%# Bind("CodiceFiscale") %>' />
                                    </td>
                                </tr>
                            </table>
                        </ItemTemplate>
                    </asp:FormView>
                </div>
                
                <div style="display: block; padding-bottom: 10px;"></div>
                <!--hr style="border: 1px dashed #C0C0C0; align-content:center; width:100%;" > -->
                <div style="border-top: 2px dashed #C0C0C0; align-content:center; width:100%;"></div>
                <div style="display: block; padding-bottom: 10px;"></div>
                
                <div>
                    <asp:Image ID="imgToolbar2" runat="server" ImageUrl="/Images/LogoAzienda.jpg" Width="400" Height="74" />
                </div>
                <div class="DetailPanel">
                    <span runat="server" id="IdModuloStampaAvviso" class="ModuloStampaAvviso"></span>
                    <asp:FormView ID="AnonimizzazioneDettaglioFormView" runat="server" DataKeyNames="IdAnonimo"
                        DataSourceID="DettaglioAnonimizzazioneObjectDataSource" EmptyDataText="Dettaglio anonimizzazione non disponibile!"
                        EnableModelValidation="True" Width="100%">
                        <ItemTemplate>
                            <table cellpadding="0" cellspacing="0" border="0">
                                <tr>
                                    <td valign="top" width="100px">Cognome:
                                    </td>
                                    <td valign="top">
                                        <asp:Label ID="lblCognome" runat="server" Text='<%# Bind("AnonimoCognome") %>' />
                                    </td>
                                </tr>
                                <tr>
                                    <td valign="top">Nome:
                                    </td>
                                    <td valign="top">
                                        <asp:Label ID="lblNome" runat="server" Text='<%# Bind("AnonimoNome") %>' />
                                    </td>
                                </tr>
                                <tr>
                                    <td valign="top">Sesso:
                                    </td>
                                    <td valign="top">
                                        <asp:Label ID="lblSesso" runat="server" Text='<%# Bind("AnonimoSesso") %>' />
                                    </td>
                                </tr>
                                <tr>
                                    <td valign="top">Data nascita:
                                    </td>
                                    <td valign="top">
                                        <asp:Label ID="lblDataNascita" runat="server" Text='<%# Bind("AnonimoDataNascita", "{0:d}") %>' />
                                    </td>
                                </tr>
                                <tr>
                                    <td valign="top">Luogo nascita:
                                    </td>
                                    <td valign="top">
                                        <asp:Label ID="lblComuneNascita" runat="server" Text='<%# Bind("AnonimoComuneNascitaDescrizione") %>' />
                                    </td>
                                </tr>
                                <tr>
                                    <td valign="top">Codice fiscale:
                                    </td>
                                    <td valign="top">
                                        <asp:Label ID="lblCodiceFiscale" runat="server" Text='<%# Bind("AnonimoCodiceFiscale") %>' />
                                    </td>
                                </tr>
                            </table>
                        </ItemTemplate>
                    </asp:FormView>

                    <div style="display: block; padding-bottom: 10px;"></div>

                    <div id="divEsenzioni" runat="server" style="width: 100%;">
                        <asp:Label ID="lblTitoloEsenzioni" runat="server" Text="ESENZIONI ASSOCIATE AL PAZIENTE ANONIMIZZATO:" CssClass="Title"></asp:Label>
                        <!-- Lista delle esenzioni attive -->
                        <asp:GridView runat="server" ID="gvEsenzioni" DataSourceID="EsenzioniObjectDataSource" Visible="true" AutoGenerateColumns="False" Width="100%">
                            <HeaderStyle CssClass="GridHeaderStyle" />
                            <RowStyle CssClass="GridRowStyle" Wrap="true" />
                            <Columns>
                                <asp:TemplateField HeaderText="Testo esenzione">
                                    <ItemTemplate>
                                        <asp:Label Text='<%# GetTestoEsenzione(Container.DataItem) %>' runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="DataInizioValidita" HeaderText="Inizio Validità" DataFormatString="{0:d}"
                                    HtmlEncode="False" HeaderStyle-Width="10%" />
                                <asp:BoundField DataField="DataFineValidita" HeaderText="Fine Validità" DataFormatString="{0:d}"
                                    HtmlEncode="False" HeaderStyle-Width="10%" />
                            </Columns>
                        </asp:GridView>
                    </div>
                                <!--<asp:BoundField DataField="CodiceDiagnosi" HeaderText="Cod Diagnosi" HeaderStyle-Width="10%" />
                                <asp:BoundField DataField="DecodificaEsenzioneDiagnosi" HeaderText="Diagnosi" /> -->
                    <asp:Label ID="lblProceduraBottom" runat="server" Text="PROCEDURA DI ANONIMIZZAZIONE - ..."
                        CssClass="Title2"></asp:Label>
                </div>

                <!-- il pulsante di stampa -->
                <div align="center" style="width: 100%; display: block; padding-top: 50px;">
                    <asp:Button ID="IdStampa" runat="server" Text="Stampa" OnClientClick="Stampa();"
                        CssClass="TabButton HideOnPrint" />
                </div>
                <div style="display: block; padding-bottom: 15px;">
                </div>
            </div>
        </div>

        <asp:ObjectDataSource ID="DettaglioPazienteObjectDataSource" runat="server" SelectMethod="GetData"
            TypeName="PazientiAnonimizzazioniDataSetTableAdapters.PazientiAnonimizzazioniPazienteSelectTableAdapter">
            <SelectParameters>
                <asp:QueryStringParameter Name="Id" QueryStringField="id" DbType="Guid" />
            </SelectParameters>
        </asp:ObjectDataSource>
        <asp:ObjectDataSource ID="DettaglioAnonimizzazioneObjectDataSource" runat="server"
            SelectMethod="GetData" TypeName="PazientiAnonimizzazioniDataSetTableAdapters.PazientiAnonimizzazioniSelectByIdSacAnonimoTableAdapter">
            <SelectParameters>
                <asp:QueryStringParameter Name="IdSacAnonimo" QueryStringField="IdPazienteAnonimo"
                    DbType="String" />
            </SelectParameters>
        </asp:ObjectDataSource>

        <asp:ObjectDataSource ID="EsenzioniObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CustomDataSource.EsenzioniPaziente">
            <SelectParameters>
                <asp:Parameter Name="Token" Type="Object"></asp:Parameter>
                <asp:QueryStringParameter QueryStringField="Id" Name="Id" DbType="Guid"></asp:QueryStringParameter>
                <asp:Parameter Name="Attive" Type="Boolean" DefaultValue=""></asp:Parameter>
            </SelectParameters>
        </asp:ObjectDataSource>

    </form>
</body>
</html>
