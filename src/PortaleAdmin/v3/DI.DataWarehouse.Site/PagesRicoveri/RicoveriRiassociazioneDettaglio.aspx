<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="RicoveriRiassociazioneDettaglio.aspx.vb" Inherits=".RicoveriRiassociazioneDettaglio" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"></asp:Label>



    <%-- INFORMAZIONI RICOVERO --%>
    <asp:FormView runat="server" DataSourceID="RicoveroOds" ID="fvRicovero" DefaultMode="ReadOnly">
        <ItemTemplate>
            <fieldset class="filters">
                <legend>Paziente</legend>
                <table class="table_dettagli" style="width: 900px">
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
                        <td class="Td-Text">Sesso:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Bind("Sesso") %>' runat="server" ID="SessoLabel" />
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
                        <td class="Td-Text">Comune Nascita:</td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Bind("ComuneNascita") %>' runat="server" ID="ComuneNascitaLabel" />
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Codice Sanitario
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Bind("CodiceSanitario") %>' runat="server" ID="CodiceSanitarioLabel" />
                        </td>
                    </tr>
                </table>
            </fieldset>
            <fieldset class="filters">
                <legend>Ricovero</legend>
                <table style="width: 900px;" class="table_dettagli">
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
                        <td class="Td-Text">Stato:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("StatoCodice") %>' runat="server" ID="StatoCodiceLabel" />
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Azienda Erogante:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("AziendaErogante") %>' runat="server" ID="AziendaEroganteLabel" />
                        </td>
                        <td class="Td-Text">Numero Nosologico:</td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("NumeroNosologico") %>' runat="server" ID="NumeroNosologicoLabel" />
                        </td>
                        <td class="Td-Text">Sistema Erogante:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("SistemaErogante") %>' runat="server" ID="SistemaEroganteLabel" />
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Tipo Ricovero
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# FormatCodiceDescrizione(Eval("TipoRicoveroDescr"), Eval("TipoRicoveroCodice")) %>' runat="server" ID="TipoRicoveroDescrLabel" />
                        </td>
                        <td class="Td-Text">Reparto Erogante:
                        </td>
                        <td class="Td-Value" colspan="3">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("RepartoErogante") %>' runat="server" ID="RepartoEroganteLabel" />
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Diagnosi:</td>
                        <td colspan="5" class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("Diagnosi") %>' runat="server" ID="DiagnosiLabel" />
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Data Accettazione:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Bind("DataAccettazione") %>' runat="server" ID="DataAccettazioneLabel" />
                        </td>
                        <td class="Td-Text">Reparto Accettazione</td>
                        <td class="Td-Value" colspan="3">
                            <asp:Label CssClass="fv-text-bold" Text='<%# FormatCodiceDescrizione(Eval("RepartoAccettazioneDescr"), Eval("RepartoAccettazioneCodice")) %>' runat="server" ID="Label1" />
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Data Trasferimento</td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("DataTrasferimento") %>' runat="server" ID="Label2" />
                        </td>
                        <td class="Td-Text">Reparto Corrente</td>
                        <td class="Td-Value" colspan="3">
                            <asp:Label CssClass="fv-text-bold" Text='<%# FormatCodiceDescrizione(Eval("RepartoDescr"), Eval("RepartoCodice")) %>' runat="server" ID="RepartoCodiceLabel" />
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Settore</td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# FormatCodiceDescrizione(Eval("SettoreDescr"), Eval("SettoreCodice")) %>' runat="server" ID="SettoreCodiceLabel" />
                        </td>
                        <td class="Td-Text">Codice Letto</td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("LettoCodice") %>' runat="server" ID="LettoCodiceLabel" />
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Data Dimissione</td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("DataDimissione") %>' runat="server" ID="DataDimissioneLabel" />
                        </td>
                    </tr>
                </table>
            </fieldset>
        </ItemTemplate>
    </asp:FormView>

    <label class="Title">Eventi del Ricovero</label>
    <div id="divEventiRicovero">
        <asp:GridView ID="gvEventiRicovero" runat="server" AllowPaging="True" Width="100%" Style="margin-top: 0px !important" CssClass="Grid" AutoGenerateColumns="False" DataSourceID="EventiRicoveroOds" PageSize="100" PagerSettings-Position="TopAndBottom">
            <HeaderStyle CssClass="GridHeader" />
            <PagerStyle CssClass="GridPager" />
            <SelectedRowStyle CssClass="GridSelected" />
            <RowStyle CssClass="GridItem" Wrap="true" />
            <AlternatingRowStyle CssClass="GridAlternatingItem" Wrap="true" />
            <Columns>
                <asp:BoundField DataField="DataInserimento" HeaderText="Data Inserimento" SortExpression="DataInserimento"></asp:BoundField>
                <asp:BoundField DataField="DataModifica" HeaderText="Data Modifica" SortExpression="DataModifica"></asp:BoundField>
                <asp:BoundField DataField="AziendaErogante" HeaderText="Azienda Erogante" SortExpression="AziendaErogante"></asp:BoundField>
                <asp:BoundField DataField="RepartoErogante" HeaderText="Reparto Erogante" SortExpression="RepartoErogante"></asp:BoundField>
                <asp:BoundField DataField="DataEvento" HeaderText="Data Evento" SortExpression="DataEvento"></asp:BoundField>
                <asp:BoundField DataField="StatoCodice" HeaderText="Stato Codice" SortExpression="StatoCodice"></asp:BoundField>
                <asp:TemplateField HeaderText="Tipo Evento">
                    <ItemTemplate>
                        <asp:Label Text='<%# String.Format("{0} - ({1})", Eval("TipoEventoDescr"), Eval("TipoEventoCodice")) %>' runat="server" />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Tipo Episodio">
                    <ItemTemplate>
                        <asp:Label Text='<%# String.Format("{0} - ({1})", Eval("TipoEpisodioDescr"), Eval("TipoEpisodio")) %>' runat="server" />
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>


    <%-- INFORMAZINI PAZIENTE --%>
    <asp:FormView ID="FormViewDettagliSAC" runat="server" Width="100%" DataSourceID="odsDettagliSAC"
        EnableModelValidation="True" EmptyDataText="" style="margin-top:40px">
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


    <%-- TOOLBAR --%>
    <table class="table_dettagli" style="width: 100%;">
        <tr>
            <td class="LeftFooter" style="width: 50%;">
                <asp:Button ID="butCerca" runat="server" CausesValidation="False" Text="Cerca Paziente"
                    class="Button" Width="130px" />
            </td>
            <td class="RightFooter" style="width: 50%;">
                <asp:Button ID="butAssocia" runat="server" CausesValidation="False" Text="Associa"
                    OnClientClick="return confirm('Confermi la riassociazione del paziente al ricovero?');"
                    class="Button" />

                <asp:Button ID="butAnnulla" runat="server" CausesValidation="False" Text="Annulla"
                    class="Button" Style="margin-left: 10px;" />
            </td>
        </tr>
    </table>


    <asp:ObjectDataSource ID="odsDettagliSAC" runat="server" OldValuesParameterFormatString="{0}"
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

    <asp:ObjectDataSource ID="RicoveroOds" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetDataBy" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.BeRicoveriListaTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter QueryStringField="IdRicovero" DbType="Guid" Name="IdRicovero"></asp:QueryStringParameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="EventiRicoveroOds" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.BevsEventiRicoveroOttieniTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter QueryStringField="NumeroNosologico" Name="NumeroNosologico" Type="String"></asp:QueryStringParameter>
            <asp:QueryStringParameter QueryStringField="AziendaErogante" Name="AziendaErogante" Type="String"></asp:QueryStringParameter>
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
