<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
  CodeBehind="IstatComuniDettaglio.aspx.vb" Inherits=".IstatComuniDettaglio" %>

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
  <asp:FormView ID="FormViewDettaglio" runat="server" DataKeyNames="Codice" DataSourceID="odsDettaglioIstatComune"
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
            Tipo:
          </td>
          <td class="Td-Value">
            <asp:DropDownList ID="ddlTipo" runat="server" AppendDataBoundItems="True" SelectedValue='<%# Bind("Nazione") %>'
              Width="100%" AutoPostBack="true" OnSelectedIndexChanged="ddlTipo_SelectedIndexChanged">
              <asp:ListItem Value="False" Text="Comune"></asp:ListItem>
              <asp:ListItem Value="True" Text="Nazione"></asp:ListItem>
            </asp:DropDownList>
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Provincia:
          </td>
          <td class="Td-Value">
            <asp:DropDownList ID="ddlProvince" runat="server" AppendDataBoundItems="True" DataSourceID="odsProvince"
              DataTextField="Nome" DataValueField="Codice" SelectedValue='<%# Bind("CodiceProvincia") %>'
              Width="100%">
            </asp:DropDownList>
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Data Inizio Validità (gg/mm/aaaa):
          </td>
          <td class="Td-Value">
            <asp:TextBox ID="txtDTInizio" runat="server" Width="100%" Text='<%# Bind("DataInizioValidita", "{0:d}") %>' />
            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" class="Error" runat="server"
              ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtDTInizio" />
            <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" ErrorMessage="Formato non valido"
              class="Error" Display="Dynamic" ControlToValidate="txtDTInizio" ValidationExpression="^(0?[1-9]|[12][0-9]|3[01])[/-](0?[1-9]|1[0-2])[/-](1[89][0-9]{2}|[2-9][0-9]{3})$"
              SetFocusOnError="True"></asp:RegularExpressionValidator>
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Data Fine Validità (gg/mm/aaaa):
          </td>
          <td class="Td-Value">
            <asp:TextBox ID="txtDTFine" runat="server" Width="100%" Text='<%# Bind("DataFineValidita", "{0:d}") %>' />
            <asp:RegularExpressionValidator ID="RegularExpressionValidator2" runat="server" ErrorMessage="Formato non valido"
              class="Error" Display="Dynamic" ControlToValidate="txtDTFine" ValidationExpression="^(0?[1-9]|[12][0-9]|3[01])[/-](0?[1-9]|1[0-2])[/-](1[89][0-9]{2}|[2-9][0-9]{3})$"
              SetFocusOnError="True"></asp:RegularExpressionValidator>
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Provenienza:
          </td>
          <td class="Td-Value">
            <asp:Label ID="lblEditProv" runat="server" CssClass="LabelReadOnly" Text='<%# Eval("Provenienza") %>'
              Width="100%"></asp:Label>
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Id Provenienza:
          </td>
          <td class="Td-Value">
            <asp:Label ID="lblEditIDProv" runat="server" Width="100%" CssClass="LabelReadOnly"
              Text='<%# Eval("IdProvenienza") %>' />
          </td>
        </tr>
        <tr>
          <td class="Td-Text2">
            Data Inserimento:
          </td>
          <td class="Td-Value2">
            <asp:Label ID="lblEditDTIns" runat="server" Width="100%" CssClass="LabelReadOnly"
              Text='<%# Eval("DataInserimento") %>' />
          </td>
        </tr>
        <!-- ---------------------------------------------------------------- -->
        <tr style="height: 45px; vertical-align: bottom;">
          <td colspan="2" class="LabelReadOnly">
            Dati da LHA
          </td>
        </tr>
        <!-- ---------------------------------------------------------------- -->
        <tr>
          <td class="Td-Text">
            Codice Distretto:
          </td>
          <td class="Td-Value">
            <asp:Label ID="lblEditCodDistr" runat="server" Width="100%" CssClass="LabelReadOnly"
              Text='<%# Eval("CodiceDistretto") %>' />
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Cap:
          </td>
          <td class="Td-Value">
            <asp:Label ID="lblEditCap" runat="server" Width="100%" CssClass="LabelReadOnly" Text='<%# Eval("Cap") %>' />
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Codice Catastale:
          </td>
          <td class="Td-Value">
            <asp:Label ID="lblEditCodCat" runat="server" Width="100%" CssClass="LabelReadOnly"
              Text='<%# Eval("CodiceCatastale") %>' />
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Codice Regione:
          </td>
          <td class="Td-Value">
            <asp:Label ID="lblEditCodReg" runat="server" Width="100%" CssClass="LabelReadOnly"
              Text='<%# Eval("CodiceRegione") %>' />
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Sigla:
          </td>
          <td class="Td-Value">
            <asp:Label ID="lblEditSigla" runat="server" Width="100%" CssClass="LabelReadOnly"
              Text='<%# Eval("Sigla") %>' />
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Codice Asl:
          </td>
          <td class="Td-Value">
            <asp:Label ID="lblEditCodAsl" runat="server" Width="100%" CssClass="LabelReadOnly"
              Text='<%# Eval("CodiceAsl") %>' />
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Comune Stato Estero:
          </td>
          <td class="Td-Value">
            <asp:Label ID="lblEditComuneStEst" runat="server" Width="100%" CssClass="LabelReadOnly"
              Text='<%# Eval("FlagComuneStatoEstero") %>' />
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Stato Estero UE:
          </td>
          <td class="Td-Value">
            <asp:Label ID="lblEditStatoEst" runat="server" Width="100%" CssClass="LabelReadOnly"
              Text='<%# Eval("FlagStatoEsteroUE") %>' />
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Data Ultima Modifica:
          </td>
          <td class="Td-Value">
            <asp:Label ID="lblEditDTUltMod" runat="server" Width="100%" CssClass="LabelReadOnly"
              Text='<%# Eval("DataUltimaModifica") %>' />
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Disattivato:
          </td>
          <td class="Td-Value">
            <asp:Label ID="lblEditDisat" runat="server" Width="100%" CssClass="LabelReadOnly"
              Text='<%# Eval("Disattivato") %>' />
          </td>
        </tr>
        <tr>
          <td class="Td-Text2">
            Codice Interno Lha:
          </td>
          <td class="Td-Value2">
            <asp:Label ID="lblEditCodIntLha" runat="server" Width="100%" CssClass="LabelReadOnly"
              Text='<%# Eval("CodiceInternoLha") %>' />
          </td>
        </tr>
        <td class="LeftFooter">
          <asp:Button ID="butElimina" runat="server" Text="Elimina" CssClass="TabButton" CommandName="Delete"
            OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione del Codice Istat?');"
            ValidationGroup="none" />
        </td>
        <td class="RightFooter">
          <asp:Button ID="butSalva" runat="server" Text="Conferma" CssClass="TabButton" CommandName="Update"
            OnClick="butSalva_Click" />
          <asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Annulla" CssClass="TabButton"
            ValidationGroup="none" />
        </td>
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
            <asp:TextBox ID="txtCodice" runat="server" Width="100%" Text='<%# Bind("Codice") %>' />
            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" class="Error" runat="server"
              ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtCodice" />
            <asp:RegularExpressionValidator ID="RegExp1" runat="server" ErrorMessage="Sono richiesti sei caratteri (lettere o numeri)."
              Display="Dynamic" class="Error" ControlToValidate="txtCodice" ValidationExpression="^[a-zA-Z0-9]{6,6}$" />
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
            Tipo:
          </td>
          <td class="Td-Value">
            <asp:DropDownList ID="ddlTipo" runat="server" AppendDataBoundItems="True" SelectedValue='<%# Bind("Nazione") %>'
              Width="100%" AutoPostBack="true" OnSelectedIndexChanged="ddlTipo_SelectedIndexChanged">
              <asp:ListItem Value="False" Text="Comune"></asp:ListItem>
              <asp:ListItem Value="True" Text="Nazione"></asp:ListItem>
            </asp:DropDownList>
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Provincia:
          </td>
          <td class="Td-Value">
            <asp:DropDownList ID="ddlProvince" runat="server" AppendDataBoundItems="True" DataSourceID="odsProvince"
              DataTextField="Nome" DataValueField="Codice" SelectedValue='<%# Bind("CodiceProvincia") %>'
              Width="100%">
            </asp:DropDownList>
          </td>
        </tr>
        <tr>
          <td class="Td-Text">
            Data Inizio Validità (gg/mm/aaaa):
          </td>
          <td class="Td-Value">
            <asp:TextBox ID="txtDTInizio" runat="server" Width="100%" Text='<%# Bind("DataInizioValidita", "{0:d}") %>' />
            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" class="Error" runat="server"
              ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtDTInizio" />
            <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" ErrorMessage="Formato non valido"
              class="Error" Display="Dynamic" ControlToValidate="txtDTInizio" ValidationExpression="^(0?[1-9]|[12][0-9]|3[01])[/-](0?[1-9]|1[0-2])[/-](1[89][0-9]{2}|[2-9][0-9]{3})$"
              SetFocusOnError="True"></asp:RegularExpressionValidator>
          </td>
        </tr>
        <tr>
          <td class="Td-Text2">
            Data Fine Validità (gg/mm/aaaa):
          </td>
          <td class="Td-Value2">
            <asp:TextBox ID="txtDTFine" runat="server" Width="100%" Text='<%# Bind("DataFineValidita", "{0:d}") %>' />
            <asp:RegularExpressionValidator ID="RegularExpressionValidator2" runat="server" ErrorMessage="Formato non valido"
              class="Error" Display="Dynamic" ControlToValidate="txtDTFine" ValidationExpression="^(0?[1-9]|[12][0-9]|3[01])[/-](0?[1-9]|1[0-2])[/-](1[89][0-9]{2}|[2-9][0-9]{3})$"
              SetFocusOnError="True"></asp:RegularExpressionValidator>
          </td>
        </tr>
        <td class="LeftFooter">
        </td>
        <td class="RightFooter">
          <asp:Button ID="butSalva" runat="server" Text="Conferma" CssClass="TabButton" CommandName="Insert"
            OnClick="butSalva_Click" />
          <asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Annulla" CssClass="TabButton"
            ValidationGroup="null" />
        </td>
      </table>
    </InsertItemTemplate>
  </asp:FormView>
  <asp:ObjectDataSource ID="odsDettaglioIstatComune" runat="server" SelectMethod="GetData"
    TypeName="DI.Sac.Admin.Data.ISTATDataSetTableAdapters.IstatComuniUiSelectTableAdapter"
    UpdateMethod="Update" InsertMethod="Insert" DeleteMethod="Delete" OldValuesParameterFormatString="{0}">
    <DeleteParameters>
      <asp:Parameter Name="Codice" Type="String" />
    </DeleteParameters>
    <InsertParameters>
      <asp:Parameter Name="Codice" Type="String" />
      <asp:Parameter Name="Nome" Type="String" />
      <asp:Parameter Name="CodiceProvincia" Type="String" />
      <asp:Parameter Name="Nazione" Type="Boolean" />
      <asp:Parameter Name="DataInizioValidita" Type="DateTime" />
      <asp:Parameter Name="DataFineValidita" Type="DateTime" />
    </InsertParameters>
    <SelectParameters>
      <asp:QueryStringParameter Name="Codice" QueryStringField="Codice" Type="String" />
    </SelectParameters>
    <UpdateParameters>
      <asp:Parameter Name="Codice" Type="String" />
      <asp:Parameter Name="Nome" Type="String" />
      <asp:Parameter Name="CodiceProvincia" Type="String" />
      <asp:Parameter Name="Nazione" Type="Boolean" />
      <asp:Parameter Name="DataInizioValidita" Type="DateTime" />
      <asp:Parameter Name="DataFineValidita" Type="DateTime" />
    </UpdateParameters>
  </asp:ObjectDataSource>
  <asp:ObjectDataSource ID="odsProvince" runat="server" OldValuesParameterFormatString="original_{0}"
    SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.ISTATDataSetTableAdapters.IstatUiComboProvinceTableAdapter"
    CacheDuration="30" EnableCaching="False"></asp:ObjectDataSource>
</asp:Content>
