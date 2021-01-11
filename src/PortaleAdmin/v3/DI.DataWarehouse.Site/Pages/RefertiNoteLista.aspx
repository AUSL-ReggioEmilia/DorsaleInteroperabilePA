<%@ Page Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeBehind="RefertiNoteLista.aspx.vb"
  Inherits="DI.DataWarehouse.Admin.RefertiNoteLista" Title="Untitled Page" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="Server">
  
  <script src="../Scripts/referti-note-lista.js" type="text/javascript"></script>
  <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"></asp:Label>
  <div id="filterPanel" runat="server">
    <fieldset class="filters">
      <legend>Ricerca</legend>
      <table class="tablefiltri">
        <tr>
          <td>
            Numero referto
          </td>
          <td >
            Nosologico
          </td>
          <td colspan="2">
            Data Inserimento (dal / al)
          </td>
          <td>
          </td>
        </tr>
        <tr>
          <td>
            <asp:TextBox ID="NumeroRefertoTextBox" runat="server" Width="150px"></asp:TextBox>
          </td>
          <td>
            <asp:TextBox ID="NosologicoTextBox" runat="server" Width="150px"></asp:TextBox>
          </td>
          <td>
            <asp:TextBox ID="DataDalTextBox" CssClass="DateTimeInput" runat="server" Width="90px"></asp:TextBox>           
            
          </td>
          <td>
            <asp:TextBox ID="DataAlTextBox" CssClass="DateTimeInput" runat="server" Width="90px"></asp:TextBox>
            </td>
          <td>
          </td>
        </tr>
        <tr>
          <td colspan="2">
            <asp:CheckBox ID="VisualizzaNoteCancellateCheckBox" runat="server" Text="Visualizza anche le note cancellate" Width="300px" />
          </td>
          <td colspan="2">
          </td>
          <td>
            <asp:Button ID="CercaButton" runat="server" CssClass="Button" Text="Cerca" />
          </td>
        </tr>
      </table>
    </fieldset>
  </div>
  <asp:Label ID="NoRecordFoundLabel" runat="server"></asp:Label>
  <asp:GridView ID="GridViewMain" runat="server" AllowPaging="True" AllowSorting="True"
    DataSourceID="DataSourceMain" AutoGenerateColumns="False" PageSize="100" CssClass="Grid"
    Width="100%">
    <RowStyle CssClass="GridItem" />
    <SelectedRowStyle CssClass="GridSelected" />
    <PagerStyle CssClass="GridPager" />
    <HeaderStyle CssClass="GridHeader" />
    <AlternatingRowStyle CssClass="GridAlternatingItem" />
    <FooterStyle CssClass="GridFooter" />
    <Columns>
      <asp:TemplateField HeaderText="">
        <ItemStyle Width="30px" />
        <ItemTemplate>
          <a href='<%# String.Format("RefertiNoteDettaglio.aspx?Id={0}", Eval("IdRefertiNote"))%>'>
            <img src='../Images/detail.png' alt="Vai al dettaglio..." title="Vai al dettaglio..." /></a>
        </ItemTemplate>
      </asp:TemplateField>
      <asp:BoundField DataField="Utente" HeaderText="Utente" SortExpression="Utente">
        <ItemStyle HorizontalAlign="Center" Wrap="False" />
      </asp:BoundField>
      <asp:BoundField DataField="DataInserimento" DataFormatString="{0:d}" HeaderText="Data Inserimento"
        SortExpression="DataInserimento">
        <ItemStyle HorizontalAlign="Center" Wrap="False" />
      </asp:BoundField>
      <asp:BoundField DataField="Nota" HeaderText="Nota" ReadOnly="True" SortExpression="Nota" />
      <asp:TemplateField HeaderText="Cancellata">
        <ItemTemplate>
          <asp:Image ID="imgCancellata" runat="server" ImageUrl="../Images/ok.png" Visible='<%# Eval("Cancellata") %>' />
        </ItemTemplate>
        <ItemStyle HorizontalAlign="Center" Wrap="False" />
      </asp:TemplateField>
      <asp:BoundField DataField="NumeroNosologico" HeaderText="Nosologico" SortExpression="NumeroNosologico">
        <ItemStyle HorizontalAlign="Center" Wrap="False" />
      </asp:BoundField>
      <asp:HyperLinkField DataNavigateUrlFields="IdReferti" DataNavigateUrlFormatString="~/Referti/RefertiDettaglio.aspx?IdReferto={0}"
        DataTextField="NumeroReferto" HeaderText="Numero referto" SortExpression="NumeroReferto" />
    </Columns>
  </asp:GridView>
  <asp:ObjectDataSource ID="DataSourceMain" runat="server" SelectMethod="GetDataRefertiNoteLista"
    TypeName="DI.DataWarehouse.Admin.Data.DataAdapterManager" OldValuesParameterFormatString="original_{0}">
    <SelectParameters>
      <asp:Parameter Name="NumeroReferto" Type="String" />
      <asp:Parameter Name="NumeroNosologico" Type="String" />
      <asp:Parameter Name="DataDal" Type="DateTime" />
      <asp:Parameter Name="DataAl" Type="DateTime" />
      <asp:Parameter Name="VisualizzaNoteCancellate" Type="Boolean" />
    </SelectParameters>
  </asp:ObjectDataSource>
</asp:Content>
