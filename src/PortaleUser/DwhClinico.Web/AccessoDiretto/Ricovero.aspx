<%@ Page Language="VB" MasterPageFile="~/AccessoDiretto/AccessoDiretto.master" AutoEventWireup="false" Inherits="DwhClinico.Web.AccessoDiretto_Ricovero" Title="" CodeBehind="Ricovero.aspx.vb" %>

<%@ Register Src="~/UserControl/ucTestataPaziente.ascx" TagPrefix="uc1" TagName="ucTestataPaziente" %>
<%@ Register Src="~/UserControl/ucInfoPaziente.ascx" TagPrefix="uc1" TagName="ucInfoPaziente" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <div class="row" id="divErrorMessage" visible="false" runat="server">
        <div class="col-sm-12">
            <div class="alert alert-danger">
                <asp:Label ID="lblErrorMessage" runat="server" CssClass="text-danger"></asp:Label>
            </div>
        </div>
    </div>

    <div class="divPage" id="divPage" runat="server">

        <uc1:ucTestataPaziente runat="server" ID="ucTestataPaziente" />

        <uc1:ucInfoPaziente runat="server" ID="ucInfoPaziente" />

        <div class="row" id="divInfoRicovero" runat="server">
            <div class="col-sm-12">
                <label class="label label-default">Episodio</label>
                <div class="well well-sm small">
                    <asp:Xml EnableViewState="false" ViewStateMode="Enabled" ID="XmlInfoRicovero" runat="server"></asp:Xml>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-sm-12">
                <asp:GridView CssClass="table table-bordered table-striped gridView-custom-margin small" ID="WebGridEventi" runat="server" AutoGenerateColumns="False" DataSourceID="DataSourceRicoveroEventi">
                    <Columns>
                        <asp:TemplateField HeaderText="Evento">
                            <ItemTemplate>
                                <%# GetEventoEpisodioDescr(Container.DataItem) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Data">
                            <ItemTemplate>
                                <%# GetDataEventoEpisodio(Container.DataItem) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Reparto di Ricovero">
                            <ItemTemplate>
                                <%# GetEventoRepartoRicovero(Container.DataItem) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Settore di Ricovero">
                            <ItemTemplate>
                                <%# GetEventoSettoreRicovero(Container.DataItem) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Letto di Ricovero">
                            <ItemTemplate>
                                <%# GetEventoLettoRicovero(Container.DataItem) %>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <div class="row" id="divMessage" runat="server">
            <div class="col-sm-12">
                <asp:Label ID="lblMessage" runat="server"></asp:Label>
            </div>
        </div>
    </div>
    <asp:ObjectDataSource ID="DataSourceRicoveroEventi" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DwhClinico.Web.CustomDataSource.AccessoDirettoEventiEpisodioCercaPerId">
        <SelectParameters>
            <asp:Parameter Name="Token" Type="Object"></asp:Parameter>
            <asp:Parameter DbType="Guid" Name="IdRicovero"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
