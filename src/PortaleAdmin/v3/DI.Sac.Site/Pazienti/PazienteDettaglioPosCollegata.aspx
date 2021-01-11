<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PazienteDettaglioPosCollegata.aspx.vb" Inherits=".PazienteDettaglioPosCollegata" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
        Visible="False"></asp:Label>
    <table id="MainTable" runat="server" cellpadding="1" cellspacing="0" border="0" style="width: 70%;">
        <tr>
            <td>
                <asp:Label ID="lblTitolo" runat="server" Text="Dettaglio Posizione collegata" CssClass="Title"></asp:Label>
            </td>
        </tr>
        <tr>
            <td class="detail">
                <table id="pannello" runat="server" style="padding: 13px;" width="100%">
                    <tr>
                        <td>
                            <asp:FormView ID="PazienteDettaglioFormView" runat="server" DataKeyNames="Id" DataSourceID="DettaglioPazienteObjectDataSource"
                                EmptyDataText="Dettaglio paziente non disponibile!" EnableModelValidation="True"
                                Width="100%">
                                <ItemTemplate>
                                    <table cellpadding="0" cellspacing="0" border="0" style="width: 100%;">
                                        <tr>
                                            <td style="vertical-align: top;">
                                                <table cellpadding="5" cellspacing="0" border="0">
                                                    <tr>
                                                        <td valign="top" width="100px">
                                                            Cognome
                                                        </td>
                                                        <td valign="top">
                                                            <asp:Label ID="lblCognome" runat="server" Text='<%# Bind("Cognome") %>' CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td valign="top">
                                                            Nome
                                                        </td>
                                                        <td valign="top">
                                                            <asp:Label ID="lblNome" runat="server" Text='<%# Bind("Nome") %>' CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td valign="top">
                                                            Codice fiscale
                                                        </td>
                                                        <td valign="top">
                                                            <asp:Label ID="lblCodiceFiscale" runat="server" Text='<%# Bind("CodiceFiscale") %>'
                                                                CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td valign="top">
                                                            Sesso
                                                        </td>
                                                        <td valign="top">
                                                            <asp:Label ID="lblSesso" runat="server" Text='<%# Bind("Sesso") %>'
                                                                CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td valign="top">
                                                            Data nascita
                                                        </td>
                                                        <td valign="top">
                                                            <asp:Label ID="lblDataNascita" runat="server" Text='<%# Bind("DataNascita", "{0:d}") %>'
                                                                CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td valign="top">
                                                            Comune nascita
                                                        </td>
                                                        <td valign="top">
                                                            <asp:Label ID="lblComuneNascita" runat="server" Text='<%# Bind("ComuneNascitaDescrizione") %>'
                                                                CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td valign="top">
                                                            Provincia nascita
                                                        </td>
                                                        <td valign="top">
                                                            <asp:Label ID="lblProvinciaNascita" runat="server" Text='<%# Bind("ProvinciaNascitaDescrizione") %>'
                                                                CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </ItemTemplate>
                            </asp:FormView>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;
            </td>
        </tr>
        <tr>
            <td>
                <fieldset>
                    <table id="pannello2" runat="server" style="padding: 13px;" width="100%">
                        <tr>
                            <td>
                                <asp:FormView ID="FormView" runat="server" DataKeyNames="IdPosizioneCollegata"
                                    DataSourceID="DettaglioPosizioneCollegataObjectDataSource" EmptyDataText="Dettaglio posizione collegata non disponibile!"
                                    EnableModelValidation="True" Width="100%">
                                    <ItemTemplate>
                                        <table cellpadding="0" cellspacing="0" border="0" style="width: 100%;">
                                            <tr>
                                                <td style="vertical-align: top;">
                                                    <table cellpadding="5" cellspacing="1" border="0">
                                                        <tr>
                                                            <td valign="top" width="100px">
                                                                Codice<br />
                                                                posizione collegata
                                                            </td>
                                                            <td valign="top">
                                                                <asp:Label Style="font-size: large;" ID="lblIdPosizioneCollegata" runat="server" Text='<%# Bind("IdPosizioneCollegata") %>'
                                                                    CssClass="LabelReadOnly" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td valign="top">
                                                                Motivo
                                                            </td>
                                                            <td valign="top">
                                                                <asp:Label ID="lblNote" runat="server" Text='<%# Bind("Note") %>' CssClass="LabelReadOnly" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2" valign="top">
                                                                <asp:HyperLink ID="hlGoToPosOriginale" runat="server" NavigateUrl='<%# string.format("~/Pazienti/PazienteDettaglio.aspx?Id={0}", Eval("IdSacOriginale")) %>'>Vai a posizione originale</asp:HyperLink>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2" valign="top">
                                                                <asp:HyperLink ID="hlGoToPosCollegata" runat="server" NavigateUrl='<%#String.Format("~/Pazienti/PazienteDettaglio.aspx?Id={0}", Eval("IdSacPosizioneCollegata")) %>'>Vai a posizione collegata</asp:HyperLink>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </ItemTemplate>
                                </asp:FormView>
                            </td>
                        </tr>
                    </table>
                    <table id="pannello3" runat="server" style="padding: 13px;" width="100%">
                        <tr>
                            <td style="vertical-align: top;">
                                <table cellpadding="5" cellspacing="1" border="0">
                                    <tr>
                                        <td valign="top">
                                            <asp:HyperLink ID="hlShowModuleToPrint" runat="server" NavigateUrl="" >Stampa documento</asp:HyperLink>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </fieldset>
            </td>
        </tr>
    </table>
    <asp:ObjectDataSource ID="DettaglioPazienteObjectDataSource" runat="server" SelectMethod="GetData"
        TypeName="DI.Sac.Admin.Data.PazientiPosizioniCollegateDataSetTableAdapters.PazientiPosizioniCollegatePazienteSelectTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter Name="Id" QueryStringField="id" DbType="Guid" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="DettaglioPosizioneCollegataObjectDataSource" runat="server"
        SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.PazientiPosizioniCollegateDataSetTableAdapters.PazientiPosizioniCollegateSelectByIdSacPosizioneCollegataTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter Name="IdSacPosizioneCollegata" QueryStringField="IdSacPosizioneCollegata" DbType="String" />
        </SelectParameters>
    </asp:ObjectDataSource>

</asp:Content>
