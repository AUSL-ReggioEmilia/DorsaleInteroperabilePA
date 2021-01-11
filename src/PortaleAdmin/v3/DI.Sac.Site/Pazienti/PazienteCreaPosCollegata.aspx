<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="PazienteCreaPosCollegata.aspx.vb" Inherits=".PazienteCreaPosCollegata" EnableEventValidation="false" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
        Visible="False"></asp:Label>
    <table id="MainTable" runat="server" cellpadding="1" cellspacing="0" border="0" style="width: 70%;">
        <tr>
            <td>
                <asp:Label ID="lblTitolo" runat="server" Text="Creazione posizione collegata del paziente" CssClass="Title"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>
                <table id="pannello" runat="server" style="padding: 13px;" width="100%">
                    <tr>
                        <td>
                            <asp:FormView ID="PazienteDettaglioFormView" runat="server" DataKeyNames="Id" DataSourceID="PazienteDettaglioObjectDataSource"
                                EmptyDataText="Dettaglio non disponibile!" EnableModelValidation="True" Width="100%">
                                <ItemTemplate>

                                    <table cellpadding="0" cellspacing="0" border="0" style="width: 100%;">
                                        <tr>
                                            <td style="vertical-align: top;" class="detail">
                                                <table cellpadding="5" cellspacing="1" border="0">
                                                    <tr>
                                                        <td>Cognome
                                                        </td>
                                                        <td>
                                                            <asp:Label ID="lblCognome" runat="server" Text='<%# Bind("Cognome") %>' CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Nome
                                                        </td>
                                                        <td>
                                                            <asp:Label ID="lblNome" runat="server" Text='<%# Bind("Nome") %>' CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Codice fiscale
                                                        </td>
                                                        <td>
                                                            <asp:Label ID="lblCodiceFiscale" runat="server" Text='<%# Bind("CodiceFiscale") %>'
                                                                CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Sesso
                                                        </td>
                                                        <td>
                                                            <asp:Label ID="Label1" runat="server" Text='<%# Bind("Sesso") %>'
                                                                CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Data nascita
                                                        </td>
                                                        <td>
                                                            <asp:Label ID="lblDataNascita" runat="server" Text='<%# Bind("DataNascita", "{0:d}") %>'
                                                                CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Comune nascita
                                                        </td>
                                                        <td>
                                                            <asp:Label ID="lblComuneNascita" runat="server" Text='<%# Bind("ComuneNascitaDescrizione") %>'
                                                                CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Provincia nascita
                                                        </td>
                                                        <td>
                                                            <asp:Label ID="lblProvinciaNascita" runat="server" Text='<%# Bind("ProvinciaNascitaDescrizione") %>'
                                                                CssClass="LabelReadOnly" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblTitolo2" runat="server" Text="Dati posizione collegata" CssClass="Title"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <table cellpadding="5" cellspacing="1" border="0">
                                                    <tr>
                                                        <td>Sesso posizione
                                                        </td>
                                                        <td>
                                                            <asp:DropDownList ID="ddlSessoPosCollegata" runat="server"
                                                                OnDataBinding="ddlSessoPosCollegata_DataBinding">
                                                                <asp:ListItem Selected="True"></asp:ListItem>
                                                                <asp:ListItem>M</asp:ListItem>
                                                                <asp:ListItem>F</asp:ListItem>
                                                            </asp:DropDownList>
                                                            <asp:RequiredFieldValidator ID="ddlSessoPosCollegataRequiredFieldValidator" runat="server" ControlToValidate="ddlSessoPosCollegata"
                                                                ErrorMessage='Campo obbligatorio!' class="Error" Display="Dynamic"></asp:RequiredFieldValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Data nascita
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="txtDataNascitaPosCollegata" runat="server" MaxLength="10"></asp:TextBox>
                                                            <asp:RequiredFieldValidator ID="txtDataNascitaPosCollegataRequiredFieldValidator" runat="server" ControlToValidate="txtDataNascitaPosCollegata"
                                                                ErrorMessage='Campo obbligatorio!' class="Error" Display="Dynamic"></asp:RequiredFieldValidator>
                                                            <asp:CompareValidator ID="cvalDataNascitaPosCollegata" runat="server" ControlToValidate="txtDataNascitaPosCollegata"
                                                                ErrorMessage='Campo obbligatorio!' class="Error" Display="Dynamic"
                                                                Operator="DataTypeCheck" Type="Date"></asp:CompareValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style="vertical-align: top">Comune nascita
                                                        </td>
                                                        <td>
                                                            <progel:CustomDropDownList ID="pddlComuneNascitaPosCollegata" runat="server" ServicePath="~/WebServices/Istat.asmx"
                                                                ParentCategory="Province" ParentServiceMethod="GetProvinceIstat" ParentPromptText="- seleziona la provincia -"
                                                                ParentLoadingText="caricamento province..." ParentBindValue="035"
                                                                ChildCategory="Comuni" ChildServiceMethod="GetComuniIstat" ChildPromptText="- seleziona il comune -"
                                                                ChildLoadingText="caricamento comuni..." />
                                                            <%--ParentBindValue="035" --> 035 è il codice di Reggio nell'Emilia, richiesto come default--%>
                                                            
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
            <td>&nbsp;
            </td>
        </tr>
        <tr>
            <td>
                <table cellpadding="1" cellspacing="0" border="0" width="100%">
                    <tr>
                        <td valign="top">Motivo
                            <asp:RequiredFieldValidator ID="txtNoteRequiredFieldValidator" runat="server" ControlToValidate="txtNote"
                                ErrorMessage='Campo obbligatorio!' class="Error" Display="Dynamic"></asp:RequiredFieldValidator>
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
        TypeName="DI.Sac.Admin.Data.PazientiPosizioniCollegateDataSetTableAdapters.PazientiPosizioniCollegatePazienteSelectTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter Name="Id" QueryStringField="id" DbType="Guid" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <ajax:ToolkitScriptManager ID="MainScriptManager" runat="server">
    </ajax:ToolkitScriptManager>

</asp:Content>
