<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PcRichiedentiStampantiDetail.aspx.vb" Inherits="PrintDispatcherAdmin.PcRichiedentiStampantiDetail" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">

    <div class="row">
        <div class="col-sm-10 col-md-8 col-lg-6">

            <h3 class="page-title">
                <asp:Label ID="lblTitle" runat="server" Text=""></asp:Label>
            </h3>

            <asp:Panel ID="PanelFormView" runat="server" Width="100%">
                <asp:FormView ID="MainFormView" runat="server" DataKeyNames="Id" DataSourceID="MainDataSource" Style="width: 100%;" DefaultMode="Insert">
                    <InsertItemTemplate>
                        <%--<div class="panel-heading">
                                <h3 class="panel-title">Nuova stampante</h3>
                            </div>--%>
                        <div class="div-bianco">
                            <div class="form-horizontal form-horizontal-mb-5">
                                <div class="form-group">
                                    <asp:Label Text="Tipo Stampante (*)" runat="server" AssociatedControlID="ddlTipoStampante" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:DropDownList class="ddlTipoStampante" ID="ddlTipoStampante" runat="server" DataValueField="Id" DataTextField="Descrizione" CssClass="form-control input-sm"
                                            SelectedValue='<%# Bind("IdTipiStampante") %>' DataSourceID="TipiStampanteDataSource" Width="50%" AutoPostBack="True">
                                        </asp:DropDownList>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text=" Server di stampa" runat="server" AssociatedControlID="txtServerDiStampa" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:TextBox ID="txtServerDiStampa" runat="server" Text='<%# Bind("ServerDiStampa") %>' MaxLength="64" CssClass="form-control input-sm" Width="100%" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Stampante (*)" runat="server" AssociatedControlID="txtStampante" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:TextBox ID="txtStampante" runat="server" Text='<%# Bind("Stampante") %>' MaxLength="512" CssClass="form-control input-sm" Width="100%" />
                                        <asp:RequiredFieldValidator ID="rfvStampante" runat="server" ControlToValidate="txtStampante" CssClass="text-danger"
                                            ErrorMessage='Campo obbligatorio' Display="Dynamic"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Tipo Modulo (*)" runat="server" AssociatedControlID="ddlTipoModulo" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:DropDownList ID="ddlTipoModulo" runat="server" SelectedValue='<%# Bind("TipoModulo") %>' Width="50%" AutoPostBack="True" OnSelectedIndexChanged="ddlTipoModulo_SelectedIndexChanged" CssClass="form-control input-sm">
                                            <asp:ListItem Value="" Text="" Selected="True" />
                                            <asp:ListItem Value="ETICHETTE" Text="ETICHETTE" />
                                            <asp:ListItem Value="ALTRO" Text="ALTRO" />
                                        </asp:DropDownList>
                                        <asp:RequiredFieldValidator ID="rfvTipoModulo" runat="server" ControlToValidate="ddlTipoModulo" CssClass="text-danger"
                                            ErrorMessage='Campo obbligatorio' Display="Dynamic"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Formato Modulo (*)" runat="server" AssociatedControlID="ddlFormatoModulo" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <!-- NON BISOGNA METTERE IL SELECTED VALUE PERCHE' E' UNA COMBO IN CASCATA: E' GESTITO VIA CODICE -->
                                        <asp:DropDownList class="ddlFormatoModulo" ID="ddlFormatoModulo" runat="server" DataTextField="Descrizione" DataValueField="Descrizione" CssClass="form-control input-sm"
                                            DataSourceID="FormatoModuloDataSource" Width="50%" OnPreRender="ddlFormatoModulo_PreRender">
                                        </asp:DropDownList>
                                        <asp:RequiredFieldValidator ID="rfvFormatoModulo" runat="server" ControlToValidate="ddlFormatoModulo" CssClass="text-danger"
                                            ErrorMessage='Campo obbligatorio' Display="Dynamic"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Server Virtuale (*)" runat="server" AssociatedControlID="ddlServerVirtuale" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:DropDownList ID="ddlServerVirtuale" runat="server" DataValueField="Nome" DataTextField="Nome" CssClass="form-control input-sm"
                                            SelectedValue='<%# Bind("ServerVirtuale") %>' DataSourceID="ServerVirtualeDataSource" Width="50%">
                                        </asp:DropDownList>
                                        <asp:RequiredFieldValidator ID="rfvServerVirtuale" runat="server" ControlToValidate="ddlServerVirtuale" CssClass="text-danger"
                                            ErrorMessage='Campo obbligatorio' Display="Dynamic"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-sm-12">
                                <div class="text-right">
                                    <asp:Button ID="InsertButton" runat="server" CssClass="btn btn-100 btn-primary btn-sm" CausesValidation="True"
                                        CommandName="Insert" CommandArgument="ParentRedirect" Text="Inserisci" />
                                <asp:Button ID="InsertCancelButton" runat="server" CssClass="btn btn-100 btn-secondary btn-sm" CausesValidation="False"
                                    CommandName="Cancel" Text="Annulla" />
                                </div>
                            </div>
                        </div>
                    </InsertItemTemplate>

                    <EditItemTemplate>
                        <%--<div class="panel-heading">
                                <h3 class="panel-title">Dettaglio stampante</h3>
                            </div>--%>
                        <div class="div-bianco">
                            <div class="form-horizontal form-horizontal-mb-5 ">
                                <div class="form-group">
                                    <asp:Label Text="Tipo Stampante (*)" runat="server" AssociatedControlID="ddlTipoStampante" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:DropDownList class="ddlTipoStampante" ID="ddlTipoStampante" runat="server" DataValueField="Id" DataTextField="Descrizione" CssClass="form-control input-sm"
                                            SelectedValue='<%# Bind("IdTipiStampante") %>' DataSourceID="TipiStampanteDataSource" Width="50%" AutoPostBack="True">
                                        </asp:DropDownList>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text=" Server di stampa" runat="server" AssociatedControlID="txtServerDiStampa" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:TextBox ID="txtServerDiStampa" runat="server" Text='<%# Bind("ServerDiStampa") %>' MaxLength="64" CssClass="form-control input-sm" Width="100%" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Stampante (*)" runat="server" AssociatedControlID="txtStampante" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:TextBox ID="txtStampante" runat="server" Text='<%# Bind("Stampante") %>' MaxLength="512" CssClass="form-control input-sm" Width="100%" />
                                        <asp:RequiredFieldValidator ID="rfvStampante" runat="server" ControlToValidate="txtStampante" CssClass="text-danger"
                                            ErrorMessage='Campo obbligatorio' Display="Dynamic"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Tipo Modulo (*)" runat="server" AssociatedControlID="ddlTipoModulo" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:DropDownList ID="ddlTipoModulo" runat="server" SelectedValue='<%# Bind("TipoModulo") %>' Width="50%" AutoPostBack="True" OnSelectedIndexChanged="ddlTipoModulo_SelectedIndexChanged" CssClass="form-control input-sm">
                                            <asp:ListItem Value="" Text="" Selected="True" />
                                            <asp:ListItem Value="ETICHETTE" Text="ETICHETTE" />
                                            <asp:ListItem Value="ALTRO" Text="ALTRO" />
                                        </asp:DropDownList>
                                        <asp:RequiredFieldValidator ID="rfvTipoModulo" runat="server" ControlToValidate="ddlTipoModulo" CssClass="text-danger"
                                            ErrorMessage='Campo obbligatorio' Display="Dynamic"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Formato Modulo (*)" runat="server" AssociatedControlID="ddlFormatoModulo" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <!-- NON BISOGNA METTERE IL SELECTED VALUE PERCHE' E' UNA COMBO IN CASCATA: E' GESTITO VIA CODICE -->
                                        <asp:DropDownList class="ddlFormatoModulo" ID="ddlFormatoModulo" runat="server" DataTextField="Descrizione" DataValueField="Descrizione" CssClass="form-control input-sm"
                                            DataSourceID="FormatoModuloDataSource" Width="50%" OnPreRender="ddlFormatoModulo_PreRender">
                                        </asp:DropDownList>
                                        <asp:RequiredFieldValidator ID="rfvFormatoModulo" runat="server" ControlToValidate="ddlFormatoModulo" CssClass="text-danger"
                                            ErrorMessage='Campo obbligatorio' Display="Dynamic"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label Text="Server Virtuale (*)" runat="server" AssociatedControlID="ddlServerVirtuale" CssClass="col-sm-4 control-label" />
                                    <div class="col-sm-8">
                                        <asp:DropDownList ID="ddlServerVirtuale" runat="server" DataValueField="Nome" DataTextField="Nome" CssClass="form-control input-sm"
                                            SelectedValue='<%# Bind("ServerVirtuale") %>' DataSourceID="ServerVirtualeDataSource" Width="50%">
                                        </asp:DropDownList>
                                        <asp:RequiredFieldValidator ID="rfvServerVirtuale" runat="server" ControlToValidate="ddlServerVirtuale" CssClass="text-danger"
                                            ErrorMessage='Campo obbligatorio' Display="Dynamic"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-12">
                                <div class="pull-left">
                                    <asp:LinkButton ID="UpdateDeleteButton" runat="server" CssClass="btn btn-100 btn-danger btn-sm" CausesValidation="False"
                                     CommandName="Delete" OnClientClick="return confirm('Procedere con la cancellazione del record?');">
                                    <i class="fas fa-trash-alt fa-lg"></i>&nbsp;Elimina</asp:LinkButton>
                                </div>
                                <div class="pull-right">
                                    <asp:Button ID="UpdateButtonOK" runat="server" CssClass="btn btn-100 btn-primary btn-sm" CausesValidation="True"
                                        CommandName="Update" CommandArgument="ParentRedirect" Text="Conferma" data-toggle="popover" data-placement="bottom" data-trigger="hover" data-content="Salva ed Esci"/>
                                    <asp:Button ID="UpdateCancelButton" runat="server" CssClass="btn btn-100 btn-secondary btn-sm" CausesValidation="False"
                                        CommandName="Cancel" Text="Annulla" />
                                    <asp:LinkButton ID="UpdateButtonApply" CommandArgument="SelfRedirect" runat="server" CssClass="btn btn-100 btn-primary btn-sm" CausesValidation="True" 
                                        CommandName="Update" data-toggle="popover" data-placement="bottom" data-trigger="hover" data-content="Salva">
                                    <i class="far fa-save fa-lg"></i>&nbsp;Applica</asp:LinkButton>
                                    
                                </div>
                            </div>
                        </div>
                    </EditItemTemplate>
                </asp:FormView>
            </asp:Panel>
        </div>
    </div>

    <asp:ObjectDataSource ID="MainDataSource" runat="server" SelectMethod="GetData" TypeName="DataAccess.PcRichiedentiDatasetTableAdapters.PcRichiedentiStampantiSelectTableAdapter"
        DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
        <UpdateParameters>
            <asp:QueryStringParameter Name="Id" DbType="Guid" QueryStringField="id" />
            <asp:Parameter Name="UtenteModifica" Type="String" />
            <asp:Parameter Name="ServerDiStampa" Type="String" />
            <asp:Parameter Name="Stampante" Type="String" />
            <asp:Parameter Name="IdTipiStampante" Type="Int16" />
            <asp:Parameter Name="TipoModulo" Type="String" />
            <asp:Parameter Name="FormatoModulo" Type="String" />
            <asp:Parameter Name="ServerVirtuale" Type="String" />
        </UpdateParameters>
        <SelectParameters>
            <asp:QueryStringParameter DbType="Guid" Name="Id" QueryStringField="id" />
        </SelectParameters>
        <InsertParameters>
            <asp:QueryStringParameter Name="IdPcRichiedenti" DbType="Guid" QueryStringField="IdPcRichiedenti" />
            <asp:Parameter Name="UtenteInserimento" Type="String" />
            <asp:Parameter Name="ServerDiStampa" Type="String" />
            <asp:Parameter Name="Stampante" Type="String" />
            <asp:Parameter Name="IdTipiStampante" Type="Int16" />
            <asp:Parameter Name="TipoModulo" Type="String" />
            <asp:Parameter Name="FormatoModulo" Type="String" />
            <asp:Parameter Name="ServerVirtuale" Type="String" />
        </InsertParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="TipiStampanteDataSource" runat="server" SelectMethod="GetData" TypeName="DataAccess.ComboDatasetTableAdapters.TipiStampanteComboTableAdapter">
        <SelectParameters>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="ServerVirtualeDataSource" runat="server" SelectMethod="GetData" TypeName="DataAccess.ComboDatasetTableAdapters.ServerVirtualiComboTableAdapter">
        <SelectParameters>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="FormatoModuloDataSource" runat="server" SelectMethod="GetData" TypeName="DataAccess.ComboDatasetTableAdapters.FormatiModuliComboTableAdapter" EnableCaching="false">
        <SelectParameters>
            <asp:Parameter Name="TipoModulo" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
