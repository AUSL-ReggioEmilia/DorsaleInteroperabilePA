<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>
  <xsl:template match="/">
    <html>
      <head>
        <title>Dwh-Clinico</title>
        <style>
          .Background	{background-color: white;}
          .Field {font-size: 9pt;	font-weight: bold;font-family: Verdana, Arial, Helvetica;}
          .FieldValue	{font-size: 9pt;font-family: Verdana, Arial, Helvetica;}
          .Title {font-size: 10pt; color: black;font-family: Verdana, Arial, Helvetica;}
          .Message {font-size: 9pt; font-family: Verdana, Arial, Helvetica;}
          .MessageBold {font-size: 9pt; font-family: Verdana, Arial, Helvetica;  font: bold;}
          .Form {width: 80%; margin: 0; border-top: Gray 1px solid; border-left: Gray 1px solid;
          border-right: Gray 1px solid; border-bottom: Gray 1px solid; padding-top: 10px;
          padding-left: 10px; padding-right: 10px; padding-bottom: 10px; background-color: whitesmoke;}
          .Header { font-size: 14pt; color: #000000; border-top: #000000 1px solid; border-left: #000000 1px solid;
          border-right: #000000 1px solid; border-bottom: #000000 1px solid; background-color: Silver;
          font-family: Verdana, Arial, Helvetica;	}
          .HeaderSeparetor {background-color: Gray;height:2}
          .Footer {font-size: 7pt; color: #C00000; background-color: silver; text-align: center; font-family: Verdana, Arial, Helvetica;}
          .Title1 {font-size: 11pt; color: black;font-family: Verdana, Arial, Helvetica; font: bold;}
        </style>
      </head>
      <body class="Background">
        <table id="TableHeader" cellSpacing="0" cellPadding="4" width="100%" border="0">
          <tr>
            <td class="Header">Dwh-Clinico</td>
          </tr>
          <tr>
            <td class="title" vAlign="bottom">Nuovo messaggio</td>
          </tr>
          <tr>
            <td class="HeaderSeparetor"/>
          </tr>
          <tr>
            <td>
              <div align="center">
                <table class="Form" id="TblForm" cellSpacing="0" cellPadding="2" border="0">
                  <tr>
                    <td align="left">
                      <table class="Message" id="TblTestata" cellSpacing="0" cellPadding="2" border="0" >
                        <tr>
                          <td>
                            <xsl:value-of select="root/messaggio"/>
                          </td>
                        </tr>
                        <tr>
                          <td>
                            <hr></hr>

                            Condivisione
                            <!-- Creo il link al referto -->
                            <xsl:element name="a">
                              <xsl:attribute name="href">
                                <xsl:value-of select="root/link"/>
                              </xsl:attribute>
                              <xsl:attribute name="target">_blank</xsl:attribute>
                              Link al DWH
                            </xsl:element>
                            da
                            <strong>
                              <xsl:value-of select="root/mittente"/>
                            </strong>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                </table>
              </div>
            </td>
          </tr>
        </table>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
