CREATE TABLE [dbo].[EsenzioniEventi] (
    [Id]             UNIQUEIDENTIFIER CONSTRAINT [DF_EsenzioniEventi_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [DataOperazione] DATETIME         CONSTRAINT [DF_EsenzioniEventi_DataOperazione] DEFAULT (getdate()) NOT NULL,
    [Operazione]     TINYINT          NOT NULL,
    [Codice]         INT              CONSTRAINT [DF_EsenzioniEventi_Codice] DEFAULT ((0)) NOT NULL,
    [Oggetto]        VARCHAR (64)     NOT NULL,
    [Utente]         VARCHAR (64)     NOT NULL,
    [Messaggio]      VARCHAR (1024)   NOT NULL,
    CONSTRAINT [PK_EsenzioniEventi] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_EsenzioniEventi_EventiOperazione] FOREIGN KEY ([Operazione]) REFERENCES [dbo].[EventiOperazione] ([Id]) NOT FOR REPLICATION
);


GO
CREATE CLUSTERED INDEX [IX_DataOperazione]
    ON [dbo].[EsenzioniEventi]([DataOperazione] ASC) WITH (FILLFACTOR = 70);

