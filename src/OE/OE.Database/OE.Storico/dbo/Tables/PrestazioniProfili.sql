﻿CREATE TABLE [dbo].[PrestazioniProfili] (
    [ID]       UNIQUEIDENTIFIER NOT NULL,
    [IDPadre]  UNIQUEIDENTIFIER NOT NULL,
    [IDFiglio] UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_PrestazioniProfili] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IXC_IDPadreFigli]
    ON [dbo].[PrestazioniProfili]([IDPadre] ASC, [IDFiglio] ASC) WITH (FILLFACTOR = 70);
