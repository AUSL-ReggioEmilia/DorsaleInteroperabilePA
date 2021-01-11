<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="NoteAnamnesticheRiassociazioneDettaglio.aspx.vb" Inherits=".NoteAnamnesticheRiassociazioneDettaglio" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="lblError" runat="server" CssClass="Error" EnableViewState="False"></asp:Label>

    <asp:FormView ID="fvNotaAnamnestica" runat="server" DataSourceID="odsNotaAnamnestica" DataKeyNames="Contenuto,TipoContenuto" Style="width: 900px">
        <ItemTemplate>
            <%-- MODALE DI VISUALIZZAZIONE DEL CONTENUTO IN FORMATO HTML --%>
            <div id="ContenutoHtmlModal" style="display: none;">
                <div style="overflow: auto; height: 500px;">
                    <%# Eval("ContenutoHtml") %>
                </div>
            </div>

            <asp:Label Text="Nota Anamnestica" CssClass="title" runat="server" />
            <table class="table_dettagli" style="width: 100%">
                <tr class="fv-table-row-height">
                    <td class="Td-Text">Data Inserimento:
                    </td>
                    <td class="Td-Value" style="width: 20% !important;">
                        <asp:Label CssClass="fv-text-bold" Text='<%# Eval("DataInserimento") %>' runat="server" ID="DataInserimentoLabel" />
                    </td>
                    <td class="Td-Text">Data Modifica:
                    </td>
                    <td class="Td-Value" style="width: 20% !important;">
                        <asp:Label CssClass="fv-text-bold" Text='<%# Eval("DataModifica") %>' runat="server" ID="DataModificaLabel" />
                    </td>
                    <td class="Td-Text">Data Nota:
                    </td>
                    <td class="Td-Value">
                        <asp:Label CssClass="fv-text-bold" Text='<%# Eval("DataNota") %>' runat="server" ID="Label1" />
                    </td>
                </tr>
                <tr class="fv-table-row-height">
                    <td class="Td-Text">Azienda Erogante:
                    </td>
                    <td class="Td-Value">
                        <asp:Label CssClass="fv-text-bold" Text='<%# Eval("AziendaErogante") %>' runat="server" ID="AziendaEroganteLabel" />
                    </td>
                    <td class="Td-Text">Sistema Erogante:
                    </td>
                    <td class="Td-Value">
                        <asp:Label CssClass="fv-text-bold" Text='<%# Eval("SistemaErogante") %>' runat="server" ID="SistemaEroganteLabel" />
                    </td>
                    <td class="Td-Text">Stato:
                    </td>
                    <td class="Td-Value">
                        <asp:Label CssClass="fv-text-bold" Text='<%# Eval("StatoCodiceDesc") %>' runat="server" ID="StatoCodiceLabel" />
                    </td>
                </tr>
                <tr class="fv-table-row-height">
                    <td class="Td-Text">Tipo Codice:
                    </td>
                    <td class="Td-Value">
                        <asp:Label CssClass="fv-text-bold" Text='<%# Eval("TipoCodice") %>' runat="server" ID="Label2" />
                    </td>
                    <td class="Td-Text">Tipo Descrizione:
                    </td>
                    <td class="Td-Value">
                        <asp:Label CssClass="fv-text-bold" Text='<%# Eval("TipoDescrizione") %>' runat="server" ID="Label3" />
                    </td>
                    <td class="Td-Text">Data Fine Validita:
                    </td>
                    <td class="Td-Value">
                        <asp:Label CssClass="fv-text-bold" Text='<%# Eval("DataFineValidita") %>' runat="server" ID="Label5" />
                    </td>

                </tr>
                <tr class="fv-table-row-height">
                    <td class="Td-Text">Tipo Contenuto:
                    </td>
                    <td class="Td-Value">
                        <asp:Label CssClass="fv-text-bold" Text='<%# Eval("TipoContenuto") %>' runat="server" ID="Label4" />
                    </td>
                    <td class="Td-Text">Download Contenuto:
                    </td>
                    <td class="Td-Value">
                        <asp:ImageButton ID="ApriContenutoBtn" CommandName="ApriContenuto" ImageUrl="../Images/ViewDoc.gif" ToolTip="Scarica il contenuto della nota anamnestica.." runat="server" />
                    </td>
                    <td class="Td-Text">Mostra Contenuto HTML:
                    </td>
                    <td class="Td-Value">
                        <asp:ImageButton ID="ApriContenutoHtmlBtn" CommandName="ApriContenutoHtml" CommandArgument=' <%# Eval("ContenutoHtml") %>' ImageUrl="../Images/ViewDoc.gif" ToolTip="Visualizza il contenuto della nota anamnestica.." runat="server" />
                    </td>
                </tr>
            </table>

            <asp:Label Text="Dati Anagrafici della Nota Anamnestica" CssClass="title" runat="server" />
            <table class="table_dettagli" style="width: 100%">
                <tr class="fv-table-row-height">
                    <td class="Td-Text" style="width: 16%;">Id Paziente Sac:
                    </td>
                    <td class="Td-Value" style="width: 34%;">
                        <asp:Label CssClass="fv-text-bold" Text='<%# Eval("IdPaziente") %>' runat="server" ID="Label6" />
                    </td>
                    <td class="Td-Text" style="width: 16%;"></td>
                    <td class="Td-Value" style="width: 34%;"></td>
                </tr>
                <tr>
                    <td class="Td-Text">Anagrafica:
                    </td>
                    <td class="Td-Value">
                        <asp:Label CssClass="fv-text-bold" Text='<%# Eval("NomeAnagraficaCentrale") %>' runat="server" ID="Label7" />
                    </td>
                    <td class="Td-Text">Codice Anagrafica:
                    </td>
                    <td class="Td-Value">
                        <asp:Label CssClass="fv-text-bold" Text='<%# Eval("CodiceAnagraficaCentrale") %>' runat="server" ID="Label8" />
                    </td>
                </tr>
                <tr class="fv-table-row-height">
                    <td class="Td-Text">Cognome:
                    </td>
                    <td class="Td-Value">
                        <asp:Label CssClass="fv-text-bold" Text='<%# Eval("Cognome") %>' runat="server" ID="CognomeLabel" />
                    </td>
                    <td class="Td-Text">Nome:
                    </td>
                    <td class="Td-Value">
                        <asp:Label CssClass="fv-text-bold" Text='<%# Eval("Nome") %>' runat="server" ID="NomeLabel" />
                    </td>

                </tr>
                <tr class="fv-table-row-height">
                    <td class="Td-Text">Codice Fiscale:</td>
                    <td class="Td-Value">
                        <asp:Label CssClass="fv-text-bold" Text='<%# Eval("CodiceFiscale") %>' runat="server" ID="CodiceFiscaleLabel" />
                    </td>

                    <td class="Td-Text">Data Nascita:</td>
                    <td class="Td-Value">
                        <asp:Label CssClass="fv-text-bold" Text='<%# Eval("DataNascita", "{0:d}") %>' runat="server" ID="DataNascitaLabel" />
                    </td>
                </tr>
                <tr class="fv-table-row-height">
                    <td class="Td-Text"></td>
                    <td class="Td-Value"></td>
                    <td class="Td-Text">Luogo di Nascita:</td>
                    <td class="Td-Value">
                        <%# Eval("ComuneNascita")%>
                        <%#If(Eval("ProvinciaNascita") Is DBNull.Value, "", "(" & Eval("ProvinciaNascita") & ")")%>
                    </td>
                </tr>
            </table>

            <asp:Label Text="Dati Anagrafici SAC Correnti" CssClass="title" runat="server" />
            <table class="table_dettagli" style="width: 100%">
                <tr>
                    <td class="Td-Text" style="width: 16%;">Anagrafica
                    </td>
                    <td class="Td-Value" style="width: 34%;">
                        <%# Eval("SACProvenienza")%>
                    </td>
                    <td class="Td-Text" nowrap="nowrap" style="width: 16%;">Codice Anagrafica
                    </td>
                    <td class="Td-Value" style="width: 34%;">
                        <%# Eval("SACIdProvenienza")%>
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text" nowrap="nowrap">Cognome:
                    </td>
                    <td class="Td-Value">
                        <%# Eval("SACCognome")%>
                    </td>
                    <td class="Td-Text">Nome:
                    </td>
                    <td class="Td-Value">
                        <%# Eval("SACNome")%>
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text" nowrap="nowrap">Codice Fiscale:
                    </td>
                    <td class="Td-Value">
                        <%#Eval("SACCodiceFiscale")%>
                    </td>
                    <td class="Td-Text" nowrap="nowrap">Data di Nascita:
                    </td>
                    <td class="Td-Value">
                        <%#Eval("SACDataNascita", "{0:d}")%>
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text" nowrap="nowrap"></td>
                    <td class="Td-Value"></td>
                    <td class="Td-Text" nowrap="nowrap">Luogo di Nascita:
                    </td>
                    <td class="Td-Value">
                        <%#Eval("SACComuneNascita")%>
                        <%#If(Eval("SACProvinciaNascita") Is DBNull.Value, "", "(" & Eval("SACProvinciaNascita") & ")")%>
                    </td>
                </tr>
            </table>
        </ItemTemplate>
    </asp:FormView>

    <asp:FormView ID="FormViewDettagliSAC" runat="server" Width="900px" DataSourceID="odsDettagliSAC"
        EnableModelValidation="True" EmptyDataText="">
        <ItemTemplate>
            <table class="table_dettagli" style="width: 100%">
                <tr>
                    <td colspan="4">
                        <span class="Title" style="display: inline-block; margin-right: 30px;">Nuovi Dati
								Anagrafici SAC</span>
                        <asp:Label ID="lblWarning" runat="server" CssClass="Warning">Verificare i dati anagrafici e premere Associa per eseguire la sostituzione.</asp:Label>
                    </td>
                </tr>
                <tr>
                    <td style="width: 16%;" class="Td-Text" nowrap="nowrap">Id Paziente SAC
                    </td>
                    <td style="width: 34%;" class="Td-Value-Alt">
                        <%# Eval("Id")%>
                    </td>
                    <td style="width: 16%;" class="Td-Text"></td>
                    <td style="width: 34%;" class="Td-Value-Alt"></td>
                </tr>
                <tr>
                    <td class="Td-Text">Anagrafica
                    </td>
                    <td class="Td-Value-Alt">
                        <%# Eval("Provenienza")%>
                    </td>
                    <td class="Td-Text" nowrap="nowrap">Codice Anagrafica
                    </td>
                    <td class="Td-Value-Alt">
                        <%# Eval("IdProvenienza")%>
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text" nowrap="nowrap">Cognome:
                    </td>
                    <td class="Td-Value-Alt">
                        <%# Eval("Cognome")%>
                    </td>
                    <td class="Td-Text">Nome:
                    </td>
                    <td class="Td-Value-Alt">
                        <%# Eval("Nome")%>
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text" nowrap="nowrap">Codice Fiscale:
                    </td>
                    <td class="Td-Value-Alt">
                        <%#Eval("CodiceFiscale")%>
                    </td>
                    <td class="Td-Text" nowrap="nowrap">Data di Nascita:
                    </td>
                    <td class="Td-Value-Alt">
                        <%#Eval("DataNascita", "{0:d}")%>
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text" nowrap="nowrap"></td>
                    <td class="Td-Value-Alt"></td>
                    <td class="Td-Text" nowrap="nowrap">Luogo di Nascita:
                    </td>
                    <td class="Td-Value-Alt">
                        <%#Eval("ComuneNascitaNome")%>
                        <%#If(Eval("ProvincianascitaNome") Is DBNull.Value, "", "(" & Eval("ProvincianascitaNome") & ")")%>
                    </td>
                </tr>
            </table>
        </ItemTemplate>
    </asp:FormView>

    <table class="table_dettagli" style="width: 900px;">
        <tr>
            <td class="LeftFooter" style="width: 50%;">
                <asp:Button ID="btnCerca" runat="server" CausesValidation="False" Text="Cerca Paziente"
                    class="Button" Width="130px" />
            </td>
            <td class="RightFooter" style="width: 50%;">
                <asp:Button ID="btnAssocia" Enabled="false" runat="server" CausesValidation="False" Text="Associa"
                    OnClientClick="return confirm('Confermi la riassociazione del paziente alla nota anamnestica?');"
                    class="Button" />
                <asp:Button ID="btnAnnulla" runat="server" CausesValidation="False" Text="Annulla"
                    class="Button" Style="margin-left: 10px;" />
            </td>
        </tr>
    </table>

    <asp:ObjectDataSource ID="odsNotaAnamnestica" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetDataByIdNotaAnamnestica" TypeName="NoteAnamnesticheDataSetTableAdapters.NotaAnamnesticaRiassociazioneOttieniTableAdapter" UpdateMethod="Update">
        <SelectParameters>
            <asp:Parameter DbType="Guid" Name="IdNotaAnamnestica"></asp:Parameter>
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter DbType="Guid" Name="IdNotaAnamnestica"></asp:Parameter>
            <asp:Parameter DbType="Guid" Name="IdPaziente"></asp:Parameter>
        </UpdateParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="odsDettagliSAC" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetData" TypeName="RefertiDataSetTableAdapters.RiassociazioneSACPazienteTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter DbType="Guid" Name="idPaziente" QueryStringField="IdPaziente" />
            <asp:Parameter Name="IdProvenienza" Type="String" />
            <asp:Parameter Name="Provenienza" Type="String" />
            <asp:Parameter Name="Disattivato" Type="Byte" />
            <asp:Parameter Name="Cognome" Type="String" />
            <asp:Parameter Name="Nome" Type="String" />
            <asp:Parameter Name="AnnoNascita" Type="Int32" />
            <asp:Parameter Name="CodiceFiscale" Type="String" />
            <asp:Parameter Name="Top" Type="Int32" DefaultValue="1" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <%-- IFRAME USATO SOLO PER ESEGUIRE IL DOWNLOAD DEL CONTENUTO --%>
    <iframe id="myIframe" runat="server" style="display: none;"></iframe>

    <script src="../Scripts/PopUp-2.0.0.js"></script>
</asp:Content>
