<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="RuoliCopiaDaSistema.aspx.vb" Inherits=".RuoliCopiaDaSistema" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
        Visible="False" />
    <table id="pannelloFiltri" runat="server" class="toolbar">
        <tr>
            <td><br /></td>
        </tr>
        <tr>
            <td>Azienda
            </td>
            <td>
                <asp:DropDownList ID="ddlFiltriAzienda" runat="server" Width="120px" AppendDataBoundItems="True"
                    DataSourceID="odsAziende" DataTextField="Descrizione" DataValueField="Codice">
                    <asp:ListItem Text="" Value="" />
                </asp:DropDownList>
            </td>
            <td>Codice
            </td>
            <td>
                <asp:TextBox ID="txtFiltriCodice" runat="server" Width="120px" MaxLength="16" />
            </td>
            <td>Descrizione
            </td>
            <td>
                <asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="120px" MaxLength="128" />
            </td>
            <td width="100%">
                <asp:Button ID="butFiltriRicerca" runat="server" CssClass="TabButton" Text="Cerca" />
            </td>
        </tr>
        <tr>
            <td colspan="7">
                <br />
            </td>
        </tr>
    </table>
    <br />

    <table class="table_pulsanti" width="100%">
        <tr>
            <td class="Left">
                <asp:Button ID="butAggiungiTop" runat="server" Text="Aggiungi..." CssClass="TabButton"
                    CommandName="Insert" />
            </td>
            <td class="Right">
                <asp:Button ID="butAnnullaTop" runat="server" CommandName="Cancel" Text="Chiudi"
                    CssClass="TabButton" ValidationGroup="none" />
            </td>
        </tr>
    </table>

    <asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="True"
        DataSourceID="odsLista" GridLines="Horizontal" AutoGenerateColumns="false" PageSize="100"
        Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom"
        DataKeyNames="Id" CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
        PagerStyle-CssClass="Pager">
        <Columns>
            <asp:TemplateField ItemStyle-Width="10px">
                <ItemTemplate>
                    <asp:CheckBox ID="gvCheckList" ClientIDMode="Static" runat="server" AutoPostBack="false" onClick="Check(this);" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"
                ItemStyle-Width="150px"/>
            <%--<asp:HyperLinkField DataTextField="Codice" DataNavigateUrlFormatString="SistemiDettaglio.aspx?id={0}"
                DataNavigateUrlFields="Id" HeaderText="Codice" SortExpression="Codice" ItemStyle-Width="150px" />--%>
            <asp:BoundField DataField="CodiceAzienda" HeaderText="Codice Azienda" SortExpression="CodiceAzienda"
                ItemStyle-Width="70px" />
            <asp:CheckBoxField DataField="Attivo" HeaderText="Attivo" ReadOnly="True" SortExpression="Attivo"
                ItemStyle-Width="60px" />
            <asp:CheckBoxField DataField="Erogante" HeaderText="Erogante" ReadOnly="True" SortExpression="Erogante"
                ItemStyle-Width="60px" />
            <asp:CheckBoxField DataField="Richiedente" HeaderText="Richiedente" ReadOnly="True"
                SortExpression="Richiedente" ItemStyle-Width="60px" />
            <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
        </Columns>
    </asp:GridView>

    <table class="table_pulsanti" width="100%">
        <tr>
            <td class="Left">
                <asp:Button ID="butAggiungi" runat="server" Text="Aggiungi..." CssClass="TabButton"
                    CommandName="Insert" />
            </td>
            <td class="Right">
                <asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="TabButton"
                    ValidationGroup="none" />
            </td>
        </tr>
    </table>


    <asp:HiddenField ID="hdnCheckedCount" runat="server" Value="0" />

    <asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="OrganigrammaDataSetTableAdapters.SistemiTableAdapter">
        <SelectParameters>
            <asp:ControlParameter ControlID="txtFiltriCodice" Name="Codice" PropertyName="Text"
                Type="String" />
            <asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text"
                Type="String" />
            <asp:Parameter Name="Erogante" Type="Boolean" />
            <asp:Parameter Name="Richiedente" Type="Boolean" />
            <asp:ControlParameter ControlID="ddlFiltriAzienda" Name="CodiceAzienda" PropertyName="SelectedValue"
                Type="String" />
            <asp:Parameter Name="Top" Type="Int32" DefaultValue="1000" />
            <asp:Parameter Name="Attivo" Type="Boolean" DefaultValue="" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="odsAziende" runat="server" OldValuesParameterFormatString="{0}"
        SelectMethod="AziendeLista" TypeName="OrganigrammaDataSetTableAdapters.AziendeListaTableAdapter"
        CacheDuration="120" CacheKeyDependency="CacheAziende" EnableCaching="True"></asp:ObjectDataSource>

    <script type="text/javascript">

        /*
        *   FUNZIONE CHIAMATA AL CLICK SULLE CHECKBOX CONTENUTE NELLA GRIGLIA.
        *   EVITA CHE VENGANO SELEZIONATI PIù ITEM.
        */
        function Check(objCheckbox) {
            if (objCheckbox.checked == true) {
                if (document.getElementById('<%=hdnCheckedCount.ClientID %>').value >= 1) {
                    alert("E' possibile selezionare solo un sistema.");
                    objCheckbox.checked = false;
                }
                else {
                    document.getElementById('<%=hdnCheckedCount.ClientID %>').value = parseInt(document.getElementById('<%=hdnCheckedCount.ClientID %>').value) + 1;
                }
            }
            else {
                document.getElementById('<%=hdnCheckedCount.ClientID %>').value = parseInt(document.getElementById('<%=hdnCheckedCount.ClientID %>').value) - 1;
            }
        };
  
    </script>
</asp:Content>
