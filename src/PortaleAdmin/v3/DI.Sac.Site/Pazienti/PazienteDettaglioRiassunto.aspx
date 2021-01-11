<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="PazienteDettaglioRiassunto.aspx.vb"
    Inherits="DI.Sac.Admin.PazienteDettaglioRiassunto" Title="Untitled Page" %>

<html>
<head>
    <title>Dettaglio paziente</title>
    <link href="../Styles/master.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form runat="server">
    <h2>
        Dettaglio Paziente</h2>
    <br />
    <asp:FormView ID="PazienteDettaglioFormView" runat="server" DataKeyNames="Id" DataSourceID="PazienteDettaglioObjectDataSource"
        EmptyDataText="Dettaglio non disponibile!">
        <ItemTemplate>
            <table cellpadding="3" cellspacing="0" border="0">
                <tr>
                    <td style="width: 250px;">
                    </td>
                    <td style="width: 300px;">
                    </td>
                </tr>
                <tr style="height: 30px;">
                    <td class="Td-Text">
                        Cognome
                    </td>
                    <td class="Td-Value">
                        <asp:Label ID="lblCognome" runat="server" Text='<%# Eval("Cognome") %>' CssClass="LabelReadOnly" />&nbsp;
                    </td>
                </tr>
                <tr style="height: 30px;">
                    <td class="Td-Text">
                        Nome
                    </td>
                    <td class="Td-Value">
                        <asp:Label ID="lblNome" runat="server" Text='<%# Eval("Nome") %>' CssClass="LabelReadOnly" />&nbsp;
                    </td>
                </tr>
                <tr style="height: 30px;">
                    <td class="Td-Text">
                        Data di nascita
                    </td>
                    <td class="Td-Value">
                        <asp:Label ID="lblDataNascita" runat="server" Text='<%# Eval("DataNascita", "{0:d}") %>'
                            CssClass="LabelReadOnly" />&nbsp;
                    </td>
                </tr>
                <tr style="height: 30px;">
                    <td class="Td-Text">
                        Comune di nascita
                    </td>
                    <td class="Td-Value">
                        <asp:Label ID="lblComuneNascitaDescrizione" runat="server" Text='<%# String.Format("{0} {1}",Eval("ComuneNascitaNome"), IF(Eval("ProvinciaNascitaNome") IsNot DbNull.Value, "(" & Eval("ProvinciaNascitaNome") & ")", "")) %>'
                            CssClass="LabelReadOnly" />&nbsp;
                    </td>
                </tr>
                <tr style="height: 30px;">
                    <td class="Td-Text">
                        Sesso
                    </td>
                    <td class="Td-Value">
                        <asp:Label ID="lblSesso" runat="server" Text='<%# Eval("Sesso") %>' CssClass="LabelReadOnly" />&nbsp;
                    </td>
                </tr>
                <tr style="height: 30px;">
                    <td class="Td-Text">
                        Codice Fiscale
                    </td>
                    <td class="Td-Value">
                        <asp:Label ID="lblCodiceFiscale" runat="server" Text='<%# Eval("CodiceFiscale") %>'
                            CssClass="LabelReadOnly" />&nbsp;
                    </td>
                </tr>
                <tr style="height: 30px;">
                    <td class="Td-Text">
                        Comune di residenza
                    </td>
                    <td class="Td-Value">
                        <asp:Label ID="lblComuneResidenza" runat="server" Text='<%# String.Format("{0} {1}",Eval("ComuneResDescrizione"), IF(Eval("ProvinciaResDescrizione") IsNot DbNull.Value, "(" & Eval("ProvinciaResDescrizione") & ")", "")) %>'
                            CssClass="LabelReadOnly" />&nbsp;
                    </td>
                </tr>
                <tr style="height: 30px;">
                    <td class="Td-Text">
                        Regione di residenza
                    </td>
                    <td class="Td-Value">
                        <asp:Label ID="lblRegioneResDescrizione" runat="server" Text='<%# Eval("RegioneResDescrizione") %>'
                            CssClass="LabelReadOnly" />&nbsp;
                    </td>
                </tr>
                <tr style="height: 30px;">
                    <td class="Td-Text_Gray">
                        Provenienza
                    </td>
                    <td class="Td-Value_Gray">
                        <asp:Label ID="lblProvenienza" runat="server" Text='<%# Eval("Provenienza") %>' CssClass="LabelReadOnly" />
                    </td>
                </tr>
                <tr style="height: 30px;">
                    <td class="Td-Text_Gray">
                        Id Provenienza
                    </td>
                    <td class="Td-Value_Gray">
                        <asp:Label ID="lblIdProvenienza" runat="server" Text='<%# Eval("IdProvenienza") %>'
                            CssClass="LabelReadOnly" />&nbsp;
                    </td>
                </tr>
                <tr style="height: 30px;">
                    <td class="Td-Text_Gray">
                        Livello Attendibilità
                    </td>
                    <td class="Td-Value_Gray">
                        <asp:Label ID="lblLivelloAttendibilita" runat="server" Text='<%# Eval("LivelloAttendibilita") %>'
                            CssClass="LabelReadOnly" />&nbsp;
                    </td>
                </tr>
                <tr style="height: 30px;">
                    <td class="Td-Text_Gray2">
                        Data Modifica
                    </td>
                    <td class="Td-Value_Gray2">
                        <asp:Label ID="lblDataModifica" runat="server" Text='<%# Eval("DataModifica") %>'
                            CssClass="LabelReadOnly" />&nbsp;
                    </td>
                </tr>
            </table>
        </ItemTemplate>
    </asp:FormView>
    <br />
    <b>Sinonimi</b>
    <asp:GridView ID="PazientiSinonimiGridView" runat="server" AutoGenerateColumns="False"
        DataSourceID="PazientiSinonimiObjectDataSource" EnableModelValidation="True"
        Width="559px" BackColor="White" BorderColor="#E7E7FF" BorderStyle="None" BorderWidth="1px"
        CellPadding="3" GridLines="Horizontal">
        <Columns>
            <asp:BoundField DataField="Provenienza" HeaderText="Provenienza" SortExpression="Provenienza" />
            <asp:BoundField DataField="IdProvenienza" HeaderText="IdProvenienza" SortExpression="IdProvenienza" />
            <asp:BoundField DataField="Stato" HeaderText="Stato" ReadOnly="True" SortExpression="Stato" />
            <asp:BoundField DataField="DataModifica" HeaderText="DataModifica" SortExpression="DataModifica"  />
        </Columns>
        <FooterStyle BackColor="#B5C7DE" ForeColor="#4A3C8C" />
        <HeaderStyle BackColor="#DDDDDD" Font-Bold="True" ForeColor="#000" />
        <PagerStyle BackColor="#E7E7FF" ForeColor="#4A3C8C" HorizontalAlign="Right" />
        <RowStyle BackColor="#FFEA93" ForeColor="#4A3C8C" />
    </asp:GridView>
    <asp:ObjectDataSource ID="PazienteDettaglioObjectDataSource" runat="server" SelectMethod="GetData"
        TypeName="DI.Sac.Admin.Data.PazientiDataSetTableAdapters.PazientiGestioneTableAdapter"
        OldValuesParameterFormatString="original_{0}">
        <SelectParameters>
            <asp:QueryStringParameter DbType="Guid" Name="Id" QueryStringField="id" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="PazientiSinonimiObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.PazientiDataSetTableAdapters.PazientiUiSistemiProvenienzaTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter DbType="Guid" Name="IdPaziente" QueryStringField="Id" />
        </SelectParameters>
    </asp:ObjectDataSource>
    </form>
</body>
</html>
