<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="PazienteCreaAnonimizzazione.aspx.vb" Inherits=".PazienteCreaAnonimizzazione" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
        Visible="False"></asp:Label>
    <table id="MainTable" runat="server" cellpadding="1" cellspacing="0" border="0" style="width: 70%;">
        <tr>
            <td>
                <asp:Label ID="lblTitolo" runat="server" Text="Anonimizzazione paziente" CssClass="Title"></asp:Label>
            </td>
        </tr>
        <tr>
            <td class="detail">
                <table id="pannello" runat="server" style="padding: 13px;" width="100%">
                    <tr>
                        <td>
                            <asp:FormView ID="PazienteDettaglioFormView" runat="server" DataKeyNames="Id" DataSourceID="PazienteDettaglioObjectDataSource"
                                EmptyDataText="Dettaglio non disponibile!" EnableModelValidation="True" Width="100%">
                                <ItemTemplate>
                                    <table cellpadding="0" cellspacing="0" border="0" style="width: 100%;">
                                        <tr>
                                            <td style="vertical-align: top;">
                                                <table cellpadding="5" cellspacing="1" border="0">
                                                    <tr>
                                                        <td>
                                                            Cognome
                                                        </td>
                                                        <td>
                                                            <asp:Label ID="lblCognome" runat="server" Text='<%# Bind("Cognome") %>' CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            Nome
                                                        </td>
                                                        <td>
                                                            <asp:Label ID="lblNome" runat="server" Text='<%# Bind("Nome") %>' CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            Codice fiscale
                                                        </td>
                                                        <td>
                                                            <asp:Label ID="lblCodiceFiscale" runat="server" Text='<%# Bind("CodiceFiscale") %>'
                                                                CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            Sesso
                                                        </td>
                                                        <td>
                                                            <asp:Label ID="Label1" runat="server" Text='<%# Bind("Sesso") %>'
                                                                CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            Data nascita
                                                        </td>
                                                        <td>
                                                            <asp:Label ID="lblDataNascita" runat="server" Text='<%# Bind("DataNascita", "{0:d}") %>'
                                                                CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            Comune nascita
                                                        </td>
                                                        <td>
                                                            <asp:Label ID="lblComuneNascita" runat="server" Text='<%# Bind("ComuneNascitaDescrizione") %>'
                                                                CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            Provincia nascita
                                                        </td>
                                                        <td>
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
                <table cellpadding="1" cellspacing="0" border="0" width="100%">
                    <tr>
                        <td valign="top">
                            Motivo anonimizzazione
                            <asp:RequiredFieldValidator ID="txtNoteRequiredFieldValidator" runat="server" ControlToValidate="txtNote"
                                ErrorMessage='Richiesto!'></asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:TextBox ID="txtNote" runat="server" MaxLength="2048" Rows="7" Width="100%" TextMode="MultiLine"></asp:TextBox>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td style="text-align: right;">
                <br />
                <asp:Button ID="btnConferma" runat="server" CssClass="TabButton" Text="Conferma"
                    Causevalidation="True" />&nbsp;
                <asp:Button ID="btnAnnulla" runat="server" CssClass="TabButton" Text="Annulla" CausesValidation="False" />
            </td>
        </tr>
    </table>
    <asp:ObjectDataSource ID="PazienteDettaglioObjectDataSource" runat="server" SelectMethod="GetData"
        TypeName="DI.Sac.Admin.Data.PazientiAnonimizzazioniDataSetTableAdapters.PazientiAnonimizzazioniPazienteSelectTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter Name="Id" QueryStringField="id" DbType="Guid" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
