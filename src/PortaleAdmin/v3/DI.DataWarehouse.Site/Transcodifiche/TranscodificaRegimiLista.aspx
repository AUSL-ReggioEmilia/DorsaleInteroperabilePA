<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="TranscodificaRegimiLista.aspx.vb" Inherits=".TranscodificaRegimiLista" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">

    <asp:Label ID="lblError" runat="server" CssClass="Error" EnableViewState="False" Visible="False"></asp:Label>

    <%-- PANNELLO FILTRI --%>
    <div id="filterPanel" runat="server">
        <div style="padding: 3px">
            <asp:Button ID="NewButton" CssClass="newbutton" runat="server" Text="Nuovo" TabIndex="10"
                Width="80px" />
        </div>
        <fieldset class="filters">
            <legend>Ricerca</legend>
            <table>
                <tr>
                    <td>Azienda Erogante
                    </td>
                    <td>Sistema Erogante
                    </td>
                    <td>Codice esterno
                    </td>
                    <td>&nbsp;
                    </td>
                    <td>&nbsp;
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:DropDownList ID="ddlAziendeEroganti" runat="server"  DataTextField="Descrizione"
                            DataValueField="Codice" Width="210px" AutoPostBack="True">
                        </asp:DropDownList>
                    </td>
                    <td>
                        <asp:DropDownList ID="ddlSistemiEroganti" runat="server"  DataTextField="Descrizione"
                            DataValueField="Codice" Width="210px">
                        </asp:DropDownList>
                    </td>
                    <td>
                        <asp:TextBox ID="txtCodiceEsterno" runat="server"></asp:TextBox>
                    </td>
                    <td style="padding-left: 10px;">
                        <asp:Button ID="SearchButton" Text="Cerca" runat="server" CssClass="Button" CausesValidation="true" />
                    </td>
                </tr>
            </table>
        </fieldset>
    </div>

    <%-- TABELLA Regimi --%>
    <asp:GridView ID="gvTranscodificaRegimi" runat="server" DataSourceID="odsTranscodificaRegimi" AllowPaging="True" AllowSorting="True" CssClass="Grid" AutoGenerateColumns="False" DataKeyNames="Id" PageSize="100" PagerSettings-Position="TopAndBottom">
        <HeaderStyle CssClass="GridHeader" />
        <PagerStyle CssClass="GridPager" />
        <SelectedRowStyle CssClass="GridSelected" />
        <RowStyle CssClass="GridItem" Wrap="true" />
        <AlternatingRowStyle CssClass="GridAlternatingItem" Wrap="true" />
        <Columns>
            <%-- BOTTONE DI DETTAGLIO --%>
            <asp:HyperLinkField runat="server" Text="&lt;img src='../Images/detail.png' alt='Vai al dettaglio...' /&gt;" DataNavigateUrlFormatString="TranscodificaRegimiDettaglio.aspx?Id={0}"
                DataNavigateUrlFields="ID" />
                  
            <%-- BOTTONE DI CANCELLAZIONE FISICA --%>
            <asp:ButtonField CommandName="Cancella" ItemStyle-CssClass="cancellaLink" Text="&lt;img src='../Images/delete.gif' alt='Cancellazione transcodifica' /&gt;" />

            <asp:BoundField DataField="AziendaErogante" HeaderText="Azienda Erogante" SortExpression="AziendaErogante"></asp:BoundField>
            <asp:BoundField DataField="SistemaErogante" HeaderText="Sistema Erogante" SortExpression="SistemaErogante"></asp:BoundField>
            <asp:BoundField DataField="CodiceEsterno" HeaderText="Codice Esterno" SortExpression="CodiceEsterno"></asp:BoundField>
            <asp:BoundField DataField="Codice" HeaderText="Codice transcodificato" SortExpression="Codice"></asp:BoundField>
            <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>

        </Columns>
        <EmptyDataTemplate>
            Nessun risultato!
        </EmptyDataTemplate>
    </asp:GridView>
        
    <asp:ObjectDataSource ID="odsTranscodificaRegimi" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetData" TypeName="TranscodificheDataSetTableAdapters.TranscodificaRegimiCercaTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="AziendaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="SistemaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="CodiceEsterno" Type="String"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>


     <script type="text/javascript">

        $(".cancellaLink").click(function () {
            return confirm('Si conferma la cancellazione della transcodifica?');
        });

      </script>

</asp:Content>
