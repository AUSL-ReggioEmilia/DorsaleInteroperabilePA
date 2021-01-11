<%@ Page Language="VB" MasterPageFile="~/Site.master" CodeBehind="Details.aspx.vb" Inherits="Details" %>

<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="Server">
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:DynamicDataManager ID="DynamicDataManager1" runat="server" AutoLoadForeignKeys="true">
        <DataControls>
            <asp:DataControlReference ControlID="FormView1" />
        </DataControls>
    </asp:DynamicDataManager>

    <%--    <div class="row" runat="server" id="divError" visible="false">
        <div class="col-sm-12">
            <div class="alert alert-danger">
                <asp:Label ID="lblError" runat="server" />
            </div>
        </div>
    </div>--%>

    <div class="row">
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <div class="col-sm-12">
                    <asp:ValidationSummary ID="ValidationSummary1" runat="server" EnableClientScript="true"
                        HeaderText="List degli errori:" CssClass="text-danger" />
                    <asp:DynamicValidator runat="server" ID="DetailsViewValidator" ControlToValidate="FormView1" Display="None" CssClass="text-danger" />
                </div>

                <div class="col-sm-12 col-md-10">
                    <h3 class="page-title"><%= DDHelper.GetTableFullName(table) %> - Dettaglio elemento</h3>

                    <asp:FormView
                        runat="server"
                        ID="FormView1"
                        DataSourceID="DetailsDataSource"
                        OnItemDeleted="FormView1_ItemDeleted"
                        OnItemCommand="FormView1_ItemCommand"
                        RenderOuterTable="false">
                        <ItemTemplate>
                            <div class="div-bianco">
                                <div class="form-horizontal" role="form">
                                    <asp:DynamicEntity runat="server" />
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-12">
                                    <div class="pull-left">
                                        <span class="btn btn-100 btn-default disabled"><i class="fas fa-trash-alt fa-lg"></i>&nbsp;Elimina</span>
                                    </div>
                                    <div class="pull-right text-right">
                                        <asp:DynamicHyperLink runat="server" Action="Edit" CssClass="btn btn-120 btn-primary">Abilita Modifica</asp:DynamicHyperLink>
                                        <span class="btn btn-100 btn-default disabled">Conferma</span>
                                        <%--<asp:DynamicHyperLink runat="server"  CssClass="btn btn-default disabled">Salva</asp:DynamicHyperLink>--%>
                                        <asp:LinkButton runat="server" CommandName="Cancel" CssClass="btn btn-100 btn-secondary" CausesValidation="false">Esci</asp:LinkButton>
                                    </div>
                                    <div class="clearfix"></div>
                                </div>
                            </div>
                        </ItemTemplate>
                        <EmptyDataTemplate>
                            <div class="DDNoItem">Elemento non trovato.</div>
                        </EmptyDataTemplate>
                    </asp:FormView>
                </div>

                <asp:LinqDataSource ID="DetailsDataSource" runat="server" EnableDelete="true" />

                <asp:QueryExtender TargetControlID="DetailsDataSource" ID="DetailsQueryExtender" runat="server">
                    <asp:DynamicRouteExpression />
                </asp:QueryExtender>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
</asp:Content>

