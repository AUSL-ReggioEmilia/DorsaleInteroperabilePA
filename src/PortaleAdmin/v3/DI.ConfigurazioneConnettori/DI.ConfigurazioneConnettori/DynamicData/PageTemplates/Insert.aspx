<%@ Page Language="VB" MasterPageFile="~/Site.master" CodeBehind="Insert.aspx.vb" Inherits="Insert" %>

<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="Server">
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:DynamicDataManager ID="DynamicDataManager1" runat="server" AutoLoadForeignKeys="true">
        <DataControls>
            <asp:DataControlReference ControlID="FormView1" />
        </DataControls>
    </asp:DynamicDataManager>

    <%--	<div class="row" runat="server" id="divError" visible="false">
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
                        HeaderText="<strong>Non è possibile salvare, sono presenti i seguenti errori:</strong>"
                        CssClass="alert alert-danger text-danger" />
                    <asp:DynamicValidator runat="server" ID="DetailsViewValidator" ControlToValidate="FormView1" Display="None" CssClass="alert alert-danger text-danger" />
                </div>
                <div class="col-sm-12 col-md-10">
                    <h3 class="page-title"><%= DDHelper.GetTableFullName(table) %> - Inserimento elemento</h3>

                    <asp:FormView runat="server" ID="FormView1" DataSourceID="DetailsDataSource" DefaultMode="Insert"
                        OnItemCommand="FormView1_ItemCommand" RenderOuterTable="false">
                        <InsertItemTemplate>
                            <div class="div-bianco">
                                <div class="form-horizontal" role="form">
                                    <asp:DynamicEntity runat="server" Mode="Insert" />
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-12 text-right">
                                    <asp:LinkButton runat="server" CommandName="Insert" CssClass="btn btn-100 btn-primary" >Inserisci</asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="Cancel" CssClass="btn btn-100 btn-secondary" CausesValidation="false">Annulla</asp:LinkButton>
                                </div>
                            </div>
                        </InsertItemTemplate>
                    </asp:FormView>
                </div>
                <asp:LinqDataSource ID="DetailsDataSource" runat="server" EnableInsert="true" />
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>


</asp:Content>

