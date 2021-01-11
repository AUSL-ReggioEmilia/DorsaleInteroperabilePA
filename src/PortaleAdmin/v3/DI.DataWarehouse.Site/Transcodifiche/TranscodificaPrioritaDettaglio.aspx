<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="TranscodificaPrioritaDettaglio.aspx.vb" Inherits=".TranscodificaPrioritaDettaglio" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">

    <asp:Label ID="lblError" runat="server" CssClass="Error" EnableViewState="False"></asp:Label>

    <label class="Title">Dettaglio transcodifica priorita</label>

    <asp:FormView ID="fvDettaglio" runat="server" DataSourceID="odsMain" DataKeyNames="Id" DefaultMode="Edit" Style="width: 900px">
       <InsertItemTemplate>
                <table class="table_dettagli" width="500px">
                    <tr>
                        <td class="Td-Text" width="150px">Azienda Erogante</td>
                        <td class="Td-Value" width="350px">
                            <asp:DropDownList ID="ddlAziendeEroganti" runat="server" Width="100%" DataSourceID="odsAziendeEroganti"
                                DataTextField="Descrizione" DataValueField="Codice" AppendDataBoundItems="true" SelectedValue='<%# Bind("AziendaErogante")%>'
                                AutoPostBack="True" OnSelectedIndexChanged="ddlAziendeEroganti_SelectedIndexChanged" >
                                <asp:ListItem Text="" Value="" />
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rv2" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="ddlAziendeEroganti" CssClass="Error" Display="Dynamic" />
                        </td>
                    </tr>
                    <tr>
                        <td class="Td-Text" width="150px">Sistema Erogante</td>
                        <td class="Td-Value" width="350px">
                            <!-- NON BISOGNA METTERE IL SELECTED VALUE PERCHE' E' UNA COMBO IN CASCATA: E' GESTITO VIA CODICE -->
                            <asp:DropDownList ID="ddlSistemiEroganti" runat="server" Width="100%" DataSourceID="odsSistemiEroganti"
                                DataTextField="Descrizione" DataValueField="Codice" OnPreRender="ddlSistemiEroganti_PreRender">
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvddlSistemiEroganti" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="ddlSistemiEroganti" CssClass="Error" Display="Dynamic" />
                        </td>
                    </tr>
                    <tr>
                        <td class="Td-Text" width="150px">Codice esterno</td>
                        <td class="Td-Value" width="350px">
                            <asp:TextBox ID="txtCodiceEsterno" runat="server" Text='<%# Bind("CodiceEsterno")%>' Width="100%" MaxLength="16" />
                            <asp:RequiredFieldValidator ID="rfvtxtCodiceEsterno" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="txtCodiceEsterno" CssClass="Error" Display="Dynamic" />
                        </td>
                    </tr>
                    <tr>
                        <td class="Td-Text" width="150px">Codice transcodificato</td>
                        <td class="Td-Value" width="350px">
                            <asp:TextBox ID="txtCodice" runat="server" Text='<%# Bind("Codice")%>' Width="100%" MaxLength="16" />
                            <asp:RequiredFieldValidator ID="rfvtxtCodice" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="txtCodice" CssClass="Error" Display="Dynamic" />
                        </td>
                    </tr>
                    <tr>
                        <td class="Td-Text" width="150px">Descrizione</td>
                        <td class="Td-Value" width="350px">
                            <asp:TextBox ID="txtDescrizione" runat="server" Text='<%# Bind("Descrizione")%>' Width="100%" MaxLength="64" />
                            <asp:RequiredFieldValidator ID="rfvtxtDescrizione" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="txtDescrizione" CssClass="Error" Display="Dynamic" />
                        </td>
                    </tr>
                    <tr>
                        <td class="LeftFooter"></td>
                        <td class="RightFooter">
                            <asp:Button ID="btnSalva" runat="server" Text="OK" CssClass="Button" CommandName="Insert" CommandArgument="ParentRedirect"/>
                            <asp:Button ID="btnAnnulla" runat="server" Text="Annulla" CssClass="Button" CommandName="Cancel" ValidationGroup="none" />
                        </td>
                    </tr>
               </table>
        </InsertItemTemplate>
        <EditItemTemplate>
                <table class="table_dettagli" width="500px">
                    <tr>
                        <td class="Td-Text" width="150px">Azienda Erogante</td>
                        <td class="Td-Value" width="350px">
                            <asp:DropDownList ID="ddlAziendeEroganti" runat="server" Width="100%" DataSourceID="odsAziendeEroganti"
                                DataTextField="Descrizione" DataValueField="Codice" AppendDataBoundItems="true" SelectedValue='<%# Bind("AziendaErogante")%>'
                                AutoPostBack="True" OnSelectedIndexChanged="ddlAziendeEroganti_SelectedIndexChanged">
                                <asp:ListItem Text="" Value="" />
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rv2" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="ddlAziendeEroganti" CssClass="Error" Display="Dynamic" />
                        </td>
                    </tr>
                    <tr>
                        <td class="Td-Text" width="150px">Sistema Erogante</td>
                        <td class="Td-Value" width="350px">
                            <!-- NON BISOGNA METTERE IL SELECTED VALUE PERCHE' E' UNA COMBO IN CASCATA: E' GESTITO VIA CODICE -->
                            <asp:DropDownList ID="ddlSistemiEroganti" runat="server" Width="100%" DataSourceID="odsSistemiEroganti"
                                DataTextField="Descrizione" DataValueField="Codice" OnPreRender="ddlSistemiEroganti_PreRender">
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvddlSistemiEroganti" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="ddlSistemiEroganti" CssClass="Error" Display="Dynamic" />
                        </td>
                    </tr>
                    <tr>
                        <td class="Td-Text" width="150px">Codice esterno</td>
                        <td class="Td-Value" width="350px">
                            <asp:TextBox ID="txtCodiceEsterno" runat="server" Text='<%# Bind("CodiceEsterno")%>' Width="100%" MaxLength="16" />
                            <asp:RequiredFieldValidator ID="rfvtxtCodiceEsterno" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="txtCodiceEsterno" CssClass="Error" Display="Dynamic" />
                        </td>
                    </tr>
                    <tr>
                        <td class="Td-Text" width="150px">Codice transcodificato</td>
                        <td class="Td-Value" width="350px">
                            <asp:TextBox ID="txtCodice" runat="server" Text='<%# Bind("Codice")%>' Width="100%" MaxLength="16" />
                            <asp:RequiredFieldValidator ID="rfvtxtCodice" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="txtCodice" CssClass="Error" Display="Dynamic" />
                        </td>
                    </tr>
                    <tr>
                        <td class="Td-Text" width="150px">Descrizione</td>
                        <td class="Td-Value" width="350px">
                            <asp:TextBox ID="txtDescrizione" runat="server" Text='<%# Bind("Descrizione")%>' Width="100%" MaxLength="64" />
                            <asp:RequiredFieldValidator ID="rfvtxtDescrizione" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="txtDescrizione" CssClass="Error" Display="Dynamic" />
                        </td>
                    </tr>
                    <tr>
                        <td class="LeftFooter">
                            <asp:Button ID="btnElimina" runat="server" Text="Elimina" CssClass="Button" CommandName="Delete" CommandArgument="ParentRedirect" ValidationGroup="none"
                                OnClientClick="return msgboxYESNO('Si conferma la cancellazione della transcodifica?');" />
                        </td>
                        <td class="RightFooter">
                            <asp:Button ID="btnSalva" runat="server" Text="OK" CssClass="Button" CommandName="Update" CommandArgument="ParentRedirect"/>
                            <asp:Button ID="btnAnnulla" runat="server" Text="Annulla" CssClass="Button" CommandName="Cancel" ValidationGroup="none" />
                            <asp:Button ID="btnApplica" runat="server" Text="Applica" CssClass="Button" CommandName="Update" ValidationGroup="none" CommandArgument=""/>
                        </td>
                    </tr>
               </table>
        </EditItemTemplate>
    </asp:FormView>


    <asp:ObjectDataSource ID="odsAziendeEroganti" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.AziendeErogantiListaTableAdapter">
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="odsSistemiEroganti" runat="server" SelectMethod="GetDataByAziendaETipo"
        TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.SistemiErogantiListaTableAdapter" OldValuesParameterFormatString="{0}">
        <SelectParameters>
            <asp:Parameter Name="AziendaErogante" Type="String" />
            <asp:Parameter DefaultValue="referti" Name="Tipo" Type="String"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="odsMain" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetDataById" InsertMethod="Insert" TypeName="TranscodificheDataSetTableAdapters.TranscodificaPrioritaOttieniTableAdapter" UpdateMethod="Update" DeleteMethod="Delete">
        <InsertParameters>
            <asp:Parameter Name="AziendaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="SistemaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="CodiceEsterno" Type="String"></asp:Parameter>
            <asp:Parameter Name="Codice" Type="String"></asp:Parameter>
            <asp:Parameter Name="Descrizione" Type="String"></asp:Parameter>
        </InsertParameters>
        <SelectParameters>
            <asp:QueryStringParameter QueryStringField="Id" DbType="Guid" Name="Id"></asp:QueryStringParameter>
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter DbType="Guid" Name="Id"></asp:Parameter>
            <asp:Parameter Name="AziendaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="SistemaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="CodiceEsterno" Type="String"></asp:Parameter>
            <asp:Parameter Name="Codice" Type="String"></asp:Parameter>
            <asp:Parameter Name="Descrizione" Type="String"></asp:Parameter>
        </UpdateParameters>
    </asp:ObjectDataSource>


</asp:Content>
