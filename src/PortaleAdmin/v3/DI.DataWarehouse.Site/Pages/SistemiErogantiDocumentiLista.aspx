<%@ Page Language="VB" MasterPageFile="~/Site.Master" AutoEventWireup="false" CodeBehind="SistemiErogantiDocumentiLista.aspx.vb"
  Inherits="DI.DataWarehouse.Admin.SistemiErogantiDocumentiLista" Title="Untitled Page" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="Server">
  <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"></asp:Label>
  <div style="padding: 3px">
    <asp:Button ID="NewButton" runat="server" CssClass="newbutton" Text="Nuovo" Width="80px" />
  </div>
  <div>
    <fieldset class="filters">
      <legend>Ricerca</legend>
      <div>
        <span>Azienda erogante</span><br />
        <asp:TextBox ID="AziendaEroganteTextBox" runat="server" Width="250px"></asp:TextBox>
      </div>
      <div>
        <br />
        <asp:Button ID="SearchButton" CssClass="Button" runat="server" Text="Cerca" />
      </div>
    </fieldset>
  </div>
  <div>
    <asp:Label Visible="False" ID="NoRecordFoundLabel" runat="server" EnableViewState="False"></asp:Label>
  </div>
  <asp:GridView ID="GridViewMain" runat="server" AllowPaging="True" AllowSorting="True"
    DataSourceID="DataSourceMain" AutoGenerateColumns="False" PageSize="100" CssClass="Grid"
    DataKeyNames="Id" Width="100%" EnableModelValidation="True">
    <Columns>
      <asp:TemplateField HeaderText="">
        <ItemStyle Width="30px" />
        <ItemTemplate>
          <a id="DettaglioHyperLink" href='<%# String.Format("SistemiErogantiDocumentiDettaglio.aspx?Id={0}", Eval("Id"))%>'>
            <img src='../Images/detail.png' alt="Vai al dettaglio..." title="Vai al dettaglio..." /></a>
        </ItemTemplate>
      </asp:TemplateField>
      <asp:BoundField DataField="AziendaErogante" HeaderText="Azienda Erogante" SortExpression="AziendaErogante">
      </asp:BoundField>
      <asp:BoundField DataField="SistemaErogante" HeaderText="Sistema Erogante" SortExpression="SistemaErogante">
      </asp:BoundField>
      <asp:TemplateField HeaderText="Documento" SortExpression="Nome">
        <ItemTemplate>
          <asp:HyperLink ID="DettaglioLink" runat="server" NavigateUrl='<%# GetViewerUrl(Eval("Id")) %>'
            Text='<%# Eval("Nome") %>' Target="_blank"></asp:HyperLink>
        </ItemTemplate>
      </asp:TemplateField>
      <asp:BoundField DataField="Dimensione" HeaderText="Dimensione (Byte)" SortExpression="Dimensione">
        <ItemStyle HorizontalAlign="Right" Width="70px" />
      </asp:BoundField>
    </Columns>
    <RowStyle CssClass="GridItem" />
    <SelectedRowStyle CssClass="GridSelected" />
    <PagerStyle CssClass="GridPager" />
    <HeaderStyle CssClass="GridHeader" />
    <AlternatingRowStyle CssClass="GridAlternatingItem" />
    <FooterStyle CssClass="GridFooter" />
  </asp:GridView>
  <asp:ObjectDataSource ID="DataSourceMain" runat="server" SelectMethod="SistemiErogantiDocumentiLista"
    TypeName="DI.DataWarehouse.Admin.Data.DataAdapterManager" OldValuesParameterFormatString="original_{0}">
    <SelectParameters>
      <asp:ControlParameter ControlID="AziendaEroganteTextBox" Name="AziendaErogante" PropertyName="Text"
        Type="String" />
    </SelectParameters>
  </asp:ObjectDataSource>
  
</asp:Content>
