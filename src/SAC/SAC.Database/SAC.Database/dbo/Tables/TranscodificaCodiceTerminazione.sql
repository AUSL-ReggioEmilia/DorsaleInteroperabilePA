CREATE TABLE [dbo].[TranscodificaCodiceTerminazione] (
    [Id]            UNIQUEIDENTIFIER CONSTRAINT [DF_TranscodificaCodiceTerminazione_Id] DEFAULT (newid()) NOT NULL,
    [Provenienza]   VARCHAR (16)     NOT NULL,
    [CodiceEsterno] VARCHAR (8)      NOT NULL,
    [Codice]        VARCHAR (8)      NOT NULL,
    [Descrizione]   VARCHAR (64)     NOT NULL,
    CONSTRAINT [PK_TranscodificaCodiceTerminazione] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TranscodificaCodiceTerminazione_ProvenienzaCodiceEsterno]
    ON [dbo].[TranscodificaCodiceTerminazione]([Provenienza] ASC, [CodiceEsterno] ASC);

