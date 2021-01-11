CREATE TABLE [organigramma].[Eventi] (
    [Id]             UNIQUEIDENTIFIER CONSTRAINT [DF_Eventi_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [DataOperazione] DATETIME         CONSTRAINT [DF_Eventi_DataOperazione] DEFAULT (getdate()) NOT NULL,
    [Operazione]     TINYINT          NOT NULL,
    [Codice]         INT              CONSTRAINT [DF_Eventi_Codice] DEFAULT ((0)) NOT NULL,
    [Oggetto]        VARCHAR (64)     NOT NULL,
    [Utente]         VARCHAR (64)     NOT NULL,
    [Messaggio]      VARCHAR (1024)   NOT NULL,
    CONSTRAINT [PK_Eventi] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_Eventi_EventiOperazione] FOREIGN KEY ([Operazione]) REFERENCES [dbo].[EventiOperazione] ([Id]) NOT FOR REPLICATION
);


GO
CREATE CLUSTERED INDEX [IX_DataOperazione]
    ON [organigramma].[Eventi]([DataOperazione] ASC) WITH (FILLFACTOR = 95);

