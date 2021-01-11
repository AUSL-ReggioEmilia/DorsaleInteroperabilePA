<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="EventiInviiSoleSinottico.aspx.vb" Inherits=".EventiInviiSoleSinottico" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <style type="text/css">
        /*
            STILE USATO PER INDENTARE LE SCRITTE DEI SOTTO GRUPPI
            VIENE ASSEGANTA VIA CODICE.
        */
        .Indent {
            padding-left: 20px !important;
        }


        /*SETTA LA LARGHEZZA DELLA ROW NEL CASO LA GRIGLIA SIA VUOTA.*/
        .GridFooter {
            width: 500px;
        }

            .GridFooter td {
                width: 500px;
            }
    </style>

    <%-- LABEL ERRORE --%>
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />

    <%-- FILTRI PAGINA --%>
    <fieldset class="filters">
        <table id="pannelloFiltri" runat="server">
            <tr>
                <td>Periodo
                </td>
                <td>
                    <asp:DropDownList ID="ddlFiltriPeriodo" runat="server" Width="120px" AutoPostBack="True">
                        <asp:ListItem Text="Ultima ora" Value="1" Selected="True" />
                        <asp:ListItem Text="Oggi" Value="2" />
                        <asp:ListItem Text="Ultimi 7 Giorni" Value="3" />
                        <asp:ListItem Text="Ultimi 30 Giorni" Value="4" />
                    </asp:DropDownList>
                </td>
                <td style="padding-left: 30px;">Visualizzazione
                </td>
                <td>
                    <asp:RadioButtonList runat="server" ID="rbtVisual" AutoPostBack="True">
                        <asp:ListItem Text="Compatta" Value="Compatta" Selected="True" />
                        <asp:ListItem Text="Dettagliata" Value="Dettagliata" />
                    </asp:RadioButtonList>
                </td>
            </tr>
        </table>
    </fieldset>

    <asp:GridView ID="gvLista" runat="server" DataSourceID="odsLista" AutoGenerateColumns="False" AllowSorting="false" CssClass="Grid" EnableModelValidation="True" EmptyDataText="Nessun risultato!">
        <Columns>
        <asp:BoundField DataField="AziendaSistemaErogante" HeaderText="Azienda-SistemaErogante" ItemStyle-Width="200" ItemStyle-HorizontalAlign="Left"></asp:BoundField>
            <asp:BoundField DataField="SubProcessoEsito" HeaderText="Esito Processo" ItemStyle-Width="200" ItemStyle-HorizontalAlign="Left"></asp:BoundField>
            <asp:BoundField DataField="Inviato" HeaderText="Inviato" ItemStyle-Width="60"></asp:BoundField>
            <asp:BoundField DataField="NonInviato" HeaderText="Non Inviato" ItemStyle-Width="90"></asp:BoundField>
            <asp:BoundField DataField="Processato" HeaderText="Processato" ItemStyle-Width="80"></asp:BoundField>
            <asp:BoundField DataField="EsitoNV" HeaderText="Esito NV" ItemStyle-Width="50"></asp:BoundField>
            <asp:BoundField DataField="EsitoIV" HeaderText="Esito IV" ItemStyle-Width="50"></asp:BoundField>
            <asp:BoundField DataField="EsitoNULL" HeaderText="Esito NULL" ItemStyle-Width="60"></asp:BoundField>
            <asp:BoundField DataField="EsitoAE" HeaderText="Esito AE" ItemStyle-Width="50"></asp:BoundField>
            <asp:BoundField DataField="EsitoAA" HeaderText="Esito AA" ItemStyle-Width="50"></asp:BoundField>
        </Columns>
        <RowStyle CssClass="GridItem" />
        <SelectedRowStyle CssClass="GridSelected" />
        <PagerStyle CssClass="GridPager" />
        <HeaderStyle CssClass="GridHeader" />
        <FooterStyle CssClass="GridFooter" />
        <EmptyDataRowStyle CssClass="GridFooter" />
    </asp:GridView>

    <asp:ObjectDataSource ID="odsLista" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DI.DataWarehouse.Admin.Data.SoleTableAdapters.EventiInviiSoleSinotticoTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="DataDal" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="DataAl" Type="DateTime"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
