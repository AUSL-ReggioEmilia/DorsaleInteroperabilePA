<%@ Control Language="VB" CodeBehind="DatePicker_Edit.ascx.vb" Inherits=".DatePicker_EditField" %>

<asp:TextBox ID="TextBox1" runat="server" CssClass="form-control form-control-dataPicker" placeholder="Es: 22/11/1996" Text='<%# FieldValueEditString %>'></asp:TextBox>
<script type="text/javascript">
    $('.form-control-dataPicker').datepicker({
        format: "dd/mm/yyyy",
        weekStart: 1,
        language: "it"
    });
</script>

<asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator1" ControlToValidate="TextBox1" Display="Dynamic" Enabled="false" ErrorMessage='<%# String.Format("Il campo {0} è obbligatorio.", Column.DisplayName)%>'
            Text="Campo Obbligatorio"
            Tooltip='<%# String.Format("Il campo {0} è obbligatorio.", Column.DisplayName)%>'  CssClass="text-danger"/>
<asp:RegularExpressionValidator runat="server" ID="RegularExpressionValidator1" ControlToValidate="TextBox1" CssClass="text-danger" Display="Dynamic" Enabled="false" />
<asp:DynamicValidator runat="server" ID="DynamicValidator1" ControlToValidate="TextBox1" Display="Dynamic" CssClass="text-danger" />
