<%@ Page Title="Tipi Referto" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="TipiRefertoLista.aspx.vb"
    Inherits=".TipiRefertoLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />

    <div style="padding: 3px">
        <asp:Button ID="NewButton" CssClass="newbutton" runat="server" Text="Nuovo" TabIndex="10" Width="80px" />
    </div>
    <fieldset runat="server" id="pannelloFiltri" class="filters">
        <legend>Ricerca</legend>
        <div>
            <span>Codice Sistema Erogante</span><br />
            <asp:TextBox ID="txtFiltriSistemaErogante" runat="server" Width="150px"></asp:TextBox>
        </div>
        <div>
            <span>Azienda Erogante</span><br />
            <%--  <asp:DropDownList ID="cmbAziendaErogante" runat="server" Width="150px">
                <asp:ListItem Text="" Value="" />
                <asp:ListItem Text="ASMN" Value="ASMN" />
                <asp:ListItem Text="AUSL" Value="AUSL" />
            </asp:DropDownList>--%>
            <asp:DropDownList ID="cmbAziendaErogante" runat="server" DataSourceID="AziendeObjectDataSource" DataTextField="Descrizione"
                DataValueField="Codice" Width="210px">
            </asp:DropDownList>
            <asp:ObjectDataSource ID="AziendeObjectDataSource" runat="server" SelectMethod="GetData"
                TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.AziendeErogantiListaTableAdapter"
                OldValuesParameterFormatString="{0}" EnableCaching="true" CacheDuration="120"></asp:ObjectDataSource>
        </div>
        <div>
            <br />
            <asp:Button CssClass="Button" ID="butFiltriRicerca" runat="server" Text="Cerca" />
        </div>
    </fieldset>

    <asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="true" AutoGenerateColumns="False"
        PageSize="100" CssClass="Grid" Width="700px" EmptyDataText="Nessun risultato!"
        PagerSettings-Position="TopAndBottom" DataKeyNames="Id" DataSourceID="odsLista">
        <Columns>
            <asp:TemplateField HeaderText="">
                <ItemStyle Width="30px" />
                <ItemTemplate>
                    <a href='<%# String.Format("TipiRefertoDettaglio.aspx?Id={0}", Eval("Id")) %>'>
                        <img src='../Images/detail.png' alt="Vai al dettaglio…" title="Vai al dettaglio…" /></a>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:ImageField DataImageUrlField="Id" DataImageUrlFormatString="~/ImageHandler.ashx?resourcetype=tiporeferto&id={0}" HeaderText="Icona" />
            <asp:BoundField DataField="AziendaErogante" HeaderText="Azienda Erogante" SortExpression="AziendaErogante"></asp:BoundField>
            <asp:BoundField DataField="SistemaErogante" HeaderText="Sistema Erogante" SortExpression="SistemaErogante"></asp:BoundField>
            <asp:BoundField DataField="SpecialitaErogante" HeaderText="Specialità Erogante" SortExpression="SpecialitaErogante"></asp:BoundField>
            <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
            <asp:BoundField DataField="Ordinamento" HeaderText="Ordinamento" SortExpression="Ordinamento"></asp:BoundField>
        </Columns>
        <RowStyle CssClass="GridItem" />
        <SelectedRowStyle CssClass="GridSelected" />
        <PagerSettings Position="TopAndBottom"></PagerSettings>
        <PagerStyle CssClass="GridPager" />
        <HeaderStyle CssClass="GridHeader" />
        <AlternatingRowStyle CssClass="GridAlternatingItem" />
        <FooterStyle CssClass="GridFooter" />
    </asp:GridView>

    <asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" OldValuesParameterFormatString="original_{0}"
        TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.TipiRefertoTableAdapter" DataObjectTypeName="System.Nullable`1[[System.Guid, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]]" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
        <SelectParameters>
            <asp:ControlParameter ControlID="txtFiltriSistemaErogante" PropertyName="Text" Name="SistemaErogante" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="cmbAziendaErogante" PropertyName="SelectedValue" Name="AziendaErogante" Type="String"></asp:ControlParameter>
        </SelectParameters>
    </asp:ObjectDataSource>

</asp:Content>
