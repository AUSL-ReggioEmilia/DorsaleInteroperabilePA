<%@ Control Language="vb" AutoEventWireup="false" Inherits="DI.DataWarehouse.Admin.StiliDettaglio1"
    CodeBehind="StiliDettaglio1.ascx.vb" %>
<meta content="True" name="vs_snapToGrid">
<meta content="True" name="vs_showGrid">
  <asp:Label ID="lblError" runat="server" CssClass="Error" EnableViewState="False"
    Visible="False"></asp:Label>
<table style="padding-left: 5px; padding-top: 5px" cellspacing="0" cellpadding="0"
    width="90%" border="0">
    <tr>
        <td style="width: 150px">Nome:
        </td>
        <td>
            <asp:TextBox ID="NomeTextBox" runat="server" Text='<%# DataBinder.Eval(_stiliDettaglioDataSet, "Tables[RefertiStili].DefaultView.[0].Nome") %>'
                Width="296px" MaxLength="64"></asp:TextBox>
        </td>
    </tr>
    <tr>
        <td style="width: 150px">Descrizione:
        </td>
        <td>
            <asp:TextBox ID="DescrizioneTextBox" runat="server" Text='<%# DataBinder.Eval(_stiliDettaglioDataSet, "Tables[RefertiStili].DefaultView.[0].Descrizione") %>'
                Width="296px" MaxLength="50"></asp:TextBox>
        </td>
    </tr>
    <tr>
        <td style="width: 150px" valign="top" width="94">Pagina Web:
        </td>
        <td style="width: 689px">
            <asp:TextBox ID="PaginaWebTextBox" runat="server" Text='<%# DataBinder.Eval(_stiliDettaglioDataSet, "Tables[RefertiStili].DefaultView.[0].PaginaWeb") %>'
                Width="95%" MaxLength="255"></asp:TextBox>
        </td>
    </tr>
    <tr>
        <td style="width: 150px" valign="top" width="94">Parametri:
        </td>
        <td style="width: 689px">
            <asp:TextBox ID="ParametriTextBox" runat="server" Text='<%# DataBinder.Eval(_stiliDettaglioDataSet, "Tables[RefertiStili].DefaultView.[0].Parametri") %>'
                Width="95%" MaxLength="255"></asp:TextBox>
        </td>
    </tr>
    <tr>
        <td style="width: 150px">Abilitato:
        </td>
        <td>
            <asp:CheckBox ID="chkAbilitato" runat="server" Checked='<%# DataBinder.Eval(_stiliDettaglioDataSet, "Tables[RefertiStili].DefaultView.[0].Abilitato") %>'></asp:CheckBox>
        </td>
    </tr>
    <tr>
        <td style="width: 150px">Note:
        </td>
        <td>
            <asp:TextBox ID="NoteTextBox" runat="server" Text='<%# DataBinder.Eval(_stiliDettaglioDataSet, "Tables[RefertiStili].DefaultView.[0].Note") %>'
                Width="95%" TextMode="MultiLine" Rows="5" MaxLength="200"></asp:TextBox>
        </td>
    </tr>
    <tr>
        <td style="width: 150px">Tipo:
        </td>
        <td>
            <asp:DropDownList runat="server" ID="cmbTipo" Width="296px" >
            </asp:DropDownList>
        </td>
    </tr>
    <tr>
        <td style="width: 150px">Xslt Testata:
        </td>
        <td>

            <asp:TextBox ID="XsltTestataTextBox" runat="server" Text='<%# DataBinder.Eval(_stiliDettaglioDataSet, "Tables[RefertiStili].DefaultView.[0].XsltTestata") %>'
                Width="95%" TextMode="MultiLine" Rows="5" ValidateRequestMode="Inherit"></asp:TextBox>
        </td>
    </tr>
    <tr>
        <td style="width: 150px">Xslt Righe:
        </td>
        <td>
            <asp:TextBox ID="XsltRigheTextBox" runat="server" Text='<%# DataBinder.Eval(_stiliDettaglioDataSet, "Tables[RefertiStili].DefaultView.[0].XsltRighe") %>'
                Width="95%" TextMode="MultiLine" Rows="5"></asp:TextBox>
        </td>
    </tr>
    <tr>
        <td style="width: 150px">Xslt Allegato XML:
        </td>
        <td>
            <asp:TextBox ID="XsltAllegatoXmlTextBox" runat="server" Text='<%# DataBinder.Eval(_stiliDettaglioDataSet, "Tables[RefertiStili].DefaultView.[0].XsltAllegatoXml") %>'
                Width="95%" TextMode="MultiLine" Rows="5"></asp:TextBox>
        </td>
    </tr>
   <tr>
        <td style="width: 150px">Nome Allegato XML:
        </td>
        <td>
            <asp:TextBox ID="NomeFileAllegatoXmlTextBox" runat="server" Text='<%# DataBinder.Eval(_stiliDettaglioDataSet, "Tables[RefertiStili].DefaultView.[0].NomeFileAllegatoXml") %>'
                Width="95%" Rows="5" MaxLength="255"></asp:TextBox>
        </td>
    </tr>
    <tr>
        <td style="width: 150px">Mostra Link Documento Pdf:
        </td>
        <td>
            <asp:CheckBox ID="chkShowLinkDocumentoPdf" runat="server" Checked='<%# DataBinder.Eval(_stiliDettaglioDataSet, "Tables[RefertiStili].DefaultView.[0].ShowLinkDocumentoPdf") %>'/>
        </td>
    </tr>

    <tr>
        <td style="width: 150px">Mostra Allegato RTF:
        </td>
        <td>
            <asp:CheckBox ID="chkShowAllegatoRTF" runat="server" Checked='<%# DataBinder.Eval(_stiliDettaglioDataSet, "Tables[RefertiStili].DefaultView.[0].ShowAllegatoRTF") %>'/>
        </td>
    </tr>

</table>
