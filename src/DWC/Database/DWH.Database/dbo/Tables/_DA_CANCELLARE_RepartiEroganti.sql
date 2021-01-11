CREATE TABLE [dbo].[_DA_CANCELLARE_RepartiEroganti] (
    [Id]              UNIQUEIDENTIFIER CONSTRAINT [DF_RepartiEroganti_Id] DEFAULT (newid()) NOT NULL,
    [AziendaErogante] VARCHAR (16)     NOT NULL,
    [RepartoErogante] VARCHAR (64)     NOT NULL,
    [Descrizione]     VARCHAR (200)    NULL,
    [RuoloManager]    VARCHAR (200)    NULL,
    [EventoSingolo]   BIT              CONSTRAINT [DF_RepartiEroganti_EventoSingolo] DEFAULT ((0)) NOT NULL,
    [SistemaErogante] VARCHAR (16)     CONSTRAINT [DF_RepartiEroganti_SistemaErogante] DEFAULT ('') NOT NULL,
    [DaVisualizzare]  BIT              CONSTRAINT [DF_RepartiEroganti_DaVisualizzare] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_RepartiEroganti] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [CK_RepartiEroganti_AziendaErogante] CHECK ([AziendaErogante]='ASMN' OR [AziendaErogante]='AUSL')
);


GO
CREATE UNIQUE CLUSTERED INDEX [UX_RepartiEroganti_AziendaErogante_RepartoErogante]
    ON [dbo].[_DA_CANCELLARE_RepartiEroganti]([AziendaErogante] ASC, [SistemaErogante] ASC, [RepartoErogante] ASC) WITH (FILLFACTOR = 95);

