<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="OscuramentiRinotifica.aspx.vb" Inherits=".OscuramentiRinotifica" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <style>
        .grid-custom-margin {
            margin-top: 1px !important;
            margin-bottom: 25px !important;
        }

        .label-title-custom-font {
            font-size: 11px;
            font-weight: bold;
            font-style: italic;
        }

        .btn-custom-align {
            text-align: right;
        }

        #tabellaPagina tr {
            vertical-align: top !important;
            padding-bottom: 20px;
        }
    </style>

    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />

    <asp:Label Text='Rinotifica Oscuramento' ID="lblTitle" CssClass="Title" runat="server" />

    <div id="wizard" runat="server">
        <ul id="wizardList">
            <li class="wizardElement">
                <div class="done">
                    <span class="stepNumber">1</span>
                    <span class="stepDescription">Creazione o Modifica Oscuramento</span>
                </div>
            </li>
            <li class="wizardElement">
                <div class="selected">
                    <span class="stepNumber">2</span>
                    <span class="stepDescription">Rinotifica a SOLE</span>
                </div>
            </li>
        </ul>
    </div>

    <%-- TESTATA OSCURAMENTO VECCHIO E NUOVO --%>
    <table style="width: 70%;" id="tabellaPagina">
        <tr>
            <td colspan="2">
                <div class="btn-custom-align">
                    <asp:Button ID="btnOkTop" Text="Ok" CssClass="Button btn-ok" runat="server" />
                    <asp:Button ID="btnAnnullaTop" Text="Anulla" CssClass="Button" runat="server" OnClientClick="return confirm('Annullando l\'operazione l\'oscuramento non verrà completato. Continuare comunque?');" />
                </div>
            </td>
        </tr>
        <tr>
            <td>
                <asp:FormView runat="server" DataSourceID="OdsDettaglioOscuramento" Width="100%" CssClass="grid-custom-margin">
                    <ItemTemplate>
                        <div id="panelNuovoOscuramento" runat="server">
                            <fieldset class="filters">
                                <legend>Nuovo Oscuramento</legend>
                                <table class="table_dettagli" style="width: 100%;">
                                    <tr>
                                        <td class="Td-Text">Titolo</td>
                                        <td class="Td-Value">
                                            <asp:Label Text='<%# Eval("Titolo") %>' runat="server" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="Td-Text">Note</td>
                                        <td class="Td-Value">
                                            <asp:Label Text='<%# Eval("Note") %>' runat="server" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="Td-Text">Filtri</td>
                                        <td class="Td-Value">
                                            <%# GetDescrizioneRow(Container.DataItem) %>
                                        </td>
                                    </tr>
                                </table>
                            </fieldset>
                        </div>
                    </ItemTemplate>
                </asp:FormView>
                <asp:ObjectDataSource ID="OdsDettaglioOscuramento" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="OscuramentiDataSetTableAdapters.OscuramentiTableAdapter">
                    <SelectParameters>
                        <asp:QueryStringParameter QueryStringField="Id" DbType="Guid" Name="Id"></asp:QueryStringParameter>
                    </SelectParameters>
                </asp:ObjectDataSource>
            </td>
            <td>
                <asp:FormView ID="fvVecchioOscuramento" runat="server" DataSourceID="odsVecchioOscuramento" Width="100%">
                    <ItemTemplate>
                        <div id="panelVecchioOscuramento" runat="server">
                            <fieldset class="filters">
                                <legend>Precedente Oscuramento</legend>
                                <table class="table_dettagli" style="width: 100%;">
                                    <tr>
                                        <td class="Td-Text">Titolo</td>
                                        <td class="Td-Value">
                                            <asp:Label Text='<%# Eval("Titolo") %>' runat="server" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="Td-Text">Note</td>
                                        <td class="Td-Value">
                                            <asp:Label Text='<%# Eval("Note") %>' runat="server" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="Td-Text">Filtri</td>
                                        <td class="Td-Value">
                                            <%# GetDescrizioneRow(Container.DataItem) %>
                                        </td>
                                    </tr>
                                </table>
                            </fieldset>
                        </div>
                    </ItemTemplate>
                </asp:FormView>
                <asp:ObjectDataSource ID="odsVecchioOscuramento" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="OscuramentiDataSetTableAdapters.OscuramentiTableAdapter">
                    <SelectParameters>
                        <asp:QueryStringParameter QueryStringField="IdOld" DbType="Guid" Name="Id"></asp:QueryStringParameter>
                    </SelectParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr class="tr-vertical-align">
            <td>
                <label class="label-title-custom-font">Referti oscurati dal nuovo Oscuramento</label>
                <asp:GridView ID="gvListareferti" ClientIDMode="Static" runat="server" DataSourceID="odsReferti" AutoGenerateColumns="False"
                    AllowPaging="true" CssClass="Grid grid-custom-margin" EmptyDataText="Nessun risultato!" PagerSettings-Position="Bottom" Width="100%">
                    <Columns>
                        <asp:HyperLinkField runat="server" Target="_blank" DataNavigateUrlFormatString="RefertiDettaglio.aspx?IdReferto={0}"
                            DataNavigateUrlFields="Id" Text="&lt;img src='../Images/detail.png' alt='Vai al dettaglio...' /&gt;" />
                        <asp:TemplateField ControlStyle-Width="200px" HeaderText="Sistema@Azienda-Reparto Erogante">
                            <ItemTemplate>
                                <asp:Label Text='<%# GetAziendaSistemaRepartoDescrizione(Eval("AziendaErogante"), Eval("SistemaErogante"), Eval("RepartoErogante")) %>' runat="server" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="DataReferto" HeaderText="Data Referto" SortExpression="DataReferto"></asp:BoundField>
                    </Columns>
                    <HeaderStyle CssClass="GridHeader" />
                    <PagerStyle CssClass="GridPager" />
                    <SelectedRowStyle CssClass="GridSelected" />
                    <RowStyle CssClass="GridItem" Wrap="true" />
                    <AlternatingRowStyle CssClass="GridAlternatingItem" Wrap="true" />
                </asp:GridView>
                <asp:ObjectDataSource ID="odsReferti" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="OscuramentiDataSetTableAdapters.OscuramentiRefertiOttieniTableAdapter">
                    <SelectParameters>
                        <asp:QueryStringParameter QueryStringField="Id" DbType="Guid" DefaultValue="" Name="IdOscuramento"></asp:QueryStringParameter>
                    </SelectParameters>
                </asp:ObjectDataSource>
            </td>
            <td>
                <div id="divRefertiOscuramentoOld" runat="server">
                    <label class="label-title-custom-font">Referti oscurati dal precedente Oscuramento</label>
                    <asp:GridView ID="gvListaRefertiVecchioOscuramento" ClientIDMode="Static" runat="server" DataSourceID="odsRefertiVecchioOscuramento"
                        AutoGenerateColumns="False" AllowPaging="true" CssClass="Grid grid-custom-margin" EmptyDataText="Nessun risultato!" PagerSettings-Position="Bottom" Width="100%">
                        <Columns>
                            <asp:HyperLinkField runat="server" Target="_blank" DataNavigateUrlFormatString="RefertiDettaglio.aspx?IdReferto={0}"
                                DataNavigateUrlFields="Id" Text="&lt;img src='../Images/detail.png' alt='Vai al dettaglio...' /&gt;" />
                            <asp:TemplateField ControlStyle-Width="200px" HeaderText="Sistema@Azienda-Reparto Erogante">
                                <ItemTemplate>
                                    <asp:Label Text='<%# GetAziendaSistemaRepartoDescrizione(Eval("AziendaErogante"), Eval("SistemaErogante"), Eval("RepartoErogante")) %>' runat="server" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="DataReferto" HeaderText="Data Referto" SortExpression="DataReferto"></asp:BoundField>
                        </Columns>
                        <HeaderStyle CssClass="GridHeader" />
                        <PagerStyle CssClass="GridPager" />
                        <SelectedRowStyle CssClass="GridSelected" />
                        <RowStyle CssClass="GridItem" Wrap="true" />
                        <AlternatingRowStyle CssClass="GridAlternatingItem" Wrap="true" />
                    </asp:GridView>
                    <asp:ObjectDataSource ID="odsRefertiVecchioOscuramento" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="OscuramentiDataSetTableAdapters.OscuramentiRefertiOttieniTableAdapter">
                        <SelectParameters>
                            <asp:Parameter DbType="Guid" DefaultValue="" Name="IdOscuramento"></asp:Parameter>

                        </SelectParameters>
                    </asp:ObjectDataSource>
                </div>
            </td>
        </tr>
        <tr class="tr-vertical-align">
            <td>
                <label class="label-title-custom-font">Eventi oscurati dal nuovo Oscuramento</label>
                <asp:GridView runat="server" DataSourceID="odsEventi" AutoGenerateColumns="False" AllowPaging="true"
                    CssClass="Grid grid-custom-margin" EmptyDataText="Nessun risultato!" PagerSettings-Position="Bottom" Width="100%">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <a runat="server" target="_blank" href='<%# GetDettaglioRicoveroUrl(Container.DataItem) %>'>
                                    <asp:Image runat="server" ImageUrl="~/Images/detail.png" />
                                </a>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ControlStyle-Width="200px" HeaderText="Sistema@Azienda-Reparto Erogante">
                            <ItemTemplate>
                                <asp:Label Text='<%# GetAziendaSistemaRepartoDescrizione(Eval("AziendaErogante"), Eval("SistemaErogante"), Eval("RepartoErogante")) %>' runat="server" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="DataEvento" HeaderText="Data Evento" SortExpression="DataEvento"></asp:BoundField>
                        <asp:BoundField DataField="NumeroNosologico" HeaderText="Numero Nosologico" SortExpression="NumeroNosologico"></asp:BoundField>
                    </Columns>
                    <HeaderStyle CssClass="GridHeader" />
                    <PagerStyle CssClass="GridPager" />
                    <SelectedRowStyle CssClass="GridSelected" />
                    <RowStyle CssClass="GridItem" Wrap="true" />
                    <AlternatingRowStyle CssClass="GridAlternatingItem" Wrap="true" />
                </asp:GridView>
                <asp:ObjectDataSource ID="odsEventi" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="OscuramentiDataSetTableAdapters.OscuramentiEventiOttieniTableAdapter">
                    <SelectParameters>
                        <asp:QueryStringParameter QueryStringField="Id" DbType="Guid" DefaultValue="" Name="IdOscuramento"></asp:QueryStringParameter>
                    </SelectParameters>
                </asp:ObjectDataSource>
            </td>
            <td>
                <div id="divEventiOscuramentoOld" runat="server">
                    <label class="label-title-custom-font">Eventi oscurati dal precedente Oscuramento</label>
                    <asp:GridView ID="gvListaEventiVecchioOscuramento" runat="server" DataSourceID="odsEventiVecchioOscuramento" AutoGenerateColumns="False"
                        AllowPaging="true" AllowSorting="false" CssClass="Grid grid-custom-margin" EmptyDataText="Nessun risultato!"
                        PagerSettings-Position="Bottom" Width="100%">
                        <Columns>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <a runat="server" target="_blank" href='<%# GetDettaglioRicoveroUrl(Container.DataItem) %>'>
                                        <asp:Image runat="server" ImageUrl="~/Images/detail.png" />
                                    </a>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField ControlStyle-Width="200px" HeaderText="Sistema@Azienda-Reparto Erogante">
                                <ItemTemplate>
                                    <asp:Label Text='<%# GetAziendaSistemaRepartoDescrizione(Eval("AziendaErogante"), Eval("SistemaErogante"), Eval("RepartoErogante")) %>' runat="server" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="DataEvento" HeaderText="Data Evento" SortExpression="DataEvento"></asp:BoundField>
                            <asp:BoundField DataField="NumeroNosologico" HeaderText="Numero Nosologico" SortExpression="NumeroNosologico"></asp:BoundField>
                        </Columns>
                        <HeaderStyle CssClass="GridHeader" />
                        <PagerStyle CssClass="GridPager" />
                        <SelectedRowStyle CssClass="GridSelected" />
                        <RowStyle CssClass="GridItem" Wrap="true" />
                        <AlternatingRowStyle CssClass="GridAlternatingItem" Wrap="true" />
                    </asp:GridView>
                    <asp:ObjectDataSource ID="odsEventiVecchioOscuramento" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="OscuramentiDataSetTableAdapters.OscuramentiEventiOttieniTableAdapter">
                        <SelectParameters>
                            <asp:Parameter DbType="Guid" DefaultValue="" Name="IdOscuramento"></asp:Parameter>
                        </SelectParameters>
                    </asp:ObjectDataSource>
                </div>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <div class="btn-custom-align">
                    <asp:Button ID="btnOk" Text="Ok" CssClass="Button btn-ok" runat="server" />
                    <asp:Button ID="btnAnnulla" Text="Annulla" CssClass="Button" runat="server" OnClientClick="return confirm('Annullando l\'operazione l\'oscuramento non verrà completato. Continuare comunque?');" />
                </div>
            </td>
        </tr>
    </table>

</asp:Content>
