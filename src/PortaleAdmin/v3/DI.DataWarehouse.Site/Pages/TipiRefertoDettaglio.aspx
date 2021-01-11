<%@ Page Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeBehind="TipiRefertoDettaglio.aspx.vb"
    Inherits="DI.DataWarehouse.Admin.TipiRefertoDettaglio" Title="Dettaglio Tipo Referto" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="Server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"></asp:Label>
    <asp:Label ID="labelTitolo" runat="server" CssClass="Title" />
    <table class="table_dettagli" width="500px">
        <tr>
            <td class="Td-Text">Azienda Erogante</td>
            <td class="Td-Value">
                <%-- <asp:DropDownList ID="cmbAziendaErogante" runat="server" AutoPostBack="true">
                    <asp:ListItem Text="" Value="" />
                    <asp:ListItem Text="ASMN" Value="ASMN" />
                    <asp:ListItem Text="AUSL" Value="AUSL" />
                </asp:DropDownList>--%>

                <asp:DropDownList ID="cmbAziendaErogante" runat="server" DataSourceID="AziendeObjectDataSource" DataTextField="Descrizione" AutoPostBack="true"
                    DataValueField="Codice" Width="210px">
                </asp:DropDownList>

                <asp:ObjectDataSource ID="AziendeObjectDataSource" runat="server" SelectMethod="GetData"
                    TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.AziendeErogantiListaTableAdapter"
                    OldValuesParameterFormatString="{0}" EnableCaching="true" CacheDuration="120"></asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td class="Td-Text" width="200px">Sistema Erogante</td>
            <td class="Td-Value">
                <asp:DropDownList ID="ddlSistemaErogante" runat="server" Width="100%" DataSourceID="odsSistemiEroganti"
                    DataTextField="Descrizione" DataValueField="Codice" AppendDataBoundItems="true">
                </asp:DropDownList>
                <asp:RequiredFieldValidator ID="rv2" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="ddlSistemaErogante" CssClass="Error" Display="Dynamic" />
            </td>
        </tr>
    </table>
    <asp:FormView ID="FormViewDettaglio" runat="server" DataKeyNames="Id" DataSourceID="odsDettaglio" EmptyDataText="Dettaglio non disponibile." DefaultMode="Edit">
        <EditItemTemplate>
            <table class="table_dettagli" width="500px">
                <tr>
                    <td class="Td-Text">Specialità Erogante</td>
                    <td class="Td-Value">
                        <asp:TextBox ID="txtSpecialitaErogante" runat="server" Text='<%# Bind("SpecialitaErogante")%>' Width="100%" MaxLength="64" />
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text">Descrizione</td>
                    <td class="Td-Value">
                        <asp:TextBox ID="txtDescrizione" runat="server" Text='<%# Bind("Descrizione")%>' Width="100%" MaxLength="128" />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="txtDescrizione" CssClass="Error" Display="Dynamic" />
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text">Icona</td>
                    <td class="Td-Value">
                        <asp:Image ID="imgIcona" runat="server" />&nbsp;
						<asp:LinkButton ID="butCambiaIcona" runat="server" Text="Seleziona icona..." CommandName="UPLOAD" CausesValidation="false"></asp:LinkButton>
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text">Ordinamento</td>
                    <td class="Td-Value">
                        <asp:TextBox ID="txtOrdinamento" runat="server" Text='<%# Bind("Ordinamento")%>' Width="100%" MaxLength="5" />
                        <asp:RangeValidator runat="server" ID="rv1" ControlToValidate="txtOrdinamento" MinimumValue="0" MaximumValue="99999" Display="Dynamic" CssClass="Error" ErrorMessage="Numero non valido" Type="Integer"></asp:RangeValidator>
                        <asp:RequiredFieldValidator ID="rqf1" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="txtOrdinamento" CssClass="Error" Display="Dynamic" />
                    </td>
                </tr>
                <tr>
                    <td class="LeftFooter">
                        <asp:Button ID="butElimina" runat="server" Text="Elimina" CssClass="Button" CommandName="Delete" OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione dell\'elemento?');"
                            ValidationGroup="none" />
                    </td>
                    <td class="RightFooter">
                        <asp:Button ID="butSalva" runat="server" Text="Conferma" CssClass="Button" CommandName="Update" />
                        <asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Annulla" CssClass="Button" ValidationGroup="none" />
                    </td>
                </tr>
            </table>
        </EditItemTemplate>
    </asp:FormView>

    <asp:ObjectDataSource ID="odsDettaglio" runat="server" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.TipiRefertoTableAdapter"
        SelectMethod="GetDataById" OldValuesParameterFormatString="{0}" UpdateMethod="Update" DeleteMethod="Delete" InsertMethod="Insert">
        <InsertParameters>
            <asp:Parameter Name="SistemaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="SpecialitaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="Descrizione" Type="String"></asp:Parameter>
            <asp:Parameter Name="Icona" Type="Object"></asp:Parameter>
            <asp:Parameter Name="Ordinamento" Type="Int32"></asp:Parameter>
            <asp:Parameter Name="AziendaErogante" Type="String"></asp:Parameter>
        </InsertParameters>
        <SelectParameters>
            <asp:QueryStringParameter Name="ID" QueryStringField="Id" DbType="Guid" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter DbType="Guid" Name="Id"></asp:Parameter>
            <asp:Parameter Name="SistemaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="SpecialitaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="Descrizione" Type="String"></asp:Parameter>
            <asp:Parameter Name="Icona" Type="Object"></asp:Parameter>
            <asp:Parameter Name="Ordinamento" Type="Int32"></asp:Parameter>
            <asp:Parameter Name="AziendaErogante" Type="String"></asp:Parameter>
        </UpdateParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="odsSistemiEroganti" runat="server" SelectMethod="GetDataByAziendaETipo"
        TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.SistemiErogantiListaTableAdapter"
        EnableCaching="false" CacheDuration="120" OldValuesParameterFormatString="{0}">
        <SelectParameters>
            <asp:Parameter Name="AziendaErogante" Type="String" />
            <asp:Parameter Name="Tipo" Type="String" DefaultValue="referti" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
