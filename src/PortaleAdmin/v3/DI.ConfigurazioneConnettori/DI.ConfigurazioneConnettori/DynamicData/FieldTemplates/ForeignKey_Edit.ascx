<%@ Control Language="VB" CodeBehind="ForeignKey_Edit.ascx.vb" Inherits="ForeignKey_EditField" %>

<asp:DropDownList ID="DropDownList1" runat="server" CssClass="form-control">
</asp:DropDownList>

<asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator1" CssClass="validator text-danger" ControlToValidate="DropDownList1" Display="Dynamic" Enabled="false" ErrorMessage='<%# String.Format("Il campo {0} è obbligatorio.", Column.DisplayName)%>'
            Text="Campo Obbligatorio"
            Tooltip='<%# String.Format("Il campo {0} è obbligatorio.", Column.DisplayName)%>' />
<asp:DynamicValidator runat="server" ID="DynamicValidator1" CssClass="validator text-danger" ControlToValidate="DropDownList1" Display="Dynamic" />

