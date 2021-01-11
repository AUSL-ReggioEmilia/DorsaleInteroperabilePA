<%@ Page Title="Ordini" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
  CodeBehind="AbbonamentiStampe.aspx.vb" Inherits="DI.DataWarehouse.Admin.AbbonamentiStampe" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
  <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
    Visible="False"></asp:Label>
  <div style="padding: 3px;">
    <input type="button" id="NuovoButton" class="newButton" value="Nuovo" style="width: 80px"
      onclick="location.href='AbbonamentiStampeDettaglio.aspx'; return false;" />
  </div>
  <div id="filterPanel" runat="server">
    <fieldset class="filters">
      <legend>Ricerca</legend>
      <table class="tablefiltri">
        <tr>
          <td>
            Nome
          </td>
          <td>
            Account
          </td>
          <td>
            Data fine al
          </td>
          <td>
            Tipo referto
          </td>
          <td>
          </td>
        </tr>
        <tr>
          <td>
            <asp:TextBox ID="NomeTextBox" runat="server" Width="150px"></asp:TextBox>
          </td>
          <td>
            <asp:TextBox ID="AccountTextBox" runat="server" Width="150px"></asp:TextBox>
          </td>
          <td>
            <asp:TextBox ID="DataFineAlTextBox" CssClass="DateInput" runat="server" Width="150px"></asp:TextBox>
          </td>
          <td>
            <asp:DropDownList ID="TipoRefertoDropDownList" runat="server" DataSourceID="TipoRefertoObjectDataSource"
              DataTextField="Descrizione" DataValueField="Id" Width="150px">
            </asp:DropDownList>
          </td>
          <td>
          </td>
        </tr>
        <tr>
          <td>
            Server di stampa
          </td>
          <td>
            Stampante
          </td>
          <td>
            Stato
          </td>
          <td>
            &nbsp;
          </td>
          <td>
          </td>
        </tr>
        <tr>
          <td>
            <asp:TextBox ID="ServerDiStampaTextBox" runat="server" Width="150px"></asp:TextBox>
          </td>
          <td>
            <asp:TextBox ID="StampanteTextBox" runat="server" Width="150px"></asp:TextBox>
          </td>
          <td>
            <asp:DropDownList ID="StatoDropDownList" runat="server" DataSourceID="StatoObjectDataSource"
              DataTextField="Descrizione" DataValueField="Id" Width="150px">
            </asp:DropDownList>
          </td>
          <td>
            &nbsp;
          </td>
          <td style="padding-left: 10px;">
            <asp:Button ID="SearchButton" Text="Cerca" runat="server" CssClass="Button" />
          </td>
        </tr>
      </table>
    </fieldset>
  </div>
  <div id="gridPanel">
    <asp:GridView ID="StampeGridView" runat="server" AllowPaging="True" AllowSorting="True"
      CssClass="Grid" AutoGenerateColumns="False" DataSourceID="RefertiListaObjectDataSource"
      EnableModelValidation="True" PageSize="100" DataKeyNames="Id" Width="100%">
      <HeaderStyle CssClass="GridHeader" />
      <PagerStyle CssClass="GridPager" />
      <SelectedRowStyle CssClass="GridSelected" />
      <RowStyle CssClass="GridItem" />
      <AlternatingRowStyle CssClass="GridAlternatingItem" />
      <Columns>
        <asp:TemplateField HeaderText="">
          <ItemStyle Width="30px" />
          <ItemTemplate>
            <a id="DettaglioHyperLink" href='<%# String.Format("AbbonamentiStampeDettaglio.aspx?Id={0}", Eval("Id"))%>'>
              <img src='../Images/detail.png' alt="Vai al dettaglio..." title="Vai al dettaglio..." /></a>
          </ItemTemplate>
        </asp:TemplateField>
        <asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome" ReadOnly="True" />
        <asp:BoundField DataField="Account" HeaderText="Account" SortExpression="Account" />
        <%--<asp:BoundField DataField="DataInizio" HeaderText="DataInizio" SortExpression="DataInizio" />--%>
        <asp:BoundField DataField="DataFine" HeaderText="Data fine" SortExpression="DataFine" />
        <asp:BoundField DataField="TipoReferti" HeaderText="Tipo referto" SortExpression="TipoReferti"
          ReadOnly="True" />

        <asp:TemplateField HeaderText="Stampa<br/>Confidenziali" SortExpression="StampaConfidenziali">
          <ItemTemplate>
            <asp:Image ID="Image1" runat="server"  ImageUrl='<%#GetChecked(Eval("StampaConfidenziali")) %>' />
          </ItemTemplate>
        </asp:TemplateField>
        <asp:TemplateField HeaderText="Stampa<br/>Oscurati" SortExpression="StampaOscurati">
          <ItemTemplate>
            <asp:Image ID="Image1" runat="server"  ImageUrl='<%#GetChecked(Eval("StampaOscurati")) %>' />
          </ItemTemplate>
        </asp:TemplateField>
        <asp:BoundField DataField="Stato" HeaderText="Stato" SortExpression="Stato" ReadOnly="True" />
        <asp:TemplateField HeaderText="Stampante" SortExpression="Stampante">
          <ItemTemplate>
            <%# String.Format("{0}\{1}", Eval("ServerDiStampa"),  Eval("Stampante")) %>
          </ItemTemplate>
        </asp:TemplateField>
        <asp:BoundField DataField="NumeroCopie" HeaderText="Numero copie" SortExpression="NumeroCopie" ReadOnly="True" />
        <asp:TemplateField HeaderText="">
          <ItemTemplate>
            <input type="button" id="CambiaAttivazioneButton_<%# Eval("Id") %>" value='<%# GetCambiaAttivazioneButtonText(Eval("IdStato")) %>'
              onclick='<%# String.Format("cambiaAttivazione(""{0}"",{1}); $(""#{2}"").click(); return false;", Eval("Id"), Eval("IdStato"), SearchButton.ClientId) %>'
              style="" style='<%# String.Format("width: 80px; cursor: pointer; display:{0};", IF(GetCambiaAttivazioneButtonText(Eval("IdStato")) = String.Empty, "none","block")) %>' />
          </ItemTemplate>
        </asp:TemplateField>
        <asp:TemplateField HeaderText="">
          <ItemTemplate>
            <input type="button" id="EliminaButton_<%# Eval("Id") %>" class="deleteButton" style="width: 22px"
              title="elimina" onclick='<%# String.Format("elimina(""{0}""); return false;", Eval("Id")) %>' />
          </ItemTemplate>
        </asp:TemplateField>
      </Columns>
    </asp:GridView>
    <asp:ObjectDataSource ID="RefertiListaObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
      SelectMethod="GetData" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.StampeSottoscrizioniListaTableAdapter"
      DeleteMethod="Delete">
      <DeleteParameters>
        <asp:Parameter DbType="Guid" Name="Id" />
        <asp:Parameter Name="Ts" Type="Object" />
      </DeleteParameters>
      <SelectParameters>
        <asp:ControlParameter ControlID="NomeTextBox" Name="Nome" PropertyName="Text" Type="String" />
        <asp:ControlParameter ControlID="AccountTextBox" Name="Account" PropertyName="Text"
          Type="String" />
        <asp:ControlParameter ControlID="DataFineAlTextBox" Name="DataFineAl" PropertyName="Text"
          Type="DateTime" />
        <asp:ControlParameter ControlID="TipoRefertoDropDownList" Name="IdTipoReferti" PropertyName="SelectedValue"
          Type="Int32" />
        <asp:ControlParameter ControlID="ServerDiStampaTextBox" Name="ServerDiStampa" PropertyName="Text"
          Type="String" />
        <asp:ControlParameter ControlID="StampanteTextBox" Name="Stampante" PropertyName="Text"
          Type="String" />
        <asp:ControlParameter ControlID="StatoDropDownList" Name="IdStato" PropertyName="SelectedValue"
          Type="Int32" />
        <asp:Parameter  Name="IdTipoSottoscrizione"
                Type="Int32" DefaultValue="1"/>
      </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="TipoRefertoObjectDataSource" runat="server" SelectMethod="GetTipiRefertiLista"
      TypeName="DI.DataWarehouse.Admin.Data.DataAdapterManager" OldValuesParameterFormatString="original_{0}"
      EnableCaching="True">
      <SelectParameters>
        <asp:Parameter DefaultValue="true" Name="addEmpty" Type="Boolean" />
      </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="StatoObjectDataSource" runat="server" SelectMethod="GetStatiSottoscrizioniLista"
      TypeName="DI.DataWarehouse.Admin.Data.DataAdapterManager" OldValuesParameterFormatString="original_{0}"
      EnableCaching="True">
      <SelectParameters>
        <asp:Parameter DefaultValue="true" Name="addEmpty" Type="Boolean" />
      </SelectParameters>
    </asp:ObjectDataSource>
  </div>
  <script src="../Scripts/abbonamenti-stampe.js" type="text/javascript"></script>
  <script type="text/javascript">

        
  </script>
</asp:Content>
