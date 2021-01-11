<%@ Control Language="VB" CodeBehind="Text_Edit.ascx.vb" Inherits="Text_EditField" %>

        <asp:TextBox
            ID="TextBox1"
            runat="server"
            Text='<%# FieldValueEditString %>'
            CssClass="form-control"
            placeholder='<%# Column.DisplayName %>'></asp:TextBox>

        <asp:RequiredFieldValidator
            runat="server"
            ID="RequiredFieldValidator1"
            CssClass="validator text-danger"
            ControlToValidate="TextBox1"
            ErrorMessage='<%# String.Format("Il campo {0} è obbligatorio.", Column.DisplayName)%>'
            Text="Campo Obbligatorio"
            Tooltip='<%# String.Format("Il campo {0} è obbligatorio.", Column.DisplayName)%>'
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
