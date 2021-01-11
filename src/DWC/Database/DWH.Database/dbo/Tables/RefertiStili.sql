CREATE TABLE [dbo].[RefertiStili] (
    [Id]                   UNIQUEIDENTIFIER CONSTRAINT [DF_RefertiStili_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [Nome]                 VARCHAR (64)     NOT NULL,
    [Abilitato]            BIT              CONSTRAINT [DF_RefertiStili_Abilitato] DEFAULT ((0)) NOT NULL,
    [Descrizione]          VARCHAR (50)     NOT NULL,
    [Note]                 VARCHAR (200)    NULL,
    [PaginaWeb]            VARCHAR (255)    NOT NULL,
    [Parametri]            VARCHAR (255)    NOT NULL,
    [Tipo]                 INT              CONSTRAINT [DF_RefertiStili_Tipo] DEFAULT ((2)) NOT NULL,
    [XsltTestata]          VARCHAR (MAX)    NULL,
    [XsltRighe]            VARCHAR (MAX)    NULL,
    [XsltAllegatoXml]      VARCHAR (MAX)    NULL,
    [NomeFileAllegatoXml]  VARCHAR (255)    NULL,
    [ShowLinkDocumentoPdf] BIT              CONSTRAINT [DF_RefertiStili_ShowLinkDocumentoPdf] DEFAULT ((0)) NOT NULL,
    [ShowAllegatoRTF]      BIT              CONSTRAINT [DF_RefertiStili_ShowAllegatoRTF] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_RefertiStili] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);






GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_RefertiStili_NomeAbilitato]
    ON [dbo].[RefertiStili]([Nome] ASC, [Abilitato] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RefertiStili', @level2type = N'COLUMN', @level2name = N'Nome';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=InternoWs2, 2=Esterno (da Visualizzazioni), 3=PDF, 4=InternoWs3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RefertiStili', @level2type = N'COLUMN', @level2name = N'Tipo';



