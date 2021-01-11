<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
  CodeBehind="IstatProvinceDettaglio.aspx.vb" Inherits=".IstatProvinceDettaglio" %>

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
  <asp:Label ID="lblTitolo" runat="server" class="Title" Text="Label"></asp:Label>
  <asp:FormView ID="FormViewDettaglio" runat="server" DataKeyNames="Codice" DataSourceID="odsIstatProvinceDettaglio"
    EmptyDataText="Dettaglio non disponibile." EnableModelValidation="True" DefaultMode="Edit">
    <EditItemTemplate>
      <table class="table_dettagli">
        <tr>
          <td class="Td-Text" style="width: 200px; min-width: 200px;">
            Codice:
          </td>
          <td class="Td-Value" style="width: 300px; min-width: 300px;">
            <asp:Label ID="txtCodice" CssClass="LabelReadOnly" runat="server" Width="100%" Text='<%# Bind("Codice") %>' />
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Nome:
          </td>
          <td class="Td-Value">
            <asp:TextBox ID="txtNome" runat="server" Width="100%" Text='<%# Bind("Nome") %>' />
            <asp:RequiredFieldValidator ID="req1" class="Error" runat="server" ErrorMessage="Campo Obbligatorio"
              Display="Dynamic" ControlToValidate="txtNome" />
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Sigla:
          </td>
          <td class="Td-Value">
            <asp:TextBox ID="txtSigla" runat="server" Width="100%" MaxLength="2" Text='<%# Bind("Sigla") %>' />
            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" class="Error" runat="server"
              ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtSigla" />
          </td>
        </tr>
        <tr>
          <td class="Td-Text2">
            Regione:
          </td>
          <td class="Td-Value2">
            <asp:DropDownList ID="ddlRegione" runat="server" SelectedValue='<%# Bind("CodiceRegione") %>'
              Width="100%" DataSourceID="odsRegioni" DataTextField="Nome" DataValueField="Codice">
            </asp:DropDownList>
          </td>
        </tr>
        <tr>
          <td class="LeftFooter">
            <asp:Button ID="butElimina" runat="server" Text="Elimina" CssClass="TabButton" CommandName="Delete"
              OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione del Codice Istat?');"
              ValidationGroup="none" />
          </td>
          <td class="RightFooter">
            <asp:Button ID="butSalva" runat="server" Text="Conferma" CssClass="TabButton" CommandName="Update" />
            <asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Annulla" CssClass="TabButton"
              ValidationGroup="none" />
          </td>
        </tr>
      </table>
      <!-- ############################################################################################################# -->
    </EditItemTemplate>
    <InsertItemTemplate>
      <table class="table_dettagli">
        <tr>
          <td class="Td-Text" style="width: 200px; min-width: 200px;">
            Codice:
          </td>
          <td class="Td-Value" style="width: 300px; min-width: 300px;">
            <asp:TextBox ID="txtCodice" runat="server" Width="100%" MaxLength="3" Text='<%# Bind("Codice") %>' />
            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" class="Error" runat="server"
              ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtCodice" />
            <asp:RegularExpressionValidator ID="RegExp1" runat="server" ErrorMessage="Sono richiesti tre caratteri (lettere o numeri)."
              Display="Dynamic" class="Error" ControlToValidate="txtCodice" ValidationExpression="^[a-zA-Z0-9]{3,3}$" />
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Nome:
          </td>
          <td class="Td-Value">
            <asp:TextBox ID="txtNome" runat="server" Width="100%" Text='<%# Bind("Nome") %>' />
            <asp:RequiredFieldValidator ID="req1" class="Error" runat="server" ErrorMessage="Campo Obbligatorio"
              Display="Dynamic" ControlToValidate="txtNome" />
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Sigla:
          </td>
          <td class="Td-Value">
            <asp:TextBox ID="txtSigla" runat="server" Width="100%" MaxLength="2" Text='<%# Bind("Sigla") %>' />
            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" class="Error" runat="server"
              ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtSigla" />
          </td>
        </tr>
        <tr>
          <td class="Td-Text2">
            Regione:
          </td>
          <td class="Td-Value2">
            <asp:DropDownList ID="ddlRegione" runat="server" SelectedValue='<%# Bind("CodiceRegione") %>'
              Width="100%" DataSourceID="odsRegioni" DataTextField="Nome" DataValueField="Codice"
              AppendDataBoundItems="True">
              <asp:ListItem Text="" Value=""></asp:ListItem>
            </asp:DropDownList>
            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" class="Error" runat="server"
              ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="ddlRegione" />
          </td>
        </tr>
        <tr>
          <td class="LeftFooter">
          </td>
          <td class="RightFooter">
            <asp:Button ID="butSalva" runat="server" Text="Conferma" CssClass="TabButton" CommandName="Insert"
              OnClick="butSalva_Click" />
            <asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Annulla" CssClass="TabButton"
              ValidationGroup="null" />
          </td>
        </tr>
      </table>
    </InsertItemTemplate>
  </asp:FormView>
  <asp:ObjectDataSource ID="odsIstatProvinceDettaglio" runat="server" SelectMethod="GetData"
    TypeName="DI.Sac.Admin.Data.ISTATDataSetTableAdapters.IstatProvinceUiSelectTableAdapter"
    UpdateMethod="Update" InsertMethod="Insert" DeleteMethod="Delete">
    <DeleteParameters>
      <asp:Parameter Name="Codice" Type="String" />
    </DeleteParameters>
    <InsertParameters>
      <asp:Parameter Name="Codice" Type="String" />
      <asp:Parameter Name="Nome" Type="String" />
      <asp:Parameter Name="Sigla" Type="String" />
      <asp:Parameter Name="CodiceRegione" Type="String" />
    </InsertParameters>
    <SelectParameters>
      <asp:QueryStringParameter Name="Codice" QueryStringField="Codice" Type="String" />
    </SelectParameters>
    <UpdateParameters>
      <asp:Parameter Name="Codice" Type="String" />
      <asp:Parameter Name="Nome" Type="String" />
      <asp:Parameter Name="Sigla" Type="String" />
      <asp:Parameter Name="CodiceRegione" Type="String" />
    </UpdateParameters>
  </asp:ObjectDataSource>
  <asp:ObjectDataSource ID="odsRegioni" runat="server" OldValuesParameterFormatString="original_{0}"
    SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.ISTATDataSetTableAdapters.IstatUiComboRegioniTableAdapter"
    CacheDuration="3600" EnableCaching="True"></asp:ObjectDataSource>
</asp:Content>
