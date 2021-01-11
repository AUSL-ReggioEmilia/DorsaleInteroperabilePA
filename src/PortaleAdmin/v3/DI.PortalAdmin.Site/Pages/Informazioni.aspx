<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="Informazioni.aspx.vb" Inherits=".Informazioni" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    
    <div class="col-sm-12">
        <h1>Informazioni sul dispositivo medico</h1>
    </div>

    <div class="col-sm-8 col-sm-offset-2">

        <%--Vecchia implementazione--%>
        <%--<asp:DataList runat="server" ID="dlListaChiavi" DataSourceID="odsChiavi" RepeatLayout="Flow">
            <ItemTemplate>
                <h4 class="page-header">
                    <%# Container.DataItem %>
                </h4>

                <div class="table-responsive">
                    <asp:GridView ID="dtConfigurazioni" runat="server" AutoGenerateColumns="False" DataKeyNames="Sessione,Chiave" DataSourceID="odsInfoDispositivoMedico" ShowHeader="false" CssClass="table table-bordered" Style="margin-bottom: 0px !important;">
                        <Columns>
                            <asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome" ItemStyle-CssClass="active" ItemStyle-Font-Bold="true" ItemStyle-Width="30%"></asp:BoundField>
                            <asp:BoundField DataField="Valore" HeaderText="Valore" SortExpression="Valore"></asp:BoundField>
                        </Columns>
                    </asp:GridView>

                    <asp:ObjectDataSource runat="server" ID="odsInfoDispositivoMedico" OldValuesParameterFormatString="{0}" SelectMethod="GetDataByChiave" TypeName="Informazioni">
                        <SelectParameters>
                            <asp:Parameter Name="Chiave" Type="String"></asp:Parameter>
                        </SelectParameters>
                    </asp:ObjectDataSource>
                </div>
            </ItemTemplate>
        </asp:DataList>
    <asp:ObjectDataSource ID="odsChiavi" runat="server" SelectMethod="GetChiavi"
        TypeName="Informazioni"></asp:ObjectDataSource>
        --%>


        <%-- Fabbricante --%>
        <h4 class="page-header">Fabbricante</h4>
        <table class="table table-bordered" style="margin-bottom: 0">
            <tr>
                <td style="width: 60px">
                    <img src="../Images/Fabbrica_Icona.png" style="width: 40px" /></td>
                <td style="width: 22%; vertical-align: middle" class="active">Ragione sociale</td>
                <td style="font-weight: bold; vertical-align: middle">PROGEL S.p.a</td>
            </tr>
            <tr>
                <td style="width: 60px"></td>
                <td style="width: 22%" class="active">Indirizzo</td>
                <td style="font-weight: bold">Sede Legale - Via due ponti 2, 40050 Argelato (BO)</td>
            </tr>
        </table>

        <%-- Dispositivo --%>
        <h4 class="page-header">Dispositivo</h4>
        <table class="table table-bordered">
            <tr>
                <td style="width: 60px"></td>
                <td style="width: 22%" class="active">Nome</td>
                <td style="font-weight: bold">Dorsale Interoperabile</td>
            </tr>
            <tr>
                <td style="width: 60px"></td>
                <td style="width: 22%" class="active">Codice prodotto</td>
                <td style="font-weight: bold">8055060650001</td>
            </tr>
        </table>

        <%-- Codice a Barre --%>
        <div class="col-sm-12">
            <img src="../Images/barcode-8055060650001.png" class="center-block" style="margin: 14px auto" />
        </div>

        <asp:GridView ID="GvDispositivo" runat="server" AutoGenerateColumns="False" ShowHeader="false" CssClass="table table-bordered" Style="margin-bottom: 0px !important;">
            <Columns>

                <asp:TemplateField>
                    <ItemTemplate>
                        <%-- Vuota per le icone / indentazione --%>
                    </ItemTemplate>
                    <ItemStyle Width="60px" />
                </asp:TemplateField>

                <asp:BoundField DataField="Nome" ItemStyle-CssClass="active" ItemStyle-Width="22%"></asp:BoundField>
                <asp:BoundField DataField="Valore" ItemStyle-Font-Bold="true"></asp:BoundField>

            </Columns>
        </asp:GridView>
    </div>

    <%-- Marchio CE --%>
    <div class="col-sm-12">
        <img src="../Images/Marchio_CE.png" class="center-block" style="margin-top: 50px" />
    </div>


</asp:Content>

