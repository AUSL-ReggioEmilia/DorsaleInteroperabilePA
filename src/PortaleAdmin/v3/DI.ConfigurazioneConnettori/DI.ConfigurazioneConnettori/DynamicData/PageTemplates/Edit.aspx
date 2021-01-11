<%@ Page Language="VB" MasterPageFile="~/Site.master" CodeBehind="Edit.aspx.vb" Inherits="Edit" %>

<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="Server">
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:DynamicDataManager ID="DynamicDataManager1" runat="server" AutoLoadForeignKeys="true">
        <DataControls>
            <asp:DataControlReference ControlID="FormView1" />
        </DataControls>
    </asp:DynamicDataManager>

    <div class="row">
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <div class="col-sm-12">
                    <asp:ValidationSummary
                        ID="ValidationSummary1"
                        runat="server"
                        EnableClientScript="true"
                        HeaderText="<strong>Non è possibile salvare, sono presenti i seguenti errori:</strong>"
                        CssClass="alert alert-danger" />
                    <asp:DynamicValidator
                        runat="server"
                        ID="DetailsViewValidator"
                        ControlToValidate="FormView1"
                        Display="None"
                        CssClass="alert alert-danger" />
                </div>
                <div class="col-sm-12 col-md-10">
                    <h3 class="page-title"><%= DDHelper.GetTableFullName(table) %> - Modifica elemento</h3>

                    <asp:FormView
                        runat="server"
                        ID="FormView1"
                        DataSourceID="DetailsDataSource"
                        DefaultMode="Edit"
                        OnItemCommand="FormView1_ItemCommand"
                        OnItemUpdated="FormView1_ItemUpdated"
                        RenderOuterTable="false">
                        <EditItemTemplate>
                            <div class="div-bianco">
                                <div class="form-horizontal" role="form">
                                    <asp:DynamicEntity runat="server" Mode="Edit" />
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-12">
                                    <div class="pull-left">
                                        <asp:LinkButton runat="server" CommandName="Delete" CssClass="btn btn-100 btn-danger "
                                            OnClientClick="return confirm('Si conferma l\'eliminazione dell\'elemento?');">
                                    <i class="fas fa-trash-alt"></i>&nbsp;Elimina</asp:LinkButton>
                                    </div>
                                    <div class="pull-right text-right">
                                        <asp:LinkButton runat="server" CommandName="Update" CssClass="btn btn-100 btn-primary">Conferma</asp:LinkButton>
                                        <asp:LinkButton runat="server" CommandName="Cancel" CssClass="btn btn-100 btn-secondary" CausesValidation="false">Annulla</asp:LinkButton>
                                    </div>
                                    <div class="clearfix"></div>
                                </div>
                            </div>
                        </EditItemTemplate>
                        <EmptyDataTemplate>
                            <div class="DDNoItem">Elemento non presente.</div>
                        </EmptyDataTemplate>
                    </asp:FormView>
                </div>
                <asp:LinqDataSource ID="DetailsDataSource" runat="server" EnableUpdate="true" EnableDelete="true" />

                <asp:QueryExtender TargetControlID="DetailsDataSource" ID="DetailsQueryExtender" runat="server">
                    <asp:DynamicRouteExpression />
                </asp:QueryExtender>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>



</asp:Content>

