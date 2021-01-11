<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
  CodeBehind="PazientiIncoerenzaISTATDettaglio.aspx.vb" Inherits=".PazientiIncoerenzaISTATDettaglio" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
  <script type="text/javascript">
    function msgboxYESNO(MessageText) {
      var confirm_value = document.createElement("INPUT");
      var ret
      confirm_value.type = "hidden";
      confirm_value.name = "confirm_value";
      ret = confirm(MessageText);
      if (ret) { confirm_value.value = "Yes"; }
      else { confirm_value.value = "No"; }
      document.forms[0].appendChild(confirm_value);
      return ret;
    }               
  </script>
  <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
    Visible="False"></asp:Label>
  <asp:Label ID="lblTitolo" runat="server" Text="Dettaglio Incoerenza Istat" CssClass="Title"></asp:Label>
  <asp:FormView ID="FormViewDettaglio" runat="server" DataKeyNames="Id" DataSourceID="odsDettaglioIncoerenzaIstat"
    EmptyDataText="Dettaglio non disponibile." EnableModelValidation="True">
    <ItemTemplate>
      <table class="table_dettagli">
        <tr>
          <td class="Td-Text" style="width: 200px; min-width: 150px;">
            Provenienza:
          </td>
          <td class="Td-Value" style="width: 300px">
            <asp:Label ID="ProvenienzaLabel" runat="server" Text='<%# Bind("Provenienza") %>'
              CssClass="LabelReadOnly" />
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Id Provenienza:
          </td>
          <td class="Td-Value">
            <asp:Label ID="IdProvenienzaLabel" runat="server" Text='<%# Bind("IdProvenienza") %>'
              CssClass="LabelReadOnly" />
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Codice Istat:
          </td>
          <td class="Td-Value">
            <asp:Label ID="CodiceIstatLabel" runat="server" Text='<%# Bind("CodiceIstat") %>'
              CssClass="LabelReadOnly" />
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Motivo:
          </td>
          <td class="Td-Value">
            <asp:Label ID="MotivoLabel" runat="server" Text='<%# Bind("Motivo") %>' CssClass="LabelReadOnly" />
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Generato Da:
          </td>
          <td class="Td-Value">
            <asp:Label ID="GeneratoDaLabel" runat="server" Text='<%# Bind("GeneratoDa") %>' CssClass="LabelReadOnly" />
          </td>
        </tr>
        <tr>
          <td class="Td-Text2">
            Data Inserimento:
          </td>
          <td class="Td-Value2">
            <asp:Label ID="DataInserimentoLabel" runat="server" Text='<%# Bind("DataInserimento") %>'
              CssClass="LabelReadOnly" />
          </td>
        </tr>
        <tr>
          <td class="LeftFooter">
            <asp:Button ID="butElimina" runat="server" Text="Elimina" CssClass="TabButton" CommandName="Delete"
              OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione dell\'Incoerenza Istat?');" />
          </td>
          <td class="RightFooter">
            <asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Annulla" CssClass="TabButton" />
          </td>
      </table>
    </ItemTemplate>
  </asp:FormView>
  <asp:ObjectDataSource ID="odsDettaglioIncoerenzaIstat" runat="server" SelectMethod="GetData"
    TypeName="DI.Sac.Admin.Data.PazientiIncoerenzaISTATDataSetTableAdapters.PazientiUiIncoerenzaIstatSelectTableAdapter"
    DeleteMethod="Delete" OldValuesParameterFormatString="{0}">
    <SelectParameters>
      <asp:QueryStringParameter DbType="Guid" Name="Id" QueryStringField="ID" />
    </SelectParameters>
  </asp:ObjectDataSource>
</asp:Content>
