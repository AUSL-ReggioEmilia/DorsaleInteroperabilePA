CREATE TABLE [ara].[AnagraficheCercate] (
    [IdSac]           UNIQUEIDENTIFIER CONSTRAINT [DF_AnagraficheCercate_IdSac] DEFAULT (newid()) NOT NULL,
    [IdProvenienza]   VARCHAR (64)     NOT NULL,
    [DataInserimento] DATETIME         CONSTRAINT [DF_AnagraficheCercate_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataRisposta]    DATETIME         CONSTRAINT [DF_AnagraficheCercate_DataRisposta] DEFAULT (getutcdate()) NOT NULL,
    [Risposta]        VARBINARY (MAX)  NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_DataRisposta]
    ON [ara].[AnagraficheCercate]([DataRisposta] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_IdProvenienza]
    ON [ara].[AnagraficheCercate]([IdProvenienza] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_IdSac]
    ON [ara].[AnagraficheCercate]([IdSac] ASC);


GO
CREATE UNIQUE CLUSTERED INDEX [PK_AnagraficheCercate]
    ON [ara].[AnagraficheCercate]([DataInserimento] ASC, [IdSac] ASC);

