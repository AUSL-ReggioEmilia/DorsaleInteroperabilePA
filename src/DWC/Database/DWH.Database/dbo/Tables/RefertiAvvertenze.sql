CREATE TABLE [dbo].[RefertiAvvertenze] (
    [Id]                UNIQUEIDENTIFIER CONSTRAINT [DF_RefertiAvvertenze_Id] DEFAULT (newid()) NOT NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_RefertiAvvertenze_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_RefertiAvvertenze_DataModifica] DEFAULT (getdate()) NOT NULL,
    [UtenteModifica]    VARCHAR (64)     CONSTRAINT [DF_RefertiAvvertenze_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    [UtenteInserimento] VARCHAR (64)     CONSTRAINT [DF_RefertiAvvertenze_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [Nome]              VARCHAR (64)     NOT NULL,
    [AziendaErogante]   VARCHAR (16)     NOT NULL,
    [SistemaErogante]   VARCHAR (16)     NOT NULL,
    [Priorita]          TINYINT          CONSTRAINT [DF_RefertiAvvertenze_Priorita] DEFAULT ((0)) NOT NULL,
    [Query]             VARCHAR (MAX)    NOT NULL,
    [Risultato]         VARCHAR (1024)   NOT NULL,
    [Note]              VARCHAR (1024)   NOT NULL,
    [Severita]          TINYINT          CONSTRAINT [DF_RefertiAvvertenze_Severita] DEFAULT ((0)) NOT NULL,
    [Abilitata]         BIT              CONSTRAINT [DF_RefertiAvvertenze_Abilitata] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_RefertiAvvertenze] PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_Table_SistemaAzienda]
    ON [dbo].[RefertiAvvertenze]([AziendaErogante] ASC, [SistemaErogante] ASC);

