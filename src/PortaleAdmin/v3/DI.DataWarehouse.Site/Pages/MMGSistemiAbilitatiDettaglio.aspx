<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="MMGSistemiAbilitatiDettaglio.aspx.vb" Inherits=".SistemiAbilitatiDettaglio" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"></asp:Label>
    <asp:Label ID="labelTitolo" runat="server" CssClass="Title" />
    <asp:FormView ID="FormViewDettaglio" runat="server" DataKeyNames="Id" DataSourceID="odsDettaglio" EmptyDataText="Dettaglio non disponibile." DefaultMode="Edit">
        <EditItemTemplate>
			<table class="table_dettagli" width="500px">
                <tr>
                    <td class="Td-Text" width="150px">Sistema Erogante</td>
                    <td class="Td-Value">
                        <asp:DropDownList ID="ddlSistemaErogante" runat="server" Width="100%" DataSourceID="odsSistemiEroganti"
                            DataTextField="Descrizione" DataValueField="Codice" AppendDataBoundItems="true" SelectedValue='<%# Bind("SistemaErogante")%>'>
                            <%--OnDataBinding="ddlSistemaErogante_DataBinding" OnDataBound="ddlSistemaErogante_DataBound"--%>
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rv2" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="ddlSistemaErogante" CssClass="Error" Display="Dynamic" />
                    </td>
                </tr>
                <tr>
                    <td class="Td-Text">Specialità Erogante</td>
                    <td class="Td-Value">
                        <asp:TextBox ID="txtSpecialitaErogante" runat="server" Text='<%# Bind("SpecialitaErogante")%>' Width="100%" MaxLength="64" />
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

    <asp:ObjectDataSource ID="odsDettaglio" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="{0}" SelectMethod="GetDataBy" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.MMGSistemiAbilitatiCercaTableAdapter" UpdateMethod="Update">
        <InsertParameters>
            <asp:Parameter Name="SistemaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="SpecialitaErogante" Type="String"></asp:Parameter>
        </InsertParameters>
        <SelectParameters>
            <asp:QueryStringParameter QueryStringField="Id" DbType="Guid" Name="Id"></asp:QueryStringParameter>
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter DbType="Guid" Name="Id"></asp:Parameter>
            <asp:Parameter Name="SistemaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="SpecialitaErogante" Type="String"></asp:Parameter>
        </UpdateParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="odsSistemiEroganti" runat="server" SelectMethod="GetData"
        TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.BevsSistemiErogantiCodiciComboTableAdapter"
        EnableCaching="true" CacheDuration="120" OldValuesParameterFormatString="{0}">
        <SelectParameters>
            <asp:Parameter Name="Tipo" Type="String" DefaultValue="referti" />
        </SelectParameters>
    </asp:ObjectDataSource>


</asp:Content>
