<%@ Register TagPrefix="uc2" TagName="StiliDettaglio1" Src="StiliDettaglio1.ascx" %>

<%@ Page Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeBehind="StiliDettaglio.aspx.vb"
  Inherits="DI.DataWarehouse.Admin.StiliDettaglio" Title="Untitled Page" ValidateRequest="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="Server">
  <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
    Visible="False"></asp:Label>
  <table id="Table1" cellspacing="0" cellpadding="0" border="0">
    <tr>
      <td align="left">
        &nbsp;
      </td>
    </tr>
    <tr height="100%">
      <td class="TabContentNoButton" valign="top">
        <div style="overflow: auto;>
          <uc2:StiliDettaglio1 ID="StiliGenerale" runat="server"></uc2:StiliDettaglio1>
        </div>
      </td>
    </tr>
    <tr><td><br /><br /></td></tr>
    <tr>
      <td>
        <table cellspacing="0" cellpadding="0" width="100%" border="0">
          <tr>
            <td>
              <table cellspacing="1" cellpadding="1" border="0">
                <tr>
                  <td>
                    <asp:Button ID="EliminaButton" CssClass="Button" runat="server" Text="Elimina"></asp:Button>
                  </td>
                  <td>
                  </td>
                </tr>
              </table>
            </td>
            <td align="right">
              <table cellspacing="1" cellpadding="1" border="0">
                <tr>
                  <td align="right" width="80">
                    <asp:Button ID="OkButton" CssClass="Button" runat="server" Text="OK"></asp:Button>
                  </td>
                  <td align="right" width="80">
                    <asp:Button ID="RitornaButton" CssClass="Button" runat="server" Text="Annulla"></asp:Button>
                  </td>
                  <td align="right" width="80">
                    <asp:Button ID="ApplicaButton" CssClass="Button" runat="server" Text="Applica"></asp:Button>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</asp:Content>
