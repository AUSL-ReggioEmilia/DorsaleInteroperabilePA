<%@ Page Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeBehind="StiliLista.aspx.vb"
    Inherits="DI.DataWarehouse.Admin.StiliLista" Title="Untitled Page" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="Server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
        Visible="False"></asp:Label>
    <div>
        <div style="padding: 3px">
            <asp:Button ID="NewButton" CssClass="newbutton" runat="server" Text="Nuovo" TabIndex="10"
                Width="80px" />
        </div>
        <fieldset class="filters">
            <legend>Ricerca</legend>
            <div>
                <span>Nome</span><br />
                <asp:TextBox ID="NomeTextBox" runat="server" Width="200px"></asp:TextBox>
            </div>
            <div>
                <span>Descrizione</span><br />
                <asp:TextBox ID="DescrizioneTextBox" runat="server" Width="200px"></asp:TextBox>
            </div>
            <div>
                <br />
                <asp:Button CssClass="Button" ID="CercaButton" runat="server" Text="Cerca" />
            </div>
        </fieldset>
    </div>
    <asp:GridView ID="GridViewMain" runat="server" AllowPaging="True" AllowSorting="True"
        DataSourceID="DataSourceMain" AutoGenerateColumns="False" PageSize="100" DataKeyNames="Id"
        CssClass="Grid" Width="100%">
        <Columns>
            <asp:TemplateField HeaderText="">
                <ItemStyle Width="30px" />
                <ItemTemplate>
                    <a href='<%# String.Format("StiliDettaglio.aspx?Id={0}", Eval("Id")) %>'>
                        <img src='../Images/detail.png' alt="Vai al dettaglio…" title="Vai al dettaglio…" /></a>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome" />
            <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
            <asp:CheckBoxField DataField="Abilitato" HeaderText="Abilitato" SortExpression="Abilitato" />
            <asp:TemplateField HeaderText="Tipo" SortExpression="Tipo">
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# GetTipo(Eval("Tipo")) %>' />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
        <RowStyle CssClass="GridItem" />
        <SelectedRowStyle CssClass="GridSelected" />
        <PagerStyle CssClass="GridPager" />
        <HeaderStyle CssClass="GridHeader" />
        <AlternatingRowStyle CssClass="GridAlternatingItem" />
        <FooterStyle CssClass="GridFooter" />
    </asp:GridView>
    <asp:ObjectDataSource ID="DataSourceMain" runat="server" SelectMethod="GetDataRefertiStiliLista"
        TypeName="DI.DataWarehouse.Admin.Data.DataAdapterManager" EnableCaching="False"
        OldValuesParameterFormatString="original_{0}">
        <SelectParameters>
            <asp:ControlParameter ControlID="NomeTextBox" Name="Nome" PropertyName="Text" Type="String" />
            <asp:ControlParameter ControlID="DescrizioneTextBox" Name="Descrizione" PropertyName="Text"
                Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
