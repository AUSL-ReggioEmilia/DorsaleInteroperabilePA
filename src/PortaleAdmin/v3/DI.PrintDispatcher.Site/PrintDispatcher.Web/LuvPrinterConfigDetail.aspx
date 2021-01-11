<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="LuvPrinterConfigDetail.aspx.vb" Inherits="PrintDispatcherAdmin.LuvPrinterConfigDetail" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Panel ID="Panel1" runat="server" Width="700px" CssClass="roundedPanel">
        <asp:FormView ID="MainFormView" runat="server" DataKeyNames="Id" DataSourceID="MainDataSource"
            DefaultMode="Insert">
            <InsertItemTemplate>
                <table cellpadding="3" cellspacing="0" border="0">
                    <tr>
                        <td style="width: 200px;">
                        </td>
                        <td style="width: 500px;">
                        </td>
                    </tr>
                    <tr style="height: 20px;">
                        <td class="td-Text">
                            Pc invio richiesta (*)
                        </td>
                        <td class="td-Value">
                            <asp:TextBox ID="txtPeriferica" runat="server" Text='<%# Bind("Periferica") %>' MaxLength="128"
                                Width="100%"  />
                            <asp:RequiredFieldValidator ID="rfvPeriferica" runat="server" ControlToValidate="txtPeriferica"
                                ErrorMessage='Campo obbligatorio' display="Dynamic"></asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr style="height: 20px;">
                        <td class="td-Text">
                            Tipo Stampante (*)
                        </td>
                        <td class="td-Value">
                            <asp:DropDownList class="ddlTipoStampante" ID="ddlTipoStampante" runat="server"  DataValueField="Id"  DataTextField="Descrizione" 
                                SelectedValue='<%# Bind("IdTipiStampante") %>' DataSourceId="ddlTipiStampanteDataSource"  width="50%" AutoPostBack="True">
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr style="height: 20px;">
                        <td class="td-Text">
                            Server di stampa
                        </td>
                        <td class="td-Value">
                            <asp:TextBox class="txtPrintServerName" ID="txtPrintServerName" runat="server" Text='<%# Bind("ServerDiStampa") %>'
                                MaxLength="64" Width="100%"  />
                        </td>
                    </tr>
                    <tr style="height: 20px;">
                        <td class="td-Text">
                            Stampante (*)
                        </td>
                        <td class="td-Value">
                            <asp:TextBox ID="txtStampante" runat="server" Text='<%# Bind("Stampante") %>' MaxLength="512"
                                Width="100%" />
                            <asp:RequiredFieldValidator ID="rfvStampante" runat="server" ControlToValidate="txtStampante"
                                ErrorMessage='Campo obbligatorio' display="Dynamic" ></asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr style="height: 20px;">
                        <td class="td-Text">
                            Server virtuale (*)
                        </td>
                        <td class="td-Value">
                            <asp:DropDownList ID="ddlServerVirtuale" runat="server"  DataValueField="Nome"  DataTextField="Nome" 
                                SelectedValue='<%# Bind("ServerVirtuale") %>' DataSourceId="ddlServerVirtualeDataSource"  width="50%">
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <br />
                        </td>
                        <td style="text-align: right">
                            <br />
                            <asp:Button ID="InsertButton" runat="server" CssClass="button" CausesValidation="True"
                                CommandName="Insert" CommandArgument="ParentRedirect" Text="OK" />
                            <asp:Button ID="InsertCancelButton" runat="server" CssClass="button" CausesValidation="False"
                                CommandName="Cancel" Text="Annulla" />
                        </td>
                    </tr>
                </table>
            </InsertItemTemplate>
            <EditItemTemplate>
                <table cellpadding="3" cellspacing="0" border="0">
                    <tr>
                        <td style="width: 200px;">
                        </td>
                        <td style="width: 500px;">
                        </td>
                    </tr>
                    <tr style="height: 20px;">
                        <td class="td-Text">
                            Pc invio richiesta (*)
                        </td>
                        <td class="td-Value">
                            <asp:TextBox ID="txtPeriferica" runat="server" Text='<%# Bind("Periferica") %>' MaxLength="64"
                                Width="100%" />
                            <asp:RequiredFieldValidator ID="rfvPeriferica" runat="server" ControlToValidate="txtPeriferica"
                                ErrorMessage='Campo obbligatorio' display="Dynamic"></asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr style="height: 20px;">
                        <td class="td-Text">
                            Tipo Stampante (*)
                        </td>
                        <td class="td-Value">
                            <asp:DropDownList class="ddlTipoStampante" ID="ddlTipoStampante" runat="server"  DataValueField="Id"  DataTextField="Descrizione" 
                                SelectedValue='<%# Bind("IdTipiStampante") %>' DataSourceId="ddlTipiStampanteDataSource" width="50%" AutoPostBack="True">
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr style="height: 20px;">
                        <td class="td-Text">
                            Server di stampa
                        </td>
                        <td class="td-Value">
                            <asp:TextBox class="txtPrintServerName"  ID="txtPrintServerName" runat="server" Text='<%# Bind("ServerDiStampa") %>'
                                MaxLength="64" Width="100%" />
                        </td>
                    </tr>
                    <tr style="height: 20px;">
                        <td class="td-Text">
                            Stampante (*)
                        </td>
                        <td class="td-Value">
                            <asp:TextBox  ID="txtStampante" runat="server" Text='<%# Bind("Stampante") %>' MaxLength="512"
                                Width="100%" />
                            <asp:RequiredFieldValidator ID="rfvStampante" runat="server" ControlToValidate="txtStampante"
                                ErrorMessage='Campo obbligatorio' display="Dynamic"></asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr style="height: 20px;">
                        <td class="td-Text">
                            Server virtuale (*)
                        </td>
                        <td class="td-Value">
                            <asp:DropDownList ID="ddlServerVirtuale" runat="server"  DataValueField="Nome"  DataTextField="Nome" 
                                SelectedValue='<%# Bind("ServerVirtuale") %>' DataSourceId="ddlServerVirtualeDataSource" width="50%">
                            </asp:DropDownList>
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <br />
                            <asp:Button ID="UpdateDeleteButton" runat="server" CssClass="button" CausesValidation="False"
                                CommandName="Delete" Text="Elimina" OnClientClick="return confirm('Procedere con la cancellazione del record?');" />
                        </td>
                        <td style="text-align: right">
                            <br />
                            <asp:Button ID="UpdateButtonOK" runat="server" CssClass="button" CausesValidation="True"
                                CommandName="Update" CommandArgument="ParentRedirect" Text="OK" />
                            <asp:Button ID="UpdateButtonApply" CommandArgument="SelfRedirect" runat="server"
                                CssClass="button" CausesValidation="True" CommandName="Update" Text="Applica" />
                            <asp:Button ID="UpdateCancelButton" runat="server" CssClass="button" CausesValidation="False"
                                CommandName="Cancel" Text="Annulla" />
                        </td>
                    </tr>
                </table>
            </EditItemTemplate>
        </asp:FormView>
    </asp:Panel>
    <cc1:RoundedCornersExtender ID="RoundedCornersExtender1" runat="server" TargetControlID="Panel1"
        BorderColor="#C8C8C8">
    </cc1:RoundedCornersExtender>
    <asp:ObjectDataSource ID="MainDataSource" runat="server" SelectMethod="GetData" TypeName="DataAccess.LuvPrinterConfigDatasetTableAdapters.LuvPrinterConfigSelectTableAdapter"
        DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
        <UpdateParameters>
            <asp:Parameter DbType="Guid" Name="Id" />
            <asp:Parameter Name="AziendaRichiedente" Type="String" />
            <asp:Parameter Name="SistemaRichiedente" Type="String" />
            <asp:Parameter Name="UnitaOperativa" Type="String" />
            <asp:Parameter Name="Periferica" Type="String" />
            <asp:Parameter Name="Utente" Type="String" />
            <asp:Parameter Name="Dal" Type="DateTime" />
            <asp:Parameter Name="Al" Type="DateTime" />
            <asp:Parameter Name="ServerDiStampa" Type="String" />
            <asp:Parameter Name="Stampante" Type="String" />
            <asp:Parameter Name="ServerVirtuale" Type="String" />
            <asp:Parameter Name="IdTipiSTampante" Type="Int16" />
        </UpdateParameters>
        <SelectParameters>
            <asp:QueryStringParameter DbType="Guid" Name="Id" QueryStringField="id" />
        </SelectParameters>
        <InsertParameters>
            <asp:Parameter Name="AziendaRichiedente" Type="String" />
            <asp:Parameter Name="SistemaRichiedente" Type="String" />
            <asp:Parameter Name="UnitaOperativa" Type="String" />
            <asp:Parameter Name="Periferica" Type="String" />
            <asp:Parameter Name="Utente" Type="String" />
            <asp:Parameter Name="Dal" Type="DateTime" />
            <asp:Parameter Name="Al" Type="DateTime" />
            <asp:Parameter Name="ServerDiStampa" Type="String" />
            <asp:Parameter Name="Stampante" Type="String" />
            <asp:Parameter Name="ServerVirtuale" Type="String" />
            <asp:Parameter Name="IdTipiSTampante" Type="Int16" />
        </InsertParameters>
    </asp:ObjectDataSource>
    
    <asp:ObjectDataSource ID="ddlServerVirtualeDataSource" runat="server" SelectMethod="GetData" TypeName="DataAccess.LuvPrinterConfigDatasetTableAdapters.LuvPrinterConfigServerVirtualiComboTableAdapter" >
        <SelectParameters>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="ddlTipiStampanteDataSource" runat="server" SelectMethod="GetData" TypeName="DataAccess.LuvPrinterConfigDatasetTableAdapters.TipiStampanteComboTableAdapter" >
        <SelectParameters>
        </SelectParameters>
    </asp:ObjectDataSource>

</asp:Content>
