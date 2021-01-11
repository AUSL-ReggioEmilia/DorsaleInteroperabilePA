<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Page.Master" CodeBehind="AdminPage.aspx.vb" Inherits=".AdminPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <div class="row" id="divErrorMessage" runat="server" visible="false">
        <div class="col-sm-12">
            <div class="alert alert-danger">
                <asp:Label ID="LabelError" runat="server" CssClass="text-danger"></asp:Label>
            </div>
        </div>
    </div>


	<div class="row">
		<div class="col-sm-12">
			<div id="IdDivClaims" runat="server" visible="true">
				<h2 class="text-center">
					<asp:Label ID="lblTitoloListaClaims" runat="server" Text="Elenco degli Accessi Role Manager"></asp:Label></h2>
				<hr />
				
                <div class="table-condensed">

                    <asp:GridView ID="gvClaims" runat="server" AutoGenerateColumns="False" DataSourceID="odsClaims" CssClass="table table-bordered table-condensed small">
                        <Columns>
                            <asp:BoundField DataField="Claims" HeaderText="Accessi Role Manager" SortExpression="Claims" ReadOnly="True"></asp:BoundField>
                        </Columns>
                    </asp:GridView>

                    <asp:ObjectDataSource ID="odsClaims" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataTable" TypeName="ClaimsInfo">
                        <SelectParameters>
                        </SelectParameters>
                    </asp:ObjectDataSource>
                </div>

			</div>
		</div>
	</div>

</asp:Content>
