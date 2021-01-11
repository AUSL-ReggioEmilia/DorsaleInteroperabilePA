<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="SistemiErogantiLista.aspx.vb" Inherits=".SistemiErogantiLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />

    <!-- MODIFICA ETTORE 2017-03-01:  NON SI VA IN INSERIMENTO: i sistemi vengono sincronizzati tramite un job sql-->
    <!-- <div style="padding: 3px">
        <asp:Button ID="NewButton" CssClass="newbutton" runat="server" Text="Nuovo" TabIndex="10" Width="80px" />
    </div>-->

    <fieldset runat="server" id="pannelloFiltri" class="filters">
        <legend>Ricerca</legend>
        <div>
            <span>Azienda Erogante</span><br />
            <asp:TextBox ID="txtFiltriAziendaErogante" runat="server" Width="150px"></asp:TextBox>
        </div>
        <div>
            <span>Sistema Erogante</span><br />
            <asp:TextBox ID="txtFiltriSistemaErogante" runat="server" Width="150px"></asp:TextBox>
        </div>
        <div>
            <span>Descrizione</span><br />
            <asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="150px"></asp:TextBox>
        </div>
        <div>
            <span>Attivo</span><br />
            <asp:DropDownList ID="ddlAttivo" runat="server" Width="120px">
                <asp:ListItem Text="" Value="" />
                <asp:ListItem Text="Si" Value="1" Selected="True" />
                <asp:ListItem Text="No" Value="0" />
            </asp:DropDownList>
        </div>
        <div>
            <span>Genera Anteprima Referto</span><br />
            <asp:DropDownList ID="ddlGeneraAnteprimaReferto" runat="server" Width="120px">
                <asp:ListItem Text="" Value="" Selected="true" />
                <asp:ListItem Text="Si" Value="1"/>
                <asp:ListItem Text="No" Value="0" />
            </asp:DropDownList>
        </div>
        <div>
            <br />
            <asp:Button CssClass="Button" ID="butFiltriRicerca" runat="server" Text="Cerca" />
        </div>
    </fieldset>

    <asp:GridView ID="gvSistemiEroganti" runat="server" DataSourceID="SistemiErogantiOds" DataKeyNames="Id"
        llowPaging="True" AllowSorting="true" AutoGenerateColumns="False"
        PageSize="100" CssClass="Grid" Width="100%" EmptyDataText="Nessun risultato!"
        PagerSettings-Position="TopAndBottom">
        <Columns>
            <asp:TemplateField HeaderText="">
                <ItemStyle Width="30px" />
                <ItemTemplate>
                    <a href='<%# String.Format("SistemiErogantiDettaglio.aspx?Id={0}", Eval("Id")) %>'>
                        <img src='../Images/detail.png' alt="Vai al dettaglio…" title="Vai al dettaglio…" /></a>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="AziendaErogante" HeaderText="Azienda Erogante" SortExpression="AziendaErogante"></asp:BoundField>
            <asp:BoundField DataField="SistemaErogante" HeaderText="Sistema Erogante" SortExpression="SistemaErogante"></asp:BoundField>
            <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
            <asp:BoundField DataField="RuoloVisualizzazione" HeaderText="Ruolo Visualizzazione" SortExpression="RuoloVisualizzazione"></asp:BoundField>
            <asp:BoundField DataField="EmailControlloQualitaPassivo" HeaderText="Email Controllo Qualita Passivo" SortExpression="EmailControlloQualitaPassivo"></asp:BoundField>
            <asp:CheckBoxField DataField="TipoReferti" HeaderText="Tipo Referti" SortExpression="TipoReferti"></asp:CheckBoxField>
            <asp:CheckBoxField DataField="TipoRicoveri" HeaderText="Tipo Ricoveri" SortExpression="TipoRicoveri"></asp:CheckBoxField>
            <asp:CheckBoxField DataField="TipoNoteAnamnestiche" HeaderText="Tipo Note Anamnestiche" SortExpression="TipoNoteAnamnestiche"></asp:CheckBoxField>
            <asp:BoundField DataField="LoginToSac" HeaderText="Login To Sac" SortExpression="LoginToSac"></asp:BoundField>
            <asp:BoundField DataField="RuoloManager" HeaderText="Ruolo Manager" SortExpression="RuoloManager"></asp:BoundField>
            <asp:CheckBoxField DataField="GeneraAnteprimaReferto" HeaderText="Genera Anteprima Referto" SortExpression="GeneraAnteprimaReferto"></asp:CheckBoxField>
        </Columns>
        <RowStyle CssClass="GridItem" />
        <SelectedRowStyle CssClass="GridSelected" />
        <PagerSettings Position="TopAndBottom"></PagerSettings>
        <PagerStyle CssClass="GridPager" />
        <HeaderStyle CssClass="GridHeader" />
        <AlternatingRowStyle CssClass="GridAlternatingItem" />
        <FooterStyle CssClass="GridFooter" />
    </asp:GridView>

    <asp:ObjectDataSource runat="server" ID="SistemiErogantiOds" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.BevsSistemiErogantiTableAdapter" UpdateMethod="Update" DataObjectTypeName="System.Nullable`1[[System.Guid, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]]" DeleteMethod="Delete">
        <SelectParameters>
            <asp:ControlParameter ControlID="txtFiltriAziendaErogante" PropertyName="Text" Name="AziendaErogante" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtFiltriSistemaErogante" PropertyName="Text" Name="SistemaErogante" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtFiltriDescrizione" PropertyName="Text" Name="Descrizione" Type="String"></asp:ControlParameter>
            <asp:Parameter Name="RuoloVisualizzazione" Type="String"></asp:Parameter>
            <asp:Parameter Name="EmailControlloQualitaPassivo" Type="String"></asp:Parameter>
            <asp:Parameter Name="TipoReferti" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="TipoRicoveri" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="TipoNoteAnamnestiche" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="LoginToSac" Type="String"></asp:Parameter>
            <asp:Parameter Name="RuoloManager" Type="String"></asp:Parameter>
            <asp:Parameter Name="Top" Type="Int32"></asp:Parameter>
            <asp:Parameter Name="GeneraAnteprimaReferto" Type="Boolean"></asp:Parameter>
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter DbType="Guid" Name="Id"></asp:Parameter>
            <asp:Parameter Name="RuoloVisualizzazione" Type="String"></asp:Parameter>
            <asp:Parameter Name="EmailControlloQualitaPassivo" Type="String"></asp:Parameter>
            <asp:Parameter Name="TipoReferti" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="TipoRicoveri" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="TipoNoteAnamnestiche" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="LoginToSac" Type="String"></asp:Parameter>
            <asp:Parameter Name="RuoloManager" Type="String"></asp:Parameter>
        </UpdateParameters>
    </asp:ObjectDataSource>

</asp:Content>
