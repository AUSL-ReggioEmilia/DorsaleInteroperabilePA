<%@ Control Language="VB" CodeBehind="DateTimePicker_Edit.ascx.vb" Inherits=".DateTimePicker_EditField" %>

<div class="input-group">
    <asp:TextBox ID="TextBox1" runat="server" placeholder="Es: 22/11/1996" CssClass="form-control form-control-dataPicker"></asp:TextBox>
    <div class="input-group-addon"><span class="glyphicon glyphicon-calendar" aria-hidden="true"></span></div>
    <asp:TextBox placeholder="Es: 12:20" runat="server" CssClass="form-control" ID="TextBox2" MaxLength="5" />
    <div class="input-group-addon"><span class="glyphicon glyphicon-time" aria-hidden="true"></span></div>
</div>

<script type="text/javascript">
    $('.form-control-dataPicker').datepicker({
        format: "dd/mm/yyyy",
        weekStart: 1,
        language: "it"
    });
</script>

<asp:RequiredFieldValidator runat="server"
    ErrorMessage='<%# String.Format("Il campo {0} è obbligatorio. Inserire la data.", Column.DisplayName)%>'
    Text="Campo Obbligatorio"
    ToolTip='<%# String.Format("Il campo {0} è obbligatorio. Inserire la data.", Column.DisplayName)%>'
    CssClass="text-danger" ID="RequiredFieldValidator1" ControlToValidate="TextBox1" Display="Dynamic" Enabled="false" />
<asp:RegularExpressionValidator runat="server" CssClass="text-danger" ID="RegularExpressionValidator1" ControlToValidate="TextBox1" Display="Dynamic" Enabled="false" />
<asp:DynamicValidator runat="server" CssClass="text-danger" ID="DynamicValidator1" ControlToValidate="TextBox1" Display="Dynamic" />

<asp:RequiredFieldValidator runat="server" CssClass="text-danger" ID="RequiredFieldValidator2" ControlToValidate="TextBox2" Display="Dynamic" Enabled="false"
    ErrorMessage='<%# String.Format("Il campo {0} è obbligatorio. Inserire un orario valido nel formato <strong>hh:mm</strong>.", Column.DisplayName)%>'
    Text="Campo Obbligatorio"
    ToolTip='<%# String.Format("Il campo {0} è obbligatorio. Inserire un orario valido nel formato <strong>hh:mm</strong>.", Column.DisplayName)%>' />
<asp:RegularExpressionValidator runat="server" CssClass="text-danger" ID="RegularExpressionValidator2" ErrorMessage="Il valore non è valido." ControlToValidate="TextBox2" Display="Dynamic" Enabled="false" />
<asp:DynamicValidator runat="server" CssClass="text-danger" ID="DynamicValidator2" ControlToValidate="TextBox2" Display="Dynamic" />
