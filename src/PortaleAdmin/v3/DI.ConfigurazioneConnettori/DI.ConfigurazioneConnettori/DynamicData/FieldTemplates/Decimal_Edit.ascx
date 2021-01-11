<%@ Control Language="VB" CodeBehind="Decimal_Edit.ascx.vb" Inherits="Decimal_EditField" %>


<asp:TextBox ID="TextBox1" runat="server" CssClass="form-control" Text='<%# FieldValueEditString %>' Columns="10" placeholder='<%# column.DisplayName %>'></asp:TextBox>


<asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator1" CssClass="validator" ControlToValidate="TextBox1" Display="Dynamic" Enabled="false" ErrorMessage='<%# String.Format("Il campo {0} è obbligatorio.", Column.DisplayName)%>'
            Text="Campo Obbligatorio"
            Tooltip='<%# String.Format("Il campo {0} è obbligatorio.", Column.DisplayName)%>' />
<asp:CompareValidator runat="server" ID="CompareValidator1" CssClass="validator text-danger" ControlToValidate="TextBox1" Display="Dynamic"
    Operator="DataTypeCheck" Type="Double"/>
<asp:RegularExpressionValidator runat="server" ID="RegularExpressionValidator1" CssClass="validator text-danger" ControlToValidate="TextBox1" Display="Dynamic" Enabled="false" />
<asp:RangeValidator runat="server" ID="RangeValidator1" CssClass="validator text-danger" ControlToValidate="TextBox1" Type="Double"
    Enabled="false" EnableClientScript="true" MinimumValue="0" MaximumValue="100" Display="Dynamic" />
<asp:DynamicValidator runat="server" ID="DynamicValidator1" CssClass="validator text-danger" ControlToValidate="TextBox1" Display="Dynamic" />

