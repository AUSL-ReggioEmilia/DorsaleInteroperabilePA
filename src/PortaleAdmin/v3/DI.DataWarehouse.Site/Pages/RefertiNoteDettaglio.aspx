<%@ Page Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeBehind="RefertiNoteDettaglio.aspx.vb"
    Inherits="DI.DataWarehouse.Admin.RefertiNoteDettaglio" Title="Untitled Page" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="Server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"></asp:Label>
    <asp:FormView ID="NoteFormView" runat="server" Width="100%" DataSourceID="NoteObjectDataSource"
        DataKeyNames="Id" EnableModelValidation="True">
        <ItemTemplate>
            <table style="padding-left: 3px; padding-top: 3px; width: 100%" cellspacing="0" cellpadding="0"
                border="0">
                <tr>
                    <td style="width: 120px;">
                        Numero referto:
                    </td>
                    <td>
                        <asp:Label ID="NumeroRefertoTextBox" runat="server" Text='<%# Eval("NumeroReferto") %>'></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td style="width: 100px;">
                        Nosologico:
                    </td>
                    <td>
                        <asp:Label ID="NosologicoTextBox" runat="server" Text='<%# Eval("NumeroNosologico") %>'></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td style="width: 100px;">
                        Utente:
                    </td>
                    <td>
                        <asp:Label ID="UtenteTextBox" runat="server" Text='<%# Eval("Utente") %>'></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td style="width: 120px;">
                        Data inserimento:
                    </td>
                    <td>
                        <asp:Label ID="DataInserimentoTextBox" runat="server" Text='<%# Eval("DataInserimento") %>'></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td>
                        Nota:
                    </td>
                    <td>
                        <asp:TextBox ID="NoteTextBox" runat="server" TextMode="MultiLine" ReadOnly="True"
                            Text='<%# Eval("Nota") %>' Width="90%" Rows="15"></asp:TextBox>
                    </td>
                </tr>
            </table>
        </ItemTemplate>
    </asp:FormView>
    <asp:Button ID="RemoveButton" runat="server" CausesValidation="False" Text="Elimina"
        OnClientClick="return confirm('Confermi la cancellazione della nota-referto?');" />
    <asp:ObjectDataSource ID="NoteObjectDataSource" runat="server" DeleteMethod="RimuoviNoteReferti"
        OldValuesParameterFormatString="original_{0}" SelectMethod="GetRefertiNoteDettaglio"
        TypeName="DI.DataWarehouse.Admin.Data.DataAdapterManager">
        <SelectParameters>
            <asp:QueryStringParameter DbType="Guid" Name="id" QueryStringField="Id" />
        </SelectParameters>
        <DeleteParameters>
            <asp:Parameter DbType="Guid" Name="id" />
        </DeleteParameters>
    </asp:ObjectDataSource>
</asp:Content>
