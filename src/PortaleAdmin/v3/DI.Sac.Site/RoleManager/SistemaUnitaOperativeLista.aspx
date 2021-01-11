<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="SistemaUnitaOperativeLista.aspx.vb" Inherits=".SistemaUnitaOperativeLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <script type="text/javascript" src="../Scripts/PopUp.js"></script>
    <script>
        function PopUp_AttributiInserisci(IdSistema) {
            commonModalDialogOpen('AttributiInserisci.aspx?IDSistema=' + IdSistema + '&Id=' + $.QueryString['Id'], '', 580, 360);
            return false;
        }
    </script>

    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
        Visible="False"></asp:Label>
    <asp:Label ID="lblTitolo" runat="server" class="Title" Text=""></asp:Label>

    <table id="pannelloFiltri" runat="server" class="toolbar">
        <tr>
            <td colspan="7">
                <br />
            </td>
        </tr>
        <tr>
            <td>Codice
            </td>
            <td>
                <asp:TextBox ID="txtFiltriCodice" runat="server" Width="120px" MaxLength="16"></asp:TextBox>
            </td>
            <td>Descrizione<br />
            </td>
            <td>
                <asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="120px" MaxLength="128"></asp:TextBox>
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

    <table class="table_pulsanti" width="100%">
        <tr>
            <td class="Left">
                <asp:Button ID="butEliminaTop" runat="server" Text="Elimina Selezionati" CssClass="TabButton"
                    CommandName="Delete" OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione degli elementi selezionati?');"
                    ValidationGroup="none" Width="10em" />
                <asp:Button ID="butAggiungiTop" runat="server" Text="Aggiungi..." CssClass="TabButton"
                    CommandName="Insert" />
                <asp:Button ID="butConfermaTop" runat="server" Text="Aggiungi Selezionati" CssClass="TabButton"
                    Style="width: 140px;" CommandName="Insert" />
            </td>
            <td class="Right">
                <asp:Button ID="butAnnullaTop" runat="server" CommandName="Cancel" Text="Chiudi"
                    CssClass="TabButton" ValidationGroup="none" />
            </td>
        </tr>
    </table>

    <asp:GridView ID="gvLista" runat="server" DataSourceID="odsRuoli" AutoGenerateColumns="False" DataKeyNames="ID,IDRuolo,IdUnitaOperativa"
        AllowPaging="True" AllowSorting="True" GridLines="Horizontal"
                PageSize="100" Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!"
                PagerSettings-Position="TopAndBottom"
                CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow" PagerStyle-CssClass="Pager">
        <Columns>
            <asp:TemplateField ItemStyle-Width="30px">
				<HeaderTemplate>
					<asp:CheckBox ID="chkboxSelectAll" runat="server" AutoPostBack="true" OnCheckedChanged="chkboxSelectAll_CheckedChanged" />
				</HeaderTemplate>
				<ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
				<ItemTemplate>
					<asp:CheckBox ID="CheckBox" runat="server"></asp:CheckBox>
				</ItemTemplate>
			</asp:TemplateField>
            <%--<asp:BoundField DataField="IDRuolo" HeaderText="IDRuolo" ReadOnly="True" SortExpression="IDRuolo"></asp:BoundField>--%>
            <asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"></asp:BoundField>
            <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
        </Columns>
    </asp:GridView>

    <table class="table_pulsanti" width="100%">
        <tr>
            <td class="Left">
                <asp:Button ID="butElimina" runat="server" Text="Elimina Selezionati" CssClass="TabButton"
                    CommandName="Delete" OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione degli elementi selezionati?');"
                    ValidationGroup="none" Width="10em" />
                <asp:Button ID="butAggiungi" runat="server" Text="Aggiungi..." CssClass="TabButton"
                    CommandName="Insert" />
                <asp:Button ID="butConferma" runat="server" Text="Aggiungi Selezionati" CssClass="TabButton"
                    Style="width: 140px;" CommandName="Insert" />
            </td>
            <td class="Right">
                <asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="TabButton"
                    ValidationGroup="none" />
            </td>
        </tr>
    </table>

    <asp:ObjectDataSource ID="odsRuoli" runat="server" CacheDuration="120" CacheKeyDependency="CacheRuoloSistemi" DeleteMethod="Delete" EnableCaching="True" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="OrganigrammaDataSetTableAdapters.RuoliCercaPerUnitaOperativaTableAdapter">
        <InsertParameters>
            <asp:Parameter Name="UtenteInserimento" Type="String"></asp:Parameter>
            <asp:Parameter DbType="Guid" Name="IdRuolo"></asp:Parameter>
            <asp:Parameter DbType="Guid" Name="IdUnitaOperativa"></asp:Parameter>
        </InsertParameters>
        <SelectParameters>
            <asp:QueryStringParameter DbType="Guid" Name="IdUnitaOperativa" QueryStringField="IdUnita"></asp:QueryStringParameter>
            <asp:ControlParameter ControlID="txtFiltriCodice" Name="CodiceRuolo" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtFiltriDescrizione" Name="DescrizioneRuolo" Type="String"></asp:ControlParameter>
            <asp:Parameter Name="Top" Type="Int32"></asp:Parameter>
        </SelectParameters>
        <DeleteParameters>
			<asp:Parameter DbType="Guid" Name="Id" />
		</DeleteParameters>
    </asp:ObjectDataSource>

</asp:Content>
