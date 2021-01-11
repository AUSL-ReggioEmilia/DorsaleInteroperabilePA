<%@ Control Language="VB" CodeBehind="MultilineText_Edit.ascx.vb" Inherits="MultilineText_EditField" %>

<asp:TextBox
    ID="TextBox1"
    runat="server"
    CssClass="form-control"
    TextMode="MultiLine"
    Text='<%# FieldValueEditString %>'
    Rows="4"
    placeholder='<%# Column.DisplayName %>'></asp:TextBox>

<asp:RequiredFieldValidator
    runat="server"
    ID="RequiredFieldValidator1"
    CssClass="validator text-danger"
    ControlToValidate="TextBox1"
    ErrorMessage='<%# String.Format("Il campo {0} è obbligatorio.", Column.DisplayName)%>'
    Text="Campo Obbligatorio"
    ToolTip='<%# String.Format("Il campo {0} è obbligatorio.", Column.DisplayName)%>'
    Display="Dynamic"
    Enabled="false" />
<asp:RegularExpressionValidator
    runat="server"
    ID="RegularExpressionValidator1"
    CssClass="validator text-danger"
    ControlToValidate="TextBox1"
    Display="Dynamic"
    Enabled="false" />
<asp:DynamicValidator
    runat="server"
    ID="DynamicValidator1"
    CssClass="validator text-danger"
    ControlToValidate="TextBox1"
    Display="Dynamic" />
