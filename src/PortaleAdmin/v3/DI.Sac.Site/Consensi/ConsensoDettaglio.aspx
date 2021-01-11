<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
  CodeBehind="ConsensoDettaglio.aspx.vb" Inherits="DI.Sac.Admin.ConsensoDettaglio" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
  <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
    Visible="False"></asp:Label>
  <table class="toolbar">
    <tr>
      <td>
        <asp:HyperLink ID="lnkIndietro" runat="server" NavigateUrl="~/Pazienti/PazienteDettaglio.aspx?id={0}"><img src="../Images/back.gif" alt="Indietro" class="toolbar-img"/>Indietro</asp:HyperLink>        
        <asp:LinkButton ID="lnkElimina" runat="server" OnClientClick="return confirm('Procedere con l\'eliminazione?');"><img src="../Images/delete.gif" alt="Elimina" class="toolbar-img"/>Elimina</asp:LinkButton>
      </td>
    </tr>
  </table>
  <br />
  <table cellpadding="1" cellspacing="0" border="0">
    <asp:FormView ID="MainFormView" runat="server" DataKeyNames="Id" DataSourceID="ConsensoDettaglioObjectDataSource">
      <ItemTemplate>
        <table cellpadding="3" cellspacing="0" border="0" style="width: 500px;">
          <tr>
            <td class="toolbar" colspan="2">
              <p>
                Dettaglio Consenso</p>
              Paziente: <span class="LabelReadOnly">
                <%#Eval("PazienteCognome")%>
                <%#Eval("PazienteNome")%></span>
            </td>
          </tr>
          <tr style="height: 30px;">
            <td colspan="2">
            </td>
          </tr>
          <tr style="height: 30px;">
            <td class="Td-Text">
              Provenienza
            </td>
            <td class="Td-Value">
              <asp:Label ID="ProvenienzaLable" runat="server" Text='<%# Eval("Provenienza") %>'
                CssClass="LabelReadOnly"></asp:Label>&nbsp;
            </td>
          </tr>
          <tr style="height: 30px;">
            <td class="Td-Text">
              IdProvenienza
            </td>
            <td class="Td-Value">
              <asp:Label ID="IdProvenienzaLabel" runat="server" Text='<%# Eval("IdProvenienza") %>'
                CssClass="LabelReadOnly"></asp:Label>&nbsp;
            </td>
          </tr>
          <tr style="height: 30px;">
            <td class="Td-Text">
              Tipo
            </td>
            <td class="Td-Value">
              <asp:Label ID="TipoNomeLabel" runat="server" Text='<%# Eval("Tipo") %>' CssClass="LabelReadOnly"></asp:Label>&nbsp;
            </td>
          </tr>
          <tr style="height: 30px;">
            <td class="Td-Text">
              Data
            </td>
            <td class="Td-Value">
              <asp:Label ID="DataStatoLabel" runat="server" Text='<%# Eval("DataStato") %>' CssClass="LabelReadOnly"></asp:Label>&nbsp;
            </td>
          </tr>
          <tr style="height: 30px;">
            <td class="Td-Text">
              Stato
            </td>
            <td class="Td-Value">
              <asp:CheckBox ID="StatoCheckBox" runat="server" Checked='<%# Eval("Stato") %>' Enabled="false" />
            </td>
          </tr>
          <tr style="height: 30px;">
            <td class="Td-Text">
              Id Operatore
            </td>
            <td class="Td-Value">
              <asp:Label ID="OperatoreIdLabel" runat="server" Text='<%# Eval("OperatoreId") %>'
                CssClass="LabelReadOnly"></asp:Label>&nbsp;
            </td>
          </tr>
          <tr style="height: 30px;">
            <td class="Td-Text">
              Cognome Operatore
            </td>
            <td class="Td-Value">
              <asp:Label ID="OperatoreCognomeLabel" runat="server" Text='<%# Eval("OperatoreCognome") %>'
                CssClass="LabelReadOnly"></asp:Label>&nbsp;
            </td>
          </tr>
          <tr style="height: 30px;">
            <td class="Td-Text">
              Nome Operatore
            </td>
            <td class="Td-Value">
              <asp:Label ID="OperatoreNomeLabel" runat="server" Text='<%# Eval("OperatoreNome") %>'
                CssClass="LabelReadOnly"></asp:Label>&nbsp;
            </td>
          </tr>
          <tr style="height: 30px;">
            <td class="Td-Text2">
              Computer Operatore
            </td>
            <td class="Td-Value2">
              <asp:Label ID="OperatoreComputerLabel" runat="server" Text='<%# Eval("OperatoreComputer") %>'
                CssClass="LabelReadOnly"></asp:Label>&nbsp;
            </td>
          </tr>
          <tr>
            <td class="Td-Text2">
              Attributi
            </td>
            <td class="Td-Value2">
              <asp:Label ID="AttributiLabel" runat="server" Text='<%# ShowAttributi(Eval("Attributi")) %>'
                CssClass="LabelReadOnly"></asp:Label>&nbsp;
            </td>
          </tr>
        </table>
      </ItemTemplate>
      <EmptyDataTemplate>
        Dettaglio non disponibile!
      </EmptyDataTemplate>
    </asp:FormView>
  </table>
  <asp:ObjectDataSource ID="ConsensoDettaglioObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
    SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.ConsensiUiDataSetTableAdapters.ConsensiTableAdapter">
    <SelectParameters>
      <asp:QueryStringParameter DbType="Guid" Name="Id" QueryStringField="idConsenso" />
    </SelectParameters>
  </asp:ObjectDataSource>
</asp:Content>
