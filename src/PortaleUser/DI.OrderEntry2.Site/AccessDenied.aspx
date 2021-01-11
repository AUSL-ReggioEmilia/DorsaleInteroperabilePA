<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="AccessDenied.aspx.vb" Inherits="DI.DataWarehouse.Admin.AccessDenied" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <table class="PageErrorContainer" cellspacing="0" cellpadding="0" style="border: 0;
        width: 100%; height: 100%">
        <tbody>
            <tr>
                <td style="text-align: center;">
                    <img border="0" src="images/ErrorAccessDenied.jpg" width="99" height="99">
                    <br />
                    <b>ACCESSO NEGATO</b>
                    <br />
                    <asp:Label ID="MessageLabel" runat="server" Text="L'utente non ha i diritti necessari per visualizzare questa pagina."></asp:Label>
                </td>
            </tr>
        </tbody>
    </table>
    <script type="text/javascript">

        $(document).ready(function () {

            $("#MenuColumn").hide();
        });
    </script>
</asp:Content>
