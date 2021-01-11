<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="RefertoImport.aspx.vb" Inherits=".RefertoImport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="lblError" runat="server" CssClass="Error" EnableViewState="False" Visible="False"></asp:Label>
    <label class="Title">Importazione referto</label>

    <table id="MainContainer" class="table_dettagli" width="500px" runat="server">
        <tr>
            <td colspan="2">
                <asp:Label ID="InfoLabel" runat="server">Selezionare il file XML desiderato e premere il pulsante 'Importa'.</asp:Label>
            </td>
        </tr>
        <tr>
            <td class="Td-Text">
                <asp:Label ID="FileLabel" CssClass="UploadPageLabel" Text="File da caricare" runat="server">File: </asp:Label>
            </td>
            <td class="Td-Value">
                <input id="InputFile" style="height: 22px; width: 600px" type="file" size="50" runat="server">
            </td>
        </tr>
        <tr>
            <td colspan="2" class="RightFooter">
                <asp:Button ID="btnImporta" CssClass="Button" runat="server" Text="Importa" OnClientClick="ChangeCursor();" />
            </td>
        </tr>
    </table>
    <table id="tblDettaglioreferto" class="table_dettagli" width="500px" runat="server">
        <tr>
            <td>
                <fieldset class="filters">
                    <legend>REFERTO IMPORTATO</legend>
                    <asp:FormView runat="server" DataSourceID="odsReferto" ID="FormView">
                        <ItemTemplate>
                            <fieldset class="filters">
                                <legend>Dati Paziente</legend>
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
                                <legend>Dati Referto</legend>
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
                <!-- URL ALL'ACCESSO DIRETTO -->
                <asp:HyperLink ID="hlAccessoDirettoReferto" runat="server" Target="_blank">Apri Referto su DwhClinico</asp:HyperLink>
            </td>

        </tr>

    </table>

    <asp:ObjectDataSource ID="odsReferto" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetDataBy" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.BeRefertiListaTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="IdReferto" DbType="Guid"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>


    <script type="text/javascript">
        function ChangeCursor() {
            $("body").css("cursor", "progress");
            $("#btnImporta").attr("disabled", "disabled");
        };

        function ResetCursor() {
            $("body").css("cursor", "auto");
            $("#btnImporta").removeAttr("disabled")
        }

        $(document).ready(function () {
            ResetCursor();
        });
    </script>
</asp:Content>

