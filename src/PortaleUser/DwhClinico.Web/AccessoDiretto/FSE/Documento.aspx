<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/AccessoDiretto/AccessoDiretto.master" CodeBehind="Documento.aspx.vb" Inherits="DwhClinico.Web.Documento" %>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="server">
	<div class="row" id="divErrorMessage" visible="false" runat="server">
		<div class="col-sm-12">
			<div class="alert alert-danger">
				<asp:Label ID="lblErrorMessage" runat="server" CssClass="text-danger"></asp:Label>
			</div>
		</div>
	</div>

	<div class="row">
		<div class="col-sm-9 col-md-9 col-lg-10">
			<%-- IFRAME --%>
			<div class="embed-responsive embed-responsive-16by9">
				<div id="IFrameContent" class="IFrameContent">
					<iframe id="IframeMain" runat="server" class="ExpandWidthHeight" frameborder="0"
						scrolling="no"></iframe>
				</div>
			</div>
		</div>
		<div class="col-sm-3 col-md-3 col-lg-2">
			<div id="rightSidebar" data-offset-top="64" data-spy="affix" style="right: 10px;">
				<div class="custom-margin-right-sidebar">
					<div class="row">
						<div class="form-group form-group-sm">
							<div class="col-sm-12">
								<asp:Button ID="BtnIndietro" runat="server" Text="Indietro" CssClass="btn-custom-margin-bottom btn btn-primary btn-block btn-sm" />
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<asp:ObjectDataSource runat="server" />

</asp:Content>
