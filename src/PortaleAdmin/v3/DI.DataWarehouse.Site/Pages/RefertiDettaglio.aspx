<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="RefertiDettaglio.aspx.vb" Inherits=".RefertiDettaglio" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"></asp:Label>
    <label class="Title">Dettaglio del Referto</label>

    <asp:FormView runat="server" DataSourceID="RefertiOds" DefaultMode="ReadOnly">
        <ItemTemplate>
            <fieldset class="filters">
                <legend>Paziente</legend>
                <table class="table_dettagli" style="width: 900px">
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Cognome:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("Cognome") %>' runat="server" ID="Label1" />
                        </td>
                        <td class="Td-Text">Nome:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("Nome") %>' runat="server" ID="Label2" />
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
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("CodiceFiscale") %>' runat="server" ID="Label3" />
                        </td>
                        <td class="Td-Text">Data Nascita:</td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("DataNascita", "{0:d}") %>' runat="server" ID="Label4" />
                        </td>
                        <td class="Td-Text">Comune Nascita:</td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Bind("ComuneNascita") %>' runat="server" ID="Label5" />
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Codice Sanitario
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Bind("CodiceSanitario") %>' runat="server" ID="Label6" />
                        </td>
                    </tr>
                </table>
            </fieldset>
            <fieldset class="filters">
                <legend>Referto</legend>
                <table style="width: 900px;" class="table_dettagli">
                    <tr class="fv-table-row-height">
                        <td class="Td-Text" colspan="2" style="width: 20% !important;">
                            <%-- UTILIZZO UN "<a>" perchè devo aprire l'url in un nuovo pannello.--%>
                            <a href='<%# GetUrlReferto() %>' target="_blank">Apri Referto su DwhClinico</a>
                        </td>
                        <td class="Td-Text" colspan="2" style="width: 20% !important;">
                            <asp:LinkButton OnClick="NavigaLogSOLE" ID="lnkSOLE" Text="Apri Log invio SOLE" runat="server"/>
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text" style="width: 10% !important;">Data Inserimento:
                        </td>
                        <td class="Td-Value" style="width: 20% !important;">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("DataInserimento") %>' runat="server" ID="Label7" />
                        </td>
                        <td class="Td-Text" style="width: 10% !important;">Data Modifica:
                        </td>
                        <td class="Td-Value" style="width: 20% !important;">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("DataModifica") %>' runat="server" ID="Label8" />
                        </td>
                        <td class="Td-Text" style="width: 10% !important;">Data Referto:
                        </td>
                        <td class="Td-Value" style="width: 30% !important;">
                            <asp:Label Text='<%# Bind("DataReferto") %>' runat="server" ID="DataRefertoLabel" />
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Azienda Erogante:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("AziendaErogante") %>' runat="server" ID="Label9" />
                        </td>
                        <td class="Td-Text">Sistema Erogante:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("SistemaErogante") %>' runat="server" ID="Label11" />
                        </td>
                        <td class="Td-Text">Numero Nosologico:</td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("NumeroNosologico") %>' runat="server" ID="Label10" />
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Reparto Erogante:</td>
                        <td colspan="2" class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("RepartoErogante") %>' runat="server" ID="Label12" />
                        </td>
                        <td class="Td-Text">Reparto Richiedente</td>
                        <td class="Td-Value" colspan="2">
                            <asp:Label CssClass="fv-text-bold" Text='<%# FormatCodiceDescrizione(Eval("RepartoRichiedenteDescr"), Eval("RepartoRichiedenteCodice")) %>' runat="server" ID="RepartoCodiceLabel" />
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Numero Prenotazione
                        </td>
                        <td class="Td-Value">
                            <asp:Label Text='<%# Bind("NumeroPrenotazione") %>' runat="server" ID="Label16" /><br />
                        </td>
                        <td class="Td-Text">Numero Referto
                        </td>
                        <td class="Td-Value">
                            <asp:Label Text='<%# Bind("NumeroReferto") %>' runat="server" ID="NumeroRefertoLabel" />
                        </td>
                        <td class="Td-Text">Stato Richiesta
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# FormatCodiceDescrizione(Eval("StatoRichiestaDescr"), Eval("StatoRichiestaCodice")) %>' runat="server" ID="Label14" />
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Id Paziente:
                        </td>
                        <td colspan="2" class="Td-Value">
                            <asp:Label Text='<%# Bind("IdPaziente") %>' runat="server" ID="Label15" />
                        </td>
                        <td class="Td-Text">Id Esterno:
                        </td>
                        <td colspan="2" class="Td-Value">
                            <asp:Label Text='<%# Bind("IdEsterno") %>' runat="server" ID="Label13" /><br />
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Codice Oscuramento</td>
                        <td class="Td-Value" colspan="2">
                            <asp:Label Text='<%# Bind("CodiceOscuramento") %>' runat="server" ID="CodiceOscuramentoLabel" />
                        </td>
                    </tr>
                </table>
            </fieldset>
        </ItemTemplate>
    </asp:FormView>

    <label class="Title">Attributi del Referto</label>
    <div id="divAttributi" style="width: 910px">
        <asp:Label EnableViewState="false" Visible="false" ID="lblAttributiEmpty" Text="Non sono presenti attributi per il referto selezionato." runat="server" />
        <asp:GridView ID="gvAttributiReferto" ClientIDMode="Static" runat="server" AllowPaging="True" Width="100%" Style="margin-top: 0px !important" CssClass="Grid" AutoGenerateColumns="False" DataSourceID="RefertoAttributiOds" PageSize="100" PagerSettings-Position="TopAndBottom">
            <HeaderStyle CssClass="GridHeader" />
            <PagerStyle CssClass="GridPager" />
            <SelectedRowStyle CssClass="GridSelected" />
            <RowStyle CssClass="GridItem" Wrap="true" />
            <AlternatingRowStyle CssClass="GridAlternatingItem" Wrap="true" />
            <Columns>
                <asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome" HeaderStyle-Width="200px" ItemStyle-Width="200px"></asp:BoundField>
                <asp:BoundField DataField="Valore" HeaderText="Valore" SortExpression="Valore" HeaderStyle-Width="500px" ItemStyle-Width="500px"></asp:BoundField>
            </Columns>
        </asp:GridView>
    </div>

    <label class="Title">Prestazioni del Referto</label>
    <div id="divPrestazioni">
        <asp:Label EnableViewState="false" Visible="false" ID="lblPrestazioniEmpty" Text="Non sono presenti attributi per il referto selezionato." runat="server" />
        <asp:GridView ClientIDMode="Static" runat="server" DataSourceID="PrestazioniRefertoOds" AutoGenerateColumns="False" ID="gvPrestazioniReferto" AllowPaging="True" Width="100%" Style="margin-top: 0px !important" CssClass="Grid" PageSize="100" PagerSettings-Position="TopAndBottom">
            <HeaderStyle CssClass="GridHeader" />
            <PagerStyle CssClass="GridPager" />
            <SelectedRowStyle CssClass="GridSelected" />
            <RowStyle CssClass="GridItem" Wrap="true" />
            <AlternatingRowStyle CssClass="GridAlternatingItem" Wrap="true" />
            <Columns>
                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:ImageButton ID="ApriAttributiBtn" CommandName="ApriAttributi" CommandArgument='<%# Eval("Id") %>' ImageUrl="../Images/detail.png" ToolTip="Apri Attributi della Prestazione.." runat="server" />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="IdRefertiBase" HeaderText="IdRefertiBase" SortExpression="IdRefertiBase"></asp:BoundField>
                <asp:BoundField DataField="IdEsterno" HeaderText="IdEsterno" SortExpression="IdEsterno"></asp:BoundField>
                <asp:BoundField DataField="DataModifica" HeaderText="DataModifica" SortExpression="DataModifica"></asp:BoundField>
                <asp:BoundField DataField="PrestazioneCodice" HeaderText="PrestazioneCodice" SortExpression="PrestazioneCodice"></asp:BoundField>
                <asp:BoundField DataField="PrestazioneDescrizione" HeaderText="PrestazioneDescrizione" SortExpression="PrestazioneDescrizione"></asp:BoundField>
                <asp:BoundField DataField="GravitaCodice" HeaderText="GravitaCodice" SortExpression="GravitaCodice"></asp:BoundField>
                <asp:BoundField DataField="GravitaDescrizione" HeaderText="GravitaDescrizione" SortExpression="GravitaDescrizione"></asp:BoundField>
                <asp:BoundField DataField="Risultato" HeaderText="Risultato" SortExpression="Risultato"></asp:BoundField>
                <asp:BoundField DataField="ValoriRiferimento" HeaderText="ValoriRiferimento" SortExpression="ValoriRiferimento"></asp:BoundField>
                <asp:BoundField DataField="Commenti" HeaderText="Commenti" SortExpression="Commenti"></asp:BoundField>
            </Columns>
        </asp:GridView>
    </div>

    <div id="attributiModal" style="display: none;">
        <div id="divAttributiPrestazione" style="overflow: auto; height: 500px;">
            <asp:GridView ID="gvAttributiPrestazione" runat="server" DataSourceID="AttributiPrestazioneOds" AutoGenerateColumns="False" CssClass="Grid" Style="margin-top: 0px !important">
                <HeaderStyle CssClass="GridHeader" />
                <PagerStyle CssClass="GridPager" />
                <SelectedRowStyle CssClass="GridSelected" />
                <RowStyle CssClass="GridItem" Wrap="true" />
                <AlternatingRowStyle CssClass="GridAlternatingItem" Wrap="true" />
                <Columns>
                    <asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome"></asp:BoundField>
                    <asp:BoundField DataField="Valore" HeaderText="Valore" SortExpression="Valore"></asp:BoundField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <label class="Title">Allegati del Referto</label>
    <div id="divAllegati">
        <asp:GridView ClientIDMode="Static" ID="gvAllegati" runat="server" AutoGenerateColumns="False" DataSourceID="AllegatiRefertoOds"
            AllowPaging="True" Width="100%" Style="margin-top: 0px !important" CssClass="Grid" PageSize="100" PagerSettings-Position="TopAndBottom">
            <HeaderStyle CssClass="GridHeader" />
            <PagerStyle CssClass="GridPager" />
            <SelectedRowStyle CssClass="GridSelected" />
            <RowStyle CssClass="GridItem" Wrap="true" />
            <AlternatingRowStyle CssClass="GridAlternatingItem" Wrap="true" />
            <Columns>
                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:ImageButton ID="ApriAttributiAllegatiBtn" CommandName="ApriAttributi" CommandArgument='<%# Eval("Attributi") %>' ImageUrl="../Images/detail.png" ToolTip="Apri Attributi dell'Allegato.." runat="server" />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Id Esterno">
                    <ItemTemplate>
                        <a href="javascript:;" onclick="ShowPopUpAllegato('<%# Eval("Id") %>')"> <%# Eval("IdEsterno") %>'</a>
                    </ItemTemplate>
                </asp:TemplateField>
                <%--<asp:BoundField DataField="IdEsterno" HeaderText="IdEsterno" SortExpression="IdEsterno"></asp:BoundField>--%>
                <asp:BoundField DataField="DataModifica" HeaderText="DataModifica" SortExpression="DataModifica"></asp:BoundField>
                <asp:BoundField DataField="DataFile" HeaderText="DataFile" SortExpression="DataFile"></asp:BoundField>
                <asp:BoundField DataField="MimeType" HeaderText="MimeType" SortExpression="MimeType"></asp:BoundField>
                <asp:BoundField DataField="NomeFile" HeaderText="NomeFile" SortExpression="NomeFile"></asp:BoundField>
                <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
                <asp:BoundField DataField="Posizione" HeaderText="Posizione" SortExpression="Posizione"></asp:BoundField>
                <asp:TemplateField HeaderText="Stato">
                    <ItemTemplate>
                        <%# FormatCodiceDescrizione(Eval("StatoDescrizione"), Eval("StatoDescrizione")) %>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>

    <div id="attributiAllegatoModal" style="display: none;">
        <div style="overflow: auto; height: 500px;">
            <asp:GridView ID="gvAllegatiAttributi" runat="server" AutoGenerateColumns="False"
                AllowPaging="True" Width="100%" Style="margin-top: 0px !important" CssClass="Grid" PageSize="100" PagerSettings-Position="TopAndBottom">
                <HeaderStyle CssClass="GridHeader" />
                <PagerStyle CssClass="GridPager" />
                <SelectedRowStyle CssClass="GridSelected" />
                <RowStyle CssClass="GridItem" Wrap="true" />
                <AlternatingRowStyle CssClass="GridAlternatingItem" Wrap="true" />
                <Columns>
                    <asp:BoundField DataField="Key" HeaderText="Nome" SortExpression="Key"></asp:BoundField>
                    <asp:BoundField DataField="Value" HeaderText="Valore" SortExpression="Value"></asp:BoundField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <asp:ObjectDataSource ID="RefertiOds" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetDataBy" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.BeRefertiListaTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter QueryStringField="IdReferto" DbType="Guid" Name="IdReferto"></asp:QueryStringParameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="RefertoAttributiOds" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="RefertiDataSetTableAdapters.BevsAttributiRefertoOttieniTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter QueryStringField="IdReferto" DbType="Guid" Name="IdReferto"></asp:QueryStringParameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="PrestazioniRefertoOds" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="RefertiDataSetTableAdapters.BevsPrestazioniRefertoOttieniTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter QueryStringField="IdReferto" DbType="Guid" Name="IdReferto"></asp:QueryStringParameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="AttributiPrestazioneOds" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="RefertiDataSetTableAdapters.BevsAttributiPrestazioneOttieniTableAdapter">
        <SelectParameters>
            <asp:Parameter DbType="Guid" Name="IdPrestazione"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource runat="server" ID="AllegatiRefertoOds" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="RefertiDataSetTableAdapters.BevsAllegatiRefertoOttieniTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter QueryStringField="IdReferto" DbType="Guid" Name="IdReferto"></asp:QueryStringParameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <script src="../Scripts/PopUp-2.0.0.js"></script>
    <script type="text/javascript">
        function ShowPopUpAllegato(IdAllegato) {
            //e.preventDefault();

            if (IdAllegato == undefined || IdAllegato == '') {
                commonModalDialogOpen('ApreAllegato.aspx', '', 700, 700);
            }
            else {
                commonModalDialogOpen('ApreAllegato.aspx?IdAllegato=' + IdAllegato, 'Allegato [' + IdAllegato + ']', 700, 700);
            }
            return false;
        }
    </script>
</asp:Content>
