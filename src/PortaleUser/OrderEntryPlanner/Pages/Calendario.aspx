<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Calendario.aspx.cs" Inherits="OrderEntryPlanner.Pages.Calendario" %>

<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        .fc-title {
            cursor: pointer;
        }

        .control-label {
            text-align: right !important;
        }
    </style>

    <%-- questo div viene posizionato all'interno del calendario da typescript --%>
    <div class="row"  id="divSistema" style="margin-top:10px">
        <div class="col-sm-12">
            <div class="form-horizontal">
                <div class="form-group form-group-sm">
                    <label class="col-sm-2 control-label" style="text-align: right !important;" for="ddlSistema">Sistema:</label>
                    <div class="col-sm-10">
                        <asp:DropDownList ID="ddlSistema" OnPreRender="ddlSistema_PreRender" onchange="aggiornaEventi(this);" ClientIDMode="Static" runat="server" CssClass="form-control" DataSourceID="odsSistema" DataTextField="Value" DataValueField="Key"></asp:DropDownList>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <asp:ObjectDataSource runat="server" ID="odsSistema" OldValuesParameterFormatString="{0}" SelectMethod="getData" TypeName="OrderEntryPlanner.Components.CustomDataSource+SistemiErogantiTableAdapter" />

    <div class="row" style="position: sticky">
        <div class="col-sm-10">
            <!-- Calendario -->
            <div id="calendario">
            </div>
        </div>
        <div class="col-sm-2">
            <div class="page-header">
                <h4 style="font-weight: 600 !important">Ordini da programmare</h4>
            </div>

            <!-- Lista degli ordini da riprogrammare !-->
            <div id="divOrdiniDaRiprogrammare" class="panel-body-ordini-nonprogrammati external-events">
                Nessun ordine
            </div>
        </div>
    </div>
</asp:Content>
