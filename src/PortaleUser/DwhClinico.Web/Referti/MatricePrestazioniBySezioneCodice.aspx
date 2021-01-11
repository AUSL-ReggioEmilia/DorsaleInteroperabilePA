<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Portale/Default.master" CodeBehind="MatricePrestazioniBySezioneCodice.aspx.vb" Inherits="DwhClinico.Web.MatricePrestazioniBySezioneCodice" %>

<%@ Register Src="~/UserControl/ucTestataPaziente.ascx" TagPrefix="uc1" TagName="ucTestataPaziente" %>


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

            <%-- TESTATA PAZIENTE --%>
            <uc1:ucTestataPaziente runat="server" ID="ucTestataPaziente" />

            <div id="divMessage" class="well well-sm" runat="server" visible="false" enableviewstate="false"></div>

            <div class="table-responsive">
                <asp:Xml ID="XmlRisultatoMatrice" runat="server" TransformSource="~/Xslt/MatricePrestazioni.xsl"></asp:Xml>
            </div>
        </div>
        <div class="col-sm-3 col-md-3 col-lg-2">
            <%-- PANNELLO FILTRI LATERALI--%>
            <div id="rightSidebar" data-offset-top="65" data-spy="affix">
                <div class="custom-margin-right-sidebar">
                    <div class="row">
                        <div class="col-sm-12">
                            <asp:Button ID="cmdEsci" CssClass="btn btn-primary btn-sm btn-block btn-custom-margin-bottom" Text="Torna indietro" runat="server" />

                            <div id="divFiltersContainer" class="panel panel-default" runat="server">
                                <div class="panel-body">
                                    <div class="form-horizontal">
                                        <div class="form-group form-group-sm">
                                            <asp:Label ID="lblDallaData" runat="server" Text="Da:" CssClass="col-sm-2 control-label" AssociatedControlID="txtDataDal"></asp:Label>
                                            <div class="col-sm-10">
                                                <asp:TextBox ID="txtDataDal" runat="server" CssClass="form-control form-control-dataPicker" MaxLength="10" placeholder="es 22/11/1996"></asp:TextBox>
                                                <asp:RequiredFieldValidator CssClass="label label-danger" Display="Dynamic" ErrorMessage="Campo Obbligatorio" ControlToValidate="txtDataDal" runat="server" />
                                                <asp:CompareValidator ID="CompareValidator1" Type="Date" Operator="DataTypeCheck" CssClass="label label-danger" Display="Dynamic" runat="server" ErrorMessage="Formato data non valido" ControlToValidate="txtDataDal"></asp:CompareValidator>
                                                <asp:RangeValidator ID="RangeValAutorizzatoreDataNascita" Type="Date" MinimumValue="1900-01-01"
                                                    MaximumValue="3000-01-01" ControlToValidate="txtDataDal" CssClass="label label-danger"
                                                    runat="server" ErrorMessage="Inserire una data nell'intervallo </br> 01/01/1900 e 01/01/3000" Display="Dynamic"></asp:RangeValidator>
                                            </div>
                                        </div>
                                        <div class="form-group form-group-sm">
                                            <asp:Label ID="lblAllaData" runat="server" Text="a:" CssClass="col-sm-2 control-label " AssociatedControlID="txtDataDal"></asp:Label>
                                            <div class="col-sm-10">
                                                <asp:TextBox ID="txtAllaData" MaxLength="10" runat="server" CssClass="form-control form-control-dataPicker" placeholder="es 22/11/1996"></asp:TextBox>
                                                <asp:CompareValidator ID="CompareValidator2" Type="Date" Operator="DataTypeCheck" CssClass="label label-danger" Display="Dynamic" runat="server" ErrorMessage="Formato data non valido" ControlToValidate="txtAllaData"></asp:CompareValidator>
                                                <asp:RangeValidator ID="RangeValidator1" Type="Date" MinimumValue="1900-01-01"
                                                    MaximumValue="3000-01-01" ControlToValidate="txtAllaData" CssClass="label label-danger"
                                                    runat="server" ErrorMessage="Inserire una data nell'intervallo </br> 01/01/1900 e 01/01/3000" Display="Dynamic"></asp:RangeValidator>
                                            </div>
                                        </div>
                                        <div class="form-group form-group-sm">
                                            <div class="col-sm-12">
                                                <asp:Button ID="cmdCerca" runat="server" Text="Applica Filtro" CssClass="btn btn-primary btn-block btn-sm" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <asp:ObjectDataSource ID="DataSourcePrestazioniMatrice" runat="server"
        SelectMethod="GetData" TypeName="DwhClinico.Web.CustomDataSource.MatricePrestazioniLabCercaPerSezioneCodice" OldValuesParameterFormatString="original_{0}">
        <SelectParameters>
            <asp:Parameter Name="Token" Type="Object" />
            <asp:Parameter Name="Ordinamento" Type="String" />
            <asp:Parameter DbType="Guid" Name="IdPaziente"></asp:Parameter>
            <asp:Parameter Name="DallaData" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="AllaData" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="ByPassaConsenso" Type="Boolean" />
            <asp:Parameter Name="PrestazioneCodice" Type="String" />
            <asp:Parameter Name="SezioneCodice" Type="String"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <script type="text/javascript">
        //CREO I BOOTSTRAP DATETIMEPICKER.
        $('.form-control-dataPicker').datepicker({
            format: "dd/mm/yyyy",
            weekStart: 1,
            language: "it",
            todayHighlight: true,
            todayBtn: "linked",
            orientation: "bottom left"
        });
    </script>
</asp:Content>
