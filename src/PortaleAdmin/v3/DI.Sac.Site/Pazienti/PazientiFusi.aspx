<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="PazientiFusi.aspx.vb"
    Inherits="DI.Sac.Admin.PazientiFusi" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../Styles/master.css" rel="stylesheet" type="text/css" />
    <title></title>
    <script src="../Scripts/jquery-1.6.1.min.js" type="text/javascript"></script>
    <script src="../Scripts/jquery-ui-1.8.14.custom.min.js" type="text/javascript"></script>
    <script src="../Scripts/master.js" type="text/javascript"></script>
</head>
<body>
    <form id="MainForm" runat="server">
    <div id="FuseGrid">
        <asp:GridView ID="PazientiFusiGridView" runat="server" AllowPaging="True" AllowSorting="True"
            HorizontalAlign="Left" AutoGenerateColumns="False" BackColor="White" BorderColor="White"
            CellPadding="4" BorderStyle="Solid" BorderWidth="1px" DataSourceID="PazientiFusiListaObjectDataSource"
            ShowHeader="false" EmptyDataText="Nessun risultato!"
            GridLines="Horizontal" PageSize="100" DataKeyNames="Id" Width="100%" EnableModelValidation="True">
            <Columns>
                <asp:TemplateField HeaderText="" ControlStyle-Width="20">
                    <ItemTemplate>
                        <a href='<%# String.Format("PazienteDettaglio.aspx?id={0}", Eval("Id")) %>'>
                            <img src='../Images/view.png' alt="vai al dettaglio" title="vai al dettaglio" /></a>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Nome" SortExpression="Cognome">
                    <ItemTemplate>
                        <%# String.Format("{0} {1}", Eval("Cognome"), Eval("Nome")) %>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="DataNascita" HeaderText="Data di nascita" SortExpression="DataNascita"
                    DataFormatString="{0:d}" HtmlEncode="False" />
                <asp:BoundField DataField="ComuneNascita" HeaderText="Comune di nascita" SortExpression="ComuneNascita" />
                <asp:BoundField DataField="CodiceFiscale" HeaderText="Codice Fiscale" SortExpression="CodiceFiscale" />
                <asp:BoundField DataField="DataDecesso" HeaderText="Data di decesso" SortExpression="DataDecesso"
                    DataFormatString="{0:d}" HtmlEncode="False" />
                <asp:BoundField DataField="Provenienza" HeaderText="Provenienza" SortExpression="Provenienza" />
                <asp:BoundField DataField="DisattivatoDescrizione" HeaderText="Stato" SortExpression="DisattivatoDescrizione" />
                <asp:CheckBoxField DataField="Occultato" HeaderText="Occultato" SortExpression="Occultato"
                    ControlStyle-BorderStyle="None" ItemStyle-HorizontalAlign="Center" />
            </Columns>
            <RowStyle BackColor="#ADD8E6" ForeColor="#333333" />
        </asp:GridView>
        <asp:ObjectDataSource ID="PazientiListaObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
            SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.PazientiDataSetTableAdapters.PazientiGestioneListaTableAdapter">
            <SelectParameters>
                <asp:Parameter Name="Cognome" Type="String" />
                <asp:Parameter Name="Nome" Type="String" />
                <asp:Parameter Name="AnnoNascita" Type="Int32" />
                <asp:Parameter Name="CodiceFiscale" Type="String" />
                <asp:QueryStringParameter DbType="Guid" Name="IdSac" QueryStringField="IdPaziente" />
                <asp:Parameter Name="Disattivato" Type="Byte" />
                <asp:Parameter Name="Occultato" Type="Boolean" />
                <asp:Parameter Name="Provenienza" Type="String" />
                <asp:Parameter Name="IdEsterno" Type="String" />
            </SelectParameters>
        </asp:ObjectDataSource>
        <asp:ObjectDataSource ID="PazientiFusiListaObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
            SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.PazientiDataSetTableAdapters.PazientiUiFusioneListaTableAdapter">
            <SelectParameters>
                <asp:QueryStringParameter DbType="Guid" Name="IdPazienteAttivo" QueryStringField="IdPaziente" />
            </SelectParameters>
        </asp:ObjectDataSource>
        <script type="text/javascript">

            $(document).ready(function () {

                var originalRow = $("#PazientiFusiGridView_originalRow");
                var columnCount = originalRow.children().length;

                $(".childRow").each(function () {

                    for (var i = 0; i < columnCount; i++) {

                        var dtOriginal = originalRow.children()[i];
                        var dtChild = $(this).children()[i];

                        if ($(dtOriginal).text() != $(dtChild).text()) {

                            $(dtChild).css("color", "red");
                        }
                    }
                });
            });
        </script>
    </div>
    </form>
</body>
</html>
