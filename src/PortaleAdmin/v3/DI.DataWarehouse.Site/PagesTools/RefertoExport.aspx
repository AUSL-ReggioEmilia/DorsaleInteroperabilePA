<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="RefertoExport.aspx.vb" Inherits=".RefertoExport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="lblError" runat="server" CssClass="Error" EnableViewState="False" Visible="False"></asp:Label>
    <label class="Title">Esportazione referto</label>

    <div id="MainContainer" runat="server" width="100%">

        <%-- PANNELLO FILTRI --%>
        <div id="filterPanel" runat="server" style="width: 700px;">
            <fieldset class="filters">
                <legend>Ricerca</legend>
                <table>
                    <tr>
                        <td>IdReferto</td>
                        <td></td>
                    </tr>
                    <tr>
                        <td>
                            <asp:TextBox ID="txtIdReferto" runat="server" MaxLength="40" Width="300px"></asp:TextBox>
                        </td>
                        <td style="padding-left: 10px;">
                            <asp:Button ID="btnCerca" Text="Cerca" runat="server" CssClass="Button" OnClientClick="ChangeCursor()" />
                        </td>
                    </tr>
                </table>
            </fieldset>
        </div>

        <table style="width: 700px;" id="tblRefertoDaEsportare" runat="server">
            <tr>
                <td>
                    <fieldset class="filters">
                        <legend>REFERTO DA ESPORTARE</legend>
                        <asp:FormView runat="server" DataSourceID="odsReferto" ID="FormView">
                            <ItemTemplate>
                                <fieldset class="filters">
                                    <legend>Paziente</legend>
                                    <table class="table_dettagli" style="width: 100%">
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
                                    <table class="table_dettagli" style="width: 100%">
                                        <tr class="fv-table-row-height">
                                            <td class="Td-Text" style="width: 10% !important;">Data Inserimento:</td>
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
                                            <td class="Td-Text">Azienda Erogante:</td>
                                            <td class="Td-Value">
                                                <asp:Label CssClass="fv-text-bold" Text='<%# Eval("AziendaErogante") %>' runat="server" ID="Label9" />
                                            </td>
                                            <td class="Td-Text">Sistema Erogante:</td>
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
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                        </tr>
                                        <tr class="fv-table-row-height">
                                            <td class="Td-Text">Numero Prenotazione</td>
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
                                            <td></td>
                                        </tr>
                                        <tr class="fv-table-row-height">
                                            <td class="Td-Text">Id Paziente:</td>
                                            <td colspan="2" class="Td-Value">
                                                <asp:Label Text='<%# Bind("IdPaziente") %>' runat="server" ID="Label15" />
                                            </td>
                                            <td class="Td-Text">Id Esterno:</td>
                                            <td colspan="2" class="Td-Value">
                                                <asp:Label Text='<%# Bind("IdEsterno") %>' runat="server" ID="Label13" /><br />
                                            </td>
                                            <td></td>
                                            <td></td>
                                        </tr>
                                    </table>
                                </fieldset>
                            </ItemTemplate>
                        </asp:FormView>
                    </fieldset>
                </td>
            </tr>
            <tr>
                <td>
                    <div style="text-align: right;">
                        <asp:Button ID="btnEsporta" Text="Esporta" CssClass="Button btn-ok" runat="server" />
                    </div>
                </td>
            </tr>
        </table>
    </div>
    <asp:ObjectDataSource ID="odsReferto" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetDataBy" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.BeRefertiListaTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="IdReferto" DbType="Guid"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <script type="text/javascript">
        function ChangeCursor() {
            $("body").css("cursor", "progress");
        };

        function ResetCursor() {
            $("body").css("cursor", "auto");
        }

        $(document).ready(function () {
            ResetCursor();
        });
    </script>
</asp:Content>

