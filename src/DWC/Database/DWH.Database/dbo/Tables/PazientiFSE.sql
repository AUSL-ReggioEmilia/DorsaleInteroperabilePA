CREATE TABLE [dbo].[PazientiFSE] (
    [IdPaziente]          UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]     DATETIME         CONSTRAINT [DF_PazientiFSE_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [AbilitazioneFSE]     TINYINT          NULL,
    [DataAbilitazioneFSE] DATETIME         NULL,
    [ListaDocumenti]      XML              NULL,
    [DataListaDocumenti]  DATETIME         NULL,
    CONSTRAINT [PK_PazientiFSE] PRIMARY KEY CLUSTERED ([IdPaziente] ASC) WITH (FILLFACTOR = 90)
);

